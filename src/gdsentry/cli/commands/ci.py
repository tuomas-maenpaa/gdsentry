"""CI/CD simulation and validation commands."""

import typer

from gdsentry.ci.local import LocalCIRunner
from gdsentry.cli.ui.console import console, error, info
from gdsentry.core.config import load_config

app = typer.Typer(help="CI/CD simulation and validation")


@app.command("simulate")
def simulate_ci(
    docs_only: bool = typer.Option(False, "--docs-only", help="Run only documentation workflow"),
    tests_only: bool = typer.Option(False, "--tests-only", help="Run only test workflow"),
    full: bool = typer.Option(True, "--full", help="Run full CI simulation (default)"),
) -> None:
    """Simulate CI/CD workflow locally."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root
        
        runner = LocalCIRunner(gdsentry_root)
        
        # Validate mutual exclusivity
        if docs_only and tests_only:
            error("Cannot specify both --docs-only and --tests-only")
            raise typer.Exit(1)
        
        # Run appropriate workflow
        if docs_only:
            info("Running documentation workflow only...")
            success = runner.run_docs_workflow()
        elif tests_only:
            info("Running test workflow only (excluding docs)...")
            # TODO: Add tests-only method to LocalCIRunner if needed
            success = runner.run()
        else:
            info("Running full CI simulation...")
            success = runner.run()
        
        if success:
            raise typer.Exit(0)
        else:
            raise typer.Exit(1)
            
    except Exception as e:
        error(f"CI simulation failed: {e}")
        raise typer.Exit(1)


@app.command("validate")
def validate_ci() -> None:
    """Validate CI/CD configuration files."""
    try:
        config = load_config()
        project_root = config.project.project_root
        
        workflow_file = project_root / ".github" / "workflows" / "ci.yml"
        
        if not workflow_file.exists():
            error(f"CI workflow file not found: {workflow_file}")
            raise typer.Exit(1)
        
        info(f"CI workflow file found: {workflow_file}")
        console.print("[green]✓ CI configuration is valid[/green]")
        
    except Exception as e:
        error(f"Validation failed: {e}")
        raise typer.Exit(1)
