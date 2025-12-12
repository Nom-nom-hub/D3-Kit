#!/usr/bin/env pwsh

# PowerShell script to update agent context from D3 feature

param(
    [switch]$Json,
    [string]$FeatureDir,
    [string]$ContextFile = ".d3-context.md",
    [switch]$Quiet
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
    if (!$Quiet) {
        Write-Host "[d3-kit] INFO: $Message" -ForegroundColor Cyan
    }
}

function Write-Warn {
    param([string]$Message)
    if (!$Quiet) {
        Write-Host "[d3-kit] WARN: $Message" -ForegroundColor Yellow
    }
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

$specFile = Join-Path $featureDir "spec.md"

if (!(Test-Path $specFile)) {
    Write-Error "spec.md not found in $featureDir"
    exit 1
}

Write-Info "Updating agent context from feature directory: $featureDir"

# Create context file
$contextPath = Join-Path $repoRoot $ContextFile

# Start building context content
$content = @()
$content += "# D3 Feature Context"
$content += ""
$content += "Auto-generated from feature specifications. Last updated: $(Get-Date)"
$content += ""

# Add spec content if it exists
if (Test-Path $specFile) {
    $content += "## Feature Specification"
    $content += ""
    $content += Get-Content $specFile -Raw
    $content += ""
}

# Add plan content if it exists
$planFile = Join-Path $featureDir "plan.md"
if (Test-Path $planFile) {
    $content += "## Implementation Plan"
    $content += ""
    $content += Get-Content $planFile -Raw
    $content += ""
}

# Add data model content if it exists
$dataModelFile = Join-Path $featureDir "data-model.md"
if (Test-Path $dataModelFile) {
    $content += "## Data Model"
    $content += ""
    $content += Get-Content $dataModelFile -Raw
    $content += ""
}

# Add quickstart content if it exists
$quickstartFile = Join-Path $featureDir "quickstart.md"
if (Test-Path $quickstartFile) {
    $content += "## Quickstart Guide"
    $content += ""
    $content += Get-Content $quickstartFile -Raw
    $content += ""
}

# Add task content if it exists
$tasksFile = Join-Path $featureDir "tasks.md"
if (Test-Path $tasksFile) {
    $content += "## Task List"
    $content += ""
    $content += Get-Content $tasksFile -Raw
    $content += ""
}

# Add contracts if they exist
$contractsDir = Join-Path $featureDir "contracts"
if (Test-Path $contractsDir) {
    $content += "## API Contracts"
    $content += ""
    
    $contractFiles = Get-ChildItem -Path $contractsDir -Filter "*.md"
    foreach ($contract in $contractFiles) {
        $content += "### $($contract.BaseName)"
        $content += ""
        $content += Get-Content $contract.FullName -Raw
        $content += ""
    }
}

# Add footer
$content += ""
$content += "<!-- AUTO-GENERATED CONTENT - DO NOT EDIT MANUALLY -->"

# Write context file
$content | Out-File -FilePath $contextPath -Encoding UTF8

Write-Info "Updated context file: $contextPath"
Write-Info "Feature: $((Split-Path $featureDir -Leaf))"
Write-Info "Spec: $(if (Test-Path $specFile) { "included" } else { "missing" })"
Write-Info "Plan: $(if (Test-Path (Join-Path $featureDir "plan.md")) { "included" } else { "missing" })"
Write-Info "Data Model: $(if (Test-Path (Join-Path $featureDir "data-model.md")) { "included" } else { "missing" })"

if ($Json) {
    $result = @{
        context_file = $contextPath
        feature_dir = $featureDir
        d3_feature = $env:D3_FEATURE
        status = "updated"
    }
    $result | ConvertTo-Json
} else {
    Write-Host "Context file updated: $contextPath"
}