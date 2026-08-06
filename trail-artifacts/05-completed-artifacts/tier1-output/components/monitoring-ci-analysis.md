# Component Analysis: Monitoring & CI

## Metadata
| Field | Value |
|-------|-------|
| Component Name | Monitoring & CI |
| Location | src/gdsentry/monitoring/ and src/gdsentry/ci/ |
| Primary Purpose | Performance monitoring and CI/CD integration support. Supports observability and automation for the testing framework. |
| Analysis Tier | Tier 1 - Metadata initialization |
| Last Updated | 2025-10-15 |

## Architecture Assessment

| Dimension | Rating | Evidence | Filled By |
|-----------|--------|----------|----------|
| Boundary Definition | Unclear | CRITICAL: These are TWO UNRELATED concerns incorrectly grouped. Monitoring (resources.py:27) = Podman container/image cleanup. CI (local.py:13) = Local GitHub Actions simulation. No relationship between them. Separate directories, no shared code, different purposes. Evidence: No imports between monitoring/ and ci/, completely independent. Should be separate components. | Tier 2 |
| Responsibility Clarity | Partially-Defined | Each subsystem has clear individual responsibility: ResourceMonitor (monitoring/resources.py:27-154) manages Podman resource cleanup. LocalCIRunner (ci/local.py:13-152) simulates CI workflow locally. BUT grouping as single "Monitoring & CI" component creates confusion - these are unrelated concerns. Evidence: Clear individual purposes, nonsensical grouping. | Tier 2 |
| Pattern Consistency | Well-Defined | Both follow standard patterns: subprocess calls for external tools, dataclasses for models, clean class design. ResourceMonitor uses Podman CLI, LocalCIRunner uses gdsentry commands. Consistent with framework patterns. Evidence: Standard Python patterns throughout. | Tier 2 |
| Documentation Alignment | Missing | COMPLETELY UNDOCUMENTED (P2 major gaps confirmed). Zero architectural documentation for either monitoring or CI. P2 explicitly identified "Monitoring System" and "CI/CD Integration Details" as gaps. Evidence: Tier 1 notes - not in architecture.rst. Sixth undocumented component. | Tier 2 |
| Interface Design | Well-Defined | Clean individual APIs: ResourceMonitor.list_containers(), cleanup_containers(), list_images(), cleanup_images(). LocalCIRunner.run(). Simple, focused interfaces. Evidence: monitoring/resources.py:38-154 methods, ci/local.py:26-152 methods. Professional API design within each. | Tier 2 |
| Coupling & Dependencies | Well-Defined | Monitoring: No framework dependencies (only subprocess, Podman). CI: Imports Core.exceptions, CLI.ui. No coupling between monitoring and CI. Independent of test execution. Evidence: monitoring/resources.py:3 only stdlib imports, ci/local.py:10-11 Core/CLI imports. Clean separation. | Tier 2 |

## Dependencies

### Monitoring Dependencies

**Outbound**:
- **Podman CLI** (external tool) - subprocess calls for container management
- **subprocess, dataclasses** (stdlib)
- **No framework dependencies** - completely standalone

**Inbound**:
- Likely used by CLI for resource cleanup commands
- Independent utility for container management

### CI Dependencies

**Outbound**:
- **Core.exceptions** (ci/local.py:11) - GDSentryError
- **CLI.ui** (ci/local.py:10) - console, success, error, warning
- **subprocess, pathlib, rich** - External dependencies

**Inbound**:
- CLI commands use LocalCIRunner
- Simulates GitHub Actions locally

### Pattern: No Relationship Between Monitoring and CI

**Independence**:
- No imports between monitoring/ and ci/
- No shared code or infrastructure
- Different external dependencies
- Different purposes

**Grouping Error**: These should be separate components

---

## Key Interfaces

### 1. ResourceMonitor - Podman Resource Cleanup

**Location**: `monitoring/resources.py:27-154` (154 lines)

**Purpose**: Manage Podman container and image cleanup

**Key Methods**:

**`list_containers(all_containers=True) -> List[ContainerInfo]`** (38-70):
- List Podman containers via `podman ps`
- Returns ContainerInfo dataclasses (id, name, status, image)
- Handles errors gracefully

**`list_images() -> List[ImageInfo]`** (72-95):
- List Podman images via `podman images`
- Returns ImageInfo dataclasses (id, repository, tag, size)

**`cleanup_containers(filter_name=None) -> int`**:
- Remove stopped containers
- Optional name filter
- Returns count of cleaned containers

**`cleanup_images(dangling_only=True) -> int`**:
- Remove unused images
- Optional dangling-only mode
- Returns count of cleaned images

**Use Case**: Resource management for containerized testing

---

### 2. LocalCIRunner - Local CI Workflow Simulation

**Location**: `ci/local.py:13-152` (152 lines)

**Purpose**: Simulate GitHub Actions CI workflow locally

**Key Method**:

**`run() -> bool`** (26-152):
- Run CI workflow steps locally
- Steps: setup, framework tests, build containers, cross-arch tests, linting
- Returns True if all pass

**Workflow Steps**:
1. Environment setup check
2. GDSentry framework tests (multiple Godot versions)
3. Container image builds
4. Cross-architecture testing
5. Linting and validation

**Use Case**: Test CI workflow before pushing to GitHub

---

## Findings

### Strengths

#### 1. Useful Development Utilities ✅ MEDIUM

**Evidence**: Both provide helpful development support

**Monitoring**: Cleanup Podman resources after testing
**CI**: Test CI workflow locally before pushing

**Value**: Improves developer experience

**Impact**: MEDIUM - Nice utilities for development

---

#### 2. Clean Individual Implementations ✅ MEDIUM

**Evidence**: Each is well-implemented within its scope

**Quality**: Simple, focused, appropriate patterns

**Impact**: MEDIUM - Good implementation quality

---

### Concerns

#### 1. CRITICAL: Two Unrelated Concerns Grouped Together 🔶 HIGH

**Evidence**: Monitoring and CI are completely separate

**Reality**:
- **Monitoring** (resources.py): Podman container cleanup
- **CI** (local.py): GitHub Actions simulation
- **No relationship**: Different purposes, no shared code, no imports

**Grouping Error**:
- Labeled as single "Monitoring & CI" component
- Should be TWO separate components
- Similar to Utilities (P11) grab-bag problem

**Comparison**:
- **Utilities** (P11): Collection of independent utilities
- **Monitoring & CI** (P13): Two unrelated concerns

**Recommendation**: Split into separate components
- Component 1: "Resource Monitoring" (Podman cleanup)
- Component 2: "CI Integration" (local workflow simulation)

**Severity**: HIGH - Architectural organization issue

---

#### 2. Completely Undocumented 🔶 HIGH

**Evidence**: Zero architectural documentation

**P2 Gaps Confirmed**:
- "Monitoring System" - completely undocumented
- "CI/CD Integration Details" - completely undocumented

**Impact**: Users unaware these utilities exist

**Pattern**: Sixth undocumented component (fifth GDScript + this)

**Severity**: HIGH - Hidden capabilities

---

#### 3. Unclear Integration with Framework 🔶 MEDIUM

**Evidence**: No clear integration points documented

**Questions**:
- When is ResourceMonitor used?
- How to invoke LocalCIRunner?
- CLI commands available?
- Automatic cleanup or manual?

**Impact**: Unclear how to use these utilities

**Severity**: MEDIUM - Usability unclear

---

### Documentation Gaps

#### 1. Entire Component Undocumented 📝 CRITICAL

**Gap**: Both monitoring and CI completely missing from architecture.rst

**What's Missing**:
- Purpose and capabilities
- When to use each
- Integration with CLI
- Resource cleanup strategies
- CI workflow details

**Impact**: Users cannot discover or understand these utilities

---

#### 2. Component Grouping Rationale Missing 📝 HIGH

**Gap**: No explanation why monitoring and CI are grouped

**What's Missing**: Architectural rationale for grouping unrelated concerns

**Impact**: Confusing organization

---

## Questions for Tier 3

### 1. Should Monitoring and CI Be Separate Components? 🔍 HIGH PRIORITY

**Question**: Should these be split into two components?

**Context**:
- Monitoring = Podman resource cleanup
- CI = Local workflow simulation
- No relationship between them

**Recommendation**: YES, split into separate components

**Impact**: HIGH - Component organization

---

### 2. How Are These Integrated with CLI? 🔍 MEDIUM PRIORITY

**Question**: What CLI commands use these utilities?

**Investigation Needed**: Find CLI integration points

**Impact**: MEDIUM - Understanding usage

---

## Tier 2 Analysis Summary

**Status**: ✅ COMPLETE

**CRITICAL DISCOVERY**: Two Unrelated Concerns Incorrectly Grouped as Single Component

**The Reality**:
- **"Monitoring"** (1 file, 154 lines): Podman container/image cleanup utility
- **"CI"** (1 file, 152 lines): Local GitHub Actions workflow simulation
- **No relationship**: Separate directories, no shared code, different purposes
- **Grouping error**: Should be two separate components

**Key Findings**:
- **Strengths**: Useful utilities (MEDIUM), clean implementations (MEDIUM)
- **Concerns**: Unrelated concerns grouped (HIGH), completely undocumented (HIGH), unclear integration (MEDIUM)
- **Primary Issue**: Architectural organization - these should be separate

**Ratings**: 1 Well-Defined, 4 Partially-Defined/Unclear, 1 Missing

**Documentation**: Completely missing (P2 gaps confirmed)

**Recommendation**: Split into "Resource Monitoring" and "CI Integration" components

**Conclusion**: Like Utilities (P11), this is a organizational grouping of unrelated concerns rather than cohesive component. Both utilities are useful but belong in separate components.

## Notes from Tier 1
- **Documentation Status**: ❌ Not mentioned in architecture.rst (P2 major gap)
- **Locations**: Two separate directories - monitoring/ (4 files) and ci/ (4 files)
- **Size**: 8 files total
- **P1 Observation**: Supports observability and automation
- **P2 Alignment**: ❌ In code but not documented - both monitoring and CI implementation undocumented
- **P2 Gap**: "Monitoring System" and "CI/CD Integration Details" identified as documentation gaps
- **P2 Note**: CI config section exists in configuration schema but implementation not documented
- **Expected Dependencies**: Core Engine, Platform Detection
- **Architecture Question**: How does monitoring integrate with test execution? How does CI integration work?
