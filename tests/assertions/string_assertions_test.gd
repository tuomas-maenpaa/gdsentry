# GDSentry - String Assertions Tests
# Comprehensive testing of string validation and manipulation assertion functionality
#
# Tests string assertions including:
# - String content and pattern matching
# - Case sensitivity and whitespace handling
# - Regular expression support and validation
# - String transformation validation
# - Multi-line string comparison and structure
# - String length and format validation
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name StringAssertionsTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "String assertions comprehensive validation"
	test_tags = ["assertions", "string", "regex", "pattern", "validation", "format"]
	test_priority = "high"
	test_category = "assertions"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all string assertions tests"""
	run_test("test_basic_string_assertions", func(): return test_basic_string_assertions())
	run_test("test_string_content_assertions", func(): return test_string_content_assertions())
	run_test("test_string_format_assertions", func(): return test_string_format_assertions())
	run_test("test_regex_assertions", func(): return test_regex_assertions())
	run_test("test_case_transformation_assertions", func(): return test_case_transformation_assertions())
	run_test("test_whitespace_assertions", func(): return test_whitespace_assertions())
	run_test("test_multiline_string_assertions", func(): return test_multiline_string_assertions())
	run_test("test_string_comparison_utilities", func(): return test_string_comparison_utilities())

# ------------------------------------------------------------------------------
# BASIC STRING ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_basic_string_assertions() -> bool:
	"""Test basic string assertions: equals, empty, length"""
	var success := true

	# Test string equals (case sensitive)
	var str1 := "Hello World"
	var str2 := "Hello World"
	var str3 := "hello world"

	success = success and StringAssertions.assert_string_equals(str1, str2, true, "Strings should be equal")
	success = success and assert_false(StringAssertions.assert_string_equals(str1, str3, true, "Strings should not be equal with case sensitivity"), "Strings should not be equal with case sensitivity")

	# Test string equals (case insensitive)
	success = success and StringAssertions.assert_string_equals(str1, str3, false, "Strings should be equal ignoring case")
	success = success and assert_false(StringAssertions.assert_string_equals(str1, "Different", false, "Strings should not be equal"), "Strings should not be equal")

	# Test string empty/not_empty
	var empty_str := ""
	var non_empty_str := "content"

	success = success and StringAssertions.assert_string_empty(empty_str, "String should be empty")
	success = success and assert_false(StringAssertions.assert_string_empty(non_empty_str, "String should not be empty"), "String should not be empty")

	success = success and StringAssertions.assert_string_not_empty(non_empty_str, "String should not be empty")
	success = success and assert_false(StringAssertions.assert_string_not_empty(empty_str, "String should not be empty"), "String should not be empty")

	# Test string length
	var test_str := "Hello"
	success = success and StringAssertions.assert_string_length(test_str, 5, "String should have length 5")
	success = success and assert_false(StringAssertions.assert_string_length(test_str, 3, "String should not have length 3"), "String should not have length 3")

	# Test string length greater/less than
	success = success and StringAssertions.assert_string_length_greater_than(test_str, 3, "String length should be greater than 3")
	success = success and assert_false(StringAssertions.assert_string_length_greater_than(test_str, 6, "String length should not be greater than 6"), "String length should not be greater than 6")

	success = success and StringAssertions.assert_string_length_less_than(test_str, 7, "String length should be less than 7")
	success = success and assert_false(StringAssertions.assert_string_length_less_than(test_str, 4, "String length should not be less than 4"), "String length should not be less than 4")

	return success

func test_string_content_assertions() -> bool:
	"""Test string content assertions: contains, starts_with, ends_with"""
	var success := true

	var test_str := "Hello Beautiful World"

	# Test contains (case sensitive)
	success = success and StringAssertions.assert_string_contains(test_str, "Beautiful", true, "String should contain 'Beautiful'")
	success = success and assert_false(StringAssertions.assert_string_contains(test_str, "beautiful", true, "String should not contain 'beautiful' with case sensitivity"), "String should not contain 'beautiful' with case sensitivity")

	# Test contains (case insensitive)
	success = success and StringAssertions.assert_string_contains(test_str, "beautiful", false, "String should contain 'beautiful' ignoring case")
	success = success and assert_false(StringAssertions.assert_string_contains(test_str, "ugly", false, "String should not contain 'ugly'"), "String should not contain 'ugly'")

	# Test not_contains
	success = success and StringAssertions.assert_string_not_contains(test_str, "ugly", true, "String should not contain 'ugly'")
	success = success and assert_false(StringAssertions.assert_string_not_contains(test_str, "Beautiful", true, "String should not contain 'Beautiful'"), "String should not contain 'Beautiful'")

	# Test starts_with
	success = success and StringAssertions.assert_string_starts_with(test_str, "Hello", true, "String should start with 'Hello'")
	success = success and assert_false(StringAssertions.assert_string_starts_with(test_str, "hello", true, "String should not start with 'hello' with case sensitivity"), "String should not start with 'hello' with case sensitivity")

	# Test ends_with
	success = success and StringAssertions.assert_string_ends_with(test_str, "World", true, "String should end with 'World'")
	success = success and assert_false(StringAssertions.assert_string_ends_with(test_str, "world", true, "String should not end with 'world' with case sensitivity"), "String should not end with 'world' with case sensitivity")

	return success

func test_string_format_assertions() -> bool:
	"""Test string format assertions: numeric, alphabetic, alphanumeric"""
	var success := true

	# Test numeric format
	var numeric_str := "123.45"
	var non_numeric_str := "12a.45"

	success = success and StringAssertions.assert_string_is_numeric(numeric_str, "String should be numeric")
	success = success and assert_false(StringAssertions.assert_string_is_numeric(non_numeric_str, "String should not be numeric"), "String should not be numeric")

	# Test alphabetic format
	var alpha_str := "Hello"
	var non_alpha_str := "Hello123"

	success = success and StringAssertions.assert_string_is_alphabetic(alpha_str, false, "String should be alphabetic")
	success = success and assert_false(StringAssertions.assert_string_is_alphabetic(non_alpha_str, false, "String should not be alphabetic"), "String should not be alphabetic")

	# Test alphabetic with spaces
	var alpha_spaces_str := "Hello World"
	success = success and StringAssertions.assert_string_is_alphabetic(alpha_spaces_str, true, "String should be alphabetic with spaces")
	success = success and assert_false(StringAssertions.assert_string_is_alphabetic("Hello123 World", true, "String should not be alphabetic with spaces"), "String should not be alphabetic with spaces")

	# Test alphanumeric format
	var alphanumeric_str := "Hello123"
	var non_alphanumeric_str := "Hello@123"

	success = success and StringAssertions.assert_string_is_alphanumeric(alphanumeric_str, false, "String should be alphanumeric")
	success = success and assert_false(StringAssertions.assert_string_is_alphanumeric(non_alphanumeric_str, false, "String should not be alphanumeric"), "String should not be alphanumeric")

	return success

func test_regex_assertions() -> bool:
	"""Test regular expression assertions"""
	var success := true

	# Test matches pattern
	var email_str := "test@example.com"
	var invalid_email := "test@.com"

	success = success and StringAssertions.assert_string_matches_pattern(email_str, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "String should match email pattern")
	success = success and assert_false(StringAssertions.assert_string_matches_pattern(invalid_email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "String should not match email pattern"), "String should not match email pattern")

	# Test not matches pattern
	success = success and StringAssertions.assert_string_not_matches_pattern(invalid_email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "String should not match email pattern")
	success = success and assert_false(StringAssertions.assert_string_not_matches_pattern(email_str, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "String should not match email pattern"), "String should not match email pattern")

	# Test email format
	success = success and StringAssertions.assert_string_email_format(email_str, "String should be valid email format")
	success = success and assert_false(StringAssertions.assert_string_email_format(invalid_email, "String should not be valid email format"), "String should not be valid email format")

	# Test URL format
	var url_str := "https://www.example.com"
	var invalid_url := "not-a-url"

	success = success and StringAssertions.assert_string_url_format(url_str, "String should be valid URL format")
	success = success and assert_false(StringAssertions.assert_string_url_format(invalid_url, "String should not be valid URL format"), "String should not be valid URL format")

	return success

func test_case_transformation_assertions() -> bool:
	"""Test case transformation assertions: uppercase, lowercase, title_case, camel_case, pascal_case, snake_case"""
	var success := true

	# Test uppercase
	var upper_str := "HELLO WORLD"
	var mixed_str := "Hello World"

	success = success and StringAssertions.assert_string_uppercase(upper_str, "String should be uppercase")
	success = success and assert_false(StringAssertions.assert_string_uppercase(mixed_str, "String should not be uppercase"), "String should not be uppercase")

	# Test lowercase
	var lower_str := "hello world"
	var mixed_str2 := "Hello World"

	success = success and StringAssertions.assert_string_lowercase(lower_str, "String should be lowercase")
	success = success and assert_false(StringAssertions.assert_string_lowercase(mixed_str2, "String should not be lowercase"), "String should not be lowercase")

	# Test title case
	var title_str := "Hello World"
	var not_title_str := "hello world"

	success = success and StringAssertions.assert_string_title_case(title_str, "String should be title case")
	success = success and assert_false(StringAssertions.assert_string_title_case(not_title_str, "String should not be title case"), "String should not be title case")

	# Test camelCase
	var camel_str := "helloWorld"
	var not_camel_str := "HelloWorld"

	success = success and StringAssertions.assert_string_camel_case(camel_str, "String should be camelCase")
	success = success and assert_false(StringAssertions.assert_string_camel_case(not_camel_str, "String should not be camelCase"), "String should not be camelCase")

	# Test PascalCase
	var pascal_str := "HelloWorld"
	var not_pascal_str := "helloWorld"

	success = success and StringAssertions.assert_string_pascal_case(pascal_str, "String should be PascalCase")
	success = success and assert_false(StringAssertions.assert_string_pascal_case(not_pascal_str, "String should not be PascalCase"), "String should not be PascalCase")

	# Test snake_case
	var snake_str := "hello_world"
	var not_snake_str := "HelloWorld"

	success = success and StringAssertions.assert_string_snake_case(snake_str, "String should be snake_case")
	success = success and assert_false(StringAssertions.assert_string_snake_case(not_snake_str, "String should not be snake_case"), "String should not be snake_case")

	return success

func test_whitespace_assertions() -> bool:
	"""Test whitespace-related assertions"""
	var success := true

	# Test no whitespace
	var no_whitespace_str := "HelloWorld"
	var whitespace_str := "Hello World"

	success = success and StringAssertions.assert_string_has_no_whitespace(no_whitespace_str, "String should have no whitespace")
	success = success and assert_false(StringAssertions.assert_string_has_no_whitespace(whitespace_str, "String should not have no whitespace"), "String should not have no whitespace")

	# Test trimmed equals
	var original_str := "  Hello World  "
	var trimmed_expected := "Hello World"

	success = success and StringAssertions.assert_string_trimmed_equals(original_str, trimmed_expected, "Trimmed strings should be equal")
	success = success and assert_false(StringAssertions.assert_string_trimmed_equals(original_str, "Different", "Trimmed strings should not be equal"), "Trimmed strings should not be equal")

	return success

func test_multiline_string_assertions() -> bool:
	"""Test multi-line string assertions"""
	var success := true

	# Test line count
	var multiline_str := "Line 1\nLine 2\nLine 3\nLine 4"
	var _single_line_str := "Single line"  # Prefix with underscore to indicate intentionally unused

	success = success and StringAssertions.assert_string_line_count(multiline_str, 4, "String should have 4 lines")
	success = success and assert_false(StringAssertions.assert_string_line_count(multiline_str, 2, "String should not have 2 lines"), "String should not have 2 lines")

	# Test contains line
	success = success and StringAssertions.assert_string_contains_line(multiline_str, "Line 2", "String should contain line 'Line 2'")
	success = success and assert_false(StringAssertions.assert_string_contains_line(multiline_str, "Line 5", "String should not contain line 'Line 5'"), "String should not contain line 'Line 5'")

	# Test line matches pattern
	var pattern_str := "Item 1\nItem 2\nItem 3"
	success = success and StringAssertions.assert_string_line_matches_pattern(pattern_str, 0, "^Item \\d+$", "Line 0 should match item pattern")
	success = success and assert_false(StringAssertions.assert_string_line_matches_pattern(pattern_str, 0, "^NotItem", "Line 0 should not match NotItem pattern"), "Line 0 should not match NotItem pattern")

	return success

func test_string_comparison_utilities() -> bool:
	"""Test string comparison utility methods"""
	var success := true

	# Test string diff
	var str1 := "Hello World"
	var str2 := "Hello Universe"

	var diff := StringAssertions.get_string_diff(str1, str2)
	success = success and assert_not_null(diff, "String diff should be generated")
	success = success and assert_true(diff.has("common_prefix_length"), "Diff should have common_prefix_length")
	success = success and assert_true(diff.has("common_suffix_length"), "Diff should have common_suffix_length")

	# Verify diff content
	if diff:
		success = success and assert_equals(diff.common_prefix_length, 6, "Should have 6 characters of common prefix")  # "Hello "

	# Test occurrence counting
	var occurrence_str := "hello hello world hello"
	var count := StringAssertions.count_occurrences(occurrence_str, "hello")
	success = success and assert_equals(count, 3, "Should count 3 occurrences of 'hello'")

	# Test normalize whitespace
	var whitespace_str := "Hello\t\nWorld\r\n"
	var normalized := StringAssertions.normalize_whitespace(whitespace_str)
	success = success and assert_equals(normalized, "Hello\nWorld\n", "Whitespace should be normalized")

	# Test remove whitespace
	var remove_whitespace_result := StringAssertions.remove_whitespace(whitespace_str)
	success = success and assert_equals(remove_whitespace_result, "HelloWorld", "All whitespace should be removed")

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_string() -> String:
	"""Create a test string for testing"""
	return "Hello, World! This is a test string."

func create_multiline_string() -> String:
	"""Create a multiline test string"""
	return "Line 1: Hello\nLine 2: World\nLine 3: Test\nLine 4: Complete"

func create_email_string() -> String:
	"""Create a test email string"""
	return "user@example.com"

func create_url_string() -> String:
	"""Create a test URL string"""
	return "https://www.example.com/path?query=value"

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
