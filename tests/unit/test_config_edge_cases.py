"""Tests for configuration loading edge cases."""

import os
import tempfile
from pathlib import Path
from unittest.mock import Mock, patch

import pytest

from gdsentry.core.config import (
    ConfigurationError,
    find_config_file,
    load_config,
    load_env_overrides,
    load_toml_config,
    load_yaml_config,
)
from gdsentry.core.models import GDSentryConfig


class TestConfigFileNotFound:
    """Test configuration loading when files don't exist."""

    def test_load_config_explicit_file_not_found(self):
        """Test loading config with explicit non-existent file."""
        with pytest.raises(ConfigurationError, match="Configuration file not found"):
            load_config(config_path=Path("/nonexistent/gdsentry.toml"))

    def test_load_config_explicit_yaml_file_not_found(self):
        """Test loading config with explicit non-existent YAML file."""
        with pytest.raises(ConfigurationError, match="Configuration file not found"):
            load_config(config_path=Path("/nonexistent/gdsentry.yml"))

    def test_load_config_no_file_found_in_search(self):
        """Test loading config when no file found in directory search."""
        with tempfile.TemporaryDirectory() as temp_dir:
            os.chdir(temp_dir)
            # Should return default config without error
            config = load_config()
            assert isinstance(config, GDSentryConfig)

    def test_find_config_file_no_config_in_tree(self):
        """Test finding config file when none exists in directory tree."""
        with tempfile.TemporaryDirectory() as temp_dir:
            result = find_config_file(Path(temp_dir))
            assert result is None


class TestConfigFileFormatErrors:
    """Test configuration loading with invalid file formats."""

    def test_load_toml_invalid_syntax(self):
        """Test loading TOML file with invalid syntax."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write("invalid [toml syntax {{{")
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Invalid TOML"):
                    load_toml_config(Path(f.name))
            finally:
                os.unlink(f.name)

    def test_load_yaml_invalid_syntax(self):
        """Test loading YAML file with invalid syntax."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".yml", delete=False) as f:
            f.write("invalid: yaml: syntax: {{{")
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Invalid YAML"):
                    load_yaml_config(Path(f.name))
            finally:
                os.unlink(f.name)

    def test_load_config_unsupported_file_extension(self):
        """Test loading config with unsupported file extension."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
            f.write('{"test": "data"}')
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Unsupported config file type"):
                    load_config(config_path=Path(f.name))
            finally:
                os.unlink(f.name)


class TestConfigFilePermissionErrors:
    """Test configuration loading with permission issues."""

    def test_load_toml_permission_denied(self):
        """Test loading TOML file with permission denied."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write('[project]\nname = "test"')
            f.flush()

            try:
                # Remove read permission
                os.chmod(f.name, 0o000)
                with pytest.raises(ConfigurationError, match="Error reading"):
                    load_toml_config(Path(f.name))
            finally:
                # Restore permission for cleanup
                os.chmod(f.name, 0o644)
                os.unlink(f.name)

    def test_load_yaml_permission_denied(self):
        """Test loading YAML file with permission denied."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".yml", delete=False) as f:
            f.write('project:\n  name: test')
            f.flush()

            try:
                # Remove read permission
                os.chmod(f.name, 0o000)
                with pytest.raises(ConfigurationError, match="Error reading"):
                    load_yaml_config(Path(f.name))
            finally:
                # Restore permission for cleanup
                os.chmod(f.name, 0o644)
                os.unlink(f.name)


class TestConfigValidationErrors:
    """Test configuration validation errors."""

    def test_load_config_invalid_project_name(self):
        """Test loading config with invalid project name."""
        config_content = """
[project]
name = 123  # Should be a string
godot_version = "4.2.2-stable"
"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write(config_content)
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Invalid configuration"):
                    load_config(config_path=Path(f.name))
            finally:
                os.unlink(f.name)

    def test_load_config_invalid_type(self):
        """Test loading config with invalid field type."""
        config_content = """
[project]
name = 123  # Name should be a string
godot_version = "4.2.2-stable"
"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write(config_content)
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Invalid configuration"):
                    load_config(config_path=Path(f.name))
            finally:
                os.unlink(f.name)

    def test_load_config_invalid_test_scope(self):
        """Test loading config with invalid test scope."""
        config_content = """
[project]
name = "test-project"
godot_version = "4.2.2-stable"

[test]
scope = "invalid_scope"
"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write(config_content)
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Invalid configuration"):
                    load_config(config_path=Path(f.name))
            finally:
                os.unlink(f.name)

    def test_load_config_invalid_godot_version(self):
        """Test loading config with invalid Godot version format."""
        config_content = """
[project]
name = "test-project"
godot_version = 4.2  # Should be a string
"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write(config_content)
            f.flush()

            try:
                with pytest.raises(ConfigurationError, match="Invalid configuration"):
                    load_config(config_path=Path(f.name))
            finally:
                os.unlink(f.name)


class TestConfigEnvironmentOverrides:
    """Test configuration loading with environment variable overrides."""

    @patch.dict(os.environ, {"GDSENTRY_PROJECT_NAME": "env-project"})
    def test_load_config_env_override(self):
        """Test loading config with environment variable override."""
        config_content = """
[project]
name = "file-project"
godot_version = "4.2.2-stable"
"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write(config_content)
            f.flush()

            try:
                config = load_config(config_path=Path(f.name))
                assert config.project.name == "env-project"  # Should be overridden
            finally:
                os.unlink(f.name)

    @patch.dict(os.environ, {"GDSENTRY_INVALID_VAR": "value"})
    def test_load_config_invalid_env_var(self):
        """Test loading config with invalid environment variable."""
        # Invalid env vars should be ignored, not cause errors
        config = load_config(search_parent_dirs=False)
        assert isinstance(config, GDSentryConfig)

    def test_load_env_overrides_empty(self):
        """Test loading environment overrides when none are set."""
        with patch.dict(os.environ, {}, clear=True):
            overrides = load_env_overrides()
            assert overrides == {}

    @patch.dict(os.environ, {"GDSENTRY_PROJECT_NAME": "test", "GDSENTRY_TEST_SCOPE": "framework"})
    def test_load_env_overrides_multiple(self):
        """Test loading multiple environment variable overrides."""
        overrides = load_env_overrides()
        assert "project" in overrides
        assert overrides["project"]["name"] == "test"
        assert "test" in overrides
        assert overrides["test"]["scope"] == "framework"


class TestConfigFileDiscovery:
    """Test configuration file discovery in directory tree."""

    def test_find_config_file_in_current_dir(self):
        """Test finding config file in current directory."""
        with tempfile.TemporaryDirectory() as temp_dir:
            config_path = Path(temp_dir) / "gdsentry.toml"
            config_path.write_text('[project]\nname = "test"')

            result = find_config_file(Path(temp_dir))
            assert result.resolve() == config_path.resolve()

    def test_find_config_file_in_parent_dir(self):
        """Test finding config file in parent directory."""
        with tempfile.TemporaryDirectory() as temp_dir:
            # Create config in root
            config_path = Path(temp_dir) / "gdsentry.toml"
            config_path.write_text('[project]\nname = "test"')

            # Create subdirectory
            sub_dir = Path(temp_dir) / "subdir"
            sub_dir.mkdir()

            result = find_config_file(sub_dir)
            assert result.resolve() == config_path.resolve()

    def test_find_config_file_not_found(self):
        """Test finding config file when none exists."""
        with tempfile.TemporaryDirectory() as temp_dir:
            result = find_config_file(Path(temp_dir))
            assert result is None

    def test_find_config_file_start_dir_none(self):
        """Test finding config file with start_dir=None."""
        with tempfile.TemporaryDirectory() as temp_dir:
            result = find_config_file(Path(temp_dir))
            assert result is None


class TestConfigMergeAndValidation:
    """Test configuration merging and final validation."""

    def test_load_config_toml_and_env_merge(self):
        """Test loading config that merges TOML file and environment variables."""
        config_content = """
[project]
name = "file-project"
godot_version = "4.2.2-stable"

[test]
scope = "project"
"""

        with patch.dict(os.environ, {"GDSENTRY_PROJECT_NAME": "env-project"}):
            with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
                f.write(config_content)
                f.flush()

                try:
                    config = load_config(config_path=Path(f.name))
                    assert config.project.name == "env-project"  # Env override
                    assert config.project.godot_version == "4.2.2-stable"  # From file
                    assert config.test.scope.value == "project"  # From file
                finally:
                    os.unlink(f.name)

    def test_load_config_yaml_support(self):
        """Test loading config from YAML file."""
        config_content = """
project:
  name: "yaml-project"
  godot_version: "4.2.2-stable"

test:
  scope: "framework"
"""

        with tempfile.NamedTemporaryFile(mode="w", suffix=".yml", delete=False) as f:
            f.write(config_content)
            f.flush()

            try:
                config = load_config(config_path=Path(f.name))
                assert config.project.name == "yaml-project"
                assert config.project.godot_version == "4.2.2-stable"
                assert config.test.scope.value == "framework"
            finally:
                os.unlink(f.name)


class TestConfigErrorMessages:
    """Test that configuration errors provide helpful messages."""

    def test_config_error_includes_context(self):
        """Test that configuration errors include helpful context."""
        try:
            load_config(config_path=Path("/nonexistent/file.toml"))
        except ConfigurationError as e:
            assert "Configuration file not found" in str(e)
            assert "/nonexistent/file.toml" in str(e)

    def test_toml_error_includes_file_path(self):
        """Test that TOML errors include the file path."""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write("invalid [toml {{{")
            f.flush()

            try:
                load_toml_config(Path(f.name))
            except ConfigurationError as e:
                assert f.name in str(e)
                assert "Invalid TOML" in str(e)
            finally:
                os.unlink(f.name)
