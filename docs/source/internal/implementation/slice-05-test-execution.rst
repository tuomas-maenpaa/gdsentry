## Slice 5: Test Discovery & Execution

**Status**: ✅ Complete  
**Dependencies**: Slice 1 (Config), Slice 2 (Platform), Slice 3 (CLI), Slice 4 (Containers)  
**Provides**: Core test functionality - discover and run GDScript tests

---

## Purpose

Implement the core testing functionality of GDSentry:
- Discover GDScript test files
- Execute tests in Godot containers
- Parse and report results
- Beautiful Rich-formatted output

This is the heart of GDSentry - what makes it a testing framework.

---

## Files Created

### Core Modules

```
src/gdsentry/core/
├── discovery.py          # Test file discovery
├── runner.py             # Test execution in containers
└── reporter.py           # Result reporting with Rich
```

### CLI Commands

```
src/gdsentry/cli/commands/
└── test.py              # Test commands (discover, run, quick)
```

### Tests

```
tests/unit/
└── test_test_execution.py   # 19 comprehensive tests
```

### Documentation

```
docs/source/internal/implementation/
└── slice-05-test-execution.rst  # This file
```

---

## Implementation Details

### Test Discovery (`discovery.py`)

**Purpose**: Find GDScript test files in the project

**Key Features**:
- Discovers test files matching `*_test.gd` pattern
- Categorizes tests by directory
- Supports filtering by scope, category, pattern
- Counts tests by category

**API**:
```python
discovery = TestDiscovery(project_root)

# Discover all tests
all_tests = discovery.discover_all()

# By scope (framework, project, both)
framework_tests = discovery.discover_by_scope("framework")

# By category (core, integration, meta, etc.)
core_tests = discovery.discover_by_category("core")

# By filter pattern
filtered = discovery.discover_by_filter("test_*_test.gd")

# Count by category
counts = discovery.count_tests()
```

**Test File Model**:
```python
class TestFile(BaseModel):
    path: Path                # Absolute path
    relative_path: Path       # Relative to project root
    name: str                 # File name
    category: str             # Category (directory)
```

### Test Runner (`runner.py`)

**Purpose**: Execute GDScript tests in containers

**Workflow**:
1. Validate container image exists
2. Create test container with Podman
3. Mount project workspace
4. Execute tests (framework or Godot headless)
5. Parse output for results
6. Cleanup container

**API**:
```python
runner = TestRunner(project_root, godot_version, architecture)

results, summary = runner.run_tests(
    test_files=discovered_tests,
    scope="project",
    timeout=300
)
```

**Result Models**:
```python
class TestResult(BaseModel):
    test_file: str
    passed: bool
    duration: float
    output: str
    error: Optional[str]

class TestSummary(BaseModel):
    total_tests: int
    passed_tests: int
    failed_tests: int
    total_suites: int
    passed_suites: int
    total_assertions: int
    passed_assertions: int
    duration: float
    all_passed: bool
```

### Test Reporter (`reporter.py`)

**Purpose**: Display test results with Rich formatting

**Features**:
- Beautiful tables for summaries
- Individual test result tables
- Error detail formatting
- Discovery result reporting
- Quick one-line summaries

**API**:
```python
reporter = TestReporter()

reporter.report_summary(summary)
reporter.report_results(results)
reporter.report_errors(results)
reporter.report_discovery(count, category_counts)
reporter.report_quick_summary(summary)
```

---

## CLI Commands

### `gdsentry test discover`

Discover test files in the project.

```bash
gdsentry test discover                    # All project tests
gdsentry test discover --scope framework  # Framework self-tests
gdsentry test discover --category core    # Specific category
gdsentry test discover --filter "*math*"  # Pattern matching
```

**Output**:
```
    Discovered Tests    
┏━━━━━━━━━━━━━━┳━━━━━━━┓
┃ Category     ┃ Count ┃
┡━━━━━━━━━━━━━━╇━━━━━━━┩
│ core         │     6 │
│ integration  │    12 │
│ meta         │    13 │
│ Total        │    31 │
└──────────────┴───────┘

Test Files:
  tests/core/test_runner_test.gd
  tests/integration/godot_patterns_test.gd
  ...
```

### `gdsentry test run`

Run tests in containers.

```bash
gdsentry test run                         # Run project tests
gdsentry test run --scope framework       # Run framework tests
gdsentry test run --category integration  # Run specific category
gdsentry test run --godot 4.2 --arch arm64  # Specific version/arch
gdsentry test run --verbose               # Show detailed results
```

**Output**:
```
Running 31 tests...
Scope: project, Godot: 4.2.2-stable, Arch: arm64

⠋ Executing tests in container...

     Test Execution Summary     
┏━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┓
┃ Metric      ┃ Result              ┃
┡━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│ Test Suites │ ✓ 5 passed, 5 total │
│ Test Cases  │ ✓ 31 passed, 31 total│
│ Assertions  │ ✓ 87 passed, 87 total│
│ Duration    │ 12.34s              │
│ Status      │ ALL TESTS PASSED    │
└─────────────┴─────────────────────┘

All tests passed! 🎉
```

### `gdsentry test quick`

Run a quick subset of tests (first 5).

```bash
gdsentry test quick                       # Quick sanity check
gdsentry test quick --scope framework     # Quick framework tests
```

**Output**:
```
Quick test (5 tests)...

⠋ Running quick tests...

✓ 5 tests passed in 3.21s
```

---

## Integration Points

### With Slice 2 (Platform)

Uses architecture detection:
```python
from gdsentry.platform import detect_architecture

arch = detect_architecture()
runner = TestRunner(project_root, godot_version, arch.value)
```

### With Slice 4 (Container Management)

Uses container manager for execution:
```python
from gdsentry.container import ContainerManager

manager = ContainerManager()
manager.create_test_container(image, name, platform)
manager.execute_in_container(name, command)
manager.cleanup_container(name)
```

### For Slice 6 (Validation)

Provides test discovery for validation:
```python
from gdsentry.core import TestDiscovery

discovery = TestDiscovery(project_root)
tests = discovery.discover_all()
# Validate test files exist, have correct structure, etc.
```

---

## Self-Tests

### Test Coverage

**Test Discovery** (6 tests):
- ✅ Discovery creation
- ✅ Discover all test files
- ✅ Discover by category
- ✅ Discover by scope (framework/project)
- ✅ Count tests by category

**Test Models** (5 tests):
- ✅ TestFile creation and string representation
- ✅ TestResult (passed/failed)
- ✅ TestSummary (empty, all passed, some failed)

**Test Reporter** (5 tests):
- ✅ Reporter creation
- ✅ Report summary (all passed)
- ✅ Report summary (some failed)
- ✅ Report individual results
- ✅ Report errors

**CLI Integration** (1 test):
- ✅ Test commands import correctly

**Total**: 19 tests, all passing

### Running Tests

```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
pytest tests/unit/test_test_execution.py -v
```

**Note**: Tests validate discovery and models; actual container execution requires Podman and built images.

---

## Design Decisions

### Why Separate Discovery from Execution?

**Decision**: Split discovery and execution into separate modules

**Rationale**:
- **Reusability**: Discovery used by validation, reporting, CI
- **Testing**: Easier to test discovery without containers
- **Performance**: Can discover once, run multiple times
- **Clarity**: Each module has single responsibility

### Why Parse Output Instead of Direct GDScript Integration?

**Decision**: Execute via `godot --headless` and parse stdout

**Rationale**:
- **Compatibility**: Works with any Godot version
- **Isolation**: Tests run in clean container environment
- **Simplicity**: No GDScript <-> Python bridge needed
- **Existing tools**: Leverages GDSentry's own test runner

### Why Both `run` and `quick` Commands?

**Decision**: Separate commands for full and quick runs

**Rationale**:
- **TDD workflow**: Quick command for rapid iteration
- **CI optimization**: Quick smoke tests before full suite
- **User experience**: Clear intent, no hidden defaults
- **Performance**: Quick runs complete in seconds

### Why Rich Tables Instead of Plain Text?

**Decision**: Use Rich for all output formatting

**Rationale**:
- **User experience**: Beautiful, modern terminal output
- **Readability**: Tables easier to scan than plain text
- **Consistency**: Matches GDSentry 2.0 design language
- **Professional**: Matches modern CLI tools (pytest, jest)

---

## Error Handling

### Image Not Found

```
✗ Container image not found: gdsentry-godot-4.2:arm64

Build it first: gdsentry build godot 4.2 --arch arm64
```

### No Tests Discovered

```
No tests discovered
```

### Test Execution Failure

```
     Test Execution Summary     
┏━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┓
┃ Metric      ┃ Result              ┃
┡━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│ Test Cases  │ ✓ 28 passed, 31 total│
│ Duration    │ 12.34s              │
│ Status      │ 3 FAILED            │
└─────────────┴─────────────────────┘

Failed Tests:

✗ tests/core/test_discovery_test.gd
  Error: Assertion failed
  [last 10 lines of output...]
```

---

## Limitations & Future Work

### Current Limitations

1. **Serial execution**: Tests run one container at a time
2. **Simple parsing**: Regex-based output parsing
3. **No watch mode**: Must manually rerun tests
4. **No filtering within files**: All tests in file run together
5. **No coverage**: No GDScript code coverage (yet)

### Future Enhancements (Post v2.0)

1. **Parallel execution**: Run multiple containers simultaneously
2. **Structured output**: JSON/XML output from GDScript
3. **Watch mode**: Auto-rerun on file changes
4. **Granular selection**: Run specific test methods
5. **Coverage reporting**: GDScript code coverage
6. **Performance tracking**: Historical performance data

---

## Usage Examples

### Discover Tests

```bash
# Discover all project tests
gdsentry test discover

# Discover framework self-tests
gdsentry test discover --scope framework

# Discover by category
gdsentry test discover --category integration

# Discover by pattern
gdsentry test discover --filter "*math*"
```

### Run Tests

```bash
# Run all project tests
gdsentry test run

# Run framework tests
gdsentry test run --scope framework

# Run specific category
gdsentry test run --category core

# Run with specific Godot version and architecture
gdsentry test run --godot 4.2 --arch x86_64

# Run with verbose output
gdsentry test run --verbose

# Run with custom timeout
gdsentry test run --timeout 600
```

### Quick Tests

```bash
# Quick sanity check (first 5 tests)
gdsentry test quick

# Quick framework tests
gdsentry test quick --scope framework
```

---

## Validation Checklist

✅ **Implementation**:
- [x] Test discovery module complete
- [x] Test runner functional
- [x] Test reporter with Rich formatting
- [x] CLI commands work
- [x] Circular import fixed

✅ **Testing**:
- [x] 19 unit tests pass
- [x] Discovery finds real test files
- [x] Models validate correctly
- [x] Reporter generates tables

✅ **Documentation**:
- [x] ARCHITECTURE.md updated
- [x] This slice document complete
- [x] Integration points documented
- [x] Usage examples provided

✅ **CLI**:
- [x] `test discover` works
- [x] `test run` works
- [x] `test quick` works
- [x] Help text clear
- [x] Error messages actionable

---

## Next Steps

**Ready for Slice 6**: Validation Tools

Slice 6 will use test discovery to:
- Validate GDScript syntax
- Check Python imports
- Verify license headers
- Check documentation links

---

## Checkpoint

**Slice 5 is complete and validated.**

Test the commands:
```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry

# Discover tests
python -m gdsentry test discover

# Show test command help
python -m gdsentry test run --help

# Run tests (requires Podman and built images)
python -m gdsentry test run

# Run all self-tests
pytest tests/unit/ -v
```

**Expected**: Beautiful CLI with test commands, 100 tests passing.

---

## Summary

**Slice 5 delivers the core value of GDSentry**: discovering and running GDScript tests in containers with beautiful, professional output.

**Key achievements**:
- ✅ 3 new core modules (discovery, runner, reporter)
- ✅ 3 CLI commands (discover, run, quick)
- ✅ 19 comprehensive tests
- ✅ Integration with Slices 1-4
- ✅ Beautiful Rich-formatted output
- ✅ Professional error handling
- ✅ Clean circular import resolution

**Total progress**: 100 tests passing across 5 slices! 🎉

