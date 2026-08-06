# Slice 6: Validation Tools

**Status**: ✅ Complete  
**Dependencies**: Slice 1 (Config), Slice 3 (CLI)  
**Provides**: Code quality validation tools

---

## Purpose

Implement code validation tools for GDSentry:
- GDScript syntax and style validation
- Import statement validation
- License header checking
- Validation orchestration and reporting

These tools ensure code quality across the project and can be used in CI/CD pipelines.

---

## Files Created

### Validation Module

```
src/gdsentry/validation/
├── __init__.py           # Validation exports
├── gdscript.py           # GDScript syntax/style validator
├── imports.py            # Import statement validator
├── licenses.py           # License header checker
└── runner.py             # Validation orchestration
```

### CLI Commands

```
src/gdsentry/cli/commands/
└── validate.py          # Validation commands
```

### Tests

```
tests/unit/
└── test_validation.py   # 23 comprehensive tests
```

### Documentation

```
docs/source/internal/implementation/
└── slice-06-validation.rst  # This file
```

---

## Implementation Details

### GDScript Validator (`gdscript.py`)

**Purpose**: Validate GDScript syntax and code style

**Checks**:
- **Syntax errors**: Unmatched quotes, parentheses
- **Compatibility**: Deprecated API usage, direct FileAccess/DirAccess
- **Style**: Trailing whitespace, tabs, line length

**API**:
```python
validator = GDScriptValidator(max_line_length=120)

# Validate single file
passed = validator.validate_file(Path("test.gd"))

# Validate multiple files
passed = validator.validate_files([Path("test1.gd"), Path("test2.gd")])

# Get issues
errors = validator.get_errors()
warnings = validator.get_warnings()
```

**ValidationIssue Model**:
```python
class ValidationIssue(BaseModel):
    file: Path
    line: int | None = None
    severity: str  # "error" or "warning"
    message: str
```

### Import Validator (`imports.py`)

**Purpose**: Validate GDScript import statements

**Checks**:
- Proper `extends` statements
- Valid `load()` paths
- Class reference consistency
- Path existence

**API**:
```python
validator = ImportValidator(project_root)

passed = validator.validate_files(gdscript_files)

errors = validator.get_errors()
warnings = validator.get_warnings()
```

**Expected Paths**:
Maps common GDSentry classes to their file paths:
- `GDTest` → `src/base_classes/gd_test.gd`
- `SceneTreeTest` → `src/base_classes/scene_tree_test.gd`
- etc.

### License Checker (`licenses.py`)

**Purpose**: Check license headers in source files

**Checks**:
- GDScript files (`.gd`) have comment headers
- Python files (`.py`) have docstring headers
- Shell scripts (`.sh`) have comment headers
- Presence of "GDSentry" and "Author:" markers

**API**:
```python
checker = LicenseChecker()

passed = checker.check_files(source_files)

warnings = checker.get_warnings()  # Missing headers are warnings
```

### Validation Runner (`runner.py`)

**Purpose**: Orchestrate validation across multiple validators

**Features**:
- Auto-discovery of files
- Parallel validation types
- Aggregated results
- Configurable checks

**API**:
```python
runner = ValidationRunner(project_root)

# Individual validations
gdscript_summary = runner.validate_gdscript_files(files)
import_summary = runner.validate_imports(files)
license_summary = runner.validate_licenses(files)

# Run all validations
results = runner.validate_all(
    check_licenses=True,
    check_style=True,
)
```

**ValidationSummary**:
```python
class ValidationSummary:
    files_checked: int
    errors: List[ValidationIssue]
    warnings: List[ValidationIssue]
    
    @property
    def error_count(self) -> int
    
    @property
    def warning_count(self) -> int
    
    @property
    def passed(self) -> bool  # True if no errors
```

---

## CLI Commands

### `gdsentry validate gdscript`

Validate GDScript syntax and style.

```bash
gdsentry validate gdscript                    # All .gd files
gdsentry validate gdscript src/core/*.gd      # Specific files
gdsentry validate gdscript --no-style         # Skip style checks
```

**Output**:
```
   GDScript Validation   
┏━━━━━━━━━━━━━━━┳━━━━━━━┓
┃ Metric        ┃ Count ┃
┡━━━━━━━━━━━━━━━╇━━━━━━━┩
│ Files Checked │    45 │
│ Errors        │     0 │
│ Warnings      │    12 │
└───────────────┴───────┘

Warnings:

  ⚠ src/core/test_manager.gd:143: Trailing whitespace found
  ⚠ src/utilities/formatter.gd:89: Line too long (125 > 120 characters)
  ...

GDScript validation passed! ✓
```

### `gdsentry validate imports`

Validate GDScript imports.

```bash
gdsentry validate imports                      # All .gd files
gdsentry validate imports tests/**/*.gd        # Specific pattern
```

**Output**:
```
    Import Validation    
┏━━━━━━━━━━━━━━━┳━━━━━━━┓
┃ Metric        ┃ Count ┃
┡━━━━━━━━━━━━━━━╇━━━━━━━┩
│ Files Checked │    45 │
│ Errors        │     0 │
│ Warnings      │     3 │
└───────────────┴───────┘

Warnings:

  ⚠ tests/core/test.gd: Load path may not exist: res://nonexistent.gd
  ...

Import validation passed! ✓
```

### `gdsentry validate licenses`

Check license headers.

```bash
gdsentry validate licenses                     # All source files
gdsentry validate licenses src/**/*.gd         # Specific pattern
```

**Output**:
```
   License Validation    
┏━━━━━━━━━━━━━━━┳━━━━━━━┓
┃ Metric        ┃ Count ┃
┡━━━━━━━━━━━━━━━╇━━━━━━━┩
│ Files Checked │   150 │
│ Errors        │     0 │
│ Warnings      │    15 │
└───────────────┴───────┘

Warnings:

  ⚠ src/new_file.gd: Missing or invalid license header
  ...

License validation passed! ✓
```

### `gdsentry validate all`

Run all validations.

```bash
gdsentry validate all                          # All checks
gdsentry validate all --no-licenses            # Skip license checks
gdsentry validate all --no-style               # Skip style checks
```

**Output**:
```
Running all validations...

   GDScript Validation   
...

    Import Validation    
...

   License Validation    
...

All validations passed! (30 warnings) ✓
```

---

## Integration Points

### With Slice 1 (Configuration)

Uses project root from config:
```python
from gdsentry.core import load_config

config = load_config()
runner = ValidationRunner(config.project.project_root)
```

### With Slice 5 (Test Discovery)

Can validate discovered test files:
```python
from gdsentry.core import TestDiscovery

discovery = TestDiscovery(project_root)
test_files = discovery.discover_all()

runner = ValidationRunner(project_root)
summary = runner.validate_gdscript_files(test_files)
```

### For CI/CD

Exit codes for automation:
- `0` - All validations passed (warnings OK)
- `1` - Validation failed (errors found)

---

## Self-Tests

### Test Coverage

**Validation Issue** (3 tests):
- ✅ Issue creation
- ✅ String representation with line
- ✅ String representation without line

**GDScript Validator** (4 tests):
- ✅ Validator creation
- ✅ Custom line length
- ✅ Validate existing files
- ✅ Get errors and warnings separately

**Import Validator** (3 tests):
- ✅ Validator creation
- ✅ Expected paths defined
- ✅ Validate existing files

**License Checker** (3 tests):
- ✅ Checker creation
- ✅ Check existing files
- ✅ Get errors and warnings

**Validation Summary** (3 tests):
- ✅ Empty summary
- ✅ Summary with errors
- ✅ Summary with warnings only

**Validation Runner** (6 tests):
- ✅ Runner creation
- ✅ Discover GDScript files
- ✅ Discover source files
- ✅ Validate GDScript files
- ✅ Validate imports
- ✅ Validate licenses

**CLI Integration** (1 test):
- ✅ Validate commands import correctly

**Total**: 23 tests, all passing

### Running Tests

```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
pytest tests/unit/test_validation.py -v
```

---

## Design Decisions

### Why Simple Line-Based Parsing Instead of AST?

**Decision**: Use regex and line-based parsing for GDScript validation

**Rationale**:
- **Simplicity**: No GDScript parser dependency
- **Fast**: Line-based checks are very fast
- **Good enough**: Catches common issues
- **Future**: Can add proper AST parsing later if needed

### Why Warnings for License Headers Instead of Errors?

**Decision**: Missing license headers are warnings, not errors

**Rationale**:
- **Non-blocking**: Don't fail CI for missing headers
- **Gradual adoption**: Can add headers incrementally
- **Focus**: Errors should be syntax/functional issues
- **Flexibility**: Teams can decide policy

### Why Separate Validators Instead of One Big Class?

**Decision**: Split into GDScriptValidator, ImportValidator, LicenseChecker

**Rationale**:
- **Single Responsibility**: Each validator has one job
- **Testability**: Easier to test independently
- **Reusability**: Can use validators separately
- **Extensibility**: Easy to add new validators

### Why ValidationSummary Instead of Direct Results?

**Decision**: Return summary objects instead of raw issue lists

**Rationale**:
- **Consistency**: Same interface for all validators
- **Convenience**: Built-in counts and pass/fail logic
- **Rich Output**: Easy to format for CLI
- **Future**: Can add more metrics without API changes

---

## Limitations & Future Work

### Current Limitations

1. **Simple parsing**: Line-based, doesn't understand full GDScript syntax
2. **No auto-fix**: Only reports issues, doesn't fix them
3. **Limited checks**: Basic syntax and style only
4. **No configuration**: Fixed rules, no customization
5. **No caching**: Re-validates all files every time

### Future Enhancements (Post v2.0)

1. **GDScript AST parsing**: Proper syntax tree analysis
2. **Auto-fix mode**: Automatically fix style issues
3. **Custom rules**: User-defined validation rules
4. **Configuration**: `.gdscript-lint.toml` for custom settings
5. **Caching**: Only validate changed files
6. **More checks**: Complexity metrics, naming conventions, etc.

---

## Usage Examples

### Validate Before Commit

```bash
# Validate all GDScript files
gdsentry validate gdscript

# Validate specific files
gdsentry validate gdscript src/core/test_manager.gd

# Validate without style checks
gdsentry validate gdscript --no-style
```

### CI/CD Integration

```bash
#!/bin/bash
# .github/workflows/validate.yml

# Run all validations
gdsentry validate all

# Exit code 0 = passed, 1 = failed
if [ $? -ne 0 ]; then
  echo "Validation failed!"
  exit 1
fi
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Get staged .gd files
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.gd$')

if [ -n "$FILES" ]; then
  gdsentry validate gdscript $FILES
  
  if [ $? -ne 0 ]; then
    echo "GDScript validation failed. Commit aborted."
    exit 1
  fi
fi
```

---

## Validation Checklist

✅ **Implementation**:
- [x] GDScript validator complete
- [x] Import validator functional
- [x] License checker working
- [x] Validation runner orchestrates all
- [x] CLI commands work

✅ **Testing**:
- [x] 23 unit tests pass
- [x] Validators find real issues
- [x] Summaries aggregate correctly
- [x] CLI integration works

✅ **Documentation**:
- [x] ARCHITECTURE.md updated
- [x] This slice document complete
- [x] Integration points documented
- [x] Usage examples provided

✅ **CLI**:
- [x] `validate gdscript` works
- [x] `validate imports` works
- [x] `validate licenses` works
- [x] `validate all` works
- [x] Help text clear
- [x] Error messages actionable

---

## Next Steps

**Ready for Slice 7**: Documentation Tools

Slice 7 will add:
- Sphinx documentation building
- Live documentation server
- API reference generation
- Documentation validation

---

## Checkpoint

**Slice 6 is complete and validated.**

Test the commands:
```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry

# Validate GDScript
python -m gdsentry validate gdscript src/base_classes/

# Check imports
python -m gdsentry validate imports

# Check licenses
python -m gdsentry validate licenses

# Run all
python -m gdsentry validate all

# Run all self-tests
pytest tests/unit/ -v
```

**Expected**: Beautiful CLI with validation commands, 123 tests passing.

---

## Summary

**Slice 6 delivers code quality validation**:
- ✅ 4 new validation modules
- ✅ 4 CLI commands (gdscript, imports, licenses, all)
- ✅ 23 comprehensive tests
- ✅ Integration with existing slices
- ✅ Professional Rich-formatted output
- ✅ Ready for CI/CD integration

**Total progress**: 123 tests passing across 6 slices! 🎉

