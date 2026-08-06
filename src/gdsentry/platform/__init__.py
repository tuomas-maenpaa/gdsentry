"""Platform detection and compatibility for GDSentry."""

from gdsentry.platform.compatibility import (
    get_compatible_godot_versions,
    get_container_platform,
    is_architecture_compatible,
    is_godot_version_compatible,
)
from gdsentry.platform.detection import (
    PlatformInfo,
    detect_architecture,
    detect_os,
    detect_platform,
    is_qemu_available,
)
from gdsentry.platform.godot import (
    GodotVersion,
    compare_versions,
    parse_godot_version,
)

__all__ = [
    "PlatformInfo",
    "detect_platform",
    "detect_architecture",
    "detect_os",
    "is_qemu_available",
    "GodotVersion",
    "parse_godot_version",
    "compare_versions",
    "is_architecture_compatible",
    "is_godot_version_compatible",
    "get_compatible_godot_versions",
    "get_container_platform",
]

