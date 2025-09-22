Test Classes
============

GDSentry provides a hierarchy of test base classes designed for different testing scenarios. Each class extends the previous one, adding specialized functionality for specific types of game testing.

Test Class Inheritance Hierarchy
================================

.. code-block:: text

    GDTest (base class)
    ├── SceneTreeTest (unit testing)
    │   └── NodeTest (node hierarchy testing)
    │       └── Node2DTest (visual/2D testing)
    └── IntegrationTest (full system testing)
        └── PerformanceTest (load/stress testing)
            └── VisualTest (advanced visual testing)

GDTest - Base Test Class
========================

Overview
--------

``GDTest`` is the foundation class for all GDSentry tests. It provides core testing infrastructure, lifecycle management, assertion methods, and result tracking. All other test classes inherit from ``GDTest``.

**Extends:** ``Node``

Key Features
------------

- Comprehensive assertion library (20+ built-in assertions)
- Test lifecycle management (setup/teardown)
- Metadata support (tags, priority, categories)
- Result tracking and reporting
- Timeout handling
- Error logging and diagnostics

Metadata Properties
-------------------

.. code-block:: none

   @export var test_description: String = ""          # Human-readable test description
   @export var test_tags: Array[String] = []           # Categorization tags
   @export var test_priority: String = "normal"        # low, normal, high, critical
   @export var test_author: String = ""                # Test author
   @export var test_timeout: float = 30.0              # Timeout in seconds
   @export var test_category: String = "general"       # Test category

Lifecycle Methods
-----------------

``_ready()`` → ``void``
^^^^^^^^^^^^^^^^^^^^^^^
Called when the test node is ready. Initializes test environment and validates dependencies.

``run_test_suite()`` → ``void``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Abstract method that must be implemented by test classes. Defines which test methods to run.

**Example:**
.. code-block:: gdscript

   func run_test_suite() -> void:
       run_test("test_basic_functionality", func(): return test_basic_functionality())
       run_test("test_edge_cases", func(): return test_edge_cases())

``run_test(test_method_name: String, test_callable: Callable)`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Executes a single test method and records the result.

**Parameters:**
- test_method_name: Name of the test method
- test_callable: Callable that executes the test

**Returns:** ``true`` if test passed, ``false`` if failed

Core Assertion Methods
----------------------

``assert_true(condition: bool, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a condition is true.

``assert_false(condition: bool, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a condition is false.

``assert_equals(actual: Variant, expected: Variant, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that two values are equal.

``assert_null(value: Variant, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a value is null.

``assert_not_null(value: Variant, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a value is not null.

SceneTreeTest - Unit Testing
============================

Overview
--------

``SceneTreeTest`` extends ``GDTest`` and is optimized for fast, headless unit testing. It extends Godot's ``SceneTree`` directly, making it ideal for testing pure logic, algorithms, and data structures without visual components.

**Extends:** ``SceneTree`` (via ``GDTest``)

When to Use
-----------

- Testing mathematical calculations and algorithms
- Validating data processing and business logic
- Testing utility functions and helpers
- Performance benchmarking
- Pure logic components without visual dependencies

Key Features
------------

- Fastest execution speed of all test types
- No visual rendering overhead
- Direct SceneTree access for complex setups
- Built-in performance timing utilities
- Fallback logging when GDTestManager unavailable

Specialized Methods
-------------------

``create_mock_object(class_name: String, methods: Dictionary = {})`` → ``Object``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Creates a mock object for dependency injection testing.

``measure_execution_time(callable: Callable)`` → ``float``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Measures execution time of a code block in milliseconds.

**Example:**
.. code-block:: gdscript

   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_fibonacci_calculation", func(): return test_fibonacci_calculation())
       run_test("test_data_processing", func(): return test_data_processing())

   func test_fibonacci_calculation() -> bool:
       var calculator = MathUtils.new()
       var result = calculator.fibonacci(10)
       return assert_equals(result, 55)

   func test_data_processing() -> bool:
       var processor = DataProcessor.new()
       var input_data = generate_test_data(1000)

       var start_time = Time.get_ticks_usec()
       var result = processor.process(input_data)
       var duration_ms = (Time.get_ticks_usec() - start_time) / 1000.0

       return assert_not_null(result) and assert_greater_than(duration_ms, 0)

NodeTest - Node Hierarchy Testing
=================================

Overview
--------

``NodeTest`` extends ``SceneTreeTest`` and adds functionality for testing Godot node hierarchies, signals, and inter-node communication. It provides utilities for creating and managing node trees in tests.

**Extends:** ``SceneTreeTest``

When to Use
-----------

- Testing node-based game objects
- Validating signal connections and emissions
- Testing node lifecycle (ready, exit_tree)
- Component interaction testing
- Scene composition validation

Key Features
------------

- Node creation and hierarchy management
- Signal testing utilities
- Automatic node cleanup
- Scene loading and instantiation
- Node finding and traversal helpers

Node Management Methods
-----------------------

``create_test_node(node_type: GDScript, parent: Node = null)`` → ``Node``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Creates a test node of the specified type.

``find_node_by_type(root: Node, node_type: String)`` → ``Node``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Finds the first node of the specified type in the hierarchy.

``find_nodes_by_type(root: Node, node_type: String)`` → ``Array[Node]``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Finds all nodes of the specified type in the hierarchy.

Signal Testing Methods
----------------------

``connect_test_signal(source: Object, signal_name: String, target: Object, method: String)`` → ``void``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Connects a signal for testing purposes with automatic cleanup.

``wait_for_signal(source: Object, signal_name: String, timeout: float = 5.0)`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Waits for a signal to be emitted within the timeout period.

Node2DTest - Visual Testing
===========================

Overview
--------

``Node2DTest`` extends ``NodeTest`` and provides specialized functionality for testing 2D visual components, UI elements, and canvas-based game features. It runs in Godot's scene environment, allowing testing of actual visual behavior.

**Extends:** ``NodeTest``

When to Use
-----------

- Testing UI layouts and positioning
- Validating button interactions and event handling
- Testing sprite rendering and animations
- Checking visual state validation
- Layout constraints and responsive design
- Canvas-based visual effects

Key Features
------------

- Visual component testing in actual scene environment
- UI interaction simulation
- Sprite and animation validation
- Layout and positioning assertions
- Visual regression testing capabilities

Visual Testing Methods
----------------------

``load_test_scene(path: String)`` → ``Node``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Loads a test scene from the specified path.

``simulate_mouse_click(node: CanvasItem, position: Vector2 = Vector2.ZERO)`` → ``void``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Simulates a mouse click on a canvas item.

``simulate_key_press(key: Key, pressed: bool = true)`` → ``void``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Simulates keyboard input.

``wait_for_frames(count: int)`` → ``void``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Waits for the specified number of frames to render.

Visual Assertion Methods
------------------------

``assert_visible(node: CanvasItem, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a canvas item is visible.

``assert_not_visible(node: CanvasItem, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a canvas item is not visible.

``assert_position(node: Node2D, expected_pos: Vector2, tolerance: float = 1.0, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a Node2D is at the expected position within tolerance.

``assert_sprite_frame(sprite: Sprite2D, expected_frame: int, message: String = "")`` → ``bool``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Asserts that a sprite is displaying the expected frame.

Usage Examples
==============

Basic Unit Test
---------------

.. code-block:: gdscript

   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_calculator", func(): return test_calculator())

   func test_calculator() -> bool:
       var calc = Calculator.new()
       var result = calc.add(2, 3)
       return assert_equals(result, 5)

UI Interaction Test
-------------------

.. code-block:: gdscript

   extends Node2DTest

   func run_test_suite() -> void:
       run_test("test_button_click", func(): return test_button_click())

   func test_button_click() -> bool:
       var scene = load_test_scene("res://ui/main_menu.tscn")
       var button = find_nodes_by_type(scene, "Button")[0]

       # Verify initial state
       assert_visible(button)

       # Simulate interaction
       simulate_mouse_click(button)
       wait_for_frames(5)

       # Verify result
       return assert_not_visible(button)  # Button might hide after click

Performance Test
----------------

.. code-block:: gdscript

   extends PerformanceTest

   func run_test_suite() -> void:
       run_test("test_frame_rate", func(): return await test_frame_rate())

   func test_frame_rate() -> bool:
       # Run performance-critical code
       var result = run_expensive_calculation()

       # Verify performance requirements
       return assert_fps_above(30, 2.0) and assert_not_null(result)

Integration Test
----------------

.. code-block:: gdscript

   extends IntegrationTest

   func run_test_suite() -> void:
       run_test("test_complete_gameplay_flow", func(): return await test_complete_gameplay_flow())

   func test_complete_gameplay_flow() -> bool:
       # Load full game scene
       var game_scene = load_scene("res://scenes/game.tscn")

       # Simulate player actions
       simulate_player_input("move_right")
       await wait_for_seconds(1.0)

       simulate_player_input("jump")
       await wait_for_seconds(2.0)

       # Verify game state
       var player = find_node_by_type(game_scene, "Player")
       return assert_greater_than(player.score, 0)

.. seealso::
   :doc:`../api/assertions`
      Complete reference for assertion methods available in all test classes.

   :doc:`../advanced/mocking`
      Learn how to use mock objects for dependency injection in tests.

   :doc:`../advanced/fixtures`
      Manage test data and resources with the fixture system.

   :doc:`../user-guide`
      Best practices for choosing the right test class for your needs.
