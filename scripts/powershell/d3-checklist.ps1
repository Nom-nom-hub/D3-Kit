# d3-checklist.ps1 - Generate quality checklists

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$repoRoot = Get-RepoRoot
$specFile = Join-Path $FeatureDir "spec.md"
if (-not (Test-Path $specFile)) {
    Out-JsonResponse -Status "error" -Message "spec.md not found"
    exit 1
}

$template = Get-Template -RepoRoot $repoRoot -TemplateName "checklist-template.md"
$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$content = $template
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "FEATURE_NAME" -Value $featureName
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "CREATION_DATE" -Value (Get-FormattedDate)

$checklistDir = Join-Path $FeatureDir "checklists"
New-Item -ItemType Directory -Path $checklistDir -Force | Out-Null

$checklistFile = Join-Path $checklistDir "requirements.md"
$content | Set-Content -Path $checklistFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; checklist_file=$checklistFile; spec_file=$specFile}
Out-JsonResponse -Status "success" -Message "Quality checklist generated successfully" -Data $data
