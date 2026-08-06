"""Security utilities for input validation and sanitization."""

import os
import re
from pathlib import Path
from typing import List

import typer

from gdsentry.cli.ui.console import error


def sanitize_command_for_logging(command: List[str]) -> str:
    """
    Sanitize a command for safe logging by removing or redacting sensitive information.

    Args:
        command: Command arguments list

    Returns:
        Sanitized command string safe for logging
    """
    if not command:
        return ""

    # Redact potentially sensitive arguments
    sanitized = []
    sensitive_patterns = [
        r'--password', r'--token', r'--key', r'--secret',
        r'-p\s+\S+', r'PASSWORD=', r'TOKEN=', r'SECRET='
    ]

    for arg in command:
        # Check if this argument contains sensitive data
        is_sensitive = any(re.search(pattern, arg, re.IGNORECASE) for pattern in sensitive_patterns)

        if is_sensitive:
            # Redact sensitive arguments
            if '=' in arg:
                key = arg.split('=', 1)[0]
                sanitized.append(f"{key}=[REDACTED]")
            else:
                sanitized.append("[REDACTED]")
        else:
            sanitized.append(arg)

    return ' '.join(sanitized)


def validate_container_name(name: str) -> None:
    """
    Validate that a container name is safe for use with podman.

    Args:
        name: Container name to validate

    Raises:
        typer.Exit: If name is invalid
    """
    if not name:
        error("Container name cannot be empty")
        raise typer.Exit(1)

    # Podman container name rules:
    # - 1-255 characters
    # - Start and end with alphanumeric
    # - Can contain: a-z, A-Z, 0-9, _, ., -
    # - No consecutive hyphens or dots
    if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?$', name):
        error(f"Invalid container name format: {name}")
        error("Container names must be 1-255 chars, start/end with alphanumeric,")
        error("and contain only: letters, numbers, hyphens, underscores, dots")
        raise typer.Exit(1)

    if len(name) > 255:
        error(f"Container name too long ({len(name)} chars, max 255)")
        raise typer.Exit(1)

    # Check for shell metacharacters that could be dangerous
    dangerous_chars = [';', '&', '|', '`', '$', '(', ')', '<', '>', '"', "'"]
    if any(char in name for char in dangerous_chars):
        error(f"Container name contains dangerous characters: {name}")
        raise typer.Exit(1)


def validate_path_safety(path_str: str, allow_relative: bool = True) -> Path:
    """
    Validate and normalize a path to prevent directory traversal attacks.

    Args:
        path_str: Path string to validate
        allow_relative: Whether relative paths are allowed

    Returns:
        Normalized Path object

    Raises:
        typer.Exit: If path is unsafe
    """
    if not path_str:
        error("Path cannot be empty")
        raise typer.Exit(1)

    # Convert to Path object
    path = Path(path_str)

    # Resolve to absolute path to canonicalize
    try:
        resolved = path.resolve()
    except (OSError, RuntimeError) as e:
        error(f"Invalid path: {e}")
        raise typer.Exit(1)

    # Check for directory traversal attempts
    if allow_relative and not path.is_absolute():
        # For relative paths, check if resolved path escapes the current directory
        try:
            resolved.relative_to(Path.cwd())
        except ValueError:
            error(f"Path traversal detected: {path_str}")
            error("Relative paths cannot escape the current working directory")
            raise typer.Exit(1)
    else:
        # For absolute paths, ensure they don't contain suspicious patterns
        path_parts = resolved.parts

        # Check for excessive .. components that might indicate traversal
        dotdot_count = sum(1 for part in path_parts if part == '..')
        if dotdot_count > 2:  # Allow reasonable .. usage
            error(f"Suspicious path with excessive '..' components: {path_str}")
            raise typer.Exit(1)

    # Check for null bytes or other dangerous characters
    if '\x00' in str(path):
        error("Path contains null bytes")
        raise typer.Exit(1)

    # Check for extremely long paths (potential DoS)
    if len(str(resolved)) > 4096:  # Common filesystem limit
        error("Path too long (max 4096 characters)")
        raise typer.Exit(1)

    return resolved


def validate_file_access(path: Path, require_readable: bool = True) -> None:
    """
    Validate that a file exists and is accessible.

    Args:
        path: Path to validate
        require_readable: Whether file must be readable

    Raises:
        typer.Exit: If file is not accessible
    """
    if not path.exists():
        error(f"Path does not exist: {path}")
        raise typer.Exit(1)

    if not path.is_file():
        error(f"Path is not a file: {path}")
        raise typer.Exit(1)

    if require_readable and not os.access(path, os.R_OK):
        error(f"File is not readable: {path}")
        raise typer.Exit(1)


def generate_secure_container_name(prefix: str = "gdsentry") -> str:
    """
    Generate a secure, unique container name.

    Args:
        prefix: Prefix for the container name

    Returns:
        Secure container name
    """
    import secrets
    import time

    # Use timestamp + random suffix for uniqueness
    timestamp = int(time.time())
    random_suffix = secrets.token_hex(4)  # 8-character random string

    name = f"{prefix}-{timestamp}-{random_suffix}"

    # Validate the generated name (belt and suspenders)
    validate_container_name(name)

    return name
