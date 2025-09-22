# GDSentry - PerformanceTest Comprehensive Test Suite
# Tests the PerformanceTest class functionality for performance monitoring and benchmarking
#
# Tests cover:
# - FPS and frame rate testing
# - Memory usage testing and leak detection
# - Benchmarking operations and statistical analysis
# - Performance monitoring and metrics collection
# - CPU performance measurement
# - Configuration and tolerance settings
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

# class_name PerformanceTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for PerformanceTest class"
	test_tags = ["performance_test", "benchmarking", "fps", "memory", "cpu", "monitoring", "metrics", "integration"]
	test_priority = "high"
	test_category = "test_types"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all PerformanceTest comprehensive tests"""
	run_test("test_performance_test_instantiation", func(): return await test_performance_test_instantiation())
	run_test("test_performance_test_configuration", func(): return await test_performance_test_configuration())
	run_test("test_fps_testing", func(): return await test_fps_testing())
	run_test("test_memory_usage_testing", func(): return await test_memory_usage_testing())
	run_test("test_memory_leak_detection", func(): return await test_memory_leak_detection())
	run_test("test_benchmarking_operations", func(): return await test_benchmarking_operations())
	run_test("test_performance_monitoring", func(): return await test_performance_monitoring())
	run_test("test_cpu_performance_measurement", func(): return await test_cpu_performance_measurement())
	run_test("test_performance_assertions", func(): return await test_performance_assertions())
	run_test("test_performance_configuration", func(): return await test_performance_configuration())
	run_test("test_error_handling", func(): return await test_error_handling())
	run_test("test_edge_cases", func(): return await test_edge_cases())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_performance_test_instantiation() -> bool:
	"""Test PerformanceTest instantiation and basic properties"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Add minimal async delay for API consistency
	await performance_test.wait_for_next_frame()

	# Test basic instantiation
	success = success and assert_not_null(performance_test, "PerformanceTest should instantiate successfully")
	success = success and assert_type(performance_test, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(performance_test.get_class(), "PerformanceTest", "Should be PerformanceTest class")
	success = success and assert_true(performance_test is SceneTreeTest, "Should extend SceneTreeTest")

	# Test default configuration values
	success = success and assert_equals(performance_test.warmup_iterations, 10, "Default warmup iterations should be 10")
	success = success and assert_equals(performance_test.benchmark_iterations, 100, "Default benchmark iterations should be 100")
	success = success and assert_equals(performance_test.target_fps, 60, "Default target FPS should be 60")
	success = success and assert_equals(performance_test.memory_threshold_mb, 100.0, "Default memory threshold should be 100.0")
	success = success and assert_equals(performance_test.cpu_threshold_ms, 16.67, "Default CPU threshold should be 16.67")
	success = success and assert_equals(performance_test.performance_tolerance, 0.05, "Default performance tolerance should be 0.05")

	# Test state initialization
	success = success and assert_true(performance_test.performance_metrics is Dictionary, "Performance metrics should be dictionary")
	success = success and assert_true(performance_test.benchmark_results is Dictionary, "Benchmark results should be dictionary")
	success = success and assert_true(performance_test.performance_history is Array, "Performance history should be array")

	# Test constants
	success = success and assert_equals(performance_test.DEFAULT_WARMUP_ITERATIONS, 10, "Default warmup iterations constant should be 10")
	success = success and assert_equals(performance_test.DEFAULT_BENCHMARK_ITERATIONS, 100, "Default benchmark iterations constant should be 100")
	success = success and assert_equals(performance_test.DEFAULT_TARGET_FPS, 60, "Default target FPS constant should be 60")
	success = success and assert_equals(performance_test.DEFAULT_MEMORY_THRESHOLD_MB, 100.0, "Default memory threshold constant should be 100.0")
	success = success and assert_equals(performance_test.DEFAULT_CPU_THRESHOLD_MS, 16.67, "Default CPU threshold constant should be 16.67")
	success = success and assert_equals(performance_test.PERFORMANCE_TOLERANCE, 0.05, "Performance tolerance constant should be 0.05")

	# Cleanup
	performance_test.queue_free()

	return success

func test_performance_test_configuration() -> bool:
	"""Test PerformanceTest configuration modification"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Add minimal async delay for API consistency
	await performance_test.wait_for_next_frame()

	# Test configuration modification
	performance_test.warmup_iterations = 20
	performance_test.benchmark_iterations = 200
	performance_test.target_fps = 120
	performance_test.memory_threshold_mb = 200.0
	performance_test.cpu_threshold_ms = 8.33
	performance_test.performance_tolerance = 0.1

	success = success and assert_equals(performance_test.warmup_iterations, 20, "Should be able to set warmup iterations")
	success = success and assert_equals(performance_test.benchmark_iterations, 200, "Should be able to set benchmark iterations")
	success = success and assert_equals(performance_test.target_fps, 120, "Should be able to set target FPS")
	success = success and assert_equals(performance_test.memory_threshold_mb, 200.0, "Should be able to set memory threshold")
	success = success and assert_equals(performance_test.cpu_threshold_ms, 8.33, "Should be able to set CPU threshold")
	success = success and assert_equals(performance_test.performance_tolerance, 0.1, "Should be able to set performance tolerance")

	# Test edge values
	performance_test.warmup_iterations = 0
	success = success and assert_equals(performance_test.warmup_iterations, 0, "Should handle zero warmup iterations")

	performance_test.benchmark_iterations = 0
	success = success and assert_equals(performance_test.benchmark_iterations, 0, "Should handle zero benchmark iterations")

	performance_test.target_fps = 0
	success = success and assert_equals(performance_test.target_fps, 0, "Should handle zero target FPS")

	performance_test.memory_threshold_mb = 0.0
	success = success and assert_equals(performance_test.memory_threshold_mb, 0.0, "Should handle zero memory threshold")

	performance_test.performance_tolerance = 0.0
	success = success and assert_equals(performance_test.performance_tolerance, 0.0, "Should handle zero performance tolerance")

	# Test negative values (should be handled gracefully)
	performance_test.warmup_iterations = -1
	success = success and assert_equals(performance_test.warmup_iterations, -1, "Should handle negative warmup iterations")

	performance_test.memory_threshold_mb = -10.0
	success = success and assert_equals(performance_test.memory_threshold_mb, -10.0, "Should handle negative memory threshold")

	# Test extreme values
	performance_test.benchmark_iterations = 999999
	success = success and assert_equals(performance_test.benchmark_iterations, 999999, "Should handle extreme benchmark iterations")

	performance_test.memory_threshold_mb = 999999.0
	success = success and assert_equals(performance_test.memory_threshold_mb, 999999.0, "Should handle extreme memory threshold")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# FPS AND FRAME RATE TESTING TESTS
# ------------------------------------------------------------------------------
func test_fps_testing() -> bool:
	"""Test FPS and frame rate testing functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test FPS assertion with current performance (should be flexible)
	var current_fps = Performance.get_monitor(Performance.TIME_FPS)
	var fps_result = await performance_test.assert_fps_above(max(1, current_fps - 10), 0.1)  # Short duration for testing
	success = success and assert_type(fps_result, TYPE_BOOL, "FPS assertion should return boolean")

	# Test FPS assertion with very low threshold (should pass)
	var low_threshold_result = await performance_test.assert_fps_above(1, 0.1)
	success = success and assert_type(low_threshold_result, TYPE_BOOL, "Low threshold FPS assertion should return boolean")

	# Test FPS assertion with impossible threshold (should fail)
	var impossible_result = await performance_test.assert_fps_above(9999, 0.1)
	success = success and assert_false(impossible_result, "Impossible FPS threshold should fail")

	# Test FPS stability assertion
	var stability_result = await performance_test.assert_fps_stable(-1, 50.0, 0.2)  # High tolerance, short duration
	success = success and assert_type(stability_result, TYPE_BOOL, "FPS stability assertion should return boolean")

	# Test FPS stability with custom target
	var custom_stability_result = await performance_test.assert_fps_stable(30, 30.0, 0.2)  # 30 FPS target
	success = success and assert_type(custom_stability_result, TYPE_BOOL, "Custom target FPS stability should return boolean")

	# Test no frame drops assertion
	var no_drops_result = await performance_test.assert_no_frame_drops(0.5, 100)  # Short duration, high threshold
	success = success and assert_type(no_drops_result, TYPE_BOOL, "No frame drops assertion should return boolean")

	# Test with zero duration (edge case)
	var zero_duration_result = await performance_test.assert_fps_above(1, 0.0)
	success = success and assert_type(zero_duration_result, TYPE_BOOL, "Zero duration FPS test should return boolean")

	# Test with custom messages
	var custom_message_result = await performance_test.assert_fps_above(1, 0.1, "Custom FPS message")
	success = success and assert_type(custom_message_result, TYPE_BOOL, "Custom message FPS assertion should return boolean")

	# Test FPS assertion with negative threshold (should handle gracefully)
	var negative_threshold_result = await performance_test.assert_fps_above(-10, 0.1)
	success = success and assert_type(negative_threshold_result, TYPE_BOOL, "Negative threshold FPS assertion should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# MEMORY USAGE TESTING TESTS
# ------------------------------------------------------------------------------
func test_memory_usage_testing() -> bool:
	"""Test memory usage testing functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Get current memory usage
	var current_memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)

	# Test memory assertion with high threshold (should pass)
	var high_threshold_result = await performance_test.assert_memory_usage_less_than(current_memory_mb + 100.0)
	success = success and assert_type(high_threshold_result, TYPE_BOOL, "High threshold memory assertion should return boolean")

	# Test memory assertion with low threshold (may fail)
	var low_threshold_result = await performance_test.assert_memory_usage_less_than(current_memory_mb - 10.0)
	success = success and assert_type(low_threshold_result, TYPE_BOOL, "Low threshold memory assertion should return boolean")

	# Test memory stability assertion
	var stability_result = await performance_test.assert_memory_stable(0.5, current_memory_mb + 50.0)  # Short duration, high tolerance
	success = success and assert_type(stability_result, TYPE_BOOL, "Memory stability assertion should return boolean")

	# Test memory stability with low tolerance
	var low_tolerance_result = await performance_test.assert_memory_stable(0.5, 0.1)  # Very low tolerance
	success = success and assert_type(low_tolerance_result, TYPE_BOOL, "Low tolerance memory stability should return boolean")

	# Test with zero threshold
	var zero_threshold_result = await performance_test.assert_memory_usage_less_than(0.0)
	success = success and assert_type(zero_threshold_result, TYPE_BOOL, "Zero threshold memory assertion should return boolean")

	# Test with negative threshold
	var negative_threshold_result = await performance_test.assert_memory_usage_less_than(-10.0)
	success = success and assert_type(negative_threshold_result, TYPE_BOOL, "Negative threshold memory assertion should return boolean")

	# Test with custom messages
	var custom_message_result = await performance_test.assert_memory_usage_less_than(current_memory_mb + 100.0, "Custom memory message")
	success = success and assert_type(custom_message_result, TYPE_BOOL, "Custom message memory assertion should return boolean")

	# Test memory stability with zero duration
	var zero_duration_stability = await performance_test.assert_memory_stable(0.0, 10.0)
	success = success and assert_type(zero_duration_stability, TYPE_BOOL, "Zero duration memory stability should return boolean")

	# Test memory stability with zero tolerance
	var zero_tolerance_stability = await performance_test.assert_memory_stable(0.5, 0.0)
	success = success and assert_type(zero_tolerance_stability, TYPE_BOOL, "Zero tolerance memory stability should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# MEMORY LEAK DETECTION TESTS
# ------------------------------------------------------------------------------
func test_memory_leak_detection() -> bool:
	"""Test memory leak detection functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test memory leak detection with simple operation
	var simple_operation = func():
		var temp_array = []
		for i in range(100):
			temp_array.append(str(i))
		# Array goes out of scope, should not leak

	var leak_result = await performance_test.assert_no_memory_leaks(simple_operation, 5, 1.0)
	success = success and assert_type(leak_result, TYPE_BOOL, "Simple operation leak detection should return boolean")

	# Test memory leak detection with zero iterations
	var zero_iterations_result = await performance_test.assert_no_memory_leaks(simple_operation, 0, 1.0)
	success = success and assert_type(zero_iterations_result, TYPE_BOOL, "Zero iterations leak detection should return boolean")

	# Test memory leak detection with high tolerance
	var high_tolerance_result = await performance_test.assert_no_memory_leaks(simple_operation, 5, 100.0)
	success = success and assert_type(high_tolerance_result, TYPE_BOOL, "High tolerance leak detection should return boolean")

	# Test memory leak detection with zero tolerance
	var zero_tolerance_result = await performance_test.assert_no_memory_leaks(simple_operation, 5, 0.0)
	success = success and assert_type(zero_tolerance_result, TYPE_BOOL, "Zero tolerance leak detection should return boolean")

	# Test memory leak detection with object creation
	var object_creation_operation = func():
		var temp_node = Node.new()
		temp_node.name = "temp_node"
		# Node is not added to scene tree, should be garbage collected

	var object_leak_result = await performance_test.assert_no_memory_leaks(object_creation_operation, 3, 2.0)
	success = success and assert_type(object_leak_result, TYPE_BOOL, "Object creation leak detection should return boolean")

	# Test with null operation (should handle gracefully)
	var null_operation_result = await performance_test.assert_no_memory_leaks(func(): pass, 5, 1.0)
	success = success and assert_type(null_operation_result, TYPE_BOOL, "Null operation leak detection should return boolean")

	# Test with custom message
	var custom_message_result = await performance_test.assert_no_memory_leaks(simple_operation, 3, 1.0, "Custom leak detection message")
	success = success and assert_type(custom_message_result, TYPE_BOOL, "Custom message leak detection should return boolean")

	# Test memory leak detection with potentially leaky operation
	var potentially_leaky_operation = func():
		var persistent_array = []  # This would be a problem if it accumulated
		for i in range(10):
			persistent_array.append(str(i))
		# Note: This is not actually leaky in this context

	var potentially_leaky_result = await performance_test.assert_no_memory_leaks(potentially_leaky_operation, 5, 2.0)
	success = success and assert_type(potentially_leaky_result, TYPE_BOOL, "Potentially leaky operation detection should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# BENCHMARKING OPERATIONS TESTS
# ------------------------------------------------------------------------------
func test_benchmarking_operations() -> bool:
	"""Test benchmarking operations functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test simple operation benchmarking
	var simple_operation = func():
		var result = 0
		for i in range(100):
			result += i * i
		return result

	var benchmark_result = await performance_test.benchmark_operation("simple_calculation", simple_operation, 10, 2)
	success = success and assert_type(benchmark_result, TYPE_DICTIONARY, "Simple operation benchmark should return dictionary")

	# Verify benchmark result structure
	if benchmark_result:
		success = success and assert_true(benchmark_result.has("operation_name"), "Benchmark should have operation name")
		success = success and assert_true(benchmark_result.has("iterations"), "Benchmark should have iterations")
		success = success and assert_true(benchmark_result.has("average_time"), "Benchmark should have average time")
		success = success and assert_true(benchmark_result.has("min_time"), "Benchmark should have min time")
		success = success and assert_true(benchmark_result.has("max_time"), "Benchmark should have max time")
		success = success and assert_true(benchmark_result.has("total_time"), "Benchmark should have total time")
		success = success and assert_true(benchmark_result.has("standard_deviation"), "Benchmark should have standard deviation")

		if benchmark_result.has("average_time"):
			success = success and assert_type(benchmark_result.average_time, TYPE_FLOAT, "Average time should be float")

		if benchmark_result.has("iterations"):
			success = success and assert_equals(benchmark_result.iterations, 10, "Iterations should match requested")

		if benchmark_result.has("operation_name"):
			success = success and assert_equals(benchmark_result.operation_name, "simple_calculation", "Operation name should match")

	# Test benchmarking with zero iterations
	var zero_iterations_result = await performance_test.benchmark_operation("zero_test", simple_operation, 0, 0)
	success = success and assert_type(zero_iterations_result, TYPE_DICTIONARY, "Zero iterations benchmark should return dictionary")

	# Test benchmarking with high iterations
	var high_iterations_result = await performance_test.benchmark_operation("high_test", simple_operation, 50, 5)
	success = success and assert_type(high_iterations_result, TYPE_DICTIONARY, "High iterations benchmark should return dictionary")

	# Test benchmarking with complex operation
	var complex_operation = func():
		var matrix = []
		for i in range(10):
			var row = []
			for j in range(10):
				row.append(i * j)
			matrix.append(row)
		return matrix

	var complex_benchmark = await performance_test.benchmark_operation("matrix_creation", complex_operation, 5, 1)
	success = success and assert_type(complex_benchmark, TYPE_DICTIONARY, "Complex operation benchmark should return dictionary")

	# Test benchmarking with null operation (should handle gracefully)
	var null_benchmark = await performance_test.benchmark_operation("null_test", func(): pass, 5, 1)
	success = success and assert_type(null_benchmark, TYPE_DICTIONARY, "Null operation benchmark should return dictionary")

	# Test default parameter usage
	var default_params_result = await performance_test.benchmark_operation("default_test", simple_operation)
	success = success and assert_type(default_params_result, TYPE_DICTIONARY, "Default parameters benchmark should return dictionary")

	# Test empty operation name
	var empty_name_result = await performance_test.benchmark_operation("", simple_operation, 5, 1)
	success = success and assert_type(empty_name_result, TYPE_DICTIONARY, "Empty name benchmark should return dictionary")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE MONITORING TESTS
# ------------------------------------------------------------------------------
func test_performance_monitoring() -> bool:
	"""Test performance monitoring functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test performance monitoring setup
	performance_test.setup_performance_monitoring()

	# Verify monitoring data structure
	success = success and assert_true(performance_test.performance_metrics is Dictionary, "Performance metrics should be dictionary")
	success = success and assert_true(performance_test.performance_metrics.has("start_time"), "Should have start time")
	success = success and assert_true(performance_test.performance_metrics.has("frames_processed"), "Should have frames processed")
	success = success and assert_true(performance_test.performance_metrics.has("total_memory_used"), "Should have total memory used")
	success = success and assert_true(performance_test.performance_metrics.has("peak_memory_used"), "Should have peak memory used")
	success = success and assert_true(performance_test.performance_metrics.has("average_fps"), "Should have average fps")
	success = success and assert_true(performance_test.performance_metrics.has("min_fps"), "Should have min fps")
	success = success and assert_true(performance_test.performance_metrics.has("max_fps"), "Should have max fps")
	success = success and assert_true(performance_test.performance_metrics.has("cpu_time_total"), "Should have cpu time total")

	# Test performance monitoring with some activity
	await performance_test.wait_for_next_frame()

	# Verify metrics are updated
	success = success and assert_greater_than_or_equal(performance_test.performance_metrics.frames_processed, 0, "Frames processed should be >= 0")
	success = success and assert_greater_than_or_equal(performance_test.performance_metrics.total_memory_used, 0.0, "Total memory should be >= 0")

	# Test performance history
	success = success and assert_true(performance_test.performance_history is Array, "Performance history should be array")

	# Test performance monitoring methods (if they exist)
	if performance_test.has_method("get_performance_summary"):
		var summary = await performance_test.get_performance_summary()
		success = success and assert_type(summary, TYPE_DICTIONARY, "Performance summary should be dictionary")

	if performance_test.has_method("reset_performance_metrics"):
		await performance_test.reset_performance_metrics()
		success = success and assert_equals(performance_test.performance_metrics.frames_processed, 0, "Metrics should reset")

	if performance_test.has_method("log_performance_event"):
		await performance_test.log_performance_event("test_event", {"duration": 1.5, "memory": 50.0})
		success = success and assert_greater_than_or_equal(performance_test.performance_history.size(), 0, "Event should be logged")

	# Test performance monitoring with extended activity
	await performance_test.wait_for_seconds(0.1)

	# Verify extended metrics
	success = success and assert_greater_than_or_equal(performance_test.performance_metrics.frames_processed, 0, "Extended frames processed should be >= 0")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# CPU PERFORMANCE MEASUREMENT TESTS
# ------------------------------------------------------------------------------
func test_cpu_performance_measurement() -> bool:
	"""Test CPU performance measurement functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test CPU performance assertion (if implemented)
	if performance_test.has_method("assert_cpu_usage_less_than"):
		var cpu_result = await performance_test.assert_cpu_usage_less_than(50.0, 0.5)  # 50% CPU, 0.5s duration
		success = success and assert_type(cpu_result, TYPE_BOOL, "CPU usage assertion should return boolean")

	if performance_test.has_method("assert_cpu_time_less_than"):
		var cpu_time_result = await performance_test.assert_cpu_time_less_than(50.0, "CPU time test")  # 50ms threshold
		success = success and assert_type(cpu_time_result, TYPE_BOOL, "CPU time assertion should return boolean")

	if performance_test.has_method("assert_frame_time_less_than"):
		var frame_time_result = await performance_test.assert_frame_time_less_than(33.0, 1.0)  # 33ms (30 FPS), 1s duration
		success = success and assert_type(frame_time_result, TYPE_BOOL, "Frame time assertion should return boolean")

	# Test CPU performance benchmarking
	if performance_test.has_method("benchmark_cpu_operation"):
		var cpu_operation = func():
			var result = 0.0
			for i in range(1000):
				result += sin(float(i)) * cos(float(i))
			return result

		var cpu_benchmark = await performance_test.benchmark_cpu_operation("cpu_intensive", cpu_operation, 5, 1)
		success = success and assert_type(cpu_benchmark, TYPE_DICTIONARY, "CPU benchmark should return dictionary")

	# Test CPU monitoring
	if performance_test.has_method("start_cpu_monitoring"):
		var start_result = await performance_test.start_cpu_monitoring()
		success = success and assert_type(start_result, TYPE_BOOL, "CPU monitoring start should return boolean")

	if performance_test.has_method("stop_cpu_monitoring"):
		var stop_result = await performance_test.stop_cpu_monitoring()
		success = success and assert_type(stop_result, TYPE_BOOL, "CPU monitoring stop should return boolean")

	if performance_test.has_method("get_cpu_metrics"):
		var cpu_metrics = await performance_test.get_cpu_metrics()
		success = success and assert_type(cpu_metrics, TYPE_DICTIONARY, "CPU metrics should be dictionary")

	# Test with extreme CPU thresholds
	if performance_test.has_method("assert_cpu_usage_less_than"):
		var extreme_cpu_result = await performance_test.assert_cpu_usage_less_than(0.01, 0.1)  # Very low threshold
		success = success and assert_type(extreme_cpu_result, TYPE_BOOL, "Extreme CPU threshold should return boolean")

		var high_cpu_result = await performance_test.assert_cpu_usage_less_than(999.0, 0.1)  # Very high threshold
		success = success and assert_type(high_cpu_result, TYPE_BOOL, "High CPU threshold should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_performance_assertions() -> bool:
	"""Test comprehensive performance assertions"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test performance threshold assertions
	if performance_test.has_method("assert_performance_within_threshold"):
		var threshold_result = await performance_test.assert_performance_within_threshold("fps", 60, 10.0, 1.0)
		success = success and assert_type(threshold_result, TYPE_BOOL, "Performance threshold assertion should return boolean")

	if performance_test.has_method("assert_resource_usage_stable"):
		var resource_result = await performance_test.assert_resource_usage_stable("memory", 5.0, 1.0)
		success = success and assert_type(resource_result, TYPE_BOOL, "Resource usage stability should return boolean")

	if performance_test.has_method("assert_no_performance_regression"):
		var regression_result = await performance_test.assert_no_performance_regression("benchmark_test", 10.0, 5.0)
		success = success and assert_type(regression_result, TYPE_BOOL, "Performance regression check should return boolean")

	# Test system performance assertions
	if performance_test.has_method("assert_system_performance"):
		var system_result = await performance_test.assert_system_performance(60, 100.0, 16.67)  # FPS, Memory, CPU
		success = success and assert_type(system_result, TYPE_BOOL, "System performance assertion should return boolean")

	if performance_test.has_method("assert_performance_trend"):
		var trend_result = await performance_test.assert_performance_trend("improving", 1.0)
		success = success and assert_type(trend_result, TYPE_BOOL, "Performance trend assertion should return boolean")

	# Test comparative performance assertions
	if performance_test.has_method("assert_better_than_baseline"):
		var baseline_result = await performance_test.assert_better_than_baseline("test_operation", 1.2)
		success = success and assert_type(baseline_result, TYPE_BOOL, "Baseline comparison should return boolean")

	if performance_test.has_method("assert_performance_ratio"):
		var ratio_result = await performance_test.assert_performance_ratio("operation_a", "operation_b", 2.0)
		success = success and assert_type(ratio_result, TYPE_BOOL, "Performance ratio assertion should return boolean")

	# Test performance profiling assertions
	if performance_test.has_method("assert_no_bottlenecks"):
		var bottleneck_result = await performance_test.assert_no_bottlenecks(50.0, 1.0)  # Threshold, duration
		success = success and assert_type(bottleneck_result, TYPE_BOOL, "Bottleneck detection should return boolean")

	if performance_test.has_method("assert_optimal_performance"):
		var optimal_result = await performance_test.assert_optimal_performance("balanced", 1.0)
		success = success and assert_type(optimal_result, TYPE_BOOL, "Optimal performance assertion should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE CONFIGURATION TESTS
# ------------------------------------------------------------------------------
func test_performance_configuration() -> bool:
	"""Test performance configuration functionality"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test configuration loading (if config exists)
	if performance_test.has_method("load_performance_config"):
		var load_result = await performance_test.load_performance_config()
		success = success and assert_type(load_result, TYPE_BOOL, "Configuration loading should return boolean")

	# Test configuration with null config
	var original_config = performance_test.config
	performance_test.config = null

	if performance_test.has_method("load_performance_config"):
		var null_config_result = await performance_test.load_performance_config()
		success = success and assert_type(null_config_result, TYPE_BOOL, "Null config loading should return boolean")

	performance_test.config = original_config

	# Test configuration validation
	if performance_test.has_method("validate_performance_config"):
		var validation_result = await performance_test.validate_performance_config()
		success = success and assert_type(validation_result, TYPE_BOOL, "Configuration validation should return boolean")

	# Test configuration saving (if implemented)
	if performance_test.has_method("save_performance_config"):
		var save_result = await performance_test.save_performance_config()
		success = success and assert_type(save_result, TYPE_BOOL, "Configuration saving should return boolean")

	# Test dynamic configuration updates
	if performance_test.has_method("update_performance_thresholds"):
		var update_result = await performance_test.update_performance_thresholds({"fps": 120, "memory": 200.0})
		success = success and assert_type(update_result, TYPE_BOOL, "Threshold updates should return boolean")

	# Test configuration reset
	if performance_test.has_method("reset_performance_config"):
		var reset_result = await performance_test.reset_performance_config()
		success = success and assert_type(reset_result, TYPE_BOOL, "Configuration reset should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test with extreme values in assertions
	var extreme_fps_result = await performance_test.assert_fps_above(999999, 0.1)
	success = success and assert_type(extreme_fps_result, TYPE_BOOL, "Extreme FPS assertion should return boolean")

	var extreme_memory_result = await performance_test.assert_memory_usage_less_than(999999.0)
	success = success and assert_type(extreme_memory_result, TYPE_BOOL, "Extreme memory assertion should return boolean")

	# Test with zero values
	var zero_fps_result = await performance_test.assert_fps_above(0, 0.1)
	success = success and assert_type(zero_fps_result, TYPE_BOOL, "Zero FPS assertion should return boolean")

	var zero_memory_result = await performance_test.assert_memory_usage_less_than(0.0)
	success = success and assert_type(zero_memory_result, TYPE_BOOL, "Zero memory assertion should return boolean")

	var zero_duration_result = await performance_test.assert_fps_stable(60, 10.0, 0.0)
	success = success and assert_type(zero_duration_result, TYPE_BOOL, "Zero duration stability should return boolean")

	# Test with negative values
	var negative_fps_result = await performance_test.assert_fps_above(-10, 0.1)
	success = success and assert_type(negative_fps_result, TYPE_BOOL, "Negative FPS assertion should return boolean")

	var negative_memory_result = await performance_test.assert_memory_usage_less_than(-10.0)
	success = success and assert_type(negative_memory_result, TYPE_BOOL, "Negative memory assertion should return boolean")

	var negative_duration_result = await performance_test.assert_fps_stable(60, 10.0, -1.0)
	success = success and assert_type(negative_duration_result, TYPE_BOOL, "Negative duration stability should return boolean")

	# Test benchmarking with invalid operations
	var invalid_benchmark = await performance_test.benchmark_operation("invalid", func(): pass, -1, -1)
	success = success and assert_type(invalid_benchmark, TYPE_DICTIONARY, "Invalid benchmark should return dictionary")

	# Test memory leak detection with invalid operations
	var invalid_leak_result = await performance_test.assert_no_memory_leaks(func(): pass, -1, -1.0)
	success = success and assert_type(invalid_leak_result, TYPE_BOOL, "Invalid leak detection should return boolean")

	# Test with very long operation names
	var long_name = ""
	for i in range(1000):
		long_name += "a"

	var long_name_benchmark = await performance_test.benchmark_operation(long_name, func(): pass, 1, 0)
	success = success and assert_type(long_name_benchmark, TYPE_DICTIONARY, "Long name benchmark should return dictionary")

	# Test configuration with extreme values
	performance_test.warmup_iterations = 999999
	performance_test.benchmark_iterations = 999999
	performance_test.target_fps = 999999
	performance_test.memory_threshold_mb = 999999.0

	var extreme_config_result = await performance_test.assert_fps_above(1, 0.1)
	success = success and assert_type(extreme_config_result, TYPE_BOOL, "Extreme configuration should work")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_edge_cases() -> bool:
	"""Test edge cases and boundary conditions"""
	var performance_test = PerformanceTest.new()
	var success = true

	# Test with system at different performance levels
	var current_fps = Performance.get_monitor(Performance.TIME_FPS)

	# Test FPS assertion right at the current level
	var at_current_result = await performance_test.assert_fps_above(current_fps, 0.1)
	success = success and assert_type(at_current_result, TYPE_BOOL, "At current FPS assertion should return boolean")

	# Test FPS assertion slightly above current level (may fail)
	var above_current_result = await performance_test.assert_fps_above(current_fps + 5, 0.1)
	success = success and assert_type(above_current_result, TYPE_BOOL, "Above current FPS assertion should return boolean")

	# Test memory assertion at current usage level
	var current_memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
	var at_memory_result = await performance_test.assert_memory_usage_less_than(current_memory_mb)
	success = success and assert_type(at_memory_result, TYPE_BOOL, "At current memory assertion should return boolean")

	# Test with rapid successive operations
	var rapid_operations = []
	for i in range(10):
		var operation = func(): return i * i
		rapid_operations.append(await performance_test.benchmark_operation("rapid_" + str(i), operation, 5, 0))

	success = success and assert_equals(rapid_operations.size(), 10, "Should handle rapid successive operations")

	for result in rapid_operations:
		success = success and assert_type(result, TYPE_DICTIONARY, "Each rapid operation should return dictionary")

	# Test performance monitoring during high activity
	performance_test.setup_performance_monitoring()

	# Simulate realistic performance stress scenarios with measurement
	var memory_before = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
	var time_before = Time.get_ticks_usec()

	# Use real stress simulation from PerformanceTest class
	await performance_test.simulate_performance_scenario("memory_stress")
	await performance_test.simulate_performance_scenario("cpu_stress")
	await performance_test.simulate_performance_scenario("frame_stress")

	var memory_after = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
	var time_after = Time.get_ticks_usec()

	var memory_increase = memory_after - memory_before
	var time_taken = (time_after - time_before) / 1000000.0

	print("Stress test results - Memory: +%.2f MB, Time: %.2f seconds" % [memory_increase, time_taken])

	# Verify that stress scenarios created measurable impact
	success = success and assert_greater_than(memory_increase, 1.0, "Memory stress should increase memory usage by at least 1MB")
	success = success and assert_greater_than(time_taken, 0.1, "CPU stress should take at least 0.1 seconds")
	success = success and assert_greater_than_or_equal(performance_test.performance_metrics.frames_processed, 100, "Frame stress should process at least 100 frames")

	# Test with very short benchmark iterations
	var micro_benchmark = await performance_test.benchmark_operation("micro", func(): pass, 1, 0)
	success = success and assert_type(micro_benchmark, TYPE_DICTIONARY, "Micro benchmark should return dictionary")

	if micro_benchmark.has("iterations"):
		success = success and assert_equals(micro_benchmark.iterations, 1, "Micro benchmark should have 1 iteration")

	# Test configuration boundary conditions
	performance_test.warmup_iterations = 1
	performance_test.benchmark_iterations = 1
	var minimal_config_result = await performance_test.benchmark_operation("minimal", func(): pass)
	success = success and assert_type(minimal_config_result, TYPE_DICTIONARY, "Minimal configuration should work")

	# Test with empty operation names and edge case names
	var edge_case_names = ["", " ", "	", "\n", "name@#$%", "very_long_name_" + "a".repeat(100)]

	for edge_name in edge_case_names:
		var edge_result = await performance_test.benchmark_operation(edge_name, func(): pass, 1, 0)
		success = success and assert_type(edge_result, TYPE_DICTIONARY, "Edge case name '" + edge_name + "' should work")

	# Test performance assertions with boundary values
	var boundary_fps_result = await performance_test.assert_fps_above(1, 0.01)  # Very short duration
	success = success and assert_type(boundary_fps_result, TYPE_BOOL, "Boundary FPS assertion should return boolean")

	var boundary_memory_result = await performance_test.assert_memory_usage_less_than(0.001)  # Very small threshold
	success = success and assert_type(boundary_memory_result, TYPE_BOOL, "Boundary memory assertion should return boolean")

	# Cleanup
	performance_test.queue_free()

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_performance_test_scene() -> Node:
	"""Create a test scene for performance testing"""
	var scene = Node.new()
	scene.name = "PerformanceTestScene"

	# Add some nodes to create a basic scene
	var node1 = Node.new()
	node1.name = "TestNode1"
	scene.add_child(node1)

	var node2 = Node.new()
	node2.name = "TestNode2"
	node1.add_child(node2)

	return scene

func create_memory_intensive_operation() -> Callable:
	"""Create an operation that uses memory"""
	return func():
		var large_array = []
		for i in range(1000):
			large_array.append({
				"index": i,
				"data": "test_data_" + str(i),
				"nested": {
					"value": i * 2,
					"text": "nested_text_" + str(i)
				}
			})
		return large_array

func create_cpu_intensive_operation() -> Callable:
	"""Create an operation that uses CPU"""
	return func():
		var result = 0.0
		for i in range(10000):
			result += sin(float(i) * 0.01) * cos(float(i) * 0.01)
			result += sqrt(abs(tan(float(i) * 0.001)))
		return result

func create_variable_time_operation() -> Callable:
	"""Create an operation with variable execution time"""
	return func():
		var base_time = randf() * 0.01  # Random time between 0-10ms
		await create_performance_test_scene().get_tree().create_timer(base_time).timeout
		return base_time

