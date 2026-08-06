"""Tests for validation functionality."""

import pytest
from pathlib import Path

from gdsentry.validation.gdscript import GDScriptValidator, ValidationIssue
from gdsentry.validation.imports import ImportValidator
from gdsentry.validation.licenses import LicenseChecker
from gdsentry.validation.runner import ValidationRunner, ValidationSummary


class TestValidationIssue:
    """Test ValidationIssue model."""

    def test_validation_issue_creation(self):
        """Test creating validation issue."""
        issue = ValidationIssue(
            file=Path("test.gd"),
            line=10,
            severity="error",
            message="Test error",
        )

        assert issue.file == Path("test.gd")
        assert issue.line == 10
        assert issue.severity == "error"
        assert issue.message == "Test error"

    def test_validation_issue_string(self):
        """Test ValidationIssue string representation."""
        issue = ValidationIssue(
            file=Path("test.gd"),
            line=5,
            severity="warning",
            message="Test warning",
        )

        assert str(issue) == "test.gd:5: Test warning"

    def test_validation_issue_without_line(self):
        """Test ValidationIssue without line number."""
        issue = ValidationIssue(
            file=Path("test.gd"),
            severity="error",
            message="File-level error",
        )

        assert issue.line is None
        assert str(issue) == "test.gd: File-level error"


class TestGDScriptValidator:
    """Test GDScript validation."""

    def test_validator_creation(self):
        """Test creating validator."""
        validator = GDScriptValidator()
        assert validator is not None
        assert validator.max_line_length == 120

    def test_validator_custom_line_length(self):
        """Test custom line length."""
        validator = GDScriptValidator(max_line_length=80)
        assert validator.max_line_length == 80

    def test_validate_existing_file(self):
        """Test validating an existing GDScript file."""
        validator = GDScriptValidator()

        # Find a real GDScript file in the project
        project_root = Path.cwd()
        gdscript_files = list((project_root / "src").rglob("*.gd"))

        if gdscript_files:
            file_path = gdscript_files[0]
            result = validator.validate_file(file_path)

            # Should return boolean
            assert isinstance(result, bool)

            # Should have issues collected
            assert isinstance(validator.issues, list)

    def test_get_errors_and_warnings(self):
        """Test getting errors and warnings separately."""
        validator = GDScriptValidator()

        # Add mock issues
        validator.issues = [
            ValidationIssue(
                file=Path("test.gd"),
                severity="error",
                message="Error 1",
            ),
            ValidationIssue(
                file=Path("test.gd"),
                severity="warning",
                message="Warning 1",
            ),
            ValidationIssue(
                file=Path("test.gd"),
                severity="error",
                message="Error 2",
            ),
        ]

        errors = validator.get_errors()
        warnings = validator.get_warnings()

        assert len(errors) == 2
        assert len(warnings) == 1


class TestImportValidator:
    """Test import validation."""

    def test_validator_creation(self):
        """Test creating import validator."""
        project_root = Path.cwd()
        validator = ImportValidator(project_root)

        assert validator is not None
        assert validator.project_root == project_root
        assert isinstance(validator.expected_paths, dict)

    def test_expected_paths_defined(self):
        """Test that expected paths are defined."""
        project_root = Path.cwd()
        validator = ImportValidator(project_root)

        # Should have expected paths for common classes
        assert "GDTest" in validator.expected_paths
        assert "SceneTreeTest" in validator.expected_paths
        assert "NodeTest" in validator.expected_paths

    def test_validate_existing_file(self):
        """Test validating an existing GDScript file."""
        project_root = Path.cwd()
        validator = ImportValidator(project_root)

        gdscript_files = list((project_root / "src").rglob("*.gd"))

        if gdscript_files:
            file_path = gdscript_files[0]
            result = validator.validate_file(file_path)

            assert isinstance(result, bool)


class TestLicenseChecker:
    """Test license header checking."""

    def test_checker_creation(self):
        """Test creating license checker."""
        checker = LicenseChecker()
        assert checker is not None

    def test_check_existing_gdscript_file(self):
        """Test checking an existing GDScript file."""
        checker = LicenseChecker()
        project_root = Path.cwd()

        gdscript_files = list((project_root / "src").rglob("*.gd"))

        if gdscript_files:
            file_path = gdscript_files[0]
            result = checker.check_file(file_path)

            assert isinstance(result, bool)

    def test_get_errors_and_warnings(self):
        """Test getting errors and warnings."""
        checker = LicenseChecker()

        # Add mock issues
        checker.issues = [
            ValidationIssue(
                file=Path("test.gd"),
                severity="warning",
                message="Missing header",
            )
        ]

        warnings = checker.get_warnings()
        assert len(warnings) == 1


class TestValidationSummary:
    """Test validation summary."""

    def test_empty_summary(self):
        """Test empty summary."""
        summary = ValidationSummary()

        assert summary.files_checked == 0
        assert summary.error_count == 0
        assert summary.warning_count == 0
        assert summary.passed is True

    def test_summary_with_errors(self):
        """Test summary with errors."""
        summary = ValidationSummary()
        summary.files_checked = 5

        summary.errors = [
            ValidationIssue(
                file=Path("test.gd"),
                severity="error",
                message="Error",
            )
        ]

        assert summary.error_count == 1
        assert summary.passed is False

    def test_summary_with_warnings(self):
        """Test summary with warnings only."""
        summary = ValidationSummary()
        summary.files_checked = 5

        summary.warnings = [
            ValidationIssue(
                file=Path("test.gd"),
                severity="warning",
                message="Warning",
            )
        ]

        assert summary.warning_count == 1
        assert summary.error_count == 0
        assert summary.passed is True  # Warnings don't fail validation


class TestValidationRunner:
    """Test validation runner."""

    def test_runner_creation(self):
        """Test creating validation runner."""
        project_root = Path.cwd()
        runner = ValidationRunner(project_root)

        assert runner is not None
        assert runner.project_root == project_root
        assert isinstance(runner.gdscript_validator, GDScriptValidator)
        assert isinstance(runner.import_validator, ImportValidator)
        assert isinstance(runner.license_checker, LicenseChecker)

    def test_discover_gdscript_files(self):
        """Test discovering GDScript files."""
        project_root = Path.cwd()
        runner = ValidationRunner(project_root)

        files = runner._discover_gdscript_files()

        # Should find some GDScript files
        assert isinstance(files, list)
        assert len(files) > 0

        # All should be .gd files
        for file in files:
            assert file.suffix == ".gd"

    def test_discover_source_files(self):
        """Test discovering source files."""
        project_root = Path.cwd()
        runner = ValidationRunner(project_root)

        files = runner._discover_source_files()

        # Should find source files
        assert isinstance(files, list)
        assert len(files) > 0

        # Should be .gd, .py, or .sh files
        for file in files:
            assert file.suffix in [".gd", ".py", ".sh"]

    def test_validate_gdscript_files(self):
        """Test validating GDScript files."""
        project_root = Path.cwd()
        runner = ValidationRunner(project_root)

        # Get some files
        files = runner._discover_gdscript_files()[:5]  # Just test first 5

        if files:
            summary = runner.validate_gdscript_files(files)

            assert isinstance(summary, ValidationSummary)
            assert summary.files_checked == len(files)

    def test_validate_imports(self):
        """Test validating imports."""
        project_root = Path.cwd()
        runner = ValidationRunner(project_root)

        files = runner._discover_gdscript_files()[:5]

        if files:
            summary = runner.validate_imports(files)

            assert isinstance(summary, ValidationSummary)
            assert summary.files_checked == len(files)

    def test_validate_licenses(self):
        """Test validating licenses."""
        project_root = Path.cwd()
        runner = ValidationRunner(project_root)

        files = runner._discover_source_files()[:10]

        if files:
            summary = runner.validate_licenses(files)

            assert isinstance(summary, ValidationSummary)
            assert summary.files_checked == len(files)


class TestValidationCLI:
    """Test validation CLI commands."""

    def test_validate_commands_import(self):
        """Test that validate commands can be imported."""
        from gdsentry.cli.commands import validate

        assert validate.app is not None
        assert hasattr(validate, "validate_gdscript")
        assert hasattr(validate, "validate_imports")
        assert hasattr(validate, "validate_licenses")
        assert hasattr(validate, "validate_all")

