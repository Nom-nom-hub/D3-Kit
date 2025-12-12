#!/bin/bash
# d3-tasks.sh - Generate executable tasks from implementation plan

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

# Check for plan file
PLAN_FILE="$FEATURE_DIR/plan.md"
if [[ ! -f "$PLAN_FILE" ]]; then
  output_json "error" "plan.md not found in feature directory"
  exit 1
fi

# Load template
TEMPLATE=$(load_template "$REPO_ROOT" "d3-tasks-template.md")

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Replace placeholders
CONTENT="$TEMPLATE"
CONTENT=$(replace_placeholder "$CONTENT" "FEATURE_NAME" "$FEATURE_NAME")
CONTENT=$(replace_placeholder "$CONTENT" "CREATION_DATE" "$(get_date)")

# Write tasks file
TASKS_FILE="$FEATURE_DIR/tasks.md"
echo "$CONTENT" > "$TASKS_FILE"

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "tasks_file": "$TASKS_FILE",
  "plan_file": "$PLAN_FILE"
}
EOF
)

output_json "success" "Executable tasks generated successfully" "$JSON_DATA"
