Visual Testing Framework
========================

GDSentry provides a comprehensive visual testing framework that enables automated testing of UI layouts, visual components, animations, and visual regression detection. Visual testing ensures that what players see matches design intentions across different screen configurations and rendering conditions.

Overview
========

Visual testing capabilities include:

- **Screenshot capture** and automated comparison
- **Visual regression detection** with baseline management
- **UI layout validation** (positioning, visibility, dimensions)
- **Animation and sprite testing**
- **Cross-platform visual consistency**
- **Performance impact measurement**

The visual testing framework consists of:

1. **VisualTest** - Advanced visual testing with regression detection
2. **Node2DTest** - 2D visual component testing
3. **Screenshot comparison utilities**
4. **Baseline image management**

Setting Up Visual Testing
=========================

Basic Visual Test Structure
---------------------------

Create a visual test that extends Node2DTest:

.. code-block:: gdscript

   extends Node2DTest
   class_name MenuVisualTest

   func run_test_suite() -> void:
       run_test("test_main_menu_layout", func(): return test_main_menu_layout())
       run_test("test_button_states", func(): return test_button_states())
       run_test("test_menu_animations", func(): return await test_menu_animations())

Visual Test Configuration
-------------------------

Configure visual testing parameters:

.. code-block:: gdscript

   func _ready() -> void:
       # Configure screenshot directory
       screenshot_dir = "res://test_screenshots/"

       # Set visual comparison tolerance (0.0 to 1.0)
       visual_tolerance = 0.01

       # Enable diff image generation
       generate_diff_images = true

Screenshot Capture
==================

Basic Screenshot Capture
------------------------

Capture screenshots of your game scenes:

.. code-block:: gdscript

   func test_menu_screenshot() -> bool:
       # Load the main menu scene
       var menu_scene = load_test_scene("res://scenes/ui/main_menu.tscn")

       # Wait for scene to be ready
       await wait_for_frames(5)

       # Take a screenshot
       var screenshot = take_screenshot()

       # Verify screenshot was captured
       assert_not_null(screenshot)
       assert_true(screenshot.get_width() > 0)
       assert_true(screenshot.get_height() > 0)

       return true

Screenshot with Custom Name
---------------------------

Save screenshots with descriptive names:

.. code-block:: gdscript

   func test_different_menu_states() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")

       # Test main menu
       var main_menu_shot = take_screenshot("main_menu_initial")
       assert_not_null(main_menu_shot)

       # Simulate button hover
       var play_button = find_nodes_by_type(menu, "Button")[0]
       simulate_mouse_hover(play_button)
       await wait_for_frames(2)

       # Capture hovered state
       var hovered_shot = take_screenshot("main_menu_button_hovered")
       assert_not_null(hovered_shot)

       return true

Visual Regression Testing
=========================

Setting Up Baselines
--------------------

Create baseline images for comparison:

.. code-block:: gdscript

   extends VisualTest
   class_name MenuRegressionTest

   func test_create_menu_baseline() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       # Capture and save as baseline
       var screenshot = take_screenshot("main_menu")
       var success = save_baseline_image("main_menu", screenshot)

       return assert_true(success, "Baseline image should be saved")

Visual Match Assertions
-----------------------

Compare current visuals against baselines:

.. code-block:: gdscript

   func test_menu_visual_regression() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       # Assert that current menu matches baseline
       return assert_visual_match("main_menu", 0.01,
           "Menu layout should match baseline")

Visual Match with Regions
-------------------------

Test specific regions of the screen:

.. code-block:: gdscript

   func test_menu_button_region() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       # Define region containing the play button
       var button_region = Rect2(300, 200, 200, 60)

       # Test only the button area
       return assert_visual_match_region("play_button", button_region, 0.005,
           "Play button should match baseline")

Retry-Based Visual Testing
--------------------------

Handle timing-sensitive visuals with retries:

.. code-block:: gdscript

   func test_animation_completion() -> bool:
       var animated_menu = load_test_scene("res://scenes/ui/animated_menu.tscn")

       # Trigger animation
       var menu_controller = find_node_by_type(animated_menu, "MenuController")
       menu_controller.play_intro_animation()

       # Wait for animation with visual verification
       return assert_visual_match_with_retry("menu_animation_complete",
           0.02, 5, "Menu animation should complete properly")

UI Layout Testing
=================

Visibility Testing
------------------

Test UI element visibility states:

.. code-block:: gdscript

   func test_menu_visibility() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")

       # Test initial state
       var title_label = find_node_by_name(menu, "TitleLabel")
       var play_button = find_nodes_by_type(menu, "Button")[0]

       assert_visible(title_label, "Title should be visible")
       assert_visible(play_button, "Play button should be visible")

       # Test hidden state
       var settings_panel = find_node_by_name(menu, "SettingsPanel")
       assert_not_visible(settings_panel, "Settings should be hidden initially")

       return true

Position and Layout Testing
---------------------------

Verify UI element positioning:

.. code-block:: gdscript

   func test_button_positioning() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")

       var play_button = find_nodes_by_type(menu, "Button")[0]
       var settings_button = find_nodes_by_type(menu, "Button")[1]

       # Test absolute positions with tolerance
       assert_position(play_button, Vector2(400, 300), 5.0,
           "Play button should be centered")

       assert_position(settings_button, Vector2(400, 350), 5.0,
           "Settings button should be below play button")

       return true

Rotation and Scale Testing
--------------------------

Test visual transformations:

.. code-block:: gdscript

   func test_ui_transformations() -> bool:
       var rotatable_button = create_test_button()
       rotatable_button.rotation = PI / 4  # 45 degrees

       assert_rotation(rotatable_button, PI / 4, 0.1,
           "Button should be rotated 45 degrees")

       var scaled_element = create_test_element()
       scaled_element.scale = Vector2(1.5, 1.5)

       assert_scale(scaled_element, Vector2(1.5, 1.5), 0.1,
           "Element should be scaled up")

       return true

Sprite and Animation Testing
============================

Sprite Frame Testing
--------------------

Test sprite animations and frame states:

.. code-block:: gdscript

   func test_sprite_animation() -> bool:
       var animated_sprite = create_animated_sprite()
       animated_sprite.play("walk")

       # Test initial frame
       assert_sprite_frame(animated_sprite, 0, "Animation should start at frame 0")

       # Advance animation
       await wait_for_frames(10)
       var current_frame = animated_sprite.frame

       # Verify animation progressed
       assert_true(current_frame > 0, "Animation should have progressed")
       assert_true(current_frame < animated_sprite.sprite_frames.get_frame_count("walk"),
           "Animation should not exceed frame count")

       return true

Animation Completion Testing
----------------------------

Test that animations complete properly:

.. code-block:: gdscript

   func test_animation_completion() -> bool:
       var door = create_door_sprite()
       door.play("open")

       # Wait for animation to complete
       var frame_count = door.sprite_frames.get_frame_count("open")
       await wait_for_frames(frame_count + 5)

       # Verify animation completed
       assert_equals(door.animation, "open")
       assert_equals(door.frame, frame_count - 1, "Animation should be at last frame")

       # Test door is now in open state
       assert_true(door.is_open(), "Door should be open after animation")

       return true

Advanced Visual Testing
=======================

Image Comparison Algorithms
---------------------------

Use different comparison algorithms:

.. code-block:: gdscript

   func test_different_comparison_algorithms() -> bool:
       var ui_element = load_test_scene("res://scenes/ui/complex_element.tscn")
       await wait_for_frames(5)

       # Compare using different algorithms
       var exact_match = assert_visual_match("complex_element",
           0.001, "Exact pixel matching", 0)  # Exact comparison

       var perceptual_match = assert_visual_match("complex_element",
           0.05, "Perceptual matching", 1)    # Perceptual comparison

       return exact_match or perceptual_match

Multi-Resolution Testing
------------------------

Test across different screen resolutions:

.. code-block:: gdscript

   func test_multiple_resolutions() -> bool:
       var resolutions = [
           Vector2(1920, 1080),  # Full HD
           Vector2(1280, 720),   # HD
           Vector2(800, 600)     # SVGA
       ]

       var success = true

       for resolution in resolutions:
           get_viewport().size = resolution
           await wait_for_frames(2)  # Allow viewport to resize

           var ui = load_test_scene("res://scenes/ui/responsive_menu.tscn")
           await wait_for_frames(5)

           # Test that UI adapts to resolution
           var baseline_name = "menu_%dx%d" % [resolution.x, resolution.y]
           success = success and assert_visual_match(baseline_name, 0.02,
               "UI should adapt to %s resolution" % resolution)

       return success

Performance-Aware Visual Testing
--------------------------------

Measure performance impact of visual operations:

.. code-block:: gdscript

   extends VisualTest

   func test_visual_performance() -> bool:
       var start_time = Time.get_ticks_usec()

       # Perform visual operations
       var scene = load_test_scene("res://scenes/complex_ui.tscn")
       await wait_for_frames(10)

       var screenshot = take_screenshot("performance_test")
       var comparison_result = assert_visual_match("complex_ui_baseline", 0.01)

       var end_time = Time.get_ticks_usec()
       var duration_ms = (end_time - start_time) / 1000.0

       # Assert both visual correctness and performance
       var visual_correct = comparison_result
       var performance_acceptable = duration_ms < 500.0  # Less than 500ms

       assert_true(performance_acceptable,
           "Visual test should complete within 500ms, took %.2fms" % duration_ms)

       return visual_correct and performance_acceptable

Baseline Management
===================

Creating Baselines
------------------

Establish baseline images for future comparisons:

.. code-block:: gdscript

   func test_create_baselines() -> bool:
       var test_scenes = [
           "res://scenes/ui/main_menu.tscn",
           "res://scenes/ui/settings.tscn",
           "res://scenes/ui/game_hud.tscn"
       ]

       var success = true

       for scene_path in test_scenes:
           var scene = load_test_scene(scene_path)
           await wait_for_frames(10)

           var scene_name = scene_path.get_file().get_basename()
           var screenshot = take_screenshot(scene_name)

           success = success and save_baseline_image(scene_name, screenshot)

       return success

Updating Baselines
------------------

Update baselines when visual changes are intentional:

.. code-block:: gdscript

   func test_update_baseline_after_ui_change() -> bool:
       # Load updated UI
       var menu = load_test_scene("res://scenes/ui/updated_menu.tscn")
       await wait_for_frames(5)

       # Take new screenshot
       var new_screenshot = take_screenshot("updated_menu")

       # Update baseline
       var success = update_baseline_image("main_menu", new_screenshot)

       assert_true(success, "Baseline should be updated successfully")

       # Verify new baseline matches
       return assert_visual_match("main_menu", 0.001, "Updated baseline should match")

Baseline Organization
---------------------

Organize baselines by platform and configuration:

.. code-block:: gdscript

   func get_baseline_name(feature: String) -> String:
       var platform = OS.get_name().to_lower()
       var renderer = ProjectSettings.get_setting("rendering/renderer/rendering_method")

       # Create platform-specific baseline names
       return "%s_%s_%s" % [feature, platform, renderer]

   func test_cross_platform_baselines() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       var baseline_name = get_baseline_name("main_menu")

       return assert_visual_match(baseline_name, 0.02,
           "Menu should match %s baseline" % baseline_name)

Visual Test Integration
=======================

CI/CD Integration
-----------------

Set up visual testing for continuous integration:

.. code-block:: bash

   # Run visual tests in CI
   godot --script gdsentry/core/test_runner.gd \
     --profile ci \
     --filter category:visual \
     --report html \
     --discover

   # Check for visual regressions
   if [ -d "test_reports/visual_regressions" ]; then
       echo "Visual regressions detected!"
       exit 1
   fi

Baseline Approval Workflow
--------------------------

Implement approval workflow for baseline updates:

.. code-block:: gdscript

   func test_baseline_approval_workflow() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       var screenshot = take_screenshot("menu_update")

       # Save to approval directory for review
       var approval_path = approval_dir + "menu_update.png"
       var success = screenshot.save_png(approval_path)

       assert_true(success, "Screenshot should be saved for approval")

       # In CI/CD, you would compare against approved images
       # and promote to baseline directory when approved

       return success

Visual Test Reporting
---------------------

Generate comprehensive visual test reports:

.. code-block:: gdscript

   extends VisualTest

   func test_comprehensive_visual_report() -> bool:
       var scenes_to_test = [
           "main_menu", "settings", "game_hud", "pause_menu"
       ]

       var results = []

       for scene_name in scenes_to_test:
           var scene = load_test_scene("res://scenes/ui/%s.tscn" % scene_name)
           await wait_for_frames(5)

           var match_result = assert_visual_match(scene_name, 0.01)
           var screenshot = take_screenshot("%s_test" % scene_name)

           results.append({
               "scene": scene_name,
               "passed": match_result,
               "screenshot_path": screenshot_dir + "%s_test.png" % scene_name,
               "timestamp": Time.get_datetime_string_from_system()
           })

       # Generate summary report
       generate_visual_test_report(results)

       return results.all(func(r): return r.passed)

Best Practices
==============

Visual Test Organization
------------------------

Structure visual tests for maintainability:

.. code-block:: gdscript

   # Organize by component/feature
   class MenuVisualTests extends Node2DTest:
       func test_menu_layout() -> bool: ...
       func test_menu_interactions() -> bool: ...
       func test_menu_animations() -> bool: ...

   class HUDVisualTests extends Node2DTest:
       func test_health_bar() -> bool: ...
       func test_minimap() -> bool: ...
       func test_inventory_display() -> bool: ...

Baseline Maintenance
--------------------

Regular baseline maintenance practices:

.. code-block:: gdscript

   # Run periodic baseline validation
   func test_validate_all_baselines() -> bool:
       var baseline_files = get_baseline_files()
       var success = true

       for baseline_file in baseline_files:
           var baseline_name = baseline_file.get_basename()
           var baseline_image = Image.load_from_file(baseline_file)

           # Verify baseline can be loaded
           success = success and assert_not_null(baseline_image,
               "Baseline %s should be loadable" % baseline_name)

           # Verify baseline has reasonable dimensions
           success = success and assert_true(baseline_image.get_width() > 0,
               "Baseline %s should have valid width" % baseline_name)

       return success

Performance Optimization
------------------------

Optimize visual tests for speed:

.. code-block:: gdscript

   # Use appropriate tolerances
   func test_efficient_comparisons() -> bool:
       var ui = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(2)  # Minimal wait time

       # Use higher tolerance for faster comparison
       return assert_visual_match("main_menu", 0.05,
           "UI should be visually acceptable")

   # Cache expensive operations
   var _cached_screenshots = {}

   func get_cached_screenshot(scene_path: String) -> Image:
       if not _cached_screenshots.has(scene_path):
           var scene = load_test_scene(scene_path)
           await wait_for_frames(5)
           _cached_screenshots[scene_path] = take_screenshot()
       return _cached_screenshots[scene_path]

Flaky Test Prevention
---------------------

Avoid timing-dependent visual tests:

.. code-block:: gdscript

   # Bad: Timing-dependent
   func test_animation_bad() -> bool:
       start_animation()
       await wait_for_frames(30)  # Fixed wait - may be unreliable
       return assert_visual_match("animation_end")

   # Good: State-based
   func test_animation_good() -> bool:
       start_animation()

       # Wait for animation to actually complete
       var animated_node = find_node_by_type(scene, "AnimatedSprite")
       while animated_node.is_playing():
           await wait_for_frames(1)

       return assert_visual_match("animation_end")

Cross-Platform Considerations
-----------------------------

Handle platform-specific visual differences:

.. code-block:: gdscript

   func get_platform_tolerance() -> float:
       match OS.get_name():
           "Windows": return 0.02
           "macOS": return 0.015
           "Linux": return 0.01
           "Android": return 0.05  # Mobile devices may have more variation
           "iOS": return 0.03
           _: return 0.02

   func test_cross_platform_visual() -> bool:
       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       var tolerance = get_platform_tolerance()
       var baseline_name = "menu_%s" % OS.get_name().to_lower()

       return assert_visual_match(baseline_name, tolerance,
           "Menu should match %s baseline within platform tolerance" % OS.get_name())

Troubleshooting
===============

Common Visual Testing Issues
----------------------------

**Screenshot capture failures:**
- Ensure viewport is properly initialized
- Wait for scene loading with ``await wait_for_frames()``
- Check viewport size and rendering settings

**Baseline comparison failures:**
- Verify baseline images exist in correct directory
- Check image formats (PNG recommended)
- Review tolerance settings (start with 0.01)

**False positive visual regressions:**
- Increase tolerance for acceptable variations
- Use perceptual comparison algorithms
- Exclude dynamic content from comparisons

**Performance issues:**
- Reduce screenshot frequency
- Use region-based comparisons
- Optimize image comparison algorithms

Debugging Visual Tests
----------------------

Enable visual debugging features:

.. code-block:: gdscript

   func test_with_visual_debugging() -> bool:
       # Enable debug mode
       visual_debug_mode = true

       var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
       await wait_for_frames(5)

       # Take debug screenshot
       var screenshot = take_screenshot("debug_menu")

       # Save debug image for inspection
       var debug_path = "res://debug_screenshots/menu_debug.png"
       screenshot.save_png(debug_path)

       print("Debug screenshot saved to: %s" % debug_path)

       return assert_visual_match("main_menu", 0.01)

Visual Test Logging
-------------------

Add detailed logging for visual test failures:

.. code-block:: gdscript

   func assert_visual_match_with_logging(baseline_name: String, tolerance: float = 0.01) -> bool:
       var result = assert_visual_match(baseline_name, tolerance)

       if not result:
           var diff_path = diff_dir + "%s_diff.png" % baseline_name
           print("Visual regression detected!")
           print("Baseline: %s" % baseline_name)
           print("Tolerance: %.3f" % tolerance)
           print("Diff image: %s" % diff_path)
           print("To update baseline, run test with UPDATE_BASELINES=true")
       else:
           print("Visual test passed: %s" % baseline_name)

       return result

.. seealso::
   :doc:`../api/test-classes`
      Node2DTest class for visual component testing.

   :doc:`../user-guide`
      Best practices for visual testing scenarios.

   :doc:`../troubleshooting`
      Solutions for visual test failures and debugging techniques.
