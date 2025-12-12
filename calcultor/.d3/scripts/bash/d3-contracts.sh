#!/bin/bash
# d3-contracts.sh - Generate API contracts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/d3-utils.sh"

REPO_ROOT=$(get_repo_root)
FEATURE_DIR="${1:-}"

# Validate input
if [[ -z "$FEATURE_DIR" ]] || [[ ! -d "$FEATURE_DIR" ]]; then
  output_json "error" "Valid feature directory required"
  exit 1
fi

# Check for plan file
PLAN_FILE="$FEATURE_DIR/plan.md"
if [[ ! -f "$PLAN_FILE" ]]; then
  output_json "error" "plan.md not found in feature directory"
  exit 1
fi

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Create contracts directory
mkdir -p "$FEATURE_DIR/contracts"

# Create API contract file
CONTRACTS_FILE="$FEATURE_DIR/contracts/api.md"

cat > "$CONTRACTS_FILE" <<'EOF'
# API Contracts

## Endpoints

### Endpoint 1: [GET /api/resource]

**Purpose**: [What does this endpoint do?]

**Request**:
```
GET /api/resource/{id}
Content-Type: application/json
Authorization: Bearer {token}
```

**Request Parameters**:
- `id` (string, required): Resource identifier
- `fields` (string, optional): Comma-separated fields to return

**Response** (200 OK):
```json
{
  "id": "uuid",
  "name": "Resource Name",
  "status": "active",
  "created_at": "2025-12-12T00:00:00Z"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid parameters
- `401 Unauthorized`: Missing or invalid authentication
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

### Endpoint 2: [POST /api/resource]

**Purpose**: [Create a new resource]

**Request**:
```
POST /api/resource
Content-Type: application/json
Authorization: Bearer {token}
```

**Request Body**:
```json
{
  "name": "Resource Name",
  "description": "Optional description"
}
```

**Response** (201 Created):
```json
{
  "id": "new-uuid",
  "name": "Resource Name",
  "description": "Optional description",
  "created_at": "2025-12-12T00:00:00Z"
}
```

---

## Events

### Event: [resource.created]

**Triggered When**: A new resource is created

**Payload**:
```json
{
  "event_type": "resource.created",
  "timestamp": "2025-12-12T00:00:00Z",
  "data": {
    "id": "uuid",
    "name": "Resource Name"
  }
}
```

---

## Rate Limiting

- **Limit**: 1000 requests per minute per API key
- **Header**: `X-RateLimit-Remaining`
- **Exceed**: Return 429 Too Many Requests

## Authentication

- **Type**: Bearer Token (JWT)
- **Header**: `Authorization: Bearer {token}`
- **Token Expiry**: 24 hours

## Error Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

---
Created: $(date +%Y-%m-%d)
EOF

# Prepare JSON response
JSON_DATA=$(cat <<EOF
{
  "feature_dir": "$FEATURE_DIR",
  "feature_name": "$FEATURE_NAME",
  "contracts_file": "$CONTRACTS_FILE"
}
EOF
)

output_json "success" "API contracts generated successfully" "$JSON_DATA"
