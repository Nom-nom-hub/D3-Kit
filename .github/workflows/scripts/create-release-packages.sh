#!/usr/bin/env bash
set -euo pipefail

# create-release-packages.sh
# Build D3-Kit template release archives for each supported AI assistant and script type.
# Usage: .github/workflows/scripts/create-release-packages.sh <version>
#   Version argument should include leading 'v'.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version-with-v-prefix>" >&2
  exit 1
fi
NEW_VERSION="$1"
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must look like v0.0.0" >&2
  exit 1
fi

echo "Building release packages for $NEW_VERSION"

# Create and use .genreleases directory for all build artifacts
GENRELEASES_DIR=".genreleases"
mkdir -p "$GENRELEASES_DIR"
rm -rf "$GENRELEASES_DIR"/* || true

build_variant() {
  local agent=$1 script=$2
  local base_dir="$GENRELEASES_DIR/d3-kit-${agent}-package-${script}"
  echo "Building $agent ($script) package..."
  mkdir -p "$base_dir"

  # Create .d3 directory
  D3_DIR="$base_dir/.d3"
  mkdir -p "$D3_DIR"

  # Create config.toml for this agent
  cat > "$D3_DIR/config.toml" <<EOF
# D3-Kit Configuration
# This file configures the D3-Kit development environment for $agent

[project]
name = "my-d3-project"
assistant = "$agent"
features_dir = "d3-features"
contracts_dir = "contracts"

[directories]
features = "d3-features"
contracts = "contracts"
templates = "D3-templates"
scripts = "scripts"

[commands]
intend = "D3-templates/d3-commands/d3.intend.md"
plan = "D3-templates/d3-commands/d3.plan.md"
tasks = "D3-templates/d3-commands/d3.tasks.md"
specify = "D3-templates/d3-commands/d3.intend.md"
implement = "D3-templates/d3-commands/d3.implement.md"
clarify = "D3-templates/d3-commands/d3.clarify.md"
analyze = "D3-templates/d3-commands/d3.analyze.md"
checklist = "D3-templates/d3-commands/d3.checklist.md"
constitution = "D3-templates/d3-commands/d3.constitution.md"
research = "D3-templates/d3-commands/d3.research.md"
data = "D3-templates/d3-commands/d3.data.md"
contracts = "D3-templates/d3-commands/d3.contracts.md"
quickstart = "D3-templates/d3-commands/d3.quickstart.md"
EOF

  # Copy D3 templates
  [[ -d D3-templates ]] && { cp -r D3-templates "$base_dir/"; echo "Copied D3-templates"; }

  # Create d3-features directory
  mkdir -p "$base_dir/d3-features"

  # Create scripts directory with appropriate script type
  mkdir -p "$base_dir/scripts"
  case $script in
    sh)
      mkdir -p "$base_dir/scripts/bash"
      echo "#!/bin/bash" > "$base_dir/scripts/bash/example.sh"
      echo "# Add your bash scripts here" >> "$base_dir/scripts/bash/example.sh"
      ;;
    ps)
      mkdir -p "$base_dir/scripts/powershell"
      echo "# Add your PowerShell scripts here" > "$base_dir/scripts/powershell/example.ps1"
      ;;
  esac

  # Create README
  cat > "$base_dir/README.md" <<EOF
# D3-Kit Template for $agent

This is a pre-configured D3-Kit template for $agent.

## Getting Started

1. Extract this template to your project directory
2. Open the project in your $agent editor
3. Use D3 commands in your agent's interface

## D3 Commands

- \`/d3.intend\` - Specify features with developer intent
- \`/d3.plan\` - Create implementation plans
- \`/d3.tasks\` - Generate executable task lists
- \`/d3.implement\` - Execute tasks to implement features
- \`/d3.clarify\` - Clarify underspecified requirements
- \`/d3.analyze\` - Cross-artifact consistency analysis
- \`/d3.checklist\` - Generate quality checklists
- \`/d3.research\` - Gather technical research
- \`/d3.data\` - Generate data models
- \`/d3.contracts\` - Generate API contracts
- \`/d3.quickstart\` - Create quickstart guides
- \`/d3.constitution\` - Create project principles

## Documentation

See the main D3-Kit repository for more information: https://github.com/Nom-nom-hub/D3-Kit
EOF

  ( cd "$base_dir" && zip -r "../d3-kit-template-${agent}-${script}-${NEW_VERSION}.zip" . )
  echo "Created $GENRELEASES_DIR/d3-kit-template-${agent}-${script}-${NEW_VERSION}.zip"
}

# Agent list
ALL_AGENTS=(amp auggie bob claude copilot cursor-agent gemini kilocode opencode q qoder qwen roo shai windsurf)
ALL_SCRIPTS=(sh ps)

echo "Agents: ${ALL_AGENTS[*]}"
echo "Scripts: ${ALL_SCRIPTS[*]}"

for agent in "${ALL_AGENTS[@]}"; do
  for script in "${ALL_SCRIPTS[@]}"; do
    build_variant "$agent" "$script"
  done
done

echo "Archives in $GENRELEASES_DIR:"
ls -1 "$GENRELEASES_DIR"/d3-kit-template-*-"${NEW_VERSION}".zip
