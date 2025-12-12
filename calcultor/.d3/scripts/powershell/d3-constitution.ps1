# d3-constitution.ps1 - Create or update project constitution

param([string]$Principles = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

$repoRoot = Get-RepoRoot
$memoryDir = Join-Path $repoRoot "memory"
New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null

$constitutionFile = Join-Path $memoryDir "d3-constitution.md"

$principalsText = if ($Principles) { $Principles } else { "- [Add your project principles here]" }

$content = @"
# D3 Project Constitution

## Project Principles

$principalsText

## Development Guidelines

- All features must start with specification (/d3.intend)
- Features follow the D3 workflow: intend → plan → tasks → implement
- Specifications are written for non-technical stakeholders
- Plans are technology-agnostic high-level designs
- Tasks are concrete, actionable items marked with [P] for parallelizable work

## Governance

- This document is reviewed regularly as new patterns emerge
- Changes to principles require consensus from the development team
- Architecture decisions are documented in the plan artifacts

---
Created: $(Get-FormattedDate)
Last Updated: $(Get-FormattedDate)
"@

$content | Set-Content -Path $constitutionFile -Encoding UTF8

$data = @{constitution_file=$constitutionFile; status="created"}
Out-JsonResponse -Status "success" -Message "Project constitution created/updated successfully" -Data $data
