# d3-research.ps1 - Gather technical research for a feature

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$specFile = Join-Path $FeatureDir "spec.md"
if (-not (Test-Path $specFile)) {
    Out-JsonResponse -Status "error" -Message "spec.md not found"
    exit 1
}

$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$researchFile = Join-Path $FeatureDir "research.md"

$content = @"
# Research: Technical Exploration

## Areas Covered

### 1. Library/Framework Comparisons
- [ ] Compare relevant libraries/frameworks
- [ ] Document pros/cons of each option
- [ ] Recommend best solution for this feature

### 2. Performance Considerations
- [ ] Identify performance bottlenecks
- [ ] Research optimization strategies
- [ ] Define acceptable performance thresholds

### 3. Security/Privacy Concerns
- [ ] Identify potential security risks
- [ ] Research security best practices
- [ ] Document compliance requirements

### 4. Integration Patterns
- [ ] Document API integration patterns
- [ ] Research data flow patterns
- [ ] Identify external dependencies

### 5. Similar Solutions
- [ ] Research existing implementations
- [ ] Analyze open-source examples
- [ ] Document lessons learned

## Findings

### Technology Stack Recommendations

- [Document your findings here]

### Key Dependencies

- [List critical dependencies and rationale]

### Risk Factors

- [Identify and mitigate risks]

## Next Steps

- Use findings to inform the implementation plan
- Document selected approaches in the plan artifact

---
Created: $(Get-FormattedDate)
"@

$content | Set-Content -Path $researchFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; research_file=$researchFile}
Out-JsonResponse -Status "success" -Message "Research file created successfully" -Data $data
