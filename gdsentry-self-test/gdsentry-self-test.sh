#!/bin/bash

# GDSentry Enterprise Self-Test Runner - Modular Architecture
# Main orchestrator script that coordinates all testing operations
# 
# This is the main entry point for GDSentry self-testing. It loads all required
# modules and coordinates the execution flow based on configuration.
#
# Author: GDSentry Framework
# Version: 2.0.0

# Exit codes for different failure scenarios
readonly EX_SUCCESS=0           # All tests passed
readonly EX_TEST_FAILURE=1      # One or more tests failed
readonly EX_NO_TESTS=2          # No tests found
readonly EX_INVALID_ARGS=3      # Invalid command line arguments
readonly EX_CONFIG_ERROR=4      # Configuration validation failed
readonly EX_GODOT_ERROR=5       # Godot execution failed
readonly EX_REPORT_ERROR=6      # Report generation failed
readonly EX_PERMISSION_ERROR=7  # Permission/file system errors

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine if we're running from the correct directory
CURRENT_DIR="$(pwd)"
SCRIPT_PARENT_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT_BASENAME="$(basename "$SCRIPT_DIR")"

# Check if we're already in the gdsentry directory or gdsentry-self-test directory
if [[ "$CURRENT_DIR" == *"/gdsentry-self-test" ]]; then
    # We're in gdsentry-self-test directory, change to parent (gdsentry)
    cd "$SCRIPT_PARENT_DIR" || {
        echo "❌ Failed to change to gdsentry directory from gdsentry-self-test" >&2
        echo "💡 Cannot access expected GDSentry directory: $SCRIPT_PARENT_DIR" >&2
        echo "" >&2
        echo "🔍 Troubleshooting:" >&2
        echo "   • Check if directory exists: $(ls -la "$SCRIPT_PARENT_DIR" 2>/dev/null || echo "Directory not found")" >&2
        echo "   • Verify permissions: $(ls -ld "$SCRIPT_PARENT_DIR" 2>/dev/null || echo "Permission denied")" >&2
        echo "   • Try running from gdsentry/ directory instead" >&2
        echo "" >&2
        echo "📂 Current directory: $(pwd)" >&2
        echo "📂 Script location: $SCRIPT_DIR" >&2
        exit 1
    }
    GDSENTRY_DIR="$(pwd)"
    SELF_TEST_DIR="$GDSENTRY_DIR/gdsentry-self-test"
elif [[ "$CURRENT_DIR" == *"/gdsentry" ]] && [[ -d "gdsentry-self-test" ]]; then
    # We're in gdsentry directory, stay here
    GDSENTRY_DIR="$(pwd)"
    SELF_TEST_DIR="$GDSENTRY_DIR/gdsentry-self-test"
else
    # We're in an unknown location, try to find the gdsentry directory
    if [[ -d "$SCRIPT_PARENT_DIR/gdsentry-self-test" ]]; then
        # Script is in gdsentry-self-test, parent should be gdsentry
        cd "$SCRIPT_PARENT_DIR" || {
            echo "❌ Failed to change to gdsentry directory" >&2
            echo "💡 Cannot access the expected GDSentry directory" >&2
            echo "" >&2
            echo "🔍 Troubleshooting:" >&2
            echo "   • Expected GDSentry directory: $SCRIPT_PARENT_DIR" >&2
            echo "   • Check if directory exists: $(ls -la "$SCRIPT_PARENT_DIR" 2>/dev/null || echo "Directory not found")" >&2
            echo "   • Verify you're running from the correct location" >&2
            echo "" >&2
            echo "💡 Alternative locations to run from:" >&2
            echo "   • gdsentry/ directory (recommended)" >&2
            echo "   • gdsentry/gdsentry-self-test/ directory" >&2
            echo "" >&2
            echo "📂 Current directory: $(pwd)" >&2
            echo "📂 Script location: $SCRIPT_DIR" >&2
            exit 1
        }
        GDSENTRY_DIR="$(pwd)"
        SELF_TEST_DIR="$GDSENTRY_DIR/gdsentry-self-test"
    else
        echo "❌ Cannot determine GDSentry directory location" >&2
        echo "💡 This script must be run from within a GDSentry project structure" >&2
        echo "" >&2
        echo "🔍 Valid locations to run from:" >&2
        echo "   📂 gdsentry/ directory (recommended)" >&2
        echo "   📂 gdsentry/gdsentry-self-test/ directory" >&2
        echo "" >&2
        echo "🔧 Troubleshooting:" >&2
        echo "   • Navigate to your GDSentry project root directory" >&2
        echo "   • Ensure gdsentry-self-test/ directory exists" >&2
        echo "   • Check if you're in the correct GDSentry installation" >&2
        echo "" >&2
        echo "📂 Current directory: $CURRENT_DIR" >&2
        echo "📂 Script location: $SCRIPT_DIR" >&2
        echo "📂 Script parent: $SCRIPT_PARENT_DIR" >&2
        echo "" >&2
        echo "📚 For help, see: https://github.com/gdsentry/gdsentry" >&2
        exit 1
    fi
fi

# Verify we have the correct directory structure
    if [[ ! -d "$SELF_TEST_DIR" ]] || [[ ! -d "$SELF_TEST_DIR/lib" ]]; then
        echo "❌ Invalid directory structure" >&2
        echo "💡 Cannot find required GDSentry directories" >&2
        echo "" >&2
        echo "🔍 Expected structure:" >&2
        echo "   📂 $GDSENTRY_DIR/ (GDSentry root)" >&2
        echo "   └── 📂 $SELF_TEST_DIR/ (Self-test directory)" >&2
        echo "       └── 📂 lib/ (Required modules)" >&2
        echo "" >&2
        echo "🔧 Troubleshooting:" >&2
        echo "   • Verify you're in the correct GDSentry directory" >&2
        echo "   • Check if gdsentry-self-test directory exists: $(ls -la "$GDSENTRY_DIR/" | grep gdsentry-self-test || echo "Not found")" >&2
        echo "   • Reinstall GDSentry if directories are missing" >&2
        echo "" >&2
        echo "📂 Current location: $(pwd)" >&2
        echo "📂 Script location: $SCRIPT_DIR" >&2
        echo "📚 For help, see: https://github.com/gdsentry/gdsentry" >&2
        exit 1
    fi

# Load all required modules using absolute paths
source "$SELF_TEST_DIR/lib/config.sh"
source "$SELF_TEST_DIR/lib/discovery.sh"
source "$SELF_TEST_DIR/lib/processor.sh"
source "$SELF_TEST_DIR/lib/executor.sh"
source "$SELF_TEST_DIR/lib/reporter.sh"
source "$SELF_TEST_DIR/modes/dry-run.sh"
source "$SELF_TEST_DIR/modes/reporting.sh"
source "$SELF_TEST_DIR/modes/individual.sh"

# Export important paths for use by sourced modules
export GDSENTRY_DIR
export SELF_TEST_DIR

# Main execution function
main() {
    local script_name="$0"
    
    # Initialize
    quiet_echo "🧪 GDSentry Enterprise Self-Test Runner"
    quiet_echo "====================================="

    # Parse command-line arguments
    parse_arguments "$@"

    # Validate configuration
    if ! validate_configuration; then
        exit $?
    fi

    # Show Godot version
    quiet_echo "✅ Godot found: $(godot --version)"

    # Set up signal handling
    setup_signal_handling

    # Discover all self-tests
    echo ""
    echo "🔍 Discovering GDSentry Self-Tests..."
    echo "──────────────────────────────────"

    local self_tests=()
    while IFS= read -r line; do
        self_tests+=("$line")
    done < <(discover_self_tests)
    local total_tests=${#self_tests[@]}

    if [ "$total_tests" -eq 0 ]; then
        echo "❌ No self-tests found in gdsentry/tests/" >&2
        echo "💡 This could mean:" >&2
        echo "   • GDSentry framework is not properly installed" >&2
        echo "   • You're running from the wrong directory" >&2
        echo "   • Test files have incorrect naming or location" >&2
        echo "" >&2
        echo "🔍 Troubleshooting:" >&2
        echo "   • Run from: $GDSENTRY_DIR" >&2
        echo "   • Check if tests/ directory exists: $(ls -la "$GDSENTRY_DIR/tests/" 2>/dev/null || echo "Not found")" >&2
        echo "   • Look for .gd files: $(find "$GDSENTRY_DIR/tests/" -name "*.gd" 2>/dev/null | wc -l) test files found" >&2
        echo "" >&2
        echo "📚 For help, see: https://github.com/gdsentry/gdsentry" >&2
        exit $EX_NO_TESTS
    fi

    quiet_echo "✅ Found $total_tests self-test files"

    # Count tests by category and show distribution
    count_tests_by_category "${self_tests[@]}"
    local quiet_mode
    quiet_mode=$(get_config "quiet")
    show_test_distribution "$quiet_mode"

    # Determine and execute the appropriate mode
    local dry_run
    dry_run=$(get_config "dry_run")
    
    if [ "$dry_run" = "true" ]; then
        # Dry run mode
        if should_use_reporting_mode; then
            execute_discovery_dry_run "${self_tests[@]}"
        else
            execute_dry_run "${self_tests[@]}"
        fi
        exit 0
    elif should_use_reporting_mode; then
        # Reporting mode
        execute_reporting_mode
        exit $?
    else
        # Individual tests mode (default)
        execute_individual_mode "${self_tests[@]}"
        exit $?
    fi
}

# Enhanced error handling for module loading
check_module_loading() {
    # Verify all required functions are available
    local required_functions=(
        "parse_arguments" "validate_configuration" "discover_self_tests"
        "count_tests_by_category" "show_test_distribution" "get_config"
        "should_use_reporting_mode" "execute_dry_run" "execute_discovery_dry_run"
        "execute_reporting_mode" "execute_individual_mode"
    )

    local missing_functions=()

    for func in "${required_functions[@]}"; do
        if ! declare -f "$func" >/dev/null; then
            missing_functions+=("$func")
        fi
    done

    if [[ ${#missing_functions[@]} -gt 0 ]]; then
        echo "❌ Critical Error: Module loading failed" >&2
        echo "💡 Missing required functions: ${missing_functions[*]}" >&2
        echo "" >&2
        echo "🔍 This usually indicates:" >&2
        echo "   • Script is not being run from the correct directory" >&2
        echo "   • GDSentry framework files are corrupted or incomplete" >&2
        echo "   • Required module files are missing from gdsentry-self-test/lib/" >&2
        echo "" >&2
        echo "🔧 Troubleshooting:" >&2
        echo "   • Run from: $GDSENTRY_DIR" >&2
        echo "   • Check lib files: $(ls -la "$SELF_TEST_DIR/lib/" 2>/dev/null | wc -l) files found" >&2
        echo "   • Reinstall GDSentry if files are missing" >&2
        echo "" >&2
        echo "📚 For help, see: https://github.com/gdsentry/gdsentry" >&2
        exit 1
    fi

    echo "✅ All required modules loaded successfully" >&2
}

# Verify module loading before proceeding
check_module_loading

# Execute main function with all arguments
main "$@"
