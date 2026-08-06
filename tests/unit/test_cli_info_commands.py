"""Tests for CLI info commands."""

from pathlib import Path
from unittest.mock import Mock, patch

import pytest
from typer.testing import CliRunner

from gdsentry.cli.app import app

runner = CliRunner()


class TestInfoCommands:
    """Test info command group."""

    def test_info_help(self):
        """Test info command help."""
        result = runner.invoke(app, ["info", "--help"])
        assert result.exit_code == 0
        assert "info" in result.stdout.lower()
        assert "Display platform and configuration information" in result.stdout

    def test_info_platform(self):
        """Test info platform command."""
        result = runner.invoke(app, ["info", "platform"])
        assert result.exit_code == 0
        # Should show platform information
        assert any(
            term in result.stdout.lower()
            for term in ["platform", "architecture", "python", "operating system"]
        )

    def test_info_version(self):
        """Test info version command."""
        result = runner.invoke(app, ["info", "version"])
        assert result.exit_code == 0
        assert "GDSentry" in result.stdout
        assert "version" in result.stdout.lower()

    @patch("gdsentry.cli.commands.info.load_config")
    def test_info_config_success(self, mock_load_config):
        """Test info config command with valid config."""
        mock_config = Mock()
        mock_config.project.name = "test-project"
        mock_config.project.godot_version = "4.2.2-stable"
        mock_config.project.project_root = Path("/fake/project")
        mock_config.test.scope.value = "project"
        mock_config.test.filter = "*"
        mock_config.test.timeout = 300
        mock_config.test.parallel = False
        mock_config.test.verbose = False
        mock_config.platform.default_arch.value = "x86_64"
        mock_config.platform.enable_qemu = True
        mock_config.container.registry = "docker.io"
        mock_config.container.base_image = "ubuntu:20.04"
        mock_config.container.auto_build = True
        mock_config.container.cleanup_on_exit = True

        mock_load_config.return_value = mock_config

        result = runner.invoke(app, ["info", "config"])

        assert result.exit_code == 0
        assert "test-project" in result.stdout
        assert "4.2.2-stable" in result.stdout
        assert "x86_64" in result.stdout

    @patch("gdsentry.cli.commands.info.load_config")
    def test_info_config_configuration_error(self, mock_load_config):
        """Test info config command with configuration error."""
        from gdsentry.core.exceptions import ConfigurationError
        mock_load_config.side_effect = ConfigurationError("Config file not found")

        result = runner.invoke(app, ["info", "config"])

        assert result.exit_code == 1
        assert "Configuration error" in result.stdout

    @patch("gdsentry.cli.commands.info.load_config")
    def test_info_config_unexpected_error(self, mock_load_config):
        """Test info config command with unexpected error."""
        mock_load_config.side_effect = Exception("Unexpected error")

        result = runner.invoke(app, ["info", "config"])

        assert result.exit_code == 1
        assert "Error loading configuration" in result.stdout

    def test_info_env(self):
        """Test info env command."""
        result = runner.invoke(app, ["info", "env"])

        assert result.exit_code == 0
        assert "Python" in result.stdout
        assert "GDSentry Version" in result.stdout
        assert "Working Directory" in result.stdout
        # Check that it shows actual environment info (not mocked)
        assert "3.12" in result.stdout  # Should contain actual Python version

    @patch("gdsentry.cli.commands.info.PodmanValidator")
    def test_info_podman_success(self, mock_validator_class):
        """Test info podman command success."""
        mock_validator = Mock()
        mock_validator.validate.return_value = Mock(
            podman_installed=True,
            podman_version="4.8.0",
            machine_exists=True,
            machine_running=True,
            machine_rootful=True,
            can_execute_containers=True,
            warning_messages=[],
            error_messages=[],
            is_valid=True
        )
        mock_validator_class.return_value = mock_validator

        result = runner.invoke(app, ["info", "podman"])

        assert result.exit_code == 0
        assert "Podman environment is properly configured" in result.stdout
        assert "4.8.0" in result.stdout
        assert "Yes" in result.stdout

    @patch("gdsentry.cli.commands.info.PodmanValidator")
    def test_info_podman_with_warnings(self, mock_validator_class):
        """Test info podman command with warnings."""
        mock_validator = Mock()
        mock_validator.validate.return_value = Mock(
            podman_installed=True,
            podman_version="4.8.0",
            machine_exists=False,
            machine_running=False,
            machine_rootful=None,
            can_execute_containers=False,
            warning_messages=["Podman machine not created"],
            error_messages=[],
            is_valid=False
        )
        mock_validator_class.return_value = mock_validator

        result = runner.invoke(app, ["info", "podman"])

        assert result.exit_code == 0  # Warnings don't cause exit
        assert "Podman machine not created" in result.stdout

    @patch("gdsentry.cli.commands.info.PodmanValidator")
    def test_info_podman_with_errors(self, mock_validator_class):
        """Test info podman command with errors."""
        mock_validator = Mock()
        mock_validator.validate.return_value = Mock(
            podman_installed=False,
            podman_version=None,
            machine_exists=False,
            machine_running=False,
            machine_rootful=None,
            can_execute_containers=False,
            warning_messages=[],
            error_messages=["Podman not installed"],
            is_valid=False
        )
        mock_validator_class.return_value = mock_validator

        result = runner.invoke(app, ["info", "podman"])

        assert result.exit_code == 1
        assert "Podman not installed" in result.stdout

    @patch("gdsentry.cli.commands.info.PodmanValidator")
    def test_info_podman_unexpected_error(self, mock_validator_class):
        """Test info podman command with unexpected error."""
        mock_validator_class.side_effect = Exception("Unexpected podman error")

        result = runner.invoke(app, ["info", "podman"])

        assert result.exit_code == 1
        assert "Error validating Podman" in result.stdout

    @patch("gdsentry.cli.commands.info.ResourceMonitor")
    def test_info_resources_no_cleanup(self, mock_monitor_class):
        """Test info resources command without cleanup."""
        mock_monitor = Mock()
        mock_containers = [
            Mock(name="gdsentry-test-123", status="running"),
            Mock(name="gdsentry-old-456", status="exited")
        ]
        mock_images = [
            Mock(repository="gdsentry", tag="latest", size="1.2GB"),
            Mock(repository="ubuntu", tag="20.04", size="72MB")
        ]

        mock_monitor.list_containers.return_value = mock_containers
        mock_monitor.list_images.return_value = mock_images
        mock_monitor_class.return_value = mock_monitor

        result = runner.invoke(app, ["info", "resources"])

        assert result.exit_code == 0
        assert "Containers: 2" in result.stdout
        assert "Images: 2" in result.stdout
        assert "gdsentry-test-123" in result.stdout

    @patch("gdsentry.cli.commands.info.ResourceMonitor")
    def test_info_resources_with_cleanup(self, mock_monitor_class):
        """Test info resources command with cleanup."""
        mock_monitor = Mock()
        mock_monitor.cleanup_stopped_containers.return_value = 3
        mock_monitor.cleanup_dangling_images.return_value = 2
        mock_monitor.list_containers.return_value = []
        mock_monitor.list_images.return_value = []
        mock_monitor_class.return_value = mock_monitor

        result = runner.invoke(app, ["info", "resources", "--cleanup"])

        assert result.exit_code == 0
        assert "Removed 3 stopped containers" in result.stdout
        assert "Removed 2 dangling images" in result.stdout

    @patch("gdsentry.cli.commands.info.ResourceMonitor")
    def test_info_resources_unexpected_error(self, mock_monitor_class):
        """Test info resources command with unexpected error."""
        mock_monitor_class.side_effect = Exception("Resource monitor error")

        result = runner.invoke(app, ["info", "resources"])

        assert result.exit_code == 1
        assert "Error checking resources" in result.stdout

    def test_info_platform_help(self):
        """Test info platform command help."""
        result = runner.invoke(app, ["info", "platform", "--help"])
        assert result.exit_code == 0
        assert "platform" in result.stdout.lower()

    def test_info_version_help(self):
        """Test info version command help."""
        result = runner.invoke(app, ["info", "version", "--help"])
        assert result.exit_code == 0
        assert "version" in result.stdout.lower()

    def test_info_config_help(self):
        """Test info config command help."""
        result = runner.invoke(app, ["info", "config", "--help"])
        assert result.exit_code == 0
        assert "config" in result.stdout.lower()

    def test_info_env_help(self):
        """Test info env command help."""
        result = runner.invoke(app, ["info", "env", "--help"])
        assert result.exit_code == 0
        assert "env" in result.stdout.lower()

    def test_info_podman_help(self):
        """Test info podman command help."""
        result = runner.invoke(app, ["info", "podman", "--help"])
        assert result.exit_code == 0
        assert "podman" in result.stdout.lower()

    def test_info_resources_help(self):
        """Test info resources command help."""
        result = runner.invoke(app, ["info", "resources", "--help"])
        assert result.exit_code == 0
        assert "resources" in result.stdout.lower()
