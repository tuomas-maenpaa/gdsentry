# GDSentry - Test Result Data Structures
# Comprehensive data structures for capturing detailed test execution results
#
# These structures provide the foundation for all reporter implementations,
# enabling detailed reporting, analysis, and CI/CD integration.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestResult

# Top-level variables for the main TestResult class
var test_results: Array = []
var suite_name: String = ""
var start_time: float = 0.0
var end_time: float = 0.0
var execution_time: float = 0.0

# ------------------------------------------------------------------------------
# TEST RESULT DATA STRUCTURE
# ------------------------------------------------------------------------------

class TestResultData:
	var test_name: String = ""
	var test_class: String = ""
	var test_category: String = ""
	var status: String = "unknown"  # "passed", "failed", "skipped", "error"
	var execution_time: float = 0.0
	var error_message: String = ""
	var stack_trace: String = ""
	var assertions: Array[TestAssertionData] = []
	var start_time: float = 0.0
	var end_time: float = 0.0
	var metadata: Dictionary = {}
	
	func _init(name: String = "", test_class_name: String = ""):
		test_name = name
		test_class = test_class_name
		start_time = Time.get_unix_time_from_system()

	func mark_passed() -> void:
		status = "passed"
		end_time = Time.get_unix_time_from_system()
		execution_time = end_time - start_time

	func mark_failed(message: String = "", trace: String = "") -> void:
		status = "failed"
		error_message = message
		stack_trace = trace
		end_time = Time.get_unix_time_from_system()
		execution_time = end_time - start_time

	func mark_error(message: String = "", trace: String = "") -> void:
		status = "error"
		error_message = message
		stack_trace = trace
		end_time = Time.get_unix_time_from_system()
		execution_time = end_time - start_time

	func mark_skipped(reason: String = "") -> void:
		status = "skipped"
		error_message = reason
		end_time = Time.get_unix_time_from_system()
		execution_time = end_time - start_time

	func add_assertion(assertion: TestAssertionData) -> void:
		assertions.append(assertion)

	func get_assertion_count() -> int:
		return assertions.size()

	func get_passed_assertion_count() -> int:
		var count = 0
		for assertion in assertions:
			if assertion.passed:
				count += 1
		return count

	func get_failed_assertion_count() -> int:
		return assertions.size() - get_passed_assertion_count()

# ------------------------------------------------------------------------------
# TEST ASSERTION DATA STRUCTURE
# ------------------------------------------------------------------------------
class TestAssertionData:
	var type: String = ""  # "equals", "true", "false", "null", "not_null", etc.
	var expected: Variant
	var actual: Variant
	var passed: bool = false
	var message: String = ""
	var timestamp: float = 0.0

	func _init(assertion_type: String, expected_value: Variant = null, actual_value: Variant = null):
		type = assertion_type
		expected = expected_value
		actual = actual_value
		timestamp = Time.get_unix_time_from_system()

	func mark_passed(custom_message: String = "") -> void:
		passed = true
		message = custom_message

	func mark_failed(custom_message: String = "") -> void:
		passed = false
		message = custom_message

# ------------------------------------------------------------------------------
# TEST SUITE RESULT AGGREGATOR
# ------------------------------------------------------------------------------
class TestSuiteResult:
	var suite_name: String = ""
	var test_results: Array[TestResultData] = []
	var start_time: float = 0.0
	var end_time: float = 0.0
	var execution_time: float = 0.0

	func _init(name: String = "GDSentry Test Suite"):
		suite_name = name
		start_time = Time.get_unix_time_from_system()

	func add_test_result(result: TestResultData) -> void:
		test_results.append(result)

	func complete() -> void:
		end_time = Time.get_unix_time_from_system()
		execution_time = end_time - start_time

	func get_total_tests() -> int:
		return test_results.size()

	func get_passed_tests() -> int:
		var count = 0
		for result in test_results:
			if result.status == "passed":
				count += 1
		return count

	func get_failed_tests() -> int:
		var count = 0
		for result in test_results:
			if result.status == "failed":
				count += 1
		return count

	func get_error_tests() -> int:
		var count = 0
		for result in test_results:
			if result.status == "error":
				count += 1
		return count

	func get_skipped_tests() -> int:
		var count = 0
		for result in test_results:
			if result.status == "skipped":
				count += 1
		return count

	func get_total_assertions() -> int:
		var count = 0
		for result in test_results:
			count += result.get_assertion_count()
		return count

	func get_passed_assertions() -> int:
		var count = 0
		for result in test_results:
			count += result.get_passed_assertion_count()
		return count

	func get_failed_assertions() -> int:
		return get_total_assertions() - get_passed_assertions()

	func get_success_rate() -> float:
		var total = get_total_tests()
		if total == 0:
			return 0.0
		return float(get_passed_tests()) / float(total) * 100.0

	func has_failures() -> bool:
		return get_failed_tests() > 0 or get_error_tests() > 0

# ------------------------------------------------------------------------------
# UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
static func create_test_result(test_name: String, test_class: String = "") -> TestResultData:
	"""Factory method for creating new test results"""
	return TestResultData.new(test_name, test_class)

static func create_assertion(type: String, expected: Variant = null, actual: Variant = null) -> TestAssertionData:
	"""Factory method for creating new assertions"""
	return TestAssertionData.new(type, expected, actual)

static func create_test_suite(suite_name_param: String = "GDSentry Test Suite") -> TestSuiteResult:
	"""Factory method for creating new test suites"""
	return TestSuiteResult.new(suite_name_param)

# ------------------------------------------------------------------------------
# SERIALIZATION HELPERS
# ------------------------------------------------------------------------------
static func test_result_to_dict(result: TestResultData) -> Dictionary:
	"""Convert TestResultData to dictionary for serialization"""
	var assertions_data = []
	for assertion in result.assertions:
		assertions_data.append(assertion_to_dict(assertion))

	return {
		"test_name": result.test_name,
		"test_class": result.test_class,
		"test_category": result.test_category,
		"status": result.status,
		"execution_time": result.execution_time,
		"error_message": result.error_message,
		"stack_trace": result.stack_trace,
		"assertions": assertions_data,
		"start_time": result.start_time,
		"end_time": result.end_time,
		"metadata": result.metadata
	}

static func assertion_to_dict(assertion: TestAssertionData) -> Dictionary:
	"""Convert TestAssertionData to dictionary for serialization"""
	return {
		"type": assertion.type,
		"expected": assertion.expected,
		"actual": assertion.actual,
		"passed": assertion.passed,
		"message": assertion.message,
		"timestamp": assertion.timestamp
	}

static func test_suite_to_dict(suite: TestSuiteResult) -> Dictionary:
	"""Convert TestSuiteResult to dictionary for serialization"""
	var results_data = []
	for result in suite.test_results:
		results_data.append(test_result_to_dict(result))

	return {
		"suite_name": suite.suite_name,
		"test_results": results_data,
		"start_time": suite.start_time,
		"end_time": suite.end_time,
		"execution_time": suite.execution_time,
		"summary": {
			"total_tests": suite.get_total_tests(),
			"passed_tests": suite.get_passed_tests(),
			"failed_tests": suite.get_failed_tests(),
			"error_tests": suite.get_error_tests(),
			"skipped_tests": suite.get_skipped_tests(),
			"total_assertions": suite.get_total_assertions(),
			"passed_assertions": suite.get_passed_assertions(),
			"failed_assertions": suite.get_failed_assertions(),
			"success_rate": suite.get_success_rate()
		}
	}
