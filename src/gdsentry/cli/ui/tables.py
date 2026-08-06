"""Table creation utilities for displaying data."""

from typing import Dict, List, Optional, Tuple

from rich.table import Table

from gdsentry.cli.ui.console import console


def create_table(
    title: Optional[str] = None,
    caption: Optional[str] = None,
    show_header: bool = True,
    show_lines: bool = False,
) -> Table:
    """
    Create a Rich table with GDSentry styling.

    Args:
        title: Table title
        caption: Table caption
        show_header: Whether to show column headers
        show_lines: Whether to show row lines

    Returns:
        Configured Table instance
    """
    return Table(
        title=title,
        caption=caption,
        show_header=show_header,
        show_lines=show_lines,
        header_style="bold cyan",
        border_style="blue",
    )


def create_info_table(
    title: str,
    data: Dict[str, str],
    key_style: str = "cyan",
    value_style: str = "green",
) -> Table:
    """
    Create a two-column info table (key-value pairs).

    Args:
        title: Table title
        data: Dictionary of key-value pairs
        key_style: Style for key column
        value_style: Style for value column

    Returns:
        Configured Table with data

    Example:
        >>> data = {"OS": "macOS", "Arch": "ARM64"}
        >>> table = create_info_table("Platform", data)
        >>> console.print(table)
    """
    table = create_table(title=title)
    table.add_column("Property", style=key_style, no_wrap=True)
    table.add_column("Value", style=value_style)

    for key, value in data.items():
        table.add_row(key, value)

    return table


def print_table(
    headers: List[str],
    rows: List[Tuple[str, ...]],
    title: Optional[str] = None,
) -> None:
    """
    Print a table with headers and rows.

    Args:
        headers: Column headers
        rows: List of row tuples
        title: Optional table title

    Example:
        >>> headers = ["Name", "Version"]
        >>> rows = [("Godot", "4.2.2"), ("Python", "3.12")]
        >>> print_table(headers, rows, "Dependencies")
    """
    table = create_table(title=title)

    for header in headers:
        table.add_column(header)

    for row in rows:
        table.add_row(*row)

    console.print(table)

