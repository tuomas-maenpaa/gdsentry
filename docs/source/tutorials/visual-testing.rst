Visual Testing Tutorial
=======================

Visual testing ensures that your game's user interface and visual elements appear correctly and behave as expected. This tutorial covers GDSentry's comprehensive visual testing capabilities.

.. note::
   **Prerequisites**: Basic familiarity with GDSentry testing. Complete the :doc:`../getting-started` guide first.

What is Visual Testing?
=======================

Visual testing validates:
- UI element positioning and sizing
- Visual component visibility and states
- Layout consistency across different screen sizes
- Sprite and texture rendering
- Animation states and transitions

Unlike traditional unit tests that focus on logic, visual tests ensure your game *looks right* to players.

When to Use Visual Testing
==========================

Visual tests are essential for:

- **UI Components**: Menus, HUD elements, dialog boxes
- **Game Objects**: Character sprites, environmental assets
- **Layout Systems**: Responsive designs, dynamic positioning
- **Visual Effects**: Particle systems, shader effects
- **Animation States**: Character poses, state transitions

Setting Up a Visual Test
========================

Create a new test class that extends ``Node2DTest``:

.. code-block:: gdscript

    extends GDSentry.Node2DTest

    func test_ui_layout() -> bool:
        # Test implementation goes here
        return true

Loading Test Scenes
===================

Visual tests require scenes to test. GDSentry provides several methods to load scenes:

.. code-block:: gdscript

    func test_menu_layout() -> bool:
        # Load a scene for testing
        var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")

        # Verify the scene loaded
        assert_not_null(menu_scene, "Menu scene should load successfully")

        return true

Finding UI Elements
===================

Once your scene is loaded, locate UI elements for testing:

.. code-block:: gdscript

    func test_play_button_position() -> bool:
        var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")

        # Find the play button by name
        var play_button = find_node_by_name(menu_scene, "PlayButton")

        # Verify the button exists
        assert_not_null(play_button, "Play button should exist")

        # Check if it's a Button node
        assert_true(play_button is Button, "Play button should be a Button node")

        return true

Testing Element Positioning
===========================

Verify that UI elements appear in the correct positions:

.. code-block:: gdscript

    func test_button_positioning() -> bool:
        var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")
        var play_button = find_node_by_name(menu_scene, "PlayButton")

        # Check button position (with tolerance for floating-point precision)
        assert_position(play_button, Vector2(400, 300), 5.0,
                       "Play button should be centered on screen")

        # Verify button size
        assert_size(play_button, Vector2(200, 60), 2.0,
                   "Play button should have correct dimensions")

        return true

Testing Visibility and States
=============================

Ensure elements are visible and in the correct state:

.. code-block:: gdscript

    func test_button_visibility() -> bool:
        var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")
        var play_button = find_node_by_name(menu_scene, "PlayButton")

        # Check if button is visible
        assert_visible(play_button, "Play button should be visible")

        # Test button enabled state
        assert_true(play_button.disabled == false, "Play button should be enabled")

        # Test button text
        assert_eq(play_button.text, "Play Game", "Button should have correct text")

        return true

Testing Layout Containers
=========================

Test complex layouts with multiple elements:

.. code-block:: gdscript

    func test_menu_layout_grid() -> bool:
        var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")

        # Find all menu buttons
        var buttons = find_nodes_by_type(menu_scene, Button)

        # Verify we have the expected number of buttons
        assert_eq(buttons.size(), 4, "Menu should have 4 buttons")

        # Check button spacing (assuming they're in a grid)
        var first_button = buttons[0]
        var second_button = buttons[1]

        var vertical_spacing = second_button.position.y - first_button.position.y
        assert_eq(vertical_spacing, 80.0, "Buttons should be properly spaced")

        return true

Testing Responsive Layouts
==========================

Verify layouts work across different screen sizes:

.. code-block:: gdscript

    func test_responsive_layout() -> bool:
        var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")

        # Simulate different screen sizes
        var test_sizes = [
            Vector2(1920, 1080),  # Full HD
            Vector2(1366, 768),   # HD
            Vector2(800, 600)     # Small screen
        ]

        for screen_size in test_sizes:
            # Set viewport size for testing
            get_viewport().size = screen_size

            # Reload scene to test responsive behavior
            menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")
            var play_button = find_node_by_name(menu_scene, "PlayButton")

            # Verify button stays within screen bounds
            assert_true(play_button.position.x >= 0, "Button should not go off-screen left")
            assert_true(play_button.position.x + play_button.size.x <= screen_size.x,
                       "Button should not go off-screen right")

        return true

Testing Visual Effects
======================

Test particle systems, shaders, and other visual effects:

.. code-block:: gdscript

    func test_particle_effect() -> bool:
        var effect_scene = load_test_scene("res://scenes/effects/explosion.tscn")
        var particle_system = find_node_by_type(effect_scene, GPUParticles2D)

        assert_not_null(particle_system, "Particle system should exist")

        # Check particle system properties
        assert_true(particle_system.emitting, "Particle system should be emitting")
        assert_gt(particle_system.amount, 0, "Particle system should have particles")

        # Test particle lifetime
        assert_gt(particle_system.lifetime, 0.0, "Particles should have lifetime")

        return true

Testing Sprite States
=====================

Verify character sprites and animations:

.. code-block:: gdscript

    func test_character_sprite() -> bool:
        var character_scene = load_test_scene("res://scenes/characters/player.tscn")
        var sprite = find_node_by_type(character_scene, Sprite2D)

        assert_not_null(sprite, "Character should have a sprite")

        # Check sprite texture is loaded
        assert_not_null(sprite.texture, "Sprite should have a texture")

        # Verify sprite dimensions
        assert_gt(sprite.texture.get_width(), 0, "Sprite texture should have width")
        assert_gt(sprite.texture.get_height(), 0, "Sprite texture should have height")

        return true

Animation Testing
=================

Test animation states and transitions:

.. code-block:: gdscript

    func test_character_animation() -> bool:
        var character_scene = load_test_scene("res://scenes/characters/player.tscn")
        var animation_player = find_node_by_type(character_scene, AnimationPlayer)

        assert_not_null(animation_player, "Character should have animation player")

        # Check for required animations
        assert_true(animation_player.has_animation("idle"), "Should have idle animation")
        assert_true(animation_player.has_animation("walk"), "Should have walk animation")
        assert_true(animation_player.has_animation("jump"), "Should have jump animation")

        # Test animation playback
        animation_player.play("idle")
        assert_eq(animation_player.current_animation, "idle", "Idle animation should play")

        return true

Best Practices for Visual Testing
=================================

**Test Organization**
- Group related visual tests in dedicated test files
- Use descriptive test method names (``test_button_positioning`` not ``test_button``)
- Separate tests for different screen sizes and orientations

**Performance Considerations**
- Visual tests can be slower than unit tests
- Run visual tests less frequently in CI/CD pipelines
- Use headless mode when possible to speed up execution

**Maintenance Tips**
- Use relative positioning tolerances (5-10 pixels) to account for floating-point precision
- Update tests when UI designs change intentionally
- Document visual requirements alongside tests

**Debugging Visual Tests**
- Use ``assert_screenshot()`` to capture visual states during test failures
- Compare expected vs actual screenshots
- Check viewport settings and camera positioning

Common Issues and Solutions
===========================

**Elements Not Found**
- Check node names and paths in your scene
- Ensure scenes are properly saved and exported
- Verify test scene loading paths

**Positioning Failures**
- Account for different screen DPI and scaling
- Use appropriate tolerance values (5-10 pixels)
- Check for dynamic layout calculations

**Visibility Issues**
- Ensure parent nodes are visible
- Check canvas layer settings
- Verify viewport and camera configurations

Next Steps
==========

Now that you understand visual testing:

1. **Practice**: Create visual tests for your game's UI components
2. **Explore**: Continue with other GDSentry tutorials as they become available
3. **Advanced**: Check the user guide for advanced testing techniques

.. seealso::
   :doc:`../examples` - More visual testing code examples
   :doc:`../best-practices` - Testing guidelines and best practices
