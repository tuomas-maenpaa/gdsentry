Getting Started with GDSentry CLI
==================================

**⏱️ 5-minute quick start** - Get testing your Godot games immediately!

This guide shows Godot developers how to install GDSentry CLI and start testing their games. No complex setup required - just install the CLI and write tests in your existing Godot project.

Prerequisites
=============

- **Godot 4.x** (recommended) or **Godot 3.5+**
- **Python 3.9+** installed on your system
- A **Godot project** you want to test

Installation
============

Since GDSentry is currently in development, install from source:

.. code-block:: bash

    # Clone the repository
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry

    # Set up conda environment (recommended)
    conda env create -f environment.yml
    conda activate gdsentry

    # Install in development mode
    pip install -e .

Verify installation:

.. code-block:: bash

    gdsentry --help

You should see the GDSentry CLI help output with available commands.

Your First Test
===============

Let's create your first test. Tests live **in your Godot project** - you don't copy GDSentry into your project.

1. **Create a test directory** in your Godot project:

   .. code-block:: bash

       cd your-godot-project
       mkdir tests

2. **Create your first test file** ``tests/player_test.gd``:

   .. code-block:: gdscript

       # tests/player_test.gd
       extends SceneTreeTest

       func run_test_suite() -> void:
           run_test("test_player_health", func(): return test_player_health())
           run_test("test_player_movement", func(): return test_player_movement())

       func test_player_health() -> bool:
           var player = Player.new()  # Your game's Player class
           player.health = 100

           # Take damage
           player.take_damage(25)

           # Verify health decreased
           return assert_equals(player.health, 75)

       func test_player_movement() -> bool:
           var player = Player.new()
           player.position = Vector2(0, 0)

           # Move player
           player.move(Vector2(10, 5))

           # Verify position changed
           return assert_equals(player.position, Vector2(10, 5))

3. **Run your tests**:

   .. code-block:: bash

       # From your Godot project directory
       gdsentry test run

You should see output showing your tests running and passing!

Understanding the Results
=========================

GDSentry will show you:

- ✅ **Green checkmarks** for passing tests
- ❌ **Red X marks** for failing tests
- 📊 **Summary** with pass/fail counts
- 🕐 **Timing information** for performance insights

Example output:

.. code-block:: text

    🚀 GDSentry - Running tests...

    ✅ tests/player_test.gd::test_player_health (0.02s)
    ✅ tests/player_test.gd::test_player_movement (0.01s)

    📊 Results: 2 passed, 0 failed (0.03s total)

Next Steps
==========

Now that you have basic testing working:

1. **Learn test types**: `SceneTreeTest`, `Node2DTest`, `PerformanceTest`, etc.
2. **Explore assertions**: `assert_equals()`, `assert_true()`, `assert_visible()`, etc.
3. **Add to CI/CD**: Automate testing in your build pipeline
4. **Visual testing**: Test UI layouts and rendering
5. **Performance testing**: Monitor FPS and memory usage

See the :doc:`user-guide` for detailed tutorials and examples.
