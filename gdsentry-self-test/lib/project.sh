#!/bin/bash

# GDSentry Self-Test Project Context Manager
# Materializes project.godot from template for standalone runs, or uses a host project.
# Never commits project.godot; cleans up only files this run created.
#
# Author: GDSentry Framework
# Version: 1.0.0

# Set by ensure_godot_project_context
GDSENTRY_PROJECT_ROOT=""
GDSENTRY_RES_PREFIX=""
GDSENTRY_CREATED_PROJECT="false"
GDSENTRY_KEEP_PROJECT="false"
GDSENTRY_PROJECT_MARKER=""

# Walk parents of GDSENTRY_DIR looking for an existing host project.godot
find_host_project_root() {
    local dir
    dir="$(cd "$GDSENTRY_DIR/.." 2>/dev/null && pwd)" || return 1
    local stop_at="/"
    while [[ -n "$dir" && "$dir" != "$stop_at" ]]; do
        if [[ -f "$dir/project.godot" ]]; then
            echo "$dir"
            return 0
        fi
        local parent
        parent="$(dirname "$dir")"
        if [[ "$parent" == "$dir" ]]; then
            break
        fi
        dir="$parent"
    done
    return 1
}

# Relative path from host project root to the framework folder (for res:// prefix)
framework_res_prefix_from_host() {
    local host_root="$1"
    local framework_dir="$2"
    local rel
    rel="${framework_dir#"$host_root"/}"
    if [[ "$rel" == "$framework_dir" ]]; then
        # Could not strip prefix
        echo ""
        return 1
    fi
    echo "$rel"
}

# Ensure a Godot project context exists; set GDSENTRY_PROJECT_ROOT and GDSENTRY_RES_PREFIX
ensure_godot_project_context() {
    GDSENTRY_PROJECT_MARKER="${GDSENTRY_DIR}/.gdsentry_selftest_created_project"
    GDSENTRY_CREATED_PROJECT="false"
    GDSENTRY_RES_PREFIX=""

    local host_root=""
    if host_root="$(find_host_project_root)"; then
        GDSENTRY_PROJECT_ROOT="$host_root"
        local prefix
        prefix="$(framework_res_prefix_from_host "$host_root" "$GDSENTRY_DIR")"
        if [[ -z "$prefix" ]]; then
            echo "❌ Could not determine framework path relative to host project: $host_root" >&2
            return 1
        fi
        GDSENTRY_RES_PREFIX="$prefix"
        echo "📦 Using host Godot project: $GDSENTRY_PROJECT_ROOT"
        echo "   Framework res:// prefix: $GDSENTRY_RES_PREFIX/"
        return 0
    fi

    # Standalone: materialize template if needed
    GDSENTRY_PROJECT_ROOT="$GDSENTRY_DIR"
    GDSENTRY_RES_PREFIX=""

    if [[ -f "$GDSENTRY_DIR/project.godot" ]]; then
        echo "📦 Using existing standalone project.godot in $GDSENTRY_DIR"
        return 0
    fi

    local template="$GDSENTRY_DIR/templates/project.godot.template"
    if [[ ! -f "$template" ]]; then
        echo "❌ No host project.godot found and template missing: $template" >&2
        echo "💡 Add a Godot project at the host root, or restore templates/project.godot.template" >&2
        return 1
    fi

    cp "$template" "$GDSENTRY_DIR/project.godot" || {
        echo "❌ Failed to materialize project.godot from template" >&2
        return 1
    }
    touch "$GDSENTRY_PROJECT_MARKER"
    GDSENTRY_CREATED_PROJECT="true"
    echo "📦 Materialized standalone project.godot from templates/project.godot.template"
    return 0
}

# Convert a framework-relative test path (tests/core/foo.gd) to a res:// path for the active project
to_res_path() {
    local test_path="$1"
    # Strip leading ./ and res://
    test_path="${test_path#./}"
    test_path="${test_path#res://}"

    if [[ -n "$GDSENTRY_RES_PREFIX" ]]; then
        echo "res://${GDSENTRY_RES_PREFIX}/${test_path}"
    else
        echo "res://${test_path}"
    fi
}

cleanup_godot_project_context() {
    if [[ "$GDSENTRY_KEEP_PROJECT" == "true" ]]; then
        echo "📦 Keeping project.godot (--keep-project)"
        return 0
    fi

    if [[ "$GDSENTRY_CREATED_PROJECT" != "true" ]]; then
        return 0
    fi

    if [[ -f "$GDSENTRY_PROJECT_MARKER" ]] || [[ "$GDSENTRY_CREATED_PROJECT" == "true" ]]; then
        if [[ -f "$GDSENTRY_DIR/project.godot" ]]; then
            rm -f "$GDSENTRY_DIR/project.godot"
            echo "📦 Removed harness-created project.godot"
        fi
        rm -f "$GDSENTRY_PROJECT_MARKER"
        # Optional: remove import cache created during standalone run
        if [[ -d "$GDSENTRY_DIR/.godot" ]]; then
            rm -rf "$GDSENTRY_DIR/.godot"
            echo "📦 Removed harness-created .godot/ cache"
        fi
    fi
}
