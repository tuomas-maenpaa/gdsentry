"""Tests for container management functionality."""

import pytest
from pathlib import Path

from gdsentry.container.podman import PodmanClient, PodmanError
from gdsentry.container.manager import ContainerManager
from gdsentry.container.builder import ContainerBuilder


class TestPodmanClient:
    """Test Podman client wrapper."""

    def test_podman_client_creation(self):
        """Test that PodmanClient can be created."""
        # Should not raise if Podman is available
        try:
            client = PodmanClient()
            assert client is not None
        except PodmanError as e:
            # Expected if Podman not installed
            pytest.skip(f"Podman not available: {e}")

    def test_image_exists_for_nonexistent_image(self):
        """Test checking for nonexistent image."""
        try:
            client = PodmanClient()
            exists = client.image_exists("nonexistent-image-12345:latest")
            assert exists is False
        except PodmanError:
            pytest.skip("Podman not available")

    def test_list_images(self):
        """Test listing images."""
        try:
            client = PodmanClient()
            images = client.list_images()
            assert isinstance(images, list)
            # May be empty, that's fine
        except PodmanError:
            pytest.skip("Podman not available")

    def test_is_machine_running(self):
        """Test checking machine status."""
        try:
            client = PodmanClient()
            running = client.is_machine_running()
            assert isinstance(running, bool)
        except PodmanError:
            pytest.skip("Podman not available")


class TestContainerManager:
    """Test container lifecycle management."""

    def test_manager_creation(self):
        """Test that ContainerManager can be created."""
        try:
            manager = ContainerManager()
            assert manager is not None
            assert manager.podman is not None
        except PodmanError:
            pytest.skip("Podman not available")

    def test_manager_with_custom_client(self):
        """Test manager with custom Podman client."""
        try:
            client = PodmanClient()
            manager = ContainerManager(podman_client=client)
            assert manager.podman is client
        except PodmanError:
            pytest.skip("Podman not available")


class TestContainerBuilder:
    """Test container image building."""

    def test_builder_creation(self):
        """Test that ContainerBuilder can be created."""
        try:
            builder = ContainerBuilder()
            assert builder is not None
            assert builder.podman is not None
        except PodmanError:
            pytest.skip("Podman not available")

    def test_get_image_name(self):
        """Test image name generation."""
        builder = ContainerBuilder()
        
        name = builder.get_image_name("4.2.2-stable", "arm64")
        assert name == "gdsentry-godot-4.2:arm64"
        
        name = builder.get_image_name("3.5-stable", "x86_64")
        assert name == "gdsentry-godot-3.5:x86_64"

    def test_image_exists(self):
        """Test checking if image exists."""
        try:
            builder = ContainerBuilder()
            # Nonexistent image should return False
            exists = builder.image_exists("nonexistent-image-12345:latest")
            assert exists is False
        except PodmanError:
            pytest.skip("Podman not available")


class TestBuildScripts:
    """Test build script integration."""

    def test_build_scripts_exist(self):
        """Test that build scripts exist in expected locations."""
        project_root = Path.cwd()
        
        # Check for build scripts (Godot containers only, docs use CLI)
        scripts = [
            "scripts/util/build-base-image.sh",
            "scripts/util/build-godot-3.5.sh",
            "scripts/util/build-godot-4.2.sh",
        ]
        
        for script_path in scripts:
            script = project_root / script_path
            assert script.exists(), f"Build script not found: {script}"
            assert script.is_file()


class TestBuildCLI:
    """Test build CLI commands."""

    def test_build_command_import(self):
        """Test that build commands can be imported."""
        from gdsentry.cli.commands import build
        
        assert build.app is not None
        assert hasattr(build, "build_base")
        assert hasattr(build, "build_godot")
        assert hasattr(build, "build_docs")
        assert hasattr(build, "build_all")

