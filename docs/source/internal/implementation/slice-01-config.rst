Slice 1: Project Structure & Configuration
==========================================

.. note::
   **Status**: ✅ Complete
   **Dependencies**: None (Foundation)
   **Provides**: Configuration system, models, exceptions for all other slices

Purpose
=======

Establish the foundation for GDSentry 2.0:

- Project structure (src layout)
- Unified conda environment
- Configuration loading system (TOML/YAML/env)
- Pydantic data models
- Custom exception hierarchy
- Self-tests for configuration

Files Created
==============

Core Python Package

```
src/gdsentry/
├── __init__.py                  # Package exports, version
├── __version__.py               # Version constants
└── core/
    ├── __init__.py              # Core exports
    ├── config.py                # Configuration loader
    ├── models.py                # Pydantic models
    └── exceptions.py            # Exception hierarchy
```

### Configuration & Environment

```
environment.yml                  # Unified conda environment
pyproject.toml                  # Pip package definition
gdsentry.toml.example           # Example configuration
```

### Tests

```
tests/unit/
└── test_config.py              # Configuration system tests
```

Documentation
-------------

::

   docs/source/internal/
   ├── architecture.rst           # Master architecture document
   └── implementation/slice-01-config.rst  # This file

Implementation Details
======================

Configuration Loading Strategy

**Priority (highest to lowest)**:
1. Environment variables (`GDSENTRY_*`)
2. Configuration file (`gdsentry.toml` or `gdsentry.yml`)
3. Default values (Pydantic models)

**File Discovery**:
- Search from current directory up to filesystem root
- Stop at first `gdsentry.toml` found
- Allow explicit path override

**Environment Variable Format**:
```bash
GDSENTRY_<SECTION>_<KEY>=<value>

# Examples:
GDSENTRY_TEST_SCOPE=framework
GDSENTRY_TEST_VERBOSE=true
GDSENTRY_PLATFORM_DEFAULT_ARCH=x86_64
```

### Pydantic Models

**Why Pydantic v2?**
- Automatic validation with clear error messages
- Type safety throughout the codebase
- Easy serialization/deserialization
- Field validators for complex rules
- Future-proof for API endpoints

**Model Hierarchy**:
```
GDSentryConfig
├── ProjectConfig
├── TestConfig
├── PlatformConfig
├── ContainerConfig
├── ValidationConfig
├── DocsConfig
└── CIConfig
```

**Key Validation Rules**:
- `timeout`: Must be positive
- `port`: Must be 1024-65535
- `registry`: Must be "localhost" (no external dependencies)
- Paths: Auto-resolved to absolute paths

### Exception Hierarchy

```
GDSentryError (base)
├── ConfigurationError       # Config file/validation errors
├── ValidationError          # Code validation failures
├── ContainerError          # Container operations failed
├── TestExecutionError      # Test execution failed
├── PlatformError           # Platform detection failed
└── TemplateError           # Template rendering failed
```

**Design Principle**: Specific exceptions for different failure modes, all inherit from `GDSentryError` for easy catching.

---

## API Examples

### Loading Configuration

```python
from gdsentry import load_config

# Auto-discover gdsentry.toml
config = load_config()

# Explicit path
config = load_config(config_path=Path("custom.toml"))

# Defaults only (no file search)
config = load_config(search_parent_dirs=False)
```

### Accessing Configuration

```python
config = load_config()

# Project settings
print(config.project.name)
print(config.project.godot_version)

# Test settings
print(config.test.scope)  # TestScope enum
print(config.test.timeout)

# Platform settings
print(config.platform.default_arch)  # Architecture enum
```

### Environment Override Example

```bash
# Set via environment
export GDSENTRY_TEST_SCOPE=framework
export GDSENTRY_TEST_VERBOSE=true

# Python code
config = load_config()
print(config.test.scope)     # TestScope.FRAMEWORK
print(config.test.verbose)   # True
```

---

## Self-Tests

### Test Coverage

**Configuration Loading**:
- ✅ Load default config without files
- ✅ Load from TOML file
- ✅ Load from YAML file
- ✅ File not found error handling
- ✅ Invalid TOML/YAML error handling
- ✅ Find config file by walking up directory tree

**Environment Overrides**:
- ✅ Load config from environment variables
- ✅ Boolean conversion (true/false/yes/no/1/0)
- ✅ Integer conversion
- ✅ String values

**Config Merging**:
- ✅ Merge simple dictionaries
- ✅ Deep merge nested dictionaries
- ✅ Environment overrides file config

**Validation**:
- ✅ Invalid config raises ConfigurationError
- ✅ Registry must be "localhost"
- ✅ Timeout must be positive
- ✅ Port must be valid range

**Model Tests**:
- ✅ Enum values correct
- ✅ Config validates on assignment
- ✅ Path resolution to absolute

### Running Tests

```bash
# Activate environment
conda activate gdsentry

# Run tests
pytest tests/unit/test_config.py -v

# With coverage
pytest tests/unit/test_config.py --cov=gdsentry.core --cov-report=term-missing
```

---

## Integration Points

### For Slice 2 (Platform Detection)

Provides:
- `GDSentryConfig` model with `platform` section
- `Architecture` enum
- `load_config()` function

Slice 2 will use:
```python
from gdsentry import load_config

config = load_config()
default_arch = config.platform.default_arch
```

### For Slice 3 (CLI Framework)

Provides:
- Configuration loading in CLI commands
- Exception types for error handling
- Models for command options

Slice 3 will use:
```python
from gdsentry import load_config, ConfigurationError

try:
    config = load_config()
except ConfigurationError as e:
    console.print(f"[error]{e}[/error]")
    raise typer.Exit(1)
```

### For All Slices

Every slice can:
- Import configuration system
- Use Pydantic models for validation
- Raise appropriate exceptions
- Access environment variable overrides

---

## LLM Generation Context

### Key Design Decisions

1. **Python 3.12 Target**: Use modern features, support 3.9+ for compatibility
2. **Pydantic v2**: Strict validation, clear errors
3. **TOML Primary**: TOML for config (more readable than YAML for config files)
4. **Environment Overrides**: Always highest priority for CI/CD flexibility
5. **No Defaults in Config File**: All defaults in Pydantic models (single source of truth)

### Common Patterns

**Path Handling**:
```python
@field_validator("some_path", mode="before")
@classmethod
def resolve_path(cls, v: str | Path) -> Path:
    return Path(v).resolve()
```

**Enum Usage**:
```python
class SomeEnum(str, Enum):
    VALUE1 = "value1"
    VALUE2 = "value2"

# In model:
field: SomeEnum = Field(default=SomeEnum.VALUE1)

# In config class:
class Config:
    use_enum_values = True  # Serialize as strings
```

**Error Handling**:
```python
try:
    # Operation
except SpecificError as e:
    raise ConfigurationError(f"Clear message: {e}") from e
```

---

## Validation Checklist

✅ **Implementation**:
- [x] All files created
- [x] Type hints throughout
- [x] Docstrings on all public APIs
- [x] Error messages are actionable
- [x] Paths resolved to absolute

✅ **Testing**:
- [x] Unit tests for all functions
- [x] Edge cases covered
- [x] Error paths tested
- [x] Environment override tests

✅ **Documentation**:
- [x] Architecture document updated
- [x] This slice document complete
- [x] Example config file created
- [x] API examples provided

✅ **Integration**:
- [x] Models exported from `__init__.py`
- [x] Exceptions exported
- [x] Config loader accessible
- [x] Ready for Slice 2

---

## Next Steps

**Ready for Slice 2**: Platform Detection & Models

Slice 2 will build on this foundation to:
- Detect host OS and architecture
- Parse Godot versions
- Define compatibility matrix
- Integrate with configuration system

---

## Checkpoint

**Slice 1 is complete and validated.**

Test the implementation:
```bash
conda activate gdsentry
pytest tests/unit/test_config.py -v
python -c "from gdsentry import load_config, GDSentryConfig; print(load_config())"
```

Expected output: Configuration loads successfully with all defaults.

