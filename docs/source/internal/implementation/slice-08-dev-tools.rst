# Slice 8: Development Tools

**Status**: ✅ Complete  
**Dependencies**: Slice 1 (Config), Slice 3 (CLI)  
**Provides**: Project initialization and template generation

---

## Purpose

Implement development tools for GDSentry:
- Project initialization (`gdsentry init project`)
- Test template generation (`gdsentry init test`)
- Interactive configuration
- Development workflow automation

These tools make it easy to start using GDSentry and maintain test quality.

---

## Files Created

### Templates Module

```
src/gdsentry/templates/
├── __init__.py           # Templates exports
├── init.py               # Project initializer
└── generator.py          # Test template generator
```

### CLI Commands

```
src/gdsentry/cli/commands/
└── init.py              # Init commands
```

### Tests

```
tests/unit/
└── test_dev_tools.py    # 18 comprehensive tests
```

### Documentation

```
docs/source/internal/implementation/
└── slice-08-dev-tools.rst  # This file
```

---

## Implementation Details

### Project Initializer (`init.py`)

**Purpose**: Initialize new GDSentry projects

**Creates**:
- `gdsentry.toml` - Complete configuration file
- `tests/` directory structure (unit, integration, performance)
- `tests/example_test.gd` - Example test file
- `GDSENTRY_README.md` - Quick start guide

**API**:
```python
initializer = ProjectInitializer(project_root)

initializer.initialize(
    project_name="my_game",
    godot_version="4.2.2-stable",
    interactive=False,
)

created_files = initializer.get_created_files()
```

**Configuration Template**:
Creates a complete `gdsentry.toml` with:
- Project settings (name, Godot version)
- Test configuration (scope, timeout, parallel)
- Platform settings (architectures, QEMU)
- Container configuration (registry, auto-build)
- Validation settings (syntax, imports, licenses)
- Documentation settings (format, theme)
- CI/CD settings (platforms, versions)

**Example Test**:
Generates a working example test demonstrating:
- Basic assertions
- Equality tests
- Collection assertions
- GDSentry best practices

### Template Generator (`generator.py`)

**Purpose**: Generate test files from templates

**Supports**:
- **Unit tests**: Standard test structure with setup/teardown
- **Integration tests**: System integration testing
- **Performance tests**: Benchmarking and profiling
- **Scene tests**: UI and scene-based testing

**API**:
```python
generator = TemplateGenerator(project_root)

test_file = generator.generate_test(
    name="player_movement",
    test_type="unit",
    base_class="GDTest",
    output_dir=Path("tests/custom"),
)
```

**Features**:
- Snake_case to PascalCase conversion
- Customizable output directories
- Prevents file overwriting
- Complete test structure with TODOs

---

## CLI Commands

### `gdsentry init project`

Initialize a new GDSentry project.

```bash
gdsentry init project                      # Current directory
gdsentry init project my_game              # Specific directory
gdsentry init project --name "My Game"     # Custom name
gdsentry init project --godot 3.5          # Specific Godot version
gdsentry init project --interactive        # Interactive prompts
```

**Output**:
```
Initializing GDSentry project...

✓ Project initialized successfully!

Created files:
  ✓ gdsentry.toml
  ✓ GDSENTRY_README.md
  ✓ tests/example_test.gd

Next steps:
  1. Review gdsentry.toml configuration
  2. Run: gdsentry test discover
  3. Run: gdsentry test run

Project directory: /path/to/project
```

**Interactive Mode**:
```bash
$ gdsentry init project --interactive

Project name [my_game]: Space Shooter
Godot version [4.2.2-stable]: 4.2.2-stable

✓ Project initialized successfully!
```

### `gdsentry init test`

Generate a new test file from template.

```bash
gdsentry init test player_movement         # Unit test (default)
gdsentry init test game_loop --type integration
gdsentry init test pathfinding --type performance
gdsentry init test main_menu --type scene
gdsentry init test custom --output tests/custom/
```

**Output**:
```
Generating unit test...

✓ Test generated: tests/unit/player_movement_test.gd

Next steps:
  1. Edit tests/unit/player_movement_test.gd
  2. Implement your test logic
  3. Run: gdsentry test run --category unit
```

**Generated Test Types**:

**Unit Test**:
- Extends `GDTest`
- Setup/teardown methods
- Basic functionality tests
- Edge case handling

**Integration Test**:
- Component integration
- Data flow testing
- System interaction

**Performance Test**:
- Execution time benchmarks
- Memory usage profiling
- Scalability tests

**Scene Test**:
- Extends `SceneTreeTest`
- Scene loading
- Node hierarchy validation
- UI interactions

---

## Integration Points

### With Slice 1 (Configuration)

Generates complete `gdsentry.toml`:
```toml
[project]
name = "my_game"
godot_version = "4.2.2-stable"

[test]
scope = "project"
timeout = 300

# ... complete configuration
```

### With Slice 5 (Test Discovery)

Generated tests are automatically discovered:
```bash
# After init
gdsentry test discover

# Shows:
# - tests/example_test.gd
# - tests/unit/*.gd
# - tests/integration/*.gd
```

### For New Projects

Perfect first steps:
```bash
# 1. Initialize
gdsentry init project my_game

# 2. Generate tests
cd my_game
gdsentry init test player --type unit
gdsentry init test level --type integration

# 3. Run tests
gdsentry test run

# 4. Validate
gdsentry validate all

# 5. Build docs
gdsentry docs build
```

---

## Self-Tests

### Test Coverage

**Project Initializer** (7 tests):
- ✅ Initializer creation
- ✅ Creates configuration file
- ✅ Creates directory structure
- ✅ Creates example test
- ✅ Creates README
- ✅ Fails if config exists
- ✅ Get created files list

**Template Generator** (8 tests):
- ✅ Generator creation
- ✅ Generate unit test
- ✅ Generate integration test
- ✅ Generate performance test
- ✅ Generate scene test
- ✅ Custom output directory
- ✅ Fails if file exists
- ✅ Snake_case to PascalCase conversion

**Exceptions** (2 tests):
- ✅ InitializationError
- ✅ TemplateError

**CLI Integration** (1 test):
- ✅ Init commands import correctly

**Total**: 18 tests, all passing

### Running Tests

```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry
pytest tests/unit/test_dev_tools.py -v
```

---

## Design Decisions

### Why TOML for Configuration?

**Decision**: Use TOML for `gdsentry.toml`

**Rationale**:
- **Readability**: Clean, human-friendly syntax
- **Standard**: Used by Rust, Python (pyproject.toml)
- **Type-safe**: Better than YAML for config
- **Comments**: Supports inline comments
- **Pydantic**: Excellent TOML support

### Why Templates Instead of Copying?

**Decision**: Generate from templates with substitution

**Rationale**:
- **Consistency**: All tests follow same structure
- **Customization**: Easy to adapt templates
- **Best Practices**: Encode framework patterns
- **Evolution**: Can improve templates over time

### Why Separate unit/integration/performance?

**Decision**: Different templates for different test types

**Rationale**:
- **Clarity**: Each type has specific patterns
- **Guidance**: Templates guide proper test structure
- **Organization**: Natural directory structure
- **Standards**: Encode testing best practices

### Why Interactive Mode?

**Decision**: Optional `--interactive` flag for prompts

**Rationale**:
- **Flexibility**: CLI-friendly by default
- **Beginner-friendly**: Prompts for new users
- **CI-friendly**: Non-interactive by default
- **Best of both**: Supports both workflows

---

## Limitations & Future Work

### Current Limitations

1. **No custom templates**: Can't provide own templates
2. **Basic validation**: Limited project name validation
3. **No undo**: Can't rollback initialization
4. **English only**: No i18n support
5. **Simple templates**: Basic structure only

### Future Enhancements (Post v2.0)

1. **Custom templates**: User-defined template directory
2. **Template marketplace**: Share community templates
3. **Project scaffolding**: Full project structure
4. **Undo/rollback**: Revert initialization
5. **Internationalization**: Multi-language support
6. **Advanced templates**: More sophisticated patterns

---

## Usage Examples

### Initialize New Project

```bash
# Quick start
gdsentry init project

# Named project
gdsentry init project space_shooter

# Specific directory
gdsentry init project ~/projects/my_game

# Custom configuration
gdsentry init project \
  --name "Space Shooter" \
  --godot 4.2.2-stable \
  --interactive
```

### Generate Tests

```bash
# Unit test for player
gdsentry init test player

# Integration test for game loop
gdsentry init test game_loop --type integration

# Performance test for pathfinding
gdsentry init test pathfinding --type performance

# Scene test for main menu
gdsentry init test main_menu --type scene

# Custom output directory
gdsentry init test weapon_system \
  --type unit \
  --output tests/combat/
```

### Complete Workflow

```bash
# 1. Create new project
mkdir awesome_game
cd awesome_game
gdsentry init project

# 2. Generate tests
gdsentry init test player --type unit
gdsentry init test combat_system --type integration
gdsentry init test frame_rate --type performance

# 3. Discover tests
gdsentry test discover

# 4. Run tests
gdsentry test run

# 5. Validate code
gdsentry validate all

# 6. Build documentation
gdsentry docs build

# 7. Serve docs locally
gdsentry docs serve
```

---

## Validation Checklist

✅ **Implementation**:
- [x] Project initializer complete
- [x] Template generator functional
- [x] Configuration generation works
- [x] Example test creates properly
- [x] CLI commands work

✅ **Testing**:
- [x] 18 unit tests pass
- [x] Initialization creates all files
- [x] Templates generate correctly
- [x] CLI integration works

✅ **Documentation**:
- [x] ARCHITECTURE.md updated
- [x] This slice document complete
- [x] Integration points documented
- [x] Usage examples provided

✅ **CLI**:
- [x] `init project` works
- [x] `init test` works
- [x] Interactive mode works
- [x] Help text clear
- [x] Error messages actionable

---

## Checkpoint

**Slice 8 is complete and validated.**

**🎉 ALL 8 SLICES COMPLETE! 🎉**

Test the commands:
```bash
conda activate gdsentry
cd /Users/tuomas.maenpaa/Src/MyCode/gdsentry

# Initialize a test project
python -m gdsentry init project /tmp/test_project

# Generate a test
python -m gdsentry init test example --type unit

# Run all self-tests
pytest tests/unit/ -v

# Result: 153 passed, 6 warnings in 3.32s
```

---

## Summary

**Slice 8 delivers development workflow automation**:
- ✅ 3 new template modules
- ✅ 2 CLI commands (project, test)
- ✅ 18 comprehensive tests
- ✅ Complete project scaffolding
- ✅ 4 test type templates
- ✅ Interactive mode support

**Total progress**: 153 tests passing across 8 slices! 🎉

**100% COMPLETE!** All slices implemented! 🚀

