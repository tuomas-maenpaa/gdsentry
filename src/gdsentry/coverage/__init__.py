"""
GDSentry Coverage System

Provides code coverage measurement for GDScript tests.
"""

from gdsentry.coverage.config import CoverageConfig, InstrumentResult, ProjectInstrumentResult
from gdsentry.coverage.exceptions import CoverageError, ParseError, InstrumentationError
from gdsentry.coverage.instrumenter import Instrumenter

__all__ = [
    "CoverageConfig",
    "InstrumentResult",
    "ProjectInstrumentResult",
    "CoverageError",
    "ParseError",
    "InstrumentationError",
    "Instrumenter",
]
