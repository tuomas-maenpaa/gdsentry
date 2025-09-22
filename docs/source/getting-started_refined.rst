:orphan:

Getting Started
===============

This guide will get you from zero to your first working test in under 5 minutes.

.. admonition:: Quick Start Summary
   :class: tip

   1. **Copy** GDSentry to your project
   2. **Configure** autoload in Project Settings
   3. **Create** your first test file
   4. **Run** tests to verify everything works

   **Total time:** 5 minutes

🚀 5-Minute Quickstart
======================

Step 1: Install GDSentry (1 minute)
---------------------------------

Copy the GDSentry framework to your Godot project:

.. code-block:: bash

   # From your project root directory
   cp -r path/to/gdsentry/ ./

Your project structure should now look like:

.. code-block:: text

   your_project/
   ├── project.godot
   ├── gdsentry/           ← GDSentry framework files
   └── your_game_files/

Step 2: Configure Autoload (1 minute)
-------------------------------------

1. Open your Godot project
2. Go to **Project → Project Settings → AutoLoad**
3. Click **Add** and configure:

   - **Path:** ``res://gdsentry/core/test_manager.gd``
   - **Node Name:** ``GDTestManager``
   - **Enable:** ✓ (checked)

4. Click **Add** and close Project Settings

Step 3: Create Your First Test (2 minutes)
------------------------------------------

Create a new file ``res://tests/my_first_test.gd``:

.. code-block:: gdscript
   :caption: tests/my_first_test.gd

   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_basic_math", func(): return test_basic_math())
       run_test("test_gdsentry_works", func(): return test_gdsentry_works())

   func test_basic_math() -> bool:
       var result = 2 + 2
       return assert_equals(result, 4, "Math should work correctly")

   func test_gdsentry_works() -> bool:
       # Verify GDSentry is properly configured
       var test_manager = get_node("/root/GDTestManager")
       return assert_not_null(test_manager, "GDTestManager should be available")

Step 4: Run Your Tests (1 minute)
---------------------------------

Run your test using the Godot command line:

.. code-block:: bash

   # Run your specific test file
   godot --headless --script gdsentry/core/test_runner.gd --test-path tests/my_first_test.gd

**Expected output:**

.. code-block:: none

   GDSentry Test Runner
   ===================

   Running tests from: tests/my_first_test.gd

   ✓ test_basic_math (0.001s)
   ✓ test_gdsentry_works (0.002s)

   Results: 2 passed, 0 failed, 0 skipped
   Total time: 0.003s

🎉 **Congratulations!** You've successfully set up GDSentry and run your first tests.

What's Next?
============

Now that GDSentry is working, explore these next steps:

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: 📖 Learn Testing Patterns
      :link: user-guide
      :link-type: doc

      Discover comprehensive testing approaches for games

      Visual testing, mocking, fixtures, and more

   .. grid-item-card:: 🎮 Game-Specific Examples
      :link: examples
      :link-type: doc

      See complete examples for different game types

      Action games, RPGs, puzzle games, and UI testing

   .. grid-item-card:: ⚡ Quick Reference
      :link: quick-reference
      :link-type: doc

      Essential commands and patterns

      Perfect for daily development

   .. grid-item-card:: 🔧 Advanced Features
      :link: advanced/mocking
      :link-type: doc

      Mocking, fixtures, and CI/CD integration

      Professional testing workflows

Detailed Installation Guide
===========================

For more complex setups or troubleshooting, here's the detailed installation process.

Prerequisites
-------------

- **Godot Engine 3.5+ or 4.0+**
- **GDScript knowledge** (basic familiarity with Godot scripting)
- **Command line access** (for running tests)

Installation Methods
--------------------

Method 1: Direct Copy (Recommended)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Download or clone the GDSentry repository
2. Copy the ``gdsentry/`` folder to your project root
3. Verify the structure matches the quickstart guide above

Method 2: Git Submodule (For Version Control)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # From your project root
   git submodule add https://github.com/username/gdsentry.git gdsentry
   git submodule update --init --recursive

Method 3: Godot Asset Library (Future)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

GDSentry will be available through the Godot Asset Library in a future release.

Autoload Configuration Details
------------------------------

The autoload step is **critical** for GDSentry to function properly. The autoload:

- **Initializes** the test framework
- **Manages** test discovery and execution
- **Provides** access to testing utilities
- **Handles** test result reporting

Without the autoload, you'll encounter errors like:

.. code-block:: text

   ERROR: Attempt to call function 'create_test_results' in base 'null instance'

Project Structure Setup
-----------------------

Organize your tests for maintainability:

.. code-block:: text

   your_project/
   ├── gdsentry/                    # GDSentry framework (don't modify)
   ├── tests/
   │   ├── unit/                  # Fast unit tests
   │   │   ├── player/
   │   │   │   ├── player_movement_test.gd
   │   │   │   └── player_combat_test.gd
   │   │   └── weapons/
   │   │       └── weapon_damage_test.gd
   │   ├── integration/           # Multi-system tests
   │   │   ├── save_load_test.gd
   │   │   └── level_progression_test.gd
   │   ├── ui/                    # Visual/UI tests
   │   │   ├── main_menu_test.gd
   │   │   └── hud_test.gd
   │   └── performance/           # Performance tests
   │       ├── rendering_test.gd
   │       └── ai_performance_test.gd
   └── scripts/                   # Your game code
       ├── player/
       └── weapons/

Verification Tests
==================

Create these verification tests to ensure your setup is working correctly:

Basic Verification Test
-----------------------

.. code-block:: gdscript
   :caption: tests/verification/setup_test.gd

   extends SceneTreeTest

   func _init():
       test_description = "Verifies GDSentry setup is working correctly"
       test_category = "verification"
       test_tags = ["setup", "critical"]

   func run_test_suite() -> void:
       run_test("test_autoload_available", func(): return test_autoload_available())
       run_test("test_basic_assertions", func(): return test_basic_assertions())
       run_test("test_scene_tree_access", func(): return test_scene_tree_access())

   func test_autoload_available() -> bool:
       var test_manager = get_node("/root/GDTestManager")
       return assert_not_null(test_manager, "GDTestManager autoload should be available")

   func test_basic_assertions() -> bool:
       var success = true
       success = success and assert_true(true, "assert_true should work")
       success = success and assert_false(false, "assert_false should work")
       success = success and assert_equals(5, 5, "assert_equals should work")
       success = success and assert_not_equals(1, 2, "assert_not_equals should work")
       return success

   func test_scene_tree_access() -> bool:
       var scene_tree = get_tree()
       return assert_not_null(scene_tree, "Should have access to scene tree")

Advanced Verification Test
--------------------------

.. code-block:: gdscript
   :caption: tests/verification/advanced_test.gd

   extends Node2DTest

   func _init():
       test_description = "Verifies advanced GDSentry features"
       test_category = "verification"

   func run_test_suite() -> void:
       run_test("test_scene_loading", func(): return test_scene_loading())
       run_test("test_mock_creation", func(): return test_mock_creation())

   func test_scene_loading() -> bool:
       # Test that we can load and instantiate scenes
       var test_scene = preload("res://gdsentry/test_types/visual_test.gd")
       return assert_not_null(test_scene, "Should be able to load GDSentry scenes")

   func test_mock_creation() -> bool:
       # Test basic mocking functionality
       var mock = create_mock("TestObject")
       return assert_not_null(mock, "Should be able to create mock objects")

Running Tests
=============

Command Line Interface
----------------------

The primary way to run tests is through the command line:

.. code-block:: bash

   # Run all tests
   godot --headless --script gdsentry/core/test_runner.gd --discover

   # Run specific test file
   godot --headless --script gdsentry/core/test_runner.gd --test-path tests/my_test.gd

   # Run tests in directory
   godot --headless --script gdsentry/core/test_runner.gd --test-dir tests/unit/

   # Run with verbose output
   godot --headless --script gdsentry/core/test_runner.gd --discover --verbose

Common Command Options
----------------------

.. list-table:: Common Command Options
   :header-rows: 1
   :widths: 20 50 30

   * - Option
     - Description
     - Example
   * - ``--discover``
     - Find and run all tests
     - ``--discover``
   * - ``--test-path``
     - Run specific test file
     - ``--test-path my_test.gd``
   * - ``--test-dir``
     - Run tests in directory
     - ``--test-dir tests/unit/``
   * - ``--verbose``
     - Detailed output
     - ``--verbose``
   * - ``--filter``
     - Filter by category/tags
     - ``--filter category:unit``
   * - ``--parallel``
     - Run tests in parallel
     - ``--parallel``
   * - ``--report``
     - Generate test reports
     - ``--report html,junit``

For the complete command reference, see :doc:`api/test-runner`.

Troubleshooting Installation
============================

Common Issues and Solutions
---------------------------

**Issue: "GDTestManager not found"**

**Solution:**
1. Verify autoload path is exactly ``res://gdsentry/core/test_manager.gd``
2. Ensure Node Name is ``GDTestManager`` (case-sensitive)
3. Confirm autoload is enabled (checkbox checked)
4. Restart Godot completely

**Issue: "Class 'SceneTreeTest' not found"**

**Solution:**
1. Verify ``gdsentry/`` directory is in project root
2. Check that all GDSentry ``.gd`` files are present
3. Ensure project doesn't exclude gdsentry directory
4. Restart Godot to refresh script cache

**Issue: "No tests found"**

**Solution:**
1. Test files must end with ``_test.gd``
2. Test classes must extend a GDSentry base class
3. Implement ``run_test_suite()`` method
4. Use ``res://`` paths when referencing files

**Issue: Tests run but fail unexpectedly**

**Solution:**
1. Run verification tests first
2. Check Godot console for error messages
3. Verify test file syntax is correct
4. Ensure test methods return boolean values

For comprehensive troubleshooting, see :doc:`troubleshooting`.

Editor Integration (Optional)
=============================

While GDSentry primarily uses command-line execution, you can integrate it with your editor workflow.

VS Code Integration
-------------------

Create ``.vscode/tasks.json`` for easy test execution:

.. code-block:: json

   {
       "version": "2.0.0",
       "tasks": [
           {
               "label": "Run All Tests",
               "type": "shell",
               "command": "godot",
               "args": ["--headless", "--script", "gdsentry/core/test_runner.gd", "--discover"],
               "group": "test",
               "presentation": {
                   "echo": true,
                   "reveal": "always",
                   "focus": false,
                   "panel": "shared"
               }
           },
           {
               "label": "Run Current Test File",
               "type": "shell",
               "command": "godot",
               "args": ["--headless", "--script", "gdsentry/core/test_runner.gd", "--test-path", "${file}"],
               "group": "test"
           }
       ]
   }

JetBrains IDE Integration
-------------------------

Configure external tools for test execution:

1. **Settings → Tools → External Tools**
2. **Add new tool:**
   - **Name:** Run GDSentry Tests
   - **Program:** godot
   - **Arguments:** ``--headless --script gdsentry/core/test_runner.gd --discover``
   - **Working Directory:** ``$ProjectFileDir$``

Next Steps
==========

Now that you have GDSentry installed and working:

1. **Read the User Guide** (:doc:`user-guide`) for comprehensive testing patterns
2. **Explore Examples** (:doc:`examples`) to see real-world testing scenarios
3. **Learn Best Practices** (:doc:`best-practices`) for maintainable test suites
4. **Set up CI/CD** (:doc:`tutorials/ci-integration`) for automated testing

**Happy testing!** 🎮
