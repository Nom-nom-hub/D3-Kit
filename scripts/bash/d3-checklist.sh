#!/bin/bash
# d3-checklist.sh - Generate quality checklists

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

# Load checklist template
TEMPLATE=$(load_template "$REPO_ROOT" "checklist-template.md")

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Replace placeholders
CONTENT="$TEMPLATE"
CONTENT=$(replace_placeholder "$CONTENT" "FEATURE_NAME" "$FEATURE_NAME")
CONTENT=$(replace_placeholder "$CONTENT" "CREATION_DATE" "$(get_date)")

# Create checklists directory if it doesn't exist
mkdir -p "$FEATURE_DIR/checklists"

# Write checklist file
CHECKLIST_FILE="$FEATURE_DIR/checklists/requirements.md"
echo "$CONTENT" > "$CHECKLIST_FILE"

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "checklist_file": "$CHECKLIST_FILE",
  "spec_file": "$SPEC_FILE"
}
EOF
)

output_json "success" "Quality checklist generated successfully" "$JSON_DATA"
