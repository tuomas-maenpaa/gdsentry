# GDSentry - NodeTest Comprehensive Test Suite
# Tests the NodeTest class functionality for node-based component testing
#
# Tests cover:
# - Node interaction and behavior testing
# - Scene hierarchy validation
# - Component testing with complex node relationships
# - Signal testing and node lifecycle validation
# - Node property and method testing
# - Scene management utilities
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name NodeTestTypeTest

# Load NodeTest class for testing
const NodeTestClass = preload("res://base_classes/node_test.gd")

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for NodeTest class"
	test_tags = ["node_test", "component", "hierarchy", "interaction", "signal", "lifecycle", "scene"]
	test_priority = "high"
	test_category = "test_types"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all NodeTest comprehensive tests"""
	run_test("test_node_test_instantiation", func(): return test_node_test_instantiation())
	run_test("test_node_test_configuration", func(): return test_node_test_configuration())
	run_test("test_node_interaction_testing", func(): return test_node_interaction_testing())
	run_test("test_scene_hierarchy_validation", func(): return test_scene_hierarchy_validation())
	run_test("test_component_testing_utilities", func(): return test_component_testing_utilities())
	run_test("test_signal_testing_utilities", func(): return test_signal_testing_utilities())
	run_test("test_node_lifecycle_testing", func(): return test_node_lifecycle_testing())
	run_test("test_scene_management_utilities", func(): return test_scene_management_utilities())
	run_test("test_error_handling", func(): return test_error_handling())
	run_test("test_edge_cases", func(): return test_edge_cases())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_node_test_instantiation() -> bool:
	"""Test that NodeTest can be instantiated correctly"""
	var node_test = NodeTest.new()
	assert_not_null(node_test, "NodeTest should be instantiable")
	assert_equals(node_test.get_class(), "NodeTest", "NodeTest should have correct class name")

	# Check default properties
	assert_equals(node_test.test_category, "node", "Default test category should be 'node'")
	assert_equals(node_test.test_timeout, 30.0, "Default timeout should be 30 seconds")

	node_test.queue_free()
	return true

func test_node_test_configuration() -> bool:
	"""Test NodeTest configuration and metadata"""
	var node_test = NodeTest.new()

	# Test metadata configuration
	node_test.test_description = "Test description"
	node_test.test_tags = ["test", "node"]
	node_test.test_priority = "high"
	node_test.test_category = "component"

	assert_equals(node_test.test_description, "Test description", "Description should be settable")
	assert_equals(node_test.test_tags.size(), 2, "Tags should be configurable")
	assert_equals(node_test.test_priority, "high", "Priority should be settable")
	assert_equals(node_test.test_category, "component", "Category should be settable")

	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# NODE INTERACTION TESTING
# ------------------------------------------------------------------------------
func test_node_interaction_testing() -> bool:
	"""Test node interaction testing capabilities"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Create test nodes
	var parent_node = Node.new()
	parent_node.name = "ParentNode"
	node_test.add_child(parent_node)

	var child_node = Node.new()
	child_node.name = "ChildNode"
	parent_node.add_child(child_node)

	# Test node existence assertions
	assert_true(node_test.assert_node_exists(parent_node, "ChildNode"), "Should find existing child node")
	assert_false(node_test.assert_node_exists(parent_node, "NonExistentNode"), "Should not find non-existent node")

	# Test node type assertions
	assert_true(node_test.assert_node_type(parent_node, "Node"), "Should identify correct node type")
	assert_false(node_test.assert_node_type(parent_node, "Node2D"), "Should reject incorrect node type")

	# Test node script assertions
	assert_true(node_test.assert_node_has_script(parent_node), "Should detect node has script")
	assert_false(node_test.assert_node_has_script(parent_node, "nonexistent.gd"), "Should reject wrong script path")

	# Cleanup
	parent_node.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# SCENE HIERARCHY VALIDATION
# ------------------------------------------------------------------------------
func test_scene_hierarchy_validation() -> bool:
	"""Test scene hierarchy validation capabilities"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Create test hierarchy
	var root = Node.new()
	root.name = "Root"
	node_test.add_child(root)

	var child1 = Node.new()
	child1.name = "Child1"
	root.add_child(child1)

	var child2 = Node.new()
	child2.name = "Child2"
	root.add_child(child2)

	var grandchild = Node.new()
	grandchild.name = "Grandchild"
	child1.add_child(grandchild)

	# Test child count
	assert_true(node_test.assert_child_count(root, 2), "Should have 2 children")
	assert_false(node_test.assert_child_count(root, 3), "Should not have 3 children")

	# Test child existence
	assert_true(node_test.assert_has_child(root, "Child1"), "Should have Child1")
	assert_false(node_test.assert_has_child(root, "NonExistent"), "Should not have NonExistent")

	# Test child order
	assert_true(node_test.assert_child_order(root, ["Child1", "Child2"]), "Children should be in correct order")
	assert_false(node_test.assert_child_order(root, ["Child2", "Child1"]), "Children should not be in reverse order")

	# Test parent relationships
	assert_true(node_test.assert_parent_relationship(child1, root), "Child1 should have Root as parent")
	assert_false(node_test.assert_parent_relationship(child1, child2), "Child1 should not have Child2 as parent")

	# Test sibling relationships
	assert_true(node_test.assert_sibling_relationship(child1, child2), "Child1 and Child2 should be siblings")
	assert_false(node_test.assert_sibling_relationship(child1, grandchild), "Child1 and Grandchild should not be siblings")

	# Cleanup
	root.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# COMPONENT TESTING UTILITIES
# ------------------------------------------------------------------------------
func test_component_testing_utilities() -> bool:
	"""Test component testing utility methods"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Create test node with properties
	var test_node = Node.new()
	test_node.name = "TestNode"
	test_node.set("custom_property", "test_value")
	test_node.set("test_number", 42)
	node_test.add_child(test_node)

	# Test property existence
	assert_true(node_test.assert_property_exists(test_node, "custom_property"), "Should find existing property")
	assert_false(node_test.assert_property_exists(test_node, "nonexistent"), "Should not find non-existent property")

	# Test property values
	assert_true(node_test.assert_property_value(test_node, "custom_property", "test_value"), "Should match property value")
	assert_false(node_test.assert_property_value(test_node, "custom_property", "wrong_value"), "Should reject wrong property value")
	assert_true(node_test.assert_property_value(test_node, "test_number", 42), "Should match numeric property value")

	# Test method existence
	assert_true(node_test.assert_method_exists(test_node, "get_name"), "Should find existing method")
	assert_false(node_test.assert_method_exists(test_node, "nonexistent_method"), "Should not find non-existent method")

	# Test signal existence
	assert_true(node_test.assert_signal_exists(test_node, "ready"), "Should find existing signal")
	assert_false(node_test.assert_signal_exists(test_node, "nonexistent_signal"), "Should not find non-existent signal")

	# Test group membership
	test_node.add_to_group("test_group")
	assert_true(node_test.assert_group_membership(test_node, "test_group"), "Should be in test group")
	assert_false(node_test.assert_group_membership(test_node, "other_group"), "Should not be in other group")

	# Cleanup
	test_node.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# SIGNAL TESTING UTILITIES
# ------------------------------------------------------------------------------
func test_signal_testing_utilities() -> bool:
	"""Test signal testing utility methods"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Create test nodes with signals
	var signal_source = Node.new()
	signal_source.name = "SignalSource"
	var signal_target = Node.new()
	signal_target.name = "SignalTarget"
	node_test.add_child(signal_source)
	node_test.add_child(signal_target)

	# Define a test method for signal connection
	var test_handler = func():
		pass

	# Test signal connection
	signal_source.connect("ready", test_handler)
	# Note: Signal connection detection for lambdas is limited, so we'll test the connection exists
	assert_true(signal_source.is_connected("ready", test_handler), "Signal should be connected")

	# Test signal not connected
	assert_false(node_test.assert_signal_connected(signal_source, "ready", node_test, "nonexistent"), "Should not detect non-existent connection")

	# Test signal not connected assertion
	assert_true(node_test.assert_signal_not_connected(signal_source, "ready", node_test, "other_method"), "Should confirm signal not connected")

	# Cleanup
	signal_source.queue_free()
	signal_target.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# NODE LIFECYCLE TESTING
# ------------------------------------------------------------------------------
func test_node_lifecycle_testing() -> bool:
	"""Test node lifecycle testing methods"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Create test nodes
	var processing_node = Node.new()
	processing_node.name = "ProcessingNode"
	node_test.add_child(processing_node)

	var idle_node = Node.new()
	idle_node.name = "IdleNode"
	idle_node.set_process(false)
	idle_node.set_physics_process(false)
	node_test.add_child(idle_node)

	# Test node in tree
	assert_true(node_test.assert_node_in_tree(processing_node), "Processing node should be in tree")
	assert_true(node_test.assert_node_in_tree(idle_node), "Idle node should be in tree")

	# Test node processing state
	assert_true(node_test.assert_node_processing(processing_node), "Processing node should be processing")
	assert_false(node_test.assert_node_processing(idle_node), "Idle node should not be processing")

	assert_true(node_test.assert_node_physics_processing(processing_node), "Processing node should be physics processing")
	assert_false(node_test.assert_node_physics_processing(idle_node), "Idle node should not be physics processing")

	# Test node not in tree (after removal)
	node_test.remove_child(processing_node)
	assert_false(node_test.assert_node_in_tree(processing_node), "Removed node should not be in tree")
	assert_true(node_test.assert_node_not_in_tree(processing_node), "Removed node should not be in tree")

	# Cleanup
	processing_node.queue_free()
	idle_node.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# SCENE MANAGEMENT UTILITIES
# ------------------------------------------------------------------------------
func test_scene_management_utilities() -> bool:
	"""Test scene management utility methods"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Test node creation
	var test_node = node_test.create_test_node("Node", "TestNode")
	assert_not_null(test_node, "Should create test node")
	assert_equals(test_node.name, "TestNode", "Should set correct name")
	assert_equals(test_node.get_class(), "Node", "Should create correct type")

	# Test different node types
	var node2d = node_test.create_test_node("Node2D", "TestNode2D")
	assert_equals(node2d.get_class(), "Node2D", "Should create Node2D")

	var control = node_test.create_test_node("Control", "TestControl")
	assert_equals(control.get_class(), "Control", "Should create Control")

	# Test node finding by type
	var all_nodes = node_test.find_nodes_by_type(node_test, "Node")
	assert_true(all_nodes.size() >= 3, "Should find multiple nodes")

	var node2d_nodes = node_test.find_nodes_by_type(node_test, "Node2D")
	assert_true(node2d_nodes.size() >= 1, "Should find Node2D nodes")

	var control_nodes = node_test.find_nodes_by_type(node_test, "Control")
	assert_true(control_nodes.size() >= 1, "Should find Control nodes")

	# Test node finding by name
	var named_nodes = node_test.find_nodes_by_name(node_test, "TestNode")
	assert_equals(named_nodes.size(), 1, "Should find one TestNode")
	assert_equals(named_nodes[0].name, "TestNode", "Should find correct node")

	# Cleanup
	test_node.queue_free()
	node2d.queue_free()
	control.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Create test nodes
	var test_node = Node.new()
	test_node.name = "TestNode"
	node_test.add_child(test_node)

	# Test with null nodes
	var null_node: Node = null
	assert_false(node_test.assert_node_exists(test_node, "nonexistent"), "Should handle missing nodes gracefully")
	assert_false(node_test.assert_node_type(null_node, "Node"), "Should handle null nodes gracefully")

	# Test with invalid paths
	assert_false(node_test.assert_node_exists(test_node, "../../../invalid/path"), "Should handle invalid paths")

	# Test with non-existent properties
	assert_false(node_test.assert_property_exists(test_node, "nonexistent_property"), "Should handle non-existent properties")
	assert_false(node_test.assert_property_value(test_node, "nonexistent_property", "value"), "Should handle property value checks on non-existent properties")

	# Test with non-existent methods
	assert_false(node_test.assert_method_exists(test_node, "nonexistent_method"), "Should handle non-existent methods")

	# Test with non-existent signals
	assert_false(node_test.assert_signal_exists(test_node, "nonexistent_signal"), "Should handle non-existent signals")

	# Cleanup
	test_node.queue_free()
	node_test.queue_free()
	return true

# ------------------------------------------------------------------------------
# EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_edge_cases() -> bool:
	"""Test edge cases and boundary conditions"""
	var node_test = NodeTest.new()
	add_child(node_test)

	# Test with empty node hierarchies
	var empty_node = Node.new()
	empty_node.name = "EmptyNode"
	node_test.add_child(empty_node)

	assert_true(node_test.assert_child_count(empty_node, 0), "Empty node should have 0 children")
	assert_false(node_test.assert_has_child(empty_node, "any_child"), "Empty node should not have children")

	# Test with deeply nested hierarchies
	var root = Node.new()
	root.name = "Root"
	node_test.add_child(root)

	var current = root
	for i in range(10):
		var child = Node.new()
		child.name = "Level" + str(i)
		current.add_child(child)
		current = child

	# Test deep hierarchy navigation
	var deep_path = "Level0/Level1/Level2/Level3/Level4"
	assert_true(node_test.assert_node_exists(root, deep_path), "Should navigate deep hierarchies")

	# Test with special characters in names
	var special_node = Node.new()
	special_node.name = "Node@#$%^&*()"
	node_test.add_child(special_node)

	assert_true(node_test.assert_has_child(node_test, "Node@#$%^&*()"), "Should handle special characters in names")

	# Test with very long names
	var long_name = "A".repeat(100)
	var long_name_node = Node.new()
	long_name_node.name = long_name
	node_test.add_child(long_name_node)

	assert_true(node_test.assert_has_child(node_test, long_name), "Should handle very long names")

	# Test with duplicate names
	var dup1 = Node.new()
	dup1.name = "Duplicate"
	node_test.add_child(dup1)

	var dup2 = Node.new()
	dup2.name = "Duplicate"
	node_test.add_child(dup2)

	var duplicates = node_test.find_nodes_by_name(node_test, "Duplicate")
	assert_equals(duplicates.size(), 2, "Should find both duplicate nodes")

	# Cleanup
	empty_node.queue_free()
	root.queue_free()
	special_node.queue_free()
	long_name_node.queue_free()
	dup1.queue_free()
	dup2.queue_free()
	node_test.queue_free()
	return true
