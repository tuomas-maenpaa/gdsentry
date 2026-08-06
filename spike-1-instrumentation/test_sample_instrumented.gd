extends Node

# Simple test file for instrumentation spike
# Tests common GDScript patterns

func test_basic_assignment():
	CoverageTracker.hit("test_sample.gd", 7)
	var x = 5
	CoverageTracker.hit("test_sample.gd", 8)
	var y = 10
	CoverageTracker.hit("test_sample.gd", 9)
	var result = x + y
	CoverageTracker.hit("test_sample.gd", 10)
	assert(result == 15, "Basic math should work")
	CoverageTracker.hit("test_sample.gd", 11)
	return true

func test_conditionals():
	CoverageTracker.hit("test_sample.gd", 14)
	var value = 42
	CoverageTracker.hit("test_sample.gd", 15)
	if value > 0:
		CoverageTracker.hit("test_sample.gd", 16)
		return true
	else:
		CoverageTracker.hit("test_sample.gd", 18)
		return false

func test_loops():
	CoverageTracker.hit("test_sample.gd", 21)
	var sum = 0
	CoverageTracker.hit("test_sample.gd", 22)
	for i in range(5):
		sum += i
	CoverageTracker.hit("test_sample.gd", 24)
	assert(sum == 10, "Loop sum should be 10")
	CoverageTracker.hit("test_sample.gd", 25)
	return true

func test_function_calls():
	CoverageTracker.hit("test_sample.gd", 28)
	var result = _helper_function(3, 4)
	CoverageTracker.hit("test_sample.gd", 29)
	assert(result == 7, "Helper should return sum")
	CoverageTracker.hit("test_sample.gd", 30)
	return true

func _helper_function(a: int, b: int) -> int:
	CoverageTracker.hit("test_sample.gd", 33)
	var temp = a + b
	CoverageTracker.hit("test_sample.gd", 34)
	return temp

func _ready():
	CoverageTracker.hit("test_sample.gd", 37)
	print("Running test_sample.gd")
	CoverageTracker.hit("test_sample.gd", 38)
	test_basic_assignment()
	CoverageTracker.hit("test_sample.gd", 39)
	test_conditionals()
	CoverageTracker.hit("test_sample.gd", 40)
	test_loops()
	CoverageTracker.hit("test_sample.gd", 41)
	test_function_calls()
	CoverageTracker.hit("test_sample.gd", 42)
	print("All tests passed!")
