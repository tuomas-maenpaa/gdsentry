"""Rich console wrapper and output utilities."""

from typing import Optional

from rich.console import Console
from rich.theme import Theme

# GDSentry color theme
gdsentry_theme = Theme(
    {
        "info": "cyan",
        "success": "green bold",
        "warning": "yellow",
        "error": "red bold",
        "code": "magenta",
        "path": "blue",
        "value": "green",
        "key": "cyan bold",
    }
)

# Global console instance
console = Console(theme=gdsentry_theme)


def success(message: str, emoji: bool = True) -> None:
    """
    Print a success message.

    Args:
        message: Success message to display
        emoji: Whether to include emoji (default: True)
    """
    prefix = "✓" if emoji else ""
    console.print(f"{prefix} {message}", style="success")


def error(message: str, emoji: bool = True) -> None:
    """
    Print an error message.

    Args:
        message: Error message to display
        emoji: Whether to include emoji (default: True)
    """
    prefix = "✗" if emoji else ""
    console.print(f"{prefix} {message}", style="error")


def warning(message: str, emoji: bool = True) -> None:
    """
    Print a warning message.

    Args:
        message: Warning message to display
        emoji: Whether to include emoji (default: True)
    """
    prefix = "⚠" if emoji else ""
    console.print(f"{prefix} {message}", style="warning")


def info(message: str, emoji: bool = True) -> None:
    """
    Print an info message.

    Args:
        message: Info message to display
        emoji: Whether to include emoji (default: True)
    """
    prefix = "ℹ" if emoji else ""
    console.print(f"{prefix} {message}", style="info")


def print_header(title: str, subtitle: Optional[str] = None) -> None:
    """
    Print a section header.

    Args:
        title: Main title
        subtitle: Optional subtitle
    """
    console.print()
    console.rule(f"[bold cyan]{title}[/bold cyan]")
    if subtitle:
        console.print(f"[dim]{subtitle}[/dim]")
    console.print()


def print_key_value(key: str, value: str, key_width: int = 20) -> None:
    """
    Print a key-value pair.

    Args:
        key: Key name
        value: Value to display
        key_width: Width for key column (default: 20)
    """
    console.print(f"[key]{key:<{key_width}}[/key] [value]{value}[/value]")

