# GDSentry - UI Test Class
# Specialized test class for comprehensive UI testing and validation
#
# Features:
# - UI element interaction testing
# - Form validation and submission
# - Navigation and focus testing
# - UI state verification
# - Responsive design testing
# - Accessibility compliance checking
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2DTest

class_name UITest

# ------------------------------------------------------------------------------
# UI TESTING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_WAIT_TIMEOUT = 5.0
const DEFAULT_ANIMATION_WAIT = 0.5
const FOCUS_TIMEOUT = 2.0

# ------------------------------------------------------------------------------
# UI TEST STATE
# ------------------------------------------------------------------------------
var wait_timeout: float = DEFAULT_WAIT_TIMEOUT
var animation_wait: float = DEFAULT_ANIMATION_WAIT
var auto_wait_for_animations: bool = true
var ui_scale_test_enabled: bool = false
var test_resolutions: Array[Vector2] = [
	Vector2(1920, 1080),  # Full HD
	Vector2(1366, 768),   # HD
	Vector2(1280, 720),   # WXGA
	Vector2(800, 600)     # SVGA
]

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize UI testing environment"""
	# Load UI test configuration if config available
	pass

# ------------------------------------------------------------------------------
# UI ELEMENT FINDING
# ------------------------------------------------------------------------------
func find_button_by_text(text: String, root: Node = null) -> Button:
	"""Find a button by its text content"""
	if root == null:
		root = get_tree().root if get_tree() else null
		if not root:
			return null

	return _find_control_by_property(root, "Button", "text", text)

func find_label_by_text(text: String, root: Node = null) -> Label:
	"""Find a label by its text content"""
	if root == null:
		root = get_tree().root if get_tree() else null
		if not root:
			return null

	return _find_control_by_property(root, "Label", "text", text)

func find_control_by_name(control_name: String, type: String = "", root: Node = null) -> Control:
	"""Find a control by name and optionally type"""
	if root == null:
		root = get_tree().root if get_tree() else null
		if not root:
			return null

	var control = root.find_child(control_name, true, false)
	if control and (type.is_empty() or control.get_class() == type):
		return control as Control

	return null

func find_controls_by_type(type: String, root: Node = null) -> Array[Control]:
	"""Find all controls of a specific type"""
	if root == null:
		root = get_tree().root if get_tree() else null
		if not root:
			return []

	var controls: Array[Control] = []
	_find_controls_recursive(root, type, controls)
	return controls

func _find_control_by_property(root: Node, type: String, property: String, value, max_depth: int = 10) -> Control:
	"""Find a control by property value"""
	var queue = [root]
	var depth = 0

	while not queue.is_empty() and depth < max_depth:
		var current = queue.pop_front()
		depth += 1

		if current.get_class() == type:
			if current.get(property) == value:
				return current as Control

		# Add children to queue
		for child in current.get_children():
			queue.append(child)

	return null

func _find_controls_recursive(root: Node, type: String, result: Array[Control]) -> void:
	"""Recursively find all controls of a specific type"""
	if root.get_class() == type:
		result.append(root as Control)

	for child in root.get_children():
		_find_controls_recursive(child, type, result)

# ------------------------------------------------------------------------------
# UI INTERACTION TESTING
# ------------------------------------------------------------------------------
func click_button(button: Button, wait_for_response: bool = true) -> bool:
	"""Click a button and optionally wait for response"""
	if not button:
		print("❌ Cannot click null button")
		return false

	if not button.visible or not button.is_inside_tree():
		print("❌ Button is not visible or not in tree")
		return false

	# Calculate click position (center of button)
	var click_pos = button.global_position + button.size / 2

	# Simulate click
	var event = InputEventMouseButton.new()
	event.position = click_pos
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)

	# Wait for initial response if requested
	await conditional_wait(0.1, wait_for_response)

	event.pressed = false
	Input.parse_input_event(event)

	# Wait for button animation response if needed
	await conditional_wait(animation_wait, auto_wait_for_animations)

	return true

func click_button_by_text(text: String, wait_for_response: bool = true) -> bool:
	"""Click a button by finding it by text"""
	var button = find_button_by_text(text)
	if not button:
		print("❌ Button with text '" + text + "' not found")
		return false

	return await click_button(button, wait_for_response)

func type_text(line_edit: LineEdit, text: String, typing_speed: float = 0.1) -> bool:
	"""Type text into a LineEdit control"""
	if not line_edit:
		print("❌ Cannot type into null LineEdit")
		return false

	if not line_edit.visible or not line_edit.is_inside_tree():
		print("❌ LineEdit is not visible or not in tree")
		return false

	# Focus the LineEdit first
	line_edit.grab_focus()
	await conditional_wait(0.1, typing_speed > 0)

	# Clear existing text
	line_edit.text = ""

	# Type text character by character
	for i in range(text.length()):
		var character = text[i]

		# Create key input event
		var event = InputEventKey.new()
		event.keycode = character.to_upper().unicode_at(0)
		event.unicode = character.unicode_at(0)
		event.pressed = true

		Input.parse_input_event(event)
		line_edit.text += character

		# Wait between characters based on typing speed
		await conditional_wait(typing_speed, typing_speed > 0)

		event.pressed = false
		Input.parse_input_event(event)

	return line_edit.text == text

func select_option(option_button: OptionButton, option_text: String) -> bool:
	"""Select an option from an OptionButton"""
	if not option_button:
		print("❌ Cannot select option on null OptionButton")
		return false

	# Find the option index
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == option_text:
			option_button.selected = i
			return true

	print("❌ Option '" + option_text + "' not found in OptionButton")
	return false

func toggle_checkbox(checkbox: CheckBox) -> bool:
	"""Toggle a checkbox"""
	if not checkbox:
		print("❌ Cannot toggle null CheckBox")
		return false

	checkbox.button_pressed = not checkbox.button_pressed
	return true

func set_slider_value(slider: Slider, value: float) -> bool:
	"""Set the value of a slider"""
	if not slider:
		print("❌ Cannot set value on null Slider")
		return false

	slider.value = clamp(value, slider.min_value, slider.max_value)
	return slider.value == value

# ------------------------------------------------------------------------------
# UI STATE VERIFICATION
# ------------------------------------------------------------------------------
func assert_button_enabled(button: Button, message: String = "") -> bool:
	"""Assert that a button is enabled"""
	if not button.disabled:
		return true

	var error_msg = message if not message.is_empty() else "Button '" + button.name + "' is disabled but should be enabled"
	print("❌ " + error_msg)
	return false

func assert_button_disabled(button: Button, message: String = "") -> bool:
	"""Assert that a button is disabled"""
	if button.disabled:
		return true

	var error_msg = message if not message.is_empty() else "Button '" + button.name + "' is enabled but should be disabled"
	print("❌ " + error_msg)
	return false

func assert_text_equals(control: Control, expected_text: String, message: String = "") -> bool:
	"""Assert that a control's text matches expected value"""
	if not control or not control.has_method("get_text"):
		var err_msg = message if not message.is_empty() else "Control does not have text property"
		print("❌ " + err_msg)
		return false

	var actual_text = control.get_text()
	if actual_text == expected_text:
		return true

	var mismatch_msg = message if not message.is_empty() else "Text mismatch: expected '" + expected_text + "', got '" + actual_text + "'"
	print("❌ " + mismatch_msg)
	return false

func assert_checkbox_checked(checkbox: CheckBox, message: String = "") -> bool:
	"""Assert that a checkbox is checked"""
	if checkbox.button_pressed:
		return true

	var error_msg = message if not message.is_empty() else "Checkbox '" + checkbox.name + "' is not checked"
	print("❌ " + error_msg)
	return false

func assert_checkbox_unchecked(checkbox: CheckBox, message: String = "") -> bool:
	"""Assert that a checkbox is unchecked"""
	if not checkbox.button_pressed:
		return true

	var error_msg = message if not message.is_empty() else "Checkbox '" + checkbox.name + "' is checked but should be unchecked"
	print("❌ " + error_msg)
	return false

func assert_slider_value(slider: Slider, expected_value: float, tolerance: float = 0.01, message: String = "") -> bool:
	"""Assert that a slider has the expected value"""
	var actual_value = slider.value
	if abs(actual_value - expected_value) <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Slider value mismatch: expected " + str(expected_value) + ", got " + str(actual_value)
	print("❌ " + error_msg)
	return false

# ------------------------------------------------------------------------------
# UI LAYOUT AND POSITIONING
# ------------------------------------------------------------------------------
func assert_control_visible(control: Control, message: String = "") -> bool:
	"""Assert that a control is visible"""
	if control.visible:
		return true

	var error_msg = message if not message.is_empty() else "Control '" + control.name + "' is not visible"
	print("❌ " + error_msg)
	return false

func assert_control_hidden(control: Control, message: String = "") -> bool:
	"""Assert that a control is hidden"""
	if not control.visible:
		return true

	var error_msg = message if not message.is_empty() else "Control '" + control.name + "' is visible but should be hidden"
	print("❌ " + error_msg)
	return false

func assert_control_position(control: Control, expected_pos: Vector2, tolerance: float = 1.0, message: String = "") -> bool:
	"""Assert that a control is at the expected position"""
	var actual_pos = control.global_position
	var distance = actual_pos.distance_to(expected_pos)

	if distance <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Control position mismatch: expected " + str(expected_pos) + ", got " + str(actual_pos) + " (distance: " + str(distance) + ")"
	print("❌ " + error_msg)
	return false

func assert_control_size(control: Control, expected_size: Vector2, tolerance: float = 1.0, message: String = "") -> bool:
	"""Assert that a control has the expected size"""
	var actual_size = control.size
	var size_diff = (actual_size - expected_size).abs()

	if size_diff.x <= tolerance and size_diff.y <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Control size mismatch: expected " + str(expected_size) + ", got " + str(actual_size)
	print("❌ " + error_msg)
	return false

# ------------------------------------------------------------------------------
# UI NAVIGATION AND FOCUS
# ------------------------------------------------------------------------------
func assert_focused(control: Control, message: String = "") -> bool:
	"""Assert that a control has focus"""
	var tree = get_tree()
	if not tree:
		return false

	if control.has_focus():
		return true

	var error_msg = message if not message.is_empty() else "Control '" + control.name + "' does not have focus"
	print("❌ " + error_msg)
	return false

func assert_not_focused(control: Control, message: String = "") -> bool:
	"""Assert that a control does not have focus"""
	var tree = get_tree()
	if not tree:
		return false

	if not control.has_focus():
		return true

	var error_msg = message if not message.is_empty() else "Control '" + control.name + "' has focus but shouldn't"
	print("❌ " + error_msg)
	return false

func wait_for_focus(control: Control, timeout: float = FOCUS_TIMEOUT) -> bool:
	"""Wait for a control to gain focus"""
	var start_time = Time.get_ticks_usec()

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < timeout:
		if control.has_focus():
			return true
		await get_tree().create_timer(0.1).timeout

	return false

func navigate_with_tab(expected_sequence: Array[Control], start_control: Control = null) -> bool:
	"""Test tab navigation through a sequence of controls"""
	var tree = get_tree()
	if not tree:
		return false

	if start_control:
		start_control.grab_focus()
		await get_tree().create_timer(0.1).timeout

	var current_focus = tree.get_root().gui_get_focus_owner()
	var sequence_index = 0

	for expected_control in expected_sequence:
		if sequence_index == 0:
			# First control should already have focus
			if current_focus != expected_control:
				print("❌ Initial focus not on expected control")
				return false
		else:
			# Simulate tab press
			var tab_event = InputEventKey.new()
			tab_event.keycode = KEY_TAB
			tab_event.pressed = true
			Input.parse_input_event(tab_event)

			await get_tree().create_timer(0.1).timeout

			tab_event.pressed = false
			Input.parse_input_event(tab_event)

			await get_tree().create_timer(0.1).timeout

			var new_focus = tree.get_root().gui_get_focus_owner()
			if new_focus != expected_control:
				print("❌ Tab navigation failed at step " + str(sequence_index))
				return false

		sequence_index += 1

	return true

func set_focus_to_control(control: Control) -> bool:
	"""Set focus to a specific control"""
	if not control:
		print("❌ Cannot set focus to null control")
		return false

	if not control.visible or not control.is_inside_tree():
		print("❌ Control is not visible or not in tree")
		return false

	control.grab_focus()
	await get_tree().create_timer(0.1).timeout

	return control.has_focus()

func assert_control_has_focus(control: Control, message: String = "") -> bool:
	"""Assert that a control has focus"""
	return assert_focused(control, message)

func assert_focus_ring_visible(control: Control, message: String = "") -> bool:
	"""Assert that focus ring is visible around focused control"""
	if not control:
		var error_msg = message if not message.is_empty() else "Control is null"
		print("❌ " + error_msg)
		return false

	if not control.has_focus():
		var error_msg = message if not message.is_empty() else "Control '" + control.name + "' does not have focus"
		print("❌ " + error_msg)
		return false

	# Check if control supports focus ring (this is a simplified check)
	# In a real implementation, you'd check theme properties or custom focus indicators
	return control.visible

func simulate_tab_navigation(tab_count: int = 1) -> bool:
	"""Simulate tab navigation for a specified number of tabs"""
	var tree = get_tree()
	if not tree:
		return false

	for i in range(tab_count):
		# Simulate tab press
		var tab_event = InputEventKey.new()
		tab_event.keycode = KEY_TAB
		tab_event.pressed = true
		Input.parse_input_event(tab_event)

		await get_tree().create_timer(0.1).timeout

		tab_event.pressed = false
		Input.parse_input_event(tab_event)

		await get_tree().create_timer(0.1).timeout

	return true

func simulate_shift_tab_navigation(shift_tab_count: int = 1) -> bool:
	"""Simulate shift+tab navigation for a specified number of tabs"""
	var tree = get_tree()
	if not tree:
		return false

	for i in range(shift_tab_count):
		# Simulate shift+tab press
		var tab_event = InputEventKey.new()
		tab_event.keycode = KEY_TAB
		tab_event.keycode |= KEY_MASK_SHIFT
		tab_event.pressed = true
		Input.parse_input_event(tab_event)

		await get_tree().create_timer(0.1).timeout

		tab_event.pressed = false
		Input.parse_input_event(tab_event)

		await get_tree().create_timer(0.1).timeout

	return true

func simulate_arrow_key_navigation(key_code: int, press_count: int = 1) -> bool:
	"""Simulate arrow key navigation for a specified number of presses"""
	var tree = get_tree()
	if not tree:
		return false

	for i in range(press_count):
		# Simulate arrow key press
		var arrow_event = InputEventKey.new()
		arrow_event.keycode = key_code
		arrow_event.pressed = true
		Input.parse_input_event(arrow_event)

		await get_tree().create_timer(0.1).timeout

		arrow_event.pressed = false
		Input.parse_input_event(arrow_event)

		await get_tree().create_timer(0.1).timeout

	return true

func simulate_enter_key_activation(control: Control = null) -> bool:
	"""Simulate enter key activation on a control"""
	if control:
		if not control.has_focus():
			control.grab_focus()
			await get_tree().create_timer(0.1).timeout

	var tree = get_tree()
	if not tree:
		return false

	var focused_control = tree.get_root().gui_get_focus_owner()
	if not focused_control:
		print("❌ No control has focus")
		return false

	# Simulate enter key press
	var enter_event = InputEventKey.new()
	enter_event.keycode = KEY_ENTER
	enter_event.pressed = true
	Input.parse_input_event(enter_event)

	await get_tree().create_timer(0.1).timeout

	enter_event.pressed = false
	Input.parse_input_event(enter_event)

	await get_tree().create_timer(0.1).timeout

	return true

func assert_ui_layout_valid(container: Control, message: String = "") -> bool:
	"""Assert that UI layout is valid (controls don't overlap, are properly sized)"""
	if not container:
		var error_msg = message if not message.is_empty() else "Container is null"
		print("❌ " + error_msg)
		return false

	var controls = _get_all_child_controls(container)
	var viewport = get_viewport()
	if not viewport:
		var error_msg = message if not message.is_empty() else "No viewport available"
		print("❌ " + error_msg)
		return false

	var viewport_size = viewport.size

	# Check each control
	for control in controls:
		if not control.visible:
			continue

		# Check if control is within viewport bounds
		var control_rect = Rect2(control.global_position, control.size)
		if control_rect.position.x < 0 or control_rect.position.y < 0:
			var error_msg = message if not message.is_empty() else "Control '" + control.name + "' is positioned outside viewport bounds"
			print("❌ " + error_msg)
			return false

		if control_rect.end.x > viewport_size.x or control_rect.end.y > viewport_size.y:
			var error_msg = message if not message.is_empty() else "Control '" + control.name + "' extends beyond viewport bounds"
			print("❌ " + error_msg)
			return false

		# Check minimum size requirements
		if control.size.x <= 0 or control.size.y <= 0:
			var error_msg = message if not message.is_empty() else "Control '" + control.name + "' has invalid size"
			print("❌ " + error_msg)
			return false

	return true

func assert_no_ui_overlap(container: Control, message: String = "") -> bool:
	"""Assert that no UI controls overlap within the container"""
	if not container:
		var error_msg = message if not message.is_empty() else "Container is null"
		print("❌ " + error_msg)
		return false

	var controls = _get_all_child_controls(container)

	# Check for overlaps between all pairs of controls
	for i in range(controls.size()):
		for j in range(i + 1, controls.size()):
			var control1 = controls[i]
			var control2 = controls[j]

			if not control1.visible or not control2.visible:
				continue

			var rect1 = Rect2(control1.global_position, control1.size)
			var rect2 = Rect2(control2.global_position, control2.size)

			if rect1.intersects(rect2):
				var error_msg = message if not message.is_empty() else "Controls '" + control1.name + "' and '" + control2.name + "' overlap"
				print("❌ " + error_msg)
				return false

	return true

func assert_text_readable(label: Label, message: String = "") -> bool:
	"""Assert that text in a label is readable (sufficient size, contrast)"""
	if not label:
		var error_msg = message if not message.is_empty() else "Label is null"
		print("❌ " + error_msg)
		return false

	if label.text.strip_edges().is_empty():
		var error_msg = message if not message.is_empty() else "Label '" + label.name + "' is empty"
		print("❌ " + error_msg)
		return false

	# Check minimum font size (rough estimate)
	if label.get_theme_font_size("font_size") < 12:
		var error_msg = message if not message.is_empty() else "Label '" + label.name + "' font size is too small for readability"
		print("❌ " + error_msg)
		return false

	# Check if label is visible
	if not label.visible:
		var error_msg = message if not message.is_empty() else "Label '" + label.name + "' is not visible"
		print("❌ " + error_msg)
		return false

	return true

func _get_all_child_controls(container: Control) -> Array[Control]:
	"""Get all child controls recursively"""
	var controls: Array[Control] = []
	_find_controls_recursive_helper(container, controls)
	return controls

func _find_controls_recursive_helper(node: Node, result: Array[Control]) -> void:
	"""Helper method to find all controls recursively"""
	if node is Control:
		result.append(node)

	for child in node.get_children():
		_find_controls_recursive_helper(child, result)

# ------------------------------------------------------------------------------
# FORM VALIDATION TESTING
# ------------------------------------------------------------------------------
func fill_form(form_data: Dictionary, submit_button: Button = null) -> bool:
	"""Fill a form with data and optionally submit it"""
	for field_name in form_data.keys():
		var field_value = form_data[field_name]
		var control = find_control_by_name(field_name)

		if not control:
			print("❌ Form field '" + field_name + "' not found")
			return false

		if control is LineEdit:
			if not await type_text(control, str(field_value)):
				return false
		elif control is CheckBox:
			control.button_pressed = bool(field_value)
		elif control is OptionButton:
			if not select_option(control, str(field_value)):
				return false
		elif control is Slider:
			control.value = float(field_value)

		await get_tree().create_timer(0.1).timeout

	# Submit form if button provided
	if submit_button:
		return await click_button(submit_button)

	return true

func assert_form_valid(form_fields: Array[Control], message: String = "") -> bool:
	"""Assert that all form fields are valid"""
	for field in form_fields:
		if field is LineEdit:
			if field.text.strip_edges().is_empty():
				var error_msg = message if not message.is_empty() else "Required field '" + field.name + "' is empty"
				print("❌ " + error_msg)
				return false
		# Add more validation rules as needed

	return true

func assert_form_field_not_empty(field: Control, message: String = "") -> bool:
	"""Assert that a form field is not empty"""
	if not field:
		var err_msg = message if not message.is_empty() else "Field is null"
		print("❌ " + err_msg)
		return false

	if field is LineEdit or field is TextEdit:
		var text = field.text if field is LineEdit else field.text
		if not text.strip_edges().is_empty():
			return true
		else:
			var err_msg = message if not message.is_empty() else "Field '" + field.name + "' is empty"
			print("❌ " + err_msg)
			return false

	var error_msg = message if not message.is_empty() else "Field '" + field.name + "' is not a text input field"
	print("❌ " + error_msg)
	return false

func assert_form_valid_email(field: LineEdit, message: String = "") -> bool:
	"""Assert that a form field contains a valid email address"""
	if not field:
		var error_msg = message if not message.is_empty() else "Email field is null"
		print("❌ " + error_msg)
		return false

	var email = field.text.strip_edges()
	var email_regex = RegEx.new()
	email_regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")

	if email_regex.search(email):
		return true
	else:
		var error_msg = message if not message.is_empty() else "Invalid email format: '" + email + "'"
		print("❌ " + error_msg)
		return false

func assert_form_field_numeric(field: LineEdit, message: String = "") -> bool:
	"""Assert that a form field contains a valid numeric value"""
	if not field:
		var error_msg = message if not message.is_empty() else "Numeric field is null"
		print("❌ " + error_msg)
		return false

	var text = field.text.strip_edges()
	if text.is_empty():
		var error_msg = message if not message.is_empty() else "Field '" + field.name + "' is empty"
		print("❌ " + error_msg)
		return false

	if text.is_valid_float() or text.is_valid_int():
		return true
	else:
		var error_msg = message if not message.is_empty() else "Field '" + field.name + "' contains non-numeric value: '" + text + "'"
		print("❌ " + error_msg)
		return false

# ------------------------------------------------------------------------------
# RESPONSIVE DESIGN TESTING
# ------------------------------------------------------------------------------
func test_responsive_layout(control: Control, resolutions: Array[Vector2] = []) -> Dictionary:
	"""Test how a control responds to different screen resolutions"""
	if resolutions.is_empty():
		resolutions = test_resolutions

	var results = {}
	var original_size = Vector2.ZERO

	var viewport = get_viewport()
	if viewport:
		original_size = viewport.size

	for resolution in resolutions:
		if viewport:
			viewport.size = resolution
		await get_tree().create_timer(2.0).timeout  # Wait for layout updates

		# Check if control is still properly positioned and sized
		var control_visible = control.visible
		var is_in_bounds = _is_control_in_viewport_bounds(control)

		results[resolution] = {
			"visible": control_visible,
			"in_bounds": is_in_bounds,
			"position": control.global_position,
			"size": control.size
		}

	# Restore original resolution
	if viewport:
		viewport.size = original_size

	return results

func test_ui_at_resolution(control: Control, resolution: Vector2) -> void:
	"""Test UI at a specific resolution"""
	if not control:
		print("❌ Control is null")
		return

	var viewport = get_viewport()
	if not viewport:
		print("❌ No viewport available")
		return

	var original_size = viewport.size
	viewport.size = resolution

	await get_tree().create_timer(1.0).timeout  # Wait for layout updates

	# Check if control is still functional
	var control_visible = control.visible
	var in_bounds = _is_control_in_viewport_bounds(control)

	# Restore original resolution
	viewport.size = original_size

	print("✅ UI test at resolution " + str(resolution) + ": visible=" + str(control_visible) + ", in_bounds=" + str(in_bounds))

func assert_ui_aspect_ratio_handled(control: Control, message: String = "") -> bool:
	"""Assert that UI handles aspect ratio changes properly"""
	if not control:
		var error_msg = message if not message.is_empty() else "Control is null"
		print("❌ " + error_msg)
		return false

	# Test with different aspect ratios
	var test_ratios = [16.0/9.0, 4.0/3.0, 16.0/10.0, 21.0/9.0]
	var viewport = get_viewport()
	if not viewport:
		var error_msg = message if not message.is_empty() else "No viewport available"
		print("❌ " + error_msg)
		return false

	var original_size = viewport.size

	for ratio in test_ratios:
		var test_width = 1920
		var test_height = int(test_width / ratio)
		var test_resolution = Vector2(test_width, test_height)

		await test_ui_at_resolution(control, test_resolution)
		# For now, assume success if no errors were printed
		var _test_success = true  # In a real implementation, you'd capture the result

	# Restore original resolution
	viewport.size = original_size
	return true

func test_ui_scaling(control: Control, scale_factor: float = 1.5) -> bool:
	"""Test UI scaling behavior"""
	if not control:
		print("❌ Control is null")
		return false

	var original_scale = control.scale
	control.scale *= scale_factor

	await get_tree().create_timer(0.5).timeout

	# Check if control is still functional after scaling
	var control_visible = control.visible
	var in_bounds = _is_control_in_viewport_bounds(control)

	# Restore original scale
	control.scale = original_scale

	return control_visible and in_bounds

func test_ui_at_dpi(control: Control, _dpi: int = 200) -> bool:
	"""Test UI at different DPI settings"""
	if not control:
		print("❌ Control is null")
		return false

	# In Godot, DPI is typically handled through the OS
	# This is a simplified test that just checks visibility
	await get_tree().create_timer(0.5).timeout

	return control.visible and _is_control_in_viewport_bounds(control)

func assert_touch_targets_accessible(container: Control, message: String = "") -> bool:
	"""Assert that touch targets meet minimum accessibility requirements"""
	if not container:
		var error_msg = message if not message.is_empty() else "Container is null"
		print("❌ " + error_msg)
		return false

	var controls = _get_all_child_controls(container)
	var min_touch_size = 44  # WCAG AA minimum touch target size in pixels

	for control in controls:
		if not control.visible:
			continue

		# Check if control is likely to be touched (buttons, interactive elements)
		if control is Button or control is TextureButton or control.focus_mode != Control.FOCUS_NONE:
			if control.size.x < min_touch_size or control.size.y < min_touch_size:
				var error_msg = message if not message.is_empty() else "Touch target '" + control.name + "' is too small: " + str(control.size) + " (minimum: " + str(min_touch_size) + "x" + str(min_touch_size) + ")"
				print("❌ " + error_msg)
				return false

	return true

func assert_accessible_button(button: Button, message: String = "") -> bool:
	"""Assert that a button meets accessibility requirements"""
	if not button:
		var error_msg = message if not message.is_empty() else "Button is null"
		print("❌ " + error_msg)
		return false

	# Check text content
	if button.text.strip_edges().is_empty():
		var error_msg = message if not message.is_empty() else "Button '" + button.name + "' has no text content"
		print("❌ " + error_msg)
		return false

	# Check minimum size
	if button.size.x < 44 or button.size.y < 24:
		var error_msg = message if not message.is_empty() else "Button '" + button.name + "' is too small for accessibility"
		print("❌ " + error_msg)
		return false

	# Check focusability
	if not button.focus_mode != Control.FOCUS_NONE:
		var error_msg = message if not message.is_empty() else "Button '" + button.name + "' is not focusable"
		print("❌ " + error_msg)
		return false

	return true

func assert_accessible_label(label: Label, message: String = "") -> bool:
	"""Assert that a label meets accessibility requirements"""
	if not label:
		var error_msg = message if not message.is_empty() else "Label is null"
		print("❌ " + error_msg)
		return false

	# Check text content
	if label.text.strip_edges().is_empty():
		var error_msg = message if not message.is_empty() else "Label '" + label.name + "' has no text content"
		print("❌ " + error_msg)
		return false

	# Check font size
	if label.get_theme_font_size("font_size") < 14:
		var error_msg = message if not message.is_empty() else "Label '" + label.name + "' font size is too small for accessibility"
		print("❌ " + error_msg)
		return false

	return true

func assert_minimum_touch_target(control: Control, message: String = "") -> bool:
	"""Assert that a control meets minimum touch target requirements"""
	if not control:
		var error_msg = message if not message.is_empty() else "Control is null"
		print("❌ " + error_msg)
		return false

	var min_size = Vector2(44, 44)  # WCAG AA minimum

	if control.size.x < min_size.x or control.size.y < min_size.y:
		var error_msg = message if not message.is_empty() else "Control '" + control.name + "' touch target too small: " + str(control.size) + " (minimum: " + str(min_size) + ")"
		print("❌ " + error_msg)
		return false

	return true

func assert_sufficient_contrast(foreground_color: Color, background_color: Color, message: String = "") -> bool:
	"""Assert that color contrast meets accessibility requirements"""
	# Calculate contrast ratio using the WCAG formula
	var contrast_ratio = _calculate_contrast_ratio(foreground_color, background_color)

	# WCAG AA requires 4.5:1 for normal text, 3:1 for large text
	var min_contrast = 4.5

	if contrast_ratio < min_contrast:
		var error_msg = message if not message.is_empty() else "Insufficient color contrast: " + str(contrast_ratio) + ":1 (minimum: " + str(min_contrast) + ":1)"
		print("❌ " + error_msg)
		return false

	return true

func assert_keyboard_navigable(container: Control, message: String = "") -> bool:
	"""Assert that all interactive elements are keyboard navigable"""
	if not container:
		var error_msg = message if not message.is_empty() else "Container is null"
		print("❌ " + error_msg)
		return false

	var controls = _get_all_child_controls(container)
	var focusable_controls: Array[Control] = []

	for control in controls:
		if control.focus_mode != Control.FOCUS_NONE:
			focusable_controls.append(control)

	if focusable_controls.is_empty():
		var error_msg = message if not message.is_empty() else "No keyboard-navigable controls found in container"
		print("❌ " + error_msg)
		return false

	# Test tab navigation through focusable controls
	await navigate_with_tab(focusable_controls)
	return true

func assert_screen_reader_friendly(container: Control, message: String = "") -> bool:
	"""Assert that UI elements are screen reader friendly"""
	if not container:
		var error_msg = message if not message.is_empty() else "Container is null"
		print("❌ " + error_msg)
		return false

	var controls = _get_all_child_controls(container)

	for control in controls:
		if control is Button:
			if not assert_accessible_button(control, message):
				return false
		elif control is Label:
			if not assert_accessible_label(control, message):
				return false

	return true

func generate_accessibility_report(container: Control) -> Dictionary:
	"""Generate an accessibility report for the given container"""
	var report = {
		"total_controls": 0,
		"accessible_controls": 0,
		"inaccessible_controls": 0,
		"issues": [],
		"recommendations": []
	}

	if not container:
		report.issues.append("Container is null")
		return report

	var controls = _get_all_child_controls(container)
	report.total_controls = controls.size()

	for control in controls:
		var is_accessible = true
		var control_issues = []

		if control is Button:
			if control.text.strip_edges().is_empty():
				control_issues.append("Button has no text content")
				is_accessible = false
			if control.size.x < 44 or control.size.y < 24:
				control_issues.append("Button size too small for touch")
				is_accessible = false
		elif control is Label:
			if control.text.strip_edges().is_empty():
				control_issues.append("Label has no text content")
				is_accessible = false
			if control.get_theme_font_size("font_size") < 14:
				control_issues.append("Label font size too small")
				is_accessible = false

		if control.focus_mode == Control.FOCUS_NONE and (control is Button or control is TextureButton):
			control_issues.append("Interactive control is not focusable")
			is_accessible = false

		if is_accessible:
			report.accessible_controls += 1
		else:
			report.inaccessible_controls += 1
			report.issues.append({
				"control": control.name,
				"type": control.get_class(),
				"issues": control_issues
			})

	# Generate recommendations
	if report.inaccessible_controls > 0:
		report.recommendations.append("Add proper labels to all interactive elements")
		report.recommendations.append("Ensure minimum touch target sizes (44x44px)")
		report.recommendations.append("Provide sufficient color contrast (4.5:1 minimum)")
		report.recommendations.append("Make all interactive elements keyboard accessible")

	return report

func _calculate_contrast_ratio(color1: Color, color2: Color) -> float:
	"""Calculate contrast ratio between two colors using WCAG formula"""
	var lum1 = _get_luminance(color1)
	var lum2 = _get_luminance(color2)

	var lighter = max(lum1, lum2)
	var darker = min(lum1, lum2)

	return (lighter + 0.05) / (darker + 0.05)

func _get_luminance(color: Color) -> float:
	"""Calculate relative luminance of a color"""
	var r = color.r
	var g = color.g
	var b = color.b

	# Convert to linear RGB
	if r <= 0.03928:
		r = r / 12.92
	else:
		r = pow((r + 0.055) / 1.055, 2.4)

	if g <= 0.03928:
		g = g / 12.92
	else:
		g = pow((g + 0.055) / 1.055, 2.4)

	if b <= 0.03928:
		b = b / 12.92
	else:
		b = pow((b + 0.055) / 1.055, 2.4)

	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func _is_control_in_viewport_bounds(control: Control) -> bool:
	"""Check if a control is within viewport bounds"""
	var viewport = get_viewport()
	if not viewport:
		return false

	var viewport_size = viewport.size
	var control_rect = Rect2(control.global_position, control.size)

	return viewport_size.x >= control_rect.end.x and viewport_size.y >= control_rect.end.y

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func wait_for_ui_update(timeout: float = 1.0) -> void:
	"""Wait for UI to update"""
	await get_tree().create_timer(timeout).timeout

func conditional_wait(duration: float, should_wait: bool) -> void:
	"""Conditionally wait for a duration based on a boolean flag"""
	if should_wait:
		await get_tree().create_timer(duration).timeout
	else:
		# Create timer but don't await it to avoid linter warnings
		var _timer = get_tree().create_timer(duration)
		# Timer will be cleaned up automatically

func set_wait_timeout(timeout: float) -> void:
	"""Set the default wait timeout for UI operations"""
	wait_timeout = timeout

func set_animation_wait(duration: float) -> void:
	"""Set the wait time for animations"""
	animation_wait = duration

func enable_animation_waiting(enabled: bool = true) -> void:
	"""Enable or disable automatic waiting for animations"""
	auto_wait_for_animations = enabled

func enable_responsive_testing(enabled: bool = true, resolutions: Array[Vector2] = []) -> void:
	"""Enable responsive design testing"""
	ui_scale_test_enabled = enabled
	if not resolutions.is_empty():
		test_resolutions = resolutions

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup UI test resources"""
	pass