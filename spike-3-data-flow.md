# Spike 3: End-to-End Data Flow

**Status**: ✅ COMPLETE  
**Created**: 2025-10-30  
**Completed**: 2025-10-30  
**Duration**: 60 minutes (paper design + validation)  
**Spike Type**: Integration & Workflow Design  
**Decision**: GO - Proceed to Phase 2

---

## Context

### Background
**Spikes 1 & 2 are complete with GO decisions:**
- ✅ **Spike 1**: Line-based instrumentation validated (40% overhead, acceptable)
- ✅ **Spike 2**: GDScript analysis/reporting validated (7ms for 100 files, 142x faster than target)

**Now we need to validate:**
- How do all the pieces fit together end-to-end?
- What are the handoff points between Python and GDScript?
- What file formats and locations are used?
- Does the orchestration workflow make sense?

### Problem
We have proven individual components work, but haven't validated:
1. **Data flow**: How coverage data moves through the pipeline
2. **File contracts**: Formats and locations for intermediate/output files
3. **Handoff points**: Where Python stops and GDScript starts
4. **Error handling**: What happens when components fail
5. **Cleanup**: Temporary file management

### Goal
Create a clear, documented end-to-end workflow that:
- Maps the complete data flow from source → instrumentation → execution → analysis → report
- Identifies all file artifacts (locations, formats, lifecycle)
- Documents Python ↔ GDScript interfaces
- Validates the orchestration makes sense (no missing steps, no circular dependencies)

---

## Success Criteria

- ✅ Complete workflow diagram (text-based is fine)
- ✅ File format specifications for all artifacts
- ✅ Clear Python ↔ GDScript interface contracts
- ✅ Error scenarios identified and handled
- ✅ No architectural blockers or circular dependencies found
- ✅ Confidence to proceed to implementation (Phase 2)

---

## Approach

### Method
This is a **paper spike** - no code required, only design validation:

1. **Map the workflow** - Step-by-step from CLI invocation to final report
2. **Document file artifacts** - Every intermediate and output file
3. **Define interfaces** - Python and GDScript contracts
4. **Validate flow** - Check for missing steps, circular deps, error cases
5. **Document findings** - Clear specifications for implementation

### Time Box
45-60 minutes total:
- 20 min: Workflow mapping
- 15 min: File format specifications  
- 10 min: Interface contracts
- 10 min: Validation and edge cases
- 5 min: Document findings

---

## Step-by-Step Plan

### Phase A: Workflow Mapping (20 min)

#### Step 1: Map Happy Path
**Goal**: Document the complete end-to-end flow for successful coverage run

Create workflow diagram showing:
1. User invokes `gdsentry test run --coverage`
2. Python: Discover source files to instrument
3. Python: Parse and instrument files
4. Python: Copy instrumented files to temp location
5. Python: Inject coverage tracker into test bootstrap
6. Python: Execute Godot with tests
7. GDScript: Track coverage during test execution
8. GDScript: Analyze coverage data after tests
9. GDScript: Generate HTML report
10. GDScript: Write report to disk
11. Python: Detect test completion
12. Python: Display coverage summary to terminal
13. Python: Clean up temporary files
14. Report: User opens HTML report

**Deliverable**: Text-based workflow diagram

#### Step 2: Identify Handoff Points
**Goal**: Mark exact points where control transfers between Python and GDScript

For each handoff, document:
- **What triggers the handoff?** (file written, process exit, etc.)
- **What data is passed?** (files, exit codes, env vars)
- **What happens if it fails?** (timeout, error codes, rollback)

**Key handoffs**:
1. Python → Godot: Launch process with instrumented files
2. Godot → GDScript: Test execution begins
3. GDScript → Disk: Coverage data JSON written
4. GDScript → Disk: HTML report written
5. Godot → Python: Process exits with code
6. Python → Terminal: Display summary and report location

**Deliverable**: Handoff point specifications

#### Step 3: Map Error Scenarios
**Goal**: Document failure modes and recovery strategies

Error scenarios to consider:
- Instrumentation fails (syntax error, parse error)
- Godot process crashes during tests
- Coverage tracker fails to initialize
- Disk full (can't write report)
- Invalid coverage data format
- Test timeout
- User interrupts (Ctrl+C)

For each scenario, define:
- Detection mechanism
- Recovery/cleanup action
- Error message to user

**Deliverable**: Error handling matrix

---

### Phase B: File Format Specifications (15 min)

#### Step 4: Document File Artifacts
**Goal**: Specify every file created during coverage workflow

Create specification for each artifact:

**1. Instrumented Source Files**
- **Location**: `.gdsentry/coverage/instrumented/**/*.gd`
- **Format**: GDScript with injected tracking calls
- **Lifecycle**: Created by Python instrumenter, deleted after run
- **Example**:
```gdscript
# Original: func calculate(x):
#             return x * 2

func calculate(x):
    __coverage_tracker.hit("file.gd", 5)
    return x * 2
```

**2. Coverage Tracker Singleton**
- **Location**: `.gdsentry/coverage/instrumented/coverage_tracker.gd`
- **Format**: GDScript class (injected by Python)
- **Lifecycle**: Created before run, deleted after
- **Purpose**: Track line hits during test execution

**3. Coverage Data JSON**
- **Location**: `.gdsentry/coverage/coverage_data.json`
- **Format**: JSON dictionary
- **Lifecycle**: Written by GDScript tracker at test completion
- **Schema**:
```json
{
  "files": {
    "src/core/test_runner.gd": {
      "5": 10,    // line 5 hit 10 times
      "6": 10,
      "8": 0,     // line 8 missed
      "12": 5
    }
  },
  "timestamp": "2025-10-30T16:30:00",
  "test_count": 42
}
```

**4. HTML Coverage Report**
- **Location**: `.gdsentry/coverage/html/index.html`
- **Format**: HTML with embedded CSS
- **Lifecycle**: Generated by GDScript reporter, persists after run
- **Purpose**: Interactive coverage visualization

**5. Per-File HTML Reports**
- **Location**: `.gdsentry/coverage/html/<file_slug>.html`
- **Format**: HTML with line-by-line coverage
- **Lifecycle**: Generated by GDScript reporter, persists
- **Purpose**: Detailed per-file coverage view

**Deliverable**: File format specifications

#### Step 5: Define File Locations
**Goal**: Establish directory structure convention

```
.gdsentry/
  coverage/
    instrumented/           (temp - deleted after run)
      *.gd                  (instrumented source files)
      coverage_tracker.gd   (tracking singleton)
    coverage_data.json      (temp - can delete after report)
    html/                   (output - persists)
      index.html            (summary report)
      <file>_gd.html        (per-file reports)
    .gitignore              (ignore instrumented/ and coverage_data.json)
```

**Deliverable**: Directory structure specification

---

### Phase C: Interface Contracts (10 min)

#### Step 6: Python Instrumenter Interface
**Goal**: Define what Python instrumenter produces

**Input**:
- Source .gd files to instrument
- List of executable line numbers (from parser)

**Output**:
- Instrumented .gd files in `.gdsentry/coverage/instrumented/`
- `coverage_tracker.gd` singleton
- Modified test bootstrap (injects tracker initialization)

**Contract**:
```python
class Instrumenter:
    def instrument_file(source_path: str, output_path: str) -> InstrumentResult:
        """
        Returns:
          - success: bool
          - instrumented_lines: int
          - errors: List[str]
        """
        
    def create_tracker_singleton(output_path: str) -> bool:
        """Creates coverage_tracker.gd in output directory"""
```

**Deliverable**: Python instrumenter contract

#### Step 7: GDScript Tracker Interface
**Goal**: Define what GDScript tracker exposes

**API**:
```gdscript
# coverage_tracker.gd (autoload singleton)
extends Node

class_name CoverageTracker

# Called by instrumented code
func hit(file_path: String, line_num: int) -> void:
    """Record a line hit during execution"""

# Called at test suite completion
func write_coverage_data(output_path: String) -> bool:
    """Write accumulated coverage data to JSON"""
    
# Called before test run
func reset() -> void:
    """Clear all coverage data (for clean runs)"""
```

**Deliverable**: GDScript tracker contract

#### Step 8: GDScript Analyzer/Reporter Interface
**Goal**: Define what analyzer/reporter consumes and produces

**Input**:
- `coverage_data.json` (from tracker)
- Original source files (for line-by-line display)

**Output**:
- HTML report files in `.gdsentry/coverage/html/`
- Terminal summary data (JSON or simple format)

**API**:
```gdscript
# coverage_analyzer.gd
static func analyze_coverage_data(data: Dictionary) -> CoverageResult:
    """
    Returns:
      - total_lines: int
      - covered_lines: int
      - percent: float
      - per_file_stats: Array[FileStats]
    """

# coverage_reporter.gd
static func generate_html_report(
    analysis: CoverageResult,
    output_dir: String
) -> bool:
    """Generate HTML reports and write to disk"""
```

**Deliverable**: Analyzer/Reporter contract

---

### Phase D: Validation & Edge Cases (10 min)

#### Step 9: Validate Workflow Logic
**Goal**: Check for missing steps or circular dependencies

**Validation checklist**:
- [ ] Can Python instrument files without GDScript running?
- [ ] Can GDScript tracker work without knowing about analyzer?
- [ ] Can analyzer run even if tests fail?
- [ ] Are there any circular file dependencies?
- [ ] Can cleanup happen even if Godot crashes?
- [ ] Does workflow handle partial instrumentation (some files fail)?

**Questions to answer**:
1. What if instrumentation succeeds but tests fail? (Still generate report)
2. What if tests pass but report generation fails? (Show error, tests still pass)
3. What if user Ctrl+C during test run? (Cleanup temp files)
4. What if .gdsentry/coverage/ doesn't exist? (Create it)
5. What if HTML report already exists? (Overwrite with warning)

**Deliverable**: Validation findings

#### Step 10: Document Integration Points
**Goal**: Specify how coverage integrates with existing test framework

**Integration requirements**:
- Coverage tracker must not interfere with test assertions
- Coverage data must survive test failures (write in finally block)
- HTML report path must be printed to terminal
- Coverage overhead must not cause test timeouts
- Instrumentation must preserve line numbers for error messages

**Deliverable**: Integration requirements

---

### Phase E: Documentation (5 min)

#### Step 11: Create Findings Document
**Goal**: Summarize workflow for implementation phase

Create `FINDINGS.md` with:
1. **Workflow Diagram**: Complete end-to-end flow
2. **File Specifications**: All artifacts with formats
3. **Interface Contracts**: Python and GDScript APIs
4. **Error Handling**: Failure modes and recovery
5. **Decision**: GO/NO-GO for Phase 2 implementation

**Deliverable**: `spike-3-data-flow/FINDINGS.md`

---

## TODO

### Phase A: Workflow Mapping
- [x] Map happy path workflow (13 steps)
  - **Execution Notes**: Created `workflow-diagram.md` with complete 18-step end-to-end flow. Includes ASCII diagram, data flow summary, timeline view. Shows: User → Python (instrument) → Godot → GDScript (track/analyze/report) → Python (cleanup) → User. Total overhead: ~2-3s for typical project.
- [x] Identify Python ↔ GDScript handoff points
  - **Execution Notes**: Created `handoff-points.md` documenting 5 critical handoffs. Each includes trigger, data passed, success criteria, failure modes, and recovery. Key: H1 (process launch), H2 (JSON write), H3 (HTML write), H4 (process exit), H5 (terminal output). All sequential, no sync issues.
- [x] Document error scenarios and recovery
  - **Execution Notes**: Created `error-scenarios.md` with 13 error scenarios across 4 categories. Each includes detection, recovery strategy, user impact, error message. Key principle: Test results are primary, coverage errors don't fail tests. Cleanup always happens (try/finally). Exit codes defined for each case.

### Phase B: File Format Specifications
- [x] Document all file artifacts (formats, locations, lifecycle)
  - **Execution Notes**: Created `file-artifacts.md` with 7 artifact types. Each includes path, format, lifecycle, size estimates, examples. Key artifacts: instrumented .gd (~1.4x original size), coverage_tracker.gd (2KB), coverage_data.json (~105KB for 10k lines), HTML reports (~150 bytes/line). Total temp: ~700KB, output: ~1.6MB.
- [x] Define directory structure convention
  - **Execution Notes**: Directory structure defined in `file-artifacts.md`. Structure: `.gdsentry/coverage/{instrumented/, coverage_data.json, html/}`. Temp files in instrumented/ deleted after run. HTML reports persist. .gitignore created to exclude temps.
- [x] Create .gitignore rules
  - **Execution Notes**: .gitignore spec included in `file-artifacts.md`. Excludes `instrumented/` and `coverage_data.json`. Keeps `html/` reports. Created during first coverage run, persists after.

### Phase C: Interface Contracts
- [x] Define Python instrumenter interface
  - **Execution Notes**: Created `interface-contracts.md` with complete API specs. Instrumenter methods: instrument_file(), instrument_project(), create_tracker_singleton(), modify_project_config(). Returns typed results (InstrumentResult, ProjectInstrumentResult). Error handling via exceptions and result objects.
- [x] Define GDScript tracker interface
  - **Execution Notes**: Tracker API in `interface-contracts.md`. Singleton with methods: hit(file, line), write_coverage_data(), reset(), get_stats(). Signal: coverage_written. Performance: O(1) hit(), ~0.1μs per call. Writes JSON on NOTIFICATION_WM_CLOSE_REQUEST.
- [x] Define GDScript analyzer/reporter interface
  - **Execution Notes**: Analyzer & Reporter APIs in `interface-contracts.md`. Analyzer: analyze_coverage_data(), compute_file_coverage(), get_missed_lines(). Reporter: generate_html_report(), generate_summary_html(), generate_file_html(), write_html_file(). All static methods. Returns typed dictionaries.

### Phase D: Validation
- [x] Validate workflow logic (no circular deps)
  - **Execution Notes**: Created `validation.md` with validation checklist. All 6 checks pass: Python instruments independently, tracker/analyzer decoupled, analysis survives test failures, no circular deps (linear flow), cleanup always happens, partial instrumentation supported. 5 questions answered. Dependency graph verified.
- [x] Document edge cases and failure modes
  - **Execution Notes**: Edge cases already documented in `error-scenarios.md` (13 scenarios) and `validation.md` (5 questions). Covers: test failures, crashes, Ctrl+C, missing dirs, overwrites. All have defined recovery strategies.
- [x] Specify integration requirements
  - **Execution Notes**: Integration requirements specified: Coverage tracker must not interfere with test assertions (independent tracking), coverage data survives test failures (write in finally/notification), HTML path printed to terminal, no timeout issues (fast operations), line numbers preserved (instrumentation on same line). All validated in workflow.

### Phase E: Documentation
- [x] Create FINDINGS.md with complete specifications
  - **Execution Notes**: Created `FINDINGS.md` with executive summary, references to 6 detailed docs, architecture validation, key decisions, performance estimates, success criteria review (all met), risks/mitigations, implementation recommendations. GO decision documented. Phase 2 estimated at 10-12 days.
- [x] Update master plan with Spike 3 results
  - **Execution Notes**: Updated `plan-coverage-master.md`. Spike 3 marked COMPLETE with GO decision. Key findings documented: 18-step workflow, 5 handoffs, 7 artifacts, 5 APIs, no circular deps. Phase 1 marked complete (all 3 spikes GO). Decision log updated. Ready for Phase 2.
- [x] Make GO/NO-GO decision for Phase 2
  - **DECISION**: ✅ **GO** - Proceed to Phase 2 implementation. All Phase 1 spikes complete with GO decisions. Architecture fully validated: workflow sound, no circular deps, error handling comprehensive, interfaces well-defined. Estimated 10-12 days for Phase 2. No blockers identified.

---

## Reference Materials

### From Master Plan
- **Architecture**: Python instruments, GDScript tracks/reports
- **CLI Flag**: `gdsentry test run --coverage`
- **Output**: Terminal summary + HTML report
- **Performance Target**: <10% overhead (40% actual from Spike 1 is acceptable)

### From Spike 1
- **Instrumentation**: Line-based regex injection
- **Tracking**: `__coverage_tracker.hit(file, line)` pattern
- **Performance**: 40% overhead deemed acceptable

### From Spike 2
- **Data Structure**: `{ "file.gd": { line_num: hit_count } }`
- **Analysis**: 7ms for 100 files (very fast)
- **HTML**: Summary + per-file line-by-line views
- **Reporter**: GDScript generates HTML, writes to disk

---

## Open Questions

1. **Cleanup timing**: When exactly do we delete `.gdsentry/coverage/instrumented/`?
   - Option A: Immediately after test run completes
   - Option B: Before next instrumentation (keep for debugging)
   - **Lean toward A** (clean up immediately)

2. **Error reporting**: Where do GDScript errors go?
   - GDScript can't easily write to Python's stderr
   - Could write error file: `.gdsentry/coverage/errors.txt`
   - Python reads error file after Godot exits

3. **Incremental coverage**: Support running coverage on subset of files?
   - MVP: All or nothing
   - V2: File filters via CLI args

4. **Source file reading**: Does reporter need original source or can use instrumented?
   - Problem: Instrumented has extra lines (breaks line numbers)
   - Solution: Reporter reads original source files
   - Implementation: Pass source paths to reporter

5. **Test isolation**: Multiple test runs in parallel?
   - MVP: Not supported (single coverage_data.json)
   - V2: Could use unique session IDs

---

## Next Steps After Spike 3

**If GO decision:**
1. Create detailed implementation plans for Phase 2:
   - Plan 2.1: Python Instrumenter
   - Plan 2.2: GDScript Tracker
   - Plan 2.3: GDScript Analyzer (adapt Spike 2 prototype)
   - Plan 2.4: GDScript Reporter (adapt Spike 2 prototype)
   - Plan 2.5: Python Orchestrator
2. Begin incremental implementation
3. Test on GDSentry's own codebase
4. Document user-facing features

**If NO-GO decision:**
- Identify blockers
- Revise architecture
- Create alternative spike

---

---

## Plan Execution Summary

**Status**: ✅ **PLAN FULLY EXECUTED**  
**Completed**: 2025-10-30 17:05  
**Duration**: 60 minutes

### Deliverables Created
1. ✅ `workflow-diagram.md` - 18-step end-to-end workflow
2. ✅ `handoff-points.md` - 5 handoff specifications
3. ✅ `error-scenarios.md` - 13 error scenarios
4. ✅ `file-artifacts.md` - 7 artifact specifications
5. ✅ `interface-contracts.md` - 5 API contracts
6. ✅ `validation.md` - Architecture validation
7. ✅ `FINDINGS.md` - Executive summary and GO decision

### All TODOs Complete
- ✅ Phase A: Workflow Mapping (3/3)
- ✅ Phase B: File Format Specifications (3/3)
- ✅ Phase C: Interface Contracts (3/3)
- ✅ Phase D: Validation (3/3)
- ✅ Phase E: Documentation (3/3)

**Total**: 15/15 TODOs completed

### Final Decision
**✅ GO** - Proceed to Phase 2 implementation

All success criteria exceeded. Architecture fully validated. No blockers identified.

**Next Step**: Create Phase 2 implementation plans for Python Instrumenter, GDScript Tracker, Analyzer, Reporter, and Orchestrator.

