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
  
  # Create agent-specific command files that agents can use
  # These will be placed in agent-specific folders for the agent to discover
  
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
       AGENT_COMMANDS_DIR="$base_dir/.opencode/commands"
       ;;
     windsurf)
       AGENT_COMMANDS_DIR="$base_dir/.windsurf/workflows"
       ;;
     kilocode)
       AGENT_COMMANDS_DIR="$base_dir/.kilocode/workflows"
       ;;
     auggie)
       AGENT_COMMANDS_DIR="$base_dir/.augment/commands"
       ;;
     roo)
       AGENT_COMMANDS_DIR="$base_dir/.roo/commands"
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
   esac
   
   if [[ -n "$AGENT_COMMANDS_DIR" ]]; then
     generate_agent_commands "$agent" "$AGENT_COMMANDS_DIR"
     echo "Generated agent-specific commands for $agent"
   fi

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
