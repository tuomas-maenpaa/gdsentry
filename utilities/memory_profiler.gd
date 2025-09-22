# GDSentry - Memory Profiling Utilities
# Advanced memory profiling and leak detection for comprehensive memory analysis
#
# Features:
# - Real-time memory usage tracking with detailed statistics
# - Intelligent leak detection algorithms with pattern recognition
# - Memory growth analysis and trend detection
# - Performance impact monitoring of memory operations
# - Automated memory stress testing scenarios
# - Memory usage pattern analysis and reporting
# - Integration with performance benchmarking framework
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name MemoryProfiler

# ------------------------------------------------------------------------------
# MEMORY PROFILING CONSTANTS
# ------------------------------------------------------------------------------
const SAMPLING_INTERVAL = 0.1  # seconds
const LEAK_DETECTION_THRESHOLD = 1.5  # MB growth threshold for leak detection
const PATTERN_ANALYSIS_WINDOW = 10	# samples for pattern analysis
const STRESS_TEST_ITERATIONS = 100
const MEMORY_WARNING_THRESHOLD = 50.0  # MB warning threshold

# ------------------------------------------------------------------------------
# MEMORY PROFILING STATE
# ------------------------------------------------------------------------------
var is_profiling: bool = false
var memory_samples: Array = []
var object_tracking: Dictionary = {}
var leak_candidates: Array = []
var memory_patterns: Dictionary = {}
var performance_impact: Dictionary = {}

var start_time: float = 0.0
var last_sample_time: float = 0.0
var sample_timer: Timer = null

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize memory profiler"""
	_setup_sample_timer()

func _setup_sample_timer() -> void:
	"""Setup automatic sampling timer"""
	sample_timer = Timer.new()
	sample_timer.wait_time = SAMPLING_INTERVAL
	sample_timer.one_shot = false
	sample_timer.timeout.connect(_on_sample_timeout)
	add_child(sample_timer)

# ------------------------------------------------------------------------------
# MEMORY PROFILING CONTROL
# ------------------------------------------------------------------------------
func start_profiling(profile_name: String = "default") -> void:
	"""Start memory profiling session"""
	if is_profiling:
		push_warning("MemoryProfiler: Profiling already active, stopping current session")
		stop_profiling()

	print("🧠 Starting memory profiling: " + profile_name)

	is_profiling = true
	start_time = Time.get_ticks_usec() / 1000000.0
	last_sample_time = start_time

	# Initialize tracking structures
	memory_samples.clear()
	object_tracking.clear()
	leak_candidates.clear()
	memory_patterns.clear()
	performance_impact.clear()

	# Take initial sample
	_take_memory_sample()

	# Start automatic sampling
	sample_timer.start()

func stop_profiling() -> Dictionary:
	"""Stop profiling and return comprehensive analysis"""
	if not is_profiling:
		return {"error": "No active profiling session"}

	print("🧠 Stopping memory profiling")

	is_profiling = false
	sample_timer.stop()

	var end_time = Time.get_ticks_usec() / 1000000.0
	var duration = end_time - start_time

	# Final sample
	_take_memory_sample()

	# Perform comprehensive analysis
	var analysis = {
		"profile_name": "memory_profile",
		"duration": duration,
		"total_samples": memory_samples.size(),
		"analysis": _analyze_memory_data(),
		"recommendations": _generate_memory_recommendations(),
		"performance_impact": performance_impact.duplicate()
	}

	return analysis

func _on_sample_timeout() -> void:
	"""Handle automatic sampling"""
	if is_profiling:
		_take_memory_sample()

# ------------------------------------------------------------------------------
# MEMORY SAMPLING AND TRACKING
# ------------------------------------------------------------------------------
func _take_memory_sample() -> void:
	"""Take a comprehensive memory sample"""
	var current_time = Time.get_ticks_usec() / 1000000.0
	var time_delta = current_time - last_sample_time

	var sample = {
		"timestamp": current_time,
		"time_delta": time_delta,
		"static_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
		"dynamic_memory": 0,  # Dynamic memory monitoring not available in Godot 4
		"static_max": Performance.get_monitor(Performance.MEMORY_STATIC_MAX),
		"dynamic_max": 0,  # Dynamic memory max not available in Godot 4
		"total_memory": Performance.get_monitor(Performance.MEMORY_STATIC),	 # Only static memory available in Godot 4
		"objects_total": Performance.get_monitor(Performance.OBJECT_COUNT),
		"resources_total": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"nodes_total": _count_scene_nodes(),
		"physics_objects": Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	}

	memory_samples.append(sample)
	last_sample_time = current_time

	# Update object tracking
	_update_object_tracking(sample)

	# Check for potential leaks
	_check_for_memory_leaks(sample)

func _count_scene_nodes() -> int:
	"""Count total nodes in scene tree"""
	var root = get_tree().root if get_tree() else null
	if not root:
		return 0

	return _count_nodes_recursive(root)

func _count_nodes_recursive(node: Node) -> int:
	"""Recursively count nodes"""
	var count = 1  # Count this node

	for child in node.get_children():
		count += _count_nodes_recursive(child)

	return count

func _update_object_tracking(sample: Dictionary) -> void:
	"""Update object lifecycle tracking"""
	var current_objects = sample.objects_total
	var current_resources = sample.resources_total

	if object_tracking.is_empty():
		# Initialize tracking
		object_tracking = {
			"initial_objects": current_objects,
			"initial_resources": current_resources,
			"peak_objects": current_objects,
			"peak_resources": current_resources,
			"object_growth_rate": 0.0,
			"resource_growth_rate": 0.0
		}
	else:
		# Update tracking
		object_tracking.peak_objects = max(object_tracking.peak_objects, current_objects)
		object_tracking.peak_resources = max(object_tracking.peak_resources, current_resources)

		# Calculate growth rates
		var sample_count = memory_samples.size()
		if sample_count > 1:
			var initial_objects = object_tracking.initial_objects
			var initial_resources = object_tracking.initial_resources

			object_tracking.object_growth_rate = (current_objects - initial_objects) / float(sample_count)
			object_tracking.resource_growth_rate = (current_resources - initial_resources) / float(sample_count)

func _check_for_memory_leaks(sample: Dictionary) -> void:
	"""Check for potential memory leaks using multiple detection methods"""
	if memory_samples.size() < 3:
		return	# Need minimum samples for analysis

	var _current_memory = sample.total_memory
	var recent_samples = memory_samples.slice(-3)  # Last 3 samples

	# Method 1: Sustained growth detection
	var growth_detected = _detect_sustained_growth(recent_samples)
	if growth_detected and not leak_candidates.has("sustained_growth"):
		leak_candidates.append("sustained_growth")

	# Method 2: Memory ceiling detection
	var memory_ceiling = _detect_memory_ceiling(recent_samples)
	if memory_ceiling > LEAK_DETECTION_THRESHOLD * 1024 * 1024:	 # Convert MB to bytes
		if not leak_candidates.has("memory_ceiling"):
			leak_candidates.append("memory_ceiling")

	# Method 3: Object accumulation detection
	var object_accumulation = _detect_object_accumulation(recent_samples)
	if object_accumulation > 50:  # 50+ object increase
		if not leak_candidates.has("object_accumulation"):
			leak_candidates.append("object_accumulation")

func _detect_sustained_growth(samples: Array) -> bool:
	"""Detect sustained memory growth pattern"""
	if samples.size() < 3:
		return false

	var memory_values = samples.map(func(s): return s.total_memory)
	var growth_count = 0

	for i in range(1, memory_values.size()):
		if memory_values[i] > memory_values[i-1]:
			growth_count += 1

	# If memory has grown in 80% of recent samples, consider it sustained growth
	return float(growth_count) / (memory_values.size() - 1) > 0.8

func _detect_memory_ceiling(samples: Array) -> float:
	"""Detect if memory has reached a concerning ceiling"""
	if samples.is_empty():
		return 0.0

	var max_memory = samples.reduce(func(acc, sample): return sample if sample.total_memory > acc.total_memory else acc)
	return max_memory.total_memory if max_memory else 0.0

func _detect_object_accumulation(samples: Array) -> int:
	"""Detect object accumulation pattern"""
	if samples.size() < 2:
		return 0

	var first_sample = samples[0]
	var last_sample = samples.back()

	return last_sample.objects_total - first_sample.objects_total

# ------------------------------------------------------------------------------
# MEMORY PATTERN ANALYSIS
# ------------------------------------------------------------------------------
func analyze_memory_patterns() -> Dictionary:
	"""Analyze memory usage patterns for optimization insights"""
	if memory_samples.size() < PATTERN_ANALYSIS_WINDOW:
		return {"error": "Insufficient data for pattern analysis"}

	memory_patterns = {
		"allocation_patterns": _analyze_allocation_patterns(),
		"deallocation_patterns": _analyze_deallocation_patterns(),
		"memory_spikes": _detect_memory_spikes(),
		"periodic_patterns": _detect_periodic_patterns(),
		"efficiency_metrics": _calculate_efficiency_metrics()
	}

	return memory_patterns.duplicate()

func _analyze_allocation_patterns() -> Dictionary:
	"""Analyze memory allocation patterns"""
	var allocations = []
	var peaks = []
	var valleys = []

	for i in range(1, memory_samples.size()):
		var current = memory_samples[i].total_memory
		var previous = memory_samples[i-1].total_memory
		var delta = current - previous

		if delta > 0:
			allocations.append({
				"sample_index": i,
				"amount": delta,
				"timestamp": memory_samples[i].timestamp
			})

		# Detect peaks and valleys
		if i > 1 and i < memory_samples.size() - 1:
			var prev_prev = memory_samples[i-1].total_memory
			var next_next = memory_samples[i+1].total_memory

			if current > prev_prev and current > next_next:
				peaks.append({"index": i, "value": current, "timestamp": memory_samples[i].timestamp})

			if current < prev_prev and current < next_next:
				valleys.append({"index": i, "value": current, "timestamp": memory_samples[i].timestamp})

	return {
		"total_allocations": allocations.size(),
		"average_allocation": _calculate_average(allocations.map(func(a): return a.amount)) if not allocations.is_empty() else 0.0,
		"peak_allocation": allocations.reduce(func(acc, alloc): return alloc if alloc.amount > acc.amount else acc).amount if not allocations.is_empty() else 0.0,
		"allocation_frequency": float(allocations.size()) / memory_samples.size(),
		"peaks": peaks,
		"valleys": valleys
	}

func _analyze_deallocation_patterns() -> Dictionary:
	"""Analyze memory deallocation patterns"""
	var deallocations = []

	for i in range(1, memory_samples.size()):
		var current = memory_samples[i].total_memory
		var previous = memory_samples[i-1].total_memory
		var delta = current - previous

		if delta < 0:
			deallocations.append({
				"sample_index": i,
				"amount": abs(delta),
				"timestamp": memory_samples[i].timestamp
			})

	return {
		"total_deallocations": deallocations.size(),
		"average_deallocation": _calculate_average(deallocations.map(func(d): return d.amount)) if not deallocations.is_empty() else 0.0,
		"deallocation_frequency": float(deallocations.size()) / memory_samples.size(),
		"deallocation_efficiency": _calculate_deallocation_efficiency(deallocations)
	}

func _detect_memory_spikes() -> Array:
	"""Detect memory usage spikes"""
	if memory_samples.size() < 3:
		return []

	var spikes = []
	var mean_memory = _calculate_average(memory_samples.map(func(s): return s.total_memory))
	var std_dev = _calculate_standard_deviation(memory_samples.map(func(s): return s.total_memory))

	for i in range(memory_samples.size()):
		var sample = memory_samples[i]
		var deviation = abs(sample.total_memory - mean_memory)

		if deviation > 2 * std_dev:	 # 2 standard deviations
			spikes.append({
				"sample_index": i,
				"memory_value": sample.total_memory,
				"deviation": deviation,
				"timestamp": sample.timestamp
			})

	return spikes

func _detect_periodic_patterns() -> Dictionary:
	"""Detect periodic memory usage patterns"""
	if memory_samples.size() < PATTERN_ANALYSIS_WINDOW * 2:
		return {"detected": false, "period": 0, "confidence": 0.0}

	# Simple autocorrelation analysis
	var memory_values = memory_samples.map(func(s): return s.total_memory)
	var autocorrelations = []

	for lag in range(1, min(PATTERN_ANALYSIS_WINDOW, memory_values.size() / 2.0)):
		var correlation = _calculate_autocorrelation(memory_values, lag)
		autocorrelations.append({"lag": lag, "correlation": correlation})

	var max_correlation = autocorrelations.reduce(func(acc, corr): return corr if corr.correlation > acc.correlation else acc)
	var detected = max_correlation and max_correlation.correlation > 0.7

	return {
		"detected": detected,
		"period": max_correlation.lag if max_correlation else 0,
		"confidence": max_correlation.correlation if max_correlation else 0.0,
		"autocorrelations": autocorrelations
	}

func _calculate_efficiency_metrics() -> Dictionary:
	"""Calculate memory efficiency metrics"""
	if memory_samples.is_empty():
		return {}

	var total_memory_used = memory_samples.back().total_memory - memory_samples[0].total_memory
	var total_time = memory_samples.back().timestamp - memory_samples[0].timestamp
	var total_objects_created = memory_samples.back().objects_total - memory_samples[0].objects_total

	return {
		"memory_efficiency": total_memory_used / float(memory_samples.size()) if memory_samples.size() > 0 else 0.0,
		"allocation_rate": total_memory_used / total_time if total_time > 0 else 0.0,
		"object_creation_rate": total_objects_created / total_time if total_time > 0 else 0.0,
		"memory_per_object": total_memory_used / float(total_objects_created) if total_objects_created > 0 else 0.0
	}

# ------------------------------------------------------------------------------
# MEMORY STRESS TESTING
# ------------------------------------------------------------------------------
func run_memory_stress_test(test_name: String = "stress_test") -> Dictionary:
	"""Run comprehensive memory stress testing"""
	print("🧪 Starting memory stress test: " + test_name)

	var stress_results = {
		"test_name": test_name,
		"start_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
		"stress_scenarios": {},
		"leak_detection": {},
		"performance_impact": {},
		"recommendations": []
	}

	# Scenario 1: Object allocation stress
	stress_results.stress_scenarios.object_allocation = _run_object_allocation_stress()

	# Scenario 2: Memory copy stress
	stress_results.stress_scenarios.memory_copy = _run_memory_copy_stress()

	# Scenario 3: Resource loading stress
	stress_results.stress_scenarios.resource_loading = _run_resource_loading_stress()

	# Analyze stress test results
	stress_results.leak_detection = _analyze_stress_leaks(stress_results.stress_scenarios)
	stress_results.performance_impact = _analyze_stress_performance(stress_results.stress_scenarios)
	stress_results.recommendations = _generate_stress_recommendations(stress_results)

	var end_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	stress_results.end_memory = end_memory
	stress_results.memory_increase = end_memory - stress_results.start_memory

	print("🧪 Memory stress test completed: " + test_name)
	return stress_results

func _run_object_allocation_stress() -> Dictionary:
	"""Run object allocation stress test"""
	var objects = []
	var local_start_time = Time.get_ticks_usec()
	var start_memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	# Allocate many objects
	for i in range(STRESS_TEST_ITERATIONS):
		var test_object = {
			"id": i,
			"data": "stress_test_data_" + str(i),
			"array": [],
			"nested": {"value": i * 2}
		}

		# Add some array data
		for j in range(10):
			test_object.array.append("array_item_" + str(j))

		objects.append(test_object)

	var end_time = Time.get_ticks_usec()
	var end_memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	# Clean up (simulate garbage collection)
	objects.clear()

	return {
		"scenario": "object_allocation",
		"iterations": STRESS_TEST_ITERATIONS,
		"execution_time": (end_time - local_start_time) / 1000000.0,
		"memory_increase": end_memory - start_memory,
		"objects_created": STRESS_TEST_ITERATIONS,
		"allocation_rate": STRESS_TEST_ITERATIONS / ((end_time - local_start_time) / 1000000.0)
	}

func _run_memory_copy_stress() -> Dictionary:
	"""Run memory copy stress test"""
	var local_start_time = Time.get_ticks_usec()
	var start_memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	# Create base data
	var base_data = []
	for i in range(1000):
		base_data.append("memory_copy_data_" + str(i))

	# Perform many copy operations
	for i in range(STRESS_TEST_ITERATIONS):
		var copy = base_data.duplicate()
		copy.shuffle()
		# Don't keep references to copies to test GC

	var end_time = Time.get_ticks_usec()
	var end_memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	return {
		"scenario": "memory_copy",
		"iterations": STRESS_TEST_ITERATIONS,
		"execution_time": (end_time - local_start_time) / 1000000.0,
		"memory_increase": end_memory - start_memory,
		"data_size": base_data.size(),
		"copy_rate": STRESS_TEST_ITERATIONS / ((end_time - local_start_time) / 1000000.0)
	}

func _run_resource_loading_stress() -> Dictionary:
	"""Run resource loading stress test"""
	var local_start_time = Time.get_ticks_usec()
	var start_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	var resources_loaded = 0

	# Simulate resource loading stress
	for i in range(min(STRESS_TEST_ITERATIONS, 50)):  # Limit to avoid actual file system stress
		# Create a simple resource-like object
		var resource = {
			"type": "texture",
			"path": "res://stress_test_resource_" + str(i) + ".png",
			"data": [],
			"metadata": {"width": 256, "height": 256, "format": "PNG"}
		}

		# Simulate loading data
		for j in range(100):
			resource.data.append(j)

		resources_loaded += 1

	var end_time = Time.get_ticks_usec()
	var end_memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	return {
		"scenario": "resource_loading",
		"iterations": resources_loaded,
		"execution_time": (end_time - local_start_time) / 1000000.0,
		"memory_increase": end_memory - start_memory,
		"resources_loaded": resources_loaded,
		"load_rate": resources_loaded / ((end_time - local_start_time) / 1000000.0) if (end_time - local_start_time) > 0 else 0.0
	}

func _analyze_stress_leaks(scenarios: Dictionary) -> Dictionary:
	"""Analyze stress test results for memory leaks"""
	var leak_analysis = {
		"potential_leaks": [],
		"memory_recovery": {},
		"leak_probability": 0.0
	}

	for scenario_name in scenarios.keys():
		var scenario = scenarios[scenario_name]
		var memory_increase = scenario.memory_increase

		# Check for concerning memory increases
		if memory_increase > MEMORY_WARNING_THRESHOLD * 1024 * 1024:  # Convert MB to bytes
			leak_analysis.potential_leaks.append({
				"scenario": scenario_name,
				"memory_increase_mb": memory_increase / (1024 * 1024),
				"severity": "high" if memory_increase > MEMORY_WARNING_THRESHOLD * 2 * 1024 * 1024 else "medium"
			})

		# Analyze memory recovery (should be tested after cleanup)
		leak_analysis.memory_recovery[scenario_name] = {
			"final_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
			"recovery_needed": memory_increase > 0
		}

	leak_analysis.leak_probability = float(leak_analysis.potential_leaks.size()) / scenarios.size()

	return leak_analysis

func _analyze_stress_performance(scenarios: Dictionary) -> Dictionary:
	"""Analyze performance impact of stress tests"""
	var performance_analysis = {
		"slowest_scenario": "",
		"fastest_scenario": "",
		"average_execution_time": 0.0,
		"performance_variance": 0.0,
		"bottlenecks": []
	}

	var execution_times = []
	var slowest_time = 0.0
	var fastest_time = INF

	for scenario_name in scenarios.keys():
		var scenario = scenarios[scenario_name]
		var execution_time = scenario.execution_time

		execution_times.append(execution_time)

		if execution_time > slowest_time:
			slowest_time = execution_time
			performance_analysis.slowest_scenario = scenario_name

		if execution_time < fastest_time:
			fastest_time = execution_time
			performance_analysis.fastest_scenario = scenario_name

	if not execution_times.is_empty():
		performance_analysis.average_execution_time = _calculate_average(execution_times)

		# Calculate variance
		var variance = 0.0
		for time in execution_times:
			variance += pow(time - performance_analysis.average_execution_time, 2)
		variance /= execution_times.size()
		performance_analysis.performance_variance = variance

	return performance_analysis

func _generate_stress_recommendations(stress_results: Dictionary) -> Array:
	"""Generate recommendations based on stress test results"""
	var recommendations = []

	var leak_analysis = stress_results.leak_detection
	var performance_analysis = stress_results.performance_impact

	# Memory leak recommendations
	if leak_analysis.leak_probability > 0.5:
		recommendations.append("High probability of memory leaks detected - implement proper cleanup mechanisms")

	for leak in leak_analysis.potential_leaks:
		if leak.severity == "high":
			recommendations.append("Critical memory leak in " + leak.scenario + " - immediate investigation required")

	# Performance recommendations
	if performance_analysis.performance_variance > 1.0:
		recommendations.append("High performance variance detected - optimize for consistency")

	if performance_analysis.slowest_scenario:
		recommendations.append("Optimize " + performance_analysis.slowest_scenario + " - it's the performance bottleneck")

	# General recommendations
	if stress_results.memory_increase > MEMORY_WARNING_THRESHOLD * 1024 * 1024:
		recommendations.append("Overall memory usage concerning - consider memory optimization strategies")

	return recommendations

# ------------------------------------------------------------------------------
# UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
func _calculate_average(values: Array) -> float:
	"""Calculate average of array values"""
	if values.is_empty():
		return 0.0
	return values.reduce(func(acc, val): return acc + val, 0.0) / values.size()

func _calculate_standard_deviation(values: Array) -> float:
	"""Calculate standard deviation of array values"""
	if values.size() < 2:
		return 0.0

	var mean = _calculate_average(values)
	var variance = 0.0

	for value in values:
		variance += pow(value - mean, 2)

	variance /= values.size()
	return sqrt(variance)

func _calculate_autocorrelation(data: Array, lag: int) -> float:
	"""Calculate autocorrelation for given lag"""
	if data.size() < lag + 1:
		return 0.0

	var n = data.size() - lag
	var mean = _calculate_average(data)

	var numerator = 0.0
	var denominator1 = 0.0
	var denominator2 = 0.0

	for i in range(n):
		var diff1 = data[i] - mean
		var diff2 = data[i + lag] - mean

		numerator += diff1 * diff2
		denominator1 += diff1 * diff1
		denominator2 += diff2 * diff2

	if denominator1 == 0 or denominator2 == 0:
		return 0.0

	return numerator / sqrt(denominator1 * denominator2)

# ------------------------------------------------------------------------------
# ANALYSIS AND REPORTING
# ------------------------------------------------------------------------------
func _analyze_memory_data() -> Dictionary:
	"""Perform comprehensive memory data analysis"""
	var analysis = {
		"basic_stats": _calculate_memory_statistics(),
		"leak_analysis": _analyze_memory_leaks(),
		"pattern_analysis": analyze_memory_patterns(),
		"performance_correlation": _analyze_performance_correlation(),
		"optimization_opportunities": _identify_optimization_opportunities()
	}

	return analysis

func _calculate_memory_statistics() -> Dictionary:
	"""Calculate comprehensive memory statistics"""
	if memory_samples.is_empty():
		return {}

	var memory_values = memory_samples.map(func(s): return s.total_memory)
	var object_values = memory_samples.map(func(s): return s.objects_total)

	return {
		"sample_count": memory_samples.size(),
		"duration": memory_samples.back().timestamp - memory_samples[0].timestamp,
		"memory_stats": {
			"initial": memory_samples[0].total_memory,
			"final": memory_samples.back().total_memory,
			"peak": memory_values.max(),
			"min": memory_values.min(),
			"average": _calculate_average(memory_values),
			"std_dev": _calculate_standard_deviation(memory_values),
			"total_growth": memory_samples.back().total_memory - memory_samples[0].total_memory
		},
		"object_stats": {
			"initial": memory_samples[0].objects_total,
			"final": memory_samples.back().objects_total,
			"peak": object_values.max(),
			"min": object_values.min(),
			"average": _calculate_average(object_values),
			"total_growth": memory_samples.back().objects_total - memory_samples[0].objects_total
		}
	}

func _analyze_memory_leaks() -> Dictionary:
	"""Analyze memory samples for leak patterns"""
	return {
		"leak_candidates": leak_candidates.duplicate(),
		"suspected_leaks": leak_candidates.size(),
		"leak_probability": float(leak_candidates.size()) / max(1, memory_samples.size() / 10.0),	 # Per 10 samples
		"object_tracking": object_tracking.duplicate()
	}

func _analyze_performance_correlation() -> Dictionary:
	"""Analyze correlation between memory usage and performance"""
	if memory_samples.size() < 5:
		return {"error": "Insufficient data for correlation analysis"}

	var memory_values = memory_samples.map(func(s): return s.total_memory)
	var fps_values = memory_samples.map(func(s): return s.fps)
	var draw_call_values = memory_samples.map(func(s): return s.draw_calls)

	# Calculate correlations
	var memory_fps_correlation = _calculate_correlation(memory_values, fps_values)
	var memory_draw_calls_correlation = _calculate_correlation(memory_values, draw_call_values)

	return {
		"memory_fps_correlation": memory_fps_correlation,
		"memory_draw_calls_correlation": memory_draw_calls_correlation,
		"performance_impact": abs(memory_fps_correlation) > 0.5,  # Significant correlation
		"rendering_impact": abs(memory_draw_calls_correlation) > 0.3
	}

func _calculate_deallocation_efficiency(deallocations: Array) -> float:
	"""Calculate deallocation efficiency"""
	if deallocations.is_empty():
		return 1.0

	var total_deallocated = 0.0
	for dealloc in deallocations:
		total_deallocated += dealloc.amount

	# Efficiency is the ratio of deallocated memory to allocated memory
	# For simplicity, return 1.0 if we have deallocations, indicating some efficiency
	return 1.0 if total_deallocated > 0 else 0.0

func _calculate_correlation(x_values: Array, y_values: Array) -> float:
	"""Calculate Pearson correlation coefficient"""
	if x_values.size() != y_values.size() or x_values.size() < 2:
		return 0.0

	var n = x_values.size()
	var sum_x = x_values.reduce(func(acc, val): return acc + val, 0.0)
	var sum_y = y_values.reduce(func(acc, val): return acc + val, 0.0)
	var sum_xy = 0.0
	var sum_x2 = 0.0
	var sum_y2 = 0.0

	for i in range(n):
		sum_xy += x_values[i] * y_values[i]
		sum_x2 += x_values[i] * x_values[i]
		sum_y2 += y_values[i] * y_values[i]

	var numerator = n * sum_xy - sum_x * sum_y
	var denominator = sqrt((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))

	return numerator / denominator if denominator != 0 else 0.0

func _identify_optimization_opportunities() -> Array:
	"""Identify memory optimization opportunities"""
	var opportunities = []

	if not memory_patterns.is_empty():
		var patterns = memory_patterns

		# Check allocation patterns
		if patterns.has("allocation_patterns"):
			var alloc_patterns = patterns.allocation_patterns
			if alloc_patterns.allocation_frequency > 0.8:  # Frequent allocations
				opportunities.append("High allocation frequency detected - consider object pooling")

			if alloc_patterns.peak_allocation > 1024 * 1024:  # Large allocations
				opportunities.append("Large memory allocations detected - optimize data structures")

		# Check for memory spikes
		if patterns.has("memory_spikes") and patterns.memory_spikes.size() > 2:
			opportunities.append("Memory spikes detected - investigate sudden memory increases")

		# Check periodic patterns
		if patterns.has("periodic_patterns") and patterns.periodic_patterns.detected:
			opportunities.append("Periodic memory patterns detected - may indicate inefficient cleanup")

	# Check object tracking
	if object_tracking.object_growth_rate > 5:	# Growing object count
		opportunities.append("Object accumulation detected - review object lifecycle management")

	return opportunities

func _generate_memory_recommendations() -> Array:
	"""Generate comprehensive memory optimization recommendations"""
	var recommendations = []

	# Basic memory analysis
	if memory_samples.size() >= 2:
		var initial_memory = memory_samples[0].total_memory
		var final_memory = memory_samples.back().total_memory
		var memory_growth = final_memory - initial_memory

		if memory_growth > 10 * 1024 * 1024:  # 10MB growth
			recommendations.append("Significant memory growth detected - investigate memory management")

		if memory_growth > 50 * 1024 * 1024:  # 50MB growth
			recommendations.append("CRITICAL: Excessive memory growth - immediate optimization required")

	# Leak analysis
	if not leak_candidates.is_empty():
		recommendations.append("Potential memory leaks detected - implement proper cleanup")

		for leak_type in leak_candidates:
			match leak_type:
				"sustained_growth":
					recommendations.append("Sustained memory growth pattern - review allocation patterns")
				"memory_ceiling":
					recommendations.append("Memory ceiling reached - optimize memory usage")
				"object_accumulation":
					recommendations.append("Object accumulation detected - review object lifecycle")

	# Performance correlation
	if not memory_samples.is_empty():
		var avg_memory = memory_samples.map(func(s): return s.total_memory).reduce(func(acc, val): return acc + val, 0.0) / memory_samples.size()
		if avg_memory > MEMORY_WARNING_THRESHOLD * 1024 * 1024:
			recommendations.append("High average memory usage - consider memory optimization")

	# Pattern-based recommendations
	var opportunities = _identify_optimization_opportunities()
	recommendations.append_array(opportunities)

	return recommendations

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup memory profiler resources"""
	if sample_timer:
		sample_timer.stop()
		sample_timer.queue_free()

	memory_samples.clear()
	object_tracking.clear()
	leak_candidates.clear()
	memory_patterns.clear()
	performance_impact.clear()
