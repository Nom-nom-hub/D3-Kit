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

rewrite_paths() {
  sed -E \
    -e 's@(/?)D3-templates/@.d3/D3-templates/@g' \
    -e 's@(/?)scripts/@.d3/scripts/@g'
}

generate_commands() {
  local agent_prefix=$1 ext=$2 arg_format=$3 output_dir=$4 script_variant=$5
  mkdir -p "$output_dir"
  for template in D3-templates/d3-commands/d3.*.md; do
    [[ -f "$template" ]] || continue
    local name description script_command agent_script_command body
    name=$(basename "$template" .md)
    # Strip the "d3." prefix since we'll add it back in the output filename
    name="${name#d3.}"
    
    # Normalize line endings
    file_content=$(tr -d '\r' < "$template")
    
    # Extract description and script command from YAML frontmatter
    description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
    script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '/^[[:space:]]*'"$script_variant"':[[:space:]]*/ {sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, ""); print; exit}')
    
    if [[ -z $script_command ]]; then
      echo "Warning: no script command found for $script_variant in $template" >&2
      script_command="(Missing script command for $script_variant)"
    fi
    
    # Extract agent_script command from YAML frontmatter if present
    agent_script_command=$(printf '%s\n' "$file_content" | awk '
      /^agent_scripts:$/ { in_agent_scripts=1; next }
      in_agent_scripts && /^[[:space:]]*'"$script_variant"':[[:space:]]*/ {
        sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, "")
        print
        exit
      }
      in_agent_scripts && /^[a-zA-Z]/ { in_agent_scripts=0 }
    ')
    
    # Replace {SCRIPT} placeholder with the script command
    body=$(printf '%s\n' "$file_content" | sed "s|{SCRIPT}|${script_command}|g")
    
    # Replace {AGENT_SCRIPT} placeholder with the agent script command if found
    if [[ -n $agent_script_command ]]; then
      body=$(printf '%s\n' "$body" | sed "s|{AGENT_SCRIPT}|${agent_script_command}|g")
    fi
    
    # Remove the scripts: and agent_scripts: sections from frontmatter while preserving YAML structure
    body=$(printf '%s\n' "$body" | awk '
      /^---$/ { print; if (++dash_count == 1) in_frontmatter=1; else in_frontmatter=0; next }
      in_frontmatter && /^scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^agent_scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^[a-zA-Z].*:/ && skip_scripts { skip_scripts=0 }
      in_frontmatter && skip_scripts && /^[[:space:]]/ { next }
      { print }
    ')
    
    # Apply other substitutions
    body=$(printf '%s\n' "$body" | sed "s/{ARGS}/$arg_format/g" | sed "s/__AGENT__/$agent_prefix/g" | rewrite_paths)
    
    case $ext in
      toml)
        body=$(printf '%s\n' "$body" | sed 's/\\/\\\\/g')
        { echo "description = \"$description\""; echo; echo "prompt = \"\"\""; echo "$body"; echo "\"\"\""; } > "$output_dir/d3.$name.$ext" ;;
      md)
        echo "$body" > "$output_dir/d3.$name.$ext" ;;
    esac
  done
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
    case $agent in
      gemini)
        generate_commands d3 toml "{{args}}" "$AGENT_COMMANDS_DIR" "$script"
        [[ -f agent_templates/gemini/GEMINI.md ]] && cp agent_templates/gemini/GEMINI.md "$base_dir/GEMINI.md" ;;
      qwen)
        generate_commands d3 toml "{{args}}" "$AGENT_COMMANDS_DIR" "$script"
        [[ -f agent_templates/qwen/QWEN.md ]] && cp agent_templates/qwen/QWEN.md "$base_dir/QWEN.md" ;;
      *)
        generate_commands d3 md "\$ARGUMENTS" "$AGENT_COMMANDS_DIR" "$script" ;;
    esac
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
