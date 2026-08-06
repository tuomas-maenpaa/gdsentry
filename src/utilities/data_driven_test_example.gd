# GDSentry - Data-Driven Test Framework Usage Examples
# Practical examples demonstrating how to use the DataDrivenTest framework
#
# This file provides comprehensive examples of using the DataDrivenTest
# for various testing scenarios including:
# - CSV and JSON data source integration
# - Parameterized test execution
# - Test matrix generation for multi-dimensional testing
# - Batch execution and result reporting
# - Integration with GDSentry test cases
# - Advanced filtering and customization
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name DataDrivenTestExample

# ------------------------------------------------------------------------------
# EXAMPLE SETUP
# ------------------------------------------------------------------------------
var data_driven

func _ready() -> void:
	"""Initialize the example"""
	data_driven = load("res://utilities/data_driven_test.gd").new()
	add_child(data_driven)

	print("🎯 GDSentry DataDrivenTest Examples")
	print("================================\n")

	run_examples()

# ------------------------------------------------------------------------------
# BASIC DATA SOURCE EXAMPLES
# ------------------------------------------------------------------------------
func example_array_data_source() -> void:
	"""Example: Creating data source from array"""
	print("📋 Example 1: Array Data Source")
	print("-------------------------------")

	# Create test data as array of dictionaries
	var user_test_data = [
		{"username": "alice", "password": "pass123", "role": "admin", "expected_result": true},
		{"username": "bob", "password": "wrongpass", "role": "user", "expected_result": false},
		{"username": "charlie", "password": "pass456", "role": "user", "expected_result": true},
		{"username": "", "password": "pass789", "role": "user", "expected_result": false}
	]

	# Create data source
	var data_source = data_driven.create_array_data_source(user_test_data, "user_login_tests")
	print("Created data source with %d test cases" % data_source.get_row_count())
	print("Columns: %s" % str(data_source.headers))
	print()

	# Use data source in parameterized test
	var login_test = data_driven.create_parameterized_test("test_user_login", func(test_case):
		var username = test_case["username"]
		var password = test_case["password"]
		var expected = test_case["expected_result"]

		# Simulate login validation
		var actual_result = false
		if not username.is_empty() and password.begins_with("pass"):
			actual_result = true

		return actual_result == expected
	)

	login_test.set_data_source(data_source)
	login_test.set_description("Validate user login with various inputs")

	# Execute test
	var executor = data_driven.create_test_executor("LoginTestSuite")
	executor.add_parameterized_test(login_test)

	var results = executor.execute_all()

	print("Test Results:")
	for i in range(results.size()):
		var result = results[i]
		var status = "✓" if result.success else "✗"
		print("	 %s Test case %d: %s (%.3fs)" % [status, i + 1, result.test_data["username"], result.execution_time])

	var passed_count = results.filter(func(r): return r.success).size()
	print("	 Passed: %d/%d tests" % [passed_count, results.size()])
	print()

# ------------------------------------------------------------------------------
# CSV DATA SOURCE EXAMPLES
# ------------------------------------------------------------------------------
func example_csv_data_source() -> void:
	"""Example: Using CSV files as data source"""
	print("📄 Example 2: CSV Data Source")
	print("-----------------------------")

	# Create a sample CSV file (in real usage, this would be an existing file)
	var _csv_content = """product_name,price,category,in_stock,expected_discount
Laptop,999.99,Electronics,true,0.1
Book,19.99,Education,true,0.0
Headphones,79.99,Electronics,false,0.05
Tablet,299.99,Electronics,true,0.15
Pen,1.99,Office,true,0.0"""

	# In real usage, you would load from an existing CSV file:
	# var data_source = data_driven.create_csv_data_source("res://test_data/products.csv")

	# For this example, we'll simulate the data
	var product_data = [
		{"product_name": "Laptop", "price": 999.99, "category": "Electronics", "in_stock": true, "expected_discount": 0.1},
		{"product_name": "Book", "price": 19.99, "category": "Education", "in_stock": true, "expected_discount": 0.0},
		{"product_name": "Headphones", "price": 79.99, "category": "Electronics", "in_stock": false, "expected_discount": 0.05},
		{"product_name": "Tablet", "price": 299.99, "category": "Electronics", "in_stock": true, "expected_discount": 0.15},
		{"product_name": "Pen", "price": 1.99, "category": "Office", "in_stock": true, "expected_discount": 0.0}
	]

	var data_source = data_driven.create_array_data_source(product_data, "product_tests")

	# Create parameterized test for product validation
	var product_test = data_driven.create_parameterized_test("validate_product_data", func(test_case):
		var price = test_case["price"]
		var in_stock = test_case["in_stock"]
		var discount = test_case["expected_discount"]

		# Validate price is reasonable
		if price <= 0:
			return false

		# Validate discount logic
		if in_stock and price > 100:
			return discount >= 0.05	 # High-value in-stock items should have discount
		elif not in_stock:
			return discount >= 0.0	# Out-of-stock items can have discount

		return discount >= 0.0	# Basic validation
	)

	product_test.set_data_source(data_source)

	# Execute test
	var executor = data_driven.create_test_executor("ProductTestSuite")
	executor.add_parameterized_test(product_test)

	var results = executor.execute_all()

	print("Product Validation Results:")
	for result in results:
		var status = "✓" if result.success else "✗"
		var product = result.test_data["product_name"]
		var price = result.test_data["price"]
		print("	 %s %s ($%.2f): %s" % [status, product, price, "Valid" if result.success else "Invalid"])

	var passed_count = results.filter(func(r): return r.success).size()
	print("	 Valid products: %d/%d" % [passed_count, results.size()])
	print()

# ------------------------------------------------------------------------------
# TEST MATRIX EXAMPLES
# ------------------------------------------------------------------------------
func example_test_matrix() -> void:
	"""Example: Test matrix for multi-dimensional testing"""
	print("🔢 Example 3: Test Matrix")
	print("------------------------")

	# Create test matrix for browser compatibility
	var compatibility_matrix = data_driven.create_test_matrix("browser_compatibility")

	# Add dimensions
	compatibility_matrix.add_dimension("browser",
		["chrome", "firefox", "safari", "edge"],
		["Chrome", "Firefox", "Safari", "Edge"]
	)

	compatibility_matrix.add_dimension("os",
		["windows", "macos", "linux"],
		["Windows", "macOS", "Linux"]
	)

	compatibility_matrix.add_dimension("viewport",
		["mobile", "tablet", "desktop"],
		["Mobile", "Tablet", "Desktop"]
	)

	# Exclude incompatible combinations
	compatibility_matrix.exclude_combination(["safari", "windows", "any"])	# Safari not on Windows
	compatibility_matrix.exclude_combination(["edge", "macos", "any"])	   # Edge not on macOS
	compatibility_matrix.exclude_combination(["any", "linux", "mobile"])   # Limited mobile support on Linux

	# Generate test cases
	var test_cases = compatibility_matrix.generate_test_cases()
	print("Generated %d test combinations:" % test_cases.size())

	# Show first 10 combinations
	for i in range(min(10, test_cases.size())):
		var test_case = test_cases[i]
		print("	 %d. %s + %s + %s (ID: %s)" % [
			i + 1,
			test_case["browser_name"],
			test_case["os_name"],
			test_case["viewport_name"],
			test_case["case_id"]
		])

	if test_cases.size() > 10:
		print("	 ... and %d more combinations" % (test_cases.size() - 10))

	print()

	# Execute matrix tests
	var executor = data_driven.create_test_executor("CompatibilityTestSuite")
	executor.set_test_matrix(compatibility_matrix)

	var results = executor.execute_all()
	print("Matrix Execution Results:")
	print("	 Total combinations tested: %d" % results.size())
	print("	 Successful tests: %d" % results.filter(func(r): return r.success).size())
	print("	 Failed tests: %d" % results.filter(func(r): return not r.success).size())
	print()

# ------------------------------------------------------------------------------
# ADVANCED PARAMETERIZED TESTING EXAMPLES
# ------------------------------------------------------------------------------
func example_advanced_parameterized_testing() -> void:
	"""Example: Advanced parameterized testing with filtering"""
	print("🔧 Example 4: Advanced Parameterized Testing")
	print("-------------------------------------------")

	# Create comprehensive test data
	var api_test_data = []

	for i in range(20):
		api_test_data.append({
			"endpoint": "/api/v%d/users/%d" % [(i % 3) + 1, i + 1],
			"method": ["GET", "POST", "PUT", "DELETE"][i % 4],
			"authenticated": i % 3 != 0,  # Every 3rd request is unauthenticated
			"payload_size": (i + 1) * 10,
			"expected_status": 200 if (i % 3 != 0) else 401,  # 401 for unauthenticated
			"response_time_max": 2.0 - (i * 0.05)  # Decreasing max time
		})

	var data_source = data_driven.create_array_data_source(api_test_data, "api_performance_tests")

	# Create parameterized test with filtering
	var api_performance_test = data_driven.create_parameterized_test("test_api_performance", func(test_case):
		var _method = test_case["method"]
		var authenticated = test_case["authenticated"]
		var payload_size = test_case["payload_size"]
		var max_time = test_case["response_time_max"]

		# Simulate API call performance
		var base_time = 0.1 + (payload_size * 0.001)  # Base time + payload overhead
		if not authenticated:
			base_time += 0.5  # Authentication overhead

		# Add some randomness
		var actual_time = base_time + (randf() * 0.2 - 0.1)	 # ±0.1s variation

		# Validate response time
		return actual_time <= max_time
	)

	api_performance_test.set_data_source(data_source)

	# Add filter to only test GET and POST methods
	api_performance_test.set_filter(func(test_case): return test_case["method"] in ["GET", "POST"])

	# Execute filtered tests
	var executor = data_driven.create_test_executor("API_Performance_Filtered")
	executor.add_parameterized_test(api_performance_test)

	var results = executor.execute_all()

	print("API Performance Test Results (GET/POST only):")
	print("	 Total filtered test cases: %d" % results.size())

	# Analyze results by method
	var get_results = results.filter(func(r): return r.test_data["method"] == "GET")
	var post_results = results.filter(func(r): return r.test_data["method"] == "POST")

	print("	 GET requests: %d (Passed: %d)" % [
		get_results.size(),
		get_results.filter(func(r): return r.success).size()
	])

	print("	 POST requests: %d (Passed: %d)" % [
		post_results.size(),
		post_results.filter(func(r): return r.success).size()
	])

	# Show performance summary
	var avg_time = results.map(func(r): return r.execution_time).reduce(func(acc, val): return acc + val, 0.0) / results.size()
	print("	 Average response time: %.3fs" % avg_time)
	print()

# ------------------------------------------------------------------------------
# BATCH EXECUTION AND REPORTING EXAMPLES
# ------------------------------------------------------------------------------
func example_batch_execution_reporting() -> void:
	"""Example: Batch execution with comprehensive reporting"""
	print("📊 Example 5: Batch Execution & Reporting")
	print("----------------------------------------")

	# Create multiple test suites
	var user_tests = create_user_validation_suite()
	var product_tests = create_product_validation_suite()
	var matrix_tests = create_compatibility_matrix()

	# Create batch executor
	var batch_executor = data_driven.create_test_executor("Complete_Test_Batch")
	batch_executor.add_parameterized_test(user_tests)
	batch_executor.add_parameterized_test(product_tests)
	batch_executor.set_test_matrix(matrix_tests)

	# Enable parallel execution
	batch_executor.set_parallel_execution(true, 3)	# 3 parallel threads

	print("Executing comprehensive test batch...")
	var start_time = Time.get_ticks_usec() / 1000000.0
	var all_results = batch_executor.execute_all()
	var end_time = Time.get_ticks_usec() / 1000000.0

	var total_time = end_time - start_time

	print("Batch Execution Complete:")
	print("	 Total execution time: %.3fs" % total_time)
	print("	 Total test cases: %d" % all_results.size())
	print()

	# Generate comprehensive report
	var report = batch_executor.generate_report()

	print("Detailed Report:")
	print("	 Suite: %s" % report["suite_name"])
	print("	 Success Rate: %.1f%%" % report["success_rate"])
	print("	 Total Execution Time: %.3fs" % report["total_execution_time"])
	print("	 Average Test Time: %.3fs" % report["average_execution_time"])
	print()

	print("Data Source Breakdown:")
	for data_source in report["data_sources"]:
		print("	 %s: %d tests" % [data_source, report["data_sources"][data_source]])
	print()

	print("Results by Category:")
	var parameterized_results = all_results.filter(func(r): return r.data_source != "matrix")
	var matrix_results = all_results.filter(func(r): return r.data_source == "matrix")

	print("	 Parameterized Tests: %d (Passed: %d)" % [
		parameterized_results.size(),
		parameterized_results.filter(func(r): return r.success).size()
	])

	print("	 Matrix Tests: %d (Passed: %d)" % [
		matrix_results.size(),
		matrix_results.filter(func(r): return r.success).size()
	])

	# Show slowest tests
	var sorted_results = all_results.duplicate()
	sorted_results.sort_custom(func(a, b): return a.execution_time > b.execution_time)

	print("
Top 5 Slowest Tests:")
	for i in range(min(5, sorted_results.size())):
		var result = sorted_results[i]
		print("	 %.3fs - %s (%s)" % [result.execution_time, result.test_name, result.test_case_id])

	print()

# ------------------------------------------------------------------------------
# HELPER METHODS FOR BATCH EXAMPLE
# ------------------------------------------------------------------------------
func create_user_validation_suite():
	"""Create user validation test suite"""
	var user_data = []
	for i in range(10):
		user_data.append({
			"username": "user_%d" % i,
			"email": "user%d@example.com" % i,
			"age": 18 + (i % 50),
			"active": i % 3 != 0  # Every 3rd user is inactive
		})

	var data_source = data_driven.create_array_data_source(user_data, "user_validation_data")

	var user_test = data_driven.create_parameterized_test("validate_user_data", func(test_case):
		var username = test_case["username"]
		var email = test_case["email"]
		var age = test_case["age"]
		var active = test_case["active"]

		# Validation rules
		if not username.begins_with("user_"):
			return false
		if not email.contains("@"):
			return false
		if age < 13 or age > 120:
			return false
		if not active and age < 18:
			return false  # Inactive minors not allowed

		return true
	)

	user_test.set_data_source(data_source)
	return user_test

func create_product_validation_suite():
	"""Create product validation test suite"""
	var product_data = []
	var categories = ["Electronics", "Books", "Clothing", "Home", "Sports"]

	for i in range(8):
		product_data.append({
			"name": "Product_%d" % i,
			"price": 10.0 + (i * 15.0),
			"category": categories[i % categories.size()],
			"in_stock": i % 4 != 0,	 # Every 4th product is out of stock
			"rating": 1.0 + (i % 5)	 # Rating from 1.0 to 5.0
		})

	var data_source = data_driven.create_array_data_source(product_data, "product_validation_data")

	var product_test = data_driven.create_parameterized_test("validate_product_data", func(test_case):
		var _product_name = test_case["name"]
		var price = test_case["price"]
		var category = test_case["category"]
		var in_stock = test_case["in_stock"]
		var rating = test_case["rating"]

		# Validation rules
		if not name.begins_with("Product_"):
			return false
		if price <= 0 or price > 1000:
			return false
		if not ["Electronics", "Books", "Clothing", "Home", "Sports"].has(category):
			return false
		if rating < 1.0 or rating > 5.0:
			return false
		if not in_stock and price > 100:
			return false  # Expensive out-of-stock items flagged

		return true
	)

	product_test.set_data_source(data_source)
	return product_test

func create_compatibility_matrix():
	"""Create compatibility test matrix"""
	var matrix = data_driven.create_test_matrix("feature_compatibility")

	matrix.add_dimension("feature", ["login", "checkout", "search"])
	matrix.add_dimension("device", ["mobile", "tablet", "desktop"])

	# Exclude certain combinations
	matrix.exclude_combination(["checkout", "mobile"])	# Mobile checkout not supported

	return matrix

# ------------------------------------------------------------------------------
# GDSENTRY INTEGRATION EXAMPLES
# ------------------------------------------------------------------------------
func example_gdsentry_integration() -> void:
	"""Example: Integration with GDSentry test cases"""
	print("🔗 Example 6: GDSentry Integration")
	print("-------------------------------")

	print("This example shows how to integrate DataDrivenTest with GDSentry test cases:")
	print()

	# Example test case structure
	print("# Example GDSentry Test Case Structure:")
	print("extends SceneTreeTest")
	print("")
	print("var data_driven")
	print("")
	print("func setup():")
	print("	   data_driven = load(\"res://utilities/data_driven_test.gd\").new()")
	print("	   add_child(data_driven)")
	print("")
	print("func test_data_driven_user_validation():")
	print("	   # Create test data")
	print("	   var user_data = [")
	print("		   {'username': 'alice', 'email': 'alice@test.com', 'expected': true},")
	print("		   {'username': 'bob', 'email': 'invalid-email', 'expected': false}")
	print("	   ]")
	print("	   ")
	print("	   var data_source = data_driven.create_array_data_source(user_data, 'user_tests')")
	print("	   ")
	print("	   # Create parameterized test")
	print("	   var user_test = data_driven.create_parameterized_test('validate_user', func(test_case):")
	print("		   var email = test_case['email']")
	print("		   var expected = test_case['expected']")
	print("		   var is_valid = email.contains('@')")
	print("		   return is_valid == expected")
	print("	   )")
	print("	   ")
	print("	   user_test.set_data_source(data_source)")
	print("	   ")
	print("	   # Execute and verify")
	print("	   var executor = data_driven.create_test_executor('UserValidationSuite')")
	print("	   executor.add_parameterized_test(user_test)")
	print("	   var results = executor.execute_all()")
	print("	   ")
	print("	   # GDSentry assertions")
	print("	   assert_equals(results.size(), 2, 'Should execute 2 test cases')")
	print("	   assert_true(results.all(func(r): return r.success), 'All tests should pass')")
	print("")
	print("func test_matrix_based_compatibility():")
	print("	   # Create test matrix")
	print("	   var matrix = data_driven.create_test_matrix('device_compatibility')")
	print("	   matrix.add_dimension('browser', ['chrome', 'firefox'])")
	print("	   matrix.add_dimension('os', ['windows', 'linux'])")
	print("	   ")
	print("	   # Execute matrix")
	print("	   var executor = data_driven.create_test_executor('CompatibilitySuite')")
	print("	   executor.set_test_matrix(matrix)")
	print("	   var results = executor.execute_all()")
	print("	   ")
	print("	   # Verify matrix execution")
	print("	   assert_equals(results.size(), 4, 'Should test all combinations')")
	print("	   assert_true(results.all(func(r): return r.success), 'Matrix tests should pass')")
	print("")
	print("func test_data_source_from_csv():")
	print("	   # Load data from CSV file")
	print("	   var csv_source = data_driven.create_csv_data_source('res://test_data/users.csv')")
	print("	   assert_not_null(csv_source, 'Should load CSV data source')")
	print("	   ")
	print("	   # Create test with CSV data")
	print("	   var csv_test = data_driven.create_parameterized_test('csv_user_test', func(test_case):")
	print("		   return test_case.has('email') and test_case['email'].contains('@')")
	print("	   )")
	print("	   ")
	print("	   csv_test.set_data_source(csv_source)")
	print("	   ")
	print("	   # Execute CSV-based test")
	print("	   var executor = data_driven.create_test_executor('CSV_Test_Suite')")
	print("	   executor.add_parameterized_test(csv_test)")
	print("	   var results = executor.execute_all()")
	print("	   ")
	print("	   assert_greater_than(results.size(), 0, 'Should execute CSV test cases')")
	print()

	print("Key Integration Benefits:")
	print("	 • Seamless integration with existing GDSentry test infrastructure")
	print("	 • Automatic test discovery and execution")
	print("	 • Rich assertion capabilities with data-driven context")
	print("	 • Comprehensive reporting and result analysis")
	print("	 • Support for both parameterized and matrix-based testing")
	print()

# ------------------------------------------------------------------------------
# PERFORMANCE AND SCALING EXAMPLES
# ------------------------------------------------------------------------------
func example_performance_scaling() -> void:
	"""Example: Performance testing and scaling"""
	print("⚡ Example 7: Performance & Scaling")
	print("----------------------------------")

	# Create large dataset for performance testing
	var large_dataset = []
	for i in range(100):
		large_dataset.append({
			"id": i,
			"data": "test_data_%d" % i,
			"value": i * 1.5,
			"category": ["A", "B", "C"][i % 3],
			"active": i % 5 != 0
		})

	var data_source = data_driven.create_array_data_source(large_dataset, "performance_test_data")

	# Create performance test
	var performance_test = data_driven.create_parameterized_test("performance_validation", func(test_case):
		# Simulate some processing time
		OS.delay_usec(1000)	 # 1ms delay per test case
		return test_case["value"] >= 0 and test_case["active"]
	)

	performance_test.set_data_source(data_source)

	# Test different execution modes
	print("Performance Test with 100 test cases:")

	# Sequential execution
	var sequential_executor = data_driven.create_test_executor("Sequential_Performance")
	sequential_executor.add_parameterized_test(performance_test)

	var seq_start = Time.get_ticks_usec() / 1000000.0
	var seq_results = sequential_executor.execute_all()
	var seq_end = Time.get_ticks_usec() / 1000000.0

	print("	 Sequential execution: %.3fs" % (seq_end - seq_start))

	# Parallel execution
	var parallel_executor = data_driven.create_test_executor("Parallel_Performance")
	parallel_executor.add_parameterized_test(performance_test)
	parallel_executor.set_parallel_execution(true, 4)

	var par_start = Time.get_ticks_usec() / 1000000.0
	var _par_results = parallel_executor.execute_all()
	var par_end = Time.get_ticks_usec() / 1000000.0

	print("	 Parallel execution (4 threads): %.3fs" % (par_end - par_start))

	# Calculate speedup
	var speedup = (seq_end - seq_start) / (par_end - par_start)
	print("	 Speedup: %.2fx" % speedup)

	print("	 Results: %d/%d tests passed" % [
		seq_results.filter(func(r): return r.success).size(),
		seq_results.size()
	])
	print()

# ------------------------------------------------------------------------------
# RUN ALL EXAMPLES
# ------------------------------------------------------------------------------
func run_examples() -> void:
	"""Run all examples"""
	example_array_data_source()
	example_csv_data_source()
	example_test_matrix()
	example_advanced_parameterized_testing()
	example_batch_execution_reporting()
	example_gdsentry_integration()
	example_performance_scaling()

	print("🎉 All DataDrivenTest examples completed!")
	print("\n💡 Key Takeaways:")
	print("	 • Data-driven testing enables comprehensive test coverage with minimal code")
	print("	 • CSV/JSON integration allows external test data management")
	print("	 • Test matrices support multi-dimensional compatibility testing")
	print("	 • Parallel execution provides significant performance improvements")
	print("	 • GDSentry integration enables seamless test framework compatibility")
	print("	 • Batch reporting provides comprehensive test result analysis")
	print("\n📖 For more advanced usage, see the DataDrivenTest class documentation.")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	if data_driven:
		data_driven.queue_free()
