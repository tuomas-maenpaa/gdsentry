# Component Analysis: Core Engine

## Metadata
| Field | Value |
|-------|-------|
| Component Name | Core Engine |
| Location | src/gdsentry/core/ |
| Primary Purpose | Central orchestration engine handling configuration, test discovery, test execution, and result reporting. Documented as configuration, models, and exceptions with test orchestration capabilities. |
| Analysis Tier | Tier 1 - Metadata initialization |
| Last Updated | 2025-10-15 |

## Architecture Assessment

| Dimension | Rating | Evidence | Filled By |
|-----------|--------|----------|----------|
| Boundary Definition | Partially-Defined | Core contains both foundational concerns (config, models) and orchestration logic (discovery, runner, reporter). Boundary between "core infrastructure" and "test execution" is blurred. Evidence: runner.py (484 lines), discovery.py (192 lines), reporter.py (172 lines) suggest orchestration responsibilities beyond "config and models". | Tier 2 |
| Responsibility Clarity | Partially-Defined | Documentation states "configuration, models, and exceptions" but implementation includes test discovery, execution orchestration, and result reporting. runner.py:TestRunner.run_tests_streaming shows complex orchestration. Actual scope broader than documented. | Tier 2 |
| Pattern Consistency | Well-Defined | Consistent use of Pydantic models (models.py:GDSentryConfig, runner.py:TestResult, TestSummary). Repository pattern for config loading (config.py:load_config). Observer pattern for streaming results (runner.py:run_tests_streaming yields). Pattern usage is appropriate and consistent. | Tier 2 |
| Documentation Alignment | Partially-Defined | architecture.rst describes as "Configuration, models, and exceptions" but omits orchestration role. runner.py, discovery.py, reporter.py are documented as file-level but their central role in test execution flow is understated. Gap between documented purpose and actual implementation scope. | Tier 2 |
| Interface Design | Well-Defined | Clean public API via __init__.py exports. TestRunner, TestDiscovery, TestReporter have clear interfaces. GDSentryConfig serves as central configuration object. Pydantic models ensure type safety. Interfaces are stable and well-designed. | Tier 2 |
| Coupling & Dependencies | Partially-Defined | runner.py:204 imports from gdsentry.platform.compatibility (tight coupling). runner.py:10 depends on gdsentry.container.manager.ContainerManager (necessary but creates dependency). discovery.py is self-contained (good). reporter.py has minimal coupling (only Rich library). Config/models layer is independent. Mixed coupling levels. | Tier 2 |

## Dependencies

### Outbound Dependencies

**Container Management** (HIGH coupling):
- `runner.py:10` - `from gdsentry.container.manager import ContainerManager`
- `runner.py:210` - `self.manager.ensure_machine_running()`
- `runner.py:218-228` - `self.manager.create_test_container()`
- `runner.py:247` - `self.manager.cleanup_container(container_name)`
- **Purpose**: Test execution requires container lifecycle management

**Platform Detection** (MEDIUM coupling):
- `runner.py:204` - `from gdsentry.platform.compatibility import get_container_platform`
- `runner.py:206` - `platform = get_container_platform(self.architecture)`
- **Purpose**: Determine correct container platform for test execution

**Rich Library** (LOW coupling):
- `reporter.py:4-5` - `from rich.console import Console` and `from rich.table import Table`
- **Purpose**: Terminal output formatting
- **Note**: External dependency, not internal GDSentry component

### Inbound Dependencies

**CLI Framework**:
- CLI commands import `core.load_config`, `core.TestRunner`, `core.TestDiscovery`, `core.TestReporter`
- Public API exposed via `__init__.py:3-16`
- **Purpose**: CLI orchestrates core functionality

**Validation System**:
- Likely uses `core.models.GDSentryConfig` for configuration
- **Purpose**: Access to configuration models

### Internal Dependencies

- `runner.py:11` - imports `core.discovery.TestFile` (cohesive)
- `runner.py:12` - imports `core.exceptions.TestExecutionError` (cohesive)
- `reporter.py:6` - imports `core.runner.TestResult, TestSummary` (cohesive)
- `config.py:16-17` - imports `core.exceptions.ConfigurationError` and `core.models.GDSentryConfig` (cohesive)

## Key Interfaces

### 1. GDSentryConfig (Central Configuration Object)

**Location**: `models.py:145-156`

**Purpose**: Aggregates all configuration subsections into single validated object

**Structure**:
- `project: ProjectConfig` - Project metadata and root path
- `test: TestConfig` - Test execution settings (scope, timeout, parallel)
- `platform: PlatformConfig` - Architecture and QEMU settings
- `container: ContainerConfig` - Container runtime configuration
- `validation: ValidationConfig` - Code validation options
- `docs: DocsConfig` - Documentation build settings
- `ci: CIConfig` - CI/CD pipeline configuration

**Key Features**:
- Pydantic validation with `ConfigDict(validate_assignment=True)`
- Frozen=False allows runtime modification
- Field validators ensure data integrity (e.g., `TestConfig.validate_timeout`)

**Usage**: `config.py:173-227` - `load_config()` creates and validates this object

---

### 2. TestRunner (Test Execution Orchestrator)

**Location**: `runner.py:53-484`

**Purpose**: Orchestrates test execution in containers with result streaming

**Primary Methods**:

**`__init__(project_root, godot_version, architecture, container_manager)`**:
- Initializes runner with project context
- Accepts optional ContainerManager for dependency injection

**`run_tests(test_files, scope, timeout) -> (list[TestResult], TestSummary)`**:
- Buffered test execution (compatibility mode)
- Returns complete results and summary
- Evidence: `runner.py:88-142`

**`run_tests_streaming(test_files, scope, timeout, verbose) -> Generator[str]`**:
- Streams test output line-by-line
- Yields status messages during execution
- Handles container lifecycle (create, execute, cleanup)
- Evidence: `runner.py:144-251`

**Key Responsibilities**:
1. Container creation with proper platform and environment
2. Test execution orchestration (framework vs. project tests)
3. Output parsing and TestResult creation
4. Container cleanup (even on failure)

**Coupling**: HIGH to ContainerManager (necessary), MEDIUM to Platform Detection

---

### 3. TestDiscovery (Test File Discovery)

**Location**: `discovery.py:28-192`

**Purpose**: Finds GDScript test files in project structure

**Primary Methods**:

**`__init__(project_root)`**:
- Initializes with project root
- Sets `tests_dir` to `project_root/tests`

**`discover_all(pattern="*_test.gd") -> List[TestFile]`**:
- Discovers all test files matching pattern
- Returns sorted list by category then name
- Evidence: `discovery.py:47-67`

**`discover_by_scope(scope) -> List[TestFile]`**:
- Discovers tests by scope (framework, project, both)
- Framework tests: `tests/framework/**/*_test.gd`
- Project tests: all non-framework tests
- Evidence: `discovery.py:69-86`

**Key Features**:
- Self-contained (no external component dependencies)
- Returns TestFile objects with metadata (path, category, name)
- Handles missing tests directory gracefully

**Coupling**: NONE (excellent)

---

### 4. TestReporter (Result Reporting)

**Location**: `reporter.py:8-172`

**Purpose**: Formats and displays test results using Rich library

**Primary Methods**:

**`__init__(console_instance=None)`**:
- Accepts optional Console for dependency injection
- Creates default Console if none provided

**`report_summary(summary: TestSummary)`**:
- Displays test execution summary table
- Shows suites, tests, assertions, duration, status
- Color-coded (green for pass, red for fail)
- Evidence: `reporter.py:29-79`

**`report_results(results: list[TestResult])`**:
- Displays individual test results
- Shows pass/fail status, duration per test
- Evidence: `reporter.py:81-106`

**`report_errors(results: list[TestResult])`**:
- Displays detailed error messages for failed tests
- Includes test file, error message, output
- Evidence: `reporter.py:108-135`

**Key Features**:
- Dependency injection for testing (console_instance parameter)
- Separation of summary, results, and error reporting
- Uses Rich for terminal formatting

**Coupling**: LOW (only Rich library dependency)

---

### 5. load_config() Function (Configuration Loading)

**Location**: `config.py:173-227`

**Purpose**: Loads and validates configuration with cascading priority

**Signature**: `load_config(config_path=None, search_parent_dirs=True) -> GDSentryConfig`

**Priority Order** (highest to lowest):
1. Environment variables (`GDSENTRY_*`)
2. Specified config file or discovered `gdsentry.toml`
3. Default values from Pydantic models

**Key Features**:
- Searches parent directories for `gdsentry.toml` if not specified
- Supports both TOML and YAML formats
- Merges configurations using deep merge (`config.py:151-170`)
- Validates final configuration using Pydantic
- Raises `ConfigurationError` on invalid config

**Supporting Functions**:
- `find_project_root()` - `config.py:18-27`
- `find_config_file()` - `config.py:30-57`
- `load_toml_config()` - `config.py:63-84`
- `load_yaml_config()` - `config.py:87-108`
- `load_env_overrides()` - `config.py:111-148`
- `merge_configs()` - `config.py:151-170`

**Coupling**: None to other GDSentry components (excellent for foundational layer)

## Findings

### Strengths

#### 1. Type Safety Through Pydantic Models ✅

**Evidence**: `models.py:1-156` - All configuration and data structures use Pydantic BaseModel

**Benefits**:
- Runtime validation prevents invalid configurations
- `GDSentryConfig` validates entire configuration tree
- Field validators enforce constraints (e.g., `TestConfig.validate_timeout:64-68` ensures positive timeout)
- IDE autocomplete and type checking support
- Clear data contracts between components

**Example**: `models.py:38-42` - `ProjectConfig.resolve_path` validator ensures paths are absolute

**Impact**: HIGH - Eliminates entire class of configuration errors at runtime

---

#### 2. Clean Separation of Configuration Loading ✅

**Evidence**: `config.py:173-227` - Layered configuration with clear priority

**Architecture**:
1. Environment variables (highest priority)
2. Config file (TOML/YAML)
3. Pydantic defaults (lowest priority)

**Benefits**:
- Flexibility for different deployment scenarios (dev, CI, production)
- Deep merge strategy allows partial overrides
- Self-contained module with no component dependencies
- Repository pattern implementation

**Impact**: HIGH - Configuration is foundational concern handled correctly

---

#### 3. Dependency Injection for Testability ✅

**Evidence**: 
- `runner.py:65-73` - `TestRunner.__init__` accepts optional `container_manager`
- `reporter.py:17-24` - `TestReporter.__init__` accepts optional `console_instance`

**Benefits**:
- Enables unit testing without container infrastructure
- Allows mock Console for output testing
- Follows best practices for testable design

**Impact**: MEDIUM - Improves testability but doesn't affect production architecture

---

#### 4. Self-Contained Test Discovery ✅

**Evidence**: `discovery.py:28-192` - TestDiscovery has zero dependencies on other GDSentry components

**Benefits**:
- Can be tested in isolation
- No coupling to Container, Platform, or CLI
- Clear, single responsibility (find test files)
- Simple data model (TestFile Pydantic model)

**Impact**: MEDIUM - Good example of low-coupling design

---

### Concerns

#### 1. Scope Ambiguity: "Core" vs. "Orchestration" 🔶 MEDIUM

**Evidence**:
- Documentation: `architecture.rst:64-70` states "Configuration, models, and exceptions"
- Implementation: `runner.py` (484 lines), `discovery.py` (192 lines), `reporter.py` (172 lines)
- Actual role: Test execution orchestration, not just foundational infrastructure

**Problem**:
- "Core" typically implies foundational, shared infrastructure
- This core also contains high-level orchestration logic
- Boundary between "core infrastructure" and "business logic" is unclear

**Impact**: 
- Makes component purpose unclear to new developers
- Harder to understand what belongs in core vs. other components
- Documentation-implementation mismatch creates confusion

**Recommendation**: 
- Either rename to `gdsentry.orchestration` or `gdsentry.execution`
- OR split into `gdsentry.core` (config, models, exceptions) and `gdsentry.execution` (runner, discovery, reporter)
- Update documentation to reflect actual scope

**Severity**: MEDIUM - Architectural clarity issue, not a functional problem

---

#### 2. Reporter Coordination with GDScript Layer 🔶 HIGH

**Evidence**:
- `reporter.py:1-172` - Python-side test reporter
- Known to exist: GDScript reporters in `tests/framework/reporters/` (from Tier 1 component topology)
- **No clear coordination mechanism visible in Python code**

**Problem** (from Tier 1 notes):
- How does `reporter.py:TestReporter` coordinate with GDScript-side reporters?
- Test output must flow: GDScript → Container → Python → Reporter
- Output parsing happens in `runner.py:_parse_test_output` (private method)
- Cross-language boundary not clearly documented

**Questions**:
- Does GDScript output to stdout in specific format?
- Is there a protocol for test result communication?
- How are GDScript assertions counted (seen in `TestSummary.total_assertions`)?

**Impact**: 
- Python-GDScript boundary is architecturally significant
- Unclear how test execution flow crosses language boundary
- Potential brittleness if format assumptions change

**Recommendation**: Investigate in Tier 3 cross-component analysis

**Severity**: HIGH - Core execution flow crosses unclear boundary

---

#### 3. TestRunner Complexity and Size 🔶 MEDIUM

**Evidence**: `runner.py` is 484 lines, largest file in core/

**Responsibilities** (multiple):
1. Container lifecycle management (create, cleanup)
2. Test execution orchestration (framework vs. project)
3. Output parsing (regex parsing of GDScript output)
4. Result aggregation (TestResult, TestSummary creation)
5. Streaming coordination (Generator-based output)
6. Error handling (cleanup on failure)

**Problem**:
- Single class with multiple high-level responsibilities
- runner.py:253-400+ contains complex parsing logic
- Mixing infrastructure concerns (container) with output parsing

**Impact**:
- Harder to test individual responsibilities
- Changes to parsing affect container management and vice versa
- Difficult to understand full execution flow

**Recommendation**: Consider extracting:
- `OutputParser` - Parse GDScript test output
- `ResultAggregator` - Build TestResult and TestSummary
- Keep `TestRunner` focused on orchestration only

**Severity**: MEDIUM - Manageable now, but growth will increase complexity

---

#### 4. Tight Coupling to Container Management 🔶 MEDIUM

**Evidence**: 
- `runner.py:10` - Direct import of `ContainerManager`
- `runner.py:210,218,247` - Multiple calls to container manager methods
- Test execution cannot work without container infrastructure

**Problem**:
- Core Engine is tightly bound to Container component
- Cannot execute tests without container (even for simple cases)
- Makes local GDScript execution harder to add later

**Trade-off Analysis**:
- **PRO**: Container-based execution is core architectural decision
- **PRO**: Provides cross-architecture support (main feature)
- **CON**: Limits execution flexibility
- **CON**: Makes testing Core Engine harder (needs container infra)

**Impact**: 
- Dependency injection helps (optional `container_manager` parameter)
- But execution path always goes through container
- Future features (local execution) would require significant refactoring

**Recommendation**: Acceptable trade-off for current architecture, but note for future

**Severity**: MEDIUM - Architectural coupling that matches design intent

---

### Documentation Gaps

#### 1. Orchestration Role Not Documented 📝

**Gap**: `architecture.rst:64-70` describes core as "Configuration, models, and exceptions" but omits:
- `runner.py` - Test execution orchestration
- `discovery.py` - Test file discovery
- `reporter.py` - Result reporting

**Impact**: Documentation understates Core Engine's central role in test execution

**Recommendation**: Update architecture.rst to describe orchestration responsibilities

---

#### 2. Python-GDScript Output Protocol Undocumented 📝

**Gap**: No documentation of:
- Expected GDScript output format
- How assertions are counted and reported
- Test result communication protocol
- Parsing assumptions in `runner.py:_parse_test_output`

**Impact**: Implicit protocol makes cross-language boundary fragile

**Recommendation**: Document output format specification, investigate GDScript side in Tier 3

---

#### 3. Streaming vs. Buffered Execution Modes 📝

**Gap**: Two execution modes exist:
- `run_tests()` - Buffered, returns all results
- `run_tests_streaming()` - Generator, yields progress

**Not documented**: 
- When to use each mode
- Trade-offs between modes
- Why both modes exist

**Impact**: API users might not know which method to call

**Recommendation**: Document execution mode selection rationale

## Questions for Tier 3

### 1. Python-GDScript Boundary: Output Protocol ⚠️ HIGH PRIORITY

**Question**: How does the Python TestReporter coordinate with GDScript-side reporters?

**Context**:
- `reporter.py:TestReporter` displays results in Python
- GDScript reporters exist in `tests/framework/reporters/` (from Tier 1)
- Test execution flow: GDScript → Container → Python → Reporter
- Output parsing in `runner.py:_parse_test_output` (private method)

**What We Need to Understand**:
1. What is the expected GDScript output format?
2. Is there a defined protocol for test result communication?
3. How are assertion counts communicated from GDScript to Python?
4. How fragile is the parsing? What happens if format changes?
5. Is this protocol documented anywhere?

**Cross-Component Analysis Needed**:
- Investigate GDScript Layer (reporters, test framework)
- Map output flow from GDScript through Container to Python
- Document implicit protocol

**Impact**: HIGH - Core execution flow depends on this boundary

---

### 2. Container Dependency: Execution Flexibility 🔍 MEDIUM PRIORITY

**Question**: Could Core Engine support non-containerized test execution?

**Context**:
- `runner.py:10` - Direct dependency on ContainerManager
- All test execution goes through containers
- Container-based execution is architectural choice for cross-architecture support

**What We Need to Understand**:
1. Is containerization fundamental or implementation detail?
2. Could local GDScript execution be added without major refactoring?
3. Would local execution be useful for development scenarios?
4. What would abstraction layer look like?

**Trade-offs to Consider**:
- Flexibility vs. architectural simplicity
- Cross-architecture support vs. local execution speed
- Current tight coupling vs. future extensibility

**Impact**: MEDIUM - Future feature consideration

---

### 3. Core vs. Orchestration: Component Scope 🔍 MEDIUM PRIORITY

**Question**: Should "Core" be split into foundational and orchestration concerns?

**Context**:
- Current core contains: config, models, exceptions (foundational) + runner, discovery, reporter (orchestration)
- Name "core" suggests foundational infrastructure
- Actual implementation includes high-level orchestration

**What We Need to Understand**:
1. Do other components depend on both foundational and orchestration parts?
2. Would splitting create clearer boundaries?
3. What would dependency graph look like after split?
4. Is current organization pragmatic or problematic?

**Potential Refactoring**:
- `gdsentry.core` → config, models, exceptions only
- `gdsentry.execution` → runner, discovery, reporter
- CLI imports from both

**Impact**: MEDIUM - Architectural clarity improvement

---

### 4. TestRunner Complexity: Decomposition Opportunity 🔍 LOW PRIORITY

**Question**: Should TestRunner be decomposed into smaller, focused classes?

**Context**:
- `runner.py` is 484 lines, largest file in core
- Multiple responsibilities: container lifecycle, execution, parsing, aggregation
- Complexity manageable now but could grow

**What We Need to Understand**:
1. Are there natural seams for splitting?
2. Would extraction improve testability?
3. What are the coupling implications?
4. Is current design pragmatic for current complexity?

**Potential Decomposition**:
- `TestRunner` - Orchestration only
- `OutputParser` - Parse GDScript output
- `ResultAggregator` - Build TestResult/TestSummary
- `ExecutionCoordinator` - Container lifecycle

**Impact**: LOW - Future refactoring consideration

---

### 5. Configuration Cascade: Complexity Analysis 🔍 LOW PRIORITY

**Question**: Is the three-layer configuration cascade (env, file, defaults) necessary?

**Context**:
- `config.py:173-227` - Complex loading with priority and merging
- Supports flexibility but adds complexity
- Deep merge logic in `config.py:151-170`

**What We Need to Understand**:
1. Are all three layers used in practice?
2. Is environment variable override critical for CI/CD?
3. Could simpler approach work (e.g., file-only with env overrides)?
4. What are the real-world usage patterns?

**Trade-offs**:
- Flexibility vs. simplicity
- Production needs vs. development ergonomics
- Current design vs. YAGNI principle

**Impact**: LOW - Current design is working, evaluation for future simplification

## Notes from Tier 1
- **Documentation Status**: Documented with file-level detail in architecture.rst
- **Key Files**: runner.py (15k bytes, largest), discovery.py, reporter.py, config.py, models.py, exceptions.py
- **Size**: 14 files
- **P1 Observation**: Heart of the system; coordinates between CLI and execution layers
- **P2 Alignment**: Good match between docs and implementation (✅ mostly aligned)
- **P2 Key Interfaces**: GDSentryConfig (Pydantic model), TestRunner, TestReporter
- **Architecture Concern**: How reporter.py coordinates with GDScript reporters/ (P1 concern #3)

---

## Tier 2 Analysis Summary

**Analysis Date**: 2025-10-17
**Analyst**: Architecture Assessment Trail (Tier 2, Prompt 1)
**Status**: ✅ COMPLETE

**Key Findings**:
- **Strengths**: Strong type safety (Pydantic), clean config separation, dependency injection, self-contained discovery
- **Primary Concern**: Python-GDScript boundary coordination mechanism unclear (HIGH priority for Tier 3)
- **Scope Issue**: "Core" contains both foundational and orchestration concerns (MEDIUM - architectural clarity)
- **Complexity**: TestRunner has multiple responsibilities (484 lines) but manageable
- **Coupling**: Tight coupling to Container Management is intentional architectural decision

**Ratings Summary**:
- **Well-Defined** (2): Pattern Consistency, Interface Design
- **Partially-Defined** (4): Boundary Definition, Responsibility Clarity, Documentation Alignment, Coupling & Dependencies
- **Unclear** (0): None
- **Missing** (0): None

**Cross-Component Questions**: 5 questions raised for Tier 3, with Python-GDScript boundary as highest priority

**Self-Assessment Checklist**: ✅ All criteria met
- ✅ All six framework dimensions have ratings
- ✅ Each rating supported by concrete evidence using file:function format
- ✅ Dependencies section lists specific dependencies with file references
- ✅ Key interfaces section documents 5 primary interfaces
- ✅ 4 strengths identified with evidence
- ✅ 4 concerns identified with evidence and severity
- ✅ 3 documentation gaps explicitly noted
- ✅ 5 questions for Tier 3 raised for cross-component concerns
- ✅ P1 concern from Tier 1 (reporter coordination) investigated
- ✅ Analysis maintains architectural focus (no code-quality nitpicks)
