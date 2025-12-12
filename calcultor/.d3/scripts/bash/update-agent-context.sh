#!/usr/bin/env bash

set -e

JSON_MODE=false
FEATURE_DIR=""
CONTEXT_FILE=""
QUIET_MODE=false
ARGS=()

i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --feature-dir)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --feature-dir requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --feature-dir requires a value' >&2
                exit 1
            fi
            FEATURE_DIR="$next_arg"
            ;;
        --context-file)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --context-file requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --context-file requires a value' >&2
                exit 1
            fi
            CONTEXT_FILE="$next_arg"
            ;;
        --quiet)
            QUIET_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--feature-dir <path>] [--context-file <file>] [--quiet] [additional args]"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --feature-dir <path> Specify feature directory (default: current directory or from D3_FEATURE env var)"
            echo "  --context-file <file> Specify context file name (default: .d3-context.md)"
            echo "  --quiet             Suppress informational messages"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --feature-dir d3-features/001-user-auth"
            echo "  $0 --context-file .agent-context.md"
            echo "  $0 --json"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

# Function to find the repository root
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.d3" ] || [ -d "$dir/d3-features" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Source common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

if [ -f "$REPO_ROOT/scripts/bash/common.sh" ]; then
    source "$REPO_ROOT/scripts/bash/common.sh"
elif [ -f "./scripts/bash/common.sh" ]; then
    source "./scripts/bash/common.sh"
else
    echo "[d3-kit] ERROR: Could not find common.sh" >&2
    exit 1
fi

# Determine context file
if [ -z "$CONTEXT_FILE" ]; then
    CONTEXT_FILE=".d3-context.md"
fi

# Determine feature directory
if [ -z "$FEATURE_DIR" ]; then
    if [ -n "$D3_FEATURE" ]; then
        # Use environment variable
        FEATURE_DIR="$REPO_ROOT/d3-features/$D3_FEATURE"
    elif [ -d "$(pwd)/spec.md" ]; then
        # Current directory is a feature directory
        FEATURE_DIR="$(pwd)"
    elif [ -d "$(pwd)/d3-features" ]; then
        # Look for the most recently created feature directory
        LATEST_FEATURE=$(ls -td "$REPO_ROOT/d3-features"/* 2>/dev/null | head -n 1 | xargs basename 2>/dev/null)
        if [ -n "$LATEST_FEATURE" ]; then
            FEATURE_DIR="$REPO_ROOT/d3-features/$LATEST_FEATURE"
        else
            echo "[d3-kit] ERROR: Could not determine feature directory. Set D3_FEATURE or use --feature-dir." >&2
            exit 1
        fi
    else
        echo "[d3-kit] ERROR: Could not determine feature directory. Set D3_FEATURE or use --feature-dir." >&2
        exit 1
    fi
elif [ ! -d "$FEATURE_DIR" ]; then
    echo "[d3-kit] ERROR: Feature directory does not exist: $FEATURE_DIR" >&2
    exit 1
fi

# Ensure feature directory is properly formatted
if [[ ! "$FEATURE_DIR" =~ d3-features/ ]]; then
    FEATURE_DIR="$REPO_ROOT/d3-features/$(basename "$FEATURE_DIR")"
fi

if [ ! -f "$FEATURE_DIR/spec.md" ]; then
    echo "[d3-kit] ERROR: spec.md not found in $FEATURE_DIR" >&2
    exit 1
fi

if [ ! $QUIET_MODE ]; then
    log_info "Updating agent context from feature directory: $FEATURE_DIR"
fi

# Create context file
CONTEXT_PATH="$REPO_ROOT/$CONTEXT_FILE"

# Start with header
cat > "$CONTEXT_PATH" << 'EOF'
# D3 Feature Context

Auto-generated from feature specifications. Last updated: $(date)

EOF

# Add spec content if it exists
if [ -f "$FEATURE_DIR/spec.md" ]; then
    echo "## Feature Specification" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
    cat "$FEATURE_DIR/spec.md" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
fi

# Add plan content if it exists
if [ -f "$FEATURE_DIR/plan.md" ]; then
    echo "## Implementation Plan" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
    cat "$FEATURE_DIR/plan.md" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
fi

# Add data model content if it exists
if [ -f "$FEATURE_DIR/data-model.md" ]; then
    echo "## Data Model" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
    cat "$FEATURE_DIR/data-model.md" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
fi

# Add quickstart content if it exists
if [ -f "$FEATURE_DIR/quickstart.md" ]; then
    echo "## Quickstart Guide" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
    cat "$FEATURE_DIR/quickstart.md" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
fi

# Add task content if it exists
if [ -f "$FEATURE_DIR/tasks.md" ]; then
    echo "## Task List" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
    cat "$FEATURE_DIR/tasks.md" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
fi

# Add contracts if they exist
if [ -d "$FEATURE_DIR/contracts" ]; then
    echo "## API Contracts" >> "$CONTEXT_PATH"
    echo "" >> "$CONTEXT_PATH"
    for contract in "$FEATURE_DIR/contracts"/*.md; do
        if [ -f "$contract" ]; then
            echo "### $(basename "$contract" .md)" >> "$CONTEXT_PATH"
            echo "" >> "$CONTEXT_PATH"
            cat "$contract" >> "$CONTEXT_PATH"
            echo "" >> "$CONTEXT_PATH"
        fi
    done
fi

# Add footer
cat >> "$CONTEXT_PATH" << 'EOF'

<!-- AUTO-GENERATED CONTENT - DO NOT EDIT MANUALLY -->
EOF

if [ ! $QUIET_MODE ]; then
    log_info "Updated context file: $CONTEXT_PATH"
    log_info "Feature: $(basename "$FEATURE_DIR")"
    log_info "Spec: $(if [ -f "$FEATURE_DIR/spec.md" ]; then echo "included"; else echo "missing"; fi)"
    log_info "Plan: $(if [ -f "$FEATURE_DIR/plan.md" ]; then echo "included"; else echo "missing"; fi)"
    log_info "Data Model: $(if [ -f "$FEATURE_DIR/data-model.md" ]; then echo "included"; else echo "missing"; fi)"
fi

if $JSON_MODE; then
    printf '{"context_file":"%s","feature_dir":"%s","d3_feature":"%s","status":"updated"}\n' \
        "$CONTEXT_PATH" "$FEATURE_DIR" "$D3_FEATURE"
else
    echo "Context file updated: $CONTEXT_PATH"
fi