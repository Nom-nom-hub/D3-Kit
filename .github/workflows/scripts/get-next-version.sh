#!/usr/bin/env bash

set -e

# Determine the next version based on conventional commits
# Usage: ./get-next-version.sh [current_version]

CURRENT_VERSION="${1:-$(python -c 'import d3_kit; print(d3_kit.__version__)' 2>/dev/null || echo '1.0.0')}"

# Extract the version numbers
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Default to patch increment
NEXT_PATCH=$((PATCH + 1))
NEXT_MINOR=$MINOR
NEXT_MAJOR=$MAJOR

# Check git logs for conventional commit types that would indicate version bumps
if git log --oneline -10 --grep="^feat(\|^feat:" --exit-code >/dev/null 2>&1; then
    # Major feature found, increment minor (following semver - features could break compatibility)
    NEXT_MINOR=$((MINOR + 1))
    NEXT_PATCH=0
elif git log --oneline -10 --grep="^BREAKING CHANGE\|^BREAKING-CHANGE:" --exit-code >/dev/null 2>&1; then
    # Breaking change found, increment major
    NEXT_MAJOR=$((MAJOR + 1))
    NEXT_MINOR=0
    NEXT_PATCH=0
fi

echo "${NEXT_MAJOR}.${NEXT_MINOR}.${NEXT_PATCH}"