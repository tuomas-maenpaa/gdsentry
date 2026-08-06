"""Main Typer application for GDSentry CLI.

This module serves as the entry point for the GDSentry command-line interface.

Usage:
    # In conda environment (recommended development setup):
    conda activate gdsentry
    gdsentry --help

    # During development (fallback):
    python -m gdsentry --help

Note: The 'gdsentry' command becomes available after 'pip install -e .' in the conda environment.
"""

import typer

from gdsentry.cli.commands import build, ci, docs, info, init, test, validate

# Create main Typer app
app = typer.Typer(
    name="gdsentry",
    help="🚀 GDSentry - Advanced Testing Framework for Godot Engine",
    add_completion=True,
    rich_markup_mode="rich",
    no_args_is_help=True,
)

# Register command groups
app.add_typer(info.app, name="info", help="Display platform and configuration information")
app.add_typer(build.app, name="build", help="Build container images")
app.add_typer(test.app, name="test", help="Test discovery and execution")
app.add_typer(validate.app, name="validate", help="Code validation tools")
app.add_typer(docs.app, name="docs", help="Documentation building and serving")
app.add_typer(ci.app, name="ci", help="CI/CD simulation and validation")
app.add_typer(init.app, name="init", help="Project initialization and setup")


@app.callback(invoke_without_command=True)
def main_callback(ctx: typer.Context):
    """
    GDSentry - Advanced Testing Framework for Godot Engine.

    A professional testing framework with cross-architecture support,
    containerized execution, and comprehensive validation tools.
    """
    pass


def main() -> None:
    """Entry point for the CLI."""
    app()


if __name__ == "__main__":
    main()

