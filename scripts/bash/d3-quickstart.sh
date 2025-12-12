#!/bin/bash
# d3-quickstart.sh - Create quickstart/validation guide

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

# Create quickstart file
QUICKSTART_FILE="$FEATURE_DIR/quickstart.md"

cat > "$QUICKSTART_FILE" <<'EOF'
# Quickstart & Validation Guide

## Overview

This guide walks you through validating the feature implementation end-to-end.

## Prerequisites

- [ ] Development environment set up
- [ ] Dependencies installed
- [ ] Database/services running (if applicable)

## Setup Steps

1. **Clone/checkout feature branch**
   ```bash
   git checkout [BRANCH_NAME]
   ```

2. **Install dependencies**
   ```bash
   [Installation command specific to your stack]
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   [Configure required environment variables]
   ```

4. **Initialize database (if applicable)**
   ```bash
   [Database setup commands]
   ```

## Running the Feature

### Start the application
```bash
[Start command]
```

### Access the feature
- **URL/Path**: [Where to access the feature]
- **Expected behavior**: [What should you see]

## Validation Scenarios

### Scenario 1: [Happy Path]

**Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: [What should happen]

**Validation**: 
- [ ] Result matches expectation
- [ ] No errors in logs
- [ ] Performance acceptable

---

### Scenario 2: [Edge Case]

**Steps**:
1. [Step 1]
2. [Step 2]

**Expected Result**: [What should happen]

**Validation**: 
- [ ] Error handling works correctly
- [ ] User feedback is clear

---

## Troubleshooting

### Issue: [Common Problem]
**Solution**: [How to fix it]

### Issue: [Another Problem]
**Solution**: [How to fix it]

## Performance Baseline

- **Load Time**: [Expected time in ms]
- **Response Time**: [Expected response time]
- **Memory Usage**: [Expected memory footprint]

## Security Checklist

- [ ] No hardcoded secrets/credentials
- [ ] Input validation in place
- [ ] Authentication working
- [ ] Authorization enforced
- [ ] Sensitive data encrypted

## Success Criteria Validation

- [ ] [Success criterion 1] - VERIFIED
- [ ] [Success criterion 2] - VERIFIED
- [ ] [Success criterion 3] - VERIFIED

## Sign-Off

- **Validated By**: [Name]
- **Date**: [Date]
- **Status**: ✓ Ready for Production / ⚠ Needs Fixes

---
Created: $(date +%Y-%m-%d)
EOF

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "quickstart_file": "$QUICKSTART_FILE"
}
EOF
)

output_json "success" "Quickstart guide created successfully" "$JSON_DATA"
