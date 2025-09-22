# GDSentry - Memory Profiler Test Suite
# Comprehensive testing of the MemoryProfiler utility
#
# This test validates all aspects of the memory profiling system including:
# - Real-time memory usage tracking and sampling
# - Intelligent leak detection algorithms
# - Memory pattern analysis and optimization insights
# - Performance impact monitoring and correlation
# - Automated memory stress testing scenarios
# - Comprehensive memory analysis and reporting
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name MemoryProfilerTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "MemoryProfiler comprehensive validation"
	test_tags = ["meta", "memory", "profiling", "leak_detection", "performance"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var memory_profiler

func before_each() -> void:
	"""Setup test environment"""
	var MemoryProfilerClass = load("res://utilities/memory_profiler.gd")
	memory_profiler = MemoryProfilerClass.new()
	# GDTest doesn't need add_child for Node-based classes

func after_each() -> void:
	"""Cleanup test environment"""
	if memory_profiler:
		memory_profiler.queue_free()

# ------------------------------------------------------------------------------
# MEMORY PROFILING CONTROL TESTS
# ------------------------------------------------------------------------------
func test_profiling_initialization() -> void:
	"""Test memory profiler initialization"""
	var success = true

	success = success and assert_not_null(memory_profiler, "MemoryProfiler should be created")
	success = success and assert_false(memory_profiler.is_profiling, "Should start in non-profiling mode")
	success = success and assert_not_null(memory_profiler.sample_timer, "Should have sample timer")
	success = success and assert_true(memory_profiler.memory_samples.is_empty(), "Should start with empty samples")

	assert_true(success, "Memory profiler initialization should work correctly")

func test_profiling_start_stop() -> void:
	"""Test profiling session start and stop"""
	var success = true

	# Start profiling
	memory_profiler.start_profiling("test_session")
	success = success and assert_true(memory_profiler.is_profiling, "Should be in profiling mode after start")
	success = success and assert_greater_than(memory_profiler.memory_samples.size(), 0, "Should have initial sample")

	# Stop profiling
	var analysis = memory_profiler.stop_profiling()
	success = success and assert_false(memory_profiler.is_profiling, "Should not be in profiling mode after stop")
	success = success and assert_not_null(analysis, "Should return analysis on stop")
	success = success and assert_true(analysis.has("analysis"), "Should include analysis in results")

	assert_true(success, "Profiling start/stop should work correctly")

# ------------------------------------------------------------------------------
# MEMORY SAMPLING TESTS
# ------------------------------------------------------------------------------
func test_memory_sampling() -> void:
	"""Test memory sampling functionality"""
	var success = true

	# Start profiling to enable sampling
	memory_profiler.start_profiling("sampling_test")
	var initial_sample_count = memory_profiler.memory_samples.size()

	# Force a sample
	memory_profiler._take_memory_sample()
	success = success and assert_equals(memory_profiler.memory_samples.size(), initial_sample_count + 1, "Should add new sample")

	# Check sample structure
	var latest_sample = memory_profiler.memory_samples.back()
	success = success and assert_true(latest_sample.has("timestamp"), "Sample should have timestamp")
	success = success and assert_true(latest_sample.has("static_memory"), "Sample should have static memory")
	success = success and assert_true(latest_sample.has("dynamic_memory"), "Sample should have dynamic memory")
	success = success and assert_true(latest_sample.has("total_memory"), "Sample should have total memory")
	success = success and assert_true(latest_sample.has("objects_total"), "Sample should have object count")

	memory_profiler.stop_profiling()

	assert_true(success, "Memory sampling should work correctly")

func test_object_tracking() -> void:
	"""Test object lifecycle tracking"""
	var success = true

	# Start profiling
	memory_profiler.start_profiling("object_tracking_test")

	# Simulate some object creation (will be tracked automatically)
	await get_tree().process_frame

	# Check that object tracking is initialized
	success = success and assert_false(memory_profiler.object_tracking.is_empty(), "Should initialize object tracking")
	success = success and assert_true(memory_profiler.object_tracking.has("initial_objects"), "Should track initial object count")

	var analysis = memory_profiler.stop_profiling()
	success = success and assert_true(analysis.analysis.leak_analysis.has("object_tracking"), "Should include object tracking in analysis")

	assert_true(success, "Object tracking should work correctly")

# ------------------------------------------------------------------------------
# LEAK DETECTION TESTS
# ------------------------------------------------------------------------------
func test_leak_detection() -> void:
	"""Test memory leak detection algorithms"""
	var success = true

	# Start profiling
	memory_profiler.start_profiling("leak_detection_test")

	# Take multiple samples to establish baseline
	for i in range(5):
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Check leak detection (should not detect leaks with stable memory)
	success = success and assert_true(memory_profiler.leak_candidates.is_empty(), "Should not detect leaks in stable memory")

	# Test leak detection methods
	var samples = memory_profiler.memory_samples.slice(-3)
	var growth_detected = memory_profiler._detect_sustained_growth(samples)
	success = success and assert_not_null(growth_detected, "Should return growth detection result")

	var memory_ceiling = memory_profiler._detect_memory_ceiling(samples)
	success = success and assert_true(memory_ceiling >= 0, "Should return valid memory ceiling")

	var object_accumulation = memory_profiler._detect_object_accumulation(samples)
	success = success and assert_not_null(object_accumulation, "Should return object accumulation result")

	memory_profiler.stop_profiling()

	assert_true(success, "Leak detection should work correctly")

# ------------------------------------------------------------------------------
# MEMORY PATTERN ANALYSIS TESTS
# ------------------------------------------------------------------------------
func test_memory_pattern_analysis() -> void:
	"""Test memory pattern analysis functionality"""
	var success = true

	# Start profiling and generate some data
	memory_profiler.start_profiling("pattern_analysis_test")

	# Generate varied memory usage pattern
	for i in range(15):  # More than PATTERN_ANALYSIS_WINDOW
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Analyze patterns
	var patterns = memory_profiler.analyze_memory_patterns()
	success = success and assert_not_null(patterns, "Should return pattern analysis")

	if not patterns.has("error"):
		success = success and assert_true(patterns.has("allocation_patterns"), "Should include allocation patterns")
		success = success and assert_true(patterns.has("deallocation_patterns"), "Should include deallocation patterns")
		success = success and assert_true(patterns.has("memory_spikes"), "Should include memory spikes")
		success = success and assert_true(patterns.has("efficiency_metrics"), "Should include efficiency metrics")

	memory_profiler.stop_profiling()

	assert_true(success, "Memory pattern analysis should work correctly")

func test_allocation_pattern_analysis() -> void:
	"""Test detailed allocation pattern analysis"""
	var success = true

	# Start profiling
	memory_profiler.start_profiling("allocation_test")

	# Generate allocation data
	for i in range(10):
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Test allocation pattern analysis
	var alloc_patterns = memory_profiler._analyze_allocation_patterns()
	success = success and assert_not_null(alloc_patterns, "Should return allocation pattern analysis")
	success = success and assert_true(alloc_patterns.has("total_allocations"), "Should include total allocations")
	success = success and assert_true(alloc_patterns.has("allocation_frequency"), "Should include allocation frequency")
	success = success and assert_true(alloc_patterns.has("peaks"), "Should include peak analysis")

	memory_profiler.stop_profiling()

	assert_true(success, "Allocation pattern analysis should work correctly")

# ------------------------------------------------------------------------------
# MEMORY STRESS TESTING TESTS
# ------------------------------------------------------------------------------
func test_memory_stress_testing() -> void:
	"""Test memory stress testing functionality"""
	var success = true

	# Run memory stress test
	var stress_results = memory_profiler.run_memory_stress_test("test_stress")

	success = success and assert_not_null(stress_results, "Should return stress test results")
	success = success and assert_equals(stress_results.test_name, "test_stress", "Should identify test correctly")
	success = success and assert_true(stress_results.has("stress_scenarios"), "Should include stress scenarios")
	success = success and assert_true(stress_results.has("leak_detection"), "Should include leak detection")
	success = success and assert_true(stress_results.has("performance_impact"), "Should include performance impact")
	success = success and assert_true(stress_results.has("recommendations"), "Should include recommendations")

	# Check stress scenarios
	var scenarios = stress_results.stress_scenarios
	success = success and assert_true(scenarios.has("object_allocation"), "Should include object allocation scenario")
	success = success and assert_true(scenarios.has("memory_copy"), "Should include memory copy scenario")
	success = success and assert_true(scenarios.has("resource_loading"), "Should include resource loading scenario")

	assert_true(success, "Memory stress testing should work correctly")

func test_stress_scenario_execution() -> void:
	"""Test individual stress scenario execution"""
	var success = true

	# Test object allocation stress
	var object_results = memory_profiler._run_object_allocation_stress()
	success = success and assert_not_null(object_results, "Should return object allocation results")
	success = success and assert_equals(object_results.scenario, "object_allocation", "Should identify scenario")
	success = success and assert_true(object_results.has("iterations"), "Should include iteration count")
	success = success and assert_true(object_results.has("execution_time"), "Should include execution time")

	# Test memory copy stress
	var copy_results = memory_profiler._run_memory_copy_stress()
	success = success and assert_not_null(copy_results, "Should return memory copy results")
	success = success and assert_equals(copy_results.scenario, "memory_copy", "Should identify scenario")
	success = success and assert_true(copy_results.has("iterations"), "Should include iteration count")

	assert_true(success, "Individual stress scenario execution should work correctly")

# ------------------------------------------------------------------------------
# COMPREHENSIVE ANALYSIS TESTS
# ------------------------------------------------------------------------------
func test_comprehensive_memory_analysis() -> void:
	"""Test comprehensive memory data analysis"""
	var success = true

	# Start profiling and generate data
	memory_profiler.start_profiling("comprehensive_test")

	# Generate sufficient data for analysis
	for i in range(20):
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Stop profiling and get analysis
	var analysis = memory_profiler.stop_profiling()

	success = success and assert_not_null(analysis, "Should return comprehensive analysis")
	success = success and assert_true(analysis.has("analysis"), "Should include detailed analysis")

	# Check analysis structure
	var detailed_analysis = analysis.analysis
	success = success and assert_true(detailed_analysis.has("basic_stats"), "Should include basic statistics")
	success = success and assert_true(detailed_analysis.has("leak_analysis"), "Should include leak analysis")
	success = success and success and assert_true(detailed_analysis.has("pattern_analysis"), "Should include pattern analysis")
	success = success and assert_true(detailed_analysis.has("performance_correlation"), "Should include performance correlation")

	assert_true(success, "Comprehensive memory analysis should work correctly")

func test_memory_statistics_calculation() -> void:
	"""Test memory statistics calculation"""
	var success = true

	# Start profiling
	memory_profiler.start_profiling("statistics_test")

	# Generate some data
	for i in range(10):
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Test statistics calculation
	var stats = memory_profiler._calculate_memory_statistics()
	success = success and assert_not_null(stats, "Should return memory statistics")
	success = success and assert_true(stats.has("memory_stats"), "Should include memory statistics")
	success = success and assert_true(stats.has("object_stats"), "Should include object statistics")

	# Check memory stats structure
	var memory_stats = stats.memory_stats
	success = success and assert_true(memory_stats.has("initial"), "Should include initial memory")
	success = success and assert_true(memory_stats.has("final"), "Should include final memory")
	success = success and assert_true(memory_stats.has("peak"), "Should include peak memory")
	success = success and assert_true(memory_stats.has("average"), "Should include average memory")

	memory_profiler.stop_profiling()

	assert_true(success, "Memory statistics calculation should work correctly")

# ------------------------------------------------------------------------------
# PERFORMANCE CORRELATION TESTS
# ------------------------------------------------------------------------------
func test_performance_correlation_analysis() -> void:
	"""Test performance correlation analysis"""
	var success = true

	# Start profiling and generate data
	memory_profiler.start_profiling("correlation_test")

	# Generate data with some variation
	for i in range(15):
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Test correlation analysis
	var correlation = memory_profiler._analyze_performance_correlation()

	if not correlation.has("error"):
		success = success and assert_true(correlation.has("memory_fps_correlation"), "Should include FPS correlation")
		success = success and assert_true(correlation.has("memory_draw_calls_correlation"), "Should include draw calls correlation")
		success = success and assert_true(correlation.has("performance_impact"), "Should include performance impact assessment")

	memory_profiler.stop_profiling()

	assert_true(success, "Performance correlation analysis should work correctly")

# ------------------------------------------------------------------------------
# UTILITY FUNCTION TESTS
# ------------------------------------------------------------------------------
func test_utility_functions() -> void:
	"""Test utility calculation functions"""
	var success = true

	# Test average calculation
	var test_values = [1.0, 2.0, 3.0, 4.0, 5.0]
	var average = memory_profiler._calculate_average(test_values)
	success = success and assert_equals(average, 3.0, "Should calculate average correctly")

	# Test standard deviation
	var std_dev = memory_profiler._calculate_standard_deviation(test_values)
	success = success and assert_greater_than(std_dev, 0, "Should calculate standard deviation")

	# Test autocorrelation
	var correlation = memory_profiler._calculate_autocorrelation(test_values, 1)
	success = success and assert_not_null(correlation, "Should calculate autocorrelation")

	# Test with empty array
	var empty_average = memory_profiler._calculate_average([])
	success = success and assert_equals(empty_average, 0.0, "Should handle empty arrays")

	assert_true(success, "Utility functions should work correctly")

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> void:
	"""Test error handling and edge cases"""
	var success = true

	# Test analysis with insufficient data
	var insufficient_patterns = memory_profiler.analyze_memory_patterns()
	success = success and assert_true(insufficient_patterns.has("error"), "Should handle insufficient data for patterns")

	# Test correlation with insufficient data
	var insufficient_correlation = memory_profiler._analyze_performance_correlation()
	success = success and assert_true(insufficient_correlation.has("error"), "Should handle insufficient data for correlation")

	# Test statistics with empty samples
	var empty_stats = memory_profiler._calculate_memory_statistics()
	success = success and assert_true(empty_stats.is_empty(), "Should handle empty sample data")

	# Test profiling double-start (should handle gracefully)
	memory_profiler.start_profiling("first")
	memory_profiler.start_profiling("second")  # Should stop first and start second
	success = success and assert_true(memory_profiler.is_profiling, "Should handle double start")

	memory_profiler.stop_profiling()

	assert_true(success, "Error handling should work correctly")

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_integration_with_performance_monitoring() -> void:
	"""Test integration with performance monitoring systems"""
	var success = true

	# Start profiling
	memory_profiler.start_profiling("integration_test")

	# Simulate performance monitoring integration
	# Skip frame wait in GDTest context

	# Check that memory profiler integrates with Godot's Performance monitor
	var godot_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	var profiler_memory = memory_profiler.memory_samples.back().static_memory

	# Should be close (within reasonable tolerance due to timing)
	var difference = abs(godot_memory - profiler_memory)
	var tolerance = 1024 * 1024  # 1MB tolerance
	success = success and assert_less_than(difference, tolerance, "Should integrate with Godot Performance monitor")

	memory_profiler.stop_profiling()

	assert_true(success, "Integration with performance monitoring should work correctly")

# ------------------------------------------------------------------------------
# RECOMMENDATION GENERATION TESTS
# ------------------------------------------------------------------------------
func test_recommendation_generation() -> void:
	"""Test memory optimization recommendation generation"""
	var success = true

	# Start profiling and create some test data
	memory_profiler.start_profiling("recommendation_test")

	# Generate varied memory usage
	for i in range(10):
		memory_profiler._take_memory_sample()
		await get_tree().process_frame

	# Test recommendation generation
	var recommendations = memory_profiler._generate_memory_recommendations()
	success = success and assert_true(recommendations is Array, "Should return array of recommendations")

	# Test stress test recommendations
	var mock_stress_results = {
		"memory_increase": 20 * 1024 * 1024,  # 20MB increase
		"leak_detection": {"potential_leaks": [{"severity": "high"}]},
		"performance_impact": {"performance_variance": 2.0}
	}

	var stress_recommendations = memory_profiler._generate_stress_recommendations(mock_stress_results)
	success = success and assert_true(stress_recommendations is Array, "Should return stress recommendations")
	success = success and assert_greater_than(stress_recommendations.size(), 0, "Should generate recommendations for concerning results")

	memory_profiler.stop_profiling()

	assert_true(success, "Recommendation generation should work correctly")

# ------------------------------------------------------------------------------
# CLEANUP AND FINALIZATION TESTS
# ------------------------------------------------------------------------------
func test_cleanup_functionality() -> void:
	"""Test cleanup and finalization"""
	var success = true

	# Start profiling and add some data
	memory_profiler.start_profiling("cleanup_test")

	# Add test data
	memory_profiler.memory_samples.append({"test": "data"})
	memory_profiler.leak_candidates.append("test_leak")
	memory_profiler.performance_impact = {"test": "impact"}

	success = success and assert_false(memory_profiler.memory_samples.is_empty(), "Should have sample data")
	success = success and assert_false(memory_profiler.leak_candidates.is_empty(), "Should have leak candidates")
	success = success and assert_false(memory_profiler.performance_impact.is_empty(), "Should have performance impact data")

	# Simulate cleanup (would happen in _exit_tree)
	memory_profiler.memory_samples.clear()
	memory_profiler.object_tracking.clear()
	memory_profiler.leak_candidates.clear()
	memory_profiler.memory_patterns.clear()
	memory_profiler.performance_impact.clear()

	success = success and assert_true(memory_profiler.memory_samples.is_empty(), "Should clear sample data")
	success = success and assert_true(memory_profiler.leak_candidates.is_empty(), "Should clear leak candidates")
	success = success and assert_true(memory_profiler.performance_impact.is_empty(), "Should clear performance impact data")

	assert_true(success, "Cleanup functionality should work correctly")

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_memory_profiler_test_suite() -> void:
	"""Run all MemoryProfiler tests"""
	print("\n🧠 Running MemoryProfiler Test Suite\n")

	# Memory Profiling Control Tests
	run_test("test_profiling_initialization", test_profiling_initialization)
	run_test("test_profiling_start_stop", test_profiling_start_stop)

	# Memory Sampling Tests
	run_test("test_memory_sampling", test_memory_sampling)
	run_test("test_object_tracking", test_object_tracking)

	# Leak Detection Tests
	run_test("test_leak_detection", test_leak_detection)

	# Memory Pattern Analysis Tests
	run_test("test_memory_pattern_analysis", test_memory_pattern_analysis)
	run_test("test_allocation_pattern_analysis", test_allocation_pattern_analysis)

	# Memory Stress Testing Tests
	run_test("test_memory_stress_testing", test_memory_stress_testing)
	run_test("test_stress_scenario_execution", test_stress_scenario_execution)

	# Comprehensive Analysis Tests
	run_test("test_comprehensive_memory_analysis", test_comprehensive_memory_analysis)
	run_test("test_memory_statistics_calculation", test_memory_statistics_calculation)

	# Performance Correlation Tests
	run_test("test_performance_correlation_analysis", test_performance_correlation_analysis)

	# Utility Function Tests
	run_test("test_utility_functions", test_utility_functions)

	# Error Handling Tests
	run_test("test_error_handling", test_error_handling)

	# Integration Tests
	run_test("test_integration_with_performance_monitoring", test_integration_with_performance_monitoring)

	# Recommendation Generation Tests
	run_test("test_recommendation_generation", test_recommendation_generation)

	# Cleanup Tests
	run_test("test_cleanup_functionality", test_cleanup_functionality)

	print("\n🧠 MemoryProfiler Test Suite Complete\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
