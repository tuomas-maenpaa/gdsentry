# GDSentry - Data-Driven Test Framework Test Suite
# Comprehensive testing of the DataDrivenTest framework
#
# This test validates all aspects of the data-driven testing system including:
# - Data source creation and management (CSV, JSON, Array)
# - Parameterized test execution with data binding
# - Test matrix generation for multi-dimensional testing
# - Test result aggregation and reporting
# - Error handling and edge cases
# - Integration with GDSentry test infrastructure
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name DataDrivenTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive DataDrivenTest validation"
	test_tags = ["meta", "utilities", "data_driven", "parameterized", "matrix"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var data_driven

func setup() -> void:
	"""Setup test environment"""
	data_driven = load("res://utilities/data_driven_test.gd").new()

func teardown() -> void:
	"""Cleanup test environment"""
	if data_driven:
		data_driven.queue_free()

# ------------------------------------------------------------------------------
# DATA SOURCE TESTS
# ------------------------------------------------------------------------------
func test_data_source_creation() -> bool:
	"""Test basic data source creation and management"""
	print("🧪 Testing data source creation")

	var success = true

	# Test array data source creation
	var test_data = [
		{"name": "Alice", "age": 25, "email": "alice@test.com"},
		{"name": "Bob", "age": 30, "email": "bob@test.com"},
		{"name": "Charlie", "age": 35, "email": "charlie@test.com"}
	]

	var array_source = data_driven.create_array_data_source(test_data, "test_users")
	success = success and assert_not_null(array_source, "Should create array data source")
	success = success and assert_equals(array_source.name, "test_users", "Should set data source name")
	success = success and assert_equals(array_source.source_type, "array", "Should set correct source type")
	success = success and assert_equals(array_source.get_row_count(), 3, "Should have correct row count")
	success = success and assert_equals(array_source.get_column_count(), 3, "Should have correct column count")

	# Test data source methods
	var first_row = array_source.get_row(0)
	success = success and assert_equals(first_row["name"], "Alice", "Should retrieve correct row data")

	var age_values = array_source.get_column_values("age")
	success = success and assert_equals(age_values.size(), 3, "Should get all column values")
	success = success and assert_equals(age_values, [25, 30, 35], "Should get correct column values")

	# Test filtering
	var filtered_rows = array_source.filter_rows(func(row): return row["age"] > 28)
	success = success and assert_equals(filtered_rows.size(), 2, "Should filter rows correctly")
	success = success and assert_equals(filtered_rows[0]["name"], "Bob", "Should return correct filtered data")

	return success

func test_csv_data_source() -> bool:
	"""Test CSV data source creation"""
	print("🧪 Testing CSV data source")

	var success = true

	# Create a temporary CSV file for testing
	var csv_content = """name,age,email,city
Alice,25,alice@test.com,New York
Bob,30,bob@test.com,Los Angeles
Charlie,35,charlie@test.com,Chicago
Diana,28,diana@test.com,Houston"""

	var temp_file = "/tmp/test_data.csv"
	var file = FileAccess.open(temp_file, FileAccess.WRITE)
	if file:
		file.store_string(csv_content)
		file.close()

		# Test CSV data source creation
		var csv_source = data_driven.create_csv_data_source(temp_file)
		success = success and assert_not_null(csv_source, "Should create CSV data source")
		success = success and assert_equals(csv_source.source_type, "csv", "Should set correct source type")
		success = success and assert_equals(csv_source.get_row_count(), 4, "Should load all CSV rows")
		success = success and assert_equals(csv_source.get_column_count(), 4, "Should detect all columns")

		# Test data types
		var first_row = csv_source.get_row(0)
		success = success and assert_equals(first_row["name"], "Alice", "Should parse string values")
		success = success and assert_equals(first_row["age"], 25, "Should convert numeric strings to int")
		success = success and assert_equals(first_row["email"], "alice@test.com", "Should preserve string values")

		# Clean up
		DirAccess.remove_absolute(temp_file)
	else:
		push_warning("DataDrivenTestTest: Could not create temporary CSV file")
		success = false

	return success

func test_json_data_source() -> bool:
	"""Test JSON data source creation"""
	print("🧪 Testing JSON data source")

	var success = true

	# Create a temporary JSON file for testing
	var json_content = """{
	"test_cases": [
		{"name": "Alice", "age": 25, "email": "alice@test.com", "active": true},
		{"name": "Bob", "age": 30, "email": "bob@test.com", "active": false},
		{"name": "Charlie", "age": 35, "email": "charlie@test.com", "active": true}
	]
}"""

	var temp_file = "/tmp/test_data.json"
	var file = FileAccess.open(temp_file, FileAccess.WRITE)
	if file:
		file.store_string(json_content)
		file.close()

		# Test JSON data source creation
		var json_source = data_driven.create_json_data_source(temp_file)
		success = success and assert_not_null(json_source, "Should create JSON data source")
		success = success and assert_equals(json_source.source_type, "json", "Should set correct source type")
		success = success and assert_equals(json_source.get_row_count(), 3, "Should load all JSON test cases")

		# Test data types preservation
		var first_row = json_source.get_row(0)
		success = success and assert_equals(first_row["name"], "Alice", "Should parse string values")
		success = success and assert_equals(first_row["age"], 25, "Should preserve numeric values")
		success = success and assert_equals(first_row["active"], true, "Should preserve boolean values")

		# Test JSON array format
		var json_array_content = """[
	{"product": "Laptop", "price": 999.99, "category": "Electronics"},
	{"product": "Book", "price": 19.99, "category": "Education"}
]"""

		var array_file = "/tmp/test_array.json"
		var array_file_handle = FileAccess.open(array_file, FileAccess.WRITE)
		if array_file_handle:
			array_file_handle.store_string(json_array_content)
			array_file_handle.close()

			var json_array_source = data_driven.create_json_data_source(array_file)
			success = success and assert_equals(json_array_source.get_row_count(), 2, "Should handle JSON arrays")

			# Clean up array file
			DirAccess.remove_absolute(array_file)

		# Clean up main file
		DirAccess.remove_absolute(temp_file)
	else:
		push_warning("DataDrivenTestTest: Could not create temporary JSON file")
		success = false

	return success

# ------------------------------------------------------------------------------
# PARAMETERIZED TEST TESTS
# ------------------------------------------------------------------------------
func test_parameterized_test_creation() -> bool:
	"""Test parameterized test creation and configuration"""
	print("🧪 Testing parameterized test creation")

	var success = true

	# Create test data source
	var test_data = [
		{"input": 5, "expected": 25},
		{"input": 10, "expected": 100},
		{"input": 15, "expected": 225}
	]
	var data_source = data_driven.create_array_data_source(test_data, "math_test_data")

	# Create parameterized test
	var square_test = data_driven.create_parameterized_test("test_square_function", func(test_case):
		var input_val = test_case["input"]
		var expected = test_case["expected"]
		var result = input_val * input_val
		return result == expected
	)

	success = success and assert_not_null(square_test, "Should create parameterized test")
	success = success and assert_equals(square_test.test_name, "test_square_function", "Should set test name")

	# Configure test
	square_test.set_data_source(data_source)
	square_test.set_timeout(10.0)
	square_test.set_retry_count(2)
	square_test.set_description("Test square function with multiple inputs")

	success = success and assert_not_null(square_test.data_source, "Should set data source")
	success = success and assert_equals(square_test.timeout, 10.0, "Should set timeout")
	success = success and assert_equals(square_test.retry_count, 2, "Should set retry count")
	success = success and assert_equals(square_test.description, "Test square function with multiple inputs", "Should set description")

	# Test test case retrieval
	var test_cases = square_test.get_test_cases()
	success = success and assert_equals(test_cases.size(), 3, "Should retrieve all test cases")

	return success

func test_parameterized_test_execution() -> bool:
	"""Test parameterized test execution"""
	print("🧪 Testing parameterized test execution")

	var success = true

	# Create test data
	var test_data = [
		{"a": 2, "b": 3, "expected": 5},
		{"a": 10, "b": 15, "expected": 25},
		{"a": 100, "b": 200, "expected": 300}
	]
	var data_source = data_driven.create_array_data_source(test_data, "addition_test_data")

	# Create parameterized test
	var addition_test = data_driven.create_parameterized_test("test_addition", func(test_case):
		var result = test_case["a"] + test_case["b"]
		return result == test_case["expected"]
	)
	addition_test.set_data_source(data_source)

	# Create test executor
	var executor = data_driven.create_test_executor("ParameterizedTestSuite")
	executor.add_parameterized_test(addition_test)

	# Execute tests
	var results = executor.execute_all()
	success = success and assert_equals(results.size(), 3, "Should execute all test cases")

	# Verify results
	for i in range(results.size()):
		var result = results[i]
		success = success and assert_true(result.success, "Test case %d should pass" % i)
		success = success and assert_equals(result.test_name, "test_addition", "Should set correct test name")
		success = success and assert_equals(result.data_source, "addition_test_data", "Should set correct data source")

		var _expected_execution_time = result.test_data["expected"]
		success = success and assert_greater_than(result.execution_time, 0.0, "Should record execution time")

	return success

# ------------------------------------------------------------------------------
# TEST MATRIX TESTS
# ------------------------------------------------------------------------------
func test_test_matrix_creation() -> bool:
	"""Test test matrix creation and configuration"""
	print("🧪 Testing test matrix creation")

	var success = true

	# Create test matrix
	var matrix = data_driven.create_test_matrix("browser_compatibility_matrix")

	# Add dimensions
	matrix.add_dimension("browser", ["chrome", "firefox", "safari"], ["Chrome", "Firefox", "Safari"])
	matrix.add_dimension("os", ["windows", "macos", "linux"], ["Windows", "macOS", "Linux"])

	success = success and assert_equals(matrix.name, "browser_compatibility_matrix", "Should set matrix name")
	success = success and assert_equals(matrix.dimensions.size(), 2, "Should add dimensions")

	# Generate test cases
	var test_cases = matrix.generate_test_cases()
	success = success and assert_equals(test_cases.size(), 9, "Should generate cartesian product (3x3=9)")

	# Verify test case structure
	var first_case = test_cases[0]
	success = success and assert_true(first_case.has("browser"), "Should include browser dimension")
	success = success and assert_true(first_case.has("os"), "Should include os dimension")
	success = success and assert_true(first_case.has("case_id"), "Should generate case ID")
	success = success and assert_equals(first_case["browser"], "chrome", "Should set correct dimension values")
	success = success and assert_equals(first_case["os"], "windows", "Should set correct dimension values")

	return success

func test_test_matrix_filtering() -> bool:
	"""Test test matrix filtering and exclusion"""
	print("🧪 Testing test matrix filtering")

	var success = true

	# Create test matrix with exclusions
	var matrix = data_driven.create_test_matrix("filtered_matrix")
	matrix.add_dimension("env", ["dev", "staging", "prod"])
	matrix.add_dimension("region", ["us", "eu", "asia"])

	# Exclude certain combinations
	matrix.exclude_combination(["prod", "us"])	# Exclude prod-us combination
	matrix.exclude_combination(["dev", "asia"])	 # Exclude dev-asia combination

	var test_cases = matrix.generate_test_cases()
	success = success and assert_equals(test_cases.size(), 7, "Should exclude 2 combinations (9-2=7)")

	# Verify exclusions
	var has_prod_us = false
	var has_dev_asia = false

	for test_case in test_cases:
		if test_case["env"] == "prod" and test_case["region"] == "us":
			has_prod_us = true
		if test_case["env"] == "dev" and test_case["region"] == "asia":
			has_dev_asia = true

	success = success and assert_false(has_prod_us, "Should exclude prod-us combination")
	success = success and assert_false(has_dev_asia, "Should exclude dev-asia combination")

	return success

func test_test_matrix_execution() -> bool:
	"""Test test matrix execution"""
	print("🧪 Testing test matrix execution")

	var success = true

	# Create test matrix
	var matrix = data_driven.create_test_matrix("execution_test_matrix")
	matrix.add_dimension("priority", ["high", "medium", "low"])
	matrix.add_dimension("category", ["smoke", "regression"])

	# Create test executor with matrix
	var executor = data_driven.create_test_executor("MatrixTestSuite")
	executor.set_test_matrix(matrix)

	# Execute matrix
	var results = executor.execute_all()
	success = success and assert_equals(results.size(), 6, "Should execute all matrix combinations (3x2=6)")

	# Verify matrix results
	for result in results:
		success = success and assert_equals(result.test_name, "execution_test_matrix", "Should set matrix name")
		success = success and assert_equals(result.data_source, "matrix", "Should set matrix data source")
		success = success and assert_true(result.success, "Matrix tests should succeed")
		success = success and assert_true(result.test_data.has("priority"), "Should include matrix dimensions")
		success = success and assert_true(result.test_data.has("category"), "Should include matrix dimensions")

	return success

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_data_driven_integration() -> bool:
	"""Test integration of all components"""
	print("🧪 Testing data-driven integration")

	var success = true

	# Create data source
	var user_data = [
		{"username": "alice", "role": "admin", "active": true},
		{"username": "bob", "role": "user", "active": true},
		{"username": "charlie", "role": "user", "active": false}
	]
	var data_source = data_driven.create_array_data_source(user_data, "user_integration_data")

	# Create parameterized test
	var user_validation_test = data_driven.create_parameterized_test("validate_user_permissions", func(test_case):
		var username = test_case["username"]
		var role = test_case["role"]
		var active = test_case["active"]

		# Simulate permission validation
		if not active:
			return false  # Inactive users should fail

		if role == "admin":
			return true	  # Admins always pass
		elif role == "user":
			return username.length() >= 3  # Users need valid username

		return false
	)
	user_validation_test.set_data_source(data_source)

	# Create test matrix for different environments
	var env_matrix = data_driven.create_test_matrix("environment_matrix")
	env_matrix.add_dimension("environment", ["development", "staging", "production"])

	# Create executor with both parameterized tests and matrix
	var executor = data_driven.create_test_executor("IntegrationTestSuite")
	executor.add_parameterized_test(user_validation_test)
	executor.set_test_matrix(env_matrix)

	# Execute all tests
	var results = executor.execute_all()
	success = success and assert_equals(results.size(), 6, "Should execute 3 user tests + 3 matrix tests")

	# Verify results
	var parameterized_results = results.filter(func(r): return r.data_source == "user_integration_data")
	var matrix_results = results.filter(func(r): return r.data_source == "matrix")

	success = success and assert_equals(parameterized_results.size(), 3, "Should have 3 parameterized test results")
	success = success and assert_equals(matrix_results.size(), 3, "Should have 3 matrix test results")

	# Check specific test outcomes
	var alice_result = parameterized_results.filter(func(r): return r.test_data["username"] == "alice")[0]
	success = success and assert_true(alice_result.success, "Alice (admin) should pass validation")

	var bob_result = parameterized_results.filter(func(r): return r.test_data["username"] == "bob")[0]
	success = success and assert_true(bob_result.success, "Bob (user) should pass validation")

	var charlie_result = parameterized_results.filter(func(r): return r.test_data["username"] == "charlie")[0]
	success = success and assert_false(charlie_result.success, "Charlie (inactive) should fail validation")

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	print("🧪 Testing error handling")

	var success = true

	# Test empty data source
	var empty_source = data_driven.create_array_data_source([], "empty_source")
	success = success and assert_equals(empty_source.get_row_count(), 0, "Should handle empty data sources")

	# Test invalid file paths
	var invalid_csv = data_driven.create_csv_data_source("/nonexistent/file.csv")
	success = success and assert_null(invalid_csv, "Should return null for invalid CSV files")

	var invalid_json = data_driven.create_json_data_source("/nonexistent/file.json")
	success = success and assert_null(invalid_json, "Should return null for invalid JSON files")

	# Test parameterized test without data source
	var test_without_source = data_driven.create_parameterized_test("no_source_test", func(): return true)
	var test_cases = test_without_source.get_test_cases()
	success = success and assert_equals(test_cases.size(), 0, "Should handle tests without data source")

	# Test matrix with no dimensions
	var empty_matrix = data_driven.create_test_matrix("empty_matrix")
	var empty_cases = empty_matrix.generate_test_cases()
	success = success and assert_equals(empty_cases.size(), 0, "Should handle matrices without dimensions")

	return success

# ------------------------------------------------------------------------------
# EXPORT FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_export_functionality() -> bool:
	"""Test result export functionality"""
	print("🧪 Testing export functionality")

	var success = true

	# Create mock test results
	var mock_results = []

	for i in range(3):
		var result = load("res://utilities/data_driven_test.gd").TestResult.new()
		result.test_name = "export_test_%d" % i
		result.test_case_id = str(i)
		result.data_source = "mock_data"
		result.success = i != 1	 # Make second test fail
		result.execution_time = 0.1 * (i + 1)
		result.error_message = "Test failed" if i == 1 else ""
		result.test_data = {"input": i, "expected": i * 2}
		result.result_data = i * 2

		mock_results.append(result)

	# Test CSV export (would need temporary file in real implementation)
	# var csv_export = data_driven.export_results_to_csv(mock_results, "/tmp/test_results.csv")
	# success = success and assert_true(csv_export, "Should export results to CSV")

	# Test JSON export (would need temporary file in real implementation)
	# var json_export = data_driven.export_results_to_json(mock_results, "/tmp/test_results.json")
	# success = success and assert_true(json_export, "Should export results to JSON")

	# Test with empty results
	var empty_csv_export = data_driven.export_results_to_csv([], "/tmp/empty_results.csv")
	success = success and assert_false(empty_csv_export, "Should handle empty results gracefully")

	var empty_json_export = data_driven.export_results_to_json([], "/tmp/empty_results.json")
	success = success and assert_false(empty_json_export, "Should handle empty results gracefully")

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE TESTS
# ------------------------------------------------------------------------------
func test_performance_large_datasets() -> bool:
	"""Test performance with large datasets"""
	print("🧪 Testing performance with large datasets")

	var success = true

	# Create large dataset
	var large_data = []
	for i in range(100):  # Create 100 test cases
		large_data.append({
			"id": i,
			"name": "test_user_%d" % i,
			"value": i * 10,
			"active": i % 2 == 0
		})

	var large_source = data_driven.create_array_data_source(large_data, "large_dataset")

	# Create parameterized test
	var large_test = data_driven.create_parameterized_test("large_dataset_test", func(test_case):
		# Simple validation
		return test_case["id"] >= 0 and test_case["name"].begins_with("test_user_")
	)
	large_test.set_data_source(large_source)

	# Execute test
	var start_time = Time.get_ticks_usec() / 1000000.0
	var executor = data_driven.create_test_executor("PerformanceTestSuite")
	executor.add_parameterized_test(large_test)

	var results = executor.execute_all()
	var end_time = Time.get_ticks_usec() / 1000000.0

	var execution_time = end_time - start_time

	success = success and assert_equals(results.size(), 100, "Should execute all 100 test cases")
	success = success and assert_less_than(execution_time, 5.0, "Should complete within 5 seconds")
	success = success and assert_true(results.all(func(r): return r.success), "All tests should pass")

	print("		 Large dataset test completed in %.3f seconds" % execution_time)

	return success

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all DataDrivenTest tests"""
	print("\n🚀 Running DataDrivenTest Test Suite\n")

	# Data Source Tests
	run_test("test_data_source_creation", func(): return test_data_source_creation())
	run_test("test_csv_data_source", func(): return test_csv_data_source())
	run_test("test_json_data_source", func(): return test_json_data_source())

	# Parameterized Test Tests
	run_test("test_parameterized_test_creation", func(): return test_parameterized_test_creation())
	run_test("test_parameterized_test_execution", func(): return test_parameterized_test_execution())

	# Test Matrix Tests
	run_test("test_test_matrix_creation", func(): return test_test_matrix_creation())
	run_test("test_test_matrix_filtering", func(): return test_test_matrix_filtering())
	run_test("test_test_matrix_execution", func(): return test_test_matrix_execution())

	# Integration Tests
	run_test("test_data_driven_integration", func(): return test_data_driven_integration())

	# Error Handling Tests
	run_test("test_error_handling", func(): return test_error_handling())

	# Export Functionality Tests
	run_test("test_export_functionality", func(): return test_export_functionality())

	# Performance Tests
	run_test("test_performance_large_datasets", func(): return test_performance_large_datasets())

	print("\n✨ DataDrivenTest Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
