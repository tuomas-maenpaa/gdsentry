# GDSentry - NodeTest Base Class Test Suite
# Tests the NodeTest base class functionality and all its specialized methods
#
# Tests cover:
# - NodeTest inheritance and basic functionality
# - All 26 node-specific assertions
# - Scene management utilities
# - Signal testing methods
# - Node lifecycle validation
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends NodeTest

class_name NodeTestBaseTest

# NodeTest class is loaded via extends NodeTest above

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for NodeTest base class"
	test_tags = ["base_class", "node_test", "assertions", "scene", "signals", "lifecycle"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all NodeTest base class tests"""
	run_test("test_nodetest_inheritance", func(): return test_nodetest_inheritance())
	run_test("test_nodetest_basic_functionality", func(): return test_nodetest_basic_functionality())

	# Node interaction assertions
	run_test("test_node_exists_assertions", func(): return test_node_exists_assertions())
	run_test("test_node_not_exists_assertions", func(): return test_node_not_exists_assertions())
	run_test("test_node_type_assertions", func(): return test_node_type_assertions())
	run_test("test_node_has_script_assertions", func(): return test_node_has_script_assertions())

	# Scene hierarchy assertions
	run_test("test_child_count_assertions", func(): return test_child_count_assertions())
	run_test("test_has_child_assertions", func(): return test_has_child_assertions())
	run_test("test_child_order_assertions", func(): return test_child_order_assertions())
	run_test("test_parent_relationship_assertions", func(): return test_parent_relationship_assertions())
	run_test("test_sibling_relationship_assertions", func(): return test_sibling_relationship_assertions())

	# Component testing assertions
	run_test("test_property_exists_assertions", func(): return test_property_exists_assertions())
	run_test("test_property_value_assertions", func(): return test_property_value_assertions())
	run_test("test_method_exists_assertions", func(): return test_method_exists_assertions())
	run_test("test_signal_exists_assertions", func(): return test_signal_exists_assertions())
	run_test("test_group_membership_assertions", func(): return test_group_membership_assertions())

	# Signal testing assertions
	run_test("test_signal_connected_assertions", func(): return test_signal_connected_assertions())
	run_test("test_signal_not_connected_assertions", func(): return test_signal_not_connected_assertions())

	# Node lifecycle assertions
	run_test("test_node_in_tree_assertions", func(): return test_node_in_tree_assertions())
	run_test("test_node_not_in_tree_assertions", func(): return test_node_not_in_tree_assertions())
	run_test("test_node_processing_assertions", func(): return test_node_processing_assertions())
	run_test("test_node_physics_processing_assertions", func(): return test_node_physics_processing_assertions())

	# Scene management utilities
	run_test("test_create_test_node", func(): return test_create_test_node())
	run_test("test_find_nodes_by_type", func(): return test_find_nodes_by_type())
	run_test("test_find_nodes_by_name", func(): return test_find_nodes_by_name())
	run_test("test_load_test_scene", func(): return test_load_test_scene())

	# Error handling
	run_test("test_error_handling", func(): return test_error_handling())
	run_test("test_edge_cases", func(): return test_edge_cases())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_nodetest_inheritance() -> bool:
	"""Test that NodeTest properly inherits from Node and integrates with GDTest"""
	# Verify class inheritance
	assert_equals(get_class(), "NodeTestTest", "Should have correct class name")
	assert_true(is_inside_tree(), "Should be in scene tree")

	# Verify NodeTest specific properties
	assert_equals(test_category, "node", "Should have node category")

	# Verify we inherit from Node
	assert_true(self is Node, "Should inherit from Node")

	return true

func test_nodetest_basic_functionality() -> bool:
	"""Test basic NodeTest functionality"""
	# Test that we can access NodeTest methods
	assert_true(has_method("assert_node_exists"), "Should have node-specific assertion methods")
	assert_true(has_method("create_test_node"), "Should have scene management methods")
	assert_true(has_method("find_nodes_by_type"), "Should have search methods")

	return true

# ------------------------------------------------------------------------------
# NODE INTERACTION ASSERTIONS
# ------------------------------------------------------------------------------
func test_node_exists_assertions() -> bool:
	"""Test node exists assertions"""
	var root = create_test_node("Node", "Root")
	var child = create_test_node("Node", "Child")
	root.add_child(child)

	# Test successful assertions
	assert_true(assert_node_exists(root, "Child"), "Should find existing child")
	assert_true(assert_node_exists(root, "."), "Should find root itself")

	# Test failing assertions
	assert_false(assert_node_exists(root, "NonExistent"), "Should not find non-existent node")

	root.queue_free()
	return true

func test_node_not_exists_assertions() -> bool:
	"""Test node not exists assertions"""
	var root = create_test_node("Node", "Root")

	# Test successful assertions
	assert_true(assert_node_not_exists(root, "NonExistent"), "Should confirm non-existent node")

	# Test failing assertions (this should actually fail in a test context)
	var child = create_test_node("Node", "Child")
	root.add_child(child)
	assert_false(assert_node_not_exists(root, "Child"), "Should find existing child")

	root.queue_free()
	return true

func test_node_type_assertions() -> bool:
	"""Test node type assertions"""
	var node = create_test_node("Node", "TestNode")
	var node2d = create_test_node("Node2D", "TestNode2D")

	# Test successful assertions
	assert_true(assert_node_type(node, "Node"), "Should identify Node type")
	assert_true(assert_node_type(node2d, "Node2D"), "Should identify Node2D type")

	# Test failing assertions
	assert_false(assert_node_type(node, "Node2D"), "Should reject wrong type")

	node.queue_free()
	node2d.queue_free()
	return true

func test_node_has_script_assertions() -> bool:
	"""Test node has script assertions"""
	var node = create_test_node("Node", "TestNode")

	# Test successful assertions
	assert_true(assert_node_has_script(node), "Should detect node has script")

	# Test with specific script path (this will likely fail since we don't have a specific script)
	assert_false(assert_node_has_script(node, "nonexistent.gd"), "Should reject wrong script path")

	node.queue_free()
	return true

# ------------------------------------------------------------------------------
# SCENE HIERARCHY ASSERTIONS
# ------------------------------------------------------------------------------
func test_child_count_assertions() -> bool:
	"""Test child count assertions"""
	var root = create_test_node("Node", "Root")

	# Test with no children
	assert_true(assert_child_count(root, 0), "Should have 0 children initially")

	# Add children and test
	var child1 = create_test_node("Node", "Child1")
	var child2 = create_test_node("Node", "Child2")
	root.add_child(child1)
	root.add_child(child2)

	assert_true(assert_child_count(root, 2), "Should have 2 children")
	assert_false(assert_child_count(root, 3), "Should not have 3 children")

	root.queue_free()
	return true

func test_has_child_assertions() -> bool:
	"""Test has child assertions"""
	var root = create_test_node("Node", "Root")
	var child = create_test_node("Node", "Child")
	root.add_child(child)

	# Test successful assertions
	assert_true(assert_has_child(root, "Child"), "Should find child")

	# Test failing assertions
	assert_false(assert_has_child(root, "NonExistent"), "Should not find non-existent child")

	root.queue_free()
	return true

func test_child_order_assertions() -> bool:
	"""Test child order assertions"""
	var root = create_test_node("Node", "Root")

	var child1 = create_test_node("Node", "Child1")
	var child2 = create_test_node("Node", "Child2")
	var child3 = create_test_node("Node", "Child3")

	root.add_child(child1)
	root.add_child(child2)
	root.add_child(child3)

	# Test correct order
	assert_true(assert_child_order(root, ["Child1", "Child2", "Child3"]), "Should match correct order")

	# Test wrong order
	assert_false(assert_child_order(root, ["Child1", "Child3", "Child2"]), "Should reject wrong order")

	root.queue_free()
	return true

func test_parent_relationship_assertions() -> bool:
	"""Test parent relationship assertions"""
	var root = create_test_node("Node", "Root")
	var child = create_test_node("Node", "Child")
	root.add_child(child)

	# Test successful assertions
	assert_true(assert_parent_relationship(child, root), "Should have correct parent relationship")

	# Test failing assertions
	var other = create_test_node("Node", "Other")
	assert_false(assert_parent_relationship(child, other), "Should reject wrong parent")

	root.queue_free()
	other.queue_free()
	return true

func test_sibling_relationship_assertions() -> bool:
	"""Test sibling relationship assertions"""
	var root = create_test_node("Node", "Root")

	var child1 = create_test_node("Node", "Child1")
	var child2 = create_test_node("Node", "Child2")
	var child3 = create_test_node("Node", "Child3")

	root.add_child(child1)
	root.add_child(child2)
	root.add_child(child3)

	# Test successful assertions
	assert_true(assert_sibling_relationship(child1, child2), "Should be siblings")
	assert_true(assert_sibling_relationship(child2, child3), "Should be siblings")

	# Test failing assertions (not siblings)
	assert_false(assert_sibling_relationship(child1, root), "Parent-child should not be siblings")

	root.queue_free()
	return true

# ------------------------------------------------------------------------------
# COMPONENT TESTING ASSERTIONS
# ------------------------------------------------------------------------------
func test_property_exists_assertions() -> bool:
	"""Test property exists assertions"""
	var node = create_test_node("Node", "TestNode")
	node.set("custom_property", "test_value")

	# Test successful assertions
	assert_true(assert_property_exists(node, "custom_property"), "Should find existing property")
	assert_true(assert_property_exists(node, "name"), "Should find built-in property")

	# Test failing assertions
	assert_false(assert_property_exists(node, "nonexistent"), "Should not find non-existent property")

	node.queue_free()
	return true

func test_property_value_assertions() -> bool:
	"""Test property value assertions"""
	var node = create_test_node("Node", "TestNode")
	node.set("custom_property", "test_value")
	node.set("test_number", 42)

	# Test successful assertions
	assert_true(assert_property_value(node, "custom_property", "test_value"), "Should match string value")
	assert_true(assert_property_value(node, "test_number", 42), "Should match numeric value")
	assert_true(assert_property_value(node, "name", "TestNode"), "Should match built-in property")

	# Test failing assertions
	assert_false(assert_property_value(node, "custom_property", "wrong_value"), "Should reject wrong value")
	assert_false(assert_property_value(node, "nonexistent", "value"), "Should reject non-existent property")

	node.queue_free()
	return true

func test_method_exists_assertions() -> bool:
	"""Test method exists assertions"""
	var node = create_test_node("Node", "TestNode")

	# Test successful assertions
	assert_true(assert_method_exists(node, "get_name"), "Should find existing method")
	assert_true(assert_method_exists(node, "set_name"), "Should find built-in method")

	# Test failing assertions
	assert_false(assert_method_exists(node, "nonexistent_method"), "Should not find non-existent method")

	node.queue_free()
	return true

func test_signal_exists_assertions() -> bool:
	"""Test signal exists assertions"""
	var node = create_test_node("Node", "TestNode")

	# Test successful assertions
	assert_true(assert_signal_exists(node, "ready"), "Should find ready signal")
	assert_true(assert_signal_exists(node, "tree_entered"), "Should find tree_entered signal")

	# Test failing assertions
	assert_false(assert_signal_exists(node, "nonexistent_signal"), "Should not find non-existent signal")

	node.queue_free()
	return true

func test_group_membership_assertions() -> bool:
	"""Test group membership assertions"""
	var node = create_test_node("Node", "TestNode")
	node.add_to_group("test_group")

	# Test successful assertions
	assert_true(assert_group_membership(node, "test_group"), "Should be in group")

	# Test failing assertions
	assert_false(assert_group_membership(node, "other_group"), "Should not be in other group")

	node.queue_free()
	return true

# ------------------------------------------------------------------------------
# SIGNAL TESTING ASSERTIONS
# ------------------------------------------------------------------------------
func test_signal_connected_assertions() -> bool:
	"""Test signal connected assertions"""
	var source = create_test_node("Node", "Source")
	var target = create_test_node("Node", "Target")

	var test_handler = func():
		pass

	# Connect signal
	source.connect("ready", test_handler)

	# Note: This is a simplified test since signal connection detection is complex
	# In a real scenario, we'd need more sophisticated signal tracking
	assert_true(source.is_connected("ready", test_handler), "Signal should be connected")

	source.queue_free()
	target.queue_free()
	return true

func test_signal_not_connected_assertions() -> bool:
	"""Test signal not connected assertions"""
	var source = create_test_node("Node", "Source")
	var target = create_test_node("Node", "Target")

	var test_handler = func():
		pass

	# Don't connect signal - should not be connected
	assert_false(source.is_connected("ready", test_handler), "Signal should not be connected")

	source.queue_free()
	target.queue_free()
	return true

# ------------------------------------------------------------------------------
# NODE LIFECYCLE ASSERTIONS
# ------------------------------------------------------------------------------
func test_node_in_tree_assertions() -> bool:
	"""Test node in tree assertions"""
	var node = create_test_node("Node", "TestNode")

	# Test successful assertions (node should be in tree since we added it)
	assert_true(assert_node_in_tree(node), "Node should be in tree")

	# Test failing assertions by removing node
	remove_child(node)
	assert_false(assert_node_in_tree(node), "Removed node should not be in tree")

	node.queue_free()
	return true

func test_node_not_in_tree_assertions() -> bool:
	"""Test node not in tree assertions"""
	var node = create_test_node("Node", "TestNode")

	# Remove node from tree
	remove_child(node)

	# Test successful assertions
	assert_true(assert_node_not_in_tree(node), "Removed node should not be in tree")

	node.queue_free()
	return true

func test_node_processing_assertions() -> bool:
	"""Test node processing assertions"""
	var node = create_test_node("Node", "TestNode")

	# Test successful assertions (nodes process by default)
	assert_true(assert_node_processing(node), "Node should be processing by default")

	# Disable processing and test
	node.set_process(false)
	assert_false(assert_node_processing(node), "Disabled node should not be processing")

	node.queue_free()
	return true

func test_node_physics_processing_assertions() -> bool:
	"""Test node physics processing assertions"""
	var node = create_test_node("Node", "TestNode")

	# Test successful assertions (nodes process physics by default)
	assert_true(assert_node_physics_processing(node), "Node should be physics processing by default")

	# Disable physics processing and test
	node.set_physics_process(false)
	assert_false(assert_node_physics_processing(node), "Disabled node should not be physics processing")

	node.queue_free()
	return true

# ------------------------------------------------------------------------------
# SCENE MANAGEMENT UTILITIES
# ------------------------------------------------------------------------------
func test_create_test_node() -> bool:
	"""Test create_test_node utility"""
	# Test creating different node types
	var node = create_test_node("Node", "TestNode")
	var node2d = create_test_node("Node2D", "TestNode2D")
	var control = create_test_node("Control", "TestControl")

	# Verify creation
	assert_not_null(node, "Should create Node")
	assert_not_null(node2d, "Should create Node2D")
	assert_not_null(control, "Should create Control")

	# Verify types
	assert_equals(node.get_class(), "Node", "Should be Node type")
	assert_equals(node2d.get_class(), "Node2D", "Should be Node2D type")
	assert_equals(control.get_class(), "Control", "Should be Control type")

	# Verify names
	assert_equals(node.name, "TestNode", "Should have correct name")
	assert_equals(node2d.name, "TestNode2D", "Should have correct name")
	assert_equals(control.name, "TestControl", "Should have correct name")

	# Cleanup
	node.queue_free()
	node2d.queue_free()
	control.queue_free()
	return true

func test_find_nodes_by_type() -> bool:
	"""Test find_nodes_by_type utility"""
	var root = create_test_node("Node", "Root")
	var node1 = create_test_node("Node", "Node1")
	var node2 = create_test_node("Node2D", "Node2D1")
	var node3 = create_test_node("Node", "Node2")
	var node4 = create_test_node("Control", "Control1")

	root.add_child(node1)
	root.add_child(node2)
	root.add_child(node3)
	root.add_child(node4)

	# Test finding all nodes
	var all_nodes = find_nodes_by_type(root, "Node")
	assert_equals(all_nodes.size(), 3, "Should find 3 Node instances")

	# Test finding Node2D nodes
	var node2d_nodes = find_nodes_by_type(root, "Node2D")
	assert_equals(node2d_nodes.size(), 1, "Should find 1 Node2D instance")

	# Test finding Control nodes
	var control_nodes = find_nodes_by_type(root, "Control")
	assert_equals(control_nodes.size(), 1, "Should find 1 Control instance")

	root.queue_free()
	return true

func test_find_nodes_by_name() -> bool:
	"""Test find_nodes_by_name utility"""
	var root = create_test_node("Node", "Root")
	var node1 = create_test_node("Node", "Target")
	var node2 = create_test_node("Node", "Target")  # Duplicate name
	var node3 = create_test_node("Node", "Other")

	root.add_child(node1)
	root.add_child(node2)
	root.add_child(node3)

	# Test finding nodes by name
	var target_nodes = find_nodes_by_name(root, "Target")
	assert_equals(target_nodes.size(), 2, "Should find 2 nodes with Target name")

	var other_nodes = find_nodes_by_name(root, "Other")
	assert_equals(other_nodes.size(), 1, "Should find 1 node with Other name")

	var nonexistent_nodes = find_nodes_by_name(root, "NonExistent")
	assert_equals(nonexistent_nodes.size(), 0, "Should find 0 nodes with non-existent name")

	root.queue_free()
	return true

func test_load_test_scene() -> bool:
	"""Test load_test_scene utility"""
	# This test is limited since we don't have actual scene files to load
	# In a real scenario, we'd test with actual scene files

	# Test with non-existent scene (should return null)
	var result = load_test_scene("nonexistent_scene.tscn")
	assert_null(result, "Should return null for non-existent scene")

	return true

# ------------------------------------------------------------------------------
# ERROR HANDLING AND EDGE CASES
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling in NodeTest methods"""
	# Test with null nodes
	var null_node: Node = null

	# These should handle null gracefully without crashing
	assert_false(assert_node_exists(null_node, "test"), "Should handle null root node")
	assert_false(assert_node_type(null_node, "Node"), "Should handle null node for type check")

	return true

func test_edge_cases() -> bool:
	"""Test edge cases in NodeTest functionality"""
	# Test with empty strings
	var node = create_test_node("Node", "")

	# Test with special characters in names
	var special_node = create_test_node("Node", "Node@#$%^&*()")
	assert_equals(special_node.name, "Node@#$%^&*()", "Should handle special characters in names")

	# Test with very long names
	var long_name = "A".repeat(100)
	var long_name_node = create_test_node("Node", long_name)
	assert_equals(long_name_node.name, long_name, "Should handle very long names")

	# Test with duplicate names in find operations
	var root = create_test_node("Node", "Root")
	var dup1 = create_test_node("Node", "Duplicate")
	var dup2 = create_test_node("Node", "Duplicate")

	root.add_child(dup1)
	root.add_child(dup2)

	var duplicates = find_nodes_by_name(root, "Duplicate")
	assert_equals(duplicates.size(), 2, "Should find both duplicate nodes")

	# Cleanup
	node.queue_free()
	special_node.queue_free()
	long_name_node.queue_free()
	root.queue_free()

	return true
