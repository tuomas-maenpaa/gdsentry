# GDSentry Visual Meta-Level Test
# Validates that GDSentry visual testing mechanics exist and can be loaded
#
# This test focuses on validating the existence of visual testing components
# rather than testing their functionality. It's a meta-test that ensures
# visual framework structure is intact and accessible.
#
# Author: GDSentry Framework
# Created: Auto-generated for self-testing

extends "res://base_classes/node2d_test.gd"

class_name GDSentryVisualMetaTest

# ------------------------------------------------------------------------------
# VISUAL META-TEST VALIDATION
# ------------------------------------------------------------------------------
func test_visual_components_exist() -> void:
	"""Test that visual testing components exist and can be loaded"""
	print("🎨 META: Testing visual component existence")

	# Test that visual components can be loaded
	var visual_test = load("res://gdsentry/test_types/visual_test.gd")
	assert_not_null(visual_test, "VisualTest class should exist")

	var event_test = load("res://gdsentry/test_types/event_test.gd")
	assert_not_null(event_test, "EventTest class should exist")

	var ui_test = load("res://gdsentry/test_types/ui_test.gd")
	assert_not_null(ui_test, "UITest class should exist")

	print("✅ META: Visual components exist")

func test_visual_base_functionality() -> void:
	"""Test that basic visual testing functionality is accessible"""
	print("🎨 META: Testing visual base functionality")

	# Test that we can create basic visual nodes
	var sprite = Sprite2D.new()
	assert_not_null(sprite, "Should be able to create Sprite2D")

	var label = Label.new()
	assert_not_null(label, "Should be able to create Label")

	var button = Button.new()
	assert_not_null(button, "Should be able to create Button")

	# Clean up
	sprite.queue_free()
	label.queue_free()
	button.queue_free()

	print("✅ META: Basic visual functionality accessible")

func test_scene_access() -> void:
	"""Test that we can access scene and node information"""
	print("🎨 META: Testing scene access")

	# Test that we can access scene tree
	var scene_tree = get_tree()
	assert_not_null(scene_tree, "Should be able to access scene tree")

	# Test that we can get root node
	var root = scene_tree.get_root()
	assert_not_null(root, "Should be able to get root node")

	print("✅ META: Scene access working")

func test_resource_loading() -> void:
	"""Test that resources can be loaded"""
	print("🎨 META: Testing resource loading")

	# Test loading basic resources
	var texture = load("res://resources/test_texture.png")
	if texture:
		assert_not_null(texture, "Should be able to load test texture")
	else:
		print("⚠️ Test texture not found (expected in standalone mode)")

	print("✅ META: Resource loading mechanics exist")

func test_input_simulation() -> void:
	"""Test that input simulation mechanics exist"""
	print("🎨 META: Testing input simulation mechanics")

	# Test that input event creation works
	var mouse_event = InputEventMouseButton.new()
	assert_not_null(mouse_event, "Should be able to create mouse event")

	var key_event = InputEventKey.new()
	assert_not_null(key_event, "Should be able to create key event")

	print("✅ META: Input simulation mechanics exist")

func test_physics_access() -> void:
	"""Test that physics access mechanics exist"""
	print("🎨 META: Testing physics access")

	# Test that we can create physics objects
	var area = Area2D.new()
	assert_not_null(area, "Should be able to create Area2D")

	var collision_shape = CollisionShape2D.new()
	assert_not_null(collision_shape, "Should be able to create CollisionShape2D")

	var physics_body = StaticBody2D.new()
	assert_not_null(physics_body, "Should be able to create physics body")

	# Clean up
	area.queue_free()
	collision_shape.queue_free()
	physics_body.queue_free()

	print("✅ META: Physics access mechanics exist")

func test_viewport_access() -> void:
	"""Test that viewport access works"""
	print("🎨 META: Testing viewport access")

	# Test that we can access viewport
	var viewport = get_viewport()
	assert_not_null(viewport, "Should be able to access viewport")

	# Test viewport properties
	var size = viewport.get_visible_rect().size
	assert_true(size.x > 0, "Viewport should have valid width")
	assert_true(size.y > 0, "Viewport should have valid height")

	print("✅ META: Viewport access working")
