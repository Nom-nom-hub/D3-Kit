# d3-intend.ps1 - Create feature specification from user description

param(
    [string]$Description = ""
)

$ErrorActionPreference = "Stop"

# Source utility functions
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$utils = Join-Path $scriptDir "d3-utils.ps1"
. $utils

# Validate input
if ([string]::IsNullOrWhiteSpace($Description)) {
    Out-JsonResponse -Status "error" -Message "Feature description required"
    exit 1
}

$repoRoot = Get-RepoRoot

# Generate feature name and number
$featureName = New-FeatureName -Description $Description
$featureNum = Get-NextFeatureNumber -ShortName $featureName
$branchName = "${featureNum}-${featureName}"

# Create feature directory
$featureDir = New-FeatureStructure -RepoRoot $repoRoot -FeatureNum $featureNum -FeatureName $featureName

# Load template
try {
    $template = Get-Template -RepoRoot $repoRoot -TemplateName "d3-spec-template.md"
}
catch {
    Out-JsonResponse -Status "error" -Message $_.Exception.Message
    exit 1
}

# Replace placeholders
$content = $template
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "FEATURE_NAME" -Value $featureName
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "FEATURE_BRANCH" -Value $branchName
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "CREATION_DATE" -Value (Get-FormattedDate)
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "DESCRIPTION" -Value $Description
$content = Invoke-PlaceholderReplacement -Content $content -Placeholder "DEVELOPER_NAME" -Value "Developer"

# Write spec file
$specFile = Join-Path $featureDir "spec.md"
$content | Set-Content -Path $specFile -Encoding UTF8

# Create git branch
New-GitBranch -BranchName $branchName

# Prepare JSON response
$data = @{
    branch_name = $branchName
    feature_number = $featureNum
    feature_name = $featureName
    feature_dir = $featureDir
    spec_file = $specFile
    description = $Description
}

Out-JsonResponse -Status "success" -Message "Feature specification created successfully" -Data $data
