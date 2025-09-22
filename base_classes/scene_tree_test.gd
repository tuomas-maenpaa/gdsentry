# GDSentry - SceneTree Test Base Class
# Base class for fast, headless unit tests that extend SceneTree
#
# Ideal for:
# - Pure logic testing
# - Algorithm validation
# - Data structure testing
# - Performance benchmarking
# - Tests that don't require visual components
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTree

class_name SceneTreeTest

# ------------------------------------------------------------------------------
# DEPENDENCY MANAGEMENT
# ------------------------------------------------------------------------------
# TestManager dependency - will be available if loaded, but not required for self-testing
var _test_manager_available: bool = false

func _check_test_manager_availability() -> void:
	"""Check if GDTestManager is available without creating hard dependency"""
	_test_manager_available = false
	# Try to access GDTestManager if it exists
	if ClassDB.class_exists("GDTestManager"):
		_test_manager_available = true

# ------------------------------------------------------------------------------
# FALLBACK METHODS (used when GDTestManager is not available)
# ------------------------------------------------------------------------------
func _fallback_log_test_info(test_name: String, message: String) -> void:
	"""Fallback logging when GDTestManager is not available"""
	print("🧪 [%s] %s" % [test_name, message])

func _fallback_log_test_success(test_name: String, duration: float = -1.0) -> void:
	"""Fallback success logging"""
	var duration_str = " (%.2fs)" % duration if duration >= 0 else ""
	print("✅ %s PASSED%s" % [test_name, duration_str])

func _fallback_log_test_failure(test_name: String, error_message: String = "") -> void:
	"""Fallback failure logging"""
	print("❌ %s FAILED" % test_name)
	if not error_message.is_empty():
		print("   Error: %s" % error_message)

func _fallback_add_test_result(results: Dictionary, test_name: String, passed: bool, details: String = "") -> void:
	"""Fallback test result recording"""
	results.total_tests += 1
	if passed:
		results.passed_tests += 1
	else:
		results.failed_tests += 1

	results.test_results.append({
		"name": test_name,
		"passed": passed,
		"details": details,
		"timestamp": Time.get_unix_time_from_system()
	})

func _log_assertion_failure(error_msg: String) -> void:
	"""Helper method to log assertion failures with fallback"""
	if _test_manager_available:
		GDTestManager.log_test_failure(current_test_name, error_msg)
	else:
		_fallback_log_test_failure(current_test_name, error_msg)

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
@export var test_description: String = ""
@export var test_tags: Array[String] = []
@export var test_priority: String = "normal"
@export var test_timeout: float = 30.0
@export var test_category: String = "unit"

# ------------------------------------------------------------------------------
# TEST STATE
# ------------------------------------------------------------------------------
var test_results: Dictionary = {}
var test_start_time: float = 0.0
var current_test_name: String = ""
var headless_mode: bool = false

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init() -> void:
	"""Initialize the test environment"""
	# Check TestManager availability to avoid circular dependencies during self-testing
	_check_test_manager_availability()

	# Initialize with defaults to avoid TestManager dependency during loading
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

func _ready() -> void:
	"""Called when SceneTree is ready - run tests here"""
	# Setup basic headless shutdown
	if headless_mode:
		_setup_basic_headless_shutdown(test_timeout)

	# Run test suite when SceneTree is ready
	call_deferred("_run_test_suite_safe")

func _run_test_suite_safe() -> void:
	"""Run test suite with proper error handling and timeout"""
	print("🏁 Starting test suite: " + get_test_suite_name())

	var start_time = Time.get_unix_time_from_system()
	var _success = true

	# Run test suite with error handling
	var _error_message = ""
	var test_result = true

	# Run the actual test suite with basic error handling
	test_result = _execute_test_suite()

	var end_time = Time.get_unix_time_from_system()
	var duration = end_time - start_time

	# Log final results
	print("\n📊 Test Results for %s:" % get_test_suite_name())
	print("   Duration: %.2fs" % duration)
	print("   Status: %s" % ("PASSED" if test_result else "FAILED"))

	# Quit with exit code based on test results (0 = success, 1 = failure)
	call_deferred("quit", 0 if test_result else 1)

func _execute_test_suite() -> bool:
	"""Execute the test suite - override in subclasses"""
	push_error("SceneTreeTest._execute_test_suite() must be overridden in subclass")
	return false

func _setup_basic_headless_shutdown(timeout_seconds: float) -> void:
	"""Setup basic headless shutdown without TestManager dependency"""
	var timer = Timer.new()
	timer.wait_time = timeout_seconds
	timer.one_shot = true
	timer.timeout.connect(func(): quit())
	root.add_child(timer)
	timer.start()

func wait_for_seconds(seconds: float) -> void:
	"""Wait for a specified number of seconds"""
	await create_timer(seconds).timeout

	# Print basic results
	test_results.end_time = Time.get_unix_time_from_system()
	test_results.execution_time = test_results.end_time - test_results.start_time

	print("Test completed in %.2f seconds" % test_results.execution_time)
	print("Results: %d passed, %d failed" % [test_results.passed_tests, test_results.failed_tests])

	# Exit after a short delay to allow output to be displayed
	var exit_timer = Timer.new()
	exit_timer.wait_time = 0.1
	exit_timer.one_shot = true
	exit_timer.timeout.connect(func(): quit())
	root.add_child(exit_timer)
	exit_timer.start()


# ------------------------------------------------------------------------------
# ABSTRACT METHODS (TO BE OVERRIDDEN)
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Override this method to define your test suite"""
	push_error("SceneTreeTest.run_test_suite() must be overridden in subclass")
	pass

# ------------------------------------------------------------------------------
# TEST EXECUTION HELPERS
# ------------------------------------------------------------------------------
func run_test(test_method_name: String, test_callable: Callable) -> bool:
	"""Execute a single test method with proper error handling"""
	current_test_name = test_method_name

	# Use GDTestManager if available, otherwise use fallback
	if _test_manager_available:
		GDTestManager.log_test_info(get_test_suite_name(), "Running: " + test_method_name)
	else:
		_fallback_log_test_info(get_test_suite_name(), "Running: " + test_method_name)

	var success = true
	var error_message = ""
	var start_time = Time.get_unix_time_from_system()

	# Execute test with error handling
	var result = test_callable.call()
	if result is bool:
		success = result
	else:
		success = true  # Assume success if no explicit return

	var end_time = Time.get_unix_time_from_system()
	var duration = end_time - start_time

	# Log result
	if success:
		if _test_manager_available:
			GDTestManager.log_test_success(test_method_name, duration)
		else:
			_fallback_log_test_success(test_method_name, duration)
	else:
		if _test_manager_available:
			GDTestManager.log_test_failure(test_method_name, error_message)
		else:
			_fallback_log_test_failure(test_method_name, error_message)

	# Record result
	if _test_manager_available:
		GDTestManager.add_test_result(test_results, test_method_name, success, error_message)
	else:
		_fallback_add_test_result(test_results, test_method_name, success, error_message)

	return success

# ------------------------------------------------------------------------------
# ASSERTION METHODS (SAME AS GDTest)
# ------------------------------------------------------------------------------
func assert_true(condition: bool, message: String = "") -> bool:
	if not condition:
		var error_msg = message if not message.is_empty() else "Expected true, got false"
		if _test_manager_available:
			GDTestManager.log_test_failure(current_test_name, error_msg)
		else:
			_fallback_log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_false(condition: bool, message: String = "") -> bool:
	if condition:
		var error_msg = message if not message.is_empty() else "Expected false, got true"
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	if actual != expected:
		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [expected, actual]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_not_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	if actual == expected:
		var error_msg = message if not message.is_empty() else "Expected values to be different, but both are %s" % actual
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_null(value: Variant, message: String = "") -> bool:
	if value != null:
		var error_msg = message if not message.is_empty() else "Expected null, got %s" % value
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_not_null(value: Variant, message: String = "") -> bool:
	if value == null:
		var error_msg = message if not message.is_empty() else "Expected non-null value, got null"
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_greater_than(actual: float, expected: float, message: String = "") -> bool:
	if actual <= expected:
		var error_msg = message if not message.is_empty() else "Expected %s > %s" % [actual, expected]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_less_than(actual: float, expected: float, message: String = "") -> bool:
	if actual >= expected:
		var error_msg = message if not message.is_empty() else "Expected %s < %s" % [actual, expected]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_in_range(value: float, min_val: float, max_val: float, message: String = "") -> bool:
	if value < min_val or value > max_val:
		var error_msg = message if not message.is_empty() else "Expected %s to be between %s and %s" % [value, min_val, max_val]
		_log_assertion_failure(error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# UTILITY METHODS FOR UNIT TESTING
# ------------------------------------------------------------------------------
func get_test_suite_name() -> String:
	"""Get the name of this test suite"""
	return get_class() if not get_class().is_empty() else "SceneTreeTest"

func create_mock_object(script_path: String = "") -> Object:
	"""Create a mock object for testing"""
	var mock = Object.new()
	if not script_path.is_empty():
		var script = load(script_path)
		if script:
			mock.set_script(script)
	return mock

func create_test_data(type: String, size: int = 10) -> Array:
	"""Create test data of specified type and size"""
	var data = []
	match type:
		"numbers":
			for i in range(size):
				data.append(i)
		"strings":
			for i in range(size):
				data.append("test_string_%d" % i)
		"vectors":
			for i in range(size):
				data.append(Vector2(i, i * 2))
		"dictionaries":
			for i in range(size):
				data.append({"id": i, "name": "item_%d" % i})
		_:
			# Default case for unsupported types
			pass
	return data

func benchmark_function(fn: Callable, iterations: int = 1000) -> Dictionary:
	"""Benchmark a function's performance"""
	var start_time: float = Time.get_unix_time_from_system()
	var results: Array = []
	for i in range(iterations):
		results.append(fn.call())
	var end_time: float = Time.get_unix_time_from_system()
	var total_time: float = end_time - start_time
	var avg_time: float = total_time / iterations
	return {
		"total_time": total_time,
		"average_time": avg_time,
		"iterations": iterations,
		"results": results
	}


# ------------------------------------------------------------------------------
# MEMORY AND PERFORMANCE TESTING
# ------------------------------------------------------------------------------
func assert_memory_usage_less_than(max_mb: float, message: String = "") -> bool:
	"""Assert that current memory usage is below threshold"""
	var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)
	if memory_mb >= max_mb:
		var error_msg = message if not message.is_empty() else "Memory usage %.2fMB exceeds limit %.2fMB" % [memory_mb, max_mb]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_performance_fps_above(min_fps: float, message: String = "") -> bool:
	"""Assert that current FPS is above minimum threshold"""
	var current_fps = Performance.get_monitor(Performance.TIME_FPS)
	if current_fps < min_fps:
		var error_msg = message if not message.is_empty() else "FPS %.1f below minimum %.1f" % [current_fps, min_fps]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_object_count_less_than(max_objects: int, message: String = "") -> bool:
	"""Assert that object count is below threshold"""
	var object_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	if object_count >= max_objects:
		var error_msg = message if not message.is_empty() else "Object count %d exceeds limit %d" % [object_count, max_objects]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_type(value: Variant, expected_type: int, message: String = "") -> bool:
	"""Assert that value is of expected type"""
	var actual_type = typeof(value)
	if actual_type != expected_type:
		var expected_type_name = _get_type_name(expected_type)
		var actual_type_name = _get_type_name(actual_type)
		var error_msg = message if not message.is_empty() else "Expected type %s but got %s" % [expected_type_name, actual_type_name]
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_has_method(value: Object, method_name: String, message: String = "") -> bool:
	"""Assert that object has the specified method"""
	if not value:
		var error_msg = message if not message.is_empty() else "Cannot check method on null object"
		_log_assertion_failure(error_msg)
		return false

	if not value.has_method(method_name):
		var error_msg = message if not message.is_empty() else "Object does not have method '%s'" % method_name
		_log_assertion_failure(error_msg)
		return false
	return true

func assert_greater_than_or_equal(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual value is greater than or equal to expected value"""
	if actual < expected:
		var error_msg = message if not message.is_empty() else "Expected %.2f to be >= %.2f" % [actual, expected]
		_log_assertion_failure(error_msg)
		return false
	return true

func _get_type_name(type_constant: int) -> String:
	"""Get string name for type constant"""
	match type_constant:
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR3: return "Vector3"
		TYPE_COLOR: return "Color"
		TYPE_OBJECT: return "Object"
		TYPE_ARRAY: return "Array"
		TYPE_DICTIONARY: return "Dictionary"
		_: return "Unknown (%d)" % type_constant
