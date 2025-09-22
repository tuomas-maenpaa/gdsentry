#!/bin/bash

# GDSentry Self-Test Execution Engine
# Handles test execution with timeout management and scene creation
# Author: GDSentry Framework

# Cleanup function for temporary files
cleanup_temp_files() {
    # Clean up any temporary scene files that might exist
    if [ -n "${temp_scene:-}" ] && [ -f "$temp_scene" ]; then
        rm -f "$temp_scene"
    fi
    # Clean up any temporary output files
    rm -f /tmp/godot_output_*.log 2>/dev/null || true
}

# Set up signal handling for clean interruption
setup_signal_handling() {
    trap 'echo -e "\n⚠️  Interrupted by user" >&2; exit 130' INT
    trap 'echo -e "\n⚠️  Terminated" >&2; cleanup_temp_files; exit 143' TERM
    trap 'cleanup_temp_files' EXIT
}

# Function to determine test type and execution method
get_test_execution_method() {
    local test_file="$1"

    # Check file content to determine execution method
    if grep -q "extends Node2DTest\|extends.*Node2D" "$test_file" 2>/dev/null; then
        echo "node2d_scene"
    elif grep -q "extends SceneTreeTest\|extends.*SceneTree" "$test_file" 2>/dev/null; then
        echo "scene_tree_script"
    elif [[ "$test_file" == *"visual"* ]] || [[ "$test_file" == *"ui"* ]] || [[ "$test_file" == *"node2d"* ]]; then
        echo "node2d_scene"
    else
        echo "scene_tree_script"
    fi
}

# Create temporary scene file for Node2D tests
create_node2d_scene() {
    local test_path="$1"
    local temp_scene="/tmp/gdsentry_temp_scene_$$_$RANDOM.tscn"
    
    cat > "$temp_scene" << EOF
[gd_scene load_steps=2 format=3 uid="uid://test_scene"]

[ext_resource type="Script" path="res://$test_path" id="1"]

[node name="TestRoot" type="Node2D"]
script = ExtResource("1")
EOF
    
    echo "$temp_scene"
}

# Create temporary scene file for SceneTree tests
create_scene_tree_scene() {
    local test_path="$1"
    local temp_scene="/tmp/gdsentry_temp_scene_$$_$RANDOM.tscn"
    
    cat > "$temp_scene" << EOF
[gd_scene load_steps=2 format=3 uid="uid://test_scene"]

[ext_resource type="Script" path="res://$test_path" id="1"]

[node name="TestRoot" type="Node"]
script = ExtResource("1")
EOF
    
    echo "$temp_scene"
}

# Execute Godot with timeout using system timeout command
execute_with_system_timeout() {
    local scene="$1"
    local timeout_duration="$2"
    local verbose_mode="$3"
    
    echo "⏱️ Using system timeout command (${timeout_duration}s)"
    local output
    output=$(godot --scene "$scene" --headless --quit 2>&1)
    local exit_code=$?
    
    # Process output and return result
    process_test_output "$output" "$verbose_mode"
    return $?
}

# Execute Godot with manual timeout implementation
execute_with_manual_timeout() {
    local scene="$1"
    local timeout_duration="$2"
    local verbose_mode="$3"
    
    echo "⏱️ Using manual timeout (${timeout_duration}s)"
    
    # Start Godot in background and capture output
    local output_file="/tmp/godot_output_$$_$RANDOM"
    godot --scene "$scene" --headless --quit > "$output_file" 2>&1 &
    local godot_pid=$!

    # Wait for completion or timeout
    local elapsed=0
    while kill -0 $godot_pid 2>/dev/null && [ $elapsed -lt $timeout_duration ]; do
        sleep 1
        elapsed=$((elapsed + 1))
        echo "⏱️ Test running... ${elapsed}/${timeout_duration}s"
    done

    # Check if process is still running
    if kill -0 $godot_pid 2>/dev/null; then
        echo "⏱️ Timeout reached! Force killing process..."
        kill -9 $godot_pid 2>/dev/null || true
        local exit_code=1  # Timeout = failure

        # Display captured output for debugging timeout issues
        echo "📄 Captured output before timeout:"
        echo "────────────────────────────────────"
        if [ -f "$output_file" ]; then
            cat "$output_file"
        else
            echo "❌ No output file found"
        fi
        echo "────────────────────────────────────"
        
        rm -f "$output_file"
        return $exit_code
    else
        wait $godot_pid 2>/dev/null
        local exit_code=$?
        echo "✅ Test completed in ${elapsed}s"

        # Check output for errors
        local output
        output=$(cat "$output_file")
        rm -f "$output_file"

        # Process output and return result
        process_test_output "$output" "$verbose_mode"
        return $?
    fi
}

# Execute Godot script directly
execute_script_directly() {
    local test_path="$1"
    local timeout_duration="$2"
    local verbose_mode="$3"
    
    if command -v timeout &> /dev/null; then
        echo "⏱️ Using system timeout command (${timeout_duration}s)"
        local output
        output=$(godot --headless --script "$test_path" 2>&1)
        local exit_code=$?

        # Process output and return result
        process_test_output "$output" "$verbose_mode"
        return $?
    else
        echo "⏱️ Using manual timeout (${timeout_duration}s)"
        
        # Start Godot in background and capture output
        local output_file="/tmp/godot_output_$$_$RANDOM"
        godot --headless --script "$test_path" > "$output_file" 2>&1 &
        local godot_pid=$!

        # Wait for completion or timeout
        local elapsed=0
        while kill -0 $godot_pid 2>/dev/null && [ $elapsed -lt $timeout_duration ]; do
            sleep 1
            elapsed=$((elapsed + 1))
            echo "⏱️ Test running... ${elapsed}/${timeout_duration}s"
        done

        # Check if process is still running
        if kill -0 $godot_pid 2>/dev/null; then
            echo "⏱️ Timeout reached! Force killing process..."
            kill -9 $godot_pid 2>/dev/null || true
            local exit_code=1  # Timeout = failure

            # Display captured output for debugging timeout issues
            echo "📄 Captured output before timeout:"
            echo "────────────────────────────────────"
            if [ -f "$output_file" ]; then
                cat "$output_file"
            else
                echo "❌ No output file found"
            fi
            echo "────────────────────────────────────"
            
            rm -f "$output_file"
            return $exit_code
        else
            wait $godot_pid 2>/dev/null
            local exit_code=$?
            echo "✅ Test completed in ${elapsed}s"

            # Check output for errors
            local output
            output=$(cat "$output_file")
            rm -f "$output_file"

            # Process output and return result
            process_test_output "$output" "$verbose_mode"
            return $?
        fi
    fi
}

# Execute scene-based test with timeout
execute_scene_test() {
    local scene="$1"
    local timeout_duration="$2"
    local verbose_mode="$3"
    
    if command -v timeout &> /dev/null; then
        execute_with_system_timeout "$scene" "$timeout_duration" "$verbose_mode"
    else
        execute_with_manual_timeout "$scene" "$timeout_duration" "$verbose_mode"
    fi
    
    local result=$?
    rm -f "$scene"
    return $result
}

# Main function to run a self-test
run_self_test() {
    local test_path="$1"
    local verbose_mode="$2"
    local test_name
    test_name=$(basename "$test_path")
    local category
    category=$(get_test_category "$test_path")
    local execution_method
    execution_method=$(get_test_execution_method "$test_path")

    echo ""
    echo "🧪 [$category] Running Self-Test: $test_name"
    echo "────────────────────────────────────────────────"

    # Stay in project directory for proper Godot context
    local original_dir
    original_dir=$(pwd)

    # Execute test based on method
    case "$execution_method" in
        "node2d_scene")
            echo "🎨 Running Node2D test (scene-based)..."
            local temp_scene
            temp_scene=$(create_node2d_scene "$test_path")
            execute_scene_test "$temp_scene" 300 "$verbose_mode"
            ;;
        "scene_tree_script")
            echo "🌳 Running SceneTree test (scene-based)..."
            local temp_scene
            temp_scene=$(create_scene_tree_scene "$test_path")
            execute_scene_test "$temp_scene" 300 "$verbose_mode"
            ;;
        *)
            echo "📜 Running test (script-based)..."
            execute_script_directly "$test_path" 60 "$verbose_mode"
            ;;
    esac
    
    local exit_code=$?
    cd "$original_dir" || exit 1
    return $exit_code
}

# Execute test with Godot runner and reporting
execute_with_reporting() {
    local runner_args="$1"
    
    echo "🏃‍♂️ Command: godot --script core/test_runner.gd $runner_args"
    echo ""

    # Execute the test runner with reporting and capture output
    local output_file="/tmp/gdsentry_reporting_output_$$_$RANDOM"
    echo "DEBUG: Executing: godot --script core/test_runner.gd $runner_args"
    eval "godot --script core/test_runner.gd $runner_args" > "$output_file" 2>&1
    local exit_code=$?

    # Read the captured output
    local output
    output=$(cat "$output_file")

    # Filter and display results
    filter_reporting_output "$output"

    # Check for reporting errors
    if ! check_reporting_errors "$output"; then
        rm -f "$output_file"
        return 2
    fi

    # Clean up
    rm -f "$output_file"
    return $exit_code
}
