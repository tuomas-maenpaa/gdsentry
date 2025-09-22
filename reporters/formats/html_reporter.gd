# GDSentry - HTML Reporter
# Generates interactive HTML reports for human consumption
#
# This reporter creates comprehensive, visually appealing HTML reports
# with interactive features, charts, and detailed test information suitable
# for stakeholders, developers, and CI/CD dashboards.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends "res://reporters/base/test_reporter.gd"

class_name HTMLReporter

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const HTML_TEMPLATE_PATH = "res://reporters/templates/report_template.html"

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var include_charts: bool = true
var include_environment_info: bool = true
var include_assertion_details: bool = true
var max_error_length: int = 500
var theme: String = "default"
var include_search: bool = true
var include_filters: bool = true

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init(config: Dictionary = {}) -> void:
	super._init(config)
	_apply_html_configuration(config)

# ------------------------------------------------------------------------------
# ABSTRACT METHOD IMPLEMENTATIONS
# ------------------------------------------------------------------------------
func generate_report(test_suite, output_path: String) -> void:
	"""Generate HTML report

	Args:
		test_suite: The complete test suite results
		output_path: Full path where the HTML report should be saved
	"""
	if not validate_test_suite(test_suite):
		handle_generation_error("Invalid test suite", output_path)
		return

	if not validate_output_path(output_path):
		handle_generation_error("Invalid output path", output_path)
		return

	var html_content = _generate_html_content(test_suite)

	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if not file:
		handle_generation_error("Failed to open output file", output_path)
		return

	file.store_string(html_content)
	file.close()

	print("HTMLReporter: HTML report saved to: ", output_path)

	# Copy any additional assets if needed
	_copy_additional_assets(output_path)

func get_supported_formats() -> Array[String]:
	"""Return supported formats for this reporter"""
	return ["html", "htm"]

func get_default_filename() -> String:
	"""Return default filename for HTML reports"""
	return "test_report"

func get_format_extension() -> String:
	"""Return file extension for HTML reports"""
	return ".html"

# ------------------------------------------------------------------------------
# HTML GENERATION
# ------------------------------------------------------------------------------
func _generate_html_content(test_suite: ) -> String:
	"""Generate the complete HTML content"""
	var template = _load_html_template()
	if template.is_empty():
		push_error("HTMLReporter: Failed to load HTML template")
		return ""

	var html_content = template

	# Replace placeholders with actual data
	html_content = _replace_summary_placeholders(html_content, test_suite)
	html_content = _replace_test_results_placeholder(html_content, test_suite)
	html_content = _replace_environment_placeholders(html_content, test_suite)

	return html_content

func _load_html_template() -> String:
	"""Load the HTML template file"""
	var file = FileAccess.open(HTML_TEMPLATE_PATH, FileAccess.READ)
	if not file:
		push_error("HTMLReporter: Could not open HTML template: " + HTML_TEMPLATE_PATH)
		return ""

	var content = file.get_as_text()
	file.close()
	return content

func _replace_summary_placeholders(template: String, test_suite: ) -> String:
	"""Replace summary-related placeholders in the template"""
	var replacements = {
		"{TOTAL_TESTS}": str(test_suite.get_total_tests()),
		"{PASSED_TESTS}": str(test_suite.get_passed_tests()),
		"{FAILED_TESTS}": str(test_suite.get_failed_tests()),
		"{SKIPPED_TESTS}": str(test_suite.get_skipped_tests()),
		"{SUCCESS_RATE}": str(int(test_suite.get_success_rate())),
		"{EXECUTION_TIME}": format_duration(test_suite.execution_time),
		"{TIMESTAMP}": format_timestamp(Time.get_unix_time_from_system())
	}

	for placeholder in replacements:
		template = template.replace(placeholder, replacements[placeholder])

	return template

func _replace_test_results_placeholder(template: String, test_suite: ) -> String:
	"""Replace test results placeholder with actual test data"""
	var test_results_html = _generate_test_results_html(test_suite)
	template = template.replace("{TEST_RESULTS_HTML}", test_results_html)
	return template

func _replace_environment_placeholders(template: String, test_suite: ) -> String:
	"""Replace environment-related placeholders"""
	var version_info = Engine.get_version_info()

	var replacements = {
		"{GDSENTRY_VERSION}": "2.0.0",
		"{GODOT_VERSION}": version_info.string,
		"{PLATFORM}": OS.get_name(),
		"{ARCHITECTURE}": _get_architecture(),
		"{EXECUTION_TIME}": format_duration(test_suite.execution_time),
		"{TIMESTAMP}": format_timestamp(Time.get_unix_time_from_system())
	}

	for placeholder in replacements:
		template = template.replace(placeholder, replacements[placeholder])

	return template

# ------------------------------------------------------------------------------
# TEST RESULTS HTML GENERATION
# ------------------------------------------------------------------------------
func _generate_test_results_html(test_suite: ) -> String:
	"""Generate HTML for test results organized by category"""
	var html = ""

	# Group tests by category
	var tests_by_category = _group_tests_by_category(test_suite)

	var section_id = 0
	for category in tests_by_category:
		html += _generate_category_section_html(category, tests_by_category[category], section_id)
		section_id += 1

	return html

func _group_tests_by_category(test_suite: ) -> Dictionary:
	"""Group test results by category for better organization"""
	var grouped = {}

	for result in test_suite.test_results:
		var category = result.test_category if not result.test_category.is_empty() else "General"
		if not grouped.has(category):
			grouped[category] = []
		grouped[category].append(result)

	return grouped

func _generate_category_section_html(category: String, test_results: Array, section_id: int) -> String:
	"""Generate HTML for a category section"""
	var passed_count = _count_status_in_group(test_results, "passed")
	var failed_count = _count_status_in_group(test_results, "failed")
	var _error_count = _count_status_in_group(test_results, "error")
	var skipped_count = _count_status_in_group(test_results, "skipped")

	var html = '<div class="test-section" id="section-' + str(section_id) + '">\n'
	html += '\t<div class="test-header" id="header-' + str(section_id) + '" onclick="toggleTestSection(' + str(section_id) + ')">\n'
	html += '\t\t<div class="test-category">\n'
	html += '\t\t\t<span class="toggle-icon">▶</span> ' + escape_html(category) + '\n'
	html += '\t\t</div>\n'
	html += '\t\t<div class="test-stats">\n'
	html += '\t\t\t<span>Total: ' + str(test_results.size()) + '</span>\n'
	html += '\t\t\t<span>Passed: ' + str(passed_count) + '</span>\n'
	html += '\t\t\t<span>Failed: ' + str(failed_count) + '</span>\n'
	html += '\t\t\t<span>Skipped: ' + str(skipped_count) + '</span>\n'
	html += '\t\t</div>\n'
	html += '\t</div>\n'

	html += '\t<div class="test-content" id="content-' + str(section_id) + '">\n'
	html += '\t\t<div class="test-list">\n'

	for result in test_results:
		html += _generate_test_item_html(result)

	html += '\t\t</div>\n'
	html += '\t</div>\n'
	html += '</div>\n'

	return html

func _generate_test_item_html(test_result: ) -> String:
	"""Generate HTML for a single test item"""
	var status_class = "status-" + test_result.status
	var status_text = test_result.status.capitalize()

	var html = '<div class="test-item">\n'
	html += '\t<div class="test-name">' + escape_html(test_result.test_name) + '</div>\n'
	html += '\t<div class="test-class">' + escape_html(test_result.test_class) + '</div>\n'

	html += '\t<div class="test-details">\n'
	html += '\t\t<span class="status-badge ' + status_class + '">' + status_text + '</span>\n'
	html += '\t\t<span>' + format_duration(test_result.execution_time) + '</span>\n'
	html += '\t</div>\n'

	# Add error details if test failed
	if test_result.status == "failed" or test_result.status == "error":
		html += _generate_error_details_html(test_result)

	html += '</div>\n'

	return html

func _generate_error_details_html(test_result: ) -> String:
	"""Generate HTML for error details"""
	var html = '<div class="error-details">\n'

	if not test_result.error_message.is_empty():
		html += '<strong>Error Message:</strong><br>\n'
		var error_msg = test_result.error_message
		if error_msg.length() > max_error_length:
			error_msg = error_msg.substr(0, max_error_length) + "..."
		html += escape_html(error_msg) + '<br><br>\n'

	if not test_result.stack_trace.is_empty():
		html += '<strong>Stack Trace:</strong><br>\n'
		var stack_trace = test_result.stack_trace
		if stack_trace.length() > max_error_length:
			stack_trace = stack_trace.substr(0, max_error_length) + "..."
		html += '<pre>' + escape_html(stack_trace) + '</pre>\n'

	html += '</div>\n'
	return html

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func _count_status_in_group(test_results: Array, status: String) -> int:
	"""Count tests with a specific status in a group"""
	var count = 0
	for result in test_results:
		if result.status == status:
			count += 1
	return count

func _get_architecture() -> String:
	"""Get system architecture"""
	match OS.get_name():
		"Windows":
			return "x86_64" if OS.has_feature("x86_64") else "x86"
		"macOS", "Linux":
			return "x86_64" if OS.has_feature("x86_64") else "arm64" if OS.has_feature("arm64") else "unknown"
		_:
			return "unknown"

func _apply_html_configuration(config: Dictionary) -> void:
	"""Apply HTML-specific configuration"""
	if config.has("html"):
		var html_config = config.html
		if html_config.has("include_charts"):
			include_charts = html_config.include_charts
		if html_config.has("include_environment_info"):
			include_environment_info = html_config.include_environment_info
		if html_config.has("include_assertion_details"):
			include_assertion_details = html_config.include_assertion_details
		if html_config.has("max_error_length"):
			max_error_length = html_config.max_error_length
		if html_config.has("theme"):
			theme = html_config.theme
		if html_config.has("include_search"):
			include_search = html_config.include_search
		if html_config.has("include_filters"):
			include_filters = html_config.include_filters

# ------------------------------------------------------------------------------
# ASSET MANAGEMENT
# ------------------------------------------------------------------------------
func _copy_additional_assets(_output_path: String) -> void:
	"""Copy any additional assets needed for the HTML report"""
	# For now, the HTML report is self-contained
	# In the future, this could copy CSS files, images, or JavaScript libraries
	pass

# ------------------------------------------------------------------------------
# ENHANCED HTML ESCAPING
# ------------------------------------------------------------------------------
func escape_html_attribute(text: String) -> String:
	"""Escape special characters for HTML attributes"""
	text = escape_html(text)
	text = text.replace("'", "&apos;")
	text = text.replace("\"", "&quot;")
	return text

# ------------------------------------------------------------------------------
# TEMPLATE CUSTOMIZATION
# ------------------------------------------------------------------------------
func customize_template(_custom_css: String = "", _custom_js: String = "") -> void:
	"""Customize the HTML template with additional CSS and JavaScript"""
	# This could be extended to allow runtime template customization
	pass

# ------------------------------------------------------------------------------
# CHART GENERATION (FUTURE ENHANCEMENT)
# ------------------------------------------------------------------------------
func _generate_chart_data(test_suite: ) -> Dictionary:
	"""Generate data for charts (placeholder for future enhancement)"""
	return {
		"passed": test_suite.get_passed_tests(),
		"failed": test_suite.get_failed_tests(),
		"skipped": test_suite.get_skipped_tests(),
		"errors": test_suite.get_error_tests()
	}

# ------------------------------------------------------------------------------
# RESPONSIVE DESIGN HELPERS
# ------------------------------------------------------------------------------
func _get_responsive_breakpoints() -> Dictionary:
	"""Get responsive design breakpoints"""
	return {
		"mobile": 768,
		"tablet": 1024,
		"desktop": 1200
	}

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func cleanup() -> void:
	"""Clean up any temporary resources"""
	super.cleanup()
	# HTML reporter doesn't create temporary files, so no cleanup needed
