#!/usr/bin/env bash
set -euo pipefail

# create-github-release.sh
# Create a GitHub release with all template zip files
# Usage: create-github-release.sh <version>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"

# Remove 'v' prefix from version for release title
VERSION_NO_V=${VERSION#v}

# Build the array of files dynamically
FILES=()
for zip in .genreleases/d3-kit-template-*-"${VERSION}".zip; do
  [[ -f "$zip" ]] && FILES+=("$zip")
done

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: No template files found for $VERSION" >&2
  exit 1
fi

gh release create "$VERSION" "${FILES[@]}" \
  --title "D3-Kit Templates - $VERSION_NO_V Latest" \
  --notes "Pre-configured D3-Kit templates for multiple AI assistants. Download the template for your preferred agent.

**Available Templates:**
- Amp
- Auggie
- Claude
- Copilot
- Cursor
- Gemini
- KiloCode
- OpenCode
- Qoder
- Qwen
- Roo
- SHAI
- WindSurf
- Amazon Q

Each template includes shell (.sh) and PowerShell (.ps1) variants."
