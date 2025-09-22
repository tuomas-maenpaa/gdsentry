# GDSentry - Data-Driven Test Framework
# Comprehensive data-driven testing utilities for GDSentry
#
# This framework provides data-driven testing capabilities including:
# - CSV/JSON data source integration for parameterized tests
# - Test matrix generation for multi-dimensional testing
# - Parameterized test execution with data binding
# - Result aggregation and reporting for data-driven scenarios
# - Integration with GDSentry's existing test infrastructure
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name DataDrivenTest

# ------------------------------------------------------------------------------
# FRAMEWORK CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_CSV_DELIMITER = ","
const DEFAULT_JSON_ARRAY_KEY = "test_cases"
const MAX_DATA_ROWS = 10000
const DEFAULT_TIMEOUT = 30.0

# ------------------------------------------------------------------------------
# FRAMEWORK METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

# ------------------------------------------------------------------------------
# DATA SOURCE CLASSES
# ------------------------------------------------------------------------------
class DataSource:
	var name: String
	var data: Array[Dictionary]
	var headers: Array[String]
	var source_type: String	 # "csv", "json", "array"

	func _init(source_name: String = ""):
		name = source_name
		data = []
		headers = []
		source_type = "array"

	func get_row_count() -> int:
		return data.size()

	func get_column_count() -> int:
		return headers.size()

	func get_row(index: int) -> Dictionary:
		if index >= 0 and index < data.size():
			return data[index].duplicate(true)
		return {}

	func get_column_values(column_name: String) -> Array:
		var values = []
		for row in data:
			if row.has(column_name):
				values.append(row[column_name])
		return values

	func filter_rows(filter_func: Callable) -> Array[Dictionary]:
		var filtered = []
		for row in data:
			if filter_func.call(row):
				filtered.append(row.duplicate(true))
		return filtered

	func to_dictionary() -> Dictionary:
		return {
			"name": name,
			"source_type": source_type,
			"headers": headers.duplicate(),
			"data": data.duplicate(true),
			"row_count": get_row_count(),
			"column_count": get_column_count()
		}

# ------------------------------------------------------------------------------
# PARAMETERIZED TEST CLASSES
# ------------------------------------------------------------------------------
class ParameterizedTest:
	var test_name: String
	var test_function: Callable
	var data_source: DataSource
	var filter_function: Callable
	var timeout: float
	var retry_count: int
	var description: String

	func _init(test_name_param: String, test_func: Callable):
		test_name = test_name_param
		test_function = test_func
		data_source = null
		filter_function = Callable()
		timeout = DEFAULT_TIMEOUT
		retry_count = 0
		description = test_name_param

	func set_data_source(source: DataSource) -> ParameterizedTest:
		data_source = source
		return self

	func set_filter(filter_func: Callable) -> ParameterizedTest:
		filter_function = filter_func
		return self

	func set_timeout(timeout_seconds: float) -> ParameterizedTest:
		timeout = timeout_seconds
		return self

	func set_retry_count(count: int) -> ParameterizedTest:
		retry_count = count
		return self

	func set_description(desc: String) -> ParameterizedTest:
		description = desc
		return self

	func get_test_cases() -> Array[Dictionary]:
		if not data_source:
			return []

		var test_cases = data_source.data.duplicate(true)

		if filter_function.is_valid():
			test_cases = test_cases.filter(filter_function)

		return test_cases

	func to_dictionary() -> Dictionary:
		return {
			"test_name": test_name,
			"description": description,
			"data_source": data_source.name if data_source else "",
			"timeout": timeout,
			"retry_count": retry_count,
			"test_case_count": get_test_cases().size()
		}

# ------------------------------------------------------------------------------
# TEST MATRIX CLASSES
# ------------------------------------------------------------------------------
class TestDimension:
	var name: String
	var values: Array
	var value_names: Array[String]

	func _init(dimension_name: String, dimension_values: Array, names: Array[String] = []):
		name = dimension_name
		values = dimension_values.duplicate(true)
		value_names = names.duplicate() if not names.is_empty() else dimension_values.map(func(v): return str(v))

	func get_value_count() -> int:
		return values.size()

	func get_value(index: int):
		if index >= 0 and index < values.size():
			return values[index]
		return null

	func get_value_name(index: int) -> String:
		if index >= 0 and index < value_names.size():
			return value_names[index]
		return str(get_value(index))

class TestMatrix:
	var name: String
	var dimensions: Array[TestDimension]
	var generated_cases: Array[Dictionary]
	var exclude_combinations: Array[Array]

	func _init(matrix_name: String):
		name = matrix_name
		dimensions = []
		generated_cases = []
		exclude_combinations = []

	func add_dimension(dimension_name: String, values: Array, names: Array[String] = []) -> TestMatrix:
		var dimension = TestDimension.new(dimension_name, values, names)
		dimensions.append(dimension)
		return self

	func exclude_combination(combination: Array) -> TestMatrix:
		exclude_combinations.append(combination.duplicate())
		return self

	func generate_test_cases() -> Array[Dictionary]:
		generated_cases.clear()

		if dimensions.is_empty():
			return generated_cases

		var indices = []
		for i in range(dimensions.size()):
			indices.append(0)

		# Generate all combinations using cartesian product
		while true:
			var test_case = {}
			var case_values = []

			for i in range(dimensions.size()):
				var dimension = dimensions[i]
				var value_index = indices[i]
				var value = dimension.get_value(value_index)
				var value_name = dimension.get_value_name(value_index)

				test_case[dimension.name] = value
				test_case[dimension.name + "_name"] = value_name
				case_values.append(value)

			# Check if this combination should be excluded
			var should_exclude = false
			for exclusion in exclude_combinations:
				if _matches_exclusion(case_values, exclusion):
					should_exclude = true
					break

			if not should_exclude:
				test_case["case_id"] = _generate_case_id(indices)
				test_case["matrix_name"] = name
				generated_cases.append(test_case.duplicate())

			# Increment indices
			if not _increment_indices(indices):
				break

		return generated_cases.duplicate()

	func _increment_indices(indices: Array) -> bool:
		for i in range(indices.size() - 1, -1, -1):
			indices[i] += 1
			if indices[i] < dimensions[i].get_value_count():
				return true
			indices[i] = 0
		return false

	func _matches_exclusion(values: Array, exclusion: Array) -> bool:
		if values.size() != exclusion.size():
			return false

		for i in range(values.size()):
			if values[i] != exclusion[i]:
				return false
		return true

	func _generate_case_id(indices: Array) -> String:
		var id_parts = []
		for i in range(indices.size()):
			var dimension = dimensions[i]
			var value_name = dimension.get_value_name(indices[i])
			id_parts.append(value_name)
		return "_".join(id_parts)

	func get_case_count() -> int:
		return generated_cases.size()

	func get_case(index: int) -> Dictionary:
		if index >= 0 and index < generated_cases.size():
			return generated_cases[index].duplicate(true)
		return {}

	func filter_cases(filter_func: Callable) -> Array[Dictionary]:
		return generated_cases.filter(filter_func)

# ------------------------------------------------------------------------------
# DATA-DRIVEN TEST EXECUTOR
# ------------------------------------------------------------------------------
class DataDrivenTestExecutor:
	var test_suite_name: String
	var parameterized_tests: Array[ParameterizedTest]
	var test_matrix: TestMatrix
	var results: Array[TestResult]
	var global_timeout: float
	var parallel_execution: bool
	var max_parallel_tests: int

	func _init(suite_name: String = ""):
		test_suite_name = suite_name if not suite_name.is_empty() else "DataDrivenTestSuite"
		parameterized_tests = []
		test_matrix = null
		results = []
		global_timeout = DEFAULT_TIMEOUT
		parallel_execution = false
		max_parallel_tests = 4

	func add_parameterized_test(test: ParameterizedTest) -> DataDrivenTestExecutor:
		parameterized_tests.append(test)
		return self

	func set_test_matrix(matrix: TestMatrix) -> DataDrivenTestExecutor:
		test_matrix = matrix
		return self

	func set_global_timeout(timeout_seconds: float) -> DataDrivenTestExecutor:
		global_timeout = timeout_seconds
		return self

	func set_parallel_execution(enabled: bool, max_parallel: int = 4) -> DataDrivenTestExecutor:
		parallel_execution = enabled
		max_parallel_tests = max_parallel
		return self

	func execute_all() -> Array[TestResult]:
		results.clear()

		if parallel_execution:
			return _execute_parallel()
		else:
			return _execute_sequential()

	func _execute_sequential() -> Array[TestResult]:
		# Execute parameterized tests
		for test in parameterized_tests:
			var test_results = _execute_parameterized_test(test)
			results.append_array(test_results)

		# Execute test matrix if present
		if test_matrix:
			var matrix_results = _execute_test_matrix()
			results.append_array(matrix_results)

		return results.duplicate()

	func _execute_parallel() -> Array[TestResult]:
		var threads = []
		var thread_results = []

		# Create threads for parameterized tests
		for test in parameterized_tests:
			var thread = Thread.new()
			threads.append(thread)
			thread_results.append({"thread": thread, "type": "parameterized", "test": test})

			thread.start(func():
				return _execute_parameterized_test(test)
			)

			# Limit concurrent threads
			if threads.size() >= max_parallel_tests:
				_collect_thread_results(threads, thread_results)
				threads.clear()

		# Execute test matrix if present
		if test_matrix:
			var matrix_thread = Thread.new()
			threads.append(matrix_thread)
			thread_results.append({"thread": matrix_thread, "type": "matrix", "matrix": test_matrix})

			matrix_thread.start(func():
				return _execute_test_matrix()
			)

		# Collect remaining results
		_collect_thread_results(threads, thread_results)

		return results.duplicate()

	func _collect_thread_results(threads: Array, thread_results: Array) -> void:
		for i in range(threads.size()):
			var thread = threads[i]
			var thread_data = thread_results[i]
			var result = thread.wait_to_finish()

			if thread_data.type == "parameterized":
				results.append_array(result)
			else:  # matrix
				results.append_array(result)

	func _execute_parameterized_test(test: ParameterizedTest) -> Array[TestResult]:
		var test_results = []
		var test_cases = test.get_test_cases()

		for case_index in range(test_cases.size()):
			var test_case = test_cases[case_index]
			var result = TestResult.new()

			result.test_name = test.test_name
			result.test_case_id = str(case_index)
			result.data_source = test.data_source.name if test.data_source else "inline"
			result.start_time = Time.get_ticks_usec() / 1000000.0

			# Execute test with data binding
			var success = true
			var error_msg = ""
			var execution_result = null

			var thread = Thread.new()
			var result_data = {"success": false, "result": null, "error": ""}

			thread.start(func():
				result_data.success = true
				result_data.result = test.test_function.call(test_case)
			)

			# Wait for completion or timeout
			var start_wait = Time.get_ticks_usec() / 1000000.0
			while thread.is_alive():
				if (Time.get_ticks_usec() / 1000000.0) - start_wait > test.timeout:
					thread.wait_to_finish()
					success = false
					error_msg = "Test timeout after %.2f seconds" % test.timeout
					break
				OS.delay_usec(10000)  # 10ms delay

			if thread.is_alive():
				thread.wait_to_finish()

			if result_data.success:
				execution_result = result_data.result
			else:
				success = false
				error_msg = result_data.error if not result_data.error.is_empty() else "Test execution failed"

			result.end_time = Time.get_ticks_usec() / 1000000.0
			result.execution_time = result.end_time - result.start_time
			result.success = success
			result.error_message = error_msg
			result.test_data = test_case.duplicate(true)
			result.result_data = execution_result

			test_results.append(result)

		return test_results

	func _execute_test_matrix() -> Array[TestResult]:
		var matrix_results = []
		var test_cases = test_matrix.generate_test_cases()

		for test_case in test_cases:
			var result = TestResult.new()

			result.test_name = test_matrix.name
			result.test_case_id = test_case.get("case_id", "unknown")
			result.data_source = "matrix"
			result.start_time = Time.get_ticks_usec() / 1000000.0

			# Execute matrix test case (placeholder - would be customized)
			var success = true
			var error_msg = ""
			var execution_result = test_case.duplicate(true)

			# Simulate test execution
			OS.delay_usec(50000)  # 50ms delay to simulate work

			result.end_time = Time.get_ticks_usec() / 1000000.0
			result.execution_time = result.end_time - result.start_time
			result.success = success
			result.error_message = error_msg
			result.test_data = test_case.duplicate(true)
			result.result_data = execution_result

			matrix_results.append(result)

		return matrix_results

	func get_successful_tests() -> Array[TestResult]:
		return results.filter(func(r): return r.success)

	func get_failed_tests() -> Array[TestResult]:
		return results.filter(func(r): return not r.success)

	func generate_report() -> Dictionary:
		var total_tests = results.size()
		var successful_tests = get_successful_tests().size()
		var failed_tests = get_failed_tests().size()

		var total_execution_time = results.map(func(r): return r.execution_time).reduce(func(acc, val): return acc + val, 0.0)
		var avg_execution_time = total_execution_time / total_tests if total_tests > 0 else 0.0

		var data_sources = {}
		for result in results:
			var source = result.data_source
			if not data_sources.has(source):
				data_sources[source] = 0
			data_sources[source] += 1

		return {
			"suite_name": test_suite_name,
			"total_tests": total_tests,
			"successful_tests": successful_tests,
			"failed_tests": failed_tests,
			"success_rate": successful_tests / float(total_tests) * 100.0 if total_tests > 0 else 0.0,
			"total_execution_time": total_execution_time,
			"average_execution_time": avg_execution_time,
			"data_sources": data_sources,
			"parameterized_test_count": parameterized_tests.size(),
			"has_matrix": test_matrix != null,
			"matrix_case_count": test_matrix.get_case_count() if test_matrix else 0
		}

# ------------------------------------------------------------------------------
# TEST RESULT CLASS
# ------------------------------------------------------------------------------
class TestResult:
	var test_name: String
	var test_case_id: String
	var data_source: String
	var start_time: float
	var end_time: float
	var execution_time: float
	var success: bool
	var error_message: String
	var test_data: Dictionary
	var result_data

	func _init():
		test_name = ""
		test_case_id = ""
		data_source = ""
		start_time = 0.0
		end_time = 0.0
		execution_time = 0.0
		success = false
		error_message = ""
		test_data = {}
		result_data = null

	func to_dictionary() -> Dictionary:
		return {
			"test_name": test_name,
			"test_case_id": test_case_id,
			"data_source": data_source,
			"start_time": start_time,
			"end_time": end_time,
			"execution_time": execution_time,
			"success": success,
			"error_message": error_message,
			"test_data": test_data.duplicate(true),
			"result_data": result_data
		}

# ------------------------------------------------------------------------------
# DATA SOURCE FACTORY METHODS
# ------------------------------------------------------------------------------
func create_csv_data_source(file_path: String, delimiter: String = DEFAULT_CSV_DELIMITER) -> DataSource:
	"""Create a data source from CSV file"""
	var source = DataSource.new("csv_" + file_path.get_file())

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("DataDrivenTest: Failed to open CSV file: %s" % file_path)
		return null

	source.source_type = "csv"

	# Read headers
	var header_line = file.get_line()
	if header_line.is_empty():
		push_error("DataDrivenTest: CSV file is empty or missing headers: %s" % file_path)
		file.close()
		return null

	source.headers = header_line.split(delimiter)
	for i in range(source.headers.size()):
		source.headers[i] = source.headers[i].strip_edges()

	# Read data rows
	while not file.eof_reached():
		var line = file.get_line()
		if line.is_empty():
			continue

		var values = line.split(delimiter)
		if values.size() != source.headers.size():
			push_warning("DataDrivenTest: Row has %d columns but expected %d, skipping" % [values.size(), source.headers.size()])
			continue

		var row = {}
		for i in range(values.size()):
			var value = values[i].strip_edges()
			# Try to convert to number if possible
			if value.is_valid_int():
				row[source.headers[i]] = value.to_int()
			elif value.is_valid_float():
				row[source.headers[i]] = value.to_float()
			else:
				row[source.headers[i]] = value

		source.data.append(row)

		# Safety limit
		if source.data.size() >= MAX_DATA_ROWS:
			push_warning("DataDrivenTest: Reached maximum data rows limit (%d), stopping read" % MAX_DATA_ROWS)
			break

	file.close()

	print("DataDrivenTest: Loaded %d rows from CSV file: %s" % [source.data.size(), file_path])
	return source

func create_json_data_source(file_path: String, array_key: String = DEFAULT_JSON_ARRAY_KEY) -> DataSource:
	"""Create a data source from JSON file"""
	var source = DataSource.new("json_" + file_path.get_file())

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("DataDrivenTest: Failed to open JSON file: %s" % file_path)
		return null

	source.source_type = "json"

	var json_content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_content)

	if parse_result != OK:
		push_error("DataDrivenTest: Failed to parse JSON file: %s (Error: %s)" % [file_path, json.get_error_message()])
		return null

	var data = json.get_data()

	# Handle different JSON structures
	var test_cases = []

	if data is Array:
		test_cases = data
	elif data is Dictionary:
		if data.has(array_key):
			test_cases = data[array_key]
		else:
			# Treat the dictionary as a single test case
			test_cases = [data]
	else:
		push_error("DataDrivenTest: Unsupported JSON structure in file: %s" % file_path)
		return null

	# Process test cases
	for case in test_cases:
		if case is Dictionary:
			source.data.append(case.duplicate(true))

			# Collect headers from all cases
			for key in case.keys():
				if not source.headers.has(key):
					source.headers.append(key)

		# Safety limit
		if source.data.size() >= MAX_DATA_ROWS:
			push_warning("DataDrivenTest: Reached maximum data rows limit (%d), stopping read" % MAX_DATA_ROWS)
			break

	print("DataDrivenTest: Loaded %d test cases from JSON file: %s" % [source.data.size(), file_path])
	return source

func create_array_data_source(data_array: Array, source_name: String = "array_data") -> DataSource:
	"""Create a data source from array of dictionaries"""
	var source = DataSource.new(source_name)
	source.source_type = "array"

	for item in data_array:
		if item is Dictionary:
			source.data.append(item.duplicate(true))

			# Collect headers
			for key in item.keys():
				if not source.headers.has(key):
					source.headers.append(key)

		# Safety limit
		if source.data.size() >= MAX_DATA_ROWS:
			push_warning("DataDrivenTest: Reached maximum data rows limit (%d), stopping read" % MAX_DATA_ROWS)
			break

	print("DataDrivenTest: Created data source with %d rows from array" % source.data.size())
	return source

# ------------------------------------------------------------------------------
# CONVENIENCE METHODS
# ------------------------------------------------------------------------------
func create_parameterized_test(test_name: String, test_function: Callable) -> ParameterizedTest:
	"""Create a parameterized test"""
	return ParameterizedTest.new(test_name, test_function)

func create_test_matrix(matrix_name: String) -> TestMatrix:
	"""Create a test matrix"""
	return TestMatrix.new(matrix_name)

func create_test_executor(suite_name: String = "") -> DataDrivenTestExecutor:
	"""Create a test executor"""
	return DataDrivenTestExecutor.new(suite_name)

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func export_results_to_csv(results: Array[TestResult], file_path: String) -> bool:
	"""Export test results to CSV file"""
	if results.is_empty():
		push_warning("DataDrivenTest: No results to export")
		return false

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("DataDrivenTest: Failed to open file for writing: %s" % file_path)
		return false

	# Write headers
	var headers = ["test_name", "test_case_id", "data_source", "success", "execution_time", "error_message"]
	file.store_line(",".join(headers))

	# Write data
	for result in results:
		var row = [
			result.test_name,
			result.test_case_id,
			result.data_source,
			str(result.success),
			"%.3f" % result.execution_time,
			"\"%s\"" % result.error_message.replace("\"", "\"\"")  # Escape quotes
		]
		file.store_line(",".join(row))

	file.close()

	print("DataDrivenTest: Exported %d test results to: %s" % [results.size(), file_path])
	return true

func export_results_to_json(results: Array[TestResult], file_path: String) -> bool:
	"""Export test results to JSON file"""
	if results.is_empty():
		push_warning("DataDrivenTest: No results to export")
		return false

	var export_data = {
		"export_timestamp": Time.get_unix_time_from_system(),
		"result_count": results.size(),
		"results": results.map(func(r): return r.to_dictionary())
	}

	var json_string = JSON.stringify(export_data, "\t")

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("DataDrivenTest: Failed to open file for writing: %s" % file_path)
		return false

	file.store_string(json_string)
	file.close()

	print("DataDrivenTest: Exported %d test results to: %s" % [results.size(), file_path])
	return true

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	pass
