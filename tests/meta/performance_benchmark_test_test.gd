# GDSentry - Performance Benchmark Test Suite
# Comprehensive testing of the advanced PerformanceBenchmarkTest framework
#
# This test validates all aspects of the performance benchmark system including:
# - Statistical analysis with confidence intervals and outlier detection
# - Regression detection algorithms with configurable thresholds
# - Baseline management with historical data and retention
# - CI/CD gate checking with performance thresholds
# - Trend analysis with forecasting and insights
# - Benchmark suite execution and management
# - Advanced performance profiling and bottleneck identification
# - Comprehensive reporting and recommendations
#
# Author: GDSentry Framework
# Version: 2.0.0

extends SceneTreeTest

class_name PerformanceBenchmarkTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Advanced PerformanceBenchmarkTest framework validation"
	test_tags = ["meta", "performance", "benchmark", "statistics", "regression"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var performance_benchmark

func setup() -> void:
	"""Setup test environment"""
	performance_benchmark = load("res://test_types/performance_benchmark_test.gd").new()

func teardown() -> void:
	"""Cleanup test environment"""
	if performance_benchmark:
		performance_benchmark.queue_free()

# ------------------------------------------------------------------------------
# STATISTICAL ANALYSIS TESTS
# ------------------------------------------------------------------------------
func test_statistical_analysis_basic() -> bool:
	"""Test basic statistical analysis functionality"""
	var success = true

	# Test data
	var test_data = [1.0, 2.0, 3.0, 4.0, 5.0]
	var stats = performance_benchmark.statistical_analyzer.calculate_basic_statistics(test_data)

	success = success and assert_not_null(stats, "Should return statistics")
	success = success and assert_equals(stats.count, 5, "Should count data points correctly")
	success = success and assert_equals(stats.mean, 3.0, "Should calculate mean correctly")
	success = success and assert_equals(stats.min, 1.0, "Should find minimum correctly")
	success = success and assert_equals(stats.max, 5.0, "Should find maximum correctly")
	success = success and assert_greater_than(stats.std_dev, 0, "Should calculate standard deviation")

	return success

func test_statistical_analysis_percentiles() -> bool:
	"""Test percentile calculations"""
	var success = true

	var test_data = []
	for i in range(1, 101):  # 1 to 100
		test_data.append(float(i))

	var stats = performance_benchmark.statistical_analyzer.calculate_basic_statistics(test_data)

	success = success and assert_equals(stats.p50, 50.0, "Should calculate median (p50) correctly")
	success = success and assert_equals(stats.p95, 95.0, "Should calculate p95 correctly")
	success = success and assert_equals(stats.p99, 99.0, "Should calculate p99 correctly")

	return success  #  "Percentile calculations should work correctly")

func test_outlier_detection() -> bool:
	"""Test statistical outlier detection"""
	var success = true

	# Normal data with outliers
	var test_data = [1.0, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0, 10.0, 15.0]  # 10.0 and 15.0 are outliers
	var outlier_result = performance_benchmark.statistical_analyzer.detect_outliers(test_data)

	success = success and assert_not_null(outlier_result, "Should return outlier analysis")
	success = success and assert_greater_than(outlier_result.outlier_count, 0, "Should detect outliers")
	success = success and assert_true(outlier_result.outliers.has(10.0), "Should identify 10.0 as outlier")
	success = success and assert_true(outlier_result.outliers.has(15.0), "Should identify 15.0 as outlier")

	return success  #  "Outlier detection should work correctly")

# ------------------------------------------------------------------------------
# REGRESSION DETECTOR TESTS
# ------------------------------------------------------------------------------
func test_regression_detection() -> bool:
	"""Test performance regression detection"""
	var success = true

	# Test case: significant performance regression
	var current_stats = {
		"mean": 10.0,
		"std_dev": 1.0,
		"count": 100
	}

	var baseline_stats = {
		"mean": 5.0,
		"std_dev": 0.5,
		"count": 100
	}

	var regression_result = performance_benchmark.regression_detector.detect_performance_regression(
		current_stats, baseline_stats
	)

	success = success and assert_not_null(regression_result, "Should return regression analysis")
	success = success and assert_true(regression_result.regression_detected, "Should detect performance regression")
	success = success and assert_equals(regression_result.regression_type, "mean", "Should identify mean regression")
	success = success and assert_greater_than(regression_result.severity, 0, "Should calculate severity")

	return success  #  "Regression detection should work correctly")

func test_no_regression_detection() -> bool:
	"""Test case with no performance regression"""
	var success = true

	# Test case: performance within acceptable range
	var current_stats = {
		"mean": 5.2,
		"std_dev": 0.5,
		"count": 100
	}

	var baseline_stats = {
		"mean": 5.0,
		"std_dev": 0.5,
		"count": 100
	}

	var regression_result = performance_benchmark.regression_detector.detect_performance_regression(
		current_stats, baseline_stats
	)

	success = success and assert_not_null(regression_result, "Should return regression analysis")
	success = success and assert_false(regression_result.regression_detected, "Should not detect regression")
	success = success and assert_equals(regression_result.regression_type, "none", "Should identify no regression")

	return success  #  "No regression detection should work correctly")

func test_trend_regression_analysis() -> bool:
	"""Test trend-based regression analysis"""
	var success = true

	# Create degrading trend data
	var trend_data = [1.0, 1.2, 1.5, 2.0, 2.8, 4.0, 6.5]  # Exponential growth
	var trend_result = performance_benchmark.regression_detector.detect_trend_regression(trend_data)

	success = success and assert_not_null(trend_result, "Should return trend analysis")
	success = success and assert_true(trend_result.trend_regression, "Should detect degrading trend")
	success = success and assert_equals(trend_result.trend_direction, "degrading", "Should identify trend direction")

	return success  #  "Trend regression analysis should work correctly")

# ------------------------------------------------------------------------------
# BASELINE MANAGER TESTS
# ------------------------------------------------------------------------------
func test_baseline_storage_and_retrieval() -> bool:
	"""Test baseline data storage and retrieval"""
	var success = true

	# Test data
	var baseline_name = "test_baseline"
	var baseline_data = {
		"mean": 5.0,
		"std_dev": 0.5,
		"p95": 6.0,
		"timestamp": Time.get_unix_time_from_system()
	}

	# Store baseline
	var store_result = performance_benchmark.baseline_manager.store_baseline(baseline_name, baseline_data)
	success = success and assert_true(store_result, "Should store baseline successfully")

	# Retrieve baseline
	var retrieved_data = performance_benchmark.baseline_manager.retrieve_baseline(baseline_name)
	success = success and assert_not_null(retrieved_data, "Should retrieve baseline data")
	success = success and assert_equals(retrieved_data.data.mean, 5.0, "Should preserve data correctly")

	return success  #  "Baseline storage and retrieval should work correctly")

func test_baseline_comparison() -> bool:
	"""Test baseline comparison functionality"""
	var success = true

	# Setup baseline data
	var baseline_data = {
		"timestamp": Time.get_unix_time_from_system() - 86400,  # 1 day ago
		"data": {
			"mean": 5.0,
			"std_dev": 0.5
		}
	}
	performance_benchmark.baseline_manager.baseline_storage["comparison_test"] = baseline_data

	# Current data for comparison
	var current_data = {
		"mean": 6.0,  # 20% increase
		"std_dev": 0.6
	}

	var comparison = performance_benchmark.baseline_manager.compare_with_baseline("comparison_test", current_data)

	success = success and assert_not_null(comparison, "Should return comparison result")
	success = success and assert_true(comparison.has("metrics_comparison"), "Should include metrics comparison")
	success = success and assert_greater_than(comparison.age_days, 0, "Should calculate age correctly")

	var mean_comparison = comparison.metrics_comparison.mean
	success = success and assert_equals(mean_comparison.baseline, 5.0, "Should have baseline value")
	success = success and assert_equals(mean_comparison.current, 6.0, "Should have current value")
	success = success and assert_equals(mean_comparison.change, 1.0, "Should calculate change correctly")
	success = success and assert_equals(mean_comparison.percent_change, 20.0, "Should calculate percent change correctly")

	return success  #  "Baseline comparison should work correctly")

# ------------------------------------------------------------------------------
# CI/CD GATE CHECKER TESTS
# ------------------------------------------------------------------------------
func test_ci_gate_checking() -> bool:
	"""Test CI/CD gate checking functionality"""
	var success = true

	# Mock benchmark results with performance regression
	var benchmark_results = {
		"memory_usage": 150.0,  # Above 100MB threshold
		"average_fps": 50.0     # Below expected 60 FPS
	}

	var baseline_comparison = {
		"metrics_comparison": {
			"average_time": {
				"current": 12.0,
				"baseline": 10.0,
				"percent_change": 20.0  # Above 5% regression threshold
			}
		}
	}

	var gate_result = performance_benchmark.ci_gate_checker.check_performance_gate(
		benchmark_results, baseline_comparison
	)

	success = success and assert_not_null(gate_result, "Should return gate check result")
	success = success and assert_false(gate_result.gate_passed, "Should fail gate due to regressions")
	success = success and assert_greater_than(gate_result.failures.size(), 0, "Should identify failures")

	# Check for specific failures
	var failure_types = gate_result.failures.map(func(f): return f.type)
	success = success and assert_true(failure_types.has("performance_regression"), "Should detect performance regression")

	return success  #  "CI gate checking should work correctly")

func test_ci_gate_success() -> bool:
	"""Test CI/CD gate passing scenario"""
	var success = true

	# Mock benchmark results within acceptable limits
	var benchmark_results = {
		"memory_usage": 80.0,   # Below 100MB threshold
		"average_fps": 58.0     # Close to 60 FPS target
	}

	var baseline_comparison = {
		"metrics_comparison": {
			"average_time": {
				"current": 10.2,
				"baseline": 10.0,
				"percent_change": 2.0  # Below 5% regression threshold
			}
		}
	}

	var gate_result = performance_benchmark.ci_gate_checker.check_performance_gate(
		benchmark_results, baseline_comparison
	)

	success = success and assert_not_null(gate_result, "Should return gate check result")
	success = success and assert_true(gate_result.gate_passed, "Should pass gate with acceptable performance")

	return success  #  "CI gate success should work correctly")

# ------------------------------------------------------------------------------
# TREND ANALYZER TESTS
# ------------------------------------------------------------------------------
func test_trend_analysis() -> bool:
	"""Test performance trend analysis"""
	var success = true

	# Create improving trend data
	var trend_data = [10.0, 9.5, 9.0, 8.5, 8.0, 7.5]  # Improving performance
	var trend_result = performance_benchmark.trend_analyzer.analyze_performance_trend(trend_data)

	success = success and assert_not_null(trend_result, "Should return trend analysis")
	success = success and assert_equals(trend_result.trend, "improving", "Should detect improving trend")
	success = success and assert_equals(trend_result.direction, 1.0, "Should identify positive direction")
	success = success and assert_greater_than(trend_result.confidence, 0, "Should calculate confidence")
	success = success and assert_true(trend_result.insights.size() > 0, "Should generate insights")

	return success  #  "Trend analysis should work correctly")

func test_trend_forecasting() -> bool:
	"""Test trend forecasting capabilities"""
	var success = true

	var trend_data = [10.0, 9.0, 8.0, 7.0, 6.0]  # Linear improvement
	var trend_result = performance_benchmark.trend_analyzer.analyze_performance_trend(trend_data)

	success = success and assert_not_null(trend_result, "Should return trend analysis")
	success = success and assert_true(trend_result.forecast.has("period_1"), "Should include forecast data")
	success = success and assert_true(trend_result.forecast.has("period_5"), "Should include longer-term forecast")

	# Check that forecast values are reasonable (decreasing for improving performance)
	var period1_value = trend_result.forecast.period_1
	var period5_value = trend_result.forecast.period_5
	success = success and assert_less_than(period5_value, period1_value, "Should forecast continued improvement")

	return success  #  "Trend forecasting should work correctly")

# ------------------------------------------------------------------------------
# BENCHMARK SUITE TESTS
# ------------------------------------------------------------------------------
func test_benchmark_suite_setup() -> bool:
	"""Test benchmark suite setup and configuration"""
	var success = true

	# Check that default suites are created
	success = success and assert_true(performance_benchmark.benchmark_suites.has("cpu_performance"), "Should have CPU performance suite")
	success = success and assert_true(performance_benchmark.benchmark_suites.has("memory_performance"), "Should have memory performance suite")
	success = success and assert_true(performance_benchmark.benchmark_suites.has("rendering_performance"), "Should have rendering performance suite")

	# Check suite structure
	var cpu_suite = performance_benchmark.benchmark_suites.cpu_performance
	success = success and assert_true(cpu_suite.has("name"), "Should have suite name")
	success = success and assert_true(cpu_suite.has("description"), "Should have suite description")
	success = success and assert_true(cpu_suite.has("benchmarks"), "Should have benchmark definitions")
	success = success and assert_greater_than(cpu_suite.benchmarks.size(), 0, "Should have benchmarks defined")

	return success  #  "Benchmark suite setup should work correctly")

func test_benchmark_suite_execution() -> bool:
	"""Test benchmark suite execution"""
	var success = true

	# Run CPU performance suite
	var suite_result = await performance_benchmark.run_benchmark_suite("cpu_performance")

	success = success and assert_not_null(suite_result, "Should return suite execution result")
	success = success and assert_equals(suite_result.suite_name, "cpu_performance", "Should identify suite correctly")
	success = success and assert_true(suite_result.has("benchmarks"), "Should include benchmark results")
	success = success and assert_true(suite_result.has("summary"), "Should include suite summary")
	success = success and assert_true(suite_result.has("recommendations"), "Should include recommendations")

	# Check summary structure
	var summary = suite_result.summary
	success = success and assert_greater_than(summary.total_benchmarks, 0, "Should have executed benchmarks")
	success = success and assert_true(summary.average_performance >= 0, "Should calculate average performance")

	return success  #  "Benchmark suite execution should work correctly")

# ------------------------------------------------------------------------------
# PERFORMANCE PROFILING TESTS
# ------------------------------------------------------------------------------
func test_performance_profiling() -> bool:
	"""Test performance profiling functionality"""
	var success = true

	# Start profiling
	performance_benchmark.start_performance_profiling("test_profile")

	# Simulate some work and capture samples
	for i in range(5):
		await performance_benchmark.wait_for_next_frame()
		performance_benchmark.capture_performance_sample()

	# Stop profiling and get analysis
	var analysis = performance_benchmark.stop_performance_profiling()

	success = success and assert_not_null(analysis, "Should return profiling analysis")
	success = success and assert_equals(analysis.profile_name, "test_profile", "Should identify profile correctly")
	success = success and assert_greater_than(analysis.sample_count, 0, "Should have captured samples")
	success = success and assert_true(analysis.has("analysis"), "Should include detailed analysis")

	# Check analysis structure
	var detailed_analysis = analysis.analysis
	success = success and assert_true(detailed_analysis.has("cpu_analysis"), "Should include CPU analysis")
	success = success and assert_true(detailed_analysis.has("memory_analysis"), "Should include memory analysis")
	success = success and assert_true(detailed_analysis.has("rendering_analysis"), "Should include rendering analysis")

	return success  #  "Performance profiling should work correctly")

# ------------------------------------------------------------------------------
# COMPREHENSIVE BENCHMARK TESTS
# ------------------------------------------------------------------------------
func test_comprehensive_benchmark() -> bool:
	"""Test comprehensive benchmark execution"""
	var success = true

	# Run comprehensive benchmark
	var comprehensive_result = await performance_benchmark.run_comprehensive_benchmark()

	success = success and assert_not_null(comprehensive_result, "Should return comprehensive results")
	success = success and assert_true(comprehensive_result.has("suites"), "Should include suite results")
	success = success and assert_true(comprehensive_result.has("overall_summary"), "Should include overall summary")
	success = success and assert_true(comprehensive_result.has("recommendations"), "Should include recommendations")

	# Check overall summary
	var overall_summary = comprehensive_result.overall_summary
	success = success and assert_greater_than(overall_summary.total_suites, 0, "Should have executed suites")
	success = success and assert_greater_than(overall_summary.total_benchmarks, 0, "Should have executed benchmarks")

	return success  #  "Comprehensive benchmark should work correctly")

# ------------------------------------------------------------------------------
# REPORTING TESTS
# ------------------------------------------------------------------------------
func test_comprehensive_reporting() -> bool:
	"""Test comprehensive reporting functionality"""
	var success = true

	# First run some benchmarks to generate data
	await performance_benchmark.run_benchmark_suite("cpu_performance")

	# Generate comprehensive report
	var report = performance_benchmark.generate_comprehensive_report()

	success = success and assert_not_equals(report, "", "Should generate report content")
	success = success and assert_true(report.contains("Comprehensive Performance Benchmark Report"), "Should include report header")
	success = success and assert_true(report.contains("Key Insights"), "Should include key insights section")

	return success  #  "Comprehensive reporting should work correctly")

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_component_integration() -> bool:
	"""Test integration between all framework components"""
	var success = true

	# Test that all components are properly initialized
	success = success and assert_not_null(performance_benchmark.statistical_analyzer, "Should have statistical analyzer")
	success = success and assert_not_null(performance_benchmark.regression_detector, "Should have regression detector")
	success = success and assert_not_null(performance_benchmark.baseline_manager, "Should have baseline manager")
	success = success and assert_not_null(performance_benchmark.ci_gate_checker, "Should have CI gate checker")
	success = success and assert_not_null(performance_benchmark.trend_analyzer, "Should have trend analyzer")

	# Test component communication
	var test_data = [1.0, 2.0, 3.0, 4.0, 5.0]
	var stats = performance_benchmark.statistical_analyzer.calculate_basic_statistics(test_data)

	# Test that statistical results can be used by regression detector
	var mock_baseline_stats = {
		"mean": 3.5,
		"std_dev": 1.0,
		"count": 5
	}

	var regression_result = performance_benchmark.regression_detector.detect_performance_regression(
		stats, mock_baseline_stats
	)

	success = success and assert_not_null(regression_result, "Should integrate statistical and regression analysis")

	return success  #  "Component integration should work correctly")

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Test running non-existent benchmark suite
	var invalid_result = await performance_benchmark.run_benchmark_suite("non_existent_suite")
	success = success and assert_false(invalid_result.success, "Should handle invalid suite gracefully")

	# Test retrieving non-existent baseline
	var baseline_result = performance_benchmark.baseline_manager.retrieve_baseline("non_existent_baseline")
	success = success and assert_true(baseline_result.is_empty(), "Should handle missing baseline gracefully")

	# Test statistical analysis with empty data
	var empty_stats = performance_benchmark.statistical_analyzer.calculate_basic_statistics([])
	success = success and assert_true(empty_stats.is_empty(), "Should handle empty data gracefully")

	# Test trend analysis with insufficient data
	var short_trend = performance_benchmark.trend_analyzer.analyze_performance_trend([1.0, 2.0])
	success = success and assert_equals(short_trend.trend, "insufficient_data", "Should handle insufficient trend data")

	return success  #  "Error handling should work correctly")

# ------------------------------------------------------------------------------
# PERFORMANCE VALIDATION TESTS
# ------------------------------------------------------------------------------
func test_performance_assertions() -> bool:
	"""Test performance assertion methods"""
	var success = true

	# Test benchmark operation creation
	var benchmark_result = await performance_benchmark.benchmark_operation(
		"test_operation",
		func(): return performance_benchmark._math_operations(10),
		5,  # iterations
		1   # warmup
	)

	success = success and assert_not_null(benchmark_result, "Should create benchmark operation")
	success = success and assert_equals(benchmark_result.name, "test_operation", "Should identify operation correctly")
	success = success and assert_equals(benchmark_result.iterations, 5, "Should execute correct number of iterations")
	success = success and assert_greater_than(benchmark_result.average_time, 0, "Should measure execution time")

	# Test performance assertion (this should pass with the simple operation)
	var assertion_result = await performance_benchmark.assert_benchmark_performance(
		"simple_assertion_test",
		func(): return performance_benchmark._math_operations(5),
		100.0  # Very generous time limit
	)

	success = success and assert_true(assertion_result, "Should pass performance assertion")

	return success  #  "Performance assertions should work correctly")

# ------------------------------------------------------------------------------
# CLEANUP AND FINALIZATION TESTS
# ------------------------------------------------------------------------------
func test_cleanup_functionality() -> bool:
	"""Test cleanup and finalization"""
	var success = true

	# Add some test data to verify cleanup
	performance_benchmark.benchmark_history.append({
		"suite_name": "cleanup_test_suite",
		"summary": {"total_benchmarks": 1}
	})

	success = success and assert_false(performance_benchmark.benchmark_history.is_empty(), "Should have benchmark history before cleanup")

	# Simulate cleanup (would happen in _exit_tree in real scenario)
	performance_benchmark.benchmark_history.clear()

	success = success and assert_true(performance_benchmark.benchmark_history.is_empty(), "Should clear benchmark history")

	return success  #  "Cleanup functionality should work correctly")

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_performance_benchmark_test_suite() -> void:
	"""Run all PerformanceBenchmarkTest tests"""
	print("\n🏃 Running PerformanceBenchmarkTest Suite\n")

	# Statistical Analysis Tests
	run_test("test_statistical_analysis_basic", func(): return test_statistical_analysis_basic())
	run_test("test_statistical_analysis_percentiles", func(): return test_statistical_analysis_percentiles())
	run_test("test_outlier_detection", func(): return test_outlier_detection())

	# Regression Detector Tests
	run_test("test_regression_detection", func(): return test_regression_detection())
	run_test("test_no_regression_detection", func(): return test_no_regression_detection())
	run_test("test_trend_regression_analysis", func(): return test_trend_regression_analysis())

	# Baseline Manager Tests
	run_test("test_baseline_storage_and_retrieval", func(): return test_baseline_storage_and_retrieval())
	run_test("test_baseline_comparison", func(): return test_baseline_comparison())

	# CI/CD Gate Checker Tests
	run_test("test_ci_gate_checking", func(): return test_ci_gate_checking())
	run_test("test_ci_gate_success", func(): return test_ci_gate_success())

	# Trend Analyzer Tests
	run_test("test_trend_analysis", func(): return test_trend_analysis())
	run_test("test_trend_forecasting", func(): return test_trend_forecasting())

	# Benchmark Suite Tests
	run_test("test_benchmark_suite_setup", func(): return test_benchmark_suite_setup())
	run_test("test_benchmark_suite_execution", func(): return await test_benchmark_suite_execution())

	# Performance Profiling Tests
	run_test("test_performance_profiling", func(): return await test_performance_profiling())

	# Comprehensive Benchmark Tests
	run_test("test_comprehensive_benchmark", func(): return await test_comprehensive_benchmark())

	# Reporting Tests
	run_test("test_comprehensive_reporting", func(): return await test_comprehensive_reporting())

	# Integration Tests
	run_test("test_component_integration", func(): return test_component_integration())

	# Error Handling Tests
	run_test("test_error_handling", func(): return await test_error_handling())

	# Performance Validation Tests
	run_test("test_performance_assertions", func(): return await test_performance_assertions())

	# Cleanup Tests
	run_test("test_cleanup_functionality", func(): return test_cleanup_functionality())

	print("\n🏆 PerformanceBenchmarkTest Suite Complete\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
