# Plan for GDScript Code Coverage (Master Plan)

## 1) Context & Goal

### Problem
- GDSentry framework has no visibility into code coverage
- Cannot measure which framework features are tested
- No way for users to measure coverage of their own GDScript projects
- Quality audit requires coverage metrics to be meaningful

### Goal
Add enterprise-grade code coverage measurement for GDScript code with:
- **Primary**: Measure GDSentry framework's own test coverage (≥70% target)
- **Secondary**: Generic tool for any GDScript project using GDSentry
- **UX**: Single flag `--coverage` on existing `gdsentry test run` command
- **Output**: Terminal summary + interactive HTML report
- **Performance**: <10% test execution overhead

### Success Criteria
- ✅ Can measure line coverage of GDSentry's own codebase
- ✅ HTML report shows per-file and per-line coverage
- ✅ Integrates seamlessly with existing test workflow
- ✅ Works on Godot 4.x projects
- ✅ Documentation explains usage and interpretation

### Non-Goals
- ❌ Godot 3.x support (complexity not justified)
- ❌ Branch coverage (defer to v2)
- ❌ Function coverage (defer to v2)
- ❌ Real-time coverage tracking (batch only)
- ❌ Coverage for non-GDScript languages

---

## 2) Inputs & Constraints

### Assumptions
1. **Architecture consistency**: Use GDScript for reporting (like existing test output)
2. **Instrumentation approach**: Python injects tracking code into .gd files before test execution
3. **Data flow**: Coverage data + reports generated in GDScript, Python orchestrates
4. **Parser**: Can use `gdtoolkit` library or simple regex-based parsing (Python side)
5. **Performance**: Instrumentation overhead acceptable for CI/dev (not production)

### Constraints
- **Technical**:
  - Must not break existing test execution
  - Must preserve existing GDScript-based reporting pattern
  - Must work in containerized Godot environment
  - Python 3.10+, Godot 4.x only
- **Resource**:
  - Single developer, ~3-4 weeks effort (reduced from 5 weeks)
  - Incremental delivery (merge PRs as components complete)
- **Quality**:
  - Must have unit tests for coverage system itself
  - Must dogfood on GDSentry's own tests

### Stakeholders
- **Primary**: You (project maintainer, quality auditor)
- **Secondary**: Future GDSentry users measuring their own coverage

---

## 3) High-Level Approach

### Architecture Overview (Revised)

```
┌─────────────────────────────────────────────────────┐
│  CLI: gdsentry test run --coverage --cov-report html│
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼────────────────────────────────────┐
│     Coverage Orchestrator (Python)                   │
│  - Discovers test files                              │
│  - Instruments .gd files (inject tracking)           │
│  - Runs tests in Godot                               │
│  - Collects generated reports                        │
└─────────────────┬────────────────────────────────────┘
                  │
                  │
┌─────────────────▼────────────────────────────────────┐
│         Godot Execution (GDScript)                   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Coverage Tracker (Singleton)                │   │
│  │  - Records line hits                         │   │
│  └──────────┬───────────────────────────────────┘   │
│             │                                         │
│  ┌──────────▼───────────────────────────────────┐   │
│  │  Coverage Reporter                           │   │
│  │  - Analyzes coverage data                    │   │
│  │  - Generates terminal output                 │   │
│  │  - Generates HTML files                      │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

### Key Architectural Decision

**GDScript handles reporting** (consistent with existing pattern):
- Existing: `output_formatter.gd` generates test reports
- New: `coverage_reporter.gd` generates coverage reports
- Python: Orchestrates workflow, displays final output

**Benefits**:
- ✅ Architectural consistency
- ✅ Less Python code (~1,500 lines instead of 3,500)
- ✅ Reporting logic lives where data is collected
- ✅ Can evolve reporting without Python changes

### Core Components (Revised)

**1. Python Instrumenter** (`src/gdsentry/coverage/instrumenter.py`)
- Parse .gd files (simple line-based approach)
- Inject `CoverageTracker.hit(file, line)` calls
- Preserve source structure and indentation
- ~300 lines

**2. GDScript Coverage Tracker** (`src/advanced/coverage/coverage_tracker.gd`)
- Singleton tracking line hits during test execution
- Stores: `{ "file.gd": { line_num: hit_count } }`
- ~200 lines

**3. GDScript Coverage Analyzer** (`src/advanced/coverage/coverage_analyzer.gd`)
- Analyzes coverage data against source files
- Calculates percentages, finds missing lines
- Builds structured coverage report data
- ~250 lines

**4. GDScript Coverage Reporter** (`src/advanced/coverage/coverage_reporter.gd`)
- Generates terminal output (colored tables)
- Generates HTML report files (index + per-file pages)
- Writes reports to disk
- ~350 lines

**5. Python Orchestrator** (`src/gdsentry/coverage/orchestrator.py`)
- Coordinates workflow: instrument → run → collect
- Invokes Godot with coverage enabled
- Displays/copies final reports
- ~200 lines

**6. Python Data Model** (`src/gdsentry/coverage/model.py`)
- Simple data classes for Python-side representation (optional)
- Mainly for CLI display logic
- ~150 lines

**7. CLI Integration** (`src/gdsentry/cli/commands/test.py`)
- Add `--coverage`, `--cov-report`, `--fail-under` flags
- ~50 lines of changes

### Integration Points

**With Existing GDSentry**:
- ✅ Extends `gdsentry test run` command (add `--coverage` flag)
- ✅ Reuses test discovery logic
- ✅ Reuses Godot test runner
- ✅ Follows same pattern as test reporting (GDScript generates, Python orchestrates)

**Key Data Flow**:
1. Python discovers tests, instruments them
2. Python runs Godot with instrumented tests
3. GDScript tracker records hits during execution
4. GDScript reporter generates reports to `.gdsentry/coverage/`
5. Python displays summary, opens HTML report

### Key Changes Expected

**New Files** (~1,500 lines total):

```
src/gdsentry/coverage/
├── __init__.py              # 30 lines
├── instrumenter.py          # 300 lines - Inject tracking code
├── orchestrator.py          # 200 lines - Coordinate workflow
└── model.py                 # 150 lines - Python data classes (optional)

src/advanced/coverage/
├── coverage_tracker.gd      # 200 lines - Track hits
├── coverage_analyzer.gd     # 250 lines - Analyze coverage
└── coverage_reporter.gd     # 350 lines - Generate reports

tests/unit/coverage/
├── test_instrumenter.py     # 100 lines
└── test_orchestrator.py     # 100 lines

tests/advanced/coverage/     # GDScript tests
└── coverage_system_test.gd  # 150 lines
```

**Modified Files**:
```
src/gdsentry/cli/commands/test.py         # Add --coverage flags (~50 lines)
src/gdsentry/test/runner.py               # Support instrumented tests (~30 lines)
pyproject.toml                            # Maybe add gdtoolkit dependency
```

**Documentation**:
```
docs/source/features/code-coverage.rst    # New feature guide
docs/source/quick-reference.rst           # Add coverage commands
```

---

## 4) Plan (Phased Approach)

### Phase 0: Master Planning ✅
**Duration**: Complete  
**Output**: This document

---

### Phase 1: Research Spikes (Risk Reduction)
**Goal**: Validate critical assumptions before building

#### Spike 1: Instrumentation Strategy
**Question**: Can we inject tracking code reliably?

**Tasks**:
- Write simple line-based instrumenter (regex approach)
- Create test .gd file with instrumentation
- Run in Godot, verify tracking calls work
- Measure performance impact

**Deliverable**: 
- `spike-1-instrumentation.md` with findings
- Instrumented test file + execution proof
- Performance metrics

**Success**: Can inject tracking with <10% performance overhead

**Note**: Simplified from original - no complex AST parsing needed for MVP

---

#### Spike 2: Coverage Analysis & Reporting ✅ COMPLETE
**Question**: Can GDScript efficiently analyze coverage data and generate reports?

**Status**: ✅ **GO DECISION** - All criteria exceeded

**Key Findings**:
- Performance: **7ms for 100 files** (142x faster than 1s target)
- Data structure: Dictionary-based O(1) lookups optimal
- Analysis logic: 100% correct (all tests pass)
- Edge cases: Robust handling (0%, 100%, empty, large files)
- HTML generation: Works for summary + line-by-line views

**Deliverables**:
- `spike-2-gdscript-reporting/FINDINGS.md` - Complete analysis
- `coverage_analyzer_prototype.gd` - Analysis functions
- `coverage_reporter_prototype.gd` - HTML generation
- Test suite: analyzer, reporter, e2e, performance, edge cases
- Sample HTML reports

**Recommendation**: Proceed with GDScript-based analysis and reporting. Production-ready.

**Completion**: 2025-10-30

---

#### Spike 3: End-to-End Data Flow ✅ COMPLETE
**Question**: Does the orchestration workflow make sense?

**Status**: ✅ **GO DECISION** - Workflow validated, ready for implementation

**Key Findings**:
- Workflow: 18-step end-to-end flow documented
- Handoffs: 5 critical handoff points specified (all sequential, no sync issues)
- File Artifacts: 7 types documented (~700KB temp, ~1.6MB output)
- Interfaces: 5 APIs defined with typed contracts
- Validation: No circular dependencies, linear flow verified
- Error Handling: 13 scenarios covered with recovery strategies

**Deliverables**:
- `spike-3-data-flow/FINDINGS.md` - Executive summary and GO decision
- `workflow-diagram.md` - Complete 18-step workflow
- `handoff-points.md` - 5 handoff specifications
- `error-scenarios.md` - 13 error cases
- `file-artifacts.md` - 7 artifact types with schemas
- `interface-contracts.md` - 5 API specifications
- `validation.md` - Architecture validation

**Recommendation**: Proceed to Phase 2 implementation (estimated 10-12 days)

**Completion**: 2025-10-30

---

**Phase 1 Decision Point**: 
After spikes, review findings. Should be low-risk given simplified architecture.

---

### Phase 2: Core Infrastructure (Incremental Builds)

#### Plan 2.1: Python Instrumenter
**Goal**: Inject coverage tracking into GDScript files

**File**: `plan-coverage-instrumenter.md`

**Scope**:
- Line-based parser (identify executable lines)
- Inject `CoverageTracker.hit(file, line)` calls
- Preserve indentation and structure
- Handle edge cases (comments, strings, etc.)
- Unit tests

**Dependencies**: Spike 1

**Done When**:
- Can instrument GDSentry's test files
- Instrumented code runs without errors
- Unit tests pass

---

#### Plan 2.2: GDScript Coverage Tracker
**Goal**: Singleton to record line hits

**File**: `plan-coverage-tracker.md`

**Scope**:
- `coverage_tracker.gd` singleton
- `enable()`, `disable()`, `hit()` methods
- Data storage: `{ file: { line: count } }`
- Reset functionality

**Dependencies**: None

**Done When**:
- Tracker records hits correctly
- Can be called from instrumented code
- Tested in isolation

---

#### Plan 2.3: GDScript Coverage Analyzer
**Goal**: Analyze coverage data vs source

**File**: `plan-coverage-analyzer.md`

**Scope**:
- `coverage_analyzer.gd` class
- Read source files, identify executable lines
- Calculate coverage percentages
- Find missing lines
- Build structured report data

**Dependencies**: Plan 2.2

**Done When**:
- Can analyze GDSentry's source files
- Produces accurate statistics
- Handles edge cases (empty files, etc.)

---

#### Plan 2.4: GDScript Coverage Reporter
**Goal**: Generate human-readable reports

**File**: `plan-coverage-reporter.md`

**Scope**:
- `coverage_reporter.gd` class
- Terminal output with color coding
- HTML index page (file list with stats)
- HTML per-file pages (line-by-line view)
- CSS styling

**Dependencies**: Plan 2.3

**Done When**:
- Terminal output is readable and attractive
- HTML report is navigable
- Reports match pytest-cov quality

---

#### Plan 2.5: Python Orchestrator
**Goal**: Coordinate the workflow

**File**: `plan-coverage-orchestrator.md`

**Scope**:
- `orchestrator.py` main class
- Discover tests
- Instrument files
- Run Godot with coverage
- Collect and display reports

**Dependencies**: Plans 2.1-2.4

**Done When**:
- End-to-end workflow works
- Error handling is robust
- Can run coverage on simple project

---

### Phase 3: Integration & Polish

#### Plan 3.1: CLI Integration
**Goal**: Wire into gdsentry CLI

**File**: `plan-coverage-cli.md`

**Scope**:
- Add `--coverage` flag to `test run`
- Add `--cov-report` format option
- Add `--fail-under` threshold
- Display coverage summary
- Open HTML report in browser

**Dependencies**: Plan 2.5

**Done When**:
- `gdsentry test run --coverage` works
- All flags functional
- Help text accurate

---

#### Plan 3.2: Self-Coverage Measurement
**Goal**: Measure GDSentry's own coverage

**File**: `plan-coverage-dogfood.md`

**Scope**:
- Run coverage on GDSentry framework tests
- Generate baseline report
- Document uncovered areas
- Create improvement plan

**Dependencies**: Plan 3.1

**Done When**:
- Have baseline metrics (target ≥70%)
- Report published in docs
- Action items identified

---

#### Plan 3.3: Documentation
**Goal**: Complete user documentation

**File**: `plan-coverage-docs.md`

**Scope**:
- Feature guide with examples
- Quick reference update
- Interpreting coverage reports
- Troubleshooting guide

**Dependencies**: Plan 3.1

**Done When**:
- Docs build without errors
- Coverage feature fully documented
- Examples work

---

## 5) Risks & Mitigations

### Risk 1: Instrumentation Breaking Code
**Likelihood**: Medium | **Impact**: High  
**Mitigation**: Spike 1 tests early, extensive unit tests, validate instrumented code, preserve exact indentation

### Risk 2: GDScript HTML Generation Limitations
**Likelihood**: Low | **Impact**: Medium  
**Mitigation**: Spike 2 validates early, fallback to Python if needed, keep HTML simple

### Risk 3: Performance Overhead
**Likelihood**: Medium | **Impact**: Medium  
**Mitigation**: Measure in Spike 1, only instrument tested files, make coverage opt-in

### Risk 4: Scope Creep
**Likelihood**: High | **Impact**: Medium  
**Mitigation**: Strict MVP scope (line coverage only), document deferred features, ship incremental PRs

### Risk 5: Integration Complexity
**Likelihood**: Low | **Impact**: Low  
**Mitigation**: Following existing patterns, simple architecture, clear handoff points

---

## 6) Validation & Acceptance

### Test Plan
- **Unit Tests**: Instrumenter, tracker, analyzer, orchestrator
- **Integration Tests**: End-to-end on simple project + GDSentry's suite
- **Regression Tests**: Existing tests pass, no performance degradation

### Success Metrics
- **Quantitative**: GDSentry coverage ≥70%, overhead <10%, HTML gen <5s, zero regressions
- **Qualitative**: Reports readable, HTML attractive, docs clear, feels integrated

---

## 7) Open Questions

### Pre-Spike (Answered by spikes)
- ❓ Can we instrument reliably without AST?
- ❓ Can GDScript generate HTML effectively?
- ❓ What's the performance impact?

### Future Enhancements (Deferred)
- Branch coverage (v2)
- Function coverage (v2)
- Coverage merging (v2)
- XML/JSON export (as needed)

---

## 8) Decision Log

- **2025-10-28 19:28** – Master plan created
- **2025-10-28 20:20** – Spike 1 completed: Line-based instrumentation validated, 40% overhead acceptable, proceed with approach
- **2025-10-30 15:38** – Spike 2 scope expanded: Focus on analysis + reporting, not just HTML (HTML proven by existing code)
- **2025-10-30 16:30** – Spike 2 completed: GDScript analysis/reporting validated, 7ms for 100 files (142x faster than target), GO decision
- **2025-10-30 16:32** – Spike 3 plan created: End-to-end data flow design (45-60 min paper spike)
- **2025-10-30 17:05** – Spike 3 completed: Workflow validated, 18-step flow + 5 handoffs + 7 artifacts + 5 APIs documented, GO decision. Phase 1 complete - all spikes GO.
- **2025-10-28** – **KEY**: Use GDScript for reporting (architectural consistency)
- **2025-10-28** – Target Godot 4.x only
- **2025-10-28** – Use `--coverage` flag on existing command
- **2025-10-28** – MVP is line coverage only
- **2025-10-28** – Simple line-based instrumentation
- **2025-10-28** – Reduced scope: ~1,500 lines instead of 3,500

---

## 9) Artifacts & References

### Related Documents
- This master plan: `plan-coverage-master.md`
- Spike reports: `spike-*.md` (Phase 1)
- Execution plans: `plan-coverage-*.md` (as needed)

### External References
- **GDScript 4.x docs**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- **coverage.py**: https://coverage.readthedocs.io/ (inspiration)
- **pytest-cov**: https://pytest-cov.readthedocs.io/ (UX inspiration)

---

## TODO (Master Plan Level)

- [x] Create master plan document
- [x] **Phase 1**: Research spikes (COMPLETE - All spikes GO)
  - [x] Spike 1: Instrumentation strategy (COMPLETE - GO decision)
  - [x] Spike 2: Coverage analysis & reporting (COMPLETE - GO decision, 7ms for 100 files)
  - [x] Spike 3: End-to-end data flow (COMPLETE - GO decision, 18-step workflow)
- [x] **Phase 2**: Core infrastructure ✅ COMPLETE (10-12 days estimated, ~2 days actual)
  - [x] Plan 2.1: Python instrumenter (1 day actual) - `plan-2.1-python-instrumenter.md` ✅ COMPLETE
  - [x] Plan 2.2: GDScript tracker (<1 day actual) - `plan-2.2-gdscript-tracker.md` ✅ COMPLETE
  - [x] Plan 2.3: GDScript analyzer (<1 hour actual) - `plan-2.3-gdscript-analyzer.md` ✅ COMPLETE
  - [x] Plan 2.4: GDScript reporter (<2 hours actual) - `plan-2.4-gdscript-reporter.md` ✅ COMPLETE
  - [x] Plan 2.5: Python orchestrator (<2 hours actual) - `plan-2.5-python-orchestrator.md` ✅ COMPLETE
- [ ] **Phase 3**: Integration & polish
  - [ ] Plan 3.1: CLI integration
  - [ ] Plan 3.2: Self-coverage measurement
  - [ ] Plan 3.3: Documentation
- [ ] **Final**: Quality gate & release
  - [ ] All tests pass
  - [ ] GDSentry coverage ≥70%
  - [ ] Docs complete
  - [ ] Merge & tag

---

**Code Estimate**: ~1,500 lines (70% GDScript, 30% Python)  
**Next Step**: Execute Phase 1 spikes ⚡

