"""Godot version parsing and comparison utilities."""

import re
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator

from gdsentry.common.exceptions import ValidationError


class GodotVersionType(str, Enum):
    """Godot version stability type."""

    STABLE = "stable"
    RC = "rc"
    BETA = "beta"
    ALPHA = "alpha"
    DEV = "dev"


class GodotVersion(BaseModel):
    """
    Structured Godot version information.

    Examples:
        >>> v = GodotVersion.parse("4.2.2-stable")
        >>> print(f"{v.major}.{v.minor}.{v.patch}-{v.type}")
        4.2.2-stable
    """

    major: int = Field(..., description="Major version number")
    minor: int = Field(..., description="Minor version number")
    patch: int = Field(default=0, description="Patch version number")
    type: GodotVersionType = Field(
        default=GodotVersionType.STABLE, description="Version type"
    )
    build: Optional[int] = Field(default=None, description="Build number (for rc/beta)")

    @field_validator("major", "minor", "patch")
    @classmethod
    def validate_version_numbers(cls, v: int) -> int:
        """Ensure version numbers are non-negative."""
        if v < 0:
            raise ValueError("Version numbers must be non-negative")
        return v

    def __str__(self) -> str:
        """String representation of version."""
        version = f"{self.major}.{self.minor}"
        if self.patch > 0:
            version += f".{self.patch}"
        if self.type != GodotVersionType.STABLE:
            version += f"-{self.type.value}"
            if self.build is not None:
                version += f".{self.build}"
        elif self.type == GodotVersionType.STABLE:
            version += "-stable"
        return version

    def to_short_string(self) -> str:
        """Short version string without type suffix."""
        version = f"{self.major}.{self.minor}"
        if self.patch > 0:
            version += f".{self.patch}"
        return version

    def to_container_tag(self, architecture: str) -> str:
        """
        Convert to container image tag.

        Args:
            architecture: Target architecture (x86_64, arm64)

        Returns:
            Container tag like "4.2:arm64" or "3.5:x86_64"
        """
        return f"{self.major}.{self.minor}:{architecture}"

    @classmethod
    def parse(cls, version_string: str) -> "GodotVersion":
        """
        Parse a Godot version string.

        Args:
            version_string: Version string (e.g., "4.2.2-stable", "3.5", "4.3-rc.2")

        Returns:
            GodotVersion object

        Raises:
            ValidationError: If version string is invalid

        Examples:
            >>> v = GodotVersion.parse("4.2.2-stable")
            >>> v.major, v.minor, v.patch
            (4, 2, 2)
        """
        return parse_godot_version(version_string)

    model_config = ConfigDict(use_enum_values=False)


def parse_godot_version(version_string: str) -> GodotVersion:
    """
    Parse a Godot version string into structured components.

    Supports formats:
        - "4.2.2-stable"
        - "4.2-stable"
        - "3.5"
        - "4.3-rc.2"
        - "4.3-beta.1"

    Args:
        version_string: Version string to parse

    Returns:
        GodotVersion object

    Raises:
        ValidationError: If version string is invalid
    """
    # Clean up input
    version_string = version_string.strip()

    # Regular expression for parsing
    # Matches: major.minor[.patch][-type[.build]]
    pattern = r"^(\d+)\.(\d+)(?:\.(\d+))?(?:-(stable|rc|beta|alpha|dev)(?:\.(\d+))?)?$"

    match = re.match(pattern, version_string, re.IGNORECASE)
    if not match:
        raise ValidationError(
            f"Invalid Godot version format: '{version_string}'. "
            "Expected format: 'major.minor[.patch][-type[.build]]' "
            "(e.g., '4.2.2-stable', '3.5', '4.3-rc.2')"
        )

    major = int(match.group(1))
    minor = int(match.group(2))
    patch = int(match.group(3)) if match.group(3) else 0
    type_str = match.group(4).lower() if match.group(4) else "stable"
    build = int(match.group(5)) if match.group(5) else None

    # Convert type string to enum
    try:
        version_type = GodotVersionType(type_str)
    except ValueError:
        raise ValidationError(f"Unknown version type: '{type_str}'")

    return GodotVersion(
        major=major,
        minor=minor,
        patch=patch,
        type=version_type,
        build=build,
    )


def compare_versions(v1: GodotVersion, v2: GodotVersion) -> int:
    """
    Compare two Godot versions.

    Args:
        v1: First version
        v2: Second version

    Returns:
        -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2

    Examples:
        >>> v1 = GodotVersion.parse("4.2.1-stable")
        >>> v2 = GodotVersion.parse("4.2.2-stable")
        >>> compare_versions(v1, v2)
        -1
    """
    # Compare major, minor, patch
    version_tuple_1 = (v1.major, v1.minor, v1.patch)
    version_tuple_2 = (v2.major, v2.minor, v2.patch)

    if version_tuple_1 < version_tuple_2:
        return -1
    elif version_tuple_1 > version_tuple_2:
        return 1

    # Same version numbers, compare type
    # Stability order: stable > rc > beta > alpha > dev
    type_order = {
        GodotVersionType.STABLE: 4,
        GodotVersionType.RC: 3,
        GodotVersionType.BETA: 2,
        GodotVersionType.ALPHA: 1,
        GodotVersionType.DEV: 0,
    }

    type1_order = type_order.get(v1.type, 0)
    type2_order = type_order.get(v2.type, 0)

    if type1_order < type2_order:
        return -1
    elif type1_order > type2_order:
        return 1

    # Same type, compare build numbers
    build1 = v1.build or 0
    build2 = v2.build or 0

    if build1 < build2:
        return -1
    elif build1 > build2:
        return 1

    return 0


def normalize_version_alias(version: str) -> str:
    """
    Normalize version aliases to full version strings.

    Args:
        version: Version string or alias

    Returns:
        Normalized version string

    Examples:
        >>> normalize_version_alias("3.5")
        "3.5-stable"
        >>> normalize_version_alias("4.2")
        "4.2.2-stable"
    """
    # Version aliases mapping
    aliases = {
        "3.5": "3.5-stable",
        "3.5.0": "3.5-stable",
        "3.5.1": "3.5.1-stable",
        "3.5.2": "3.5.2-stable",
        "4.2": "4.2.2-stable",
        "4.2.0": "4.2-stable",
        "4.2.1": "4.2.1-stable",
        "4.2.2": "4.2.2-stable",
        "4.x": "4.2.2-stable",
    }

    return aliases.get(version, version)

