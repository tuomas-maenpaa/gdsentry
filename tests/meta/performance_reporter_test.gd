# GDSentry - Performance Reporter Test Suite
# Comprehensive testing of the PerformanceReporter system
#
# This test validates all aspects of the performance reporting system including:
# - Comprehensive performance report generation
# - Chart visualization creation and rendering
# - Benchmark comparison report functionality
# - CI/CD integration hooks and status reporting
# - Historical data management and trend analysis
# - Multiple output format support (JSON, text)
# - Performance metric calculations and scoring
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name PerformanceReporterTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "PerformanceReporter comprehensive validation"
	test_tags = ["meta", "performance", "reporting", "visualization", "ci_cd"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var performance_reporter

func setup() -> void:
	"""Setup test environment"""
	performance_reporter = load("res://reporters/performance_reporter.gd").new()
	# SceneTreeTest doesn't have add_child, so we'll manage the instance directly

func teardown() -> void:
	"""Cleanup test environment"""
	if performance_reporter:
		performance_reporter.queue_free()

# ------------------------------------------------------------------------------
# REPORT GENERATION TESTS
# ------------------------------------------------------------------------------
func test_report_generation() -> bool:
	"""Test basic performance report generation"""
	var success = true

	# Create mock benchmark results
	var benchmark_results = {
		"benchmark_results": {
			"test_operation_1": {"average_time": 10.5, "min_time": 8.0, "max_time": 15.0},
			"test_operation_2": {"average_time": 25.2, "min_time": 20.0, "max_time": 35.0}
		},
		"memory_usage": 50 * 1024 * 1024,  # 50MB
		"fps_average": 58.5,
		"memory_samples": [45.0, 48.0, 52.0, 47.0, 51.0],
		"fps_samples": [55, 58, 60, 57, 59]
	}

	# Generate report
	var report = performance_reporter.generate_performance_report(benchmark_results, {"format": "json"})

	success = success and assert_not_null(report, "Should return generated report")
	success = success and assert_true(report.has("summary"), "Should include summary section")
	success = success and assert_true(report.has("charts"), "Should include charts section")
	success = success and assert_true(report.has("recommendations"), "Should include recommendations")
	success = success and assert_true(report.has("alerts"), "Should include alerts")
	success = success and assert_true(report.has("report_path"), "Should include report path")

	# Check summary structure
	var summary = report.summary
	success = success and assert_equals(summary.total_benchmarks, 2, "Should count benchmarks correctly")
	success = success and assert_greater_than(summary.average_performance, 0, "Should calculate average performance")

	return success  #  "Performance report generation should work correctly")

func test_comparison_report_generation() -> bool:
	"""Test benchmark comparison report generation"""
	var success = true

	# Create mock baseline and current results
	var baseline_results = {
		"benchmark_results": {
			"test_operation_1": {"average_time": 10.0},
			"test_operation_2": {"average_time": 20.0}
		}
	}

	var current_results = {
		"benchmark_results": {
			"test_operation_1": {"average_time": 12.0},  # 20% regression
			"test_operation_2": {"average_time": 18.0}   # 10% improvement
		}
	}

	# Generate comparison report
	var comparison_report = performance_reporter.generate_comparison_report(baseline_results, current_results)

	success = success and assert_not_null(comparison_report, "Should return comparison report")
	success = success and assert_true(comparison_report.has("comparison"), "Should include comparison data")
	success = success and assert_true(comparison_report.has("summary"), "Should include comparison summary")
	success = success and assert_true(comparison_report.has("regressions"), "Should include regressions")
	success = success and assert_true(comparison_report.has("improvements"), "Should include improvements")

	# Check comparison structure
	var comparison = comparison_report.comparison
	success = success and assert_true(comparison.has("benchmarks"), "Should include benchmark comparisons")
	success = success and assert_equals(comparison.regression_count, 1, "Should detect one regression")
	success = success and assert_equals(comparison.improvement_count, 1, "Should detect one improvement")

	return success  #  "Comparison report generation should work correctly")

# ------------------------------------------------------------------------------
# CHART GENERATION TESTS
# ------------------------------------------------------------------------------
func test_chart_generation() -> bool:
	"""Test performance chart generation"""
	var success = true

	# Create mock benchmark results with chart data
	var benchmark_results = {
		"memory_samples": [40.0, 45.0, 50.0, 48.0, 52.0],
		"fps_samples": [55, 58, 60, 57, 59],
		"benchmark_results": {
			"operation_1": {"average_time": 10.0},
			"operation_2": {"average_time": 15.0},
			"operation_3": {"average_time": 8.0}
		}
	}

	# Generate charts
	var charts = performance_reporter._generate_performance_charts(benchmark_results)

	success = success and assert_not_null(charts, "Should return charts dictionary")
	success = success and assert_true(charts.has("memory_usage"), "Should include memory chart")
	success = success and assert_true(charts.has("fps_performance"), "Should include FPS chart")
	success = success and assert_true(charts.has("benchmark_timings"), "Should include benchmark chart")

	# Verify chart image properties
	var memory_chart = charts.memory_usage
	success = success and assert_not_null(memory_chart, "Memory chart should be generated")
	if memory_chart:
		success = success and assert_equals(memory_chart.get_width(), 800, "Chart should have correct width")
		success = success and assert_equals(memory_chart.get_height(), 600, "Chart should have correct height")

	return success  #  "Chart generation should work correctly")

func test_comparison_chart_generation() -> bool:
	"""Test comparison chart generation"""
	var success = true

	# Create mock data for comparison
	var baseline_results = {
		"benchmark_results": {
			"operation_1": {"average_time": 10.0},
			"operation_2": {"average_time": 15.0}
		}
	}

	var current_results = {
		"benchmark_results": {
			"operation_1": {"average_time": 12.0},
			"operation_2": {"average_time": 13.0}
		}
	}

	# Generate comparison charts
	var charts = performance_reporter._generate_comparison_charts(baseline_results, current_results)

	success = success and assert_not_null(charts, "Should return comparison charts")
	success = success and assert_true(charts.has("side_by_side"), "Should include side-by-side chart")
	success = success and assert_true(charts.has("differences"), "Should include difference chart")
	success = success and assert_true(charts.has("regressions"), "Should include regression chart")

	return success  #  "Comparison chart generation should work correctly")

# ------------------------------------------------------------------------------
# ANALYSIS AND CALCULATION TESTS
# ------------------------------------------------------------------------------
func test_report_summary_generation() -> bool:
	"""Test report summary generation"""
	var success = true

	var benchmark_results = {
		"benchmark_results": {
			"fast_op": {"average_time": 5.0},
			"slow_op": {"average_time": 25.0},
			"medium_op": {"average_time": 15.0}
		},
		"memory_usage": 100 * 1024 * 1024,  # 100MB
		"fps_average": 45.0
	}

	var summary = performance_reporter._generate_report_summary(benchmark_results)

	success = success and assert_not_null(summary, "Should return summary")
	success = success and assert_equals(summary.total_benchmarks, 3, "Should count benchmarks correctly")
	success = success and assert_equals(summary.best_performance, "fast_op", "Should identify best performance")
	success = success and assert_equals(summary.worst_performance, "slow_op", "Should identify worst performance")
	success = success and assert_greater_than(summary.average_performance, 0, "Should calculate average")

	return success  #  "Report summary generation should work correctly")

func test_performance_recommendations() -> bool:
	"""Test performance recommendation generation"""
	var success = true

	# Create results that should trigger recommendations
	var benchmark_results = {
		"benchmark_results": {
			"slow_operation": {"average_time": 150.0}  # Very slow
		},
		"memory_usage": 300 * 1024 * 1024,  # High memory usage
		"fps_average": 25.0  # Low FPS
	}

	var recommendations = performance_reporter._generate_performance_recommendations(benchmark_results)

	success = success and assert_true(recommendations is Array, "Should return recommendations array")
	success = success and assert_greater_than(recommendations.size(), 0, "Should generate recommendations for poor performance")

	# Check for specific recommendations
	var recommendation_text = recommendations.reduce(func(acc, rec): return acc + rec, "")
	success = success and assert_true(recommendation_text.contains("memory") or recommendation_text.contains("FPS") or recommendation_text.contains("slow"), "Should include relevant recommendations")

	return success  #  "Performance recommendations should work correctly")

func test_performance_alerts() -> bool:
	"""Test performance alert generation"""
	var success = true

	# Create results that should trigger alerts
	var benchmark_results = {
		"fps_average": 15.0,  # Critically low FPS
		"memory_usage": 600 * 1024 * 1024  # Excessive memory
	}

	var alerts = performance_reporter._check_performance_alerts(benchmark_results)

	success = success and assert_true(alerts is Array, "Should return alerts array")
	success = success and assert_greater_than(alerts.size(), 0, "Should generate alerts for critical issues")

	# Check for critical alerts
	var critical_alerts = alerts.filter(func(alert): return alert.level == "critical")
	success = success and assert_greater_than(critical_alerts.size(), 0, "Should include critical alerts")

	return success  #  "Performance alerts should work correctly")

# ------------------------------------------------------------------------------
# COMPARISON ANALYSIS TESTS
# ------------------------------------------------------------------------------
func test_benchmark_comparison() -> bool:
	"""Test benchmark result comparison"""
	var success = true

	var baseline_results = {
		"benchmark_results": {
			"operation_1": {"average_time": 10.0},
			"operation_2": {"average_time": 20.0}
		}
	}

	var current_results = {
		"benchmark_results": {
			"operation_1": {"average_time": 15.0},  # 50% regression
			"operation_2": {"average_time": 18.0}   # 10% improvement
		}
	}

	var comparison = performance_reporter._compare_benchmark_results(baseline_results, current_results)

	success = success and assert_not_null(comparison, "Should return comparison")
	success = success and assert_true(comparison.has("benchmarks"), "Should include benchmark comparisons")
	success = success and assert_equals(comparison.regression_count, 1, "Should detect regression")
	success = success and assert_equals(comparison.improvement_count, 1, "Should detect improvement")

	# Check specific benchmark comparison
	var op1_comparison = comparison.benchmarks.operation_1
	success = success and assert_equals(op1_comparison.baseline_time, 10.0, "Should have baseline time")
	success = success and assert_equals(op1_comparison.current_time, 15.0, "Should have current time")
	success = success and assert_equals(op1_comparison.percent_change, 50.0, "Should calculate percent change")
	success = success and assert_equals(op1_comparison.status, "regression", "Should identify as regression")

	return success  #  "Benchmark comparison should work correctly")

func test_comparison_summary() -> bool:
	"""Test comparison summary generation"""
	var success = true

	var comparison = {
		"benchmarks": {
			"op1": {"status": "regression"},
			"op2": {"status": "improvement"},
			"op3": {"status": "stable"}
		},
		"regression_count": 1,
		"improvement_count": 1,
		"overall_change": 5.0
	}

	var summary = performance_reporter._generate_comparison_summary(comparison)

	success = success and assert_not_null(summary, "Should return comparison summary")
	success = success and assert_equals(summary.benchmarks_compared, 3, "Should count benchmarks")
	success = success and assert_equals(summary.regressions, 1, "Should count regressions")
	success = success and assert_equals(summary.improvements, 1, "Should count improvements")
	success = success and assert_equals(summary.stable, 1, "Should count stable benchmarks")

	return success  #  "Comparison summary should work correctly")

# ------------------------------------------------------------------------------
# CI/CD INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_ci_report_generation() -> bool:
	"""Test CI/CD report generation"""
	var success = true

	var benchmark_results = {
		"benchmark_results": {
			"fast_operation": {"average_time": 5.0},
			"slow_operation": {"average_time": 25.0}
		},
		"memory_usage": 80 * 1024 * 1024,  # 80MB
		"fps_average": 55.0
	}

	var baseline_comparison = {
		"metrics_comparison": {
			"average_performance": {
				"percent_change": -10.0  # 10% improvement
			}
		}
	}

	var ci_report = performance_reporter.generate_ci_report(benchmark_results, baseline_comparison)

	success = success and assert_not_null(ci_report, "Should return CI report")
	success = success and assert_true(ci_report.has("ci_status"), "Should include CI status")
	success = success and assert_true(ci_report.has("performance_score"), "Should include performance score")
	success = success and assert_true(ci_report.has("metrics"), "Should include metrics")

	# Check performance score range
	var score = ci_report.performance_score
	success = success and assert_true(score >= 0.0, "Score should be non-negative")
	success = success and assert_true(score <= 100.0, "Score should not exceed 100")

	return success  #  "CI report generation should work correctly")

func test_performance_score_calculation() -> bool:
	"""Test performance score calculation"""
	var success = true

	# Test good performance (should get high score)
	var good_summary = {
		"average_performance": 10.0,
		"memory_usage": 50 * 1024 * 1024,
		"fps_average": 55.0,
		"performance_variance": 0.5
	}

	var good_score = performance_reporter._calculate_performance_score(good_summary)
	success = success and assert_greater_than(good_score, 80.0, "Good performance should get high score")

	# Test poor performance (should get low score)
	var poor_summary = {
		"average_performance": 100.0,
		"memory_usage": 400 * 1024 * 1024,
		"fps_average": 15.0,
		"performance_variance": 5.0
	}

	var poor_score = performance_reporter._calculate_performance_score(poor_summary)
	success = success and assert_less_than(poor_score, 50.0, "Poor performance should get low score")

	success = success and assert_greater_than(good_score, poor_score, "Good performance should score higher than poor")

	return success  #  "Performance score calculation should work correctly")

# ------------------------------------------------------------------------------
# FILE MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_file_operations() -> bool:
	"""Test report file operations"""
	var success = true

	var test_report = {
		"timestamp": Time.get_unix_time_from_system(),
		"test_data": "sample_report",
		"summary": {"total": 5}
	}

	# Test JSON report saving
	var json_path = performance_reporter._save_report(test_report, "json")
	success = success and assert_not_equals(json_path, "", "Should return JSON report path")

	# Test text report saving
	var text_path = performance_reporter._save_report(test_report, "txt")
	success = success and assert_not_equals(text_path, "", "Should return text report path")

	# Test comparison report saving
	var comparison_report = {
		"comparison": {"test": "data"},
		"summary": {"compared": 2}
	}

	var comparison_path = performance_reporter._save_comparison_report(comparison_report, "json")
	success = success and assert_not_equals(comparison_path, "", "Should return comparison report path")

	return success  #  "File operations should work correctly")

# ------------------------------------------------------------------------------
# HISTORICAL DATA TESTS
# ------------------------------------------------------------------------------
func test_historical_data_management() -> bool:
	"""Test historical data loading and management"""
	var success = true

	# Check that historical data is initialized
	success = success and assert_true(performance_reporter.historical_data is Array, "Historical data should be array")

	# Add mock historical data
	var mock_historical = {
		"timestamp": Time.get_unix_time_from_system() - 86400,  # 1 day ago
		"summary": {"average_performance": 15.0}
	}
	performance_reporter.historical_data.append(mock_historical)

	success = success and assert_greater_than(performance_reporter.historical_data.size(), 0, "Should contain historical data")

	# Test trend chart generation with historical data
	var trend_chart = performance_reporter._generate_trend_chart()
	success = success and assert_not_null(trend_chart, "Should generate trend chart")

	return success  #  "Historical data management should work correctly")

# ------------------------------------------------------------------------------
# UTILITY FUNCTION TESTS
# ------------------------------------------------------------------------------
func test_utility_calculations() -> bool:
	"""Test utility calculation functions"""
	var success = true

	# Test variance calculation
	var test_data = [10.0, 12.0, 8.0, 15.0, 9.0]
	var variance = performance_reporter._calculate_variance(test_data)
	success = success and assert_greater_than(variance, 0, "Should calculate variance correctly")

	# Test performance differences calculation
	var baseline_results = {
		"benchmark_results": {
			"op1": {"average_time": 10.0},
			"op2": {"average_time": 20.0}
		}
	}

	var current_results = {
		"benchmark_results": {
			"op1": {"average_time": 15.0},
			"op2": {"average_time": 18.0}
		}
	}

	var differences = performance_reporter._calculate_performance_differences(baseline_results, current_results)
	success = success and assert_not_null(differences, "Should calculate differences")
	success = success and assert_equals(differences.op1, 5.0, "Should calculate op1 difference correctly")
	success = success and assert_equals(differences.op2, -2.0, "Should calculate op2 difference correctly")

	return success  #  "Utility calculations should work correctly")

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Test report generation with empty data
	var empty_results = {}
	var empty_report = performance_reporter.generate_performance_report(empty_results)
	success = success and assert_not_null(empty_report, "Should handle empty results gracefully")

	# Test comparison with missing data
	var incomplete_baseline = {}
	var incomplete_current = {"benchmark_results": {"op1": {"average_time": 10.0}}}
	var incomplete_comparison = performance_reporter.generate_comparison_report(incomplete_baseline, incomplete_current)
	success = success and assert_not_null(incomplete_comparison, "Should handle incomplete data gracefully")

	# Test chart generation with minimal data
	var minimal_results = {"benchmark_results": {}}
	var minimal_charts = performance_reporter._generate_performance_charts(minimal_results)
	success = success and assert_not_null(minimal_charts, "Should handle minimal data gracefully")

	return success  #  "Error handling should work correctly")

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_report_generation_integration() -> bool:
	"""Test complete report generation workflow"""
	var success = true

	# Create comprehensive benchmark results
	var comprehensive_results = {
		"benchmark_results": {
			"database_query": {"average_time": 25.0, "min_time": 20.0, "max_time": 35.0},
			"file_operation": {"average_time": 15.0, "min_time": 12.0, "max_time": 20.0},
			"network_call": {"average_time": 45.0, "min_time": 30.0, "max_time": 60.0}
		},
		"memory_usage": 120 * 1024 * 1024,  # 120MB
		"fps_average": 52.0,
		"memory_samples": [110.0, 115.0, 120.0, 118.0, 125.0],
		"fps_samples": [50, 52, 55, 51, 53]
	}

	# Generate full report
	var report = performance_reporter.generate_performance_report(comprehensive_results, {"format": "json"})

	# Verify report completeness
	success = success and assert_true(report.has("timestamp"), "Should include timestamp")
	success = success and assert_true(report.has("summary"), "Should include summary")
	success = success and assert_true(report.has("charts"), "Should include charts")
	success = success and assert_true(report.has("recommendations"), "Should include recommendations")
	success = success and assert_true(report.has("alerts"), "Should include alerts")
	success = success and assert_true(report.has("report_path"), "Should include report path")

	# Verify summary calculations
	var summary = report.summary
	success = success and assert_equals(summary.total_benchmarks, 3, "Should count all benchmarks")
	success = success and assert_greater_than(summary.average_performance, 0, "Should calculate average")
	success = success and assert_equals(summary.best_performance, "file_operation", "Should identify best performer")
	success = success and assert_equals(summary.worst_performance, "network_call", "Should identify worst performer")

	return success  #  "Complete report generation workflow should work correctly")

# ------------------------------------------------------------------------------
# CLEANUP AND FINALIZATION TESTS
# ------------------------------------------------------------------------------
func test_cleanup_functionality() -> bool:
	"""Test cleanup and finalization"""
	var success = true

	# Add test data
	var test_report = {"test": "data"}
	performance_reporter.report_data = test_report
	performance_reporter.historical_data.append({"test": "historical"})

	success = success and assert_false(performance_reporter.report_data.is_empty(), "Should have report data")
	success = success and assert_greater_than(performance_reporter.historical_data.size(), 0, "Should have historical data")

	# Simulate cleanup (would happen in _exit_tree)
	performance_reporter.report_data.clear()
	performance_reporter.historical_data.clear()
	performance_reporter.performance_charts.clear()
	performance_reporter.report_templates.clear()

	success = success and assert_true(performance_reporter.report_data.is_empty(), "Should clear report data")
	success = success and assert_true(performance_reporter.historical_data.is_empty(), "Should clear historical data")

	return success  #  "Cleanup functionality should work correctly")

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_performance_reporter_test_suite() -> void:
	"""Run all PerformanceReporter tests"""
	print("\n📈 Running PerformanceReporter Test Suite\n")

	# Report Generation Tests
	run_test("test_report_generation", func(): return test_report_generation())
	run_test("test_comparison_report_generation", func(): return test_comparison_report_generation())

	# Chart Generation Tests
	run_test("test_chart_generation", func(): return test_chart_generation())
	run_test("test_comparison_chart_generation", func(): return test_comparison_chart_generation())

	# Analysis and Calculation Tests
	run_test("test_report_summary_generation", func(): return test_report_summary_generation())
	run_test("test_performance_recommendations", func(): return test_performance_recommendations())
	run_test("test_performance_alerts", func(): return test_performance_alerts())

	# Comparison Analysis Tests
	run_test("test_benchmark_comparison", func(): return test_benchmark_comparison())
	run_test("test_comparison_summary", func(): return test_comparison_summary())

	# CI/CD Integration Tests
	run_test("test_ci_report_generation", func(): return test_ci_report_generation())
	run_test("test_performance_score_calculation", func(): return test_performance_score_calculation())

	# File Management Tests
	run_test("test_file_operations", func(): return test_file_operations())

	# Historical Data Tests
	run_test("test_historical_data_management", func(): return test_historical_data_management())

	# Utility Function Tests
	run_test("test_utility_calculations", func(): return test_utility_calculations())

	# Error Handling Tests
	run_test("test_error_handling", func(): return test_error_handling())

	# Integration Tests
	run_test("test_report_generation_integration", func(): return test_report_generation_integration())

	# Cleanup Tests
	run_test("test_cleanup_functionality", func(): return test_cleanup_functionality())

	print("\n📈 PerformanceReporter Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
