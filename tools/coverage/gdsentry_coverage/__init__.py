"""
GDSentry coverage thin library (hybrid B+C1 sidecar).

Stdlib-oriented; no Typer / Podman / gdsentry.toml platform.
"""

from gdsentry_coverage.config import CoverageConfig, InstrumentResult, ProjectInstrumentResult
from gdsentry_coverage.exceptions import CoverageError, ParseError, InstrumentationError
from gdsentry_coverage.instrumenter import Instrumenter
from gdsentry_coverage.orchestrator import CoverageOrchestrator, CoverageRunResult, detect_framework_root

__all__ = [
    "CoverageConfig",
    "InstrumentResult",
    "ProjectInstrumentResult",
    "CoverageError",
    "ParseError",
    "InstrumentationError",
    "Instrumenter",
    "CoverageOrchestrator",
    "CoverageRunResult",
    "detect_framework_root",
]
