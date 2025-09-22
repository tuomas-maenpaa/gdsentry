:orphan:

Best Practices for Game Testing
===============================

This guide outlines proven patterns and practices for effective game testing with GDSentry. Following these practices will help you create maintainable, reliable test suites that provide real value throughout your development process.

Test Organization Principles
============================

Organize by Feature, Not by Test Type
-------------------------------------

**❌ Avoid organizing by test type:**

.. code-block:: text

   tests/
   ├── unit/
   │   ├── player_test.gd
   │   ├── weapon_test.gd
   │   └── enemy_test.gd
   ├── integration/
   │   ├── player_integration_test.gd
   │   └── weapon_integration_test.gd
   └── ui/
       ├── player_ui_test.gd
       └── weapon_ui_test.gd

**✅ Organize by feature/domain:**

.. code-block:: text

   tests/
   ├── player/
   │   ├── player_movement_test.gd        # Unit tests
   │   ├── player_ui_test.gd              # UI tests
   │   └── player_integration_test.gd     # Integration tests
   ├── weapons/
   │   ├── weapon_damage_test.gd
   │   ├── weapon_ui_test.gd
   │   └── weapon_effects_test.gd
   └── enemies/
       ├── enemy_ai_test.gd
       ├── enemy_spawning_test.gd
       └── enemy_behavior_test.gd

**Why this matters:**
- Related tests are co-located
- Easier to find tests when working on a feature
- Natural test organization that matches code structure
- Simpler maintenance when refactoring features

Use Descriptive Test Names
--------------------------

**❌ Poor test names:**

.. code-block:: gdscript

   func test_player() -> bool:           # Too vague
   func test_movement() -> bool:         # What about movement?
   func test_jump() -> bool:             # What aspect of jumping?

**✅ Descriptive test names:**

.. code-block:: gdscript

   func test_player_moves_right_when_right_key_pressed() -> bool:
   func test_player_cannot_move_during_cutscene() -> bool:
   func test_player_jump_height_matches_jump_strength() -> bool:
   func test_player_takes_damage_when_touching_enemy() -> bool:

**Naming pattern:** ``test_[subject]_[behavior]_[condition]``

Test Structure Patterns
=======================

The AAA Pattern
---------------

Structure every test using **Arrange-Act-Assert**:

.. code-block:: gdscript

   func test_player_loses_health_when_taking_damage() -> bool:
       # Arrange - Set up test conditions
       var player = Player.new()
       player.health = 100
       var initial_health = player.health

       # Act - Perform the action being tested
       player.take_damage(25)

       # Assert - Verify the expected outcome
       return assert_equals(player.health, initial_health - 25)

**Benefits:**
- Clear test structure
- Easy to understand test intent
- Separates setup from verification
- Makes tests easier to debug

One Concept Per Test
--------------------

**❌ Testing multiple concepts:**

.. code-block:: gdscript

   func test_player_functionality() -> bool:
       var player = Player.new()

       # Testing movement
       player.move_right()
       assert_true(player.position.x > 0)

       # Testing health
       player.take_damage(10)
       assert_equals(player.health, 90)

       # Testing inventory
       player.add_item("sword")
       assert_array_contains(player.inventory, "sword")

       return true  # This hides which assertion might fail

**✅ One concept per test:**

.. code-block:: gdscript

   func test_player_moves_right_increases_x_position() -> bool:
       var player = Player.new()
       var initial_x = player.position.x

       player.move_right()

       return assert_true(player.position.x > initial_x)

   func test_player_takes_damage_reduces_health() -> bool:
       var player = Player.new()
       player.health = 100

       player.take_damage(10)

       return assert_equals(player.health, 90)

   func test_player_can_add_items_to_inventory() -> bool:
       var player = Player.new()

       player.add_item("sword")

       return assert_array_contains(player.inventory, "sword")

**Benefits:**
- Clear failure messages
- Easy to identify what broke
- Tests can be run independently
- Better test documentation

Choosing the Right Test Type
============================

Decision Matrix
---------------

+-------------------+------------------+------------------+------------------+
| Testing Goal      | Test Class       | When to Use      | Example          |
+===================+==================+==================+==================+
| Business Logic    | SceneTreeTest    | Pure logic,      | Damage           |
|                   |                  | calculations,    | calculations,    |
|                   |                  | algorithms       | AI decisions     |
+-------------------+------------------+------------------+------------------+
| UI Components     | Node2DTest       | Visual elements, | Button layouts,  |
|                   |                  | positioning,     | menu navigation, |
|                   |                  | interactions     | HUD elements     |
+-------------------+------------------+------------------+------------------+
| Game Flows        | IntegrationTest  | Multi-system     | Level            |
|                   |                  | interactions,    | transitions,     |
|                   |                  | complete         | save/load        |
|                   |                  | workflows        | systems          |
+-------------------+------------------+------------------+------------------+
| Performance       | PerformanceTest  | FPS, memory,     | Large battles,   |
|                   |                  | load testing     | particle         |
|                   |                  |                  | effects          |
+-------------------+------------------+------------------+------------------+

Common Anti-Patterns
====================

Testing Implementation Details
------------------------------

**❌ Testing internal state:**

.. code-block:: gdscript

   func test_player_internal_state() -> bool:
       var player = Player.new()
       player.move_right()

       # Testing private implementation details
       return assert_equals(player._internal_velocity_x, 5.0)

**✅ Testing behavior:**

.. code-block:: gdscript

   func test_player_moves_right_when_requested() -> bool:
       var player = Player.new()
       var initial_position = player.position.x

       player.move_right()
       await wait_for_frames(1)  # Allow movement to process

       # Testing observable behavior
       return assert_true(player.position.x > initial_position)

Over-Mocking
------------

**❌ Mocking everything:**

.. code-block:: gdscript

   func test_game_manager_with_too_many_mocks() -> bool:
       # Mocking every dependency
       var mock_player = create_mock("Player")
       var mock_ui = create_mock("UI")
       var mock_audio = create_mock("AudioManager")
       var mock_input = create_mock("InputManager")
       var mock_physics = create_mock("PhysicsManager")

       var game_manager = GameManager.new(mock_player, mock_ui, mock_audio, mock_input, mock_physics)
       # Test becomes complex and brittle

**✅ Mock only what you need:**

.. code-block:: gdscript

   func test_game_manager_pauses_when_menu_opened() -> bool:
       # Only mock the dependencies that matter for this test
       var mock_ui = create_mock("UI")
       when(mock_ui, "is_menu_open").then_return(true)

       var game_manager = GameManager.new()
       game_manager.ui = mock_ui

       game_manager.update()

       return assert_true(game_manager.is_paused)

Testing Strategies by Game Type
===============================

Action Games
------------

**Focus Areas:**
- Collision detection accuracy
- Input response times
- Physics consistency
- Performance under load

.. code-block:: gdscript

   # Action game test example
   func test_bullet_hits_enemy_consistently() -> bool:
       var bullet = Bullet.new()
       var enemy = Enemy.new()

       bullet.position = Vector2(0, 0)
       enemy.position = Vector2(100, 0)
       bullet.velocity = Vector2(200, 0)

       # Simulate bullet travel
       for i in range(10):  # 10 frames at 60fps
           bullet.position += bullet.velocity / 60.0

           if bullet.get_rect().intersects(enemy.get_rect()):
               return assert_true(true, "Bullet should hit enemy")

       return assert_true(false, "Bullet should have hit enemy")

RPG Games
---------

**Focus Areas:**
- Character progression systems
- Inventory management
- Quest state tracking
- Save/load functionality

.. code-block:: gdscript

   # RPG test example
   func test_character_levels_up_with_sufficient_experience() -> bool:
       var character = Character.new()
       character.level = 1
       character.experience = 0
       var experience_needed = character.get_experience_for_next_level()

       character.gain_experience(experience_needed)

       return assert_equals(character.level, 2)

Puzzle Games
------------

**Focus Areas:**
- Game state validation
- Move validation
- Win condition detection
- Undo/redo functionality

.. code-block:: gdscript

   # Puzzle game test example
   func test_puzzle_detects_win_condition() -> bool:
       var puzzle = PuzzleBoard.new()

       # Set up winning configuration
       puzzle.set_piece(0, 0, PuzzleBoard.RED)
       puzzle.set_piece(0, 1, PuzzleBoard.RED)
       puzzle.set_piece(0, 2, PuzzleBoard.RED)

       var is_solved = puzzle.check_win_condition()

       return assert_true(is_solved, "Three in a row should win")

Performance Testing Guidelines
==============================

Establish Baselines
-------------------

Always establish performance baselines before optimizing:

.. code-block:: gdscript

   extends PerformanceTest

   func test_scene_loading_performance() -> bool:
       # Establish baseline
       var start_time = Time.get_time_dict_from_system()

       var scene = load("res://scenes/main_menu.tscn")
       var instance = scene.instantiate()
       add_child(instance)

       var end_time = Time.get_time_dict_from_system()
       var load_time_ms = (end_time.unix - start_time.unix) * 1000

       # Baseline: Main menu should load in under 100ms
       return assert_true(load_time_ms < 100, "Main menu load time: %s ms" % load_time_ms)

Test Under Realistic Conditions
-------------------------------

.. code-block:: gdscript

   func test_game_performance_with_many_entities() -> bool:
       # Create realistic game scenario
       var game_scene = load("res://scenes/game.tscn").instantiate()
       add_child(game_scene)

       # Spawn realistic number of entities
       for i in range(50):  # 50 enemies on screen
           var enemy = Enemy.new()
           enemy.position = Vector2(randf() * 1000, randf() * 600)
           game_scene.add_child(enemy)

       # Let the scene stabilize
       await wait_for_frames(60)  # 1 second at 60fps

       # Measure performance over time
       return assert_fps_above(30, 5.0)  # 30+ FPS for 5 seconds

CI/CD Integration Best Practices
================================

Fast Feedback Loops
-------------------

Structure your CI pipeline for quick feedback:

.. code-block:: yaml

   # .github/workflows/tests.yml
   name: Game Tests

   on: [push, pull_request]

   jobs:
     unit-tests:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Run Unit Tests (fast)
           run: godot --headless --script gdsentry/core/test_runner.gd --filter category:unit

     integration-tests:
       runs-on: ubuntu-latest
       needs: unit-tests  # Only run if unit tests pass
       steps:
         - uses: actions/checkout@v3
         - name: Run Integration Tests
           run: godot --headless --script gdsentry/core/test_runner.gd --filter category:integration

Test Categories and Tags
------------------------

Use consistent categorization for selective test execution:

.. code-block:: gdscript

   extends SceneTreeTest

   func _init():
       test_category = "unit"
       test_tags = ["player", "movement", "fast"]
       test_priority = "high"

   # Fast unit tests run on every commit
   # Integration tests run on pull requests
   # Performance tests run nightly

Common Pitfalls and Solutions
=============================

Flaky Tests
-----------

**Problem:** Tests that sometimes pass and sometimes fail

**Solutions:**

1. **Wait for initialization:**

.. code-block:: gdscript

   func test_ui_element_appears() -> bool:
       var scene = load("res://ui/menu.tscn").instantiate()
       add_child(scene)

       # Wait for scene to initialize properly
       await wait_for_frames(3)

       var button = scene.find_child("PlayButton")
       return assert_not_null(button)

2. **Use proper synchronization:**

.. code-block:: gdscript

   func test_animation_completes() -> bool:
       var sprite = AnimatedSprite2D.new()
       add_child(sprite)

       sprite.play("walk")

       # Wait for animation to complete
       await sprite.animation_finished

       return assert_false(sprite.is_playing())

Brittle Tests
-------------

**Problem:** Tests break with small code changes

**Solutions:**

1. **Test behavior, not implementation**
2. **Use page object pattern for UI tests**
3. **Create test helpers for common operations**

.. code-block:: gdscript

   # Test helper class
   class_name TestHelpers

   static func create_test_player() -> Player:
       var player = Player.new()
       player.health = 100
       player.position = Vector2.ZERO
       return player

   static func simulate_player_input(player: Player, input_action: String):
       # Consistent way to simulate input across tests
       pass

Test Data Management
====================

Use Fixtures for Complex Setup
------------------------------

.. code-block:: gdscript

   extends SceneTreeTest

   func before_all() -> void:
       # Register fixtures that can be reused across tests
       register_fixture("test_player", func(): return create_fully_equipped_player())
       register_fixture("test_dungeon", func(): return create_test_dungeon_with_enemies())

   func test_player_can_clear_dungeon() -> bool:
       var player = get_fixture("test_player")
       var dungeon = get_fixture("test_dungeon")

       # Test logic here
       return assert_true(player.can_complete(dungeon))

Keep Test Data Small and Focused
--------------------------------

.. code-block:: gdscript

   # ❌ Large, complex test data
   var complex_save_data = {
       "player": {
           "name": "TestPlayer",
           "level": 50,
           "experience": 125000,
           "skills": [...],  # 20+ skills
           "inventory": [...], # 100+ items
           "quests": [...]   # 50+ quests
       }
   }

   # ✅ Minimal test data
   var minimal_save_data = {
       "player": {
           "name": "TestPlayer",
           "level": 1,
           "health": 100
       }
   }

Documentation and Maintenance
=============================

Document Test Intent
--------------------

.. code-block:: gdscript

   # ✅ Well-documented test
   func test_player_cannot_move_through_solid_walls() -> bool:
       """
       Verifies that the player collision system correctly prevents
       movement through tiles marked as solid in the tilemap.

       This test ensures that the physics system respects collision
       boundaries, which is critical for level design integrity.

       Related bug report: #123 "Player clips through walls"
       """
       var player = Player.new()
       var wall = create_solid_wall_at(Vector2(100, 0))

       player.position = Vector2(50, 0)
       player.move_right()  # Should hit wall at x=100

       # Player should stop at wall boundary, not pass through
       return assert_true(player.position.x < 100)

Regular Test Review
-------------------

Schedule regular test review sessions:

1. **Remove obsolete tests** for removed features
2. **Update tests** when requirements change
3. **Refactor tests** to reduce duplication
4. **Add missing tests** for new edge cases discovered in production

Test Metrics to Track
=====================

Coverage Metrics
----------------

- **Feature coverage**: Every user-facing feature has tests
- **Edge case coverage**: Error conditions and boundary cases
- **Integration coverage**: Critical user workflows

Quality Metrics
---------------

- **Test execution time**: Keep fast feedback loops
- **Test reliability**: Track and fix flaky tests
- **Maintenance burden**: Time spent updating tests vs. adding features

Business Metrics
----------------

- **Bug detection rate**: Tests should catch bugs before production
- **Regression prevention**: Tests should prevent reintroduction of known bugs
- **Confidence level**: Team confidence in making changes

For more detailed examples and patterns, see:

- :doc:`examples` - Complete runnable examples
- :doc:`user-guide` - Comprehensive testing patterns
- :doc:`api/test-classes` - API reference for all test types
- :doc:`troubleshooting` - Solutions for common testing issues
