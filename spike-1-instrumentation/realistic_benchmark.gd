extends SceneTree

# Realistic benchmark: includes actual work (node creation, string operations, etc.)

class CoverageTrackerSimple:
	var hits = {}
	var enabled = true
	var file_cache = {}
	
	func hit(file: String, line: int):
		if not enabled:
			return
		var file_dict = file_cache.get(file)
		if file_dict == null:
			file_dict = {}
			hits[file] = file_dict
			file_cache[file] = file_dict
		file_dict[line] = file_dict.get(line, 0) + 1

var CoverageTracker = CoverageTrackerSimple.new()

func _init():
	print("=== Realistic Performance Benchmark ===")
	print("(Includes actual work: node creation, string ops, assertions)\n")
	
	var iterations = 1000
	
	# Test 1: Original code
	var time_original = benchmark_original(iterations)
	print("Original code: %.2f ms" % time_original)
	
	# Test 2: Instrumented code
	var time_instrumented = benchmark_instrumented(iterations)
	print("Instrumented code: %.2f ms" % time_instrumented)
	
	# Calculate overhead
	var overhead = time_instrumented - time_original
	var overhead_pct = (overhead / time_original) * 100.0
	
	print("\nOverhead: %.2f ms (%.2f%%)" % [overhead, overhead_pct])
	
	if overhead_pct < 10.0:
		print("✓ SUCCESS: Overhead < 10% - acceptable!")
	elif overhead_pct < 15.0:
		print("⚠ WARNING: Overhead 10-15% - borderline")
	elif overhead_pct < 30.0:
		print("⚠ CAUTION: Overhead 15-30% - acceptable for optional feature")
	else:
		print("✗ FAILURE: Overhead > 30% - too high!")
	
	quit()

func benchmark_original(iterations: int) -> float:
	var start_time = Time.get_ticks_usec()
	
	for i in range(iterations):
		# Realistic test work
		var node = Node.new()
		node.name = "TestNode_%d" % i
		
		var data = {"key": "value", "count": i}
		var json_str = JSON.stringify(data)
		var parsed = JSON.parse_string(json_str)
		
		assert(parsed.key == "value")
		assert(parsed.count == i)
		
		node.free()
	
	var end_time = Time.get_ticks_usec()
	return (end_time - start_time) / 1000.0

func benchmark_instrumented(iterations: int) -> float:
	var start_time = Time.get_ticks_usec()
	
	for i in range(iterations):
		# Same work with instrumentation
		CoverageTracker.hit("test.gd", 10)
		var node = Node.new()
		CoverageTracker.hit("test.gd", 11)
		node.name = "TestNode_%d" % i
		
		CoverageTracker.hit("test.gd", 13)
		var data = {"key": "value", "count": i}
		CoverageTracker.hit("test.gd", 14)
		var json_str = JSON.stringify(data)
		CoverageTracker.hit("test.gd", 15)
		var parsed = JSON.parse_string(json_str)
		
		CoverageTracker.hit("test.gd", 17)
		assert(parsed.key == "value")
		CoverageTracker.hit("test.gd", 18)
		assert(parsed.count == i)
		
		CoverageTracker.hit("test.gd", 20)
		node.free()
	
	var end_time = Time.get_ticks_usec()
	return (end_time - start_time) / 1000.0
