# GDSentry - Test Resource Manager
# Centralized resource management for test execution
#
# Features:
# - Resource tracking and cleanup
# - Memory leak prevention
# - Automatic cleanup on test failure
# - Resource usage monitoring
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestResourceManager

# ------------------------------------------------------------------------------
# RESOURCE TRACKING
# ------------------------------------------------------------------------------
var tracked_resources: Array[Resource] = []
var tracked_nodes: Array[Node] = []
var tracked_timers: Array[Timer] = []
var tracked_objects: Array[Object] = []

# ------------------------------------------------------------------------------
# RESOURCE MANAGEMENT
# ------------------------------------------------------------------------------
func track_resource(resource: Resource) -> void:
	"""Track a resource for automatic cleanup"""
	if resource and not tracked_resources.has(resource):
		tracked_resources.append(resource)

func track_node(node: Node) -> void:
	"""Track a node for automatic cleanup"""
	if node and not tracked_nodes.has(node):
		tracked_nodes.append(node)

func track_timer(timer: Timer) -> void:
	"""Track a timer for automatic cleanup"""
	if timer and not tracked_timers.has(timer):
		tracked_timers.append(timer)

func track_object(obj: Object) -> void:
	"""Track any object for automatic cleanup"""
	if obj and not tracked_objects.has(obj):
		tracked_objects.append(obj)

# ------------------------------------------------------------------------------
# RESOURCE CLEANUP
# ------------------------------------------------------------------------------
func cleanup_all_resources() -> void:
	"""Clean up all tracked resources"""
	cleanup_timers()
	cleanup_nodes()
	cleanup_resources()
	cleanup_objects()

func cleanup_timers() -> void:
	"""Clean up all tracked timers"""
	for timer in tracked_timers:
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
	tracked_timers.clear()

func cleanup_nodes() -> void:
	"""Clean up all tracked nodes"""
	for node in tracked_nodes:
		if is_instance_valid(node) and node.is_inside_tree():
			node.get_parent().remove_child(node)
			node.queue_free()
	tracked_nodes.clear()

func cleanup_resources() -> void:
	"""Clean up all tracked resources"""
	for resource in tracked_resources:
		if is_instance_valid(resource):
			resource.queue_free()
	tracked_resources.clear()

func cleanup_objects() -> void:
	"""Clean up all tracked objects"""
	for obj in tracked_objects:
		if is_instance_valid(obj):
			# Try to call cleanup method if it exists
			if obj.has_method("cleanup"):
				obj.cleanup()
			elif obj.has_method("queue_free"):
				obj.queue_free()
	tracked_objects.clear()

# ------------------------------------------------------------------------------
# RESOURCE MONITORING
# ------------------------------------------------------------------------------
func get_resource_count() -> int:
	"""Get total number of tracked resources"""
	return tracked_resources.size() + tracked_nodes.size() + tracked_timers.size() + tracked_objects.size()

func get_memory_usage() -> Dictionary:
	"""Get memory usage information"""
	return {
		"tracked_resources": tracked_resources.size(),
		"tracked_nodes": tracked_nodes.size(),
		"tracked_timers": tracked_timers.size(),
		"tracked_objects": tracked_objects.size(),
		"total_tracked": get_resource_count()
	}

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func create_and_track_timer(wait_time: float, one_shot: bool = true, autostart: bool = true, timer_name: String = "") -> Timer:
	"""Create a timer and track it for cleanup (version-aware)
	Note: In Godot 4.x, timer must be added to tree before it starts"""
	var timer = GDTestManager.create_test_timer(wait_time, one_shot, autostart, timer_name)
	if timer:
		track_timer(timer)
	return timer

func create_and_track_node(node_type: String, node_name: String = "") -> Node:
	"""Create a node and track it for cleanup"""
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
		_:
			if ClassDB.class_exists(node_type):
				node = ClassDB.instantiate(node_type)
	
	if node:
		if not node_name.is_empty():
			node.name = node_name
		track_node(node)
	
	return node

# ------------------------------------------------------------------------------
# SINGLETON PATTERN
# ------------------------------------------------------------------------------
static var _instance: TestResourceManager = null

static func get_instance() -> TestResourceManager:
	"""Get the global resource manager instance"""
	return _instance

static func set_instance(manager: TestResourceManager) -> void:
	"""Set the global resource manager instance"""
	_instance = manager

static func cleanup_test_resources() -> void:
	"""Static method to cleanup all test resources"""
	if _instance:
		_instance.cleanup_all_resources()
