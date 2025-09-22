Examples
========

This section provides practical examples of GDSentry testing patterns. You can find complete, runnable examples in the ``examples/`` directory of the GDSentry framework.

Calculator Test Example
=======================

A comprehensive unit test demonstrating mathematical operations validation using the SceneTreeTest base class. This example shows how to test a complete calculator implementation with proper error handling and performance testing.

**Key Features Demonstrated:**
- Unit testing with SceneTreeTest base class
- Test metadata and organization
- Mock class implementation within test file
- Comprehensive assertion usage
- Performance benchmarking
- Error condition testing

.. literalinclude:: ../../examples/calculator_test.gd
   :language: gdscript
   :lines: 1-177

**Test Structure Analysis:**

The calculator test demonstrates several GDSentry patterns:

1. **Test Metadata:** Uses ``_init()`` to set test description, tags, priority, and category
2. **Mock Implementation:** Contains a complete Calculator class for testing
3. **Test Organization:** Uses ``run_test_suite()`` to organize test execution
4. **Assertion Patterns:** Comprehensive use of ``assert_equals()`` for validation
5. **Error Handling:** Tests edge cases like division by zero and negative square roots
6. **Performance Testing:** Includes benchmark testing for operation speed

**Running the Calculator Test:**

.. code-block:: bash

   # Run the calculator test directly
   godot --script gdsentry/examples/calculator_test.gd

   # Run with GDSentry test runner
   godot --script gdsentry/core/test_runner.gd --test-path gdsentry/examples/calculator_test.gd

UI Layout Test Example
======================

A comprehensive visual UI testing example using the Node2DTest base class. This example demonstrates testing UI components, layout validation, interaction simulation, and visual assertions.

**Key Features Demonstrated:**
- Visual testing with Node2DTest base class
- UI element creation and positioning
- Button interaction testing
- Signal testing patterns
- Visual assertion methods
- Collision detection testing
- Layout constraint validation

.. literalinclude:: ../../examples/ui_layout_test.gd
   :language: gdscript
   :lines: 1-220

**Test Structure Analysis:**

The UI layout test demonstrates advanced visual testing patterns:

1. **Visual Test Setup:** Extends Node2DTest for scene-based testing
2. **UI Element Testing:** Tests buttons, labels, sprites, and collision shapes
3. **Interaction Simulation:** Demonstrates button press simulation and signal testing
4. **Visual Assertions:** Uses ``assert_visible()``, ``assert_position()``, ``assert_scale()``
5. **Async Testing:** Shows ``await`` usage for physics and timing-dependent tests
6. **Helper Methods:** Includes utility methods for creating test UI elements

**Running the UI Layout Test:**

.. code-block:: bash

   # Run the UI layout test directly
   godot --script gdsentry/examples/ui_layout_test.gd

   # Run with GDSentry test runner
   godot --script gdsentry/core/test_runner.gd --test-path gdsentry/examples/ui_layout_test.gd

   # Run with visual debugging (if supported)
   godot --script gdsentry/core/test_runner.gd --test-path gdsentry/examples/ui_layout_test.gd --verbose

Common Testing Patterns
=======================

Scene Loading Pattern
---------------------

.. code-block:: gdscript

    extends Node2DTest

    func test_scene_loading() -> bool:
        # Load a test scene
        var scene = load_test_scene("res://scenes/test_scene.tscn")

        # Verify scene loaded correctly
        assert_not_null(scene, "Scene should load successfully")
        assert_true(scene is Node, "Loaded scene should be a Node")

        # Test scene-specific properties
        var root_node = scene
        assert_true(root_node.is_inside_tree(), "Scene should be in scene tree")

        return true

Node Finding Pattern
--------------------

.. code-block:: gdscript

    extends Node2DTest

    func test_node_finding() -> bool:
        var scene = load_test_scene("res://scenes/ui/menu.tscn")

        # Find nodes by type
        var buttons = find_nodes_by_type(scene, "Button")
        assert_true(buttons.size() > 0, "Scene should contain buttons")

        # Find nodes by name
        var play_button = find_control_by_name("PlayButton")
        assert_not_null(play_button, "Play button should exist")

        # Find all controls of a specific type
        var all_controls = find_controls_by_type("Control")
        assert_true(all_controls.size() > 0, "Scene should contain controls")

        return true

Assertion Patterns
------------------

.. code-block:: gdscript

    extends SceneTreeTest

    func test_game_logic_assertions() -> bool:
        var player = Player.new()
        player.health = 100

        # Take damage
        player.take_damage(25)

        # Use fluent assertion chaining
        return assert_equals(player.health, 75, "Health should be reduced by 25") and \
               assert_true(player.is_alive(), "Player should still be alive") and \
               assert_false(player.is_dead(), "Player should not be dead")

    func test_collection_assertions() -> bool:
        var inventory = ["sword", "shield", "potion"]

        # Test collection contents
        assert_array_contains(inventory, "sword")
        assert_array_size(inventory, 3)
        assert_array_not_empty(inventory)

        # Test string contents
        var message = "Hello GDSentry World"
        assert_string_contains(message, "GDSentry")
        assert_string_starts_with(message, "Hello")
        assert_string_length(message, 18)

        return true

Async Testing Pattern
---------------------

.. code-block:: gdscript

    extends Node2DTest

    func test_async_operations() -> bool:
        # Test scene loading (async operation)
        var scene_load_success = await test_scene_loading_async()
        assert_true(scene_load_success, "Scene should load asynchronously")

        # Test timed operations
        await wait_for_frames(30)  # Wait for animations/physics

        # Test signal waiting
        var button = find_nodes_by_type(self, "Button")[0]
        var signal_received = await wait_for_signal(button, "pressed", 2.0)
        assert_true(signal_received, "Button press signal should be received")

        return true

    func test_scene_loading_async() -> bool:
        var scene = load_test_scene("res://scenes/async_scene.tscn")
        return assert_not_null(scene)

Mocking Pattern
---------------

.. code-block:: gdscript

    extends SceneTreeTest

    func test_with_mocking() -> bool:
        # Create mock of dependency
        var mock_api = create_mock("NetworkAPI")
        when(mock_api, "send_request").then_return({"status": "success", "data": {}})

        # Inject mock into system under test
        var service = GameService.new(mock_api)

        # Test behavior
        var result = service.authenticate_user("user", "pass")

        # Verify interactions
        assert_method_called(mock_api, "send_request")
        assert_method_called_with(mock_api, "send_request", [{"user": "user", "pass": "pass"}])

        return assert_equals(result.status, "success")

Data-Driven Testing Pattern
---------------------------

.. code-block:: gdscript

    extends SceneTreeTest

    func test_data_driven_calculator() -> bool:
        var test_cases = [
            {"input": [2, 3], "expected": 5, "description": "positive addition"},
            {"input": [10, -5], "expected": 5, "description": "negative addition"},
            {"input": [0, 0], "expected": 0, "description": "zero addition"},
            {"input": [3.14, 2.86], "expected": 6.0, "description": "float addition"}
        ]

        for test_case in test_cases:
            var calc = Calculator.new()
            var result = calc.add(test_case.input[0], test_case.input[1])

            var message = "Test case '%s': %s + %s should equal %s" % [
                test_case.description,
                test_case.input[0],
                test_case.input[1],
                test_case.expected
            ]

            if not assert_equals(result, test_case.expected, message):
                return false

        return true

Fixture Testing Pattern
-----------------------

.. code-block:: gdscript

    extends SceneTreeTest

    func before_all() -> void:
        # Set up shared test data
        register_fixture("test_database", func(): return create_test_database())
        register_fixture("sample_users", func(): return create_sample_users())

    func test_user_operations() -> bool:
        var db = get_fixture("test_database")
        var users = get_fixture("sample_users")

        # Test user creation
        for user_data in users:
            var user_id = db.create_user(user_data.email, user_data.name)
            assert_greater_than(user_id, 0, "User should be created successfully")

        # Test user retrieval
        var all_users = db.get_all_users()
        assert_equals(all_users.size(), users.size(), "All users should be retrievable")

        return true

Visual Testing Pattern
----------------------

.. code-block:: gdscript

    extends Node2DTest

    func test_ui_visual_consistency() -> bool:
        var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
        await wait_for_frames(5)

        # Test visual elements
        var title = find_nodes_by_type(menu, "Label")[0]
        assert_visible(title, "Title should be visible")
        assert_position(title, Vector2(400, 100), 10, "Title should be centered")

        # Test button layout
        var buttons = find_nodes_by_type(menu, "Button")
        assert_true(buttons.size() >= 2, "Menu should have at least 2 buttons")

        for i in range(buttons.size()):
            var button = buttons[i]
            assert_visible(button, "Button %d should be visible" % i)

            # Check button spacing
            if i > 0:
                var prev_button = buttons[i-1]
                var spacing = button.position.y - (prev_button.position.y + prev_button.size.y)
                assert_greater_than(spacing, 10, "Buttons should have adequate spacing")

        return true

Integration Testing Pattern
---------------------------

.. code-block:: gdscript

    extends IntegrationTest

    func test_complete_game_flow() -> bool:
        # Load complete game scene
        var game_scene = load_scene("res://scenes/game.tscn")
        var player = find_node_by_type(game_scene, "Player")
        var enemy = find_node_by_type(game_scene, "Enemy")
        var ui = find_node_by_type(game_scene, "GameUI")

        # Test initial state
        assert_equals(player.health, 100, "Player should start with full health")
        assert_true(enemy.is_alive(), "Enemy should be alive initially")
        assert_equals(ui.score, 0, "Score should start at zero")

        # Simulate player action
        player.attack(enemy)
        await wait_for_frames(10)  # Allow attack animation

        # Verify system-wide effects
        assert_true(enemy.is_damaged(), "Enemy should be damaged after attack")
        assert_greater_than(player.experience, 0, "Player should gain experience")
        assert_greater_than(ui.score, 0, "Score should increase")
        assert_true(game_scene.score_updated, "Game should track score updates")

        return true

Running the Examples
====================

To run these examples, use the GDSentry test runner:

.. code-block:: bash

    # Run the calculator test example
    godot --script gdsentry/core/test_runner.gd --test-path gdsentry/examples/calculator_test.gd

    # Run the UI layout test example
    godot --script gdsentry/core/test_runner.gd --test-path gdsentry/examples/ui_layout_test.gd

    # Run all examples in the examples directory
    godot --script gdsentry/core/test_runner.gd --test-dir gdsentry/examples/

    # Run with verbose output
    godot --script gdsentry/core/test_runner.gd --test-dir gdsentry/examples/ --verbose

    # Run examples with specific filtering
    godot --script gdsentry/core/test_runner.gd --test-dir gdsentry/examples/ --filter category:examples

    # Run examples and generate HTML report
    godot --script gdsentry/core/test_runner.gd --test-dir gdsentry/examples/ --report html --report-path reports/

**Expected Output:**

When you run the calculator test, you should see output similar to:

.. code-block:: none

    🧪 GDSentry Test Runner v2.0.0
    ==============================

    Running: CalculatorTest
    ✅ test_basic_addition PASSED
    ✅ test_basic_subtraction PASSED
    ✅ test_basic_multiplication PASSED
    ✅ test_basic_division PASSED
    ✅ test_division_by_zero PASSED
    ✅ test_square_root PASSED
    ✅ test_negative_square_root PASSED
    ✅ test_power_function PASSED
    ✅ test_memory_operations PASSED
    ✅ test_performance PASSED

    Results: 10 passed, 0 failed
    Total time: 0.123s

For the UI layout test, you'll see visual testing results with scene loading and UI element validation confirmations.
