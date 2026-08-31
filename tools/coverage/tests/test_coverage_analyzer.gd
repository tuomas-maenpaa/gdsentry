extends SceneTree

# Unit tests for Coverage Analyzer
# Run with: godot --headless --script test_coverage_analyzer.gd

var tests_passed = 0
var tests_failed = 0

func _init():
	print("\n=== Coverage Analyzer Unit Tests ===\n")
	
	# Run tests
	test_compute_file_coverage_basic()
	test_compute_file_coverage_empty()
	test_compute_file_coverage_all_covered()
	test_compute_file_coverage_none_covered()
	test_get_missed_lines_basic()
	test_get_missed_lines_all_covered()
	test_get_missed_lines_none_covered()
	test_get_missed_lines_sorted()
	test_analyze_coverage_data_single_file()
	test_analyze_coverage_data_multiple_files()
	test_analyze_coverage_data_empty()
	test_analyze_coverage_data_invalid_data()
	test_string_line_numbers()
	test_get_coverage_summary()
	
	# Report
	print("\n=== Test Results ===")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("===================\n")
	
	quit(0 if tests_failed == 0 else 1)

func assert_equals(actual, expected, message: String):
	if actual == expected:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])
		tests_failed += 1

func assert_true(condition: bool, message: String):
	if condition:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s" % message)
		tests_failed += 1

func assert_approx_equals(actual: float, expected: float, message: String, tolerance: float = 0.1):
	if abs(actual - expected) < tolerance:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s (expected: %.2f, got: %.2f)" % [message, expected, actual])
		tests_failed += 1

func test_compute_file_coverage_basic():
	print("\n--- Test: Compute File Coverage Basic ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		1: 5,
		2: 0,
		3: 10,
		4: 0,
		5: 3
	}
	
	var result = Analyzer.compute_file_coverage(file_data)
	
	assert_equals(result["total"], 5, "Total lines is 5")
	assert_equals(result["covered"], 3, "Covered lines is 3")
	assert_approx_equals(result["percent"], 60.0, "Coverage is 60%")

func test_compute_file_coverage_empty():
	print("\n--- Test: Compute File Coverage Empty ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var result = Analyzer.compute_file_coverage({})
	
	assert_equals(result["total"], 0, "Total is 0")
	assert_equals(result["covered"], 0, "Covered is 0")
	assert_equals(result["percent"], 0.0, "Percent is 0")

func test_compute_file_coverage_all_covered():
	print("\n--- Test: Compute File Coverage All Covered ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		1: 1,
		2: 5,
		3: 10
	}
	
	var result = Analyzer.compute_file_coverage(file_data)
	
	assert_equals(result["covered"], 3, "All 3 lines covered")
	assert_equals(result["percent"], 100.0, "Coverage is 100%")

func test_compute_file_coverage_none_covered():
	print("\n--- Test: Compute File Coverage None Covered ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		1: 0,
		2: 0,
		3: 0
	}
	
	var result = Analyzer.compute_file_coverage(file_data)
	
	assert_equals(result["covered"], 0, "No lines covered")
	assert_equals(result["percent"], 0.0, "Coverage is 0%")

func test_get_missed_lines_basic():
	print("\n--- Test: Get Missed Lines Basic ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		1: 5,
		2: 0,
		3: 10,
		4: 0,
		5: 3
	}
	
	var missed = Analyzer.get_missed_lines(file_data)
	
	assert_equals(missed.size(), 2, "2 missed lines")
	assert_true(2 in missed, "Line 2 is missed")
	assert_true(4 in missed, "Line 4 is missed")

func test_get_missed_lines_all_covered():
	print("\n--- Test: Get Missed Lines All Covered ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		1: 1,
		2: 5,
		3: 10
	}
	
	var missed = Analyzer.get_missed_lines(file_data)
	
	assert_equals(missed.size(), 0, "No missed lines")

func test_get_missed_lines_none_covered():
	print("\n--- Test: Get Missed Lines None Covered ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		1: 0,
		2: 0,
		3: 0
	}
	
	var missed = Analyzer.get_missed_lines(file_data)
	
	assert_equals(missed.size(), 3, "All 3 lines missed")

func test_get_missed_lines_sorted():
	print("\n--- Test: Get Missed Lines Sorted ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var file_data = {
		5: 0,
		1: 0,
		3: 0,
		2: 1,
		4: 1
	}
	
	var missed = Analyzer.get_missed_lines(file_data)
	
	assert_equals(missed.size(), 3, "3 missed lines")
	assert_equals(missed[0], 1, "First is line 1")
	assert_equals(missed[1], 3, "Second is line 3")
	assert_equals(missed[2], 5, "Third is line 5")

func test_analyze_coverage_data_single_file():
	print("\n--- Test: Analyze Coverage Data Single File ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var coverage_data = {
		"test.gd": {
			1: 5,
			2: 0,
			3: 10
		}
	}
	
	var result = Analyzer.analyze_coverage_data(coverage_data)
	
	assert_equals(result["total_lines"], 3, "Total 3 lines")
	assert_equals(result["total_covered"], 2, "2 lines covered")
	assert_approx_equals(result["total_percent"], 66.67, "Coverage ~66.67%", 0.1)
	assert_equals(result["files"].size(), 1, "1 file analyzed")
	assert_equals(result["files"][0]["file"], "test.gd", "File is test.gd")

func test_analyze_coverage_data_multiple_files():
	print("\n--- Test: Analyze Coverage Data Multiple Files ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var coverage_data = {
		"file1.gd": {
			1: 1,
			2: 1
		},
		"file2.gd": {
			1: 0,
			2: 1,
			3: 1
		}
	}
	
	var result = Analyzer.analyze_coverage_data(coverage_data)
	
	assert_equals(result["total_lines"], 5, "Total 5 lines")
	assert_equals(result["total_covered"], 4, "4 lines covered")
	assert_equals(result["total_percent"], 80.0, "Coverage 80%")
	assert_equals(result["files"].size(), 2, "2 files analyzed")

func test_analyze_coverage_data_empty():
	print("\n--- Test: Analyze Coverage Data Empty ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var result = Analyzer.analyze_coverage_data({})
	
	assert_equals(result["total_lines"], 0, "Total 0 lines")
	assert_equals(result["total_covered"], 0, "0 lines covered")
	assert_equals(result["total_percent"], 0.0, "Coverage 0%")
	assert_equals(result["files"].size(), 0, "0 files")

func test_analyze_coverage_data_invalid_data():
	print("\n--- Test: Analyze Coverage Data Invalid Data ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var coverage_data = {
		"file1.gd": {
			1: 1,
			2: 1
		},
		"file2.gd": null,  # Invalid
		"file3.gd": {
			1: 1
		}
	}
	
	var result = Analyzer.analyze_coverage_data(coverage_data)
	
	# Should skip invalid file2.gd
	assert_equals(result["files"].size(), 2, "2 valid files analyzed")
	assert_equals(result["total_lines"], 3, "Total 3 lines (from valid files)")

func test_string_line_numbers():
	print("\n--- Test: String Line Numbers (from JSON) ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	# JSON parsing converts keys to strings
	var file_data = {
		"1": 5,
		"2": 0,
		"3": 10
	}
	
	var missed = Analyzer.get_missed_lines(file_data)
	
	# Should handle string keys
	assert_equals(missed.size(), 1, "1 missed line")
	assert_equals(missed[0], 2, "Line 2 is missed")

func test_get_coverage_summary():
	print("\n--- Test: Get Coverage Summary ---")
	var Analyzer = load("res://coverage_analyzer.gd")
	
	var analysis = {
		"total_covered": 75,
		"total_lines": 100,
		"total_percent": 75.0,
		"files": [{}, {}]  # 2 files
	}
	
	var summary = Analyzer.get_coverage_summary(analysis)
	
	assert_true("75/100" in summary, "Summary contains coverage numbers")
	assert_true("75.0%" in summary, "Summary contains percentage")
	assert_true("Files: 2" in summary, "Summary contains file count")
