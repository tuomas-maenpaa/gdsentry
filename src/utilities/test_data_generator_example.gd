# GDSentry - Test Data Generator Usage Examples
# Practical examples demonstrating how to use the TestDataGenerator
#
# This file provides comprehensive examples of using the TestDataGenerator
# for various testing scenarios including:
# - Basic data generation
# - Object creation factories
# - Bulk data generation
# - Integration with GDSentry fixtures
# - Export functionality
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestDataGeneratorExample

# ------------------------------------------------------------------------------
# EXAMPLE SETUP
# ------------------------------------------------------------------------------
var generator

func _ready() -> void:
	"""Initialize the example"""
	generator = load("res://utilities/test_data_generator.gd").new()
	add_child(generator)

	print("🎯 GDSentry TestDataGenerator Examples")
	print("====================================\n")

	run_examples()

# ------------------------------------------------------------------------------
# BASIC DATA GENERATION EXAMPLES
# ------------------------------------------------------------------------------
func example_basic_data_generation() -> void:
	"""Example: Basic data type generation"""
	print("📝 Example 1: Basic Data Generation")
	print("-----------------------------------")

	# Generate basic data types
	var random_string = generator.generate_string(12)
	var random_number = generator.generate_int(1, 100)
	var random_float = generator.generate_float(0.0, 10.0, 2)
	var random_bool = generator.generate_bool(0.7)	# 70% chance of true
	var random_date = generator.generate_date(2020, 2024)

	print("Random String (12 chars):", random_string)
	print("Random Number (1-100):", random_number)
	print("Random Float (0-10, 2 decimals):", random_float)
	print("Random Boolean (70% true):", random_bool)
	print("Random Date (2020-2024):", random_date.string)
	print()

# ------------------------------------------------------------------------------
# SPECIALIZED DATA GENERATION EXAMPLES
# ------------------------------------------------------------------------------
func example_specialized_data() -> void:
	"""Example: Specialized data generation"""
	print("📧 Example 2: Specialized Data Generation")
	print("-----------------------------------------")

	# Generate realistic test data
	var email = generator.generate_email("company.com")
	var name_data = generator.generate_name()
	var address = generator.generate_address()
	var phone = generator.generate_phone_number()
	var uuid = generator.generate_uuid()

	print("Email:", email)
	print("Full Name:", name_data.full_name)
	print("Address:", address.full_address)
	print("Phone:", phone)
	print("UUID:", uuid)
	print()

# ------------------------------------------------------------------------------
# OBJECT FACTORY EXAMPLES
# ------------------------------------------------------------------------------
func example_object_factories() -> void:
	"""Example: Using object factories"""
	print("🏭 Example 3: Object Factories")
	print("------------------------------")

	# Create complete user object
	var user = generator.create_user()
	print("Generated User:")
	print("	 ID:", user.id)
	print("	 Name:", user.name.full_name)
	print("	 Email:", user.email)
	print("	 Age:", user.age)
	print("	 Phone:", user.phone)
	print("	 Address:", user.address.city, ",", user.address.country)
	print("	 Active:", user.active)
	print()

	# Create product object
	var product = generator.create_product("electronics")
	print("Generated Product:")
	print("	 ID:", product.id)
	print("	 Name:", product.name)
	print("	 Category:", product.category)
	print("	 Price: $%.2f" % product.price)
	print("	 Rating:", product.rating, "stars")
	print("	 In Stock:", product.in_stock)
	print()

# ------------------------------------------------------------------------------
# BULK DATA GENERATION EXAMPLES
# ------------------------------------------------------------------------------
func example_bulk_generation() -> void:
	"""Example: Bulk data generation"""
	print("📊 Example 4: Bulk Data Generation")
	print("----------------------------------")

	# Generate multiple users
	var users = generator.generate_users(3)
	print("Generated", users.size(), "users:")
	for i in range(users.size()):
		print("	 User", i + 1, ":", users[i].name.full_name, "-", users[i].email)
	print()

	# Generate multiple products
	var products = generator.generate_products(2, "books")
	print("Generated", products.size(), "books:")
	for i in range(products.size()):
		print("	 Book", i + 1, ":", products[i].name, "- $%.2f" % products[i].price)
	print()

# ------------------------------------------------------------------------------
# ARRAY AND COLLECTION EXAMPLES
# ------------------------------------------------------------------------------
func example_collections() -> void:
	"""Example: Array and collection generation"""
	print("📋 Example 5: Arrays and Collections")
	print("------------------------------------")

	# Generate array of strings
	var string_array = generator.generate_array(5, func(): return generator.generate_string(8))
	print("String Array:", string_array)
	print()

	# Generate unique numbers
	var unique_numbers = generator.generate_unique_array(10, func(): return generator.generate_int(1, 20))
	print("Unique Numbers (1-20):", unique_numbers)
	print()

	# Generate dictionary with custom structure
	var keys = ["first_name", "last_name", "email", "department"]
	var generators = [
		func(): return generator.generate_name().first_name,
		func(): return generator.generate_name().last_name,
		func(): return generator.generate_email("company.com"),
		func(): return ["Engineering", "Marketing", "Sales", "HR"][generator.generate_int(0, 3)]
	]
	var employee_dict = generator.generate_dictionary(keys, generators)
	print("Employee Dictionary:")
	for key in employee_dict.keys():
		print("	 ", key, ":", employee_dict[key])
	print()

# ------------------------------------------------------------------------------
# FIXTURE INTEGRATION EXAMPLES
# ------------------------------------------------------------------------------
func example_fixture_integration() -> void:
	"""Example: Integration with GDSentry fixtures"""
	print("🔧 Example 6: GDSentry Fixture Integration")
	print("----------------------------------------")

	# Create fixture-compatible data
	var user_fixtures = generator.create_fixture_data(func(): return generator.create_user(), 2)

	print("Generated", user_fixtures.size(), "user fixtures:")
	for i in range(user_fixtures.size()):
		var fixture = user_fixtures[i]
		print("	 Fixture", i + 1, ":")
		print("	   ID:", fixture.fixture_id)
		print("	   User:", fixture.name.full_name)
		print("	   Email:", fixture.email)
		print("	   Created by:", fixture.created_by)
		print("	   Created at:", Time.get_datetime_string_from_unix_time(fixture.created_at))
	print()

# ------------------------------------------------------------------------------
# EXPORT FUNCTIONALITY EXAMPLES
# ------------------------------------------------------------------------------
func example_data_export() -> void:
	"""Example: Data export functionality"""
	print("💾 Example 7: Data Export")
	print("------------------------")

	# Create test dataset
	var test_data = {
		"metadata": {
			"generated_at": Time.get_unix_time_from_system(),
			"generator_version": "1.0.0",
			"description": "Example test dataset"
		},
		"users": generator.generate_users(3),
		"products": generator.generate_products(2),
		"test_scenarios": [
			generator.create_test_scenario("user_registration"),
			generator.create_test_scenario("product_purchase")
		]
	}

	print("Generated test dataset:")
	print("	 Users:", test_data.users.size())
	print("	 Products:", test_data.products.size())
	print("	 Test Scenarios:", test_data.test_scenarios.size())
	print()

	# Note: Actual export would require file system permissions
	# var success = generator.export_to_json(test_data, "test_data.json")
	# print("Export to JSON:", "Success" if success else "Failed")

# ------------------------------------------------------------------------------
# PRACTICAL TESTING SCENARIOS
# ------------------------------------------------------------------------------
func example_practical_scenarios() -> void:
	"""Example: Practical testing scenarios"""
	print("🎯 Example 8: Practical Testing Scenarios")
	print("-----------------------------------------")

	# Scenario 1: User registration testing
	print("User Registration Test Data:")
	var registration_users = []
	for i in range(3):
		var user = generator.create_user()
		user.registration_date = generator.generate_date(2024, 2024)
		user.email_verified = generator.generate_bool(0.8)
		registration_users.append(user)
		print("	 User:", user.name.full_name, "- Verified:", user.email_verified)

	print()

	# Scenario 2: E-commerce testing
	print("E-commerce Test Data:")
	var ecommerce_data = {
		"customers": generator.generate_users(2),
		"products": generator.generate_products(3, "electronics"),
		"orders": []
	}

	# Generate orders
	for i in range(2):
		var order = {
			"id": generator.generate_uuid(),
			"customer_id": ecommerce_data.customers[i].id,
			"items": generator.generate_array(
				generator.generate_int(1, 3),
				func(): return {
					"product_id": ecommerce_data.products[generator.generate_int(0, 2)].id,
					"quantity": generator.generate_int(1, 5),
					"price": generator.generate_float(10.0, 100.0)
				}
			),
			"order_date": generator.generate_date(2024, 2024),
			"status": ["pending", "confirmed", "shipped"][generator.generate_int(0, 2)]
		}
		ecommerce_data.orders.append(order)
		print("	 Order:", order.id, "- Status:", order.status, "- Items:", order.items.size())

	print()

# ------------------------------------------------------------------------------
# PERFORMANCE TESTING EXAMPLE
# ------------------------------------------------------------------------------
func example_performance_testing() -> void:
	"""Example: Performance testing with generated data"""
	print("⚡ Example 9: Performance Testing")
	print("--------------------------------")

	var start_time = Time.get_ticks_usec()

	# Generate large dataset for performance testing
	var large_user_set = generator.generate_users(100)
	var large_product_set = generator.generate_products(50)

	var end_time = Time.get_ticks_usec()
	var generation_time = (end_time - start_time) / 1000000.0  # Convert to seconds

	print("Generated", large_user_set.size(), "users and", large_product_set.size(), "products")
	print("Generation time: %.3f seconds" % generation_time)
	print("Average time per user: %.4f seconds" % (generation_time / large_user_set.size()))
	print()

# ------------------------------------------------------------------------------
# RUN ALL EXAMPLES
# ------------------------------------------------------------------------------
func run_examples() -> void:
	"""Run all examples"""
	example_basic_data_generation()
	example_specialized_data()
	example_object_factories()
	example_bulk_generation()
	example_collections()
	example_fixture_integration()
	example_data_export()
	example_practical_scenarios()
	example_performance_testing()

	print("🎉 All examples completed!")
	print("\n💡 Tip: Use these examples as templates for your own test data generation needs.")
	print("📖 For more advanced usage, see the TestDataGenerator class documentation.")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	if generator:
		generator.queue_free()
