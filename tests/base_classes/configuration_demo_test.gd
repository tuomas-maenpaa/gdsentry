# GDSentry - Configuration Management Demonstration
# Demonstrates the enterprise configuration capabilities of GDSentry
#
# Features demonstrated:
# - Environment detection and configuration
# - File-based configuration loading
# - Environment variable support
# - Configuration validation
# - Environment-specific overrides
# - Runtime configuration management
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name ConfigurationDemoTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Demonstrate enterprise configuration management"
	test_tags = ["configuration", "enterprise", "environment", "validation"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# CONFIGURATION LOADING TESTS
# ------------------------------------------------------------------------------
func test_configuration_loading() -> bool:
	"""Test basic configuration loading and access"""
	print("🧪 Testing configuration loading...")

	var success = true

	# Test configuration instance creation
	var config = get_test_config()
	success = success and assert_not_null(config, "Configuration should be created")
	success = success and assert_true(config is TestConfig, "Should be TestConfig instance")

	# Test default values
	var timeout = get_config_value("test_timeout", 30.0)
	success = success and assert_equals(timeout, 30.0, "Default timeout should be 30.0")

	var max_parallel = get_config_value("max_parallel_tests", 4)
	success = success and assert_equals(max_parallel, 4, "Default max parallel should be 4")

	if success:
		print("✅ Configuration loading test passed")
	else:
		print("❌ Configuration loading test failed")

	return success

func test_environment_detection() -> bool:
	"""Test automatic environment detection"""
	print("🧪 Testing environment detection...")

	var success = true

	# Test environment detection methods
	var is_dev = is_development_environment()
	var is_ci = is_ci_environment()
	var is_testing = is_testing_environment()

	# At least one environment should be detected
	var has_environment = is_dev or is_ci or is_testing
	success = success and assert_true(has_environment, "Should detect at least one environment")

	# Test configuration environment
	var config_env = get_test_config().environment
	success = success and assert_not_null(config_env, "Configuration should have environment")
	success = success and assert_type(config_env, TYPE_STRING, "Environment should be string")

	print("Detected environment: %s" % config_env)

	if success:
		print("✅ Environment detection test passed")
	else:
		print("❌ Environment detection test failed")

	return success

func test_configuration_file_loading() -> bool:
	"""Test loading configuration from JSON files"""
	print("🧪 Testing configuration file loading...")

	var success = true

	# Create a test configuration file
	var test_config = {
		"test_timeout": 60.0,
		"max_parallel_tests": 8,
		"fail_fast": true,
		"verbose_logging": true,
		"custom_setting": "test_value"
	}

	var config_path = "res://test_config_temp.json"
	var file = FileAccess.open(config_path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(test_config, "\t"))
		file.close()

		# Test loading the configuration
		var loaded = get_test_config().load_from_file(config_path)
		success = success and assert_true(loaded, "Configuration should load successfully")

		# Test loaded values
		var timeout = get_config_value("test_timeout")
		success = success and assert_equals(timeout, 60.0, "Loaded timeout should be 60.0")

		var max_parallel = get_config_value("max_parallel_tests")
		success = success and assert_equals(max_parallel, 8, "Loaded max parallel should be 8")

		var custom_value = get_config_value("custom_setting")
		success = success and assert_equals(custom_value, "test_value", "Custom setting should be loaded")

		# Clean up test file
		DirAccess.remove_absolute(config_path)

	else:
		push_warning("Could not create test config file")
		success = false

	if success:
		print("✅ Configuration file loading test passed")
	else:
		print("❌ Configuration file loading test failed")

	return success

func test_configuration_validation() -> bool:
	"""Test configuration validation"""
	print("🧪 Testing configuration validation...")

	var success = true

	var config = TestConfig.new("testing")

	# Test valid configuration
	var valid_config = {
		"test_timeout": 45.0,
		"max_parallel_tests": 6,
		"floating_point_tolerance": 0.001,
		"memory_threshold_mb": 150
	}

	config._merge_config(valid_config)
	var errors = config.validate()
	success = success and assert_equals(errors.size(), 0, "Valid config should have no errors")

	# Test invalid configuration
	var invalid_config = {
		"test_timeout": -5.0,  # Invalid negative timeout
		"max_parallel_tests": 0,  # Invalid zero parallel
		"floating_point_tolerance": -0.1,  # Invalid negative tolerance
		"memory_threshold_mb": -100  # Invalid negative memory
	}

	config.config_data = config.config_data.duplicate()  # Reset to defaults
	config._merge_config(invalid_config)
	errors = config.validate()

	success = success and assert_greater_than(errors.size(), 0, "Invalid config should have errors")
	success = success and assert_true(errors.size() >= 4, "Should have at least 4 validation errors")

	if success:
		print("✅ Configuration validation test passed")
	else:
		print("❌ Configuration validation test failed")

	return success

func test_environment_specific_configuration() -> bool:
	"""Test environment-specific configuration overrides"""
	print("🧪 Testing environment-specific configuration...")

	var success = true

	# Test different environments
	var environments = ["development", "testing", "ci", "production"]

	for env in environments:
		var config = TestConfig.new(env)
		var env_overrides = config._get_environment_overrides()

		success = success and assert_not_null(env_overrides, "Environment %s should have overrides" % env)
		success = success and assert_type(env_overrides, TYPE_DICTIONARY, "Overrides should be dictionary")

		# Each environment should have some specific settings
		success = success and assert_greater_than(env_overrides.size(), 0, "Environment %s should have overrides" % env)

	if success:
		print("✅ Environment-specific configuration test passed")
	else:
		print("❌ Environment-specific configuration test failed")

	return success

func test_runtime_configuration_management() -> bool:
	"""Test runtime configuration value management"""
	print("🧪 Testing runtime configuration management...")

	var success = true

	# Test setting and getting values
	set_config_value("custom_test_setting", "test_value")
	var retrieved_value = get_config_value("custom_test_setting")
	success = success and assert_equals(retrieved_value, "test_value", "Should retrieve set value")

	# Test default values
	var default_value = get_config_value("nonexistent_setting", "default")
	success = success and assert_equals(default_value, "default", "Should return default for nonexistent setting")

	# Test different data types
	set_config_value("int_setting", 42)
	set_config_value("float_setting", 3.14)
	set_config_value("bool_setting", true)
	set_config_value("array_setting", [1, 2, 3])

	success = success and assert_equals(get_config_value("int_setting"), 42, "Int setting should work")
	success = success and assert_equals(get_config_value("float_setting"), 3.14, "Float setting should work")
	success = success and assert_equals(get_config_value("bool_setting"), true, "Bool setting should work")
	success = success and assert_equals(get_config_value("array_setting"), [1, 2, 3], "Array setting should work")

	if success:
		print("✅ Runtime configuration management test passed")
	else:
		print("❌ Runtime configuration management test failed")

	return success

func test_configuration_driven_behavior() -> bool:
	"""Test configuration-driven test behavior"""
	print("🧪 Testing configuration-driven behavior...")

	var success = true

	# Test helper methods
	var timeout = get_test_timeout()
	success = success and assert_type(timeout, TYPE_FLOAT, "Timeout should be float")
	success = success and assert_greater_than(timeout, 0, "Timeout should be positive")

	var fail_fast_value = should_fail_fast()
	success = success and assert_type(fail_fast_value, TYPE_BOOL, "Fail fast should be boolean")

	var generate_reports_value = should_generate_reports()
	success = success and assert_type(generate_reports_value, TYPE_BOOL, "Generate reports should be boolean")

	var is_verbose = is_verbose_logging_enabled()
	success = success and assert_type(is_verbose, TYPE_BOOL, "Verbose logging should be boolean")

	# Test environment checks
	var dev_env = is_development_environment()
	var ci_env = is_ci_environment()
	var test_env = is_testing_environment()

	success = success and assert_type(dev_env, TYPE_BOOL, "Development env check should be boolean")
	success = success and assert_type(ci_env, TYPE_BOOL, "CI env check should be boolean")
	success = success and assert_type(test_env, TYPE_BOOL, "Testing env check should be boolean")

	if success:
		print("✅ Configuration-driven behavior test passed")
	else:
		print("❌ Configuration-driven behavior test failed")

	return success

func test_configuration_summary() -> bool:
	"""Test configuration summary generation"""
	print("🧪 Testing configuration summary...")

	var success = true

	var summary = get_config_summary()
	success = success and assert_not_null(summary, "Summary should not be null")
	success = success and assert_type(summary, TYPE_STRING, "Summary should be string")
	success = success and assert_greater_than(summary.length(), 0, "Summary should not be empty")

	# Summary should contain key information
	success = success and assert_true(summary.contains("TestConfig Summary"), "Summary should contain title")
	success = success and assert_true(summary.contains("Environment:"), "Summary should contain environment")
	success = success and assert_true(summary.contains("Total settings:"), "Summary should contain settings count")

	if success:
		print("✅ Configuration summary test passed")
		print("📋 Configuration Summary:")
		print(summary)
	else:
		print("❌ Configuration summary test failed")

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE TEST
# ------------------------------------------------------------------------------
func test_configuration_performance() -> bool:
	"""Test configuration access performance"""
	print("🧪 Testing configuration performance...")

	var success = true

	# Measure performance of configuration access
	var start_time = Time.get_time_dict_from_system()

	const NUM_ACCESSES = 1000
	for i in range(NUM_ACCESSES):
		var _timeout = get_config_value("test_timeout")
		var _parallel = get_config_value("max_parallel_tests")
		var _fail_fast = get_config_value("fail_fast")

	var end_time = Time.get_time_dict_from_system()
	var elapsed = Time.get_unix_time_from_datetime_dict(end_time) - Time.get_unix_time_from_datetime_dict(start_time)

	# Performance should be very fast (less than 0.05 seconds for 1000 accesses)
	success = success and assert_less_than(elapsed, 0.05, "Configuration access should be fast")

	if success:
		print("✅ Configuration performance test passed (%.4fs for %d accesses)" % [elapsed, NUM_ACCESSES])
	else:
		print("❌ Configuration performance test failed")

	return success

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	print("\n🚀 Running Configuration Management Test Suite\n")

	run_test("test_configuration_loading", func(): return test_configuration_loading())
	run_test("test_environment_detection", func(): return test_environment_detection())
	run_test("test_configuration_file_loading", func(): return test_configuration_file_loading())
	run_test("test_configuration_validation", func(): return test_configuration_validation())
	run_test("test_environment_specific_configuration", func(): return test_environment_specific_configuration())
	run_test("test_runtime_configuration_management", func(): return test_runtime_configuration_management())
	run_test("test_configuration_driven_behavior", func(): return test_configuration_driven_behavior())
	run_test("test_configuration_summary", func(): return test_configuration_summary())
	run_test("test_configuration_performance", func(): return test_configuration_performance())

	print("\n✨ Configuration Management Test Suite Complete ✨\n")
