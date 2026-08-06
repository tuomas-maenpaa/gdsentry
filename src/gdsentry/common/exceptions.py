"""Custom exceptions for GDSentry framework.

This module contains all common exceptions used throughout the framework.
Extracted from core.exceptions to resolve circular dependencies between
core and platform modules.
"""


class GDSentryError(Exception):
    """Base exception for all GDSentry errors."""

    pass


class ConfigurationError(GDSentryError):
    """Raised when configuration is invalid or cannot be loaded."""

    pass


class ValidationError(GDSentryError):
    """Raised when validation checks fail."""

    pass


class ContainerError(GDSentryError):
    """Raised when container operations fail."""

    pass


class TestExecutionError(GDSentryError):
    """Raised when test execution fails."""

    pass


class PlatformError(GDSentryError):
    """Raised when platform detection or compatibility checks fail."""

    pass


class TemplateError(GDSentryError):
    """Raised when template rendering or generation fails."""

    pass
