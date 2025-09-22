# GDSentry - Node2DTest Base Class Test Suite
# Tests the Node2DTest base class functionality for 2D visual and spatial testing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2DTest

class_name Node2DTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for Node2DTest base class"
	test_tags = ["base_class", "node2d_test", "visual", "physics", "2d", "screenshot"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all Node2DTest base class tests"""
	run_test("test_node2dtest_inheritance", func(): return test_node2dtest_inheritance())
	run_test("test_visual_assertions", func(): return test_visual_assertions())
	run_test("test_position_assertions", func(): return test_position_assertions())
	run_test("test_create_test_sprite", func(): return test_create_test_sprite())
	run_test("test_create_test_area", func(): return test_create_test_area())
	run_test("test_create_test_body", func(): return test_create_test_body())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_node2dtest_inheritance() -> bool:
	"""Test that Node2DTest properly inherits from Node2D"""
	assert_equals(get_class(), "Node2DTestTest", "Should have correct class name")
	assert_true(is_inside_tree(), "Should be in scene tree")
	assert_equals(test_category, "visual", "Should have visual category")
	assert_true(self is Node2D, "Should inherit from Node2D")
	return true

# ------------------------------------------------------------------------------
# VISUAL TESTING ASSERTIONS
# ------------------------------------------------------------------------------
func test_visual_assertions() -> bool:
	"""Test visual assertion methods"""
	var sprite = create_test_sprite("", Vector2(100, 100))
	var hidden_sprite = create_test_sprite("", Vector2(200, 200))

	assert_true(assert_visible(sprite), "Sprite should be visible by default")

	hidden_sprite.visible = false
	assert_false(assert_visible(hidden_sprite), "Hidden sprite should not be visible")
	assert_true(assert_not_visible(hidden_sprite), "Hidden sprite should pass not visible assertion")

	sprite.queue_free()
	hidden_sprite.queue_free()
	return true

func test_position_assertions() -> bool:
	"""Test position assertion methods"""
	var sprite = create_test_sprite("", Vector2(100, 100))

	assert_true(assert_position(sprite, Vector2(100, 100)), "Should match exact position")
	assert_true(assert_position(sprite, Vector2(101, 101), 2.0), "Should match within tolerance")
	assert_false(assert_position(sprite, Vector2(200, 200)), "Should not match different position")

	sprite.queue_free()
	return true

# ------------------------------------------------------------------------------
# SCENE MANAGEMENT UTILITIES
# ------------------------------------------------------------------------------
func test_create_test_sprite() -> bool:
	"""Test create_test_sprite utility"""
	var sprite1 = create_test_sprite("", Vector2(100, 100))
	assert_not_null(sprite1, "Should create sprite without texture")
	assert_equals(sprite1.position, Vector2(100, 100), "Should set correct position")
	assert_true(sprite1.is_inside_tree(), "Sprite should be in scene tree")

	var sprite2 = create_test_sprite("", Vector2(200, 200))
	assert_equals(sprite2.position, Vector2(200, 200), "Should set correct position")

	sprite1.queue_free()
	sprite2.queue_free()
	return true

func test_create_test_area() -> bool:
	"""Test create_test_area utility"""
	var area = create_test_area(Vector2(100, 100), Vector2(64, 32))

	assert_not_null(area, "Should create area")
	assert_equals(area.position, Vector2(100, 100), "Should set correct position")
	assert_true(area.get_child(0) is CollisionShape2D, "Should have collision shape")
	assert_true(area.is_inside_tree(), "Area should be in scene tree")

	area.queue_free()
	return true

func test_create_test_body() -> bool:
	"""Test create_test_body utility"""
	var static_body = create_test_body(Vector2(100, 100), "static")
	var rigid_body = create_test_body(Vector2(200, 200), "rigid")

	assert_true(static_body is StaticBody2D, "Should create StaticBody2D")
	assert_true(rigid_body is RigidBody2D, "Should create RigidBody2D")
	assert_equals(static_body.position, Vector2(100, 100), "Should set correct position")
	assert_equals(rigid_body.position, Vector2(200, 200), "Should set correct position")

	static_body.queue_free()
	rigid_body.queue_free()
	return true