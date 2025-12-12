# d3-quickstart.ps1 - Create quickstart/validation guide

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$specFile = Join-Path $FeatureDir "spec.md"
if (-not (Test-Path $specFile)) {
    Out-JsonResponse -Status "error" -Message "spec.md not found"
    exit 1
}

$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$quickstartFile = Join-Path $FeatureDir "quickstart.md"

$content = @"
# Quickstart & Validation Guide

## Overview

This guide walks you through validating the feature implementation end-to-end.

## Prerequisites

- [ ] Development environment set up
- [ ] Dependencies installed
- [ ] Database/services running (if applicable)

## Setup Steps

1. **Clone/checkout feature branch**
   \`\`\`bash
   git checkout [BRANCH_NAME]
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   [Installation command specific to your stack]
   \`\`\`

3. **Configure environment**
   \`\`\`bash
   cp .env.example .env
   [Configure required environment variables]
   \`\`\`

4. **Initialize database (if applicable)**
   \`\`\`bash
   [Database setup commands]
   \`\`\`

## Running the Feature

### Start the application
\`\`\`bash
[Start command]
\`\`\`

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
Created: $(Get-FormattedDate)
"@

$content | Set-Content -Path $quickstartFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; quickstart_file=$quickstartFile}
Out-JsonResponse -Status "success" -Message "Quickstart guide created successfully" -Data $data
