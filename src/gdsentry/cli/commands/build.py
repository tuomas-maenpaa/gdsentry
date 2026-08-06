"""Build commands - container image building."""

import re

import typer

from gdsentry.cli.ui.console import console, error, success
from gdsentry.container.builder import ContainerBuilder
from gdsentry.core.exceptions import ContainerError
from gdsentry.platform.detection import detect_architecture

app = typer.Typer(help="Build container images")


@app.command("base")
def build_base(
    arch: str = typer.Option("auto", "--arch", "-a", help="Target architecture (auto, x86_64, arm64)"),
) -> None:
    """Build base container image."""
    # Validate inputs to prevent command injection
    if arch != "auto" and not re.match(r'^[a-zA-Z0-9_-]+$', arch):
        error(f"Invalid architecture format: {arch}")
        raise typer.Exit(1)

    try:
        if arch == "auto":
            detected = detect_architecture()
            arch_value = detected.value
            console.print(f"[dim]Detected architecture: {arch_value}[/dim]")
        else:
            arch_value = arch

        from gdsentry.cli import create_build_progress

        builder = ContainerBuilder()

        with create_build_progress() as progress:
            task = progress.add_task(f"Building base image for {arch_value}...", total=None)
            builder.build_base(arch_value)
        
        success(f"Base image built successfully for {arch_value}")

    except ContainerError as e:
        error(f"Build failed: {e}")
        raise typer.Exit(1)


@app.command("godot")
def build_godot(
    version: str = typer.Argument(..., help="Godot version (3.5, 4.2)"),
    arch: str = typer.Option("auto", "--arch", "-a", help="Target architecture"),
) -> None:
    """Build Godot container image."""
    # Validate inputs to prevent command injection
    if not re.match(r'^[a-zA-Z0-9._-]+$', version):
        error(f"Invalid version format: {version}")
        raise typer.Exit(1)

    if arch != "auto" and not re.match(r'^[a-zA-Z0-9_-]+$', arch):
        error(f"Invalid architecture format: {arch}")
        raise typer.Exit(1)

    try:
        if arch == "auto":
            detected = detect_architecture()
            arch_value = detected.value
            console.print(f"[dim]Detected architecture: {arch_value}[/dim]")
        else:
            arch_value = arch

        from gdsentry.cli import create_build_progress

        builder = ContainerBuilder()

        with create_build_progress() as progress:
            task = progress.add_task(f"Building Godot {version} image for {arch_value}...", total=None)
            builder.build_godot(version, arch_value)
        
        success(f"Godot {version} image built successfully for {arch_value}")

    except ContainerError as e:
        error(f"Build failed: {e}")
        console.print("\n[yellow]Tip:[/yellow] Check that the build script exists and Podman is running")
        raise typer.Exit(1)


@app.command("docs")
def build_docs() -> None:
    """Build documentation container image."""
    try:
        from gdsentry.cli import create_docs_progress

        builder = ContainerBuilder()

        with create_docs_progress() as progress:
            task = progress.add_task("Building documentation image...", total=None)
            builder.build_docs()
        
        success("Documentation image built successfully")

    except ContainerError as e:
        error(f"Build failed: {e}")
        raise typer.Exit(1)


@app.command("all")
def build_all(
    arch: str = typer.Option("auto", "--arch", "-a", help="Target architecture"),
) -> None:
    """Build all container images."""
    # Validate inputs to prevent command injection
    if arch != "auto" and not re.match(r'^[a-zA-Z0-9_-]+$', arch):
        error(f"Invalid architecture format: {arch}")
        raise typer.Exit(1)

    try:
        if arch == "auto":
            detected = detect_architecture()
            arch_value = detected.value
            console.print(f"[dim]Detected architecture: {arch_value}[/dim]")
        else:
            arch_value = arch

        from gdsentry.cli import create_build_progress

        builder = ContainerBuilder()

        console.print(f"[bold cyan]Building all images for {arch_value}...[/bold cyan]\n")

        with create_build_progress() as progress:
            task = progress.add_task("Building all images...", total=None)
            builder.build_all(arch_value)
        
        success(f"All images built successfully for {arch_value}")

    except ContainerError as e:
        error(f"Build failed: {e}")
        raise typer.Exit(1)

