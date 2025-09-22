#!/bin/bash

# GDSentry Self-Test Configuration Manager
# Handles CLI argument parsing and validation
# Author: GDSentry Framework

# Configuration structure (global variables)
CONFIG_STOP_ON_ERROR=false
CONFIG_STOP_ON_FAILURE=false
CONFIG_VERBOSE=false
CONFIG_QUIET=false
CONFIG_DRY_RUN=false
CONFIG_SELECTED_CATEGORIES=()
CONFIG_EXCLUDED_CATEGORIES=()
CONFIG_FILE_PATTERN=""
CONFIG_SELECTED_FILES=()
CONFIG_REPORT_FORMATS=""
CONFIG_REPORT_PATH=""

# Parse command-line arguments and populate configuration
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --stop-on-error)
                CONFIG_STOP_ON_ERROR=true
                echo "🛑 Stop on first error: ENABLED"
                shift
                ;;
            --stop-on-failure)
                CONFIG_STOP_ON_FAILURE=true
                echo "🛑 Stop on first failure: ENABLED"
                shift
                ;;
            --verbose|-v)
                CONFIG_VERBOSE=true
                echo "🔊 Verbose output: ENABLED"
                shift
                ;;
            --category|-c)
                IFS=',' read -ra CATS <<< "$2"
                for cat in "${CATS[@]}"; do
                    CONFIG_SELECTED_CATEGORIES+=("$cat")
                done
                echo "📂 Selected categories: ${CONFIG_SELECTED_CATEGORIES[*]}"
                shift 2
                ;;
            --exclude-category|-x)
                IFS=',' read -ra CATS <<< "$2"
                for cat in "${CATS[@]}"; do
                    CONFIG_EXCLUDED_CATEGORIES+=("$cat")
                done
                echo "🚫 Excluded categories: ${CONFIG_EXCLUDED_CATEGORIES[*]}"
                shift 2
                ;;
            --pattern|-p)
                CONFIG_FILE_PATTERN="$2"
                echo "🔍 File pattern: $CONFIG_FILE_PATTERN"
                shift 2
                ;;
            --file|-f)
                CONFIG_SELECTED_FILES+=("$2")
                echo "📄 Selected file: $2"
                shift 2
                ;;
            --quiet)
                CONFIG_QUIET=true
                echo "🤫 Quiet mode: ENABLED"
                shift
                ;;
            --dry-run)
                CONFIG_DRY_RUN=true
                echo "🔍 Dry run mode: ENABLED"
                shift
                ;;
            --report|-r)
                CONFIG_REPORT_FORMATS="$2"
                echo "📊 Report formats: $CONFIG_REPORT_FORMATS"
                shift 2
                ;;
            --report-path)
                CONFIG_REPORT_PATH="$2"
                echo "📁 Report output path: $CONFIG_REPORT_PATH"
                shift 2
                ;;
            --list-categories)
                show_categories
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --help|-h)
                show_help "$0"
                exit 0
                ;;
            *)
                echo "$0: unrecognized option '$1'" >&2
                echo "Try '$0 --help' for more information." >&2
                exit 64  # EX_USAGE - command used incorrectly
                ;;
        esac
    done
}

# Show available test categories
show_categories() {
    echo "📂 Available test categories:"
    echo "  • meta           - Meta-tests and framework validation"
    echo "  • core           - Core framework components"
    echo "  • base_classes   - Base test classes"
    echo "  • assertions     - Assertion libraries"
    echo "  • test_types     - Specialized test types"
    echo "  • advanced       - Advanced features"
    echo "  • integration    - Integration systems"
    echo "  • performance    - Performance tests"
    echo "  • regression     - Regression tests"
    echo "  • end_to_end     - End-to-end tests"
    echo "  • other          - Uncategorized tests"
}

# Show version information
show_version() {
    echo "GDSentry Self-Test Runner 2.0.0"
    echo "Author: GDSentry Framework"
}

# Show help message
show_help() {
    local script_name="$1"
    echo "Usage: $script_name [OPTIONS]"
    echo ""
    echo "Test Selection Options:"
    echo "  --category, -c CATEGORY     Run only specified category (comma-separated)"
    echo "  --exclude-category, -x CAT  Exclude specified category (comma-separated)"
    echo "  --pattern, -p PATTERN       Run tests matching glob pattern"
    echo "  --file, -f FILE             Run specific test file"
    echo "  --list-categories           List all available categories"
    echo ""
    echo "Execution Control Options:"
    echo "  --stop-on-error             Stop execution on first script parsing/compilation error"
    echo "  --stop-on-failure           Stop execution on first test failure (any non-zero exit)"
    echo "  --verbose, -v               Show detailed Godot output for each test execution"
    echo "  --quiet                     Suppress non-essential output (for CI/CD)"
    echo "  --dry-run                   Show tests that would run without executing them"
    echo ""
    echo "Reporting Options:"
    echo "  --report, -r FORMATS        Generate test reports (comma-separated: json,junit,html)"
    echo "  --report-path PATH          Specify output directory for reports (default: res://test_reports/)"
    echo ""
    echo "Information Options:"
    echo "  --version                   Show version information"
    echo "  --help, -h                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $script_name                                    # Run all tests"
    echo "  $script_name --category core                   # Run only core tests"
    echo "  $script_name --category meta,base_classes      # Run meta and base_classes tests"
    echo "  $script_name --exclude-category advanced       # Run all except advanced tests"
    echo "  $script_name --pattern \"*test*\"               # Run tests with 'test' in filename"
    echo "  $script_name --file tests/meta/gdsentry_self_test.gd  # Run specific test file"
    echo "  $script_name --stop-on-failure --category core # Stop on first failure in core tests"
    echo "  $script_name --verbose --category meta        # Show detailed Godot output for meta tests"
    echo "  $script_name -v --file tests/meta/gdsentry_self_test.gd  # Verbose output for specific test"
    echo "  $script_name --dry-run --category test_types # Show tests without running them"
    echo "  $script_name --quiet --category core         # Run quietly for CI/CD pipelines"
    echo "  $script_name --report json                    # Generate JSON report only"
    echo "  $script_name --report junit,html             # Generate JUnit XML and HTML reports"
    echo "  $script_name --report html --report-path ./reports  # Generate HTML report to custom directory"
    echo "  $script_name --category core --report json,junit,html  # Run core tests with all report formats"
}

# Validate configuration after parsing
validate_configuration() {
    # Check if Godot is available
    if ! command -v godot &> /dev/null; then
        echo "❌ Godot not found in PATH" >&2
        echo "Please ensure Godot 4.x is installed and in your PATH" >&2
        echo "💡 Install Godot from: https://godotengine.org/download" >&2
        return 5  # EX_GODOT_ERROR
    fi

    # Validate selected files exist and are readable
    if [[ ${#CONFIG_SELECTED_FILES[@]} -gt 0 ]]; then
        for file_path in "${CONFIG_SELECTED_FILES[@]}"; do
            if ! validate_test_file_path "$file_path"; then
                return 3  # EX_INVALID_ARGS
            fi
        done
    fi

    # Validate report path if specified
    if [[ -n "$CONFIG_REPORT_PATH" ]]; then
        if ! validate_report_path "$CONFIG_REPORT_PATH"; then
            return 3  # EX_INVALID_ARGS
        fi
    fi

    # Validate category combinations
    if [[ ${#CONFIG_SELECTED_CATEGORIES[@]} -gt 0 ]] && [[ ${#CONFIG_EXCLUDED_CATEGORIES[@]} -gt 0 ]]; then
        echo "❌ Cannot use both --category and --exclude-category options together" >&2
        echo "💡 Use either --category to select specific categories, or --exclude-category to exclude categories" >&2
        return 3  # EX_INVALID_ARGS
    fi

    # Validate report formats
    if [[ -n "$CONFIG_REPORT_FORMATS" ]]; then
        if ! validate_report_formats "$CONFIG_REPORT_FORMATS"; then
            return 3  # EX_INVALID_ARGS
        fi
    fi

    return 0
}

# Get configuration value by key
get_config() {
    local key="$1"
    case "$key" in
        "stop_on_error") echo "$CONFIG_STOP_ON_ERROR" ;;
        "stop_on_failure") echo "$CONFIG_STOP_ON_FAILURE" ;;
        "verbose") echo "$CONFIG_VERBOSE" ;;
        "quiet") echo "$CONFIG_QUIET" ;;
        "dry_run") echo "$CONFIG_DRY_RUN" ;;
        "file_pattern") echo "$CONFIG_FILE_PATTERN" ;;
        "report_formats") echo "$CONFIG_REPORT_FORMATS" ;;
        "report_path") echo "$CONFIG_REPORT_PATH" ;;
        *) echo "" ;;
    esac
}

# Get array configuration by key
get_config_array() {
    local key="$1"
    case "$key" in
        "selected_categories")
            if [ ${#CONFIG_SELECTED_CATEGORIES[@]} -gt 0 ]; then
                printf '%s\n' "${CONFIG_SELECTED_CATEGORIES[@]}"
            fi
            ;;
        "excluded_categories")
            if [ ${#CONFIG_EXCLUDED_CATEGORIES[@]} -gt 0 ]; then
                printf '%s\n' "${CONFIG_EXCLUDED_CATEGORIES[@]}"
            fi
            ;;
        "selected_files")
            if [ ${#CONFIG_SELECTED_FILES[@]} -gt 0 ]; then
                printf '%s\n' "${CONFIG_SELECTED_FILES[@]}"
            fi
            ;;
        *) ;;
    esac
}

# Check if configuration has values for array
has_config_values() {
    local key="$1"
    case "$key" in
        "selected_categories") [[ ${#CONFIG_SELECTED_CATEGORIES[@]} -gt 0 ]] ;;
        "excluded_categories") [[ ${#CONFIG_EXCLUDED_CATEGORIES[@]} -gt 0 ]] ;;
        "selected_files") [[ ${#CONFIG_SELECTED_FILES[@]} -gt 0 ]] ;;
        *) return 1 ;;
    esac
}

# ============================================================================
# PATH AND FILE VALIDATION FUNCTIONS
# ============================================================================

# Validate test file path
validate_test_file_path() {
    local file_path="$1"

    # Check if file path is provided
    if [[ -z "$file_path" ]]; then
        echo "❌ No file path specified" >&2
        echo "💡 Use: --file tests/category/test_file.gd" >&2
        return 1
    fi

    # Convert relative path to absolute if needed
    local abs_path="$file_path"
    if [[ "$file_path" != /* ]]; then
        # Check if GDSENTRY_DIR is available (from main script)
        if [[ -n "${GDSENTRY_DIR:-}" ]]; then
            abs_path="$GDSENTRY_DIR/$file_path"
        else
            abs_path="$(pwd)/$file_path"
        fi
    fi

    # Check if file exists
    if [[ ! -f "$abs_path" ]]; then
        echo "❌ Test file not found: $file_path" >&2
        echo "💡 Looking for: $abs_path" >&2
        echo "💡 Available test directories:" >&2

        # Show available test directories
        if [[ -n "${GDSENTRY_DIR:-}" ]] && [[ -d "${GDSENTRY_DIR:-}/tests" ]]; then
            echo "   📂 ${GDSENTRY_DIR}/tests/" >&2
            ls -1 "${GDSENTRY_DIR}/tests/" | head -10 | sed 's/^/     • /' >&2
            if [[ $(ls -1 "${GDSENTRY_DIR}/tests/" | wc -l) -gt 10 ]]; then
                echo "     ... and $(($(ls -1 "${GDSENTRY_DIR}/tests/" | wc -l) - 10)) more directories" >&2
            fi
        fi

        echo "💡 Use: --list-categories to see available test categories" >&2
        return 1
    fi

    # Check if file is readable
    if [[ ! -r "$abs_path" ]]; then
        echo "❌ Test file not readable: $file_path" >&2
        echo "💡 Check file permissions: $abs_path" >&2
        return 1
    fi

    # Check if file has .gd extension
    if [[ "$abs_path" != *.gd ]]; then
        echo "❌ File does not have .gd extension: $file_path" >&2
        echo "💡 GDSentry test files must have .gd extension" >&2
        return 1
    fi

    # Check if file contains test class
    if ! grep -q "extends.*Test\|class_name.*Test" "$abs_path" 2>/dev/null; then
        echo "⚠️  Warning: File may not contain a test class: $file_path" >&2
        echo "💡 GDSentry test files should extend SceneTreeTest, Node2DTest, etc." >&2
        # Don't return 1 here, just warn - let the user decide
    fi

    return 0
}

# Validate report path
validate_report_path() {
    local report_path="$1"

    # Check if path is provided
    if [[ -z "$report_path" ]]; then
        echo "❌ No report path specified" >&2
        echo "💡 Use: --report-path ./my-reports" >&2
        return 1
    fi

    # Convert to absolute path if relative
    local abs_path="$report_path"
    if [[ "$report_path" != /* ]]; then
        abs_path="$(pwd)/$report_path"
    fi

    # Check if path exists or can be created
    local parent_dir="$(dirname "$abs_path")"
    if [[ ! -d "$parent_dir" ]]; then
        echo "❌ Parent directory does not exist: $parent_dir" >&2
        echo "💡 Create the directory first or use an existing path" >&2
        return 1
    fi

    # Check if parent directory is writable
    if [[ ! -w "$parent_dir" ]]; then
        echo "❌ Cannot write to directory: $parent_dir" >&2
        echo "💡 Check directory permissions" >&2
        return 1
    fi

    return 0
}

# Validate report formats
validate_report_formats() {
    local formats="$1"

    # Check if formats are provided
    if [[ -z "$formats" ]]; then
        echo "❌ No report formats specified" >&2
        echo "💡 Use: --report json,junit,html" >&2
        return 1
    fi

    # Split formats by comma and validate each
    IFS=',' read -ra FORMAT_ARRAY <<< "$formats"
    local valid_formats=("json" "junit" "html")

    for format in "${FORMAT_ARRAY[@]}"; do
        format=$(echo "$format" | xargs)  # Trim whitespace

        # Check if format is valid
        local is_valid=false
        for valid_format in "${valid_formats[@]}"; do
            if [[ "$format" == "$valid_format" ]]; then
                is_valid=true
                break
            fi
        done

        if [[ "$is_valid" != "true" ]]; then
            echo "❌ Invalid report format: $format" >&2
            echo "💡 Valid formats: ${valid_formats[*]}" >&2
            return 1
        fi
    done

    return 0
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Show available categories
show_categories() {
    echo "📂 Available Test Categories:"
    echo ""

    if [[ -n "${GDSENTRY_DIR:-}" ]] && [[ -d "${GDSENTRY_DIR:-}/tests" ]]; then
        local categories=()
        while IFS= read -r -d '' dir; do
            categories+=("$(basename "$dir")")
        done < <(find "${GDSENTRY_DIR}/tests" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)

        if [[ ${#categories[@]} -eq 0 ]]; then
            echo "❌ No test categories found in: ${GDSENTRY_DIR}/tests" >&2
            return 1
        fi

        for category in "${categories[@]}"; do
            local test_count=$(find "${GDSENTRY_DIR}/tests/$category" -name "*.gd" 2>/dev/null | wc -l)
            echo "  📁 $category ($test_count tests)"
        done

        echo ""
        echo "💡 Usage examples:"
        echo "  --category core                   # Run only core tests"
        echo "  --category meta,base_classes      # Run multiple categories"
        echo "  --exclude-category advanced       # Exclude specific category"
    else
        echo "❌ Cannot find test directory" >&2
        echo "💡 Please run this script from the gdsentry directory" >&2
        return 1
    fi
}
