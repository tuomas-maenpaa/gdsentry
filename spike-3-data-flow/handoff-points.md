# Python ↔ GDScript Handoff Points

## Overview

The coverage workflow has **5 critical handoff points** where control and data transfer between components:

1. Python → Godot (process launch)
2. GDScript → Disk (coverage data JSON)
3. GDScript → Disk (HTML reports)
4. Godot → Python (process exit)
5. Python → Terminal (user output)

---

## Handoff 1: Python → Godot (Process Launch)

### Trigger
Python orchestrator launches Godot process after instrumentation complete

### Data Passed
**Command**:
```bash
godot --headless \
      --path .gdsentry/coverage/instrumented \
      --script test_runner.gd \
      -- --reporter gdsentry
```

**Environment Variables**:
- `GDSENTRY_COVERAGE=1` - Signals coverage mode is active
- `GDSENTRY_COVERAGE_OUTPUT=../../coverage/` - Output directory (relative to instrumented/)
- `GDSENTRY_ORIGINAL_PATH=<project_root>` - Original source location for reporter

**File System**:
- Instrumented files in `.gdsentry/coverage/instrumented/`
- `coverage_tracker.gd` singleton present
- Modified `project.godot` with tracker autoload

### Success Criteria
- Godot process starts successfully
- coverage_tracker.gd loads without errors
- Tests begin execution

### Failure Modes
| Failure | Detection | Recovery |
|---------|-----------|----------|
| Godot not in PATH | Process spawn fails | Error: "Godot not found, install Godot 4.x" |
| Instrumented files invalid | Godot parse errors | Show GDScript error, rollback instrumentation |
| coverage_tracker.gd missing | Autoload fails | Error: "Coverage tracker not initialized" |
| Wrong Godot version | Version check fails | Error: "Godot 4.x required, found 3.x" |

### Timeout
- If Godot doesn't start within 30s: Kill process, error "Godot launch timeout"

---

## Handoff 2: GDScript → Disk (Coverage Data JSON)

### Trigger
Test suite finishes (from `_suite_finished()` callback or `_notification(NOTIFICATION_WM_CLOSE_REQUEST)`)

### Data Passed
**File**: `.gdsentry/coverage/coverage_data.json`

**Format**:
```json
{
  "format_version": "1.0",
  "timestamp": "2025-10-30T16:45:00+02:00",
  "test_count": 42,
  "test_passed": 40,
  "test_failed": 2,
  "files": {
    "src/core/runner.gd": {
      "5": 10,
      "6": 10,
      "7": 0,
      "8": 5
    },
    "src/utils/helper.gd": {
      "3": 2,
      "4": 2,
      "5": 0
    }
  }
}
```

**Size**: ~100 bytes per file + ~10 bytes per line (efficient)

### Success Criteria
- JSON file written successfully
- Valid JSON format
- Contains coverage data for all instrumented files
- File is complete (not truncated)

### Failure Modes
| Failure | Detection | Recovery |
|---------|-----------|----------|
| Disk full | FileAccess.open() returns null | Error: "Cannot write coverage data: disk full" |
| Permission denied | FileAccess error | Error: "Cannot write to .gdsentry/coverage/" |
| Invalid coverage data | JSON serialization fails | Write error log, exit with code 2 |
| Godot crashes before write | File doesn't exist | Python detects missing file, reports "Coverage data not generated" |

### Guarantees
- Write happens in `_notification(NOTIFICATION_WM_CLOSE_REQUEST)` to survive test failures
- Uses atomic write pattern (write to .tmp, rename) to avoid corruption

---

## Handoff 3: GDScript → Disk (HTML Reports)

### Trigger
Immediately after coverage analysis completes (before Godot exit)

### Data Passed
**Files**:
- `.gdsentry/coverage/html/index.html` (summary report)
- `.gdsentry/coverage/html/<file_slug>.html` (per-file reports)

**Format**: HTML5 with embedded CSS

**Size**: ~2KB summary + ~150 bytes per line for detail reports

### Success Criteria
- HTML files written successfully
- Valid HTML (can be parsed by browser)
- Contains correct coverage data
- File links work between summary and detail pages

### Failure Modes
| Failure | Detection | Recovery |
|---------|-----------|----------|
| Disk full | FileAccess.open() fails | Error: "Cannot write HTML report", but coverage_data.json preserved |
| Permission denied | Directory creation fails | Error: "Cannot create html/ directory" |
| HTML generation fails | Exception in reporter | Log error, exit with code 3 |
| Missing source files | Cannot read original source | Use "[source unavailable]" placeholder |

### Guarantees
- HTML report failure does NOT fail the test run (tests still pass/fail independently)
- If HTML fails but coverage_data.json exists, Python can regenerate HTML later

---

## Handoff 4: Godot → Python (Process Exit)

### Trigger
Godot process terminates after tests and reporting complete

### Data Passed
**Exit Code**:
- `0` - Tests passed, coverage generated successfully
- `1` - Tests failed (but coverage still generated)
- `2` - Coverage tracking failed (couldn't write data)
- `3` - Coverage reporting failed (data exists but HTML failed)
- `127` - Godot crash or unhandled exception

**Standard Output** (last 1000 lines captured):
- Test results
- Coverage summary line: "Coverage: X.X% (Y/Z lines)"
- HTML report path: "Report: .gdsentry/coverage/html/index.html"

**Standard Error** (if errors occurred):
- GDScript errors
- Coverage system errors
- Test framework errors

### Success Criteria
- Process exits cleanly
- Exit code is 0 or 1 (tests result)
- coverage_data.json exists
- HTML reports exist

### Failure Modes
| Failure | Detection | Recovery |
|---------|-----------|----------|
| Godot crashes | Exit code 127 or SIGKILL | Python detects, shows "Godot crashed during tests", attempts cleanup |
| Hangs/timeout | No exit after 10 minutes | Python kills process, shows "Test timeout", cleanup |
| Out of memory | Exit code 137 (SIGKILL by OS) | Error: "Godot OOM, reduce test scope or increase memory" |
| User interrupt (Ctrl+C) | SIGINT received | Python forwards signal to Godot, wait for graceful exit, then cleanup |

### Python Detection Logic
```python
try:
    exit_code = godot_process.wait(timeout=600)  # 10 min
    
    if exit_code == 0:
        # Success path
    elif exit_code == 1:
        # Tests failed but coverage OK
    elif exit_code in (2, 3):
        # Coverage system error
    elif exit_code == 127:
        # Crash
    else:
        # Unknown error
        
except TimeoutExpired:
    godot_process.kill()
    # Handle timeout
```

---

## Handoff 5: Python → Terminal (User Output)

### Trigger
After Godot process exits and Python reads coverage results

### Data Passed
**Terminal Output**:
```
Running tests with coverage...
.................
42 tests passed, 2 failed

Coverage Report:
─────────────────────────────────────────────
  Coverage: 72.5% (145/200 lines)
  
  By File:
    src/core/runner.gd      85.0% (17/20)
    src/utils/helper.gd     60.0% (6/10)
    ...

  HTML Report: .gdsentry/coverage/html/index.html
─────────────────────────────────────────────
```

**Exit Code** (from `gdsentry` command):
- `0` - Tests passed
- `1` - Tests failed
- `2` - Coverage system error (but this doesn't fail the command, only warns)

### Success Criteria
- Coverage percentage displayed
- Report path shown
- Clear indication of where to find details

### Failure Modes
| Failure | Detection | Recovery |
|---------|-----------|----------|
| coverage_data.json missing | File doesn't exist | Warning: "Coverage data not generated, report unavailable" |
| coverage_data.json corrupt | JSON parse fails | Warning: "Coverage data corrupt, cannot display summary" |
| HTML reports missing | Files don't exist | Warning: "HTML report generation failed" (but show terminal summary) |

### User Experience
- Coverage summary always shown if data exists
- HTML report path always shown if report exists
- Warnings are non-fatal (tests still pass/fail independently)

---

## Handoff Summary Table

| # | From | To | Mechanism | Data | Failure Mode |
|---|------|----|-----------|------|--------------|
| 1 | Python | Godot | Process spawn | Instrumented files, env vars | Godot not found, spawn fails |
| 2 | GDScript | Disk | File write | coverage_data.json | Disk full, permissions |
| 3 | GDScript | Disk | File write | HTML reports | Disk full, missing source |
| 4 | Godot | Python | Process exit | Exit code, stdout/stderr | Crash, timeout, OOM |
| 5 | Python | Terminal | Print | Coverage summary, report path | Missing data, corrupt JSON |

---

## Critical Dependencies

### Handoff 1 → 2
- Godot must successfully load instrumented files
- coverage_tracker must initialize

### Handoff 2 → 3
- coverage_data.json must be written before HTML generation
- JSON must be valid for analyzer to parse

### Handoff 3 → 4
- HTML generation should not block process exit
- Errors in HTML generation should not crash Godot

### Handoff 4 → 5
- Python must wait for Godot to fully exit
- Files must be flushed to disk before exit

---

## Synchronization Points

**No explicit synchronization needed** - handoffs are sequential:
1. Python completes instrumentation before launching Godot
2. GDScript writes coverage_data.json before HTML generation
3. GDScript completes all file writes before process exit
4. Python waits for process exit before reading files
5. Python displays output after reading files

**Atomic operations**:
- File writes use atomic rename pattern where possible
- Process exit is atomic (OS guarantees)
- Python blocks on process.wait() (synchronous)

---

## Error Propagation

Errors propagate **backwards** through handoffs:

```
GDScript write fails (H2)
  → Godot exits with code 2
  → Python detects exit code (H4)
  → Python shows error (H5)
  → User sees: "Coverage data generation failed"
```

This ensures:
- No silent failures
- Clear error messages
- User can take action (fix permissions, free disk space, etc.)
