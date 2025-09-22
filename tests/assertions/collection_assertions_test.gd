# GDSentry - Collection Assertions Tests
# Comprehensive testing of collection assertion functionality
#
# Tests collection assertions including:
# - Array size, content, and structure validation
# - Dictionary key/value assertions and operations
# - Sorting and uniqueness validation
# - Collection diffing and comparison
# - Set operations (intersection, union, subset)
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name CollectionAssertionsTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Collection assertions comprehensive validation"
	test_tags = ["assertions", "collection", "array", "dictionary", "validation"]
	test_priority = "high"
	test_category = "assertions"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all collection assertions tests"""
	run_test("test_array_basic_assertions", func(): return test_array_basic_assertions())
	run_test("test_array_content_assertions", func(): return test_array_content_assertions())
	run_test("test_array_sorting_assertions", func(): return test_array_sorting_assertions())
	run_test("test_array_uniqueness_assertions", func(): return test_array_uniqueness_assertions())
	run_test("test_dictionary_basic_assertions", func(): return test_dictionary_basic_assertions())
	run_test("test_dictionary_content_assertions", func(): return test_dictionary_content_assertions())
	run_test("test_collection_operations_assertions", func(): return test_collection_operations_assertions())
	run_test("test_collection_diffing_assertions", func(): return test_collection_diffing_assertions())

# ------------------------------------------------------------------------------
# ARRAY BASIC ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_array_basic_assertions() -> bool:
	"""Test basic array assertions: equals, size, empty/not_empty"""
	var success := true

	# Test array equals
	var array1 := [1, 2, 3, 4, 5]
	var array2 := [1, 2, 3, 4, 5]
	var array3 := [1, 2, 3, 4, 6]

	success = success and CollectionAssertions.assert_array_equals(array1, array2, "Arrays should be equal")
	success = success and assert_false(CollectionAssertions.assert_array_equals(array1, array3, "Arrays should not be equal"), "Arrays should not be equal")

	# Test array size
	success = success and CollectionAssertions.assert_array_size(array1, 5, "Array should have size 5")
	success = success and assert_false(CollectionAssertions.assert_array_size(array1, 3, "Array should not have size 3"), "Array should not have size 3")

	# Test array empty/not_empty
	var empty_array: Array = []
	var non_empty_array := [1, 2, 3]

	success = success and CollectionAssertions.assert_array_empty(empty_array, "Array should be empty")
	success = success and assert_false(CollectionAssertions.assert_array_empty(non_empty_array, "Array should not be empty"), "Array should not be empty")

	success = success and CollectionAssertions.assert_array_not_empty(non_empty_array, "Array should not be empty")
	success = success and assert_false(CollectionAssertions.assert_array_not_empty(empty_array, "Array should not be empty"), "Array should not be empty")

	return success

func test_array_content_assertions() -> bool:
	"""Test array content assertions: contains, not_contains, contains_all, contains_any"""
	var success := true

	var test_array := ["apple", "banana", "cherry", "date"]

	# Test contains
	success = success and CollectionAssertions.assert_array_contains(test_array, "banana", "Array should contain banana")
	success = success and assert_false(CollectionAssertions.assert_array_contains(test_array, "grape", "Array should not contain grape"), "Array should not contain grape")

	# Test not_contains
	success = success and CollectionAssertions.assert_array_not_contains(test_array, "grape", "Array should not contain grape")
	success = success and assert_false(CollectionAssertions.assert_array_not_contains(test_array, "banana", "Array should not contain banana"), "Array should not contain banana")

	# Test contains_all
	var subset_all := ["apple", "cherry"]
	var subset_partial := ["apple", "grape"]

	success = success and CollectionAssertions.assert_array_contains_all(test_array, subset_all, "Array should contain all subset elements")
	success = success and assert_false(CollectionAssertions.assert_array_contains_all(test_array, subset_partial, "Array should not contain all subset elements"), "Array should not contain all subset elements")

	# Test contains_any
	var any_match := ["grape", "banana", "orange"]
	var no_match := ["grape", "orange", "kiwi"]

	success = success and CollectionAssertions.assert_array_contains_any(test_array, any_match, "Array should contain at least one element")
	success = success and assert_false(CollectionAssertions.assert_array_contains_any(test_array, no_match, "Array should not contain any elements"), "Array should not contain any elements")

	return success

func test_array_sorting_assertions() -> bool:
	"""Test array sorting assertions: sorted_ascending, sorted_descending"""
	var success := true

	# Test sorted ascending
	var sorted_asc := [1, 2, 3, 4, 5]
	var not_sorted_asc := [1, 3, 2, 4, 5]

	success = success and CollectionAssertions.assert_array_sorted_ascending(sorted_asc, "Array should be sorted ascending")
	success = success and assert_false(CollectionAssertions.assert_array_sorted_ascending(not_sorted_asc, "Array should not be sorted ascending"), "Array should not be sorted ascending")

	# Test sorted descending
	var sorted_desc := [5, 4, 3, 2, 1]
	var not_sorted_desc := [5, 3, 4, 2, 1]

	success = success and CollectionAssertions.assert_array_sorted_descending(sorted_desc, "Array should be sorted descending")
	success = success and assert_false(CollectionAssertions.assert_array_sorted_descending(not_sorted_desc, "Array should not be sorted descending"), "Array should not be sorted descending")

	# Test with different data types
	var strings_sorted := ["apple", "banana", "cherry"]
	var strings_unsorted := ["cherry", "apple", "banana"]

	success = success and CollectionAssertions.assert_array_sorted_ascending(strings_sorted, "String array should be sorted")
	success = success and assert_false(CollectionAssertions.assert_array_sorted_ascending(strings_unsorted, "String array should not be sorted"), "String array should not be sorted")

	return success

func test_array_uniqueness_assertions() -> bool:
	"""Test array uniqueness assertions"""
	var success := true

	var unique_array := [1, 2, 3, 4, 5]
	var duplicate_array := [1, 2, 2, 3, 4]

	success = success and CollectionAssertions.assert_array_unique(unique_array, "Array should contain only unique elements")
	success = success and assert_false(CollectionAssertions.assert_array_unique(duplicate_array, "Array should not contain unique elements"), "Array should not contain unique elements")

	# Test with strings
	var unique_strings := ["apple", "banana", "cherry"]
	var duplicate_strings := ["apple", "banana", "banana"]

	success = success and CollectionAssertions.assert_array_unique(unique_strings, "String array should be unique")
	success = success and assert_false(CollectionAssertions.assert_array_unique(duplicate_strings, "String array should not be unique"), "String array should not be unique")

	return success

# ------------------------------------------------------------------------------
# DICTIONARY BASIC ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_dictionary_basic_assertions() -> bool:
	"""Test basic dictionary assertions: equals, size, empty/not_empty"""
	var success := true

	# Test dictionary equals
	var dict1 := {"a": 1, "b": 2, "c": 3}
	var dict2 := {"a": 1, "b": 2, "c": 3}
	var dict3 := {"a": 1, "b": 2, "c": 4}

	success = success and CollectionAssertions.assert_dict_equals(dict1, dict2, "Dictionaries should be equal")
	success = success and assert_false(CollectionAssertions.assert_dict_equals(dict1, dict3, "Dictionaries should not be equal"), "Dictionaries should not be equal")

	# Test dictionary size
	success = success and CollectionAssertions.assert_dict_size(dict1, 3, "Dictionary should have size 3")
	success = success and assert_false(CollectionAssertions.assert_dict_size(dict1, 2, "Dictionary should not have size 2"), "Dictionary should not have size 2")

	# Test dictionary empty/not_empty
	var empty_dict := {}
	var non_empty_dict := {"key": "value"}

	success = success and CollectionAssertions.assert_dict_empty(empty_dict, "Dictionary should be empty")
	success = success and assert_false(CollectionAssertions.assert_dict_empty(non_empty_dict, "Dictionary should not be empty"), "Dictionary should not be empty")

	success = success and CollectionAssertions.assert_dict_not_empty(non_empty_dict, "Dictionary should not be empty")
	success = success and assert_false(CollectionAssertions.assert_dict_not_empty(empty_dict, "Dictionary should not be empty"), "Dictionary should not be empty")

	return success

func test_dictionary_content_assertions() -> bool:
	"""Test dictionary content assertions: has_key, not_has_key, has_value, value_equals"""
	var success := true

	var test_dict := {"name": "Alice", "age": 30, "city": "New York"}

	# Test has_key
	success = success and CollectionAssertions.assert_dict_has_key(test_dict, "name", "Dictionary should have name key")
	success = success and assert_false(CollectionAssertions.assert_dict_has_key(test_dict, "salary", "Dictionary should not have salary key"), "Dictionary should not have salary key")

	# Test not_has_key
	success = success and CollectionAssertions.assert_dict_not_has_key(test_dict, "salary", "Dictionary should not have salary key")
	success = success and assert_false(CollectionAssertions.assert_dict_not_has_key(test_dict, "name", "Dictionary should not have name key"), "Dictionary should not have name key")

	# Test has_value
	success = success and CollectionAssertions.assert_dict_has_value(test_dict, "Alice", "Dictionary should contain Alice value")
	success = success and assert_false(CollectionAssertions.assert_dict_has_value(test_dict, "Bob", "Dictionary should not contain Bob value"), "Dictionary should not contain Bob value")

	# Test value_equals
	success = success and CollectionAssertions.assert_dict_value_equals(test_dict, "age", 30, "Age should equal 30")
	success = success and assert_false(CollectionAssertions.assert_dict_value_equals(test_dict, "age", 25, "Age should not equal 25"), "Age should not equal 25")

	return success

func test_collection_operations_assertions() -> bool:
	"""Test collection operation assertions: subset, intersection, union"""
	var success := true

	var array1 := [1, 2, 3, 4, 5]
	var array2 := [3, 4, 5, 6, 7]
	var array3 := [1, 2, 3]

	# Test subset
	success = success and CollectionAssertions.assert_array_subset(array3, array1, "Array3 should be subset of array1")
	success = success and assert_false(CollectionAssertions.assert_array_subset(array2, array3, "Array2 should not be subset of array3"), "Array2 should not be subset of array3")

	# Test intersection
	var expected_intersection := [3, 4, 5]
	success = success and CollectionAssertions.assert_array_intersection(array1, array2, expected_intersection, "Intersection should match expected")

	# Test union
	var expected_union := [1, 2, 3, 4, 5, 6, 7]
	success = success and CollectionAssertions.assert_array_union(array1, array2, expected_union, "Union should match expected")

	return success

func test_collection_diffing_assertions() -> bool:
	"""Test collection diffing functionality"""
	var success := true

	var array1 := [1, 2, 3, 4]
	var array2 := [2, 3, 4, 5, 6]

	# Test array diff
	var array_diff := CollectionAssertions.get_array_diff(array1, array2)
	success = success and assert_not_null(array_diff, "Array diff should be generated")
	success = success and assert_true(array_diff.has("added"), "Diff should have added field")
	success = success and assert_true(array_diff.has("removed"), "Diff should have removed field")
	success = success and assert_true(array_diff.has("common"), "Diff should have common field")

	# Verify diff content
	if array_diff:
		success = success and assert_equals(array_diff.added.size(), 2, "Should have 2 added elements")
		success = success and assert_equals(array_diff.removed.size(), 1, "Should have 1 removed element")
		success = success and assert_equals(array_diff.common.size(), 3, "Should have 3 common elements")

	# Test dictionary diff
	var dict1 := {"a": 1, "b": 2, "c": 3}
	var dict2 := {"b": 2, "c": 4, "d": 5}

	var dict_diff := CollectionAssertions.get_dict_diff(dict1, dict2)
	success = success and assert_not_null(dict_diff, "Dictionary diff should be generated")
	success = success and assert_true(dict_diff.has("added_keys"), "Dict diff should have added_keys field")
	success = success and assert_true(dict_diff.has("removed_keys"), "Dict diff should have removed_keys field")
	success = success and assert_true(dict_diff.has("changed_keys"), "Dict diff should have changed_keys field")

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_array(size: int) -> Array:
	"""Create a test array of specified size"""
	var result := []
	for i in range(size):
		result.append(i + 1)
	return result

func create_test_dictionary(size: int) -> Dictionary:
	"""Create a test dictionary of specified size"""
	var result := {}
	for i in range(size):
		result["key_" + str(i)] = "value_" + str(i)
	return result

func create_sorted_array(size: int, descending: bool = false) -> Array:
	"""Create a sorted array"""
	var result := []
	for i in range(size):
		if descending:
			result.append(size - i)
		else:
			result.append(i + 1)
	return result

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
