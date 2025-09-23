# GDSentry - Base Test Class
# Abstract base class for all GDSentry tests
#
# Provides common testing functionality, lifecycle management,
# and result tracking for all test types
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name GDTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
@export var test_description: String = ""
@export var test_tags: Array[String] = []
@export var test_priority: String = "normal"  # low, normal, high, critical
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
# LIFECYCLE METHODS
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize test environment"""
	headless_mode = GDTestManager.is_headless_mode()

	# Initialize test results
	test_results = GDTestManager.create_test_results()

	# Validate that test_results has required structure
	if not test_results.has("start_time"):
		push_error("GDTest: test_results dictionary missing required 'start_time' property")
		test_results.start_time = 0.0  # Fallback

	test_results.start_time = Time.get_unix_time_from_system()
	test_start_time = test_results.start_time  # Backup for fallback

	# Setup headless shutdown if needed
	if headless_mode:
		GDTestManager.setup_headless_shutdown(self, test_timeout)

	# Log test start
	GDTestManager.log_test_start(get_test_suite_name())

	# Run test suite
	run_test_suite()

func _exit_tree() -> void:
	"""Cleanup when test finishes"""

	# Defensive programming: Ensure test_results has required structure
	if not test_results.has("start_time"):
		# Fallback initialization if start_time is missing
		if test_results.is_empty():
			test_results = GDTestManager.create_test_results()

		# Set default start_time if missing (use current time as fallback)
		test_results.start_time = test_start_time if test_start_time > 0.0 else Time.get_unix_time_from_system()

	# Set end time
	test_results.end_time = Time.get_unix_time_from_system()

	# Calculate execution time safely
	var start_time = test_results.get("start_time", test_results.end_time)
	var end_time = test_results.end_time
	test_results.execution_time = GDTestManager.calculate_execution_time(start_time, end_time)

	# Print final results
	GDTestManager.print_test_results(test_results, get_test_suite_name())

# ------------------------------------------------------------------------------
# ABSTRACT METHODS (TO BE OVERRIDDEN)
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Override this method to define your test suite
	This is where you call individual test methods"""
	push_error("GDTest.run_test_suite() must be overridden in subclass")
	pass

# ------------------------------------------------------------------------------
# TEST EXECUTION HELPERS
# ------------------------------------------------------------------------------
func run_test(test_method_name: String, test_callable: Callable) -> bool:
	"""Execute a single test method with proper error handling"""
	current_test_name = test_method_name
	var start_time = Time.get_time_dict_from_system()

	GDTestManager.log_test_info(get_test_suite_name(), "Running: " + test_method_name)

	var success = true
	var error_message = ""

	# Execute test with error handling
	var result = test_callable.call()
	if result is bool:
		success = result
	elif result is GDScript:
		# Handle async tests
		if result.has_method("call"):
			success = await result.call()
	else:
		success = true  # Assume success if no explicit return

	var end_time = Time.get_time_dict_from_system()
	var duration = GDTestManager.calculate_execution_time(
		Time.get_unix_time_from_datetime_dict(start_time),
		Time.get_unix_time_from_datetime_dict(end_time)
	)

	# Log result
	if success:
		GDTestManager.log_test_success(test_method_name, duration)
	else:
		GDTestManager.log_test_failure(test_method_name, error_message)

	# Record result
	GDTestManager.add_test_result(test_results, test_method_name, success, error_message)

	return success

# ------------------------------------------------------------------------------
# ASSERTION METHODS
# ------------------------------------------------------------------------------
func assert_true(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is true"""
	if not condition:
		var error_msg = message if not message.is_empty() else "Expected true, got false"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_false(condition: bool, message: String = "") -> bool:
	"""Assert that a condition is false"""
	if condition:
		var error_msg = message if not message.is_empty() else "Expected false, got true"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are equal"""
	if actual != expected:
		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [expected, actual]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_not_equals(actual: Variant, expected: Variant, message: String = "") -> bool:
	"""Assert that two values are not equal"""
	if actual == expected:
		var error_msg = message if not message.is_empty() else "Expected values to be different, but both are %s" % actual
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is null"""
	if value != null:
		var error_msg = message if not message.is_empty() else "Expected null, got %s" % value
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_not_null(value: Variant, message: String = "") -> bool:
	"""Assert that a value is not null"""
	if value == null:
		var error_msg = message if not message.is_empty() else "Expected non-null value, got null"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_greater_than(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is greater than expected"""
	if actual <= expected:
		var error_msg = message if not message.is_empty() else "Expected %s > %s" % [actual, expected]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_greater_than_or_equal(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is greater than or equal to expected"""
	if actual < expected:
		var error_msg = message if not message.is_empty() else "Expected %s >= %s" % [actual, expected]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_less_than(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is less than expected"""
	if actual >= expected:
		var error_msg = message if not message.is_empty() else "Expected %s < %s" % [actual, expected]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_less_than_or_equal(actual: float, expected: float, message: String = "") -> bool:
	"""Assert that actual is less than or equal to expected"""
	if actual > expected:
		var error_msg = message if not message.is_empty() else "Expected %s <= %s" % [actual, expected]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_in_range(value: float, min_val: float, max_val: float, message: String = "") -> bool:
	"""Assert that a value is within a range"""
	if value < min_val or value > max_val:
		var error_msg = message if not message.is_empty() else "Expected %s to be between %s and %s" % [value, min_val, max_val]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_type(value: Variant, expected_type: int, message: String = "") -> bool:
	"""Assert that a value is of a specific type"""
	if typeof(value) != expected_type:
		var error_msg = message if not message.is_empty() else "Expected %s, got %s" % [expected_type, value.get_class()]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_has_method(value: Object, method_name: String, message: String = "") -> bool:
	"""Assert that a value has a specific method"""
	if not value.has_method(method_name):
		var error_msg = message if not message.is_empty() else "Expected %s to have method: %s" % [value.get_class(), method_name]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

# ------------------------------------------------------------------------------
# GODOT-SPECIFIC ASSERTIONS
# ------------------------------------------------------------------------------
func assert_node_exists(root: Node, path: String, message: String = "") -> bool:
	"""Assert that a node exists at the given path"""
	var node = root.get_node_or_null(path)
	if node == null:
		var error_msg = message if not message.is_empty() else "Node not found at path: %s" % path
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_scene_loads(scene_path: String, message: String = "") -> bool:
	"""Assert that a scene can be loaded"""
	var scene = GDTestManager.load_scene_safely(scene_path)
	if scene == null:
		var error_msg = message if not message.is_empty() else "Failed to load scene: %s" % scene_path
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false
	return true

func assert_signal_emitted(_emitter: Object, signal_name: String, message: String = "") -> bool:
	"""Assert that a signal has been emitted"""
	# This is a simplified version - full implementation would track signal emissions
	var error_msg = message if not message.is_empty() else "Signal emission tracking not implemented for: %s" % signal_name
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func get_test_suite_name() -> String:
	"""Get the name of this test suite"""
	return get_class() if not get_class().is_empty() else "GDTest"

func wait_for_signal(emitter: Object, signal_name: String, timeout: float = 5.0) -> bool:
	"""Wait for a signal to be emitted"""
	var signal_received = [false]  # Use array to work around lambda capture limitation
	var callable = func(): signal_received[0] = true

	emitter.connect(signal_name, callable)

	var start_time = Time.get_time_dict_from_system()["second"]
	while not signal_received[0]:
		await get_tree().process_frame
		var current_time = Time.get_time_dict_from_system()["second"]
		if current_time - start_time > timeout:
			emitter.disconnect(signal_name, callable)
			return false

	emitter.disconnect(signal_name, callable)
	return true

func wait_for_condition(condition: Callable, timeout: float = 5.0) -> bool:
	"""Wait for a condition to become true"""
	var start_time = Time.get_time_dict_from_system()["second"]
	while not condition.call():
		await get_tree().process_frame
		var current_time = Time.get_time_dict_from_system()["second"]
		if current_time - start_time > timeout:
			return false
	return true

func create_timer_and_wait(duration: float) -> void:
	"""Create a timer and wait for it to complete"""
	await get_tree().create_timer(duration).timeout

# ------------------------------------------------------------------------------
# SETUP/TEARDOWN METHODS (OPTIONAL OVERRIDES)
# ------------------------------------------------------------------------------
func setup() -> void:
	"""Override this method to run setup code before each test"""
	pass

func teardown() -> void:
	"""Override this method to run cleanup code after each test"""
	pass

func setup_suite() -> void:
	"""Override this method to run setup code once for the entire suite"""
	pass

func teardown_suite() -> void:
	"""Override this method to run cleanup code once for the entire suite"""
	pass

# ------------------------------------------------------------------------------
# TEST FIXTURE MANAGEMENT (ENTERPRISE FEATURE)
# ------------------------------------------------------------------------------
class TestFixture:

	# Fixture states
	enum FixtureState {
		UNINITIALIZED,
		INITIALIZING,
		READY,
		FAILED,
		CLEANING_UP,
		CLEANED_UP
	}

# Fixture data structure
class FixtureData:
	var name: String
	var state: TestFixture.FixtureState = TestFixture.FixtureState.UNINITIALIZED
	var instance: Object = null
	var dependencies: Array[String] = []
	var cleanup_methods: Array[String] = []
	var error_message: String = ""

	func _init(fixture_name: String, deps: Array[String] = []):
		name = fixture_name
		dependencies = deps

# Fixture registry
var _fixtures: Dictionary = {}
var _fixture_order: Array[String] = []

func register_fixture(fixture_name: String, factory_method: Callable, dependencies: Array[String] = [], cleanup_methods: Array[String] = []) -> void:
	"""Register a test fixture with optional dependencies and cleanup methods"""
	if _fixtures.has(fixture_name):
		push_warning("GDTest: Fixture '%s' already registered, overwriting" % fixture_name)

	var fixture_data = FixtureData.new(fixture_name, dependencies)
	fixture_data.cleanup_methods = cleanup_methods

	_fixtures[fixture_name] = {
		"data": fixture_data,
		"factory": factory_method
	}

	# Add to order if not already present
	if not _fixture_order.has(fixture_name):
		_fixture_order.append(fixture_name)

func unregister_fixture(fixture_name: String) -> void:
	"""Unregister a test fixture"""
	if _fixtures.has(fixture_name):
		_fixtures.erase(fixture_name)
		_fixture_order.erase(fixture_name)

func get_fixture(fixture_name: String) -> Object:
	"""Get a fixture instance, initializing it if necessary"""
	if not _fixtures.has(fixture_name):
		push_error("GDTest: Fixture '%s' not registered" % fixture_name)
		return null

	var fixture_entry = _fixtures[fixture_name]
	var fixture_data: FixtureData = fixture_entry.data

	# Check if fixture is ready
	if fixture_data.state == TestFixture.FixtureState.READY:
		return fixture_data.instance

	# Check if fixture is already initializing (circular dependency)
	if fixture_data.state == TestFixture.FixtureState.INITIALIZING:
		push_error("GDTest: Circular dependency detected for fixture '%s'" % fixture_name)
		return null

	# Initialize dependencies first
	for dep in fixture_data.dependencies:
		if not get_fixture(dep):
			push_error("GDTest: Failed to initialize dependency '%s' for fixture '%s'" % [dep, fixture_name])
			fixture_data.state = TestFixture.FixtureState.FAILED
			return null

	# Initialize fixture
	fixture_data.state = TestFixture.FixtureState.INITIALIZING
	var factory: Callable = fixture_entry.factory

	if factory.is_valid():
		fixture_data.instance = factory.call()
		if fixture_data.instance:
			fixture_data.state = TestFixture.FixtureState.READY
			return fixture_data.instance
		else:
			push_error("GDTest: Fixture factory for '%s' returned null" % fixture_name)
			fixture_data.state = TestFixture.FixtureState.FAILED
			return null
	else:
		push_error("GDTest: Invalid fixture factory for '%s'" % fixture_name)
		fixture_data.state = TestFixture.FixtureState.FAILED
		return null

func cleanup_fixture(fixture_name: String) -> bool:
	"""Manually cleanup a specific fixture"""
	if not _fixtures.has(fixture_name):
		push_warning("GDTest: Fixture '%s' not registered" % fixture_name)
		return false

	var fixture_entry = _fixtures[fixture_name]
	var fixture_data: FixtureData = fixture_entry.data

	if fixture_data.state == TestFixture.FixtureState.UNINITIALIZED:
		return true  # Nothing to cleanup

	if fixture_data.state == TestFixture.FixtureState.CLEANING_UP:
		push_warning("GDTest: Fixture '%s' already being cleaned up" % fixture_name)
		return false

	fixture_data.state = TestFixture.FixtureState.CLEANING_UP

	# Run cleanup methods
	var success = true
	for cleanup_method in fixture_data.cleanup_methods:
		if fixture_data.instance and fixture_data.instance.has_method(cleanup_method):
			var result = fixture_data.instance.call(cleanup_method)
			if result is bool and not result:
				push_warning("GDTest: Cleanup method '%s' on fixture '%s' returned false" % [cleanup_method, fixture_name])
				success = false

	# Cleanup instance
	if fixture_data.instance:
		if fixture_data.instance is Node:
			fixture_data.instance.queue_free()
		fixture_data.instance = null

	fixture_data.state = TestFixture.FixtureState.CLEANED_UP
	return success

func cleanup_all_fixtures() -> bool:
	"""Cleanup all registered fixtures in reverse dependency order"""
	var success = true

	# Create reverse order for cleanup (dependencies first)
	var cleanup_order = _fixture_order.duplicate()
	cleanup_order.reverse()

	for fixture_name in cleanup_order:
		if not cleanup_fixture(fixture_name):
			success = false

	_fixtures.clear()
	_fixture_order.clear()

	return success

func reset_fixture(fixture_name: String) -> bool:
	"""Reset a fixture to uninitialized state (will be re-initialized on next access)"""
	if not _fixtures.has(fixture_name):
		push_warning("GDTest: Fixture '%s' not registered" % fixture_name)
		return false

	var fixture_entry = _fixtures[fixture_name]
	var fixture_data: FixtureData = fixture_entry.data

	# Cleanup first if necessary
	if fixture_data.state == TestFixture.FixtureState.READY:
		cleanup_fixture(fixture_name)

	fixture_data.state = TestFixture.FixtureState.UNINITIALIZED
	fixture_data.instance = null

	return true

# ------------------------------------------------------------------------------
# AUTOMATIC FIXTURE LIFECYCLE MANAGEMENT
# ------------------------------------------------------------------------------
func _setup_test_fixtures() -> bool:
	"""Internal method to setup all fixtures before test execution"""
	var success = true

	for fixture_name in _fixture_order:
		if not get_fixture(fixture_name):
			push_error("GDTest: Failed to setup fixture '%s'" % fixture_name)
			success = false

	return success

func _cleanup_test_fixtures() -> bool:
	"""Internal method to cleanup all fixtures after test execution"""
	return cleanup_all_fixtures()

# ------------------------------------------------------------------------------
# FIXTURE LIFECYCLE INTEGRATION
# ------------------------------------------------------------------------------
func run_test_with_fixtures(test_method_name: String, test_callable: Callable) -> bool:
	"""Run a test with automatic fixture setup and cleanup"""
	# Setup fixtures
	if not _setup_test_fixtures():
		push_error("GDTest: Failed to setup fixtures for test '%s'" % test_method_name)
		return false

	# Run test
	var test_result = test_callable.call()

	# Cleanup fixtures
	if not _cleanup_test_fixtures():
		push_warning("GDTest: Some fixtures failed to cleanup for test '%s'" % test_method_name)

	return test_result if test_result is bool else true

# ------------------------------------------------------------------------------
# CONFIGURATION MANAGEMENT (ENTERPRISE FEATURE)
# ------------------------------------------------------------------------------
class TestConfig:
	var config_data: Dictionary = {}
	var environment: String = "default"
	var config_files: Array[String] = []
	var is_loaded: bool = false

	func _init(env: String = "default"):
		environment = env
		_load_default_config()

	func _load_default_config() -> void:
		"""Load default configuration values"""
		config_data = {
			# Test execution settings
			"test_timeout": 30.0,
			"max_parallel_tests": 4,
			"fail_fast": false,
			"verbose_logging": false,

			# Reporting settings
			"generate_reports": true,
			"report_format": "json",
			"report_directory": "res://test_reports/",

			# Assertion settings
			"floating_point_tolerance": 0.0001,
			"string_comparison_case_sensitive": true,

			# Performance settings
			"performance_monitoring": true,
			"memory_threshold_mb": 100,

			# UI Testing settings
			"ui_test_delay": 0.1,
			"ui_wait_timeout": 5.0,

			# Visual Testing settings
			"screenshot_directory": "res://test_screenshots/",
			"visual_tolerance": 0.01,

			# Event Testing settings
			"input_delay": 0.1,
			"event_timeout": 2.0,

			# Physics Testing settings
			"physics_fps": 60,
			"physics_simulation_speed": 1.0,

			# Database/Mock settings
			"mock_strict_mode": false,
			"use_real_services": false
		}

	func load_from_file(file_path: String) -> bool:
		"""Load configuration from a JSON file"""
		var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")
		var file = FileSystemCompatibility.open_file(file_path, FileSystemCompatibility.READ)
		if not file:
			push_error("TestConfig: Cannot open config file: %s" % file_path)
			return false

		var json_text = FileSystemCompatibility.get_file_as_text(file)
		FileSystemCompatibility.close_file(file)

		var json = JSON.new()
		var parse_result = json.parse(json_text)

		if parse_result != OK:
			push_error("TestConfig: Failed to parse config file %s: %s" % [file_path, json.get_error_message()])
			return false

		var file_config = json.get_data()
		if typeof(file_config) != TYPE_DICTIONARY:
			push_error("TestConfig: Config file %s must contain a dictionary" % file_path)
			return false

		# Merge with existing config (file config takes precedence)
		_merge_config(file_config)
		config_files.append(file_path)
		is_loaded = true

		return true

	func load_from_environment() -> void:
		"""Load configuration from environment variables"""
		var env_config = {}

		# Test execution settings
		if OS.has_environment("GDSENTRY_TEST_TIMEOUT"):
			env_config["test_timeout"] = float(OS.get_environment("GDSENTRY_TEST_TIMEOUT"))
		if OS.has_environment("GDSENTRY_MAX_PARALLEL"):
			env_config["max_parallel_tests"] = int(OS.get_environment("GDSENTRY_MAX_PARALLEL"))
		if OS.has_environment("GDSENTRY_FAIL_FAST"):
			env_config["fail_fast"] = OS.get_environment("GDSENTRY_FAIL_FAST").to_lower() == "true"

		# Environment-specific overrides
		var env_overrides = _get_environment_overrides()
		_merge_config(env_overrides)

		if not env_config.is_empty():
			_merge_config(env_config)

	func _get_environment_overrides() -> Dictionary:
		"""Get environment-specific configuration overrides"""
		var overrides = {}

		match environment:
			"development":
				overrides = {
					"verbose_logging": true,
					"fail_fast": false,
					"test_timeout": 60.0
				}
			"testing":
				overrides = {
					"verbose_logging": true,
					"generate_reports": true,
					"fail_fast": true
				}
			"ci":
				overrides = {
					"verbose_logging": false,
					"generate_reports": true,
					"max_parallel_tests": 8,
					"fail_fast": true
				}
			"production":
				overrides = {
					"verbose_logging": false,
					"performance_monitoring": true,
					"memory_threshold_mb": 200
				}

		return overrides

	func _merge_config(new_config: Dictionary) -> void:
		"""Merge new configuration with existing config"""
		for key in new_config:
			config_data[key] = new_config[key]

	func get_value(key: String, default_value: Variant = null) -> Variant:
		"""Get a configuration value"""
		if config_data.has(key):
			return config_data[key]
		return default_value

	func set_value(key: String, value: Variant) -> void:
		"""Set a configuration value"""
		config_data[key] = value

	func save_to_file(file_path: String) -> bool:
		"""Save current configuration to a file"""
		var json_text = JSON.stringify(config_data, "\t")

		var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")
		var file = FileSystemCompatibility.open_file(file_path, FileSystemCompatibility.WRITE)
		if not file:
			push_error("TestConfig: Cannot write to config file: %s" % file_path)
			return false

		FileSystemCompatibility.store_string(file, json_text)
		FileSystemCompatibility.close_file(file)

		if not config_files.has(file_path):
			config_files.append(file_path)

		return true

	func validate() -> Array:
		"""Validate configuration values and return any errors"""
		var errors = []

		# Validate test_timeout
		var timeout = get_value("test_timeout", 30.0)
		if typeof(timeout) != TYPE_FLOAT or timeout <= 0:
			errors.append("test_timeout must be a positive number")

		# Validate max_parallel_tests
		var max_parallel = get_value("max_parallel_tests", 4)
		if typeof(max_parallel) != TYPE_INT or max_parallel < 1:
			errors.append("max_parallel_tests must be a positive integer")

		# Validate floating_point_tolerance
		var tolerance = get_value("floating_point_tolerance", 0.0001)
		if typeof(tolerance) != TYPE_FLOAT or tolerance < 0:
			errors.append("floating_point_tolerance must be a non-negative number")

		# Validate memory_threshold_mb
		var memory_threshold = get_value("memory_threshold_mb", 100)
		if typeof(memory_threshold) != TYPE_INT or memory_threshold < 0:
			errors.append("memory_threshold_mb must be a non-negative integer")

		return errors

	func get_summary() -> String:
		"""Get a summary of the current configuration"""
		var summary = "TestConfig Summary:\n"
		summary += "- Environment: %s\n" % environment
		summary += "- Loaded files: %s\n" % str(config_files)
		summary += "- Total settings: %d\n" % config_data.size()

		# Key settings summary
		summary += "\nKey Settings:\n"
		summary += "- Test timeout: %.1fs\n" % get_value("test_timeout", 30.0)
		summary += "- Max parallel tests: %d\n" % get_value("max_parallel_tests", 4)
		summary += "- Fail fast: %s\n" % str(get_value("fail_fast", false))
		summary += "- Verbose logging: %s\n" % str(get_value("verbose_logging", false))

		return summary

# ------------------------------------------------------------------------------
# CONFIGURATION MANAGEMENT METHODS
# ------------------------------------------------------------------------------
var _test_config: TestConfig = null

func get_test_config() -> TestConfig:
	"""Get the test configuration instance"""
	if _test_config == null:
		var environment = _detect_environment()
		_test_config = TestConfig.new(environment)
		_load_test_configuration()
	return _test_config

func _detect_environment() -> String:
	"""Detect the current test environment"""
	# Check environment variables first
	if OS.has_environment("GDSENTRY_ENV"):
		return OS.get_environment("GDSENTRY_ENV")

	# Check for CI environment
	if OS.has_environment("CI") or OS.has_environment("CONTINUOUS_INTEGRATION"):
		return "ci"

	# Check for development vs production
	if OS.is_debug_build():
		return "development"
	else:
		return "production"

func _load_test_configuration() -> void:
	"""Load test configuration from various sources"""
	if _test_config == null:
		return

	# Load from environment variables
	_test_config.load_from_environment()

	# Try to load from standard config files
	var config_paths = [
		"res://test_config.json",
		"res://config/test_config.json",
		"user://test_config.json"
	]

	var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")
	for path in config_paths:
		if FileSystemCompatibility.file_exists(path):
			if _test_config.load_from_file(path):
				print("GDTest: Loaded configuration from %s" % path)
				break

	# Validate configuration
	var validation_errors = _test_config.validate()
	if not validation_errors.is_empty():
		for error in validation_errors:
			push_warning("GDTest: Configuration validation error: %s" % error)

func get_config_value(key: String, default_value: Variant = null) -> Variant:
	"""Get a configuration value"""
	return get_test_config().get_value(key, default_value)

func set_config_value(key: String, value: Variant) -> void:
	"""Set a configuration value"""
	get_test_config().set_value(key, value)

func save_test_config(file_path: String = "res://test_config.json") -> bool:
	"""Save current test configuration to a file"""
	return get_test_config().save_to_file(file_path)

func get_config_summary() -> String:
	"""Get a summary of the current test configuration"""
	return get_test_config().get_summary()

# ------------------------------------------------------------------------------
# ENVIRONMENT-SPECIFIC CONFIGURATION
# ------------------------------------------------------------------------------
func is_development_environment() -> bool:
	"""Check if running in development environment"""
	return get_test_config().environment == "development"

func is_ci_environment() -> bool:
	"""Check if running in CI environment"""
	return get_test_config().environment == "ci"

func is_testing_environment() -> bool:
	"""Check if running in testing environment"""
	return get_test_config().environment == "testing"

func should_generate_reports() -> bool:
	"""Check if reports should be generated based on configuration"""
	return get_config_value("generate_reports", true)

func get_test_timeout() -> float:
	"""Get the configured test timeout"""
	return get_config_value("test_timeout", 30.0)

func should_fail_fast() -> bool:
	"""Check if tests should fail fast"""
	return get_config_value("fail_fast", false)

func is_verbose_logging_enabled() -> bool:
	"""Check if verbose logging is enabled"""
	return get_config_value("verbose_logging", false)

# ------------------------------------------------------------------------------
# CONFIGURATION-DRIVEN TEST BEHAVIOR
# ------------------------------------------------------------------------------
func _setup_test_with_config() -> void:
	"""Setup test behavior based on configuration"""
	if is_verbose_logging_enabled():
		print("GDTest: Verbose logging enabled")

	if should_fail_fast():
		print("GDTest: Fail-fast mode enabled")

func _cleanup_test_with_config() -> void:
	"""Cleanup based on configuration"""
	if should_generate_reports():
		# Generate test reports if configured
		_generate_test_report()

func _generate_test_report() -> void:
	"""Generate a test report based on configuration"""
	var report_dir = get_config_value("report_directory", "res://test_reports/")
	var report_format = get_config_value("report_format", "json")

	# Ensure report directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(report_dir.replace("res://", "")):
		dir.make_dir_recursive(report_dir.replace("res://", ""))

	# Generate report based on format
	var report_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"environment": get_test_config().environment,
		"test_suite": get_class(),
		"configuration": get_test_config().config_data
	}

	match report_format:
		"json":
		var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")
		var report_path = report_dir + "test_report_%s.json" % Time.get_unix_time_from_system()
		var file = FileSystemCompatibility.open_file(report_path, FileSystemCompatibility.WRITE)
		if file:
			FileSystemCompatibility.store_string(file, JSON.stringify(report_data, "\t"))
				FileSystemCompatibility.close_file(file)
				if is_verbose_logging_enabled():
					print("GDTest: Generated JSON report at %s" % report_path)

		"text":
		var report_path = report_dir + "test_report_%s.txt" % Time.get_unix_time_from_system()
		var file = FileSystemCompatibility.open_file(report_path, FileSystemCompatibility.WRITE)
		if file:
			FileSystemCompatibility.store_string(file, get_config_summary())
				FileSystemCompatibility.close_file(file)
				if is_verbose_logging_enabled():
					print("GDTest: Generated text report at %s" % report_path)

# ------------------------------------------------------------------------------
# MOCKING UTILITIES (ENTERPRISE FEATURE)
# ------------------------------------------------------------------------------
class MockObject:
	var _mock_calls: Array = []
	var _mock_returns: Dictionary = {}
	var _mock_original_methods: Dictionary = {}
	var _mock_name: String = ""

	func _init(mock_name: String = ""):
		_mock_name = mock_name if not mock_name.is_empty() else "MockObject"

	func _call_method(method_name: String, args: Array) -> Variant:
		# Record the method call
		var call_info = {
			"method": method_name,
			"args": args.duplicate(),
			"timestamp": Time.get_unix_time_from_system()
		}
		_mock_calls.append(call_info)

		# Check if we have a stubbed return value
		var return_key = method_name
		if args.size() > 0:
			return_key += "(" + str(args) + ")"

		if _mock_returns.has(return_key):
			return _mock_returns[return_key]
		elif _mock_returns.has(method_name):
			return _mock_returns[method_name]

		# Default return values based on method name patterns
		if method_name.begins_with("get_") or method_name.begins_with("is_"):
			return null
		elif method_name.begins_with("has_") or method_name.begins_with("can_"):
			return false
		elif method_name.begins_with("count") or method_name.begins_with("size"):
			return 0

		return null

	func when(method_name: String) -> MockStubBuilder:
		"""Start stubbing a method call"""
		return MockStubBuilder.new(self, method_name)

	func verify(method_name: String) -> MockVerifier:
		"""Start verifying method calls"""
		return MockVerifier.new(self, method_name)

	func get_call_count(method_name: String) -> int:
		"""Get the number of times a method was called"""
		var count = 0
		for mock_call in _mock_calls:
			if mock_call.method == method_name:
				count += 1
		return count

	func get_calls(method_name: String) -> Array:
		"""Get all calls to a specific method"""
		var calls = []
		for mock_call in _mock_calls:
			if mock_call.method == method_name:
				calls.append(mock_call)
		return calls

	func reset() -> void:
		"""Reset the mock object state"""
		_mock_calls.clear()
		_mock_returns.clear()
		_mock_original_methods.clear()

	func get_call_history() -> Array:
		"""Get the complete call history"""
		return _mock_calls.duplicate()

class MockStubBuilder:
	var _mock: MockObject
	var _method_name: String
	var _args: Array = []

	func _init(mock: MockObject, method_name: String):
		_mock = mock
		_method_name = method_name

	func with_args(args: Array) -> MockStubBuilder:
		"""Specify arguments for the stubbed method"""
		_args = args.duplicate()
		return self

	func then_return(value: Variant) -> void:
		"""Specify the return value for the stubbed method"""
		var return_key = _method_name
		if _args.size() > 0:
			return_key += "(" + str(_args) + ")"

		_mock._mock_returns[return_key] = value

	func then_call(callable: Callable) -> void:
		"""Specify a callable to execute instead of returning a value"""
		var return_key = _method_name
		if _args.size() > 0:
			return_key += "(" + str(_args) + ")"

		_mock._mock_returns[return_key] = callable

class MockVerifier:
	var _mock: MockObject
	var _method_name: String

	func _init(mock: MockObject, method_name: String):
		_mock = mock
		_method_name = method_name

	func was_called() -> bool:
		"""Verify that the method was called at least once"""
		return _mock.get_call_count(_method_name) > 0

	func was_called_times(count: int) -> bool:
		"""Verify that the method was called exactly 'count' times"""
		return _mock.get_call_count(_method_name) == count

	func was_called_with(args: Array) -> bool:
		"""Verify that the method was called with specific arguments"""
		var calls = _mock.get_calls(_method_name)
		for mock_call in calls:
			if mock_call.args == args:
				return true
		return false

	func was_never_called() -> bool:
		"""Verify that the method was never called"""
		return _mock.get_call_count(_method_name) == 0

	func was_called_at_least_once() -> bool:
		"""Verify that the method was called at least once (alias for was_called)"""
		return was_called()

	func get_call_count() -> int:
		"""Get the actual call count for this method"""
		return _mock.get_call_count(_method_name)

# ------------------------------------------------------------------------------
# MOCK OBJECT CREATION METHODS
# ------------------------------------------------------------------------------
var _created_mocks: Array = []

func create_mock(mock_name: String = "") -> MockObject:
	"""Create a new mock object"""
	var mock = MockObject.new(mock_name)
	_created_mocks.append(mock)
	return mock

func create_mock_from_class(base_class: String, mock_name: String = "") -> MockObject:
	"""Create a mock object that behaves like a specific class"""
	var mock = MockObject.new(mock_name if not mock_name.is_empty() else base_class)

	# Add common methods that most classes have
	mock.when("get_class").then_return(base_class)

	# Mock is_class method to return true when class_name matches base_class
	var check_class = func(class_name_to_check: String) -> bool:
		return class_name_to_check == base_class
	mock.when("is_class").then_call(check_class)

	_created_mocks.append(mock)
	return mock

func create_partial_mock(real_object: Object, mock_name: String = "") -> MockObject:
	"""Create a partial mock that delegates to a real object for unstubbed methods"""
	var mock = MockObject.new(mock_name if not mock_name.is_empty() else real_object.get_class())

	# Store reference to real object for delegation
	mock._real_object = real_object

	_created_mocks.append(mock)
	return mock

func cleanup_mocks() -> void:
	"""Clean up all created mock objects"""
	for mock in _created_mocks:
		if mock is MockObject:
			mock.reset()
	_created_mocks.clear()

# ------------------------------------------------------------------------------
# VERIFICATION HELPERS
# ------------------------------------------------------------------------------
func verify(mock: MockObject, method_name: String) -> MockVerifier:
	"""Helper method to create a verifier for a mock"""
	return mock.verify(method_name)

func when(mock: MockObject, method_name: String) -> MockStubBuilder:
	"""Helper method to create a stub builder for a mock"""
	return mock.when(method_name)

# ------------------------------------------------------------------------------
# MOCK LIFECYCLE INTEGRATION
# ------------------------------------------------------------------------------
func _setup_mocks_for_test() -> void:
	"""Setup mocks before test execution"""
	# Reset all existing mocks
	for mock in _created_mocks:
		if mock is MockObject:
			mock.reset()

func _cleanup_mocks_after_test() -> void:
	"""Cleanup mocks after test execution"""
	cleanup_mocks()

# ------------------------------------------------------------------------------
# ASSERTION EXTENSIONS FOR MOCKING
# ------------------------------------------------------------------------------
func assert_method_called(mock: MockObject, method_name: String, message: String = "") -> bool:
	"""Assert that a method was called on a mock"""
	var verifier = mock.verify(method_name)
	if not verifier.was_called():
		var error_msg = message if not message.is_empty() else "Expected method '%s' to be called on mock" % method_name
		push_error(error_msg)
		return false
	return true

func assert_method_called_times(mock: MockObject, method_name: String, expected_count: int, message: String = "") -> bool:
	"""Assert that a method was called a specific number of times"""
	var verifier = mock.verify(method_name)
	if not verifier.was_called_times(expected_count):
		var actual_count = verifier.get_call_count()
		var error_msg = message if not message.is_empty() else "Expected method '%s' to be called %d times, but was called %d times" % [method_name, expected_count, actual_count]
		push_error(error_msg)
		return false
	return true

func assert_method_called_with(mock: MockObject, method_name: String, expected_args: Array, message: String = "") -> bool:
	"""Assert that a method was called with specific arguments"""
	var verifier = mock.verify(method_name)
	if not verifier.was_called_with(expected_args):
		var error_msg = message if not message.is_empty() else "Expected method '%s' to be called with args %s, but wasn't" % [method_name, str(expected_args)]
		push_error(error_msg)
		return false
	return true

func assert_method_never_called(mock: MockObject, method_name: String, message: String = "") -> bool:
	"""Assert that a method was never called"""
	var verifier = mock.verify(method_name)
	if not verifier.was_never_called():
		var actual_count = verifier.get_call_count()
		var error_msg = message if not message.is_empty() else "Expected method '%s' to never be called, but was called %d times" % [method_name, actual_count]
		push_error(error_msg)
		return false
	return true
