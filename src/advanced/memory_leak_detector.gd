# GDSentry - Memory Leak Detection System
# Advanced memory monitoring and leak detection for Godot applications
#
# Features:
# - Heap analysis and object tracking
# - Memory leak detection algorithms
# - Reference counting analysis
# - Garbage collection monitoring
# - Memory usage profiling
# - Automated leak detection
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name MemoryLeakDetector

# ------------------------------------------------------------------------------
# MEMORY DETECTION CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_LEAK_THRESHOLD = 1024 * 1024  # 1MB
const DEFAULT_GROWTH_THRESHOLD = 0.1  # 10%
const DEFAULT_MONITORING_INTERVAL = 1.0
const MAX_TRACKED_OBJECTS = 10000

# ------------------------------------------------------------------------------
# MEMORY DETECTION STATE
# ------------------------------------------------------------------------------
var leak_threshold: int = DEFAULT_LEAK_THRESHOLD
var growth_threshold: float = DEFAULT_GROWTH_THRESHOLD
var monitoring_interval: float = DEFAULT_MONITORING_INTERVAL
var enable_auto_detection: bool = true
var enable_detailed_tracking: bool = false

# ------------------------------------------------------------------------------
# MEMORY TRACKING DATA
# ------------------------------------------------------------------------------
var memory_snapshots: Array = []
var object_registry: Dictionary = {}
var reference_counts: Dictionary = {}
var allocation_history: Array = []

# ------------------------------------------------------------------------------
# LEAK DETECTION RESULTS
# ------------------------------------------------------------------------------
var detected_leaks: Array = []
var memory_growth_trends: Array = []
var suspicious_objects: Array = []

# ------------------------------------------------------------------------------
# MONITORING STATE
# ------------------------------------------------------------------------------
var monitoring_active: bool = false
var baseline_memory: float = 0.0
var current_memory: float = 0.0
var peak_memory: float = 0.0
var last_snapshot_time: float = 0.0

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize memory leak detection system"""
	setup_memory_monitoring()

func _process(_delta: float) -> void:
	"""Continuous memory monitoring"""
	if monitoring_active and Time.get_ticks_msec() / 1000.0 - last_snapshot_time >= monitoring_interval:
		take_memory_snapshot()

# ------------------------------------------------------------------------------
# MEMORY MONITORING SETUP
# ------------------------------------------------------------------------------
func setup_memory_monitoring() -> void:
	"""Set up memory monitoring systems"""
	# Create monitoring directories
	var dirs = ["res://memory_snapshots/", "res://memory_reports/"]
	for dir_path in dirs:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			DirAccess.make_dir_recursive_absolute(global_path)

	# Initialize baseline
	update_baseline_memory()

func start_monitoring() -> void:
	"""Start memory monitoring"""
	monitoring_active = true
	last_snapshot_time = Time.get_ticks_msec() / 1000.0
	take_memory_snapshot()  # Initial snapshot

	if OS.is_debug_build():
		print("🔍 Memory leak detection started")

func stop_monitoring() -> void:
	"""Stop memory monitoring"""
	monitoring_active = false

	if OS.is_debug_build():
		print("🛑 Memory leak detection stopped")

func update_baseline_memory() -> void:
	"""Update baseline memory usage"""
	baseline_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	current_memory = baseline_memory
	peak_memory = baseline_memory

# ------------------------------------------------------------------------------
# MEMORY SNAPSHOT SYSTEM
# ------------------------------------------------------------------------------
func take_memory_snapshot(label: String = "") -> Dictionary:
	"""Take a snapshot of current memory state"""
	var snapshot = {
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"label": label if not label.is_empty() else "snapshot_" + str(memory_snapshots.size()),
		"static_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
		"dynamic_memory": 0,  # Performance.MEMORY_DYNAMIC not available in Godot 4
		"total_memory": Performance.get_monitor(Performance.MEMORY_STATIC),  # Only static memory available
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"resource_count": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"orphan_node_count": Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	}

	# Add detailed tracking if enabled
	if enable_detailed_tracking:
		snapshot["detailed_objects"] = get_detailed_object_info()
		snapshot["reference_counts"] = reference_counts.duplicate()

	memory_snapshots.append(snapshot)
	last_snapshot_time = snapshot.timestamp

	# Update current memory tracking
	current_memory = snapshot.total_memory
	peak_memory = max(peak_memory, current_memory)

	# Auto-detect leaks if enabled
	if enable_auto_detection:
		detect_memory_leaks()

	return snapshot

func get_detailed_object_info() -> Dictionary:
	"""Get detailed information about objects in memory"""
	var object_info = {
		"nodes": [],
		"resources": [],
		"scripts": []
	}

	# This is a simplified version - in a real implementation,
	# you'd need to hook into Godot's internal object tracking
	var tree = get_tree()
	if tree:
		_collect_node_info(tree.root, object_info)

	return object_info

func _collect_node_info(node: Node, info: Dictionary) -> void:
	"""Recursively collect node information"""
	if object_registry.size() < MAX_TRACKED_OBJECTS:
		var node_info = {
			"name": node.name,
			"type": node.get_class(),
			"path": node.get_path(),
			"script": node.get_script() if node.get_script() else null,
			"children_count": node.get_child_count()
		}
		info.nodes.append(node_info)

		# Track this object
		var object_id = node.get_instance_id()
		if not object_registry.has(object_id):
			object_registry[object_id] = {
				"object": node,
				"first_seen": Time.get_ticks_msec() / 1000.0,
				"type": node.get_class(),
				"name": node.name
			}

	# Recurse on children (limit depth to prevent excessive tracking)
	if node.get_child_count() > 0 and info.nodes.size() < 1000:
		for child in node.get_children():
			_collect_node_info(child, info)

# ------------------------------------------------------------------------------
# MEMORY LEAK DETECTION ALGORITHMS
# ------------------------------------------------------------------------------
func detect_memory_leaks() -> Array:
	"""Detect potential memory leaks using multiple algorithms"""
	detected_leaks.clear()

	# Algorithm 1: Memory growth detection
	detect_memory_growth_leaks()

	# Algorithm 2: Object lifetime analysis
	detect_object_lifetime_leaks()

	# Algorithm 3: Reference cycle detection
	detect_reference_cycles()

	# Algorithm 4: Resource leak detection
	detect_resource_leaks()

	return detected_leaks

func detect_memory_growth_leaks() -> void:
	"""Detect memory leaks based on continuous growth"""
	if memory_snapshots.size() < 3:
		return

	var recent_snapshots = memory_snapshots.slice(-3)  # Last 3 snapshots
	var growth_rates = []

	for i in range(1, recent_snapshots.size()):
		var prev = recent_snapshots[i-1]
		var curr = recent_snapshots[i]
		var growth = float(curr.total_memory - prev.total_memory) / float(prev.total_memory)
		growth_rates.append(growth)

	# Calculate average growth rate
	var avg_growth = 0.0
	for rate in growth_rates:
		avg_growth += rate
	avg_growth /= growth_rates.size()

	if avg_growth > growth_threshold:
		var leak_info = {
			"type": "memory_growth",
			"description": "Continuous memory growth detected",
			"growth_rate": avg_growth,
			"threshold": growth_threshold,
			"severity": "high" if avg_growth > growth_threshold * 2 else "medium",
			"recommendation": "Check for objects not being freed or circular references"
		}
		detected_leaks.append(leak_info)

func detect_object_lifetime_leaks() -> void:
	"""Detect objects that have been alive too long"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var long_lived_threshold = 300.0  # 5 minutes

	suspicious_objects.clear()

	for object_id in object_registry.keys():
		var obj_info = object_registry[object_id]
		var lifetime = current_time - obj_info.first_seen

		if lifetime > long_lived_threshold:
			# Check if object still exists
			var object = instance_from_id(object_id)
			if object and is_instance_valid(object):
				suspicious_objects.append({
					"object_id": object_id,
					"type": obj_info.type,
					"name": obj_info.name,
					"lifetime": lifetime,
					"first_seen": obj_info.first_seen
				})

	if suspicious_objects.size() > 10:  # More than 10 long-lived objects
		var leak_info = {
			"type": "object_lifetime",
			"description": "Multiple long-lived objects detected",
			"object_count": suspicious_objects.size(),
			"threshold": long_lived_threshold,
			"severity": "medium",
			"recommendation": "Review object lifecycle management",
			"suspicious_objects": suspicious_objects.slice(0, 5)  # Top 5
		}
		detected_leaks.append(leak_info)

func detect_reference_cycles() -> void:
	"""Detect potential reference cycles"""
	# This is a simplified reference cycle detection
	# In a real implementation, you'd need more sophisticated analysis

	var potential_cycles = []

	for object_id in object_registry.keys():
		var object = instance_from_id(object_id)
		if not object or not is_instance_valid(object):
			continue

		# Check for objects that reference themselves or their parents
		if object is Node:
			var parent = object.get_parent()
			if parent and object.get_instance_id() in _get_object_references(parent):
				potential_cycles.append({
					"object_id": object_id,
					"type": object.get_class(),
					"name": object.name
				})

	if potential_cycles.size() > 0:
		var leak_info = {
			"type": "reference_cycle",
			"description": "Potential reference cycles detected",
			"cycle_count": potential_cycles.size(),
			"severity": "high",
			"recommendation": "Check for circular references in object hierarchies",
			"potential_cycles": potential_cycles.slice(0, 3)  # Top 3
		}
		detected_leaks.append(leak_info)

func _get_object_references(object) -> Array:
	"""Get all object references from an object (simplified)"""
	var references = []

	# This is a very basic implementation
	# In a real system, you'd need to analyze the object's properties
	if object is Node:
		for child in object.get_children():
			references.append(child.get_instance_id())

	return references

func detect_resource_leaks() -> void:
	"""Detect resource leaks"""
	var current_resources = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	var current_orphans = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

	# Compare with expected values (this would be calibrated per application)
	var expected_max_resources = 1000  # Application-specific
	var expected_max_orphans = 100

	if current_resources > expected_max_resources:
		var leak_info = {
			"type": "resource_leak",
			"description": "High number of resources in memory",
			"resource_count": current_resources,
			"threshold": expected_max_resources,
			"severity": "medium",
			"recommendation": "Check resource loading and unloading"
		}
		detected_leaks.append(leak_info)

	if current_orphans > expected_max_orphans:
		var leak_info = {
			"type": "orphan_nodes",
			"description": "High number of orphan nodes",
			"orphan_count": current_orphans,
			"threshold": expected_max_orphans,
			"severity": "medium",
			"recommendation": "Ensure proper node cleanup"
		}
		detected_leaks.append(leak_info)

# ------------------------------------------------------------------------------
# MEMORY ANALYSIS METHODS
# ------------------------------------------------------------------------------
func analyze_memory_usage() -> Dictionary:
	"""Analyze current memory usage patterns"""
	var analysis = {
		"total_memory_mb": float(current_memory) / (1024 * 1024),
		"peak_memory_mb": float(peak_memory) / (1024 * 1024),
		"baseline_memory_mb": float(baseline_memory) / (1024 * 1024),
		"memory_growth_mb": float(current_memory - baseline_memory) / (1024 * 1024),
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"resource_count": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"leak_detected": not detected_leaks.is_empty(),
		"leak_count": detected_leaks.size()
	}

	# Calculate memory efficiency
	var efficiency = 1.0
	if baseline_memory > 0:
		efficiency = float(baseline_memory) / float(current_memory)
	analysis["memory_efficiency"] = efficiency

	# Memory fragmentation estimate (simplified)
	var fragmentation = 0.0
	if memory_snapshots.size() >= 2:
		var recent = memory_snapshots.slice(-2)
		var growth = recent[1].total_memory - recent[0].total_memory
		var objects_added = recent[1].object_count - recent[0].object_count
		if objects_added > 0:
			fragmentation = float(growth) / float(objects_added * 100)  # Rough estimate
	analysis["estimated_fragmentation"] = fragmentation

	return analysis

func get_memory_trends() -> Dictionary:
	"""Analyze memory usage trends over time"""
	if memory_snapshots.size() < 2:
		return {"error": "Insufficient data for trend analysis"}

	var trends = {
		"growth_rate": 0.0,
		"stability": 1.0,
		"peak_times": [],
		"allocation_spikes": []
	}

	# Calculate growth rate
	var first = memory_snapshots[0]
	var last = memory_snapshots.back()
	var time_diff = last.timestamp - first.timestamp
	if time_diff > 0:
		trends.growth_rate = float(last.total_memory - first.total_memory) / time_diff

	# Calculate stability (lower variance = more stable)
	var memory_values = []
	for snapshot in memory_snapshots:
		memory_values.append(snapshot.total_memory)

	var mean = 0.0
	for value in memory_values:
		mean += value
	mean /= memory_values.size()

	var variance = 0.0
	for value in memory_values:
		variance += pow(value - mean, 2)
	variance /= memory_values.size()

	trends.stability = 1.0 / (1.0 + sqrt(variance) / mean)  # Normalized stability score

	# Find peak memory times
	var max_memory = 0
	for snapshot in memory_snapshots:
		if snapshot.total_memory > max_memory:
			max_memory = snapshot.total_memory
			trends.peak_times.append(snapshot.timestamp)

	return trends

# ------------------------------------------------------------------------------
# MEMORY TESTING METHODS
# ------------------------------------------------------------------------------
func test_memory_operation(operation: Callable, iterations: int = 100, cleanup: Variant = null) -> Dictionary:
	"""Test a memory-intensive operation for leaks"""
	var results = {
		"operation": "unknown",
		"iterations": iterations,
		"memory_before": Performance.get_monitor(Performance.MEMORY_STATIC),
		"memory_after": 0,
		"peak_memory": 0,
		"memory_leaked": 0,
		"leaked_per_iteration": 0,
		"has_leak": false
	}

	# Take initial snapshot
	var initial_snapshot = take_memory_snapshot("before_operation")

	# Execute operation multiple times
	var max_memory = initial_snapshot.total_memory
	for i in range(iterations):
		await operation.call()

		var current_memory_local = Performance.get_monitor(Performance.MEMORY_STATIC)
		max_memory = max(max_memory, current_memory_local)

		# Allow for garbage collection between iterations
		if cleanup:
			await cleanup.call()

		await get_tree().create_timer(0.01).timeout

	# Take final snapshot
	var final_snapshot = take_memory_snapshot("after_operation")

	results.memory_after = final_snapshot.total_memory
	results.peak_memory = max_memory
	results.memory_leaked = final_snapshot.total_memory - initial_snapshot.total_memory
	results.leaked_per_iteration = float(results.memory_leaked) / float(iterations)
	results.has_leak = results.memory_leaked > leak_threshold

	return results

func benchmark_memory_allocation(allocation_func: Callable, deallocation_func: Variant = null, iterations: int = 1000) -> Dictionary:
	"""Benchmark memory allocation and deallocation performance"""
	var results = {
		"allocation_time_total": 0.0,
		"deallocation_time_total": 0.0,
		"allocation_time_avg": 0.0,
		"deallocation_time_avg": 0.0,
		"memory_peak": 0,
		"memory_leaked": 0
	}

	var initial_memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	# Allocation benchmark
	var start_time = Time.get_ticks_usec()
	var allocated_objects = []
	for i in range(iterations):
		var obj = await allocation_func.call()
		allocated_objects.append(obj)

	results.allocation_time_total = (Time.get_ticks_usec() - start_time) / 1000000.0
	results.allocation_time_avg = results.allocation_time_total / iterations

	# Peak memory during allocation
	results.memory_peak = Performance.get_monitor(Performance.MEMORY_STATIC)

	# Deallocation benchmark
	if deallocation_func:
		start_time = Time.get_ticks_usec()
		for obj in allocated_objects:
			await deallocation_func.call(obj)
		results.deallocation_time_total = (Time.get_ticks_usec() - start_time) / 1000000.0
		results.deallocation_time_avg = results.deallocation_time_total / iterations

		# Force garbage collection
		await get_tree().create_timer(0.1).timeout

	var final_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	results.memory_leaked = final_memory - initial_memory

	return results

# ------------------------------------------------------------------------------
# REPORTING AND LOGGING
# ------------------------------------------------------------------------------
func generate_memory_report() -> String:
	"""Generate a comprehensive memory analysis report"""
	var analysis = analyze_memory_usage()
	var trends = get_memory_trends()

	var report = "🧠 Memory Leak Detection Report\n"
	report += "==================================================\n\n"

	report += "📊 CURRENT MEMORY STATUS\n"
	report += "Total Memory: %.2f MB\n" % analysis.total_memory_mb
	report += "Peak Memory: %.2f MB\n" % analysis.peak_memory_mb
	report += "Baseline Memory: %.2f MB\n" % analysis.baseline_memory_mb
	report += "Memory Growth: %.2f MB\n" % analysis.memory_growth_mb
	report += "Memory Efficiency: %.2f%%\n" % (analysis.memory_efficiency * 100)
	report += "\n"

	report += "📈 OBJECT COUNTS\n"
	report += "Total Objects: %d\n" % analysis.object_count
	report += "Resources: %d\n" % analysis.resource_count
	report += "Nodes: %d\n" % analysis.node_count
	report += "\n"

	if not detected_leaks.is_empty():
		report += "🚨 DETECTED LEAKS\n"
		for i in range(detected_leaks.size()):
			var leak = detected_leaks[i]
			report += "%d. %s (%s)\n" % [i + 1, leak.description, leak.severity]
			report += "   Recommendation: %s\n" % leak.recommendation
			report += "\n"

	if not trends.is_empty() and not trends.has("error"):
		report += "📉 MEMORY TRENDS\n"
		report += "Growth Rate: %.2f MB/s\n" % trends.growth_rate
		report += "Stability Score: %.2f\n" % trends.stability
		report += "\n"

	if not suspicious_objects.is_empty():
		report += "👀 SUSPICIOUS OBJECTS\n"
		for i in range(min(suspicious_objects.size(), 5)):
			var obj = suspicious_objects[i]
			report += "%d. %s (%s) - %.1fs\n" % [i + 1, obj.name, obj.type, obj.lifetime]
		report += "\n"

	return report

func save_memory_report(filename: String = "") -> bool:
	"""Save memory report to file"""
	if filename.is_empty():
		filename = "memory_report_" + str(Time.get_unix_time_from_system()) + ".txt"

	var report_path = "res://memory_reports/" + filename
	var global_path = ProjectSettings.globalize_path(report_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(generate_memory_report())
		file.close()

		# Also save raw data
		var data_path = report_path.replace(".txt", "_data.json")
		var data_global = ProjectSettings.globalize_path(data_path)
		var data_file = FileAccess.open(data_global, FileAccess.WRITE)
		if data_file:
			var export_data = {
				"snapshots": memory_snapshots,
				"detected_leaks": detected_leaks,
				"suspicious_objects": suspicious_objects,
				"analysis": analyze_memory_usage(),
				"trends": get_memory_trends()
			}
			data_file.store_string(JSON.stringify(export_data, "\t"))
			data_file.close()

		return true

	return false

# ------------------------------------------------------------------------------
# CONFIGURATION METHODS
# ------------------------------------------------------------------------------
func set_leak_threshold(threshold_bytes: int) -> void:
	"""Set the memory leak detection threshold"""
	leak_threshold = threshold_bytes

func set_growth_threshold(threshold: float) -> void:
	"""Set the memory growth detection threshold"""
	growth_threshold = threshold

func set_monitoring_interval(interval: float) -> void:
	"""Set the monitoring interval"""
	monitoring_interval = interval

func set_auto_detection(enabled: bool = true) -> void:
	"""Enable or disable automatic leak detection"""
	enable_auto_detection = enabled

func set_detailed_tracking(enabled: bool = true) -> void:
	"""Enable or disable detailed object tracking"""
	enable_detailed_tracking = enabled

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func clear_snapshots() -> void:
	"""Clear all memory snapshots"""
	memory_snapshots.clear()

func get_snapshot_count() -> int:
	"""Get the number of stored snapshots"""
	return memory_snapshots.size()

func get_latest_snapshot() -> Dictionary:
	"""Get the most recent memory snapshot"""
	if memory_snapshots.is_empty():
		return {}
	return memory_snapshots.back()

func export_memory_data() -> Dictionary:
	"""Export all memory monitoring data"""
	return {
		"snapshots": memory_snapshots,
		"object_registry": object_registry,
		"detected_leaks": detected_leaks,
		"suspicious_objects": suspicious_objects,
		"analysis": analyze_memory_usage(),
		"trends": get_memory_trends()
	}

func reset_detection() -> void:
	"""Reset leak detection state"""
	detected_leaks.clear()
	suspicious_objects.clear()
	object_registry.clear()
	update_baseline_memory()

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup memory detection resources"""
	stop_monitoring()

	if OS.is_debug_build() and not detected_leaks.is_empty():
		print(generate_memory_report())
