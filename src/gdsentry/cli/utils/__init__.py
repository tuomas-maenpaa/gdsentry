"""CLI utilities for common functionality."""

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
