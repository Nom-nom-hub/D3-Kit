# d3-utils.ps1 - Shared utility functions for D3-Kit scripts

$ErrorActionPreference = "Stop"

# Get the repo root directory
function Get-RepoRoot {
    $currentDir = Get-Location
    while ($currentDir -ne [System.IO.Path]::GetPathRoot($currentDir)) {
        if ((Test-Path (Join-Path $currentDir ".git")) -or (Test-Path (Join-Path $currentDir "D3-Kit-Methodology.md"))) {
            return $currentDir
        }
        $currentDir = Split-Path $currentDir -Parent
    }
    return "."
}

# Output JSON response
function Out-JsonResponse {
    param(
        [string]$Status,
        [string]$Message,
        [object]$Data = @{}
    )
    
    $response = @{
        status = $Status
        message = $Message
        timestamp = (Get-Date -AsUTC -Format "yyyy-MM-ddTHH:mm:ssZ")
        data = $Data
    }
    
    $response | ConvertTo-Json -Depth 10
}

# Generate feature name from description
function New-FeatureName {
    param([string]$Description)
    
    # Extract first few significant words, convert to lowercase, replace spaces with hyphens
    $words = $Description -replace "[^a-zA-Z0-9 ]", "" -split " " | Where-Object { $_ } | Select-Object -First 4
    return ($words | ForEach-Object { $_.ToLower() }) -join "-"
}

# Get next feature number
function Get-NextFeatureNumber {
    param([string]$ShortName)
    
    $repoRoot = Get-RepoRoot
    $maxNum = 0
    
    # Check d3-features directories
    $featuresDir = Join-Path $repoRoot "d3-features"
    if (Test-Path $featuresDir) {
        Get-ChildItem $featuresDir -Directory | Where-Object { $_.Name -match "^[0-9]+.*$ShortName" } | ForEach-Object {
            if ($_.Name -match "^([0-9]+)-") {
                $num = [int]$matches[1]
                if ($num -gt $maxNum) { $maxNum = $num }
            }
        }
    }
    
    # Check git branches
    try {
        $branches = git branch -a 2>$null | ForEach-Object { $_.Trim().TrimStart('*').Trim() } | Where-Object { $_ -match "$ShortName" }
        $branches | ForEach-Object {
            if ($_ -match "^([0-9]+)-") {
                $num = [int]$matches[1]
                if ($num -gt $maxNum) { $maxNum = $num }
            }
        }
    }
    catch { }
    
    return $maxNum + 1
}

# Create feature directory structure
function New-FeatureStructure {
    param(
        [string]$RepoRoot,
        [int]$FeatureNum,
        [string]$FeatureName
    )
    
    $featureDir = Join-Path $repoRoot "d3-features" "${FeatureNum}-${FeatureName}"
    New-Item -ItemType Directory -Path $featureDir -Force | Out-Null
    
    return $featureDir
}

# Load template file
function Get-Template {
    param(
        [string]$RepoRoot,
        [string]$TemplateName
    )
    
    $templateFile = Join-Path $repoRoot "D3-templates" $TemplateName
    
    if (-not (Test-Path $templateFile)) {
        throw "Template not found: $templateFile"
    }
    
    return (Get-Content $templateFile -Raw)
}

# Replace placeholder in content
function Invoke-PlaceholderReplacement {
    param(
        [string]$Content,
        [string]$Placeholder,
        [string]$Value
    )
    
    return $Content -replace "{$Placeholder}", $Value
}

# Extract body (content after frontmatter)
function Get-TemplateBody {
    param([string]$Content)
    
    $lines = $Content -split "`n"
    $inFrontmatter = $false
    $seenClosing = $false
    $body = @()
    
    foreach ($line in $lines) {
        if ($line -eq "---") {
            if (-not $inFrontmatter) {
                $inFrontmatter = $true
            }
            elseif ($inFrontmatter) {
                $seenClosing = $true
                continue
            }
        }
        elseif ($seenClosing) {
            $body += $line
        }
    }
    
    return $body -join "`n"
}

# Format date
function Get-FormattedDate {
    return (Get-Date -Format "yyyy-MM-dd")
}

# Create git branch if git is available
function New-GitBranch {
    param([string]$BranchName)
    
    try {
        if (-not (git rev-parse --git-dir 2>$null)) {
            return
        }
        
        # Check if branch exists
        $exists = git rev-parse --verify $BranchName 2>$null
        if ($exists) {
            git checkout $BranchName 2>$null | Out-Null
        }
        else {
            git checkout -b $BranchName 2>$null | Out-Null
        }
    }
    catch { }
}

# Validate required arguments
function Test-RequiredArguments {
    param(
        [int]$RequiredCount,
        [object[]]$ProvidedArgs
    )
    
    if ($ProvidedArgs.Count -lt $RequiredCount) {
        Out-JsonResponse -Status "error" -Message "Missing required arguments. Expected at least $RequiredCount arguments, got $($ProvidedArgs.Count)"
        exit 1
    }
}

# Export functions for use in other scripts
Export-ModuleMember -Function * -Variable *
