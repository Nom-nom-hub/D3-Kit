#!/usr/bin/env bash

set -e

JSON_MODE=false
FEATURE_DIR=""
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
        --help|-h)
            echo "Usage: $0 [--json] [--feature-dir <path>] [additional args]"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --feature-dir <path> Specify feature directory (default: current directory or from D3_FEATURE env var)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --feature-dir d3-features/001-user-auth"
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

log_info "Setting up plan for feature directory: $FEATURE_DIR"

SPEC_FILE="$FEATURE_DIR/spec.md"
PLAN_FILE="$FEATURE_DIR/plan.md"
DATA_MODEL_FILE="$FEATURE_DIR/data-model.md"
QUICKSTART_FILE="$FEATURE_DIR/quickstart.md"
CONTRACTS_DIR="$FEATURE_DIR/contracts"

# Check if spec file exists
if [ ! -f "$SPEC_FILE" ]; then
    echo "[d3-kit] ERROR: spec.md not found in $FEATURE_DIR" >&2
    exit 1
fi

# Create missing directories
mkdir -p "$CONTRACTS_DIR"

# Copy templates if files don't exist
if [ ! -f "$PLAN_FILE" ] && [ -f "$REPO_ROOT/D3-templates/d3-plan-template.md" ]; then
    cp "$REPO_ROOT/D3-templates/d3-plan-template.md" "$PLAN_FILE"
    log_info "Created plan.md from template"
fi

if [ ! -f "$DATA_MODEL_FILE" ] && [ -f "$REPO_ROOT/D3-templates/d3-commands/d3.data.md" ]; then
    cp "$REPO_ROOT/D3-templates/d3-commands/d3.data.md" "$DATA_MODEL_FILE"
    log_info "Created data-model.md from template"
fi

if [ ! -f "$QUICKSTART_FILE" ] && [ -f "$REPO_ROOT/D3-templates/d3-commands/d3.quickstart.md" ]; then
    cp "$REPO_ROOT/D3-templates/d3-commands/d3.quickstart.md" "$QUICKSTART_FILE"
    log_info "Created quickstart.md from template"
fi

# Create contracts directory structure if needed
if [ -d "$REPO_ROOT/D3-templates/contracts" ]; then
    cp -r "$REPO_ROOT/D3-templates/contracts"/* "$CONTRACTS_DIR"/ 2>/dev/null || true
fi

# Check if plan file exists now
if [ ! -f "$PLAN_FILE" ]; then
    touch "$PLAN_FILE"
    log_warn "Created empty plan.md file"
fi

# Update environment variable if not already set
if [ -z "$D3_FEATURE" ]; then
    export D3_FEATURE=$(basename "$FEATURE_DIR")
fi

if $JSON_MODE; then
    printf '{"feature_dir":"%s","spec_file":"%s","plan_file":"%s","data_model_file":"%s","quickstart_file":"%s","contracts_dir":"%s","d3_feature":"%s"}\n' \
        "$FEATURE_DIR" "$SPEC_FILE" "$PLAN_FILE" "$DATA_MODEL_FILE" "$QUICKSTART_FILE" "$CONTRACTS_DIR" "$D3_FEATURE"
else
    echo "Feature Directory: $FEATURE_DIR"
    echo "Spec File: $SPEC_FILE"
    echo "Plan File: $PLAN_FILE"
    echo "Data Model File: $DATA_MODEL_FILE"
    echo "Quickstart File: $QUICKSTART_FILE"
    echo "Contracts Directory: $CONTRACTS_DIR"
    echo "D3_FEATURE environment variable set to: $D3_FEATURE"
fi