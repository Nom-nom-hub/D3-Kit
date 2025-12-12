# common.ps1
# Common functions for D3-Kit PowerShell scripts

# Function to find the repository root by searching for existing project markers
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

# Function to check if running in a git repository
function Test-GitRepo {
    try {
        $null = git rev-parse --git-dir 2>$null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# Function to get the repository root
function Get-RepoRoot {
    if (Test-GitRepo) {
        return git rev-parse --show-toplevel
    } else {
        return Find-RepoRoot
    }
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

# Function to check prerequisites
function Test-Prerequisites {
    $missing = @()
    
    # Check for git
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        $missing += "git"
    }
    
    # Check for basic shell utilities (which may not be available on Windows)
    if (!(Get-Command grep -ErrorAction SilentlyContinue)) {
        $missing += "grep"
    }
    if (!(Get-Command sed -ErrorAction SilentlyContinue)) {
        $missing += "sed"
    }
    if (!(Get-Command awk -ErrorAction SilentlyContinue)) {
        $missing += "awk"
    }
    
    if ($missing.Count -gt 0) {
        Write-Error "Missing required commands: $($missing -join ', ')"
        return $false
    }
    
    return $true
}

# Function to wait for git operations to complete
function Wait-GitOperation {
    param([int]$Timeout = 30)  # 30 seconds timeout
    
    $count = 0
    while ($count -lt $Timeout) {
        # Try to detect git processes (this is a simplified check)
        $gitProcesses = Get-Process | Where-Object { $_.ProcessName -match "git" }
        if ($gitProcesses.Count -eq 0) {
            return $true
        }
        Start-Sleep -Seconds 1
        $count++
    }
    
    Write-Error "Timeout waiting for git operations to complete"
    return $false
}