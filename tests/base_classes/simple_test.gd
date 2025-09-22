extends GDTest

class_name SimpleTest

func _ready() -> void:
	test_description = "Simple test to verify GDTest inheritance"
	test_tags = ["simple"]
	test_priority = "high"
	test_category = "base_classes"

func run_test_suite() -> void:
	run_test("test_simple", func(): return test_simple())

func test_simple() -> bool:
	print("Simple test executed successfully!")
	return true
