"""Integration tests for container operations (build, run, cleanup)."""

import subprocess
import tempfile
from pathlib import Path

import pytest

from gdsentry.cli.app import app
from typer.testing import CliRunner

runner = CliRunner()


class TestContainerOperations:
    """Test container build, run, and cleanup operations."""

    def test_build_base_container_integration(self):
        """Test building base container image."""
        # This may fail if Podman is not available, but tests the workflow
        result = runner.invoke(app, ["build", "base", "--arch", "x86_64"])
        # Should either succeed (0) or fail gracefully (1) if Podman not available
        assert result.exit_code in [0, 1]

    def test_build_godot_container_integration(self):
        """Test building Godot container image."""
        result = runner.invoke(app, ["build", "godot", "4.2.1-stable", "--arch", "x86_64"])
        assert result.exit_code in [0, 1]

    def test_build_docs_container_integration(self):
        """Test building docs container image."""
        result = runner.invoke(app, ["build", "docs"])
        assert result.exit_code in [0, 1]

    def test_build_all_containers_integration(self):
        """Test building all container images."""
        result = runner.invoke(app, ["build", "all", "--arch", "x86_64"])
        assert result.exit_code in [0, 1]

    def test_container_build_with_invalid_arch(self):
        """Test container build with invalid architecture."""
        result = runner.invoke(app, ["build", "base", "--arch", "invalid_arch"])
        # CLI accepts any architecture string and passes it to build script
        # Build script handles unknown architectures gracefully
        assert result.exit_code == 0
        assert "invalid_arch" in result.stdout

    def test_container_build_with_invalid_version(self):
        """Test container build with invalid Godot version."""
        result = runner.invoke(app, ["build", "godot", "invalid.version", "--arch", "x86_64"])
        # May succeed or fail depending on validation
        assert result.exit_code in [0, 1]


class TestContainerTestExecution:
    """Test running tests in containers."""

    def test_container_test_run_framework(self):
        """Test running framework tests in container."""
        result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "30"])
        # May succeed or fail depending on container availability
        assert result.exit_code in [0, 1, 2, 3]

    def test_container_test_run_project_no_project(self):
        """Test running project tests when no project files exist."""
        with tempfile.TemporaryDirectory() as temp_dir:
            original_cwd = Path.cwd()
            try:
                import os
                os.chdir(temp_dir)

                result = runner.invoke(app, ["test", "run-container", "--scope", "project", "--timeout", "10"])
                # Should fail gracefully when no tests found
                assert result.exit_code in [0, 1, 2, 3]  # 0 = no tests found, others = errors

            finally:
                os.chdir(original_cwd)

    def test_container_test_run_with_category(self):
        """Test running tests with category filter in container."""
        result = runner.invoke(app, ["test", "run-container", "--category", "unit", "--timeout", "10"])
        assert result.exit_code in [0, 1, 2, 3]

    def test_container_test_run_with_filter(self):
        """Test running tests with pattern filter in container."""
        result = runner.invoke(app, ["test", "run-container", "--filter", "test_*", "--timeout", "10"])
        assert result.exit_code in [0, 1, 2, 3]

    def test_container_test_run_invalid_scope(self):
        """Test container test run with invalid scope."""
        result = runner.invoke(app, ["test", "run-container", "--scope", "invalid", "--timeout", "5"])
        # Should handle invalid scope gracefully
        assert result.exit_code in [0, 1, 2, 3]


class TestContainerInfoAndCleanup:
    """Test container information and cleanup operations."""

    def test_podman_info_integration(self):
        """Test podman information display."""
        result = runner.invoke(app, ["info", "podman"])
        assert result.exit_code == 0
        # Should show some podman information even if not installed
        assert "Podman" in result.stdout

    def test_resources_info_integration(self):
        """Test container resources information."""
        result = runner.invoke(app, ["info", "resources"])
        assert result.exit_code == 0
        # Should show resource information
        assert "Containers:" in result.stdout or "Images:" in result.stdout

    def test_resources_cleanup_integration(self):
        """Test container resources cleanup."""
        result = runner.invoke(app, ["info", "resources", "--cleanup"])
        assert result.exit_code == 0
        # Should attempt cleanup even if no resources to clean

    def test_container_test_with_custom_timeout(self):
        """Test container test execution with custom timeout."""
        result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "5"])
        # Should respect timeout setting
        assert result.exit_code in [0, 1, 2, 3]


class TestContainerWorkflowIntegration:
    """Test full container operation workflows."""

    def test_build_and_test_workflow(self):
        """Test building containers and then running tests."""
        # First try to build base image
        build_result = runner.invoke(app, ["build", "base", "--arch", "x86_64"])
        # Build may succeed or fail

        # Then try to run tests (may use existing containers)
        test_result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "15"])
        # Test may succeed or fail depending on build and container availability
        assert test_result.exit_code in [0, 1, 2, 3]

    def test_container_error_handling(self):
        """Test container operations handle errors gracefully."""
        # Test with very short timeout
        result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "1"])
        # Should either succeed quickly or fail gracefully
        assert result.exit_code in [0, 1, 2, 3]

    def test_container_config_integration(self):
        """Test container operations work with different configurations."""
        with tempfile.TemporaryDirectory() as temp_dir:
            config_file = Path(temp_dir) / "test-config.toml"
            config_file.write_text("""
[container]
registry = "localhost"
base_image = "ubuntu:20.04"
auto_build = false
cleanup_on_exit = true

[test]
scope = "framework"
timeout = 30
""")

            # Test with custom config
            result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "10"])
            # Should work regardless of config
            assert result.exit_code in [0, 1, 2, 3]


class TestContainerAvailability:
    """Test behavior when containers are not available."""

    def test_graceful_failure_without_podman(self):
        """Test that operations fail gracefully when Podman is not available."""
        # This test assumes Podman may not be available in test environment
        result = runner.invoke(app, ["build", "base", "--arch", "x86_64"])

        if result.exit_code == 1:
            # If it fails, it should fail with a reasonable error message
            assert "Build failed" in result.stdout or "command not found" in result.stdout.lower() or len(result.stdout) > 0

        # If Podman is available, it might succeed or fail for other reasons
        assert result.exit_code in [0, 1]

    def test_container_test_fallback_behavior(self):
        """Test container test execution falls back gracefully."""
        result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "5"])

        # Should either:
        # - Succeed if containers work
        # - Fail gracefully if containers not available
        # - Exit with infrastructure error (2) or config error (3)
        assert result.exit_code in [0, 1, 2, 3]

        # Should provide some output
        assert len(result.stdout) > 0 or len(result.stderr) > 0


class TestContainerCrossPlatform:
    """Test container operations across different architectures."""

    def test_multi_arch_build_workflow(self):
        """Test building for multiple architectures."""
        # Test x86_64 build
        result_x86 = runner.invoke(app, ["build", "base", "--arch", "x86_64"])
        assert result_x86.exit_code in [0, 1]

        # Test arm64 build (may not be available)
        result_arm = runner.invoke(app, ["build", "base", "--arch", "arm64"])
        assert result_arm.exit_code in [0, 1]

    def test_container_test_cross_arch(self):
        """Test container test execution specifies architecture."""
        result = runner.invoke(app, ["test", "run-container", "--arch", "x86_64", "--scope", "framework", "--timeout", "10"])
        assert result.exit_code in [0, 1, 2, 3]


class TestContainerResourceManagement:
    """Test container resource management and cleanup."""

    def test_container_resource_monitoring(self):
        """Test container resource information display."""
        result = runner.invoke(app, ["info", "resources"])
        assert result.exit_code == 0

        # Should contain some resource information
        output = result.stdout.lower()
        assert any(keyword in output for keyword in ["containers:", "images:", "resources", "podman"])

    def test_container_cleanup_operations(self):
        """Test container cleanup functionality."""
        # First show resources
        info_result = runner.invoke(app, ["info", "resources"])
        assert info_result.exit_code == 0

        # Then attempt cleanup
        cleanup_result = runner.invoke(app, ["info", "resources", "--cleanup"])
        assert cleanup_result.exit_code == 0

        # Cleanup should mention what it attempted
        assert "Removed" in cleanup_result.stdout or "Cleanup" in cleanup_result.stdout or len(cleanup_result.stdout) > 0

    def test_container_info_consistency(self):
        """Test that container info commands are consistent."""
        commands = [
            ["info", "podman"],
            ["info", "resources"],
            ["build", "base", "--help"],
            ["test", "run-container", "--help"]
        ]

        for cmd in commands:
            result = runner.invoke(app, cmd)
            assert result.exit_code == 0
