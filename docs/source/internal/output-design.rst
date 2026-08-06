# GDSentry Output Design Language

**Version**: 2.0.0  
**Status**: Living Document  
**Purpose**: Define consistent output patterns across GDScript and Python implementations

---

## Design Principle

**GDSentry uses two output systems**:
1. **GDScript**: ASCII box formatting for Godot console (fixed-width, monospace-safe)
2. **Python CLI**: Rich tables for terminal (dynamic width, colors, modern UX)

**Both share**: Common structure, terminology, and information hierarchy

---

## Common Elements

### Status Indicators

| Status | Symbol | GDScript | Python Rich |
|--------|--------|----------|-------------|
| Passed | ✓ | `[✓]` | `[green]✓[/green]` |
| Failed | ✗ | `[✗]` | `[red]✗[/red]` |
| Warning | ⚠ | `[!]` | `[yellow]⚠[/yellow]` |
| Info | ℹ | `[i]` | `[cyan]ℹ[/cyan]` |

### Duration Format

- Always: `X.XXs` (two decimal places, lowercase 's')
- Examples: `0.05s`, `2.34s`, `120.00s`
- Never: "2.34 seconds", "2.34sec", "2s"

### Count Display

- Format: `X passed, Y total`
- Examples: `5 passed, 10 total`, `0 passed, 3 total`
- Not: "5/10", "5 out of 10", "10 tests (5 passed)"

---

## Test Results Structure

### Information Hierarchy

1. **Test Suites** (highest level)
   - Files containing test classes/methods
   - Example: `test_player.gd`, `test_combat.gd`

2. **Test Cases** (middle level)
   - Individual test methods/functions
   - Example: `test_player_movement()`, `test_health_system()`

3. **Assertions** (lowest level)
   - Individual assert statements
   - Example: `assert_equal(x, y)`, `assert_true(condition)`

### Display Order

Both implementations must show (in this order):

1. **Header**: Test type, scope, architecture
2. **Test Suites**: `[✓] X passed, Y total`
3. **Test Cases**: `[✓] X passed, Y total` (if applicable)
4. **Assertions**: `[✓] X passed, Y total` (if applicable)
5. **Duration**: `X.XXs`
6. **Final Status**: `ALL TESTS PASSED` or `X FAILED`
7. **Coverage**: `X%` or `N/A (not configured)`

---

## Terminology Standards

### Use These Terms

| Concept | Correct Term | Not These |
|---------|--------------|-----------|
| Test file | Test Suite | script, file, module |
| Test method | Test Case | test, function, method |
| Assert statement | Assertion | check, verify, validation |
| Time taken | Duration | time, elapsed, runtime |
| Architecture | Architecture | platform, arch, system |

### Capitalization

- **Test Suites**: Title case in headers
- **test_cases**: Snake case in code
- **Assertions**: Title case in output
- **Duration**: Lowercase in labels

---

## GDScript Implementation (ASCII)

### Box Format

```
╔═══════════════════════════════════════════════════════════════════════════╗
║ Title                                                                     ║
╠═══════════════════════════════════════════════════════════════════════════╣
║ Test Suites: [✓] 5 passed, 5 total                                       ║
║ Test Cases: [✓] 23 passed, 23 total                                      ║
║ Assertions: [✓] 87 passed, 87 total                                      ║
║ Duration: 2.34s                                                           ║
║ Status: ALL TESTS PASSED                                                 ║
║ Coverage: N/A (not configured)                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Constants

- `BOX_WIDTH = 77` (standard terminal width minus margin)
- `CONTENT_WIDTH = 73` (77 - 4 for borders)

### Implementation Reference

See: `src/utilities/output_formatter.gd`

---

## Python CLI Implementation (Rich)

### Table Format

```
     Execution Summary     
┏━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┓
┃ Metric     ┃ Result            ┃
┡━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━┩
│ Test Suites│ ✓ 5 passed, 5 total│
│ Test Cases │ ✓ 23 passed, 23 total│
│ Assertions │ ✓ 87 passed, 87 total│
│ Duration   │ 2.34s             │
│ Status     │ ALL TESTS PASSED  │
│ Coverage   │ N/A               │
└────────────┴───────────────────┘
```

### Colors

- **Headers**: Bold cyan
- **Success**: Green bold
- **Failure**: Red bold
- **Warning**: Yellow
- **Info**: Cyan
- **Paths**: Blue
- **Values**: Green

### Implementation Reference

See: `src/gdsentry/cli/ui/tables.py`, `src/gdsentry/cli/ui/console.py`

---

## Platform Information

### Standard Fields (Both Implementations)

1. **Operating System**: `macos`, `linux`, `windows`
2. **Architecture**: `x86_64`, `arm64`
3. **Python Version**: `3.12.11` (exact version)
4. **Godot Version**: `4.2.2-stable` (full version with stability tag)
5. **QEMU Available**: `Yes` or `No`
6. **Podman Available**: `Yes` or `No`

### Display Order

1. OS
2. Architecture
3. Python/Godot version
4. Tool availability (QEMU, Podman)

---

## Configuration Display

### Standard Sections (Both Implementations)

1. **Project Configuration**
   - Name
   - Godot Version
   - Project Root

2. **Test Configuration**
   - Scope
   - Filter
   - Timeout
   - Parallel
   - Verbose

3. **Platform Configuration**
   - Default Architecture
   - Supported Architectures
   - QEMU Enabled

4. **Container Configuration**
   - Registry
   - Base Image
   - Auto Build
   - Auto Cleanup

---

## Error Messages

### Structure

```
[Context] Error type: Detailed message
Suggestion: Actionable next step
```

### Examples

**GDScript**:
```
[Container] Build failed: Image gdsentry-godot-4.2:arm64 not found
Suggestion: Run 'gdsentry build godot --architecture arm64' or enable auto_build in config
```

**Python CLI**:
```
✗ Container build failed: Image gdsentry-godot-4.2:arm64 not found

Tip: Run 'gdsentry build godot 4.2 --arch arm64' or enable auto_build
```

### Error Levels

1. **Error**: Stops execution, requires user action
2. **Warning**: Continues execution, suggests improvement
3. **Info**: Informational, no action needed

---

## Progress Indicators

### GDScript (ASCII Progress)

```
Running tests... [=====>    ] 50% (5/10)
```

### Python (Rich Progress)

```
⠋ Running tests... ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 50% 0:00:05
```

---

## Future: ASCII Formatter for Python (Optional)

If exact visual consistency is needed (CI logs, documentation, comparison):

```python
# src/gdsentry/cli/ui/ascii_formatter.py
class ASCIIFormatter:
    """Python implementation matching GDScript OutputFormatter"""
    
    @staticmethod
    def format_execution_summary(stats: TestStats) -> str:
        """Returns exact same ASCII box format as GDScript"""
        # Implements same BOX_WIDTH, formatting logic
        pass
```

**Usage**:
```bash
gdsentry test --output ascii    # Matches GDScript output exactly
gdsentry test --output rich     # Default, modern Rich output
```

**When to implement**: After Slice 5 (Test Execution) when we have actual test results to format

---

## Consistency Checklist

When adding new output features:

- [ ] Uses standard terminology (Test Suites, Test Cases, Assertions)
- [ ] Duration in `X.XXs` format
- [ ] Status indicators: ✓ passed, ✗ failed
- [ ] Counts in `X passed, Y total` format
- [ ] Error messages include context and suggestions
- [ ] Same information hierarchy in both implementations
- [ ] GDScript: Fixed 77-character width
- [ ] Python: Dynamic width with Rich tables

---

## References

- **GDScript Implementation**: `src/utilities/output_formatter.gd`
- **Python Rich UI**: `src/gdsentry/cli/ui/`
- **Design Philosophy**: Modern, professional, consistent
- **User Experience**: Clear, actionable, beautiful

---

**This document ensures GDSentry maintains consistent UX across all output contexts.**

