#!/usr/bin/env pwsh

# PowerShell script to check D3-Kit prerequisites

param(
    [switch]$Json
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

# Check prerequisites function
function Test-D3Prerequisites {
    $missing = @()
    
    # Check for git
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        $missing += "git"
    }
    
    # Check for basic utilities (Windows equivalent checks)
    if (!(Get-Command grep -ErrorAction SilentlyContinue)) {
        $missing += "grep"
    }
    if (!(Get-Command sed -ErrorAction SilentlyContinue)) {
        $missing += "sed"
    }
    if (!(Get-Command awk -ErrorAction SilentlyContinue)) {
        $missing += "awk"
    }
    
    # Check for jq (optional but useful for JSON processing)
    if (!(Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Warn "jq not found (optional for JSON processing)"
    }
    
    # Check for Python if needed
    if (!(Get-Command python3 -ErrorAction SilentlyContinue) -and 
        !(Get-Command python -ErrorAction SilentlyContinue)) {
        $missing += "python3"
    }
    
    # Check for curl or wget for HTTP operations
    if (!(Get-Command curl -ErrorAction SilentlyContinue) -and
        !(Get-Command wget -ErrorAction SilentlyContinue)) {
        $missing += "curl or wget"
    }
    
    if ($missing.Count -gt 0) {
        Write-Error "Missing required commands: $($missing -join ', ')"
        Write-Host "Please install the missing dependencies and try again."
        return $false
    }
    
    Write-Info "All prerequisites satisfied"
    return $true
}

# Main execution
if ($Json) {
    $result = Test-D3Prerequisites
    if ($result) {
        $response = @{status = "success"; message = "All prerequisites satisfied" }
    } else {
        $response = @{status = "error"; message = "Missing prerequisites" }
        $global:LASTEXITCODE = 1
    }
    $response | ConvertTo-Json
} else {
    $result = Test-D3Prerequisites
    if (!$result) {
        exit 1
    }
}