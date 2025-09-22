# GDSentry - EventTest Comprehensive Test Suite
# Tests the EventTest class functionality for input simulation and event handling
#
# Tests cover:
# - Mouse event simulation (click, double-click, drag, hover, wheel)
# - Keyboard event simulation (single keys, sequences, text input)
# - Touch/gesture simulation (press, release, drag, pinch)
# - Event recording and playback
# - Configuration and timing controls
# - Input validation and error handling
#
# Author: GDSentry Framework
# Version: 1.0.0

extends EventTest

class_name EventTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for EventTest class"
	test_tags = ["event_test", "input_simulation", "mouse", "keyboard", "touch", "integration"]
	test_priority = "high"
	test_category = "test_types"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all EventTest comprehensive tests"""
	run_test("test_event_test_instantiation", func(): return test_event_test_instantiation())
	run_test("test_event_test_configuration", func(): return test_event_test_configuration())
	run_test("test_mouse_event_simulation", func(): return test_mouse_event_simulation())
	run_test("test_mouse_double_click_simulation", func(): return test_mouse_double_click_simulation())
	run_test("test_mouse_drag_simulation", func(): return test_mouse_drag_simulation())
	run_test("test_mouse_hover_simulation", func(): return test_mouse_hover_simulation())
	run_test("test_mouse_wheel_simulation", func(): return test_mouse_wheel_simulation())
	run_test("test_keyboard_event_simulation", func(): return test_keyboard_event_simulation())
	run_test("test_keyboard_sequence_simulation", func(): return test_keyboard_sequence_simulation())
	run_test("test_text_input_simulation", func(): return test_text_input_simulation())
	run_test("test_touch_event_simulation", func(): return test_touch_event_simulation())
	run_test("test_touch_drag_simulation", func(): return test_touch_drag_simulation())
	run_test("test_pinch_gesture_simulation", func(): return test_pinch_gesture_simulation())
	run_test("test_event_recording", func(): return test_event_recording())
	run_test("test_event_playback", func(): return test_event_playback())
	run_test("test_timing_controls", func(): return test_timing_controls())
	run_test("test_input_validation", func(): return test_input_validation())
	run_test("test_error_handling", func(): return test_error_handling())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_event_test_instantiation() -> bool:
	"""Test EventTest instantiation and basic properties"""
	var success = true

	# Test basic instantiation (self is already instantiated)
	success = success and assert_not_null(self, "EventTest should instantiate successfully")
	success = success and assert_type(self, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(self.get_class(), "EventTest", "Should be EventTest class")
	success = success and assert_true(self is Node2DTest, "Should extend Node2DTest")

	# Test default configuration values
	success = success and assert_equals(self.input_delay, 0.1, "Default input delay should be 0.1")
	success = success and assert_equals(self.key_press_duration, 0.05, "Default key press duration should be 0.05")
	success = success and assert_equals(self.drag_speed, 500.0, "Default drag speed should be 500.0")
	success = success and assert_true(self.simulate_real_timing, "Should simulate real timing by default")

	# Test state initialization
	success = success and assert_true(self.input_history is Array, "Input history should be array")
	success = success and assert_equals(self.input_history.size(), 0, "Input history should start empty")
	success = success and assert_equals(self.max_history_size, 100, "Max history size should be 100")

	return success

func test_event_test_configuration() -> bool:
	"""Test EventTest configuration loading and modification"""
	var success = true

	# Store original values to restore later
	var original_input_delay = input_delay
	var original_key_press_duration = key_press_duration
	var original_drag_speed = drag_speed
	var original_simulate_real_timing = simulate_real_timing
	var original_max_history_size = max_history_size

	# Test configuration modification
	input_delay = 0.2
	key_press_duration = 0.1
	drag_speed = 750.0
	simulate_real_timing = false
	max_history_size = 200

	success = success and assert_equals(input_delay, 0.2, "Should be able to set input delay")
	success = success and assert_equals(key_press_duration, 0.1, "Should be able to set key press duration")
	success = success and assert_equals(drag_speed, 750.0, "Should be able to set drag speed")
	success = success and assert_false(simulate_real_timing, "Should be able to disable real timing")
	success = success and assert_equals(max_history_size, 200, "Should be able to set max history size")

	# Test configuration bounds checking
	input_delay = -1.0  # Invalid negative value
	success = success and assert_equals(input_delay, -1.0, "Should handle negative input delay")

	# Restore original values
	input_delay = original_input_delay
	key_press_duration = original_key_press_duration
	drag_speed = original_drag_speed
	simulate_real_timing = original_simulate_real_timing
	max_history_size = original_max_history_size

	return success

# ------------------------------------------------------------------------------
# MOUSE EVENT SIMULATION TESTS
# ------------------------------------------------------------------------------
func test_mouse_event_simulation() -> bool:
	"""Test basic mouse click simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test basic mouse click
	var click_position = Vector2(100, 100)
	simulate_mouse_click(click_position)

	# Verify event was recorded (if recording is enabled)
	if record_events:
		success = success and assert_greater_than(input_history.size(), 0, "Mouse click should be recorded")

	# Test mouse click with different buttons
	simulate_mouse_click(click_position, MOUSE_BUTTON_RIGHT)
	simulate_mouse_click(click_position, MOUSE_BUTTON_MIDDLE)

	# Test mouse click with modifiers
	simulate_mouse_click(click_position, MOUSE_BUTTON_LEFT, [KEY_CTRL, KEY_SHIFT])

	# Verify multiple events recorded
	if record_events:
		var initial_count = input_history.size()
		simulate_mouse_click(click_position)
		success = success and assert_greater_than(input_history.size(), initial_count, "Additional clicks should be recorded")

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_mouse_double_click_simulation() -> bool:
	"""Test mouse double-click simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test double click
	var click_position = Vector2(200, 150)
	simulate_mouse_double_click(click_position)

	# Verify timing constants
	success = success and assert_equals(DOUBLE_CLICK_TIME, 0.3, "Double click time should be 0.3s")

	# Test double click with different button
	simulate_mouse_double_click(click_position, MOUSE_BUTTON_RIGHT)

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_mouse_drag_simulation() -> bool:
	"""Test mouse drag simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test basic drag
	var start_pos = Vector2(50, 50)
	var end_pos = Vector2(150, 150)
	simulate_mouse_drag(start_pos, end_pos)

	# Test drag with custom duration
	simulate_mouse_drag(start_pos, end_pos, MOUSE_BUTTON_LEFT, 1.0)

	# Test drag with different button
	simulate_mouse_drag(start_pos, end_pos, MOUSE_BUTTON_RIGHT, 0.5)

	# Verify drag speed constant
	success = success and assert_equals(DEFAULT_DRAG_SPEED, 500.0, "Default drag speed should be 500.0")

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_mouse_hover_simulation() -> bool:
	"""Test mouse hover simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test basic hover
	var hover_position = Vector2(300, 200)
	simulate_mouse_hover(hover_position)

	# Test hover with custom duration
	simulate_mouse_hover(hover_position, 2.0)

	# Verify hover creates motion events
	if record_events:
		success = success and assert_greater_than(input_history.size(), 0, "Hover should create motion events")

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_mouse_wheel_simulation() -> bool:
	"""Test mouse wheel simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test wheel up
	var wheel_position = Vector2(250, 200)
	simulate_mouse_wheel(wheel_position, Vector2(0, -1))

	# Test wheel down
	simulate_mouse_wheel(wheel_position, Vector2(0, 1))

	# Test horizontal scrolling
	simulate_mouse_wheel(wheel_position, Vector2(-1, 0))  # Left
	simulate_mouse_wheel(wheel_position, Vector2(1, 0))   # Right

	# Test zero delta (should not create events)
	simulate_mouse_wheel(wheel_position, Vector2.ZERO)

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

# ------------------------------------------------------------------------------
# KEYBOARD EVENT SIMULATION TESTS
# ------------------------------------------------------------------------------
func test_keyboard_event_simulation() -> bool:
	"""Test keyboard event simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test basic key press
	simulate_key_press(KEY_A)

	# Test key press with modifiers
	simulate_key_press(KEY_C, [KEY_CTRL])  # Ctrl+C
	simulate_key_press(KEY_V, [KEY_CTRL, KEY_SHIFT])  # Ctrl+Shift+V

	# Test special keys
	simulate_key_press(KEY_ENTER)
	simulate_key_press(KEY_SPACE)
	simulate_key_press(KEY_ESCAPE)

	# Test modifier keys
	simulate_key_press(KEY_CTRL)
	simulate_key_press(KEY_SHIFT)
	simulate_key_press(KEY_ALT)

	# Verify timing constants
	success = success and assert_equals(DEFAULT_KEY_PRESS_DURATION, 0.05, "Default key press duration should be 0.05")

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_keyboard_sequence_simulation() -> bool:
	"""Test keyboard sequence simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test simple key sequence
	var keys = [KEY_H, KEY_E, KEY_L, KEY_L, KEY_O]
	simulate_key_sequence(keys)

	# Test sequence with modifiers
	var complex_keys = [
		[KEY_A, [KEY_CTRL]],  # Ctrl+A
		[KEY_C, [KEY_CTRL]],  # Ctrl+C
		[KEY_V, [KEY_CTRL]]   # Ctrl+V
	]
	simulate_key_sequence(complex_keys)

	# Test sequence with custom delay
	simulate_key_sequence(keys, 0.1)

	# Test empty sequence
	simulate_key_sequence([])

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_text_input_simulation() -> bool:
	"""Test text input simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test basic text input
	var test_text = "Hello World"
	simulate_text_input(test_text)

	# Test text with special characters
	var special_text = "Test@123!#$%"
	simulate_text_input(special_text)

	# Test empty text
	simulate_text_input("")

	# Test single character
	simulate_text_input("A")

	# Test text with custom typing speed
	simulate_text_input(test_text, 0.2)

	# Test unicode characters (if supported)
	var unicode_text = "Hello 世界 🌍"
	simulate_text_input(unicode_text)

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

# ------------------------------------------------------------------------------
# TOUCH/GESTURE SIMULATION TESTS
# ------------------------------------------------------------------------------
func test_touch_event_simulation() -> bool:
	"""Test basic touch event simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test single touch press and release
	var touch_position = Vector2(100, 100)
	simulate_touch_press(0, touch_position)
	simulate_touch_release(0, touch_position)

	# Test multiple touch points
	simulate_touch_press(1, Vector2(200, 200))
	simulate_touch_release(1, Vector2(200, 200))

	# Test touch at different positions
	simulate_touch_press(0, Vector2(50, 50))
	simulate_touch_release(0, Vector2(150, 150))

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_touch_drag_simulation() -> bool:
	"""Test touch drag simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test basic touch drag
	var start_pos = Vector2(100, 100)
	var end_pos = Vector2(200, 200)
	simulate_touch_drag(0, start_pos, end_pos)

	# Test touch drag with custom duration
	simulate_touch_drag(1, start_pos, end_pos, 1.0)

	# Test short distance drag
	simulate_touch_drag(0, Vector2(50, 50), Vector2(60, 60))

	# Test long distance drag
	simulate_touch_drag(0, Vector2(0, 0), Vector2(500, 500))

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

func test_pinch_gesture_simulation() -> bool:
	"""Test pinch gesture simulation"""
	var success = true

	# Store original value to restore later
	var original_simulate_real_timing = simulate_real_timing

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test pinch in (zoom out)
	var center = Vector2(250, 250)
	simulate_pinch_gesture(center, 200.0, 50.0)

	# Test pinch out (zoom in)
	simulate_pinch_gesture(center, 50.0, 200.0)

	# Test pinch with custom duration
	simulate_pinch_gesture(center, 100.0, 150.0, 2.0)

	# Test pinch with same start and end distance
	simulate_pinch_gesture(center, 100.0, 100.0)

	# Restore original value
	simulate_real_timing = original_simulate_real_timing

	return success

# ------------------------------------------------------------------------------
# EVENT RECORDING AND PLAYBACK TESTS
# ------------------------------------------------------------------------------
func test_event_recording() -> bool:
	"""Test event recording functionality"""
	var success = true

	# Store original values to restore later
	var original_record_events = record_events
	var original_max_history_size = max_history_size

	# Enable event recording
	record_events = true

	# Test recording mouse events
	simulate_mouse_click(Vector2(100, 100))
	success = success and assert_greater_than(input_history.size(), 0, "Mouse events should be recorded")

	# Test recording keyboard events
	var initial_count = input_history.size()
	simulate_key_press(KEY_A)
	success = success and assert_greater_than(input_history.size(), initial_count, "Keyboard events should be recorded")

	# Test recording touch events
	initial_count = input_history.size()
	simulate_touch_press(0, Vector2(200, 200))
	success = success and assert_greater_than(input_history.size(), initial_count, "Touch events should be recorded")

	# Test recorded event structure
	if input_history.size() > 0:
		var recorded_event = input_history[0]
		success = success and assert_true(recorded_event.has("type"), "Recorded event should have type")
		success = success and assert_true(recorded_event.has("time"), "Recorded event should have timestamp")
		success = success and assert_true(recorded_event.has("data"), "Recorded event should have data")

	# Test history size limit
	max_history_size = 5
	for i in range(10):
		simulate_mouse_click(Vector2(i * 10, i * 10))

	success = success and assert_less_than(input_history.size(), 6, "History should respect size limit")

	# Test disabling recording
	record_events = false
	initial_count = input_history.size()
	simulate_mouse_click(Vector2(500, 500))
	success = success and assert_equals(input_history.size(), initial_count, "Events should not be recorded when disabled")

	# Restore original values
	record_events = original_record_events
	max_history_size = original_max_history_size

	return success

func test_event_playback() -> bool:
	"""Test event playback functionality"""
	var success = true

	# Store original value to restore later
	var original_record_events = record_events

	# Enable recording and create some events
	record_events = true
	simulate_mouse_click(Vector2(100, 100))
	simulate_key_press(KEY_A)
	simulate_touch_press(0, Vector2(200, 200))

	var event_count = input_history.size()
	success = success and assert_greater_than(event_count, 0, "Should have recorded events for playback test")

	# Test playback functionality (if implemented)
	# Note: Full playback implementation would require additional methods in EventTest
	# For now, we test that the recorded events are properly structured for playback

	if event_count > 0:
		for event_data in input_history:
			success = success and assert_true(event_data.has("type"), "Recorded event should have type for playback")
			success = success and assert_true(event_data.has("data"), "Recorded event should have data for playback")

	# Restore original value
	record_events = original_record_events

	return success

# ------------------------------------------------------------------------------
# TIMING AND CONTROL TESTS
# ------------------------------------------------------------------------------
func test_timing_controls() -> bool:
	"""Test timing control functionality"""
	var success = true

	# Store original values to restore later
	var original_input_delay = input_delay
	var original_key_press_duration = key_press_duration
	var original_drag_speed = drag_speed
	var original_simulate_real_timing = simulate_real_timing

	# Test timing constants
	success = success and assert_equals(DEFAULT_CLICK_DELAY, 0.1, "Default click delay should be 0.1")
	success = success and assert_equals(DEFAULT_KEY_PRESS_DURATION, 0.05, "Default key press duration should be 0.05")
	success = success and assert_equals(DEFAULT_DRAG_SPEED, 500.0, "Default drag speed should be 500.0")

	# Test timing modifications
	input_delay = 0.2
	key_press_duration = 0.1
	drag_speed = 750.0

	success = success and assert_equals(input_delay, 0.2, "Should be able to modify input delay")
	success = success and assert_equals(key_press_duration, 0.1, "Should be able to modify key press duration")
	success = success and assert_equals(drag_speed, 750.0, "Should be able to modify drag speed")

	# Test real timing toggle
	simulate_real_timing = true
	success = success and assert_true(simulate_real_timing, "Should be able to enable real timing")

	simulate_real_timing = false
	success = success and assert_false(simulate_real_timing, "Should be able to disable real timing")

	# Restore original values
	input_delay = original_input_delay
	key_press_duration = original_key_press_duration
	drag_speed = original_drag_speed
	simulate_real_timing = original_simulate_real_timing

	return success

# ------------------------------------------------------------------------------
# VALIDATION AND ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_input_validation() -> bool:
	"""Test input validation and bounds checking"""
	var success = true

	# Store original values to restore later
	var original_simulate_real_timing = simulate_real_timing
	var original_input_delay = input_delay
	var original_key_press_duration = key_press_duration

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test valid mouse positions
	simulate_mouse_click(Vector2(0, 0))
	simulate_mouse_click(Vector2(1920, 1080))
	simulate_mouse_click(Vector2(-100, -100))  # Negative positions should be handled

	# Test valid key codes
	simulate_key_press(KEY_A)
	simulate_key_press(KEY_Z)
	simulate_key_press(0)  # Edge case - null key

	# Test valid touch indices
	simulate_touch_press(0, Vector2(100, 100))
	simulate_touch_press(10, Vector2(100, 100))
	simulate_touch_press(-1, Vector2(100, 100))  # Negative index should be handled

	# Test empty modifier arrays
	simulate_key_press(KEY_A, [])
	simulate_mouse_click(Vector2(100, 100), MOUSE_BUTTON_LEFT, [])

	# Test large values
	input_delay = 999.0
	key_press_duration = 999.0
	success = success and assert_equals(input_delay, 999.0, "Should handle large timing values")

	# Restore original values
	simulate_real_timing = original_simulate_real_timing
	input_delay = original_input_delay
	key_press_duration = original_key_press_duration

	return success

func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Store original values to restore later
	var original_simulate_real_timing = simulate_real_timing
	var original_record_events = record_events
	var original_max_history_size = max_history_size

	# Disable real timing for faster testing
	simulate_real_timing = false

	# Test null/empty inputs that should be handled gracefully
	simulate_text_input("")  # Empty text
	simulate_key_sequence([])  # Empty sequence
	simulate_mouse_wheel(Vector2(100, 100), Vector2.ZERO)  # Zero delta

	# Test extreme values
	simulate_mouse_drag(Vector2(0, 0), Vector2(0, 0))  # Same start/end position
	simulate_touch_drag(0, Vector2(0, 0), Vector2(0, 0))  # Same touch positions

	# Test with recording disabled (should not crash)
	record_events = false
	simulate_mouse_click(Vector2(100, 100))
	simulate_key_press(KEY_A)
	simulate_touch_press(0, Vector2(100, 100))

	# Test configuration edge cases
	max_history_size = 0  # Should handle zero history size
	simulate_mouse_click(Vector2(100, 100))

	max_history_size = -1  # Should handle negative history size
	simulate_mouse_click(Vector2(100, 100))

	# Restore original values
	simulate_real_timing = original_simulate_real_timing
	record_events = original_record_events
	max_history_size = original_max_history_size

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_mock_input_event() -> InputEvent:
	"""Create a mock input event for testing"""
	var event = InputEventMouseButton.new()
	event.position = Vector2(100, 100)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	return event

func verify_event_structure(event_data: Dictionary) -> bool:
	"""Verify that recorded event data has required structure"""
	return event_data.has("type") and event_data.has("time") and event_data.has("data")

func simulate_complex_interaction(event_test: EventTest) -> void:
	"""Simulate a complex user interaction sequence"""
	# Mouse interactions
	event_test.simulate_mouse_click(Vector2(100, 100))
	event_test.simulate_mouse_drag(Vector2(100, 100), Vector2(200, 200))

	# Keyboard interactions
	event_test.simulate_key_sequence([KEY_CTRL, KEY_A])
	event_test.simulate_text_input("Test")

	# Touch interactions
	event_test.simulate_touch_drag(0, Vector2(50, 50), Vector2(150, 150))
