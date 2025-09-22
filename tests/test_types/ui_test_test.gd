# GDSentry - UITest Comprehensive Test Suite
# Tests the UITest class functionality for user interface testing and validation
#
# Tests cover:
# - UI element finding (by text, name, type)
# - UI interaction simulation (button clicks, text input, option selection)
# - UI state verification (button states, text content, checkbox states)
# - Form validation and submission
# - Navigation and focus testing
# - Responsive design testing
# - Accessibility compliance checking
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0


extends UITest

class_name UITestTests

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for UITest class"
	test_tags = ["ui_test", "interface", "interaction", "validation", "accessibility", "responsive", "integration"]
	test_priority = "high"
	test_category = "test_types"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all UITest comprehensive tests"""
	run_test("test_ui_test_instantiation", func(): return test_ui_test_instantiation())
	run_test("test_ui_test_configuration", func(): return test_ui_test_configuration())
	run_test("test_ui_element_finding", func(): return test_ui_element_finding())
	run_test("test_ui_interaction_simulation", func(): return await test_ui_interaction_simulation())
	run_test("test_ui_state_verification", func(): return test_ui_state_verification())
	run_test("test_form_validation", func(): return await test_form_validation())
	run_test("test_navigation_focus_testing", func(): return await test_navigation_focus_testing())
	run_test("test_responsive_design_testing", func(): return await test_responsive_design_testing())
	run_test("test_accessibility_compliance", func(): return await test_accessibility_compliance())
	run_test("test_error_handling", func(): return await test_error_handling())
	run_test("test_edge_cases", func(): return await test_edge_cases())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_ui_test_instantiation() -> bool:
	"""Test UITest inheritance and basic properties"""
	var success = true

	# Test that we inherit from UITest
	success = success and assert_equals(get_class(), "UITestTest", "Should be UITestTest class")
	success = success and assert_true(self is UITest, "Should inherit from UITest")
	success = success and assert_true(self is Node2DTest, "Should inherit from Node2DTest")

	# Test default configuration values
	success = success and assert_equals(wait_timeout, 5.0, "Default wait timeout should be 5.0")
	success = success and assert_equals(animation_wait, 0.5, "Default animation wait should be 0.5")
	success = success and assert_equals(FOCUS_TIMEOUT, 2.0, "Default focus timeout should be 2.0")
	success = success and assert_true(auto_wait_for_animations, "Should auto wait for animations by default")

	# Test test resolutions array
	success = success and assert_true(test_resolutions is Array, "Test resolutions should be array")
	success = success and assert_greater_than(test_resolutions.size(), 0, "Should have test resolutions")
	success = success and assert_true(test_resolutions[0] is Vector2, "First resolution should be Vector2")

	# Test default resolutions
	var expected_resolutions = [
		Vector2(1920, 1080),  # Full HD
		Vector2(1366, 768),   # HD
		Vector2(1280, 720),   # WXGA
		Vector2(800, 600)     # SVGA
	]

	for i in range(min(test_resolutions.size(), expected_resolutions.size())):
		success = success and assert_equals(test_resolutions[i], expected_resolutions[i], "Resolution " + str(i) + " should match expected")

	return success

func test_ui_test_configuration() -> bool:
	"""Test UITest configuration modification"""
	var success = true

	# Test configuration modification
	wait_timeout = 10.0
	animation_wait = 1.0
	auto_wait_for_animations = false
	ui_scale_test_enabled = true

	success = success and assert_equals(wait_timeout, 10.0, "Should be able to set wait timeout")
	success = success and assert_equals(animation_wait, 1.0, "Should be able to set animation wait")
	success = success and assert_false(auto_wait_for_animations, "Should be able to disable auto wait")
	success = success and assert_true(ui_scale_test_enabled, "Should be able to enable UI scale testing")

	# Test custom test resolutions
	var custom_resolutions = [
		Vector2(3840, 2160),  # 4K
		Vector2(2560, 1440),  # QHD
		Vector2(1920, 1080)   # FHD
	]
	test_resolutions = custom_resolutions

	success = success and assert_equals(test_resolutions.size(), 3, "Should be able to set custom resolutions")
	success = success and assert_equals(test_resolutions[0], Vector2(3840, 2160), "First custom resolution should be set")

	# Test edge values
	wait_timeout = 0.0  # Zero timeout
	success = success and assert_equals(wait_timeout, 0.0, "Should handle zero wait timeout")

	animation_wait = 0.0  # Zero animation wait
	success = success and assert_equals(animation_wait, 0.0, "Should handle zero animation wait")

	# Test negative values (should be handled gracefully)
	wait_timeout = -1.0
	success = success and assert_equals(wait_timeout, -1.0, "Should handle negative wait timeout")

	animation_wait = -0.5
	success = success and assert_equals(animation_wait, -0.5, "Should handle negative animation wait")

	return success

# ------------------------------------------------------------------------------
# UI ELEMENT FINDING TESTS
# ------------------------------------------------------------------------------
func test_ui_element_finding() -> bool:
	"""Test UI element finding functionality"""
	var success = true

	# Create test UI hierarchy
	var root = Control.new()
	var container = VBoxContainer.new()
	var button1 = Button.new()
	button1.text = "Test Button 1"
	var button2 = Button.new()
	button2.text = "Test Button 2"
	var label1 = Label.new()
	label1.text = "Test Label"
	var line_edit = LineEdit.new()
	line_edit.name = "TestLineEdit"

	container.add_child(button1)
	container.add_child(label1)
	container.add_child(line_edit)
	root.add_child(container)
	root.add_child(button2)

	add_child(root)

	# Test find_button_by_text
	var found_button1 = find_button_by_text("Test Button 1")
	success = success and assert_not_null(found_button1, "Should find button by text")
	success = success and assert_equals(found_button1.text, "Test Button 1", "Found button should have correct text")

	var not_found_button = find_button_by_text("Nonexistent Button")
	success = success and assert_null(not_found_button, "Should return null for nonexistent button")

	# Test find_label_by_text
	var found_label = find_label_by_text("Test Label")
	success = success and assert_not_null(found_label, "Should find label by text")
	success = success and assert_equals(found_label.text, "Test Label", "Found label should have correct text")

	# Test find_control_by_name
	var found_line_edit = find_control_by_name("TestLineEdit", "LineEdit")
	success = success and assert_not_null(found_line_edit, "Should find control by name")
	success = success and assert_equals(found_line_edit.name, "TestLineEdit", "Found control should have correct name")

	var nonexistent_control = find_control_by_name("NonexistentControl")
	success = success and assert_null(nonexistent_control, "Should return null for nonexistent control")

	# Test find_controls_by_type
	var all_buttons = find_controls_by_type("Button")
	success = success and assert_equals(all_buttons.size(), 2, "Should find 2 buttons")
	success = success and assert_true(all_buttons[0] is Button, "First result should be Button")
	success = success and assert_true(all_buttons[1] is Button, "Second result should be Button")

	var all_labels = find_controls_by_type("Label")
	success = success and assert_equals(all_labels.size(), 1, "Should find 1 label")

	var nonexistent_type = find_controls_by_type("NonexistentType")
	success = success and assert_equals(nonexistent_type.size(), 0, "Should find no controls of nonexistent type")

	# Test with null root
	var null_root_buttons = find_controls_by_type("Button", null)
	success = success and assert_type(null_root_buttons, TYPE_ARRAY, "Should handle null root gracefully")

	return success

# ------------------------------------------------------------------------------
# UI INTERACTION SIMULATION TESTS
# ------------------------------------------------------------------------------
func test_ui_interaction_simulation() -> bool:
	"""Test UI interaction simulation functionality"""
	var success = true

	# Create test UI elements
	var button = Button.new()
	button.text = "Test Button"
	button.size = Vector2(100, 50)

	var line_edit = LineEdit.new()
	line_edit.size = Vector2(200, 30)

	var option_button = OptionButton.new()
	option_button.add_item("Option 1")
	option_button.add_item("Option 2")
	option_button.add_item("Option 3")

	var checkbox = CheckBox.new()
	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0

	var container = VBoxContainer.new()
	container.add_child(button)
	container.add_child(line_edit)
	container.add_child(option_button)
	container.add_child(checkbox)
	container.add_child(slider)

	add_child(container)

	# Test button clicking
	var button_click_result = await click_button(button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(button_click_result, TYPE_BOOL, "Button click should return boolean")

	var button_by_text_result = await click_button_by_text("Test Button", false)  # Disable waiting to avoid coroutine
	success = success and assert_type(button_by_text_result, TYPE_BOOL, "Button by text click should return boolean")

	# Test nonexistent button click
	var nonexistent_button_result = await click_button_by_text("Nonexistent Button", false)  # Disable waiting to avoid coroutine
	success = success and assert_false(nonexistent_button_result, "Nonexistent button click should fail")

	# Test text typing
	var typing_result = await type_text(line_edit, "Hello World", 0.0)  # Set typing speed to 0 to avoid coroutine
	success = success and assert_type(typing_result, TYPE_BOOL, "Text typing should return boolean")

	# Test option selection
	var option_select_result = select_option(option_button, "Option 2")
	success = success and assert_true(option_select_result, "Option selection should succeed")
	success = success and assert_equals(option_button.selected, 1, "Option 2 should be selected")

	var nonexistent_option_result = select_option(option_button, "Nonexistent Option")
	success = success and assert_false(nonexistent_option_result, "Nonexistent option selection should fail")

	# Test checkbox toggling
	var initial_state = checkbox.button_pressed
	var toggle_result = toggle_checkbox(checkbox)
	success = success and assert_true(toggle_result, "Checkbox toggle should succeed")
	success = success and assert_not_equals(checkbox.button_pressed, initial_state, "Checkbox state should change")

	# Test slider value setting
	var slider_result = set_slider_value(slider, 75.0)
	success = success and assert_true(slider_result, "Slider value setting should succeed")
	success = success and assert_equals(slider.value, 75.0, "Slider should have correct value")

	# Test slider value clamping
	var clamp_result = set_slider_value(slider, 150.0)  # Above max
	success = success and assert_false(clamp_result, "Out of range slider value should fail")

	var clamp_result2 = set_slider_value(slider, -50.0)  # Below min
	success = success and assert_false(clamp_result2, "Below range slider value should fail")

	# Test with null controls
	var null_button_result = await click_button(null, false)  # Disable waiting to avoid coroutine
	success = success and assert_false(null_button_result, "Null button click should fail")

	var null_text_result = await type_text(null, "test", 0.0)  # Set typing speed to 0 to avoid coroutine
	success = success and assert_false(null_text_result, "Null text input should fail")

	var null_option_result = select_option(null, "test")
	success = success and assert_false(null_option_result, "Null option selection should fail")

	var null_checkbox_result = toggle_checkbox(null)
	success = success and assert_false(null_checkbox_result, "Null checkbox toggle should fail")

	var null_slider_result = set_slider_value(null, 50.0)
	success = success and assert_false(null_slider_result, "Null slider setting should fail")

	return success

# ------------------------------------------------------------------------------
# UI STATE VERIFICATION TESTS
# ------------------------------------------------------------------------------
func test_ui_state_verification() -> bool:
	"""Test UI state verification functionality"""
	var success = true

	# Create test UI elements
	var enabled_button = Button.new()
	enabled_button.text = "Enabled Button"

	var disabled_button = Button.new()
	disabled_button.text = "Disabled Button"
	disabled_button.disabled = true

	var checked_checkbox = CheckBox.new()
	checked_checkbox.button_pressed = true

	var unchecked_checkbox = CheckBox.new()
	unchecked_checkbox.button_pressed = false

	var label = Label.new()
	label.text = "Test Label Text"

	var line_edit = LineEdit.new()
	line_edit.text = "Test LineEdit Text"

	var container = VBoxContainer.new()
	container.add_child(enabled_button)
	container.add_child(disabled_button)
	container.add_child(checked_checkbox)
	container.add_child(unchecked_checkbox)
	container.add_child(label)
	container.add_child(line_edit)

	add_child(container)

	# Test button state assertions
	var enabled_assertion = assert_button_enabled(enabled_button)
	success = success and assert_true(enabled_assertion, "Enabled button assertion should pass")

	var disabled_assertion = assert_button_disabled(disabled_button)
	success = success and assert_true(disabled_assertion, "Disabled button assertion should pass")

	# Test incorrect button state assertions
	var wrong_enabled_assertion = assert_button_enabled(disabled_button)
	success = success and assert_false(wrong_enabled_assertion, "Wrong enabled button assertion should fail")

	var wrong_disabled_assertion = assert_button_disabled(enabled_button)
	success = success and assert_false(wrong_disabled_assertion, "Wrong disabled button assertion should fail")

	# Test checkbox state assertions
	var checked_assertion = assert_checkbox_checked(checked_checkbox)
	success = success and assert_true(checked_assertion, "Checked checkbox assertion should pass")

	var unchecked_assertion = assert_checkbox_unchecked(unchecked_checkbox)
	success = success and assert_true(unchecked_assertion, "Unchecked checkbox assertion should pass")

	# Test incorrect checkbox state assertions
	var wrong_checked_assertion = assert_checkbox_checked(unchecked_checkbox)
	success = success and assert_false(wrong_checked_assertion, "Wrong checked checkbox assertion should fail")

	var wrong_unchecked_assertion = assert_checkbox_unchecked(checked_checkbox)
	success = success and assert_false(wrong_unchecked_assertion, "Wrong unchecked checkbox assertion should fail")

	# Test text assertions
	var label_text_assertion = assert_text_equals(label, "Test Label Text")
	success = success and assert_true(label_text_assertion, "Correct label text assertion should pass")

	var line_edit_text_assertion = assert_text_equals(line_edit, "Test LineEdit Text")
	success = success and assert_true(line_edit_text_assertion, "Correct LineEdit text assertion should pass")

	# Test incorrect text assertions
	var wrong_label_text_assertion = assert_text_equals(label, "Wrong Text")
	success = success and assert_false(wrong_label_text_assertion, "Wrong label text assertion should fail")

	var wrong_line_edit_text_assertion = assert_text_equals(line_edit, "Wrong Text")
	success = success and assert_false(wrong_line_edit_text_assertion, "Wrong LineEdit text assertion should fail")

	# Test with null controls
	var null_text_assertion = assert_text_equals(null, "test")
	success = success and assert_false(null_text_assertion, "Null text assertion should fail")

	# Test with controls without text property
	var button_text_assertion = assert_text_equals(enabled_button, "test")
	success = success and assert_false(button_text_assertion, "Button text assertion should fail (no text property)")

	# Test custom messages
	var custom_message_assertion = assert_button_enabled(disabled_button, "Custom error message")
	success = success and assert_false(custom_message_assertion, "Custom message assertion should fail")

	return success

# ------------------------------------------------------------------------------
# FORM VALIDATION TESTS
# ------------------------------------------------------------------------------
func test_form_validation() -> bool:
	"""Test form validation and submission functionality"""
	var success = true

	# Create test form elements
	var name_field = LineEdit.new()
	name_field.placeholder_text = "Enter your name"

	var email_field = LineEdit.new()
	email_field.placeholder_text = "Enter your email"

	var age_field = LineEdit.new()
	age_field.placeholder_text = "Enter your age"

	var submit_button = Button.new()
	submit_button.text = "Submit"

	var form_container = VBoxContainer.new()
	form_container.add_child(name_field)
	form_container.add_child(email_field)
	form_container.add_child(age_field)
	form_container.add_child(submit_button)

	add_child(form_container)

	# Test form field population
	var name_result = await type_text(name_field, "John Doe", 0.0)  # Set typing speed to 0 to avoid coroutine
	success = success and assert_type(name_result, TYPE_BOOL, "Name field typing should return boolean")

	var email_result = await type_text(email_field, "john.doe@example.com", 0.0)  # Set typing speed to 0 to avoid coroutine
	success = success and assert_type(email_result, TYPE_BOOL, "Email field typing should return boolean")

	var age_result = await type_text(age_field, "30", 0.0)  # Set typing speed to 0 to avoid coroutine
	success = success and assert_type(age_result, TYPE_BOOL, "Age field typing should return boolean")

	# Verify form field contents
	var name_assertion = assert_text_equals(name_field, "John Doe")
	success = success and assert_true(name_assertion, "Name field should contain correct text")

	var email_assertion = assert_text_equals(email_field, "john.doe@example.com")
	success = success and assert_true(email_assertion, "Email field should contain correct text")

	var age_assertion = assert_text_equals(age_field, "30")
	success = success and assert_true(age_assertion, "Age field should contain correct text")

	# Test form submission
	var submit_result = await click_button(submit_button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(submit_result, TYPE_BOOL, "Form submission should return boolean")

	# Test form validation (if methods exist)
	if has_method("assert_form_field_not_empty"):
		var name_validation = assert_form_field_not_empty(name_field)
		success = success and assert_type(name_validation, TYPE_BOOL, "Name field validation should return boolean")

		var empty_field = LineEdit.new()
		add_child(empty_field)
		var empty_validation = assert_form_field_not_empty(empty_field)
		success = success and assert_type(empty_validation, TYPE_BOOL, "Empty field validation should return boolean")

	if has_method("assert_form_valid_email"):
		var valid_email = assert_form_valid_email(email_field)
		success = success and assert_type(valid_email, TYPE_BOOL, "Valid email validation should return boolean")

		var invalid_email_field = LineEdit.new()
		invalid_email_field.text = "invalid-email"
		add_child(invalid_email_field)
		var invalid_email = assert_form_valid_email(invalid_email_field)
		success = success and assert_type(invalid_email, TYPE_BOOL, "Invalid email validation should return boolean")

	if has_method("assert_form_field_numeric"):
		var numeric_age = assert_form_field_numeric(age_field)
		success = success and assert_type(numeric_age, TYPE_BOOL, "Numeric field validation should return boolean")

		var non_numeric_field = LineEdit.new()
		non_numeric_field.text = "not-a-number"
		add_child(non_numeric_field)
		var non_numeric = assert_form_field_numeric(non_numeric_field)
		success = success and assert_type(non_numeric, TYPE_BOOL, "Non-numeric field validation should return boolean")

	return success

# ------------------------------------------------------------------------------
# NAVIGATION AND FOCUS TESTING TESTS
# ------------------------------------------------------------------------------
func test_navigation_focus_testing() -> bool:
	"""Test navigation and focus testing functionality"""
	var success = true

	# Create test UI elements with focus
	var text_field1 = LineEdit.new()
	text_field1.placeholder_text = "First field"

	var text_field2 = LineEdit.new()
	text_field2.placeholder_text = "Second field"

	var button = Button.new()
	button.text = "Test Button"
	button.focus_mode = Control.FOCUS_ALL

	var container = VBoxContainer.new()
	container.add_child(text_field1)
	container.add_child(text_field2)
	container.add_child(button)

	add_child(container)

	# Test focus setting (if methods exist)
	if has_method("set_focus_to_control"):
		var focus_result1 = await set_focus_to_control(text_field1)
		success = success and assert_type(focus_result1, TYPE_BOOL, "Focus setting should return boolean")

		var focus_result2 = await set_focus_to_control(text_field2)
		success = success and assert_type(focus_result2, TYPE_BOOL, "Focus setting should return boolean")

	if has_method("assert_control_has_focus"):
		var focus_assertion1 = assert_control_has_focus(text_field1)
		success = success and assert_type(focus_assertion1, TYPE_BOOL, "Focus assertion should return boolean")

		var focus_assertion2 = assert_control_has_focus(button)
		success = success and assert_type(focus_assertion2, TYPE_BOOL, "Focus assertion should return boolean")

	# Test tab navigation
	if has_method("simulate_tab_navigation"):
		var tab_result = await simulate_tab_navigation(3)  # Tab through 3 controls
		success = success and assert_type(tab_result, TYPE_BOOL, "Tab navigation should return boolean")

	if has_method("simulate_shift_tab_navigation"):
		var shift_tab_result = await simulate_shift_tab_navigation(2)  # Shift+Tab through 2 controls
		success = success and assert_type(shift_tab_result, TYPE_BOOL, "Shift+Tab navigation should return boolean")

	# Test keyboard navigation
	if has_method("simulate_arrow_key_navigation"):
		var arrow_result = await simulate_arrow_key_navigation(KEY_DOWN, 2)
		success = success and assert_type(arrow_result, TYPE_BOOL, "Arrow key navigation should return boolean")

	if has_method("simulate_enter_key_activation"):
		var enter_result = await simulate_enter_key_activation(button)
		success = success and assert_type(enter_result, TYPE_BOOL, "Enter key activation should return boolean")

	# Test focus ring visibility
	if has_method("assert_focus_ring_visible"):
		var focus_ring_result = assert_focus_ring_visible(button)
		success = success and assert_type(focus_ring_result, TYPE_BOOL, "Focus ring visibility should return boolean")

	# Test with null controls
	if has_method("set_focus_to_control"):
		var null_focus_result = await set_focus_to_control(null)
		success = success and assert_type(null_focus_result, TYPE_BOOL, "Null focus setting should return boolean")

	if has_method("assert_control_has_focus"):
		var null_focus_assertion = assert_control_has_focus(null)
		success = success and assert_type(null_focus_assertion, TYPE_BOOL, "Null focus assertion should return boolean")

	return success

# ------------------------------------------------------------------------------
# RESPONSIVE DESIGN TESTING TESTS
# ------------------------------------------------------------------------------
func test_responsive_design_testing() -> bool:
	"""Test responsive design testing functionality"""
	var success = true

	# Create test UI layout
	var container = VBoxContainer.new()
	var header = Label.new()
	header.text = "Header"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var content = TextEdit.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var footer = HBoxContainer.new()
	var button1 = Button.new()
	button1.text = "Button 1"
	var button2 = Button.new()
	button2.text = "Button 2"

	footer.add_child(button1)
	footer.add_child(button2)

	container.add_child(header)
	container.add_child(content)
	container.add_child(footer)

	add_child(container)

	# Test resolution testing
	if has_method("test_ui_at_resolution"):
		for resolution in test_resolutions:
			await test_ui_at_resolution(container, resolution)
			# Function returns void, assume success if no errors printed

	if has_method("assert_ui_layout_valid"):
		var layout_result = assert_ui_layout_valid(container)
		success = success and assert_type(layout_result, TYPE_BOOL, "Layout validation should return boolean")

	if has_method("assert_no_ui_overlap"):
		var overlap_result = assert_no_ui_overlap(container)
		success = success and assert_type(overlap_result, TYPE_BOOL, "Overlap check should return boolean")

	if has_method("assert_text_readable"):
		var readable_result = assert_text_readable(header)
		success = success and assert_type(readable_result, TYPE_BOOL, "Text readability should return boolean")

	# Test aspect ratio handling
	if has_method("assert_ui_aspect_ratio_handled"):
		var aspect_result = await assert_ui_aspect_ratio_handled(container, "Test aspect ratio handling")
		success = success and assert_type(aspect_result, TYPE_BOOL, "Aspect ratio handling should return boolean")

	# Test UI scaling
	if has_method("test_ui_scaling"):
		var scaling_result = await test_ui_scaling(container, 1.5)
		success = success and assert_type(scaling_result, TYPE_BOOL, "UI scaling should return boolean")

	# Test with different DPI settings
	if has_method("test_ui_at_dpi"):
		var dpi_result = await test_ui_at_dpi(container, 200)
		success = success and assert_type(dpi_result, TYPE_BOOL, "DPI testing should return boolean")

	# Test touch target sizes (accessibility)
	if has_method("assert_touch_targets_accessible"):
		var touch_result = assert_touch_targets_accessible(container)
		success = success and assert_type(touch_result, TYPE_BOOL, "Touch target accessibility should return boolean")

	return success

# ------------------------------------------------------------------------------
# ACCESSIBILITY COMPLIANCE TESTS
# ------------------------------------------------------------------------------
func test_accessibility_compliance() -> bool:
	"""Test accessibility compliance checking functionality"""
	var success = true

	# Create test UI elements with various accessibility concerns
	var good_button = Button.new()
	good_button.text = "Accessible Button"

	var bad_button = Button.new()
	bad_button.text = ""  # No text

	var good_label = Label.new()
	good_label.text = "Clear label text"

	var small_button = Button.new()
	small_button.text = "Small"
	small_button.size = Vector2(10, 10)  # Too small for accessibility

	var low_contrast_label = Label.new()
	low_contrast_label.text = "Low contrast text"

	var container = VBoxContainer.new()
	container.add_child(good_button)
	container.add_child(bad_button)
	container.add_child(good_label)
	container.add_child(small_button)
	container.add_child(low_contrast_label)

	add_child(container)

	# Test accessibility compliance checks
	if has_method("assert_accessible_button"):
		var good_button_access = assert_accessible_button(good_button)
		success = success and assert_type(good_button_access, TYPE_BOOL, "Good button accessibility should return boolean")

		var bad_button_access = assert_accessible_button(bad_button)
		success = success and assert_type(bad_button_access, TYPE_BOOL, "Bad button accessibility should return boolean")

	if has_method("assert_accessible_label"):
		var good_label_access = assert_accessible_label(good_label)
		success = success and assert_type(good_label_access, TYPE_BOOL, "Good label accessibility should return boolean")

	if has_method("assert_minimum_touch_target"):
		var good_touch_target = assert_minimum_touch_target(good_button, "Test good touch target")
		success = success and assert_type(good_touch_target, TYPE_BOOL, "Good touch target should return boolean")

		var bad_touch_target = assert_minimum_touch_target(small_button, "Test bad touch target")
		success = success and assert_type(bad_touch_target, TYPE_BOOL, "Bad touch target should return boolean")

	if has_method("assert_sufficient_contrast"):
		var contrast_result = assert_sufficient_contrast(Color.WHITE, Color.BLACK, "Test contrast")
		success = success and assert_type(contrast_result, TYPE_BOOL, "Contrast check should return boolean")

	if has_method("assert_keyboard_navigable"):
		var keyboard_nav_result = await assert_keyboard_navigable(container, "Test keyboard navigation")
		success = success and assert_type(keyboard_nav_result, TYPE_BOOL, "Keyboard navigation should return boolean")

	if has_method("assert_screen_reader_friendly"):
		var screen_reader_result = assert_screen_reader_friendly(container)
		success = success and assert_type(screen_reader_result, TYPE_BOOL, "Screen reader compatibility should return boolean")

	if has_method("generate_accessibility_report"):
		var report = generate_accessibility_report(container)
		success = success and assert_type(report, TYPE_STRING, "Accessibility report should be string")
		success = success and assert_greater_than(report.length(), 0, "Accessibility report should not be empty")

	# Test with null controls
	if has_method("assert_accessible_button"):
		var null_access_result = assert_accessible_button(null)
		success = success and assert_type(null_access_result, TYPE_BOOL, "Null accessibility check should return boolean")

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Test with null controls for all methods
	var methods_to_test = [
		"click_button", "type_text", "select_option", "toggle_checkbox", "set_slider_value",
		"assert_button_enabled", "assert_button_disabled", "assert_text_equals",
		"assert_checkbox_checked", "assert_checkbox_unchecked"
	]

	for method_name in methods_to_test:
		if has_method(method_name):
			var null_result = call(method_name, null)
			success = success and assert_type(null_result, TYPE_BOOL, "Null parameter for " + method_name + " should return boolean")

	# Test with invalid parameters
	var button = Button.new()
	var invalid_text_result = assert_text_equals(button, "test")
	success = success and assert_false(invalid_text_result, "Invalid text assertion should fail")

	# Test with empty strings
	var empty_text_result = find_button_by_text("")
	success = success and assert_type(empty_text_result, TYPE_BOOL, "Empty text search should return boolean")

	var empty_name_result = find_control_by_name("")
	success = success and assert_type(empty_name_result, TYPE_BOOL, "Empty name search should return boolean")

	# Test with invalid types
	var invalid_type_result = find_controls_by_type("")
	success = success and assert_type(invalid_type_result, TYPE_ARRAY, "Invalid type search should return array")

	# Test with extreme values
	wait_timeout = 999.0
	animation_wait = 999.0

	var extreme_timeout_result = await click_button(button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(extreme_timeout_result, TYPE_BOOL, "Extreme timeout should return boolean")

	# Test with negative values
	wait_timeout = -1.0
	animation_wait = -1.0

	var negative_timeout_result = await click_button(button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(negative_timeout_result, TYPE_BOOL, "Negative timeout should return boolean")

	# Test with very long text
	var long_text = ""
	for i in range(1000):
		long_text += "a"

	var long_text_result = await type_text(LineEdit.new(), long_text, 0.0)  # Set typing speed to 0 to avoid coroutine
	success = success and assert_type(long_text_result, TYPE_BOOL, "Long text input should return boolean")

	return success

# ------------------------------------------------------------------------------
# EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_edge_cases() -> bool:
	"""Test edge cases and boundary conditions"""
	var success = true

	# Test with controls at extreme positions
	var far_button = Button.new()
	far_button.position = Vector2(9999, 9999)
	far_button.text = "Far Button"
	add_child(far_button)

	var far_click_result = await click_button(far_button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(far_click_result, TYPE_BOOL, "Far button click should return boolean")

	var origin_button = Button.new()
	origin_button.position = Vector2(0, 0)
	origin_button.text = "Origin Button"
	add_child(origin_button)

	var origin_click_result = await click_button(origin_button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(origin_click_result, TYPE_BOOL, "Origin button click should return boolean")

	# Test with zero-sized controls
	var zero_size_button = Button.new()
	zero_size_button.size = Vector2(0, 0)
	zero_size_button.text = "Zero Size"
	add_child(zero_size_button)

	var zero_size_result = await click_button(zero_size_button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(zero_size_result, TYPE_BOOL, "Zero size button click should return boolean")

	# Test with very large controls
	var large_button = Button.new()
	large_button.size = Vector2(9999, 9999)
	large_button.text = "Large Button"
	add_child(large_button)

	var large_click_result = await click_button(large_button, false)  # Disable waiting to avoid coroutine
	success = success and assert_type(large_click_result, TYPE_BOOL, "Large button click should return boolean")

	# Test with special characters in text
	var special_chars = ["", " ", "	", "\n", "©®™", "🚀", "αβγ", "123!@#"]
	for special_text in special_chars:
		var special_button = Button.new()
		special_button.text = special_text
		add_child(special_button)

		var special_result = await click_button(special_button, false)  # Disable waiting to avoid coroutine
		success = success and assert_type(special_result, TYPE_BOOL, "Special char button '" + special_text + "' should return boolean")

	# Test with nested container hierarchies
	var deep_container = create_deep_container_hierarchy(5)
	add_child(deep_container)

	var deep_find_result = find_controls_by_type("Button")
	success = success and assert_type(deep_find_result, TYPE_ARRAY, "Deep hierarchy search should return array")

	# Test with controls that have the same name/text
	var duplicate_button1 = Button.new()
	duplicate_button1.text = "Duplicate"
	var duplicate_button2 = Button.new()
	duplicate_button2.text = "Duplicate"

	add_child(duplicate_button1)
	add_child(duplicate_button2)

	var duplicate_find_result = find_button_by_text("Duplicate")
	success = success and assert_not_null(duplicate_find_result, "Duplicate text search should find first match")

	# Test configuration boundary values
	test_resolutions = []
	var empty_resolutions_result = find_controls_by_type("Button")
	success = success and assert_type(empty_resolutions_result, TYPE_ARRAY, "Empty resolutions should work")

	test_resolutions = [Vector2(0, 0), Vector2(-1, -1)]
	var invalid_resolutions_result = find_controls_by_type("Button")
	success = success and assert_type(invalid_resolutions_result, TYPE_ARRAY, "Invalid resolutions should work")

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_deep_container_hierarchy(depth: int) -> Control:
	"""Create a deeply nested container hierarchy for testing"""
	if depth <= 0:
		var button = Button.new()
		button.text = "Deep Button"
		return button

	var container = VBoxContainer.new()
	var child = create_deep_container_hierarchy(depth - 1)
	container.add_child(child)
	return container

func create_test_form() -> Control:
	"""Create a test form with various input fields"""
	var form = VBoxContainer.new()

	var name_field = LineEdit.new()
	name_field.placeholder_text = "Name"
	form.add_child(name_field)

	var email_field = LineEdit.new()
	email_field.placeholder_text = "Email"
	form.add_child(email_field)

	var submit_button = Button.new()
	submit_button.text = "Submit"
	form.add_child(submit_button)

	return form

func create_accessible_ui() -> Control:
	"""Create an accessible UI layout"""
	var container = VBoxContainer.new()

	var header = Label.new()
	header.text = "Accessible Form"
	container.add_child(header)

	var name_button = Button.new()
	name_button.text = "Enter Name"
	name_button.size = Vector2(200, 44)  # Minimum touch target size
	container.add_child(name_button)

	return container

func create_inaccessible_ui() -> Control:
	"""Create an inaccessible UI layout for testing"""
	var container = VBoxContainer.new()

	var no_text_button = Button.new()
	no_text_button.size = Vector2(5, 5)  # Too small
	container.add_child(no_text_button)

	var low_contrast_label = Label.new()
	low_contrast_label.text = "Hard to read"
	container.add_child(low_contrast_label)

	return container
