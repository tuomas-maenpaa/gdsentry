# GDSentry - Output Formatting System
# Centralized ASCII visualization and formatting utilities
#
# Provides consistent, reusable formatting for all GDSentry output
# Supports multiple output formats and styling options
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name OutputFormatter

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------

const BOX_WIDTH = 77
const CONTENT_WIDTH = BOX_WIDTH - 4  # Account for "║ " + " ║" borders

# ------------------------------------------------------------------------------
# STRING UTILITIES
# ------------------------------------------------------------------------------

static func pad_string(text: String, width: int, align: String = "left") -> String:
	"""Pad string to specified width with spaces"""
	if text.length() > width:
		return text.substr(0, width)  # Truncate if longer than width

	var padding = width - text.length()
	var spaces = " ".repeat(padding)

	match align:
		"left":
			return text + spaces
		"right":
			return spaces + text
		"center":
			var left_padding = int(padding / 2.0)
			var right_padding = padding - left_padding
			return " ".repeat(left_padding) + text + " ".repeat(right_padding)

	return text + spaces

# ------------------------------------------------------------------------------
# ASCII FORMATTING - HEADERS AND BORDERS
# ------------------------------------------------------------------------------

static func format_box_bottom() -> String:
	"""Create bottom border for ASCII box"""
	return "╚" + "═".repeat(BOX_WIDTH - 2) + "╝"

static func format_box_header(title: String) -> String:
	"""Create complete box header with title - returns multi-line string"""
	var result = "╔" + "═".repeat(BOX_WIDTH - 2) + "╗\n"
	result += format_content_line(title)
	return result

static func format_section_divider() -> String:
	"""Create section divider line"""
	return "╠" + "═".repeat(BOX_WIDTH - 2) + "╣"

# ------------------------------------------------------------------------------
# ASCII FORMATTING - CONTENT LINES
# ------------------------------------------------------------------------------

static func format_content_line(content: String) -> String:
	"""Create a formatted content line"""
	var padded_content = pad_string(content, CONTENT_WIDTH)
	return "║ " + padded_content + " ║"

static func format_labeled_line(label: String, value: String, separator: String = ": ") -> String:
	"""Create a formatted label:value line"""
	var combined = label + separator + value
	return format_content_line(combined)


# ------------------------------------------------------------------------------
# ASCII FORMATTING - SEPARATORS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# COMPLETE SECTION FORMATTERS
# ------------------------------------------------------------------------------

static func format_execution_summary(stats: Dictionary) -> String:
	"""Format complete execution summary section"""
	var result = ""

	# Header
	result += format_section_divider() + "\n"
	result += format_content_line("EXECUTION SUMMARY") + "\n"
	result += format_section_divider() + "\n"

	# Test suites
	var suite_status = "[✓] %d passed" % stats.get("passed_suites", 0) if stats.get("failed_suites", 0) == 0 else "[✗] %d failed" % stats.get("failed_suites", 0)
	result += format_labeled_line("Test Suites", "%s, %d total" % [suite_status, stats.get("total_suites", 0)]) + "\n"

	# Test cases
	if stats.get("total_cases", 0) > 0:
		var case_status = "[✓] %d passed" % stats.get("passed_cases", 0) if stats.get("failed_cases", 0) == 0 else "[✗] %d failed" % stats.get("failed_cases", 0)
		result += format_labeled_line("Test Cases", "%s, %d total" % [case_status, stats.get("total_cases", 0)]) + "\n"

	# Assertions
	if stats.get("total_assertions", 0) > 0:
		var assertion_status = "[✓] %d passed" % stats.get("passed_assertions", 0) if stats.get("failed_assertions", 0) == 0 else "[✗] %d failed" % stats.get("failed_assertions", 0)
		result += format_labeled_line("Assertions", "%s, %d total" % [assertion_status, stats.get("total_assertions", 0)]) + "\n"

	# Duration
	result += format_labeled_line("Duration", "%.2fs" % stats.get("duration", 0.0)) + "\n"

	# Status
	var total_failures = stats.get("failed_suites", 0) + stats.get("failed_cases", 0)
	if total_failures == 0:
		result += format_content_line("Status: ALL TESTS PASSED") + "\n"
	else:
		result += format_content_line("Status: [✗] %d TEST SUITE(S) OR INDIVIDUAL TEST(S) FAILED" % total_failures) + "\n"

	# Coverage (placeholder)
	result += format_labeled_line("Coverage", "N/A (not configured)") + "\n"

	# Footer
	result += format_box_bottom()

	return result

static func format_discovery_summary(result: Object) -> String:
	"""Format discovery summary section"""
	var output = ""

	# Header
	output += format_content_line("Discovery Summary") + "\n"
	output += "─".repeat(BOX_WIDTH) + "\n"

	# Total scripts
	var total_text = "Total test scripts: " + str(result.total_found)
	output += format_content_line(total_text) + "\n"

	# Categories
	if result.categorized.size() > 0:
		output += format_content_line("Categorized by type:") + "\n"
		for category in result.categorized.keys():
			var count = result.categorized[category].size()
			var category_line = "     • " + str(category) + ": " + str(count)
			while category_line.length() < CONTENT_WIDTH:
				category_line += " "
			output += "║   " + category_line + "║\n"

	# Errors
	if result.errors.size() > 0:
		output += format_content_line("Errors encountered:") + "\n"
		for error in result.errors:
			var error_line = "[✗] " + str(error)
			# Error lines have different prefix/suffix: "║     " + content + "║"
			# So content width should be BOX_WIDTH - 7 (77 - 6 - 1)
			while error_line.length() < BOX_WIDTH - 7:
				error_line += " "
			output += "║     " + error_line + "║\n"

	output += format_box_bottom()
	return output

# ------------------------------------------------------------------------------
# BOX LIFECYCLE MANAGEMENT
# ------------------------------------------------------------------------------
# These methods provide higher-level box and section management
# to address integration issues with empty lines and border consistency

static func start_box(title: String) -> String:
	"""Start a complete output box with title"""
	return format_box_header(title)

static func end_box() -> String:
	"""End a complete output box"""
	return format_box_bottom()

static func start_section(title: String) -> String:
	"""Start a section within a box"""
	var result = ""
	result += format_section_divider() + "\n"
	result += format_content_line(title) + "\n"
	result += format_section_divider()
	return result

static func end_section() -> String:
	"""End a section (typically no output needed - sections flow together)"""
	return ""

static func section_break() -> String:
	"""Create proper spacing between sections without breaking box structure"""
	return format_content_line("")  # Empty formatted line instead of gap

static func add_content(content: String) -> String:
	"""Add content line within a section"""
	return format_content_line(content)

static func add_empty_line() -> String:
	"""Add properly formatted empty line within a section"""
	return format_content_line("")

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------