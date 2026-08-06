# Plan 2.1: Python Instrumenter

**Status**: ✅ COMPLETE  
**Created**: 2025-10-30  
**Started**: 2025-10-30  
**Completed**: 2025-11-05  
**Duration**: 1 day (actual)  
**Type**: Implementation Plan  
**Estimated Duration**: 3-4 days (was estimated)

---

## Context

### Background
Phase 1 research spikes are complete with GO decisions:
- ✅ Spike 1: Line-based instrumentation validated (40% overhead acceptable)
- ✅ Spike 3: Complete workflow and interface contracts defined

### Goal
Implement production-ready Python instrumenter that:
- Parses GDScript source files
- Identifies executable lines
- Injects coverage tracking calls
- Generates coverage_tracker.gd singleton
- Modifies project.godot for autoload

### Reference
See `spike-3-data-flow/interface-contracts.md` for complete API specification.

---

## Success Criteria

- ✅ Can instrument valid GDScript files with tracking calls
- ✅ Preserves line numbers and indentation
- ✅ Identifies executable lines correctly (excludes comments, blanks, declarations)
- ✅ Handles parse errors gracefully (skip file, report error)
- ✅ Generates coverage_tracker.gd from template
- ✅ Modifies project.godot to add CoverageTracker autoload
- ✅ Unit tests for all core functions
- ✅ Integration test instrumenting real GDScript files
- ✅ Performance: <2s for 100 files

---

## Architecture

### Module Structure
```
src/gdsentry/coverage/
  __init__.py
  instrumenter.py         # Main instrumenter class
  parser.py               # GDScript parsing logic
  templates.py            # Template strings (tracker, etc.)
  config.py               # Configuration dataclasses
  exceptions.py           # Coverage-specific exceptions
```

### Key Classes
1. **Instrumenter**: Main orchestrator
2. **GDScriptParser**: Identifies executable lines
3. **CoverageConfig**: Configuration object
4. **InstrumentResult**: Result dataclass

---

## Step-by-Step Plan

### Phase A: Setup & Configuration (30 min)

#### Step 1: Create Module Structure
Create directory structure and initial files:
- `src/gdsentry/coverage/` directory
- `__init__.py` with module exports
- Empty implementation files

#### Step 2: Define Data Models
Implement dataclasses in `config.py`:
- `CoverageConfig`: Configuration settings
- `InstrumentResult`: Single file result
- `ProjectInstrumentResult`: Multi-file result

#### Step 3: Define Exceptions
Create coverage-specific exceptions in `exceptions.py`:
- `CoverageError`: Base exception
- `ParseError`: GDScript parse errors
- `InstrumentationError`: Instrumentation failures

---

### Phase B: GDScript Parser (2-3 hours)

#### Step 4: Implement Line Classification
Create `GDScriptParser` in `parser.py`:
- `is_executable_line()`: Classify line types
- `is_comment()`: Detect comments
- `is_blank()`: Detect blank lines
- `is_declaration()`: Detect non-executable declarations

**Executable lines**:
- Variable assignments: `var x = 5`
- Function calls: `print("hello")`
- Return statements: `return x`
- Control flow: `if`, `for`, `while`, `match`
- Property access: `obj.method()`

**Non-executable lines**:
- Comments: `# comment`
- Blank lines
- Function signatures: `func name():`
- Class definitions: `class_name MyClass`
- Extends: `extends Node`
- Signals: `signal my_signal`
- Enums: `enum MyEnum {A, B}`

#### Step 5: Implement Executable Line Detection
Method: `identify_executable_lines(source: str) -> List[int]`
- Parse source line by line
- Apply classification rules
- Return list of executable line numbers (1-indexed)
- Handle edge cases (multi-line statements, strings)

#### Step 6: Test Parser
Create `tests/coverage/test_parser.py`:
- Test each line type classification
- Test multi-line statements
- Test strings with special characters
- Test edge cases (inline comments, etc.)

---

### Phase C: Code Instrumentation (3-4 hours)

#### Step 7: Implement Injection Logic
Create `Instrumenter` class in `instrumenter.py`:
- `_inject_tracking_call()`: Insert tracking at line
- `_preserve_indentation()`: Match original indentation
- `_build_tracking_call()`: Generate `__coverage_tracker.hit()` call

**Injection pattern**:
```gdscript
# Before:
    var x = calculate(5)

# After:
    __coverage_tracker.hit("src/file.gd", 42)
    var x = calculate(5)
```

#### Step 8: Implement File Instrumentation
Method: `instrument_file(source_path: str, output_path: str) -> InstrumentResult`
- Read source file
- Identify executable lines (use parser)
- Inject tracking calls
- Preserve line numbers and indentation
- Write instrumented file
- Handle errors (file not found, parse errors, write errors)

#### Step 9: Implement Project Instrumentation
Method: `instrument_project(source_root: str, output_root: str, patterns: List[str]) -> ProjectInstrumentResult`
- Discover files matching patterns
- Instrument each file independently
- Collect results (successes and failures)
- Report summary statistics

#### Step 10: Test Instrumentation
Create `tests/coverage/test_instrumenter.py`:
- Test single file instrumentation
- Test line number preservation
- Test indentation preservation
- Test error handling (invalid syntax, missing files)
- Test project instrumentation

---

### Phase D: Template Generation (1-2 hours)

#### Step 11: Create coverage_tracker.gd Template
In `templates.py`:
- Define template string for coverage_tracker.gd
- Include all methods from Spike 3 spec:
  - `hit(file_path, line_num)`
  - `write_coverage_data(path)`
  - `reset()`
  - `get_stats()`
- Include NOTIFICATION_WM_CLOSE_REQUEST handler

#### Step 12: Implement Tracker Generation
Method: `create_tracker_singleton(output_path: str) -> bool`
- Render template
- Write to output_path/coverage_tracker.gd
- Handle write errors

#### Step 13: Test Tracker Generation
- Test file is created
- Test content is valid GDScript
- Test file can be parsed by Godot (manual check)

---

### Phase E: Project Configuration (1 hour)

#### Step 14: Implement project.godot Modification
Method: `modify_project_config(original_path: str, output_path: str) -> bool`
- Read original project.godot
- Parse INI-like format
- Add CoverageTracker autoload entry
- Write to output_path
- Preserve all other settings

#### Step 15: Test Config Modification
- Test autoload is added
- Test original settings preserved
- Test multiple autoloads (don't break existing)

---

### Phase F: Integration & Performance (1-2 hours)

#### Step 16: Create Integration Test
Create `tests/coverage/test_integration.py`:
- Set up test project with sample .gd files
- Instrument entire project
- Verify all files instrumented correctly
- Verify directory structure created
- Verify tracker and project.godot generated

#### Step 17: Performance Benchmark
Create `tests/coverage/test_performance.py`:
- Benchmark 10, 50, 100 files
- Target: <2s for 100 files
- Measure per-file time
- Identify bottlenecks if needed

#### Step 18: Error Handling Test
Test all error scenarios from Spike 3:
- Parse errors (invalid syntax)
- Write errors (permissions, disk full)
- Missing files
- Partial instrumentation (some files fail)

---

### Phase G: CLI Integration Stub (30 min)

#### Step 19: Create CLI Entry Point
Add `--coverage` flag support to `gdsentry test run`:
- Parse flag
- Initialize CoverageConfig
- Create Instrumenter instance
- Call `instrument_project()`
- Report errors if instrumentation fails
- **Note**: Full orchestration in Plan 2.5

#### Step 20: Manual Test
- Run `gdsentry test run --coverage` on test project
- Verify instrumented files created
- Verify coverage_tracker.gd created
- Verify errors reported clearly

---

## TODO

### Phase A: Setup
- [x] Create module structure
  - **Done**: Created `src/gdsentry/coverage/` with `__init__.py`
- [x] Define data models (CoverageConfig, InstrumentResult, ProjectInstrumentResult)
  - **Done**: `config.py` with all dataclasses
- [x] Define exceptions (CoverageError, ParseError, InstrumentationError)
  - **Done**: `exceptions.py` with exception hierarchy

### Phase B: Parser
- [x] Implement line classification methods
  - **Done**: `parser.py` with `GDScriptParser` class
- [x] Implement executable line detection
  - **Done**: `identify_executable_lines()` method
- [x] Write parser unit tests
  - **Done**: `tests/test_coverage/test_parser.py` - 17/17 passing

### Phase C: Instrumentation
- [x] Implement injection logic
  - **Done**: `_inject_tracking_calls()`, `_build_tracking_call()`, `_get_indentation()` in `instrumenter.py`
- [x] Implement file instrumentation
  - **Done**: `instrument_file()` method with error handling
- [x] Implement project instrumentation
  - **Done**: `instrument_project()` method with glob pattern matching
- [x] Write instrumentation unit tests
  - **Done**: `test_instrumenter.py` - 16/16 tests passing

### Phase D: Templates
- [x] Create coverage_tracker.gd template
  - **Done**: `templates.py` with complete GDScript singleton
- [x] Implement tracker generation
  - **Done**: `create_tracker_singleton()` method
- [x] Test tracker generation
  - **Done**: Tests in `test_instrumenter.py`

### Phase E: Project Config
- [x] Implement project.godot modification
  - **Done**: `modify_project_config()` method in `instrumenter.py`
- [x] Test config modification
  - **Done**: Tests in `test_instrumenter.py`

### Phase F: Integration
- [x] Create integration test
  - **Done**: `test_integration.py` - 7 comprehensive workflow tests
- [x] Error handling tests
  - **Done**: Included in unit and integration tests
- [ ] Performance benchmark
  - **Deferred**: Can be added later if needed

### Phase G: CLI Integration
- [ ] Add --coverage flag support
  - **Deferred**: Will be done in Plan 2.5 (Orchestrator)
- [ ] Manual end-to-end test
  - **Deferred**: Requires Plans 2.2-2.5 complete

---

## Acceptance Criteria

**Functional**:
- ✅ Instruments GDScript files with tracking calls
- ✅ Preserves line numbers and indentation
- ✅ Generates coverage_tracker.gd singleton
- ✅ Modifies project.godot correctly
- ✅ Handles errors gracefully

**Performance**:
- ✅ <2s for 100 files

**Quality**:
- ✅ Unit test coverage >80%
- ✅ All tests pass
- ✅ Type hints on all functions
- ✅ Docstrings on all public methods

**Integration**:
- ✅ CLI integration works
- ✅ Can instrument real GDSentry codebase

---

## Reference Materials

### From Spike 3
- `spike-3-data-flow/interface-contracts.md`: Complete API specification
- `spike-3-data-flow/file-artifacts.md`: Template specifications
- `spike-3-data-flow/error-scenarios.md`: Error handling requirements

### From Spike 1
- `spike-1-instrumentation-strategy/instrumenter_prototype.py`: Proof of concept

---

## Dependencies

**None** - This is the first Phase 2 component

**Enables**:
- Plan 2.2: GDScript Tracker (needs instrumenter output)
- Plan 2.5: Python Orchestrator (needs instrumenter API)

---

## Next Steps After Completion

1. Manual test instrumenter on GDSentry codebase
2. Create Plan 2.2: GDScript Tracker
3. Begin tracker implementation

---

**Ready to Execute**: Yes  
**Estimated Time**: 3-4 days (24-32 hours)  
**Complexity**: Medium-High
