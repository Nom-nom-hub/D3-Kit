#!/usr/bin/env pwsh

# PowerShell script to create a new D3 feature

param(
    [switch]$Json,
    [string]$ShortName,
    [int]$Number,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$FeatureDescription
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

# Function to get highest number from d3-features directory
function Get-HighestFromFeatures {
    param([string]$FeaturesDir)
    
    $highest = 0
    
    if (Test-Path $FeaturesDir) {
        $dirs = Get-ChildItem -Path $FeaturesDir -Directory -Name
        foreach ($dir in $dirs) {
            $number = [int]($dir -replace '^[^0-9]*([0-9]+).*', '$1' -replace '[^0-9]', '')
            if ($number -gt $highest) {
                $highest = $number
            }
        }
    }
    
    return $highest
}

# Function to get highest number from git branches
function Get-HighestFromBranches {
    try {
        $branches = git branch -a 2>$null
        if ($branches) {
            $highest = 0
            foreach ($branch in $branches) {
                $branch = $branch.Trim()
                # Clean branch name: remove leading markers
                $branch = $branch -replace '^[* ]*'
                $branch = $branch -replace '^remotes/[^/]+/', ''
                
                # Extract feature number if branch matches pattern ###-*
                if ($branch -match '^[0-9]{3}-') {
                    $number = [int]($branch.Substring(0, 3))
                    if ($number -gt $highest) {
                        $highest = $number
                    }
                }
            }
            return $highest
        }
    } catch {
        # Git not available or no repo
    }
    return 0
}

# Function to check existing branches and return next available number
function Get-NextBranchNumber {
    param([string]$FeaturesDir)
    
    try {
        # Fetch all remotes to get latest branch info
        git fetch --all --prune 2>$null | Out-Null
    } catch {
        # Ignore errors if no remotes
    }
    
    # Get highest number from ALL branches
    $highestBranch = Get-HighestFromBranches
    
    # Get highest number from ALL features
    $highestFeature = Get-HighestFromFeatures $FeaturesDir
    
    # Take the maximum of both and return next number
    return [Math]::Max($highestBranch, $highestFeature) + 1
}

# Function to clean and format a branch name
function Format-BranchName {
    param([string]$Name)
    
    # Convert to lowercase and replace non-alphanumeric with hyphens
    $clean = $Name.ToLower() -replace '[^a-z0-9]', '-'
    # Replace multiple hyphens with single hyphen
    $clean = $clean -replace '-+', '-'
    # Remove leading/trailing hyphens
    $clean = $clean -replace '^-|-$', ''
    
    return $clean
}

# Function to generate branch name with stop word filtering
function Generate-BranchName {
    param([string]$Description)
    
    # Common stop words to filter out
    $stopWords = @('i', 'a', 'an', 'the', 'to', 'for', 'of', 'in', 'on', 'at', 'by', 'with', 'from', 
                   'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 
                   'did', 'will', 'would', 'should', 'could', 'can', 'may', 'might', 'must', 'shall', 
                   'this', 'that', 'these', 'those', 'my', 'your', 'our', 'their', 'want', 'need', 'add', 'get', 'set')
    
    # Convert to lowercase and split into words
    $words = $Description.ToLower() -split '[^a-z0-9]+'
    
    # Filter words: remove stop words and words shorter than 3 chars
    $meaningfulWords = @()
    foreach ($word in $words) {
        if ($word -and $stopWords -notcontains $word) {
            if ($word.Length -ge 3) {
                $meaningfulWords += $word
            } elseif ($Description -match "\b$([regex]::Escape($word.ToUpper()))\b") {
                # Keep short words if they appear as uppercase in original (likely acronyms)
                $meaningfulWords += $word
            }
        }
    }
    
    # If we have meaningful words, use first 3-4 of them
    if ($meaningfulWords.Count -gt 0) {
        $maxWords = 3
        if ($meaningfulWords.Count -eq 4) { $maxWords = 4 }
        
        $result = @()
        for ($i = 0; $i -lt [Math]::Min($meaningfulWords.Count, $maxWords); $i++) {
            $result += $meaningfulWords[$i]
        }
        return ($result -join '-')
    } else {
        # Fallback to original logic if no meaningful words found
        $cleaned = Format-BranchName $Description
        $parts = $cleaned -split '-'
        return ($parts | Where-Object { $_ } | Select-Object -First 3) -join '-'
    }
}

# Main script execution
$featureDescriptionStr = ($FeatureDescription -join ' ').Trim()

if (!$featureDescriptionStr) {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [--Json] [--ShortName <name>] [--Number N] <feature_description>" -ForegroundColor Red
    exit 1
}

# Resolve repository root
if (Get-Command git -ErrorAction SilentlyContinue) {
    try {
        $repoRoot = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -ne 0) { $repoRoot = $null }
    } catch { $repoRoot = $null }
    $hasGit = $true
} else {
    $repoRoot = Find-RepoRoot
    $hasGit = $false
}

if (!$repoRoot) {
    Write-Host "Error: Could not determine repository root. Please run this script from within the repository." -ForegroundColor Red
    exit 1
}

Set-Location $repoRoot

$d3FeaturesDir = Join-Path $repoRoot "d3-features"
if (!(Test-Path $d3FeaturesDir)) {
    New-Item -ItemType Directory -Path $d3FeaturesDir -Force | Out-Null
}

# Generate branch name
if ($ShortName) {
    # Use provided short name, just clean it up
    $branchSuffix = Format-BranchName $ShortName
} else {
    # Generate from description with smart filtering
    $branchSuffix = Generate-BranchName $featureDescriptionStr
}

# Determine branch number
if (!$Number) {
    if ($hasGit) {
        # Check existing branches on remotes
        $branchNumber = Get-NextBranchNumber $d3FeaturesDir
    } else {
        # Fall back to local directory check
        $highest = Get-HighestFromFeatures $d3FeaturesDir
        $branchNumber = $highest + 1
    }
} else {
    $branchNumber = $Number
}

# Format as 3-digit number
$featureNum = "{0:D3}" -f $branchNumber
$branchName = "${featureNum}-${branchSuffix}"

# GitHub enforces a 244-character limit on branch names
# Validate and truncate if necessary
$maxBranchLength = 244
if ($branchName.Length -gt $maxBranchLength) {
    # Calculate how much we need to trim from suffix
    # Account for: feature number (3) + hyphen (1) = 4 chars
    $maxSuffixLength = $maxBranchLength - 4
    
    # Truncate suffix at word boundary if possible
    $originalBranchName = $branchName
    $truncatedSuffix = $branchSuffix.Substring(0, [Math]::Min($branchSuffix.Length, $maxSuffixLength))
    # Remove trailing hyphen if truncation created one
    $truncatedSuffix = $truncatedSuffix.TrimEnd('-')
    
    $branchName = "${featureNum}-${truncatedSuffix}"
    
    Write-Warning "[d3-kit] Warning: Branch name exceeded GitHub's 244-character limit"
    Write-Warning "[d3-kit] Original: $originalBranchName ($($originalBranchName.Length) chars)"
    Write-Warning "[d3-kit] Truncated to: $branchName ($($branchName.Length) chars)"
}

if ($hasGit) {
    try {
        git checkout -b $branchName 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "[d3-kit] Warning: Failed to create git branch $branchName"
        }
    } catch {
        Write-Warning "[d3-kit] Warning: Git repository not detected; skipped branch creation for $branchName"
    }
} else {
    Write-Warning "[d3-kit] Warning: Git repository not detected; skipped branch creation for $branchName"
}

$featureDir = Join-Path $d3FeaturesDir $branchName
New-Item -ItemType Directory -Path $featureDir -Force | Out-Null

$templatePath = Join-Path $repoRoot "D3-templates" "d3-spec-template.md"
$specFile = Join-Path $featureDir "spec.md"

if (Test-Path $templatePath) {
    Copy-Item $templatePath $specFile
} else {
    New-Item -ItemType File -Path $specFile -Force | Out-Null
}

# Set the D3_FEATURE environment variable for the current session
$env:D3_FEATURE = $branchName

# Output results
if ($Json) {
    $result = @{
        BRANCH_NAME = $branchName
        SPEC_FILE = $specFile
        FEATURE_NUM = $featureNum
    }
    $result | ConvertTo-Json
} else {
    Write-Host "BRANCH_NAME: $branchName"
    Write-Host "SPEC_FILE: $specFile"
    Write-Host "FEATURE_NUM: $featureNum"
    Write-Host "D3_FEATURE environment variable set to: $branchName"
}