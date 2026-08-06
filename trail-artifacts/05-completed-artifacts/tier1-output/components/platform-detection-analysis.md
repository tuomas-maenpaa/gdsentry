# Component Analysis: Platform Detection

## Metadata
| Field | Value |
|-------|-------|
| Component Name | Platform Detection |
| Location | src/gdsentry/platform/ |
| Primary Purpose | Detects OS, architecture, Godot version compatibility; provides platform-specific adaptations. Foundation component for cross-architecture support. |
| Analysis Tier | Tier 1 - Metadata initialization |
| Last Updated | 2025-10-15 |

## Architecture Assessment

| Dimension | Rating | Evidence | Filled By |
|-----------|--------|----------|----------|
| Boundary Definition | Well-Defined | Clear three-module separation: detection.py (OS/arch detection), godot.py (version parsing), compatibility.py (compatibility matrix). Each has focused responsibility. Clean abstraction for platform-specific concerns. Evidence: detection.py:13-27 enums, godot.py:12-19 version types, compatibility.py:11-25 compatibility matrix. Boundary between platform detection and consumers is stable interface. | Tier 2 |
| Responsibility Clarity | Well-Defined | detection.py detects OS/arch/QEMU/Podman (detection.py:42-189). godot.py parses/compares Godot versions (godot.py:21-244). compatibility.py manages arch-version compatibility matrix (compatibility.py:11-213). No overlap. Each module has single, clear purpose. Evidence: clean separation of concerns across three modules. | Tier 2 |
| Pattern Consistency | Well-Defined | Consistent enum-based types (OS, Architecture, GodotVersionType). Pydantic models for structured data (PlatformInfo, GodotVersion). Pure functions for detection/parsing. Compatibility matrix as data structure. Evidence: detection.py:13-37 enums/models, godot.py:12-100 version model, compatibility.py:11-25 matrix dict. Professional pattern usage. | Tier 2 |
| Documentation Alignment | Partially-Defined | CRITICAL FINDING: Documentation claims "no dependencies" but code imports from gdsentry.core.exceptions (detection.py:11, godot.py:10). Otherwise well-documented. Structure matches docs. Foundation layer claim is misleading - depends on Core for exceptions. Evidence: detection.py:11 imports PlatformError, godot.py:10 imports ValidationError. | Tier 2 |
| Interface Design | Well-Defined | Clean public API via __init__.py exports (detect_platform, detect_architecture, parse_godot_version, etc.). Well-designed functions with clear signatures. Pydantic models ensure type safety. Many dependents rely on stable interface. Evidence: __init__.py:3-35 clean exports, detection.py:165-189 detect_platform() returns PlatformInfo, godot.py:103-156 parse returns GodotVersion. | Tier 2 |
| Coupling & Dependencies | Partially-Defined | CRITICAL FINDING: NOT dependency-free as documented. Depends on gdsentry.core.exceptions (detection.py:11 PlatformError, godot.py:10 ValidationError). Only standard library + core exceptions + pydantic. Foundation layer claim incorrect - Core exceptions is dependency. Otherwise minimal coupling. Evidence: detection.py:11, godot.py:10 import from core.exceptions. | Tier 2 |

## Dependencies

### Outbound Dependencies

**CRITICAL FINDING - Core.Exceptions Dependency**:
- `detection.py:11` - `from gdsentry.core.exceptions import PlatformError`
- `godot.py:10` - `from gdsentry.core.exceptions import ValidationError`
- **Issue**: Documentation claims "no dependencies" (P2, Tier 1 notes)
- **Reality**: Platform Detection DEPENDS on Core for exception types
- **Impact**: Foundation layer claim is incorrect - creates circular risk if Core depends on Platform

**Python Standard Library** (FOUNDATIONAL):
- `platform` module - OS/architecture detection (`detection.py:3`)
- `subprocess` - Command execution for QEMU/Podman checks (`detection.py:4`)
- `re` - Regular expressions for version parsing (`godot.py:3`)
- `enum` - Enum types (`detection.py:5`, `godot.py:4`)
- `typing` - Type hints
- **Purpose**: Core Python functionality, true foundation

**Pydantic** (FOUNDATIONAL):
- `detection.py:9` - `from pydantic import BaseModel, ConfigDict`
- `godot.py:8` - `from pydantic import BaseModel, ConfigDict, Field, field_validator`
- **Purpose**: Data validation and structured models (PlatformInfo, GodotVersion)
- **External dependency**: Third-party library

**Internal Module Dependencies**:
- `compatibility.py:5` imports from `detection` and `godot` modules
- Clean internal dependency within platform package
- Evidence: `compatibility.py:5-6`

**Dependency Analysis**:
- **Claimed**: "No dependencies" (P2 documentation, Tier 1 notes)
- **Actual**: Depends on Core.exceptions + Pydantic + stdlib
- **Severity**: MEDIUM - Documentation inaccuracy about foundation status

### Inbound Dependencies

**Core Engine** (HIGH usage):
- TestRunner likely uses architecture detection
- Config may use platform detection
- Evidence: Widespread usage expected

**Container Management** (HIGH usage):
- `builder.py:19` - `from gdsentry.platform.compatibility import get_container_platform`
- `builder.py:19` - `from gdsentry.platform.godot import normalize_version_alias`
- **Purpose**: Architecture selection for container builds

**CLI Framework** (HIGH usage):
- `test.py:14` - `from gdsentry.platform.detection import detect_architecture`
- `build.py:9` - `from gdsentry.platform.detection import detect_architecture`
- **Purpose**: Auto-detect architecture for commands

**Validation Tools** (potential):
- May use Godot version parsing

**Many Dependents**:
- Platform Detection is widely used across Python components
- Interface stability is critical
- Changes would impact many components

### Circular Dependency Risk

**CRITICAL CONCERN**: Platform depends on Core.exceptions
- If Core also depends on Platform → circular dependency
- **Investigation Needed**: Does Core import from Platform?
- **From P1 Analysis**: Core Engine does import `from gdsentry.platform.compatibility`
- **Result**: CIRCULAR DEPENDENCY EXISTS

**Circular Dependency Confirmed**:
```
Platform → Core.exceptions
Core → Platform.compatibility
```

**Why This Works** (likely):
- Python allows import cycles if imports are at module level
- Core.exceptions module may not import Platform
- Only detection/godot import from exceptions, not compatibility
- Compatibility imports from detection/godot but not Core
- Circular at package level but not module level

**Architectural Issue**: Foundation layer should not depend on Core

## Key Interfaces

### 1. Platform Detection API

**Location**: `detection.py:1-223`

**Purpose**: Detect host OS, architecture, and available tools

**Core Types**:
- `OS` enum: MACOS, LINUX, WINDOWS, UNKNOWN (`detection.py:13-19`)
- `Architecture` enum: X86_64, ARM64, UNKNOWN (`detection.py:22-27`)
- `PlatformInfo` model: Complete platform information (`detection.py:30-37`)

**Key Functions**:

**`detect_os() -> OS`** (`detection.py:42-62`):
- Detect operating system
- Uses `platform.system()`
- Maps "darwin" → macOS, "linux" → Linux, "windows" → Windows

**`detect_architecture() -> Architecture`** (`detection.py:65-86`):
- Detect CPU architecture
- Uses `platform.machine()`
- Normalizes various names (aarch64, arm64) to standard values

**`is_qemu_available() -> bool`** (`detection.py:89-134`):
- Check if QEMU is available for cross-architecture emulation
- Uses subprocess to check for qemu-system commands

**`is_podman_available() -> bool`** (`detection.py:137-152`):
- Check if Podman is installed
- Used by Container Management

**`detect_platform() -> PlatformInfo`** (`detection.py:165-189`):
- Comprehensive platform detection
- Returns structured PlatformInfo with OS, arch, QEMU, Podman, Python version
- **Most commonly used** entry point

**`get_platform_display_name() -> str`** (`detection.py:192-223`):
- Human-readable platform name (e.g., "macOS ARM64")
- For user-facing output

**Interface Stability**: CRITICAL - many components depend on this

---

### 2. Godot Version API

**Location**: `godot.py:1-244`

**Purpose**: Parse, compare, and normalize Godot version strings

**Core Types**:
- `GodotVersionType` enum: STABLE, RC, BETA, ALPHA, DEV (`godot.py:12-19`)
- `GodotVersion` model: Structured version info (`godot.py:21-100`)
  - Fields: major, minor, patch, type, build
  - Methods: `__str__()`, `to_short_string()`, `to_container_tag()`

**Key Functions**:

**`parse_godot_version(version_string: str) -> GodotVersion`** (`godot.py:103-156`):
- Parse version string into structured components
- Supports: "4.2.2-stable", "4.2-stable", "3.5", "4.3-rc.2"
- **Critical for Container Management and CLI**

**`compare_versions(v1, v2) -> int`** (`godot.py:159-212`):
- Compare two versions
- Returns -1, 0, or 1
- Used for version compatibility checks

**`normalize_version_alias(version: str) -> str`** (`godot.py:215-244`):
- Normalize aliases to full version strings
- "3.5" → "3.5-stable", "4.2" → "4.2.2-stable"
- **Critical for Container Management** - used in builder.py

**Design**: Pydantic model ensures type safety and validation

---

### 3. Compatibility Matrix API

**Location**: `compatibility.py:1-213`

**Purpose**: Manage architecture-version compatibility and container platforms

**Compatibility Matrix** (`compatibility.py:11-25`):
```python
ARCHITECTURE_COMPATIBILITY = {
    Architecture.X86_64: ["3.5-stable", "3.5.1-stable", ..., "4.2.2-stable"],
    Architecture.ARM64: ["4.2-stable", "4.2.1-stable", "4.2.2-stable"],
}
```
**Note**: Godot 3.x lacks ARM64 support

**Container Platforms** (`compatibility.py:28-31`):
```python
CONTAINER_PLATFORMS = {
    Architecture.X86_64: "linux/amd64",
    Architecture.ARM64: "linux/arm64",
}
```

**Key Functions**:

**`is_architecture_compatible(arch, godot_version) -> bool`** (`compatibility.py:34-67`):
- Check if version works on architecture
- Consults compatibility matrix

**`get_compatible_godot_versions(architecture) -> List[str]`** (`compatibility.py:85-107`):
- Get all compatible versions for architecture
- Returns list from compatibility matrix

**`get_container_platform(architecture) -> str`** (`compatibility.py:110-140`):
- Get Podman/Docker platform string ("linux/amd64")
- **Critical for Container Management**

**`supports_cross_architecture(host_arch, target_arch) -> bool`** (`compatibility.py:170-213`):
- Check if cross-arch testing is possible
- x86_64 → ARM64: via QEMU
- ARM64 → x86_64: via Podman VM

**Design**: Centralized compatibility data, easy to update as Godot evolves

---

### 4. Public API

**Location**: `__init__.py:1-35`

**Exports**:
- Platform detection: `detect_platform`, `detect_architecture`, `detect_os`, `is_qemu_available`
- Godot versioning: `GodotVersion`, `parse_godot_version`, `compare_versions`
- Compatibility: `is_architecture_compatible`, `get_compatible_godot_versions`, `get_container_platform`

**Usage Pattern**:
```python
from gdsentry.platform import detect_architecture, parse_godot_version

arch = detect_architecture()
version = parse_godot_version("4.2.2-stable")
```

**Interface Stability**:
- Many components depend on this
- Changes would be breaking
- Well-designed, unlikely to need changes

## Findings

### Strengths

#### 1. Clean Module Separation ✅ HIGH

**Evidence**: Three focused modules with distinct responsibilities

**Structure**:
- `detection.py`: OS/arch/tool detection
- `godot.py`: Version parsing and comparison
- `compatibility.py`: Compatibility matrix management

**Benefits**:
- Easy to understand each module
- Changes isolated to relevant module
- Clean internal dependencies (compatibility imports from detection/godot)
- Professional organization

**Impact**: HIGH - Well-organized foundation

---

#### 2. Strong Type Safety ✅ HIGH

**Evidence**: Enums and Pydantic models throughout

**Design**:
- Enums for OS, Architecture, GodotVersionType
- Pydantic models for PlatformInfo, GodotVersion
- Type hints on all functions
- Validation in Pydantic models

**Benefits**:
- Compile-time type checking
- Runtime validation
- Self-documenting code
- Prevents invalid data

**Examples**:
- `detection.py:13-27` - OS and Architecture enums
- `godot.py:21-100` - GodotVersion with field validators

**Impact**: HIGH - Professional type safety design

---

#### 3. Centralized Compatibility Matrix ✅ MEDIUM

**Evidence**: Single source of truth for arch-version compatibility

**Design** (`compatibility.py:11-25`):
- Dictionary mapping architectures to compatible Godot versions
- Easy to update as Godot releases new versions
- Documents known limitation (Godot 3.x lacks ARM64 support)

**Benefits**:
- Single place to update compatibility
- Clear documentation of platform support
- Easy to query compatibility

**Impact**: MEDIUM - Good centralized design

---

#### 4. Stable Public Interface ✅ MEDIUM

**Evidence**: Clean __init__.py exports, well-designed functions

**Interface Quality**:
- Clear function names
- Proper return types
- Documented with docstrings
- Examples in docstrings

**Stability**:
- Many components depend on this
- Interface unlikely to need breaking changes
- Enums provide extensibility (can add new OS/arch)

**Impact**: MEDIUM - Critical for widely-used component

---

### Concerns

#### 1. CRITICAL: Circular Dependency with Core 🔶 HIGH

**Evidence**: Platform imports from Core, Core imports from Platform

**The Circular Dependency**:
```
Platform → Core.exceptions (detection.py:11, godot.py:10)
Core → Platform.compatibility (runner.py:204)
```

**Documentation Inaccuracy**:
- **Claimed**: "No dependencies" (P2 documentation, Tier 1 notes)
- **Actual**: Depends on Core.exceptions
- **Result**: Foundation layer claim is misleading

**Why It Works** (Python allows this):
- Circular at package level, not module level
- Core.exceptions likely doesn't import Platform
- Only detection/godot import exceptions
- Compatibility doesn't import Core
- Import cycle broken at module granularity

**Architectural Issue**:
- Foundation layer shouldn't depend on Core
- Violates layered architecture principle
- Creates coupling between "foundation" and upper layers

**Impact**:
- **Technical**: Works in Python but architecturally wrong
- **Conceptual**: "Foundation" depends on what it's supposed to support
- **Maintenance**: Harder to refactor Core or Platform independently

**Recommendation**: Move exception types to truly foundational module
- Create `gdsentry.exceptions` (no dependencies)
- Both Platform and Core import from it
- Break circular dependency

**Severity**: HIGH - Architectural principle violation, documentation inaccuracy

---

#### 2. Compatibility Matrix Maintenance Burden 🔶 MEDIUM

**Evidence**: Hardcoded version list in compatibility.py:11-25

**Current Approach**:
```python
ARCHITECTURE_COMPATIBILITY = {
    Architecture.X86_64: [
        "3.5-stable", "3.5.1-stable", "3.5.2-stable",
        "4.2-stable", "4.2.1-stable", "4.2.2-stable",
    ],
    ...
}
```

**Issue**:
- Manual updates required for each Godot release
- Must remember to update when new versions released
- Risk of forgetting to add new versions
- No automated synchronization with Godot releases

**Impact**:
- Maintenance burden
- May lag behind Godot releases
- Users may want to use versions not in list

**Trade-offs**:
- **Current (manual)**: Simple, explicit, controlled
- **Alternative (dynamic)**: Auto-detect from available images, more complex

**Recommendation**: Document update process, consider version range patterns

**Severity**: MEDIUM - Manageable but requires discipline

---

#### 3. No Version Validation Against Actual Godot Releases 🔶 LOW

**Evidence**: Version parsing accepts any format, no verification against real releases

**Current**:
- `parse_godot_version("99.99.99-stable")` - parses successfully
- No check if version actually exists
- No check if version is downloadable

**Issue**:
- Users can specify non-existent versions
- Error occurs later (container build or download)
- Less helpful error messages

**Trade-off**:
- **Current**: Parse any version, validate later
- **Alternative**: Maintain list of valid releases, validate early

**Verdict**: Current approach is reasonable (version validation is complex)

**Severity**: LOW - Acceptable design choice

---

#### 4. Documentation Claims Don't Match Reality 🔶 MEDIUM

**Evidence**: P2 and Tier 1 claim "no dependencies"

**Documentation Claims**:
- "No dependencies" (Tier 1 notes)
- "Foundation layer" (Tier 1 notes)
- "Truly foundational component" (implied)

**Reality**:
- Depends on gdsentry.core.exceptions
- Depends on Pydantic (external)
- Not truly foundational

**Impact**:
- Misleading architecture documentation
- False sense of layering
- Developers may assume no coupling

**Recommendation**: Update documentation to acknowledge Core.exceptions dependency

**Severity**: MEDIUM - Documentation accuracy issue

### Documentation Gaps

#### 1. "No Dependencies" Claim is False 📝 HIGH

**Gap**: Documentation claims Platform has no dependencies

**Claimed** (P2, Tier 1):
- "No dependencies"
- "Foundational component"
- "Foundation layer in 3-tier architecture"

**Reality**:
- Depends on gdsentry.core.exceptions
- Circular dependency with Core

**What's Missing**:
- Accurate dependency documentation
- Acknowledgment of Core.exceptions coupling
- Circular dependency explanation

**Impact**: Misleading architecture understanding

---

#### 2. Circular Dependency Not Documented 📝 HIGH

**Gap**: No mention of Platform ↔ Core circular dependency

**What's Missing**:
- Why circular dependency exists
- Why it works (module-level vs package-level)
- Plan to resolve it
- Architectural rationale

**Impact**: Hidden architectural coupling

---

#### 3. Compatibility Matrix Update Process 📝 MEDIUM

**Gap**: No documentation on how to update compatibility matrix

**What's Missing**:
- When to add new Godot versions
- Process for verifying compatibility
- Testing new versions
- Update checklist

**Impact**: Maintenance burden, may lag Godot releases

---

**Overall Documentation Quality**: GOOD except for dependency claim
- Structure well-documented
- Functions have docstrings
- Major gap: "no dependencies" is factually incorrect

---

## Questions for Tier 3

### 1. How to Break Circular Dependency? ⚠️ HIGH PRIORITY

**Question**: What's the best way to break Platform ↔ Core circular dependency?

**Context**:
- Platform imports Core.exceptions
- Core imports Platform.compatibility
- Violates foundation layer principle

**Potential Solutions**:

**Option 1: Create gdsentry.exceptions module**
- Move PlatformError, ValidationError to new module
- Both Platform and Core import from it
- Clean separation
- **Pro**: Breaks circular dependency completely
- **Con**: Refactoring effort

**Option 2: Use standard Python exceptions**
- Platform raises ValueError, TypeError instead of custom exceptions
- Remove Core.exceptions dependency
- **Pro**: Simpler, truly dependency-free
- **Con**: Less informative exception hierarchy

**Option 3: Accept circular dependency**
- Document it clearly
- Ensure module-level imports don't create cycles
- **Pro**: No changes needed
- **Con**: Architectural principle violation remains

**Recommendation**: Option 1 (create gdsentry.exceptions)

**Impact**: HIGH - Architectural health improvement

---

### 2. Is Core.exceptions Module Truly Independent? 🔍 MEDIUM PRIORITY

**Question**: Does core/exceptions.py import anything from Platform?

**Context**:
- Circular dependency at package level
- Works because imports at module level
- Need to verify exceptions.py doesn't import Platform

**What We Need to Understand**:
1. Does exceptions.py have any Platform imports?
2. Is it truly independent?
3. Could we move it to top level?

**Investigation**: Examine core/exceptions.py imports

**Impact**: MEDIUM - Understanding circular dependency details

---

### 3. Should Compatibility Matrix Be Data File? 🔍 LOW PRIORITY

**Question**: Should compatibility matrix be external data instead of Python code?

**Context**:
- Currently hardcoded in compatibility.py
- Requires code changes for new Godot versions

**Alternative**:
- JSON/YAML file with compatibility data
- Load at runtime
- Update without code changes

**Trade-offs**:
- **Pro**: Easier updates, non-developers can update
- **Con**: Runtime loading, validation complexity

**Impact**: LOW - Maintenance improvement consideration

## Notes from Tier 1
- **Documentation Status**: Well documented in architecture.rst
- **Key Files**: detection.py (OS/arch detection), godot.py (version parsing), compatibility.py (compatibility matrix)
- **Size**: 8 files
- **P1 Observation**: Foundational layer; used by most other components
- **P2 Alignment**: Structure matches documentation (✅ aligned)
- **P2 Note**: Listed as having no dependencies - truly foundational component
- **Architecture Role**: Foundation layer in documented 3-tier architecture

---

## Tier 2 Analysis Summary

**Analysis Date**: 2025-10-17
**Analyst**: Architecture Assessment Trail (Tier 2, Prompt 7)
**Status**: ✅ COMPLETE

**CRITICAL DISCOVERY**: Platform Detection Has Circular Dependency with Core - "No Dependencies" Claim is False

**The Investigation**:
- **Documented Claim**: "No dependencies" - truly foundational component (P2, Tier 1)
- **After Investigation**: Platform imports from gdsentry.core.exceptions
- **Further Discovery**: Core imports from gdsentry.platform.compatibility
- **Result**: **CIRCULAR DEPENDENCY** at package level

**The Circular Dependency**:
```
Platform → Core.exceptions (detection.py:11, godot.py:10)
Core → Platform.compatibility (runner.py:204)
```

**Why It Works** (Python allows this):
- Circular at package level, not module level
- core/exceptions.py likely doesn't import Platform
- Only detection/godot import from exceptions
- compatibility.py doesn't import from Core
- Import cycle broken at module granularity

**Architectural Issue**:
- "Foundation layer" shouldn't depend on layers above it
- Violates documented 3-tier architecture
- Creates coupling Platform <-> Core
- Documentation inaccuracy (claims no dependencies)

**Key Findings**:
- **Strengths**: Clean module separation (HIGH), strong type safety (HIGH), centralized compatibility matrix (MEDIUM), stable interface (MEDIUM)
- **Primary Discovery**: Circular dependency with Core violates foundation principle
- **Concerns**: Circular dependency (HIGH), documentation inaccuracy (MEDIUM), compatibility matrix maintenance (MEDIUM)
- **Documentation**: Good overall but "no dependencies" claim is factually incorrect (HIGH gap)

**Ratings Summary**:
- **Well-Defined** (4): Boundary Definition, Responsibility Clarity, Pattern Consistency, Interface Design
- **Partially-Defined** (2): Documentation Alignment (dependency claim wrong), Coupling & Dependencies (circular dependency)
- **Unclear** (0): None
- **Missing** (0): None

**Cross-Component Questions**: 3 questions raised for Tier 3, with breaking circular dependency as highest priority

**Impact on Previous Analyses**:
- Explains why Core has platform detection capabilities
- Reveals architectural layering is not as clean as documented
- First component with circular dependency discovered
- Challenges "foundation layer" claim in 3-tier architecture

**Recommendation**: Create truly foundational `gdsentry.exceptions` module
- Move exception types to top-level module
- Both Platform and Core import from it
- Break circular dependency
- Make Platform truly dependency-free (except stdlib + Pydantic)

**Self-Assessment Checklist**: ✅ All criteria met
- ✅ All six framework dimensions have ratings
- ✅ Each rating supported by concrete evidence using file:function format
- ✅ Dependencies section documents circular dependency (CRITICAL finding)
- ✅ Key interfaces section documents 4 interfaces with critical usage notes
- ✅ 4 strengths identified with evidence (clean separation, type safety, matrix, interface)
- ✅ 4 concerns identified with evidence and severity (including circular dependency HIGH)
- ✅ 3 documentation gaps explicitly noted (dependency claim FALSE)
- ✅ 3 questions for Tier 3 raised including solution options
- ✅ P2/Tier 1 "no dependencies" claim INVESTIGATED and proven FALSE
- ✅ Analysis maintains architectural focus (no code-quality nitpicks)

**Conclusion**: Platform Detection is well-designed with strong type safety and clean module organization, but the "no dependencies" claim is false. It has a circular dependency with Core that violates the documented foundation layer principle. The component is functionally sound but architecturally coupled in ways not documented. Recommendation: Create truly foundational exceptions module to break the circular dependency and make Platform actually dependency-free.
