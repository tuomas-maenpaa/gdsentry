# GDSentry - JSON Reporter
# Generates structured JSON reports for programmatic consumption
#
# This reporter creates JSON output with a well-defined schema that can be
# easily consumed by external tools, APIs, dashboards, and analysis systems.
# The JSON format provides complete test execution data in a machine-readable format.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends "res://reporters/base/test_reporter.gd"

class_name JSONReporter

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const JSON_SCHEMA_VERSION = "1.0"
const JSON_INDENT_SIZE = 2

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var include_assertion_details: bool = true
var include_system_info: bool = true
var include_environment_data: bool = true
var flatten_results: bool = false
var group_by_category: bool = true

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init(config: Dictionary = {}) -> void:
	super._init(config)
	_apply_json_configuration(config)

# ------------------------------------------------------------------------------
# ABSTRACT METHOD IMPLEMENTATIONS
# ------------------------------------------------------------------------------
func generate_report(test_suite, output_path: String) -> void:
	"""Generate JSON report

	Args:
		test_suite: The complete test suite results
		output_path: Full path where the JSON report should be saved
	"""
	if not validate_test_suite(test_suite):
		handle_generation_error("Invalid test suite", output_path)
		return

	if not validate_output_path(output_path):
		handle_generation_error("Invalid output path", output_path)
		return

	var json_data = _generate_json_data(test_suite)
	var json_string = _serialize_json(json_data)

	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if not file:
		handle_generation_error("Failed to open output file", output_path)
		return

	file.store_string(json_string)
	file.close()

	print("JSONReporter: JSON report saved to: ", output_path)

func get_supported_formats() -> Array[String]:
	"""Return supported formats for this reporter"""
	return ["json"]

func get_default_filename() -> String:
	"""Return default filename for JSON reports"""
	return "test_results"

func get_format_extension() -> String:
	"""Return file extension for JSON reports"""
	return ".json"

# ------------------------------------------------------------------------------
# JSON DATA GENERATION
# ------------------------------------------------------------------------------
func _generate_json_data(test_suite) -> Dictionary:
	"""Generate the complete JSON data structure"""
	var data = {
		"schema": {
			"version": JSON_SCHEMA_VERSION,
			"type": "gdsentry_test_report"
		},
		"metadata": _generate_metadata(),
		"summary": _generate_summary_data(test_suite),
		"tests": _generate_tests_data(test_suite)
	}

	if include_environment_data:
		data["environment"] = _generate_environment_data()

	return data

func _generate_metadata() -> Dictionary:
	"""Generate report metadata"""
	return {
		"framework": "GDSentry",
		"version": "2.0.0",
		"generated_at": format_timestamp(Time.get_unix_time_from_system()),
		"generator": "JSONReporter"
	}

func _generate_summary_data(test_suite) -> Dictionary:
	"""Generate summary statistics"""
	return {
		"total_tests": test_suite.get_total_tests(),
		"passed_tests": test_suite.get_passed_tests(),
		"failed_tests": test_suite.get_failed_tests(),
		"error_tests": test_suite.get_error_tests(),
		"skipped_tests": test_suite.get_skipped_tests(),
		"total_assertions": test_suite.get_total_assertions(),
		"passed_assertions": test_suite.get_passed_assertions(),
		"failed_assertions": test_suite.get_failed_assertions(),
		"success_rate": test_suite.get_success_rate(),
		"execution_time": test_suite.execution_time,
		"formatted_execution_time": format_duration(test_suite.execution_time),
		"has_failures": test_suite.has_failures(),
		"start_time": format_timestamp(test_suite.start_time),
		"end_time": format_timestamp(test_suite.end_time)
	}

func _generate_tests_data(test_suite) -> Dictionary:
	"""Generate test results data"""
	if flatten_results:
		return _generate_flattened_tests_data(test_suite)
	else:
		return _generate_structured_tests_data(test_suite)

func _generate_structured_tests_data(test_suite) -> Dictionary:
	"""Generate structured test data grouped by category"""
	var data = {}

	if group_by_category:
		# Group tests by category
		var tests_by_category = {}
		for result in test_suite.test_results:
			var category = result.test_category if not result.test_category.is_empty() else "uncategorized"
			if not tests_by_category.has(category):
				tests_by_category[category] = []
			tests_by_category[category].append(_convert_test_result_to_dict(result))

		data["by_category"] = tests_by_category
	else:
		# Flat list of all tests
		var all_tests = []
		for result in test_suite.test_results:
			all_tests.append(_convert_test_result_to_dict(result))
		data["all"] = all_tests

	return data

func _generate_flattened_tests_data(test_suite: ) -> Dictionary:
	"""Generate flattened test data for simple consumption"""
	var data = {
		"tests": []
	}

	for result in test_suite.test_results:
		data.tests.append(_convert_test_result_to_dict(result))

	return data

func _convert_test_result_to_dict(result: ) -> Dictionary:
	"""Convert a TestResultData object to a dictionary"""
	var test_data = {
		"name": result.test_name,
		"class": result.test_class,
		"category": result.test_category,
		"status": result.status,
		"execution_time": result.execution_time,
		"start_time": format_timestamp(result.start_time),
		"end_time": format_timestamp(result.end_time)
	}

	# Add optional fields based on configuration
	if not result.error_message.is_empty():
		test_data["error_message"] = result.error_message

	if not result.stack_trace.is_empty():
		test_data["stack_trace"] = result.stack_trace

	if include_assertion_details and not result.assertions.is_empty():
		test_data["assertions"] = _convert_assertions_to_array(result.assertions)

	if include_metadata and not result.metadata.is_empty():
		test_data["metadata"] = result.metadata

	return test_data

func _convert_assertions_to_array(assertions: Array) -> Array:
	"""Convert assertion objects to dictionaries"""
	var assertion_data = []

	for assertion in assertions:
		assertion_data.append({
			"type": assertion.type,
			"passed": assertion.passed,
			"message": assertion.message,
			"timestamp": format_timestamp(assertion.timestamp),
			"expected": assertion.expected,
			"actual": assertion.actual
		})

	return assertion_data

func _generate_environment_data() -> Dictionary:
	"""Generate environment information"""
	var version_info = Engine.get_version_info()

	return {
		"godot": {
			"version": version_info.string,
			"major": version_info.major,
			"minor": version_info.minor,
			"patch": version_info.patch,
			"status": version_info.status
		},
		"platform": {
			"name": OS.get_name(),
			"architecture": _get_architecture(),
			"is_debug_build": OS.is_debug_build(),
			"is_release_build": not OS.is_debug_build()
		},
		"system": {
			"processor_count": OS.get_processor_count(),
			"processor_name": OS.get_processor_name(),
			"locale": OS.get_locale(),
			"timezone": Time.get_time_zone_from_system().name
		},
		"gdsentry": {
			"version": "2.0.0",
			"headless_mode": GDTestManager.is_headless_mode()
		}
	}

# ------------------------------------------------------------------------------
# JSON SERIALIZATION
# ------------------------------------------------------------------------------
func _serialize_json(data: Dictionary) -> String:
	"""Serialize data to JSON string with proper formatting"""
	var json_string = JSON.stringify(data, "\t" if pretty_print else "", false, true)

	if json_string.is_empty():
		push_error("JSONReporter: Failed to serialize JSON data")
		return "{}"

	return json_string

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func _get_architecture() -> String:
	"""Get system architecture"""
	match OS.get_name():
		"Windows":
			return "x86_64" if OS.has_feature("x86_64") else "x86"
		"macOS", "Linux":
			return "x86_64" if OS.has_feature("x86_64") else "arm64" if OS.has_feature("arm64") else "unknown"
		_:
			return "unknown"

func _apply_json_configuration(config: Dictionary) -> void:
	"""Apply JSON-specific configuration"""
	if config.has("json"):
		var json_config = config.json
		if json_config.has("include_assertion_details"):
			include_assertion_details = json_config.include_assertion_details
		if json_config.has("include_system_info"):
			include_system_info = json_config.include_system_info
		if json_config.has("include_environment_data"):
			include_environment_data = json_config.include_environment_data
		if json_config.has("flatten_results"):
			flatten_results = json_config.flatten_results
		if json_config.has("group_by_category"):
			group_by_category = json_config.group_by_category

# ------------------------------------------------------------------------------
# SCHEMA VALIDATION
# ------------------------------------------------------------------------------
func validate_json_schema(data: Dictionary) -> bool:
	"""Validate that the generated JSON conforms to the expected schema"""
	var required_root_keys = ["schema", "metadata", "summary", "tests"]

	for key in required_root_keys:
		if not data.has(key):
			push_error("JSONReporter: Missing required root key: " + key)
			return false

	if not data.schema.has("version"):
		push_error("JSONReporter: Missing schema version")
		return false

	if not data.metadata.has("framework"):
		push_error("JSONReporter: Missing framework metadata")
		return false

	return true

# ------------------------------------------------------------------------------
# API-FRIENDLY METHODS
# ------------------------------------------------------------------------------
func get_structured_data(test_suite: ) -> Dictionary:
	"""Get structured JSON data for API consumption"""
	return _generate_json_data(test_suite)

func get_summary_only(test_suite: ) -> Dictionary:
	"""Get only summary data for quick API responses"""
	return {
		"summary": _generate_summary_data(test_suite),
		"metadata": _generate_metadata()
	}

func get_failures_only(test_suite: ) -> Dictionary:
	"""Get only failed/error test data"""
	var failures = []

	for result in test_suite.test_results:
		if result.status == "failed" or result.status == "error":
			failures.append(_convert_test_result_to_dict(result))

	return {
		"failures": failures,
		"count": failures.size(),
		"metadata": _generate_metadata()
	}

# ------------------------------------------------------------------------------
# QUERY METHODS
# ------------------------------------------------------------------------------
func query_tests_by_status(test_suite, status) -> Array:
	"""Query tests by status (passed, failed, error, skipped)"""
	var results = []

	for result in test_suite.test_results:
		if result.status == status:
			results.append(_convert_test_result_to_dict(result))

	return results

func query_tests_by_category(test_suite, category) -> Array:
	"""Query tests by category"""
	var results = []

	for result in test_suite.test_results:
		if result.test_category == category:
			results.append(_convert_test_result_to_dict(result))

	return results

# ------------------------------------------------------------------------------
# CLASS QUERY METHODS
# ------------------------------------------------------------------------------
func query_tests_by_class(test_suite, test_class_name) -> Array:
	"""Query tests by class name"""
	var results = []
	for result in test_suite.test_results:
		if result.test_class == test_class_name:
			results.append(_convert_test_result_to_dict(result))
	return results

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func cleanup() -> void:
	"""Clean up any temporary resources"""
	super.cleanup()
	# JSON reporter doesn't create temporary files, so no cleanup needed
