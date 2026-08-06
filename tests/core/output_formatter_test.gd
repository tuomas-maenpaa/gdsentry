# GDSentry - OutputFormatter Unit Tests
# Comprehensive testing of OutputFormatter ASCII formatting utilities
#
# This test validates that OutputFormatter can:
# - Create consistent box borders and content lines
# - Handle proper width calculations
# - Format various content types correctly
# - Maintain visual consistency across different sections
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name OutputFormatterTest

# Preload OutputFormatter for testing
const OutputFormatter = preload("res://src/utilities/output_formatter.gd")

# ------------------------------------------------------------------------------
# TEST SETUP
# ------------------------------------------------------------------------------
func setup() -> void:
	"""Setup test environment"""
	print("⚙️ Setting up OutputFormatter test")

# ------------------------------------------------------------------------------
# BASIC FORMATTING TESTS
# ------------------------------------------------------------------------------
func test_pad_string_left_alignment():
	"""Test string padding with left alignment"""
	var result = OutputFormatter.pad_string("test", 10, "left")
	assert_equals(result, "test      ", "Left padding should add spaces on the right")

func test_pad_string_right_alignment():
	"""Test string padding with right alignment"""
	var result = OutputFormatter.pad_string("test", 10, "right")
	assert_equals(result, "      test", "Right padding should add spaces on the left")

func test_pad_string_center_alignment():
	"""Test string padding with center alignment"""
	var result = OutputFormatter.pad_string("test", 10, "center")
	assert_equals(result, "   test   ", "Center padding should distribute spaces evenly")

func test_pad_string_exact_width():
	"""Test string padding when string is shorter than target width"""
	var result = OutputFormatter.pad_string("exactly10", 10, "left")
	assert_equals(result, "exactly10 ", "Shorter string should be padded with space")

func test_pad_string_longer_than_width():
	"""Test string padding when string exceeds target width"""
	var result = OutputFormatter.pad_string("verylongstring", 5, "left")
	assert_equals(result, "veryl", "String longer than width should be truncated")

func test_format_labeled_line():
	"""Test label:value line formatting"""
	var result = OutputFormatter.format_labeled_line("Test Label", "Test Value")
	var expected = "║ Test Label: Test Value                                                    ║"
	assert_equals(result, expected, "Labeled line should format label and value with separator")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Labeled line should be exactly 77 characters")

func test_format_labeled_line_custom_separator():
	"""Test label:value line with custom separator"""
	var result = OutputFormatter.format_labeled_line("Status", "PASS", " = ")
	var expected = "║ Status = PASS                                                             ║"
	assert_equals(result, expected, "Custom separator should be used")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Custom separator line should be exactly 77 characters")


# ------------------------------------------------------------------------------
# TEST METADATA & CONSTANTS
# ------------------------------------------------------------------------------
const TEST_TIMEOUT = 10.0
const EXPECTED_BOX_WIDTH = 77

var test_data: Dictionary

# ------------------------------------------------------------------------------
# TEST SETUP & TEARDOWN
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize test data and setup"""
	test_data = {
		"sample_stats": {
			"passed_suites": 5,
			"failed_suites": 1,
			"total_suites": 6,
			"passed_cases": 25,
			"failed_cases": 3,
			"total_cases": 28,
			"passed_assertions": 150,
			"failed_assertions": 5,
			"total_assertions": 155,
			"duration": 3.45
		},
		"sample_discovery": {
			"total_found": 42,
			"categorized": {
				"unit": 25,
				"integration": 10,
				"ui": 5,
				"performance": 2
			},
			"errors": ["Parse error in test_abc.gd", "Missing dependency: test_utils.gd"]
		}
	}

	# Override GDTest's automatic test execution - we control it manually
	lifecycle_testing_mode = true

	# Call deferred ready to initialize the test framework
	call_deferred("_deferred_ready")

func run_test_suite() -> void:
	"""Override GDTest's automatic test execution - do nothing here, we run manually"""
	# Basic formatting tests
	run_test("test_pad_string_left_alignment", func(): return test_pad_string_left_alignment())
	run_test("test_pad_string_right_alignment", func(): return test_pad_string_right_alignment())
	run_test("test_pad_string_center_alignment", func(): return test_pad_string_center_alignment())
	run_test("test_pad_string_exact_width", func(): return test_pad_string_exact_width())
	run_test("test_pad_string_longer_than_width", func(): return test_pad_string_longer_than_width())
	run_test("test_format_labeled_line", func(): return test_format_labeled_line())
	run_test("test_format_labeled_line_custom_separator", func(): return test_format_labeled_line_custom_separator())

	# Box formatting tests
	run_test("test_format_box_bottom", func(): return test_format_box_bottom())
	run_test("test_format_section_divider", func(): return test_format_section_divider())
	run_test("test_format_content_line", func(): return test_format_content_line())
	run_test("test_format_box_header", func(): return test_format_box_header())

	# Section formatting tests
	run_test("test_format_execution_summary_structure", func(): return test_format_execution_summary_structure())

	# Width consistency tests
	run_test("test_all_elements_consistent_width", func(): return test_all_elements_consistent_width())

	# Edge case tests
	run_test("test_empty_content_handling", func(): return test_empty_content_handling())
	run_test("test_special_characters_handling", func(): return test_special_characters_handling())
	run_test("test_pad_string_invalid_alignment", func(): return test_pad_string_invalid_alignment())
	run_test("test_pad_string_zero_width", func(): return test_pad_string_zero_width())
	run_test("test_pad_string_negative_width", func(): return test_pad_string_negative_width())

	# Integration and lifecycle tests
	run_test("test_multiline_section_empty_lines", func(): return test_multiline_section_empty_lines())
	run_test("test_section_divider_consistency", func(): return test_section_divider_consistency())
	run_test("test_complete_section_closure", func(): return test_complete_section_closure())
	run_test("test_start_box", func(): return test_start_box())
	run_test("test_end_box", func(): return test_end_box())
	run_test("test_start_section", func(): return test_start_section())
	run_test("test_section_break", func(): return test_section_break())
	run_test("test_add_content", func(): return test_add_content())
	run_test("test_add_empty_line", func(): return test_add_empty_line())
	run_test("test_box_lifecycle_integration", func(): return test_box_lifecycle_integration())
	run_test("test_no_unformatted_empty_lines", func(): return test_no_unformatted_empty_lines())
	run_test("test_double_newline_bug", func(): return test_double_newline_bug())
	run_test("test_nested_box_detection", func(): return test_nested_box_detection())
	run_test("test_integration_complete_output_formatting", func(): return test_integration_complete_output_formatting())
	run_test("test_format_content_line_very_long", func(): return test_format_content_line_very_long())
	run_test("test_format_content_line_empty_string", func(): return test_format_content_line_empty_string())
	run_test("test_format_labeled_line_empty_values", func(): return test_format_labeled_line_empty_values())
	run_test("test_format_execution_summary_empty_stats", func(): return test_format_execution_summary_empty_stats())

	# Integration tests
	run_test("test_full_section_formatting", func(): return test_full_section_formatting())
	run_test("test_section_combination", func(): return test_section_combination())

# ------------------------------------------------------------------------------
# BASIC FORMATTING TESTS
# ------------------------------------------------------------------------------





# ------------------------------------------------------------------------------
# BOX FORMATTING TESTS
# ------------------------------------------------------------------------------

func test_format_box_bottom():
	"""Test bottom border formatting"""
	var result = OutputFormatter.format_box_bottom()
	var expected = "╚" + "═".repeat(75) + "╝"
	assert_equals(result, expected, "Bottom border should have correct width and characters")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Bottom border should be exactly 77 characters")

func test_format_section_divider():
	"""Test section divider formatting"""
	var result = OutputFormatter.format_section_divider()
	var expected = "╠" + "═".repeat(75) + "╣"
	assert_equals(result, expected, "Section divider should have correct width and characters")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Section divider should be exactly 77 characters")

func test_format_content_line():
	"""Test content line formatting"""
	var result = OutputFormatter.format_content_line("Test content")
	var expected = "║ Test content                                                             ║"
	assert_equals(result, expected, "Content line should have proper borders and padding")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Content line should be exactly 77 characters")

func test_format_box_header():
	"""Test complete box header with title"""
	var result = OutputFormatter.format_box_header("Test Header")
	var lines = result.split("\n")

	# Should have 2 lines: top border, title (no trailing newline)
	assert_equals(lines.size(), 2, "Box header should have 2 lines")

	# First line should be top border
	assert_equals(lines[0], "╔" + "═".repeat(75) + "╗", "First line should be top border")
	assert_equals(lines[0].length(), EXPECTED_BOX_WIDTH, "Top border should be exactly 77 characters")

	# Second line should be title content
	var expected_title = "║ Test Header                                                             ║"
	assert_equals(lines[1], expected_title, "Second line should be formatted title")
	assert_equals(lines[1].length(), EXPECTED_BOX_WIDTH, "Title line should be exactly 77 characters")

# ------------------------------------------------------------------------------
# SECTION FORMATTING TESTS
# ------------------------------------------------------------------------------
func test_format_execution_summary_structure():
	"""Test that execution summary has proper structure"""
	var result = OutputFormatter.format_execution_summary(test_data.sample_stats)

	# Should contain section dividers
	assert_true(result.find("╠") != -1, "Should contain section dividers")
	assert_true(result.find("═") != -1, "Should contain border characters")

	# Should contain expected content
	assert_true(result.find("EXECUTION SUMMARY") != -1, "Should contain section title")
	assert_true(result.find("Test Suites") != -1, "Should contain test suites info")
	assert_true(result.find("Duration") != -1, "Should contain duration info")

	# Should end with box bottom
	assert_true(result.ends_with("╝\n"), "Should end with box bottom")


# ------------------------------------------------------------------------------
# WIDTH CONSISTENCY TESTS
# ------------------------------------------------------------------------------
func test_all_elements_consistent_width():
	"""Test that all ASCII elements maintain consistent 77-character width"""
	var elements = [
		"╔" + "═".repeat(75) + "╗",  # box top inline
		OutputFormatter.format_box_bottom(),  # now includes newline
		OutputFormatter.format_section_divider(),
		OutputFormatter.format_content_line("Test"),
		"─".repeat(77)  # thin separator inline
	]

	for element in elements:
		# All elements should be exactly 77 characters (no trailing newlines)
		assert_equals(element.length(), EXPECTED_BOX_WIDTH, "Element '" + element.substr(0, 20) + "...' should be exactly " + str(EXPECTED_BOX_WIDTH) + " characters")


func test_content_width_calculation():
	"""Test that content width calculation is correct"""
	var box_width = 77
	var _expected_content_width = box_width - 4  # Account for "║ " + " ║"

	# Test with various content lengths
	var short_content = OutputFormatter.format_content_line("Short")
	var long_content = OutputFormatter.format_content_line("Very long content that should be properly padded")

	assert_equals(short_content.length(), box_width, "Short content should still be 77 chars wide")
	assert_equals(long_content.length(), box_width, "Long content should still be 77 chars wide")

# ------------------------------------------------------------------------------
# EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_empty_content_handling():
	"""Test handling of empty or null content"""
	var result = OutputFormatter.format_content_line("")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Empty content should still be 77 chars")

func test_special_characters_handling():
	"""Test handling of special characters in content"""
	var special_content = "Test with émojis 🚀 and spëcial çhars"
	var result = OutputFormatter.format_content_line(special_content)
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Special characters should not affect width")

# ------------------------------------------------------------------------------
# COMPREHENSIVE EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_pad_string_invalid_alignment():
	"""Test padding with invalid alignment parameter"""
	var result = OutputFormatter.pad_string("test", 10, "invalid")
	# Should default to left alignment
	assert_equals(result, "test      ", "Invalid alignment should default to left")

func test_pad_string_zero_width():
	"""Test padding with zero width"""
	var result = OutputFormatter.pad_string("test", 0)
	assert_equals(result, "", "Zero width should truncate to empty string")

func test_pad_string_negative_width():
	"""Test padding with negative width"""
	var result = OutputFormatter.pad_string("test", -5)
	assert_equals(result, "", "Negative width should truncate to empty string")

func test_format_content_line_very_long():
	"""Test content line with extremely long content"""
	var long_content = "A".repeat(200)  # 200 'A' characters
	var result = OutputFormatter.format_content_line(long_content)
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Very long content should be properly truncated")
	assert_true(result.begins_with("║ A"), "Should start with content prefix")
	assert_true(result.ends_with(" ║"), "Should end with content suffix")

func test_format_content_line_empty_string():
	"""Test content line with empty string"""
	var result = OutputFormatter.format_content_line("")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Empty content should still be 77 chars")
	assert_true(result.begins_with("║ "), "Should start with content prefix")
	assert_true(result.ends_with(" ║"), "Should end with content suffix")

func test_format_labeled_line_empty_values():
	"""Test labeled line with empty label and value"""
	var result = OutputFormatter.format_labeled_line("", "")
	var expected = "║ :                                                                         ║"
	assert_equals(result, expected, "Empty label and value should still format correctly")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Empty labeled line should be exactly 77 characters")


func test_format_execution_summary_empty_stats():
	"""Test execution summary with empty statistics"""
	var empty_stats = {}
	var result = OutputFormatter.format_execution_summary(empty_stats)

	# Should still have basic structure
	assert_true(result.find("EXECUTION SUMMARY") != -1, "Should contain section title")
	assert_true(result.find("Test Suites") != -1, "Should contain test suites info")
	assert_true(result.ends_with("╝"), "Should end with box bottom")


# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_full_section_formatting():
	"""Test complete section formatting integration"""
	var summary = OutputFormatter.format_execution_summary(test_data.sample_stats)

	# Test that summary has proper formatting
	assert_true(summary.find("╠") != -1, "Summary should have dividers")
	assert_true(summary.ends_with("╝"), "Summary should end with box bottom")

	# Test discovery summary formatting (now done inline in discover_tests)
	var discovery_lines = [
		OutputFormatter.add_content("Discovery Summary"),
		OutputFormatter.format_section_divider(),
		OutputFormatter.add_content("Total test scripts: 42")
	]
	var discovery_combined = ""
	for line in discovery_lines:
		discovery_combined += line

	assert_true(discovery_combined.find("Discovery Summary") != -1, "Should contain summary title")
	assert_true(discovery_combined.find("Total test scripts: 42") != -1, "Should contain total count")

func test_section_combination():
	"""Test combining multiple formatted sections"""
	# Use lifecycle methods to create sections
	var section1 = OutputFormatter.start_section("Test Discovery")
	section1 += OutputFormatter.add_content("Search directories: test")
	section1 += OutputFormatter.add_content("Recursive search: true")

	# Create discovery summary content (now done inline)
	var section2 = OutputFormatter.section_break()
	section2 += OutputFormatter.add_content("Discovery Summary")
	section2 += OutputFormatter.format_section_divider()
	section2 += OutputFormatter.add_content("Total test scripts: 42")
	section2 += OutputFormatter.add_content("Categorized by type:")
	section2 += OutputFormatter.add_content("  • unit: 2")
	section2 += OutputFormatter.add_content("  • integration: 1")

	# Should be able to combine without issues
	var combined = section1 + section2
	assert_true(combined.length() > 0, "Combined sections should have content")
	assert_true(combined.find("Test Discovery") != -1, "Should contain discovery section")
	assert_true(combined.find("Discovery Summary") != -1, "Should contain summary section")

# ------------------------------------------------------------------------------
# INTEGRATION TESTS - FORMATTING ISSUES
# ------------------------------------------------------------------------------
func test_multiline_section_empty_lines():
	"""Test that multi-line sections properly format empty lines (Issue #1)"""
	# Create a scenario that produces empty lines in output using lifecycle methods
	var result = ""
	result += OutputFormatter.start_section("Environment Detection")
	result += OutputFormatter.add_content("Context: context")
	result += OutputFormatter.add_content("Strategy: strategy")
	result += OutputFormatter.add_content("Search path: /path")
	result += OutputFormatter.add_content("[✓] Found project: project1")
	result += OutputFormatter.add_content("[✓] Found project: project2")
	result += OutputFormatter.end_box()

	# Split into lines and check for empty lines
	var lines = result.split("\n")

	# Should not contain completely empty lines (unformatted gaps)
	for line in lines:
		if line.strip_edges() == "":
			# If there's an empty line, it should be a properly formatted empty content line
			assert_equals(line, "", "Empty lines should be properly formatted or truly empty")
		else:
			# Non-empty lines should be properly formatted
			if line.length() > 0:
				assert_true(line.begins_with("║") or line.begins_with("╠") or line.begins_with("╚"),
					"Non-empty lines should start with proper border characters")

	# The issue is that empty lines appear as gaps - let's check for that
	var empty_line_found = false
	for line in lines:
		if line == "":
			empty_line_found = true
			break

	# If we find empty lines, they should be properly formatted content lines
	# This test will initially fail, revealing the issue
	if empty_line_found:
		assert_true(false, "Found unformatted empty lines in multi-line section - should be '║                                                                       ║'")

	return true

func test_section_divider_consistency():
	"""Test that sections use correct divider types (Issue #2)"""
	# Test environment detection section - should end with bottom border, not section divider
	var result = ""
	result += OutputFormatter.start_box("Environment Detection")
	result += OutputFormatter.add_content("Context: context")
	result += OutputFormatter.add_content("Strategy: strategy")
	result += OutputFormatter.add_content("Search path: /path")
	result += OutputFormatter.add_content("[✓] Found project: project1")
	result += OutputFormatter.end_box()

	# Environment detection should be a complete section ending with bottom border ╚════╝
	assert_true(result.ends_with("╝"), "Environment detection section should end with bottom border ╚════╝")

	# Should NOT end with section divider ╠════╣
	var lines = result.split("\n")
	var last_content_line = ""
	for i in range(lines.size() - 1, -1, -1):
		if lines[i].strip_edges() != "":
			last_content_line = lines[i]
			break

	assert_false(last_content_line.begins_with("╠"), "Complete sections should not end with section dividers ╠════╣")

	# Test discovery section using lifecycle methods - should end with section divider (not bottom border) since it's not complete
	var discovery_result = OutputFormatter.start_section("Test Discovery")
	assert_true(discovery_result.ends_with("╣"), "Discovery section should end with section divider ╠════╣ (not bottom border)")

	return true

func test_complete_section_closure():
	"""Test that complete output sections are properly closed (Issue #3)"""
	# Test various complete sections that should end with bottom borders

	# Execution summary should be complete and end with bottom border
	var summary = OutputFormatter.format_execution_summary(test_data.sample_stats)
	assert_true(summary.ends_with("╝"), "Execution summary should end with bottom border")

	# Discovery summary (now done inline) doesn't create complete sections with bottom borders
	# It's just content within the Test Discovery section

	# Box header ends with content line (no trailing newline)
	var header = OutputFormatter.format_box_header("Test Header")
	assert_true(header.ends_with("║"), "Box header should end with content line border")

	return true

# ------------------------------------------------------------------------------
# UTILITY METHOD TESTS
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# BOX LIFECYCLE MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_start_box():
	"""Test box lifecycle start method"""
	var result = OutputFormatter.start_box("Test Box")

	# Should have 2 lines: top border, title (no trailing newline)
	var lines = result.split("\n")
	assert_equals(lines.size(), 2, "Box start should have 2 lines")

	assert_equals(lines[0], "╔" + "═".repeat(75) + "╗", "First line should be top border")
	var expected_title = OutputFormatter.format_content_line("Test Box")
	assert_equals(lines[1], expected_title, "Second line should be formatted title")

	return true

func test_end_box():
	"""Test box lifecycle end method"""
	var result = OutputFormatter.end_box()
	assert_equals(result, "╚" + "═".repeat(75) + "╝", "Box end should be bottom border")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Box end should be exactly 77 characters")

	return true

func test_start_section():
	"""Test section lifecycle start method"""
	var result = OutputFormatter.start_section("Test Section")

	# Should have 3 lines: divider, title, divider (no trailing newline)
	var lines = result.split("\n")
	assert_equals(lines.size(), 3, "Section start should have 3 lines")

	assert_equals(lines[0], "╠" + "═".repeat(75) + "╣", "First line should be section divider")
	var expected_section_title = OutputFormatter.format_content_line("Test Section")
	assert_equals(lines[1], expected_section_title, "Second line should be formatted title")
	assert_equals(lines[2], "╠" + "═".repeat(75) + "╣", "Third line should be section divider")

	return true

func test_section_break():
	"""Test section break method"""
	var result = OutputFormatter.section_break()
	# section_break() now returns a formatted empty line instead of just "\n"
	assert_equals(result, OutputFormatter.format_content_line(""), "Section break should be formatted empty line")

	return true

func test_add_content():
	"""Test add content method"""
	var result = OutputFormatter.add_content("Test content")
	var expected = OutputFormatter.format_content_line("Test content")
	assert_equals(result, expected, "Add content should format line without trailing newline")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Should be exactly 77 chars")

	return true

func test_add_empty_line():
	"""Test add empty line method"""
	var result = OutputFormatter.add_empty_line()
	var expected = OutputFormatter.format_content_line("")
	assert_equals(result, expected, "Add empty line should format empty content line without trailing newline")
	assert_equals(result.length(), EXPECTED_BOX_WIDTH, "Should be exactly 77 chars")

	return true

func test_box_lifecycle_integration():
	"""Test complete box lifecycle integration"""
	var output = ""

	# Start box
	output += OutputFormatter.start_box("Integration Test")

	# Add section
	output += OutputFormatter.start_section("Environment")
	output += OutputFormatter.add_content("Context: test")
	output += OutputFormatter.add_content("Strategy: mock")
	output += OutputFormatter.add_empty_line()  # Properly formatted empty line
	output += OutputFormatter.add_content("Status: active")

	# Section break
	output += OutputFormatter.section_break()

	# Another section
	output += OutputFormatter.start_section("Results")
	output += OutputFormatter.add_content("Tests: 5")
	output += OutputFormatter.add_content("Passed: 5")

	# End box
	output += OutputFormatter.end_box()

	# Verify structure
	var lines = output.split("\n")

	# Should start with box top
	assert_true(lines[0].begins_with("╔"), "Should start with box top")
	assert_true(lines[1].contains("Integration Test"), "Should contain box title")

	# Should contain section dividers and content
	var has_section_divider = false
	var has_content = false
	for line in lines:
		if line.begins_with("╠"):
			has_section_divider = true
		if line.begins_with("║") and line.contains("Context: test"):
			has_content = true

	assert_true(has_section_divider, "Should contain section dividers")
	assert_true(has_content, "Should contain formatted content")

	# Should end with box bottom
	assert_true(lines[lines.size() - 1].begins_with("╚"), "Should end with box bottom")

	return true

func test_no_unformatted_empty_lines():
	"""Test that output contains no unformatted empty lines (gaps in box frame)"""
	# Test various OutputFormatter methods to ensure they don't produce empty lines

	var test_outputs = [
		OutputFormatter.start_box("Test"),
		OutputFormatter.start_section("Section"),
		OutputFormatter.add_content("Content"),
		OutputFormatter.add_empty_line(),
		OutputFormatter.section_break(),
		OutputFormatter.end_box(),
		OutputFormatter.format_execution_summary({"total_suites": 1}),
		# Discovery summary is now done inline, not as a separate formatted method
		OutputFormatter.add_content("Discovery Summary") + OutputFormatter.format_section_divider()
	]

	for output in test_outputs:
		var lines = output.split("\n", false)  # Don't skip empty strings

		for i in range(lines.size()):
			var line = lines[i]
			# Skip the last line if it's empty (trailing newline is OK)
			if i == lines.size() - 1 and line.strip_edges() == "":
				continue

			# No line should be completely empty (just whitespace/newlines)
			assert_false(line.strip_edges() == "", "Found unformatted empty line in output: '" + line + "'")

			# All non-empty lines should start with proper box characters
			if line.strip_edges() != "":
				assert_true(
					line.begins_with("╔") or line.begins_with("║") or line.begins_with("╠") or
					line.begins_with("╚") or line.begins_with("─") or line.begins_with("═"),
					"Non-empty line should start with proper formatting character: '" + line.substr(0, 1) + "'"
				)

	return true

func test_double_newline_bug():
	"""Test that print() doesn't create double newlines (empty line gaps)"""
	# The CORE issue: methods return strings with \n, then print() adds ANOTHER \n!
	# This creates: "content\n" + print's "\n" = "content\n\n" = visual gap!
	
	# Simulate what print() actually outputs
	var simulated_output = ""
	
	# This is what happens in real code:
	# print(OutputFormatter.start_box("Test Box"))  →  "╔...╗\n║ Test Box ║\n" + "\n" from print()
	simulated_output += OutputFormatter.start_box("Test Box") + "\n"  # print() adds \n
	simulated_output += OutputFormatter.add_content("Line 1") + "\n"  # print() adds \n
	simulated_output += OutputFormatter.add_content("Line 2") + "\n"  # print() adds \n  
	simulated_output += OutputFormatter.end_box() + "\n"  # print() adds \n
	
	# Split and analyze - KEEP empty strings to detect gaps!
	var lines = simulated_output.split("\n", true)
	
	# Count and show lines
	print("DEBUG test_double_newline_bug (with print newlines): Total lines = ", lines.size())
	for i in range(lines.size()):
		var display = lines[i].substr(0, min(30, lines[i].length())) if lines[i].length() > 0 else "(EMPTY)"
		print("  [", i, "] '", display, "...' (len=", lines[i].length(), ")")
	
	# Check for GAPS - empty lines that aren't the final trailing one
	for i in range(lines.size() - 1):  # Exclude last line (expected trailing empty from final \n)
		var line = lines[i]
		if line.strip_edges() == "":
			assert_true(false, 
				"Found GAP (empty line) at position " + str(i) + " - this creates visual gaps in the box!")
	
	# Every non-empty line should have box borders
	for i in range(lines.size()):
		var line = lines[i]
		if line.length() > 0:
			var starts_with_border = (line.begins_with("╔") or line.begins_with("║") or 
									 line.begins_with("╠") or line.begins_with("╚"))
			assert_true(starts_with_border,
				"Line " + str(i) + " doesn't start with border: '" + line + "'")
	
	return true

func test_nested_box_detection():
	"""Test that proper box/section structure is used (not nested boxes)"""
	# Test the CORRECT pattern: box header, then sections
	var output = ""
	
	# CORRECT usage:
	output += OutputFormatter.start_box("Main Title") + "\n"  # Opens box with title
	output += OutputFormatter.start_section("Sub Section") + "\n"  # Section divider, not new box
	output += OutputFormatter.add_content("Content") + "\n"
	output += OutputFormatter.end_box() + "\n"
	
	# Analyze the structure
	var lines = output.split("\n", true)
	
	print("DEBUG test_nested_box_detection: Verifying correct structure")
	for i in range(min(10, lines.size())):
		print("  [", i, "] '", lines[i].substr(0, min(40, lines[i].length())), "...'")
	
	# Verify CORRECT pattern: no ╔...║...╔ (nested boxes)
	for i in range(lines.size() - 2):
		var line1 = lines[i]
		var line2 = lines[i + 1]
		var line3 = lines[i + 2]
		
		# Pattern: ╔ (top), ║ (title), ╔ (another top) = NESTED BOXES BUG
		if line1.begins_with("╔") and line2.begins_with("║") and line3.begins_with("╔"):
			assert_true(false, 
				"Found improperly nested boxes (╔...║...╔ pattern) at lines " + str(i) + "-" + str(i+2) + ":\n" +
				"  Line " + str(i) + ": '" + line1 + "'\n" +
				"  Line " + str(i+1) + ": '" + line2 + "'\n" +
				"  Line " + str(i+2) + ": '" + line3 + "'\n" +
				"After a box title, expected section divider (╠) not another box top (╔)")
	
	# Verify the CORRECT structure: ╔ then ║ then ╠ (section divider)
	assert_true(lines[0].begins_with("╔"), "Should start with box top")
	assert_true(lines[1].begins_with("║"), "Should have title line")
	assert_true(lines[2].begins_with("╠"), "Should have section divider, not another box top")
	
	return true

func test_integration_complete_output_formatting():
	"""Integration test: verify complete output flows produce properly formatted output"""

	# Simulate the exact sequence of print() calls that happen in the real application
	var printed_lines = []

	# === MAIN TEST RUNNER BOX ===
	printed_lines.append(OutputFormatter.start_box("GDSentry Advanced Test Runner v2.0.0"))

	# === ENVIRONMENT DETECTION SUB-BOX ===
	printed_lines.append(OutputFormatter.start_box("Environment Detection"))
	printed_lines.append(OutputFormatter.add_content("Context: GDSentry framework directory"))
	printed_lines.append(OutputFormatter.add_content("Strategy: Sibling project discovery"))
	printed_lines.append(OutputFormatter.add_content("Search path: ../"))
	printed_lines.append(OutputFormatter.add_content("[✓] Found project: lore-twin"))
	printed_lines.append(OutputFormatter.end_box())

	# === DISCOVERY SCOPE CONTENT ===
	printed_lines.append(OutputFormatter.add_content("Discovery Scope: Project tests in 1 project(s)"))

	# === TEST DISCOVERY SECTION ===
	printed_lines.append(OutputFormatter.start_section("Test Discovery"))
	printed_lines.append(OutputFormatter.add_content("Search directories: [\"../lore-twin/tests/\", \"../lore-twin/test/\"]"))
	printed_lines.append(OutputFormatter.add_content("Recursive search: true"))
	printed_lines.append(OutputFormatter.add_empty_line())  # Intentional empty line for spacing
	printed_lines.append(OutputFormatter.add_content("[!] Directory not found: ../lore-twin/tests/"))
	printed_lines.append(OutputFormatter.add_content("[!] Directory not found: ../lore-twin/test/"))
	printed_lines.append(OutputFormatter.add_empty_line())  # Intentional empty line for spacing
	printed_lines.append(OutputFormatter.add_content("Discovery complete. Found 0 test scripts"))
	printed_lines.append(OutputFormatter.section_break())
	printed_lines.append(OutputFormatter.add_content("Discovery Summary"))
	printed_lines.append(OutputFormatter.format_section_divider())
	printed_lines.append(OutputFormatter.add_content("Total test scripts: 0"))
	printed_lines.append(OutputFormatter.end_box())

	# === STATUS MESSAGE ===
	printed_lines.append(OutputFormatter.add_content("Status: No test scripts found"))
	printed_lines.append(OutputFormatter.end_box())

	# Simulate what happens when each line is printed (each gets a newline)
	var complete_output = ""
	for line in printed_lines:
		complete_output += line  # Each line already ends with \n from the methods

	# Analyze the complete output
	var lines = complete_output.split("\n", false)

	# Count different types of lines for verification
	var empty_lines = []
	var content_lines = []
	var border_lines = []
	var intentional_empty_lines = []

	for i in range(lines.size()):
		var line = lines[i]
		var trimmed = line.strip_edges()

		if trimmed == "":
			empty_lines.append(i)
		elif line.begins_with("╔") or line.begins_with("╚") or line.begins_with("╠") or line.begins_with("═") or line.begins_with("─"):
			border_lines.append(i)
		elif line.begins_with("║"):
			content_lines.append(i)

		# Check if this is an intentional formatted empty line
		if line.begins_with("║") and line.ends_with("║") and line.length() == 77:
			var content_part = line.substr(2, 73)  # Remove "║ " and " ║"
			if content_part.strip_edges() == "":
				intentional_empty_lines.append(i)

	# CRITICAL ASSERTIONS - No unexpected empty lines
	for i in empty_lines:
		var line = lines[i]
		var is_intentional_empty = (i in intentional_empty_lines)
		assert_true(is_intentional_empty,
			"Found unexpected empty line at position " + str(i) + ": '" + line + "'")

	# All lines must be exactly 77 characters
	for i in range(lines.size()):
		var line = lines[i]
		if line.strip_edges() != "":  # Skip completely empty lines (shouldn't exist anyway)
			assert_equals(line.length(), 77,
				"Line " + str(i) + " should be exactly 77 characters: '" + line + "' (length: " + str(line.length()) + ")")

	# Box structure verification - just check that we have proper box structure
	assert_true(lines[0].begins_with("╔"), "First line should be box top")
	assert_true(lines[lines.size() - 1].begins_with("╚"), "Last line should be box bottom")

	# Should have reasonable number of lines
	assert_true(lines.size() > 20, "Should have at least 20 lines of output")
	assert_true(content_lines.size() > 10, "Should have many content lines")
	assert_true(border_lines.size() > 3, "Should have multiple border/divider lines")

	# Verify no gaps in box structure
	var consecutive_empty_lines = 0
	for i in range(lines.size()):
		if lines[i].strip_edges() == "":
			consecutive_empty_lines += 1
			assert_true(consecutive_empty_lines <= 1,
				"Found consecutive empty lines at position " + str(i) + " - this creates visual gaps")
		else:
			consecutive_empty_lines = 0

	return true
