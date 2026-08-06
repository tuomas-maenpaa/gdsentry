"""Tests for CLI init commands."""

import tempfile
from pathlib import Path
from unittest.mock import Mock, patch

import pytest
from typer.testing import CliRunner

from gdsentry.cli.app import app

runner = CliRunner()


class TestInitCommands:
    """Test init command group."""

    def test_init_help(self):
        """Test init command help."""
        result = runner.invoke(app, ["init", "--help"])
        assert result.exit_code == 0
        assert "init" in result.stdout.lower()
        assert "Project initialization" in result.stdout

    def test_init_project_help(self):
        """Test init project command help."""
        result = runner.invoke(app, ["init", "project", "--help"])
        assert result.exit_code == 0
        assert "project" in result.stdout.lower()

    @patch("gdsentry.cli.commands.init.ProjectInitializer")
    def test_init_project_success(self, mock_initializer_class):
        """Test successful project initialization."""
        mock_initializer = Mock()
        mock_initializer_class.return_value = mock_initializer
        mock_initializer.initialize.return_value = None

        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir).resolve()  # Use resolved path like the code does
            mock_initializer.get_created_files.return_value = [
                project_dir / "gdsentry.toml",
                project_dir / "tests" / "unit" / "test_example.gd"
            ]

            # Run command
            result = runner.invoke(app, ["init", "project", temp_dir, "--name", "test-project"])

            assert result.exit_code == 0
            assert "Project initialized successfully" in result.stdout
            assert "gdsentry.toml" in result.stdout
            assert "test_example.gd" in result.stdout

            mock_initializer.initialize.assert_called_once_with("test-project", "4.2.2-stable", False)

    @patch("gdsentry.cli.commands.init.ProjectInitializer")
    def test_init_project_default_name(self, mock_initializer_class):
        """Test project initialization with default name from directory."""
        mock_initializer = Mock()
        mock_initializer_class.return_value = mock_initializer
        mock_initializer.initialize.return_value = None
        mock_initializer.get_created_files.return_value = []

        with tempfile.TemporaryDirectory() as temp_dir:
            project_dir = Path(temp_dir) / "my-awesome-project"

            # Run command without --name flag
            result = runner.invoke(app, ["init", "project", str(project_dir)])

            assert result.exit_code == 0
            mock_initializer.initialize.assert_called_once_with("my-awesome-project", "4.2.2-stable", False)

    @patch("gdsentry.cli.commands.init.ProjectInitializer")
    def test_init_project_custom_godot_version(self, mock_initializer_class):
        """Test project initialization with custom Godot version."""
        mock_initializer = Mock()
        mock_initializer_class.return_value = mock_initializer
        mock_initializer.initialize.return_value = None
        mock_initializer.get_created_files.return_value = []

        with tempfile.TemporaryDirectory() as temp_dir:
            # Run command with custom Godot version
            result = runner.invoke(app, [
                "init", "project", temp_dir,
                "--name", "test-project",
                "--godot", "3.5.3-stable"
            ])

            assert result.exit_code == 0
            mock_initializer.initialize.assert_called_once_with("test-project", "3.5.3-stable", False)

    @patch("gdsentry.cli.commands.init.ProjectInitializer")
    def test_init_project_interactive_mode(self, mock_initializer_class):
        """Test project initialization in interactive mode."""
        mock_initializer = Mock()
        mock_initializer_class.return_value = mock_initializer
        mock_initializer.initialize.return_value = None
        mock_initializer.get_created_files.return_value = []

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            expected_name = temp_path.name  # Uses directory name when --name not provided

            # Run command with interactive flag
            result = runner.invoke(app, [
                "init", "project", temp_dir,
                "--interactive"
            ])

            assert result.exit_code == 0
            mock_initializer.initialize.assert_called_once_with(expected_name, "4.2.2-stable", True)

    @patch("gdsentry.cli.commands.init.ProjectInitializer")
    def test_init_project_initialization_error(self, mock_initializer_class):
        """Test project initialization with InitializationError."""
        from gdsentry.templates.init import InitializationError

        mock_initializer_class.side_effect = InitializationError("Test error")

        with tempfile.TemporaryDirectory() as temp_dir:
            # Run command
            result = runner.invoke(app, ["init", "project", temp_dir])

            assert result.exit_code == 1
            assert "Initialization failed: Test error" in result.stdout

    @patch("gdsentry.cli.commands.init.ProjectInitializer")
    def test_init_project_unexpected_error(self, mock_initializer_class):
        """Test project initialization with unexpected error."""
        mock_initializer_class.side_effect = Exception("Unexpected error")

        with tempfile.TemporaryDirectory() as temp_dir:
            # Run command
            result = runner.invoke(app, ["init", "project", temp_dir])

            assert result.exit_code == 1
            assert "Unexpected error: Unexpected error" in result.stdout

    def test_generate_test_help(self):
        """Test init test command help."""
        result = runner.invoke(app, ["init", "test", "--help"])
        assert result.exit_code == 0
        assert "test" in result.stdout.lower()
        assert "Generate a new test file" in result.stdout

    @patch("gdsentry.cli.commands.init.TemplateGenerator")
    def test_generate_test_unit_type(self, mock_generator_class):
        """Test generating a unit test."""
        mock_generator = Mock()
        mock_generator_class.return_value = mock_generator
        mock_test_file = Mock()
        mock_test_file.relative_to.return_value = Path("tests/unit/test_player_movement.gd")
        mock_generator.generate_test.return_value = mock_test_file

        # Run command
        result = runner.invoke(app, ["init", "test", "player_movement", "--type", "unit"])

        assert result.exit_code == 0
        assert "Test generated: tests/unit/test_player_movement.gd" in result.stdout
        mock_generator.generate_test.assert_called_once_with(
            name="player_movement",
            test_type="unit",
            output_dir=None
        )

    @patch("gdsentry.cli.commands.init.TemplateGenerator")
    def test_generate_test_integration_type(self, mock_generator_class):
        """Test generating an integration test."""
        mock_generator = Mock()
        mock_generator_class.return_value = mock_generator
        mock_test_file = Mock()
        mock_test_file.relative_to.return_value = Path("tests/integration/test_user_flow.gd")
        mock_generator.generate_test.return_value = mock_test_file

        # Run command
        result = runner.invoke(app, ["init", "test", "user_flow", "--type", "integration"])

        assert result.exit_code == 0
        assert "integration" in result.stdout
        mock_generator.generate_test.assert_called_once_with(
            name="user_flow",
            test_type="integration",
            output_dir=None
        )

    @patch("gdsentry.cli.commands.init.TemplateGenerator")
    def test_generate_test_custom_output_dir(self, mock_generator_class):
        """Test generating a test with custom output directory."""
        mock_generator = Mock()
        mock_generator_class.return_value = mock_generator
        mock_test_file = Mock()
        mock_test_file.relative_to.return_value = Path("custom/tests/test_custom.gd")
        mock_generator.generate_test.return_value = mock_test_file

        # Run command with custom output directory
        result = runner.invoke(app, [
            "init", "test", "custom",
            "--output", "custom/tests"
        ])

        assert result.exit_code == 0
        mock_generator.generate_test.assert_called_once()
        call_args = mock_generator.generate_test.call_args
        assert call_args[1]["output_dir"] == Path("custom/tests")

    @patch("gdsentry.cli.commands.init.TemplateGenerator")
    def test_generate_test_default_type(self, mock_generator_class):
        """Test generating a test with default type (unit)."""
        mock_generator = Mock()
        mock_generator_class.return_value = mock_generator
        mock_test_file = Mock()
        mock_test_file.relative_to.return_value = Path("tests/unit/test_default.gd")
        mock_generator.generate_test.return_value = mock_test_file

        # Run command without --type flag
        result = runner.invoke(app, ["init", "test", "default"])

        assert result.exit_code == 0
        mock_generator.generate_test.assert_called_once_with(
            name="default",
            test_type="unit",
            output_dir=None
        )

    @patch("gdsentry.cli.commands.init.TemplateGenerator")
    def test_generate_test_template_error(self, mock_generator_class):
        """Test generating a test with TemplateError."""
        from gdsentry.templates.generator import TemplateError

        mock_generator = Mock()
        mock_generator_class.return_value = mock_generator
        mock_generator.generate_test.side_effect = TemplateError("Template not found")

        # Run command
        result = runner.invoke(app, ["init", "test", "failing_test"])

        assert result.exit_code == 1
        assert "Template generation failed: Template not found" in result.stdout

    @patch("gdsentry.cli.commands.init.TemplateGenerator")
    def test_generate_test_unexpected_error(self, mock_generator_class):
        """Test generating a test with unexpected error."""
        mock_generator = Mock()
        mock_generator_class.return_value = mock_generator
        mock_generator.generate_test.side_effect = Exception("Unexpected template error")

        # Run command
        result = runner.invoke(app, ["init", "test", "failing_test"])

        assert result.exit_code == 1
        assert "Unexpected error: Unexpected template error" in result.stdout
