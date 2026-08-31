"""
Coverage configuration and result data models
"""

from dataclasses import dataclass, field
from typing import List, Optional, Dict
from pathlib import Path


@dataclass
class CoverageConfig:
    """Configuration for coverage instrumentation and reporting"""

    # Source paths
    source_root: Path
    output_dir: Path

    # File patterns
    file_patterns: List[str] = field(default_factory=lambda: ["**/*.gd"])
    exclude_patterns: List[str] = field(default_factory=list)

    # Godot / framework layout (hybrid B+C1: core/test_runner.gd, not src/core/)
    godot_path: str = "godot"
    timeout: int = 600  # 10 minutes
    framework_root: Optional[Path] = None  # dir containing core/test_runner.gd
    project_path: Optional[Path] = None  # Godot --path (defaults to source_root)
    test_runner_script: str = "core/test_runner.gd"
    # If True, run Godot against output_dir/instrumented after preparing project.godot
    use_instrumented_project: bool = True

    # Coverage options
    relative_paths: bool = True  # Use relative paths in tracking calls

    def __post_init__(self):
        """Convert string paths to Path objects"""
        if isinstance(self.source_root, str):
            self.source_root = Path(self.source_root)
        if isinstance(self.output_dir, str):
            self.output_dir = Path(self.output_dir)
        if isinstance(self.framework_root, str):
            self.framework_root = Path(self.framework_root)
        if isinstance(self.project_path, str):
            self.project_path = Path(self.project_path)


@dataclass
class InstrumentResult:
    """Result of instrumenting a single file"""

    success: bool
    file_path: str
    instrumented_lines: int = 0
    total_lines: int = 0
    errors: List[str] = field(default_factory=list)

    @property
    def coverage_percent(self) -> float:
        """Percentage of lines that are executable"""
        if self.total_lines == 0:
            return 0.0
        return (self.instrumented_lines / self.total_lines) * 100.0


@dataclass
class ProjectInstrumentResult:
    """Result of instrumenting multiple files in a project"""

    success: bool
    files_instrumented: int = 0
    files_failed: int = 0
    total_lines: int = 0
    instrumented_lines: int = 0
    file_results: Dict[str, InstrumentResult] = field(default_factory=dict)

    @property
    def total_files(self) -> int:
        """Total number of files processed"""
        return self.files_instrumented + self.files_failed

    @property
    def coverage_percent(self) -> float:
        """Average coverage percentage across all files"""
        if self.total_lines == 0:
            return 0.0
        return (self.instrumented_lines / self.total_lines) * 100.0
