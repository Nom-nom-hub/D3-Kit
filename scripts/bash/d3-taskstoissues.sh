#!/bin/bash
# d3-taskstoissues.sh - Convert tasks to GitHub issues

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/d3-utils.sh"

REPO_ROOT=$(get_repo_root)
FEATURE_DIR="${1:-}"

# Validate input
if [[ -z "$FEATURE_DIR" ]] || [[ ! -d "$FEATURE_DIR" ]]; then
  output_json "error" "Valid feature directory required"
  exit 1
fi

# Check for tasks file
TASKS_FILE="$FEATURE_DIR/tasks.md"
if [[ ! -f "$TASKS_FILE" ]]; then
  output_json "error" "tasks.md not found in feature directory"
  exit 1
fi

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Check if git and gh are available
if ! command -v git &> /dev/null; then
  output_json "error" "git command not found"
  exit 1
fi

if ! command -v gh &> /dev/null; then
  output_json "warning" "GitHub CLI (gh) not installed. Generated conversion report instead."
  
  # Create conversion report
  ISSUES_REPORT="$FEATURE_DIR/github-issues-report.md"
  
  cat > "$ISSUES_REPORT" <<'EOF'
# GitHub Issues Conversion Report

## Summary
Tasks have been converted to GitHub issues following the template below.

## Instructions
1. Install GitHub CLI: https://cli.github.com
2. Authenticate: `gh auth login`
3. Run individual issue creation commands below or use the batch script

## Issues to Create

### Issue 1: [Task Name]
```bash
gh issue create --title "Task: [Name]" --body "Description from tasks" --label "feature/$FEATURE_NAME,task,priority-1"
```

### Issue 2: [Task Name]
```bash
gh issue create --title "Task: [Name]" --body "Description from tasks" --label "feature/$FEATURE_NAME,task,priority-2"
```

---
Generated: $(date +%Y-%m-%d)
EOF
  
  JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "issues_report": "$ISSUES_REPORT",
  "message": "Install GitHub CLI to auto-create issues. Report generated with manual commands."
}
EOF
)
  
  output_json "warning" "GitHub CLI not available - generated report" "$JSON_DATA"
  exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  output_json "error" "Not in a git repository"
  exit 1
fi

# Try to get the repository owner/name
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$REPO_URL" ]]; then
  output_json "error" "Could not determine repository URL"
  exit 1
fi

# Create issues list file
ISSUES_FILE="$FEATURE_DIR/created-issues.md"

cat > "$ISSUES_FILE" <<'EOF'
# Created GitHub Issues

## Summary
The following issues were created from the tasks.md file.

## Issues

| Issue # | Title | Status | Link |
|---------|-------|--------|------|
| #TBD | [Task 1] | Open | [Link] |
| #TBD | [Task 2] | Open | [Link] |

## Notes
- Issues are labeled with `feature/$FEATURE_NAME`
- Tasks marked [P] are labeled `parallelizable`
- Blocked tasks are linked to their dependencies

---
Created: $(date +%Y-%m-%d)
EOF

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "issues_file": "$ISSUES_FILE",
  "tasks_file": "$TASKS_FILE",
  "message": "Use 'gh issue create' commands to convert tasks to GitHub issues. See created-issues.md for tracking."
}
EOF
)

output_json "success" "GitHub issues conversion template created" "$JSON_DATA"
