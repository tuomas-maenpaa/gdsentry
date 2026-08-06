extends PerformanceBenchmarkTest

## CI/CD Performance Gate Example
##
## Demonstrates CI/CD performance gate checking for automated builds.
## This example shows how to:
## - Configure performance gates
## - Run benchmarks with gate checking
## - Generate pass/fail reports
## - Integrate with CI/CD pipelines

func test_performance_gate_pass():
	"""Test performance gate with passing results"""
	describe("Performance Gate - Pass Scenario")
	
	print("\n🚦 Testing CI/CD Performance Gate (Pass)")
	
	# Configure gate thresholds
	ci_gate_checker.gate_thresholds = {
		"performance_regression": 0.10,  # 10% regression threshold
		"memory_regression": 20.0,       # 20MB memory increase
		"fps_drop": 10.0                 # 10 FPS drop
	}
	
	print("  Gate Thresholds:")
	print("    Performance Regression: ", ci_gate_checker.gate_thresholds.performance_regression * 100, "%")
	print("    Memory Regression: ", ci_gate_checker.gate_thresholds.memory_regression, " MB")
	print("    FPS Drop: ", ci_gate_checker.gate_thresholds.fps_drop, " FPS")
	
	# Run benchmark
	var iterations = 10
	var results = []
	
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Workload
		var test_array = []
		for j in range(3000):
			test_array.append(j)
		test_array.sort()
		
		var end_time = Time.get_ticks_usec()
		results.append((end_time - start_time) / 1000000.0)
	
	var current_stats = statistical_analyzer.calculate_basic_statistics(results)
	
	# Simulate baseline (slightly slower, but within threshold)
	var baseline_stats = {
		"mean": current_stats.mean * 0.95,  # Current is 5% slower (within 10% threshold)
		"median": current_stats.median * 0.95,
		"std_dev": current_stats.std_dev
	}
	
	var baseline_comparison = {
		"percent_change": 0.05,  # 5% slower
		"improved": false,
		"regressed": false,  # Not regressed because within threshold
		"stable": true
	}
	
	# Check performance gate
	var gate_result = ci_gate_checker.check_performance_gate(
		{"stats": current_stats},
		baseline_comparison
	)
	
	print("\n📊 Gate Check Results:")
	print("  Gate Passed: ", gate_result.gate_passed)
	print("  Performance Change: ", "%.1f" % (baseline_comparison.percent_change * 100), "%")
	
	# Generate report
	var report = ci_gate_checker.generate_gate_report(gate_result)
	print("\n" + report)
	
	assert_true(gate_result.gate_passed, "Gate should pass with 5% regression (threshold 10%)")
	print("\n✅ Performance gate PASSED")

func test_performance_gate_fail():
	"""Test performance gate with failing results"""
	describe("Performance Gate - Fail Scenario")
	
	print("\n🚦 Testing CI/CD Performance Gate (Fail)")
	
	# Configure strict gate thresholds
	ci_gate_checker.gate_thresholds = {
		"performance_regression": 0.05,  # 5% regression threshold (strict)
		"memory_regression": 10.0,
		"fps_drop": 5.0
	}
	
	print("  Gate Thresholds (Strict):")
	print("    Performance Regression: ", ci_gate_checker.gate_thresholds.performance_regression * 100, "%")
	
	# Run benchmark
	var iterations = 10
	var results = []
	
	for i in range(iterations):
		var start_time = Time.get_ticks_usec()
		
		# Workload
		var test_array = []
		for j in range(3000):
			test_array.append(j)
		test_array.sort()
		
		var end_time = Time.get_ticks_usec()
		results.append((end_time - start_time) / 1000000.0)
	
	var current_stats = statistical_analyzer.calculate_basic_statistics(results)
	
	# Simulate baseline (significantly faster - current is regressed)
	var baseline_stats = {
		"mean": current_stats.mean * 0.85,  # Current is 15% slower (exceeds 5% threshold)
		"median": current_stats.median * 0.85,
		"std_dev": current_stats.std_dev
	}
	
	var baseline_comparison = {
		"percent_change": 0.15,  # 15% slower - REGRESSION
		"improved": false,
		"regressed": true,
		"stable": false
	}
	
	# Check performance gate
	var gate_result = ci_gate_checker.check_performance_gate(
		{"stats": current_stats},
		baseline_comparison
	)
	
	print("\n📊 Gate Check Results:")
	print("  Gate Passed: ", gate_result.gate_passed)
	print("  Performance Change: ", "%.1f" % (baseline_comparison.percent_change * 100), "%")
	print("  Failures: ", gate_result.failures.size())
	
	# Generate report
	var report = ci_gate_checker.generate_gate_report(gate_result)
	print("\n" + report)
	
	assert_false(gate_result.gate_passed, "Gate should fail with 15% regression (threshold 5%)")
	assert_true(gate_result.failures.size() > 0, "Should have failure reasons")
	
	print("\n❌ Performance gate FAILED (as expected)")
	print("  This demonstrates how CI/CD gates catch regressions")

func test_memory_gate():
	"""Test memory regression gate"""
	describe("Memory Regression Gate")
	
	print("\n🚦 Testing Memory Regression Gate")
	
	# Configure gate
	ci_gate_checker.gate_thresholds = {
		"performance_regression": 0.10,
		"memory_regression": 5.0,  # 5MB threshold
		"fps_drop": 10.0
	}
	
	print("  Memory Threshold: ", ci_gate_checker.gate_thresholds.memory_regression, " MB")
	
	# Simulate memory measurements
	var current_memory = 150.0  # MB
	var baseline_memory = 140.0  # MB
	var memory_increase = current_memory - baseline_memory
	
	print("\n📊 Memory Measurements:")
	print("  Baseline Memory: ", baseline_memory, " MB")
	print("  Current Memory: ", current_memory, " MB")
	print("  Increase: ", memory_increase, " MB")
	
	# Check if memory increase exceeds threshold
	var memory_gate_passed = memory_increase <= ci_gate_checker.gate_thresholds.memory_regression
	
	if memory_gate_passed:
		print("\n✅ Memory gate PASSED")
	else:
		print("\n❌ Memory gate FAILED")
		print("  Increase (", memory_increase, " MB) exceeds threshold (", 
		      ci_gate_checker.gate_thresholds.memory_regression, " MB)")
	
	assert_false(memory_gate_passed, "Memory gate should fail (10MB > 5MB threshold)")

func test_fps_gate():
	"""Test FPS drop gate"""
	describe("FPS Drop Gate")
	
	print("\n🚦 Testing FPS Drop Gate")
	
	# Configure gate
	ci_gate_checker.gate_thresholds = {
		"performance_regression": 0.10,
		"memory_regression": 10.0,
		"fps_drop": 5.0  # 5 FPS threshold
	}
	
	print("  FPS Drop Threshold: ", ci_gate_checker.gate_thresholds.fps_drop, " FPS")
	
	# Simulate FPS measurements
	var baseline_fps = 60.0
	var current_fps = 57.0
	var fps_drop = baseline_fps - current_fps
	
	print("\n📊 FPS Measurements:")
	print("  Baseline FPS: ", baseline_fps)
	print("  Current FPS: ", current_fps)
	print("  Drop: ", fps_drop, " FPS")
	
	# Check if FPS drop exceeds threshold
	var fps_gate_passed = fps_drop <= ci_gate_checker.gate_thresholds.fps_drop
	
	if fps_gate_passed:
		print("\n✅ FPS gate PASSED")
	else:
		print("\n❌ FPS gate FAILED")
		print("  Drop (", fps_drop, " FPS) exceeds threshold (", 
		      ci_gate_checker.gate_thresholds.fps_drop, " FPS)")
	
	assert_true(fps_gate_passed, "FPS gate should pass (3 FPS < 5 FPS threshold)")

func test_comprehensive_gate_check():
	"""Test comprehensive gate check with all metrics"""
	describe("Comprehensive Gate Check")
	
	print("\n🚦 Testing Comprehensive Performance Gate")
	
	# Configure gates
	ci_gate_checker.gate_thresholds = {
		"performance_regression": 0.08,  # 8%
		"memory_regression": 15.0,       # 15MB
		"fps_drop": 8.0                  # 8 FPS
	}
	
	print("  Configured Thresholds:")
	print("    Performance: ", ci_gate_checker.gate_thresholds.performance_regression * 100, "%")
	print("    Memory: ", ci_gate_checker.gate_thresholds.memory_regression, " MB")
	print("    FPS: ", ci_gate_checker.gate_thresholds.fps_drop, " FPS")
	
	# Simulate comprehensive benchmark results
	var benchmark_results = {
		"performance": {
			"mean": 0.0234,
			"regression": 0.06  # 6% regression - PASS
		},
		"memory": {
			"current": 125.0,
			"baseline": 115.0,
			"increase": 10.0  # 10MB increase - PASS
		},
		"fps": {
			"current": 58.0,
			"baseline": 60.0,
			"drop": 2.0  # 2 FPS drop - PASS
		}
	}
	
	print("\n📊 Benchmark Results:")
	print("  Performance Regression: ", "%.1f" % (benchmark_results.performance.regression * 100), "%")
	print("  Memory Increase: ", benchmark_results.memory.increase, " MB")
	print("  FPS Drop: ", benchmark_results.fps.drop, " FPS")
	
	# Check all gates
	var all_passed = true
	var failures = []
	
	if benchmark_results.performance.regression > ci_gate_checker.gate_thresholds.performance_regression:
		all_passed = false
		failures.append("Performance regression exceeded threshold")
	
	if benchmark_results.memory.increase > ci_gate_checker.gate_thresholds.memory_regression:
		all_passed = false
		failures.append("Memory increase exceeded threshold")
	
	if benchmark_results.fps.drop > ci_gate_checker.gate_thresholds.fps_drop:
		all_passed = false
		failures.append("FPS drop exceeded threshold")
	
	print("\n🚦 Gate Results:")
	if all_passed:
		print("  ✅ ALL GATES PASSED")
		print("  Build can proceed")
	else:
		print("  ❌ GATES FAILED")
		print("  Failures:")
		for failure in failures:
			print("    - ", failure)
		print("  Build should be blocked")
	
	assert_true(all_passed, "All gates should pass with current thresholds")
	print("\n✅ Comprehensive gate check completed")
