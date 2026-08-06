# Slice 4: Container Management (Local Only)

**Status**: ✅ Complete  
**Dependencies**: Slice 1 (Configuration), Slice 2 (Platform), Slice 3 (CLI)  
**Provides**: Container lifecycle management, image building for all other slices

---

## Purpose

Implement local-only container management for GDSentry:
- Podman client wrapper (subprocess-based)
- Container lifecycle (create, exec, stop, remove)
- Image building (wraps existing bash scripts)
- `gdsentry build` commands
- **No external registries** - localhost only

---

## Files Created

### Container Module

```
src/gdsentry/container/
├── __init__.py           # Container exports
├── podman.py             # Podman CLI wrapper
├── manager.py            # Container lifecycle
└── builder.py            # Image building
```

### CLI Commands

```
src/gdsentry/cli/commands/
└── build.py              # gdsentry build commands
```

### Tests

```
tests/unit/
└── test_container_mgmt.py   # Container tests
```

### Documentation

```
docs/source/internal/
├── output-design.rst     # Shared output design (created for formatter alignment)
└── implementation/slice-04-containers.rst  # This file
```

---

## Implementation Details

### Podman Client Wrapper (`podman.py`)

**Design**: Subprocess-based wrapper around Podman CLI

**Why not Docker SDK for Python?**
- Simpler: No heavy dependencies
- Podman-specific: Machine management, platform selection
- Direct control: Pass exact flags we need
- Portable: Works anywhere Podman CLI works

**Key Operations**:
- **Images**: list, build, remove, exists check
- **Containers**: run, exec, stop, remove, copy files
- **Machines**: check status, ensure running

### Container Manager (`manager.py`)

**Purpose**: High-level lifecycle management

**Operations**:
- Create test containers (detached mode)
- Copy project files to containers
- Execute commands in containers
- Clean up containers (stop + remove)

### Container Builder (`builder.py`)

**Strategy**: Wraps existing bash build scripts

**Why not rewrite in Python?**
- Build scripts work well (don't fix what isn't broken)
- Complex Containerfile generation logic
- Will migrate incrementally if needed

**Builds**:
- Base image (`build-base-image.sh`)
- Godot images (`build-godot-3.5.sh`, `build-godot-4.2.sh`)

**Note**: Documentation building uses CLI directly (``gdsentry docs build``), not containers.

---

## CLI Commands

### `gdsentry build base`

Build base container image.

```bash
gdsentry build base               # Auto-detect architecture
gdsentry build base --arch arm64  # Specific architecture
```

### `gdsentry build godot VERSION`

Build Godot container image.

```bash
gdsentry build godot 4.2          # Build Godot 4.2
gdsentry build godot 3.5 --arch x86_64
```

### `gdsentry build docs`

Build documentation image.

```bash
gdsentry build docs
```

### `gdsentry build all`

Build all images.

```bash
gdsentry build all                # All for current arch
gdsentry build all --arch x86_64  # All for specific arch
```

---

## Integration Points

### With Slice 2 (Platform Detection)

Uses platform detection:
```python
from gdsentry.platform import detect_architecture, get_container_platform

arch = detect_architecture()
platform = get_container_platform(arch)
# Use in: podman run --platform linux/arm64
```

### With Slice 3 (CLI)

Provides build commands:
```python
# In app.py
app.add_typer(build.app, name="build")

# CLI now has: gdsentry build ...
```

### For Slice 5 (Test Execution)

Provides container execution:
```python
from gdsentry.container import ContainerManager

manager = ContainerManager()
manager.create_test_container(
    image="gdsentry-godot-4.2:arm64",
    name="test-container",
    platform="linux/arm64"
)
manager.execute_in_container("test-container", ["godot", "--headless", ...])
manager.cleanup_container("test-container")
```

---

## Self-Tests

### Test Coverage

**Podman Client**:
- ✅ Client creation (checks Podman availability)
- ✅ Image exists check
- ✅ List images
- ✅ Machine status check

**Container Manager**:
- ✅ Manager creation
- ✅ Custom client injection

**Container Builder**:
- ✅ Builder creation
- ✅ Image name generation
- ✅ Image exists check

**Build Scripts**:
- ✅ All build scripts exist

**CLI Commands**:
- ✅ Build commands import correctly

### Running Tests

```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
pytest tests/unit/test_container_mgmt.py -v
```

**Note**: Some tests are skipped if Podman is not available (graceful degradation)

---

## Design Decisions

### Why Subprocess Instead of Docker SDK?

**Decision**: Use subprocess.run() to call Podman CLI

**Rationale**:
- **Simpler**: No docker-py dependency, version conflicts
- **Podman-specific**: Machine management not in Docker SDK
- **Control**: Pass exact Podman flags (--platform, etc.)
- **Maintainability**: Easy to understand subprocess calls
- **Portability**: Works everywhere Podman CLI works

### Why Keep Bash Build Scripts?

**Decision**: Wrap existing scripts, don't rewrite in Python

**Rationale**:
- **Working code**: Scripts are tested and functional
- **Complex logic**: Containerfile generation, dependency management
- **Incremental migration**: Can rewrite later if needed
- **Solo founder**: Don't spend time rewriting working code

### Why Local-Only (No Registries)?

**Decision**: Hard-coded `localhost` registry, reject external

**Rationale**:
- **User requirement**: No external dependencies
- **Security**: No credentials, no network leaks
- **Simplicity**: No registry authentication
- **Air-gappable**: Works offline

### Why Separate Manager and Builder?

**Decision**: Split lifecycle (Manager) and building (Builder)

**Rationale**:
- **Single Responsibility**: Each class has one job
- **Testing**: Easier to test separately
- **Reusability**: Manager used by test runner, Builder by build commands
- **Clarity**: Clear what each module does

---

## Error Handling

### Container Errors

All container operations raise `ContainerError` with context:

```python
try:
    builder.build_godot("4.2", "arm64")
except ContainerError as e:
    # e contains full error context
    # stderr from build process
    # actionable error message
```

### Podman Not Available

```
✗ Podman is not installed.

Tip: Install Podman from https://podman.io/getting-started/installation
```

### Build Script Not Found

```
✗ Build failed: Build script not found: scripts/util/build-godot-5.0.sh

Supported versions: 3.5, 4.2
```

### Machine Not Running

```python
# Auto-starts machine if not running
manager.ensure_machine_running()
```

---

## Limitations & Future Work

### Current Limitations

1. **Sequential builds**: Builds run one at a time
2. **No caching control**: Uses default Podman cache
3. **No progress tracking**: Build progress from scripts, not detailed
4. **Timeout hardcoded**: 10min base, 30min Godot, 10min docs

### Future Enhancements (Post v2.0)

1. **Parallel builds**: Build multiple images simultaneously
2. **Cache management**: Clear cache, no-cache builds
3. **Build progress**: Parse build output for progress bars
4. **Configurable timeouts**: User-specified build timeouts
5. **Python build scripts**: Migrate from bash to pure Python

---

## Validation Checklist

✅ **Implementation**:
- [x] All files created
- [x] Podman client wrapper complete
- [x] Container manager functional
- [x] Builder wraps scripts
- [x] CLI commands work

✅ **Testing**:
- [x] Unit tests pass
- [x] Graceful Podman unavailable handling
- [x] Build scripts exist check

✅ **Documentation**:
- [x] ARCHITECTURE.md updated
- [x] This slice document complete
- [x] OUTPUT_DESIGN.md created
- [x] Integration points documented

✅ **CLI**:
- [x] Build commands registered
- [x] Help text clear
- [x] Error messages actionable

---

## Next Steps

**Ready for Slice 5**: Test Discovery & Execution

Slice 5 will use Container Manager to:
- Discover GDScript test files
- Execute tests in containers
- Capture and parse results
- Display test summaries

---

## Checkpoint

**Slice 4 is complete and validated.**

Test the build commands:
```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry

# Show build help
python -m gdsentry build --help

# Test build commands exist
python -m gdsentry build base --help
python -m gdsentry build godot --help

# Run tests
pytest tests/unit/test_container_mgmt.py -v
```

Expected output: Beautiful CLI with build commands available, tests pass.

