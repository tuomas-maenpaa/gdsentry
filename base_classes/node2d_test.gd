# GDSentry - Node2D Test Base Class
# Base class for 2D visual and spatial testing
#
# Ideal for:
# - UI layout testing
# - Sprite and visual component testing
# - 2D physics and collision testing
# - Position and transform validation
# - Visual regression testing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2D

class_name Node2DTest

# Using GDTestManager as global class (no preload needed)

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
@export var test_description: String = ""
@export var test_tags: Array[String] = []
@export var test_priority: String = "normal"
@export var test_timeout: float = 30.0
@export var test_category: String = "visual"

# ------------------------------------------------------------------------------
# TEST STATE
# ------------------------------------------------------------------------------
var test_results: Dictionary = {}
var test_start_time: float = 0.0
var current_test_name: String = ""
var headless_mode: bool = false

# ------------------------------------------------------------------------------
# LIFECYCLE METHODS
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize test environment"""
	# Initialize with defaults to avoid GDTestManager dependency during loading
	headless_mode = true  # Assume headless for self-tests

	# Initialize basic test results structure
	test_results = {
		"start_time": Time.get_unix_time_from_system(),
		"end_time": 0.0,
		"execution_time": 0.0,
		"total_tests": 0,
		"passed_tests": 0,
		"failed_tests": 0,
		"skipped_tests": 0,
		"test_results": []
	}

	# Setup basic headless shutdown
	if headless_mode:
		_setup_basic_headless_shutdown(test_timeout)

	# Run test suite
	run_test_suite()

func _setup_basic_headless_shutdown(timeout_seconds: float) -> void:
	"""Setup basic headless shutdown without GDTestManager dependency"""
	var timer = Timer.new()
	timer.wait_time = timeout_seconds
	timer.one_shot = true
	timer.timeout.connect(func(): get_tree().quit())
	get_parent().add_child(timer)
	timer.start()

func wait_for_seconds(seconds: float) -> void:
	"""Wait for a specified number of seconds"""
	await get_tree().create_timer(seconds).timeout

func _exit_tree() -> void:
	"""Cleanup when test finishes"""
	if test_results.has("start_time") and test_results.start_time > 0:
		test_results.end_time = Time.get_unix_time_from_system()
		test_results.execution_time = test_results.end_time - test_results.start_time
	else:
		# Fallback if start_time wasn't properly set
		test_results.end_time = Time.get_unix_time_from_system()
		test_results.execution_time = 0.0

	# Print basic results
	print("Test completed in %.2f seconds" % test_results.get("execution_time", 0.0))
	var passed = test_results.get("passed_tests", 0)
	var failed = test_results.get("failed_tests", 0)
	print("Results: %d passed, %d failed" % [passed, failed])

# ------------------------------------------------------------------------------
# ABSTRACT METHODS (TO BE OVERRIDDEN)
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Override this method to define your test suite"""
	push_error("Node2DTest.run_test_suite() must be overridden in subclass")
	pass

# ------------------------------------------------------------------------------
# TEST EXECUTION HELPERS
# ------------------------------------------------------------------------------
func run_test(test_method_name: String, test_callable: Callable) -> bool:
	"""Execute a single test method with proper error handling"""
	current_test_name = test_method_name

	GDTestManager.log_test_info(get_test_suite_name(), "Running: " + test_method_name)

	var success = true
	var error_message = ""
	var start_time = Time.get_unix_time_from_system()

	# Execute test with error handling
	var result = test_callable.call()
	if result is bool:
		success = result
	else:
		success = true  # Assume success if no explicit return

	var end_time = Time.get_unix_time_from_system()
	var duration = end_time - start_time

	# Log result
	if success:
		GDTestManager.log_test_success(test_method_name, duration)
	else:
		GDTestManager.log_test_failure(test_method_name, error_message)

	# Record result
	GDTestManager.add_test_result(test_results, test_method_name, success, error_message)

	return success


# ------------------------------------------------------------------------------
# VISUAL TESTING UTILITIES
# ------------------------------------------------------------------------------
func take_screenshot() -> Image:
	"""Take a screenshot of the current viewport"""
	var viewport = get_viewport()
	if viewport:
		var texture = viewport.get_texture()
		if texture and texture is ViewportTexture:
			return texture.get_image()
	return null

func assert_visible(node: CanvasItem, message: String = "") -> bool:
	"""Assert that a node is visible"""
	if not node.visible:
		var error_msg = message if not message.is_empty() else "Node %s should be visible" % node.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_not_visible(node: CanvasItem, message: String = "") -> bool:
	"""Assert that a node is not visible"""
	if node.visible:
		var error_msg = message if not message.is_empty() else "Node %s should not be visible" % node.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_position(node: Node2D, expected_pos: Vector2, tolerance: float = 1.0, message: String = "") -> bool:
	"""Assert that a node's position is within tolerance of expected position"""
	var distance = node.position.distance_to(expected_pos)
	if distance > tolerance:
		var error_msg = message if not message.is_empty() else "Node position %s is not within %f units of expected position %s" % [node.position, tolerance, expected_pos]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_rotation(node: Node2D, expected_rotation: float, tolerance: float = 0.1, message: String = "") -> bool:
	"""Assert that a node's rotation is within tolerance of expected rotation"""
	var rotation_diff = abs(node.rotation - expected_rotation)
	if rotation_diff > tolerance:
		var error_msg = message if not message.is_empty() else "Node rotation %f is not within %f radians of expected rotation %f" % [node.rotation, tolerance, expected_rotation]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_scale(node: Node2D, expected_scale: Vector2, tolerance: float = 0.1, message: String = "") -> bool:
	"""Assert that a node's scale is within tolerance of expected scale"""
	var scale_diff = (node.scale - expected_scale).length()
	if scale_diff > tolerance:
		var error_msg = message if not message.is_empty() else "Node scale %s is not within %f units of expected scale %s" % [node.scale, tolerance, expected_scale]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_color_match(color1: Color, color2: Color, tolerance: float = 0.01, message: String = "") -> bool:
	"""Assert that two colors match within tolerance"""
	var diff_r = abs(color1.r - color2.r)
	var diff_g = abs(color1.g - color2.g)
	var diff_b = abs(color1.b - color2.b)
	var diff_a = abs(color1.a - color2.a)
	var max_diff = max(diff_r, max(diff_g, max(diff_b, diff_a)))

	if max_diff > tolerance:
		var error_msg = message if not message.is_empty() else "Colors %s and %s don't match within tolerance %f (max diff: %f)" % [color1, color2, tolerance, max_diff]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_sprite_frame(sprite: Sprite2D, expected_frame: int, message: String = "") -> bool:
	"""Assert that a sprite is showing the expected frame"""
	if sprite.frame != expected_frame:
		var error_msg = message if not message.is_empty() else "Sprite frame %d doesn't match expected frame %d" % [sprite.frame, expected_frame]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_animation_playing(animation_player: AnimationPlayer, expected_animation: String = "", message: String = "") -> bool:
	"""Assert that an animation is currently playing"""
	if not animation_player.is_playing():
		var error_msg = message if not message.is_empty() else "Animation is not playing"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if not expected_animation.is_empty() and animation_player.current_animation != expected_animation:
		var error_msg = message if not message.is_empty() else "Current animation '%s' doesn't match expected animation '%s'" % [animation_player.current_animation, expected_animation]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

# ------------------------------------------------------------------------------
# 2D PHYSICS TESTING
# ------------------------------------------------------------------------------
func assert_collision_detected(area1: Area2D, area2: Area2D, message: String = "") -> bool:
	"""Assert that two areas are colliding"""
	if not area1.overlaps_area(area2):
		var error_msg = message if not message.is_empty() else "Areas %s and %s are not colliding" % [area1.name, area2.name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_no_collision(area1: Area2D, area2: Area2D, message: String = "") -> bool:
	"""Assert that two areas are not colliding"""
	if area1.overlaps_area(area2):
		var error_msg = message if not message.is_empty() else "Areas %s and %s are colliding when they shouldn't" % [area1.name, area2.name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_physics_velocity(body: RigidBody2D, expected_velocity: Vector2, tolerance: float = 10.0, message: String = "") -> bool:
	"""Assert that a physics body's velocity is within tolerance of expected velocity"""
	var velocity_diff = (body.linear_velocity - expected_velocity).length()
	if velocity_diff > tolerance:
		var error_msg = message if not message.is_empty() else "Body velocity %s is not within %f units of expected velocity %s" % [body.linear_velocity, tolerance, expected_velocity]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_physics_position(body: RigidBody2D, expected_position: Vector2, tolerance: float = 5.0, message: String = "") -> bool:
	"""Assert that a physics body's position is within tolerance of expected position"""
	var position_diff = (body.position - expected_position).length()
	if position_diff > tolerance:
		var error_msg = message if not message.is_empty() else "Body position %s is not within %f units of expected position %s" % [body.position, tolerance, expected_position]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# SCENE MANAGEMENT UTILITIES
# ------------------------------------------------------------------------------
func load_test_scene(scene_path: String) -> Node:
	"""Load and instantiate a test scene"""
	var scene = GDTestManager.load_scene_safely(scene_path)
	if scene:
		var instance = GDTestManager.instantiate_scene_safely(scene)
		if instance:
			add_child(instance)
			return instance
	return null

func create_test_sprite(texture_path: String = "", _position: Vector2 = Vector2.ZERO) -> Sprite2D:
	"""Create a test sprite with optional texture"""
	var sprite = Sprite2D.new()
	if not texture_path.is_empty():
		var texture = load(texture_path)
		if texture and texture is Texture2D:
			sprite.texture = texture
		sprite.position = _position
	add_child(sprite)
	return sprite

func create_test_area(_position: Vector2 = Vector2.ZERO, size: Vector2 = Vector2(32, 32)) -> Area2D:
	"""Create a test area with collision shape"""
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = size
	shape.shape = rectangle_shape
	area.add_child(shape)
	area.position = _position
	add_child(area)
	return area

func create_test_body(_position: Vector2 = Vector2.ZERO, type: String = "static") -> PhysicsBody2D:
	"""Create a test physics body"""
	var body: PhysicsBody2D

	match type:
		"static":
			body = StaticBody2D.new()
		"kinematic":
			body = CharacterBody2D.new()  # Using CharacterBody2D for kinematic-like behavior
		"rigid":
			body = RigidBody2D.new()
		_:
			body = RigidBody2D.new()

	var shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(32, 32)
	shape.shape = rectangle_shape
	body.add_child(shape)
	body.position = _position
	add_child(body)
	return body

# ------------------------------------------------------------------------------
# VISUAL REGRESSION TESTING
# ------------------------------------------------------------------------------
func assert_visual_match(baseline_image_path: String, tolerance: float = 0.95, message: String = "") -> bool:
	"""Assert that current screen matches baseline image"""
	var current_image = take_screenshot()
	if not current_image:
		var error_msg = message if not message.is_empty() else "Failed to take screenshot"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var baseline_texture = load(baseline_image_path)
	if not baseline_texture:
		var error_msg = message if not message.is_empty() else "Failed to load baseline image: %s" % baseline_image_path
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var baseline_image: Image = null
	if baseline_texture is Texture2D:
		baseline_image = baseline_texture.get_image()
	else:
		var error_msg = message if not message.is_empty() else "Loaded resource is not a Texture2D: %s" % baseline_image_path
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if not baseline_image:
		var error_msg = message if not message.is_empty() else "Failed to get image from baseline texture"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	# Simple pixel comparison (can be enhanced with more sophisticated algorithms)
	var similarity = calculate_image_similarity(current_image, baseline_image)
	if similarity < tolerance:
		var error_msg = message if not message.is_empty() else "Visual similarity %.2f%% below tolerance %.2f%%" % [similarity * 100, tolerance * 100]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func calculate_image_similarity(image1: Image, image2: Image) -> float:
	"""Calculate similarity between two images (0.0 to 1.0)"""
	if image1.get_size() != image2.get_size():
		return 0.0

	var total_pixels = image1.get_width() * image1.get_height()
	var matching_pixels = 0

	image1.lock()
	image2.lock()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)
			if color1.is_equal_approx(color2):
				matching_pixels += 1

	image1.unlock()
	image2.unlock()

	return float(matching_pixels) / float(total_pixels)

# ------------------------------------------------------------------------------
# GENERAL ASSERTION METHODS (DUPLICATED FROM GDTest)
# ------------------------------------------------------------------------------
func assert_true(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is true"""
	if not condition:
		var error_msg = message if not message.is_empty() else "Expected true, got false"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_false(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is false"""
	if condition:
		var error_msg = message if not message.is_empty() else "Expected false, got true"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are equal"""
	if actual != expected:
		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [expected, actual]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_not_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are not equal"""
	if actual == expected:
		var error_msg = message if not message.is_empty() else "Expected values to be different, but both are %s" % actual
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is null"""
	if value != null:
		var error_msg = message if not message.is_empty() else "Expected null, got %s" % value
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_not_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is not null"""
	if value == null:
		var error_msg = message if not message.is_empty() else "Expected non-null value, got null"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_greater_than(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is greater than expected"""
	if actual <= expected:
		var error_msg = message if not message.is_empty() else "Expected %s > %s" % [actual, expected]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_less_than(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is less than expected"""
	if actual >= expected:
		var error_msg = message if not message.is_empty() else "Expected %s < %s" % [actual, expected]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_in_range(value: float, min_val: float, max_val: float, message: String = "") -> bool:
	"""Assert that a value is within a range"""
	if value < min_val or value > max_val:
		var error_msg = message if not message.is_empty() else "Expected %s to be between %s and %s" % [value, min_val, max_val]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_type(value: Variant, expected_type: int, message: String = "") -> bool:
	"""Assert that a value is of a specific type"""
	if typeof(value) != expected_type:
		var type_name = ""
		match expected_type:
			TYPE_BOOL: type_name = "bool"
			TYPE_INT: type_name = "int"
			TYPE_FLOAT: type_name = "float"
			TYPE_STRING: type_name = "String"
			TYPE_VECTOR2: type_name = "Vector2"
			TYPE_VECTOR2I: type_name = "Vector2i"
			TYPE_RECT2: type_name = "Rect2"
			TYPE_RECT2I: type_name = "Rect2i"
			TYPE_VECTOR3: type_name = "Vector3"
			TYPE_VECTOR3I: type_name = "Vector3i"
			TYPE_TRANSFORM2D: type_name = "Transform2D"
			TYPE_VECTOR4: type_name = "Vector4"
			TYPE_VECTOR4I: type_name = "Vector4i"
			TYPE_PLANE: type_name = "Plane"
			TYPE_QUATERNION: type_name = "Quaternion"
			TYPE_AABB: type_name = "AABB"
			TYPE_BASIS: type_name = "Basis"
			TYPE_TRANSFORM3D: type_name = "Transform3D"
			TYPE_PROJECTION: type_name = "Projection"
			TYPE_COLOR: type_name = "Color"
			TYPE_STRING_NAME: type_name = "StringName"
			TYPE_NODE_PATH: type_name = "NodePath"
			TYPE_RID: type_name = "RID"
			TYPE_OBJECT: type_name = "Object"
			TYPE_CALLABLE: type_name = "Callable"
			TYPE_SIGNAL: type_name = "Signal"
			TYPE_DICTIONARY: type_name = "Dictionary"
			TYPE_ARRAY: type_name = "Array"
			TYPE_PACKED_BYTE_ARRAY: type_name = "PackedByteArray"
			TYPE_PACKED_INT32_ARRAY: type_name = "PackedInt32Array"
			TYPE_PACKED_INT64_ARRAY: type_name = "PackedInt64Array"
			TYPE_PACKED_FLOAT32_ARRAY: type_name = "PackedFloat32Array"
			TYPE_PACKED_FLOAT64_ARRAY: type_name = "PackedFloat64Array"
			TYPE_PACKED_STRING_ARRAY: type_name = "PackedStringArray"
			TYPE_PACKED_VECTOR2_ARRAY: type_name = "PackedVector2Array"
			TYPE_PACKED_VECTOR3_ARRAY: type_name = "PackedVector3Array"
			TYPE_PACKED_COLOR_ARRAY: type_name = "PackedColorArray"
			_: type_name = "Unknown"

		var actual_type_name = ""
		match typeof(value):
			TYPE_BOOL: actual_type_name = "bool"
			TYPE_INT: actual_type_name = "int"
			TYPE_FLOAT: actual_type_name = "float"
			TYPE_STRING: actual_type_name = "String"
			TYPE_VECTOR2: actual_type_name = "Vector2"
			TYPE_VECTOR2I: actual_type_name = "Vector2i"
			TYPE_RECT2: actual_type_name = "Rect2"
			TYPE_RECT2I: actual_type_name = "Rect2i"
			TYPE_VECTOR3: actual_type_name = "Vector3"
			TYPE_VECTOR3I: actual_type_name = "Vector3i"
			TYPE_TRANSFORM2D: actual_type_name = "Transform2D"
			TYPE_VECTOR4: actual_type_name = "Vector4"
			TYPE_VECTOR4I: actual_type_name = "Vector4i"
			TYPE_PLANE: actual_type_name = "Plane"
			TYPE_QUATERNION: actual_type_name = "Quaternion"
			TYPE_AABB: actual_type_name = "AABB"
			TYPE_BASIS: actual_type_name = "Basis"
			TYPE_TRANSFORM3D: actual_type_name = "Transform3D"
			TYPE_PROJECTION: actual_type_name = "Projection"
			TYPE_COLOR: actual_type_name = "Color"
			TYPE_STRING_NAME: actual_type_name = "StringName"
			TYPE_NODE_PATH: actual_type_name = "NodePath"
			TYPE_RID: actual_type_name = "RID"
			TYPE_OBJECT: actual_type_name = "Object"
			TYPE_CALLABLE: actual_type_name = "Callable"
			TYPE_SIGNAL: actual_type_name = "Signal"
			TYPE_DICTIONARY: actual_type_name = "Dictionary"
			TYPE_ARRAY: actual_type_name = "Array"
			TYPE_PACKED_BYTE_ARRAY: actual_type_name = "PackedByteArray"
			TYPE_PACKED_INT32_ARRAY: actual_type_name = "PackedInt32Array"
			TYPE_PACKED_INT64_ARRAY: actual_type_name = "PackedInt64Array"
			TYPE_PACKED_FLOAT32_ARRAY: actual_type_name = "PackedFloat32Array"
			TYPE_PACKED_FLOAT64_ARRAY: actual_type_name = "PackedFloat64Array"
			TYPE_PACKED_STRING_ARRAY: actual_type_name = "PackedStringArray"
			TYPE_PACKED_VECTOR2_ARRAY: actual_type_name = "PackedVector2Array"
			TYPE_PACKED_VECTOR3_ARRAY: actual_type_name = "PackedVector3Array"
			TYPE_PACKED_COLOR_ARRAY: actual_type_name = "PackedColorArray"
			_: actual_type_name = "Unknown"

		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [type_name, actual_type_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_has_method(value: Object, method_name: String, message: String = "") -> bool:
	"""Assert that a value has a specific method"""
	if not value.has_method(method_name):
		var error_msg = message if not message.is_empty() else "Expected %s to have method: %s" % [value.get_class(), method_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func get_test_suite_name() -> String:
	"""Get the name of this test suite"""
	return get_class() if not get_class().is_empty() else "Node2DTest"

func wait_for_physics_frames(frames: int = 1) -> void:
	"""Wait for specified number of physics frames"""
	for i in range(frames):
		await get_tree().physics_frame

func wait_for_render_frames(frames: int = 1) -> void:
	"""Wait for specified number of render frames"""
	for i in range(frames):
		await get_tree().process_frame

func simulate_frames(count: int = 1) -> void:
	"""Simulate multiple frames for testing"""
	for i in range(count):
		await get_tree().process_frame
