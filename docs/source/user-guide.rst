User Guide
==========

This section provides comprehensive guidance for using GDSentry effectively in your Godot projects.


Test Organization Patterns
==========================

Effective test organization is crucial for maintaining a robust and scalable test suite. GDSentry provides flexible patterns for structuring your tests that align with Godot's project conventions while supporting different testing approaches.

Directory Structure
-------------------

GDSentry follows a hierarchical directory structure that separates tests by type and purpose:

.. code-block:: text

    your_project/
    ├── gdsentry/                    # GDSentry framework
    ├── tests/
    │   ├── unit/                  # SceneTreeTest classes - fast unit tests
    │   │   ├── core/              # Core game logic tests
    │   │   ├── systems/           # Game systems tests
    │   │   └── utils/             # Utility function tests
    │   ├── visual/                # Node2DTest classes - UI/visual tests
    │   │   ├── ui/                # User interface tests
    │   │   ├── sprites/           # Sprite and animation tests
    │   │   └── layouts/           # Layout and positioning tests
    │   ├── integration/           # IntegrationTest classes
    │   │   ├── gameplay/          # Full gameplay flow tests
    │   │   ├── scenes/            # Scene transition tests
    │   │   └── systems/           # Multi-system integration tests
    │   ├── performance/           # PerformanceTest classes
    │   │   ├── benchmarks/        # Performance benchmarks
    │   │   └── stress/            # Load testing scenarios
    │   └── physics/               # PhysicsTest classes
    │       ├── collisions/        # Collision detection tests
    │       ├── forces/            # Physics force tests
    │       └── constraints/       # Physics constraint tests
    └── scripts/
        ├── core/                  # Core game scripts
        ├── systems/               # Game systems
        └── ui/                    # UI components

Naming Conventions
------------------

Consistent naming helps maintain clarity and enables automatic test discovery:

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

Integration with Godot Development Workflow
===========================================

GDSentry integrates seamlessly with Godot's development environment, enhancing your workflow with automated testing capabilities while maintaining compatibility with Godot's tools and practices.

IDE Integration and Setup
-------------------------

**Godot Editor Integration:**
- Tests run within the Godot environment, ensuring compatibility
- Access to Godot's debugging tools and inspector
- Visual debugging of scene-based tests
- Integration with Godot's project management

**External Editor Support:**
- Compatible with VS Code, Sublime Text, and other editors
- Command-line test execution for CI/CD pipelines
- Integration with version control systems
- Support for automated testing workflows

**Test Runner Integration:**
- Built-in test discovery and execution
- Configurable test filtering and selection
- Parallel test execution support
- Comprehensive reporting and output formats

Debugging Test Failures
-----------------------

**Visual Debugging:**
- Scene tree inspection for Node2DTest failures
- Visual verification of UI layout issues
- Animation and sprite rendering validation
- Physics simulation debugging

**Logging and Diagnostics:**
- Detailed failure messages with context
- Stack traces for exception locations
- Performance metrics and timing information
- Memory usage and leak detection

**Breakpoint Debugging:**
- Set breakpoints in test methods
- Debug test setup and teardown
- Inspect test state and variables
- Step through complex test scenarios

**Test Output Analysis:**
- Console output for test progress
- JUnit XML reports for CI integration
- HTML reports for detailed analysis
- JSON output for automated processing

Continuous Integration Setup
----------------------------

**Automated Test Execution:**
- Command-line test runner for headless execution
- Configurable test selection and filtering
- Parallel test execution for faster builds
- Integration with popular CI platforms

**Report Generation:**
- Multiple output formats (console, JUnit, HTML, JSON)
- Test result archiving and history
- Performance trend analysis
- Coverage reporting integration

**Quality Gates:**
- Configurable failure thresholds
- Performance regression detection
- Code quality metric validation
- Automated deployment gates

Version Control Integration
---------------------------

**Test Organization in Git:**
- Tests stored alongside source code
- Branch-specific test configurations
- Test result tracking and history
- Merge request quality validation

**Collaborative Development:**
- Shared test standards and conventions
- Automated test execution on commits
- Test result notifications and alerts
- Team-wide testing best practices

Common Testing Scenarios
========================

GDSentry provides practical solutions for testing typical game development scenarios. These examples demonstrate how to apply GDSentry's testing patterns to real-world game features.

Player Movement Testing
-----------------------

Testing character movement mechanics requires validating position updates, collision detection, and physics interactions:

.. code-block:: gdscript

    extends Node2DTest
    class_name PlayerMovementTest

    func run_test_suite() -> void:
        run_test("test_player_walks_right", func(): return test_player_walks_right())
        run_test("test_player_jumps", func(): return test_player_jumps())
        run_test("test_player_collision", func(): return test_player_collision())

    func test_player_walks_right() -> bool:
        var player = create_test_player()
        var initial_pos = player.position

        # Simulate right movement input
        simulate_input("move_right", true)
        await wait_for_frames(10)

        return assert_greater(player.position.x, initial_pos.x, "Player should move right")

    func test_player_jumps() -> bool:
        var player = create_test_player()
        player.position = Vector2(100, 400)  # On ground

        # Simulate jump input
        simulate_input("jump", true)
        await wait_for_frames(5)

        return assert_less(player.position.y, 400, "Player should move upward when jumping")

    func test_player_collision() -> bool:
        var player = create_test_player()
        var wall = create_test_wall(Vector2(200, 300))

        player.position = Vector2(180, 300)
        simulate_input("move_right", true)
        await wait_for_frames(15)

        return assert_less_equal(player.position.x, 200, "Player should not pass through wall")

UI Interaction Testing
----------------------

Testing user interface components involves validating button states, input handling, and visual feedback:

.. code-block:: gdscript

    extends Node2DTest
    class_name UITest

    func run_test_suite() -> void:
        run_test("test_button_click_changes_scene", func(): return test_button_click_changes_scene())
        run_test("test_menu_navigation", func(): return test_menu_navigation())

    func test_button_click_changes_scene() -> bool:
        var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
        var play_button = find_nodes_by_type(menu, "Button")[0]

        # Verify initial state
        assert_visible(play_button)
        assert_equals(play_button.text, "Play Game")

        # Simulate button click
        simulate_mouse_click(play_button)
        await wait_for_frames(5)

        # Verify scene transition occurred
        var current_scene = get_tree().current_scene
        return assert_not_null(current_scene, "Scene should have changed after button click")

    func test_menu_navigation() -> bool:
        var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
        var settings_button = find_nodes_by_type(menu, "Button")[1]

        # Navigate to settings
        simulate_mouse_click(settings_button)
        await wait_for_frames(5)

        # Verify settings panel is visible
        var settings_panel = find_node_by_name(menu, "SettingsPanel")
        return assert_visible(settings_panel, "Settings panel should be visible after navigation")

Game State Management Testing
-----------------------------

Testing game state transitions and persistence requires validating state changes and data integrity:

.. code-block:: gdscript

    extends SceneTreeTest
    class_name GameStateTest

    func run_test_suite() -> void:
        run_test("test_game_state_transitions", func(): return test_game_state_transitions())
        run_test("test_score_persistence", func(): return test_score_persistence())

    func test_game_state_transitions() -> bool:
        var game_state = GameState.new()

        # Test initial state
        assert_equals(game_state.current_state, GameState.State.MENU)

        # Test transition to gameplay
        game_state.start_game()
        assert_equals(game_state.current_state, GameState.State.PLAYING)

        # Test pause functionality
        game_state.pause_game()
        assert_equals(game_state.current_state, GameState.State.PAUSED)

        # Test resume
        game_state.resume_game()
        return assert_equals(game_state.current_state, GameState.State.PLAYING)

    func test_score_persistence() -> bool:
        var game_state = GameState.new()

        # Set test score
        game_state.score = 1500
        game_state.save_game()

        # Create new instance and load
        var new_game_state = GameState.new()
        new_game_state.load_game()

        return assert_equals(new_game_state.score, 1500, "Score should persist across game sessions")

Inventory System Testing
------------------------

Testing inventory mechanics involves validating item management, capacity limits, and item interactions:

.. code-block:: gdscript

    extends SceneTreeTest
    class_name InventoryTest

    func run_test_suite() -> void:
        run_test("test_add_item_to_inventory", func(): return test_add_item_to_inventory())
        run_test("test_inventory_capacity", func(): return test_inventory_capacity())
        run_test("test_remove_item", func(): return test_remove_item())

    func test_add_item_to_inventory() -> bool:
        var inventory = Inventory.new()
        var sword = create_test_item("sword", "weapon")

        var success = inventory.add_item(sword)
        assert_true(success, "Should successfully add item to inventory")

        return assert_equals(inventory.get_item_count(), 1, "Inventory should contain one item")

    func test_inventory_capacity() -> bool:
        var inventory = Inventory.new()
        inventory.max_capacity = 3

        # Fill inventory to capacity
        for i in range(3):
            var item = create_test_item("item_" + str(i), "misc")
            inventory.add_item(item)

        # Try to add one more item
        var extra_item = create_test_item("extra", "misc")
        var success = inventory.add_item(extra_item)

        return assert_false(success, "Should not be able to add items beyond capacity")

    func test_remove_item() -> bool:
        var inventory = Inventory.new()
        var potion = create_test_item("health_potion", "consumable")

        inventory.add_item(potion)
        assert_equals(inventory.get_item_count(), 1)

        var removed_item = inventory.remove_item(potion)
        assert_not_null(removed_item, "Should return the removed item")

        return assert_equals(inventory.get_item_count(), 0, "Inventory should be empty after removal")

Performance Benchmarking
------------------------

Testing performance-critical code ensures your game maintains acceptable frame rates under various conditions:

.. code-block:: gdscript

    extends PerformanceTest
    class_name PerformanceBenchmarkTest

    func run_test_suite() -> void:
        run_test("test_pathfinding_performance", func(): return await test_pathfinding_performance())
        run_test("test_particle_system_performance", func(): return await test_particle_system_performance())

    func test_pathfinding_performance() -> bool:
        var pathfinder = Pathfinder.new()
        var large_map = generate_large_test_map(1000, 1000)

        var success = await assert_benchmark_performance(
            "pathfinding_large_map",
            func(): return pathfinder.find_path(large_map, Vector2(0, 0), Vector2(999, 999)),
            50.0  # Max 50ms per pathfinding operation
        )

        return success

    func test_particle_system_performance() -> bool:
        var particle_system = ParticleSystem.new()

        # Test under heavy load
        for i in range(100):
            particle_system.emit_particles_at(Vector2(randf() * 1920, randf() * 1080))

        # Verify performance remains acceptable
        var success = await assert_fps_above(30, 2.0)
        success = success and await assert_memory_usage_less_than(256.0)

        return success

Save/Load System Testing
------------------------

Testing persistence systems validates data integrity and backwards compatibility:

.. code-block:: gdscript

    extends SceneTreeTest
    class_name SaveLoadTest

    func run_test_suite() -> void:
        run_test("test_save_game_state", func(): return test_save_game_state())
        run_test("test_load_game_state", func(): return test_load_game_state())
        run_test("test_corrupted_save_handling", func(): return test_corrupted_save_handling())

    func test_save_game_state() -> bool:
        var save_system = SaveSystem.new()
        var game_data = create_complex_game_state()

        var success = save_system.save_game("test_save.dat", game_data)
        assert_true(success, "Save operation should succeed")

        # Verify file was created
        var file_exists = FileAccess.file_exists("user://test_save.dat")
        return assert_true(file_exists, "Save file should exist on disk")

    func test_load_game_state() -> bool:
        var save_system = SaveSystem.new()
        var original_data = create_complex_game_state()

        # Save first
        save_system.save_game("test_save.dat", original_data)

        # Load in new instance
        var loaded_data = save_system.load_game("test_save.dat")
        assert_not_null(loaded_data, "Loaded data should not be null")

        # Verify data integrity
        return assert_equal_deep(loaded_data, original_data, "Loaded data should match saved data")

    func test_corrupted_save_handling() -> bool:
        var save_system = SaveSystem.new()

        # Create corrupted save file
        var file = FileAccess.open("user://corrupted_save.dat", FileAccess.WRITE)
        file.store_string("invalid json data{")
        file.close()

        # Attempt to load corrupted file
        var loaded_data = save_system.load_game("corrupted_save.dat")

        # Should handle corruption gracefully (return null or default state)
        return assert_null(loaded_data, "Corrupted save files should be handled gracefully")

.. seealso::
   :doc:`examples`
      Practical code examples for all testing scenarios covered in this guide.

   :doc:`api/test-classes`
      Detailed API documentation for SceneTreeTest, Node2DTest, and other base classes.

   :doc:`api/assertions`
      Complete reference for all assertion methods used in the examples above.

   :doc:`troubleshooting`
      Solutions for common testing issues and debugging strategies.
