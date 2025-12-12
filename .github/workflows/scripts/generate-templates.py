#!/usr/bin/env python3
"""Generate D3-Kit template variants for different AI assistants."""

import os
import shutil
import zipfile
from pathlib import Path

# List of AI assistants to generate templates for
ASSISTANTS = [
    "amp",
    "auggie",
    "bob",
    "claude",
    "copilot",
    "cursor-agent",
    "gemini",
    "kilocode",
    "opencode",
    "q",
    "qoder",
    "qwen",
    "roo",
    "shai",
    "windsurf",
]

SCRIPT_TYPES = ["sh", "ps"]

def create_template_zip(assistant: str, script_type: str, output_dir: Path) -> None:
    """Create a template ZIP for a specific assistant and script type."""
    templates_dir = Path("D3-templates")
    
    # Create temp directory for this variant
    temp_dir = Path(f"temp-d3kit-{assistant}-{script_type}")
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    temp_dir.mkdir()
    
    # Copy D3-templates
    shutil.copytree(templates_dir, temp_dir / "D3-templates")
    
    # Create d3-features directory
    (temp_dir / "d3-features").mkdir()
    
    # Create .d3 config directory
    d3_dir = temp_dir / ".d3"
    d3_dir.mkdir()
    
    # Create config file with assistant specified
    config_content = f"""# D3-Kit Configuration
# This file configures the D3-Kit development environment for {assistant}

[project]
name = "my-d3-project"
assistant = "{assistant}"
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
"""
    (d3_dir / "config.toml").write_text(config_content)
    
    # Create scripts directory with appropriate script type
    scripts_dir = temp_dir / "scripts" / script_type
    scripts_dir.mkdir(parents=True)
    
    # Create a placeholder script
    ext = ".sh" if script_type == "sh" else ".ps1"
    (scripts_dir / f"example{ext}").write_text(
        "#!/bin/bash\n# Add your scripts here\n" if script_type == "sh" 
        else "# Add your scripts here\n"
    )
    
    # Create README
    readme_content = f"""# D3-Kit Template for {assistant.title()}

This is a pre-configured D3-Kit template for {assistant}.

## Getting Started

1. Extract this template to your project directory
2. Open the project in your {assistant} editor
3. Use D3 commands: `/d3.intend`, `/d3.plan`, `/d3.tasks`, etc.

## D3 Commands

- `/d3.intend` - Specify features with developer intent
- `/d3.plan` - Create implementation plans
- `/d3.tasks` - Generate executable task lists
- `/d3.implement` - Execute tasks to implement features

## Documentation

See the main D3-Kit repository for more information: https://github.com/Nom-nom-hub/D3-Kit
"""
    (temp_dir / "README.md").write_text(readme_content)
    
    # Create ZIP file
    zip_name = f"d3-kit-template-{assistant}-{script_type}-v1.0.0.zip"
    zip_path = output_dir / zip_name
    
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                file_path = Path(root) / file
                arcname = file_path.relative_to(temp_dir)
                zf.write(file_path, arcname)
    
    # Clean up temp directory
    shutil.rmtree(temp_dir)
    
    print(f"Created {zip_name}")


def main():
    """Generate all template variants."""
    output_dir = Path("templates-dist")
    output_dir.mkdir(exist_ok=True)
    
    for assistant in ASSISTANTS:
        for script_type in SCRIPT_TYPES:
            create_template_zip(assistant, script_type, output_dir)
    
    print(f"All templates generated in {output_dir}/")


if __name__ == "__main__":
    main()
