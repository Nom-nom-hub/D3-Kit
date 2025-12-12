# d3-plan.ps1 - Create implementation plan from specification

param(
    [string]$FeatureDir = ""
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$utils = Join-Path $scriptDir "d3-utils.ps1"
. $utils

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$repoRoot = Get-RepoRoot
$specFile = Join-Path $FeatureDir "spec.md"

if (-not (Test-Path $specFile)) {
    Out-JsonResponse -Status "error" -Message "spec.md not found in feature directory"
    exit 1
}

try {
    $template = Get-Template -RepoRoot $repoRoot -TemplateName "d3-plan-template.md"
}
catch {
    Out-JsonResponse -Status "error" -Message $_.Exception.Message
    exit 1
}

$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""

$content = $template
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "FEATURE_NAME" -Value $featureName
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "CREATION_DATE" -Value (Get-FormattedDate)

$planFile = Join-Path $FeatureDir "plan.md"
$content | Set-Content -Path $planFile -Encoding UTF8

$data = @{
    feature_dir = $FeatureDir
    feature_name = $featureName
    plan_file = $planFile
    spec_file = $specFile
}

Out-JsonResponse -Status "success" -Message "Implementation plan created successfully" -Data $data
