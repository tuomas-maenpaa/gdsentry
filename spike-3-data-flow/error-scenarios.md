# Error Scenarios and Recovery Strategies

## Error Handling Matrix

### Category 1: Pre-Execution Errors (Python)

#### E1: Instrumentation Parse Error
**Scenario**: Python cannot parse a source .gd file

**Detection**:
- Exception during regex parsing
- Invalid GDScript syntax detected

**Recovery**:
```python
try:
    instrument_file(path)
except ParseError as e:
    log_error(f"Failed to instrument {path}: {e}")
    skip_file(path)
    # Continue with other files
```

**User Impact**: File excluded from coverage (not instrumented)

**Error Message**:
```
Warning: Could not instrument src/broken.gd: Invalid syntax at line 42
File will be excluded from coverage report.
```

---

#### E2: Instrumentation Write Error
**Scenario**: Cannot write instrumented file to disk

**Detection**:
- FileNotFoundError, PermissionError during file write
- Disk full

**Recovery**:
- Fail fast (cannot proceed without instrumented files)
- Clean up partial instrumentation
- Exit with error

**User Impact**: Coverage run aborted

**Error Message**:
```
Error: Cannot write instrumented files to .gdsentry/coverage/instrumented/
Reason: Permission denied
Action: Check directory permissions or disk space
```

---

#### E3: Godot Not Found
**Scenario**: Godot executable not in PATH

**Detection**:
- subprocess.Popen() raises FileNotFoundError
- `which godot` returns empty

**Recovery**:
- Fail fast (cannot run tests without Godot)
- Provide installation guidance

**User Impact**: Coverage run aborted

**Error Message**:
```
Error: Godot not found in PATH
Install Godot 4.x: https://godotengine.org/download
Or specify path: gdsentry test run --godot-path /path/to/godot
```

---

### Category 2: Execution Errors (Godot/GDScript)

#### E4: Godot Crashes During Tests
**Scenario**: Godot process terminates unexpectedly (SIGSEGV, SIGKILL)

**Detection**:
- Exit code 127 or negative (signal)
- Process terminated by OS

**Recovery**:
```python
exit_code = process.wait()
if exit_code < 0 or exit_code == 127:
    print("Error: Godot crashed during test execution")
    attempt_partial_coverage_report()
    cleanup_instrumented_files()
```

**User Impact**: Tests incomplete, partial coverage data may exist

**Error Message**:
```
Error: Godot crashed during test execution (exit code: 127)
Coverage data may be incomplete or missing.
Check godot.log for details.
```

---

#### E5: Coverage Tracker Initialization Fails
**Scenario**: coverage_tracker.gd cannot load or initialize

**Detection**:
- GDScript error in coverage_tracker.gd
- Autoload fails

**Recovery** (GDScript):
```gdscript
func _ready():
    if not _initialize_coverage():
        push_error("Coverage tracker failed to initialize")
        # Continue tests without coverage
        get_tree().quit(2)  # Exit code 2 = coverage system error
```

**User Impact**: Tests run but no coverage collected

**Error Message**:
```
Warning: Coverage tracking failed to initialize
Tests will run normally but coverage data will not be collected.
```

---

#### E6: Coverage Data Write Fails
**Scenario**: Cannot write coverage_data.json

**Detection** (GDScript):
- FileAccess.open() returns null
- Disk full or permission denied

**Recovery** (GDScript):
```gdscript
func write_coverage_data(path: String) -> bool:
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Cannot write coverage data: " + error_string(FileAccess.get_open_error()))
        _write_error_file(".gdsentry/coverage/error.txt")
        return false
    # ... write data
    return true
```

**User Impact**: Tests complete but no coverage report

**Error Message**:
```
Error: Cannot write coverage data to .gdsentry/coverage/coverage_data.json
Reason: Disk full (no space left on device)
Tests passed, but coverage report unavailable.
```

---

#### E7: HTML Report Generation Fails
**Scenario**: Analyzer or reporter crashes

**Detection** (GDScript):
- Exception during HTML generation
- Invalid coverage data

**Recovery** (GDScript):
```gdscript
func generate_report():
    try:
        _generate_html()
    except Exception as e:
        push_error("HTML report generation failed: " + str(e))
        # Don't exit - tests already complete
        # Python will detect missing HTML
```

**User Impact**: coverage_data.json exists but no HTML

**Error Message**:
```
Warning: HTML report generation failed
Coverage data available in: .gdsentry/coverage/coverage_data.json
Run 'gdsentry coverage report' to regenerate HTML
```

---

### Category 3: Post-Execution Errors (Python)

#### E8: Coverage Data JSON Missing
**Scenario**: Godot exited but coverage_data.json not found

**Detection**:
- File doesn't exist after Godot exit
- Exit code may be 0 (tests passed) or 2 (coverage failed)

**Recovery**:
```python
if not os.path.exists(coverage_data_path):
    if exit_code == 2:
        error("Coverage system reported failure")
    else:
        warning("Coverage data not generated (Godot may have crashed)")
    # Skip coverage summary, continue with test results
```

**User Impact**: Test results shown, no coverage

**Error Message**:
```
Warning: Coverage data not generated
Tests: 42 passed, 2 failed
Coverage report unavailable - check for errors above
```

---

#### E9: Coverage Data JSON Corrupt
**Scenario**: JSON file exists but cannot be parsed

**Detection**:
- json.loads() raises JSONDecodeError
- File truncated or incomplete

**Recovery**:
```python
try:
    data = json.loads(coverage_file.read())
except JSONDecodeError as e:
    warning(f"Coverage data corrupt: {e}")
    # Show test results, skip coverage summary
```

**User Impact**: Test results shown, no coverage summary

**Error Message**:
```
Warning: Coverage data file is corrupt or incomplete
Tests: 42 passed, 2 failed
Cannot display coverage summary.
```

---

#### E10: User Interrupts (Ctrl+C)
**Scenario**: User presses Ctrl+C during execution

**Detection**:
- SIGINT signal received by Python

**Recovery**:
```python
def signal_handler(sig, frame):
    print("\nInterrupted by user. Cleaning up...")
    if godot_process:
        godot_process.terminate()
        godot_process.wait(timeout=5)
        if godot_process.poll() is None:
            godot_process.kill()
    cleanup_instrumented_files()
    sys.exit(130)  # Standard exit code for Ctrl+C

signal.signal(signal.SIGINT, signal_handler)
```

**User Impact**: Tests stopped, cleanup performed

**Error Message**:
```
^C
Interrupted by user. Cleaning up...
Tests stopped. Temporary files removed.
```

---

### Category 4: Edge Cases

#### E11: Test Timeout
**Scenario**: Tests run longer than configured timeout (default 10 minutes)

**Detection**:
- process.wait(timeout) raises TimeoutExpired

**Recovery**:
```python
try:
    exit_code = process.wait(timeout=600)
except TimeoutExpired:
    process.kill()
    error("Test execution timeout (10 minutes)")
    cleanup()
    sys.exit(1)
```

**User Impact**: Tests forcibly terminated

**Error Message**:
```
Error: Test execution timeout after 10 minutes
Tests were forcibly terminated.
Increase timeout with: --timeout 1200
```

---

#### E12: Partial Instrumentation
**Scenario**: Some files instrumented, others failed

**Detection**:
- Instrumentation completed with warnings
- Some files skipped

**Recovery**:
- Continue with successfully instrumented files
- Report excludes failed files

**User Impact**: Incomplete coverage report

**Error Message**:
```
Warning: 2 files could not be instrumented and were excluded:
  - src/broken_syntax.gd: Parse error at line 15
  - src/weird_encoding.gd: Encoding error (not UTF-8)

Coverage report will exclude these files.
Continue? [Y/n]
```

---

#### E13: Wrong Godot Version
**Scenario**: Godot 3.x detected instead of 4.x

**Detection**:
- Check `godot --version` output
- Parse major version

**Recovery**:
- Fail fast (incompatible)
- Provide upgrade guidance

**User Impact**: Coverage run aborted

**Error Message**:
```
Error: Godot 3.5.1 detected, but Godot 4.x required
GDSentry coverage requires Godot 4.0 or later.
Download: https://godotengine.org/download
```

---

## Recovery Strategy Summary

| Error | Severity | Recovery | Exit Code |
|-------|----------|----------|-----------|
| E1: Parse error | Warning | Skip file | 0 (warn) |
| E2: Write error | Fatal | Abort | 2 |
| E3: Godot not found | Fatal | Abort | 2 |
| E4: Crash | Error | Partial data | 1 |
| E5: Tracker init fail | Warning | Tests without coverage | 0 (warn) |
| E6: Data write fail | Error | Tests pass, no coverage | 0 (warn) |
| E7: HTML gen fail | Warning | Data exists | 0 (warn) |
| E8: Data missing | Warning | Tests only | 0 (warn) |
| E9: Data corrupt | Warning | Tests only | 0 (warn) |
| E10: User interrupt | Fatal | Cleanup, exit | 130 |
| E11: Timeout | Fatal | Kill, exit | 1 |
| E12: Partial instr. | Warning | Continue with subset | 0 (warn) |
| E13: Wrong version | Fatal | Abort | 2 |

**Key Principles**:
1. **Test results are primary** - Coverage errors don't fail test run
2. **Cleanup always happens** - Use try/finally blocks
3. **Clear error messages** - Tell user what failed and how to fix
4. **Graceful degradation** - Partial data is better than no data
5. **No silent failures** - Always log warnings/errors

---

## Cleanup Guarantees

**Always cleanup** (even on error):
- `.gdsentry/coverage/instrumented/` directory
- Temporary `project.godot` modifications
- Any file locks or handles

**Implementation**:
```python
try:
    run_coverage()
finally:
    cleanup_instrumented_files()
    restore_original_project()
```

**Never delete** (preserve user data):
- `.gdsentry/coverage/html/` reports
- `.gdsentry/coverage/coverage_data.json` (unless corrupted)
- Original source files
