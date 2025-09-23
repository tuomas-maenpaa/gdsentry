# GDSentry - Test Data Generator Framework
# Comprehensive test data generation utilities for GDSentry
#
# This framework provides automated test data generation capabilities including:
# - Random data generators for common types (strings, numbers, dates, emails)
# - Factory pattern for complex object creation
# - Configurable data constraints and validation
# - CSV/JSON export capabilities for data-driven testing
# - Integration with GDSentry's fixture and mocking systems
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestDataGenerator

# ------------------------------------------------------------------------------
# FRAMEWORK CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_STRING_LENGTH = 10
const MAX_STRING_LENGTH = 1000
const DEFAULT_ARRAY_SIZE = 5
const MAX_ARRAY_SIZE = 100

# Common data patterns
const EMAIL_DOMAINS = ["gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "example.com"]
const FIRST_NAMES = ["John", "Jane", "Michael", "Sarah", "David", "Emma", "Chris", "Lisa"]
const LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis"]
const CITIES = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia"]
const COUNTRIES = ["USA", "Canada", "UK", "Germany", "France", "Australia", "Japan"]

# ------------------------------------------------------------------------------
# FRAMEWORK METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	randomize()	 # Ensure random seed is set

# ------------------------------------------------------------------------------
# BASIC DATA GENERATORS
# ------------------------------------------------------------------------------
func generate_string(length: int = DEFAULT_STRING_LENGTH, charset: String = "alphanumeric") -> String:
	"""Generate a random string with specified length and character set"""
	if length <= 0:
		push_warning("TestDataGenerator: Invalid string length %d, using default" % length)
		length = DEFAULT_STRING_LENGTH

	if length > MAX_STRING_LENGTH:
		push_warning("TestDataGenerator: String length %d exceeds maximum %d, truncating" % [length, MAX_STRING_LENGTH])
		length = MAX_STRING_LENGTH

	var chars = _get_charset(charset)
	if chars.is_empty():
		push_error("TestDataGenerator: Invalid charset '%s', using alphanumeric" % charset)
		chars = _get_charset("alphanumeric")

	var result = ""
	for i in range(length):
		result += chars[randi() % chars.length()]

	return result

func generate_int(min_value: int = 0, max_value: int = 100) -> int:
	"""Generate a random integer within the specified range"""
	if min_value > max_value:
		push_warning("TestDataGenerator: min_value > max_value, swapping values")
		var temp = min_value
		min_value = max_value
		max_value = temp

	return randi() % (max_value - min_value + 1) + min_value

func generate_float(min_value: float = 0.0, max_value: float = 100.0, precision: int = 2) -> float:
	"""Generate a random float within the specified range"""
	if min_value > max_value:
		push_warning("TestDataGenerator: min_value > max_value, swapping values")
		var temp = min_value
		min_value = max_value
		max_value = temp

	var value = randf() * (max_value - min_value) + min_value
	return snapped(value, pow(10, -precision))

func generate_bool(true_probability: float = 0.5) -> bool:
	"""Generate a random boolean with specified probability of being true"""
	if true_probability < 0.0 or true_probability > 1.0:
		push_warning("TestDataGenerator: Invalid probability %.2f, using 0.5" % true_probability)
		true_probability = 0.5

	return randf() < true_probability

func generate_date(start_year: int = 2000, end_year: int = 2024) -> Dictionary:
	"""Generate a random date within the specified year range"""
	if start_year > end_year:
		push_warning("TestDataGenerator: start_year > end_year, swapping values")
		var temp = start_year
		start_year = end_year
		end_year = temp

	var year = generate_int(start_year, end_year)
	var month = generate_int(1, 12)
	var day = generate_int(1, _days_in_month(month, year))

	return {
		"year": year,
		"month": month,
		"day": day,
		"string": "%04d-%02d-%02d" % [year, month, day],
		"timestamp": Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0})
	}

# ------------------------------------------------------------------------------
# SPECIALIZED DATA GENERATORS
# ------------------------------------------------------------------------------
func generate_email(domain: String = "", prefix_length: int = 8) -> String:
	"""Generate a random email address"""
	var prefix = generate_string(prefix_length, "alphanumeric").to_lower()

	if domain.is_empty():
		domain = EMAIL_DOMAINS[randi() % EMAIL_DOMAINS.size()]

	return "%s@%s" % [prefix, domain]

func generate_name() -> Dictionary:
	"""Generate a random name with first and last name"""
	var first_name = FIRST_NAMES[randi() % FIRST_NAMES.size()]
	var last_name = LAST_NAMES[randi() % LAST_NAMES.size()]

	return {
		"first_name": first_name,
		"last_name": last_name,
		"full_name": "%s %s" % [first_name, last_name],
		"initials": "%s%s" % [first_name[0], last_name[0]]
	}

func generate_address() -> Dictionary:
	"""Generate a random address"""
	var street_number = generate_int(1, 9999)
	var street_name = generate_string(generate_int(5, 12), "alphabetic")
	var city = CITIES[randi() % CITIES.size()]
	var zip_code = "%05d" % generate_int(10000, 99999)
	var country = COUNTRIES[randi() % COUNTRIES.size()]

	return {
		"street": "%d %s Street" % [street_number, street_name],
		"city": city,
		"zip_code": zip_code,
		"country": country,
		"full_address": "%d %s Street, %s, %s %s" % [street_number, street_name, city, country, zip_code]
	}

func generate_phone_number(format: String = "us") -> String:
	"""Generate a random phone number in specified format"""
	match format:
		"us":
			return "(%03d) %03d-%04d" % [
				generate_int(200, 999),
				generate_int(100, 999),
				generate_int(1000, 9999)
			]
		"international":
			return "+%d %03d %03d %04d" % [
				generate_int(1, 999),
				generate_int(100, 999),
				generate_int(100, 999),
				generate_int(1000, 9999)
			]
		_:
			push_warning("TestDataGenerator: Unknown phone format '%s', using 'us'" % format)
			return generate_phone_number("us")

func generate_uuid() -> String:
	"""Generate a random UUID-like string"""
	var parts = []
	for i in range(5):
		parts.append(generate_string(4, "hex").to_lower())

	return "%s-%s-%s-%s-%s" % parts

# ------------------------------------------------------------------------------
# ARRAY AND COLLECTION GENERATORS
# ------------------------------------------------------------------------------
func generate_array(size: int = DEFAULT_ARRAY_SIZE, generator_func: Callable = Callable()) -> Array:
	"""Generate an array of random data using a generator function"""
	if size <= 0:
		push_warning("TestDataGenerator: Invalid array size %d, using default" % size)
		size = DEFAULT_ARRAY_SIZE

	if size > MAX_ARRAY_SIZE:
		push_warning("TestDataGenerator: Array size %d exceeds maximum %d, truncating" % [size, MAX_ARRAY_SIZE])
		size = MAX_ARRAY_SIZE

	var result = []

	if generator_func.is_valid():
		for i in range(size):
			result.append(generator_func.call())
	else:
		# Default to generating integers
		for i in range(size):
			result.append(generate_int())

	return result

func generate_unique_array(size: int = DEFAULT_ARRAY_SIZE, generator_func: Callable = Callable(), max_attempts: int = 1000) -> Array:
	"""Generate an array of unique random data"""
	if size <= 0:
		push_warning("TestDataGenerator: Invalid array size %d, using default" % size)
		size = DEFAULT_ARRAY_SIZE

	var result = []
	var attempts = 0

	while result.size() < size and attempts < max_attempts:
		var value = generator_func.call() if generator_func.is_valid() else generate_int()

		if not result.has(value):
			result.append(value)
		attempts += 1

	if result.size() < size:
		push_warning("TestDataGenerator: Could not generate %d unique values after %d attempts" % [size, max_attempts])

	return result

func generate_dictionary(keys: Array = [], generator_funcs: Array = []) -> Dictionary:
	"""Generate a dictionary with specified keys and generator functions"""
	var result = {}

	if keys.is_empty():
		# Generate a random dictionary with 3-8 entries
		var num_entries = generate_int(3, 8)
		for i in range(num_entries):
			var key = "key_%d" % i
			result[key] = generate_string()
	else:
		for i in range(keys.size()):
			var key = keys[i]
			var value = Callable()

			if i < generator_funcs.size() and generator_funcs[i].is_valid():
				value = generator_funcs[i].call()
			else:
				value = generate_string()

			result[key] = value

	return result

# ------------------------------------------------------------------------------
# OBJECT FACTORY METHODS
# ------------------------------------------------------------------------------
func create_user() -> Dictionary:
	"""Create a complete user object with realistic data"""
	var name_data = generate_name()

	return {
		"id": generate_uuid(),
		"email": generate_email(),
		"name": name_data,
		"phone": generate_phone_number(),
		"address": generate_address(),
		"age": generate_int(18, 80),
		"active": generate_bool(0.8),  # 80% chance of being active
		"created_at": generate_date(2020, 2024),
		"preferences": {
			"notifications": generate_bool(0.6),
			"theme": ["light", "dark"][generate_int(0, 1)],
			"language": ["en", "es", "fr", "de"][generate_int(0, 3)]
		}
	}

func create_product(category: String = "") -> Dictionary:
	"""Create a product object with realistic data"""
	var categories = ["electronics", "clothing", "books", "home", "sports"]
	if category.is_empty():
		category = categories[randi() % categories.size()]

	var base_price = generate_float(10.0, 1000.0)
	var discount = generate_float(0.0, 0.3)	 # 0-30% discount

	return {
		"id": generate_uuid(),
		"name": generate_string(generate_int(8, 20), "alphabetic"),
		"category": category,
		"price": base_price,
		"discounted_price": base_price * (1.0 - discount),
		"in_stock": generate_bool(0.9),	 # 90% chance of being in stock
		"rating": generate_float(1.0, 5.0, 1),
		"reviews_count": generate_int(0, 500),
		"tags": generate_array(generate_int(2, 5), func(): return generate_string(6, "alphabetic"))
	}

func create_test_scenario(scenario_name: String = "") -> Dictionary:
	"""Create a test scenario template"""
	if scenario_name.is_empty():
		scenario_name = "scenario_%s" % generate_string(8, "alphanumeric")

	return {
		"id": generate_uuid(),
		"name": scenario_name,
		"description": "Generated test scenario for %s" % scenario_name,
		"test_data": generate_dictionary(),
		"expected_results": generate_array(3),
		"tags": ["generated", "scenario"],
		"created_at": Time.get_unix_time_from_system()
	}

# ------------------------------------------------------------------------------
# BULK DATA GENERATION
# ------------------------------------------------------------------------------
func generate_users(count: int) -> Array:
	"""Generate multiple user objects"""
	if count <= 0:
		push_warning("TestDataGenerator: Invalid count %d, using 1" % count)
		count = 1

	if count > 1000:
		push_warning("TestDataGenerator: Large count %d may impact performance" % count)

	var users = []
	for i in range(count):
		users.append(create_user())

	return users

func generate_products(count: int, category: String = "") -> Array:
	"""Generate multiple product objects"""
	if count <= 0:
		push_warning("TestDataGenerator: Invalid count %d, using 1" % count)
		count = 1

	var products = []
	for i in range(count):
		products.append(create_product(category))

	return products

func generate_test_data(type: String, count: int = 1) -> Array:
	"""Generate test data of specified type"""
	match type:
		"users":
			return generate_users(count)
		"products":
			return generate_products(count)
		"emails":
			var emails = []
			for i in range(count):
				emails.append(generate_email())
			return emails
		"names":
			var names = []
			for i in range(count):
				names.append(generate_name())
			return names
		"addresses":
			var addresses = []
			for i in range(count):
				addresses.append(generate_address())
			return addresses
		_:
			push_warning("TestDataGenerator: Unknown data type '%s', generating generic data" % type)
			var generic = []
			for i in range(count):
				generic.append(generate_dictionary())
			return generic

# ------------------------------------------------------------------------------
# EXPORT AND SERIALIZATION
# ------------------------------------------------------------------------------
func export_to_json(data, file_path: String) -> bool:
	"""Export generated data to JSON file"""
	var json_string = JSON.stringify(data, "\t")

	var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")
	var file = FileSystemCompatibility.open_file(file_path, FileSystemCompatibility.WRITE)
	if not file:
		push_error("TestDataGenerator: Failed to open file for writing: %s" % file_path)
		return false

	FileSystemCompatibility.store_string(file, json_string)
	FileSystemCompatibility.close_file(file)

	print("TestDataGenerator: Exported data to %s (%d bytes)" % [file_path, json_string.length()])
	return true

func export_to_csv(data: Array, file_path: String, headers: Array = []) -> bool:
	"""Export array data to CSV file"""
	if data.is_empty():
		push_warning("TestDataGenerator: No data to export to CSV")
		return false

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("TestDataGenerator: Failed to open file for writing: %s" % file_path)
		return false

	# Write headers if provided, otherwise use first object's keys
	if headers.is_empty() and data[0] is Dictionary:
		headers = data[0].keys()

	if not headers.is_empty():
		file.store_line(",".join(headers))

	# Write data rows
	for item in data:
		if item is Dictionary:
			var row = []
			for header in headers:
				var value = item.get(header, "")
				if value is String:
					# Escape quotes and wrap in quotes if contains comma
					if value.contains(",") or value.contains("\""):
						value = "\"%s\"" % value.replace("\"", "\"\"")
					row.append(value)
				else:
					row.append(str(value))
			file.store_line(",".join(row))
		else:
			file.store_line(str(item))

	file.close()

	print("TestDataGenerator: Exported %d records to %s" % [data.size(), file_path])
	return true

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func _get_charset(charset: String) -> String:
	"""Get character set for string generation"""
	match charset:
		"alphabetic":
			return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
		"numeric":
			return "0123456789"
		"alphanumeric":
			return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		"hex":
			return "0123456789ABCDEF"
		"symbols":
			return "!@#$%^&*()_+-=[]{}|;:,.<>?"
		"printable":
			return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>? "
		_:
			return charset	# Use custom charset as-is

func _days_in_month(month: int, year: int) -> int:
	"""Get number of days in specified month and year"""
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			# Check for leap year
			if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
				return 29
			else:
				return 28
		_:
			return 30  # Default fallback

# ------------------------------------------------------------------------------
# INTEGRATION WITH GDSENTRY FIXTURES
# ------------------------------------------------------------------------------
func create_fixture_data(generator_func: Callable, count: int = 1) -> Array:
	"""Create fixture data compatible with GDSentry fixture system"""
	var data = []

	for i in range(count):
		var item = generator_func.call()
		if item is Dictionary:
			item["fixture_id"] = generate_uuid()
			item["created_by"] = "TestDataGenerator"
			item["created_at"] = Time.get_unix_time_from_system()

		data.append(item)

	return data

func register_as_fixture(_fixture_name: String, _generator_func: Callable, _count: int = 1) -> void:
	"""Register generated data as GDSentry fixture (requires GDTest context)"""
	push_warning("TestDataGenerator: register_as_fixture() requires GDTest context to function properly")
	push_warning("TestDataGenerator: Use create_fixture_data() instead and register manually")

# ------------------------------------------------------------------------------
# CLEANUP AND RESOURCE MANAGEMENT
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources when node is removed from tree"""
	pass
