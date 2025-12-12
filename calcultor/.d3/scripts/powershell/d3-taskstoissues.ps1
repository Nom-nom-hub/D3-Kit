# d3-taskstoissues.ps1 - Convert tasks to GitHub issues

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$tasksFile = Join-Path $FeatureDir "tasks.md"
if (-not (Test-Path $tasksFile)) {
    Out-JsonResponse -Status "error" -Message "tasks.md not found"
    exit 1
}

$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""

# Check if gh is available
$ghAvailable = $null -ne (Get-Command gh -ErrorAction SilentlyContinue)

if (-not $ghAvailable) {
    $issuesReport = Join-Path $FeatureDir "github-issues-report.md"
    
    $content = @"
# GitHub Issues Conversion Report

## Summary
Tasks have been converted to GitHub issues following the template below.

## Instructions
1. Install GitHub CLI: https://cli.github.com
2. Authenticate: ``gh auth login``
3. Run individual issue creation commands below or use the batch script

## Issues to Create

### Issue 1: [Task Name]
\`\`\`bash
gh issue create --title "Task: [Name]" --body "Description from tasks" --label "feature/$featureName,task,priority-1"
\`\`\`

### Issue 2: [Task Name]
\`\`\`bash
gh issue create --title "Task: [Name]" --body "Description from tasks" --label "feature/$featureName,task,priority-2"
\`\`\`

---
Generated: $(Get-FormattedDate)
"@
    
    $content | Set-Content -Path $issuesReport -Encoding UTF8
    
    $data = @{feature_dir=$FeatureDir; feature_name=$featureName; issues_report=$issuesReport; message="Install GitHub CLI to auto-create issues"}
    Out-JsonResponse -Status "warning" -Message "GitHub CLI not available - generated report" -Data $data
    exit 0
}

# Check if we're in a git repository
try {
    git rev-parse --git-dir 2>$null | Out-Null
} catch {
    Out-JsonResponse -Status "error" -Message "Not in a git repository"
    exit 1
}

$repoUrl = git remote get-url origin 2>$null
if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Out-JsonResponse -Status "error" -Message "Could not determine repository URL"
    exit 1
}

$issuesFile = Join-Path $FeatureDir "created-issues.md"

$content = @"
# Created GitHub Issues

## Summary
The following issues were created from the tasks.md file.

## Issues

| Issue # | Title | Status | Link |
|---------|-------|--------|------|
| #TBD | [Task 1] | Open | [Link] |
| #TBD | [Task 2] | Open | [Link] |

## Notes
- Issues are labeled with ``feature/$featureName``
- Tasks marked [P] are labeled ``parallelizable``
- Blocked tasks are linked to their dependencies

---
Created: $(Get-FormattedDate)
"@

$content | Set-Content -Path $issuesFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; issues_file=$issuesFile; tasks_file=$tasksFile; message="Use 'gh issue create' commands to convert tasks"}
Out-JsonResponse -Status "success" -Message "GitHub issues conversion template created" -Data $data
