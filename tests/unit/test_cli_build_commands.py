"""Tests for CLI build commands."""

from unittest.mock import Mock, patch

import pytest
from typer.testing import CliRunner

from gdsentry.cli.app import app

runner = CliRunner()


class TestBuildCommands:
    """Test build command group."""

    def test_build_help(self):
        """Test build command help."""
        result = runner.invoke(app, ["build", "--help"])
        assert result.exit_code == 0
        assert "build" in result.stdout.lower()
        assert "Build container images" in result.stdout

    def test_build_base_help(self):
        """Test build base command help."""
        result = runner.invoke(app, ["build", "base", "--help"])
        assert result.exit_code == 0
        assert "base" in result.stdout.lower()

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    @patch("gdsentry.cli.commands.build.detect_architecture")
    def test_build_base_auto_arch(self, mock_detect_arch, mock_builder_class):
        """Test build base with auto architecture detection."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_arch = Mock()
        mock_arch.value = "x86_64"
        mock_detect_arch.return_value = mock_arch

        result = runner.invoke(app, ["build", "base"])

        assert result.exit_code == 0
        assert "Base image built successfully" in result.stdout
        assert "x86_64" in result.stdout
        mock_builder.build_base.assert_called_once_with("x86_64")

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_base_explicit_arch(self, mock_builder_class):
        """Test build base with explicit architecture."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        result = runner.invoke(app, ["build", "base", "--arch", "arm64"])

        assert result.exit_code == 0
        assert "Base image built successfully" in result.stdout
        assert "arm64" in result.stdout
        mock_builder.build_base.assert_called_once_with("arm64")

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_base_error(self, mock_builder_class):
        """Test build base with error."""
        from gdsentry.core.exceptions import ContainerError

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_base.side_effect = ContainerError("Build failed")

        result = runner.invoke(app, ["build", "base", "--arch", "x86_64"])

        assert result.exit_code == 1
        assert "Build failed: Build failed" in result.stdout

    def test_build_godot_help(self):
        """Test build godot command help."""
        result = runner.invoke(app, ["build", "godot", "--help"])
        assert result.exit_code == 0
        assert "godot" in result.stdout.lower()

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    @patch("gdsentry.cli.commands.build.detect_architecture")
    def test_build_godot_auto_arch(self, mock_detect_arch, mock_builder_class):
        """Test build godot with auto architecture detection."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_arch = Mock()
        mock_arch.value = "x86_64"
        mock_detect_arch.return_value = mock_arch

        result = runner.invoke(app, ["build", "godot", "4.2.1-stable"])

        assert result.exit_code == 0
        assert "Godot 4.2.1-stable image built successfully" in result.stdout
        assert "x86_64" in result.stdout
        mock_builder.build_godot.assert_called_once_with("4.2.1-stable", "x86_64")

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_godot_explicit_arch(self, mock_builder_class):
        """Test build godot with explicit architecture."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        result = runner.invoke(app, ["build", "godot", "3.5.2-stable", "--arch", "arm64"])

        assert result.exit_code == 0
        assert "Godot 3.5.2-stable image built successfully" in result.stdout
        assert "arm64" in result.stdout
        mock_builder.build_godot.assert_called_once_with("3.5.2-stable", "arm64")

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_godot_error(self, mock_builder_class):
        """Test build godot with error."""
        from gdsentry.core.exceptions import ContainerError

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_godot.side_effect = ContainerError("Podman not running")

        result = runner.invoke(app, ["build", "godot", "4.2.1-stable"])

        assert result.exit_code == 1
        assert "Build failed: Podman not running" in result.stdout
        assert "Check that the build script exists and Podman is running" in result.stdout

    def test_build_docs_help(self):
        """Test build docs command help."""
        result = runner.invoke(app, ["build", "docs", "--help"])
        assert result.exit_code == 0
        assert "docs" in result.stdout.lower()

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_docs_success(self, mock_builder_class):
        """Test build docs success."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        result = runner.invoke(app, ["build", "docs"])

        assert result.exit_code == 0
        assert "Documentation image built successfully" in result.stdout
        mock_builder.build_docs.assert_called_once()

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_docs_error(self, mock_builder_class):
        """Test build docs with error."""
        from gdsentry.core.exceptions import ContainerError

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_docs.side_effect = ContainerError("Docs build failed")

        result = runner.invoke(app, ["build", "docs"])

        assert result.exit_code == 1
        assert "Build failed: Docs build failed" in result.stdout

    def test_build_all_help(self):
        """Test build all command help."""
        result = runner.invoke(app, ["build", "all", "--help"])
        assert result.exit_code == 0
        assert "all" in result.stdout.lower()

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    @patch("gdsentry.cli.commands.build.detect_architecture")
    def test_build_all_auto_arch(self, mock_detect_arch, mock_builder_class):
        """Test build all with auto architecture detection."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_arch = Mock()
        mock_arch.value = "arm64"
        mock_detect_arch.return_value = mock_arch

        result = runner.invoke(app, ["build", "all"])

        assert result.exit_code == 0
        assert "Building all images for arm64" in result.stdout
        assert "All images built successfully" in result.stdout
        assert "arm64" in result.stdout
        mock_builder.build_all.assert_called_once_with("arm64")

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_all_explicit_arch(self, mock_builder_class):
        """Test build all with explicit architecture."""
        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        result = runner.invoke(app, ["build", "all", "--arch", "x86_64"])

        assert result.exit_code == 0
        assert "Building all images for x86_64" in result.stdout
        assert "All images built successfully" in result.stdout
        mock_builder.build_all.assert_called_once_with("x86_64")

    @patch("gdsentry.cli.commands.build.ContainerBuilder")
    def test_build_all_error(self, mock_builder_class):
        """Test build all with error."""
        from gdsentry.core.exceptions import ContainerError

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_all.side_effect = ContainerError("Build all failed")

        result = runner.invoke(app, ["build", "all", "--arch", "x86_64"])

        assert result.exit_code == 1
        assert "Build failed: Build all failed" in result.stdout
