"""Validation orchestration."""

from pathlib import Path
from typing import Dict, List, Optional

from gdsentry.validation.gdscript import GDScriptValidator, ValidationIssue
from gdsentry.validation.imports import ImportValidator
from gdsentry.validation.licenses import LicenseChecker


class ValidationSummary:
    """Summary of validation results."""

    def __init__(self) -> None:
        """Initialize summary."""
        self.files_checked = 0
        self.errors: List[ValidationIssue] = []
        self.warnings: List[ValidationIssue] = []

    @property
    def error_count(self) -> int:
        """Get error count."""
        return len(self.errors)

    @property
    def warning_count(self) -> int:
        """Get warning count."""
        return len(self.warnings)

    @property
    def passed(self) -> bool:
        """Check if validation passed (no errors)."""
        return self.error_count == 0


class ValidationRunner:
    """
    Orchestrates validation across multiple validators.

    Runs:
    - GDScript syntax validation
    - Import validation
    - License header checking
    """

    def __init__(self, gdsentry_root: Path):
        """
        Initialize validation runner.

        Args:
            gdsentry_root: GDSentry framework root directory
        """
        self.gdsentry_root = gdsentry_root
        self.gdscript_validator = GDScriptValidator()
        self.import_validator = ImportValidator(gdsentry_root)
        self.license_checker = LicenseChecker()

    def validate_gdscript_files(
        self, file_paths: List[Path], check_style: bool = True
    ) -> ValidationSummary:
        """
        Validate GDScript files for syntax and style.

        Args:
            file_paths: List of .gd files to validate
            check_style: Whether to check style issues

        Returns:
            Validation summary
        """
        summary = ValidationSummary()

        self.gdscript_validator.validate_files(file_paths)

        summary.files_checked = len(file_paths)
        summary.errors = self.gdscript_validator.get_errors()

        if check_style:
            summary.warnings = self.gdscript_validator.get_warnings()

        return summary

    def validate_imports(self, file_paths: List[Path]) -> ValidationSummary:
        """
        Validate imports in GDScript files.

        Args:
            file_paths: List of .gd files to validate

        Returns:
            Validation summary
        """
        summary = ValidationSummary()

        self.import_validator.validate_files(file_paths)

        summary.files_checked = len(file_paths)
        summary.errors = self.import_validator.get_errors()
        summary.warnings = self.import_validator.get_warnings()

        return summary

    def validate_licenses(self, file_paths: List[Path]) -> ValidationSummary:
        """
        Validate license headers.

        Args:
            file_paths: List of files to check

        Returns:
            Validation summary
        """
        summary = ValidationSummary()

        self.license_checker.check_files(file_paths)

        summary.files_checked = len(file_paths)
        summary.errors = self.license_checker.get_errors()
        summary.warnings = self.license_checker.get_warnings()

        return summary

    def validate_all(
        self,
        gdscript_files: Optional[List[Path]] = None,
        check_licenses: bool = True,
        check_style: bool = True,
    ) -> Dict[str, ValidationSummary]:
        """
        Run all validations.

        Args:
            gdscript_files: GDScript files to validate (discovers if None)
            check_licenses: Whether to check license headers
            check_style: Whether to check style issues

        Returns:
            Dictionary of validation summaries by type
        """
        # Discover GDScript files if not provided
        if gdscript_files is None:
            gdscript_files = self._discover_gdscript_files()

        results = {}

        # Run GDScript validation
        results["gdscript"] = self.validate_gdscript_files(
            gdscript_files, check_style=check_style
        )

        # Run import validation
        results["imports"] = self.validate_imports(gdscript_files)

        # Run license validation
        if check_licenses:
            all_source_files = self._discover_source_files()
            results["licenses"] = self.validate_licenses(all_source_files)

        return results

    def _discover_gdscript_files(self) -> List[Path]:
        """Discover all GDScript files in project."""
        gdscript_files: List[Path] = []

        src_dir = self.gdsentry_root / "src"
        tests_dir = self.gdsentry_root / "tests"

        for directory in [src_dir, tests_dir]:
            if directory.exists():
                gdscript_files.extend(directory.rglob("*.gd"))

        return sorted(gdscript_files)

    def _discover_source_files(self) -> List[Path]:
        """Discover all source files (.gd, .py, .sh)."""
        source_files: List[Path] = []

        for ext in ["*.gd", "*.py", "*.sh"]:
            source_files.extend(self.gdsentry_root.rglob(ext))

        # Filter out certain directories
        exclude_dirs = [".git", "build", "dist", "__pycache__", ".pytest_cache"]

        filtered = []
        for file in source_files:
            if not any(excluded in file.parts for excluded in exclude_dirs):
                filtered.append(file)

        return sorted(filtered)

