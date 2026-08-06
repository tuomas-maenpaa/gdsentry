# Interface Contracts

## Python Instrumenter API

### Module: `gdsentry.coverage.instrumenter`

#### Class: `Instrumenter`

**Purpose**: Parse GDScript files and inject coverage tracking calls

**Constructor**:
```python
def __init__(self, config: CoverageConfig):
    """
    Args:
        config: Coverage configuration (output paths, filters, etc.)
    """
```

#### Method: `instrument_file`

```python
def instrument_file(
    self,
    source_path: str,
    output_path: str
) -> InstrumentResult:
    """
    Instrument a single GDScript file.
    
    Args:
        source_path: Path to original .gd file
        output_path: Path to write instrumented file
        
    Returns:
        InstrumentResult with:
          - success: bool
          - instrumented_lines: int (number of lines instrumented)
          - total_lines: int (total lines in file)
          - errors: List[str] (parse/write errors)
          
    Raises:
        FileNotFoundError: source_path doesn't exist
        PermissionError: cannot write to output_path
    """
```

**Example Usage**:
```python
instrumenter = Instrumenter(config)
result = instrumenter.instrument_file(
    "src/core/runner.gd",
    ".gdsentry/coverage/instrumented/src/core/runner.gd"
)

if result.success:
    print(f"Instrumented {result.instrumented_lines} lines")
else:
    for error in result.errors:
        print(f"Error: {error}")
```

#### Method: `instrument_project`

```python
def instrument_project(
    self,
    source_root: str,
    output_root: str,
    file_patterns: List[str] = ["**/*.gd"]
) -> ProjectInstrumentResult:
    """
    Instrument all matching files in a project.
    
    Args:
        source_root: Project root directory
        output_root: Output directory (e.g., .gdsentry/coverage/instrumented)
        file_patterns: Glob patterns for files to instrument
        
    Returns:
        ProjectInstrumentResult with:
          - success: bool (true if at least one file succeeded)
          - files_instrumented: int
          - files_failed: int
          - total_lines: int
          - instrumented_lines: int
          - file_results: Dict[str, InstrumentResult]
          
    Raises:
        ValueError: Invalid source_root or output_root
    """
```

**Example Usage**:
```python
result = instrumenter.instrument_project(
    source_root=".",
    output_root=".gdsentry/coverage/instrumented",
    file_patterns=["src/**/*.gd", "!src/external/**"]
)

print(f"Instrumented {result.files_instrumented}/{result.files_instrumented + result.files_failed} files")
```

#### Method: `create_tracker_singleton`

```python
def create_tracker_singleton(
    self,
    output_path: str
) -> bool:
    """
    Generate coverage_tracker.gd singleton from template.
    
    Args:
        output_path: Directory to write coverage_tracker.gd
        
    Returns:
        True if successful, False otherwise
        
    Raises:
        PermissionError: cannot write to output_path
    """
```

#### Method: `modify_project_config`

```python
def modify_project_config(
    self,
    original_path: str,
    output_path: str
) -> bool:
    """
    Copy and modify project.godot to add CoverageTracker autoload.
    
    Args:
        original_path: Path to original project.godot
        output_path: Path to write modified project.godot
        
    Returns:
        True if successful, False otherwise
    """
```

#### Helper: `identify_executable_lines`

```python
def identify_executable_lines(
    self,
    source_code: str
) -> List[int]:
    """
    Identify which lines in source code are executable.
    
    Args:
        source_code: GDScript source code
        
    Returns:
        List of line numbers (1-indexed) that are executable
        
    Note:
        Excludes comments, blank lines, and non-executable statements
    """
```

**Executable line examples**:
- ✅ Variable assignments: `var x = 5`
- ✅ Function calls: `print("hello")`
- ✅ Return statements: `return x + 1`
- ✅ Control flow: `if x > 0:`, `for i in range(10):`
- ❌ Comments: `# This is a comment`
- ❌ Blank lines
- ❌ Function signatures: `func calculate():`
- ❌ Class definitions: `class_name MyClass`

---

## GDScript Tracker API

### File: `coverage_tracker.gd`

**Purpose**: Singleton that tracks line hits during test execution

**Autoload Name**: `CoverageTracker`

#### Method: `hit`

```gdscript
func hit(file_path: String, line_num: int) -> void:
    """
    Record that a line was executed.
    
    Called by instrumented code on each executable line.
    
    Args:
        file_path: Relative path to source file (e.g., "src/core/runner.gd")
        line_num: Line number (1-indexed)
        
    Returns:
        void (no return value)
        
    Performance:
        O(1) - Dictionary lookup and increment
        ~0.1 microseconds per call
        
    Thread-safety:
        Not thread-safe (GDScript is single-threaded)
    """
```

**Usage in instrumented code**:
```gdscript
# Original line:
var result = calculate(x, y)

# Becomes:
__coverage_tracker.hit("src/utils/math.gd", 42)
var result = calculate(x, y)
```

#### Method: `write_coverage_data`

```gdscript
func write_coverage_data(output_path: String = "") -> bool:
    """
    Write accumulated coverage data to JSON file.
    
    Called automatically on NOTIFICATION_WM_CLOSE_REQUEST or manually.
    
    Args:
        output_path: Path to write JSON (default: from env var)
        
    Returns:
        true if write successful, false otherwise
        
    Side effects:
        - Creates file at output_path
        - Prints "[Coverage] Data written: <path>" on success
        - Prints error message on failure
        
    Format:
        See coverage_data.json specification
    """
```

#### Method: `reset`

```gdscript
func reset() -> void:
    """
    Clear all accumulated coverage data.
    
    Useful for:
      - Running multiple test suites separately
      - Debugging/testing the tracker itself
      
    Returns:
        void
    """
```

#### Method: `get_stats`

```gdscript
func get_stats() -> Dictionary:
    """
    Get current coverage statistics (for debugging).
    
    Returns:
        {
          "files_tracked": int,
          "total_hits": int,
          "data_size_bytes": int (estimated)
        }
    """
```

#### Signal: `coverage_written`

```gdscript
signal coverage_written(path: String, success: bool)
    """
    Emitted after write_coverage_data() completes.
    
    Args:
        path: File path that was written
        success: Whether write was successful
    """
```

---

## GDScript Analyzer API

### File: `coverage_analyzer.gd`

**Purpose**: Analyze coverage data and compute statistics

**Type**: Static utility class (no instantiation)

#### Method: `analyze_coverage_data`

```gdscript
static func analyze_coverage_data(coverage_data: Dictionary) -> CoverageResult:
    """
    Analyze coverage data from coverage_data.json.
    
    Args:
        coverage_data: Parsed JSON from coverage_data.json
        
    Returns:
        CoverageResult dictionary:
        {
          "total_lines": int,
          "covered_lines": int,
          "percent": float (0-100),
          "files": Array[FileCoverage]
        }
        
        where FileCoverage is:
        {
          "file": String (path),
          "total": int,
          "covered": int,
          "percent": float,
          "missed_lines": Array[int]
        }
    """
```

**Example Usage**:
```gdscript
var json_text = FileAccess.get_file_as_string("coverage_data.json")
var data = JSON.parse_string(json_text)
var result = CoverageAnalyzer.analyze_coverage_data(data)

print("Total Coverage: %.1f%%" % result["percent"])
for file_cov in result["files"]:
    print("  %s: %.1f%%" % [file_cov["file"], file_cov["percent"]])
```

#### Method: `compute_file_coverage`

```gdscript
static func compute_file_coverage(line_data: Dictionary) -> FileCoverage:
    """
    Compute coverage statistics for a single file.
    
    Args:
        line_data: Dictionary { line_num: hit_count }
        
    Returns:
        FileCoverage dictionary (see analyze_coverage_data)
    """
```

#### Method: `get_missed_lines`

```gdscript
static func get_missed_lines(line_data: Dictionary) -> Array[int]:
    """
    Get sorted list of line numbers that were not hit.
    
    Args:
        line_data: Dictionary { line_num: hit_count }
        
    Returns:
        Array of line numbers (sorted ascending)
    """
```

---

## GDScript Reporter API

### File: `coverage_reporter.gd`

**Purpose**: Generate HTML coverage reports

**Type**: Static utility class (no instantiation)

#### Method: `generate_html_report`

```gdscript
static func generate_html_report(
    analysis: CoverageResult,
    source_root: String,
    output_dir: String
) -> bool:
    """
    Generate complete HTML coverage report.
    
    Creates:
      - index.html (summary)
      - <file_slug>.html (per-file detail)
      
    Args:
        analysis: Result from CoverageAnalyzer.analyze_coverage_data()
        source_root: Path to original source files
        output_dir: Directory to write HTML files
        
    Returns:
        true if successful, false if any errors
        
    Side effects:
        - Creates output_dir if doesn't exist
        - Writes multiple HTML files
        - Prints progress messages
    """
```

**Example Usage**:
```gdscript
var data = JSON.parse_string(FileAccess.get_file_as_string("coverage_data.json"))
var analysis = CoverageAnalyzer.analyze_coverage_data(data)

var success = CoverageReporter.generate_html_report(
    analysis,
    OS.get_environment("GDSENTRY_ORIGINAL_PATH"),
    ".gdsentry/coverage/html"
)

if success:
    print("Report generated: .gdsentry/coverage/html/index.html")
```

#### Method: `generate_summary_html`

```gdscript
static func generate_summary_html(analysis: CoverageResult) -> String:
    """
    Generate HTML for summary report (index.html).
    
    Args:
        analysis: Coverage analysis result
        
    Returns:
        Complete HTML string (DOCTYPE to </html>)
    """
```

#### Method: `generate_file_html`

```gdscript
static func generate_file_html(
    file_path: String,
    line_data: Dictionary,
    source_lines: Array[String]
) -> String:
    """
    Generate HTML for per-file detail report.
    
    Args:
        file_path: Path to source file (for title)
        line_data: Dictionary { line_num: hit_count }
        source_lines: Array of source code lines
        
    Returns:
        Complete HTML string with line-by-line display
    """
```

#### Method: `write_html_file`

```gdscript
static func write_html_file(file_path: String, html_content: String) -> bool:
    """
    Write HTML string to file.
    
    Args:
        file_path: Output file path
        html_content: HTML string to write
        
    Returns:
        true if successful, false otherwise
        
    Side effects:
        - Creates parent directories if needed
        - Overwrites existing file
    """
```

---

## Python Orchestrator API

### Module: `gdsentry.coverage.orchestrator`

#### Class: `CoverageOrchestrator`

**Purpose**: Coordinate the entire coverage workflow

**Constructor**:
```python
def __init__(self, config: CoverageConfig):
    """
    Args:
        config: Coverage configuration
    """
```

#### Method: `run_coverage`

```python
def run_coverage(
    self,
    test_args: List[str]
) -> CoverageRunResult:
    """
    Run full coverage workflow.
    
    Workflow:
      1. Instrument files
      2. Create tracker
      3. Modify project config
      4. Launch Godot
      5. Wait for completion
      6. Display summary
      7. Cleanup
      
    Args:
        test_args: Arguments to pass to test runner
        
    Returns:
        CoverageRunResult with:
          - test_exit_code: int (0 = pass, 1 = fail)
          - coverage_percent: float (or None if failed)
          - report_path: str (or None if failed)
          - errors: List[str]
          
    Raises:
        CoverageError: Unrecoverable error (Godot not found, etc.)
    """
```

**Example Usage**:
```python
orchestrator = CoverageOrchestrator(config)
result = orchestrator.run_coverage(test_args=["--verbose"])

if result.coverage_percent:
    print(f"Coverage: {result.coverage_percent:.1f}%")
    print(f"Report: {result.report_path}")

sys.exit(result.test_exit_code)
```

#### Method: `cleanup`

```python
def cleanup(self) -> None:
    """
    Remove temporary instrumented files.
    
    Always called, even on error (try/finally).
    
    Side effects:
        - Deletes .gdsentry/coverage/instrumented/
        - Restores original project.godot if modified
    """
```

---

## Data Transfer Objects

### Python Types

```python
from dataclasses import dataclass
from typing import List, Optional, Dict

@dataclass
class InstrumentResult:
    success: bool
    instrumented_lines: int
    total_lines: int
    errors: List[str]

@dataclass
class ProjectInstrumentResult:
    success: bool
    files_instrumented: int
    files_failed: int
    total_lines: int
    instrumented_lines: int
    file_results: Dict[str, InstrumentResult]

@dataclass
class CoverageRunResult:
    test_exit_code: int
    coverage_percent: Optional[float]
    report_path: Optional[str]
    errors: List[str]

@dataclass
class CoverageConfig:
    source_root: str
    output_dir: str
    file_patterns: List[str]
    godot_path: str
    timeout: int
```

### GDScript Types

```gdscript
# CoverageResult (Dictionary)
{
  "total_lines": int,
  "covered_lines": int,
  "percent": float,
  "files": Array[FileCoverage]
}

# FileCoverage (Dictionary)
{
  "file": String,
  "total": int,
  "covered": int,
  "percent": float,
  "missed_lines": Array[int]
}
```

---

## Interface Contract Summary

| Interface | Type | Purpose | Key Methods |
|-----------|------|---------|-------------|
| Instrumenter | Python Class | Parse & instrument files | instrument_file, instrument_project |
| CoverageTracker | GDScript Singleton | Track line hits | hit, write_coverage_data |
| CoverageAnalyzer | GDScript Static | Analyze coverage data | analyze_coverage_data |
| CoverageReporter | GDScript Static | Generate HTML | generate_html_report |
| CoverageOrchestrator | Python Class | Coordinate workflow | run_coverage, cleanup |

**Key Design Principles**:
1. **Clear separation**: Each component has single responsibility
2. **Stateless where possible**: Analyzer and Reporter are pure functions
3. **Error handling**: All methods indicate success/failure
4. **Type safety**: Strong typing with Python dataclasses and GDScript types
5. **No circular dependencies**: Data flows one direction (tracker → analyzer → reporter)
