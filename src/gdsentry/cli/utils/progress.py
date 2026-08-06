"""Standardized progress bar utilities for CLI commands."""

from contextlib import contextmanager
from typing import Generator, Optional

from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeElapsedColumn,
)

from gdsentry.cli.ui.console import console


def create_standard_progress(
    show_spinner: bool = True,
    show_time: bool = False,
    show_bar: bool = False,
) -> Progress:
    """
    Create a standardized progress bar for CLI commands.

    Args:
        show_spinner: Whether to show spinner column
        show_time: Whether to show elapsed time column
        show_bar: Whether to show progress bar column

    Returns:
        Configured Progress instance

    Example:
        with create_standard_progress() as progress:
            task = progress.add_task("Building...", total=None)
            # Do work here
            progress.update(task, completed=True)
    """
    columns = []

    if show_spinner:
        columns.append(SpinnerColumn())

    columns.append(TextColumn("[progress.description]{task.description}"))

    if show_time:
        columns.append(TimeElapsedColumn())

    if show_bar:
        columns.append(BarColumn())
        columns.append(TextColumn("[progress.percentage]{task.percentage:>3.0f}%"))

    return Progress(*columns, console=console)


@contextmanager
def standard_progress_context(
    task_description: str,
    show_spinner: bool = True,
    show_time: bool = False,
    show_bar: bool = False,
    total: Optional[int] = None,
) -> Generator[tuple[Progress, str], None, None]:
    """
    Context manager for standardized progress display.

    Args:
        task_description: Description text for the progress task
        show_spinner: Whether to show spinner
        show_time: Whether to show elapsed time
        show_bar: Whether to show progress bar
        total: Total units for progress bar (None for indeterminate)

    Yields:
        Tuple of (progress, task_id) for updating progress

    Example:
        with standard_progress_context("Building containers...") as (progress, task):
            # Do work here
            progress.update(task, advance=1)
    """
    with create_standard_progress(show_spinner, show_time, show_bar) as progress:
        task = progress.add_task(task_description, total=total)
        yield progress, task


def create_build_progress() -> Progress:
    """
    Create a progress bar optimized for build operations.

    Returns:
        Progress instance configured for build operations
    """
    return create_standard_progress(show_spinner=True, show_time=True)


def create_test_progress() -> Progress:
    """
    Create a progress bar optimized for test operations.

    Returns:
        Progress instance configured for test operations
    """
    return create_standard_progress(show_spinner=True, show_time=True)


def create_docs_progress() -> Progress:
    """
    Create a progress bar optimized for documentation operations.

    Returns:
        Progress instance configured for docs operations
    """
    return create_standard_progress(show_spinner=True, show_time=False)
