#!/bin/bash
# d3-analyze.sh - Analyze artifacts for consistency and completeness

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

# Check what artifacts exist
SPEC_FILE="$FEATURE_DIR/spec.md"
PLAN_FILE="$FEATURE_DIR/plan.md"
TASKS_FILE="$FEATURE_DIR/tasks.md"

ARTIFACTS=()
[[ -f "$SPEC_FILE" ]] && ARTIFACTS+=("spec")
[[ -f "$PLAN_FILE" ]] && ARTIFACTS+=("plan")
[[ -f "$TASKS_FILE" ]] && ARTIFACTS+=("tasks")

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Check for issues
ISSUES=()

if [[ ! -f "$SPEC_FILE" ]]; then
  ISSUES+=("Missing spec.md")
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  ISSUES+=("Missing plan.md - Run /d3.plan first")
fi

if [[ ! -f "$TASKS_FILE" ]]; then
  ISSUES+=("Missing tasks.md - Run /d3.tasks after plan")
fi

# Count issues in spec
if [[ -f "$SPEC_FILE" ]]; then
  CLARIFICATION_COUNT=$(grep -c "\[NEEDS CLARIFICATION:" "$SPEC_FILE" || echo 0)
  if [[ $CLARIFICATION_COUNT -gt 0 ]]; then
    ISSUES+=("$CLARIFICATION_COUNT unresolved clarifications in spec")
  fi
fi

# Prepare JSON response
ISSUES_JSON=$(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .)

JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "artifacts_present": $(printf '%s\n' "${ARTIFACTS[@]}" | jq -R . | jq -s .),
  "issues": $ISSUES_JSON,
  "is_complete": $([ ${#ISSUES[@]} -eq 0 ] && echo "true" || echo "false")
}
EOF
)

output_json "success" "Analysis complete" "$JSON_DATA"
