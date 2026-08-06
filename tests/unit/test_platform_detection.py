"""Tests for platform detection functionality."""

import platform

import pytest

from gdsentry.platform.detection import (
    Architecture,
    OS,
    PlatformInfo,
    detect_architecture,
    detect_os,
    detect_platform,
    get_platform_display_name,
    get_python_version,
)
from gdsentry.platform.godot import (
    GodotVersion,
    GodotVersionType,
    compare_versions,
    normalize_version_alias,
    parse_godot_version,
)
from gdsentry.platform.compatibility import (
    get_compatible_godot_versions,
    get_container_platform,
    get_recommended_godot_version,
    is_architecture_compatible,
    supports_cross_architecture,
)
from gdsentry.core.exceptions import ValidationError


class TestOSDetection:
    """Test operating system detection."""

    def test_detect_os_returns_valid_enum(self):
        """Test that OS detection returns a valid OS enum."""
        os_type = detect_os()
        assert isinstance(os_type, OS)
        assert os_type in [OS.MACOS, OS.LINUX, OS.WINDOWS, OS.UNKNOWN]

    def test_detect_os_matches_platform(self):
        """Test that OS detection matches Python's platform module."""
        os_type = detect_os()
        system = platform.system().lower()

        if system == "darwin":
            assert os_type == OS.MACOS
        elif system == "linux":
            assert os_type == OS.LINUX
        elif system == "windows":
            assert os_type == OS.WINDOWS


class TestArchitectureDetection:
    """Test CPU architecture detection."""

    def test_detect_architecture_returns_valid_enum(self):
        """Test that architecture detection returns a valid enum."""
        arch = detect_architecture()
        assert isinstance(arch, Architecture)
        assert arch in [Architecture.X86_64, Architecture.ARM64, Architecture.UNKNOWN]

    def test_detect_architecture_matches_current_system(self):
        """Test that architecture detection works on current system."""
        arch = detect_architecture()
        machine = platform.machine().lower()

        if machine in ("x86_64", "amd64", "x64"):
            assert arch == Architecture.X86_64
        elif machine in ("arm64", "aarch64"):
            assert arch == Architecture.ARM64


class TestPlatformDetection:
    """Test complete platform detection."""

    def test_detect_platform_returns_complete_info(self):
        """Test that platform detection returns complete PlatformInfo."""
        info = detect_platform()

        assert isinstance(info, PlatformInfo)
        assert isinstance(info.os, OS)
        assert isinstance(info.architecture, Architecture)
        assert isinstance(info.qemu_available, bool)
        assert isinstance(info.podman_available, bool)
        assert isinstance(info.python_version, str)

    def test_python_version_format(self):
        """Test that Python version is correctly formatted."""
        version = get_python_version()
        assert isinstance(version, str)
        # Should be like "3.12.8"
        parts = version.split(".")
        assert len(parts) >= 2
        assert all(part.isdigit() for part in parts)

    def test_platform_display_name(self):
        """Test platform display name generation."""
        name = get_platform_display_name()
        assert isinstance(name, str)
        # Should contain OS and architecture
        assert any(os_name in name for os_name in ["macOS", "Linux", "Windows"])
        assert any(arch in name for arch in ["x86_64", "ARM64"])


class TestGodotVersionParsing:
    """Test Godot version parsing and comparison."""

    def test_parse_stable_version(self):
        """Test parsing stable version strings."""
        version = parse_godot_version("4.2.2-stable")
        assert version.major == 4
        assert version.minor == 2
        assert version.patch == 2
        assert version.type == GodotVersionType.STABLE

    def test_parse_version_without_patch(self):
        """Test parsing version without patch number."""
        version = parse_godot_version("3.5-stable")
        assert version.major == 3
        assert version.minor == 5
        assert version.patch == 0
        assert version.type == GodotVersionType.STABLE

    def test_parse_version_without_type(self):
        """Test parsing version without type suffix."""
        version = parse_godot_version("4.2")
        assert version.major == 4
        assert version.minor == 2
        assert version.patch == 0
        assert version.type == GodotVersionType.STABLE

    def test_parse_rc_version(self):
        """Test parsing release candidate versions."""
        version = parse_godot_version("4.3-rc.2")
        assert version.major == 4
        assert version.minor == 3
        assert version.type == GodotVersionType.RC
        assert version.build == 2

    def test_parse_beta_version(self):
        """Test parsing beta versions."""
        version = parse_godot_version("4.3-beta.1")
        assert version.major == 4
        assert version.minor == 3
        assert version.type == GodotVersionType.BETA
        assert version.build == 1

    def test_parse_invalid_version_raises_error(self):
        """Test that invalid version strings raise ValidationError."""
        with pytest.raises(ValidationError, match="Invalid Godot version"):
            parse_godot_version("invalid")

        with pytest.raises(ValidationError, match="Invalid Godot version"):
            parse_godot_version("4.x.y")

    def test_version_string_conversion(self):
        """Test converting version back to string."""
        version = parse_godot_version("4.2.2-stable")
        assert str(version) == "4.2.2-stable"

        version = parse_godot_version("3.5-stable")
        assert str(version) == "3.5-stable"

    def test_version_short_string(self):
        """Test short version string without type."""
        version = parse_godot_version("4.2.2-stable")
        assert version.to_short_string() == "4.2.2"

    def test_version_container_tag(self):
        """Test container tag generation."""
        version = parse_godot_version("4.2-stable")
        assert version.to_container_tag("arm64") == "4.2:arm64"
        assert version.to_container_tag("x86_64") == "4.2:x86_64"

    def test_compare_versions_equal(self):
        """Test comparing equal versions."""
        v1 = parse_godot_version("4.2.2-stable")
        v2 = parse_godot_version("4.2.2-stable")
        assert compare_versions(v1, v2) == 0

    def test_compare_versions_less_than(self):
        """Test comparing versions (less than)."""
        v1 = parse_godot_version("4.2.1-stable")
        v2 = parse_godot_version("4.2.2-stable")
        assert compare_versions(v1, v2) == -1

    def test_compare_versions_greater_than(self):
        """Test comparing versions (greater than)."""
        v1 = parse_godot_version("4.3-stable")
        v2 = parse_godot_version("4.2.2-stable")
        assert compare_versions(v1, v2) == 1

    def test_compare_versions_by_type(self):
        """Test that stable > rc > beta."""
        stable = parse_godot_version("4.3-stable")
        rc = parse_godot_version("4.3-rc.1")
        beta = parse_godot_version("4.3-beta.1")

        assert compare_versions(stable, rc) == 1
        assert compare_versions(rc, beta) == 1
        assert compare_versions(stable, beta) == 1

    def test_normalize_version_alias(self):
        """Test version alias normalization."""
        assert normalize_version_alias("3.5") == "3.5-stable"
        assert normalize_version_alias("4.2") == "4.2.2-stable"
        assert normalize_version_alias("4.x") == "4.2.2-stable"
        # Unknown aliases pass through unchanged
        assert normalize_version_alias("5.0") == "5.0"


class TestArchitectureCompatibility:
    """Test architecture and Godot version compatibility."""

    def test_x86_64_supports_godot_3_and_4(self):
        """Test that x86_64 supports both Godot 3.5 and 4.2."""
        assert is_architecture_compatible("x86_64", "3.5-stable")
        assert is_architecture_compatible("x86_64", "4.2.2-stable")

    def test_arm64_only_supports_godot_4(self):
        """Test that ARM64 only supports Godot 4.x."""
        assert not is_architecture_compatible("arm64", "3.5-stable")
        assert is_architecture_compatible("arm64", "4.2.2-stable")

    def test_compatibility_with_string_architecture(self):
        """Test compatibility checks with string architecture."""
        assert is_architecture_compatible("x86_64", "4.2.2-stable")
        assert is_architecture_compatible(Architecture.X86_64, "4.2.2-stable")

    def test_get_compatible_versions(self):
        """Test getting all compatible versions for an architecture."""
        x86_versions = get_compatible_godot_versions("x86_64")
        arm_versions = get_compatible_godot_versions("arm64")

        assert "3.5-stable" in x86_versions
        assert "4.2.2-stable" in x86_versions

        assert "3.5-stable" not in arm_versions
        assert "4.2.2-stable" in arm_versions

    def test_get_container_platform(self):
        """Test container platform identifier mapping."""
        assert get_container_platform("x86_64") == "linux/amd64"
        assert get_container_platform("arm64") == "linux/arm64"
        assert get_container_platform(Architecture.X86_64) == "linux/amd64"

    def test_get_container_platform_invalid_architecture(self):
        """Test that invalid architecture raises ValueError."""
        with pytest.raises(ValueError, match="Unsupported architecture"):
            get_container_platform("invalid")

    def test_get_recommended_version(self):
        """Test getting recommended Godot version."""
        # Should recommend 4.2.2-stable for both architectures
        x86_rec = get_recommended_godot_version("x86_64")
        arm_rec = get_recommended_godot_version("arm64")

        assert "4.2" in x86_rec
        assert "4.2" in arm_rec


class TestCrossArchitectureSupport:
    """Test cross-architecture testing support detection."""

    def test_same_architecture_is_supported(self):
        """Test that same architecture is always supported."""
        assert supports_cross_architecture("x86_64", "x86_64")
        assert supports_cross_architecture("arm64", "arm64")

    def test_x86_to_arm_is_supported(self):
        """Test that x86_64 → ARM64 is supported (QEMU)."""
        assert supports_cross_architecture("x86_64", "arm64")

    def test_arm_to_x86_is_supported(self):
        """Test that ARM64 → x86_64 is supported (VM)."""
        assert supports_cross_architecture("arm64", "x86_64")

    def test_cross_architecture_with_enums(self):
        """Test cross-architecture support with Architecture enums."""
        assert supports_cross_architecture(
            Architecture.X86_64, Architecture.ARM64
        )
        assert supports_cross_architecture(
            Architecture.ARM64, Architecture.X86_64
        )

    def test_invalid_architecture_returns_false(self):
        """Test that invalid architectures return False."""
        assert not supports_cross_architecture("invalid", "x86_64")
        assert not supports_cross_architecture("x86_64", "invalid")


class TestGodotVersionModel:
    """Test GodotVersion Pydantic model."""

    def test_version_validation_positive_numbers(self):
        """Test that version numbers must be non-negative."""
        with pytest.raises(ValueError):
            GodotVersion(major=-1, minor=2, patch=0)

        with pytest.raises(ValueError):
            GodotVersion(major=4, minor=-1, patch=0)

    def test_version_model_creation(self):
        """Test creating GodotVersion model directly."""
        version = GodotVersion(
            major=4,
            minor=2,
            patch=2,
            type=GodotVersionType.STABLE,
        )

        assert version.major == 4
        assert version.minor == 2
        assert version.patch == 2
        assert version.type == GodotVersionType.STABLE

    def test_version_parse_class_method(self):
        """Test GodotVersion.parse() class method."""
        version = GodotVersion.parse("4.2.2-stable")
        assert isinstance(version, GodotVersion)
        assert version.major == 4
        assert version.minor == 2

