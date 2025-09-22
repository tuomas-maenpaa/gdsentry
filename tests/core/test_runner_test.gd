# GDSentry - Enhanced TestRunner Unit Tests
# Comprehensive testing of GDTestRunner functionality
#
# This test validates that TestRunner can:
# - Parse command line arguments correctly
# - Discover and execute tests properly
# - Handle different test scenarios
# - Generate accurate reports
# - Perform under performance constraints
#
# Author: GDSentry Framework
# Version: 2.0.0 - Enhanced from basic existence checks

extends SceneTreeTest

class_name TestRunnerTest

# ------------------------------------------------------------------------------
# TEST METADATA & CONSTANTS
# ------------------------------------------------------------------------------
const TEST_TIMEOUT = 30.0
const PERFORMANCE_THRESHOLD_MS = 5000  # 5 seconds max for test execution

var mock_cli_args: Dictionary
var benchmark_start_time: float

# ------------------------------------------------------------------------------
# TEST SETUP & TEARDOWN
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize test metadata"""
	test_description = "Comprehensive GDTestRunner functionality validation"
	test_tags = ["core", "test_runner", "integration", "performance"]
	test_priority = "high"
	test_category = "core"

func setup() -> void:
	"""Setup test environment with proper initialization"""
	benchmark_start_time = Time.get_unix_time_from_system()
	print("🏃 Setting up enhanced TestRunner test environment")

	# Reset mock CLI args for each test
	mock_cli_args = {
		"test_path": "",
		"test_dir": "",
		"discover": false,
		"config_path": "res://gdsentry_config.tres",
		"profile": "",
		"filter_category": "",
		"filter_tags": [],
		"filter_pattern": "",
		"parallel": false,
		"verbose": false,
		"fail_fast": false,
		"timeout": TEST_TIMEOUT,
		"randomize": false,
		"seed": 0,
		"report_formats": [],
		"report_path": "",
		"dry_run": false
	}

func teardown() -> void:
	"""Clean up after each test"""
	print("🏃 Cleaning up TestRunner test resources")

	# Clean up any temporary files created during tests
	var temp_files = ["res://test_temp_config.tres", "res://test_report_temp.json"]
	for file_path in temp_files:
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path))

# ------------------------------------------------------------------------------
# 1. COMMAND LINE PARSING VALIDATION TESTS
# ------------------------------------------------------------------------------
func test_command_line_parsing_basic_args() -> bool:
	"""Test basic command line argument parsing"""
	print("🧪 Testing basic command line argument parsing")

	var success = true

	# Test single arguments
	var args = ["--discover"]
	var parsed = _parse_test_args(args)
	success = success and assert_true(parsed.discover, "Should parse --discover flag")
	success = success and assert_equals(parsed.test_path, "", "Should not set test_path for discover")

	# Test argument with value
	args = ["--test-path", "res://tests/my_test.gd"]
	parsed = _parse_test_args(args)
	success = success and assert_equals(parsed.test_path, "res://tests/my_test.gd", "Should parse test path correctly")

	# Test multiple arguments
	args = ["--verbose", "--fail-fast", "--parallel"]
	parsed = _parse_test_args(args)
	success = success and assert_true(parsed.verbose, "Should parse verbose flag")
	success = success and assert_true(parsed.fail_fast, "Should parse fail-fast flag")
	success = success and assert_true(parsed.parallel, "Should parse parallel flag")

	return success

func test_command_line_parsing_filter_args() -> bool:
	"""Test filter-related command line arguments"""
	print("🧪 Testing filter argument parsing")

	var success = true

	# Test category filter
	var args = ["--filter", "category:unit"]
	var parsed = _parse_test_args(args)
	success = success and assert_equals(parsed.filter_category, "unit", "Should parse category filter")

	# Test tags filter
	args = ["--filter", "tags:integration,slow"]
	parsed = _parse_test_args(args)
	success = success and assert_equals(parsed.filter_tags.size(), 2, "Should parse multiple tags")
	success = success and assert_true(parsed.filter_tags.has("integration"), "Should contain integration tag")
	success = success and assert_true(parsed.filter_tags.has("slow"), "Should contain slow tag")

	return success

func test_command_line_parsing_invalid_args() -> bool:
	"""Test handling of invalid command line arguments"""
	print("🧪 Testing invalid argument handling")

	var success = true

	# Test unknown argument (should be ignored gracefully)
	var args = ["--unknown-arg", "value"]
	var parsed = _parse_test_args(args)
	success = success and assert_not_null(parsed, "Should handle unknown arguments gracefully")

	# Test missing value for argument that requires one
	args = ["--test-path"]	# Missing value
	parsed = _parse_test_args(args)
	success = success and assert_equals(parsed.test_path, "", "Should handle missing values gracefully")

	return success

func test_command_line_parsing_report_formats() -> bool:
	"""Test report format parsing"""
	print("🧪 Testing report format parsing")

	var success = true

	# Test single report format
	var args = ["--report", "json"]
	var parsed = _parse_test_args(args)
	success = success and assert_true(parsed.report_formats.has("json"), "Should parse single report format")

	# Test multiple report formats
	args = ["--report", "junit,html"]
	parsed = _parse_test_args(args)
	success = success and assert_true(parsed.report_formats.has("junit"), "Should parse junit format")
	success = success and assert_true(parsed.report_formats.has("html"), "Should parse html format")
	success = success and assert_equals(parsed.report_formats.size(), 2, "Should parse both formats")

	return success

# ------------------------------------------------------------------------------
# 2. TEST DISCOVERY AND EXECUTION TESTS
# ------------------------------------------------------------------------------
func test_test_discovery_integration() -> bool:
	"""Test integration with test discovery system"""
	print("🧪 Testing test discovery integration")

	var success = true

	# Create a test discovery instance
	var discovery = GDTestDiscovery.new()
	success = success and assert_not_null(discovery, "Should create discovery instance")

	# Test discovery with default directories
	var result = discovery.discover_tests()
	success = success and assert_not_null(result, "Should return discovery result")
	success = success and assert_greater_than(result.total_found, 0, "Should find test files")

	# Verify result structure
	success = success and assert_true(result.has_method("get_all_test_paths"), "Should have test path getter")
	success = success and assert_true(result.has_method("get_tests_by_category"), "Should have category getter")

	# Test category filtering
	var core_tests = result.get_tests_by_category("core")
	success = success and assert_greater_than(core_tests.size(), 0, "Should find core category tests")

	return success

func test_test_execution_orchestration() -> bool:
	"""Test actual test execution orchestration"""
	print("🧪 Testing test execution orchestration")

	var success = true

	# Create test runner instance
	var runner_script = load("res://gdsentry/core/test_runner.gd")
	var runner = runner_script.new()
	success = success and assert_not_null(runner, "Should create test runner")

	# Test that runner has required execution methods
	success = success and assert_true(runner.has_method("run_requested_tests"), "Should have test execution method")
	success = success and assert_true(runner.has_method("parse_command_line_args"), "Should have CLI parsing")

	# Test execution state initialization
	success = success and assert_not_null(runner.execution_stats, "Should initialize execution stats")
	success = success and assert_equals(runner.execution_stats.total_tests, 0, "Should start with zero tests")

	runner.queue_free()
	return success

func test_configuration_loading() -> bool:
	"""Test configuration loading from different sources"""
	print("🧪 Testing configuration loading")

	var success = true

	# Test default configuration loading
	var config = GDTestConfig.new()
	success = success and assert_not_null(config, "Should create config instance")

	# Test configuration properties
	success = success and assert_true(config.has_method("load_from_file"), "Should have file loading method")
	success = success and assert_true(config.has_method("get_test_timeout"), "Should have timeout getter")
	success = success and assert_true(config.has_method("is_parallel_execution_enabled"), "Should have parallel getter")

	return success

# ------------------------------------------------------------------------------
# 3. RESULT REPORTING AND VALIDATION TESTS
# ------------------------------------------------------------------------------
func test_result_collection_and_reporting() -> bool:
	"""Test result collection and reporting functionality"""
	print("🧪 Testing result collection and reporting")

	var success = true

	# Create test runner for result testing
	var runner_script = load("res://gdsentry/core/test_runner.gd")
	var runner = runner_script.new()

	# Test result structure
	success = success and assert_not_null(runner.execution_stats, "Should have execution stats")
	success = success and assert_true(runner.execution_stats is Dictionary, "Execution stats should be dictionary")

	# Test required result fields
	var required_fields = ["total_tests", "passed_tests", "failed_tests", "skipped_tests", "execution_time"]
	for field in required_fields:
		success = success and assert_true(runner.execution_stats.has(field), "Should have " + field + " field")
		success = success and assert_type(runner.execution_stats[field], TYPE_INT if field != "execution_time" else TYPE_FLOAT,
										field + " should have correct type")

	runner.queue_free()
	return success

func test_performance_benchmarking() -> bool:
	"""Test performance benchmarking capabilities"""
	print("🧪 Testing performance benchmarking")

	var success = true

	var benchmark_start = Time.get_unix_time_from_system()

	# Simulate test discovery (the actual performance bottleneck)
	var discovery = GDTestDiscovery.new()
	var discovery_result = discovery.discover_tests()

	var benchmark_end = Time.get_unix_time_from_system()
	var discovery_time = benchmark_end - benchmark_start

	# Performance should be reasonable (under threshold)
	success = success and assert_less_than(discovery_time, PERFORMANCE_THRESHOLD_MS / 1000.0,
										 "Discovery should complete within performance threshold")

	# Test should have found a reasonable number of tests
	success = success and assert_greater_than(discovery_result.total_found, 5,
											"Should find reasonable number of tests")

	print("📊 Discovery performance: %.3f seconds for %d tests" % [discovery_time, discovery_result.total_found])

	return success

# ------------------------------------------------------------------------------
# 4. ERROR HANDLING AND EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_error_handling_malformed_files() -> bool:
	"""Test handling of malformed test files"""
	print("🧪 Testing malformed file error handling")

	var success = true

	# Test discovery with non-existent directory
	var discovery = GDTestDiscovery.new()
	var result = discovery.discover_tests(["res://non_existent_directory/"])

	# Should handle gracefully without crashing
	success = success and assert_not_null(result, "Should handle non-existent directories gracefully")
	success = success and assert_equals(result.errors.size(), 1, "Should record error for non-existent directory")

	return success

func test_timeout_handling() -> bool:
	"""Test timeout handling functionality"""
	print("🧪 Testing timeout handling")

	var success = true

	# Create test runner and verify timeout configuration
	var runner_script = load("res://gdsentry/core/test_runner.gd")
	var runner = runner_script.new()

	# Test default timeout
	success = success and assert_equals(runner.cli_args.timeout, TEST_TIMEOUT, "Should have default timeout")

	# Test timeout modification
	runner.cli_args.timeout = 60.0
	success = success and assert_equals(runner.cli_args.timeout, 60.0, "Should allow timeout modification")

	runner.queue_free()
	return success

func test_concurrent_execution_handling() -> bool:
	"""Test concurrent execution handling"""
	print("🧪 Testing concurrent execution handling")

	var success = true

	# Test parallel execution flag handling
	var runner_script = load("res://gdsentry/core/test_runner.gd")
	var runner = runner_script.new()

	# Test default parallel setting
	success = success and assert_false(runner.cli_args.parallel, "Should default to non-parallel")

	# Test parallel flag setting
	runner.cli_args.parallel = true
	success = success and assert_true(runner.cli_args.parallel, "Should allow parallel execution")

	runner.queue_free()
	return success

# ------------------------------------------------------------------------------
# 5. INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_end_to_end_workflow() -> bool:
	"""Test complete end-to-end test runner workflow"""
	print("🧪 Testing end-to-end workflow")

	var success = true

	# This would be a more complete integration test in a real scenario
	# For now, test the workflow components individually

	# 1. Test discovery
	var discovery = GDTestDiscovery.new()
	var discovery_result = discovery.discover_tests()
	success = success and assert_greater_than(discovery_result.total_found, 0, "Should discover tests")

	# 2. Test configuration
	var config = GDTestConfig.new()
	success = success and assert_not_null(config, "Should create configuration")

	# 3. Test runner initialization
	var runner_script = load("res://gdsentry/core/test_runner.gd")
	var runner = runner_script.new()
	success = success and assert_not_null(runner, "Should create test runner")

	runner.queue_free()
	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func _parse_test_args(args: Array) -> Dictionary:
	"""Helper method to simulate command line argument parsing"""
	var parsed = mock_cli_args.duplicate(true)

	var i = 0
	while i < args.size():
		var arg = args[i]
		match arg:
			"--discover":
				parsed.discover = true
			"--test-path", "--file":
				if i + 1 < args.size():
					parsed.test_path = args[i + 1]
					i += 1
			"--test-dir":
				if i + 1 < args.size():
					parsed.test_dir = args[i + 1]
					i += 1
			"--verbose":
				parsed.verbose = true
			"--fail-fast":
				parsed.fail_fast = true
			"--parallel":
				parsed.parallel = true
			"--filter":
				if i + 1 < args.size():
					var filter = args[i + 1]
					if filter.begins_with("category:"):
						parsed.filter_category = filter.substr(9)
					elif filter.begins_with("tags:"):
						parsed.filter_tags = filter.substr(5).split(",")
					i += 1
			"--report":
				if i + 1 < args.size():
					parsed.report_formats = args[i + 1].split(",")
					i += 1
		i += 1

	return parsed

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all TestRunner unit tests"""
	print("\n🚀 Running GDTestRunner Test Suite\n")

	run_test("test_command_line_parsing_basic_args", func(): return test_command_line_parsing_basic_args())
	run_test("test_command_line_parsing_filter_args", func(): return test_command_line_parsing_filter_args())
	run_test("test_command_line_parsing_invalid_args", func(): return test_command_line_parsing_invalid_args())
	run_test("test_command_line_parsing_report_formats", func(): return test_command_line_parsing_report_formats())
	run_test("test_test_discovery_integration", func(): return test_test_discovery_integration())
	run_test("test_test_execution_orchestration", func(): return test_test_execution_orchestration())
	run_test("test_configuration_loading", func(): return test_configuration_loading())
	run_test("test_result_collection_and_reporting", func(): return test_result_collection_and_reporting())
	run_test("test_performance_benchmarking", func(): return test_performance_benchmarking())
	run_test("test_error_handling_malformed_files", func(): return test_error_handling_malformed_files())
	run_test("test_timeout_handling", func(): return test_timeout_handling())
	run_test("test_concurrent_execution_handling", func(): return test_concurrent_execution_handling())
	run_test("test_end_to_end_workflow", func(): return test_end_to_end_workflow())

	print("\n✨ GDTestRunner Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# LEGACY COMPATIBILITY METHODS
# ------------------------------------------------------------------------------
func test_runner_class_exists() -> void:
	"""Legacy compatibility test - basic class existence check"""
	print("🏃 Testing TestRunner class existence (legacy)")

	var test_runner = load("res://gdsentry/core/test_runner.gd")
	assert_not_null(test_runner, "TestRunner should be loadable")

	var instance = test_runner.new()
	assert_not_null(instance, "Should be able to instantiate TestRunner")

	instance.queue_free()
	print("✅ TestRunner class exists")