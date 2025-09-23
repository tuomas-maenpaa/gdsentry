# GDSentry - JUnit XML Reporter
# Generates JUnit XML format reports for CI/CD integration
#
# This reporter creates XML output compatible with the JUnit XML format,
# which is widely supported by CI/CD platforms like Jenkins, GitHub Actions,
# GitLab CI, Azure DevOps, and many others.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends "res://reporters/base/test_reporter.gd"

class_name JUnitReporter

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const JUNIT_XML_VERSION = "1.0"
const JUNIT_XML_ENCODING = "UTF-8"

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var include_system_out: bool = false
var include_system_err: bool = true
var include_properties: bool = true
var suite_name_template: String = "GDSentry.{category}"
var test_name_template: String = "{class}.{test_name}"

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init(config: Dictionary = {}) -> void:
	super._init(config)
	_apply_junit_configuration(config)

# ------------------------------------------------------------------------------
# ABSTRACT METHOD IMPLEMENTATIONS
# ------------------------------------------------------------------------------
func generate_report(test_suite, output_path: String) -> void:
	"""Generate JUnit XML report

	Args:
		test_suite: The complete test suite results
		output_path: Full path where the XML report should be saved
	"""
	if not validate_test_suite(test_suite):
		handle_generation_error("Invalid test suite", output_path)
		return

	if not validate_output_path(output_path):
		handle_generation_error("Invalid output path", output_path)
		return

	var xml_content = _generate_xml_content(test_suite)

	var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")
	var file = FileSystemCompatibility.open_file(output_path, FileSystemCompatibility.WRITE)
	if not file:
		handle_generation_error("Failed to open output file", output_path)
		return

	FileSystemCompatibility.store_string(file, xml_content)
	FileSystemCompatibility.close_file(file)

	print("JUnitReporter: XML report saved to: ", output_path)

func get_supported_formats() -> Array[String]:
	"""Return supported formats for this reporter"""
	return ["xml", "junit"]

func get_default_filename() -> String:
	"""Return default filename for JUnit reports"""
	return "junit_results"

func get_format_extension() -> String:
	"""Return file extension for JUnit reports"""
	return ".xml"

# ------------------------------------------------------------------------------
# XML GENERATION
# ------------------------------------------------------------------------------
func _generate_xml_content(test_suite: ) -> String:
	"""Generate the complete XML content for the test suite"""
	var xml = '<?xml version="' + JUNIT_XML_VERSION + '" encoding="' + JUNIT_XML_ENCODING + '"?>\n'
	xml += '<testsuites>\n'

	# Group tests by category for better organization
	var tests_by_category = _group_tests_by_category(test_suite)

	for category in tests_by_category.keys():
		var category_tests = tests_by_category[category]
		xml += _generate_testsuite_xml(category, category_tests, test_suite)

	xml += '</testsuites>\n'
	return xml

func _group_tests_by_category(test_suite: ) -> Dictionary:
	"""Group test results by category for better XML structure"""
	var grouped = {}

	for result in test_suite.test_results:
		var category = result.test_category if not result.test_category.is_empty() else "default"
		if not grouped.has(category):
			grouped[category] = []
		grouped[category].append(result)

	return grouped

func _generate_testsuite_xml(category: String, test_results: Array, full_suite: ) -> String:
	"""Generate XML for a single test suite (category)"""
	var suite_name = suite_name_template.format({"category": category})
	var total_tests = test_results.size()
	var total_failures = _count_status_in_group(test_results, "failed")
	var total_errors = _count_status_in_group(test_results, "error")
	var total_skipped = _count_status_in_group(test_results, "skipped")

	var xml = '\t<testsuite name="' + escape_xml(suite_name) + '" '
	xml += 'tests="' + str(total_tests) + '" '
	xml += 'failures="' + str(total_failures) + '" '
	xml += 'errors="' + str(total_errors) + '" '
	xml += 'skipped="' + str(total_skipped) + '" '
	xml += 'time="' + str(full_suite.execution_time) + '" '
	xml += 'timestamp="' + format_timestamp(full_suite.start_time) + '">\n'

	# Add properties if enabled
	if include_properties:
		xml += _generate_properties_xml()

	# Add individual test cases
	for test_result in test_results:
		xml += _generate_testcase_xml(test_result)

	# Add system output if enabled
	if include_system_out or include_system_err:
		xml += _generate_system_output_xml()

	xml += '\t</testsuite>\n'
	return xml

func _generate_testcase_xml(test_result: ) -> String:
	"""Generate XML for a single test case"""
	var test_name = test_name_template.format({
		"class": test_result.test_class,
		"test_name": test_result.test_name
	})

	var xml = '\t\t<testcase name="' + escape_xml(test_name) + '" '
	xml += 'classname="' + escape_xml(test_result.test_class) + '" '
	xml += 'time="' + str(test_result.execution_time) + '"'

	if test_result.status == "skipped":
		xml += '>\n'
		xml += '\t\t\t<skipped message="' + escape_xml(test_result.error_message) + '" />\n'
		xml += '\t\t</testcase>\n'
		return xml

	xml += '>\n'

	# Add failure or error details
	if test_result.status == "failed":
		xml += _generate_failure_xml(test_result)
	elif test_result.status == "error":
		xml += _generate_error_xml(test_result)

	xml += '\t\t</testcase>\n'
	return xml

func _generate_failure_xml(test_result: ) -> String:
	"""Generate XML for test failure details"""
	var xml = '\t\t\t<failure message="' + escape_xml(test_result.error_message) + '"'
	xml += ' type="AssertionError"'
	xml += '>\n'

	xml += '\t\t\t\t' + escape_xml(test_result.stack_trace) + '\n'

	# Add assertion details if available
	if not test_result.assertions.is_empty():
		xml += '\t\t\t\tAssertions:\n'
		for assertion in test_result.assertions:
			if not assertion.passed:
				xml += '\t\t\t\t- ' + escape_xml(assertion.message) + '\n'

	xml += '\t\t\t</failure>\n'
	return xml

func _generate_error_xml(test_result: ) -> String:
	"""Generate XML for test error details"""
	var xml = '\t\t\t<error message="' + escape_xml(test_result.error_message) + '"'
	xml += ' type="TestError"'
	xml += '>\n'

	xml += '\t\t\t\t' + escape_xml(test_result.stack_trace) + '\n'
	xml += '\t\t\t</error>\n'
	return xml

func _generate_properties_xml() -> String:
	"""Generate XML for test properties"""
	var xml = '\t\t<properties>\n'
	xml += '\t\t\t<property name="framework" value="GDSentry" />\n'
	xml += '\t\t\t<property name="version" value="2.0.0" />\n'
	xml += '\t\t\t<property name="godot_version" value="' + str(Engine.get_version_info().string) + '" />\n'
	xml += '\t\t\t<property name="platform" value="' + OS.get_name() + '" />\n'
	xml += '\t\t\t<property name="timestamp" value="' + str(Time.get_unix_time_from_system()) + '" />\n'
	xml += '\t\t</properties>\n'
	return xml

func _generate_system_output_xml() -> String:
	"""Generate XML for system output (stdout/stderr)"""
	var xml = ""

	if include_system_out:
		xml += '\t\t<system-out>\n'
		xml += '\t\t\tGDSentry Test Execution\n'
		xml += '\t\t\tGenerated by JUnitReporter\n'
		xml += '\t\t</system-out>\n'

	if include_system_err:
		xml += '\t\t<system-err>\n'
		xml += '\t\t\tNo system errors reported\n'
		xml += '\t\t</system-err>\n'

	return xml

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

func _apply_junit_configuration(config: Dictionary) -> void:
	"""Apply JUnit-specific configuration"""
	if config.has("junit"):
		var junit_config = config.junit
		if junit_config.has("include_system_out"):
			include_system_out = junit_config.include_system_out
		if junit_config.has("include_system_err"):
			include_system_err = junit_config.include_system_err
		if junit_config.has("include_properties"):
			include_properties = junit_config.include_properties
		if junit_config.has("suite_name_template"):
			suite_name_template = junit_config.suite_name_template
		if junit_config.has("test_name_template"):
			test_name_template = junit_config.test_name_template

# ------------------------------------------------------------------------------
# VALIDATION METHODS
# ------------------------------------------------------------------------------
func _validate_xml_content(xml_content: String) -> bool:
	"""Validate that generated XML is well-formed"""
	# Basic validation - check for required elements
	var required_elements = ["<testsuites>", "</testsuites>"]

	for element in required_elements:
		if xml_content.find(element) == -1:
			push_error("JUnitReporter: Missing required XML element: " + element)
			return false

	return true

# ------------------------------------------------------------------------------
# ENHANCED XML ESCAPING
# ------------------------------------------------------------------------------
func escape_xml_attribute(text: String) -> String:
	"""Escape special characters for XML attributes"""
	text = escape_xml(text)
	text = text.replace("\n", "&#10;")
	text = text.replace("\r", "&#13;")
	text = text.replace("\t", "&#9;")
	return text

# ------------------------------------------------------------------------------
# CI/CD COMPATIBILITY HELPERS
# ------------------------------------------------------------------------------
func get_ci_compatible_output(test_suite: ) -> String:
	"""Generate XML optimized for CI/CD consumption"""
	# For CI/CD, we want minimal but complete information
	include_system_out = false
	include_system_err = false
	include_properties = true

	return _generate_xml_content(test_suite)

func get_github_actions_summary(test_suite: ) -> String:
	"""Generate summary suitable for GitHub Actions annotations"""
	var summary = ""
	var failures = []

	for result in test_suite.test_results:
		if result.status == "failed" or result.status == "error":
			failures.append(result.test_name + " (" + result.test_class + ")")

	if failures.is_empty():
		summary = "✅ All tests passed"
	else:
		summary = "❌ " + str(failures.size()) + " test(s) failed: " + ", ".join(failures)

	return summary

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func cleanup() -> void:
	"""Clean up any temporary resources"""
	super.cleanup()
	# JUnit reporter doesn't create temporary files, so no cleanup needed
