#!/bin/bash

# GDSentry Self-Test Discovery Module
# Handles test file discovery and categorization
# Author: GDSentry Framework

# Global arrays for test organization
DISCOVERED_TESTS=()
TEST_CATEGORIES=(
    "meta" "core" "base_classes" "assertions"
    "test_types" "advanced" "integration"
    "performance" "regression" "end_to_end" "other"
)

# Discover all self-test files
discover_self_tests() {
    local test_files=()

    echo "🔍 Discovering test files..." >&2

    # Look for tests in the local tests directory
    if [ -d "tests" ]; then
        echo "🔍 Searching for tests in: tests/" >&2

        # Find all .gd test files in the tests directory structure
        while IFS= read -r -d '' file; do
            # Skip files in __pycache__ or .git directories
            if [[ "$file" != *"/__pycache__/"* ]] && [[ "$file" != *"/.git/"* ]]; then
                echo "🔍 Found test file: $file" >&2
                test_files+=("$file")
            fi
        done < <(find "tests" -name "*.gd" -type f -print0 2>/dev/null)
    else
        echo "❌ Tests directory not found" >&2
    fi

    # Store discovered tests globally
    DISCOVERED_TESTS=("${test_files[@]}")
    
    # Only output the actual file list to stdout (for command substitution)
    printf '%s\n' "${test_files[@]}"
}

# Function to get test category from path
get_test_category() {
    local test_file="$1"

    if [[ "$test_file" == *"meta/"* ]]; then
        echo "meta"
    elif [[ "$test_file" == *"core/"* ]]; then
        echo "core"
    elif [[ "$test_file" == *"base_classes/"* ]]; then
        echo "base_classes"
    elif [[ "$test_file" == *"assertions/"* ]]; then
        echo "assertions"
    elif [[ "$test_file" == *"test_types/"* ]]; then
        echo "test_types"
    elif [[ "$test_file" == *"advanced/"* ]]; then
        echo "advanced"
    elif [[ "$test_file" == *"integration/"* ]]; then
        echo "integration"
    elif [[ "$test_file" == *"performance/"* ]]; then
        echo "performance"
    elif [[ "$test_file" == *"regression/"* ]]; then
        echo "regression"
    elif [[ "$test_file" == *"end_to_end/"* ]]; then
        echo "end_to_end"
    else
        echo "other"
    fi
}

# Count tests by category
count_tests_by_category() {
    local test_files=("$@")
    
    # Initialize category counters
    local meta_count=0
    local core_count=0
    local base_classes_count=0
    local assertions_count=0
    local test_types_count=0
    local advanced_count=0
    local integration_count=0
    local performance_count=0
    local regression_count=0
    local end_to_end_count=0
    local other_count=0
    
    # Count tests by category
    for test_file in "${test_files[@]}"; do
        category=$(get_test_category "$test_file")
        case $category in
            "meta") ((meta_count++)) ;;
            "core") ((core_count++)) ;;
            "base_classes") ((base_classes_count++)) ;;
            "assertions") ((assertions_count++)) ;;
            "test_types") ((test_types_count++)) ;;
            "advanced") ((advanced_count++)) ;;
            "integration") ((integration_count++)) ;;
            "performance") ((performance_count++)) ;;
            "regression") ((regression_count++)) ;;
            "end_to_end") ((end_to_end_count++)) ;;
            *) ((other_count++)) ;;
        esac
    done
    
    # Export counts as global variables for use by other modules
    export CATEGORY_META_COUNT=$meta_count
    export CATEGORY_CORE_COUNT=$core_count
    export CATEGORY_BASE_CLASSES_COUNT=$base_classes_count
    export CATEGORY_ASSERTIONS_COUNT=$assertions_count
    export CATEGORY_TEST_TYPES_COUNT=$test_types_count
    export CATEGORY_ADVANCED_COUNT=$advanced_count
    export CATEGORY_INTEGRATION_COUNT=$integration_count
    export CATEGORY_PERFORMANCE_COUNT=$performance_count
    export CATEGORY_REGRESSION_COUNT=$regression_count
    export CATEGORY_END_TO_END_COUNT=$end_to_end_count
    export CATEGORY_OTHER_COUNT=$other_count
}

# Show test distribution by category
show_test_distribution() {
    local quiet_mode="$1"

    if [ "$quiet_mode" != "true" ]; then
        echo ""
        echo "📊 Test File Distribution by Category:"
        [ "${CATEGORY_META_COUNT:-0}" -gt 0 ] && echo "  • meta: $CATEGORY_META_COUNT test files"
        [ "${CATEGORY_CORE_COUNT:-0}" -gt 0 ] && echo "  • core: $CATEGORY_CORE_COUNT test files"
        [ "${CATEGORY_BASE_CLASSES_COUNT:-0}" -gt 0 ] && echo "  • base_classes: $CATEGORY_BASE_CLASSES_COUNT test files"
        [ "${CATEGORY_ASSERTIONS_COUNT:-0}" -gt 0 ] && echo "  • assertions: $CATEGORY_ASSERTIONS_COUNT test files"
        [ "${CATEGORY_TEST_TYPES_COUNT:-0}" -gt 0 ] && echo "  • test_types: $CATEGORY_TEST_TYPES_COUNT test files"
        [ "${CATEGORY_ADVANCED_COUNT:-0}" -gt 0 ] && echo "  • advanced: $CATEGORY_ADVANCED_COUNT test files"
        [ "${CATEGORY_INTEGRATION_COUNT:-0}" -gt 0 ] && echo "  • integration: $CATEGORY_INTEGRATION_COUNT test files"
        [ "${CATEGORY_PERFORMANCE_COUNT:-0}" -gt 0 ] && echo "  • performance: $CATEGORY_PERFORMANCE_COUNT test files"
        [ "${CATEGORY_REGRESSION_COUNT:-0}" -gt 0 ] && echo "  • regression: $CATEGORY_REGRESSION_COUNT test files"
        [ "${CATEGORY_END_TO_END_COUNT:-0}" -gt 0 ] && echo "  • end_to_end: $CATEGORY_END_TO_END_COUNT test files"
        [ "${CATEGORY_OTHER_COUNT:-0}" -gt 0 ] && echo "  • other: $CATEGORY_OTHER_COUNT test files"
    fi
}

# Filter tests based on selection criteria
filter_tests() {
    local all_tests=("$@")
    local filtered_tests=()

    # Get configuration values
    local selected_files=()
    while IFS= read -r line; do
        selected_files+=("$line")
    done < <(get_config_array "selected_files")

    local selected_categories=()
    while IFS= read -r line; do
        selected_categories+=("$line")
    done < <(get_config_array "selected_categories")

    local excluded_categories=()
    while IFS= read -r line; do
        excluded_categories+=("$line")
    done < <(get_config_array "excluded_categories")

    local file_pattern
    file_pattern=$(get_config "file_pattern")

    if [ ${#selected_files[@]} -gt 0 ]; then
        # If specific files are selected, only include those
        for selected_file in "${selected_files[@]}"; do
            for test_file in "${all_tests[@]}"; do
                if [[ "$test_file" == *"$selected_file"* ]]; then
                    filtered_tests+=("$test_file")
                fi
            done
        done
    else
        # Apply category and pattern filtering
        for test_file in "${all_tests[@]}"; do
            include_test=true

            # Check file pattern if specified
            if [ -n "$file_pattern" ]; then
                if [[ "$test_file" != $file_pattern ]]; then
                    include_test=false
                fi
            fi

            # Check category selection if specified
            if [ ${#selected_categories[@]} -gt 0 ]; then
                test_category=$(get_test_category "$test_file")
                category_selected=false
                for selected_cat in "${selected_categories[@]}"; do
                    if [[ "$test_category" == "$selected_cat" ]]; then
                        category_selected=true
                        break
                    fi
                done
                if [ "$category_selected" = false ]; then
                    include_test=false
                fi
            fi

            # Check category exclusion
            if [ ${#excluded_categories[@]} -gt 0 ]; then
                test_category=$(get_test_category "$test_file")
                for excluded_cat in "${excluded_categories[@]}"; do
                    if [[ "$test_category" == "$excluded_cat" ]]; then
                        include_test=false
                        break
                    fi
                done
            fi

            if [ "$include_test" = true ]; then
                filtered_tests+=("$test_file")
            fi
        done
    fi
    
    # Output filtered tests
    printf '%s\n' "${filtered_tests[@]}"
}

# Group tests by category for organized execution
group_tests_by_category() {
    local tests=("$@")
    
    for category in "${TEST_CATEGORIES[@]}"; do
        local category_tests=()
        for test_file in "${tests[@]}"; do
            if [[ "$(get_test_category "$test_file")" == "$category" ]]; then
                category_tests+=("$test_file")
            fi
        done
        
        if [ ${#category_tests[@]} -gt 0 ]; then
            echo "CATEGORY:$category"
            printf '%s\n' "${category_tests[@]}"
            echo "END_CATEGORY"
        fi
    done
}

# Get total category count
get_total_category_count() {
    echo $((
        ${CATEGORY_META_COUNT:-0} + 
        ${CATEGORY_CORE_COUNT:-0} + 
        ${CATEGORY_BASE_CLASSES_COUNT:-0} + 
        ${CATEGORY_ASSERTIONS_COUNT:-0} + 
        ${CATEGORY_TEST_TYPES_COUNT:-0} + 
        ${CATEGORY_ADVANCED_COUNT:-0} + 
        ${CATEGORY_INTEGRATION_COUNT:-0} + 
        ${CATEGORY_PERFORMANCE_COUNT:-0} + 
        ${CATEGORY_REGRESSION_COUNT:-0} + 
        ${CATEGORY_END_TO_END_COUNT:-0} + 
        ${CATEGORY_OTHER_COUNT:-0}
    ))
}
