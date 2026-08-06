extends PerformanceBenchmarkTest

## Basic Performance Benchmark Example
##
## Demonstrates fundamental performance benchmarking with statistical analysis.
## This example shows how to:
## - Run simple performance benchmarks
## - Collect statistical metrics
## - Detect outliers
## - Generate performance reports

func test_array_operations_benchmark():
	"""Benchmark basic array operations"""
	describe("Array Operations Performance")
	
	# Configure benchmark
	var iterations = 10
	var array_size = 10000
	var results = []
	
	print("\n📊 Running benchmark: array_operations")
	print("  Array size: ", array_size)
	print("  Iterations: ", iterations)
	
	# Run benchmark iterations
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Benchmark: Create and populate array
		var test_array = []
		for j in range(array_size):
			test_array.append(j * 2)
		
		# Benchmark: Array operations
		test_array.sort()
		test_array.reverse()
		var sum = test_array.reduce(func(acc, val): return acc + val, 0)
		
		var end_time = Time.get_ticks_usec()
		var duration = (end_time - start_time) / 1000000.0  # Convert to seconds
		
		results.append(duration)
		print("  Iteration ", i + 1, "/", iterations, ": ", "%.4f" % duration, "s")
	
	# Analyze results
	var stats = statistical_analyzer.calculate_basic_statistics(results)
	var outliers = statistical_analyzer.detect_outliers(results)
	
	# Print statistical analysis
	print("\n📈 Statistical Analysis:")
	print("  Mean: ", "%.4f" % stats.mean, "s")
	print("  Median: ", "%.4f" % stats.median, "s")
	print("  Std Dev: ", "%.4f" % stats.std_dev, "s")
	print("  P95: ", "%.4f" % stats.p95, "s")
	print("  P99: ", "%.4f" % stats.p99, "s")
	print("  Outliers: ", outliers.outliers.size(), " (", "%.1f" % outliers.outlier_percentage, "%)")
	
	# Assertions
	assert_true(stats.mean > 0, "Mean execution time should be positive")
	assert_true(stats.std_dev < stats.mean * 0.5, "Standard deviation should be reasonable")
	assert_true(outliers.outlier_percentage < 20.0, "Outlier percentage should be low")
	
	print("\n✅ Benchmark completed successfully")

func test_dictionary_operations_benchmark():
	"""Benchmark dictionary operations"""
	describe("Dictionary Operations Performance")
	
	var iterations = 10
	var dict_size = 5000
	var results = []
	
	print("\n📊 Running benchmark: dictionary_operations")
	print("  Dictionary size: ", dict_size)
	print("  Iterations: ", iterations)
	
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Benchmark: Create and populate dictionary
		var test_dict = {}
		for j in range(dict_size):
			test_dict["key_" + str(j)] = j * 3
		
		# Benchmark: Dictionary operations
		var keys = test_dict.keys()
		var values = test_dict.values()
		var lookup_sum = 0
		for key in keys:
			lookup_sum += test_dict[key]
		
		var end_time = Time.get_ticks_usec()
		var duration = (end_time - start_time) / 1000000.0
		
		results.append(duration)
		print("  Iteration ", i + 1, "/", iterations, ": ", "%.4f" % duration, "s")
	
	# Analyze results
	var stats = statistical_analyzer.calculate_basic_statistics(results)
	
	print("\n📈 Statistical Analysis:")
	print("  Mean: ", "%.4f" % stats.mean, "s")
	print("  Median: ", "%.4f" % stats.median, "s")
	print("  P95: ", "%.4f" % stats.p95, "s")
	
	assert_true(stats.mean > 0, "Mean execution time should be positive")
	print("\n✅ Benchmark completed successfully")

func test_string_operations_benchmark():
	"""Benchmark string operations"""
	describe("String Operations Performance")
	
	var iterations = 10
	var string_count = 1000
	var results = []
	
	print("\n📊 Running benchmark: string_operations")
	print("  String operations: ", string_count)
	print("  Iterations: ", iterations)
	
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Benchmark: String concatenation and manipulation
		var result_string = ""
		for j in range(string_count):
			result_string += "test_" + str(j) + "_"
		
		# String operations
		result_string = result_string.to_upper()
		var parts = result_string.split("_")
		var joined = "_".join(parts)
		
		var end_time = Time.get_ticks_usec()
		var duration = (end_time - start_time) / 1000000.0
		
		results.append(duration)
		print("  Iteration ", i + 1, "/", iterations, ": ", "%.4f" % duration, "s")
	
	# Analyze results with confidence intervals
	var stats = statistical_analyzer.calculate_basic_statistics(results)
	
	print("\n📈 Statistical Analysis:")
	print("  Mean: ", "%.4f" % stats.mean, "s")
	print("  Confidence Interval: [", "%.4f" % stats.confidence_interval_lower, ", ", 
	      "%.4f" % stats.confidence_interval_upper, "]")
	print("  Std Dev: ", "%.4f" % stats.std_dev, "s")
	
	assert_true(stats.mean > 0, "Mean execution time should be positive")
	print("\n✅ Benchmark completed successfully")
