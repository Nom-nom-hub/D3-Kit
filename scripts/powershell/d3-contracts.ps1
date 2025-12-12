# d3-contracts.ps1 - Generate API contracts

param([string]$FeatureDir = "")
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "d3-utils.ps1")

if ([string]::IsNullOrWhiteSpace($FeatureDir) -or -not (Test-Path $FeatureDir)) {
    Out-JsonResponse -Status "error" -Message "Valid feature directory required"
    exit 1
}

$planFile = Join-Path $FeatureDir "plan.md"
if (-not (Test-Path $planFile)) {
    Out-JsonResponse -Status "error" -Message "plan.md not found"
    exit 1
}

$featureName = (Split-Path -Leaf $FeatureDir) -replace "^[0-9]+-", ""
$contractsDir = Join-Path $FeatureDir "contracts"
New-Item -ItemType Directory -Path $contractsDir -Force | Out-Null

$contractsFile = Join-Path $contractsDir "api.md"

$content = @"
# API Contracts

## Endpoints

### Endpoint 1: [GET /api/resource]

**Purpose**: [What does this endpoint do?]

**Request**:
\`\`\`
GET /api/resource/{id}
Content-Type: application/json
Authorization: Bearer {token}
\`\`\`

**Request Parameters**:
- ``id`` (string, required): Resource identifier
- ``fields`` (string, optional): Comma-separated fields to return

**Response** (200 OK):
\`\`\`json
{
  "id": "uuid",
  "name": "Resource Name",
  "status": "active",
  "created_at": "2025-12-12T00:00:00Z"
}
\`\`\`

**Error Responses**:
- ``400 Bad Request``: Invalid parameters
- ``401 Unauthorized``: Missing or invalid authentication
- ``404 Not Found``: Resource not found
- ``500 Internal Server Error``: Server error

---

### Endpoint 2: [POST /api/resource]

**Purpose**: [Create a new resource]

**Request**:
\`\`\`
POST /api/resource
Content-Type: application/json
Authorization: Bearer {token}
\`\`\`

**Request Body**:
\`\`\`json
{
  "name": "Resource Name",
  "description": "Optional description"
}
\`\`\`

**Response** (201 Created):
\`\`\`json
{
  "id": "new-uuid",
  "name": "Resource Name",
  "description": "Optional description",
  "created_at": "2025-12-12T00:00:00Z"
}
\`\`\`

---

## Rate Limiting

- **Limit**: 1000 requests per minute per API key
- **Header**: ``X-RateLimit-Remaining``
- **Exceed**: Return 429 Too Many Requests

## Authentication

- **Type**: Bearer Token (JWT)
- **Header**: ``Authorization: Bearer {token}``
- **Token Expiry**: 24 hours

## Error Format

\`\`\`json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
\`\`\`

---
Created: $(Get-FormattedDate)
"@

$content | Set-Content -Path $contractsFile -Encoding UTF8

$data = @{feature_dir=$FeatureDir; feature_name=$featureName; contracts_file=$contractsFile}
Out-JsonResponse -Status "success" -Message "API contracts generated successfully" -Data $data
