#!/bin/bash

# GDSentry Self-Test Individual Mode
# Handles individual test execution (original behavior)
# Author: GDSentry Framework

# Execute individual tests mode
execute_individual_mode() {
    local all_tests=("$@")
    
    quiet_echo ""
    quiet_echo "🎯 Executing GDSentry Self-Tests"
    quiet_echo "=============================="

    # Initialize counters
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0

    # Filter tests based on selection criteria
    local filtered_tests=()
    while IFS= read -r line; do
        filtered_tests+=("$line")
    done < <(filter_tests "${all_tests[@]}")
    local total_tests=${#filtered_tests[@]}

    # Check if any tests match criteria
    if [ "$total_tests" -eq 0 ]; then
        show_no_tests_message
        return 0
    fi

    # Execute filtered tests by category for better organization
    execute_tests_by_category "${filtered_tests[@]}"
    local execution_result=$?
    
    # Get final counts (these should be set by execute_tests_by_category)
    passed_tests=${FINAL_PASSED_COUNT:-0}
    failed_tests=${FINAL_FAILED_COUNT:-0}
    skipped_tests=${FINAL_SKIPPED_COUNT:-0}

    # Display final summary
    show_final_summary "$total_tests" "$passed_tests" "$failed_tests" "$skipped_tests"

    # Generate reports if requested
    if is_reporting_enabled; then
        echo ""
        echo "📊 Generating reports..."
        if generate_reports "$total_tests" "$passed_tests" "$failed_tests" "$skipped_tests"; then
            echo "✅ Reports generated successfully"
        else
            echo "❌ Failed to generate reports"
        fi
    fi

    # Show success or failure message
    if [ "$failed_tests" -eq 0 ]; then
        show_success_message
        return $EX_SUCCESS
    else
        show_failure_message "$failed_tests"
        return $EX_TEST_FAILURE
    fi
}

# Execute tests organized by category
execute_tests_by_category() {
    local filtered_tests=("$@")
    local passed_tests=0
    local failed_tests=0
    local skipped_tests=0

    # Process tests grouped by category
    while IFS= read -r line; do
        if [[ "$line" == "CATEGORY:"* ]]; then
            # Extract category name
            local category="${line#CATEGORY:}"
            local category_tests=()
            
            # Read tests for this category
            while IFS= read -r test_line; do
                if [[ "$test_line" == "END_CATEGORY" ]]; then
                    break
                fi
                category_tests+=("$test_line")
            done
            
            # Execute tests in this category
            if [ ${#category_tests[@]} -gt 0 ]; then
                show_category_header "$category" "${#category_tests[@]}"
                
                for test_file in "${category_tests[@]}"; do
                    local test_name
                    test_name=$(basename "$test_file")

                    # Show progress
                    show_test_progress "$((passed_tests + failed_tests + skipped_tests + 1))" "${#filtered_tests[@]}" "$test_name"

                    # Track timing for verbose mode
                    local test_start_time=$(date +%s.%N)
                    local verbose_mode
                    verbose_mode=$(get_config "verbose")

                    # Execute the test
                    run_self_test "$test_file" "$verbose_mode"
                    local test_exit_code=$?
                    local test_end_time=$(date +%s.%N)

                    # Calculate test duration
                    local test_duration=$(echo "$test_end_time - $test_start_time" | bc 2>/dev/null || echo "0")

                    # Process result
                    if [ "$test_exit_code" -eq 0 ]; then
                        ((passed_tests++))
                        show_test_result "$test_name" 0 "$test_duration"
                    else
                        ((failed_tests++))
                        show_test_result "$test_name" 1 "$test_duration"

                        # Check stop conditions
                        if ! check_stop_conditions "$test_name" "$test_exit_code"; then
                            # Export final counts and exit early
                            export FINAL_PASSED_COUNT=$passed_tests
                            export FINAL_FAILED_COUNT=$failed_tests
                            export FINAL_SKIPPED_COUNT=$skipped_tests
                            return 1
                        fi
                    fi
                done
            fi
        fi
    done < <(group_tests_by_category "${filtered_tests[@]}")
    
    # Export final counts
    export FINAL_PASSED_COUNT=$passed_tests
    export FINAL_FAILED_COUNT=$failed_tests
    export FINAL_SKIPPED_COUNT=$skipped_tests
    
    return 0
}
