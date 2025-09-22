# GDSentry - Performance Test Class
# Specialized test class for performance monitoring and benchmarking
#
# Features:
# - FPS monitoring and validation
# - Memory usage tracking
# - CPU performance measurement
# - Benchmarking with statistical analysis
# - Performance regression detection
# - Resource usage monitoring
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name PerformanceTest

# ------------------------------------------------------------------------------
# PERFORMANCE TESTING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_WARMUP_ITERATIONS = 10
const DEFAULT_BENCHMARK_ITERATIONS = 100
const DEFAULT_TARGET_FPS = 60
const DEFAULT_MEMORY_THRESHOLD_MB = 100
const DEFAULT_CPU_THRESHOLD_MS = 16.67
const PERFORMANCE_TOLERANCE = 0.05

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var config: GDTestConfig

# ------------------------------------------------------------------------------
# PERFORMANCE TEST STATE
# ------------------------------------------------------------------------------
var warmup_iterations: int = DEFAULT_WARMUP_ITERATIONS
var benchmark_iterations: int = DEFAULT_BENCHMARK_ITERATIONS
var target_fps: int = DEFAULT_TARGET_FPS
var memory_threshold_mb: float = DEFAULT_MEMORY_THRESHOLD_MB
var cpu_threshold_ms: float = DEFAULT_CPU_THRESHOLD_MS
var performance_tolerance: float = PERFORMANCE_TOLERANCE

# ------------------------------------------------------------------------------
# PERFORMANCE METRICS STORAGE
# ------------------------------------------------------------------------------
var performance_metrics: Dictionary = {}
var benchmark_results: Dictionary = {}
var performance_history: Array = []

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init() -> void:
	"""Initialize performance testing environment"""
	super._init()

	# Initialize test configuration
	config = GDTestConfig.load_from_file()

	# Load performance test configuration
	load_performance_config()

	# Initialize performance monitoring
	setup_performance_monitoring()

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
func load_performance_config() -> bool:
	"""Load performance testing configuration"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	if config and config.performance_thresholds:
		target_fps = config.performance_thresholds.get("min_fps", DEFAULT_TARGET_FPS)
		memory_threshold_mb = config.performance_thresholds.get("max_memory_mb", DEFAULT_MEMORY_THRESHOLD_MB)

	if config and config.benchmark_settings:
		warmup_iterations = config.benchmark_settings.get("warmup_iterations", DEFAULT_WARMUP_ITERATIONS)
		benchmark_iterations = config.benchmark_settings.get("benchmark_iterations", DEFAULT_BENCHMARK_ITERATIONS)
		performance_tolerance = config.benchmark_settings.get("performance_tolerance", PERFORMANCE_TOLERANCE)

	return true

func setup_performance_monitoring() -> void:
	"""Set up performance monitoring systems"""
	performance_metrics = {
		"start_time": Time.get_ticks_usec(),
		"frames_processed": 0,
		"total_memory_used": 0,
		"peak_memory_used": 0,
		"average_fps": 0,
		"min_fps": 999,
		"max_fps": 0,
		"cpu_time_total": 0
	}

# ------------------------------------------------------------------------------
# FPS AND FRAME RATE TESTING
# ------------------------------------------------------------------------------
func assert_fps_above(min_fps: int, duration: float = 1.0, message: String = "") -> bool:
	"""Assert that FPS stays above minimum threshold"""
	var start_time = Time.get_ticks_usec()
	var frame_count = 0
	var total_fps = 0.0
	var min_measured_fps = 999

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < duration:
		await wait_for_next_frame()

		var current_fps = Performance.get_monitor(Performance.TIME_FPS)
		total_fps += current_fps
		min_measured_fps = min(min_measured_fps, current_fps)
		frame_count += 1

	var average_fps = total_fps / frame_count

	# Update performance metrics
	performance_metrics.frames_processed += frame_count
	performance_metrics.average_fps = average_fps
	performance_metrics.min_fps = min(performance_metrics.min_fps, min_measured_fps)
	performance_metrics.max_fps = max(performance_metrics.max_fps, Performance.get_monitor(Performance.TIME_FPS))

	if min_measured_fps >= min_fps:
		return true

	var error_msg = message if not message.is_empty() else "FPS too low: minimum measured %.1f FPS, required %d FPS (average: %.1f FPS)" % [min_measured_fps, min_fps, average_fps]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_fps_stable(_target_fps: int = -1, tolerance_percent: float = 10.0, duration: float = 2.0, message: String = "") -> bool:
	"""Assert that FPS remains stable within tolerance"""
	if _target_fps < 0:
		_target_fps = self.target_fps

	var start_time = Time.get_ticks_usec()
	var fps_values = []

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < duration:
		await wait_for_next_frame()
		fps_values.append(Performance.get_monitor(Performance.TIME_FPS))

	var average_fps = fps_values.reduce(func(acc, val): return acc + val, 0.0) / fps_values.size()
	var variance = 0.0

	for fps in fps_values:
		variance += pow(fps - average_fps, 2)

	variance /= fps_values.size()
	var standard_deviation = sqrt(variance)
	var coefficient_of_variation = standard_deviation / average_fps * 100

	var tolerance_fps = _target_fps * tolerance_percent / 100.0
	var fps_deviation = abs(average_fps - _target_fps)

	if fps_deviation <= tolerance_fps:
		return true

	var error_msg = message if not message.is_empty() else "FPS unstable: target %d FPS, average %.1f FPS, deviation %.1f FPS (%.1f%% variation)" % [_target_fps, average_fps, fps_deviation, coefficient_of_variation]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_no_frame_drops(duration: float = 5.0, drop_threshold: int = 10, message: String = "") -> bool:
	"""Assert that there are no significant frame drops"""
	var start_time = Time.get_ticks_usec()
	var frame_times = []
	var frame_drops = 0

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < duration:
		await wait_for_next_frame()

		var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
		frame_times.append(frame_time)

		# Check for frame drops (frame time > target frame time)
		if frame_time > (1000.0 / target_fps):
			frame_drops += 1

	if frame_drops <= drop_threshold:
		return true

	var error_msg = message if not message.is_empty() else "Too many frame drops: %d drops detected (threshold: %d)" % [frame_drops, drop_threshold]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# MEMORY USAGE TESTING
# ------------------------------------------------------------------------------
func assert_memory_usage_less_than(max_mb: float, message: String = "") -> bool:
	"""Assert that memory usage is below threshold"""
	# Add minimal async delay to make function awaitable
	await wait_for_next_frame()
	
	var memory_used_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
	
	# Update performance metrics
	performance_metrics.total_memory_used = memory_used_mb
	performance_metrics.peak_memory_used = max(performance_metrics.peak_memory_used, memory_used_mb)
	
	if memory_used_mb <= max_mb:
		return true
	
	var error_msg = message if not message.is_empty() else "Memory usage too high: %.2f MB used, limit %.2f MB" % [memory_used_mb, max_mb]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_memory_stable(duration: float = 5.0, tolerance_mb: float = 5.0, message: String = "") -> bool:
	"""Assert that memory usage remains stable"""
	var start_time = Time.get_ticks_usec()
	var memory_samples = []

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < duration:
		await wait_for_seconds(0.1)
		var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
		memory_samples.append(memory_mb)

	var average_memory = memory_samples.reduce(func(acc, val): return acc + val, 0.0) / memory_samples.size()
	var memory_variance = 0.0

	for memory in memory_samples:
		memory_variance += pow(memory - average_memory, 2)

	memory_variance /= memory_samples.size()
	var memory_std_dev = sqrt(memory_variance)

	if memory_std_dev <= tolerance_mb:
		return true

	var error_msg = message if not message.is_empty() else "Memory usage unstable: average %.2f MB, std dev %.2f MB (tolerance: %.2f MB)" % [average_memory, memory_std_dev, tolerance_mb]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_no_memory_leaks(test_operation: Callable, iterations: int = 10, tolerance_mb: float = 1.0, message: String = "") -> bool:
	"""Assert that repeated operations don't cause memory leaks"""
	var initial_memory = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)

	for i in range(iterations):
		await test_operation.call()
		await wait_for_next_frame()  # Allow cleanup

	var final_memory = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
	var memory_increase = final_memory - initial_memory

	if memory_increase <= tolerance_mb:
		return true

	var error_msg = message if not message.is_empty() else "Memory leak detected: %.2f MB increase after %d iterations (tolerance: %.2f MB)" % [memory_increase, iterations, tolerance_mb]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# BENCHMARKING
# ------------------------------------------------------------------------------
func benchmark_operation(operation_name: String, operation: Callable, iterations: int = -1, warmup: int = -1) -> Dictionary:
	"""Benchmark an operation and return detailed results"""
	if iterations < 0:
		iterations = benchmark_iterations
	if warmup < 0:
		warmup = warmup_iterations

	# Warmup phase
	for i in range(warmup):
		await operation.call()

	# Benchmark phase
	var execution_times = []
	var start_time = Time.get_ticks_usec()

	for i in range(iterations):
		var op_start = Time.get_ticks_usec()
		await operation.call()
		var op_end = Time.get_ticks_usec()
		execution_times.append((op_end - op_start) / 1000000.0)  # Convert to milliseconds

	var total_time = (Time.get_ticks_usec() - start_time) / 1000000.0

	# Calculate statistics
	var average_time = execution_times.reduce(func(acc, val): return acc + val, 0.0) / execution_times.size()
	var min_time = execution_times.min()
	var max_time = execution_times.max()

	var variance = 0.0
	for time in execution_times:
		variance += pow(time - average_time, 2)
	variance /= execution_times.size()
	var standard_deviation = sqrt(variance)

	var result = {
		"name": operation_name,
		"iterations": iterations,
		"warmup_iterations": warmup,
		"total_time": total_time,
		"average_time": average_time,
		"min_time": min_time,
		"max_time": max_time,
		"standard_deviation": standard_deviation,
		"operations_per_second": iterations / (total_time / 1000.0),
		"execution_times": execution_times
	}

	benchmark_results[operation_name] = result
	return result

func assert_benchmark_performance(operation_name: String, operation: Callable, max_average_time: float, message: String = "") -> bool:
	"""Assert that benchmarked operation meets performance requirements"""
	var benchmark_result = await benchmark_operation(operation_name, operation)

	if benchmark_result.average_time <= max_average_time:
		return true

	var error_msg = message if not message.is_empty() else "Benchmark failed: %s average %.2f ms exceeds limit %.2f ms" % [operation_name, benchmark_result.average_time, max_average_time]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_performance_regression(operation_name: String, operation: Callable, baseline_average: float, message: String = "") -> bool:
	"""Assert that performance hasn't regressed from baseline"""
	var benchmark_result = await benchmark_operation(operation_name, operation)
	var current_average = benchmark_result.average_time

	var regression_threshold = baseline_average * (1.0 + performance_tolerance)
	if current_average <= regression_threshold:
		return true

	var regression_percent = ((current_average - baseline_average) / baseline_average) * 100
	var error_msg = message if not message.is_empty() else "Performance regression: %s %.2f%% slower than baseline (%.2f ms vs %.2f ms)" % [operation_name, regression_percent, current_average, baseline_average]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# RESOURCE USAGE MONITORING
# ------------------------------------------------------------------------------
func assert_objects_count_less_than(max_objects: int, message: String = "") -> bool:
	"""Assert that the number of objects is below threshold"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var object_count = Performance.get_monitor(Performance.OBJECT_COUNT)

	if object_count <= max_objects:
		return true

	var error_msg = message if not message.is_empty() else "Too many objects: %d objects, limit %d" % [object_count, max_objects]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_nodes_count_less_than(max_nodes: int, message: String = "") -> bool:
	"""Assert that the number of scene nodes is below threshold"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var scene_tree = self
	if not scene_tree:
		var error_msg = message if not message.is_empty() else "No scene tree available for node count check"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var node_count = count_scene_nodes(scene_tree.root)

	if node_count <= max_nodes:
		return true

	var final_error_msg = message if not message.is_empty() else "Too many scene nodes: %d nodes, limit %d" % [node_count, max_nodes]
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func count_scene_nodes(node: Node) -> int:
	"""Count total nodes in scene tree"""
	var count = 1  # Count this node

	for child in node.get_children():
		count += count_scene_nodes(child)

	return count

func assert_physics_active_objects_less_than(max_objects: int, message: String = "") -> bool:
	"""Assert that the number of active physics objects is below threshold"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var active_objects = Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)

	if active_objects <= max_objects:
		return true

	var error_msg = message if not message.is_empty() else "Too many active physics objects: %d objects, limit %d" % [active_objects, max_objects]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# CPU PERFORMANCE TESTING
# ------------------------------------------------------------------------------
func assert_cpu_time_less_than(max_time_ms: float, message: String = "") -> bool:
	"""Assert that CPU processing time is below threshold"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000

	if process_time <= max_time_ms:
		return true

	var error_msg = message if not message.is_empty() else "CPU time too high: %.2f ms, limit %.2f ms" % [process_time, max_time_ms]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_physics_time_less_than(max_time_ms: float, message: String = "") -> bool:
	"""Assert that physics processing time is below threshold"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000

	if physics_time <= max_time_ms:
		return true

	var error_msg = message if not message.is_empty() else "Physics time too high: %.2f ms, limit %.2f ms" % [physics_time, max_time_ms]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# PERFORMANCE BASELINE MANAGEMENT
# ------------------------------------------------------------------------------
func create_performance_baseline(baseline_name: String) -> bool:
	"""Create a performance baseline for future comparison"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var baseline_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"system_info": await get_system_info(),
		"benchmarks": benchmark_results.duplicate(),
		"metrics": performance_metrics.duplicate()
	}

	var baseline_path = "res://performance_baselines/" + baseline_name + ".json"
	var global_path = ProjectSettings.globalize_path(baseline_path)

	# Ensure directory exists
	var dir_path = global_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		var error = DirAccess.make_dir_recursive_absolute(dir_path)
		if error != OK:
			print("❌ Failed to create baseline directory: ", dir_path)
			return false

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(baseline_data, "\t"))
		file.close()
		print("✅ Performance baseline created: ", baseline_path)
		return true

	print("❌ Failed to create performance baseline")
	return false

func load_performance_baseline(baseline_name: String) -> Dictionary:
	"""Load a performance baseline for comparison"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var baseline_path = "res://performance_baselines/" + baseline_name + ".json"
	var global_path = ProjectSettings.globalize_path(baseline_path)

	var file = FileAccess.open(global_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var parsed = JSON.parse_string(content)
		if parsed is Dictionary:
			return parsed

	return {}

func compare_with_baseline(baseline_name: String, tolerance: float = -1.0) -> Dictionary:
	"""Compare current performance with baseline"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	if tolerance < 0:
		tolerance = performance_tolerance

	var baseline_data = await load_performance_baseline(baseline_name)
	if baseline_data.is_empty():
		return {"success": false, "error": "Baseline not found: " + baseline_name}

	var results = {
		"success": true,
		"regressions": [],
		"improvements": [],
		"baseline_timestamp": baseline_data.get("timestamp", 0)
	}

	# Compare benchmark results
	var current_benchmarks = benchmark_results
	var baseline_benchmarks = baseline_data.get("benchmarks", {})

	for benchmark_name in current_benchmarks.keys():
		if baseline_benchmarks.has(benchmark_name):
			var current_result = current_benchmarks[benchmark_name]
			var baseline_result = baseline_benchmarks[benchmark_name]

			var current_avg = current_result.average_time
			var baseline_avg = baseline_result.average_time

			var percent_change = ((current_avg - baseline_avg) / baseline_avg) * 100

			if percent_change > tolerance * 100:
				results.regressions.append({
					"name": benchmark_name,
					"current_time": current_avg,
					"baseline_time": baseline_avg,
					"percent_change": percent_change
				})
				results.success = false
			elif percent_change < -tolerance * 100:
				results.improvements.append({
					"name": benchmark_name,
					"current_time": current_avg,
					"baseline_time": baseline_avg,
					"percent_change": percent_change
				})

	return results

# ------------------------------------------------------------------------------
# SYSTEM INFORMATION
# ------------------------------------------------------------------------------
func get_system_info() -> Dictionary:
	"""Get system information for performance context"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	return {
		"os_name": OS.get_name(),
		"os_version": OS.get_version(),
		"cpu_count": OS.get_processor_count(),
		"cpu_name": OS.get_processor_name(),
		"memory_total": OS.get_memory_info().physical,
		"gpu_name": "Unknown",
		"godot_version": Engine.get_version_info(),
		"project_name": ProjectSettings.get_setting("application/config/name", "Unknown")
	}

# ------------------------------------------------------------------------------
# PERFORMANCE REPORTING
# ------------------------------------------------------------------------------
func generate_performance_report() -> String:
	"""Generate a comprehensive performance report"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	var report = "📊 Performance Test Report\n"
	report += "==========================\n\n"

	# System information
	report += "System Information:\n"
	var sys_info = await get_system_info()
	for key in sys_info.keys():
		report += "  " + key + ": " + str(sys_info[key]) + "\n"
	report += "\n"

	# Performance metrics
	report += "Performance Metrics:\n"
	for key in performance_metrics.keys():
		report += "  " + key + ": " + str(performance_metrics[key]) + "\n"
	report += "\n"

	# Benchmark results
	if not benchmark_results.is_empty():
		report += "Benchmark Results:\n"
		for benchmark_name in benchmark_results.keys():
			var result = benchmark_results[benchmark_name]
			report += "  " + benchmark_name + ":\n"
			report += "    Average: %.2f ms\n" % result.average_time
			report += "    Min: %.2f ms\n" % result.min_time
			report += "    Max: %.2f ms\n" % result.max_time
			report += "    Std Dev: %.2f ms\n" % result.standard_deviation
			report += "    Ops/sec: %.0f\n" % result.operations_per_second
			report += "\n"

	return report

func print_performance_report() -> void:
	"""Print performance report to console"""
	print(await generate_performance_report())

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func wait_for_next_frame() -> void:
	"""Wait for the next frame"""
	await process_frame

func set_performance_thresholds(fps: int = -1, memory_mb: float = -1, cpu_ms: float = -1) -> void:
	"""Set performance thresholds for testing"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	if fps > 0:
		target_fps = fps
	if memory_mb > 0:
		memory_threshold_mb = memory_mb
	if cpu_ms > 0:
		cpu_threshold_ms = cpu_ms

func reset_performance_metrics() -> void:
	"""Reset performance metrics"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	setup_performance_monitoring()

func enable_performance_monitoring(enabled: bool = true) -> void:
	"""Enable or disable detailed performance monitoring"""
	# Add minimal async delay for API consistency
	await wait_for_next_frame()

	if enabled:
		setup_performance_monitoring()
	else:
		performance_metrics.clear()

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup performance test resources"""
	# Print final performance report if verbose
	if not performance_metrics.is_empty():
		print_performance_report()

# ------------------------------------------------------------------------------
# PERFORMANCE STRESS SIMULATION
# ------------------------------------------------------------------------------
func simulate_performance_scenario(scenario_type: String) -> void:
	"""Simulate different performance scenarios for load testing"""
	match scenario_type:
		"memory_stress":
			await _create_memory_stress()
		"cpu_stress":
			await _create_cpu_stress()
		"frame_stress":
			await _create_frame_stress()
		_:
			push_error("Unknown performance scenario: " + scenario_type)

func _create_memory_stress() -> void:
	"""Create sustained memory pressure for testing"""
	# Create sustained memory pressure with retained objects
	var memory_objects = []
	for i in range(50):  # Fewer iterations, bigger objects
		var large_object = {
			"data": [],
			"metadata": {},
			"nested": {}
		}
		for j in range(5000):  # Bigger arrays
			large_object.data.append("memory_data_" + str(j) + "_longer_string_to_use_more_memory")
		memory_objects.append(large_object)  # RETAIN objects!

	await wait_for_next_frame()

	# Memory usage should increase significantly
	print("Created ", memory_objects.size(), " large objects for memory stress testing")

func _create_cpu_stress() -> void:
	"""Create CPU load for testing performance impact"""
	for i in range(50000):  # Much more iterations
		var result = 0.0
		# Complex math operations
		result += sin(float(i) * 0.01) * cos(float(i) * 0.01)
		result += sqrt(abs(float(i))) * tan(float(i) * 0.001)
		result += pow(float(i % 100), 3.0) * log(abs(float(i) + 1))
		# Use result to prevent optimization
		if result > 1000000:
			result = result * 0.1

	await wait_for_next_frame()
	print("Completed 50,000 complex CPU operations for stress testing")

func _create_frame_stress() -> void:
	"""Create frame-based load for testing frame rate impact"""
	for i in range(100):
		await wait_for_next_frame()
	print("Completed 100 frame stress cycles")
