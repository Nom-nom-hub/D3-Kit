#!/usr/bin/env bash

set -e

# Update version in pyproject.toml and __init__.py
# Usage: ./update-version.sh <new_version>

NEW_VERSION="$1"

if [ -z "$NEW_VERSION" ]; then
    echo "Usage: $0 <new_version>"
    exit 1
fi

echo "Updating version to $NEW_VERSION"

# Update version in pyproject.toml
if command -v sed >/dev/null 2>&1; then
    sed -i.bak "s/^version = \".*\"/version = \"$NEW_VERSION\"/" pyproject.toml
    rm -f pyproject.toml.bak
else
    # For macOS with BSD sed
    sed -i.bak -E "s/^(version = \")[^\"]+(\")/\1$NEW_VERSION\2/" pyproject.toml
    rm -f pyproject.toml.bak
fi

# Update version in __init__.py
if command -v sed >/dev/null 2>&1; then
    sed -i.bak "s/^__version__ = \".*\"/__version__ = \"$NEW_VERSION\"/" src/d3_kit/__init__.py
    rm -f src/d3_kit/__init__.py.bak
else
    # For macOS with BSD sed
    sed -i.bak -E "s/^(__version__ = \")[^\"]+(\")/\1$NEW_VERSION\2/" src/d3_kit/__init__.py
    rm -f src/d3_kit/__init__.py.bak
fi

echo "Version updated to $NEW_VERSION"