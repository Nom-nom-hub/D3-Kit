# d3-clarify.ps1 - Clarify requirements in specification

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

$specContent = Get-Content $specFile -Raw
$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$clarificationCount = ([regex]::Matches($specContent, "\[NEEDS CLARIFICATION:")).Count

$data = @{
    feature_dir=$FeatureDir
    feature_name=$featureName
    spec_file=$specFile
    clarifications_needed=$clarificationCount
    message="Review the spec.md file and update clarification items. Save changes when complete."
}

Out-JsonResponse -Status "success" -Message "Specification ready for clarification review" -Data $data
