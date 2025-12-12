#!/usr/bin/env python3
"""D3-Kit: Developer-Driven Development Framework CLI"""

import os
import sys
import shutil
import zipfile
import tempfile
import subprocess
from pathlib import Path
from typing import Optional

import typer
import httpx
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.text import Text
from rich.live import Live
from rich.align import Align
from rich.tree import Tree
from typer.core import TyperGroup

console = Console()

BANNER = """
  ___  ___  _  _  _ ___
 |   \\| _ \\| || ||_| _ \\
 | |) |  _/| __ ||_|  _/
 |___/|_|  |_||_||_|_|
"""

TAGLINE = "Developer-Driven Development Framework"

# Agent configuration
AGENT_CONFIG = {
    "amp": {"name": "Amp", "folder": ".agents/"},
    "claude": {"name": "Claude Code", "folder": ".claude/"},
    "cursor-agent": {"name": "Cursor", "folder": ".cursor/"},
    "copilot": {"name": "GitHub Copilot", "folder": ".github/"},
    "gemini": {"name": "Gemini CLI", "folder": ".gemini/"},
    "qwen": {"name": "Qwen Code", "folder": ".qwen/"},
    "opencode": {"name": "opencode", "folder": ".opencode/"},
    "windsurf": {"name": "Windsurf", "folder": ".windsurf/"},
    "kilocode": {"name": "Kilo Code", "folder": ".kilocode/"},
    "auggie": {"name": "Auggie CLI", "folder": ".augment/"},
    "roo": {"name": "Roo Code", "folder": ".roo/"},
    "q": {"name": "Amazon Q Developer", "folder": ".amazonq/"},
    "shai": {"name": "SHAI", "folder": ".shai/"},
    "bob": {"name": "IBM Bob", "folder": ".bob/"},
    "codebuddy": {"name": "CodeBuddy", "folder": ".codebuddy/"},
    "qoder": {"name": "Qoder CLI", "folder": ".qoder/"},
    "codex": {"name": "Codex CLI", "folder": ".codex/"},
}

SCRIPT_TYPE_CHOICES = {"sh": "POSIX Shell (bash/zsh)", "ps": "PowerShell"}


class StepTracker:
    """Track and render hierarchical steps."""

    def __init__(self, title: str):
        self.title = title
        self.steps: list[dict[str, str]] = []

    def add(self, key: str, label: str):
        if key not in [s["key"] for s in self.steps]:
            self.steps.append(
                {"key": key, "label": label, "status": "pending", "detail": ""}
            )

    def start(self, key: str, detail: str = ""):
        self._update(key, status="running", detail=detail)

    def complete(self, key: str, detail: str = ""):
        self._update(key, status="done", detail=detail)

    def error(self, key: str, detail: str = ""):
        self._update(key, status="error", detail=detail)

    def skip(self, key: str, detail: str = ""):
        self._update(key, status="skipped", detail=detail)

    def _update(self, key: str, status: str, detail: str):
        for s in self.steps:
            if s["key"] == key:
                s["status"] = status
                if detail:
                    s["detail"] = detail
                return

        self.steps.append(
            {"key": key, "label": key, "status": status, "detail": detail}
        )

    def render(self):
        tree = Tree(f"[cyan]{self.title}[/cyan]", guide_style="grey50")
        for step in self.steps:
            label = step["label"]
            detail_text = step["detail"].strip() if step["detail"] else ""

            status = step["status"]
            if status == "done":
                symbol = "[green][OK][/green]"
            elif status == "pending":
                symbol = "[green dim][ ][/green dim]"
            elif status == "running":
                symbol = "[cyan][*][/cyan]"
            elif status == "error":
                symbol = "[red][!][/red]"
            elif status == "skipped":
                symbol = "[yellow][-][/yellow]"
            else:
                symbol = " "

            if status == "pending":
                if detail_text:
                    line = (
                        f"{symbol} [bright_black]{label} ({detail_text})[/bright_black]"
                    )
                else:
                    line = f"{symbol} [bright_black]{label}[/bright_black]"
            else:
                if detail_text:
                    line = f"{symbol} [white]{label}[/white] [bright_black]({detail_text})[/bright_black]"
                else:
                    line = f"{symbol} [white]{label}[/white]"

            tree.add(line)
        return tree


class BannerGroup(TyperGroup):
    """Custom group that shows banner before help."""

    def format_help(self, ctx, formatter):
        show_banner()
        super().format_help(ctx, formatter)


app = typer.Typer(
    name="d3",
    help="D3-Kit: Developer-Driven Development Framework",
    add_completion=False,
    invoke_without_command=True,
    cls=BannerGroup,
)


def show_banner():
    """Display the ASCII art banner."""
    banner_lines = BANNER.strip().split("\n")
    colors = ["bright_blue", "blue", "cyan", "bright_cyan", "white", "bright_white"]

    styled_banner = Text()
    for i, line in enumerate(banner_lines):
        color = colors[i % len(colors)]
        styled_banner.append(line + "\n", style=color)

    console.print(Align.center(styled_banner))
    console.print(Align.center(Text(TAGLINE, style="italic bright_yellow")))
    console.print()


@app.callback()
def callback(ctx: typer.Context):
    """Show banner when no subcommand is provided."""
    if (
        ctx.invoked_subcommand is None
        and "--help" not in sys.argv
        and "-h" not in sys.argv
    ):
        show_banner()
        console.print(Align.center("[dim]Run 'd3 --help' for usage information[/dim]"))
        console.print()


def get_latest_release_version() -> str:
    """Get the latest D3-Kit release version from GitHub."""
    try:
        with httpx.Client(follow_redirects=True) as client:
            response = client.get(
                "https://api.github.com/repos/Nom-nom-hub/D3-Kit/releases/latest",
                timeout=10.0,
            )
            response.raise_for_status()
            return response.json()["tag_name"]
    except Exception as e:
        console.print(f"[yellow]Warning:[/yellow] Could not fetch latest release: {e}")
        return "v1.0.4"


def download_and_extract_template(
    project_path: Path,
    agent: str,
    script_type: str,
    tracker: Optional[StepTracker] = None,
    is_current_dir: bool = False,
) -> bool:
    """Download and extract the D3-Kit template from GitHub releases."""
    version = get_latest_release_version()
    zip_filename = f"d3-kit-template-{agent}-{script_type}-{version}.zip"
    url = f"https://github.com/Nom-nom-hub/D3-Kit/releases/download/{version}/{zip_filename}"

    try:
        if tracker:
            tracker.start("download")

        with httpx.Client(follow_redirects=True) as client:
            response = client.get(url, timeout=30.0)
            response.raise_for_status()

            if tracker:
                tracker.complete("download")
                tracker.start("extract")

            zip_path = project_path.parent / zip_filename
            with open(zip_path, "wb") as f:
                f.write(response.content)

            # Extract ZIP
            with zipfile.ZipFile(zip_path, "r") as zip_ref:
                zip_ref.extractall(str(project_path))

            # Flatten if extracted into a single subdirectory
            items = list(project_path.iterdir())
            if len(items) == 1 and items[0].is_dir():
                single_dir = items[0]
                for item in single_dir.iterdir():
                    shutil.move(str(item), str(project_path / item.name))
                single_dir.rmdir()

            if tracker:
                tracker.complete("extract")
                tracker.start("cleanup")

            # Clean up ZIP
            if zip_path.exists():
                zip_path.unlink()

            if tracker:
                tracker.complete("cleanup")

            return True
    except Exception as e:
        if tracker:
            tracker.error("download", str(e))
        else:
            console.print(f"[red]Error downloading template:[/red] {e}")
        return False


@app.command()
def init(
    project_name: Optional[str] = typer.Argument(
        None, help="Name for your new project directory"
    ),
    ai_assistant: Optional[str] = typer.Option(
        None,
        "--ai",
        help="AI assistant to use (e.g. claude, amp, copilot, cursor-agent)",
    ),
    script_variant: Optional[str] = typer.Option(
        None, "--script", help="Script variant to use: sh (bash/zsh) or ps (PowerShell)"
    ),
    force: bool = typer.Option(False, "--force", help="Force merge when using --here"),
    here: bool = typer.Option(False, "--here", help="Initialize in current directory"),
):
    """
    Initialize a new D3-Kit project from the latest template.

    This command will:
    1. Create a new project directory (or use current directory with --here)
    2. Download the template from GitHub releases
    3. Extract the template files
    4. Show next steps
    """

    show_banner()

    # Handle project name and path
    if project_name == ".":
        here = True
        project_name = None

    if here and project_name:
        console.print(
            "[red]Error:[/red] Cannot specify both project name and --here flag"
        )
        raise typer.Exit(1)

    if not here and not project_name:
        console.print("[red]Error:[/red] Must specify a project name or use --here")
        raise typer.Exit(1)

    if here:
        project_name = Path.cwd().name
        project_path = Path.cwd()

        existing_items = list(project_path.iterdir())
        if existing_items:
            console.print(
                f"[yellow]Warning:[/yellow] Current directory is not empty ({len(existing_items)} items)"
            )
            console.print(
                "[yellow]Template files will be merged with existing content[/yellow]"
            )
            if not force:
                response = typer.confirm("Do you want to continue?")
                if not response:
                    console.print("[yellow]Operation cancelled[/yellow]")
                    raise typer.Exit(0)
    else:
        assert project_name is not None
        project_path = Path(project_name).resolve()
        if project_path.exists():
            error_panel = Panel(
                f"Directory '[cyan]{project_name}[/cyan]' already exists\n"
                "Please choose a different project name or remove the existing directory.",
                title="[red]Directory Conflict[/red]",
                border_style="red",
                padding=(1, 2),
            )
            console.print()
            console.print(error_panel)
            raise typer.Exit(1)

        project_path.mkdir(parents=True)

    # Determine script type
    if script_variant is None:
        console.print()
        console.print("[cyan]Select script type:[/cyan]")
        script_choices = list(SCRIPT_TYPE_CHOICES.items())
        for i, (key, desc) in enumerate(script_choices, 1):
            console.print(f"  [bold]{i}[/bold]. {desc} ({key})")
        choice = typer.prompt(
            "Enter your choice", type=int, default=2 if sys.platform == "win32" else 1
        )
        if choice < 1 or choice > len(script_choices):
            console.print("[red]Invalid choice[/red]")
            raise typer.Exit(1)
        script_type = script_choices[choice - 1][0]
    else:
        if script_variant not in SCRIPT_TYPE_CHOICES:
            console.print(
                f"[red]Error:[/red] Invalid script type '{script_variant}'. Choose from: {', '.join(SCRIPT_TYPE_CHOICES.keys())}"
            )
            raise typer.Exit(1)
        script_type = script_variant

    # Determine AI assistant
    if ai_assistant is None:
        console.print()
        console.print("[cyan]Select AI assistant:[/cyan]")
        agent_list = list(AGENT_CONFIG.items())
        for i, (key, config) in enumerate(agent_list, 1):
            console.print(f"  [bold]{i}[/bold]. {config['name']} ({key})")
        choice = typer.prompt("Enter your choice", type=int, default=1)
        if choice < 1 or choice > len(agent_list):
            console.print("[red]Invalid choice[/red]")
            raise typer.Exit(1)
        ai_assistant = agent_list[choice - 1][0]
    else:
        if ai_assistant not in AGENT_CONFIG:
            console.print(
                f"[red]Error:[/red] Invalid AI assistant '{ai_assistant}'. Choose from: {', '.join(AGENT_CONFIG.keys())}"
            )
            raise typer.Exit(1)

    # Show setup info
    setup_lines = [
        "[cyan]D3-Kit Project Setup[/cyan]",
        "",
        f"{'Project':<15} [green]{project_name}[/green]",
        f"{'AI Assistant':<15} [green]{ai_assistant}[/green]",
        f"{'Script Type':<15} [green]{script_type}[/green]",
    ]

    console.print(Panel("\n".join(setup_lines), border_style="cyan", padding=(1, 2)))
    console.print()

    # Initialize tracking
    tracker = StepTracker("Initialize D3-Kit Project")
    tracker.add("download", "Download template")
    tracker.add("extract", "Extract template")
    tracker.add("cleanup", "Cleanup")
    tracker.add("final", "Finalize")

    try:
        with Live(
            tracker.render(), console=console, refresh_per_second=4, transient=True
        ) as live:

            def refresh():
                live.update(tracker.render())

            # Download and extract
            success = download_and_extract_template(
                project_path,
                ai_assistant,
                script_type,
                tracker=tracker,
                is_current_dir=here,
            )

            if not success:
                if not here and project_path.exists():
                    shutil.rmtree(project_path)
                tracker.error("final", "download failed")
                raise typer.Exit(1)

            tracker.complete("final")

    except Exception as e:
        console.print(
            Panel(f"Initialization failed: {e}", title="Failure", border_style="red")
        )
        if not here and project_path.exists():
            shutil.rmtree(project_path)
        raise typer.Exit(1)

    console.print(tracker.render())
    console.print("\n[bold green]Project ready![/bold green]")

    # Show next steps
    if not here:
        next_steps = [
            f"[cyan]1. Go to your project:[/cyan]",
            f"   [bold]cd {project_name}[/bold]",
            "",
            f"[cyan]2. Open in your {ai_assistant} agent[/cyan]",
            "",
            f"[cyan]3. Use D3 commands:[/cyan]",
            "   • [bold]/d3.intend[/bold] - Specify features with intent",
            "   • [bold]/d3.plan[/bold] - Create implementation plan",
            "   • [bold]/d3.tasks[/bold] - Generate executable tasks",
            "   • [bold]/d3.implement[/bold] - Execute implementation",
        ]
    else:
        next_steps = [
            f"[cyan]1. Project initialized in current directory[/cyan]",
            "",
            f"[cyan]2. Open this folder in your {ai_assistant} agent[/cyan]",
            "",
            f"[cyan]3. Use D3 commands:[/cyan]",
            "   • [bold]/d3.intend[/bold] - Specify features with intent",
            "   • [bold]/d3.plan[/bold] - Create implementation plan",
            "   • [bold]/d3.tasks[/bold] - Generate executable tasks",
            "   • [bold]/d3.implement[/bold] - Execute implementation",
        ]

    next_steps_panel = Panel(
        "\n".join(next_steps), title="Next Steps", border_style="cyan", padding=(1, 2)
    )
    console.print()
    console.print(next_steps_panel)


@app.command()
def intend(
    feature_description: str = typer.Argument(
        ..., help="Description of the feature to be specified"
    ),
    output_file: str = typer.Option(
        "spec.md", "--output", "-o", help="Output specification file"
    ),
):
    """Create a new feature specification from a user description, capturing developer intent and user stories"""
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
    """Gather technical or contextual research automatically for a feature"""
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
    """Generate/update key entities & data models for the feature"""
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
    """Generate API/event contracts from the plan"""
    typer.echo(f"Generating contracts for feature: {feature_dir}")
    typer.echo(f"Output directory: {output_dir}")
    typer.echo("This is a placeholder for the D3-Kit contracts command.")


@app.command()
def plan(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    plan_file: str = typer.Option("plan.md", "--output", "-o", help="Output plan file"),
):
    """Generate implementation plan for a feature based on its spec.md, mapping user stories to technical tasks"""
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
    """Generate an executable task list from the implementation plan, with parallelization"""
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
    """Produce a quickstart/validation guide to verify the feature independently"""
    typer.echo(f"Generating quickstart guide for: {feature_dir}")
    typer.echo(f"Output file: {quickstart_file}")
    typer.echo("This is a placeholder for the D3-Kit quickstart command.")


@app.command()
def implement(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    tasks_file: str = typer.Option("tasks.md", "--tasks", help="Tasks file to execute"),
):
    """Execute all tasks to build the feature according to the plan"""
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
    """Clarify underspecified areas (recommended before /d3.plan)"""
    typer.echo(f"Clarifying requirements for feature: {feature_dir}")
    typer.echo(f"Using specification file: {spec_file}")
    typer.echo("This is a placeholder for the D3-Kit clarify command.")


@app.command()
def analyze(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
):
    """Cross-artifact consistency & coverage analysis"""
    typer.echo(f"Analyzing feature: {feature_dir}")
    typer.echo("This is a placeholder for the D3-Kit analyze command.")


@app.command()
def checklist(
    feature_dir: str = typer.Argument(..., help="Feature directory to process"),
    output_file: str = typer.Option(
        "checklist.md", "--output", "-o", help="Output checklist file"
    ),
):
    """Generate custom quality checklists"""
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
    """Create or update project governing principles and development guidelines"""
    typer.echo(f"Updating constitution for project: {project_dir}")
    typer.echo(f"Constitution file: {constitution_file}")
    typer.echo("This is a placeholder for the D3-Kit constitution command.")


@app.command()
def check():
    """Check for installed tools and D3-Kit setup"""
    show_banner()
    console.print("[bold]Checking D3-Kit installation...[/bold]\n")
    typer.echo("This is a placeholder for the D3-Kit check command.")


if __name__ == "__main__":
    app()
