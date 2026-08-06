# GDSentry - String Assertions
# Specialized assertions for string validation and manipulation testing
#
# Features:
# - String content and pattern matching
# - Case sensitivity and whitespace handling
# - Regular expression support
# - String transformation validation
# - Multi-line string comparison
# - String length and structure validation
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name StringAssertions

# ------------------------------------------------------------------------------
# BASIC STRING ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_string_equals(actual: String, expected: String, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that two strings are equal"""
	var actual_cmp = actual if not ignore_case else actual.to_lower()
	var expected_cmp = expected if not ignore_case else expected.to_lower()

	if actual_cmp == expected_cmp:
		return true

	var error_msg = message if not message.is_empty() else "String mismatch:\n  Expected: '" + expected + "'\n  Actual: '" + actual + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_not_equals(actual: String, expected: String, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that two strings are not equal"""
	var actual_cmp = actual if not ignore_case else actual.to_lower()
	var expected_cmp = expected if not ignore_case else expected.to_lower()

	if actual_cmp != expected_cmp:
		return true

	var error_msg = message if not message.is_empty() else "Strings are equal: '" + actual + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_empty(string: String, message: String = "") -> bool:
	"""Assert that string is empty"""
	if string.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "String is not empty: '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_not_empty(string: String, message: String = "") -> bool:
	"""Assert that string is not empty"""
	if not string.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "String is empty"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_length(string: String, expected_length: int, message: String = "") -> bool:
	"""Assert that string has expected length"""
	if string.length() == expected_length:
		return true

	var error_msg = message if not message.is_empty() else "String length mismatch: expected " + str(expected_length) + ", got " + str(string.length()) + " ('" + string + "')"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_length_greater_than(string: String, min_length: int, message: String = "") -> bool:
	"""Assert that string length is greater than minimum"""
	if string.length() > min_length:
		return true

	var error_msg = message if not message.is_empty() else "String too short: length " + str(string.length()) + " <= " + str(min_length) + " ('" + string + "')"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_length_less_than(string: String, max_length: int, message: String = "") -> bool:
	"""Assert that string length is less than maximum"""
	if string.length() < max_length:
		return true

	var error_msg = message if not message.is_empty() else "String too long: length " + str(string.length()) + " >= " + str(max_length) + " ('" + string + "')"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# STRING CONTENT ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_string_contains(string: String, substring: String, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that string contains substring"""
	var string_cmp = string if not ignore_case else string.to_lower()
	var substring_cmp = substring if not ignore_case else substring.to_lower()

	if string_cmp.contains(substring_cmp):
		return true

	var error_msg = message if not message.is_empty() else "String does not contain '" + substring + "': '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_not_contains(string: String, substring: String, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that string does not contain substring"""
	var string_cmp = string if not ignore_case else string.to_lower()
	var substring_cmp = substring if not ignore_case else substring.to_lower()

	if not string_cmp.contains(substring_cmp):
		return true

	var error_msg = message if not message.is_empty() else "String contains '" + substring + "': '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_starts_with(string: String, prefix: String, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that string starts with prefix"""
	var string_cmp = string if not ignore_case else string.to_lower()
	var prefix_cmp = prefix if not ignore_case else prefix.to_lower()

	if string_cmp.begins_with(prefix_cmp):
		return true

	var error_msg = message if not message.is_empty() else "String does not start with '" + prefix + "': '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_ends_with(string: String, suffix: String, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that string ends with suffix"""
	var string_cmp = string if not ignore_case else string.to_lower()
	var suffix_cmp = suffix if not ignore_case else suffix.to_lower()

	if string_cmp.ends_with(suffix_cmp):
		return true

	var error_msg = message if not message.is_empty() else "String does not end with '" + suffix + "': '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_contains_any(string: String, substrings: Array, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that string contains at least one of the substrings"""
	for substring in substrings:
		var string_cmp = string if not ignore_case else string.to_lower()
		var substring_cmp = substring if not ignore_case else substring.to_lower()

		if string_cmp.contains(substring_cmp):
			return true

	var error_msg = message if not message.is_empty() else "String does not contain any of: " + str(substrings) + " ('" + string + "')"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_contains_all(string: String, substrings: Array, ignore_case: bool = false, message: String = "") -> bool:
	"""Assert that string contains all substrings"""
	var missing = []

	for substring in substrings:
		var string_cmp = string if not ignore_case else string.to_lower()
		var substring_cmp = substring if not ignore_case else substring.to_lower()

		if not string_cmp.contains(substring_cmp):
			missing.append(substring)

	if missing.is_empty():
		return true

	var error_msg = message if not message.is_empty() else "String missing substrings: " + str(missing) + " ('" + string + "')"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

# ------------------------------------------------------------------------------
# REGULAR EXPRESSION ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_string_matches_pattern(string: String, pattern: String, message: String = "") -> bool:
	"""Assert that string matches regular expression pattern"""
	var regex = RegEx.new()
	var error = regex.compile(pattern)

	if error != OK:
		var error_msg = message if not message.is_empty() else "Invalid regex pattern: " + pattern
		GDTestManager.log_test_failure("StringAssertions", error_msg)
		return false

	var result = regex.search(string)
	if result:
		return true

	var final_error_msg = message if not message.is_empty() else "String does not match pattern '" + pattern + "': '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", final_error_msg)
	return false

static func assert_string_not_matches_pattern(string: String, pattern: String, message: String = "") -> bool:
	"""Assert that string does not match regular expression pattern"""
	var regex = RegEx.new()
	var error = regex.compile(pattern)

	if error != OK:
		var error_msg = message if not message.is_empty() else "Invalid regex pattern: " + pattern
		GDTestManager.log_test_failure("StringAssertions", error_msg)
		return false

	var result = regex.search(string)
	if not result:
		return true

	var final_error_msg = message if not message.is_empty() else "String matches pattern '" + pattern + "': '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", final_error_msg)
	return false

static func assert_string_email_format(string: String, message: String = "") -> bool:
	"""Assert that string is a valid email format"""
	var email_pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
	return assert_string_matches_pattern(string, email_pattern, message if not message.is_empty() else "Invalid email format: '" + string + "'")

static func assert_string_url_format(string: String, message: String = "") -> bool:
	"""Assert that string is a valid URL format"""
	var url_pattern = "^https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}[^\\s]*$"
	return assert_string_matches_pattern(string, url_pattern, message if not message.is_empty() else "Invalid URL format: '" + string + "'")

# ------------------------------------------------------------------------------
# STRING FORMAT AND STRUCTURE
# ------------------------------------------------------------------------------
static func assert_string_is_numeric(string: String, message: String = "") -> bool:
	"""Assert that string represents a valid number"""
	if string.is_valid_float() or string.is_valid_int():
		return true

	var error_msg = message if not message.is_empty() else "String is not numeric: '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_is_alphabetic(string: String, allow_spaces: bool = false, message: String = "") -> bool:
	"""Assert that string contains only alphabetic characters"""
	for c in string:
		if not ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (allow_spaces and c == ' ')):
			var error_msg = message if not message.is_empty() else "String contains non-alphabetic character '" + c + "': '" + string + "'"
			GDTestManager.log_test_failure("StringAssertions", error_msg)
			return false

	return true

static func assert_string_is_alphanumeric(string: String, allow_spaces: bool = false, message: String = "") -> bool:
	"""Assert that string contains only alphanumeric characters"""
	for c in string:
		if not ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or (allow_spaces and c == ' ')):
			var error_msg = message if not message.is_empty() else "String contains non-alphanumeric character '" + c + "': '" + string + "'"
			GDTestManager.log_test_failure("StringAssertions", error_msg)
			return false

	return true

static func assert_string_has_no_whitespace(string: String, message: String = "") -> bool:
	"""Assert that string contains no whitespace characters"""
	if not string.contains(" ") and not string.contains("\t") and not string.contains("\n") and not string.contains("\r"):
		return true

	var error_msg = message if not message.is_empty() else "String contains whitespace: '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_trimmed_equals(string: String, expected: String, message: String = "") -> bool:
	"""Assert that string equals expected after trimming whitespace"""
	var trimmed = string.strip_edges()
	return assert_string_equals(trimmed, expected, false, message if not message.is_empty() else "Trimmed string mismatch")

# ------------------------------------------------------------------------------
# STRING TRANSFORMATION ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_string_uppercase(string: String, message: String = "") -> bool:
	"""Assert that string is all uppercase"""
	if string == string.to_upper():
		return true

	var error_msg = message if not message.is_empty() else "String is not uppercase: '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_lowercase(string: String, message: String = "") -> bool:
	"""Assert that string is all lowercase"""
	if string == string.to_lower():
		return true

	var error_msg = message if not message.is_empty() else "String is not lowercase: '" + string + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_title_case(string: String, message: String = "") -> bool:
	"""Assert that string is in title case"""
	var words = string.split(" ")
	var expected_title = ""

	for i in range(words.size()):
		if not words[i].is_empty():
			expected_title += words[i].substr(0, 1).to_upper() + words[i].substr(1).to_lower()
			if i < words.size() - 1:
				expected_title += " "

	if string == expected_title:
		return true

	var error_msg = message if not message.is_empty() else "String is not title case: '" + string + "' (expected: '" + expected_title + "')"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_camel_case(string: String, message: String = "") -> bool:
	"""Assert that string is in camelCase format"""
	var camel_pattern = "^[a-z][a-zA-Z0-9]*$"
	return assert_string_matches_pattern(string, camel_pattern, message if not message.is_empty() else "String is not camelCase: '" + string + "'")

static func assert_string_pascal_case(string: String, message: String = "") -> bool:
	"""Assert that string is in PascalCase format"""
	var pascal_pattern = "^[A-Z][a-zA-Z0-9]*$"
	return assert_string_matches_pattern(string, pascal_pattern, message if not message.is_empty() else "String is not PascalCase: '" + string + "'")

static func assert_string_snake_case(string: String, message: String = "") -> bool:
	"""Assert that string is in snake_case format"""
	var snake_pattern = "^[a-z][a-z0-9_]*$"
	return assert_string_matches_pattern(string, snake_pattern, message if not message.is_empty() else "String is not snake_case: '" + string + "'")

# ------------------------------------------------------------------------------
# MULTI-LINE STRING ASSERTIONS
# ------------------------------------------------------------------------------
static func assert_string_line_count(string: String, expected_lines: int, message: String = "") -> bool:
	"""Assert that multi-line string has expected number of lines"""
	var lines = string.split("\n")
	if lines.size() == expected_lines:
		return true

	var error_msg = message if not message.is_empty() else "Line count mismatch: expected " + str(expected_lines) + ", got " + str(lines.size())
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_contains_line(string: String, line_content: String, message: String = "") -> bool:
	"""Assert that multi-line string contains specific line"""
	var lines = string.split("\n")

	for line in lines:
		if line.strip_edges() == line_content.strip_edges():
			return true

	var error_msg = message if not message.is_empty() else "String does not contain line: '" + line_content + "'"
	GDTestManager.log_test_failure("StringAssertions", error_msg)
	return false

static func assert_string_line_matches_pattern(string: String, line_index: int, pattern: String, message: String = "") -> bool:
	"""Assert that specific line matches pattern"""
	var lines = string.split("\n")

	if line_index >= lines.size():
		var error_msg = message if not message.is_empty() else "Line index " + str(line_index) + " out of range (total lines: " + str(lines.size()) + ")"
		GDTestManager.log_test_failure("StringAssertions", error_msg)
		return false

	var line = lines[line_index]
	return assert_string_matches_pattern(line, pattern, message if not message.is_empty() else "Line " + str(line_index) + " does not match pattern")

# ------------------------------------------------------------------------------
# STRING COMPARISON HELPERS
# ------------------------------------------------------------------------------
static func get_string_diff(string1: String, string2: String) -> Dictionary:
	"""Get detailed diff between two strings"""
	var diff = {
		"length_diff": string2.length() - string1.length(),
		"common_prefix_length": 0,
		"common_suffix_length": 0,
		"differences": []
	}

	# Find common prefix
	var min_length = min(string1.length(), string2.length())
	for i in range(min_length):
		if string1[i] == string2[i]:
			diff.common_prefix_length += 1
		else:
			break

	# Find common suffix
	for i in range(min_length - diff.common_prefix_length):
		var idx1 = string1.length() - 1 - i
		var idx2 = string2.length() - 1 - i
		if string1[idx1] == string2[idx2]:
			diff.common_suffix_length += 1
		else:
			break

	return diff

static func print_string_diff(string1: String, string2: String) -> void:
	"""Print detailed diff between two strings"""
	var diff = get_string_diff(string1, string2)

	print("String Diff:")
	print("  Length difference: ", diff.length_diff)
	print("  Common prefix length: ", diff.common_prefix_length)
	print("  Common suffix length: ", diff.common_suffix_length)
	print("  String 1: '", string1, "'")
	print("  String 2: '", string2, "'")

	if diff.common_prefix_length > 0:
		print("  Common prefix: '", string1.substr(0, diff.common_prefix_length), "'")

	if diff.common_suffix_length > 0:
		var suffix_start = string1.length() - diff.common_suffix_length
		print("  Common suffix: '", string1.substr(suffix_start), "'")

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
static func normalize_whitespace(string: String) -> String:
	"""Normalize whitespace in string for comparison"""
	return string.replace("\t", " ").replace("\r\n", "\n").replace("\r", "\n")

static func remove_whitespace(string: String) -> String:
	"""Remove all whitespace from string"""
	return string.replace(" ", "").replace("\t", "").replace("\n", "").replace("\r", "")

static func count_occurrences(string: String, substring: String) -> int:
	"""Count occurrences of substring in string"""
	if substring.is_empty():
		return 0

	var count = 0
	var pos = 0

	while true:
		pos = string.find(substring, pos)
		if pos == -1:
			break
		count += 1
		pos += substring.length()

	return count
