# GDSentry - GDTest Base Class Unit Tests
# Comprehensive testing of GDTest base class functionality
#
# Tests the core base class including:
# - Test lifecycle management (_ready, _exit_tree)
# - Test metadata handling
# - Test result tracking
# - Headless mode integration
# - Test suite execution
# - Assertion method delegation
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name GDTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready():
	test_description = "Unit tests for GDTest base class functionality"
	test_tags = ["unit", "base_class", "gd_test"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all GDTest base class unit tests"""
	run_test("test_gd_test_instantiation", func(): return test_gd_test_instantiation())
	run_test("test_gd_test_metadata_properties", func(): return test_gd_test_metadata_properties())
	run_test("test_gd_test_lifecycle", func(): return test_gd_test_lifecycle())
	run_test("test_gd_test_result_tracking", func(): return test_gd_test_result_tracking())
	run_test("test_gd_test_assertion_delegation", func(): return test_gd_test_assertion_delegation())
	run_test("test_gd_test_headless_integration", func(): return test_gd_test_headless_integration())
	run_test("test_gd_test_method_availability", func(): return test_gd_test_method_availability())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_gd_test_instantiation() -> bool:
	"""Test GDTest instantiation and basic properties"""
	var gd_test = GDTest.new()

	var success = assert_not_null(gd_test, "GDTest should instantiate successfully")
	success = success and assert_type(gd_test, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(gd_test.get_class(), "GDTest",
										"Should be GDTest class")

	# Test that it's a Node
	success = success and assert_true(gd_test is Node, "Should be a Node")

	return success

func test_gd_test_metadata_properties() -> bool:
	"""Test GDTest metadata property access and modification"""
	var gd_test = GDTest.new()
	var success = true

	# Test default metadata values
	success = success and assert_equals(gd_test.test_description, "",
										"Default test_description should be empty")
	success = success and assert_true(gd_test.test_tags is Array,
									"test_tags should be array")
	success = success and assert_equals(gd_test.test_tags.size(), 0,
										"Default test_tags should be empty")
	success = success and assert_equals(gd_test.test_priority, "normal",
										"Default test_priority should be 'normal'")
	success = success and assert_equals(gd_test.test_author, "",
										"Default test_author should be empty")
	success = success and assert_equals(gd_test.test_timeout, 30.0,
										"Default test_timeout should be 30.0")

	# Test metadata modification
	gd_test.test_description = "Test description"
	gd_test.test_tags = ["unit", "metadata"]
	gd_test.test_priority = "high"
	gd_test.test_author = "Test Author"
	gd_test.test_timeout = 60.0

	success = success and assert_equals(gd_test.test_description, "Test description",
										"Should be able to set test_description")
	success = success and assert_equals(gd_test.test_tags, ["unit", "metadata"],
										"Should be able to set test_tags")
	success = success and assert_equals(gd_test.test_priority, "high",
										"Should be able to set test_priority")
	success = success and assert_equals(gd_test.test_author, "Test Author",
										"Should be able to set test_author")
	success = success and assert_equals(gd_test.test_timeout, 60.0,
										"Should be able to set test_timeout")

	return success

func test_gd_test_lifecycle() -> bool:
	"""Test GDTest lifecycle methods"""
	var gd_test = GDTest.new()
	var success = true

	# Test _ready method (should not crash)
	gd_test._ready()
	success = success and assert_true(true, "_ready should execute without error")

	# Test that _ready initializes required properties
	success = success and assert_not_null(gd_test.test_results,
										"_ready should initialize test_results")
	success = success and assert_greater_than(gd_test.test_start_time, 0.0,
											"_ready should set test_start_time")

	# Test _exit_tree method (should not crash)
	gd_test._exit_tree()
	success = success and assert_true(true, "_exit_tree should execute without error")

	return success

func test_gd_test_result_tracking() -> bool:
	"""Test GDTest result tracking functionality"""
	var gd_test = GDTest.new()
	var success = true

	# Test initial result state
	success = success and assert_not_null(gd_test.test_results,
										"Should have test_results property")
	success = success and assert_true(gd_test.test_results is Dictionary,
									"test_results should be dictionary")

	# Test result tracking methods
	success = success and assert_true(gd_test.has_method("record_test_result"),
									"Should have record_test_result method")
	success = success and assert_true(gd_test.has_method("get_test_summary"),
									"Should have get_test_summary method")
	success = success and assert_true(gd_test.has_method("reset_test_results"),
									"Should have reset_test_results method")

	# Test recording a test result
	gd_test.record_test_result("test_method", true, "")
	success = success and assert_true(gd_test.test_results.has("test_method"),
									"Should record test result")

	# Test getting test summary
	var summary = gd_test.get_test_summary()
	success = success and assert_not_null(summary, "Should get test summary")
	success = success and assert_true(summary is Dictionary, "Summary should be dictionary")

	return success

func test_gd_test_assertion_delegation() -> bool:
	"""Test GDTest assertion method delegation"""
	var gd_test = GDTest.new()
	var success = true

	# Test that GDTest has all required assertion methods
	var assertion_methods = [
		"assert_true", "assert_false", "assert_equals", "assert_not_equals",
		"assert_null", "assert_not_null", "assert_greater_than", "assert_less_than",
		"assert_in_range", "assert_type", "assert_has_method"
	]

	for method in assertion_methods:
		success = success and assert_true(gd_test.has_method(method),
										"GDTest should have assertion method: " + method)

	# Test basic assertion functionality
	success = success and assert_true(gd_test.assert_true(true, "Should pass"),
									"assert_true should work")
	success = success and assert_false(gd_test.assert_true(false, "Should fail"),
										"assert_true with false should fail")

	# Test equality assertions
	success = success and assert_true(gd_test.assert_equals(42, 42, "Should be equal"),
									"assert_equals with same values should pass")
	success = success and assert_false(gd_test.assert_equals(42, 43, "Should not be equal"),
										"assert_equals with different values should fail")

	return success

func test_gd_test_headless_integration() -> bool:
	"""Test GDTest headless mode integration"""
	var gd_test = GDTest.new()
	var success = true

	# Test headless mode property
	success = success and assert_type(gd_test.headless_mode, TYPE_BOOL,
									"headless_mode should be boolean")

	# Test headless integration methods
	success = success and assert_true(gd_test.has_method("is_headless_mode"),
									"Should have is_headless_mode method")

	# Test headless mode detection
	var detected_headless = gd_test.is_headless_mode()
	success = success and assert_type(detected_headless, TYPE_BOOL,
									"is_headless_mode should return boolean")

	# Test headless shutdown setup (if available)
	if gd_test.has_method("setup_headless_shutdown"):
		# Create a test node for shutdown setup
		var test_node = Node.new()
		gd_test.setup_headless_shutdown(test_node, 5.0)
		success = success and assert_true(true, "setup_headless_shutdown should execute without error")
		test_node.queue_free()

	return success

func test_gd_test_method_availability() -> bool:
	"""Test that all required GDTest methods are available"""
	var gd_test = GDTest.new()
	var success = true

	# Core lifecycle methods
	var lifecycle_methods = [
		"_ready", "_exit_tree"
	]

	for method in lifecycle_methods:
		success = success and assert_true(gd_test.has_method(method),
										"GDTest should have lifecycle method: " + method)

	# Test execution methods
	var execution_methods = [
		"run_test", "run_test_suite", "run_tests"
	]

	for method in execution_methods:
		success = success and assert_true(gd_test.has_method(method),
										"GDTest should have execution method: " + method)

	# Test management methods
	var management_methods = [
		"get_test_suite_name", "get_test_metadata", "is_test_enabled"
	]

	for method in management_methods:
		success = success and assert_true(gd_test.has_method(method),
										"GDTest should have management method: " + method)

	# Result and reporting methods
	var reporting_methods = [
		"get_test_results", "get_test_summary", "print_test_results"
	]

	for method in reporting_methods:
		success = success and assert_true(gd_test.has_method(method),
										"GDTest should have reporting method: " + method)

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_gd_test_instance() -> GDTest:
	"""Create a GDTest instance with custom metadata for testing"""
	var gd_test = GDTest.new()

	gd_test.test_description = "Custom test description"
	gd_test.test_tags = ["custom", "test"]
	gd_test.test_priority = "high"
	gd_test.test_author = "Test Author"
	gd_test.test_timeout = 45.0
	gd_test.test_category = "custom"

	return gd_test

func validate_gd_test_metadata(gd_test: GDTest, expected_description: String,
								expected_tags: Array, expected_priority: String) -> bool:
	"""Validate GDTest metadata against expected values"""
	var success = true

	success = success and assert_equals(gd_test.test_description, expected_description,
										"test_description should match expected")
	success = success and assert_equals(gd_test.test_tags, expected_tags,
										"test_tags should match expected")
	success = success and assert_equals(gd_test.test_priority, expected_priority,
										"test_priority should match expected")

	return success

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
