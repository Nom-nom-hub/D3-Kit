# d3-data.ps1 - Generate data models and entities

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
$dataFile = Join-Path $FeatureDir "data-model.md"

$content = @"
# Data Model

## Key Entities

### Entity 1
- **Name**: [Entity Name]
- **Description**: [What does this entity represent?]
- **Attributes**:
  - ``id`` (UUID): Unique identifier
  - ``name`` (string): Entity name
  - ``created_at`` (timestamp): Creation time
  - ``updated_at`` (timestamp): Last update time

### Entity 2
- **Name**: [Entity Name]
- **Description**: [What does this entity represent?]
- **Attributes**:
  - [Define attributes here]

## Relationships

\`\`\`
[Entity 1] ──has_many──> [Entity 2]
[Entity 2] ──belongs_to──> [Entity 1]
\`\`\`

## State Diagram

\`\`\`
[Initial State] ──action──> [Next State] ──action──> [Final State]
\`\`\`

## Storage Strategy

### Primary Store
- [Define primary data store (database, file system, etc.)]

### Caching
- [Define caching strategy if applicable]

### Persistence
- [Define persistence approach]

## Access Patterns

- **Read**: [How is data queried/read?]
- **Write**: [How is data created/updated?]
- **Delete**: [How is data removed?]

## Constraints and Validations

- [ ] [Constraint/validation 1]
- [ ] [Constraint/validation 2]

## Example Data

\`\`\`json
{
  "entity1": {
    "id": "uuid-1",
    "name": "Example",
    "created_at": "2025-12-12T00:00:00Z"
  }
}
\`\`\`

---
Created: $(Get-FormattedDate)
"@

$content | Set-Content -Path $dataFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; data_file=$dataFile}
Out-JsonResponse -Status "success" -Message "Data model file created successfully" -Data $data
