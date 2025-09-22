# GDSentry - Node Test Base Class
# Base class for component testing with scene hierarchy support
#
# Ideal for:
# - Node interaction and behavior testing
# - Scene hierarchy validation
# - Component testing with complex node relationships
# - Signal testing and node lifecycle validation
# - Node property and method testing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name NodeTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
@export var test_description: String = ""
@export var test_tags: Array[String] = []
@export var test_priority: String = "normal"
@export var test_timeout: float = 30.0
@export var test_category: String = "node"

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
	headless_mode = GDTestManager.is_headless_mode()

	# Initialize test results
	test_results = GDTestManager.create_test_results()

	# Defensive programming: Ensure test_results has required structure
	if not test_results.has("start_time"):
		push_error("NodeTest: test_results dictionary missing required 'start_time' property")
		test_results.start_time = 0.0  # Fallback

	test_results.start_time = Time.get_unix_time_from_system()
	test_start_time = test_results.start_time  # Backup for fallback

	# Setup headless shutdown if needed
	if headless_mode:
		GDTestManager.setup_headless_shutdown(self, test_timeout)

	# Log test start
	GDTestManager.log_test_start(get_test_suite_name())

	# Run test suite
	run_test_suite()

func _exit_tree() -> void:
	"""Cleanup when test finishes"""
	# Defensive programming: Ensure test_results has required structure
	if not test_results.has("start_time"):
		# Fallback initialization if start_time is missing
		if test_results.is_empty():
			test_results = GDTestManager.create_test_results()

		# Set default start_time if missing (use current time as fallback)
		test_results.start_time = test_start_time if test_start_time > 0.0 else Time.get_unix_time_from_system()

	# Set end time
	test_results.end_time = Time.get_unix_time_from_system()

	# Calculate execution time safely
	var start_time = test_results.get("start_time", test_results.end_time)
	var end_time = test_results.end_time
	test_results.execution_time = GDTestManager.calculate_execution_time(start_time, end_time)

	# Print final results
	GDTestManager.print_test_results(test_results, get_test_suite_name())

# ------------------------------------------------------------------------------
# ABSTRACT METHODS (TO BE OVERRIDDEN)
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Override this method to define your test suite"""
	push_error("NodeTest.run_test_suite() must be overridden in subclass")
	pass

# ------------------------------------------------------------------------------
# TEST EXECUTION HELPERS
# ------------------------------------------------------------------------------
func run_test(test_method_name: String, test_callable: Callable) -> bool:
	"""Execute a single test method with proper error handling"""
	current_test_name = test_method_name
	var start_time = Time.get_time_dict_from_system()["second"]

	GDTestManager.log_test_info(get_test_suite_name(), "Running: " + test_method_name)

	var success = true
	var error_message = ""

	# Execute test with error handling
	var result = test_callable.call()
	if result is bool:
		success = result
	elif result is GDScript:
		# Handle async tests
		if result.has_method("call"):
			success = await result.call()
	else:
		success = true  # Assume success if no explicit return

	var end_time = Time.get_time_dict_from_system()["second"]
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
# NODE INTERACTION TESTING
# ------------------------------------------------------------------------------
func assert_node_exists(root: Node, path: String, message: String = "") -> bool:
	"""Assert that a node exists at the given path"""
	var node = root.get_node_or_null(path)
	if node == null:
		var error_msg = message if not message.is_empty() else "Node not found at path: %s" % path
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_node_not_exists(root: Node, path: String, message: String = "") -> bool:
	"""Assert that a node does not exist at the given path"""
	var node = root.get_node_or_null(path)
	if node != null:
		var error_msg = message if not message.is_empty() else "Node unexpectedly found at path: %s" % path
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_node_type(node: Node, expected_type: String, message: String = "") -> bool:
	"""Assert that a node is of the expected type"""
	if node.get_class() != expected_type:
		var error_msg = message if not message.is_empty() else "Node %s is of type %s, expected %s" % [node.name, node.get_class(), expected_type]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_node_has_script(node: Node, expected_script_path: String = "", message: String = "") -> bool:
	"""Assert that a node has a script attached"""
	if node.get_script() == null:
		var error_msg = message if not message.is_empty() else "Node %s has no script attached" % node.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if not expected_script_path.is_empty():
		var script_path = node.get_script().get_path()
		if script_path != expected_script_path:
			var error_msg = message if not message.is_empty() else "Node script path %s doesn't match expected %s" % [script_path, expected_script_path]
			GDTestManager.log_test_failure(current_test_name, error_msg)
			return false

	return true

# ------------------------------------------------------------------------------
# SCENE HIERARCHY VALIDATION
# ------------------------------------------------------------------------------
func assert_child_count(parent: Node, expected_count: int, message: String = "") -> bool:
	"""Assert that a node has the expected number of children"""
	var actual_count = parent.get_child_count()
	if actual_count != expected_count:
		var error_msg = message if not message.is_empty() else "Node %s has %d children, expected %d" % [parent.name, actual_count, expected_count]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_has_child(parent: Node, child_name: String, message: String = "") -> bool:
	"""Assert that a node has a specific child"""
	if not parent.has_node(child_name):
		var error_msg = message if not message.is_empty() else "Node %s does not have child: %s" % [parent.name, child_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_child_order(parent: Node, child_names: Array[String], message: String = "") -> bool:
	"""Assert that children are in the expected order"""
	for i in range(child_names.size()):
		if i >= parent.get_child_count() or parent.get_child(i).name != child_names[i]:
			var error_msg = message if not message.is_empty() else "Child order doesn't match expected sequence: %s" % child_names
			GDTestManager.log_test_failure(current_test_name, error_msg)
			return false
	return true

func assert_parent_relationship(child: Node, expected_parent: Node, message: String = "") -> bool:
	"""Assert that a node has the expected parent"""
	if child.get_parent() != expected_parent:
		var actual_parent = child.get_parent()
		var parent_name = actual_parent.name if actual_parent != null else "null"
		var expected_name: String
		if expected_parent != null:
			expected_name = expected_parent.name
		else:
			expected_name = "null"
		var error_msg = message if not message.is_empty() else "Node %s has parent %s, expected %s" % [child.name, parent_name, expected_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_sibling_relationship(node1: Node, node2: Node, message: String = "") -> bool:
	"""Assert that two nodes are siblings (same parent)"""
	if node1.get_parent() != node2.get_parent():
		var error_msg = message if not message.is_empty() else "Nodes %s and %s are not siblings" % [node1.name, node2.name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# COMPONENT TESTING UTILITIES
# ------------------------------------------------------------------------------
func assert_property_exists(node: Node, property_name: String, message: String = "") -> bool:
	"""Assert that a node has a specific property"""
	if not property_name in node:
		var error_msg = message if not message.is_empty() else "Node %s does not have property: %s" % [node.name, property_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_property_value(node: Node, property_name: String, expected_value: Variant, message: String = "") -> bool:
	"""Assert that a node property has the expected value"""
	if not property_name in node:
		var error_msg = message if not message.is_empty() else "Node %s does not have property: %s" % [node.name, property_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var actual_value = node.get(property_name)
	if actual_value != expected_value:
		var error_msg = message if not message.is_empty() else "Property %s value %s doesn't match expected %s" % [property_name, actual_value, expected_value]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_method_exists(node: Node, method_name: String, message: String = "") -> bool:
	"""Assert that a node has a specific method"""
	if not node.has_method(method_name):
		var error_msg = message if not message.is_empty() else "Node %s does not have method: %s" % [node.name, method_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_signal_exists(node: Node, signal_name: String, message: String = "") -> bool:
	"""Assert that a node has a specific signal"""
	var signal_list = node.get_signal_list()
	var signal_exists = false
	for signal_info in signal_list:
		if signal_info.name == signal_name:
			signal_exists = true
			break

	if not signal_exists:
		var error_msg = message if not message.is_empty() else "Node %s does not have signal: %s" % [node.name, signal_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_group_membership(node: Node, group_name: String, message: String = "") -> bool:
	"""Assert that a node is in a specific group"""
	if not node.is_in_group(group_name):
		var error_msg = message if not message.is_empty() else "Node %s is not in group: %s" % [node.name, group_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# SIGNAL TESTING UTILITIES
# ------------------------------------------------------------------------------
func assert_signal_connected(source: Node, signal_name: String, target: Node, method_name: String, message: String = "") -> bool:
	"""Assert that a signal is connected to a specific method"""
	var connections = source.get_signal_connection_list(signal_name)
	for connection in connections:
		if connection.callable.get_object() == target and connection.callable.get_method() == method_name:
			return true

	var error_msg = message if not message.is_empty() else "Signal %s is not connected from %s to %s.%s" % [signal_name, source.name, target.name, method_name]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_signal_not_connected(source: Node, signal_name: String, target: Node, method_name: String, message: String = "") -> bool:
	"""Assert that a signal is not connected to a specific method"""
	var connections = source.get_signal_connection_list(signal_name)
	for connection in connections:
		if connection.callable.get_object() == target and connection.callable.get_method() == method_name:
			var error_msg = message if not message.is_empty() else "Signal %s should not be connected from %s to %s.%s" % [signal_name, source.name, target.name, method_name]
			GDTestManager.log_test_failure(current_test_name, error_msg)
			return false
	return true

# ------------------------------------------------------------------------------
# NODE LIFECYCLE TESTING
# ------------------------------------------------------------------------------
func assert_node_in_tree(node: Node, message: String = "") -> bool:
	"""Assert that a node is currently in the scene tree"""
	if not node.is_inside_tree():
		var error_msg = message if not message.is_empty() else "Node %s is not in the scene tree" % node.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_node_not_in_tree(node: Node, message: String = "") -> bool:
	"""Assert that a node is not in the scene tree"""
	if node.is_inside_tree():
		var error_msg = message if not message.is_empty() else "Node %s should not be in the scene tree" % node.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_node_processing(node: Node, message: String = "") -> bool:
	"""Assert that a node is processing (receiving _process calls)"""
	if not node.is_processing():
		var error_msg = message if not message.is_empty() else "Node %s is not processing" % node.name
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_node_physics_processing(node: Node, message: String = "") -> bool:
	"""Assert that a node is processing physics (_physics_process calls)"""
	if not node.is_physics_processing():
		var error_msg = message if not message.is_empty() else "Node %s is not processing physics" % node.name
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

func create_test_node(node_type: String = "Node", node_name: String = "") -> Node:
	"""Create a test node of the specified type"""
	var node: Node = null

	match node_type:
		"Node":
			node = Node.new()
		"Node2D":
			node = Node2D.new()
		"Node3D":
			node = Node3D.new()
		"Control":
			node = Control.new()
		"Timer":
			node = Timer.new()
		"HTTPRequest":
			node = HTTPRequest.new()
		_:
			# Try to create node by class name
			if ClassDB.class_exists(node_type):
				node = ClassDB.instantiate(node_type)
			else:
				push_error("NodeTest: Unknown node type: " + node_type)
				return null

	if node and not node_name.is_empty():
		node.name = node_name

	if node:
		add_child(node)

	return node

func find_nodes_by_type(root: Node, node_type: String) -> Array[Node]:
	"""Find all nodes of a specific type in the hierarchy"""
	var result: Array[Node] = []

	if root.get_class() == node_type:
		result.append(root)

	for child in root.get_children():
		result.append_array(find_nodes_by_type(child, node_type))

	return result

func find_nodes_by_name(root: Node, node_name: String) -> Array[Node]:
	"""Find all nodes with a specific name in the hierarchy"""
	var result: Array[Node] = []

	if root.name == node_name:
		result.append(root)

	for child in root.get_children():
		result.append_array(find_nodes_by_name(child, node_name))

	return result

# ------------------------------------------------------------------------------
# GENERAL ASSERTION METHODS (FROM GDTest)
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

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func get_test_suite_name() -> String:
	"""Get the name of this test suite"""
	return get_class() if not get_class().is_empty() else "NodeTest"

func wait_for_next_frame() -> void:
	"""Wait for the next frame"""
	await get_tree().process_frame

func wait_for_physics_frame() -> void:
	"""Wait for the next physics frame"""
	await get_tree().physics_frame

func wait_for_seconds(seconds: float) -> void:
	"""Wait for a specified number of seconds"""
	await get_tree().create_timer(seconds).timeout

func simulate_frames(count: int = 1) -> void:
	"""Simulate multiple frames for testing"""
	for i in range(count):
		await get_tree().process_frame
