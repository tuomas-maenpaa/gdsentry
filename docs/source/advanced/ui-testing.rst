UI Testing Framework
====================

GDSentry provides a comprehensive UI testing framework specifically designed for testing Godot user interfaces. UI testing validates that your game's user interface behaves correctly, handles user interactions properly, and maintains usability across different scenarios and configurations.

Overview
========

UI testing capabilities include:

- **Element discovery** and selection by various criteria
- **User interaction simulation** (clicks, typing, navigation)
- **UI state validation** (visibility, text content, positions)
- **Form testing** and data entry validation
- **Accessibility compliance** checking
- **Cross-resolution testing** and responsive design validation

The UI testing framework consists of:

1. **UITest** - Core UI testing functionality
2. **Element finding utilities** - Locate UI elements by text, name, type
3. **Interaction simulation** - Simulate user actions and input
4. **UI assertions** - Validate UI state and behavior
5. **Accessibility testing** - Ensure UI meets accessibility standards

Setting Up UI Testing
=====================

Basic UI Test Structure
-----------------------

Create a UI test that extends UITest:

.. code-block:: gdscript

   extends UITest
   class_name MenuUITest

   func run_test_suite() -> void:
       run_test("test_menu_navigation", func(): return test_menu_navigation())
       run_test("test_button_interactions", func(): return test_button_interactions())
       run_test("test_form_validation", func(): return test_form_validation())
       run_test("test_accessibility", func(): return test_accessibility())

UI Test Configuration
---------------------

Configure UI testing parameters:

.. code-block:: gdscript

   func _ready() -> void:
       # Configure timeouts and waits
       wait_timeout = 5.0           # Default wait timeout
       animation_wait = 0.5         # Animation wait time
       auto_wait_for_animations = true

       # Configure cross-resolution testing
       ui_scale_test_enabled = true
       test_resolutions = [
           Vector2(1920, 1080),     # Full HD
           Vector2(1366, 768),      # HD
           Vector2(1280, 720),      # WXGA
           Vector2(800, 600)        # SVGA
       ]

Finding UI Elements
===================

Finding Elements by Text
------------------------

Locate UI elements by their displayed text:

.. code-block:: gdscript

   func test_find_elements_by_text() -> bool:
       var menu = load_scene("res://scenes/ui/main_menu.tscn")

       # Find button by text
       var play_button = find_button_by_text("Play Game")
       assert_not_null(play_button, "Should find Play Game button")

       # Find label by text
       var title_label = find_label_by_text("My Game")
       assert_not_null(title_label, "Should find title label")

       return true

Finding Elements by Name
------------------------

Locate UI elements by their node name:

.. code-block:: gdscript

   func test_find_elements_by_name() -> bool:
       var settings = load_scene("res://scenes/ui/settings.tscn")

       # Find control by name
       var volume_slider = find_control_by_name("VolumeSlider", "Slider")
       assert_not_null(volume_slider, "Should find volume slider")

       # Find control by name (any type)
       var settings_panel = find_control_by_name("SettingsPanel")
       assert_not_null(settings_panel, "Should find settings panel")

       return true

Finding Elements by Type
------------------------

Locate all elements of a specific type:

.. code-block:: gdscript

   func test_find_elements_by_type() -> bool:
       var form = load_scene("res://scenes/ui/login_form.tscn")

       # Find all buttons
       var buttons = find_controls_by_type("Button")
       assert_true(buttons.size() >= 2, "Should have at least login and cancel buttons")

       # Find all text inputs
       var inputs = find_controls_by_type("LineEdit")
       assert_equals(inputs.size(), 2, "Should have username and password fields")

       return true

User Interaction Simulation
===========================

Button Interactions
-------------------

Simulate button clicks and interactions:

.. code-block:: gdscript

   func test_button_interactions() -> bool:
       var menu = load_scene("res://scenes/ui/main_menu.tscn")

       # Find and click button by text
       var success = click_button_by_text("Start Game")
       assert_true(success, "Should successfully click Start Game button")

       # Alternative: find button first, then click
       var settings_button = find_button_by_text("Settings")
       success = click_button(settings_button)
       assert_true(success, "Should successfully click settings button")

       # Wait for scene transition
       await wait_for_ui_update(2.0)

       # Verify we're in the game scene
       var current_scene = get_tree().current_scene
       assert_not_null(current_scene, "Should have transitioned to new scene")

       return true

Text Input Simulation
---------------------

Simulate typing text into input fields:

.. code-block:: gdscript

   func test_text_input() -> bool:
       var login_form = load_scene("res://scenes/ui/login_form.tscn")

       # Find input fields
       var username_field = find_control_by_name("UsernameField", "LineEdit")
       var password_field = find_control_by_name("PasswordField", "LineEdit")

       # Type text with realistic timing
       var success = type_text(username_field, "testuser", 0.1)
       assert_true(success, "Should successfully type username")

       success = type_text(password_field, "password123", 0.1)
       assert_true(success, "Should successfully type password")

       # Verify text was entered
       assert_equals(username_field.text, "testuser")
       assert_equals(password_field.text, "password123")

       return true

Keyboard Navigation
-------------------

Test keyboard navigation and accessibility:

.. code-block:: gdscript

   func test_keyboard_navigation() -> bool:
       var menu = load_scene("res://scenes/ui/main_menu.tscn")

       # Test tab navigation
       var tab_success = simulate_tab_navigation(3)  # Tab through 3 elements
       assert_true(tab_success, "Should navigate through menu items with Tab")

       # Test shift-tab (reverse navigation)
       var shift_tab_success = simulate_shift_tab_navigation(2)
       assert_true(shift_tab_success, "Should navigate backwards with Shift+Tab")

       # Test arrow key navigation
       var arrow_success = simulate_arrow_key_navigation(KEY_DOWN, 2)
       assert_true(arrow_success, "Should navigate with arrow keys")

       # Test enter key activation
       var focused_control = get_viewport().gui_get_focus_owner()
       var enter_success = simulate_enter_key_activation(focused_control)
       assert_true(enter_success, "Should activate focused control with Enter")

       return true

Focus Management
----------------

Test focus behavior and transitions:

.. code-block:: gdscript

   func test_focus_management() -> bool:
       var form = load_scene("res://scenes/ui/complex_form.tscn")

       # Wait for initial focus
       var focus_success = wait_for_focus(null, 2.0)  # Wait for any control to get focus
       assert_true(focus_success, "Form should set initial focus")

       # Test focus transitions
       var username_field = find_control_by_name("UsernameField")
       username_field.grab_focus()

       focus_success = wait_for_focus(username_field, 1.0)
       assert_true(focus_success, "Should be able to focus username field")

       return true

UI State Validation
===================

Control State Assertions
------------------------

Validate UI control states and properties:

.. code-block:: gdscript

   func test_control_states() -> bool:
       var menu = load_scene("res://scenes/ui/main_menu.tscn")

       # Test button states
       var play_button = find_button_by_text("Play")
       assert_button_enabled(play_button, "Play button should be enabled")

       # Test visibility
       var title_label = find_label_by_text("Game Title")
       assert_control_visible(title_label, "Title should be visible")

       # Test text content
       assert_text_equals(title_label, "My Awesome Game", "Title text should match")

       return true

Form Validation
---------------

Test form input validation and submission:

.. code-block:: gdscript

   func test_form_validation() -> bool:
       var registration_form = load_scene("res://scenes/ui/registration_form.tscn")

       # Fill out form
       var email_field = find_control_by_name("EmailField", "LineEdit")
       var password_field = find_control_by_name("PasswordField", "LineEdit")
       var confirm_field = find_control_by_name("ConfirmPasswordField", "LineEdit")

       type_text(email_field, "user@example.com")
       type_text(password_field, "password123")
       type_text(confirm_field, "password123")

       # Submit form
       var submit_button = find_button_by_text("Register")
       click_button(submit_button)

       # Wait for validation response
       await wait_for_ui_update(1.0)

       # Check for success message
       var success_message = find_label_by_text("Registration successful!")
       assert_control_visible(success_message, "Success message should appear")

       return true

Checkbox and Radio Button Testing
---------------------------------

Test toggle controls and selection states:

.. code-block:: gdscript

   func test_checkbox_states() -> bool:
       var settings = load_scene("res://scenes/ui/settings.tscn")

       # Find checkboxes
       var music_checkbox = find_control_by_name("MusicEnabled", "CheckBox")
       var sfx_checkbox = find_control_by_name("SFXEnabled", "CheckBox")

       # Test initial states
       assert_checkbox_unchecked(music_checkbox, "Music should be off initially")
       assert_checkbox_checked(sfx_checkbox, "SFX should be on initially")

       # Toggle music on
       click_button(music_checkbox)  # Checkboxes can be clicked like buttons
       await wait_for_ui_update(0.5)
       assert_checkbox_checked(music_checkbox, "Music should be on after clicking")

       return true

Slider and Range Control Testing
--------------------------------

Test slider values and ranges:

.. code-block:: gdscript

   func test_slider_controls() -> bool:
       var audio_settings = load_scene("res://scenes/ui/audio_settings.tscn")

       var volume_slider = find_control_by_name("MasterVolume", "Slider")

       # Test initial value
       assert_slider_value(volume_slider, 0.8, 0.01, "Volume should default to 80%")

       # Simulate slider interaction (this would require custom implementation)
       # For now, test programmatic value changes
       volume_slider.value = 0.5
       await wait_for_ui_update(0.5)

       assert_slider_value(volume_slider, 0.5, 0.01, "Volume should be set to 50%")

       return true

Layout and Positioning Tests
============================

Control Positioning
-------------------

Test UI element positioning and layout:

.. code-block:: gdscript

   func test_control_positioning() -> bool:
       var hud = load_scene("res://scenes/ui/game_hud.tscn")

       var health_bar = find_control_by_name("HealthBar")
       var score_label = find_control_by_name("ScoreLabel")

       # Test absolute positions
       assert_control_position(health_bar, Vector2(20, 20), 5.0,
           "Health bar should be positioned at top-left")

       assert_control_position(score_label, Vector2(20, 60), 5.0,
           "Score should be below health bar")

       return true

Control Sizing
--------------

Test control dimensions and sizing:

.. code-block:: gdscript

   func test_control_sizing() -> bool:
       var dialog = load_scene("res://scenes/ui/dialog_box.tscn")

       var dialog_panel = find_control_by_name("DialogPanel")
       var message_label = find_control_by_name("MessageLabel")

       # Test panel size
       assert_control_size(dialog_panel, Vector2(400, 300), 10.0,
           "Dialog panel should be 400x300 pixels")

       # Test label fits within panel
       assert_less(message_label.size.x, dialog_panel.size.x - 40,
           "Message label should fit within dialog with margins")

       return true

Responsive Design Testing
=========================

Multi-Resolution Testing
------------------------

Test UI across different screen resolutions:

.. code-block:: gdscript

   func test_responsive_design() -> bool:
       var success = true

       for resolution in test_resolutions:
           # Set test resolution
           get_viewport().size = resolution
           await wait_for_ui_update(1.0)  # Allow UI to respond

           var menu = load_scene("res://scenes/ui/main_menu.tscn")
           await wait_for_ui_update(1.0)

           # Test that critical elements are visible and accessible
           var play_button = find_button_by_text("Play")
           assert_not_null(play_button, "Play button should exist at %s" % resolution)

           if play_button:
               assert_control_visible(play_button,
                   "Play button should be visible at %s" % resolution)

               # Test that button is within viewport bounds
               var button_rect = Rect2(play_button.global_position, play_button.size)
               var viewport_rect = Rect2(Vector2.ZERO, resolution)

               assert_true(viewport_rect.encloses(button_rect),
                   "Play button should be within viewport at %s" % resolution)

           success = success and (play_button != null)

       return success

UI Scaling Tests
----------------

Test UI scaling and DPI handling:

.. code-block:: gdscript

   func test_ui_scaling() -> bool:
       if not ui_scale_test_enabled:
           return true  # Skip if scaling tests disabled

       var base_scale = 1.0
       var test_scales = [0.8, 1.0, 1.2, 1.5]

       for scale_factor in test_scales:
           # Set UI scale
           get_viewport().content_scale_factor = scale_factor
           await wait_for_ui_update(1.0)

           var settings = load_scene("res://scenes/ui/settings.tscn")
           await wait_for_ui_update(1.0)

           # Test that UI elements scale appropriately
           var panel = find_control_by_name("SettingsPanel")
           assert_not_null(panel, "Settings panel should exist at scale %f" % scale_factor)

           if panel:
               # Test minimum size constraints
               assert_greater(panel.size.x, 200 * scale_factor,
                   "Panel should scale with UI scale factor")

               assert_greater(panel.size.y, 150 * scale_factor,
                   "Panel should scale with UI scale factor")

       return true

Accessibility Testing
=====================

Keyboard Navigation Testing
---------------------------

Test keyboard accessibility:

.. code-block:: gdscript

   func test_keyboard_accessibility() -> bool:
       var form = load_scene("res://scenes/ui/accessibility_form.tscn")

       # Test tab order
       var first_field = find_control_by_name("FirstNameField")
       first_field.grab_focus()

       # Tab through form fields
       for i in range(5):  # 5 form fields
           var tab_success = simulate_tab_navigation(1)
           assert_true(tab_success, "Should be able to tab to field %d" % (i + 1))

           await wait_for_ui_update(0.5)

       # Test that all interactive elements are keyboard accessible
       var submit_button = find_button_by_text("Submit")
       submit_button.grab_focus()

       var enter_success = simulate_enter_key_activation(submit_button)
       assert_true(enter_success, "Submit button should be activatable with Enter key")

       return true

Screen Reader Compatibility
---------------------------

Test screen reader compatibility:

.. code-block:: gdscript

   func test_screen_reader_compatibility() -> bool:
       var menu = load_scene("res://scenes/ui/main_menu.tscn")

       # Test that interactive elements have accessible names
       var buttons = find_controls_by_type("Button")

       for button in buttons:
           # Check for text content or accessible name
           var has_text = not button.text.is_empty()
           var has_tooltip = button.has_meta("tooltip") and not button.get_meta("tooltip").is_empty()

           assert_true(has_text or has_tooltip,
               "Button should have text or tooltip for screen readers: %s" % button.name)

       # Test form labels are associated with inputs
       var inputs = find_controls_by_type("LineEdit")
       for input_field in inputs:
           var label = find_associated_label(input_field)
           assert_not_null(label,
               "Input field should have associated label: %s" % input_field.name)

       return true

Color Contrast Testing
----------------------

Test color contrast for accessibility:

.. code-block:: gdscript

   func test_color_contrast() -> bool:
       var ui = load_scene("res://scenes/ui/color_contrast_test.tscn")

       # Test text contrast against backgrounds
       var text_elements = find_controls_by_type("Label")

       for label in text_elements:
           var text_color = label.get_theme_color("font_color")
           var bg_color = get_background_color(label)

           var contrast_ratio = calculate_contrast_ratio(text_color, bg_color)

           # WCAG AA standard: 4.5:1 for normal text
           assert_greater(contrast_ratio, 4.5,
               "Text contrast should meet WCAG AA standards: %s (ratio: %.2f)" %
               [label.name, contrast_ratio])

       return true

Advanced UI Testing Patterns
============================

Workflow Testing
----------------

Test complete user workflows:

.. code-block:: gdscript

   func test_user_registration_workflow() -> bool:
       # Step 1: Navigate to registration page
       var menu = load_scene("res://scenes/ui/main_menu.tscn")
       click_button_by_text("Register")
       await wait_for_ui_update(2.0)

       # Step 2: Fill registration form
       var reg_form = get_tree().current_scene
       type_text(find_control_by_name("EmailField"), "newuser@example.com")
       type_text(find_control_by_name("PasswordField"), "securepass123")
       type_text(find_control_by_name("ConfirmPassword"), "securepass123")

       # Step 3: Check terms checkbox
       var terms_checkbox = find_control_by_name("AcceptTerms", "CheckBox")
       click_button(terms_checkbox)

       # Step 4: Submit form
       click_button_by_text("Create Account")
       await wait_for_ui_update(3.0)

       # Step 5: Verify success
       var success_message = find_label_by_text("Account created successfully!")
       assert_control_visible(success_message, "Success message should appear")

       # Step 6: Verify user can log in
       click_button_by_text("Continue to Login")
       await wait_for_ui_update(2.0)

       var login_form = get_tree().current_scene
       assert_not_null(login_form, "Should navigate to login form")

       return true

Error Handling Testing
----------------------

Test UI error states and validation:

.. code-block:: gdscript

   func test_form_validation_errors() -> bool:
       var login_form = load_scene("res://scenes/ui/login_form.tscn")

       # Try to submit empty form
       click_button_by_text("Login")
       await wait_for_ui_update(1.0)

       # Check for validation errors
       var email_error = find_label_by_text("Email is required")
       var password_error = find_label_by_text("Password is required")

       assert_control_visible(email_error, "Email validation error should appear")
       assert_control_visible(password_error, "Password validation error should appear")

       # Fill partial data and test specific validations
       type_text(find_control_by_name("EmailField"), "invalid-email")
       click_button_by_text("Login")
       await wait_for_ui_update(1.0)

       var format_error = find_label_by_text("Please enter a valid email address")
       assert_control_visible(format_error, "Email format validation should trigger")

       return true

Animation Testing
-----------------

Test UI animations and transitions:

.. code-block:: gdscript

   func test_ui_animations() -> bool:
       var menu = load_scene("res://scenes/ui/animated_menu.tscn")

       # Trigger menu open animation
       click_button_by_text("Open Menu")
       await wait_for_ui_update(animation_wait)

       # Test menu panel animation
       var menu_panel = find_control_by_name("MenuPanel")
       var initial_pos = menu_panel.position

       # Wait for animation to complete
       await wait_for_ui_update(2.0)

       # Verify panel moved (animated in)
       assert_not_equals(menu_panel.position, initial_pos,
           "Menu panel should animate to new position")

       # Test menu item hover animations
       var first_item = find_controls_by_type("Button")[0]
       simulate_mouse_hover(first_item)
       await wait_for_ui_update(0.5)

       # Verify hover effect (this would depend on your animation implementation)
       var hover_effect_active = first_item.has_meta("hover_active") and first_item.get_meta("hover_active")
       assert_true(hover_effect_active, "Hover animation should activate")

       return true

Performance-Aware UI Testing
============================

UI Performance Testing
----------------------

Test UI responsiveness and performance:

.. code-block:: gdscript

   func test_ui_performance() -> bool:
       var complex_ui = load_scene("res://scenes/ui/complex_dashboard.tscn")

       # Measure UI load time
       var start_time = Time.get_ticks_usec()
       await wait_for_ui_update(1.0)  # Allow UI to fully load
       var load_time = (Time.get_ticks_usec() - start_time) / 1000000.0

       assert_less(load_time, 2.0, "UI should load within 2 seconds")

       # Test interaction responsiveness
       var button = find_button_by_text("Refresh Data")

       start_time = Time.get_ticks_usec()
       click_button(button)
       await wait_for_ui_update(0.5)
       var response_time = (Time.get_ticks_usec() - start_time) / 1000000.0

       assert_less(response_time, 0.1, "UI should respond within 100ms")

       return true

Memory Leak Testing
-------------------

Test for UI-related memory leaks:

.. code-block:: gdscript

   func test_ui_memory_usage() -> bool:
       var initial_memory = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)

       # Create and destroy UI scenes repeatedly
       for i in range(10):
           var scene = load_scene("res://scenes/ui/dynamic_content.tscn")
           await wait_for_ui_update(0.5)

           # Simulate user interactions
           var buttons = find_controls_by_type("Button")
           for button in buttons:
               click_button(button)
               await wait_for_ui_update(0.1)

           # Clean up
           scene.queue_free()
           await wait_for_ui_update(0.5)

       var final_memory = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
       var memory_increase = final_memory - initial_memory

       assert_less(memory_increase, 50.0,
           "UI operations should not leak more than 50MB of memory")

       return true

Best Practices
==============

UI Test Organization
--------------------

Structure UI tests for maintainability:

.. code-block:: gdscript

   # Organize by UI component/feature
   class MenuUITests extends UITest:
       func test_menu_layout() -> bool: ...
       func test_menu_navigation() -> bool: ...
       func test_menu_animations() -> bool: ...

   class FormUITests extends UITest:
       func test_form_validation() -> bool: ...
       func test_form_submission() -> bool: ...
       func test_error_handling() -> bool: ...

   class AccessibilityTests extends UITest:
       func test_keyboard_navigation() -> bool: ...
       func test_screen_reader_support() -> bool: ...
       func test_color_contrast() -> bool: ...

Test Data Management
--------------------

Manage test data effectively:

.. code-block:: gdscript

   # Use fixtures for test data
   func before_all() -> void:
       register_fixture("test_user_data", func(): return create_test_user_data())

   func create_test_user_data() -> Dictionary:
       return {
           "valid_user": {"email": "user@example.com", "password": "password123"},
           "invalid_user": {"email": "invalid", "password": "short"},
           "admin_user": {"email": "admin@example.com", "password": "admin123"}
       }

   func test_form_validation_scenarios() -> bool:
       var test_data = get_fixture("test_user_data")

       for scenario in test_data.keys():
           var data = test_data[scenario]

           # Reset form
           reset_form()

           # Fill form with test data
           type_text(find_control_by_name("EmailField"), data.email)
           type_text(find_control_by_name("PasswordField"), data.password)

           click_button_by_text("Submit")
           await wait_for_ui_update(1.0)

           # Validate results based on scenario
           validate_scenario_results(scenario, data)

       return true

Wait Strategy Optimization
--------------------------

Optimize wait strategies for reliable tests:

.. code-block:: gdscript

   # Use specific waits instead of fixed delays
   func test_efficient_waits() -> bool:
       var loading_dialog = load_scene("res://scenes/ui/loading_dialog.tscn")

       # Bad: Fixed wait
       # await wait_for_ui_update(5.0)  # Always waits 5 seconds

       # Good: Wait for condition
       var loading_spinner = find_control_by_name("LoadingSpinner")

       # Wait for loading to complete
       var start_time = Time.get_ticks_usec()
       while loading_spinner.visible and (Time.get_ticks_usec() - start_time) / 1000000.0 < 10.0:
           await wait_for_ui_update(0.1)

       assert_false(loading_spinner.visible, "Loading should complete within 10 seconds")

       # Alternative: Wait for specific element to appear
       var success_message = wait_for_element_by_text("Loading Complete!", 10.0)
       assert_not_null(success_message, "Success message should appear")

       return true

Cross-Platform Considerations
-----------------------------

Handle platform-specific UI differences:

.. code-block:: gdscript

   func get_platform_specific_selectors() -> Dictionary:
       match OS.get_name():
           "Windows":
               return {
                   "menu_button": "WindowsMenuButton",
                   "close_button": "WindowsCloseButton"
               }
           "macOS":
               return {
                   "menu_button": "macOSMenuButton",
                   "close_button": "macOSCloseButton"
               }
           "Linux":
               return {
                   "menu_button": "LinuxMenuButton",
                   "close_button": "LinuxCloseButton"
               }
           _:
               return {
                   "menu_button": "GenericMenuButton",
                   "close_button": "GenericCloseButton"
               }

   func test_cross_platform_ui() -> bool:
       var selectors = get_platform_specific_selectors()

       var menu_button = find_control_by_name(selectors.menu_button)
       assert_not_null(menu_button,
           "Should find menu button for platform: %s" % OS.get_name())

       click_button(menu_button)
       await wait_for_ui_update(1.0)

       var close_button = find_control_by_name(selectors.close_button)
       assert_not_null(close_button, "Close button should exist")

       return true

Troubleshooting
===============

Common UI Testing Issues
------------------------

**Element not found errors:**
- Verify scene is fully loaded with ``await wait_for_ui_update()``
- Check element names and paths match exactly
- Ensure elements are visible and enabled when searched
- Use debug output to inspect scene hierarchy

**Timing-related test failures:**
- Increase wait timeouts for slower operations
- Use conditional waits instead of fixed delays
- Check for animation completion before assertions
- Consider system performance variations

**Interaction simulation failures:**
- Ensure controls are visible and enabled before interaction
- Wait for focus changes in keyboard navigation tests
- Verify event handling is properly connected
- Check for modal dialogs blocking interactions

**Visual regression false positives:**
- Account for platform-specific rendering differences
- Use appropriate tolerance values for comparisons
- Exclude dynamic content from visual tests
- Establish stable baselines before enabling regression testing

Debugging UI Tests
------------------

Enable UI test debugging features:

.. code-block:: gdscript

   func test_with_ui_debugging() -> bool:
       # Enable verbose UI logging
       ui_debug_mode = true

       var form = load_scene("res://scenes/ui/test_form.tscn")

       print("UI Scene loaded, inspecting hierarchy...")
       debug_print_ui_hierarchy(form)

       # Test with detailed logging
       var button = find_button_by_text("Submit")
       if button:
           print("Found submit button: %s at position %s" % [button.name, button.global_position])
           click_button(button)
           await wait_for_ui_update(2.0)

           var result = find_label_by_text("Form submitted successfully!")
           if result:
               print("SUCCESS: Form submission confirmed")
               return true
           else:
               print("FAILURE: Success message not found")
               debug_print_visible_labels(form)
               return false
       else:
           print("FAILURE: Submit button not found")
           debug_print_all_buttons(form)
           return false

Helper Functions for Debugging
------------------------------

.. code-block:: gdscript

   func debug_print_ui_hierarchy(root: Node, indent: String = "") -> void:
       """Print UI element hierarchy for debugging"""
       print("%s%s (%s)" % [indent, root.name, root.get_class()])

       for child in root.get_children():
           if child is Control:
               var control = child as Control
               print("%s  - %s: %s, visible: %s, pos: %s" %
                   [indent, control.name, control.get_class(), control.visible, control.global_position])
               debug_print_ui_hierarchy(child, indent + "    ")

   func debug_print_visible_labels(root: Node) -> void:
       """Print all visible label text for debugging"""
       var labels = find_controls_by_type("Label", root)

       for label in labels:
           if label.visible:
               print("Visible label: '%s' (%s)" % [label.text, label.name])

   func debug_print_all_buttons(root: Node) -> void:
       """Print all buttons for debugging"""
       var buttons = find_controls_by_type("Button", root)

       for button in buttons:
           print("Button: '%s' (%s), visible: %s, enabled: %s" %
               [button.text, button.name, button.visible, button.disabled])

UI Test Performance Tips
------------------------

.. code-block:: gdscript

   # Cache frequently accessed elements
   var _cached_elements = {}

   func get_cached_element(name: String, type: String = "") -> Control:
       var cache_key = name + "_" + type
       if not _cached_elements.has(cache_key):
           _cached_elements[cache_key] = find_control_by_name(name, type)
       return _cached_elements[cache_key]

   # Use batch operations for multiple UI checks
   func validate_form_state_batch(form: Node) -> Dictionary:
       """Validate multiple form elements in one pass"""
       var results = {}

       var required_fields = ["email", "password", "confirm_password"]
       for field_name in required_fields:
           var field = find_control_by_name(field_name + "_field", "LineEdit")
           results[field_name + "_present"] = field != null
           results[field_name + "_filled"] = field and not field.text.is_empty()

       var submit_button = find_button_by_text("Submit")
       results["submit_enabled"] = submit_button and not submit_button.disabled

       return results

   func test_efficient_form_validation() -> bool:
       var form = load_scene("res://scenes/ui/registration_form.tscn")

       # Single batch validation instead of multiple individual checks
       var state = validate_form_state_batch(form)

       assert_true(state.email_present, "Email field should be present")
       assert_true(state.password_present, "Password field should be present")
       assert_false(state.submit_enabled, "Submit should be disabled for empty form")

       return true

.. seealso::
   :doc:`../api/test-classes`
      UITest class for comprehensive UI testing.

   :doc:`../user-guide`
      Best practices for UI interaction and validation testing.

   :doc:`../troubleshooting`
      Solutions for UI test failures and element finding issues.
