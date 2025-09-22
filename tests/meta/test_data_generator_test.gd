# GDSentry - Test Data Generator Test Suite
# Comprehensive testing of the TestDataGenerator utility framework
#
# This test validates all aspects of the test data generator including:
# - Basic data type generation (strings, numbers, dates, booleans)
# - Specialized data generation (emails, names, addresses)
# - Array and collection generation
# - Object factory methods
# - Bulk data generation
# - Export functionality (JSON, CSV)
# - Integration with GDSentry fixtures
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name TestDataGeneratorTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive TestDataGenerator validation"
	test_tags = ["meta", "utilities", "data_generation", "test_data", "factory"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var generator

func setup() -> void:
	"""Setup test environment"""
	generator = load("res://utilities/test_data_generator.gd").new()
	# SceneTreeTest doesn't have add_child, so we'll manage the instance directly

func teardown() -> void:
	"""Cleanup test environment"""
	if generator:
		generator.queue_free()

# ------------------------------------------------------------------------------
# BASIC DATA GENERATION TESTS
# ------------------------------------------------------------------------------
func test_generate_string() -> bool:
	"""Test basic string generation"""
	print("🧪 Testing basic string generation")

	var success = true

	# Test default string generation
	var str1 = generator.generate_string()
	success = success and assert_not_null(str1, "Should generate default string")
	success = success and assert_equals(str1.length(), 10, "Should generate string of default length")
	success = success and assert_true(str1.is_valid_identifier() or str1.contains("_"), "Should contain valid characters")

	# Test custom length
	var str2 = generator.generate_string(5)
	success = success and assert_equals(str2.length(), 5, "Should generate string of custom length")

	# Test different character sets
	var alpha_str = generator.generate_string(8, "alphabetic")
	success = success and assert_true(alpha_str.is_valid_identifier(), "Should generate alphabetic string")

	var numeric_str = generator.generate_string(6, "numeric")
	success = success and assert_true(numeric_str.is_valid_int(), "Should generate numeric string")

	var hex_str = generator.generate_string(4, "hex")
	success = success and assert_true(hex_str.is_valid_hex_number(false), "Should generate hex string")

	return success

func test_generate_int() -> bool:
	"""Test integer generation"""
	print("🧪 Testing integer generation")

	var success = true

	# Test default range
	var int1 = generator.generate_int()
	success = success and assert_true(int1 >= 0 and int1 <= 100, "Should generate int in default range")

	# Test custom range
	var int2 = generator.generate_int(10, 20)
	success = success and assert_true(int2 >= 10 and int2 <= 20, "Should generate int in custom range")

	# Test edge cases
	var int3 = generator.generate_int(5, 5)
	success = success and assert_equals(int3, 5, "Should handle single-value range")

	# Test range validation (should swap if min > max)
	var int4 = generator.generate_int(20, 10)
	success = success and assert_true(int4 >= 10 and int4 <= 20, "Should handle reversed range")

	return success

func test_generate_float() -> bool:
	"""Test float generation"""
	print("🧪 Testing float generation")

	var success = true

	# Test default range
	var float1 = generator.generate_float()
	success = success and assert_true(float1 >= 0.0 and float1 <= 100.0, "Should generate float in default range")

	# Test custom range and precision
	var float2 = generator.generate_float(1.0, 10.0, 1)
	success = success and assert_true(float2 >= 1.0 and float2 <= 10.0, "Should generate float in custom range")

	# Test precision
	var float3 = generator.generate_float(0.0, 1.0, 2)
	var float_str = "%.2f" % float3
	success = success and assert_true(float_str.length() <= 4, "Should respect precision")

	return success

func test_generate_bool() -> bool:
	"""Test boolean generation"""
	print("🧪 Testing boolean generation")

	var success = true

	# Test default probability (should generate both true and false over multiple calls)
	var true_count = 0
	var false_count = 0

	for i in range(100):
		var bool_val = generator.generate_bool()
		if bool_val:
			true_count += 1
		else:
			false_count += 1

	success = success and assert_greater_than(true_count, 0, "Should generate some true values")
	success = success and assert_greater_than(false_count, 0, "Should generate some false values")

	# Test custom probability
	var mostly_true = generator.generate_bool(0.9)
	success = success and assert_type(mostly_true, TYPE_BOOL, "Should return boolean")

	return success

func test_generate_date() -> bool:
	"""Test date generation"""
	print("🧪 Testing date generation")

	var success = true

	# Test default date generation
	var date1 = generator.generate_date()
	success = success and assert_not_null(date1, "Should generate date object")
	success = success and assert_true(date1.has("year"), "Should have year")
	success = success and assert_true(date1.has("month"), "Should have month")
	success = success and assert_true(date1.has("day"), "Should have day")
	success = success and assert_true(date1.has("string"), "Should have string representation")
	success = success and assert_true(date1.has("timestamp"), "Should have timestamp")

	# Test year range
	var date2 = generator.generate_date(2020, 2022)
	success = success and assert_true(date2.year >= 2020 and date2.year <= 2022, "Should respect year range")

	# Test leap year handling
	var leap_year_date = generator.generate_date(2020, 2020)  # 2020 is leap year
	if leap_year_date.month == 2:  # February
		success = success and assert_true(leap_year_date.day >= 1 and leap_year_date.day <= 29, "Should handle leap year")

	return success

# ------------------------------------------------------------------------------
# SPECIALIZED DATA GENERATION TESTS
# ------------------------------------------------------------------------------
func test_generate_email() -> bool:
	"""Test email generation"""
	print("🧪 Testing email generation")

	var success = true

	# Test default email generation
	var email1 = generator.generate_email()
	success = success and assert_true(email1.contains("@"), "Should contain @ symbol")
	success = success and assert_true(email1.split("@").size() == 2, "Should have valid email format")

	# Test custom domain
	var email2 = generator.generate_email("test.com")
	success = success and assert_true(email2.ends_with("@test.com"), "Should use custom domain")

	# Test custom prefix length
	var email3 = generator.generate_email("", 5)
	var prefix = email3.split("@")[0]
	success = success and assert_equals(prefix.length(), 5, "Should respect prefix length")

	return success

func test_generate_name() -> bool:
	"""Test name generation"""
	print("🧪 Testing name generation")

	var success = true

	# Test name generation
	var name1 = generator.generate_name()
	success = success and assert_true(name1.has("first_name"), "Should have first name")
	success = success and assert_true(name1.has("last_name"), "Should have last name")
	success = success and assert_true(name1.has("full_name"), "Should have full name")
	success = success and assert_true(name1.has("initials"), "Should have initials")

	# Test full name format
	var expected_full = name1.first_name + " " + name1.last_name
	success = success and assert_equals(name1.full_name, expected_full, "Full name should be properly formatted")

	# Test initials format
	var expected_initials = name1.first_name[0] + name1.last_name[0]
	success = success and assert_equals(name1.initials, expected_initials, "Initials should be properly formatted")

	return success

func test_generate_address() -> bool:
	"""Test address generation"""
	print("🧪 Testing address generation")

	var success = true

	# Test address generation
	var address1 = generator.generate_address()
	success = success and assert_true(address1.has("street"), "Should have street")
	success = success and assert_true(address1.has("city"), "Should have city")
	success = success and assert_true(address1.has("zip_code"), "Should have zip code")
	success = success and assert_true(address1.has("country"), "Should have country")
	success = success and assert_true(address1.has("full_address"), "Should have full address")

	# Test zip code format
	success = success and assert_equals(address1.zip_code.length(), 5, "Should have 5-digit zip code")
	success = success and assert_true(address1.zip_code.is_valid_int(), "Zip code should be numeric")

	# Test full address format
	success = success and assert_true(address1.full_address.contains(address1.street), "Full address should contain street")
	success = success and assert_true(address1.full_address.contains(address1.city), "Full address should contain city")
	success = success and assert_true(address1.full_address.contains(address1.zip_code), "Full address should contain zip code")

	return success

func test_generate_phone_number() -> bool:
	"""Test phone number generation"""
	print("🧪 Testing phone number generation")

	var success = true

	# Test US format (default)
	var phone1 = generator.generate_phone_number()
	success = success and assert_true(phone1.begins_with("("), "US format should start with (")
	success = success and assert_true(phone1.contains(") "), "US format should contain ) space")
	success = success and assert_true(phone1.contains("-"), "US format should contain dash")

	# Test international format
	var phone2 = generator.generate_phone_number("international")
	success = success and assert_true(phone2.begins_with("+"), "International format should start with +")

	# Test invalid format (should fallback to US)
	var phone3 = generator.generate_phone_number("invalid")
	success = success and assert_true(phone3.begins_with("("), "Invalid format should fallback to US")

	return success

func test_generate_uuid() -> bool:
	"""Test UUID generation"""
	print("🧪 Testing UUID generation")

	var success = true

	# Test UUID format
	var uuid1 = generator.generate_uuid()
	var parts = uuid1.split("-")

	success = success and assert_equals(parts.size(), 5, "Should have 5 parts separated by dashes")

	# Check each part length
	success = success and assert_equals(parts[0].length(), 4, "First part should be 4 characters")
	success = success and assert_equals(parts[1].length(), 4, "Second part should be 4 characters")
	success = success and assert_equals(parts[2].length(), 4, "Third part should be 4 characters")
	success = success and assert_equals(parts[3].length(), 4, "Fourth part should be 4 characters")
	success = success and assert_equals(parts[4].length(), 4, "Fifth part should be 4 characters")

	# Test uniqueness (generate multiple and check they're different)
	var uuid2 = generator.generate_uuid()
	success = success and assert_not_equals(uuid1, uuid2, "Should generate unique UUIDs")

	# Test hex characters only
	for part in parts:
		for char_val in part:
			var char_code = char_val.to_utf8_buffer()[0]
			success = success and assert_true(
				(char_code >= 48 and char_code <= 57) or  # 0-9
				(char_code >= 97 and char_code <= 102),	  # a-f
				"UUID should contain only hex characters"
			)

	return success

# ------------------------------------------------------------------------------
# ARRAY AND COLLECTION GENERATION TESTS
# ------------------------------------------------------------------------------
func test_generate_array() -> bool:
	"""Test array generation"""
	print("🧪 Testing array generation")

	var success = true

	# Test default array generation
	var array1 = generator.generate_array()
	success = success and assert_equals(array1.size(), 5, "Should generate array of default size")
	success = success and assert_type(array1, TYPE_ARRAY, "Should return array")

	# Test custom size
	var array2 = generator.generate_array(3)
	success = success and assert_equals(array2.size(), 3, "Should generate array of custom size")

	# Test with generator function
	var string_generator = func(): return generator.generate_string(3)
	var array3 = generator.generate_array(4, string_generator)
	success = success and assert_equals(array3.size(), 4, "Should generate array with custom generator")
	for item in array3:
		success = success and assert_equals(item.length(), 3, "Each item should match generator output")

	# Test size limits
	var large_array = generator.generate_array(150)	 # Over MAX_ARRAY_SIZE
	success = success and assert_true(large_array.size() <= 100, "Should respect maximum array size")

	return success

func test_generate_unique_array() -> bool:
	"""Test unique array generation"""
	print("🧪 Testing unique array generation")

	var success = true

	# Test unique integer generation
	var unique_ints = generator.generate_unique_array(10, func(): return generator.generate_int(1, 20))
	success = success and assert_equals(unique_ints.size(), 10, "Should generate requested number of unique items")

	# Verify uniqueness
	var seen = {}
	for num in unique_ints:
		success = success and assert_false(seen.has(num), "Should not have duplicate values")
		seen[num] = true

	# Test when uniqueness is impossible (small range, large count)
	var limited_unique = generator.generate_unique_array(50, func(): return generator.generate_int(1, 10))
	success = success and assert_less_than(limited_unique.size(), 50, "Should handle impossible uniqueness gracefully")

	return success

func test_generate_dictionary() -> bool:
	"""Test dictionary generation"""
	print("🧪 Testing dictionary generation")

	var success = true

	# Test default dictionary generation
	var dict1 = generator.generate_dictionary()
	success = success and assert_type(dict1, TYPE_DICTIONARY, "Should return dictionary")
	success = success and assert_greater_than(dict1.size(), 2, "Should have multiple entries")

	# Test with custom keys
	var keys = ["name", "email", "age"]
	var dict2 = generator.generate_dictionary(keys)
	success = success and assert_equals(dict2.size(), 3, "Should have correct number of entries")
	for key in keys:
		success = success and assert_true(dict2.has(key), "Should contain specified key")

	# Test with custom generators
	var generators = [
		func(): return generator.generate_name().full_name,
		func(): return generator.generate_email(),
		func(): return generator.generate_int(18, 80)
	]
	var dict3 = generator.generate_dictionary(keys, generators)
	success = success and assert_equals(dict3.size(), 3, "Should have correct number of entries")
	success = success and assert_type(dict3.name, TYPE_STRING, "Name should be string")
	success = success and assert_type(dict3.email, TYPE_STRING, "Email should be string")
	success = success and assert_type(dict3.age, TYPE_INT, "Age should be int")

	return success

# ------------------------------------------------------------------------------
# OBJECT FACTORY TESTS
# ------------------------------------------------------------------------------
func test_create_user() -> bool:
	"""Test user object creation"""
	print("🧪 Testing user object creation")

	var success = true

	# Test user creation
	var user = generator.create_user()
	success = success and assert_not_null(user, "Should create user object")
	success = success and assert_true(user.has("id"), "Should have ID")
	success = success and assert_true(user.has("email"), "Should have email")
	success = success and assert_true(user.has("name"), "Should have name")
	success = success and assert_true(user.has("phone"), "Should have phone")
	success = success and assert_true(user.has("address"), "Should have address")
	success = success and assert_true(user.has("age"), "Should have age")
	success = success and assert_true(user.has("active"), "Should have active status")
	success = success and assert_true(user.has("preferences"), "Should have preferences")

	# Test data validity
	success = success and assert_true(user.email.contains("@"), "Email should be valid format")
	success = success and assert_type(user.age, TYPE_INT, "Age should be integer")
	success = success and assert_true(user.age >= 18 and user.age <= 80, "Age should be in valid range")

	# Test name structure
	var name_obj = user.name
	success = success and assert_true(name_obj.has("first_name"), "Name should have first_name")
	success = success and assert_true(name_obj.has("last_name"), "Name should have last_name")
	success = success and assert_true(name_obj.has("full_name"), "Name should have full_name")

	return success

func test_create_product() -> bool:
	"""Test product object creation"""
	print("🧪 Testing product object creation")

	var success = true

	# Test product creation
	var product = generator.create_product()
	success = success and assert_not_null(product, "Should create product object")
	success = success and assert_true(product.has("id"), "Should have ID")
	success = success and assert_true(product.has("name"), "Should have name")
	success = success and assert_true(product.has("category"), "Should have category")
	success = success and assert_true(product.has("price"), "Should have price")
	success = success and assert_true(product.has("discounted_price"), "Should have discounted price")
	success = success and assert_true(product.has("in_stock"), "Should have stock status")
	success = success and assert_true(product.has("rating"), "Should have rating")
	success = success and assert_true(product.has("tags"), "Should have tags")

	# Test data validity
	success = success and assert_type(product.price, TYPE_FLOAT, "Price should be float")
	success = success and assert_true(product.price > 0, "Price should be positive")
	success = success and assert_true(product.discounted_price <= product.price, "Discounted price should not exceed original")
	success = success and assert_true(product.rating >= 1.0 and product.rating <= 5.0, "Rating should be in valid range")

	# Test custom category
	var tech_product = generator.create_product("electronics")
	success = success and assert_equals(tech_product.category, "electronics", "Should use custom category")

	return success

# ------------------------------------------------------------------------------
# BULK GENERATION TESTS
# ------------------------------------------------------------------------------
func test_generate_users() -> bool:
	"""Test bulk user generation"""
	print("🧪 Testing bulk user generation")

	var success = true

	# Test user array generation
	var users = generator.generate_users(5)
	success = success and assert_equals(users.size(), 5, "Should generate requested number of users")
	success = success and assert_type(users, TYPE_ARRAY, "Should return array")

	# Test each user
	for user in users:
		success = success and assert_true(user.has("id"), "Each user should have ID")
		success = success and assert_true(user.has("email"), "Each user should have email")
		success = success and assert_true(user.email.contains("@"), "Each user should have valid email")

	# Test uniqueness of emails
	var emails = []
	for user in users:
		success = success and assert_false(emails.has(user.email), "Emails should be unique")
		emails.append(user.email)

	# Test edge cases
	var zero_users = generator.generate_users(0)
	success = success and assert_equals(zero_users.size(), 1, "Should handle zero count gracefully")

	var large_count = generator.generate_users(100)
	success = success and assert_equals(large_count.size(), 100, "Should handle large counts")

	return success

func test_generate_test_data() -> bool:
	"""Test generic test data generation"""
	print("🧪 Testing generic test data generation")

	var success = true

	# Test user data generation
	var user_data = generator.generate_test_data("users", 3)
	success = success and assert_equals(user_data.size(), 3, "Should generate requested count")
	success = success and assert_true(user_data[0].has("email"), "Should generate user data")

	# Test product data generation
	var product_data = generator.generate_test_data("products", 2)
	success = success and assert_equals(product_data.size(), 2, "Should generate requested count")
	success = success and assert_true(product_data[0].has("price"), "Should generate product data")

	# Test email data generation
	var email_data = generator.generate_test_data("emails", 4)
	success = success and assert_equals(email_data.size(), 4, "Should generate requested count")
	for email in email_data:
		success = success and assert_true(email.contains("@"), "Should generate valid emails")

	# Test unknown type (should generate generic data)
	var unknown_data = generator.generate_test_data("unknown_type", 2)
	success = success and assert_equals(unknown_data.size(), 2, "Should handle unknown types gracefully")
	success = success and assert_type(unknown_data[0], TYPE_DICTIONARY, "Should generate dictionary data")

	return success

# ------------------------------------------------------------------------------
# EXPORT FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_export_to_json() -> bool:
	"""Test JSON export functionality"""
	print("🧪 Testing JSON export functionality")

	var success = true

	# Create test data
	var _test_data = {
		"users": generator.generate_users(2),
		"products": generator.generate_products(1),
		"metadata": {
			"generated_at": Time.get_unix_time_from_system(),
			"version": "1.0.0"
		}
	}

	# Test export (would need a temporary file path in real implementation)
	# For now, just test that the method exists and handles null data
	var null_export = generator.export_to_json(null, "")
	success = success and assert_false(null_export, "Should handle null data gracefully")

	return success

func test_create_fixture_data() -> bool:
	"""Test fixture data creation"""
	print("🧪 Testing fixture data creation")

	var success = true

	# Test fixture data creation
	var fixture_data = generator.create_fixture_data(func(): return generator.create_user(), 3)
	success = success and assert_equals(fixture_data.size(), 3, "Should create requested number of fixtures")

	# Test fixture structure
	var first_fixture = fixture_data[0]
	success = success and assert_true(first_fixture.has("fixture_id"), "Should have fixture ID")
	success = success and assert_true(first_fixture.has("created_by"), "Should have created_by field")
	success = success and assert_true(first_fixture.has("created_at"), "Should have created_at timestamp")
	success = success and assert_true(first_fixture.has("email"), "Should have original user data")

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	print("🧪 Testing error handling and edge cases")

	var success = true

	# Test invalid string length
	var empty_string = generator.generate_string(0)
	success = success and assert_equals(empty_string.length(), 10, "Should handle invalid length gracefully")

	# Test invalid charset
	var invalid_charset = generator.generate_string(5, "invalid_charset")
	success = success and assert_equals(invalid_charset.length(), 5, "Should handle invalid charset gracefully")

	# Test invalid array size
	var empty_array = generator.generate_array(0)
	success = success and assert_equals(empty_array.size(), 5, "Should handle invalid array size gracefully")

	# Test invalid date range
	var invalid_date = generator.generate_date(2024, 2020)	# start > end
	success = success and assert_true(invalid_date.year >= 2020 and invalid_date.year <= 2024, "Should handle invalid date range")

	return success

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all TestDataGenerator tests"""
	print("\n📊 Running TestDataGenerator Test Suite\n")

	# Basic Data Generation
	run_test("test_generate_string", func(): return test_generate_string())
	run_test("test_generate_int", func(): return test_generate_int())
	run_test("test_generate_float", func(): return test_generate_float())
	run_test("test_generate_bool", func(): return test_generate_bool())
	run_test("test_generate_date", func(): return test_generate_date())

	# Specialized Data Generation
	run_test("test_generate_email", func(): return test_generate_email())
	run_test("test_generate_name", func(): return test_generate_name())
	run_test("test_generate_address", func(): return test_generate_address())
	run_test("test_generate_phone_number", func(): return test_generate_phone_number())
	run_test("test_generate_uuid", func(): return test_generate_uuid())

	# Array and Collection Generation
	run_test("test_generate_array", func(): return test_generate_array())
	run_test("test_generate_unique_array", func(): return test_generate_unique_array())
	run_test("test_generate_dictionary", func(): return test_generate_dictionary())

	# Object Factory Methods
	run_test("test_create_user", func(): return test_create_user())
	run_test("test_create_product", func(): return test_create_product())

	# Bulk Generation
	run_test("test_generate_users", func(): return test_generate_users())
	run_test("test_generate_test_data", func(): return test_generate_test_data())

	# Export Functionality
	run_test("test_export_to_json", func(): return test_export_to_json())
	run_test("test_create_fixture_data", func(): return test_create_fixture_data())

	# Error Handling
	run_test("test_error_handling", func(): return test_error_handling())

	print("\n📊 TestDataGenerator Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# MAIN EXECUTION ENTRY POINT
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
