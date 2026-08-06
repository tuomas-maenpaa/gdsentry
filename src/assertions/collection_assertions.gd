# GDSentry - Collection Assertions
# Specialized assertions for arrays, dictionaries, and other collections
#
# Features:
# - Array content and structure validation
# - Dictionary key/value assertions
# - Collection size and emptiness checks
# - Element presence and ordering validation
# - Collection comparison and diffing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name CollectionAssertions

# ------------------------------------------------------------------------------
# ARRAY ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_array_equals(actual: Array, expected: Array, message: String = "") -> bool:
	"""Assert that two arrays are equal"""
	if actual == expected:
		return true

	var error_msg = message if not message.is_empty() else "Array mismatch:\n  Expected: " + str(expected) + "\n  Actual: " + str(actual)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_size(array: Array, expected_size: int, message: String = "") -> bool:
	"""Assert that array has expected size"""
	if array.size() == expected_size:
		return true

	var error_msg = message if not message.is_empty() else "Array size mismatch: expected " + str(expected_size) + ", got " + str(array.size())
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_empty(array: Array, message: String = "") -> bool:
	"""Assert that array is empty"""
	if array.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "Array is not empty: contains " + str(array.size()) + " elements"
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_not_empty(array: Array, message: String = "") -> bool:
	"""Assert that array is not empty"""
	if not array.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "Array is empty"
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_contains(array: Array, element, message: String = "") -> bool:
	"""Assert that array contains specific element"""
	if array.has(element):
		return true

	var error_msg = message if not message.is_empty() else "Array does not contain element: " + str(element)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_not_contains(array: Array, element, message: String = "") -> bool:
	"""Assert that array does not contain specific element"""
	if not array.has(element):
		return true

	var error_msg = message if not message.is_empty() else "Array contains element: " + str(element)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_contains_all(array: Array, elements: Array, message: String = "") -> bool:
	"""Assert that array contains all specified elements"""
	var missing_elements = []

	for element in elements:
		if not array.has(element):
			missing_elements.append(element)

	if missing_elements.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "Array missing elements: " + str(missing_elements)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_contains_any(array: Array, elements: Array, message: String = "") -> bool:
	"""Assert that array contains at least one of the specified elements"""
	for element in elements:
		if array.has(element):
			return true

	var error_msg = message if not message.is_empty() else "Array does not contain any of: " + str(elements)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_array_sorted_ascending(array: Array, message: String = "") -> bool:
	"""Assert that array is sorted in ascending order"""
	if array.size() <= 1:
		return true

	for i in range(array.size() - 1):
		if array[i] > array[i + 1]:
			var error_msg = message if not message.is_empty() else "Array not sorted ascending at index " + str(i) + ": " + str(array[i]) + " > " + str(array[i + 1])
			GDTestManager.log_test_failure("CollectionAssertions", error_msg)
			return false

	return true

static func assert_array_sorted_descending(array: Array, message: String = "") -> bool:
	"""Assert that array is sorted in descending order"""
	if array.size() <= 1:
		return true

	for i in range(array.size() - 1):
		if array[i] < array[i + 1]:
			var error_msg = message if not message.is_empty() else "Array not sorted descending at index " + str(i) + ": " + str(array[i]) + " < " + str(array[i + 1])
			GDTestManager.log_test_failure("CollectionAssertions", error_msg)
			return false

	return true

static func assert_array_unique(array: Array, message: String = "") -> bool:
	"""Assert that array contains only unique elements"""
	var seen = {}
	var duplicates = []

	for element in array:
		if seen.has(element):
			if not duplicates.has(element):
				duplicates.append(element)
		else:
			seen[element] = true

	if duplicates.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "Array contains duplicate elements: " + str(duplicates)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# DICTIONARY ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_dict_equals(actual: Dictionary, expected: Dictionary, message: String = "") -> bool:
	"""Assert that two dictionaries are equal"""
	if actual == expected:
		return true

	var error_msg = message if not message.is_empty() else "Dictionary mismatch:\n  Expected: " + str(expected) + "\n  Actual: " + str(actual)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_size(dict: Dictionary, expected_size: int, message: String = "") -> bool:
	"""Assert that dictionary has expected size"""
	if dict.size() == expected_size:
		return true

	var error_msg = message if not message.is_empty() else "Dictionary size mismatch: expected " + str(expected_size) + ", got " + str(dict.size())
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_empty(dict: Dictionary, message: String = "") -> bool:
	"""Assert that dictionary is empty"""
	if dict.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "Dictionary is not empty: contains " + str(dict.size()) + " entries"
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_not_empty(dict: Dictionary, message: String = "") -> bool:
	"""Assert that dictionary is not empty"""
	if not dict.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "Dictionary is empty"
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_has_key(dict: Dictionary, key, message: String = "") -> bool:
	"""Assert that dictionary has specific key"""
	if dict.has(key):
		return true

	var error_msg = message if not message.is_empty() else "Dictionary does not have key: " + str(key)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_not_has_key(dict: Dictionary, key, message: String = "") -> bool:
	"""Assert that dictionary does not have specific key"""
	if not dict.has(key):
		return true

	var error_msg = message if not message.is_empty() else "Dictionary has key: " + str(key)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_has_value(dict: Dictionary, value, message: String = "") -> bool:
	"""Assert that dictionary contains specific value"""
	if dict.values().has(value):
		return true

	var error_msg = message if not message.is_empty() else "Dictionary does not contain value: " + str(value)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_value_equals(dict: Dictionary, key, expected_value, message: String = "") -> bool:
	"""Assert that dictionary key has expected value"""
	if dict.has(key) and dict[key] == expected_value:
		return true

	var actual_value = dict.get(key, "KEY_NOT_FOUND")
	var error_msg = message if not message.is_empty() else "Dictionary key '" + str(key) + "' value mismatch: expected " + str(expected_value) + ", got " + str(actual_value)
	GDTestManager.log_test_failure("CollectionAssertions", error_msg)
	return false

static func assert_dict_contains(dict: Dictionary, subset: Dictionary, message: String = "") -> bool:
	"""Assert that dictionary contains all key-value pairs from subset"""
	for key in subset.keys():
		if not dict.has(key):
			var error_msg = message if not message.is_empty() else "Dictionary missing key: " + str(key)
			GDTestManager.log_test_failure("CollectionAssertions", error_msg)
			return false

		if dict[key] != subset[key]:
			var error_msg = message if not message.is_empty() else "Dictionary key '" + str(key) + "' value mismatch: expected " + str(subset[key]) + ", got " + str(dict[key])
			GDTestManager.log_test_failure("CollectionAssertions", error_msg)
			return false

	return true

# ------------------------------------------------------------------------------
# ADVANCED COLLECTION OPERATIONS
# ------------------------------------------------------------------------------
static func assert_arrays_equal_unordered(array1: Array, array2: Array, message: String = "") -> bool:
	"""Assert that two arrays contain the same elements regardless of order"""
	if array1.size() != array2.size():
		var error_msg = message if not message.is_empty() else "Array size mismatch: " + str(array1.size()) + " vs " + str(array2.size())
		GDTestManager.log_test_failure("CollectionAssertions", error_msg)
		return false

	var _array1_copy = array1.duplicate()
	var array2_copy = array2.duplicate()

	for element in array1:
		if array2_copy.has(element):
			array2_copy.erase(element)
		else:
			var error_msg = message if not message.is_empty() else "Element " + str(element) + " from first array not found in second array"
			GDTestManager.log_test_failure("CollectionAssertions", error_msg)
			return false

	if not array2_copy.is_empty():
		var error_msg = message if not message.is_empty() else "Elements in second array not found in first: " + str(array2_copy)
		GDTestManager.log_test_failure("CollectionAssertions", error_msg)
		return false

	return true

static func assert_array_subset(subset: Array, superset: Array, message: String = "") -> bool:
	"""Assert that first array is a subset of second array"""
	for element in subset:
		if not superset.has(element):
			var error_msg = message if not message.is_empty() else "Element " + str(element) + " from subset not found in superset"
			GDTestManager.log_test_failure("CollectionAssertions", error_msg)
			return false

	return true

static func assert_array_intersection(array1: Array, array2: Array, expected_intersection: Array, message: String = "") -> bool:
	"""Assert that intersection of two arrays equals expected result"""
	var intersection = []

	for element in array1:
		if array2.has(element) and not intersection.has(element):
			intersection.append(element)

	return assert_arrays_equal_unordered(intersection, expected_intersection, message)

static func assert_array_union(array1: Array, array2: Array, expected_union: Array, message: String = "") -> bool:
	"""Assert that union of two arrays equals expected result"""
	var union = array1.duplicate()

	for element in array2:
		if not union.has(element):
			union.append(element)

	return assert_arrays_equal_unordered(union, expected_union, message)

# ------------------------------------------------------------------------------
# COLLECTION DIFFING
# ------------------------------------------------------------------------------
static func get_array_diff(array1: Array, array2: Array) -> Dictionary:
	"""Get detailed diff between two arrays"""
	var diff = {
		"added": [],
		"removed": [],
		"common": []
	}

	var array2_copy = array2.duplicate()

	# Find removed elements (in array1 but not array2)
	for element in array1:
		if array2_copy.has(element):
			array2_copy.erase(element)
			diff.common.append(element)
		else:
			diff.removed.append(element)

	# Remaining elements in array2 are added
	diff.added = array2_copy

	return diff

static func get_dict_diff(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	"""Get detailed diff between two dictionaries"""
	var diff = {
		"added_keys": [],
		"removed_keys": [],
		"changed_keys": [],
		"common_keys": []
	}

	# Find added and changed keys
	for key in dict2.keys():
		if not dict1.has(key):
			diff.added_keys.append(key)
		elif dict1[key] != dict2[key]:
			diff.changed_keys.append(key)
		else:
			diff.common_keys.append(key)

	# Find removed keys
	for key in dict1.keys():
		if not dict2.has(key):
			diff.removed_keys.append(key)

	return diff

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
static func print_array_diff(array1: Array, array2: Array) -> void:
	"""Print detailed diff between two arrays"""
	var diff = get_array_diff(array1, array2)

	print("Array Diff:")
	print("  Added: ", diff.added)
	print("  Removed: ", diff.removed)
	print("  Common: ", diff.common)

static func print_dict_diff(dict1: Dictionary, dict2: Dictionary) -> void:
	"""Print detailed diff between two dictionaries"""
	var diff = get_dict_diff(dict1, dict2)

	print("Dictionary Diff:")
	print("  Added keys: ", diff.added_keys)
	print("  Removed keys: ", diff.removed_keys)
	print("  Changed keys: ", diff.changed_keys)
	print("  Common keys: ", diff.common_keys)
