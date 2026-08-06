"""Custom exceptions for GDSentry framework.

DEPRECATED: This module is maintained for backward compatibility.
New code should import from gdsentry.common.exceptions instead.

All exceptions have been moved to gdsentry.common.exceptions to resolve
circular dependencies between core and platform modules.
"""

# Re-export all exceptions from common for backward compatibility
from gdsentry.common.exceptions import (
    ConfigurationError,
    ContainerError,
    GDSentryError,
    PlatformError,
    TemplateError,
    TestExecutionError,
    ValidationError,
)

__all__ = [
    "GDSentryError",
    "ConfigurationError",
    "ValidationError",
    "ContainerError",
    "TestExecutionError",
    "PlatformError",
    "TemplateError",
]

