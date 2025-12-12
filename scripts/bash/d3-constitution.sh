#!/bin/bash
# d3-constitution.sh - Create or update project constitution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/d3-utils.sh"

REPO_ROOT=$(get_repo_root)
PRINCIPLES="${1:-}"

# Load template
TEMPLATE=$(load_template "$REPO_ROOT" "d3-spec-template.md")

# Create memory directory if it doesn't exist
mkdir -p "$REPO_ROOT/memory"

# Constitution file path
CONSTITUTION_FILE="$REPO_ROOT/memory/d3-constitution.md"

# If constitution exists, load it; otherwise use template
if [[ -f "$CONSTITUTION_FILE" ]]; then
  CONTENT=$(cat "$CONSTITUTION_FILE")
else
  CONTENT="# D3 Project Constitution

## Project Principles

$(if [[ -n "$PRINCIPLES" ]]; then echo "$PRINCIPLES"; else echo "- [Add your project principles here]"; fi)

## Development Guidelines

- All features must start with specification (/d3.intend)
- Features follow the D3 workflow: intend → plan → tasks → implement
- Specifications are written for non-technical stakeholders
- Plans are technology-agnostic high-level designs
- Tasks are concrete, actionable items marked with [P] for parallelizable work

## Governance

- This document is reviewed regularly as new patterns emerge
- Changes to principles require consensus from the development team
- Architecture decisions are documented in the plan artifacts

---
Created: $(get_date)
Last Updated: $(get_date)
"
fi

# Write constitution file
echo "$CONTENT" > "$CONSTITUTION_FILE"

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "constitution_file": "$CONSTITUTION_FILE",
  "status": "created"
}
EOF
)

output_json "success" "Project constitution created/updated successfully" "$JSON_DATA"
