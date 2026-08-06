extends SceneTree

# Performance benchmark: measure instrumentation overhead

class CoverageTrackerSimple:
	var hits = {}
	var enabled = true
	var file_cache = {}  # Cache file dictionaries
	
	func hit(file: String, line: int):
		if not enabled:
			return
		
		# Get or create file dict (cached)
		var file_dict = file_cache.get(file)
		if file_dict == null:
			file_dict = {}
			hits[file] = file_dict
			file_cache[file] = file_dict
		
		# Increment hit count (simplified)
		file_dict[line] = file_dict.get(line, 0) + 1

var CoverageTracker = CoverageTrackerSimple.new()

func _init():
	print("=== Performance Benchmark ===\n")
	
	var iterations = 10000
	
	# Test 1: Original code (no instrumentation)
	var time_original = benchmark_original(iterations)
	print("Original code: %.4f ms (%.2f µs per iteration)" % [time_original, time_original * 1000.0 / iterations])
	
	# Test 2: Instrumented code
	var time_instrumented = benchmark_instrumented(iterations)
	print("Instrumented code: %.4f ms (%.2f µs per iteration)" % [time_instrumented, time_instrumented * 1000.0 / iterations])
	
	# Calculate overhead
	var overhead = time_instrumented - time_original
	var overhead_pct = (overhead / time_original) * 100.0
	
	print("\nOverhead: %.4f ms (%.2f%%)" % [overhead, overhead_pct])
	
	if overhead_pct < 10.0:
		print("✓ SUCCESS: Overhead < 10% - acceptable!")
	elif overhead_pct < 15.0:
		print("⚠ WARNING: Overhead between 10-15% - borderline")
	else:
		print("✗ FAILURE: Overhead > 15% - too high!")
	
	quit()

func benchmark_original(iterations: int) -> float:
	var start_time = Time.get_ticks_usec()
	
	for i in range(iterations):
		# Original test logic (no instrumentation)
		var x = 5
		var y = 10
		var result = x + y
		assert(result == 15)
		
		var value = 42
		if value > 0:
			pass  # Do nothing
		
		var sum = 0
		for j in range(5):
			sum += j
		assert(sum == 10)
	
	var end_time = Time.get_ticks_usec()
	return (end_time - start_time) / 1000.0  # Convert to milliseconds

func benchmark_instrumented(iterations: int) -> float:
	var start_time = Time.get_ticks_usec()
	
	for i in range(iterations):
		# Instrumented test logic
		CoverageTracker.hit("test.gd", 7)
		var x = 5
		CoverageTracker.hit("test.gd", 8)
		var y = 10
		CoverageTracker.hit("test.gd", 9)
		var result = x + y
		CoverageTracker.hit("test.gd", 10)
		assert(result == 15)
		
		CoverageTracker.hit("test.gd", 14)
		var value = 42
		CoverageTracker.hit("test.gd", 15)
		if value > 0:
			CoverageTracker.hit("test.gd", 16)
			pass  # Do nothing
		
		CoverageTracker.hit("test.gd", 21)
		var sum = 0
		CoverageTracker.hit("test.gd", 22)
		for j in range(5):
			sum += j
		CoverageTracker.hit("test.gd", 24)
		assert(sum == 10)
	
	var end_time = Time.get_ticks_usec()
	return (end_time - start_time) / 1000.0  # Convert to milliseconds
