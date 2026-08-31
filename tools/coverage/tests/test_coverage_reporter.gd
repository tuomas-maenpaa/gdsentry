extends SceneTree

# Unit tests for Coverage Reporter
# Run with: godot --headless --script test_coverage_reporter.gd

var tests_passed = 0
var tests_failed = 0
var test_output_dir = "res://test_output/reporter/"

func _init():
	print("\n=== Coverage Reporter Unit Tests ===\n")
	
	# Setup
	setup_test_environment()
	
	# Run tests
	test_generate_summary_html_basic()
	test_generate_summary_html_empty()
	test_generate_file_html_basic()
	test_generate_file_slug()
	test_read_source_file()
	test_write_html_file()
	test_html_escape()
	test_coverage_class()
	test_bar_color()
	test_generate_html_report_complete()
	test_handle_missing_source()
	test_clickable_links()
	
	# Teardown
	teardown_test_environment()
	
	# Report
	print("\n=== Test Results ===")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("===================\n")
	
	quit(0 if tests_failed == 0 else 1)

func setup_test_environment():
	# Create test directories
	DirAccess.make_dir_recursive_absolute(test_output_dir)
	DirAccess.make_dir_recursive_absolute(test_output_dir + "source/")

func teardown_test_environment():
	# Clean up test files
	var dir = DirAccess.open(test_output_dir)
	if dir:
		_remove_directory_recursive(test_output_dir)

func _remove_directory_recursive(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir():
				_remove_directory_recursive(full_path)
			else:
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

func assert_contains(text: String, substring: String, message: String):
	if substring in text:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s (substring '%s' not found)" % [message, substring])
		tests_failed += 1

func assert_equals(actual, expected, message: String):
	if actual == expected:
		print("✓ PASS: %s" % message)
		tests_passed += 1
	else:
		print("✗ FAIL: %s (expected: %s, got: %s)" % [message, str(expected), str(actual)])
		tests_failed += 1

func test_generate_summary_html_basic():
	print("\n--- Test: Generate Summary HTML Basic ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var analysis = {
		"total_covered": 75,
		"total_lines": 100,
		"total_percent": 75.0,
		"files": [
			{
				"file": "test.gd",
				"covered": 75,
				"total": 100,
				"percent": 75.0,
				"missed_lines": []
			}
		]
	}
	
	var html = Reporter.generate_summary_html(analysis)
	
	assert_contains(html, "<!DOCTYPE html>", "Has DOCTYPE")
	assert_contains(html, "Coverage Report", "Has title")
	assert_contains(html, "75.0%", "Has percentage")
	assert_contains(html, "75 / 100", "Has line counts")
	assert_contains(html, "test.gd", "Has filename")

func test_generate_summary_html_empty():
	print("\n--- Test: Generate Summary HTML Empty ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var analysis = {
		"total_covered": 0,
		"total_lines": 0,
		"total_percent": 0.0,
		"files": []
	}
	
	var html = Reporter.generate_summary_html(analysis)
	
	assert_contains(html, "<!DOCTYPE html>", "Has DOCTYPE")
	assert_contains(html, "0.0%", "Has 0% coverage")

func test_generate_file_html_basic():
	print("\n--- Test: Generate File HTML Basic ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var file_info = {
		"file": "test.gd",
		"covered": 2,
		"total": 3,
		"percent": 66.67,
		"missed_lines": [2]
	}
	
	var line_data = {
		1: 5,
		2: 0,
		3: 10
	}
	
	var source_lines = [
		"var x = 1",
		"var y = 2",
		"var z = 3"
	]
	
	var html = Reporter.generate_file_html("test.gd", line_data, source_lines, file_info)
	
	assert_contains(html, "<!DOCTYPE html>", "Has DOCTYPE")
	assert_contains(html, "test.gd", "Has filename")
	assert_contains(html, "var x = 1", "Has source line 1")
	assert_contains(html, "var y = 2", "Has source line 2")
	assert_contains(html, "Back to Summary", "Has back link")
	assert_contains(html, "class='line hit'", "Has hit class")
	assert_contains(html, "class='line miss'", "Has miss class")

func test_generate_file_slug():
	print("\n--- Test: Generate File Slug ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var slug1 = Reporter._generate_file_slug("src/core/player.gd")
	assert_equals(slug1, "src_core_player_gd", "Converts path to slug")
	
	var slug2 = Reporter._generate_file_slug("test.gd")
	assert_equals(slug2, "test_gd", "Converts simple name")
	
	var slug3 = Reporter._generate_file_slug("a\\b\\c.gd")
	assert_equals(slug3, "a_b_c_gd", "Handles backslashes")

func test_read_source_file():
	print("\n--- Test: Read Source File ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	# Create test file
	var test_file_path = test_output_dir + "source/test.gd"
	var file = FileAccess.open(test_file_path, FileAccess.WRITE)
	file.store_string("line 1\nline 2\nline 3")
	file.close()
	
	var lines = Reporter._read_source_file(test_file_path)
	
	assert_equals(lines.size(), 3, "Read 3 lines")
	assert_equals(lines[0], "line 1", "First line correct")
	assert_equals(lines[1], "line 2", "Second line correct")

func test_write_html_file():
	print("\n--- Test: Write HTML File ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var test_path = test_output_dir + "test.html"
	var content = "<html><body>Test</body></html>"
	
	var success = Reporter.write_html_file(test_path, content)
	
	assert_true(success, "Write succeeds")
	assert_true(FileAccess.file_exists(test_path), "File created")
	
	var file = FileAccess.open(test_path, FileAccess.READ)
	var read_content = file.get_as_text()
	file.close()
	
	assert_equals(read_content, content, "Content matches")

func test_html_escape():
	print("\n--- Test: HTML Escape ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var escaped = Reporter._html_escape("<script>alert('xss')</script>")
	assert_contains(escaped, "&lt;script&gt;", "Escapes < and >")
	assert_contains(escaped, "&#39;", "Escapes single quotes")
	
	var escaped2 = Reporter._html_escape("a & b")
	assert_contains(escaped2, "&amp;", "Escapes ampersand")

func test_coverage_class():
	print("\n--- Test: Coverage Class ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	assert_equals(Reporter._get_coverage_class(90.0), "good", "High coverage is good")
	assert_equals(Reporter._get_coverage_class(60.0), "ok", "Medium coverage is ok")
	assert_equals(Reporter._get_coverage_class(30.0), "bad", "Low coverage is bad")

func test_bar_color():
	print("\n--- Test: Bar Color ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	assert_equals(Reporter._get_bar_color(90.0), "#28a745", "High coverage is green")
	assert_equals(Reporter._get_bar_color(60.0), "#ffc107", "Medium coverage is yellow")
	assert_equals(Reporter._get_bar_color(30.0), "#dc3545", "Low coverage is red")

func test_generate_html_report_complete():
	print("\n--- Test: Generate Complete HTML Report ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	# Create source file
	var source_path = test_output_dir + "source/test.gd"
	var file = FileAccess.open(source_path, FileAccess.WRITE)
	file.store_string("var x = 1\nvar y = 2\nvar z = 3")
	file.close()
	
	var analysis = {
		"total_covered": 2,
		"total_lines": 3,
		"total_percent": 66.67,
		"files": [
			{
				"file": "test.gd",
				"covered": 2,
				"total": 3,
				"percent": 66.67,
				"missed_lines": [2]
			}
		]
	}
	
	var output_dir = test_output_dir + "html/"
	var success = Reporter.generate_html_report(analysis, test_output_dir + "source", output_dir)
	
	assert_true(success, "Report generation succeeds")
	assert_true(FileAccess.file_exists(output_dir + "index.html"), "Summary HTML created")
	assert_true(FileAccess.file_exists(output_dir + "test_gd.html"), "File HTML created")

func test_handle_missing_source():
	print("\n--- Test: Handle Missing Source ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var lines = Reporter._read_source_file("nonexistent.gd")
	assert_equals(lines.size(), 0, "Returns empty array for missing file")

func test_clickable_links():
	print("\n--- Test: Clickable Links ---")
	var Reporter = load("res://coverage_reporter.gd")
	
	var analysis = {
		"total_covered": 1,
		"total_lines": 1,
		"total_percent": 100.0,
		"files": [
			{
				"file": "test.gd",
				"covered": 1,
				"total": 1,
				"percent": 100.0,
				"missed_lines": []
			}
		]
	}
	
	var html = Reporter.generate_summary_html(analysis)
	
	# Should have clickable link to file detail
	assert_contains(html, "href='test_gd.html'", "Has link to file detail")
	assert_contains(html, "<a href=", "Has anchor tag")
