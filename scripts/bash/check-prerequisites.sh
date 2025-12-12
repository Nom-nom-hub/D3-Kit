#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source common functions
if [ -f "$REPO_ROOT/scripts/bash/common.sh" ]; then
    source "$REPO_ROOT/scripts/bash/common.sh"
elif [ -f "./scripts/bash/common.sh" ]; then
    source "./scripts/bash/common.sh"
else
    echo "[d3-kit] ERROR: Could not find common.sh" >&2
    exit 1
fi

# Check prerequisites function
check_d3_prerequisites() {
    local missing=()
    
    # Check for git
    if ! command -v git >/dev/null 2>&1; then
        missing+=("git")
    fi
    
    # Check for basic shell utilities
    for cmd in grep sed awk jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    # Check for Python if needed
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_CMD="python3"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_CMD="python"
    else
        missing+=("python3")
    fi
    
    # Check for Python modules if Python is available
    if [ -n "$PYTHON_CMD" ]; then
        if ! $PYTHON_CMD -c "import json" 2>/dev/null; then
            log_warn "Python JSON module not available"
        fi
    fi
    
    # Check for curl or wget for HTTP operations
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing+=("curl or wget")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        echo "Please install the missing dependencies and try again."
        return 1
    fi
    
    log_info "All prerequisites satisfied"
    return 0
}

# JSON output mode
JSON_OUTPUT=false
for arg in "$@"; do
    case $arg in
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--json]"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --help, -h          Show this help message"
            exit 0
            ;;
    esac
done

if $JSON_OUTPUT; then
    if check_d3_prerequisites; then
        jq -n '{"status": "success", "message": "All prerequisites satisfied"}' 2>/dev/null || echo '{"status": "success", "message": "All prerequisites satisfied"}'
    else
        jq -n '{"status": "error", "message": "Missing prerequisites"}' 2>/dev/null || echo '{"status": "error", "message": "Missing prerequisites"}'
        exit 1
    fi
else
    check_d3_prerequisites
fi