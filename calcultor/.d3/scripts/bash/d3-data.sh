#!/bin/bash
# d3-data.sh - Generate data models and entities

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

# Check for spec file
SPEC_FILE="$FEATURE_DIR/spec.md"
if [[ ! -f "$SPEC_FILE" ]]; then
  output_json "error" "spec.md not found in feature directory"
  exit 1
fi

# Extract feature name from directory
FEATURE_NAME=$(basename "$FEATURE_DIR" | sed 's/^[0-9]*-//')

# Create data model file
DATA_FILE="$FEATURE_DIR/data-model.md"

cat > "$DATA_FILE" <<'EOF'
# Data Model

## Key Entities

### Entity 1
- **Name**: [Entity Name]
- **Description**: [What does this entity represent?]
- **Attributes**:
  - `id` (UUID): Unique identifier
  - `name` (string): Entity name
  - `created_at` (timestamp): Creation time
  - `updated_at` (timestamp): Last update time

### Entity 2
- **Name**: [Entity Name]
- **Description**: [What does this entity represent?]
- **Attributes**:
  - [Define attributes here]

## Relationships

```
[Entity 1] ──has_many──> [Entity 2]
[Entity 2] ──belongs_to──> [Entity 1]
```

## State Diagram

```
[Initial State] ──action──> [Next State] ──action──> [Final State]
```

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

```json
{
  "entity1": {
    "id": "uuid-1",
    "name": "Example",
    "created_at": "2025-12-12T00:00:00Z"
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
  "data_file": "$DATA_FILE"
}
EOF
)

output_json "success" "Data model file created successfully" "$JSON_DATA"
