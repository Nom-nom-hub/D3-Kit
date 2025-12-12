#!/bin/bash
# d3-implement.sh - Execute implementation

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

# Check for required artifacts
SPEC_FILE="$FEATURE_DIR/spec.md"
PLAN_FILE="$FEATURE_DIR/plan.md"
TASKS_FILE="$FEATURE_DIR/tasks.md"

if [[ ! -f "$SPEC_FILE" ]]; then
  output_json "error" "spec.md not found - run /d3.intend first"
  exit 1
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  output_json "error" "plan.md not found - run /d3.plan first"
  exit 1
fi

if [[ ! -f "$TASKS_FILE" ]]; then
  output_json "error" "tasks.md not found - run /d3.tasks first"
  exit 1
fi

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Create implementation log file
IMPL_LOG="$FEATURE_DIR/implementation-log.md"

cat > "$IMPL_LOG" <<'EOF'
# Implementation Log

## Project Summary
[Feature summary from spec.md]

## Implementation Status

### Phase 1: Setup & Infrastructure
- [ ] Development environment configured
- [ ] Dependencies installed
- [ ] Version control branch created
- [ ] Build/test pipeline configured

### Phase 2: Core Implementation
- [ ] Data models implemented
- [ ] Core business logic implemented
- [ ] API endpoints implemented
- [ ] Error handling implemented
- [ ] Logging implemented

### Phase 3: Integration
- [ ] External integrations completed
- [ ] Cross-component connections working
- [ ] Event handlers registered
- [ ] Database migrations run

### Phase 4: Testing
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing
- [ ] End-to-end tests written and passing
- [ ] Performance tests passing

### Phase 5: Documentation & Deployment
- [ ] Code documented
- [ ] API documentation complete
- [ ] Deployment guide written
- [ ] Release notes prepared
- [ ] Feature deployed to staging
- [ ] Smoke tests passing

## Task Execution Progress

[Tasks from tasks.md will be tracked here]

- [ ] [Task 1]
- [ ] [Task 2]
- [ ] [Task 3]

## Issues Encountered

### Issue 1: [Description]
**Status**: [Resolved/In Progress/Blocked]
**Resolution**: [How it was solved]

## Blockers

- [ ] [Blocker 1]
- [ ] [Blocker 2]

## Performance Metrics

- **Build Time**: [X seconds]
- **Test Coverage**: [X%]
- **Load Time**: [X ms]

## Sign-Off

- **Implemented By**: [Developer Name]
- **Reviewed By**: [Reviewer Name]
- **Approved By**: [Manager/Lead]
- **Deployment Date**: [Date]

---
Started: $(date +%Y-%m-%d)
EOF

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "implementation_log": "$IMPL_LOG",
  "tasks_file": "$TASKS_FILE",
  "message": "Implementation workflow initialized. Follow the tasks in tasks.md and log progress in implementation-log.md"
}
EOF
)

output_json "success" "Implementation workflow initialized" "$JSON_DATA"
