# GDSentry - Event Test Class
# Specialized test class for simulating user interactions and event testing
#
# Features:
# - Mouse event simulation (click, drag, hover)
# - Keyboard input simulation
# - Touch/gesture simulation
# - Event sequence recording and playback
# - Input validation and timing
# - Multi-touch support
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2DTest

class_name EventTest

# GDTestConfig is available as a global class

# ------------------------------------------------------------------------------
# EVENT TESTING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_CLICK_DELAY = 0.1
const DEFAULT_KEY_PRESS_DURATION = 0.05
const DEFAULT_DRAG_SPEED = 500.0
const DOUBLE_CLICK_TIME = 0.3

# ------------------------------------------------------------------------------
# EVENT SIMULATION STATE
# ------------------------------------------------------------------------------
var config: GDTestConfig
var input_delay: float = DEFAULT_CLICK_DELAY
var key_press_duration: float = DEFAULT_KEY_PRESS_DURATION
var drag_speed: float = DEFAULT_DRAG_SPEED
var simulate_real_timing: bool = true
var record_events: bool = false
var recorded_events: Array = []

# ------------------------------------------------------------------------------
# INPUT EVENT HISTORY
# ------------------------------------------------------------------------------
var input_history: Array = []
var max_history_size: int = 100

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize event testing environment"""
	super._ready()

	# Initialize test configuration
	config = GDTestConfig.load_from_file()

	# Load event test configuration
	load_event_config()

	# Set up input processing
	set_process_input(true)

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
func load_event_config() -> void:
	"""Load event testing configuration"""
	if config and config.ui_settings:
		input_delay = config.ui_settings.get("input_delay", DEFAULT_CLICK_DELAY)

# ------------------------------------------------------------------------------
# MOUSE EVENT SIMULATION
# ------------------------------------------------------------------------------
func simulate_mouse_click(click_position: Vector2, button: int = MOUSE_BUTTON_LEFT, modifiers: Array[int] = []) -> void:
	"""Simulate a mouse click at the specified position"""
	var event = InputEventMouseButton.new()
	event.position = click_position
	event.button_index = button
	event.pressed = true

	# Apply modifiers (Ctrl, Shift, Alt)
	for modifier in modifiers:
		match modifier:
			KEY_CTRL:
				event.ctrl_pressed = true
			KEY_SHIFT:
				event.shift_pressed = true
			KEY_ALT:
				event.alt_pressed = true

	# Send press event
	Input.parse_input_event(event)
	record_event(event)

	# Wait for input delay
	if simulate_real_timing:
		await wait_for_seconds(input_delay)

	# Send release event
	event.pressed = false
	Input.parse_input_event(event)
	record_event(event)

func simulate_mouse_double_click(click_position: Vector2, button: int = MOUSE_BUTTON_LEFT) -> void:
	"""Simulate a mouse double-click"""
	simulate_mouse_click(click_position, button)
	await wait_for_seconds(DOUBLE_CLICK_TIME)
	simulate_mouse_click(click_position, button)

func simulate_mouse_drag(start_pos: Vector2, end_pos: Vector2, button: int = MOUSE_BUTTON_LEFT, duration: float = 0.5) -> void:
	"""Simulate dragging from start position to end position"""
	var event = InputEventMouseButton.new()
	event.position = start_pos
	event.button_index = button
	event.pressed = true

	# Send initial press
	Input.parse_input_event(event)
	record_event(event)

	# Calculate drag path
	var distance = start_pos.distance_to(end_pos)
	var steps = max(5, int(distance / 20))  # Minimum 5 steps, more for longer drags
	var step_duration = duration / steps

	for i in range(steps + 1):
		var t = float(i) / steps
		var current_pos = start_pos.lerp(end_pos, t)

		var move_event = InputEventMouseMotion.new()
		move_event.position = current_pos
		move_event.relative = (end_pos - start_pos) / steps if i == 0 else (current_pos - start_pos.lerp(end_pos, float(i-1) / steps))

		if i == 0:
			move_event.button_mask |= 1 << (button - 1)  # Set button mask for drag

		Input.parse_input_event(move_event)
		record_event(move_event)

		if simulate_real_timing and i < steps:
			await wait_for_seconds(step_duration)

	# Send release event
	event.pressed = false
	event.position = end_pos
	Input.parse_input_event(event)
	record_event(event)

func simulate_mouse_hover(hover_position: Vector2, duration: float = 1.0) -> void:
	"""Simulate mouse hovering at a position"""
	var event = InputEventMouseMotion.new()
	event.position = hover_position
	event.relative = Vector2.ZERO

	Input.parse_input_event(event)
	record_event(event)

	if simulate_real_timing:
		await wait_for_seconds(duration)

func simulate_mouse_wheel(wheel_position: Vector2, delta: Vector2) -> void:
	"""Simulate mouse wheel scrolling"""
	var event = InputEventMouseButton.new()
	event.position = wheel_position

	if delta.y > 0:
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
	elif delta.y < 0:
		event.button_index = MOUSE_BUTTON_WHEEL_UP
	elif delta.x > 0:
		event.button_index = MOUSE_BUTTON_WHEEL_RIGHT
	elif delta.x < 0:
		event.button_index = MOUSE_BUTTON_WHEEL_LEFT

	event.pressed = true
	Input.parse_input_event(event)
	record_event(event)

	if simulate_real_timing:
		await wait_for_seconds(input_delay)

	event.pressed = false
	Input.parse_input_event(event)
	record_event(event)

# ------------------------------------------------------------------------------
# KEYBOARD EVENT SIMULATION
# ------------------------------------------------------------------------------
func simulate_key_press(key: int, modifiers: Array[int] = []) -> void:
	"""Simulate pressing a key"""
	var event = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	event.echo = false

	# Apply modifiers
	for modifier in modifiers:
		match modifier:
			KEY_CTRL:
				event.ctrl_pressed = true
			KEY_SHIFT:
				event.shift_pressed = true
			KEY_ALT:
				event.alt_pressed = true
			KEY_META:
				event.meta_pressed = true

	Input.parse_input_event(event)
	record_event(event)

	if simulate_real_timing:
		await wait_for_seconds(key_press_duration)

	event.pressed = false
	event.echo = false
	Input.parse_input_event(event)
	record_event(event)

func simulate_key_sequence(keys: Array, delay_between_keys: float = 0.05) -> void:
	"""Simulate pressing a sequence of keys"""
	for key in keys:
		if key is int:
			simulate_key_press(key)
		elif key is Array and key.size() >= 2:
			# Handle key with modifiers: [key, [modifiers]]
			simulate_key_press(key[0], key[1] if key.size() > 1 else [])

		if simulate_real_timing:
			await wait_for_seconds(delay_between_keys)

func simulate_text_input(text: String, typing_speed: float = 0.1) -> void:
	"""Simulate typing text character by character"""
	for i in range(text.length()):
		var character = text[i]

		# Create text input event
		var event = InputEventKey.new()
		event.keycode = character.to_upper().unicode_at(0)
		event.unicode = character.unicode_at(0)
		event.pressed = true

		Input.parse_input_event(event)
		record_event(event)

		if simulate_real_timing:
			await wait_for_seconds(typing_speed)

		event.pressed = false
		Input.parse_input_event(event)
		record_event(event)

# ------------------------------------------------------------------------------
# TOUCH/GESTURE SIMULATION
# ------------------------------------------------------------------------------
func simulate_touch_press(index: int, touch_position: Vector2) -> void:
	"""Simulate touch press"""
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = touch_position
	event.pressed = true

	Input.parse_input_event(event)
	record_event(event)

func simulate_touch_release(index: int, release_position: Vector2) -> void:
	"""Simulate touch release"""
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = release_position
	event.pressed = false

	Input.parse_input_event(event)
	record_event(event)

func simulate_touch_drag(index: int, start_pos: Vector2, end_pos: Vector2, duration: float = 0.5) -> void:
	"""Simulate touch drag gesture"""
	simulate_touch_press(index, start_pos)

	var distance = start_pos.distance_to(end_pos)
	var steps = max(5, int(distance / 30))
	var step_duration = duration / steps

	for i in range(steps + 1):
		var t = float(i) / steps
		var current_pos = start_pos.lerp(end_pos, t)

		var drag_event = InputEventScreenDrag.new()
		drag_event.index = index
		drag_event.position = current_pos
		drag_event.relative = (end_pos - start_pos) / steps if i == 0 else (current_pos - start_pos.lerp(end_pos, float(i-1) / steps))

		Input.parse_input_event(drag_event)
		record_event(drag_event)

		if simulate_real_timing and i < steps:
			await wait_for_seconds(step_duration)

	simulate_touch_release(index, end_pos)

func simulate_pinch_gesture(center: Vector2, start_distance: float, end_distance: float, duration: float = 1.0) -> void:
	"""Simulate a pinch gesture (zoom in/out)"""
	var steps = max(10, int(duration * 30))  # 30 FPS equivalent
	var step_duration = duration / steps

	for i in range(steps + 1):
		var t = float(i) / steps
		var current_distance = lerpf(start_distance, end_distance, t)

		# Calculate touch positions for pinch
		var angle1 = 0
		var angle2 = PI
		var pos1 = center + Vector2(cos(angle1), sin(angle1)) * (current_distance / 2)
		var pos2 = center + Vector2(cos(angle2), sin(angle2)) * (current_distance / 2)

		if i == 0:
			# Start pinch
			simulate_touch_press(0, pos1)
			simulate_touch_press(1, pos2)
		else:
			# Continue pinch
			var drag1 = InputEventScreenDrag.new()
			drag1.index = 0
			drag1.position = pos1
			Input.parse_input_event(drag1)

			var drag2 = InputEventScreenDrag.new()
			drag2.index = 1
			drag2.position = pos2
			Input.parse_input_event(drag2)

		if simulate_real_timing and i < steps:
			await wait_for_seconds(step_duration)

	# End pinch
	simulate_touch_release(0, center + Vector2(cos(0), sin(0)) * (end_distance / 2))
	simulate_touch_release(1, center + Vector2(cos(PI), sin(PI)) * (end_distance / 2))

# ------------------------------------------------------------------------------
# EVENT RECORDING AND PLAYBACK
# ------------------------------------------------------------------------------
func record_event(event: InputEvent) -> void:
	"""Record an input event for later analysis or playback"""
	if not record_events:
		return

	var event_data = {
		"type": event.get_class(),
		"time": Time.get_ticks_usec(),
		"data": {}
	}

	# Extract relevant event data
	if event is InputEventMouseButton:
		event_data.data = {
			"position": event.position,
			"button_index": event.button_index,
			"pressed": event.pressed,
			"modifiers": {
				"ctrl": event.ctrl_pressed,
				"shift": event.shift_pressed,
				"alt": event.alt_pressed
			}
		}
	elif event is InputEventKey:
		event_data.data = {
			"keycode": event.keycode,
			"pressed": event.pressed,
			"modifiers": {
				"ctrl": event.ctrl_pressed,
				"shift": event.shift_pressed,
				"alt": event.alt_pressed
			}
		}

	recorded_events.append(event_data)

func start_recording() -> void:
	"""Start recording input events"""
	record_events = true
	recorded_events.clear()

func stop_recording() -> void:
	"""Stop recording input events"""
	record_events = false

func get_recorded_events() -> Array:
	"""Get all recorded events"""
	return recorded_events.duplicate()

func save_recorded_events(filename: String) -> bool:
	"""Save recorded events to a file"""
	var file = FileAccess.open("res://test_recordings/" + filename + ".json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(recorded_events, "\t"))
		file.close()
		return true
	return false

func load_recorded_events(filename: String) -> Array:
	"""Load recorded events from a file"""
	var file = FileAccess.open("res://test_recordings/" + filename + ".json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed is Array:
			return parsed
	return []

func playback_recorded_events(events: Array, speed_multiplier: float = 1.0) -> void:
	"""Playback recorded events"""
	if events.is_empty():
		return

	var start_time = events[0].time if events[0].has("time") else Time.get_ticks_usec()

	for event_data in events:
		if event_data.has("time"):
			var delay = (event_data.time - start_time) / 1000000.0 / speed_multiplier
			if delay > 0:
				await wait_for_seconds(delay)

		# Recreate and send event
		var event = create_event_from_data(event_data)
		if event:
			Input.parse_input_event(event)

func create_event_from_data(event_data: Dictionary) -> InputEvent:
	"""Create an InputEvent from recorded data"""
	match event_data.get("type", ""):
		"InputEventMouseButton":
			var event = InputEventMouseButton.new()
			var data = event_data.get("data", {})
			event.position = data.get("position", Vector2.ZERO)
			event.button_index = data.get("button_index", MOUSE_BUTTON_LEFT)
			event.pressed = data.get("pressed", false)

			var modifiers = data.get("modifiers", {})
			event.ctrl_pressed = modifiers.get("ctrl", false)
			event.shift_pressed = modifiers.get("shift", false)
			event.alt_pressed = modifiers.get("alt", false)
			return event

		"InputEventKey":
			var event = InputEventKey.new()
			var data = event_data.get("data", {})
			event.keycode = data.get("keycode", 0)
			event.pressed = data.get("pressed", false)

			var modifiers = data.get("modifiers", {})
			event.ctrl_pressed = modifiers.get("ctrl", false)
			event.shift_pressed = modifiers.get("shift", false)
			event.alt_pressed = modifiers.get("alt", false)
			return event

	return null

# ------------------------------------------------------------------------------
# EVENT SEQUENCE TESTING
# ------------------------------------------------------------------------------
func simulate_event_sequence(sequence: Array, delays: Array = []) -> void:
	"""Simulate a sequence of events with optional delays"""
	for i in range(sequence.size()):
		var event_func = sequence[i]

		# Call the event function (should be a callable)
		if event_func is Callable:
			event_func.call()

		# Wait for specified delay
		if i < delays.size() and delays[i] > 0:
			await wait_for_seconds(delays[i])
		elif simulate_real_timing:
			await wait_for_seconds(input_delay)

func assert_event_received(expected_event_type: String, timeout: float = 1.0, message: String = "") -> bool:
	"""Assert that a specific type of event was received within timeout"""
	var start_time = Time.get_ticks_usec()

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < timeout:
		await wait_for_seconds(0.01)

		# Check input history for the event
		for event_data in input_history:
			if event_data.type == expected_event_type:
				return true

	var error_msg = message if not message.is_empty() else "Expected event '%s' was not received within %.2fs" % [expected_event_type, timeout]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# INPUT VALIDATION ASSERTIONS
# ------------------------------------------------------------------------------
func assert_input_focused(control: Control, message: String = "") -> bool:
	"""Assert that a control has input focus"""
	if not control.has_focus():
		var error_msg = message if not message.is_empty() else "Control '%s' does not have input focus" % control.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_input_not_focused(control: Control, message: String = "") -> bool:
	"""Assert that a control does not have input focus"""
	if control.has_focus():
		var error_msg = message if not message.is_empty() else "Control '%s' has input focus when it shouldn't" % control.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func wait_for_input_idle(duration: float = 0.1) -> void:
	"""Wait for input system to become idle"""
	await wait_for_seconds(duration)

func clear_input_history() -> void:
	"""Clear the input event history"""
	input_history.clear()

func set_input_delay(delay: float) -> void:
	"""Set the delay between simulated input events"""
	input_delay = max(0.01, delay)

func set_key_press_duration(duration: float) -> void:
	"""Set the duration for key press simulation"""
	key_press_duration = max(0.01, duration)

func enable_real_timing(enabled: bool = true) -> void:
	"""Enable or disable real timing simulation"""
	simulate_real_timing = enabled

func wait_for_seconds(seconds: float) -> void:
	"""Wait for a specified number of seconds"""
	await get_tree().create_timer(seconds).timeout

# ------------------------------------------------------------------------------
# INPUT PROCESSING
# ------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	"""Capture input events for analysis"""
	if record_events:
		record_event(event)

	# Add to history (with size limit)
	input_history.append({
		"type": event.get_class(),
		"time": Time.get_ticks_usec(),
		"event": event
	})

	if input_history.size() > max_history_size:
		input_history.remove_at(0)

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup event test resources"""
	stop_recording()
	clear_input_history()
	super._exit_tree()
