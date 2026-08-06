"""Validate commands - code validation tools."""

from pathlib import Path
from typing import List, Optional

import typer
from rich.table import Table

from gdsentry.cli.ui.console import console, error, info, success
from gdsentry.container.podman import PodmanClient
from gdsentry.core.config import load_config
from gdsentry.validation.podman import PodmanValidator
from gdsentry.validation.runner import ValidationRunner, ValidationSummary

app = typer.Typer(help="Code validation tools")


def _report_validation(summary: ValidationSummary, validation_type: str) -> None:
    """Report validation results."""
    table = Table(title=f"{validation_type} Validation", show_header=True, header_style="bold cyan")

    table.add_column("Metric", style="cyan")
    table.add_column("Count", justify="right")

    table.add_row("Files Checked", str(summary.files_checked))
    table.add_row(
        "Errors",
        f"[red]{summary.error_count}[/red]"
        if summary.error_count > 0
        else f"[green]{summary.error_count}[/green]",
    )
    table.add_row(
        "Warnings",
        f"[yellow]{summary.warning_count}[/yellow]"
        if summary.warning_count > 0
        else f"[green]{summary.warning_count}[/green]",
    )

    console.print(table)

    # Show errors
    if summary.errors:
        console.print("\n[bold red]Errors:[/bold red]\n")
        for issue in summary.errors[:10]:  # Show first 10
            console.print(f"  [red]✗[/red] {issue}")

        if len(summary.errors) > 10:
            console.print(f"\n  [dim]... and {len(summary.errors) - 10} more errors[/dim]")

    # Show warnings
    if summary.warnings:
        console.print("\n[bold yellow]Warnings:[/bold yellow]\n")
        for issue in summary.warnings[:10]:  # Show first 10
            console.print(f"  [yellow]⚠[/yellow] {issue}")

        if len(summary.warnings) > 10:
            console.print(f"\n  [dim]... and {len(summary.warnings) - 10} more warnings[/dim]")


@app.command("gdscript")
def validate_gdscript(
    files: Optional[List[str]] = typer.Argument(None, help="Specific files to validate"),
    no_style: bool = typer.Option(False, "--no-style", help="Skip style checks"),
) -> None:
    """Validate GDScript syntax and style."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        runner = ValidationRunner(gdsentry_root)

        # Determine files to validate
        if files:
            file_paths = [Path(f) for f in files]
        else:
            file_paths = runner._discover_gdscript_files()
            info(f"Discovered {len(file_paths)} GDScript files")

        if not file_paths:
            console.print("[yellow]No GDScript files to validate[/yellow]")
            return

        # Run validation
        summary = runner.validate_gdscript_files(file_paths, check_style=not no_style)

        # Report results
        console.print()
        _report_validation(summary, "GDScript")

        if summary.passed:
            console.print()
            success("GDScript validation passed! ✓")
        else:
            console.print()
            error(f"GDScript validation failed with {summary.error_count} errors")
            raise typer.Exit(1)

    except Exception as e:
        error(f"Validation failed: {e}")
        raise typer.Exit(1)


@app.command("imports")
def validate_imports(
    files: Optional[List[str]] = typer.Argument(None, help="Specific files to validate"),
) -> None:
    """Validate GDScript imports."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        runner = ValidationRunner(gdsentry_root)

        # Determine files to validate
        if files:
            file_paths = [Path(f) for f in files]
        else:
            file_paths = runner._discover_gdscript_files()
            info(f"Discovered {len(file_paths)} GDScript files")

        if not file_paths:
            console.print("[yellow]No GDScript files to validate[/yellow]")
            return

        # Run validation
        summary = runner.validate_imports(file_paths)

        # Report results
        console.print()
        _report_validation(summary, "Import")

        if summary.passed:
            console.print()
            success("Import validation passed! ✓")
        else:
            console.print()
            error(f"Import validation failed with {summary.error_count} errors")
            raise typer.Exit(1)

    except Exception as e:
        error(f"Validation failed: {e}")
        raise typer.Exit(1)


@app.command("licenses")
def validate_licenses(
    files: Optional[List[str]] = typer.Argument(None, help="Specific files to check"),
) -> None:
    """Check license headers in source files."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        runner = ValidationRunner(gdsentry_root)

        # Determine files to check
        if files:
            file_paths = [Path(f) for f in files]
        else:
            file_paths = runner._discover_source_files()
            info(f"Discovered {len(file_paths)} source files")

        if not file_paths:
            console.print("[yellow]No files to check[/yellow]")
            return

        # Run validation
        summary = runner.validate_licenses(file_paths)

        # Report results
        console.print()
        _report_validation(summary, "License")

        if summary.passed:
            console.print()
            success("License validation passed! ✓")
        else:
            console.print()
            error(f"License validation failed with {summary.error_count} errors")
            raise typer.Exit(1)

    except Exception as e:
        error(f"Validation failed: {e}")
        raise typer.Exit(1)


@app.command("all")
def validate_all(
    no_licenses: bool = typer.Option(False, "--no-licenses", help="Skip license checks"),
    no_style: bool = typer.Option(False, "--no-style", help="Skip style checks"),
) -> None:
    """Run all validations."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        runner = ValidationRunner(gdsentry_root)

        console.print("[bold cyan]Running all validations...[/bold cyan]\n")

        # Run all validations
        results = runner.validate_all(
            check_licenses=not no_licenses,
            check_style=not no_style,
        )

        # Report each result
        for validation_type, summary in results.items():
            _report_validation(summary, validation_type.title())
            console.print()

        # Overall summary
        total_errors = sum(s.error_count for s in results.values())
        total_warnings = sum(s.warning_count for s in results.values())

        if total_errors == 0:
            success(
                f"All validations passed! "
                f"({total_warnings} warnings)"
            )
        else:
            error(
                f"Validation failed: {total_errors} errors, "
                f"{total_warnings} warnings"
            )
            raise typer.Exit(1)

    except Exception as e:
        error(f"Validation failed: {e}")
        raise typer.Exit(1)


@app.command("podman")
def validate_podman(
    build_missing: bool = typer.Option(False, "--build-missing", help="Build missing containers automatically"),
) -> None:
    """Validate Podman environment and container setup.

    Performs comprehensive validation of:
    - Podman installation and daemon
    - Podman machine existence and status
    - Rootful mode configuration
    - Container execution capability
    - Required container images
    """
    try:
        console.print(f"\n[bold cyan]Validating Podman environment...[/bold cyan]\n")

        # Create validator and run validation
        validator = PodmanValidator()
        result = validator.validate()

        # Report installation status
        if result.podman_installed:
            success("✓ Podman is installed")
        else:
            error("✗ Podman is not installed")
            console.print("Install podman and run: gdsentry init podman")
            raise typer.Exit(1)

        # Report machine status
        if result.machine_exists:
            success("✓ Podman machine exists")
        else:
            error("✗ Podman machine does not exist")
            console.print("Run: gdsentry init podman")
            raise typer.Exit(1)

        if result.machine_running:
            success("✓ Podman machine is running")
        else:
            error("✗ Podman machine is not running")
            console.print("Run: gdsentry init podman")
            raise typer.Exit(1)

        # Report rootful status
        if result.machine_rootful is True:
            success("✓ Podman machine is in rootful mode")
        elif result.machine_rootful is False:
            error("✗ Podman machine is not in rootful mode")
            console.print("Rootful mode is required for GDSentry testing")
            console.print("Recreate machine with: podman machine init --rootful")
            raise typer.Exit(1)
        else:
            console.print("[yellow]⚠ Podman machine rootful status unknown[/yellow]")

        # Test container execution
        console.print("\n[bold]Testing container execution...[/bold]")
        podman = PodmanClient()
        try:
            test_result = podman._run_command(["podman", "run", "--rm", "docker.io/alpine:latest", "echo", "test"])
            if test_result.returncode == 0 and "test" in test_result.stdout:
                success("✓ Container execution works")
            else:
                error("✗ Container execution failed")
                console.print(f"Command output: {test_result.stdout}")
                raise typer.Exit(1)
        except Exception as e:
            error(f"✗ Container execution test failed: {e}")
            raise typer.Exit(1)

        # Check for required container images (Godot versions only)
        console.print("\n[bold]Checking required container images...[/bold]")
        required_images = [
            "gdsentry-base:latest",
            "gdsentry-godot-4.2:latest",
            "gdsentry-godot-3.5:latest"
        ]

        missing_images = []
        for image in required_images:
            try:
                result = podman._run_command(["podman", "images", "-q", image])
                if not result.stdout.strip():
                    missing_images.append(image)
            except Exception:
                missing_images.append(image)

        if missing_images:
            console.print(f"[yellow]⚠ Missing {len(missing_images)} container images:[/yellow]")
            for image in missing_images:
                console.print(f"  - {image}")

            if build_missing:
                console.print("\n[bold]Building missing images...[/bold]")
                # Import here to avoid circular imports
                from gdsentry.container.builder import ContainerBuilder

                builder = ContainerBuilder()
                for image in missing_images:
                    try:
                        console.print(f"Building {image}...")
                        if "godot-4.2" in image:
                            builder.build_godot("4.2.2-stable", "x86_64")
                        elif "godot-3.5" in image:
                            builder.build_godot("3.5.2-stable", "x86_64")
                        elif "base" in image:
                            builder.build_base("x86_64")
                        elif "docs" in image:
                            builder.build_docs()
                        success(f"✓ Built {image}")
                    except Exception as e:
                        error(f"✗ Failed to build {image}: {e}")
                        raise typer.Exit(1)
            else:
                console.print("\n[yellow]Run with --build-missing to build them automatically[/yellow]")
                console.print("Or build manually: gdsentry build all")
        else:
            success("✓ All required container images are available")

        console.print(f"\n[bold green]✓[/bold green] Podman environment validation passed!")
        console.print("\n[bold]Ready for GDSentry testing![/bold]")
        console.print("Next: gdsentry test run-container")

    except Exception as e:
        error(f"Podman validation failed: {e}")
        raise typer.Exit(1)

