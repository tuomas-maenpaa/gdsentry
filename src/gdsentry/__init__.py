"""
GDSentry - Advanced Testing Framework for Godot Engine

A professional testing framework for Godot projects with cross-architecture support,
containerized execution, and comprehensive validation tools.

CLI Usage (recommended):
    conda activate gdsentry
    gdsentry --help

Development Usage (fallback):
    python -m gdsentry --help
"""

from gdsentry.__version__ import __version__, __version_info__
from gdsentry.common.exceptions import (
    ConfigurationError,
    ContainerError,
    GDSentryError,
    TestExecutionError,
    ValidationError,
)
from gdsentry.core.config import GDSentryConfig, load_config

__all__ = [
    "__version__",
    "__version_info__",
    "GDSentryConfig",
    "load_config",
    "GDSentryError",
    "ConfigurationError",
    "ValidationError",
    "ContainerError",
    "TestExecutionError",
]

