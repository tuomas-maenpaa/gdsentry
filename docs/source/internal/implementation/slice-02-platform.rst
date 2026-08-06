# Slice 2: Platform Detection & Models

**Status**: ✅ Complete  
**Dependencies**: Slice 1 (Configuration)  
**Provides**: Platform detection, Godot version handling, compatibility matrix for all other slices

---

## Purpose

Implement cross-platform detection and Godot version compatibility:
- Detect host OS and CPU architecture
- Parse and compare Godot version strings
- Define architecture/version compatibility matrix
- Provide container platform mappings
- Check QEMU/Podman availability

---

## Files Created

### Platform Module

```
src/gdsentry/platform/
├── __init__.py              # Platform exports
├── detection.py             # OS/arch detection
├── godot.py                 # Godot version parsing
└── compatibility.py         # Compatibility matrix
```

### Tests

```
tests/unit/
└── test_platform_detection.py   # Platform detection tests
```

### Documentation

```
docs/source/internal/implementation/
└── slice-02-platform.rst        # This file
```

---

## Implementation Details

### OS & Architecture Detection

**Supported Operating Systems**:
- macOS (darwin)
- Linux
- Windows
- Unknown (fallback)

**Supported Architectures**:
- x86_64 (Intel/AMD 64-bit)
- ARM64 (Apple Silicon, ARM 64-bit)
- Unknown (fallback)

**Detection Method**:
- Uses Python's `platform` module (pure Python, no shell calls)
- Normalizes architecture names (`amd64` → `x86_64`, `aarch64` → `arm64`)
- Checks for QEMU and Podman availability

### Godot Version Parsing

**Supported Formats**:
```
4.2.2-stable     # Full version with type
4.2-stable       # Without patch
3.5              # Minimal version
4.3-rc.2         # Release candidate
4.3-beta.1       # Beta version
```

**Version Components**:
- Major version (required)
- Minor version (required)
- Patch version (optional, defaults to 0)
- Type (stable, rc, beta, alpha, dev)
- Build number (for rc/beta)

**Version Comparison**:
- Compares by: major → minor → patch → type → build
- Stability order: stable > rc > beta > alpha > dev

### Compatibility Matrix

**Current Compatibility** (as of GDSentry 2.0):

| Architecture | Godot 3.5 | Godot 4.2 | Notes |
|-------------|-----------|-----------|-------|
| x86_64 | ✅ | ✅ | Full support |
| ARM64 | ❌ | ✅ | Godot 3.x has no ARM64 builds |

**Cross-Architecture Testing**:
- x86_64 → ARM64: Via QEMU emulation
- ARM64 → x86_64: Via Podman VM (Rosetta on macOS)

**Container Platforms**:
- x86_64 → `linux/amd64`
- ARM64 → `linux/arm64`

---

## API Examples

### Platform Detection

```python
from gdsentry.platform import detect_platform, get_platform_display_name

# Detect complete platform info
info = detect_platform()
print(info.os)              # OS.MACOS
print(info.architecture)    # Architecture.ARM64
print(info.qemu_available)  # True/False
print(info.podman_available) # True/False

# Get human-readable name
name = get_platform_display_name()
print(name)  # "macOS ARM64"
```

### Godot Version Parsing

```python
from gdsentry.platform import parse_godot_version, compare_versions

# Parse version string
version = parse_godot_version("4.2.2-stable")
print(version.major)  # 4
print(version.minor)  # 2
print(version.patch)  # 2
print(version.type)   # GodotVersionType.STABLE

# Convert to strings
print(str(version))              # "4.2.2-stable"
print(version.to_short_string()) # "4.2.2"
print(version.to_container_tag("arm64"))  # "4.2:arm64"

# Compare versions
v1 = parse_godot_version("4.2.1-stable")
v2 = parse_godot_version("4.2.2-stable")
print(compare_versions(v1, v2))  # -1 (v1 < v2)
```

### Compatibility Checks

```python
from gdsentry.platform import (
    is_architecture_compatible,
    get_compatible_godot_versions,
    get_container_platform,
    supports_cross_architecture,
)

# Check if Godot version works on architecture
is_compatible = is_architecture_compatible("x86_64", "3.5-stable")
print(is_compatible)  # True

is_compatible = is_architecture_compatible("arm64", "3.5-stable")
print(is_compatible)  # False (ARM64 doesn't support Godot 3.x)

# Get all compatible versions
versions = get_compatible_godot_versions("arm64")
print(versions)  # ["4.2-stable", "4.2.1-stable", "4.2.2-stable"]

# Get container platform string
platform = get_container_platform("x86_64")
print(platform)  # "linux/amd64"

# Check cross-architecture support
supported = supports_cross_architecture("arm64", "x86_64")
print(supported)  # True (ARM64 → x86_64 via VM)
```

---

## Integration Points

### With Slice 1 (Configuration)

Uses configuration models:
```python
from gdsentry import load_config
from gdsentry.platform import detect_architecture

config = load_config()

# Check configured default architecture
if config.platform.default_arch == "auto":
    actual_arch = detect_architecture()
```

### For Slice 3 (CLI Framework)

Provides platform info for CLI commands:
```python
# In gdsentry info platform command
from gdsentry.platform import detect_platform

info = detect_platform()
# Display in Rich table
```

### For Slice 4 (Container Management)

Provides container platform strings:
```python
from gdsentry.platform import get_container_platform

platform = get_container_platform("arm64")
# Use in: podman run --platform linux/arm64 ...
```

### For Slice 5 (Test Execution)

Provides compatibility checks:
```python
from gdsentry.platform import is_architecture_compatible

# Before running tests
if not is_architecture_compatible(arch, godot_version):
    raise TestExecutionError(f"Incompatible: {godot_version} on {arch}")
```

---

## Self-Tests

### Test Coverage

**OS Detection**:
- ✅ Returns valid OS enum
- ✅ Matches platform.system()

**Architecture Detection**:
- ✅ Returns valid Architecture enum
- ✅ Matches platform.machine()
- ✅ Normalizes architecture names

**Platform Detection**:
- ✅ Returns complete PlatformInfo
- ✅ Python version format is correct
- ✅ Display name contains OS and arch

**Godot Version Parsing**:
- ✅ Parse stable versions
- ✅ Parse versions without patch
- ✅ Parse versions without type
- ✅ Parse RC versions with build number
- ✅ Parse beta versions
- ✅ Invalid versions raise ValidationError
- ✅ Convert back to string
- ✅ Short string format
- ✅ Container tag generation

**Version Comparison**:
- ✅ Compare equal versions
- ✅ Compare less than
- ✅ Compare greater than
- ✅ Compare by type (stable > rc > beta)
- ✅ Version alias normalization

**Compatibility**:
- ✅ x86_64 supports Godot 3 and 4
- ✅ ARM64 only supports Godot 4
- ✅ Get compatible versions list
- ✅ Container platform mapping
- ✅ Recommended version selection

**Cross-Architecture**:
- ✅ Same architecture always supported
- ✅ x86_64 → ARM64 supported (QEMU)
- ✅ ARM64 → x86_64 supported (VM)
- ✅ Invalid architectures handled

### Running Tests

```bash
# Activate conda environment
conda activate gdsentry

# Run Slice 2 tests
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
pytest tests/unit/test_platform_detection.py -v

# Run with coverage
pytest tests/unit/test_platform_detection.py \
    --cov=gdsentry.platform --cov-report=term-missing
```

---

## Design Decisions

### Why Pure Python for Detection?

**Decision**: Use Python's `platform` module instead of shell commands

**Rationale**:
- Cross-platform (works on macOS, Linux, Windows)
- No shell compatibility issues
- No subprocess overhead
- Type-safe with Pydantic models
- Easier to test

### Why Pydantic for Version Models?

**Decision**: Use Pydantic BaseModel for GodotVersion

**Rationale**:
- Automatic validation (non-negative version numbers)
- Type safety
- Easy serialization (future JSON API)
- Consistent with Slice 1 configuration
- Self-documenting with Field descriptions

### Why Hard-Code Compatibility Matrix?

**Decision**: Define compatibility in Python dict instead of external config

**Rationale**:
- Simple and explicit
- Easy to update as new Godot versions release
- Type-safe (no runtime parsing)
- Can be moved to config file later if needed
- Clear source of truth in code

### Why Support Both Enum and String?

**Decision**: Functions accept both `Architecture` enum and string

**Rationale**:
- Flexibility for CLI (strings from arguments)
- Type safety for internal code (enums)
- Easy conversion in wrapper functions
- Better user experience

---

## Future Enhancements

### Potential Additions (Post v2.0)

1. **Automatic Godot Version Detection**: Scan installed Godot binaries
2. **Extended Compatibility Matrix**: Support Godot 4.3+, 5.x
3. **Platform-Specific Optimizations**: SIMD, GPU detection
4. **Container Registry Support**: Pull pre-built images (if external deps allowed)
5. **Version Constraint Parsing**: Semver-style constraints ("^4.2.0")

---

## Integration with Existing Code

### Replaces Bash Script Logic

This slice replaces:
- `scripts/config/gdsentry-test-config.sh`:
  - `get_godot_versions_for_arch()` → `get_compatible_godot_versions()`
  - `get_container_platform()` → Same function name, pure Python
  - `get_test_strategy()` → `supports_cross_architecture()`

### Migration Path

Old bash code:
```bash
VERSIONS=$(./scripts/config/gdsentry-test-config.sh get_godot_versions_for_arch x86_64)
```

New Python code:
```python
from gdsentry.platform import get_compatible_godot_versions

versions = get_compatible_godot_versions("x86_64")
```

---

## Validation Checklist

✅ **Implementation**:
- [x] All files created
- [x] Pure Python (no shell calls)
- [x] Type hints throughout
- [x] Docstrings with examples
- [x] Pydantic models for data

✅ **Testing**:
- [x] Unit tests for all functions
- [x] Edge cases covered
- [x] Cross-platform considerations
- [x] Error handling tested

✅ **Documentation**:
- [x] ARCHITECTURE.md updated
- [x] This slice document complete
- [x] API examples provided
- [x] Integration points documented

✅ **Integration**:
- [x] Exports from `__init__.py`
- [x] Uses Slice 1 exceptions
- [x] Ready for Slice 3 (CLI)

---

## Next Steps

**Ready for Slice 3**: CLI Framework & Basic Commands

Slice 3 will build on this to:
- Create Typer CLI application
- Add `gdsentry info platform` command
- Display platform info in Rich tables
- Implement basic help/version commands

---

## Checkpoint

**Slice 2 is complete and validated.**

Test the implementation:
```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
python -c "
from gdsentry.platform import detect_platform, parse_godot_version
print(detect_platform())
print(parse_godot_version('4.2.2-stable'))
"
```

Expected output: Platform info and parsed Godot version.

