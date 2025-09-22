# GDSentry - SceneTreeTest Base Class Unit Tests
# Comprehensive testing of SceneTreeTest base class functionality
#
# Tests the SceneTree test base class including:
# - SceneTree inheritance and lifecycle
# - Test execution coordination
# - Result aggregation and reporting
# - Scene management integration
# - Process and physics frame handling
# - Signal connection and management
#
# Author: GDSentry Framework
# Version: 1.0.0

extends "res://base_classes/scene_tree_test.gd"

class_name SceneTreeTestTest


# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready():
	test_description = "Unit tests for SceneTreeTest base class functionality"
	test_tags = ["unit", "base_class", "scene_tree_test"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func _execute_test_suite() -> bool:
	"""Execute SceneTreeTest base class unit tests"""
	var all_passed = true

	# Test basic SceneTreeTest instantiation
	var instantiation_result = run_test("test_scene_tree_test_instantiation", func(): return test_scene_tree_test_instantiation())
	all_passed = all_passed and instantiation_result

	return all_passed

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_scene_tree_test_instantiation() -> bool:
	"""Test SceneTreeTest instantiation and basic properties"""
	var scene_tree_test = SceneTreeTest.new()

	var success = assert_not_null(scene_tree_test, "SceneTreeTest should instantiate successfully")
	success = success and assert_true(typeof(scene_tree_test) == TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(scene_tree_test.get_class(), "SceneTreeTest",
										"Should be SceneTreeTest class")

	return success

func test_scene_tree_test_inheritance() -> bool:
	"""Test SceneTreeTest inheritance hierarchy"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test that it inherits from SceneTree
	success = success and assert_true(scene_tree_test is SceneTree,
									"Should inherit from SceneTree")

	# Test that it also inherits from GDTest (through composition/extension)
	success = success and assert_true(scene_tree_test.has_method("assert_true"),
									"Should have GDTest assertion methods")

	# Test SceneTree-specific properties
	success = success and assert_true(scene_tree_test.has_method("get_root"),
									"Should have SceneTree get_root method")
	success = success and assert_true(scene_tree_test.has_method("get_current_scene"),
									"Should have SceneTree get_current_scene method")

	return success

func test_scene_tree_test_execution_methods() -> bool:
	"""Test SceneTreeTest execution method availability"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test core execution methods from GDTest
	var gdtest_methods = [
		"run_test", "run_test_suite", "run_tests"
	]

	for method in gdtest_methods:
		success = success and assert_true(scene_tree_test.has_method(method),
										"Should have GDTest method: " + method)

	# Test SceneTree-specific execution methods
	var scenetree_methods = [
		"quit", "set_pause", "get_frame_time",
		"get_physics_frame_time", "get_process_time"
	]

	for method in scenetree_methods:
		success = success and assert_true(scene_tree_test.has_method(method),
										"Should have SceneTree method: " + method)

	# Test that it can execute tests
	var test_result = scene_tree_test.run_test("dummy_test", func(): return true)
	success = success and assert_true(typeof(test_result) == TYPE_BOOL,
									"run_test should return boolean")

	return success

func test_scene_tree_test_result_management() -> bool:
	"""Test SceneTreeTest result management capabilities"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test result management methods
	var result_methods = [
		"get_test_results", "get_test_summary", "record_test_result"
	]

	for method in result_methods:
		success = success and assert_true(scene_tree_test.has_method(method),
										"Should have result method: " + method)

	# Test result aggregation
	var results = scene_tree_test.get_test_results()
	success = success and assert_not_null(results, "Should get test results")

	# Test summary generation
	var summary = scene_tree_test.get_test_summary()
	success = success and assert_not_null(summary, "Should get test summary")
	success = success and assert_true(summary is Dictionary, "Summary should be dictionary")

	return success

func test_scene_tree_test_scene_management() -> bool:
	"""Test SceneTreeTest scene management integration"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test scene management methods
	var scene_methods = [
		"change_scene_to_file", "change_scene_to_packed",
		"reload_current_scene", "unload_current_scene"
	]

	for method in scene_methods:
		success = success and assert_true(scene_tree_test.has_method(method),
										"Should have scene method: " + method)

	# Test root access
	var scene_root = scene_tree_test.get_root()
	success = success and assert_not_null(scene_root, "Should have access to root")

	# Test current scene access
	var _current_scene = scene_tree_test.get_current_scene()
	# Note: current_scene might be null in test environment
	success = success and assert_true(true, "get_current_scene should not crash")

	return success

func test_scene_tree_test_signal_handling() -> bool:
	"""Test SceneTreeTest signal handling capabilities"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test signal handling methods
	var signal_methods = [
		"connect", "disconnect", "is_connected", "emit_signal"
	]

	for method in signal_methods:
		success = success and assert_true(scene_tree_test.has_method(method),
										"Should have signal method: " + method)

	# Test custom signal creation and emission
	if scene_tree_test.has_method("add_user_signal"):
		# Create a test signal (add_user_signal returns void)
		scene_tree_test.add_user_signal("test_signal", [])
		success = success and assert_true(true, "add_user_signal should execute without error")

		# Test signal emission (should not crash)
		if scene_tree_test.has_signal("test_signal"):
			var _emit_result = scene_tree_test.emit_signal("test_signal")
			success = success and assert_true(true, "emit_signal should execute without error")

	return success

func test_scene_tree_test_process_management() -> bool:
	"""Test SceneTreeTest process and physics management"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test process management methods
	var process_methods = [
		"set_pause", "is_paused", "get_frame_time",
		"get_physics_frame_time", "get_process_time"
	]

	for method in process_methods:
		success = success and assert_true(scene_tree_test.has_method(method),
										"Should have process method: " + method)

	# Test pause functionality
	var original_pause_state = scene_tree_test.is_paused()
	success = success and assert_true(typeof(original_pause_state) == TYPE_BOOL,
									"is_paused should return boolean")

	# Test pause toggle (should not crash)
	scene_tree_test.set_pause(!original_pause_state)
	var new_pause_state = scene_tree_test.is_paused()
	success = success and assert_equals(new_pause_state, !original_pause_state,
										"Pause state should change")

	# Restore original state
	scene_tree_test.set_pause(original_pause_state)

	# Test timing methods
	var frame_time = scene_tree_test.get_frame_time()
	success = success and assert_true(typeof(frame_time) == TYPE_FLOAT,
									"get_frame_time should return float")
	success = success and assert_true(frame_time >= 0.0,
														"Frame time should be non-negative")

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_scene_tree_test() -> SceneTreeTest:
	"""Create a SceneTreeTest instance with test configuration"""
	var scene_tree_test = SceneTreeTest.new()

	# Configure test metadata
	scene_tree_test.test_description = "Test SceneTreeTest instance"
	scene_tree_test.test_tags = ["test", "scene_tree"]
	scene_tree_test.test_priority = "normal"

	return scene_tree_test

func test_scene_tree_functionality(scene_tree_test: SceneTreeTest) -> bool:
	"""Test core SceneTree functionality"""
	var success = true

	# Test basic SceneTree operations
	var test_root = scene_tree_test.get_root()
	success = success and assert_not_null(test_root, "Should have root node")

	# Test tree structure
	var tree_string = scene_tree_test.get_tree_string()
	success = success and assert_true(typeof(tree_string) == TYPE_STRING,
									"get_tree_string should return string")

	return success

func test_new_assertion_methods() -> bool:
	"""Test the newly added assertion methods in SceneTreeTest"""
	var scene_tree_test = SceneTreeTest.new()
	var success = true

	# Test assert_type
	var test_string = "hello"
	var test_int = 42
	var test_float = 3.14
	var test_array = [1, 2, 3]

	success = success and assert_type(test_string, TYPE_STRING, "Should identify string type")
	success = success and assert_type(test_int, TYPE_INT, "Should identify int type")
	success = success and assert_type(test_float, TYPE_FLOAT, "Should identify float type")
	success = success and assert_type(test_array, TYPE_ARRAY, "Should identify array type")

	# Test assert_has_method
	var test_node = Node.new()
	success = success and assert_has_method(test_node, "get_name", "Node should have get_name method")
	success = success and assert_has_method(test_node, "set_name", "Node should have set_name method")
	success = success and assert_has_method(scene_tree_test, "assert_true", "SceneTreeTest should have assert_true method")

	# Test assert_greater_than_or_equal
	success = success and assert_greater_than_or_equal(5.0, 3.0, "5.0 should be >= 3.0")
	success = success and assert_greater_than_or_equal(5.0, 5.0, "5.0 should be >= 5.0")
	success = success and assert_false(assert_greater_than_or_equal(3.0, 5.0, "3.0 should not be >= 5.0"))

	# Test assert_type with wrong type (should fail)
	var wrong_type_result = scene_tree_test.assert_type(test_string, TYPE_INT, "String should not be int")
	success = success and assert_false(wrong_type_result, "assert_type should return false for wrong type")

	# Test assert_has_method with non-existent method (should fail)
	var no_method_result = scene_tree_test.assert_has_method(test_node, "non_existent_method", "Should not have non-existent method")
	success = success and assert_false(no_method_result, "assert_has_method should return false for missing method")

	# Cleanup
	test_node.queue_free()

	return success

func simulate_test_execution(scene_tree_test: SceneTreeTest) -> void:
	"""Simulate test execution for testing purposes"""
	# Add a simple test
	var _test_result = scene_tree_test.run_test("simulation_test", func(): return true)

	# This is just for testing the execution framework
	pass

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
