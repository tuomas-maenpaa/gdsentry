#!/bin/bash

# GDSentry Self-Test Reporter
# Handles report generation and integration
# Author: GDSentry Framework

# Build command line arguments for the test runner with reporting
build_runner_args() {
    local runner_args="--verbose"
    
        # Add selected files if specified (only run first file for now)
        if has_config_values "selected_files"; then
            local selected_files=()
            while IFS= read -r line; do
                selected_files+=("$line")
            done < <(get_config_array "selected_files")
            runner_args="$runner_args --file \"${selected_files[0]}\""
        else
        # Only use --discover when no specific file is selected
        runner_args="$runner_args --discover"
    fi

    # Add report path if specified
    local report_path
    report_path=$(get_config "report_path")
    if [ -n "$report_path" ]; then
        runner_args="$runner_args --report-path \"$report_path\""
    fi

    # Add selected categories if specified
    if has_config_values "selected_categories"; then
        local selected_categories=()
        while IFS= read -r line; do
            selected_categories+=("$line")
        done < <(get_config_array "selected_categories")
        local categories_str
        categories_str=$(IFS=,; echo "${selected_categories[*]}")
        runner_args="$runner_args --filter category:$categories_str"
    fi

    # Add reporting formats
    local report_formats
    report_formats=$(get_config "report_formats")
    runner_args="$runner_args --report \"$report_formats\""

    echo "$runner_args"
}

# Show reporting configuration
show_reporting_config() {
    local report_formats
    local report_path
    report_formats=$(get_config "report_formats")
    report_path=$(get_config "report_path")
    
    echo "📊 Running with reports: $report_formats"
    echo "📁 Report path: ${report_path:-res://test_reports/}"
}

# Execute tests with reporting enabled
execute_with_reporting_mode() {
    echo ""
    echo "🎯 Executing GDSentry Self-Tests with Reporting"
    echo "=============================================="

    # Validate report paths before proceeding
    if ! validate_report_paths; then
        echo "❌ Report path validation failed"
        return $EX_PERMISSION_ERROR
    fi

    # Build command line arguments for the test runner
    local runner_args
    runner_args=$(build_runner_args)

    # Show configuration
    show_reporting_config

    # For reporting mode, we need to ensure we run the same tests as individual mode
    # If no specific filtering was requested, run all discovered tests
    if [ "${#self_tests[@]}" -gt 0 ] && ! has_config_values "selected_files" && ! has_config_values "selected_categories" && ! has_config_values "excluded_categories" && [ -z "$(get_config "file_pattern")" ]; then
        echo "📋 Running all ${#self_tests[@]} discovered tests with reporting..."
        # Run each test individually with reporting enabled
        run_tests_with_reporting "${self_tests[@]}"
        return $?
    else
        # Use the test runner's built-in execution for filtered cases
        if execute_with_reporting "$runner_args"; then
            show_reporting_success
            return $EX_SUCCESS
        else
            show_reporting_failure
            return $EX_REPORT_ERROR
        fi
    fi
}

# Get the count of filtered tests for reporting
get_filtered_test_count() {
    echo "${#self_tests[@]}"
}

# Validate report paths and create directories
validate_report_paths() {
    local report_formats
    report_formats=$(get_config "report_formats")
    local report_path
    report_path=$(get_config "report_path")

    # Skip validation if no reporting enabled
    if [ -z "$report_formats" ]; then
        return 0
    fi

    # Convert res:// paths to local paths
    local local_report_path
    if [ -n "$report_path" ]; then
        local_report_path=$(echo "$report_path" | sed 's|res://||')
    else
        local_report_path="test_reports"
    fi

    # Check if path is absolute or relative
    if [[ "$local_report_path" != /* ]]; then
        # Relative path - make it relative to project root
        local_report_path="$local_report_path"
    fi

    # Validate and create directory
    if [ ! -d "$local_report_path" ]; then
        if ! mkdir -p "$local_report_path" 2>/dev/null; then
            echo "❌ Cannot create report directory: $local_report_path" >&2
            echo "   Please check permissions or specify a different path" >&2
            return 1
        fi
        echo "📁 Created report directory: $local_report_path"
    fi

    # Check if directory is writable
    if [ ! -w "$local_report_path" ]; then
        echo "❌ Report directory is not writable: $local_report_path" >&2
        echo "   Please check permissions or specify a different path" >&2
        return 1
    fi

    # Test creating a temporary file to ensure we can write
    local test_file="$local_report_path/.write_test.tmp"
    if ! touch "$test_file" 2>/dev/null; then
        echo "❌ Cannot write to report directory: $local_report_path" >&2
        echo "   Please check permissions or specify a different path" >&2
        return 1
    fi
    rm -f "$test_file"

    return 0
}

# Generate reports from individual mode results
generate_reports() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    local skipped_tests="$4"

    local report_formats
    report_formats=$(get_config "report_formats")
    local report_path
    report_path=$(get_config "report_path")

    if [ -z "$report_formats" ]; then
        return $EX_SUCCESS  # No reports to generate is not an error
    fi

    # Create report data structure
    local report_data
    report_data=$(build_report_data "$total_tests" "$passed_tests" "$failed_tests" "$skipped_tests")

    # Generate each requested format
    local IFS=,
    for format in $report_formats; do
        format=$(echo "$format" | xargs)  # trim whitespace
        case "$format" in
            json)
                generate_json_report "$report_data" "$report_path"
                ;;
            junit)
                generate_junit_report "$report_data" "$report_path"
                ;;
            html)
                generate_html_report "$report_data" "$report_path"
                ;;
            *)
                echo "⚠️  Unknown report format: $format" >&2
                ;;
        esac
    done

    return 0
}

# Build report data structure
build_report_data() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    local skipped_tests="$4"

    # This is a simplified version - in a real implementation you'd collect
    # detailed test results from each executed test
    cat << EOF
{
    "summary": {
        "total_tests": $total_tests,
        "passed_tests": $passed_tests,
        "failed_tests": $failed_tests,
        "skipped_tests": $skipped_tests,
        "execution_time": 0.0
    },
    "tests": []
}
EOF
}

# Generate JSON report
generate_json_report() {
    local report_data="$1"
    local report_path="$2"

    local output_path="${report_path:-res://test_reports/}/test_results.json"
    local local_path
    local_path=$(echo "$output_path" | sed 's|res://||')

    mkdir -p "$(dirname "$local_path")"
    echo "$report_data" > "$local_path"
}

# Generate JUnit XML report
generate_junit_report() {
    local report_data="$1"
    local report_path="$2"

    local output_path="${report_path:-res://test_reports/}/junit_report.xml"
    local local_path
    local_path=$(echo "$output_path" | sed 's|res://||')

    mkdir -p "$(dirname "$local_path")"

    # Extract data from JSON (simplified)
    local total_tests failed_tests
    total_tests=$(echo "$report_data" | grep -o '"total_tests": [0-9]*' | cut -d' ' -f2)
    failed_tests=$(echo "$report_data" | grep -o '"failed_tests": [0-9]*' | cut -d' ' -f2)

    cat > "$local_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
    <testsuite name="GDSentry Self-Tests" tests="$total_tests" failures="$failed_tests" time="0.0">
    </testsuite>
</testsuites>
EOF
}

# Generate HTML report
generate_html_report() {
    local report_data="$1"
    local report_path="$2"

    local output_path="${report_path:-res://test_reports/}/test_report.html"
    local local_path
    local_path=$(echo "$output_path" | sed 's|res://||')

    mkdir -p "$(dirname "$local_path")"

    # Extract data from JSON (simplified)
    local total_tests passed_tests failed_tests
    total_tests=$(echo "$report_data" | grep -o '"total_tests": [0-9]*' | cut -d' ' -f2)
    passed_tests=$(echo "$report_data" | grep -o '"passed_tests": [0-9]*' | cut -d' ' -f2)
    failed_tests=$(echo "$report_data" | grep -o '"failed_tests": [0-9]*' | cut -d' ' -f2)

    cat > "$local_path" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>GDSentry Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .summary { background: #f0f0f0; padding: 10px; border-radius: 5px; }
        .passed { color: green; }
        .failed { color: red; }
    </style>
</head>
<body>
    <h1>GDSentry Test Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p>Total Tests: $total_tests</p>
        <p class="passed">Passed: $passed_tests</p>
        <p class="failed">Failed: $failed_tests</p>
    </div>
</body>
</html>
EOF
}

# Run tests individually with reporting enabled
run_tests_with_reporting() {
    local tests=("$@")
    local total_tests=${#tests[@]}
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0

    echo "📊 Starting individual test execution with reporting..."

    for test_file in "${tests[@]}"; do
        local test_name
        test_name=$(basename "$test_file")

        echo ""
        echo "🧪 Running test: $test_name"

        # Run the test (similar to individual mode but capture results)
        if run_single_test_for_reporting "$test_file"; then
            ((passed_tests++))
            echo "✅ $test_name PASSED"
        else
            ((failed_tests++))
            echo "❌ $test_name FAILED"
        fi
    done

    echo ""
    echo "📊 Test execution completed"

    # Generate reports with the collected results
    if generate_reports "$total_tests" "$passed_tests" "$failed_tests" "$skipped_tests"; then
        show_reporting_success
        return $EX_SUCCESS
    else
        show_reporting_failure
        return $EX_REPORT_ERROR
    fi
}

# Run a single test for reporting (simplified version of individual test execution)
run_single_test_for_reporting() {
    local test_file="$1"

    # Use the existing run_self_test function but capture the result
    if run_self_test "$test_file" "false"; then
        return 0
    else
        return 1
    fi
}

# Show successful reporting completion
show_reporting_success() {
    if [ "$IS_PIPED" = "false" ]; then
        echo ""
        echo "✅ Test suite completed successfully with reports generated"
        echo "📊 Check the report directory for generated files"
    fi
}

# Show reporting failure
show_reporting_failure() {
    if [ "$IS_PIPED" = "false" ]; then
        echo ""
        echo "❌ Test suite failed - check reports for details"
    fi
}

# Handle dry run reporting preview
show_dry_run_reporting() {
    local report_formats
    local report_path
    report_formats=$(get_config "report_formats")
    report_path=$(get_config "report_path")
    
    if [ -n "$report_formats" ]; then
        echo "📊 Would generate reports in formats: $report_formats"
        echo "📁 Report path: ${report_path:-res://test_reports/}"
        echo ""
    fi
}

# Show dry run reporting tips
show_dry_run_reporting_tips() {
    local report_formats
    report_formats=$(get_config "report_formats")
    
    if [ -n "$report_formats" ]; then
        local report_path
        report_path=$(get_config "report_path")
        echo "💡 Reports will be generated in: ${report_path:-res://test_reports/}"
    fi
}

# Check if reporting mode is enabled
is_reporting_enabled() {
    local report_formats
    report_formats=$(get_config "report_formats")
    [ -n "$report_formats" ]
}

# Validate reporting configuration
validate_reporting_config() {
    local report_formats
    report_formats=$(get_config "report_formats")
    
    if [ -n "$report_formats" ]; then
        # Validate report formats
        IFS=',' read -ra formats <<< "$report_formats"
        for format in "${formats[@]}"; do
            case "$format" in
                json|junit|html)
                    # Valid format
                    ;;
                *)
                    echo "❌ Invalid report format: $format" >&2
                    echo "Valid formats: json, junit, html" >&2
                    return 1
                    ;;
            esac
        done
        
        # Validate report path if specified
        local report_path
        report_path=$(get_config "report_path")
        if [ -n "$report_path" ]; then
            # Check if directory exists or can be created
            local report_dir
            report_dir=$(dirname "$report_path")
            if [ ! -d "$report_dir" ]; then
                if ! mkdir -p "$report_dir" 2>/dev/null; then
                    echo "❌ Cannot create report directory: $report_dir" >&2
                    return 1
                fi
            fi
        fi
    fi
    
    return 0
}
