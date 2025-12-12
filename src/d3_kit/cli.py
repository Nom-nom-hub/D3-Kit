"""D3-Kit: Developer-Driven Development Framework CLI"""

import typer
from pathlib import Path
import shutil
import subprocess
import sys
import httpx
from rich.console import Console
from rich.panel import Panel

console = Console()

app = typer.Typer()


def get_latest_release_version() -> str:
    """Get the latest D3-Kit release version from GitHub."""
    try:
        with httpx.Client() as client:
            response = client.get(
                "https://api.github.com/repos/Nom-nom-hub/D3-Kit/releases/latest",
                timeout=10.0,
            )
            response.raise_for_status()
            return response.json()["tag_name"]
    except Exception as e:
        console.print(f"[yellow]Warning:[/yellow] Could not fetch latest release: {e}")
        return "v1.0.3"


def download_and_extract_template(
    project_path: Path, agent: str, script_type: str
) -> bool:
    """Download and extract the D3-Kit template from GitHub releases."""
    version = get_latest_release_version()
    zip_filename = f"d3-kit-template-{agent}-{script_type}-{version}.zip"
    url = f"https://github.com/Nom-nom-hub/D3-Kit/releases/download/{version}/{zip_filename}"

    try:
        console.print(f"[cyan]Downloading template from GitHub...[/cyan]")
        with httpx.stream("GET", url, timeout=30.0) as response:
            response.raise_for_status()
            zip_path = project_path.parent / zip_filename
            with open(zip_path, "wb") as f:
                for chunk in response.iter_bytes():
                    f.write(chunk)

        console.print(f"[cyan]Extracting template...[/cyan]")
        shutil.unpack_archive(str(zip_path), str(project_path))
        zip_path.unlink()  # Delete the ZIP after extraction
        return True
    except Exception as e:
        console.print(f"[red]Error downloading template:[/red] {e}")
        return False


@app.command()
def init(
    project_name: str = typer.Argument(
        ..., help="Name for your new project directory"
    ),
    ai_assistant: str = typer.Option(
        None, "--ai", help="AI assistant to use (amp, claude, cursor-agent, etc.)"
    ),
    script_variant: str = typer.Option(
        None, "--script", help="Script variant to use: sh (bash/zsh) or ps (PowerShell)"
    ),
):
    """
    Initialize a new D3-Kit project from the latest template
    """
    console.print(f"\n[dark_cyan]Initializing D3-Kit project: {project_name}[/dark_cyan]")

    # Create project directory
    project_path = Path(project_name)
    if project_path.exists():
        console.print(f"[red]Error:[/red] Directory '{project_name}' already exists")
        raise typer.Exit(1)

    project_path.mkdir(parents=True)

    # Determine script type
    if script_variant is None:
        script_type = "ps" if sys.platform == "win32" else "sh"
    else:
        script_type = script_variant

    # Determine AI assistant (use provided or prompt)
    if ai_assistant is None:
        ai_assistant = "claude"  # Default to Claude

    # Download and extract template
    if not download_and_extract_template(project_path, ai_assistant, script_type):
        shutil.rmtree(project_path)
        raise typer.Exit(1)

    console.print(f"[green][OK][/green] Project structure created at {project_path}")
    console.print(f"[green][OK][/green] D3-Kit configuration initialized")
    console.print(
        f"[green][OK][/green] Templates and scripts installed for {ai_assistant}"
    )

    # Show next steps
    console.print("\n[cyan]Getting Started:[/cyan]")
    console.print(f"1. cd {project_name}")
    console.print(f"2. Launch your {ai_assistant} agent in this directory")
    console.print(f"3. Use D3 commands: /d3.intend, /d3.plan, /d3.tasks, etc.")


@app.command()
def intend(
    feature_description: str = typer.Argument(
        ..., help="Description of the feature to be specified"
    ),
    output_file: str = typer.Option(
        "spec.md", "--output", "-o", help="Output specification file"
    ),
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
    research_file: str = typer.Option(
        "research.md", "--output", "-o", help="Output research file"
    ),
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
    data_file: str = typer.Option(
        "data-model.md", "--output", "-o", help="Output data model file"
    ),
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
    output_dir: str = typer.Option(
        "contracts/", "--output", "-o", help="Output contracts directory"
    ),
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
    tasks_file: str = typer.Option(
        "tasks.md", "--output", "-o", help="Output tasks file"
    ),
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
    quickstart_file: str = typer.Option(
        "quickstart.md", "--output", "-o", help="Output quickstart file"
    ),
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
    spec_file: str = typer.Option(
        "spec.md", "--spec", help="Specification file to clarify"
    ),
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
    output_file: str = typer.Option(
        "checklist.md", "--output", "-o", help="Output checklist file"
    ),
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
    constitution_file: str = typer.Option(
        "d3-constitution.md", "--output", "-o", help="Constitution file to update"
    ),
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
