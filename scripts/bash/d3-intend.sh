#!/bin/bash
# d3-intend.sh - Create feature specification from user description

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/d3-utils.sh"

REPO_ROOT=$(get_repo_root)
DESCRIPTION="${1:-}"

# Validate input
if [[ -z "$DESCRIPTION" ]]; then
  output_json "error" "Feature description required"
  exit 1
fi

# Generate feature name and number
FEATURE_NAME=$(generate_feature_name "$DESCRIPTION")
FEATURE_NUM=$(get_next_feature_number "$FEATURE_NAME")
BRANCH_NAME="${FEATURE_NUM}-${FEATURE_NAME}"

# Create feature directory
FEATURE_DIR=$(create_feature_structure "$REPO_ROOT" "$FEATURE_NUM" "$FEATURE_NAME")

# Load template
TEMPLATE=$(load_template "$REPO_ROOT" "d3-spec-template.md")

# Replace placeholders
CONTENT="$TEMPLATE"
CONTENT=$(replace_placeholder "$CONTENT" "FEATURE_NAME" "$FEATURE_NAME")
CONTENT=$(replace_placeholder "$CONTENT" "FEATURE_BRANCH" "$BRANCH_NAME")
CONTENT=$(replace_placeholder "$CONTENT" "CREATION_DATE" "$(get_date)")
CONTENT=$(replace_placeholder "$CONTENT" "DESCRIPTION" "$DESCRIPTION")
CONTENT=$(replace_placeholder "$CONTENT" "DEVELOPER_NAME" "Developer")

# Write spec file
SPEC_FILE="$FEATURE_DIR/spec.md"
echo "$CONTENT" > "$SPEC_FILE"

# Create git branch
create_git_branch "$BRANCH_NAME"

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "branch_name": "$BRANCH_NAME",
  "feature_number": $FEATURE_NUM,
  "feature_name": "$FEATURE_NAME",
  "feature_dir": "$FEATURE_DIR",
  "spec_file": "$SPEC_FILE",
  "description": "$DESCRIPTION"
}
EOF
)

output_json "success" "Feature specification created successfully" "$JSON_DATA"
