Testing Examples
================

This section provides practical examples of GDSentry testing patterns with inline code snippets. All examples can be copied directly into your Godot project's ``tests/`` directory.

Unit Testing Example
====================

A comprehensive unit test demonstrating game logic validation using SceneTreeTest.

**Key Features Demonstrated:**
- Unit testing with SceneTreeTest base class
- Test organization with ``run_test_suite()``
- Comprehensive assertion usage
- Error condition testing

**Complete Test File:**

.. code-block:: gdscript

   # tests/test_player.gd
   extends SceneTreeTest

   func _init():
       test_description = "Player character logic and behavior tests"
       test_tags = ["unit", "player", "gameplay"]
       test_priority = "high"
       test_category = "core"

   func run_test_suite() -> void:
       run_test("test_player_initialization", func(): return test_player_initialization())
       run_test("test_player_health_system", func(): return test_player_health_system())
       run_test("test_player_movement", func(): return test_player_movement())
       run_test("test_player_combat", func(): return test_player_combat())

   # Mock Player class for testing
   class MockPlayer:
       var health: int = 100
       var max_health: int = 100
       var position: Vector2 = Vector2.ZERO
       var speed: float = 200.0

       func take_damage(amount: int) -> void:
           health = max(0, health - amount)

       func heal(amount: int) -> void:
           health = min(max_health, health + amount)

       func move(direction: Vector2) -> void:
           position += direction.normalized() * speed

       func is_alive() -> bool:
           return health > 0

   func test_player_initialization() -> bool:
       var player = MockPlayer.new()
       return assert_equals(player.health, 100) and assert_equals(player.max_health, 100)

   func test_player_health_system() -> bool:
       var player = MockPlayer.new()

       # Test damage
       player.take_damage(25)
       var success = assert_equals(player.health, 75)

       # Test healing
       player.heal(10)
       success = success and assert_equals(player.health, 85)

       # Test over-healing
       player.heal(50)  # Would take to 135, but caps at max_health
       success = success and assert_equals(player.health, 100)

       # Test death
       player.take_damage(150)
       success = success and assert_equals(player.health, 0)
       success = success and assert_false(player.is_alive())

       return success

   func test_player_movement() -> bool:
       var player = MockPlayer.new()
       player.position = Vector2(0, 0)

       # Test basic movement
       player.move(Vector2(10, 0))
       var expected = Vector2(10, 0).normalized() * 200.0
       var success = assert_equals(player.position, expected)

       # Test diagonal movement
       var start_pos = player.position
       player.move(Vector2(3, 4))  # Should result in normalized movement
       var move_vector = Vector2(3, 4).normalized() * 200.0
       success = success and assert_equals(player.position, start_pos + move_vector)

       return success

   func test_player_combat() -> bool:
       var player = MockPlayer.new()
       var enemy = MockPlayer.new()

       # Test combat interaction
       enemy.take_damage(30)
       var success = assert_equals(enemy.health, 70)

       # Test that dead enemies stay dead
       enemy.take_damage(100)
       enemy.take_damage(50)  # Should not go below 0
       success = success and assert_equals(enemy.health, 0)

       return success

**Running This Test:**

.. code-block:: bash

   # From your Godot project directory
   gdsentry test run --file tests/test_player.gd

   # Run with verbose output
   gdsentry test run --file tests/test_player.gd --verbose

Visual UI Testing Example
=========================

A comprehensive visual UI testing example using Node2DTest for testing user interfaces.

**Key Features Demonstrated:**
- Visual testing with Node2DTest base class
- UI component validation
- Position and layout testing
- Scene loading and inspection
- UI element creation and positioning
- Button interaction testing
- Signal testing patterns
- Visual assertion methods
- Layout constraint validation

**Complete Test File:**

.. code-block:: gdscript

   # tests/test_ui_layout.gd
   extends Node2DTest

   func _init():
       test_description = "UI layout and interaction tests"
       test_tags = ["visual", "ui", "layout"]
       test_category = "interface"

   func run_test_suite() -> void:
       run_test("test_button_creation_and_positioning", func(): return test_button_creation_and_positioning())
       run_test("test_label_text_and_visibility", func(): return test_label_text_and_visibility())
       run_test("test_ui_layout_constraints", func(): return test_ui_layout_constraints())

   func test_button_creation_and_positioning() -> bool:
       # Create a test button
       var button = Button.new()
       button.text = "Test Button"
       button.position = Vector2(100, 50)
       button.size = Vector2(120, 40)
       add_child(button)

       # Test positioning and sizing
       var success = assert_position(button, Vector2(100, 50), 1.0)
       success = success and assert_visible(button)
       success = success and assert_equals(button.text, "Test Button")

       # Test button interaction simulation
       var initial_text = button.text
       # Note: Button interaction would be tested with signal connections
       success = success and assert_equals(button.text, initial_text)

       return success

   func test_label_text_and_visibility() -> bool:
       # Create a test label
       var label = Label.new()
       label.text = "Hello World"
       label.position = Vector2(200, 100)
       add_child(label)

       # Test label properties
       var success = assert_visible(label)
       success = success and assert_equals(label.text, "Hello World")
       success = success and assert_position(label, Vector2(200, 100), 1.0)

       # Test text changes
       label.text = "Updated Text"
       success = success and assert_equals(label.text, "Updated Text")

       return success

   func test_ui_layout_constraints() -> bool:
       # Create a container with multiple UI elements
       var container = Control.new()
       container.size = Vector2(400, 300)
       add_child(container)

       # Create child elements
       var title = Label.new()
       title.text = "Game Title"
       title.position = Vector2(150, 50)
       container.add_child(title)

       var start_button = Button.new()
       start_button.text = "Start Game"
       start_button.position = Vector2(150, 200)
       start_button.size = Vector2(100, 40)
       container.add_child(start_button)

       # Test layout constraints
       var success = assert_visible(title)
       success = success and assert_visible(start_button)
       success = success and assert_position(title, Vector2(150, 50), 2.0)
       success = success and assert_position(start_button, Vector2(150, 200), 2.0)

       # Test that elements are properly contained
       success = success and assert_true(title.position.x >= 0)
       success = success and assert_true(title.position.y >= 0)
       success = success and assert_true(start_button.position.x >= 0)
       success = success and assert_true(start_button.position.y >= 0)

       return success

**Running This Test:**

.. code-block:: bash

   # From your Godot project directory
   gdsentry test run --file tests/test_ui_layout.gd

   # Run visual tests only
   gdsentry test run --category visual

Common Testing Patterns
=======================

Data-Driven Testing
-------------------

.. code-block:: gdscript

   # tests/test_inventory.gd
   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_inventory_capacity", func(): return test_inventory_capacity())

   func test_inventory_capacity() -> bool:
       var inventory = Inventory.new()
       var test_cases = [
           {"items": 5, "capacity": 10, "expected": true},
           {"items": 10, "capacity": 10, "expected": true},
           {"items": 15, "capacity": 10, "expected": false}
       ]

       var success = true
       for test_case in test_cases:
           inventory.clear()
           inventory.capacity = test_case.capacity

           # Add items up to the test count
           for i in range(test_case.items):
               inventory.add_item("test_item")

           var can_add_more = inventory.can_add_item("new_item")
           success = success and assert_equals(can_add_more, test_case.expected,
               "Failed for %d items in capacity %d" % [test_case.items, test_case.capacity])

       return success

Async Testing with Timeouts
---------------------------

.. code-block:: gdscript

   # tests/test_async_operations.gd
   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_async_loading", func(): return await test_async_loading())

   func test_async_loading() -> bool:
       var loader = ResourceLoader.new()
       var start_time = Time.get_time()

       # Simulate async loading
       await get_tree().create_timer(0.1).timeout

       var end_time = Time.get_time()
       var load_time = end_time - start_time

       # Test that loading took reasonable time
       var success = assert_true(load_time >= 0.08, "Loading should take at least 80ms")
       success = success and assert_true(load_time <= 0.2, "Loading should complete within 200ms")

       return success

Error Handling and Edge Cases
------------------------------

.. code-block:: gdscript

   # tests/test_error_conditions.gd
   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_division_by_zero", func(): return test_division_by_zero())
       run_test("test_invalid_input", func(): return test_invalid_input())

   func test_division_by_zero() -> bool:
       var calculator = Calculator.new()

       # Test that division by zero is handled gracefully
       var result = calculator.divide(10, 0)

       # Should return 0 or some safe value, not crash
       return assert_equals(result, 0)  # Assuming safe division returns 0

   func test_invalid_input() -> bool:
       var parser = DataParser.new()

       # Test parsing invalid data
       var result = parser.parse_json("invalid json string")

       # Should handle gracefully, not crash
       return assert_null(result)  # Assuming invalid JSON returns null
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

Running Test Examples
=====================

All test examples shown above are self-contained and can be copied directly into your project's test directory. To run them:

.. code-block:: bash

    # Run a specific test file
    gdsentry test run --file tests/test_player.gd

    # Run all tests in a directory
    gdsentry test run --directory tests/

    # Run with verbose output
    gdsentry test run --verbose

    # Run and generate HTML report
    gdsentry test run --report html --output reports/

See :doc:`quick-reference` for more CLI command examples.

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
