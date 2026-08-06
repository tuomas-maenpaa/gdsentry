# Slice 3: CLI Framework & Basic Commands

**Status**: ✅ Complete  
**Dependencies**: Slice 1 (Configuration), Slice 2 (Platform Detection)  
**Provides**: Typer CLI framework, Rich UI components, info commands for all other slices

---

## Purpose

Build the command-line interface foundation for GDSentry:
- Main Typer application with command groups
- Rich UI components (console, progress bars, tables)
- Info commands (platform, config, env)
- Beautiful terminal output with colors and formatting
- Tab completion support

---

## Files Created

### CLI Application

```
src/gdsentry/
├── __main__.py                  # Enable python -m gdsentry
└── cli/
    ├── __init__.py              # CLI exports
    ├── app.py                   # Main Typer app
    ├── ui/
    │   ├── __init__.py          # UI exports
    │   ├── console.py           # Rich console wrapper
    │   ├── progress.py          # Progress bars & spinners
    │   ├── tables.py            # Table utilities
    │   └── styles.py            # Style constants
    └── commands/
        ├── __init__.py          # Commands exports
        └── info.py              # Info command group
```

### Tests

```
tests/unit/
└── test_cli_basics.py           # CLI tests
```

### Documentation

```
docs/source/internal/implementation/
└── slice-03-cli-framework.rst   # This file
```

---

## Implementation Details

### Main Typer Application

**Features**:
- Command group structure (info, test, build, validate, etc.)
- Rich help formatting
- Tab completion support (bash, zsh, fish)
- No-args shows help (user-friendly)

**Entry Points**:
```bash
gdsentry --help              # Via console_scripts
python -m gdsentry --help    # Via __main__.py
```

### Rich UI Components

**Console (`src/gdsentry/cli/ui/console.py`)**:
- Global themed console instance
- Helper functions: `success()`, `error()`, `warning()`, `info()`
- Header and key-value formatting
- Emoji support (can be disabled)

**Progress (`src/gdsentry/cli/ui/progress.py`)**:
- Progress bars for determinate operations
- Spinners for indeterminate operations
- Time elapsed tracking

**Tables (`src/gdsentry/cli/ui/tables.py`)**:
- Info tables (key-value pairs)
- Data tables (headers + rows)
- Styled borders and headers

**Styles (`src/gdsentry/cli/ui/styles.py`)**:
- Consistent color scheme
- Style constants
- Formatting helpers

### Info Commands

**`gdsentry info platform`**:
- Shows OS, architecture, Python version
- QEMU and Podman availability
- Compatible Godot versions for current architecture

**`gdsentry info config`**:
- Displays current configuration
- Shows project, test, platform, container settings
- Accepts `--path` to specify config file

**`gdsentry info env`**:
- Shows development environment details
- Python executable, version, path
- Working directory

---

## API Examples

### Using the CLI

```bash
# Show help
gdsentry --help
gdsentry info --help

# Platform information
gdsentry info platform

# Configuration
gdsentry info config
gdsentry info config --path custom.toml

# Environment
gdsentry info env
```

### Using UI Components in Code

```python
from gdsentry.cli.ui import console, success, error, create_table

# Print messages
success("Operation completed!")
error("Something went wrong")

# Create tables
table = create_table(title="Test Results")
table.add_column("Test", style="cyan")
table.add_column("Status", style="green")
table.add_row("test_player.gd", "PASSED")
console.print(table)

# Progress bars
from gdsentry.cli.ui import create_progress

with create_progress() as progress:
    task = progress.add_task("Running tests...", total=100)
    for i in range(100):
        # do work
        progress.update(task, advance=1)
```

### Adding New Commands

```python
# In a new command file
import typer
from gdsentry.cli.ui import console, success

app = typer.Typer(help="My command group")

@app.command()
def my_command(
    option: str = typer.Option("default", help="An option"),
):
    """My command description."""
    console.print(f"Running with option: {option}")
    success("Done!")

# In app.py, register it:
# app.add_typer(my_command.app, name="mycommand")
```

---

## Integration Points

### With Slice 1 (Configuration)

Uses configuration loading:
```python
from gdsentry.core.config import load_config

config = load_config()
# Display config in info command
```

### With Slice 2 (Platform Detection)

Uses platform detection:
```python
from gdsentry.platform import detect_platform

info = detect_platform()
# Display platform info in info command
```

### For Slice 4 (Container Management)

Provides UI for container operations:
```python
from gdsentry.cli.ui import create_progress, success

with create_progress() as progress:
    task = progress.add_task("Building container...", total=100)
    # build container
    success("Container built!")
```

### For Slice 5 (Test Execution)

Provides UI for test results:
```python
from gdsentry.cli.ui import create_table, console

# Display test results table
table = create_table(title="Test Results")
table.add_column("Test File")
table.add_column("Status")
# ... add rows
console.print(table)
```

---

## Self-Tests

### Test Coverage

**CLI Basics**:
- ✅ CLI help works
- ✅ No args shows help

**Info Commands**:
- ✅ Info help works
- ✅ Info platform shows platform data
- ✅ Info config handles missing config
- ✅ Info env shows environment

**UI Components**:
- ✅ Console can be imported
- ✅ Console functions are callable
- ✅ Progress bars can be created
- ✅ Tables can be created

**Integration**:
- ✅ CLI uses platform detection
- ✅ CLI uses configuration system
- ✅ Main entrypoint works
- ✅ python -m gdsentry works

### Running Tests

```bash
# Activate conda environment
conda activate gdsentry

# Run Slice 3 tests
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
pytest tests/unit/test_cli_basics.py -v

# Test the CLI directly
python -m gdsentry --help
python -m gdsentry info platform
```

---

## Design Decisions

### Why Typer?

**Decision**: Use Typer for CLI framework

**Rationale**:
- Modern Python CLI framework (successor to Click)
- Automatic type validation from type hints
- Built-in Rich integration for beautiful output
- Automatic help generation
- Tab completion support
- Minimal boilerplate

### Why Rich?

**Decision**: Use Rich for terminal output

**Rationale**:
- Beautiful, modern terminal UI
- Progress bars, spinners, tables
- Color themes and styling
- Wide terminal compatibility
- Used by major Python projects (pytest, pip, etc.)
- Professional appearance

### Why Separate UI Module?

**Decision**: Create `cli/ui/` module for UI components

**Rationale**:
- Reusable across all commands
- Consistent styling throughout CLI
- Easy to modify theme
- Testable in isolation
- Clear separation of concerns

### Why Command Groups?

**Decision**: Use Typer command groups (info, test, build, etc.)

**Rationale**:
- Logical organization of commands
- Scalable (each slice adds its commands)
- Familiar pattern (like git, docker, )
- Easy to discover related commands
- Better help organization

---

## CLI Design Philosophy

### User Experience Principles

1. **Discoverability**: Help at every level
2. **Clarity**: Clear error messages with suggestions
3. **Feedback**: Progress indicators for long operations
4. **Beauty**: Professional, polished appearance
5. **Consistency**: Same patterns across all commands

### Command Naming

- Verbs for actions: `test`, `build`, `validate`
- Nouns for queries: `info`, `status`
- Short, memorable names
- Aliases where helpful

### Output Design

- **Success**: Green with ✓
- **Error**: Red with ✗
- **Warning**: Yellow with ⚠
- **Info**: Cyan with ℹ
- **Tables**: For structured data
- **Progress**: For long operations

---

## Future Commands (Other Slices)

### Slice 4 (Container Management)
```bash
gdsentry build base --arch arm64
gdsentry build godot 4.2 --arch x86_64
gdsentry build all
```

### Slice 5 (Test Execution)
```bash
gdsentry test
gdsentry test --arch x86_64
gdsentry test --all-arch
gdsentry test --filter "Player*"
```

### Slice 6 (Validation)
```bash
gdsentry validate gdscript
gdsentry validate all
```

### Slice 7 (Documentation)
```bash
gdsentry docs build
gdsentry docs serve
gdsentry docs linkcheck
```

### Slice 8 (Developer Tools)
```bash
gdsentry init
gdsentry generate test MyClass
gdsentry clean all
```

---

## Tab Completion

### Enable Tab Completion

```bash
# Bash
gdsentry --install-completion bash

# Zsh
gdsentry --install-completion zsh

# Fish
gdsentry --install-completion fish
```

### How It Works

Typer automatically generates completion scripts for:
- Command names
- Option names
- Option values (for enums/choices)

---

## Error Handling

### Error Display Pattern

```python
from gdsentry.cli.ui import console, error
import typer

try:
    # operation
    pass
except SomeError as e:
    error(f"Operation failed: {e}")
    console.print("\n[yellow]Tip:[/yellow] Try adding --verbose for more details")
    raise typer.Exit(1)
```

### Exit Codes

- `0`: Success
- `1`: General error
- `2`: Configuration error
- `3`: Test failures
- Other codes as needed

---

## Validation Checklist

✅ **Implementation**:
- [x] All files created
- [x] Typer app with Rich integration
- [x] Info commands working
- [x] UI components reusable
- [x] __main__.py entry point

✅ **Testing**:
- [x] CLI tests pass
- [x] All info commands work
- [x] UI components tested
- [x] Integration with Slices 1 & 2

✅ **Documentation**:
- [x] ARCHITECTURE.md updated
- [x] This slice document complete
- [x] Command examples provided
- [x] Integration points documented

✅ **User Experience**:
- [x] Beautiful output
- [x] Clear help messages
- [x] Consistent styling
- [x] Error handling

---

## Next Steps

**Ready for Slice 4**: Container Management (Local Only)

Slice 4 will add:
- `gdsentry build` command group
- Container lifecycle management
- Image building (wraps existing bash scripts)
- Podman integration

---

## Checkpoint

**Slice 3 is complete and validated.**

Test the CLI:
```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry

# Test via Python module
python -m gdsentry --help
python -m gdsentry info platform
python -m gdsentry info env

# Run tests
pytest tests/unit/test_cli_basics.py -v
```

Expected output: Beautiful, colored CLI output with platform information.

