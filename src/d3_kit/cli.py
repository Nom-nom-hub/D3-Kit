"""D3-Kit: Developer-Driven Development Framework CLI"""
import typer
from pathlib import Path
import shutil
from rich.console import Console
from rich.panel import Panel

console = Console()

app = typer.Typer()

@app.command()
def init(
    project_name: str = typer.Argument(..., help="Name for your new project directory"),
    ai_assistant: str = typer.Option(None, "--ai", help="AI assistant to use"),
    script_variant: str = typer.Option("sh", "--script", help="Script variant to use: sh (bash/zsh) or ps (PowerShell)"),
):
    """
    Initialize a new D3-Kit project from the latest template
    """
    console.print(f"\n[dark_cyan]Initializing D3-Kit project: {project_name}[/dark_cyan]")

    # Create directory structure
    project_path = Path(project_name)
    project_path.mkdir(exist_ok=True)

    # Create .d3 directory for D3-Kit configuration
    d3_dir = project_path / ".d3"
    d3_dir.mkdir(exist_ok=True)

    # Create scripts directory structure
    scripts_dir = project_path / "scripts"
    bash_dir = scripts_dir / "bash"
    powershell_dir = scripts_dir / "powershell"

    bash_dir.mkdir(parents=True, exist_ok=True)
    powershell_dir.mkdir(parents=True, exist_ok=True)

    # Try to copy our local scripts to the project
    local_bash_dir = Path(__file__).parent.parent.parent / "scripts" / "bash"
    local_powershell_dir = Path(__file__).parent.parent.parent / "scripts" / "powershell"

    if local_bash_dir.exists():
        for script_file in local_bash_dir.glob("*.sh"):
            dest_file = bash_dir / script_file.name
            shutil.copy2(script_file, dest_file)

    if local_powershell_dir.exists():
        for script_file in local_powershell_dir.glob("*.ps1"):
            dest_file = powershell_dir / script_file.name
            shutil.copy2(script_file, dest_file)

    # Create basic configuration
    config_content = f"""# D3-Kit Configuration
# This file configures the D3-Kit development environment for {ai_assistant}

[project]
name = "{project_name}"
assistant = "{ai_assistant}"
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

    # Create directory structure
    (project_path / "d3-features").mkdir(exist_ok=True)
    (project_path / "contracts").mkdir(exist_ok=True)

    # Copy templates
    templates_dir = project_path / "D3-templates"
    templates_dir.mkdir(exist_ok=True)

    commands_dir = templates_dir / "d3-commands"
    commands_dir.mkdir(exist_ok=True)

    # Copy all command templates with actual content
    import importlib.resources
    import d3_kit

    template_files = [
        "d3.intend.md", "d3.plan.md", "d3.tasks.md",
        "d3.implement.md", "d3.clarify.md", "d3.analyze.md",
        "d3.checklist.md", "d3.constitution.md", "d3.research.md",
        "d3.data.md", "d3.contracts.md", "d3.quickstart.md",
        "d3.taskstoissues.md"
    ]

    for template_file in template_files:
        try:
            # Try to read from package resources first
            if importlib.resources.is_resource(d3_kit, f"D3-templates/d3-commands/{template_file}"):
                content = importlib.resources.read_text(d3_kit, f"D3-templates/d3-commands/{template_file}")
                (commands_dir / template_file).write_text(content)
            else:
                # Create empty file if template not found
                (commands_dir / template_file).write_text("")
        except:
            # Create empty file if template not found
            (commands_dir / template_file).write_text("")

    console.print(f"[green]✓[/green] Project structure created at {project_path}")
    console.print(f"[green]✓[/green] D3-Kit configuration created")
    console.print(f"[green]✓[/green] Command templates installed")
    console.print(f"[green]✓[/green] Scripts directory created with {len(list(bash_dir.glob('*.sh')))} bash and {len(list(powershell_dir.glob('*.ps1')))} PowerShell scripts")

    # Show next steps
    console.print("\n[cyan]Getting Started:[/cyan]")
    console.print(f"1. cd {project_name}")
    console.print(f"2. Launch your {ai_assistant} agent")
    console.print(f"3. Use D3 commands: /d3.intend, /d3.plan, /d3.tasks, etc.")
    console.print(f"4. Use helper scripts in ./scripts/ directory")


@app.command()
def intend(
    feature_description: str = typer.Argument(..., help="Description of the feature to be specified"),
    output_file: str = typer.Option("spec.md", "--output", "-o", help="Output specification file"),
):
    """
    Create a new feature specification from a user description, capturing developer intent and user stories
    """
    typer.echo(f"Creating specification for: {feature_description}")
    typer.echo(f"Output file: {output_file}")
    typer.echo("This is a placeholder for the D3-Kit intend command.")


@app.command()
def research(
    feature_dir: str = typer.Argument(..., help="Feature directory to research"),
    research_file: str = typer.Option("research.md", "--output", "-o", help="Output research file"),
):
    """
    Gather technical or contextual research automatically for a feature
    """
    typer.echo(f"Gathering research for feature: {feature_dir}")
    typer.echo(f"Output file: {research_file}")
    typer.echo("This is a placeholder for the D3-Kit research command.")


@app.command()
def data(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    data_file: str = typer.Option("data-model.md", "--output", "-o", help="Output data model file"),
):
    """
    Generate/update key entities & data models for the feature
    """
    typer.echo(f"Generating data models for feature: {feature_dir}")
    typer.echo(f"Output file: {data_file}")
    typer.echo("This is a placeholder for the D3-Kit data command.")


@app.command()
def contracts(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    output_dir: str = typer.Option("contracts/", "--output", "-o", help="Output contracts directory"),
):
    """
    Generate API/event contracts from the plan
    """
    typer.echo(f"Generating contracts for feature: {feature_dir}")
    typer.echo(f"Output directory: {output_dir}")
    typer.echo("This is a placeholder for the D3-Kit contracts command.")


@app.command()
def plan(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    plan_file: str = typer.Option("plan.md", "--output", "-o", help="Output plan file"),
):
    """
    Generate implementation plan for a feature based on its spec.md, mapping user stories to technical tasks
    """
    typer.echo(f"Generating implementation plan for: {feature_dir}")
    typer.echo(f"Output file: {plan_file}")
    typer.echo("This is a placeholder for the D3-Kit plan command.")


@app.command()
def tasks(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    tasks_file: str = typer.Option("tasks.md", "--output", "-o", help="Output tasks file"),
):
    """
    Generate an executable task list from the implementation plan, with parallelization
    """
    typer.echo(f"Generating tasks for feature: {feature_dir}")
    typer.echo(f"Output file: {tasks_file}")
    typer.echo("This is a placeholder for the D3-Kit tasks command.")


@app.command()
def quickstart(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    quickstart_file: str = typer.Option("quickstart.md", "--output", "-o", help="Output quickstart file"),
):
    """
    Produce a quickstart/validation guide to verify the feature independently
    """
    typer.echo(f"Generating quickstart guide for: {feature_dir}")
    typer.echo(f"Output file: {quickstart_file}")
    typer.echo("This is a placeholder for the D3-Kit quickstart command.")


@app.command()
def implement(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    tasks_file: str = typer.Option("tasks.md", "--tasks", help="Tasks file to execute"),
):
    """
    Execute all tasks to build the feature according to the plan
    """
    typer.echo(f"Implementing feature: {feature_dir}")
    typer.echo(f"Using tasks file: {tasks_file}")
    typer.echo("This is a placeholder for the D3-Kit implement command.")


@app.command()
def clarify(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    spec_file: str = typer.Option("spec.md", "--spec", help="Specification file to clarify"),
):
    """
    Clarify underspecified areas (recommended before `/d3.plan`)
    """
    typer.echo(f"Clarifying requirements for feature: {feature_dir}")
    typer.echo(f"Using specification file: {spec_file}")
    typer.echo("This is a placeholder for the D3-Kit clarify command.")


@app.command()
def analyze(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
):
    """
    Cross-artifact consistency & coverage analysis
    """
    typer.echo(f"Analyzing feature: {feature_dir}")
    typer.echo("This is a placeholder for the D3-Kit analyze command.")


@app.command()
def checklist(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    output_file: str = typer.Option("checklist.md", "--output", "-o", help="Output checklist file"),
):
    """
    Generate custom quality checklists
    """
    typer.echo(f"Generating checklist for feature: {feature_dir}")
    typer.echo(f"Output file: {output_file}")
    typer.echo("This is a placeholder for the D3-Kit checklist command.")


@app.command()
def constitution(
    project_dir: str = typer.Argument(..., help="Project directory"),
    constitution_file: str = typer.Option("d3-constitution.md", "--output", "-o", help="Constitution file to update"),
):
    """
    Create or update project governing principles and development guidelines
    """
    typer.echo(f"Updating constitution for project: {project_dir}")
    typer.echo(f"Constitution file: {constitution_file}")
    typer.echo("This is a placeholder for the D3-Kit constitution command.")


@app.command()
def check():
    """
    Check for installed tools and D3-Kit setup
    """
    typer.echo("Checking D3-Kit installation and configuration...")
    typer.echo("This is a placeholder for the D3-Kit check command.")


if __name__ == "__main__":
    app()