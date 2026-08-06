"""Init commands - project initialization and setup."""

import re
from pathlib import Path
from typing import Optional

import typer

from gdsentry.cli.ui.console import console, error, success
from gdsentry.container.podman import PodmanClient
from gdsentry.templates.generator import TemplateError, TemplateGenerator
from gdsentry.templates.init import InitializationError, ProjectInitializer

app = typer.Typer(help="Project initialization and setup")


@app.command("project")
def init_project(
    directory: str = typer.Argument(".", help="Project directory"),
    name: Optional[str] = typer.Option(None, "--name", "-n", help="Project name"),
    godot: str = typer.Option("4.2.2-stable", "--godot", "-g", help="Godot version"),
    interactive: bool = typer.Option(False, "--interactive", "-i", help="Interactive mode"),
) -> None:
    """Initialize a new GDSentry project."""
    # Validate inputs to prevent command injection and path traversal
    from gdsentry.cli import validate_path_safety
    if directory != ".":
        validate_path_safety(directory, allow_relative=True)

    if name and not re.match(r'^[a-zA-Z0-9._-]+$', name):
        error(f"Invalid project name format: {name}")
        raise typer.Exit(1)

    if godot != "4.2.2-stable" and not re.match(r'^[a-zA-Z0-9._-]+$', godot):
        error(f"Invalid Godot version format: {godot}")
        raise typer.Exit(1)

    try:
        project_dir = Path(directory).resolve()

        # Get project name from directory if not provided
        if name is None:
            name = project_dir.name

        console.print(f"\n[bold cyan]Initializing GDSentry project...[/bold cyan]\n")

        initializer = ProjectInitializer(project_dir)
        initializer.initialize(name, godot, interactive)

        # Show created files
        created_files = initializer.get_created_files()

        console.print("[bold green]✓[/bold green] Project initialized successfully!\n")
        console.print("[bold]Created files:[/bold]")

        for file in created_files:
            relative_path = file.relative_to(project_dir)
            console.print(f"  [green]✓[/green] {relative_path}")

        console.print(f"\n[bold]Next steps:[/bold]")
        console.print("  1. Review gdsentry.toml configuration")
        console.print("  2. Run: gdsentry test discover")
        console.print("  3. Run: gdsentry test run")
        console.print(f"\n[dim]Project directory: {project_dir}[/dim]")

    except InitializationError as e:
        error(f"Initialization failed: {e}")
        raise typer.Exit(1)
    except Exception as e:
        error(f"Unexpected error: {e}")
        raise typer.Exit(1)


@app.command("test")
def generate_test(
    name: str = typer.Argument(..., help="Test name (e.g., player_movement)"),
    type: str = typer.Option("unit", "--type", "-t", help="Test type (unit, integration, performance, scene)"),
    output: Optional[str] = typer.Option(None, "--output", "-o", help="Output directory"),
) -> None:
    """Generate a new test file from template."""
    # Validate inputs to prevent command injection and path traversal
    if not re.match(r'^[a-zA-Z0-9_-]+$', name):
        error(f"Invalid test name format: {name}")
        raise typer.Exit(1)

    if not re.match(r'^[a-zA-Z0-9_-]+$', type):
        error(f"Invalid test type format: {type}")
        raise typer.Exit(1)

    if output:
        validate_path_safety(output, allow_relative=True)

    try:
        # For template generation, use current directory as base
        # (this is for generating test files in user's project)
        base_dir = Path.cwd()
        generator = TemplateGenerator(base_dir)

        output_dir = Path(output) if output else None

        console.print(f"\n[bold cyan]Generating {type} test...[/bold cyan]\n")

        test_file = generator.generate_test(
            name=name,
            test_type=type,  # type: ignore
            output_dir=output_dir,
        )

        relative_path = test_file.relative_to(base_dir)

        success(f"Test generated: {relative_path}")

        console.print(f"\n[bold]Next steps:[/bold]")
        console.print(f"  1. Edit {relative_path}")
        console.print("  2. Implement your test logic")
        console.print(f"  3. Run: gdsentry test run --category {type}")

    except TemplateError as e:
        error(f"Template generation failed: {e}")
        raise typer.Exit(1)
    except Exception as e:
        error(f"Unexpected error: {e}")
        raise typer.Exit(1)


@app.command("podman")
def init_podman(
    install: bool = typer.Option(False, "--install", help="Install podman if missing"),
    machine_name: str = typer.Option("podman-machine-default", "--machine-name", help="Podman machine name"),
    cpus: Optional[int] = typer.Option(None, "--cpus", help="CPU cores for machine (auto-detect if not specified)"),
    memory: Optional[str] = typer.Option(None, "--memory", help="Memory for machine (auto-detect if not specified)"),
    force: bool = typer.Option(False, "--force", help="Recreate machine if it exists"),
) -> None:
    """Initialize Podman environment for containerized testing.

    Sets up Podman machine with appropriate resources for GDSentry testing.
    Installs Podman if requested, creates machine if needed, and ensures it's running.
    """
    try:
        podman = PodmanClient()

        console.print(f"\n[bold cyan]Initializing Podman environment...[/bold cyan]\n")

        # Check if podman is installed
        if not podman.is_podman_installed():
            if install:
                console.print("[yellow]Podman not found. Installing...[/yellow]")
                # Note: Installation would require platform-specific logic
                # For now, we'll provide instructions
                console.print("[red]Automatic podman installation not yet implemented.[/red]")
                console.print("Please install podman manually:")
                console.print("  macOS (brew): brew install podman")
                console.print("  Linux: See https://podman.io/getting-started/installation")
                raise typer.Exit(1)
            else:
                error("Podman not found. Use --install to install it automatically.")
                raise typer.Exit(1)

        success("✓ Podman is installed")

        # Check if machine exists
        if podman.is_machine_running(machine_name):
            success(f"✓ Podman machine '{machine_name}' is already running")
        elif podman.is_machine_exists(machine_name) and not force:
            console.print(f"[yellow]Podman machine '{machine_name}' exists but is not running.[/yellow]")
            console.print("Starting machine...")
            podman.ensure_machine_running(machine_name)
            success(f"✓ Podman machine '{machine_name}' started")
        else:
            # Create new machine
            if podman.is_machine_exists(machine_name) and force:
                console.print(f"[yellow]Removing existing machine '{machine_name}'...[/yellow]")
                # Note: Machine removal would need to be implemented
                console.print("[red]Machine recreation not yet implemented. Please remove manually:[/red]")
                console.print(f"  podman machine rm {machine_name}")

            console.print(f"[yellow]Creating podman machine '{machine_name}'...[/yellow]")

            # Auto-detect resources if not specified
            if cpus is None:
                import os
                cpus = min(4, max(2, os.cpu_count() // 2))  # Use half of available CPUs, max 4
            if memory is None:
                import psutil
                total_memory = psutil.virtual_memory().total // (1024**3)  # GB
                memory = f"{min(8, max(4, total_memory // 2))}GB"  # Use half of available RAM, max 8GB

            console.print(f"[dim]Resources: {cpus} CPUs, {memory} RAM[/dim]")

            # Create machine (this would need to be implemented in PodmanClient)
            console.print("[red]Machine creation not yet implemented in PodmanClient.[/red]")
            console.print("Please create the machine manually:")
            console.print(f"  podman machine init {machine_name} --cpus {cpus} --memory {memory}")
            console.print(f"  podman machine start {machine_name}")

            # For now, we'll assume the machine gets created and started
            # podman.create_machine(machine_name, cpus=cpus, memory=memory)
            # podman.ensure_machine_running(machine_name)

        # Validate the setup
        console.print("\n[bold]Validating setup...[/bold]")
        if podman.is_machine_running(machine_name):
            success("✓ Podman machine is running")
        else:
            error("✗ Podman machine is not running")
            raise typer.Exit(1)

        # Test container execution
        try:
            result = podman._run_command(["podman", "run", "--rm", "docker.io/alpine:latest", "echo", "test"])
            if result.returncode == 0:
                success("✓ Container execution works")
            else:
                error("✗ Container execution failed")
                raise typer.Exit(1)
        except Exception:
            error("✗ Container execution test failed")
            raise typer.Exit(1)

        console.print(f"\n[bold green]✓[/bold green] Podman environment initialized successfully!")
        console.print(f"[bold]Machine:[/bold] {machine_name}")
        console.print(f"[bold]Resources:[/bold] {cpus} CPUs, {memory} RAM")
        console.print("\n[bold]Next steps:[/bold]")
        console.print("  1. Run: gdsentry validate podman")
        console.print("  2. Run: gdsentry build all")
        console.print("  3. Run: gdsentry test run-container")

    except Exception as e:
        error(f"Podman initialization failed: {e}")
        raise typer.Exit(1)

