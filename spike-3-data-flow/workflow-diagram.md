# Coverage Workflow: End-to-End Data Flow

## Happy Path Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER ACTION                                                  │
│    $ gdsentry test run --coverage                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 2. PYTHON: Coverage Orchestrator Initialized                    │
│    - Parse CLI args (--coverage flag detected)                  │
│    - Initialize coverage configuration                          │
│    - Create .gdsentry/coverage/ directory structure             │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 3. PYTHON: Discover Source Files                                │
│    - Scan project for *.gd files                                │
│    - Filter to source files (exclude tests if configured)      │
│    - Build list of files to instrument                          │
│    Result: ['src/core/runner.gd', 'src/utils/helper.gd', ...]   │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 4. PYTHON: Parse & Instrument Files                             │
│    For each source file:                                        │
│      - Read original source                                     │
│      - Identify executable lines (skip comments, blank lines)   │
│      - Inject __coverage_tracker.hit() calls                    │
│      - Write to .gdsentry/coverage/instrumented/<path>          │
│    Result: Instrumented copies of all source files              │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 5. PYTHON: Create Coverage Tracker Singleton                    │
│    - Generate coverage_tracker.gd from template                 │
│    - Write to .gdsentry/coverage/instrumented/                  │
│    - Includes: hit(), write_coverage_data(), reset()            │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 6. PYTHON: Modify Test Bootstrap                                │
│    - Inject autoload for coverage_tracker.gd                    │
│    - Add coverage initialization at test start                  │
│    - Add coverage finalization at test end                      │
│    Result: project.godot or test bootstrap modified             │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 7. PYTHON: Launch Godot Process                                 │
│    Command: godot --headless --script <test_runner>             │
│    Environment:                                                  │
│      - GDSENTRY_COVERAGE=1                                      │
│      - GDSENTRY_COVERAGE_OUTPUT=.gdsentry/coverage/             │
│    Working directory: instrumented source tree                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │   HANDOFF POINT 1   │
              │  Python → Godot     │
              │  (Process launch)   │
              └──────────┬──────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 8. GODOT: Test Execution Begins                                 │
│    - Godot engine loads instrumented files                      │
│    - coverage_tracker.gd autoloaded as singleton                │
│    - Test framework initializes                                 │
│    - Tests start running                                        │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 9. GDSCRIPT: Coverage Tracking (During Tests)                   │
│    As instrumented code executes:                               │
│      - Each executable line calls:                              │
│        __coverage_tracker.hit("file.gd", line_num)              │
│      - Tracker accumulates hits in Dictionary:                  │
│        { "file.gd": { 5: 10, 6: 10, 8: 0 } }                    │
│    Continues throughout all test execution                      │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 10. GDSCRIPT: Tests Complete                                    │
│     - All tests finish (pass or fail)                           │
│     - Test framework cleanup runs                               │
│     - Coverage finalization triggered                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 11. GDSCRIPT: Write Coverage Data to Disk                       │
│     __coverage_tracker.write_coverage_data():                   │
│       - Serialize coverage dictionary to JSON                   │
│       - Write to .gdsentry/coverage/coverage_data.json          │
│       - Include metadata (timestamp, test count)                │
│     Result: coverage_data.json persisted                        │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │   HANDOFF POINT 2   │
              │  GDScript → Disk    │
              │  (JSON written)     │
              └──────────┬──────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 12. GDSCRIPT: Analyze Coverage Data                             │
│     coverage_analyzer.analyze_coverage_data():                  │
│       - Load coverage_data.json                                 │
│       - Compute per-file coverage %                             │
│       - Identify missed lines                                   │
│       - Aggregate total coverage                                │
│     Result: CoverageResult object with stats                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 13. GDSCRIPT: Generate HTML Reports                             │
│     coverage_reporter.generate_html_report():                   │
│       - Create summary HTML (index.html)                        │
│       - Generate per-file detail HTML                           │
│       - Write to .gdsentry/coverage/html/                       │
│     Result: HTML reports on disk                                │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │   HANDOFF POINT 3   │
              │  GDScript → Disk    │
              │  (HTML written)     │
              └──────────┬──────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 14. GODOT: Process Exits                                        │
│     - GDScript execution complete                               │
│     - Godot process terminates                                  │
│     - Exit code: 0 (success) or non-zero (test failures)        │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │   HANDOFF POINT 4   │
              │  Godot → Python     │
              │  (Process exit)     │
              └──────────┬──────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 15. PYTHON: Detect Test Completion                              │
│     - Godot process has exited                                  │
│     - Capture exit code                                         │
│     - Read coverage_data.json (verify exists)                   │
│     - Read HTML report location                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 16. PYTHON: Display Coverage Summary                            │
│     - Parse coverage_data.json                                  │
│     - Display terminal summary:                                 │
│       "Coverage: 72.5% (145/200 lines)"                         │
│       "Report: .gdsentry/coverage/html/index.html"              │
│     - Print per-file summary table (optional)                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │   HANDOFF POINT 5   │
              │  Python → Terminal  │
              │  (Display output)   │
              └──────────┬──────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 17. PYTHON: Cleanup Temporary Files                             │
│     - Delete .gdsentry/coverage/instrumented/ (entire directory)│
│     - Optionally delete coverage_data.json                      │
│     - Restore original project.godot if modified                │
│     Result: Clean state, only HTML reports remain               │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│ 18. USER: Opens HTML Report                                     │
│     - User browses to .gdsentry/coverage/html/index.html        │
│     - Interactive coverage visualization                        │
│     - Drill down to per-file line-by-line views                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Summary

```
Source Files (.gd)
    │
    ├──→ [Python Instrumenter] → Instrumented Files (.gd)
    │                                    │
    │                                    ├──→ [Godot Execution]
    │                                    │         │
    │                                    │         ├──→ [Coverage Tracker]
    │                                    │         │         │
    │                                    │         │         ├──→ coverage_data.json
    │                                    │         │                    │
    │                                    │         │                    ├──→ [Analyzer]
    │                                    │         │                    │         │
    └──────────────────────────────────────────────────────────────────┘         │
                                                   (read original source)         │
                                                                                  │
                                                                                  ├──→ [Reporter]
                                                                                           │
                                                                                           ├──→ HTML Reports
                                                                                           │
                                                                                           └──→ Terminal Summary
```

## Timeline View

| Time | Component | Activity |
|------|-----------|----------|
| T0   | User      | Invoke `gdsentry test run --coverage` |
| T1   | Python    | Parse args, discover files |
| T2   | Python    | Instrument files (1-2s for 100 files) |
| T3   | Python    | Create tracker, modify bootstrap |
| T4   | Python    | Launch Godot process |
| T5   | Godot     | Load instrumented files, start tests |
| T6-T7| GDScript  | Track coverage during test execution |
| T8   | GDScript  | Write coverage_data.json |
| T9   | GDScript  | Analyze data (< 10ms) |
| T10  | GDScript  | Generate HTML (< 50ms) |
| T11  | Godot     | Process exits |
| T12  | Python    | Display summary, cleanup |
| T13+ | User      | View HTML report |

**Total overhead estimate**: 1-2s instrumentation + 40% test execution + <100ms reporting = ~2-3s for typical project
