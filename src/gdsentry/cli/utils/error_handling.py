"""Standardized error handling utilities for CLI commands."""

import subprocess
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Callable, List

import typer

from gdsentry.cli.ui.console import error


def handle_command_errors(
    error_prefix: str = "",
    exit_code: int = 1,
) -> Callable:
    """
    Decorator for standardized error handling in CLI commands.

    Args:
        error_prefix: Prefix to add to error messages
        exit_code: Exit code to use for errors

    Returns:
        Decorated function

    Example:
        @handle_command_errors("Build failed")
        def build_command():
            # Command logic here
            pass
    """
    def decorator(func: Callable) -> Callable:
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except FileNotFoundError as e:
                error(f"{error_prefix}File not found: {e.filename}")
                raise typer.Exit(exit_code)
            except PermissionError as e:
                error(f"{error_prefix}Permission denied: {e.filename}")
                raise typer.Exit(exit_code)
            except subprocess.CalledProcessError as e:
                error(f"{error_prefix}Command failed with exit code {e.returncode}")
                raise typer.Exit(exit_code)
            except subprocess.TimeoutExpired as e:
                error(f"{error_prefix}Command timed out after {e.timeout} seconds")
                raise typer.Exit(exit_code)
            except typer.Exit:
                # Re-raise typer exits as-is
                raise
            except Exception as e:
                error(f"{error_prefix}Unexpected error: {e}")
                raise typer.Exit(exit_code)
        return wrapper
    return decorator


def run_subprocess_safely(
    args: List[str],
    error_prefix: str = "Command failed",
    exit_code: int = 1,
    **kwargs: Any,
) -> subprocess.CompletedProcess:
    """
    Run subprocess with standardized error handling.

    Args:
        args: Command arguments
        error_prefix: Prefix for error messages
        exit_code: Exit code to use on failure
        **kwargs: Additional arguments passed to subprocess.run

    Returns:
        CompletedProcess instance

    Raises:
        typer.Exit: On command failure
    """
    try:
        result = subprocess.run(args, **kwargs)
        if result.returncode != 0:
            error(f"{error_prefix}: command exited with code {result.returncode}")
            raise typer.Exit(exit_code)
        return result
    except FileNotFoundError:
        error(f"{error_prefix}: command not found: {args[0]}")
        raise typer.Exit(exit_code)
    except subprocess.TimeoutExpired:
        timeout = kwargs.get('timeout', 'unknown')
        error(f"{error_prefix}: command timed out after {timeout} seconds")
        raise typer.Exit(exit_code)
    except Exception as e:
        error(f"{error_prefix}: {e}")
        raise typer.Exit(exit_code)


@contextmanager
def safe_file_operation(error_prefix: str = "File operation failed"):
    """
    Context manager for safe file operations with standardized error handling.

    Args:
        error_prefix: Prefix for error messages

    Example:
        with safe_file_operation("Config file error"):
            with open("config.toml", "r") as f:
                data = f.read()
    """
    try:
        yield
    except FileNotFoundError as e:
        error(f"{error_prefix}: file not found: {e.filename}")
        raise typer.Exit(1)
    except PermissionError as e:
        error(f"{error_prefix}: permission denied: {e.filename}")
        raise typer.Exit(1)
    except IsADirectoryError as e:
        error(f"{error_prefix}: expected file but found directory: {e.filename}")
        raise typer.Exit(1)
    except OSError as e:
        error(f"{error_prefix}: file system error: {e}")
        raise typer.Exit(1)


def validate_path_exists(path: Path, error_prefix: str = "Path validation failed") -> None:
    """
    Validate that a path exists.

    Args:
        path: Path to validate
        error_prefix: Prefix for error messages

    Raises:
        typer.Exit: If path doesn't exist
    """
    if not path.exists():
        error(f"{error_prefix}: path does not exist: {path}")
        raise typer.Exit(1)


def validate_file_readable(path: Path, error_prefix: str = "File validation failed") -> None:
    """
    Validate that a file exists and is readable.

    Args:
        path: File path to validate
        error_prefix: Prefix for error messages

    Raises:
        typer.Exit: If file is not readable
    """
    validate_path_exists(path, error_prefix)
    if not path.is_file():
        error(f"{error_prefix}: path is not a file: {path}")
        raise typer.Exit(1)
    if not path.stat().st_mode & 0o400:  # Check read permission
        error(f"{error_prefix}: file is not readable: {path}")
        raise typer.Exit(1)
