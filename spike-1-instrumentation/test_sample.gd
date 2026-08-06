extends Node

# Simple test file for instrumentation spike
# Tests common GDScript patterns

func test_basic_assignment():
	var x = 5
	var y = 10
	var result = x + y
	assert(result == 15, "Basic math should work")
	return true

func test_conditionals():
	var value = 42
	if value > 0:
		return true
	else:
		return false

func test_loops():
	var sum = 0
	for i in range(5):
		sum += i
	assert(sum == 10, "Loop sum should be 10")
	return true

func test_function_calls():
	var result = _helper_function(3, 4)
	assert(result == 7, "Helper should return sum")
	return true

func _helper_function(a: int, b: int) -> int:
	var temp = a + b
	return temp

func _ready():
	print("Running test_sample.gd")
	test_basic_assignment()
	test_conditionals()
	test_loops()
	test_function_calls()
	print("All tests passed!")
