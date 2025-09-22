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
var TestResult = null
var ReporterManager = null
var TestReporter = null
var JUnitReporter = null
var JSONReporter = null
var HTMLReporter = null

func _load_test_classes() -> void:
	"""Load test classes dynamically to avoid import issues"""
	if TestResult == null:
		TestResult = load("res://reporters/base/test_result.gd")
	if ReporterManager == null:
		ReporterManager = load("res://reporters/manager/reporter_manager.gd")
	if TestReporter == null:
		TestReporter = load("res://reporters/base/test_reporter.gd")
	if JUnitReporter == null:
		JUnitReporter = load("res://reporters/formats/junit_reporter.gd")
	if JSONReporter == null:
		JSONReporter = load("res://reporters/formats/json_reporter.gd")
	if HTMLReporter == null:
		HTMLReporter = load("res://reporters/formats/html_reporter.gd")

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Test the advanced reporter system functionality"
	test_tags = ["reporter", "system", "integration"]
	test_category = "reporters"

func _cleanup_test_resources() -> void:
	"""Clean up any lingering test resources"""
	# Clean up any temporary files that might exist
	var temp_files = [
		"res://test_temp_junit.xml",
		"res://test_temp_report.json",
		"res://test_temp_report.html"
	]

	for temp_file in temp_files:
		if FileAccess.file_exists(temp_file):
			DirAccess.remove_absolute(temp_file)

# ------------------------------------------------------------------------------
# TEST DATA
# ------------------------------------------------------------------------------
func _create_sample_test_suite():
	"""Create a sample test suite for testing"""
	_load_test_classes()
	var test_suite = TestResult.create_test_suite("Reporter System Test Suite")

	# Create sample test results
	var result1 = TestResult.create_test_result("test_calculator_addition", "CalculatorTest")
	result1.test_category = "unit"
	result1.execution_time = 0.123
	result1.mark_passed()

	var result2 = TestResult.create_test_result("test_user_validation", "UserServiceTest")
	result2.test_category = "integration"
	result2.execution_time = 0.456
	result2.mark_failed("Expected user to be valid, but got validation error")

	var result3 = TestResult.create_test_result("test_database_connection", "DatabaseTest")
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
	var manager = ReporterManager.new()
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
	var manager = ReporterManager.new()

	# Register a mock reporter
	var mock_reporter = TestReporter.new()
	var _result = manager.register_reporter("mock", mock_reporter)

	assert_true(_result, "Should successfully register reporter")
	assert_true(manager.get_reporter("mock") == mock_reporter, "Should be able to retrieve registered reporter")

	# Unregister the reporter
	var _result2 = manager.unregister_reporter("mock")
	assert_true(_result2, "Should successfully unregister reporter")
	assert_true(manager.get_reporter("mock") == null, "Reporter should be removed")

	# Clean up resources
	if mock_reporter and is_instance_valid(mock_reporter):
		mock_reporter.free()
	if manager and is_instance_valid(manager):
		manager.free()

	return true

func test_active_reporter_configuration() -> bool:
	"""Test setting active reporters"""
	_load_test_classes()
	var manager = ReporterManager.new()

	# Set active reporters
	manager.set_active_reporters(["json", "junit"])
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

	var reporter = JUnitReporter.new(config)
	assert_true(reporter != null, "JUnit reporter should be created")
	assert_true(reporter.has_method("generate_report"), "Should be a TestReporter")

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

	var reporter = JSONReporter.new(config)
	assert_true(reporter != null, "JSON reporter should be created")
	assert_true(reporter.has_method("generate_report"), "Should be a TestReporter")

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

	var reporter = HTMLReporter.new(config)
	assert_true(reporter != null, "HTML reporter should be created")
	assert_true(reporter.has_method("generate_report"), "Should be a TestReporter")

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
	var reporter = JUnitReporter.new()

	# Generate report to a temporary file
	var temp_path = "res://test_temp_junit.xml"
	reporter.generate_report(test_suite, temp_path)

	# Check if file was created
	var file_exists = FileAccess.file_exists(temp_path)
	assert_true(file_exists, "JUnit report file should be created")

	if file_exists:
		# Check file contents
		var file = FileAccess.open(temp_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()

			# Check for expected XML structure
			assert_true(content.find('<testsuites>') != -1, "Should contain testsuites element")
			assert_true(content.find('<testsuite') != -1, "Should contain testsuite element")
			assert_true(content.find('<testcase') != -1, "Should contain testcase elements")
			assert_true(content.find('test_calculator_addition') != -1, "Should contain test name")

			# Clean up
			DirAccess.remove_absolute(temp_path)

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_json_report_generation() -> bool:
	"""Test JSON report generation"""
	_load_test_classes()
	var test_suite = _create_sample_test_suite()
	var reporter = JSONReporter.new()

	# Generate report to a temporary file
	var temp_path = "res://test_temp_report.json"
	reporter.generate_report(test_suite, temp_path)

	# Check if file was created
	var file_exists = FileAccess.file_exists(temp_path)
	assert_true(file_exists, "JSON report file should be created")

	if file_exists:
		# Check file contents
		var file = FileAccess.open(temp_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()

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
			DirAccess.remove_absolute(temp_path)

	# Clean up reporter
	if reporter and is_instance_valid(reporter):
		reporter.free()

	return true

func test_html_report_generation() -> bool:
	"""Test HTML report generation"""
	_load_test_classes()
	var test_suite = _create_sample_test_suite()
	var reporter = HTMLReporter.new()

	# Generate report to a temporary file
	var temp_path = "res://test_temp_report.html"
	reporter.generate_report(test_suite, temp_path)

	# Check if file was created
	var file_exists = FileAccess.file_exists(temp_path)
	assert_true(file_exists, "HTML report file should be created")

	if file_exists:
		# Check file contents
		var file = FileAccess.open(temp_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()

			# Check for expected HTML structure
			assert_true(content.find('<!DOCTYPE html>') != -1, "Should be valid HTML")
			assert_true(content.find('<title>GDSentry Test Report</title>') != -1, "Should have correct title")
			assert_true(content.find('test_calculator_addition') != -1, "Should contain test names")
			assert_true(content.find('Total Tests') != -1, "Should contain summary information")

			# Clean up
			DirAccess.remove_absolute(temp_path)

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

	var reporter = JUnitReporter.new(config)

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
	var reporter = JUnitReporter.new()
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
	var reporter = JUnitReporter.new()

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
	"""Test TestResult data structures work correctly"""
	_load_test_classes()
	# Test TestResultData
	var result = TestResult.create_test_result("test_name", "TestClass")
	assert_equals(result.test_name, "test_name", "Test name should be set")
	assert_equals(result.test_class, "TestClass", "Test class should be set")

	# Test status changes
	result.mark_passed()
	assert_equals(result.status, "passed", "Status should be passed")

	result.mark_failed("error message")
	assert_equals(result.status, "failed", "Status should be failed")
	assert_equals(result.error_message, "error message", "Error message should be set")

	# Test TestSuiteResult
	var suite = TestResult.create_test_suite("Test Suite")
	suite.add_test_result(result)
	assert_equals(suite.get_total_tests(), 1, "Should have 1 test")

	return true
