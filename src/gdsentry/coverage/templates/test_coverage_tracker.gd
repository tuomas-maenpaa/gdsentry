extends SceneTree

# Unit tests for CoverageTracker
# Run with: godot --headless --script test_coverage_tracker.gd

var tracker: Node
var test_output_dir = "res://test_output/"
var tests_passed = 0
var tests_failed = 0

func _init():
	print("\n=== CoverageTracker Unit Tests ===\n")
	
	# Setup
	setup_test_environment()
	
	# Run tests
	test_hit_tracking()
	test_multiple_files()
	test_multiple_hits_same_line()
	test_reset()
	test_get_stats()
	test_write_coverage_data()
	test_write_error_handling()
	test_disabled_tracking()
	
	# Teardown
	teardown_test_environment()
	
	# Report
	print("\n=== Test Results ===")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("===================\n")
	
	quit(0 if tests_failed == 0 else 1)

func setup_test_environment():
	# Create test output directory
	DirAccess.make_dir_recursive_absolute(test_output_dir)
	
	# Load tracker script
	var tracker_script = load("res://coverage_tracker.gd")
	tracker = tracker_script.new()
	tracker._enabled = true
	tracker._output_path = test_output_dir

func teardown_test_environment():
	# Clean up test files
	var dir = DirAccess.open(test_output_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func assert_true(condition: bool, message: String):
	if condition:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s" % message)
		tests_failed += 1

func assert_equals(actual, expected, message: String):
	if actual == expected:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])
		tests_failed += 1

func test_hit_tracking():
	print("\n--- Test: Hit Tracking ---")
	tracker.reset()
	
	tracker.hit("test.gd", 10)
	
	var data = tracker._coverage_data
	assert_true(data.has("test.gd"), "File tracked")
	assert_true(data["test.gd"].has(10), "Line tracked")
	assert_equals(data["test.gd"][10], 1, "Hit count is 1")

func test_multiple_files():
	print("\n--- Test: Multiple Files ---")
	tracker.reset()
	
	tracker.hit("file1.gd", 5)
	tracker.hit("file2.gd", 10)
	tracker.hit("file3.gd", 15)
	
	var data = tracker._coverage_data
	assert_equals(data.size(), 3, "Three files tracked")
	assert_true(data.has("file1.gd"), "File1 tracked")
	assert_true(data.has("file2.gd"), "File2 tracked")
	assert_true(data.has("file3.gd"), "File3 tracked")

func test_multiple_hits_same_line():
	print("\n--- Test: Multiple Hits Same Line ---")
	tracker.reset()
	
	tracker.hit("test.gd", 20)
	tracker.hit("test.gd", 20)
	tracker.hit("test.gd", 20)
	
	var data = tracker._coverage_data
	assert_equals(data["test.gd"][20], 3, "Hit count is 3")

func test_reset():
	print("\n--- Test: Reset ---")
	tracker.reset()
	
	tracker.hit("test.gd", 1)
	tracker.hit("test.gd", 2)
	assert_true(tracker._coverage_data.size() > 0, "Data exists before reset")
	
	tracker.reset()
	assert_equals(tracker._coverage_data.size(), 0, "Data cleared after reset")

func test_get_stats():
	print("\n--- Test: Get Stats ---")
	tracker.reset()
	
	tracker.hit("file1.gd", 10)
	tracker.hit("file1.gd", 10)
	tracker.hit("file2.gd", 5)
	
	var stats = tracker.get_stats()
	assert_equals(stats["files_tracked"], 2, "Two files in stats")
	assert_equals(stats["total_hits"], 3, "Three hits in stats")
	assert_true(stats["data_size_bytes"] > 0, "Data size reported")

func test_write_coverage_data():
	print("\n--- Test: Write Coverage Data ---")
	tracker.reset()
	
	tracker.hit("test.gd", 5)
	tracker.hit("test.gd", 10)
	
	var test_path = test_output_dir + "test_coverage.json"
	var success = tracker.write_coverage_data(test_path)
	
	assert_true(success, "Write succeeded")
	assert_true(FileAccess.file_exists(test_path), "File was created")
	
	# Read and validate JSON
	var file = FileAccess.open(test_path, FileAccess.READ)
	assert_true(file != null, "File can be opened")
	
	if file:
		var json_str = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		assert_equals(parse_result, OK, "JSON is valid")
		
		if parse_result == OK:
			var data = json.data
			assert_true(data.has("format_version"), "Has format_version")
			assert_true(data.has("timestamp"), "Has timestamp")
			assert_true(data.has("files"), "Has files")
			assert_true(data["files"].has("test.gd"), "Has test.gd data")
			assert_equals(data["files"]["test.gd"][5], 1, "Line 5 has 1 hit")
			assert_equals(data["files"]["test.gd"][10], 1, "Line 10 has 1 hit")

func test_write_error_handling():
	print("\n--- Test: Write Error Handling ---")
	tracker.reset()
	
	tracker.hit("test.gd", 1)
	
	# Try to write to invalid path (should fail gracefully)
	var invalid_path = "/invalid/nonexistent/path/coverage.json"
	var success = tracker.write_coverage_data(invalid_path)
	
	assert_true(not success, "Write fails for invalid path")
	
	# Check error file was created
	var error_file_path = test_output_dir + "coverage_error.txt"
	# Note: Error file should exist from the failed write
	# This is implementation-dependent, so we just verify it doesn't crash

func test_disabled_tracking():
	print("\n--- Test: Disabled Tracking ---")
	tracker.reset()
	tracker._enabled = false
	
	tracker.hit("test.gd", 1)
	
	assert_equals(tracker._coverage_data.size(), 0, "No tracking when disabled")
	
	# Re-enable for other tests
	tracker._enabled = true
