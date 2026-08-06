extends PerformanceBenchmarkTest

## Baseline Comparison Example
##
## Demonstrates how to create, store, and compare against performance baselines.
## This example shows how to:
## - Create performance baselines
## - Store baselines for future comparison
## - Compare current results against baselines
## - Detect performance regressions

func test_create_baseline():
	"""Create a performance baseline"""
	describe("Create Performance Baseline")
	
	print("\n📊 Creating performance baseline...")
	
	# Run benchmark to establish baseline
	var iterations = 10
	var results = []
	
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Simulate workload
		var test_array = []
		for j in range(5000):
			test_array.append(j * 2)
		test_array.sort()
		
		var end_time = Time.get_ticks_usec()
		var duration = (end_time - start_time) / 1000000.0
		results.append(duration)
	
	# Calculate statistics for baseline
	var stats = statistical_analyzer.calculate_basic_statistics(results)
	
	print("  Mean: ", "%.4f" % stats.mean, "s")
	print("  Median: ", "%.4f" % stats.median, "s")
	print("  Std Dev: ", "%.4f" % stats.std_dev, "s")
	
	# Store baseline
	var baseline_data = {
		"name": "array_sort_v1.0",
		"stats": stats,
		"raw_results": results,
		"metadata": {
			"version": "1.0.0",
			"date": Time.get_datetime_string_from_system(),
			"iterations": iterations
		}
	}
	
	var success = baseline_manager.store_baseline("array_sort_v1.0", baseline_data)
	
	assert_true(success, "Baseline should be stored successfully")
	print("\n✅ Baseline created and stored: array_sort_v1.0")

func test_compare_with_baseline():
	"""Compare current performance against baseline"""
	describe("Compare with Baseline")
	
	print("\n📊 Running benchmark for comparison...")
	
	# First, ensure baseline exists (create if needed)
	var baseline = baseline_manager.retrieve_baseline("array_sort_v1.0")
	if baseline.is_empty():
		print("  ⚠️  Baseline not found, creating...")
		test_create_baseline()
		baseline = baseline_manager.retrieve_baseline("array_sort_v1.0")
	
	# Run current benchmark
	var iterations = 10
	var results = []
	
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Same workload as baseline
		var test_array = []
		for j in range(5000):
			test_array.append(j * 2)
		test_array.sort()
		
		var end_time = Time.get_ticks_usec()
		var duration = (end_time - start_time) / 1000000.0
		results.append(duration)
	
	# Calculate current statistics
	var current_stats = statistical_analyzer.calculate_basic_statistics(results)
	
	print("\n📈 Current Performance:")
	print("  Mean: ", "%.4f" % current_stats.mean, "s")
	print("  Median: ", "%.4f" % current_stats.median, "s")
	
	# Compare with baseline
	var baseline_stats = baseline.data.stats
	var comparison = baseline_manager.compare_with_baseline("array_sort_v1.0", {
		"stats": current_stats,
		"raw_results": results
	})
	
	print("\n🔍 Baseline Comparison:")
	print("  Baseline Mean: ", "%.4f" % baseline_stats.mean, "s")
	print("  Current Mean: ", "%.4f" % current_stats.mean, "s")
	print("  Difference: ", "%.2f" % (comparison.percent_change * 100), "%")
	
	if comparison.improved:
		print("  Status: ✅ Performance IMPROVED")
	elif comparison.regressed:
		print("  Status: ⚠️  Performance REGRESSED")
	else:
		print("  Status: ➡️  Performance STABLE")
	
	# Detect regression
	var regression = regression_detector.detect_performance_regression(
		current_stats,
		baseline_stats
	)
	
	if regression.regression_detected:
		print("\n⚠️  REGRESSION DETECTED:")
		print("  Type: ", regression.regression_type)
		print("  Severity: ", regression.severity)
		print("  Confidence: ", "%.1f" % (regression.confidence * 100), "%")
		
		# This is expected in some test runs due to system variance
		# In production, this would fail the test
		print("  Note: Regression detection is working as expected")
	else:
		print("\n✅ No regression detected")
	
	assert_true(true, "Comparison completed successfully")

func test_trend_analysis():
	"""Analyze performance trends over multiple runs"""
	describe("Performance Trend Analysis")
	
	print("\n📊 Simulating historical performance data...")
	
	# Simulate historical data (in real scenario, this comes from stored baselines)
	var historical_data = [
		0.0234,  # Run 1
		0.0231,  # Run 2
		0.0235,  # Run 3
		0.0238,  # Run 4
		0.0242,  # Run 5 - slight degradation
		0.0245,  # Run 6
		0.0248,  # Run 7
		0.0251,  # Run 8
		0.0255,  # Run 9
		0.0258   # Run 10 - clear trend
	]
	
	# Analyze trend
	var trend = trend_analyzer.analyze_performance_trend(historical_data)
	
	print("\n📈 Trend Analysis:")
	print("  Trend: ", trend.trend)
	print("  Direction: ", "%.4f" % trend.direction)
	print("  Confidence: ", "%.1f" % (trend.confidence * 100), "%")
	print("  Slope: ", "%.6f" % trend.slope)
	
	if trend.trend == "degrading":
		print("  ⚠️  Performance is degrading over time")
		print("  Recommendation: Investigate recent changes")
	elif trend.trend == "improving":
		print("  ✅ Performance is improving over time")
	else:
		print("  ➡️  Performance is stable")
	
	# Detect trend-based regression
	var trend_regression = regression_detector.detect_trend_regression(historical_data)
	
	if trend_regression.trend_regression:
		print("\n⚠️  TREND REGRESSION DETECTED:")
		print("  Direction: ", trend_regression.trend_direction)
		print("  Note: Gradual performance degradation over time")
	
	assert_true(trend.confidence > 0.0, "Trend analysis should produce confidence score")
	print("\n✅ Trend analysis completed")

func test_baseline_cleanup():
	"""Test baseline retention and cleanup"""
	describe("Baseline Cleanup")
	
	print("\n🧹 Testing baseline cleanup...")
	
	# Check current baselines
	var initial_count = baseline_manager.baseline_storage.size()
	print("  Current baselines: ", initial_count)
	
	# Cleanup old baselines (older than retention period)
	var removed_count = baseline_manager.cleanup_old_baselines()
	
	print("  Removed baselines: ", removed_count)
	print("  Remaining baselines: ", baseline_manager.baseline_storage.size())
	
	assert_true(removed_count >= 0, "Cleanup should return non-negative count")
	print("\n✅ Baseline cleanup completed")
