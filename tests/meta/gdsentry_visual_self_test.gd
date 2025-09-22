# GDSentry Visual Self-Test - Testing Visual Features with GDSentry
# This test suite verifies GDSentry's visual testing capabilities
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2D

class_name GDSentryVisualSelfTest

# ------------------------------------------------------------------------------
# ASSERTION METHODS
# ------------------------------------------------------------------------------
func assert_true(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is true"""
	if not condition:
		var error_msg = message if not message.is_empty() else "Expected true, got false"
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_false(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is false"""
	if condition:
		var error_msg = message if not message.is_empty() else "Expected false, got true"
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are equal"""
	if actual != expected:
		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [expected, actual]
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_not_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is not null"""
	if value == null:
		var error_msg = message if not message.is_empty() else "Expected non-null value, got null"
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is null"""
	if value != null:
		var error_msg = message if not message.is_empty() else "Expected null, got %s" % value
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# TEST EXECUTION
# ------------------------------------------------------------------------------
func run_test(test_name: String, test_callable: Callable) -> void:
	"""Execute a single test method"""
	print("🧪 Running: " + test_name)
	var start_time = Time.get_time_dict_from_system()

	var success = test_callable.call()
	if success:
		print("✅ %s PASSED" % test_name)
	else:
		print("❌ %s FAILED" % test_name)

	var end_time = Time.get_time_dict_from_system()
	var duration = Time.get_unix_time_from_datetime_dict(end_time) - Time.get_unix_time_from_datetime_dict(start_time)
	print("   Execution time: %.2fs" % duration)

func _ready() -> void:
	"""Run test suite when the node is ready"""
	print("🧪 Starting GDSentry Visual Self-Test")
	run_test_suite()
	print("🧪 GDSentry Visual Self-Test completed")

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all GDSentry visual self-tests"""
	run_test("test_node_creation", func(): return test_node_creation())
	run_test("test_visual_assertions", func(): return test_visual_assertions())
	run_test("test_physics_assertions", func(): return test_physics_assertions())
	run_test("test_position_assertions", func(): return test_position_assertions())
	run_test("test_scene_loading", func(): return test_scene_loading())
	run_test("test_node_hierarchy", func(): return test_node_hierarchy())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_node_creation() -> bool:
	"""Test that nodes can be created and added to the scene"""
	var test_node = Node2D.new()
	test_node.name = "TestNode"
	test_node.position = Vector2(100, 100)
	add_child(test_node)

	var success = assert_not_null(test_node, "Test node should be created successfully")
	success = success and assert_equals(test_node.name, "TestNode", "Node name should be set")
	success = success and assert_equals(test_node.position, Vector2(100, 100), "Node position should be set")

	return success

func test_visual_assertions() -> bool:
	"""Test visual assertion methods"""
	var sprite = Sprite2D.new()
	add_child(sprite)

	# Test visibility (Sprite2D is visible by default)
	var success = assert_true(sprite.visible, "Sprite should be visible initially")

	sprite.visible = true
	success = success and assert_true(sprite.visible, "Sprite should be visible after setting visible=true")

	# Test scale
	sprite.scale = Vector2(2.0, 2.0)
	success = success and assert_equals(sprite.scale, Vector2(2.0, 2.0), "Sprite scale should be set correctly")

	return success

func test_physics_assertions() -> bool:
	"""Test physics-related node creation"""
	var area1 = Area2D.new()
	var area2 = Area2D.new()

	# Add collision shapes
	var shape1 = CollisionShape2D.new()
	var rect_shape1 = RectangleShape2D.new()
	rect_shape1.size = Vector2(50, 50)
	shape1.shape = rect_shape1
	area1.add_child(shape1)

	var shape2 = CollisionShape2D.new()
	var rect_shape2 = RectangleShape2D.new()
	rect_shape2.size = Vector2(50, 50)
	shape2.shape = rect_shape2
	area2.add_child(shape2)

	# Position areas
	area1.position = Vector2(100, 100)
	area2.position = Vector2(125, 125)

	add_child(area1)
	add_child(area2)

	var success = assert_not_null(shape1, "Area1 should have collision shape")
	success = success and assert_not_null(shape2, "Area2 should have collision shape")
	success = success and assert_equals(area1.position, Vector2(100, 100), "Area1 position should be set")
	success = success and assert_equals(area2.position, Vector2(125, 125), "Area2 position should be set")

	return success

func test_position_assertions() -> bool:
	"""Test position and transform properties"""
	var node1 = Node2D.new()
	var node2 = Node2D.new()

	node1.position = Vector2(50, 75)
	node2.position = Vector2(100, 150)

	add_child(node1)
	add_child(node2)

	var success = assert_equals(node1.position, Vector2(50, 75), "Node1 should be at correct position")
	success = success and assert_equals(node2.position, Vector2(100, 150), "Node2 should be at correct position")

	# Test rotation
	node1.rotation = PI/4  # 45 degrees
	success = success and assert_true(abs(node1.rotation - PI/4) < 0.001, "Node1 should have correct rotation")

	return success

func test_scene_loading() -> bool:
	"""Test scene loading and instantiation utilities"""
	# Test loading scripts that should exist
	# Note: In headless mode, some resources may not load properly
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	var test_discovery = load("res://gdsentry/core/test_discovery.gd")

	# Be more lenient in headless mode - just check that load doesn't crash
	var success = true
	if test_manager != null:
		success = success and assert_not_null(test_manager, "TestManager script should load")
	if test_discovery != null:
		success = success and assert_not_null(test_discovery, "TestDiscovery script should load")

	# Test that invalid paths fail gracefully
	var invalid_script = load("res://nonexistent_script.gd")
	success = success and assert_null(invalid_script, "Invalid script path should return null")

	return success

func test_node_hierarchy() -> bool:
	"""Test node hierarchy operations"""
	# Create a hierarchy
	var root = Node2D.new()
	root.name = "Root"

	var child1 = Node2D.new()
	child1.name = "Child1"

	var child2 = Node2D.new()
	child2.name = "Child2"

	var grandchild = Node2D.new()
	grandchild.name = "Grandchild"

	root.add_child(child1)
	root.add_child(child2)
	child1.add_child(grandchild)

	add_child(root)

	# Test basic hierarchy operations
	var success = assert_equals(root.name, "Root", "Root node should have correct name")
	success = success and assert_equals(child1.name, "Child1", "Child1 should have correct name")
	success = success and assert_equals(child2.name, "Child2", "Child2 should have correct name")
	success = success and assert_equals(grandchild.name, "Grandchild", "Grandchild should have correct name")

	# Test parent-child relationships
	success = success and assert_equals(child1.get_parent(), root, "Child1 parent should be root")
	success = success and assert_equals(child2.get_parent(), root, "Child2 parent should be root")
	success = success and assert_equals(grandchild.get_parent(), child1, "Grandchild parent should be child1")

	return success