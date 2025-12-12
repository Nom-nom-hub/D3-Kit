#!/usr/bin/env bash

set -e

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.d3" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to check if running in a git repository
is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# Function to get the repository root
get_repo_root() {
    if is_git_repo; then
        git rev-parse --show-toplevel
    else
        find_repo_root "$(pwd)"
    fi
}

# Function to log messages
log_info() {
    echo "[d3-kit] INFO: $1" >&2
}

log_warn() {
    echo "[d3-kit] WARN: $1" >&2
}

log_error() {
    echo "[d3-kit] ERROR: $1" >&2
}

# Function to check prerequisites
check_prerequisites() {
    local missing=()
    
    # Check for git
    if ! command -v git >/dev/null 2>&1; then
        missing+=("git")
    fi
    
    # Check for basic shell utilities
    for cmd in grep sed awk; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Function to wait for git operations to complete
wait_for_git() {
    local timeout=30  # 30 seconds timeout
    local count=0
    
    while [ $count -lt $timeout ]; do
        if ! pgrep -f "git.*push\|git.*pull\|git.*fetch" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    
    log_error "Timeout waiting for git operations to complete"
    return 1
}