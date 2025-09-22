# GDSentry - UI Layout Test Example
# Example test demonstrating visual UI testing with GDSentry
#
# This example shows how to test UI layouts, button interactions,
# and visual components using the Node2DTest base class
#
# Author: GDSentry Framework
# Version: 1.0.0

# extends Node2DTest  # Commented out - base class not available in this project

class_name UILayoutTest extends Node2DTest

# Instance variables for signal testing
var _signal_test_emitted: bool = false

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready():
	test_description = "Test suite for UI layout and interaction"
	test_tags = ["ui", "visual", "layout", "interaction"]
	test_priority = "high"
	test_category = "interface"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all UI layout tests"""
	run_test("test_button_creation", func(): return test_button_creation())
	run_test("test_button_positioning", func(): return test_button_positioning())
	run_test("test_button_interaction", func(): return test_button_interaction())
	run_test("test_label_display", func(): return test_label_display())
	run_test("test_sprite_visibility", func(): return test_sprite_visibility())
	run_test("test_collision_shapes", func(): return await test_collision_shapes())
	run_test("test_ui_layout_constraints", func(): return test_ui_layout_constraints())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_button_creation() -> bool:
	"""Test creating and configuring buttons"""
	var button = Button.new()
	button.text = "Test Button"
	button.size = Vector2(120, 40)
	add_child(button)

	return assert_not_null(button, "Button should be created successfully") and \
		   assert_equals(button.text, "Test Button", "Button text should be set correctly") and \
		   assert_equals(button.size, Vector2(120, 40), "Button size should be set correctly")

func test_button_positioning() -> bool:
	"""Test button positioning and layout"""
	var button1 = Button.new()
	button1.text = "Button 1"
	button1.position = Vector2(100, 50)
	add_child(button1)

	var button2 = Button.new()
	button2.text = "Button 2"
	button2.position = Vector2(100, 100)
	add_child(button2)

	return assert_position(button1, Vector2(100, 50), 1.0, "Button 1 should be at correct position") and \
		   assert_position(button2, Vector2(100, 100), 1.0, "Button 2 should be at correct position") and \
		   assert_greater_than(button2.position.y, button1.position.y, "Button 2 should be below Button 1")

func test_button_interaction() -> bool:
	"""Test button press simulation and state changes"""
	var button = Button.new()
	button.text = "Clickable Button"
	add_child(button)

	# Initially button should not be pressed
	var initial_pressed = button.button_pressed
	assert_false(initial_pressed, "Button should not be pressed initially")

	# Simulate button press
	button.button_pressed = true
	var after_press = button.button_pressed
	assert_true(after_press, "Button should be pressed after setting button_pressed")

	# Test button signal emission
	_signal_test_emitted = false
	button.connect("pressed", Callable(self, "_on_signal_test_pressed"))

	# Simulate button press via emit_signal
	button.emit_signal("pressed")
	assert_true(_signal_test_emitted, "Button pressed signal should be emitted")

	return true

func _on_signal_test_pressed() -> void:
	"""Helper method for button signal testing"""
	_signal_test_emitted = true

func test_label_display() -> bool:
	"""Test label text display and formatting"""
	var label = Label.new()
	label.text = "Hello, GDSentry!"
	label.position = Vector2(50, 150)
	add_child(label)

	return assert_equals(label.text, "Hello, GDSentry!", "Label text should match") and \
		   assert_visible(label, "Label should be visible") and \
		   assert_greater_than(label.size.x, 0, "Label should have non-zero width") and \
		   assert_greater_than(label.size.y, 0, "Label should have non-zero height")

func test_sprite_visibility() -> bool:
	"""Test sprite visibility and texture loading"""
	var sprite = Sprite2D.new()

	# Test initial state
	assert_not_visible(sprite, "Sprite should not be visible initially")

	# Make visible and test
	sprite.visible = true
	assert_visible(sprite, "Sprite should be visible after setting visible = true")

	# Test with position
	sprite.position = Vector2(200, 200)
	assert_position(sprite, Vector2(200, 200), 1.0, "Sprite should be at correct position")

	# Test scaling
	sprite.scale = Vector2(2.0, 2.0)
	assert_scale(sprite, Vector2(2.0, 2.0), 0.1, "Sprite should be scaled correctly")

	return true

func test_collision_shapes() -> bool:
	"""Test collision shape creation and overlap detection"""
	var area1 = Area2D.new()
	var shape1 = CollisionShape2D.new()
	var rect_shape1 = RectangleShape2D.new()
	rect_shape1.size = Vector2(50, 50)
	shape1.shape = rect_shape1
	area1.add_child(shape1)
	area1.position = Vector2(100, 100)
	add_child(area1)

	var area2 = Area2D.new()
	var shape2 = CollisionShape2D.new()
	var rect_shape2 = RectangleShape2D.new()
	rect_shape2.size = Vector2(50, 50)
	shape2.shape = rect_shape2
	area2.add_child(shape2)
	area2.position = Vector2(125, 125)  # Overlapping position
	add_child(area2)

	# Wait for physics to process
	await wait_for_physics_frames(2)

	return assert_collision_detected(area1, area2, "Areas should be colliding") and \
		   assert_not_null(area1.get_node("CollisionShape2D"), "Area1 should have collision shape") and \
		   assert_not_null(area2.get_node("CollisionShape2D"), "Area2 should have collision shape")

func test_ui_layout_constraints() -> bool:
	"""Test UI layout positioning constraints"""
	var container = Control.new()
	container.size = Vector2(400, 300)
	container.position = Vector2(0, 0)
	add_child(container)

	# Create buttons in a vertical layout
	var button1 = Button.new()
	button1.text = "Top Button"
	button1.size = Vector2(150, 40)
	button1.position = Vector2(50, 50)
	container.add_child(button1)

	var button2 = Button.new()
	button2.text = "Bottom Button"
	button2.size = Vector2(150, 40)
	button2.position = Vector2(50, 120)
	container.add_child(button2)

	var button3 = Button.new()
	button3.text = "Right Button"
	button3.size = Vector2(150, 40)
	button3.position = Vector2(250, 50)
	container.add_child(button3)

	# Test layout constraints
	var container_rect = Rect2(container.position, container.size)

	return assert_true(container_rect.has_point(button1.position), "Button1 should be inside container") and \
		   assert_true(container_rect.has_point(button2.position), "Button2 should be inside container") and \
		   assert_true(container_rect.has_point(button3.position), "Button3 should be inside container") and \
		   assert_less_than(button1.position.y, button2.position.y, "Button1 should be above Button2") and \
		   assert_equals(button1.position.x, button2.position.x, "Buttons should be vertically aligned") and \
		   assert_greater_than(button3.position.x, button1.position.x, "Button3 should be to the right of Button1")

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_button(text: String, button_position: Vector2, button_size: Vector2 = Vector2(120, 40)) -> Button:
	"""Helper method to create a test button"""
	var button = Button.new()
	button.text = text
	button.position = button_position
	button.size = button_size
	add_child(button)
	return button

func create_test_label(text: String, label_position: Vector2) -> Label:
	"""Helper method to create a test label"""
	var label = Label.new()
	label.text = text
	label.position = label_position
	add_child(label)
	return label

func create_test_sprite(sprite_name: String = "TestSprite", sprite_position: Vector2 = Vector2.ZERO) -> Sprite2D:
	"""Helper method to create a test sprite"""
	var sprite = Sprite2D.new()
	sprite.name = sprite_name
	sprite.position = sprite_position
	add_child(sprite)
	return sprite
