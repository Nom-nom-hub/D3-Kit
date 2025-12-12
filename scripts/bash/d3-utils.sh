#!/bin/bash
# d3-utils.sh - Shared utility functions for D3-Kit scripts

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the repo root directory
# If $1 is provided as start directory, use that; otherwise calculate from script location
get_repo_root() {
  local current_dir="${1:-}"
  
  if [[ -z "$current_dir" ]]; then
    # Get script directory: scripts/bash/d3-utils.sh
    # Go up: scripts/bash -> scripts -> (should be in .d3 already if in calcultor/.d3)
    # Need to go up 2 levels to get to project root
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    current_dir="$(dirname "$(dirname "$script_dir")")"  # Up 2 levels from bash to project root
  fi
  
  # Walk up to find .git, .d3, or D3-Kit-Methodology.md
  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "$current_dir/.git" ]] || [[ -d "$current_dir/.d3" ]] || [[ -f "$current_dir/D3-Kit-Methodology.md" ]]; then
      echo "$current_dir"
      return 0
    fi
    current_dir="$(dirname "$current_dir")"
  done
  echo "." # fallback
}

# Output JSON response
output_json() {
  local status=$1
  local message=$2
  local data=${3:-"{}"}
  
  cat <<EOF
{
  "status": "$status",
  "message": "$message",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "data": $data
}
EOF
}

# Generate feature name from description (2-4 words, kebab-case)
generate_feature_name() {
  local description="$1"
  # Extract first few significant words, convert to lowercase, replace spaces with hyphens
  echo "$description" | \
    sed 's/[^a-zA-Z0-9 ]//g' | \
    awk '{for(i=1;i<=4&&i<=NF;i++) printf "%s-", tolower($i)}' | \
    sed 's/-$//'
}

# Get next feature number
get_next_feature_number() {
  local short_name=$1
  local repo_root=$(get_repo_root)
  
  local max_num=0
  
  # Check d3-features directories
  if [[ -d "$repo_root/d3-features" ]]; then
    while IFS= read -r dir; do
      if [[ "$dir" =~ ^[0-9]+- ]]; then
        local num=$(echo "$dir" | sed 's/^\([0-9]*\).*/\1/')
        [[ "$num" -gt "$max_num" ]] && max_num=$num
      fi
    done < <(find "$repo_root/d3-features" -maxdepth 1 -type d -name "*$short_name*" 2>/dev/null | xargs -n1 basename)
  fi
  
  # Check git branches
  if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    while IFS= read -r branch; do
      if [[ "$branch" =~ ^[0-9]+- ]]; then
        local num=$(echo "$branch" | sed 's/^\([0-9]*\).*/\1/')
        [[ "$num" -gt "$max_num" ]] && max_num=$num
      fi
    done < <(git branch -a 2>/dev/null | sed 's/^\*\?\s*//' | grep "$short_name" || true)
  fi
  
  echo $((max_num + 1))
}

# Create feature directory structure
create_feature_structure() {
  local repo_root=$1
  local feature_num=$2
  local feature_name=$3
  
  local feature_dir="$repo_root/d3-features/${feature_num}-${feature_name}"
  
  mkdir -p "$feature_dir"
  
  echo "$feature_dir"
}

# Load template file
load_template() {
   local repo_root=$1
   local template_name=$2
   
   # Try .d3/D3-templates first, then D3-templates
   local template_file="$repo_root/.d3/D3-templates/$template_name"
   
   if [[ ! -f "$template_file" ]]; then
     # Try alternative location
     template_file="$repo_root/D3-templates/$template_name"
   fi
   
   if [[ ! -f "$template_file" ]]; then
     echo "ERROR: Template not found: $template_name in $repo_root/.d3/D3-templates or $repo_root/D3-templates" >&2
     return 1
   fi
   
   cat "$template_file"
}

# Replace placeholder in content
replace_placeholder() {
  local content="$1"
  local placeholder=$2
  local value=$3
  
  # Escape special characters in value for sed
  value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
  
  echo "$content" | sed "s/{$placeholder}/$value/g"
}

# Extract YAML frontmatter
extract_frontmatter() {
  local content="$1"
  echo "$content" | awk '/^---$/{if(++count==1) next; if(count==2) exit} count==1'
}

# Extract body (content after frontmatter)
extract_body() {
  local content="$1"
  local in_frontmatter=0
  local seen_closing=0
  
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if [[ $in_frontmatter -eq 0 ]]; then
        in_frontmatter=1
      elif [[ $in_frontmatter -eq 1 ]]; then
        seen_closing=1
        continue
      fi
    elif [[ $seen_closing -eq 1 ]]; then
      echo "$line"
    fi
  done <<< "$content"
}

# Format date
get_date() {
  date +%Y-%m-%d
}

# Create git branch if git is available
create_git_branch() {
  local branch_name=$1
  
  if ! command -v git &> /dev/null; then
    return 0
  fi
  
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  fi
  
  # Check if branch exists
  if git rev-parse --verify "$branch_name" > /dev/null 2>&1; then
    git checkout "$branch_name" 2>/dev/null || true
  else
    git checkout -b "$branch_name" 2>/dev/null || true
  fi
}

# Validate required arguments
require_args() {
  local required_count=$1
  shift
  local provided_args=("$@")
  
  if [[ ${#provided_args[@]} -lt $required_count ]]; then
    output_json "error" "Missing required arguments. Expected at least $required_count arguments, got ${#provided_args[@]}"
    exit 1
  fi
}

# Export functions for use in other scripts
export -f output_json
export -f generate_feature_name
export -f get_next_feature_number
export -f create_feature_structure
export -f load_template
export -f replace_placeholder
export -f extract_frontmatter
export -f extract_body
export -f get_date
export -f create_git_branch
export -f require_args
export -f get_repo_root
