"""Docs commands - documentation building and validation."""


import typer

from gdsentry.cli.ui.console import console, error, info, success
from gdsentry.core.config import load_config
from gdsentry.docs.builder import DocBuilder, DocsBuildError

app = typer.Typer(help="Documentation building and validation")


@app.command("build")
def build_docs(
    format: str = typer.Option("html", "--format", "-f", help="Output format (html, pdf)"),
    clean: bool = typer.Option(False, "--clean", "-c", help="Clean build directory first"),
) -> None:
    """Build documentation."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        from gdsentry.cli import create_docs_progress

        builder = DocBuilder(gdsentry_root)

        # Build documentation
        with create_docs_progress() as progress:
            if format == "html":
                task = progress.add_task("Building HTML documentation...", total=None)
                builder.build_html(clean=clean)
                output_dir = builder.get_html_dir()
                index_file = builder.get_index_file()

                console.print()
                success("HTML documentation built successfully!")
                info(f"Output directory: {output_dir}")
                info(f"Open: {index_file}")

            elif format == "pdf":
                task = progress.add_task("Building PDF documentation...", total=None)
                builder.build_pdf(clean=clean)
                pdf_dir = builder.build_dir / "latex"

                console.print()
                success("PDF documentation built successfully!")
                info(f"Output directory: {pdf_dir}")

            else:
                error(f"Unknown format: {format}")
                raise typer.Exit(1)

    except DocsBuildError as e:
        error(f"Documentation build failed: {e}")
        raise typer.Exit(1)
    except Exception as e:
        error(f"Unexpected error: {e}")
        raise typer.Exit(1)


@app.command("linkcheck")
def check_links() -> None:
    """Check documentation links."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        builder = DocBuilder(gdsentry_root)

        with create_docs_progress() as progress:
            task = progress.add_task("Checking documentation links...", total=None)
            broken_links = builder.linkcheck()

        console.print()

        if not broken_links:
            success("All links are valid! ✓")
        else:
            console.print(f"[yellow]Found {len(broken_links)} broken links:[/yellow]\n")

            for link in broken_links[:10]:  # Show first 10
                console.print(f"  [red]✗[/red] {link}")

            if len(broken_links) > 10:
                console.print(f"\n  [dim]... and {len(broken_links) - 10} more[/dim]")

            console.print(
                f"\n[yellow]Check full report: {builder.build_dir / 'linkcheck' / 'output.txt'}[/yellow]"
            )
            raise typer.Exit(1)

    except DocsBuildError as e:
        error(f"Link check failed: {e}")
        raise typer.Exit(1)
    except Exception as e:
        error(f"Unexpected error: {e}")
        raise typer.Exit(1)


@app.command("clean")
def clean_docs() -> None:
    """Clean documentation build directory."""
    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root

        builder = DocBuilder(gdsentry_root)
        builder.clean()

        success(f"Build directory cleaned: {builder.build_dir}")

    except Exception as e:
        error(f"Clean failed: {e}")
        raise typer.Exit(1)


@app.command("validate")
def validate_docs() -> None:
    """Validate documentation quality and accuracy."""
    try:
        config = load_config()
        project_root = config.project.project_root

        # Import and run the validation script
        import sys
        from pathlib import Path

        # Add scripts directory to path
        scripts_dir = project_root / "scripts"
        sys.path.insert(0, str(scripts_dir))

        # Import the validator
        from validate_docs import DocumentationValidator

        # Run validation
        validator = DocumentationValidator(project_root)
        success_result = validator.validate_all()

        # Exit with appropriate code
        if not success_result:
            raise typer.Exit(1)

    except ImportError as e:
        error(f"Validation script not found: {e}")
        info("Make sure scripts/validate_docs.py exists")
        raise typer.Exit(1)
    except Exception as e:
        error(f"Validation failed: {e}")
        raise typer.Exit(1)

