"""Local CI simulation - runs GitHub Actions workflow locally."""

import subprocess
import sys
from pathlib import Path
from typing import Optional

from rich.progress import Progress, SpinnerColumn, TextColumn

from gdsentry.cli.ui.console import console, error, success


class LocalCIRunner:
    """Simulates GitHub Actions CI workflow locally."""

    def __init__(self, gdsentry_root: Optional[Path] = None):
        """
        Initialize local CI runner.

        Args:
            gdsentry_root: GDSentry framework root directory (uses cwd if None)
        """
        self.gdsentry_root = gdsentry_root or Path.cwd()
        self.workflow_file = self.gdsentry_root / ".github" / "workflows" / "ci.yml"

    def run(self) -> bool:
        """
        Run CI workflow locally.

        Returns:
            True if all steps pass, False otherwise
        """
        if not self.workflow_file.exists():
            error(f"CI workflow file not found: {self.workflow_file}")
            return False

        console.print("[bold blue]🚀 Running CI workflow locally[/bold blue]")
        console.print(f"[dim]Workflow: {self.workflow_file}[/dim]\n")

        all_passed = True

        # Step 1: Setup (already done if running this command)
        console.print("[bold]Step 1:[/bold] Environment Setup")
        success("✓ Python environment ready")
        success("✓ GDSentry CLI installed")
        console.print()

        # Step 2: Run GDSentry self-tests
        console.print("[bold]Step 2:[/bold] Run GDSentry Framework Tests")
        import platform
        arch = platform.machine().lower()
        # Normalize architecture name to match our compatibility matrix
        if arch in ["arm64", "aarch64"]:
            arch = "arm64"
        elif arch in ["x86_64", "amd64"]:
            arch = "x86_64"
        godot_versions = ["3.5-stable", "4.2.2-stable"]
        framework_passed = True
        for godot_version in godot_versions:
            console.print(f"[dim]Testing Godot {godot_version} on {arch}...[/dim]")
            if not self._run_step(f"gdsentry test run --scope framework --godot {godot_version} --timeout 30"):
                framework_passed = False
                console.print(f"[red]✗ Framework tests failed for Godot {godot_version}[/red]")
            else:
                console.print(f"[green]✓ Framework tests passed for Godot {godot_version}[/green]")
        if not framework_passed:
            all_passed = False
        console.print()

        # Step 3: Build containers (required for cross-arch testing)
        console.print("[bold]Step 3:[/bold] Build Container Images")
        console.print("[dim]Building base and Godot images for current architecture...[/dim]")
        if not self._run_step("gdsentry build base && gdsentry build godot 4.2.2-stable"):
            console.print("[yellow]⚠ Container build failed, cross-architecture testing may not work[/yellow]")
            all_passed = False
        console.print()

        # Step 4: Run cross-architecture tests
        console.print("[bold]Step 4:[/bold] Run Cross-Architecture Tests")
        console.print(f"[dim]Testing on native architecture ({arch})...[/dim]")
        if not self._run_step(f"gdsentry test run --scope framework --arch {arch} --godot 4.2.2-stable --timeout 30"):
            console.print(f"[red]✗ Cross-architecture tests failed on {arch}[/red]")
            all_passed = False
        else:
            console.print(f"[green]✓ Cross-architecture tests passed on {arch}[/green]")
        console.print()

        # Step 5: Run Python unit tests
        console.print("[bold]Step 5:[/bold] Run Python Unit Tests")
        if not self._run_step(f"{sys.executable} -m pytest tests/unit/ -v --tb=short"):
            all_passed = False
        console.print()

        # Step 6: Run documentation workflow
        console.print("[bold]Step 6:[/bold] Run Documentation Workflow")
        if not self.run_docs_workflow():
            all_passed = False
        console.print()

        # Summary
        console.print("[bold]═" * 60 + "[/bold]")
        if all_passed:
            success("✓ All CI steps passed locally!")
            console.print("[dim]Note: Actual CI may have additional platform-specific checks[/dim]")
            return True
        else:
            error("✗ Some CI steps failed")
            console.print("[yellow]Fix the failures and run again[/yellow]")
            return False

    def run_docs_workflow(self) -> bool:
        """
        Run documentation workflow locally using CLI (not containers).

        Returns:
            True if docs workflow passes, False otherwise
        """
        console.print("[dim]Building documentation locally (no container)...[/dim]")
        
        all_passed = True
        
        # Build documentation
        if not self._run_step("gdsentry docs build --clean"):
            console.print("[red]✗ Documentation build failed[/red]")
            all_passed = False
        else:
            console.print("[green]✓ Documentation built successfully[/green]")
        
        # Check links
        if not self._run_step("gdsentry docs linkcheck"):
            console.print("[yellow]⚠ Link check found issues[/yellow]")
            # Don't fail on link check warnings
        else:
            console.print("[green]✓ Link check passed[/green]")
        
        return all_passed

    def _run_step(self, command: str) -> bool:
        """
        Run a single CI step.

        Args:
            command: Shell command to run

        Returns:
            True if step passed, False otherwise
        """
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            task = progress.add_task(f"Running: {command}", total=None)

            try:
                result = subprocess.run(
                    command,
                    shell=True,
                    cwd=self.gdsentry_root,
                    capture_output=True,
                    text=True,
                    timeout=300,  # 5 minutes per step
                )

                progress.update(task, completed=True)

                if result.returncode == 0:
                    success(f"✓ {command}")
                    if result.stdout:
                        console.print(f"[dim]{result.stdout[:500]}[/dim]")  # Show first 500 chars
                    return True
                else:
                    error(f"✗ {command} (exit code: {result.returncode})")
                    if result.stderr:
                        console.print(f"[red]{result.stderr[:500]}[/red]")
                    return False

            except subprocess.TimeoutExpired:
                progress.update(task, completed=True)
                error(f"✗ {command} (timeout after 5 minutes)")
                return False
            except Exception as e:
                progress.update(task, completed=True)
                error(f"✗ {command} (error: {e})")
                return False

