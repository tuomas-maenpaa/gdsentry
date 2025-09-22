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

Command Line Reference
======================

Basic Commands
--------------

.. code-block:: bash

   # Run all tests
   godot --script gdsentry/core/test_runner.gd --discover

   # Run specific test file
   godot --script gdsentry/core/test_runner.gd --test-path tests/unit/player_test.gd

   # Run tests in directory
   godot --script gdsentry/core/test_runner.gd --test-dir tests/unit/

   # Run with verbose output
   godot --script gdsentry/core/test_runner.gd --verbose --discover

Filtering Tests
---------------

.. code-block:: bash

   # Filter by category
   --filter category:unit

   # Filter by tags
   --filter tags:critical,smoke

   # Filter by pattern
   --pattern "*player*"

Reporting Options
-----------------

.. code-block:: bash

   # Generate JUnit XML
   --report junit --report-path reports/

   # Generate HTML report
   --report html --report-path reports/

   # Multiple report formats
   --report junit,html,json --report-path reports/

Execution Control
-----------------

.. code-block:: bash

   # Parallel execution
   --parallel

   # Stop on first failure
   --fail-fast

   # Custom timeout
   --timeout 60

   # Dry run (show what would execute)
   --dry-run

Configuration Profiles
======================

.. code-block:: bash

   # CI optimized
   --profile ci

   # Development focused
   --profile development

   # Performance testing
   --profile performance

   # Visual regression
   --profile visual

   # Quick smoke tests
   --profile smoke

Configuration Setup
===================

Autoload Configuration
----------------------

Project → Project Settings → AutoLoad:

- **Path:** ``res://gdsentry/core/test_manager.gd``
- **Node Name:** ``GDTestManager``
- **Enable** ✓

Basic Configuration File
------------------------

Create ``res://gdsentry_config.tres``:

.. code-block:: gdscript

   [resource]
   script = ExtResource("1")

   test_directories = Array[String](["res://tests/"])
   execution_policies = {
       "parallel_execution": true,
       "fail_fast": false
   }
   timeout_settings = {
       "test_timeout": 30.0
   }
   report_settings = {
       "formats": Array[String](["html", "json"]),
       "output_directory": "res://test_reports/"
   }

Common Issues & Solutions
=========================

Test Discovery Fails
--------------------

- Ensure test files end with ``_test.gd``
- Verify test classes extend GDSentry base classes
- Check file paths use ``res://`` protocol
- Restart Godot after adding new test files

Null Reference Errors
---------------------

- Use ``assert_not_null()`` to check object creation
- Verify scene loading with ``ResourceLoader.exists()``
- Check autoload availability before use
- Initialize variables before use in tests

Timeout Errors
--------------

- Increase individual test timeouts: ``test_timeout = 60.0``
- Use ``await`` for async operations
- Break long tests into smaller focused tests
- Profile slow operations to identify bottlenecks

Visual Test Failures
--------------------

- Wait for scene initialization: ``await wait_for_frames(5)``
- Use appropriate tolerance for position checks
- Verify viewport size and scaling
- Check for animation completion

Performance Test Issues
-----------------------

- Warm up system before measurement: ``await wait_for_frames(60)``
- Use consistent test environment
- Disable VSync for accurate FPS measurement
- Run multiple iterations for statistical validity

File Structure Template
=======================

Recommended Project Structure:

.. code-block::

   your_project/
   ├── gdsentry/                    # GDSentry framework
   ├── tests/
   │   ├── unit/                  # SceneTreeTest classes
   │   │   ├── core/              # Core logic tests
   │   │   └── systems/           # System tests
   │   ├── visual/                # Node2DTest classes
   │   │   ├── ui/                # UI component tests
   │   │   └── scenes/            # Scene tests
   │   └── integration/           # IntegrationTest classes
   │       └── gameplay/          # End-to-end tests
   ├── scenes/
   │   ├── ui/
   │   └── game/
   └── scripts/
       ├── core/
       └── systems/

Test File Naming:

- ``player_controller_test.gd``
- ``ui_menu_test.gd``
- ``game_physics_test.gd``
- ``save_system_test.gd``

Method Naming:

- ``test_player_movement()``
- ``test_jump_mechanics()``
- ``test_collision_detection()``
- ``test_save_load_cycle()``

For detailed documentation, see:

- :doc:`getting-started` - Installation and basic setup
- :doc:`user-guide` - Comprehensive testing patterns
- :doc:`api/test-classes` - Complete API reference
- :doc:`troubleshooting` - Solutions to common issues
