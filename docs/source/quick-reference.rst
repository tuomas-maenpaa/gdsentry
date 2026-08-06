Quick Reference
===============

This quick reference provides essential GDSentry patterns and commands for rapid development.

Test Class Inheritance
======================

.. list-table:: Test Class Inheritance
   :header-rows: 1
   :widths: 25 45 30

   * - Class
     - Purpose
     - Key Features
   * - SceneTreeTest
     - Unit testing
     - Fast, isolated
   * - Node2DTest
     - Visual/UI testing
     - Scene tree access
   * - IntegrationTest
     - Full system testing
     - End-to-end flows
   * - PerformanceTest
     - Load & stress testing
     - FPS/memory mon.

Basic Test Structure
====================

.. code-block:: gdscript

   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_feature", func(): return test_feature())

   func test_feature() -> bool:
       # Arrange
       var obj = MyClass.new()

       # Act
       var result = obj.do_something()

       # Assert
       return assert_equals(result, expected_value)

Essential Assertions
====================

Basic Assertions
----------------

.. code-block:: gdscript

   assert_true(condition)                    # Value is true
   assert_false(condition)                   # Value is false
   assert_equals(actual, expected)           # Values are equal
   assert_not_equals(actual, expected)       # Values differ

Null & Type Checks
------------------

.. code-block:: gdscript

   assert_null(value)                        # Value is null
   assert_not_null(value)                    # Value exists

Collection Assertions
---------------------

.. code-block:: gdscript

   assert_array_contains(array, element)     # Array has element
   assert_array_size(array, size)            # Array size matches
   assert_array_empty(array)                 # Array is empty

String Assertions
-----------------

.. code-block:: gdscript

   assert_string_equals(str1, str2)          # Strings match
   assert_string_contains(text, substring)   # Text contains substring
   assert_string_length(text, length)        # String length matches

Numeric Assertions
------------------

.. code-block:: gdscript

   assert_float_equals(value, expected, tolerance)
   assert_vector2_equals(vec1, vec2, tolerance)

Method Call Verification
========================

.. code-block:: gdscript

   # Basic verification
   assert_method_called(mock, "method_name")
   assert_method_called_times(mock, "method", count)
   assert_method_called_with(mock, "method", [args])

   # Fluent API
   verify(mock, "method").was_called()
   verify(mock, "method").was_called_times(2)

Mock Creation
=============

.. code-block:: gdscript

   # Basic mock
   var mock = create_mock("ServiceName")

   # Class-based mock
   var mock = create_mock_from_class("Database")

   # Partial mock (delegates to real object)
   var mock = create_partial_mock(real_obj, "MockName")

Mock Stubbing
=============

.. code-block:: gdscript

   # Return specific value
   when(mock, "get_data").then_return(test_data)

   # Call custom function
   when(mock, "process").then_call(func(): return "result")

   # Different responses by arguments
   mock.when("calculate").with_args([2, 3]).then_return(5)

Fixture Management
==================

.. code-block:: gdscript

   func before_all() -> void:
       register_fixture("db", func(): return create_test_db())

   func test_with_fixture() -> bool:
       var db = get_fixture("db")  # Auto-initialized
       return assert_not_null(db)

UI Element Finding
==================

.. code-block:: gdscript

   # Find by text content
   var button = find_button_by_text("Submit")
   var label = find_label_by_text("Welcome")

   # Find by name
   var panel = find_control_by_name("SettingsPanel")

   # Find by type
   var buttons = find_controls_by_type("Button")

UI Interaction
==============

.. code-block:: gdscript

   # Button interaction
   click_button(button)
   click_button_by_text("Save")

   # Text input
   type_text(text_field, "Hello World")

   # Keyboard navigation
   simulate_tab_navigation(2)    # Tab twice
   simulate_enter_key_activation(focused_control)

Visual Testing
==============

.. code-block:: gdscript

   extends Node2DTest

   func test_ui_layout() -> bool:
       var scene = load_test_scene("res://ui/menu.tscn")
       await wait_for_frames(5)

       var title = find_nodes_by_type(scene, "Label")[0]
       assert_visible(title)
       assert_position(title, Vector2(400, 100), 10)

       return true

Performance Testing
===================

.. code-block:: gdscript

   extends PerformanceTest

   func test_fps() -> bool:
       var game = load_scene("res://scenes/game.tscn")
       await wait_for_frames(30)

       return assert_fps_above(30, 2.0)  # 30+ FPS for 2 seconds

   func test_memory() -> bool:
       return assert_memory_usage_less_than(200.0)  # Under 200MB

   func test_benchmark() -> bool:
       return assert_benchmark_performance(
           "heavy_calculation",
           func(): return perform_calculation(),
           50.0  # Max 50ms average
       )

CLI Command Reference
======================

Test Commands
-------------

Running Tests
~~~~~~~~~~~~~

.. code-block:: bash

   # Run all tests in current directory
   gdsentry test run

   # Run specific test file
   gdsentry test run --file tests/unit/player_test.gd

   # Run tests in specific directory
   gdsentry test run --dir tests/unit/

   # Run with verbose output
   gdsentry test run --verbose

Test Discovery
~~~~~~~~~~~~~~

.. code-block:: bash

   # Show all available tests
   gdsentry test discover

   # Discover tests in specific directory
   gdsentry test discover --dir tests/integration/

Filtering & Selection
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Filter by category
   gdsentry test run --category unit

   # Filter by pattern
   gdsentry test run --filter "*player*"

   # Quick test (framework self-tests)
   gdsentry test quick

   # Simulate CI workflow locally (comprehensive testing)
   gdsentry test ci-local

Build Commands
--------------

Container Building
~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Build base container image
   gdsentry build base

   # Build Godot container image
   gdsentry build godot 4.2.2-stable

   # Build all container images
   gdsentry build all

   # Build for specific architecture
   gdsentry build godot 4.2.2-stable --arch x86_64

CI Simulation Commands
----------------------

Simulate CI workflows locally for rapid feedback before pushing to remote CI/CD:

.. code-block:: bash

   # Run full CI simulation (tests + docs)
   gdsentry ci simulate --full

   # Run only documentation workflow
   gdsentry ci simulate --docs-only

   # Run only test workflow
   gdsentry ci simulate --tests-only

   # Validate CI configuration files
   gdsentry ci validate

**Note**: CI simulation runs locally using CLI (not containers) for documentation building.
Containers are used only for Godot version isolation during testing.

Documentation Commands
----------------------

Build and validate documentation:

.. code-block:: bash

   # Build HTML documentation
   gdsentry docs build

   # Build and clean previous build
   gdsentry docs build --clean

   # Check for broken links
   gdsentry docs linkcheck

   # Clean build directory
   gdsentry docs clean

   # Run documentation validation
   gdsentry docs validate

Info Commands
-------------

Platform Information
~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Show platform and system information
   gdsentry info platform

   # Show GDSentry version
   gdsentry info version

   # Show current configuration
   gdsentry info config

   # Show development environment information
   gdsentry info env

   # Validate Podman installation
   gdsentry info podman

   # Show Podman resource usage
   gdsentry info resources

Reporting & Output
------------------

.. code-block:: bash

   # Generate JUnit XML report
   gdsentry test run --report junit --output reports/

   # Generate HTML report
   gdsentry test run --report html --output reports/

   # Multiple report formats
   gdsentry test run --report junit,html,json --output reports/

Execution Options
-----------------

.. code-block:: bash

   # Stop on first failure
   gdsentry test run --fail-fast

   # Custom timeout (seconds)
   gdsentry test run --timeout 60

   # Dry run (show what would execute)
   gdsentry test run --dry-run

Cross-Architecture Testing
--------------------------

.. code-block:: bash

   # Test on x86_64 architecture
   gdsentry test run --arch x86_64

   # Test on ARM64 architecture
   gdsentry test run --arch arm64

   # Test on all available architectures
   gdsentry test run --all-architectures

Configuration
=============

GDSentry CLI works out-of-the-box with sensible defaults. For advanced configuration, create a ``gdsentry.toml`` file in your project root:

.. code-block:: toml

   [project]
   godot_version = "4.2.2-stable"
   test_directories = ["tests/", "test/"]

   [test]
   timeout = 30.0
   fail_fast = false

   [report]
   formats = ["console", "html"]
   output_dir = "test-reports/"

   [container]
   base_image = "gdsentry-base"
   architecture = "x86_64"

Configuration File Locations
-----------------------------

GDSentry looks for configuration in this order:

1. ``gdsentry.toml`` (project root)
2. ``.gdsentry.toml`` (project root)
3. Environment variables (``GDSENTRY_*``)
4. Built-in defaults

See :doc:`configuration` for complete configuration options.

Common Issues & Solutions
=========================

CLI Not Found
-------------

- **pip install**: Ensure ``~/.local/bin`` is in your PATH
- **conda**: Activate your conda environment first
- **pipx**: Check that ``~/.local/bin`` is in PATH

Test Discovery Fails
--------------------

- Ensure test files end with ``_test.gd``
- Verify test classes extend GDSentry base classes (``SceneTreeTest``, etc.)
- Check that test directories are named ``tests/`` or ``test/``
- Run ``gdsentry test discover`` to see what tests are found

Godot Not Found
---------------

- Ensure Godot is installed and accessible via command line
- Check ``godot --version`` works in terminal
- Specify Godot path in ``gdsentry.toml`` if needed

Container/Podman Errors
-----------------------

- Install Podman or Docker
- Start Podman machine: ``podman machine start``
- Build containers first: ``gdsentry build all``

Timeout Errors
--------------

- Increase timeout: ``gdsentry test run --timeout 60``
- Use ``await`` for async operations in tests
- Break long tests into smaller focused tests

Test Failures
-------------

- Run with verbose output: ``gdsentry test run --verbose``
- Check test file syntax and imports
- Ensure Godot project structure is correct
- Verify test methods return ``bool`` values

Project Structure Template
===========================

Recommended Godot project structure with tests:

.. code-block::

   your-godot-project/
   ├── project.godot              # Godot project file
   ├── tests/                     # Test directory (auto-discovered)
   │   ├── unit/                  # SceneTreeTest classes
   │   │   ├── test_player.gd
   │   │   ├── test_inventory.gd
   │   │   └── test_combat.gd
   │   ├── visual/                # Node2DTest classes
   │   │   ├── test_main_menu.gd
   │   │   ├── test_hud.gd
   │   │   └── test_dialogue.gd
   │   ├── integration/           # IntegrationTest classes
   │   │   ├── test_level_loading.gd
   │   │   └── test_save_system.gd
   │   └── performance/           # PerformanceTest classes
   │       └── test_frame_rate.gd
   ├── scripts/                   # Your game scripts
   │   ├── player.gd
   │   ├── inventory.gd
   │   └── ui/
   ├── scenes/                    # Your game scenes
   │   ├── main_menu.tscn
   │   └── game_world.tscn
   └── gdsentry.toml              # Optional configuration

Test File Naming:

- End with ``_test.gd`` (e.g., ``player_test.gd``)
- Use descriptive names (``test_player_movement.gd``)
- Group related tests in same file

Test Method Naming:

- Start with ``test_`` (e.g., ``test_player_movement()``)
- Include expected behavior (``test_jump_mechanics()``)
- Use descriptive names (``test_collision_detection()``)

For detailed documentation, see:

- :doc:`getting-started` - Installation and basic setup
- :doc:`user-guide` - Comprehensive testing patterns
- :doc:`api/test-classes` - Complete API reference
- :doc:`troubleshooting` - Solutions to common issues
