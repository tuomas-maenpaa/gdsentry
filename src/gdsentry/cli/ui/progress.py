"""Progress indicators and spinners."""

from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TaskProgressColumn,
    TextColumn,
    TimeElapsedColumn,
)

from gdsentry.cli.ui.console import console


def create_progress() -> Progress:
    """
    Create a Rich progress bar for long-running operations.

    Returns:
        Configured Progress instance

    Example:
        >>> with create_progress() as progress:
        ...     task = progress.add_task("Building...", total=100)
        ...     for i in range(100):
        ...         progress.update(task, advance=1)
    """
    return Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        TimeElapsedColumn(),
        console=console,
    )


def create_spinner(description: str = "Processing...") -> Progress:
    """
    Create a simple spinner for indeterminate operations.

    Args:
        description: Description text for the spinner

    Returns:
        Configured Progress instance

    Example:
        >>> with create_spinner("Loading...") as spinner:
        ...     task = spinner.add_task("", total=None)
        ...     # do work
    """
    return Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    )

