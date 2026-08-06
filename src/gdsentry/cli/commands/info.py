"""Info commands - display platform and configuration information."""

from typing import Optional

import typer
from rich.table import Table

from gdsentry import __version__
from gdsentry.cli.ui.console import console, error, success, warning
from gdsentry.cli.ui.tables import create_info_table
from gdsentry.core.config import load_config
from gdsentry.core.exceptions import ConfigurationError
from gdsentry.monitoring.resources import ResourceMonitor
from gdsentry.platform.compatibility import get_compatible_godot_versions
from gdsentry.platform.detection import detect_platform, get_platform_display_name
from gdsentry.validation.podman import PodmanValidator

app = typer.Typer(help="Display information about platform and configuration")


@app.command("platform")
def platform_info() -> None:
    """Show platform and system information."""
    try:
        info = detect_platform()

        # Create platform info table
        platform_data = {
            "Operating System": str(info.os.value),
            "Architecture": str(info.architecture.value),
            "Python Version": info.python_version,
            "QEMU Available": "Yes" if info.qemu_available else "No",
            "Podman Available": "Yes" if info.podman_available else "No",
        }

        table = create_info_table("Platform Information", platform_data)
        console.print(table)

        # Show compatible Godot versions
        console.print()
        godot_versions = get_compatible_godot_versions(info.architecture)
        
        versions_table = Table(title="Compatible Godot Versions", border_style="blue")
        versions_table.add_column("Version", style="green")
        
        for version in godot_versions:
            versions_table.add_row(version)
        
        console.print(versions_table)

    except Exception as e:
        console.print(f"[red]Error detecting platform: {e}[/red]")
        raise typer.Exit(1)


@app.command("version")
def version_info() -> None:
    """Show GDSentry version."""
    console.print(f"[bold green]GDSentry[/bold green] version [cyan]{__version__}[/cyan]")


@app.command("config")
def config_info(
    path: Optional[str] = typer.Option(
        None,
        "--path",
        "-p",
        help="Path to config file (default: search for gdsentry.toml)",
    ),
) -> None:
    """Show current configuration."""
    try:
        from pathlib import Path as PathlibPath

        config_path = PathlibPath(path) if path else None
        config = load_config(config_path=config_path)

        # Project configuration
        project_data = {
            "Name": config.project.name,
            "Godot Version": config.project.godot_version,
            "GDSentry Root": str(config.project.gdsentry_root),
            "Game Project Root": str(config.project.game_project_root) if config.project.game_project_root else "Not attached",
        }
        console.print(create_info_table("Project Configuration", project_data))

        # Test configuration
        test_data = {
            "Scope": str(config.test.scope.value),
            "Filter": config.test.filter,
            "Timeout": f"{config.test.timeout}s",
            "Parallel": "Yes" if config.test.parallel else "No",
            "Verbose": "Yes" if config.test.verbose else "No",
        }
        console.print()
        console.print(create_info_table("Test Configuration", test_data))

        # Platform configuration
        platform_data = {
            "Default Architecture": str(config.platform.default_arch.value),
            "QEMU Enabled": "Yes" if config.platform.enable_qemu else "No",
        }
        console.print()
        console.print(create_info_table("Platform Configuration", platform_data))

        # Container configuration
        container_data = {
            "Registry": config.container.registry,
            "Base Image": config.container.base_image,
            "Auto Build": "Yes" if config.container.auto_build else "No",
            "Auto Cleanup": "Yes" if config.container.cleanup_on_exit else "No",
        }
        console.print()
        console.print(create_info_table("Container Configuration", container_data))

        success("Configuration loaded successfully")

    except ConfigurationError as e:
        console.print(f"[red]Configuration error: {e}[/red]")
        console.print("\n[yellow]Tip:[/yellow] Create a gdsentry.toml file in your project root.")
        console.print("See gdsentry.toml.example for reference.")
        raise typer.Exit(1)
    except Exception as e:
        console.print(f"[red]Error loading configuration: {e}[/red]")
        raise typer.Exit(1)


@app.command("env")
def environment_info() -> None:
    """Show development environment information."""
    import sys
    from pathlib import Path as PathlibPath

    info = detect_platform()

    env_data = {
        "Python Executable": sys.executable,
        "Python Version": sys.version.split()[0],
        "Platform": get_platform_display_name(info),
        "GDSentry Version": __version__,
        "Working Directory": str(PathlibPath.cwd()),
    }

    console.print(create_info_table("Environment Information", env_data))

    # Show Python path
    console.print()
    paths_table = Table(title="Python Path", border_style="blue")
    paths_table.add_column("Path", style="blue")
    
    for path in sys.path[:5]:  # Show first 5 paths
        paths_table.add_row(path)
    
    console.print(paths_table)


@app.command("podman")
def podman_info() -> None:
    """Validate Podman installation and configuration."""
    try:
        validator = PodmanValidator()
        result = validator.validate()

        # Create Podman info table
        podman_data = {
            "Installed": "Yes" if result.podman_installed else "No",
            "Version": result.podman_version or "N/A",
            "Machine Exists": "Yes" if result.machine_exists else "No",
            "Machine Running": "Yes" if result.machine_running else "No",
            "Rootful Mode": (
                "Yes"
                if result.machine_rootful is True
                else "No" if result.machine_rootful is False else "Unknown"
            ),
            "Can Execute Containers": "Yes" if result.can_execute_containers else "No",
        }

        table = create_info_table("Podman Environment", podman_data)
        console.print(table)

        # Show warnings
        if result.warning_messages:
            console.print()
            for msg in result.warning_messages:
                warning(msg)

        # Show errors
        if result.error_messages:
            console.print()
            for msg in result.error_messages:
                error(msg)
            raise typer.Exit(1)

        # Success message
        if result.is_valid:
            console.print()
            success("Podman environment is properly configured")

    except Exception as e:
        error(f"Error validating Podman: {e}")
        raise typer.Exit(1)


@app.command("resources")
def resources_info(
    cleanup: bool = typer.Option(False, "--cleanup", help="Clean up unused resources"),
) -> None:
    """Show Podman resource usage and optionally clean up."""
    try:
        monitor = ResourceMonitor()

        if cleanup:
            console.print("[bold]Cleaning up resources...[/bold]\n")
            
            containers_removed = monitor.cleanup_stopped_containers()
            success(f"Removed {containers_removed} stopped containers")
            
            images_removed = monitor.cleanup_dangling_images()
            success(f"Removed {images_removed} dangling images")
            
            console.print()

        # Show current resources
        console.print("[bold]Current Resources:[/bold]\n")
        
        containers = monitor.list_containers(all_containers=True)
        console.print(f"Containers: {len(containers)}")
        if containers:
            for c in containers[:5]:  # Show first 5
                console.print(f"  - {c.name} ({c.status})")
            if len(containers) > 5:
                console.print(f"  ... and {len(containers) - 5} more")
        
        console.print()
        images = monitor.list_images()
        console.print(f"Images: {len(images)}")
        if images:
            for img in images[:5]:  # Show first 5
                console.print(f"  - {img.repository}:{img.tag} ({img.size})")
            if len(images) > 5:
                console.print(f"  ... and {len(images) - 5} more")

    except Exception as e:
        error(f"Error checking resources: {e}")
        raise typer.Exit(1)

