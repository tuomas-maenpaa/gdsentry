"""Tests for GDSentry configuration system."""

import os
import tempfile
from pathlib import Path

import pytest

from gdsentry.core.config import (
    find_config_file,
    get_default_config,
    load_config,
    load_env_overrides,
    load_toml_config,
    merge_configs,
)
from gdsentry.core.exceptions import ConfigurationError
from gdsentry.core.models import Architecture, GDSentryConfig, ScopeType


class TestConfigurationLoading:
    """Test configuration file loading."""

    def test_load_default_config(self):
        """Test loading default configuration without any files."""
        config = get_default_config()
        assert isinstance(config, GDSentryConfig)
        assert config.project.name == "gdsentry-project"
        assert config.test.scope == ScopeType.PROJECT
        assert config.platform.default_arch == Architecture.AUTO
        assert config.container.registry == "localhost"

    def test_load_toml_config(self, tmp_path: Path):
        """Test loading configuration from TOML file."""
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text(
            """
[project]
name = "test-project"
godot_version = "4.2.2-stable"

[test]
scope = "framework"
timeout = 600
"""
        )

        config_dict = load_toml_config(config_file)
        assert config_dict["project"]["name"] == "test-project"
        assert config_dict["test"]["scope"] == "framework"
        assert config_dict["test"]["timeout"] == 600

    def test_load_toml_config_not_found(self):
        """Test error when TOML file doesn't exist."""
        with pytest.raises(ConfigurationError, match="not found"):
            load_toml_config(Path("/nonexistent/gdsentry.toml"))

    def test_load_toml_config_invalid(self, tmp_path: Path):
        """Test error with invalid TOML."""
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text("invalid toml [[[")

        with pytest.raises(ConfigurationError, match="Invalid TOML"):
            load_toml_config(config_file)

    def test_find_config_file(self, tmp_path: Path):
        """Test finding config file by walking up directory tree."""
        # Create nested directory structure
        nested = tmp_path / "a" / "b" / "c"
        nested.mkdir(parents=True)

        # Place config in parent directory
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text("[project]\nname = 'test'")

        # Should find config from nested directory
        found = find_config_file(nested)
        assert found == config_file

    def test_find_config_file_not_found(self, tmp_path: Path):
        """Test when config file is not found."""
        nested = tmp_path / "a" / "b" / "c"
        nested.mkdir(parents=True)

        found = find_config_file(nested)
        assert found is None


class TestEnvironmentOverrides:
    """Test environment variable configuration overrides."""

    def test_load_env_overrides(self):
        """Test loading configuration from environment variables."""
        os.environ["GDSENTRY_TEST_SCOPE"] = "framework"
        os.environ["GDSENTRY_TEST_VERBOSE"] = "true"
        os.environ["GDSENTRY_TEST_TIMEOUT"] = "600"
        os.environ["GDSENTRY_PLATFORM_DEFAULT_ARCH"] = "x86_64"

        try:
            env_config = load_env_overrides()
            assert env_config["test"]["scope"] == "framework"
            assert env_config["test"]["verbose"] is True
            assert env_config["test"]["timeout"] == 600
            assert env_config["platform"]["default_arch"] == "x86_64"
        finally:
            # Cleanup
            for key in list(os.environ.keys()):
                if key.startswith("GDSENTRY_"):
                    del os.environ[key]

    def test_env_boolean_conversion(self):
        """Test boolean value conversion from environment variables."""
        test_cases = {
            "true": True,
            "True": True,
            "TRUE": True,
            "yes": True,
            "1": True,
            "false": False,
            "False": False,
            "FALSE": False,
            "no": False,
            "0": False,
        }

        for env_value, expected in test_cases.items():
            os.environ["GDSENTRY_TEST_VERBOSE"] = env_value
            try:
                env_config = load_env_overrides()
                assert env_config["test"]["verbose"] == expected
            finally:
                del os.environ["GDSENTRY_TEST_VERBOSE"]


class TestConfigMerging:
    """Test configuration merging logic."""

    def test_merge_configs_simple(self):
        """Test merging simple dictionaries."""
        base = {"a": 1, "b": 2}
        override = {"b": 3, "c": 4}

        result = merge_configs(base, override)
        assert result == {"a": 1, "b": 3, "c": 4}

    def test_merge_configs_nested(self):
        """Test merging nested dictionaries."""
        base = {
            "project": {"name": "base", "version": "1.0"},
            "test": {"scope": "project"},
        }
        override = {
            "project": {"name": "override"},
            "test": {"verbose": True},
        }

        result = merge_configs(base, override)
        assert result["project"]["name"] == "override"
        assert result["project"]["version"] == "1.0"
        assert result["test"]["scope"] == "project"
        assert result["test"]["verbose"] is True


class TestFullConfiguration:
    """Test complete configuration loading with all features."""

    def test_load_config_with_file(self, tmp_path: Path):
        """Test loading configuration from file."""
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text(
            """
[project]
name = "my-game"
godot_version = "4.2.2-stable"

[test]
scope = "project"
timeout = 600
verbose = true
"""
        )

        config = load_config(config_path=config_file, search_parent_dirs=False)
        assert config.project.name == "my-game"
        assert config.project.godot_version == "4.2.2-stable"
        assert config.test.scope == ScopeType.PROJECT
        assert config.test.timeout == 600
        assert config.test.verbose is True

    def test_load_config_with_env_override(self, tmp_path: Path):
        """Test that environment variables override file config."""
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text(
            """
[test]
scope = "project"
"""
        )

        os.environ["GDSENTRY_TEST_SCOPE"] = "framework"
        try:
            config = load_config(config_path=config_file, search_parent_dirs=False)
            # Environment should override file
            assert config.test.scope == ScopeType.FRAMEWORK
        finally:
            del os.environ["GDSENTRY_TEST_SCOPE"]

    def test_load_config_defaults_only(self):
        """Test loading with only default values."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Change to directory with no config file
            original_cwd = Path.cwd()
            os.chdir(tmpdir)
            try:
                config = load_config(search_parent_dirs=False)
                assert config.project.name == "gdsentry-project"
                assert config.test.scope == ScopeType.PROJECT
                assert config.container.registry == "localhost"
            finally:
                os.chdir(original_cwd)

    def test_invalid_config_raises_error(self, tmp_path: Path):
        """Test that invalid configuration raises ConfigurationError."""
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text(
            """
[test]
timeout = -100  # Invalid: must be positive
"""
        )

        with pytest.raises(ConfigurationError, match="Invalid configuration"):
            load_config(config_path=config_file, search_parent_dirs=False)

    def test_registry_must_be_localhost(self, tmp_path: Path):
        """Test that only localhost registry is allowed."""
        config_file = tmp_path / "gdsentry.toml"
        config_file.write_text(
            """
[container]
registry = "docker.io"  # Should be rejected
"""
        )

        with pytest.raises(ConfigurationError, match="localhost"):
            load_config(config_path=config_file, search_parent_dirs=False)


class TestConfigurationModels:
    """Test Pydantic model validation."""

    def test_architecture_enum(self):
        """Test Architecture enum values."""
        assert Architecture.X86_64.value == "x86_64"
        assert Architecture.ARM64.value == "arm64"
        assert Architecture.AUTO.value == "auto"

    def test_test_scope_enum(self):
        """Test TestScope enum values."""
        assert ScopeType.PROJECT.value == "project"
        assert ScopeType.FRAMEWORK.value == "framework"
        assert ScopeType.BOTH.value == "both"

    def test_config_immutability(self):
        """Test that config validates on assignment."""
        config = GDSentryConfig()

        # This should work
        config.test.timeout = 600

        # This should raise validation error
        with pytest.raises(Exception):  # Pydantic ValidationError
            config.test.timeout = -100

