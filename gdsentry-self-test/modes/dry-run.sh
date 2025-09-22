#!/bin/bash

# GDSentry Self-Test Dry Run Mode
# Shows what test files would be executed without running them
# Author: GDSentry Framework

# Execute dry run mode
execute_dry_run() {
    local all_tests=("$@")
    
    echo ""
    echo "🔍 DRY RUN MODE - No test files will be executed"
    echo ""

    # Show reporting configuration if enabled
    show_dry_run_reporting

    # Filter tests based on current configuration
    local filter_output
    filter_output=$(filter_tests "${all_tests[@]}")
    local filtered_tests=()
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            filtered_tests+=("$line")
        fi
    done <<< "$filter_output"
    local total_tests=${#filtered_tests[@]}

    # Show what would be executed
    show_dry_run_tests "${filtered_tests[@]}"
    
    # Show summary
    show_dry_run_summary "$total_tests"
    
    # Show tips
    show_dry_run_tips
    
    return 0
}

# Show tests that would be executed
show_dry_run_tests() {
    local tests=("$@")

    quiet_echo ""
    quiet_echo "🔍 DRY RUN - Tests that would be executed:"
    quiet_echo "=========================================="

    # Group tests by category
    local tests_by_category=()
    local category_counts=()
    local category_index=0

    # Initialize category arrays
    local categories=("meta" "core" "base_classes" "assertions" "test_types" "advanced" "integration" "other")
    for category in "${categories[@]}"; do
        tests_by_category[$category_index]=""
        category_counts[$category_index]=0
        ((category_index++))
    done

    # Group tests
    for test_file in "${tests[@]}"; do
        local test_name
        test_name=$(basename "$test_file")
        local category
        category=$(get_test_category "$test_file")
        local relative_path
        relative_path=$(echo "$test_file" | sed 's|tests/||')

        # Find category index
        for i in "${!categories[@]}"; do
            if [ "${categories[$i]}" = "$category" ]; then
                tests_by_category[$i]="${tests_by_category[$i]}$test_name ($relative_path)
"
                ((category_counts[$i]++))
                break
            fi
        done
    done

    # Display grouped tests
    for i in "${!categories[@]}"; do
        if [ "${category_counts[$i]}" -gt 0 ]; then
            local category="${categories[$i]}"
            local count="${category_counts[$i]}"
            local tests_list="${tests_by_category[$i]}"

            quiet_echo ""
            quiet_echo "📂 $category/ ($count test$( [ "$count" -ne 1 ] && echo "s" )):"
            quiet_echo "$(printf '%.0s─' {1..50})"

            # Show each test with details
            while IFS= read -r test_line; do
                if [ -n "$test_line" ]; then
                    local test_name
                    local relative_path
                    test_name=$(echo "$test_line" | cut -d'(' -f1 | xargs)
                    relative_path=$(echo "$test_line" | sed 's/.*(\(.*\))/\1/')

                    # Try to extract test description from file
                    local description=""
                    if [ -f "tests/$relative_path" ]; then
                        description=$(grep -m1 "test_description.*=" "tests/$relative_path" 2>/dev/null | sed 's/.*= "\(.*\)".*/\1/' || echo "")
                    fi

                    quiet_echo "  📋 $test_name"
                    if [ -n "$description" ]; then
                        quiet_echo "     └─ $description"
                    fi
                fi
            done <<< "$tests_list"
        fi
    done

    # Show execution order hint
    quiet_echo ""
    quiet_echo "📝 Execution Order:"
    for i in "${!categories[@]}"; do
        if [ "${category_counts[$i]}" -gt 0 ]; then
            quiet_echo "  $((i+1)). ${categories[$i]}/ (${category_counts[$i]} tests)"
        fi
    done
}

# Show dry run summary
show_dry_run_summary() {
    local total_tests="$1"
    
    quiet_echo ""
    quiet_echo "📊 Summary:"
    quiet_echo "  • Total test files: $total_tests"
    
    # Show categories that would be tested
    if has_config_values "selected_categories"; then
        local selected_categories=()
        while IFS= read -r line; do
            selected_categories+=("$line")
        done < <(get_config_array "selected_categories")
        local categories_str
        categories_str=$(IFS=,; echo "${selected_categories[*]}")
        quiet_echo "  • Selected categories: $categories_str"
    fi
    
    # Show file pattern if specified
    local file_pattern
    file_pattern=$(get_config "file_pattern")
    if [ -n "$file_pattern" ]; then
        quiet_echo "  • File pattern: $file_pattern"
    fi
    
    # Show excluded categories if any
    if has_config_values "excluded_categories"; then
        local excluded_categories=()
        while IFS= read -r line; do
            excluded_categories+=("$line")
        done < <(get_config_array "excluded_categories")
        local excluded_str
        excluded_str=$(IFS=,; echo "${excluded_categories[*]}")
        quiet_echo "  • Excluded categories: $excluded_str"
    fi
}

# Show dry run tips
show_dry_run_tips() {
    quiet_echo ""
    quiet_echo "💡 Use without --dry-run to actually execute these test files"
    
    # Show reporting tips if applicable
    show_dry_run_reporting_tips
}

# Handle discovery dry run (shows all discovered tests)
execute_discovery_dry_run() {
    local all_tests=("$@")
    
    echo ""
    echo "🔍 DRY RUN MODE - No test files will be executed"
    echo ""

    # Show reporting configuration if enabled
    show_dry_run_reporting

    # Discover and show tests
    discover_self_tests >&2
    
    echo ""
    echo "💡 Use without --dry-run to actually execute tests"
    show_dry_run_reporting_tips
    
    return 0
}
