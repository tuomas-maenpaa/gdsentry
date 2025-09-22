#!/bin/bash

# GDSentry Self-Test Reporting Mode
# Handles test execution with report generation
# Author: GDSentry Framework

# Execute reporting mode
execute_reporting_mode() {
    # Validate reporting configuration
    if ! validate_reporting_config; then
        return 1
    fi

    # Apply filtering to test list (same as individual mode)
    local filtered_tests=()
    while IFS= read -r line; do
        filtered_tests+=("$line")
    done < <(filter_tests "${self_tests[@]}")

    # Store filtered tests for reporting
    self_tests=("${filtered_tests[@]}")

    # Execute tests with reporting
    if execute_with_reporting_mode; then
        return 0
    else
        return 1
    fi
}

# Check if we should use reporting mode
should_use_reporting_mode() {
    # Use reporting mode if report formats are specified AND no complex filtering is used
    if is_reporting_enabled; then
        # Don't use reporting mode if category filtering is involved (selected or excluded)
        if has_config_values "selected_categories" || has_config_values "excluded_categories"; then
            return 1
        fi
        # Don't use reporting mode if pattern filtering is used
        if [ -n "$(get_config "file_pattern")" ]; then
            return 1
        fi
        return 0
    fi

    if has_config_values "selected_files"; then
        return 0
    fi

    return 1
}
