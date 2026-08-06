"""Command-line interface for GDSentry."""

import tempfile
from contextlib import contextmanager
from pathlib import Path
from typing import Generator, Optional

from gdsentry.cli.app import app, main
from gdsentry.cli.utils.error_handling import (
    handle_command_errors,
    run_subprocess_safely,
)
from gdsentry.cli.utils.progress import (
    create_build_progress,
    create_docs_progress,
    create_standard_progress,
    create_test_progress,
    standard_progress_context,
)
from gdsentry.cli.utils.security import (
    generate_secure_container_name,
    sanitize_command_for_logging,
    validate_container_name,
    validate_file_access,
    validate_path_safety,
)

__all__ = [
    "app",
    "main",
    "secure_temp_file",
    "secure_temp_dir",
    "handle_command_errors",
    "run_subprocess_safely",
    "create_standard_progress",
    "standard_progress_context",
    "create_build_progress",
    "create_test_progress",
    "create_docs_progress",
    "sanitize_command_for_logging",
    "validate_container_name",
    "validate_path_safety",
    "validate_file_access",
    "generate_secure_container_name",
]


@contextmanager
def secure_temp_file(
    suffix: Optional[str] = None,
    prefix: Optional[str] = None,
    dir: Optional[str] = None,
    mode: str = "w+",
    encoding: Optional[str] = None,
    delete: bool = True,
) -> Generator[Path, None, None]:
    """
    Create a secure temporary file with proper isolation.

    This function provides secure temporary file creation that prevents
    race conditions and symlink attacks.

    Args:
        suffix: File suffix (e.g., '.txt')
        prefix: File prefix
        dir: Directory to create file in (uses system temp dir if None)
        mode: File mode
        encoding: Text encoding
        delete: Whether to delete file on context exit

    Yields:
        Path to the temporary file

    Example:
        with secure_temp_file(suffix='.log') as temp_file:
            temp_file.write_text("log data")
            # File is automatically cleaned up
    """
    with tempfile.NamedTemporaryFile(
        suffix=suffix,
        prefix=prefix,
        dir=dir,
        mode=mode,
        encoding=encoding,
        delete=delete,
    ) as temp_file:
        yield Path(temp_file.name)


@contextmanager
def secure_temp_dir(
    suffix: Optional[str] = None,
    prefix: Optional[str] = None,
    dir: Optional[str] = None,
) -> Generator[Path, None, None]:
    """
    Create a secure temporary directory with proper isolation.

    This function provides secure temporary directory creation that prevents
    race conditions and ensures proper cleanup.

    Args:
        suffix: Directory suffix
        prefix: Directory prefix
        dir: Parent directory (uses system temp dir if None)

    Yields:
        Path to the temporary directory

    Example:
        with secure_temp_dir() as temp_dir:
            (temp_dir / "file.txt").write_text("data")
            # Directory and contents are automatically cleaned up
    """
    with tempfile.TemporaryDirectory(
        suffix=suffix,
        prefix=prefix,
        dir=dir,
    ) as temp_dir:
        yield Path(temp_dir)

