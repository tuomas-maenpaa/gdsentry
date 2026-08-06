"""Container image building."""

import os
import subprocess
from pathlib import Path
from typing import Dict, Optional

from gdsentry.container.podman import PodmanClient
from gdsentry.core.exceptions import ContainerError


def _build_safe_environment(extra_env: Optional[Dict[str, str]] = None) -> Dict[str, str]:
    """
    Build a safe environment dictionary for subprocess execution.

    Only includes whitelisted environment variables to prevent information leakage
    and injection attacks.

    Args:
        extra_env: Additional environment variables to include

    Returns:
        Dictionary of safe environment variables
    """
    # Whitelist of safe environment variables
    safe_vars = {
        # Basic system variables needed for shell and utilities
        "PATH",
        "HOME",
        "USER",
        "SHELL",
        "TERM",
        "LANG",
        "LC_ALL",
        "LC_CTYPE",
        # Container-specific variables that may be needed
        "CONTAINER_REGISTRY",
        "REGISTRY_USERNAME",
        "REGISTRY_PASSWORD",
        # Build-specific variables (will be added via extra_env)
        "TARGET_ARCH",
    }

    safe_env = {}
    for var in safe_vars:
        value = os.environ.get(var)
        if value is not None:
            safe_env[var] = value

    # Add any extra environment variables passed in
    if extra_env:
        safe_env.update(extra_env)

    return safe_env


def _get_scripts_dir() -> Path:
    """Get the scripts directory relative to the package location."""
    import gdsentry
    package_dir = Path(gdsentry.__file__).parent.parent.parent  # src/gdsentry -> src -> project root
    scripts_dir = package_dir / "scripts"
    return scripts_dir
from gdsentry.platform.godot import normalize_version_alias


class ContainerBuilder:
    """
    Container image builder.

    Wraps existing bash build scripts and provides
    Python API for image building.
    """

    def __init__(self, podman_client: Optional[PodmanClient] = None):
        """
        Initialize builder.

        Args:
            podman_client: PodmanClient instance (creates new if None)
        """
        self.podman = podman_client or PodmanClient()
        # Auto-detect GDSentry framework root
        from gdsentry.core.config import find_gdsentry_root
        self.gdsentry_root = find_gdsentry_root()

    def build_base(self, architecture: str = "auto") -> None:
        """
        Build base container image.

        Args:
            architecture: Target architecture (auto, x86_64, arm64)

        Raises:
            ContainerError: If build fails
        """
        script = _get_scripts_dir() / "util" / "build-base-image.sh"
        if not script.exists():
            raise ContainerError(f"Build script not found: {script}")

        env = {"TARGET_ARCH": architecture} if architecture != "auto" else {}

        try:
            safe_env = _build_safe_environment(env)
            result = subprocess.run(
                [str(script)],
                env=safe_env,
                capture_output=True,
                text=True,
                timeout=600,  # 10 minutes
            )
            
            if result.returncode != 0:
                raise ContainerError(
                    f"Base image build failed:\n{result.stderr}"
                )
                
        except subprocess.TimeoutExpired:
            raise ContainerError("Base image build timed out after 10 minutes")

    def build_godot(self, version: str, architecture: str = "auto") -> None:
        """
        Build Godot container image.

        Args:
            version: Godot version (3.5, 4.2, etc.)
            architecture: Target architecture

        Raises:
            ContainerError: If build fails
        """
        # Normalize version and extract major.minor
        normalized = normalize_version_alias(version)
        parts = normalized.split("-")[0].split(".")  # Strip stability suffix
        major_minor = ".".join(parts[:2])  # e.g., "4.2"
        
        # Determine script
        script_name = f"build-godot-{major_minor}.sh"
        script = _get_scripts_dir() / "util" / script_name
        
        if not script.exists():
            raise ContainerError(
                f"Build script not found: {script}\n"
                f"Supported versions: 3.5, 4.2"
            )

        env = {"TARGET_ARCH": architecture} if architecture != "auto" else {}

        try:
            safe_env = _build_safe_environment(env)
            result = subprocess.run(
                [str(script)],
                env=safe_env,
                capture_output=True,
                text=True,
                timeout=1800,  # 30 minutes
            )
            
            if result.returncode != 0:
                raise ContainerError(
                    f"Godot {version} image build failed:\n{result.stderr}"
                )
                
        except subprocess.TimeoutExpired:
            raise ContainerError(
                f"Godot {version} image build timed out after 30 minutes"
            )

    def build_all(self, architecture: str = "auto") -> None:
        """
        Build all container images (base + Godot versions).
        
        Note: Documentation building uses CLI directly, not containers.

        Args:
            architecture: Target architecture

        Raises:
            ContainerError: If any build fails
        """
        self.build_base(architecture)
        
        # Build both Godot versions for x86_64, only 4.2 for ARM64
        from gdsentry.platform.compatibility import get_compatible_godot_versions
        from gdsentry.platform.detection import Architecture
        
        arch_enum = Architecture(architecture) if architecture != "auto" else Architecture.ARM64
        versions = get_compatible_godot_versions(arch_enum)
        
        # Map to major.minor
        godot_versions = set()
        for v in versions:
            major_minor = ".".join(v.split(".")[:2])
            godot_versions.add(major_minor)
        
        for version in sorted(godot_versions):
            self.build_godot(version, architecture)

    def image_exists(self, image_name: str) -> bool:
        """
        Check if an image exists.

        Args:
            image_name: Image name

        Returns:
            True if image exists
        """
        return self.podman.image_exists(image_name)

    def get_image_name(self, godot_version: str, architecture: str) -> str:
        """
        Get container image name for Godot version and architecture.

        Args:
            godot_version: Godot version
            architecture: Architecture

        Returns:
            Image name (e.g., "gdsentry-godot-4.2:arm64")
        """
        normalized = normalize_version_alias(godot_version)
        # Extract major.minor, stripping stability suffix
        # E.g., "4.2.2-stable" -> "4.2"
        parts = normalized.split("-")[0].split(".")  # Remove stability first
        major_minor = ".".join(parts[:2])
        return f"gdsentry-godot-{major_minor}:{architecture}"

