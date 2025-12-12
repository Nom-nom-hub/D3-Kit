# d3-tasks.ps1 - Generate executable tasks from implementation plan

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$repoRoot = Get-RepoRoot
$planFile = Join-Path $FeatureDir "plan.md"
if (-not (Test-Path $planFile)) {
    Out-JsonResponse -Status "error" -Message "plan.md not found"
    exit 1
}

$template = Get-Template -RepoRoot $repoRoot -TemplateName "d3-tasks-template.md"
$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$content = $template
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "FEATURE_NAME" -Value $featureName
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "CREATION_DATE" -Value (Get-FormattedDate)

$tasksFile = Join-Path $FeatureDir "tasks.md"
$content | Set-Content -Path $tasksFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; tasks_file=$tasksFile; plan_file=$planFile}
Out-JsonResponse -Status "success" -Message "Executable tasks generated successfully" -Data $data
