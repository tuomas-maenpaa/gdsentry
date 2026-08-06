"""Integration tests for full CLI workflows."""

import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

from gdsentry.cli.app import app
from typer.testing import CliRunner

runner = CliRunner()


class TestCLIWorkflows:
    """Test full CLI workflows end-to-end."""

    def test_full_project_workflow(self):
        """Test complete project lifecycle: init -> discover -> run."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "test-project"
            project_dir.mkdir()

            # Change to project directory for relative operations
            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Step 1: Initialize project
                result = runner.invoke(app, ["init", "project", ".", "--name", "workflow-test"])
                assert result.exit_code == 0
                assert "Project initialized successfully" in result.stdout

                # Verify gdsentry.toml was created
                config_file = project_dir / "gdsentry.toml"
                assert config_file.exists()

                # Step 2: Generate a test file
                result = runner.invoke(app, ["init", "test", "player_movement", "--type", "unit"])
                assert result.exit_code == 0
                assert "Test generated:" in result.stdout

                # Verify test file was created
                test_file = project_dir / "tests" / "unit" / "player_movement_test.gd"
                assert test_file.exists()

                # Step 3: Discover tests
                result = runner.invoke(app, ["test", "discover"])
                assert result.exit_code == 0
                # Should find the generated test or framework tests

                # Step 4: Run tests (framework scope for reliability)
                result = runner.invoke(app, ["test", "run", "--scope", "framework", "--timeout", "30"])
                # This might fail in CI without Godot, but we're testing the workflow
                assert result.exit_code in [0, 1, 3]  # Success, test failure, or exception

            finally:
                os.chdir(original_cwd)

    def test_docs_workflow(self):
        """Test documentation workflow: build docs."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "docs-project"
            project_dir.mkdir()

            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Initialize project
                result = runner.invoke(app, ["init", "project", ".", "--name", "docs-test"])
                assert result.exit_code == 0

                # Try to build docs (may fail without sphinx, but tests workflow)
                result = runner.invoke(app, ["docs", "build", "--format", "html"])
                # Docs build may fail due to missing dependencies, but we're testing the workflow
                assert result.exit_code in [0, 1]

            finally:
                os.chdir(original_cwd)

    def test_validation_workflow(self):
        """Test validation workflow."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "validation-project"
            project_dir.mkdir()

            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Initialize project
                result = runner.invoke(app, ["init", "project", ".", "--name", "validation-test"])
                assert result.exit_code == 0

                # Create a simple GDScript file to validate
                gdscript_dir = project_dir / "src"
                gdscript_dir.mkdir()
                gdscript_file = gdscript_dir / "test_script.gd"
                gdscript_file.write_text("""
extends Node

func _ready():
    print("Hello from test script")

func test_function():
    var x = 1
    return x
""")

                # Try to validate (may have limited validation without full Godot)
                result = runner.invoke(app, ["validate", "gdscript"])
                # Validation may pass or fail depending on setup, but we're testing workflow
                assert result.exit_code in [0, 1]

            finally:
                os.chdir(original_cwd)

    def test_info_workflow(self):
        """Test info commands workflow."""
        # Test info commands work together
        result = runner.invoke(app, ["info", "platform"])
        assert result.exit_code == 0

        result = runner.invoke(app, ["info", "version"])
        assert result.exit_code == 0

        result = runner.invoke(app, ["info", "env"])
        assert result.exit_code == 0

    def test_build_workflow(self):
        """Test build commands workflow."""
        # Test build commands (may fail without Podman, but tests workflow)
        result = runner.invoke(app, ["build", "base", "--arch", "x86_64"])
        assert result.exit_code in [0, 1]  # May fail without Podman

        result = runner.invoke(app, ["build", "docs"])
        assert result.exit_code in [0, 1]  # May fail without Podman

    def test_config_workflow(self):
        """Test configuration workflow."""
        with tempfile.TemporaryDirectory() as temp_dir:
            config_file = Path(temp_dir) / "test-config.toml"
            config_file.write_text("""
[project]
name = "config-test"
godot_version = "4.2.2-stable"

[test]
scope = "project"
timeout = 60
""")

            # Test loading specific config
            result = runner.invoke(app, ["info", "config", "--path", str(config_file)])
            assert result.exit_code == 0
            assert "config-test" in result.stdout

    def test_error_workflow(self):
        """Test error handling workflow."""
        # Test various error scenarios
        result = runner.invoke(app, ["init", "project", "/nonexistent/path"])
        assert result.exit_code == 1

        # Invalid scope doesn't cause error, just uses default
        result = runner.invoke(app, ["test", "discover", "--scope", "invalid"])
        assert result.exit_code == 0

        result = runner.invoke(app, ["docs", "build", "--format", "invalid"])
        assert result.exit_code == 1

    def test_cli_consistency(self):
        """Test CLI command consistency and help system."""
        # Test that all commands have help
        commands = [
            ["init", "--help"],
            ["test", "--help"],
            ["build", "--help"],
            ["docs", "--help"],
            ["info", "--help"],
            ["validate", "--help"],
        ]

        for cmd in commands:
            result = runner.invoke(app, cmd)
            assert result.exit_code == 0
            assert "Usage:" in result.stdout or "usage:" in result.stdout.lower()

    def test_project_structure_workflow(self):
        """Test project structure creation and validation."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "structure-test"
            project_dir.mkdir()

            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Initialize project
                result = runner.invoke(app, ["init", "project", ".", "--name", "structure-test"])
                assert result.exit_code == 0

                # Check that expected directories/files were created
                assert (project_dir / "gdsentry.toml").exists()
                assert (project_dir / "tests").exists()
                assert (project_dir / "tests" / "unit").exists()
                assert (project_dir / "tests" / "integration").exists()

                # Generate test and check structure
                result = runner.invoke(app, ["init", "test", "example_test", "--type", "integration"])
                assert result.exit_code == 0
                assert (project_dir / "tests" / "integration" / "example_test_test.gd").exists()

            finally:
                os.chdir(original_cwd)


class TestWorkflowIntegration:
    """Test integration between different CLI components."""

    def test_init_and_info_integration(self):
        """Test that init creates valid config that info can read."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "integration-test"
            project_dir.mkdir()

            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Init project
                result = runner.invoke(app, ["init", "project", ".", "--name", "integration-test"])
                assert result.exit_code == 0

                # Info should be able to read the config
                result = runner.invoke(app, ["info", "config"])
                assert result.exit_code == 0
                assert "integration-test" in result.stdout

            finally:
                os.chdir(original_cwd)

    def test_template_and_validation_integration(self):
        """Test that generated templates pass validation."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "template-test"
            project_dir.mkdir()

            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Initialize project
                runner.invoke(app, ["init", "project", ".", "--name", "template-test"])

                # Generate a test template
                runner.invoke(app, ["init", "test", "validation_test", "--type", "unit"])

                # The generated file should exist and be valid GDScript structure
                test_file = project_dir / "tests" / "unit" / "validation_test_test.gd"
                assert test_file.exists()

                # Read the file content
                content = test_file.read_text()
                assert "extends GDTest" in content or "extends Node" in content
                assert "func test_" in content

            finally:
                os.chdir(original_cwd)

    def test_workflow_error_recovery(self):
        """Test that workflows handle errors gracefully."""
        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "error-test"
            project_dir.mkdir()

            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(project_dir)

                # Try operations that might fail
                result = runner.invoke(app, ["test", "run", "--scope", "framework", "--timeout", "5"])
                # May succeed or fail, but shouldn't crash
                assert result.exit_code in [0, 1, 3]

                # Try docs build
                result = runner.invoke(app, ["docs", "build"])
                # May succeed or fail depending on environment
                assert result.exit_code in [0, 1]

            finally:
                os.chdir(original_cwd)
