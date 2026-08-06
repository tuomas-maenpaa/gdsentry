User Guide
==========

This comprehensive guide teaches you how to write effective tests for your Godot projects using GDSentry CLI. Learn test patterns, assertions, organization, and best practices.

.. note::
   **Prerequisite**: Complete the :doc:`installation` and :doc:`getting-started` guides first.

Writing Your First Tests
========================

Tests in GDSentry are written in GDScript and live in your Godot project. Unlike traditional testing frameworks, GDSentry runs externally using the CLI, so your tests are just regular GDScript files.

Basic Test Structure
--------------------

Every GDSentry test follows this pattern:

.. code-block:: gdscript

    # tests/test_player.gd
    extends SceneTreeTest

    func run_test_suite() -> void:
        run_test("test_player_health", func(): return test_player_health())
        run_test("test_player_movement", func(): return test_player_movement())

    func test_player_health() -> bool:
        var player = Player.new()
        player.take_damage(25)
        return assert_equals(player.health, 75)

    func test_player_movement() -> bool:
        var player = Player.new()
        player.move(Vector2(10, 5))
        return assert_equals(player.position, Vector2(10, 5))

Key Elements:

1. **Extends a Test Class**: ``SceneTreeTest``, ``Node2DTest``, ``PerformanceTest``, etc.
2. **run_test_suite() Function**: Registers all test functions
3. **run_test() Calls**: Each test method with a descriptive name
4. **Test Methods**: Return ``bool`` indicating pass/fail
5. **Assertions**: Use ``assert_*()`` functions to validate expectations

Project Organization
====================

Structure your tests to match your game's architecture:

Directory Structure
-------------------

.. code-block:: text

    your-godot-project/
    ├── tests/
    │   ├── unit/              # Fast, isolated logic tests
    │   │   ├── test_player.gd
    │   │   ├── test_inventory.gd
    │   │   └── test_combat.gd
    │   ├── visual/            # UI and visual component tests
    │   │   ├── test_main_menu.gd
    │   │   ├── test_hud.gd
    │   │   └── test_dialogue.gd
    │   ├── integration/       # Multi-system interaction tests
    │   │   ├── test_level_loading.gd
    │   │   └── test_save_system.gd
    │   └── performance/       # Performance and load tests
    │       └── test_frame_rate.gd
    ├── scripts/
    │   ├── player.gd
    │   ├── inventory.gd
    │   └── ui/
    └── scenes/
        ├── main_menu.tscn
        └── game_world.tscn

Naming Conventions
------------------

Follow these patterns for automatic discovery:

**Test Files:**
- End with ``_test.gd`` (e.g., ``player_controller_test.gd``)
- Use descriptive names that indicate what's being tested
- Group related tests in the same file when they test the same component

**Test Methods:**
- Start with ``test_`` (e.g., ``test_player_movement``)
- Use descriptive names that explain the specific behavior being tested
- Include the expected outcome in the name when helpful

**Test Classes:**
- Extend appropriate base classes (``SceneTreeTest``, ``Node2DTest``, etc.)
- Use descriptive class names that match the component being tested
- Include metadata for categorization and filtering

Test Discovery Patterns
-----------------------

GDSentry automatically discovers tests based on several patterns:

**File-based Discovery:**
- Scans directories specified in ``DEFAULT_TEST_DIRECTORIES``
- Finds files ending with ``_test.gd``
- Validates that test classes extend recognized base classes

**Class-based Discovery:**
- Identifies classes that inherit from GDSentry base classes
- Categorizes tests by their base class type
- Supports custom test categories through metadata

**Method-based Discovery:**
- Finds methods starting with ``test_``
- Supports async test methods with ``await``
- Allows test methods to be organized in ``run_test_suite()`` functions

**Metadata-driven Organization:**
- Uses test tags for flexible categorization (``unit``, ``integration``, ``performance``)
- Supports priority levels (``low``, ``medium``, ``high``, ``critical``)
- Enables category-based filtering (``core``, ``ui``, ``gameplay``)

Best Practices for Game Testing
===============================

Choosing the right testing approach for different aspects of your game is essential for creating maintainable and effective test suites. GDSentry provides specialized base classes optimized for different testing scenarios.

When to Use Each Test Type
--------------------------

**SceneTreeTest (Unit Testing):**
Use for testing isolated game logic that doesn't require the Godot scene tree or visual components. Ideal for:

- Mathematical calculations and algorithms
- Data processing and validation
- Business logic and game rules
- Utility functions and helpers
- Pure logic components without visual dependencies

SceneTreeTest provides the fastest execution speed and is perfect for testing the core algorithms that power your game.

**Node2DTest (Visual Testing):**
Use when you need to test visual components, UI elements, or any code that interacts with the scene tree. Best for:

- UI layout and positioning
- Button interactions and event handling
- Sprite rendering and animations
- Visual state validation
- Layout constraints and responsive design
- Canvas-based visual effects

Node2DTest runs in the Godot scene tree environment, allowing you to test actual visual behavior and user interactions.

**IntegrationTest (Full System Testing):**
Use for testing complete game flows and interactions between multiple systems. Essential for:

- Complete gameplay scenarios
- Scene transitions and loading
- Multi-system interactions
- End-to-end user workflows
- Complex state management
- Cross-component communication

IntegrationTest allows you to test how different parts of your game work together as a complete system.

**PerformanceTest (Load and Stress Testing):**
Use for validating performance requirements and identifying bottlenecks. Critical for:

- Frame rate validation under load
- Memory usage monitoring
- CPU performance benchmarking
- Stress testing with simulated load
- Performance regression detection
- Resource usage optimization

PerformanceTest provides specialized assertions for measuring and validating performance metrics.

Assertions and Validation
=========================

GDSentry provides a rich set of assertion functions to validate your game's behavior. All assertions return ``bool`` and automatically provide descriptive error messages.

Basic Assertions
----------------

**Equality and Comparison:**

.. code-block:: gdscript

    # Value equality
    assert_equals(actual_value, expected_value)
    assert_not_equals(value1, value2)

    # Numeric comparisons
    assert_greater_than(actual, minimum)
    assert_less_than(actual, maximum)
    assert_between(value, min_val, max_val)

    # Floating point (with tolerance)
    assert_almost_equals(actual, expected, tolerance=0.01)

**Truth and Null Checks:**

.. code-block:: gdscript

    # Boolean assertions
    assert_true(condition)
    assert_false(condition)

    # Null/reference checks
    assert_null(value)
    assert_not_null(value)

Visual and UI Assertions
-------------------------

**Node and Scene Validation:**

.. code-block:: gdscript

    # Node existence and visibility
    assert_visible(node)
    assert_hidden(node)

    # Position and size validation
    assert_position(node, expected_position, tolerance=1.0)
    assert_size(node, expected_size)

    # Node hierarchy
    assert_has_child(parent, child_name)
    assert_child_count(node, expected_count)

**String and Text Assertions:**

.. code-block:: gdscript

    # Text content validation
    assert_text_equals(label, "Expected Text")
    assert_contains_text(label, "partial text")
    assert_text_length(label, expected_length)

Performance Assertions
----------------------

**Timing and FPS:**

.. code-block:: gdscript

    # Frame rate validation
    assert_fps_above(min_fps, duration=1.0)
    assert_fps_stable(target_fps, variance=5.0, duration=2.0)

    # Execution time limits
    assert_execution_time_less_than(func_ref, max_seconds)

**Resource Monitoring:**

.. code-block:: gdscript

    # Memory usage validation
    assert_memory_usage_less_than(max_mb)
    assert_memory_growth_less_than(max_growth_mb, duration=5.0)

    # Object counting
    assert_object_count_less_than(max_objects)

Custom Assertions
-----------------

Create domain-specific assertions for your game:

.. code-block:: gdscript

    func assert_player_alive(player: Player) -> bool:
        return assert_true(player.health > 0, "Player should be alive")

    func assert_inventory_contains(player: Player, item_name: String) -> bool:
        var has_item = player.inventory.has_item(item_name)
        return assert_true(has_item, "Player should have " + item_name)

    func assert_position_in_bounds(node: Node2D, bounds: Rect2) -> bool:
        var in_bounds = bounds.has_point(node.position)
        return assert_true(in_bounds, "Position should be within bounds")

Test Isolation and Dependencies
-------------------------------

**Mocking and Stubbing:**
- Use GDSentry's mocking capabilities to isolate units under test
- Replace external dependencies with test doubles
- Simulate complex system interactions without full implementation
- Test error conditions and edge cases safely

**Fixture Management:**
- Set up test data and state in ``before_each()`` methods
- Clean up resources in ``after_each()`` methods
- Share common setup code across related tests
- Ensure tests don't interfere with each other

**Test Data Generation:**
- Create varied test inputs to cover edge cases
- Use data-driven testing for comprehensive coverage
- Generate random but valid test data
- Test boundary conditions systematically

Test Discovery and Configuration
================================

Understanding how GDSentry finds and configures your tests is crucial for organizing large test suites effectively.

Automatic Test Discovery
------------------------

GDSentry automatically discovers tests using these patterns:

**Directory Scanning:**
- Searches for ``tests/`` and ``test/`` directories in your project root
- Recursively scans subdirectories for test files
- Supports custom directory paths via configuration

**File Pattern Matching:**
- Finds files ending with ``_test.gd`` (e.g., ``player_test.gd``, ``combat_system_test.gd``)
- Ignores files that don't follow the naming convention
- Case-sensitive matching

**Class Detection:**
- Identifies GDScript classes that extend GDSentry base classes:
  - ``SceneTreeTest`` - Unit tests
  - ``Node2DTest`` - Visual/UI tests
  - ``IntegrationTest`` - System integration tests
  - ``PerformanceTest`` - Performance benchmarks

**Method Discovery:**
- Finds all methods starting with ``test_`` in test classes
- Supports both synchronous and asynchronous test methods
- Methods must return ``bool`` (pass/fail status)

Configuration Options
--------------------

Control test discovery and execution through ``gdsentry.toml``:

.. code-block:: toml

    [project]
    # Test discovery settings
    test_directories = ["tests/", "test/"]  # Directories to scan
    godot_version = "4.2.2-stable"          # Target Godot version

    [test]
    # Execution settings
    timeout = 30.0         # Seconds per test
    fail_fast = false      # Stop on first failure
    parallel = true        # Run tests in parallel

    [discovery]
    # Advanced discovery options
    recursive = true       # Scan subdirectories
    pattern = "*_test.gd"  # File name pattern
    exclude_patterns = ["temp_*", "backup_*"]  # Files to ignore

Selective Test Execution
------------------------

Run specific subsets of your tests:

**By Category:**
.. code-block:: bash

    gdsentry test run --category unit      # Only unit tests
    gdsentry test run --category visual    # Only UI/visual tests
    gdsentry test run --category integration  # Only integration tests

**By File:**
.. code-block:: bash

    gdsentry test run --file tests/unit/player_test.gd
    gdsentry test run --dir tests/unit/     # All tests in directory

**By Pattern:**
.. code-block:: bash

    gdsentry test run --filter "*player*"  # Tests containing "player"
    gdsentry test run --filter "test_movement"  # Specific test method

**Quick Checks:**
.. code-block:: bash

    gdsentry test quick     # Fast smoke test (framework tests)
    gdsentry test discover  # Show all discoverable tests without running

Cross-Platform Testing
----------------------

Test across different architectures from a single machine:

**Architecture-Specific Testing:**
.. code-block:: bash

    gdsentry test run --arch x86_64  # Test x86_64 compatibility
    gdsentry test run --arch arm64   # Test ARM64 performance
    gdsentry test run --all-architectures  # Test all supported architectures

**Container Requirements:**
- Uses Podman/Docker for cross-architecture execution
- Requires architecture-specific container images
- Automatic fallback to native architecture if containers unavailable

Configuration File Locations
----------------------------

GDSentry looks for configuration in order of priority:

1. ``gdsentry.toml`` (project root) - Recommended for project-specific settings
2. ``.gdsentry.toml`` (project root) - Alternative naming
3. Environment variables (``GDSENTRY_*``) - For CI/CD overrides
4. Built-in defaults - Sensible fallbacks

**Example Configuration File:**

.. code-block:: toml

    [project]
    name = "My Game"
    godot_version = "4.2.2-stable"
    test_directories = ["tests/", "integration/"]

    [test]
    timeout = 45.0
    fail_fast = true
    parallel = true

    [report]
    formats = ["console", "html", "junit"]
    output_dir = "test-reports"

    [container]
    base_image = "gdsentry-base"
    architecture = "x86_64"

Environment Variable Overrides
------------------------------

Override configuration with environment variables:

.. code-block:: bash

    # Execution settings
    export GDSENTRY_TEST_TIMEOUT=60
    export GDSENTRY_FAIL_FAST=true

    # Project settings
    export GDSENTRY_PROJECT_GODOT_VERSION="4.2.1-stable"
    export GDSENTRY_TEST_DIRECTORIES="tests/,custom_tests/"

    # Run with overrides
    gdsentry test run

Common Discovery Issues
-----------------------

**Tests Not Found:**
- Ensure test files end with ``_test.gd``
- Check that test classes extend GDSentry base classes
- Verify test directories are named ``tests/`` or configured in ``gdsentry.toml``
- Use ``gdsentry test discover`` to see what tests are found

**Wrong Test Categories:**
- Check which base class your tests extend
- SceneTreeTest → unit category
- Node2DTest → visual category
- IntegrationTest → integration category

**Configuration Not Applied:**
- Ensure ``gdsentry.toml`` is in project root
- Check file syntax (valid TOML)
- Use environment variables for testing overrides

**Cross-Architecture Issues:**
- Ensure Podman/Docker is installed and running
- Build required container images: ``gdsentry build all``
- Check that target architecture is supported

Writing Maintainable Tests
--------------------------

**Descriptive Test Names:**
- Write test names that explain what behavior is being verified
- Include the expected outcome in the test name
- Use consistent naming patterns across your test suite
- Make test failures self-explanatory

**Clear Test Structure:**
- Follow the Arrange-Act-Assert pattern
- Keep individual tests focused on single behaviors
- Use descriptive variable names in tests
- Add comments for complex test scenarios

**Test Documentation:**
- Include test metadata (description, tags, priority, category)
- Document complex test setups and assumptions
- Explain the purpose of parametrized tests
- Maintain up-to-date test documentation

Godot Editor Integration and Workflow
=====================================

GDSentry CLI integrates smoothly with your Godot development workflow. Run tests from your terminal, get results in your editor, and iterate quickly on game features.

Terminal-Based Testing Workflow
-------------------------------

**Quick Test Runs:**
.. code-block:: bash

    # In your Godot project directory
    gdsentry test run                    # Run all tests
    gdsentry test run --category unit    # Run only unit tests
    gdsentry test run --verbose          # Detailed output

**Test Discovery:**
.. code-block:: bash

    gdsentry test discover              # See all available tests
    gdsentry test discover --dir tests/unit/  # Check specific directory

**Rapid Iteration:**
.. code-block:: bash

    # Test as you develop
    gdsentry test quick                 # Fast framework validation
    gdsentry test run --fail-fast       # Stop on first failure

Editor Integration Tips
-----------------------

**VS Code Integration:**

*Install VS Code extensions for GDScript:*
- "geequlim.gdscript" - GDScript syntax highlighting
- "geequlim.gdscript-toolkit" - Enhanced GDScript support

*Add test running tasks to ``.vscode/tasks.json``:*
.. code-block:: json

    {
        "version": "2.0.0",
        "tasks": [
            {
                "label": "Run GDSentry Tests",
                "type": "shell",
                "command": "gdsentry",
                "args": ["test", "run"],
                "group": "test",
                "presentation": {
                    "echo": true,
                    "reveal": "always",
                    "focus": false,
                    "panel": "shared"
                }
            }
        ]
    }

**Keyboard Shortcuts:**
- Set up F5 or Ctrl+R to run tests
- Use terminal panel for test output
- Quick open test files with Ctrl+P

**Test File Navigation:**
- Use ``gdsentry test discover`` output to find test files
- Jump between implementation and test files
- Group test files in dedicated directories

Iterative Development Workflow
------------------------------

**Test-Driven Development:**
1. **Write failing test** for new feature
2. **Implement feature** in Godot editor
3. **Run tests** to verify implementation
4. **Refactor** with confidence
5. **Repeat** for next feature

**Debugging Test Failures:**

**Console Output Analysis:**
- Look for assertion failure messages
- Check timing information for performance tests
- Review error stack traces

**Isolate Failing Tests:**
.. code-block:: bash

    # Run single failing test
    gdsentry test run --file tests/unit/player_test.gd

    # Run with detailed output
    gdsentry test run --verbose --filter "*failing_test*"

**Godot Editor Debugging:**
- Open your Godot project to inspect scenes
- Use Godot's debugger for complex test scenarios
- Check node hierarchies and property values
- Validate scene loading and resource references

**Visual Test Debugging:**
- For Node2DTest failures, open scenes in Godot editor
- Check positioning, visibility, and rendering
- Use Godot's remote debugger for visual inspection
- Compare expected vs actual visual states

**Performance Test Analysis:**
- Review FPS metrics and frame timing
- Check memory usage reports
- Identify performance bottlenecks
- Use Godot's profiler for detailed analysis

Hot-Reloading and Fast Iteration
---------------------------------

**Watch Mode (if implemented):**
.. code-block:: bash

    gdsentry test watch                 # Auto-run tests on file changes

**Manual Quick Checks:**
.. code-block:: bash

    # Fast feedback loop
    gdsentry test quick                 # < 5 seconds
    gdsentry test run --category unit   # < 30 seconds

**Selective Testing:**
.. code-block:: bash

    # Test only what you're working on
    gdsentry test run --filter "*player*"  # Player-related tests
    gdsentry test run --dir tests/unit/    # Unit tests only

CI/CD Integration in Development
---------------------------------

**Pre-commit Testing:**
.. code-block:: bash

    # Add to your git hooks
    #!/bin/bash
    gdsentry test run --fail-fast
    if [ $? -ne 0 ]; then
        echo "Tests failed - commit aborted"
        exit 1
    fi

**Pull Request Validation:**
- Run full test suite before pushing
- Use ``gdsentry test run --all-architectures`` for compatibility
- Generate reports for review

Version Control Best Practices
------------------------------

**Test File Organization:**
- Keep tests in ``tests/`` directory alongside code
- Use consistent naming: ``feature_test.gd``
- Commit tests with implementation

**Branch Testing Strategy:**
- Test on feature branches before merging
- Use different test scopes per branch type
- Run comprehensive tests on main/release branches

**Conflict Resolution:**
- Test after resolving merge conflicts
- Run full suite after rebasing
- Use ``gdsentry test run --verbose`` for debugging

Troubleshooting Editor Integration
-----------------------------------

**Tests Not Running from Editor:**
- Ensure GDSentry CLI is installed and in PATH
- Check that you're in the correct project directory
- Verify Godot project structure (``project.godot`` file)

**Slow Test Execution:**
- Use ``--category unit`` for fast feedback
- Run tests in parallel when possible
- Focus on specific test files during development

**Path Issues:**
- Always run commands from project root
- Use relative paths in test files
- Check working directory in scripts

**Godot Version Conflicts:**
- Ensure CLI uses same Godot version as your editor
- Configure ``godot_version`` in ``gdsentry.toml``
- Test compatibility with ``gdsentry build all``
