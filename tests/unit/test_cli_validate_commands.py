"""Tests for CLI validate commands."""

from pathlib import Path
from unittest.mock import Mock, patch

import pytest
from typer.testing import CliRunner

from gdsentry.cli.app import app

runner = CliRunner()


def create_mock_summary(files_checked=0, errors=None, warnings=None):
    """Create a validation summary object."""
    from gdsentry.validation.runner import ValidationSummary

    # Use the actual ValidationSummary class
    summary = ValidationSummary()
    summary.files_checked = files_checked
    summary.errors = errors or []
    summary.warnings = warnings or []

    return summary


class TestValidateCommands:
    """Test validate command group."""

    def test_validate_help(self):
        """Test validate command help."""
        result = runner.invoke(app, ["validate", "--help"])
        assert result.exit_code == 0
        assert "validate" in result.stdout.lower()
        assert "Code validation tools" in result.stdout

    def test_validate_gdscript_help(self):
        """Test validate gdscript command help."""
        result = runner.invoke(app, ["validate", "gdscript", "--help"])
        assert result.exit_code == 0
        assert "gdscript" in result.stdout.lower()

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_gdscript_success(self, mock_runner_class, mock_load_config):
        """Test GDScript validation success."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        # Mock file discovery
        mock_runner._discover_gdscript_files.return_value = [
            Path("/fake/project/test1.gd"),
            Path("/fake/project/test2.gd"),
            Path("/fake/project/test3.gd"),
            Path("/fake/project/test4.gd"),
            Path("/fake/project/test5.gd")
        ]

        mock_summary = create_mock_summary(
            files_checked=5,
            warnings=["Warning 1", "Warning 2"]
        )
        mock_runner.validate_gdscript_files.return_value = mock_summary

        result = runner.invoke(app, ["validate", "gdscript"])

        assert result.exit_code == 0
        assert "GDScript validation passed! ✓" in result.stdout

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_gdscript_with_files(self, mock_runner_class, mock_load_config):
        """Test GDScript validation with specific files."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner

        mock_summary = create_mock_summary(files_checked=2)
        mock_runner.validate_gdscript_files.return_value = mock_summary

        result = runner.invoke(app, ["validate", "gdscript", "file1.gd", "file2.gd"])

        assert result.exit_code == 0
        mock_runner.validate_gdscript_files.assert_called_once()
        call_args = mock_runner.validate_gdscript_files.call_args
        assert len(call_args[0][0]) == 2  # Two files passed

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_gdscript_no_style(self, mock_runner_class, mock_load_config):
        """Test GDScript validation without style checks."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        # Mock file discovery
        mock_runner._discover_gdscript_files.return_value = [Path("/fake/project/test.gd")]

        mock_summary = create_mock_summary(files_checked=1)
        mock_runner.validate_gdscript_files.return_value = mock_summary

        result = runner.invoke(app, ["validate", "gdscript", "--no-style"])

        assert result.exit_code == 0

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_gdscript_with_errors(self, mock_runner_class, mock_load_config):
        """Test GDScript validation with errors."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        # Mock file discovery
        mock_runner._discover_gdscript_files.return_value = [
            Path("/fake/project/file1.gd"),
            Path("/fake/project/file2.gd"),
            Path("/fake/project/file3.gd")
        ]

        mock_summary = create_mock_summary(
            files_checked=3,
            errors=["Syntax error in file1.gd", "Missing import in file2.gd"],
            warnings=["Style warning in file3.gd"]
        )
        mock_runner.validate_gdscript_files.return_value = mock_summary

        result = runner.invoke(app, ["validate", "gdscript"])

        assert result.exit_code == 1

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_gdscript_no_files(self, mock_runner_class, mock_load_config):
        """Test GDScript validation when no files found."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        mock_runner._discover_gdscript_files.return_value = []

        result = runner.invoke(app, ["validate", "gdscript"])

        assert result.exit_code == 0
        assert "No GDScript files to validate" in result.stdout

    def test_validate_imports_help(self):
        """Test validate imports command help."""
        result = runner.invoke(app, ["validate", "imports", "--help"])
        assert result.exit_code == 0
        assert "imports" in result.stdout.lower()

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_imports_success(self, mock_runner_class, mock_load_config):
        """Test imports validation success."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        # Mock file discovery
        mock_runner._discover_gdscript_files.return_value = [
            Path("/fake/project/file1.gd"),
            Path("/fake/project/file2.gd"),
            Path("/fake/project/file3.gd"),
            Path("/fake/project/file4.gd")
        ]

        mock_summary = create_mock_summary(
            files_checked=4,
            warnings=["Unused import warning"]
        )
        mock_runner.validate_imports.return_value = mock_summary

        result = runner.invoke(app, ["validate", "imports"])

        assert result.exit_code == 0
        assert "Import validation passed! ✓" in result.stdout

    def test_validate_licenses_help(self):
        """Test validate licenses command help."""
        result = runner.invoke(app, ["validate", "licenses", "--help"])
        assert result.exit_code == 0
        assert "licenses" in result.stdout.lower()

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_licenses_success(self, mock_runner_class, mock_load_config):
        """Test licenses validation success."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        # Mock file discovery
        mock_runner._discover_source_files.return_value = [
            Path("/fake/project/file1.py"),
            Path("/fake/project/file2.gd"),
            Path("/fake/project/file3.md"),
            Path("/fake/project/file4.txt"),
            Path("/fake/project/file5.sh"),
            Path("/fake/project/file6.py"),
            Path("/fake/project/file7.gd"),
            Path("/fake/project/file8.md"),
            Path("/fake/project/file9.txt"),
            Path("/fake/project/file10.sh")
        ]

        mock_summary = create_mock_summary(files_checked=10)
        mock_runner.validate_licenses.return_value = mock_summary

        result = runner.invoke(app, ["validate", "licenses"])

        assert result.exit_code == 0
        assert "License validation passed! ✓" in result.stdout

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_licenses_with_files(self, mock_runner_class, mock_load_config):
        """Test licenses validation with specific files."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner

        mock_summary = Mock()
        mock_summary.files_checked = 3
        mock_summary.error_count = 0
        mock_summary.warning_count = 0
        mock_summary.passed = True
        mock_summary.errors = []
        mock_summary.warnings = []

        mock_runner.validate_licenses.return_value = mock_summary

        result = runner.invoke(app, ["validate", "licenses", "file1.py", "file2.gd", "file3.md"])

        assert result.exit_code == 0
        mock_runner.validate_licenses.assert_called_once()
        call_args = mock_runner.validate_licenses.call_args
        assert len(call_args[0][0]) == 3  # Three files passed

    def test_validate_all_help(self):
        """Test validate all command help."""
        result = runner.invoke(app, ["validate", "all", "--help"])
        assert result.exit_code == 0
        assert "all" in result.stdout.lower()

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_all_success(self, mock_runner_class, mock_load_config):
        """Test validate all success."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner

        # Mock results for different validation types
        gdscript_summary = create_mock_summary(warnings=["Style warning"])
        import_summary = create_mock_summary()
        license_summary = create_mock_summary(warnings=["License warning 1", "License warning 2"])

        mock_runner.validate_all.return_value = {
            "GDScript": gdscript_summary,
            "Import": import_summary,
            "License": license_summary,
        }

        result = runner.invoke(app, ["validate", "all"])

        assert result.exit_code == 0
        assert "All validations passed!" in result.stdout

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_all_with_errors(self, mock_runner_class, mock_load_config):
        """Test validate all with errors."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner

        # Mock results with errors
        gdscript_summary = create_mock_summary(errors=["Error 1", "Error 2"])
        import_summary = create_mock_summary(errors=["Import error"], warnings=["Import warning"])

        mock_runner.validate_all.return_value = {
            "GDScript": gdscript_summary,
            "Import": import_summary,
        }

        result = runner.invoke(app, ["validate", "all"])

        assert result.exit_code == 1
        assert "Validation failed:" in result.stdout

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_all_no_licenses(self, mock_runner_class, mock_load_config):
        """Test validate all without license checks."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner

        mock_runner.validate_all.return_value = {
            "GDScript": create_mock_summary(),
            "Import": create_mock_summary(),
        }

        result = runner.invoke(app, ["validate", "all", "--no-licenses"])

        assert result.exit_code == 0
        mock_runner.validate_all.assert_called_once_with(check_licenses=False, check_style=True)

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_all_no_style(self, mock_runner_class, mock_load_config):
        """Test validate all without style checks."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner

        mock_runner.validate_all.return_value = {
            "GDScript": create_mock_summary(),
            "Import": create_mock_summary(),
            "License": create_mock_summary(),
        }

        result = runner.invoke(app, ["validate", "all", "--no-style"])

        assert result.exit_code == 0
        mock_runner.validate_all.assert_called_once_with(check_licenses=True, check_style=False)

    @patch("gdsentry.cli.commands.validate.load_config")
    @patch("gdsentry.cli.commands.validate.ValidationRunner")
    def test_validate_all_unexpected_error(self, mock_runner_class, mock_load_config):
        """Test validate all with unexpected error."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_runner = Mock()
        mock_runner_class.return_value = mock_runner
        mock_runner.validate_all.side_effect = Exception("Unexpected validation error")

        result = runner.invoke(app, ["validate", "all"])

        assert result.exit_code == 1
        assert "Validation failed: Unexpected validation error" in result.stdout
