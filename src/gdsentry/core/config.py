"""Configuration loading and management for GDSentry."""

import os
import sys
from pathlib import Path
from typing import Any, Dict, Optional

if sys.version_info < (3, 11):
    import tomli as tomllib
else:
    import tomllib

import yaml
from pydantic import ValidationError as PydanticValidationError

from gdsentry.core.exceptions import ConfigurationError
from gdsentry.core.models import GDSentryConfig

# Process-level configuration cache to avoid repeated file I/O
_config_cache: Dict[str, GDSentryConfig] = {}


def find_gdsentry_root(start_dir: Optional[Path] = None) -> Path:
    """
    Find the GDSentry framework root directory.
    
    Searches for directory named "gdsentry" containing the framework structure
    (src/gdsentry/ package and tests/framework/gdsentry-self-test.sh).
    
    Args:
        start_dir: Starting directory (defaults to current working directory)
        
    Returns:
        Path to GDSentry framework root directory
    """
    if start_dir is None:
        start_dir = Path.cwd()
    
    current = start_dir.resolve()
    
    # Walk up the directory tree
    while True:
        # Check if current directory is named "gdsentry" and has framework structure
        if current.name == "gdsentry":
            self_test_script = current / "tests" / "framework" / "gdsentry-self-test.sh"
            if self_test_script.exists():
                return current
        
        # Check if current directory contains "gdsentry" subdirectory
        gdsentry_subdir = current / "gdsentry"
        if gdsentry_subdir.exists():
            self_test_script = gdsentry_subdir / "tests" / "framework" / "gdsentry-self-test.sh"
            if self_test_script.exists():
                return gdsentry_subdir
        
        # Check if we've reached the root
        parent = current.parent
        if parent == current:
            break
        current = parent
    
    # Default: assume current directory is gdsentry root
    return Path.cwd()


def find_game_project_root(gdsentry_root: Path) -> Optional[Path]:
    """
    Find the Godot game project root directory.
    
    Looks for directory containing project.godot file, typically parent of gdsentry/.
    
    Args:
        gdsentry_root: GDSentry framework root directory
        
    Returns:
        Path to game project root if found, None if in standalone GDSentry dev mode
    """
    # Check if parent directory has project.godot
    parent = gdsentry_root.parent
    if parent != gdsentry_root:  # Not at filesystem root
        if (parent / "project.godot").exists():
            return parent
    
    # Check if gdsentry_root itself has project.godot (GDSentry dev workspace)
    if (gdsentry_root / "project.godot").exists():
        # This is GDSentry dev workspace, no separate game project
        return None
    
    return None


def find_project_root(start_dir: Optional[Path] = None) -> Optional[Path]:
    """
    DEPRECATED: Use find_gdsentry_root() instead.
    
    Find the GDSentry project root by walking up the directory tree.

    Args:
        start_dir: Starting directory (defaults to current working directory)

    Returns:
        Path to project root (directory containing gdsentry.toml) if found, None otherwise
    """
    config_file = find_config_file(start_dir)
    return config_file.parent if config_file else None


def find_config_file(start_dir: Optional[Path] = None) -> Optional[Path]:
    """
    Find gdsentry.toml by walking up the directory tree.

    Args:
        start_dir: Starting directory (defaults to current working directory)

    Returns:
        Path to gdsentry.toml if found, None otherwise
    """
    if start_dir is None:
        start_dir = Path.cwd()

    current = start_dir.resolve()

    # Walk up the directory tree
    while True:
        config_file = current / "gdsentry.toml"
        if config_file.exists():
            return config_file

        # Check if we've reached the root
        parent = current.parent
        if parent == current:
            break
        current = parent

    return None


def load_toml_config(config_path: Path) -> Dict[str, Any]:
    """
    Load configuration from TOML file.

    Args:
        config_path: Path to gdsentry.toml

    Returns:
        Dictionary of configuration values

    Raises:
        ConfigurationError: If file cannot be read or parsed
    """
    try:
        with open(config_path, "rb") as f:
            return tomllib.load(f)
    except FileNotFoundError:
        raise ConfigurationError(f"Configuration file not found: {config_path}")
    except tomllib.TOMLDecodeError as e:
        raise ConfigurationError(f"Invalid TOML in {config_path}: {e}")
    except Exception as e:
        raise ConfigurationError(f"Error reading {config_path}: {e}")


def load_yaml_config(config_path: Path) -> Dict[str, Any]:
    """
    Load configuration from YAML file.

    Args:
        config_path: Path to gdsentry.yml

    Returns:
        Dictionary of configuration values

    Raises:
        ConfigurationError: If file cannot be read or parsed
    """
    try:
        with open(config_path, "r") as f:
            return yaml.safe_load(f) or {}
    except FileNotFoundError:
        raise ConfigurationError(f"Configuration file not found: {config_path}")
    except yaml.YAMLError as e:
        raise ConfigurationError(f"Invalid YAML in {config_path}: {e}")
    except Exception as e:
        raise ConfigurationError(f"Error reading {config_path}: {e}")


def load_env_overrides() -> Dict[str, Any]:
    """
    Load configuration overrides from environment variables.

    Environment variables follow the pattern: GDSENTRY_<SECTION>_<KEY>
    For example: GDSENTRY_TEST_SCOPE=framework

    Returns:
        Dictionary of configuration overrides
    """
    env_config: Dict[str, Any] = {}

    for key, value in os.environ.items():
        if not key.startswith("GDSENTRY_"):
            continue

        # Remove GDSENTRY_ prefix and split into parts
        parts = key[9:].lower().split("_", 1)
        if len(parts) != 2:
            continue

        section, setting = parts

        # Initialize section if needed
        if section not in env_config:
            env_config[section] = {}

        # Convert string values to appropriate types
        if value.lower() in ("true", "yes", "1"):
            env_config[section][setting] = True
        elif value.lower() in ("false", "no", "0"):
            env_config[section][setting] = False
        elif value.isdigit():
            env_config[section][setting] = int(value)
        else:
            env_config[section][setting] = value

    return env_config


def merge_configs(base: Dict[str, Any], override: Dict[str, Any]) -> Dict[str, Any]:
    """
    Deep merge two configuration dictionaries.

    Args:
        base: Base configuration
        override: Override configuration

    Returns:
        Merged configuration
    """
    result = base.copy()

    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = merge_configs(result[key], value)
        else:
            result[key] = value

    return result


def load_config(
    config_path: Optional[Path] = None,
    search_parent_dirs: bool = True,
) -> GDSentryConfig:
    """
    Load GDSentry configuration with cascading priority.

    Uses process-level caching to avoid repeated file I/O for the same configuration.

    Priority (highest to lowest):
    1. Environment variables (GDSENTRY_*)
    2. Specified config file or discovered gdsentry.toml
    3. Default values

    Args:
        config_path: Explicit path to config file (TOML or YAML)
        search_parent_dirs: Search parent directories for config file

    Returns:
        Validated GDSentryConfig object

    Raises:
        ConfigurationError: If configuration is invalid
    """
    # Create cache key based on parameters
    cache_key = f"{config_path}:{search_parent_dirs}"

    # Return cached config if available
    if cache_key in _config_cache:
        return _config_cache[cache_key]
    config_dict: Dict[str, Any] = {}

    # Step 1: Try to load from file
    if config_path is not None:
        # Explicit path provided
        if not config_path.exists():
            raise ConfigurationError(f"Configuration file not found: {config_path}")

        if config_path.suffix == ".toml":
            config_dict = load_toml_config(config_path)
        elif config_path.suffix in (".yml", ".yaml"):
            config_dict = load_yaml_config(config_path)
        else:
            raise ConfigurationError(
                f"Unsupported config file type: {config_path.suffix}. "
                "Supported: .toml, .yml, .yaml"
            )
    elif search_parent_dirs:
        # Search for gdsentry.toml
        found_config = find_config_file()
        if found_config is not None:
            config_dict = load_toml_config(found_config)

    # Step 2: Merge with environment variables
    env_overrides = load_env_overrides()
    if env_overrides:
        config_dict = merge_configs(config_dict, env_overrides)

    # Step 3: Auto-detect roots if not explicitly set
    if "project" not in config_dict:
        config_dict["project"] = {}
    
    project_dict = config_dict["project"]
    
    # Auto-detect gdsentry_root if not set
    if "gdsentry_root" not in project_dict:
        # Check for legacy project_root
        if "project_root" in project_dict:
            # Map legacy project_root to gdsentry_root for backward compatibility
            project_dict["gdsentry_root"] = project_dict["project_root"]
        else:
            # Auto-detect
            project_dict["gdsentry_root"] = str(find_gdsentry_root())
    
    # Auto-detect game_project_root if not set
    if "game_project_root" not in project_dict:
        gdsentry_root = Path(project_dict["gdsentry_root"])
        detected_game_root = find_game_project_root(gdsentry_root)
        if detected_game_root:
            project_dict["game_project_root"] = str(detected_game_root)
    
    # Step 4: Validate and create config object
    try:
        config = GDSentryConfig(**config_dict)
        # Cache the loaded configuration
        _config_cache[cache_key] = config
        return config
    except PydanticValidationError as e:
        raise ConfigurationError(f"Invalid configuration: {e}")


def get_default_config() -> GDSentryConfig:
    """
    Get default configuration without loading from files.

    Returns:
        GDSentryConfig with all default values
    """
    return GDSentryConfig()


def clear_config_cache() -> None:
    """
    Clear the configuration cache.

    Useful for testing or when configuration changes during development.
    """
    _config_cache.clear()

