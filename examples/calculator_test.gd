# GDSentry - Calculator Test Example
# Example test demonstrating GDSentry framework usage
#
# This example shows how to test a simple calculator class
# using the SceneTreeTest base class for fast unit testing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name CalculatorTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _init():
	test_description = "Test suite for Calculator class functionality"
	test_tags = ["unit", "math", "calculator"]
	test_priority = "high"
	test_category = "core"

# ------------------------------------------------------------------------------
# MOCK CALCULATOR CLASS FOR TESTING
# ------------------------------------------------------------------------------
class Calculator:
	var memory: float = 0.0

	func add(a: float, b: float) -> float:
		return a + b

	func subtract(a: float, b: float) -> float:
		return a - b

	func multiply(a: float, b: float) -> float:
		return a * b

	func divide(a: float, b: float) -> float:
		if b == 0:
			return 0.0  # Simple error handling for test
		return a / b

	func square_root(value: float) -> float:
		if value < 0:
			return 0.0  # Simple error handling for test
		return sqrt(value)

	func power(base: float, exponent: float) -> float:
		return pow(base, exponent)

	func store_in_memory(value: float) -> void:
		memory = value

	func recall_memory() -> float:
		return memory

	func clear_memory() -> void:
		memory = 0.0

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all calculator tests"""
	var calculator = CalculatorTest.new()

	run_test("test_basic_addition", func(): return test_basic_addition(calculator))
	run_test("test_basic_subtraction", func(): return test_basic_subtraction(calculator))
	run_test("test_basic_multiplication", func(): return test_basic_multiplication(calculator))
	run_test("test_basic_division", func(): return test_basic_division(calculator))
	run_test("test_division_by_zero", func(): return test_division_by_zero(calculator))
	run_test("test_square_root", func(): return test_square_root(calculator))
	run_test("test_negative_square_root", func(): return test_negative_square_root(calculator))
	run_test("test_power_function", func(): return test_power_function(calculator))
	run_test("test_memory_operations", func(): return test_memory_operations(calculator))
	run_test("test_performance", func(): return test_performance())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_basic_addition(calc: Calculator) -> bool:
	"""Test basic addition functionality"""
	var result1 = calc.add(2, 3)
	var result2 = calc.add(-5, 10)
	var result3 = calc.add(0, 0)
	var result4 = calc.add(3.14, 2.86)

	return assert_equals(result1, 5, "2 + 3 should equal 5") and \
		   assert_equals(result2, 5, "-5 + 10 should equal 5") and \
		   assert_equals(result3, 0, "0 + 0 should equal 0") and \
		   assert_equals(result4, 6.0, "3.14 + 2.86 should equal 6.0")

func test_basic_subtraction(calc: Calculator) -> bool:
	"""Test basic subtraction functionality"""
	var result1 = calc.subtract(10, 3)
	var result2 = calc.subtract(5, 10)
	var result3 = calc.subtract(0, 0)

	return assert_equals(result1, 7, "10 - 3 should equal 7") and \
		   assert_equals(result2, -5, "5 - 10 should equal -5") and \
		   assert_equals(result3, 0, "0 - 0 should equal 0")

func test_basic_multiplication(calc: Calculator) -> bool:
	"""Test basic multiplication functionality"""
	var result1 = calc.multiply(4, 3)
	var result2 = calc.multiply(-2, 5)
	var result3 = calc.multiply(0, 100)

	return assert_equals(result1, 12, "4 * 3 should equal 12") and \
		   assert_equals(result2, -10, "-2 * 5 should equal -10") and \
		   assert_equals(result3, 0, "0 * 100 should equal 0")

func test_basic_division(calc: Calculator) -> bool:
	"""Test basic division functionality"""
	var result1 = calc.divide(10, 2)
	var result2 = calc.divide(7, 2)
	var result3 = calc.divide(0, 5)

	return assert_equals(result1, 5, "10 / 2 should equal 5") and \
		   assert_equals(result2, 3.5, "7 / 2 should equal 3.5") and \
		   assert_equals(result3, 0, "0 / 5 should equal 0")

func test_division_by_zero(calc: Calculator) -> bool:
	"""Test division by zero handling"""
	var result = calc.divide(10, 0)
	return assert_equals(result, 0.0, "Division by zero should return 0.0 (error handling)")

func test_square_root(calc: Calculator) -> bool:
	"""Test square root functionality"""
	var result1 = calc.square_root(9)
	var result2 = calc.square_root(16)
	var result3 = calc.square_root(0)

	return assert_equals(result1, 3, "√9 should equal 3") and \
		   assert_equals(result2, 4, "√16 should equal 4") and \
		   assert_equals(result3, 0, "√0 should equal 0")

func test_negative_square_root(calc: Calculator) -> bool:
	"""Test negative square root handling"""
	var result = calc.square_root(-4)
	return assert_equals(result, 0.0, "√(-4) should return 0.0 (error handling)")

func test_power_function(calc: Calculator) -> bool:
	"""Test power function"""
	var result1 = calc.power(2, 3)
	var result2 = calc.power(5, 0)
	var result3 = calc.power(3, 2)

	return assert_equals(result1, 8, "2^3 should equal 8") and \
		   assert_equals(result2, 1, "5^0 should equal 1") and \
		   assert_equals(result3, 9, "3^2 should equal 9")

func test_memory_operations(calc: Calculator) -> bool:
	"""Test memory functionality"""
	# Test storing and recalling
	calc.store_in_memory(42.5)
	var recalled1 = calc.recall_memory()

	# Test clearing
	calc.clear_memory()
	var recalled2 = calc.recall_memory()

	return assert_equals(recalled1, 42.5, "Memory recall should return stored value") and \
		   assert_equals(recalled2, 0.0, "Memory should be cleared to 0.0")

func test_performance() -> bool:
	"""Test performance of calculator operations"""
	var calc = CalculatorTest.new()

	# Benchmark addition operations
	var benchmark_result = benchmark_function(func(): return calc.add(123.45, 678.90), 10000)

	var avg_time = benchmark_result.average_time
	var acceptable_time = 0.0001  # 0.1ms per operation

	return assert_less_than(avg_time, acceptable_time,
		"Average operation time %.6fs exceeds acceptable limit %.6fs" % [avg_time, acceptable_time])
