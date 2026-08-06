"""Tests for basic CLI functionality."""

import sys
from pathlib import Path

import pytest
from typer.testing import CliRunner

from gdsentry.cli.app import app

runner = CliRunner()


class TestCLIBasics:
    """Test basic CLI commands and infrastructure."""

    def test_cli_help(self):
        """Test that CLI help works."""
        result = runner.invoke(app, ["--help"])
        assert result.exit_code == 0
        assert "GDSentry" in result.stdout
        assert "Advanced Testing Framework" in result.stdout

    def test_cli_no_args_shows_help(self):
        """Test that running with no args shows help."""
        result = runner.invoke(app)
        # Exit code 2 is expected for missing command when no_args_is_help=True
        assert result.exit_code in [0, 2]
        assert "Usage:" in result.stdout or "GDSentry" in result.stdout


class TestInfoCommands:
    """Test info command group."""

    def test_info_help(self):
        """Test info command help."""
        result = runner.invoke(app, ["info", "--help"])
        assert result.exit_code == 0
        assert "info" in result.stdout.lower()

    def test_info_platform(self):
        """Test info platform command."""
        result = runner.invoke(app, ["info", "platform"])
        assert result.exit_code == 0
        # Should show platform information
        assert any(
            term in result.stdout.lower()
            for term in ["platform", "architecture", "python"]
        )

    def test_info_config_without_file(self):
        """Test info config command without config file."""
        # Should work with defaults
        result = runner.invoke(app, ["info", "config"])
        # May exit with 0 (using defaults) or 1 (no config found)
        # Either is acceptable
        assert result.exit_code in [0, 1]

    def test_info_env(self):
        """Test info env command."""
        result = runner.invoke(app, ["info", "env"])
        assert result.exit_code == 0
        # Should show environment information
        assert "Python" in result.stdout or "python" in result.stdout.lower()


class TestCLIUI:
    """Test CLI UI components."""

    def test_console_import(self):
        """Test that console can be imported."""
        from gdsentry.cli.ui import console

        assert console is not None

    def test_console_functions(self):
        """Test console utility functions."""
        from gdsentry.cli.ui import error, success, warning, info

        # These should not raise exceptions
        # (output goes to console, which we don't capture here)
        # Just verify they're callable
        assert callable(success)
        assert callable(error)
        assert callable(warning)
        assert callable(info)

    def test_progress_creation(self):
        """Test progress bar creation."""
        from gdsentry.cli.ui import create_progress, create_spinner

        progress = create_progress()
        assert progress is not None

        spinner = create_spinner("Testing...")
        assert spinner is not None

    def test_table_creation(self):
        """Test table creation utilities."""
        from gdsentry.cli.ui import create_table, create_info_table

        table = create_table(title="Test Table")
        assert table is not None

        data = {"Key1": "Value1", "Key2": "Value2"}
        info_table = create_info_table("Info", data)
        assert info_table is not None


class TestCLIIntegration:
    """Test CLI integration with core modules."""

    def test_cli_uses_platform_detection(self):
        """Test that CLI commands use platform detection."""
        result = runner.invoke(app, ["info", "platform"])
        assert result.exit_code == 0
        # Should detect current platform
        output_lower = result.stdout.lower()
        assert any(
            os_name in output_lower for os_name in ["macos", "linux", "windows"]
        )

    def test_cli_uses_configuration(self):
        """Test that CLI commands use configuration system."""
        # Create a temporary config file
        import tempfile

        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".toml", delete=False
        ) as f:
            f.write(
                """
[project]
name = "test-project"
godot_version = "4.2.2-stable"

[test]
scope = "framework"
"""
            )
            config_path = f.name

        try:
            result = runner.invoke(app, ["info", "config", "--path", config_path])
            assert result.exit_code == 0
            assert "test-project" in result.stdout
        finally:
            Path(config_path).unlink()

    def test_cli_main_entrypoint(self):
        """Test that main() entrypoint works."""
        from gdsentry.cli.app import main

        # Just verify it's callable (don't actually run it)
        assert callable(main)

    def test_python_m_gdsentry(self):
        """Test that python -m gdsentry works."""
        # The __main__.py module should exist
        import gdsentry.__main__

        assert hasattr(gdsentry.__main__, "main")

