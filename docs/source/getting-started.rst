Getting Started
===============

Installation
============

Copy GDSentry to your Godot project:

.. code-block:: bash

    # Copy GDSentry to your Godot project
    cp -r gdsentry/ your-project/

The folder name ``gdsentry/`` is the documented default. Alternate install folders such as ``.gdsentry/`` or ``addons/gdsentry/`` also work: the framework auto-detects its root (or you can set ``framework_root`` in ``gdsentry_config.tres``). See :doc:`configuration` for details. When using a non-default folder, point Godot ``--script`` / autoload paths at that folder (for example ``.gdsentry/core/test_runner.gd``).

Supported run path
------------------

Daily execution is **Godot + the self-test harness** (hybrid B+C1). There is no Python CLI front door on mainline.

**Agent / developer happy path (framework self-check):**

.. code-block:: bash

    cd path/to/gdsentry   # or your-project/.gdsentry
    ./gdsentry-self-test/gdsentry-self-test.sh --category core --pattern "*framework_paths*" --verbose

**Run project tests via Godot:**

.. code-block:: bash

    # From the Godot project root (adjust folder name if nested as .gdsentry/)
    godot --script gdsentry/core/test_runner.gd --test-dir gdsentry/examples/
    godot --script gdsentry/core/test_runner.gd --discover --verbose

**Full self-test suite:**

.. code-block:: bash

    ./gdsentry/gdsentry-self-test/gdsentry-self-test.sh

Product shape (skills + Godot/harness; WIP Python CLI archived) is documented in ``docs/assessment/PRODUCT-SHAPE-hybrid-B-C1.md``. Quill agentic work uses the Cursor project skill ``gdsentry-tdd``.

Configure GDSentry Autoload
-------------------------

Set up the GDSentry autoload to enable test discovery and execution:

1. Open your Godot project
2. Go to **Project → Project Settings**
3. Click the **AutoLoad** tab
4. Click **Add** and configure:
   - **Path:** ``res://gdsentry/core/test_manager.gd`` (or ``res://.gdsentry/core/test_manager.gd``)
   - **Node Name:** ``GDTestManager``
5. Check the **Enable** box to activate the autoload

Verify Installation
-------------------

Create a simple test to confirm GDSentry is working:

.. code-block:: gdscript

    # res://tests/verification_test.gd
    extends SceneTreeTest

    func run_test_suite() -> void:
        run_test("test_gdsentry_installation", func(): return test_gdsentry_installation())

    func test_gdsentry_installation() -> bool:
        # Verify GDTestManager autoload is available
        var test_manager = get_node("/root/GDTestManager")
        return assert_not_null(test_manager, "GDTestManager autoload should be available")

Run this test to confirm your setup is working correctly.

Troubleshooting
---------------

**GDTestManager autoload not found:**
- Ensure the autoload path is exactly ``res://gdsentry/core/test_manager.gd``
- Verify the Node Name is ``GDTestManager`` (case-sensitive)
- Confirm the autoload is enabled in Project Settings

**Tests not discovered:**
- Check that test files end with ``_test.gd``
- Ensure test classes extend appropriate base classes (SceneTreeTest, Node2DTest, etc.)
- Verify the ``run_test_suite()`` function is implemented

**Godot errors on startup:**
- Make sure you've copied the entire ``gdsentry/`` directory
- Check that all GDSentry script files are present in ``res://gdsentry/``

Test Organization
=================

Recommended project structure:

.. code-block:: text

    your_project/
    ├── gdsentry/           # GDSentry framework
    ├── tests/
    │   ├── unit/         # SceneTreeTest classes
    │   ├── visual/       # Node2DTest classes
    │   ├── integration/  # Integration tests
    │   └── performance/  # Performance tests
    └── scripts/          # Your game scripts

Basic Testing Patterns
======================

GDSentry provides familiar testing patterns adapted for Godot's unique architecture. The framework supports multiple testing approaches, each suited to different aspects of game validation.

Traditional Unit Testing
------------------------

Traditional unit testing validates core game logic and calculations. Developers create test instances of game objects, set up specific scenarios, and verify that calculations and state changes occur as expected.

.. code-block:: gdscript

    # Basic unit test
    extends SceneTreeTest

    func run_test_suite() -> void:
        run_test("test_calculator_addition", func(): return test_calculator_addition())

    func test_calculator_addition() -> bool:
        var calc = Calculator.new()
        var result = calc.add(2, 3)
        return assert_equals(result, 5)

Visual Testing
--------------

Visual testing ensures that what players see matches design intentions. GDSentry enables verification of UI element positioning, visibility states, and layout consistency across different screen configurations.

.. code-block:: gdscript

    # Visual test
    extends Node2DTest

    func run_test_suite() -> void:
        run_test("test_ui_layout", func(): return test_ui_layout())

    func test_ui_layout() -> bool:
        var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
        var button = find_nodes_by_type(menu, "Button")[0]

        return assert_visible(button) and assert_position(button, Vector2(100, 100), 5.0)

Interactive Testing
-------------------

Event simulation enables testing of user interactions and system responses. Developers can simulate mouse clicks, keyboard input, and other user actions to validate that the game responds appropriately.

.. code-block:: gdscript

    # Interactive test
    extends Node2DTest

    func run_test_suite() -> void:
        run_test("test_button_interaction", func(): return test_button_interaction())

Performance and Load Testing
----------------------------

GDSentry provides comprehensive performance testing capabilities including stress simulation for load testing scenarios.

.. code-block:: gdscript

    # Performance test with load testing
    extends PerformanceTest

    func run_test_suite() -> void:
        run_test("test_game_performance_under_load", func(): return await test_game_performance_under_load())

    func test_game_performance_under_load() -> bool:
        var success = true

        # Performance assertions would go here
        # Example: assert_fps_above(30, 1.0)
        # Example: assert_memory_usage_less_than(200.0)

        return success

.. seealso::
   :doc:`configuration`
      Learn how to customize GDSentry behavior with configuration files and profiles.

   :doc:`user-guide`
      Comprehensive guide to testing patterns and best practices.

   :doc:`examples`
      Runnable examples demonstrating GDSentry usage patterns.

   :doc:`troubleshooting`
      Solutions to common setup and configuration issues.
