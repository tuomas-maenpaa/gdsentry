# GDSentry Self-Test Base Class
# Simplified base class for self-testing without external dependencies
#
# This class provides the minimal functionality needed for self-tests
# without depending on GDTestManager or other framework components.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTree

class_name GDSentrySelfTestBase

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
@export var test_description: String = ""
@export var test_tags: Array[String] = []
@export var test_priority: String = "normal"
@export var test_author: String = ""
@export var test_timeout: float = 30.0
@export var test_category: String = "general"

# ------------------------------------------------------------------------------
# TEST STATE
# ------------------------------------------------------------------------------
var test_results: Dictionary = {}
var test_start_time: float = 0.0
var test_end_time: float = 0.0
var current_test_name: String = ""
var headless_mode: bool = false

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init() -> void:
	"""Initialize the test environment"""
	headless_mode = true  # Assume headless for self-tests

	# Initialize basic test results structure
	test_results = {
		"start_time": Time.get_unix_time_from_system(),
		"end_time": 0.0,
		"execution_time": 0.0,
		"total_tests": 0,
		"passed_tests": 0,
		"failed_tests": 0,
		"skipped_tests": 0,
		"test_results": []
	}

	# Run test suite when ready (will be called in _ready for SceneTree compatibility)
	# run_test_suite()  # Commented out - will be called in _ready

func _ready() -> void:
	"""Called when SceneTree is ready - run tests here"""
	call_deferred("_run_test_suite_safe")

# ------------------------------------------------------------------------------
# ABSTRACT METHODS (TO BE OVERRIDDEN)
# ------------------------------------------------------------------------------
func _execute_test_suite() -> bool:
	"""Override this method to define your test suite"""
	push_error("_execute_test_suite() must be overridden in subclass")
	return false

# ------------------------------------------------------------------------------
# TEST EXECUTION HELPERS
# ------------------------------------------------------------------------------
func run_test(test_method_name: String, test_callable: Callable) -> bool:
	"""Execute a single test method with proper error handling"""
	current_test_name = test_method_name
	var start_time = Time.get_time_dict_from_system()

	print("🧪 Running: " + test_method_name)

	var success = true
	var _error_message = ""

	# Execute test with error handling
	var result = test_callable.call()
	if result is bool:
		success = result
	else:
		# Assume success if no explicit return
		success = true

	var end_time = Time.get_time_dict_from_system()
	var duration = Time.get_unix_time_from_datetime_dict(end_time) - Time.get_unix_time_from_datetime_dict(start_time)

	# Log result
	if success:
		print("✅ %s PASSED (%.2fs)" % [test_method_name, duration])
	else:
		print("❌ %s FAILED (%.2fs)" % [test_method_name, duration])

	# Record result
	test_results.passed_tests += 1 if success else 0
	test_results.failed_tests += 1 if not success else 0
	test_results.total_tests += 1

	return success

# ------------------------------------------------------------------------------
# ASSERTION METHODS
# ------------------------------------------------------------------------------
func assert_true(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is true"""
	if not condition:
		var error_msg = message if not message.is_empty() else "Expected true, got false"
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_false(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is false"""
	if condition:
		var error_msg = message if not message.is_empty() else "Expected false, got true"
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are equal"""
	if actual != expected:
		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [expected, actual]
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_not_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are not equal"""
	if actual == expected:
		var error_msg = message if not message.is_empty() else "Expected values to be different, but both are %s" % actual
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is null"""
	if value != null:
		var error_msg = message if not message.is_empty() else "Expected null, got %s" % value
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_not_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is not null"""
	if value == null:
		var error_msg = message if not message.is_empty() else "Expected non-null value, got null"
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_greater_than(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is greater than expected"""
	if actual <= expected:
		var error_msg = message if not message.is_empty() else "Expected %s > %s" % [actual, expected]
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_less_than(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is less than expected"""
	if actual >= expected:
		var error_msg = message if not message.is_empty() else "Expected %s < %s" % [actual, expected]
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

func assert_in_range(value: float, min_val: float, max_val: float, message: String = "") -> bool:
	"""Assert that a value is within a range"""
	if value < min_val or value > max_val:
		var error_msg = message if not message.is_empty() else "Expected %s to be between %s and %s" % [value, min_val, max_val]
		print("❌ ASSERTION FAILED: " + error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func get_test_suite_name() -> String:
	"""Get the test suite name"""
	return get_script().resource_path.get_file().get_basename()

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _finalize() -> void:
	"""Finalize test execution"""
	test_results.end_time = Time.get_unix_time_from_system()
	test_results.execution_time = test_results.end_time - test_results.start_time

	print("\n📊 Test Results for %s:" % get_test_suite_name())
	print("   Total: %d" % test_results.total_tests)
	print("   Passed: %d" % test_results.passed_tests)
	print("   Failed: %d" % test_results.failed_tests)
	print("   Execution time: %.2fs" % test_results.execution_time)

	# Exit immediately - no timer needed in headless mode
	quit()
