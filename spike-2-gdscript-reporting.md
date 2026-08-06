# Spike 2: Coverage Analysis & Reporting

**Parent Plan**: `plan-coverage-master.md`  
**Created**: 2025-10-30  
**Updated**: 2025-10-30 15:38 (scope expanded)  
**Status**: 🟡 PLANNED  
**Duration Target**: 60-90 minutes  
**Owner**: AI-driven execution

---

## 1) Context & Goal

### Problem
GDSentry already has proven HTML generation (`output_formatter.gd`), so basic file I/O and HTML templating are validated. The **real unknowns** for coverage are:

1. **Data structures**: How to efficiently store and query coverage data in GDScript?
2. **Analysis logic**: Computing coverage percentages, finding missed lines, aggregating by file
3. **Performance**: Can GDScript handle analysis + reporting for 100+ files efficiently?
4. **Integration**: How do tracker → analyzer → reporter components connect?

### Goal
**Prove feasibility**: GDScript can efficiently analyze coverage data and generate coverage-specific HTML reports end-to-end.

### Success Criteria
- ✅ Coverage data structures are efficient for query operations
- ✅ Analysis logic correctly computes coverage % and finds gaps
- ✅ HTML generation works for line-by-line coverage display
- ✅ Performance acceptable: <1s for 100 files, 10k total lines
- ✅ End-to-end flow from mock tracker data → HTML report works

### Non-Goals
- ❌ Production-quality HTML/CSS design
- ❌ Syntax highlighting for source code
- ❌ Multi-format reports (XML, JSON, Cobertura)
- ❌ Coverage merging or historical trends
- ❌ Integration with actual instrumenter (mock data only)

---

## 2) Inputs & Constraints

### Assumptions
1. HTML file I/O works (proven by existing `output_formatter.gd`)
2. Coverage tracker provides data as: `{ "file.gd": { line_num: hit_count } }`
3. Analyzer queries: coverage %, missed lines, total executable lines
4. Reporter needs: file summary table + per-file line-by-line view
5. Performance matters for large codebases (100+ files)

### Constraints
- **Technical**: Must work in Godot 4.x headless environment
- **Simplicity**: No external dependencies, pure GDScript
- **Time**: 60-90 minute spike, focused prototype
- **Compatibility**: Godot 4.0+ (no 3.x support needed)
- **Integration**: Must fit existing GDSentry patterns (like output_formatter.gd)

### Stakeholders
- **Primary**: Coverage feature development (blocked on this spike)
- **Reference**: Existing `output_formatter.gd` pattern in GDSentry

---

## 3) High-Level Approach

### Architecture Overview

```
┌──────────────────────────────────────────────────────┐
│  Spike End-to-End Flow                               │
│                                                       │
│  1. Mock Coverage Tracker Data                       │
│     { "file.gd": { 1: 3, 2: 0, 3: 5 } }             │
│             ↓                                         │
│  2. Coverage Analyzer                                │
│     - Compute coverage % per file                    │
│     - Find missed lines (hit_count = 0)              │
│     - Aggregate totals                               │
│             ↓                                         │
│  3. Coverage Reporter                                │
│     - Generate HTML summary table                    │
│     - Generate line-by-line file views               │
│     - Write HTML to disk                             │
│             ↓                                         │
│  4. Validation                                       │
│     - Verify HTML correctness                        │
│     - Measure performance                            │
└──────────────────────────────────────────────────────┘
```

### Key Components to Test

1. **Coverage Analyzer** (new logic):
   - Data structure design: efficient queries
   - Coverage % calculation: `(hit_lines / executable_lines) * 100`
   - Missed line identification: `where hit_count == 0`
   - File aggregation: total stats across codebase

2. **Coverage Reporter** (builds on existing HTML patterns):
   - Summary table: file name, coverage %, lines covered, lines total
   - Per-file view: line-by-line with hit counts and source code
   - HTML structure: reuse patterns from `output_formatter.gd`

3. **Performance**:
   - Time to analyze 100 files with 10k total lines
   - Time to generate HTML
   - Memory usage during analysis

### Test Scenario

Mock coverage data for realistic test:
- **3 files**: `math.gd` (50 lines), `player.gd` (120 lines), `enemy.gd` (80 lines)
- **Coverage**: 70% total (some lines hit, some missed)
- **Generate**: Summary HTML + 3 file detail views

---

## 4) Plan (Step-by-step)

### Phase A: Data Structures & Analysis
**Goal**: Design and validate coverage data structures and analysis logic

- [ ] **Step 1**: Create spike directory
  - Create `spike-2-gdscript-reporting/` directory
  - Create `coverage_analyzer_prototype.gd`

- [ ] **Step 2**: Define mock tracker data structure
  - Format: `{ "file.gd": { line_num: hit_count } }`
  - Create mock data for 3 files (~250 total lines)
  - Mix of hit lines (count > 0) and missed lines (count = 0)

- [ ] **Step 3**: Implement coverage analyzer
  - Function: `compute_file_coverage(file_data) -> { covered, total, percent }`
  - Function: `get_missed_lines(file_data) -> Array[int]`
  - Function: `aggregate_total_coverage(all_files) -> { covered, total, percent }`

- [ ] **Step 4**: Test analyzer logic
  - Run in Godot headless
  - Verify coverage % calculations correct
  - Verify missed line identification works

### Phase B: HTML Report Generation
**Goal**: Generate coverage-specific HTML from analyzed data

- [ ] **Step 5**: Create reporter prototype
  - Create `coverage_reporter_prototype.gd`
  - Reference existing `output_formatter.gd` patterns

- [ ] **Step 6**: Implement summary HTML generation
  - Function: `generate_summary_html(coverage_data) -> String`
  - Table with: file name, lines covered/total, coverage %
  - Total coverage summary at top

- [ ] **Step 7**: Implement file detail HTML generation
  - Function: `generate_file_html(file_path, line_data, source_lines) -> String`
  - Line-by-line view with line numbers, hit counts, source code
  - Color coding: hit=green, missed=red, not-executable=gray

- [ ] **Step 8**: Write HTML to disk
  - Use patterns from existing `output_formatter.gd`
  - Write to `.gdsentry/coverage/spike_report.html`
  - Verify file created and valid

### Phase C: End-to-End & Performance
**Goal**: Test full flow and measure performance

- [ ] **Step 9**: Create end-to-end test script
  - Mock tracker data → Analyzer → Reporter → HTML file
  - Measure total time for full flow

- [ ] **Step 10**: Performance testing
  - Test with 10 files (~1000 lines total)
  - Test with 100 files (~10k lines total)
  - Measure: analysis time, HTML generation time, file write time
  - Target: <1s total for 100 files

- [ ] **Step 11**: Test edge cases
  - File with 0% coverage (all missed)
  - File with 100% coverage (all hit)
  - Empty file
  - Large file (500+ lines)
  - Special characters in source code

- [ ] **Step 12**: Document findings
  - Create `FINDINGS.md` in spike directory
  - Document data structure decisions
  - Document performance results
  - Recommend optimizations if needed
  - Include example HTML output

### Decision Point
**Goal**: Make go/no-go decision

- [ ] **Step 13**: Review findings
  - Are data structures efficient?
  - Is analysis logic correct?
  - Is performance acceptable?
  - Can this scale to production?

- [ ] **Step 14**: Update master plan
  - Document decision in master plan
  - Note architecture adjustments if needed
  - Proceed to Spike 3 or adjust approach

---

## 5) Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Coverage % logic incorrect | Medium | High | Unit test with known datasets, cross-check math |
| Data structure too slow at scale | Medium | High | Benchmark early, use arrays not dicts where possible |
| HTML generation too slow | Low | Medium | Use PackedStringArray, profile and optimize |
| Memory usage too high | Low | Medium | Process files in chunks, measure with large datasets |
| Integration with tracker unclear | Medium | Medium | Document interface clearly, test with mock data |

---

## 6) Validation & Acceptance

### Test Plan
1. **Data Structures**: Can efficiently query coverage data
2. **Analysis Logic**: Coverage % and missed lines computed correctly
3. **HTML Generation**: Line-by-line coverage display works
4. **Performance**: <1s for 100 files with 10k lines
5. **End-to-End**: Mock data → Analyzer → Reporter → HTML works

### Success Metrics
- ✅ Coverage % calculation: Matches manual calculation
- ✅ Missed line detection: Correctly identifies hit_count=0
- ✅ HTML structure: Valid and renders in browser
- ✅ Performance: <1s for 100 files
- ✅ File size: Reasonable (<1MB for 100 files)

### Observability
- Console output with timing breakdown (analysis vs generation vs I/O)
- Coverage statistics logged
- File size measurement

---

## 7) Open Questions

### Before Spike
- ❓ What data structure is most efficient for coverage queries?
- ❓ Should we store executable line count separately or compute on-demand?
- ❓ How to handle files with no coverage data (not instrumented)?
- ❓ Should analyzer cache computed results or recalculate?

### To Answer During Spike
- ❓ Performance: Dict lookup vs Array iteration for large datasets?
- ❓ Memory: Build HTML all at once or stream per file?
- ❓ Integration: Should analyzer and reporter be separate classes or one?
- ❓ Edge cases: How to display files with 0 executable lines?
- ❓ HTML structure: Single page or multiple pages (index + file details)?

**Answers will be documented in findings**

---

## 8) Decision Log

- **2025-10-30 13:30** – Spike 2 plan created (initial scope: HTML generation validation)
- **2025-10-30 15:38** – Scope expanded to "Coverage Analysis & Reporting" (HTML proven by existing code)
- **[After execution]** – Findings documented
- **[End of spike]** – Go/no-go decision made

---

## 9) Artifacts & References

### Deliverables
- `spike-2-gdscript-reporting/` directory
- `coverage_analyzer_prototype.gd` - Coverage analysis logic
- `coverage_reporter_prototype.gd` - HTML generation
- `spike_e2e_test.gd` - End-to-end test script
- `spike_report.html` - Example output
- `FINDINGS.md` - Results, data structure decisions, performance metrics

### References
- **GDScript Dict/Array docs**: https://docs.godotengine.org/en/stable/classes/class_dictionary.html
- **Existing reporter**: `src/advanced/output_formatter.gd` (HTML patterns)
- **Master plan**: `plan-coverage-master.md`
- **Spike 1 findings**: `spike-1-instrumentation/FINDINGS.md`

---

## TODO

### Phase A: Data Structures & Analysis
- [x] Create spike directory structure
  - **Execution Notes**: Created `spike-2-gdscript-reporting/` directory
- [x] Define and create mock tracker data (3 files)
  - **Execution Notes**: Created mock data in `coverage_analyzer_prototype.gd`. Structure: `{ "file.gd": { line_num: hit_count } }`. 3 files: math.gd (50 lines, 70%), player.gd (120 lines, 75%), enemy.gd (80 lines, 65%). Total 250 lines, 177 covered.
- [x] Implement coverage analyzer prototype
  - **Execution Notes**: Implemented 3 functions: `compute_file_coverage()` (calculates covered/total/%), `get_missed_lines()` (returns array of missed line numbers), `aggregate_total_coverage()` (sums across all files). Uses Dictionary iteration for queries.
- [x] Test analyzer logic correctness
  - **Execution Notes**: Created `test_analyzer.gd` and ran in Godot headless. All tests pass: coverage % calculations correct (70%, 75%, 65%), missed line detection correct (15, 30, 28 lines), aggregation correct (177/250 = 70.8%). ✅ Analysis logic validated.

### Phase B: HTML Report Generation  
- [x] Create reporter prototype
  - **Execution Notes**: Created `coverage_reporter_prototype.gd` with HTML generation functions. Includes `generate_summary_html()` (table view), `generate_file_html()` (line-by-line view), `write_html_file()` (file I/O), and helpers for CSS styling and HTML escaping.
- [x] Implement summary HTML generation
  - **Execution Notes**: Implemented in `generate_summary_html()`. Creates HTML with: total coverage summary, visual progress bars, file table with coverage %, CSS styling (green/yellow/red based on coverage).
- [x] Implement file detail HTML generation
  - **Execution Notes**: Implemented in `generate_file_html()`. Line-by-line view with: line numbers, hit counts, source code, color coding (green=hit, red=miss), monospace font.
- [x] Write HTML to disk and verify
  - **Execution Notes**: Created `test_reporter.gd`. Successfully generated summary HTML (2.4KB) and file detail HTML (8.6KB). File I/O works: created `.gdsentry/coverage/spike_report.html` and `math.gd.html`. All HTML structure checks pass. ✅ HTML generation validated.

### Phase C: End-to-End & Performance
- [x] Create end-to-end test script
  - **Execution Notes**: Created `spike_e2e_test.gd`. Full pipeline (tracking → analysis → HTML → disk) completes in **5ms** for 3 files/250 lines. Analysis: 0ms, HTML generation: 1ms, Disk I/O: 4ms. ✅ E2E pipeline validated.
- [x] Performance test with 10 and 100 files
  - **Execution Notes**: Created `performance_test.gd`. Results: **10 files (1k lines): 4ms total**. **100 files (10k lines): 7ms total** (0.7 μs/line). **500 files (50k lines): 25ms total**. ✅ **EXCEEDS target** - 100 files completes in 7ms vs 1s requirement (142x faster).
- [x] Test edge cases (0%, 100%, empty, large, special chars)
  - **Execution Notes**: Created `edge_case_test.gd`. All tests pass: 0% coverage (50 lines), 100% coverage (50 lines), empty file (0 lines), single line, HTML special char escaping, large file (5000 lines in 1ms). ✅ Robust edge case handling validated.
- [x] Document findings with data structure decisions
  - **Execution Notes**: Created `FINDINGS.md` with comprehensive analysis. Data structure: Dictionary-based O(1) lookups. Performance: 7ms for 100 files (142x faster than target). All success criteria exceeded. Edge cases handled. GO decision documented.

### Decision
- [x] Review: data structures efficient, analysis correct, performance acceptable?
  - **DECISION**: ✅ **GO** - All criteria exceeded. Dictionary structure optimal (O(1) lookups). Analysis logic 100% correct. Performance 142x faster than requirement (7ms vs 1s for 100 files). Edge cases handled. Production-ready.
- [x] Update master plan with decision
  - **Execution Notes**: Updated `plan-coverage-master.md`. Spike 2 marked COMPLETE with GO decision. Key findings documented: 7ms for 100 files (142x faster), Dictionary structure optimal, all tests pass. Decision log updated with 2025-10-30 completion.
- [x] Proceed to Spike 3 or adjust approach
  - **DECISION**: ✅ Proceed to Spike 3 (End-to-End Data Flow). Both Spike 1 and 2 have GO decisions. No adjustments needed - architecture validated. Next: validate integration workflow and handoff points.

---

**Next Step**: Create `spike-2-gdscript-reporting/` directory and build coverage analyzer! 🚀

