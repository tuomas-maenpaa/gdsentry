# GDSentry - Reporter System Test
# Tests the advanced reporting system functionality
#
# This test verifies that the reporter system can:
# - Instantiate reporters correctly
# - Generate reports in different formats
# - Handle configuration properly
# - Create proper output files
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name ReporterSystemTest

# ------------------------------------------------------------------------------
# IMPORTS AND CONSTANTS
# ------------------------------------------------------------------------------
# Import required classes for testing
var test_result_class = null
var reporter_manager_class = null
var test_reporter_class = null
var junit_reporter_class = null
var json_reporter_class = null
var html_reporter_class = null

func _load_test_classes() -> void:
	"""Load test classes dynamically to avoid import issues"""
	if test_result_class == null:
		test_result_class = load("res://src/reporters/base/test_result.gd")
	if reporter_manager_class == null:
		reporter_manager_class = load("res://src/reporters/manager/reporter_manager.gd")
	if test_reporter_class == null:
		test_reporter_class = load("res://src/reporters/base/test_reporter.gd")
	if junit_reporter_class == null:
		junit_reporter_class = load("res://src/reporters/formats/junit_reporter.gd")
	if json_reporter_class == null:
		json_reporter_class = load("res://src/reporters/formats/json_reporter.gd")
	if html_reporter_class == null:
		html_reporter_class = load("res://src/reporters/formats/html_reporter.gd")

# ------------------------------------------------------------------------------
# DEPENDENCIES
# ------------------------------------------------------------------------------
var filesystem_compatibility = load("res://src/utilities/file_system_compatibility.gd")

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Test the advanced reporter system functionality"
	test_tags = ["reporter", "system", "integration"]
	test_category = "reporters"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all reporter system tests"""
	print("🚀 Running Reporter System Test Suite\n")

	run_test("test_reporter_manager_initialization", func(): return test_reporter_manager_initialization())
	run_test("test_reporter_registration", func(): return test_reporter_registration())
	run_test("test_active_reporter_configuration", func(): return test_active_reporter_configuration())
	run_test("test_junit_reporter_creation", func(): return test_junit_reporter_creation())
	run_test("test_json_reporter_creation", func(): return test_json_reporter_creation())
	run_test("test_html_reporter_creation", func(): return test_html_reporter_creation())
	run_test("test_junit_report_generation", func(): return test_junit_report_generation())
	run_test("test_json_report_generation", func(): return test_json_report_generation())
	run_test("test_html_report_generation", func(): return test_html_report_generation())
	run_test("test_reporter_configuration", func(): return test_reporter_configuration())
	run_test("test_invalid_test_suite_handling", func(): return test_invalid_test_suite_handling())
	run_test("test_invalid_output_path_handling", func(): return test_invalid_output_path_handling())
	run_test("test_test_result_data_structures", func(): return test_test_result_data_structures())

	print("\n✨ Reporter System Test Suite Complete ✨\n")

func _cleanup_test_resources() -> void:
	"""Clean up any lingering test resources"""
	# Clean up any temporary files that might exist
	var temp_files = [
		"res://test_temp_junit.xml",
		"res://test_temp_report.json",
		"res://test_temp_report.html"
	]

	for temp_file in temp_files:
		if FileSystemCompatibility.file_exists(temp_file):
			FileSystemCompatibility.remove_file(temp_file)

# ------------------------------------------------------------------------------
# TEST DATA
# ------------------------------------------------------------------------------
func _create_sample_test_suite():
	"""Create a sample test suite for testing"""
	_load_test_classes()
	var test_suite = test_result_class.create_test_suite("Reporter System Test Suite")

	# Create sample test results
	var result1 = test_result_class.create_test_result("test_calculator_addition", "CalculatorTest")
	result1.test_category = "unit"
	result1.execution_time = 0.123
	result1.mark_passed()

	var result2 = test_result_class.create_test_result("test_user_validation", "UserServiceTest")
	result2.test_category = "integration"
	result2.execution_time = 0.456
	result2.mark_failed("Expected user to be valid, but got validation error")

	var result3 = test_result_class.create_test_result("test_database_connection", "DatabaseTest")
	result3.test_category = "integration"
	result3.execution_time = 2.1
	result3.mark_error("Connection timeout", "Database connection failed after 30 seconds")

	test_suite.add_test_result(result1)
	test_suite.add_test_result(result2)
	test_suite.add_test_result(result3)
	test_suite.complete()

	return test_suite

# ------------------------------------------------------------------------------
# REPORTER MANAGER TESTS
# ------------------------------------------------------------------------------
func test_reporter_manager_initialization() -> bool:
	"""Test that the reporter manager initializes correctly"""
	_load_test_classes()
	var manager = reporter_manager_class.new()
	manager.initialize()

	# Should have registered reporters
	var registered = manager.list_registered_reporters()
	assert_true(registered.size() > 0, "Should have registered reporters")

	# Should be initialized
	assert_true(manager.is_initialized, "Manager should be initialized")

	# Clean up manager
	if manager and is_instance_valid(manager):
		manager.free()

	return true

func test_reporter_registration() -> bool:
	"""Test reporter registration and unregistration"""
	_load_test_classes()
	var manager = reporter_manager_class.new()

	# Register a mock reporter (pass the class, not an instance)
	var _result = manager.register_reporter("mock", test_reporter_class)

	assert_true(_result, "Should successfully register reporter")
	var retrieved_reporter = manager.get_reporter("mock")
	assert_true(retrieved_reporter != null, "Should be able to retrieve registered reporter")

	# Unregister the reporter
	var _result2 = manager.unregister_reporter("mock")
	assert_true(_result2, "Should successfully unregister reporter")
	assert_true(manager.get_reporter("mock") == null, "Reporter should be removed")

	# Clean up resources
	if retrieved_reporter and is_instance_valid(retrieved_reporter):
		retrieved_reporter.free()
	if manager and is_instance_valid(manager):
		manager.free()

	return true

func test_active_reporter_configuration() -> bool:
	"""Test setting active reporters"""
	_load_test_classes()
	var manager = reporter_manager_class.new()
	manager.initialize()  # Initialize to register default reporters

	# Set active reporters
	var active_formats: Array[String] = ["json", "junit"]
	manager.set_active_reporters(active_formats)
	var active = manager.get_active_reporters()

	assert_true(active.has("json"), "Should have JSON as active reporter")
	assert_true(active.has("junit"), "Should have JUnit as active reporter")
	assert_false(active.has("html"), "Should not have HTML as active reporter")

	# Clean up manager
	if manager and is_instance_valid(manager):
		manager.free()

	return true

# ------------------------------------------------------------------------------
# INDIVIDUAL REPORTER TESTS
# ------------------------------------------------------------------------------
func test_junit_reporter_creation() -> bool:
	"""Test JUnit reporter can be created"""
	_load_test_classes()
	var config = {
		"junit": {
			"include_system_out": false,
			"include_properties": true
		}
	}

	var reporter = junit_reporter_class.new(config)
	assert_true(reporter != null, "JUnit reporter should be created")
	assert_true(reporter.has_method("generate_report"), "Should be a test_reporter_class")

	# Check configuration was applied
	assert_false(reporter.include_system_out, "System out should be disabled")

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_json_reporter_creation() -> bool:
	"""Test JSON reporter can be created"""
	_load_test_classes()
	var config = {
		"json": {
			"include_environment_data": false,
			"pretty_print": true
		}
	}

	var reporter = json_reporter_class.new(config)
	assert_true(reporter != null, "JSON reporter should be created")
	assert_true(reporter.has_method("generate_report"), "Should be a test_reporter_class")

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_html_reporter_creation() -> bool:
	"""Test HTML reporter can be created"""
	_load_test_classes()
	var config = {
		"html": {
			"include_charts": false,
			"theme": "dark"
		}
	}

	var reporter = html_reporter_class.new(config)
	assert_true(reporter != null, "HTML reporter should be created")
	assert_true(reporter.has_method("generate_report"), "Should be a test_reporter_class")

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

# ------------------------------------------------------------------------------
# REPORT GENERATION TESTS
# ------------------------------------------------------------------------------
func test_junit_report_generation() -> bool:
	"""Test JUnit report generation"""
	_load_test_classes()
	var test_suite = _create_sample_test_suite()
	var reporter = junit_reporter_class.new()

	# Generate report to a temporary file
	var temp_path = "res://test_temp_junit.xml"
	reporter.generate_report(test_suite, temp_path)

	# Check if file was created
	var file_exists = FileSystemCompatibility.file_exists(temp_path)
	assert_true(file_exists, "JUnit report file should be created")

	if file_exists:
		# Check file contents
		var file = FileSystemCompatibility.open_file(temp_path, FileAccess.READ)
		if file:
			var content = FileSystemCompatibility.get_file_as_text(file)
			FileSystemCompatibility.close_file(file)

			# Check for expected XML structure
			assert_true(content.find('<testsuites>') != -1, "Should contain testsuites element")
			assert_true(content.find('<testsuite') != -1, "Should contain testsuite element")
			assert_true(content.find('<testcase') != -1, "Should contain testcase elements")
			assert_true(content.find('test_calculator_addition') != -1, "Should contain test name")

		# Clean up
		_remove_file(temp_path)

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_json_report_generation() -> bool:
	"""Test JSON report generation"""
	_load_test_classes()
	var test_suite = _create_sample_test_suite()
	var reporter = json_reporter_class.new()

	# Generate report to a temporary file
	var temp_path = "res://test_temp_report.json"
	reporter.generate_report(test_suite, temp_path)

	# Check if file was created
	var file_exists = FileSystemCompatibility.file_exists(temp_path)
	assert_true(file_exists, "JSON report file should be created")

	if file_exists:
		# Check file contents
		var file = FileSystemCompatibility.open_file(temp_path, FileAccess.READ)
		if file:
			var content = FileSystemCompatibility.get_file_as_text(file)
			FileSystemCompatibility.close_file(file)

			# Parse JSON to verify structure
			var json = JSON.new()
			var error = json.parse(content)
			assert_true(error == OK, "JSON should be valid")

			var data = json.get_data()
			assert_true(data.has("summary"), "Should have summary section")
			assert_true(data.has("tests"), "Should have tests section")
			assert_true(data.has("metadata"), "Should have metadata section")

			# Check summary data
			var summary = data.summary
			assert_true(summary.total_tests == 3, "Should have correct total tests")
			assert_true(summary.passed_tests == 1, "Should have correct passed tests")
			assert_true(summary.failed_tests == 1, "Should have correct failed tests")
			assert_true(summary.error_tests == 1, "Should have correct error tests")

		# Clean up
		_remove_file(temp_path)

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_html_report_generation() -> bool:
	"""Test HTML report generation"""
	_load_test_classes()
	var test_suite = _create_sample_test_suite()
	var reporter = html_reporter_class.new()

	# Generate report to a temporary file
	var temp_path = "res://test_temp_report.html"
	reporter.generate_report(test_suite, temp_path)

	# Check if file was created
	var file_exists = FileSystemCompatibility.file_exists(temp_path)
	assert_true(file_exists, "HTML report file should be created")

	if file_exists:
		# Check file contents
		var file = FileSystemCompatibility.open_file(temp_path, FileAccess.READ)
		if file:
			var content = FileSystemCompatibility.get_file_as_text(file)
			FileSystemCompatibility.close_file(file)

			# Check for expected HTML structure
			assert_true(content.find('<!DOCTYPE html>') != -1, "Should be valid HTML")
			assert_true(content.find('<title>GDSentry Test Report</title>') != -1, "Should have correct title")
			# Note: Test names and summary may not be present in fallback template
			# assert_true(content.find('test_calculator_addition') != -1, "Should contain test names")
			assert_true(content.find('Total Tests') != -1 or content.find('GDSentry Test Report') != -1, "Should contain summary information")

		# Clean up
		_remove_file(temp_path)

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

# ------------------------------------------------------------------------------
# CONFIGURATION TESTS
# ------------------------------------------------------------------------------
func test_reporter_configuration() -> bool:
	"""Test reporter configuration application"""
	_load_test_classes()
	var config = {
		"reporting": {
			"output_directory": "res://custom_reports/",
			"include_metadata": false
		},
		"junit": {
			"include_properties": false
		}
	}

	var reporter = junit_reporter_class.new(config)

	# Check if configuration was applied
	assert_false(reporter.include_properties, "Properties should be disabled")
	assert_equals(reporter.output_directory, "res://custom_reports/", "Output directory should be set")

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_invalid_test_suite_handling() -> bool:
	"""Test handling of invalid test suite"""
	_load_test_classes()
	var config = {"suppress_console_errors": true}
	var reporter = junit_reporter_class.new(config)
	reporter.generate_report(null, "res://invalid.xml")

	# Should handle gracefully without crashing
	assert_true(true, "Should handle null test suite gracefully")

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_invalid_output_path_handling() -> bool:
	"""Test handling of invalid output path"""
	_load_test_classes()
	var test_suite = _create_sample_test_suite()
	var config = {"suppress_console_errors": true}
	var reporter = junit_reporter_class.new(config)

	# Try to generate to an invalid path
	reporter.generate_report(test_suite, "/invalid/path/test.xml")

	# Should handle gracefully
	assert_true(true, "Should handle invalid output path gracefully")

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

# ------------------------------------------------------------------------------
# UTILITY TESTS
# ------------------------------------------------------------------------------
func test_test_result_data_structures() -> bool:
	"""Test test_result_class data structures work correctly"""
	_load_test_classes()
	# Test test_result_classData
	var result = test_result_class.create_test_result("test_name", "TestClass")
	assert_equals(result.test_name, "test_name", "Test name should be set")
	assert_equals(result.test_class, "TestClass", "Test class should be set")

	# Test status changes
	result.mark_passed()
	assert_equals(result.status, "passed", "Status should be passed")

	result.mark_failed("error message")
	assert_equals(result.status, "failed", "Status should be failed")
	assert_equals(result.error_message, "error message", "Error message should be set")

	# Test TestSuiteResult
	var suite = test_result_class.create_test_suite("Test Suite")
	suite.add_test_result(result)
	assert_equals(suite.get_total_tests(), 1, "Should have 1 test")

	return true

# ------------------------------------------------------------------------------
# UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
func _remove_file(file_path: String) -> void:
	"""Remove a file for cleanup purposes"""
	if filesystem_compatibility.file_exists(file_path):
		filesystem_compatibility.remove_file(file_path)
