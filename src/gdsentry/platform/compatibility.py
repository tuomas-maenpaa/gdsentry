"""Architecture and Godot version compatibility matrix."""

from typing import List, Union

from gdsentry.platform.detection import Architecture, detect_architecture

# Compatibility matrix: which Godot versions work on which architectures
# Based on Godot's official platform support
ARCHITECTURE_COMPATIBILITY = {
    Architecture.X86_64: [
        "3.5-stable",
        "3.5.1-stable",
        "3.5.2-stable",
        "4.2-stable",
        "4.2.1-stable",
        "4.2.2-stable",
    ],
    Architecture.ARM64: [
        # Godot 3.x does not have official ARM64 support
        "4.2-stable",
        "4.2.1-stable",
        "4.2.2-stable",
    ],
}

# Container platform identifiers for Podman/Docker
CONTAINER_PLATFORMS = {
    Architecture.X86_64: "linux/amd64",
    Architecture.ARM64: "linux/arm64",
}


def is_architecture_compatible(
    architecture: Union[Architecture, str], godot_version: str
) -> bool:
    """
    Check if a Godot version is compatible with an architecture.

    Args:
        architecture: Target architecture (enum or string)
        godot_version: Godot version string

    Returns:
        True if compatible, False otherwise

    Examples:
        >>> is_architecture_compatible("x86_64", "3.5-stable")
        True
        >>> is_architecture_compatible("arm64", "3.5-stable")
        False
    """
    # Convert string to enum if needed
    if isinstance(architecture, str):
        try:
            architecture = Architecture(architecture)
        except ValueError:
            return False

    # Get compatible versions for this architecture
    compatible_versions = ARCHITECTURE_COMPATIBILITY.get(architecture, [])

    # Normalize the version string
    from gdsentry.platform.godot import normalize_version_alias

    normalized = normalize_version_alias(godot_version)

    return normalized in compatible_versions


def is_godot_version_compatible(godot_version: str) -> bool:
    """
    Check if a Godot version is compatible with the current architecture.

    Args:
        godot_version: Godot version string

    Returns:
        True if compatible with current architecture, False otherwise
    """
    current_arch = detect_architecture()
    return is_architecture_compatible(current_arch, godot_version)


def get_compatible_godot_versions(architecture: Union[Architecture, str]) -> List[str]:
    """
    Get all Godot versions compatible with an architecture.

    Args:
        architecture: Target architecture

    Returns:
        List of compatible Godot version strings

    Examples:
        >>> versions = get_compatible_godot_versions("x86_64")
        >>> "4.2.2-stable" in versions
        True
    """
    # Convert string to enum if needed
    if isinstance(architecture, str):
        try:
            architecture = Architecture(architecture)
        except ValueError:
            return []

    return ARCHITECTURE_COMPATIBILITY.get(architecture, []).copy()


def get_container_platform(architecture: Union[Architecture, str]) -> str:
    """
    Get the container platform identifier for an architecture.

    Args:
        architecture: Target architecture

    Returns:
        Platform string for Podman/Docker (e.g., "linux/amd64")

    Raises:
        ValueError: If architecture is not supported

    Examples:
        >>> get_container_platform("x86_64")
        "linux/amd64"
        >>> get_container_platform("arm64")
        "linux/arm64"
    """
    # Convert string to enum if needed
    if isinstance(architecture, str):
        try:
            architecture = Architecture(architecture)
        except ValueError:
            raise ValueError(f"Unsupported architecture: {architecture}")

    platform = CONTAINER_PLATFORMS.get(architecture)
    if platform is None:
        raise ValueError(f"No container platform defined for architecture: {architecture}")

    return platform


def get_recommended_godot_version(architecture: Union[Architecture, str]) -> str:
    """
    Get the recommended Godot version for an architecture.

    Currently returns the latest stable 4.2.x version for all architectures.

    Args:
        architecture: Target architecture

    Returns:
        Recommended Godot version string
    """
    # For now, recommend 4.2.2-stable for all supported architectures
    # as it has the widest compatibility
    if isinstance(architecture, str):
        try:
            architecture = Architecture(architecture)
        except ValueError:
            return "4.2.2-stable"

    # Return latest compatible version
    compatible = get_compatible_godot_versions(architecture)
    if compatible:
        return compatible[-1]  # Last in list is typically newest
    return "4.2.2-stable"


def supports_cross_architecture(
    host_arch: Union[Architecture, str], target_arch: Union[Architecture, str]
) -> bool:
    """
    Check if cross-architecture testing is supported.

    Args:
        host_arch: Host architecture
        target_arch: Target architecture

    Returns:
        True if cross-architecture testing is possible

    Notes:
        - Same architecture: Always supported (native)
        - x86_64 → ARM64: Supported via QEMU emulation
        - ARM64 → x86_64: Supported via Podman VM
    """
    # Convert strings to enums
    if isinstance(host_arch, str):
        try:
            host_arch = Architecture(host_arch)
        except ValueError:
            return False

    if isinstance(target_arch, str):
        try:
            target_arch = Architecture(target_arch)
        except ValueError:
            return False

    # Same architecture: always supported
    if host_arch == target_arch:
        return True

    # Cross-architecture combinations
    # x86_64 → ARM64: QEMU emulation
    # ARM64 → x86_64: Podman VM (Rosetta on macOS)
    if host_arch == Architecture.X86_64 and target_arch == Architecture.ARM64:
        return True
    if host_arch == Architecture.ARM64 and target_arch == Architecture.X86_64:
        return True

    return False

