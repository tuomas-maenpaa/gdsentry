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


---

_Excerpt only. Full file: `git show origin/wip/coverage-restructure:plan-coverage-master.md`_
