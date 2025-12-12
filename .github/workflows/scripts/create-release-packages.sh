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

generate_agent_commands() {
  local agent=$1 output_dir=$2
  mkdir -p "$output_dir"
  
  # Determine if this agent uses TOML or Markdown
  case $agent in
    gemini|qwen)
      # Generate TOML format for these agents
      cat > "$output_dir/d3.toml" <<'CMD_EOF'
[commands.d3_intend]
name = "/d3.intend"
description = "Specify Feature with Intent"
help = "Capture the developer's intent and create a specification for a new feature."
usage = "/d3.intend <feature-description>"
output = "Creates d3-features/[feature-name]/spec.md"

[commands.d3_plan]
name = "/d3.plan"
description = "Create Implementation Plan"
help = "Create a technical implementation plan from the specification."
usage = "/d3.plan <feature-directory>"
output = "Creates d3-features/[feature-name]/plan.md"

[commands.d3_tasks]
name = "/d3.tasks"
description = "Generate Executable Tasks"
help = "Generate actionable task list from the implementation plan."
usage = "/d3.tasks <feature-directory>"
output = "Creates d3-features/[feature-name]/tasks.md"

[commands.d3_implement]
name = "/d3.implement"
description = "Execute Implementation"
help = "Execute all tasks to build the feature according to the plan."
usage = "/d3.implement <feature-directory>"
output = "Implements the feature based on the task list"

[commands.d3_clarify]
name = "/d3.clarify"
description = "Clarify Requirements"
help = "Ask structured questions to clarify underspecified areas before planning."
usage = "/d3.clarify <feature-directory>"
output = "Updates d3-features/[feature-name]/spec.md"

[commands.d3_analyze]
name = "/d3.analyze"
description = "Cross-artifact Analysis"
help = "Analyze consistency and coverage across specification, plan, and tasks."
usage = "/d3.analyze <feature-directory>"
output = "Creates d3-features/[feature-name]/analysis.md"

[commands.d3_checklist]
name = "/d3.checklist"
description = "Generate Quality Checklist"
help = "Generate custom quality checklists for validating requirements."
usage = "/d3.checklist <feature-directory>"
output = "Creates d3-features/[feature-name]/checklist.md"

[commands.d3_constitution]
name = "/d3.constitution"
description = "Project Principles"
help = "Create or update project governing principles and development guidelines."
usage = "/d3.constitution"
output = "Creates or updates d3-constitution.md"

[commands.d3_research]
name = "/d3.research"
description = "Gather Technical Research"
help = "Gather technical or contextual research automatically for a feature."
usage = "/d3.research <feature-directory>"
output = "Creates d3-features/[feature-name]/research.md"

[commands.d3_data]
name = "/d3.data"
description = "Generate Data Models"
help = "Generate and update key entities and data models for the feature."
usage = "/d3.data <feature-directory>"
output = "Creates d3-features/[feature-name]/data-model.md"

[commands.d3_contracts]
name = "/d3.contracts"
description = "Generate API Contracts"
help = "Generate API and event contracts from the plan."
usage = "/d3.contracts <feature-directory>"
output = "Creates d3-features/[feature-name]/contracts/"

[commands.d3_quickstart]
name = "/d3.quickstart"
description = "Create Validation Guide"
help = "Produce a quickstart/validation guide to verify the feature independently."
usage = "/d3.quickstart <feature-directory>"
output = "Creates d3-features/[feature-name]/quickstart.md"
CMD_EOF
      ;;
    *)
      # Generate Markdown format for all other agents
      cat > "$output_dir/d3.intend.md" <<'CMD_EOF'
# /d3.intend - Specify Feature with Intent

Capture the developer's intent and create a specification for a new feature.

**Usage:** `/d3.intend <feature-description>`

**Output:** Creates `d3-features/[feature-name]/spec.md`

**Purpose:** Define what you want to build (the problem you're solving), who it's for, and why it matters.
CMD_EOF
      
      cat > "$output_dir/d3.plan.md" <<'CMD_EOF'
# /d3.plan - Create Implementation Plan

Create a technical implementation plan from the specification.

**Usage:** `/d3.plan <feature-directory>`

**Output:** Creates `d3-features/[feature-name]/plan.md`

**Purpose:** Map user stories to technical tasks with your chosen tech stack and architecture.
CMD_EOF
      
      cat > "$output_dir/d3.tasks.md" <<'CMD_EOF'
# /d3.tasks - Generate Executable Tasks

Generate actionable task list from the implementation plan.

**Usage:** `/d3.tasks <feature-directory>`

**Output:** Creates `d3-features/[feature-name]/tasks.md`

**Purpose:** Break down the plan into executable, parallelizable tasks.
CMD_EOF
      
      cat > "$output_dir/d3.implement.md" <<'CMD_EOF'
# /d3.implement - Execute Implementation

Execute all tasks to build the feature according to the plan.

**Usage:** `/d3.implement <feature-directory>`

**Output:** Implements the feature based on the task list

**Purpose:** Execute the implementation following the specified plan and tasks.
CMD_EOF
      
      cat > "$output_dir/d3.clarify.md" <<'CMD_EOF'
# /d3.clarify - Clarify Requirements

Ask structured questions to clarify underspecified areas before planning.

**Usage:** `/d3.clarify <feature-directory>`

**Output:** Updates `d3-features/[feature-name]/spec.md`

**Purpose:** De-risk ambiguous areas before investing in implementation.
CMD_EOF
      
      cat > "$output_dir/d3.analyze.md" <<'CMD_EOF'
# /d3.analyze - Cross-artifact Analysis

Analyze consistency and coverage across specification, plan, and tasks.

**Usage:** `/d3.analyze <feature-directory>`

**Output:** Creates `d3-features/[feature-name]/analysis.md`

**Purpose:** Validate that your specification and plan are complete and aligned.
CMD_EOF
      
      cat > "$output_dir/d3.checklist.md" <<'CMD_EOF'
# /d3.checklist - Generate Quality Checklist

Generate custom quality checklists for validating requirements.

**Usage:** `/d3.checklist <feature-directory>`

**Output:** Creates `d3-features/[feature-name]/checklist.md`

**Purpose:** Create quality gates and validation criteria for the feature.
CMD_EOF
      
      cat > "$output_dir/d3.constitution.md" <<'CMD_EOF'
# /d3.constitution - Project Principles

Create or update project governing principles and development guidelines.

**Usage:** `/d3.constitution`

**Output:** Creates or updates `d3-constitution.md`

**Purpose:** Establish project principles that guide all development decisions.
CMD_EOF
      ;;
  esac
}

build_variant() {
  local agent=$1 script=$2
  local base_dir="$GENRELEASES_DIR/d3-kit-${agent}-package-${script}"
  echo "Building $agent ($script) package..."
  mkdir -p "$base_dir"

  # Create .d3 directory
  D3_DIR="$base_dir/.d3"
  mkdir -p "$D3_DIR"

  # Create config.toml for this agent
  cat > "$D3_DIR/config.toml" <<'CONFIG_EOF'
# D3-Kit Configuration
# This file configures the D3-Kit development environment

[project]
name = "my-d3-project"
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
CONFIG_EOF

  # Create agent-specific command files in the agent folder
  AGENT_COMMANDS_DIR=""
  case $agent in
    claude)
      AGENT_COMMANDS_DIR="$base_dir/.claude/commands"
      ;;
    amp)
      AGENT_COMMANDS_DIR="$base_dir/.agents/commands"
      ;;
    copilot)
      AGENT_COMMANDS_DIR="$base_dir/.github/agents"
      ;;
    cursor-agent)
      AGENT_COMMANDS_DIR="$base_dir/.cursor/commands"
      ;;
    gemini)
      AGENT_COMMANDS_DIR="$base_dir/.gemini/commands"
      ;;
    qwen)
      AGENT_COMMANDS_DIR="$base_dir/.qwen/commands"
      ;;
    opencode)
      AGENT_COMMANDS_DIR="$base_dir/.opencode/command"
      ;;
    windsurf)
      AGENT_COMMANDS_DIR="$base_dir/.windsurf/workflows"
      ;;
    kilocode)
      AGENT_COMMANDS_DIR="$base_dir/.kilocode/rules"
      ;;
    auggie)
      AGENT_COMMANDS_DIR="$base_dir/.augment/rules"
      ;;
    roo)
      AGENT_COMMANDS_DIR="$base_dir/.roo/rules"
      ;;
    codebuddy)
      AGENT_COMMANDS_DIR="$base_dir/.codebuddy/commands"
      ;;
    qoder)
      AGENT_COMMANDS_DIR="$base_dir/.qoder/commands"
      ;;
    shai)
      AGENT_COMMANDS_DIR="$base_dir/.shai/commands"
      ;;
    bob)
      AGENT_COMMANDS_DIR="$base_dir/.bob/commands"
      ;;
    q)
      AGENT_COMMANDS_DIR="$base_dir/.amazonq/prompts"
      ;;
    codex)
      AGENT_COMMANDS_DIR="$base_dir/.codex/commands"
      ;;
  esac
  
  if [[ -n "$AGENT_COMMANDS_DIR" ]]; then
    generate_agent_commands "$agent" "$AGENT_COMMANDS_DIR"
    echo "Generated agent-specific commands for $agent"
  fi

  # Copy D3 templates into .d3
  [[ -d D3-templates ]] && { cp -r D3-templates "$D3_DIR/"; echo "Copied D3-templates"; }

  # Create scripts directory inside .d3 with appropriate script type
  mkdir -p "$D3_DIR/scripts"
  case $script in
    sh)
      mkdir -p "$D3_DIR/scripts/bash"
      echo "#!/bin/bash" > "$D3_DIR/scripts/bash/example.sh"
      echo "# Add your bash scripts here" >> "$D3_DIR/scripts/bash/example.sh"
      ;;
    ps)
      mkdir -p "$D3_DIR/scripts/powershell"
      echo "# Add your PowerShell scripts here" > "$D3_DIR/scripts/powershell/example.ps1"
      ;;
  esac

  ( cd "$base_dir" && zip -r "../d3-kit-template-${agent}-${script}-${NEW_VERSION}.zip" . )
  echo "Created $GENRELEASES_DIR/d3-kit-template-${agent}-${script}-${NEW_VERSION}.zip"
}

# Agent list
ALL_AGENTS=(amp auggie bob claude codex copilot cursor-agent gemini kilocode opencode q qoder qwen roo shai windsurf)
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
