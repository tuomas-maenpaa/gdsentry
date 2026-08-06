"""Platform and architecture detection for GDSentry."""

import platform
import subprocess
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict

from gdsentry.common.exceptions import PlatformError


class OS(str, Enum):
    """Supported operating systems."""

    MACOS = "macos"
    LINUX = "linux"
    WINDOWS = "windows"
    UNKNOWN = "unknown"


class Architecture(str, Enum):
    """Supported CPU architectures."""

    X86_64 = "x86_64"
    ARM64 = "arm64"
    UNKNOWN = "unknown"


class PlatformInfo(BaseModel):
    """Complete platform information."""

    model_config = ConfigDict(use_enum_values=False)

    os: OS
    architecture: Architecture
    qemu_available: bool
    podman_available: bool
    python_version: str


def detect_os() -> OS:
    """
    Detect the host operating system.

    Returns:
        OS enum value

    Examples:
        >>> os_type = detect_os()
        >>> print(os_type)
        OS.MACOS
    """
    system = platform.system().lower()

    if system == "darwin":
        return OS.MACOS
    elif system == "linux":
        return OS.LINUX
    elif system == "windows":
        return OS.WINDOWS
    else:
        return OS.UNKNOWN


def detect_architecture() -> Architecture:
    """
    Detect the host CPU architecture.

    Returns:
        Architecture enum value

    Notes:
        - On macOS ARM: returns ARM64
        - On macOS Intel: returns X86_64
        - Normalizes various architecture names to standard values
    """
    # Get machine type from platform module
    machine = platform.machine().lower()

    # Normalize architecture names
    if machine in ("x86_64", "amd64", "x64"):
        return Architecture.X86_64
    elif machine in ("arm64", "aarch64"):
        return Architecture.ARM64
    else:
        return Architecture.UNKNOWN


def is_qemu_available() -> bool:
    """
    Check if QEMU is available for cross-architecture emulation.

    Returns:
        True if QEMU is installed and available, False otherwise

    Notes:
        This checks for the presence of qemu-system commands or
        Docker/Podman's built-in QEMU support.
    """
    try:
        # Check for qemu-system-x86_64 or qemu-system-aarch64
        result = subprocess.run(
            ["which", "qemu-system-x86_64"],
            capture_output=True,
            timeout=5,
        )
        if result.returncode == 0:
            return True

        result = subprocess.run(
            ["which", "qemu-system-aarch64"],
            capture_output=True,
            timeout=5,
        )
        if result.returncode == 0:
            return True

        # Check for Podman's QEMU support
        # Podman on macOS uses QEMU for cross-arch by default
        host_os = detect_os()
        if host_os == OS.MACOS:
            # macOS Podman machine typically has QEMU built-in
            result = subprocess.run(
                ["podman", "version"],
                capture_output=True,
                timeout=5,
            )
            if result.returncode == 0:
                return True

        return False

    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def is_podman_available() -> bool:
    """
    Check if Podman is installed and available.

    Returns:
        True if Podman is available, False otherwise
    """
    try:
        result = subprocess.run(
            ["podman", "version"],
            capture_output=True,
            timeout=5,
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def get_python_version() -> str:
    """
    Get the current Python version.

    Returns:
        Python version string (e.g., "3.12.8")
    """
    return platform.python_version()


def detect_platform() -> PlatformInfo:
    """
    Detect complete platform information.

    Returns:
        PlatformInfo object with all platform details

    Raises:
        PlatformError: If platform detection fails

    Examples:
        >>> info = detect_platform()
        >>> print(f"Running on {info.os} {info.architecture}")
        Running on macos arm64
    """
    try:
        return PlatformInfo(
            os=detect_os(),
            architecture=detect_architecture(),
            qemu_available=is_qemu_available(),
            podman_available=is_podman_available(),
            python_version=get_python_version(),
        )
    except Exception as e:
        raise PlatformError(f"Failed to detect platform: {e}") from e


def get_platform_display_name(info: Optional[PlatformInfo] = None) -> str:
    """
    Get a human-readable platform display name.

    Args:
        info: PlatformInfo object (if None, will detect)

    Returns:
        Display string like "macOS ARM64" or "Linux x86_64"

    Examples:
        >>> name = get_platform_display_name()
        >>> print(name)
        macOS ARM64
    """
    if info is None:
        info = detect_platform()

    os_name = {
        OS.MACOS: "macOS",
        OS.LINUX: "Linux",
        OS.WINDOWS: "Windows",
        OS.UNKNOWN: "Unknown OS",
    }.get(info.os, str(info.os))

    arch_name = {
        Architecture.X86_64: "x86_64",
        Architecture.ARM64: "ARM64",
        Architecture.UNKNOWN: "Unknown",
    }.get(info.architecture, str(info.architecture))

    return f"{os_name} {arch_name}"

