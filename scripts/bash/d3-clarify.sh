#!/bin/bash
# d3-clarify.sh - Clarify requirements in specification

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

# Check for spec file
SPEC_FILE="$FEATURE_DIR/spec.md"
if [[ ! -f "$SPEC_FILE" ]]; then
  output_json "error" "spec.md not found in feature directory"
  exit 1
fi

# Read current spec
SPEC_CONTENT=$(cat "$SPEC_FILE")

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Count clarification markers
CLARIFICATION_COUNT=$(echo "$SPEC_CONTENT" | grep -c "\[NEEDS CLARIFICATION:" || echo 0)

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "spec_file": "$SPEC_FILE",
  "clarifications_needed": $CLARIFICATION_COUNT,
  "message": "Review the spec.md file and update clarification items. Save changes when complete."
}
EOF
)

output_json "success" "Specification ready for clarification review" "$JSON_DATA"
