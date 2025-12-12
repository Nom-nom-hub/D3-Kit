# d3-analyze.ps1 - Analyze artifacts for consistency and completeness

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$specFile = Join-Path $FeatureDir "spec.md"
$planFile = Join-Path $FeatureDir "plan.md"
$tasksFile = Join-Path $FeatureDir "tasks.md"

$artifacts = @()
if (Test-Path $specFile) { $artifacts += "spec" }
if (Test-Path $planFile) { $artifacts += "plan" }
if (Test-Path $tasksFile) { $artifacts += "tasks" }

$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$issues = @()

if (-not (Test-Path $specFile)) { $issues += "Missing spec.md" }
if (-not (Test-Path $planFile)) { $issues += "Missing plan.md - Run /d3.plan first" }
if (-not (Test-Path $tasksFile)) { $issues += "Missing tasks.md - Run /d3.tasks after plan" }

if (Test-Path $specFile) {
    $clarCount = ([regex]::Matches((Get-Content $specFile -Raw), "\[NEEDS CLARIFICATION:")).Count
    if ($clarCount -gt 0) { $issues += "$clarCount unresolved clarifications in spec" }
}

$data = @{
    feature_dir=$FeatureDir
    feature_name=$featureName
    artifacts_present=$artifacts
    issues=$issues
    is_complete=($issues.Count -eq 0)
}

Out-JsonResponse -Status "success" -Message "Analysis complete" -Data $data
