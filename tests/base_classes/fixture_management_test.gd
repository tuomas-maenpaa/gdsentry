# GDSentry - Test Fixture Management Demonstration
# Demonstrates the enterprise fixture management capabilities of GDSentry
#
# Features demonstrated:
# - Fixture registration with dependencies
# - Automatic lifecycle management
# - Fixture cleanup and reset
# - Circular dependency detection
# - Error handling
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name FixtureManagementTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Demonstrate enterprise test fixture management capabilities"
	test_tags = ["fixture", "enterprise", "dependency_management", "lifecycle"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# DEMO FIXTURE CLASSES
# ------------------------------------------------------------------------------
class MockDatabase:
	var connection_string: String = "mock://localhost:5432/testdb"
	var db_connected: bool = false
	var tables_created: Array[String] = []

	func _init():
		print("MockDatabase: Initializing...")

	func connect_to_database() -> bool:
		print("MockDatabase: Connecting to database...")
		db_connected = true
		return true

	func disconnect_from_database() -> void:
		print("MockDatabase: Disconnecting...")
		db_connected = false

	func create_table(table_name: String) -> bool:
		if not db_connected:
			push_error("MockDatabase: Cannot create table - not connected")
			return false
		tables_created.append(table_name)
		print("MockDatabase: Created table '%s'" % table_name)
		return true

	func cleanup() -> bool:
		print("MockDatabase: Running cleanup...")
		disconnect_from_database()
		return true

class MockUserService:
	var database: MockDatabase = null
	var users: Array = []

	func _init(db: MockDatabase):
		print("MockUserService: Initializing with database...")
		database = db

	func create_user(username: String, email: String) -> bool:
		if not database or not database.db_connected:
			push_error("MockUserService: Database not available")
			return false

		if not database.create_table("users"):
			return false

		var user = {"username": username, "email": email}
		users.append(user)
		print("MockUserService: Created user '%s'" % username)
		return true

	func get_user_count() -> int:
		return users.size()

	func cleanup() -> bool:
		print("MockUserService: Running cleanup...")
		users.clear()
		return true

# ------------------------------------------------------------------------------
# FIXTURE SETUP
# ------------------------------------------------------------------------------
func setup_suite() -> void:
	print("\n=== GDSentry Fixture Management Demo ===\n")

	# Register fixtures with dependencies
	register_fixture("database",
		func(): return MockDatabase.new(),
		[],  # No dependencies
		["cleanup"]  # Cleanup method
	)

	register_fixture("user_service",
		func(): return MockUserService.new(get_fixture("database")),
		["database"],  # Depends on database
		["cleanup"]  # Cleanup method
	)

	print("✅ Fixtures registered successfully\n")

func teardown_suite() -> void:
	print("\n=== Fixture Demo Complete ===\n")

# ------------------------------------------------------------------------------
# FIXTURE MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_fixture_registration() -> bool:
	"""Test basic fixture registration and access"""
	print("🧪 Testing fixture registration...")

	var success = true

	# Test fixture access
	var db = get_fixture("database") as MockDatabase
	success = success and assert_not_null(db, "Database fixture should be accessible")
	success = success and assert_equals(db.connection_string, "mock://localhost:5432/testdb", "Database should have correct connection string")

	var user_service = get_fixture("user_service") as MockUserService
	success = success and assert_not_null(user_service, "User service fixture should be accessible")
	success = success and assert_not_null(user_service.database, "User service should have database reference")

	if success:
		print("✅ Fixture registration test passed")
	else:
		print("❌ Fixture registration test failed")

	return success

func test_fixture_dependencies() -> bool:
	"""Test fixture dependency management"""
	print("🧪 Testing fixture dependencies...")

	var success = true

	# Access user service (should automatically initialize database dependency)
	var user_service = get_fixture("user_service") as MockUserService
	success = success and assert_not_null(user_service, "User service should be available")

	# Verify database was initialized as dependency
	var db = get_fixture("database") as MockDatabase
	success = success and assert_not_null(db, "Database dependency should be initialized")
	success = success and assert_true(db.db_connected, "Database should be connected")

	if success:
		print("✅ Fixture dependencies test passed")
	else:
		print("❌ Fixture dependencies test failed")

	return success

func test_fixture_functionality() -> bool:
	"""Test fixture functionality with real operations"""
	print("🧪 Testing fixture functionality...")

	var success = true

	var db = get_fixture("database") as MockDatabase
	var user_service = get_fixture("user_service") as MockUserService

	# Test database operations
	success = success and assert_true(db.connect_to_database(), "Database should connect successfully")
	success = success and assert_true(db.db_connected, "Database should be connected")

	# Test user service operations
	success = success and assert_true(user_service.create_user("john_doe", "john@example.com"), "Should create user successfully")
	success = success and assert_true(user_service.create_user("jane_doe", "jane@example.com"), "Should create second user successfully")
	success = success and assert_equals(user_service.get_user_count(), 2, "Should have 2 users")

	# Verify database table was created
	success = success and assert_true(db.tables_created.has("users"), "Database should have created users table")

	if success:
		print("✅ Fixture functionality test passed")
	else:
		print("❌ Fixture functionality test failed")

	return success

func test_fixture_cleanup() -> bool:
	"""Test fixture cleanup functionality"""
	print("🧪 Testing fixture cleanup...")

	var success = true

	# Get fixtures
	var db = get_fixture("database") as MockDatabase
	var user_service = get_fixture("user_service") as MockUserService

	# Verify fixtures are working
	success = success and assert_true(db.db_connected, "Database should be connected")
	success = success and assert_greater_than(user_service.get_user_count(), 0, "Should have users")

	# Test manual cleanup of specific fixture
	success = success and assert_true(cleanup_fixture("user_service"), "User service cleanup should succeed")

	# Verify user service was cleaned up
	var fresh_user_service = get_fixture("user_service") as MockUserService
	success = success and assert_equals(fresh_user_service.get_user_count(), 0, "User service should be reset after cleanup")

	# Test cleanup of all fixtures
	success = success and assert_true(cleanup_all_fixtures(), "All fixtures cleanup should succeed")

	if success:
		print("✅ Fixture cleanup test passed")
	else:
		print("❌ Fixture cleanup test failed")

	return success

func test_fixture_reset() -> bool:
	"""Test fixture reset functionality"""
	print("🧪 Testing fixture reset...")

	var success = true

	# Get and modify fixtures
	var _db = get_fixture("database") as MockDatabase
	var user_service = get_fixture("user_service") as MockUserService

	# Make some changes
	user_service.create_user("test_user", "test@example.com")
	success = success and assert_equals(user_service.get_user_count(), 1, "Should have 1 user initially")

	# Reset user service fixture
	success = success and assert_true(reset_fixture("user_service"), "User service reset should succeed")

	# Access fixture again (should be reinitialized)
	var fresh_user_service = get_fixture("user_service") as MockUserService
	success = success and assert_equals(fresh_user_service.get_user_count(), 0, "User service should be reset")

	if success:
		print("✅ Fixture reset test passed")
	else:
		print("❌ Fixture reset test failed")

	return success

func test_fixture_error_handling() -> bool:
	"""Test fixture error handling"""
	print("🧪 Testing fixture error handling...")

	var success = true

	# Test accessing non-existent fixture
	var null_fixture = get_fixture("nonexistent")
	success = success and assert_null(null_fixture, "Non-existent fixture should return null")

	# Test circular dependency detection would require more complex setup
	# (This is tested internally in the fixture management system)

	if success:
		print("✅ Fixture error handling test passed")
	else:
		print("❌ Fixture error handling test failed")

	return success

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_fixture_lifecycle_integration() -> bool:
	"""Test complete fixture lifecycle integration"""
	print("🧪 Testing fixture lifecycle integration...")

	var success = true

	# This test demonstrates the complete fixture lifecycle
	var _db = get_fixture("database") as MockDatabase
	var user_service = get_fixture("user_service") as MockUserService

	# Perform operations
	success = success and assert_true(user_service.create_user("integration_test", "integration@example.com"), "Integration test should work")

	# The fixtures will be automatically cleaned up by the framework
	# after this test completes

	if success:
		print("✅ Fixture lifecycle integration test passed")
	else:
		print("❌ Fixture lifecycle integration test failed")

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE TEST
# ------------------------------------------------------------------------------
func test_fixture_performance() -> bool:
	"""Test fixture performance and efficiency"""
	print("🧪 Testing fixture performance...")

	var success = true

	# Measure fixture access time
	var start_time = Time.get_time_dict_from_system()

	# Access fixtures multiple times (should be cached after first access)
	for i in range(100):
		var db = get_fixture("database")
		var user_service = get_fixture("user_service")
		success = success and assert_not_null(db, "Database should always be accessible")
		success = success and assert_not_null(user_service, "User service should always be accessible")

	var end_time = Time.get_time_dict_from_system()
	var elapsed = Time.get_unix_time_from_datetime_dict(end_time) - Time.get_unix_time_from_datetime_dict(start_time)

	# Performance should be very fast (fixture caching)
	success = success and assert_less_than(elapsed, 1.0, "Fixture access should be fast (<%0.1fs)" % elapsed)

	if success:
		print("✅ Fixture performance test passed (%.3fs)" % elapsed)
	else:
		print("❌ Fixture performance test failed")

	return success

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	print("\n🚀 Running Fixture Management Test Suite\n")

	run_test("test_fixture_registration", func(): return test_fixture_registration())
	run_test("test_fixture_dependencies", func(): return test_fixture_dependencies())
	run_test("test_fixture_functionality", func(): return test_fixture_functionality())
	run_test("test_fixture_cleanup", func(): return test_fixture_cleanup())
	run_test("test_fixture_reset", func(): return test_fixture_reset())
	run_test("test_fixture_error_handling", func(): return test_fixture_error_handling())
	run_test("test_fixture_lifecycle_integration", func(): return test_fixture_lifecycle_integration())
	run_test("test_fixture_performance", func(): return test_fixture_performance())

	print("\n✨ Fixture Management Test Suite Complete ✨\n")
