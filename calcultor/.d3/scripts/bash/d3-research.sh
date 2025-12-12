#!/bin/bash
# d3-research.sh - Gather technical research for a feature

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

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Create research file with template content
RESEARCH_FILE="$FEATURE_DIR/research.md"

cat > "$RESEARCH_FILE" <<'EOF'
# Research: Technical Exploration

## Areas Covered

### 1. Library/Framework Comparisons
- [ ] Compare relevant libraries/frameworks
- [ ] Document pros/cons of each option
- [ ] Recommend best solution for this feature

### 2. Performance Considerations
- [ ] Identify performance bottlenecks
- [ ] Research optimization strategies
- [ ] Define acceptable performance thresholds

### 3. Security/Privacy Concerns
- [ ] Identify potential security risks
- [ ] Research security best practices
- [ ] Document compliance requirements

### 4. Integration Patterns
- [ ] Document API integration patterns
- [ ] Research data flow patterns
- [ ] Identify external dependencies

### 5. Similar Solutions
- [ ] Research existing implementations
- [ ] Analyze open-source examples
- [ ] Document lessons learned

## Findings

### Technology Stack Recommendations

- [Document your findings here]

### Key Dependencies

- [List critical dependencies and rationale]

### Risk Factors

- [Identify and mitigate risks]

## Next Steps

- Use findings to inform the implementation plan
- Document selected approaches in the plan artifact

---
Created: $(date +%Y-%m-%d)
EOF

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "research_file": "$RESEARCH_FILE"
}
EOF
)

output_json "success" "Research file created successfully" "$JSON_DATA"
