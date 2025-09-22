#!/bin/bash

# GDSentry Self-Test Output Processor
# Handles output processing and filtering
# Author: GDSentry Framework

# Check if output is being piped (to avoid broken pipe errors)
IS_PIPED=false
if [ ! -t 1 ]; then
    IS_PIPED=true
fi

# Helper function for quiet-aware output (also respects piping)
quiet_echo() {
    local quiet_mode
    quiet_mode=$(get_config "quiet")
    if [ "$quiet_mode" = "false" ] && [ "$IS_PIPED" = "false" ]; then
        echo "$@"
    fi
}

# Pre-process Godot output to suppress cosmetic errors
process_godot_output() {
    local output="$1"
    local verbose_mode="$2"
    local processed_output="$output"
    local suppressed_errors=""

    # Check for SceneTree attachment error and suppress it
    if echo "$output" | grep -q "Script inherits from native type 'SceneTree'"; then
        # Remove the SceneTree error from output
        processed_output=$(echo "$output" | grep -v "Script inherits from native type 'SceneTree'")
        suppressed_errors="${suppressed_errors}SceneTree attachment warning "
        if [ "$verbose_mode" = "true" ]; then
            echo "ℹ️ SceneTree attachment warning suppressed (non-critical)"
        fi
    fi

    echo "$processed_output"
}

# Show detailed output if verbose mode is enabled
show_verbose_output() {
    local output="$1"
    local verbose_mode
    verbose_mode=$(get_config "verbose")
    
    if [ "$verbose_mode" = "true" ]; then
        echo "📄 Godot Output:"
        echo "────────────────"
        echo "$output"
        echo "────────────────"
    fi
}

# Check for script errors in output
check_script_errors() {
    local output="$1"
    local verbose_mode="$2"
    
    if echo "$output" | grep -q "SCRIPT ERROR\|Parse Error\|Failed to load script"; then
        if [ "$verbose_mode" = "false" ]; then
            echo "$output"
        fi
        return 2  # Script error exit code
    fi
    return 0
}

# Check for test assertion failures
check_test_failures() {
    local output="$1"
    local verbose_mode="$2"
    
    if echo "$output" | grep -q "❌.*FAILED\|Status: FAILED"; then
        if [ "$verbose_mode" = "false" ]; then
            echo "$output"
        fi
        return 1  # Test failure exit code
    fi
    return 0
}

# Process and analyze test output
process_test_output() {
    local output="$1"
    local verbose_mode="$2"
    
    # Pre-process output to suppress cosmetic errors
    local processed_output
    processed_output=$(process_godot_output "$output" "$verbose_mode")
    
    # Show detailed output if verbose mode is enabled
    show_verbose_output "$processed_output"
    
    # Check for script errors (highest priority)
    if ! check_script_errors "$processed_output" "$verbose_mode"; then
        return 2
    fi
    
    # Check for test assertion failures
    if ! check_test_failures "$processed_output" "$verbose_mode"; then
        return 1
    fi
    
    return 0
}

# Filter reporting output to show meaningful results
filter_reporting_output() {
    local output="$1"
    
    # Filter to show the correct NODE - TEST RESULTS with accurate statistics
    echo "$output" | grep -A10 -B2 "^Total: [1-9]" | grep -v "^Total: 0"
}

# Check for specific error types in reporting mode
check_reporting_errors() {
    local output="$1"
    local stop_on_error
    stop_on_error=$(get_config "stop_on_error")
    
    if [ "$stop_on_error" = "true" ]; then
        # Check for script errors (parsing/compilation errors)
        if echo "$output" | grep -q "SCRIPT ERROR\|Parse Error\|Failed to load script\|Cannot get path of node\|Resource still in use at exit"; then
            echo ""
            echo "🛑 Stopping execution due to --stop-on-error flag"
            echo "❌ Script or system error detected during test execution"
            return 2
        fi
        
        # Check for reporter initialization errors
        if echo "$output" | grep -q "ReporterManager autoload not found\|Could not find type\|SCRIPT ERROR"; then
            echo ""
            echo "🛑 Stopping execution due to --stop-on-error flag"
            echo "❌ Reporter initialization error detected"
            return 2
        fi
    fi
    
    return 0
}

# Display test execution progress
show_test_progress() {
    local current="$1"
    local total="$2"
    local test_name="$3"

    # Calculate percentage
    local percentage=0
    if [ "$total" -gt 0 ]; then
        percentage=$((current * 100 / total))
    fi

    # Create progress bar (20 characters wide)
    local bar_width=20
    local filled=$((current * bar_width / total))
    local bar=""
    for ((i=1; i<=bar_width; i++)); do
        if [ "$i" -le "$filled" ]; then
            bar="${bar}█"
        else
            bar="${bar}░"
        fi
    done

    echo ""
    echo "[$current/$total] $percentage% |$bar| $test_name"
}

# Display test result
show_test_result() {
    local test_name="$1"
    local exit_code="$2"
    local duration="$3"

    if [ "$exit_code" -eq 0 ]; then
        quiet_echo "✅ $test_name PASSED"
    else
        echo "❌ $test_name FAILED"  # Always show failures
    fi

    # Show timing in verbose mode
    local verbose_mode
    verbose_mode=$(get_config "verbose")
    if [ "$verbose_mode" = "true" ] && [ -n "$duration" ]; then
        printf "   ⏱️  Execution time: %.2fs\n" "$duration"
    fi
}

# Display category header
show_category_header() {
    local category="$1"
    local count="$2"
    
    quiet_echo ""
    quiet_echo "📂 Running $category test files ($count files)"
    quiet_echo "────────────────────────────────────────────────────────"
}

# Display final summary
show_final_summary() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    local skipped_tests="$4"
    
    quiet_echo ""
    quiet_echo "📊 ENTERPRISE SELF-TEST SUMMARY"
    quiet_echo "==============================="
    quiet_echo "Total Self-Test Files: $total_tests"
    quiet_echo "Categories Tested: $(get_total_category_count)"
    quiet_echo ""
    quiet_echo "Results:"
    quiet_echo "  ✅ Passed: $passed_tests"
    echo "  ❌ Failed: $failed_tests"  # Always show failures
    quiet_echo "  ⏭️ Skipped: $skipped_tests"
    quiet_echo ""
}

# Display success message
show_success_message() {
    quiet_echo "🎉 ALL SELF-TESTS PASSED!"
    quiet_echo "✅ GDSentry Enterprise framework is working correctly"
    quiet_echo "🚀 The framework successfully validates itself"
    quiet_echo ""
    quiet_echo "🏆 Enterprise Features Validated:"
    quiet_echo "  • Core infrastructure (TestManager, TestDiscovery, TestConfig, TestRunner)"
    quiet_echo "  • Base classes (GDTest, SceneTreeTest, Node2DTest)"
    quiet_echo "  • Specialized test types (Visual, Event, UI, Physics, Integration, Performance)"
    quiet_echo "  • Advanced features (Visual regression, Memory leak detection, Video recording, Accessibility)"
    quiet_echo "  • Integration systems (CI/CD, IDE, Plugin system, External tools)"
    quiet_echo "  • Enterprise testing structure and organization"
}

# Display failure message
show_failure_message() {
    local failed_tests="$1"
    local stop_on_failure
    local stop_on_error
    stop_on_failure=$(get_config "stop_on_failure")
    stop_on_error=$(get_config "stop_on_error")
    
    echo "⚠️ $failed_tests SELF-TEST FILE(S) FAILED"  # Always show failures
    echo "This indicates issues with the GDSentry Enterprise framework"
    echo "Please check the framework implementation and test failures above"

    # Show early termination info if applicable
    if [ "$stop_on_failure" = "true" ] || [ "$stop_on_error" = "true" ]; then
        echo ""
        echo "ℹ️  Note: Execution was stopped early due to configured flags"
        if [ "$stop_on_failure" = "true" ]; then
            echo "   • --stop-on-failure was enabled"
        fi
        if [ "$stop_on_error" = "true" ]; then
            echo "   • --stop-on-error was enabled"
        fi
        echo "   • Run without flags to see all test results"
    fi

    echo ""
    echo "🔧 Debugging Tips:"
    echo "  • Check individual test output for specific error details"
    echo "  • Verify Godot 4.x compatibility"
    echo "  • Ensure all framework files are present and accessible"
    echo "  • Check for missing dependencies or circular imports"
    echo "  • Use --stop-on-failure or --stop-on-error for faster debugging"
}

# Display no tests found message
show_no_tests_message() {
    echo "⚠️ No test files match the specified selection criteria"
    echo ""
    echo "💡 Try these options:"
    echo "  --list-categories          # See available categories"
    echo "  --category core           # Run core test files"
    echo "  --pattern \"*test*\"       # Run test files with 'test' in name"
}

# Check stop conditions and handle early termination
check_stop_conditions() {
    local test_name="$1"
    local exit_code="$2"
    local stop_on_failure
    local stop_on_error
    stop_on_failure=$(get_config "stop_on_failure")
    stop_on_error=$(get_config "stop_on_error")
    
    # Check stop conditions
    if [ "$stop_on_failure" = "true" ] && [ "$exit_code" -ne 0 ]; then
        echo ""
        echo "🛑 Stopping execution due to --stop-on-failure flag"
        echo "❌ Test failure detected: $test_name"
        return 1  # Signal to stop execution
    fi

    # Check for parsing/compilation errors (exit code 2 = script error)
    if [ "$stop_on_error" = "true" ] && [ "$exit_code" -eq 2 ]; then
        echo ""
        echo "🛑 Stopping execution due to --stop-on-error flag"
        echo "❌ Script error detected: $test_name"
        echo "   Exit code: $exit_code (script parsing/compilation error)"
        return 1  # Signal to stop execution
    fi
    
    return 0  # Continue execution
}
