#!/usr/bin/env pwsh

# PowerShell script to setup plan for a D3 feature

param(
    [switch]$Json,
    [string]$FeatureDir
)

# Function to find the repository root
function Find-RepoRoot {
    param([string]$StartDir = $PWD.Path)
    
    $dir = $StartDir
    while ($dir -ne [System.IO.Path]::GetPathRoot($dir)) {
        if (Test-Path (Join-Path $dir ".git") -PathType Container) -or 
           (Test-Path (Join-Path $dir ".d3") -PathType Container) -or
           (Test-Path (Join-Path $dir "d3-features") -PathType Container) {
            return $dir
        }
        $dir = Split-Path $dir -Parent
    }
    return $null
}

# Function to log messages
function Write-Info {
    param([string]$Message)
    Write-Host "[d3-kit] INFO: $Message" -ForegroundColor Cyan
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[d3-kit] WARN: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[d3-kit] ERROR: $Message" -ForegroundColor Red
}

# Main script execution
$repoRoot = Find-RepoRoot

if (!$repoRoot) {
    Write-Error "Could not determine repository root"
    exit 1
}

# Determine feature directory
if (!$FeatureDir) {
    if ($env:D3_FEATURE) {
        # Use environment variable
        $featureDir = Join-Path $repoRoot "d3-features" $env:D3_FEATURE
    } elseif (Test-Path (Join-Path $PWD.Path "spec.md")) {
        # Current directory is a feature directory
        $featureDir = $PWD.Path
    } elseif (Test-Path (Join-Path $repoRoot "d3-features")) {
        # Look for the most recently created feature directory
        $d3FeaturesPath = Join-Path $repoRoot "d3-features"
        $latestFeatureDir = Get-ChildItem -Path $d3FeaturesPath -Directory | 
                           Sort-Object CreationTime -Descending | 
                           Select-Object -First 1
        if ($latestFeatureDir) {
            $featureDir = $latestFeatureDir.FullName
        } else {
            Write-Error "Could not determine feature directory. Set D3_FEATURE or use -FeatureDir."
            exit 1
        }
    } else {
        Write-Error "Could not determine feature directory. Set D3_FEATURE or use -FeatureDir."
        exit 1
    }
} elseif (!(Test-Path $FeatureDir)) {
    Write-Error "Feature directory does not exist: $FeatureDir"
    exit 1
}

Write-Info "Setting up plan for feature directory: $featureDir"

$specFile = Join-Path $featureDir "spec.md"
$planFile = Join-Path $featureDir "plan.md"
$dataModelFile = Join-Path $featureDir "data-model.md"
$quickstartFile = Join-Path $featureDir "quickstart.md"
$contractsDir = Join-Path $featureDir "contracts"

# Check if spec file exists
if (!(Test-Path $specFile)) {
    Write-Error "spec.md not found in $featureDir"
    exit 1
}

# Create missing directories
if (!(Test-Path $contractsDir)) {
    New-Item -ItemType Directory -Path $contractsDir -Force | Out-Null
}

# Copy templates if files don't exist
$templatesDir = Join-Path $repoRoot "D3-templates"

if (!(Test-Path $planFile) -and (Test-Path (Join-Path $templatesDir "d3-plan-template.md"))) {
    Copy-Item (Join-Path $templatesDir "d3-plan-template.md") $planFile
    Write-Info "Created plan.md from template"
}

if (!(Test-Path $dataModelFile) -and (Test-Path (Join-Path $templatesDir "d3-commands" "d3.data.md"))) {
    Copy-Item (Join-Path $templatesDir "d3-commands" "d3.data.md") $dataModelFile
    Write-Info "Created data-model.md from template"
}

if (!(Test-Path $quickstartFile) -and (Test-Path (Join-Path $templatesDir "d3-commands" "d3.quickstart.md"))) {
    Copy-Item (Join-Path $templatesDir "d3-commands" "d3.quickstart.md") $quickstartFile
    Write-Info "Created quickstart.md from template"
}

# Create contracts directory structure if needed
$contractsTemplateDir = Join-Path $templatesDir "contracts"
if (Test-Path $contractsTemplateDir) {
    $contractFiles = Get-ChildItem -Path $contractsTemplateDir -File
    foreach ($file in $contractFiles) {
        Copy-Item $file.FullName $contractsDir -Force
    }
}

# Check if plan file exists now
if (!(Test-Path $planFile)) {
    New-Item -ItemType File -Path $planFile -Force | Out-Null
    Write-Warn "Created empty plan.md file"
}

# Update environment variable if not already set
if (!$env:D3_FEATURE) {
    $env:D3_FEATURE = Split-Path $featureDir -Leaf
}

# Output results
if ($Json) {
    $result = @{
        feature_dir = $featureDir
        spec_file = $specFile
        plan_file = $planFile
        data_model_file = $dataModelFile
        quickstart_file = $quickstartFile
        contracts_dir = $contractsDir
        d3_feature = $env:D3_FEATURE
    }
    $result | ConvertTo-Json
} else {
    Write-Host "Feature Directory: $featureDir"
    Write-Host "Spec File: $specFile"
    Write-Host "Plan File: $planFile"
    Write-Host "Data Model File: $dataModelFile"
    Write-Host "Quickstart File: $quickstartFile"
    Write-Host "Contracts Directory: $contractsDir"
    Write-Host "D3_FEATURE environment variable set to: $env:D3_FEATURE"
}