extends SceneTree

# Test runner that loads CoverageTracker and runs instrumented test

# Simple in-memory CoverageTracker for spike (replaces singleton)
class CoverageTrackerSimple:
	var hits = {}
	var enabled = true
	
	func hit(file: String, line: int):
		if not enabled:
			return
		if file not in hits:
			hits[file] = {}
		if line not in hits[file]:
			hits[file][line] = 0
		hits[file][line] += 1
	
	func print_report():
		print("\n=== Coverage Report ===")
		for file in hits:
			print("\nFile: %s" % file)
			var lines = hits[file].keys()
			lines.sort()
			for line_num in lines:
				var count = hits[file][line_num]
				print("  Line %d: %d hits" % [line_num, count])
		print("======================\n")

# Global tracker instance
var CoverageTracker = CoverageTrackerSimple.new()

func _init():
	print("=== Spike 1: Instrumentation Test ===\n")
	
	# Run the instrumented test
	run_instrumented_test()
	
	# Print coverage report
	CoverageTracker.print_report()
	
	# Exit
	quit()

func run_instrumented_test():
	print("Running instrumented test...")
	
	# Inline the instrumented test logic
	# This simulates what would happen if we loaded test_sample_instrumented.gd
	
	CoverageTracker.hit("test_sample.gd", 7)
	var x = 5
	CoverageTracker.hit("test_sample.gd", 8)
	var y = 10
	CoverageTracker.hit("test_sample.gd", 9)
	var result = x + y
	CoverageTracker.hit("test_sample.gd", 10)
	assert(result == 15, "Basic math should work")
	print("✓ test_basic_assignment passed")
	
	CoverageTracker.hit("test_sample.gd", 14)
	var value = 42
	CoverageTracker.hit("test_sample.gd", 15)
	if value > 0:
		CoverageTracker.hit("test_sample.gd", 16)
		print("✓ test_conditionals passed (true branch)")
	else:
		CoverageTracker.hit("test_sample.gd", 18)
		print("✗ test_conditionals failed (false branch)")
	
	CoverageTracker.hit("test_sample.gd", 21)
	var sum = 0
	CoverageTracker.hit("test_sample.gd", 22)
	for i in range(5):
		sum += i
	CoverageTracker.hit("test_sample.gd", 24)
	assert(sum == 10, "Loop sum should be 10")
	print("✓ test_loops passed")
	
	print("\nAll tests executed!")
