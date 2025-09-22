# GDSentry - Mocking Utilities Demonstration
# Demonstrates the enterprise mocking capabilities of GDSentry
#
# Features demonstrated:
# - Mock object creation and configuration
# - Method call stubbing with return values
# - Method call verification and counting
# - Argument matching for stubs and verifications
# - Mock lifecycle management
# - Integration with existing assertion methods
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name MockingDemoTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Demonstrate enterprise mocking capabilities"
	test_tags = ["mocking", "enterprise", "verification", "stubbing", "isolation"]
	test_priority = "high"
	test_category = "base_classes"

# ------------------------------------------------------------------------------
# DEMO CLASSES FOR MOCKING
# ------------------------------------------------------------------------------
class UserService:
	var database: Object = null

	func _init(db: Object):
		database = db

	func get_user_count() -> int:
		return database.get_user_count()

	func create_user(username: String, email: String) -> bool:
		return database.create_user(username, email)

	func delete_user(user_id: int) -> bool:
		return database.delete_user(user_id)

	func get_user_by_id(user_id: int) -> Dictionary:
		return database.get_user_by_id(user_id)

	func is_user_active(user_id: int) -> bool:
		return database.is_user_active(user_id)

	func update_user_email(user_id: int, new_email: String) -> bool:
		return database.update_user_email(user_id, new_email)

class EmailService:
	func send_welcome_email(email: String, username: String) -> bool:
		print("Sending welcome email to %s (%s)" % [email, username])
		return true

	func send_password_reset(email: String) -> bool:
		print("Sending password reset to %s" % email)
		return true

	func validate_email(email: String) -> bool:
		return email.contains("@") and email.contains(".")

# ------------------------------------------------------------------------------
# BASIC MOCKING TESTS
# ------------------------------------------------------------------------------
func test_basic_mock_creation() -> bool:
	"""Test basic mock object creation and usage"""
	print("🧪 Testing basic mock creation...")

	var success = true

	# Create a basic mock
	var mock_db = create_mock("DatabaseMock")
	success = success and assert_not_null(mock_db, "Mock should be created successfully")
	success = success and assert_equals(mock_db._mock_name, "DatabaseMock", "Mock should have correct name")

	# Test default return values
	var user_count = mock_db._call_method("get_user_count", [])
	success = success and assert_equals(user_count, 0, "Default return for count method should be 0")

	var has_users = mock_db._call_method("has_users", [])
	success = success and assert_false(has_users, "Default return for has_ method should be false")

	var user_data = mock_db._call_method("get_user_data", [])
	success = success and assert_null(user_data, "Default return for get_ method should be null")

	if success:
		print("✅ Basic mock creation test passed")
	else:
		print("❌ Basic mock creation test failed")

	return success

func test_mock_stubbing() -> bool:
	"""Test method stubbing with return values"""
	print("🧪 Testing mock stubbing...")

	var success = true

	var mock_db = create_mock("StubbedDatabase")

	# Stub methods with return values
	mock_db.when("get_user_count").then_return(42)
	mock_db.when("is_connected").then_return(true)
	mock_db.when("get_user_by_id").with_args([123]).then_return({"id": 123, "name": "John"})
	mock_db.when("create_user").then_call(func(): print("User creation called!"); return true)

	# Test stubbed methods
	var count = mock_db._call_method("get_user_count", [])
	success = success and assert_equals(count, 42, "Stubbed method should return configured value")

	var connected = mock_db._call_method("is_connected", [])
	success = success and assert_true(connected, "Stubbed boolean method should return true")

	var user = mock_db._call_method("get_user_by_id", [123])
	success = success and assert_equals(user.id, 123, "Stubbed method with args should return correct value")
	success = success and assert_equals(user.name, "John", "Stubbed method should return complete object")

	# Test unstubbed method (should use defaults)
	var unknown_method = mock_db._call_method("unknown_method", [])
	success = success and assert_null(unknown_method, "Unstubbed method should return default null")

	if success:
		print("✅ Mock stubbing test passed")
	else:
		print("❌ Mock stubbing test failed")

	return success

func test_mock_verification() -> bool:
	"""Test method call verification"""
	print("🧪 Testing mock verification...")

	var success = true

	var mock_db = create_mock("VerificationDatabase")

	# Call methods to create call history
	mock_db._call_method("get_user_count", [])
	mock_db._call_method("get_user_by_id", [456])
	mock_db._call_method("get_user_by_id", [789])
	mock_db._call_method("create_user", ["john", "john@example.com"])

	# Test verification methods
	var verifier = mock_db.verify("get_user_count")
	success = success and assert_true(verifier.was_called(), "get_user_count should have been called")
	success = success and assert_true(verifier.was_called_times(1), "get_user_count should be called once")

	var user_verifier = mock_db.verify("get_user_by_id")
	success = success and assert_true(user_verifier.was_called_times(2), "get_user_by_id should be called twice")
	success = success and assert_true(user_verifier.was_called_with([456]), "get_user_by_id should be called with 456")
	success = success and assert_true(user_verifier.was_called_with([789]), "get_user_by_id should be called with 789")

	var create_verifier = mock_db.verify("create_user")
	success = success and assert_true(create_verifier.was_called_with(["john", "john@example.com"]), "create_user should be called with correct args")

	# Test never called
	var delete_verifier = mock_db.verify("delete_user")
	success = success and assert_true(delete_verifier.was_never_called(), "delete_user should never be called")

	if success:
		print("✅ Mock verification test passed")
	else:
		print("❌ Mock verification test failed")

	return success

func test_mock_assertion_extensions() -> bool:
	"""Test mock-specific assertion methods"""
	print("🧪 Testing mock assertion extensions...")

	var success = true

	var mock_service = create_mock("AssertionService")

	# Make some method calls
	mock_service._call_method("process_data", [])
	mock_service._call_method("process_data", [])
	mock_service._call_method("validate_input", ["test"])

	# Test assertion methods
	success = success and assert_method_called(mock_service, "process_data", "process_data should be called")
	success = success and assert_method_called_times(mock_service, "process_data", 2, "process_data should be called twice")
	success = success and assert_method_called_with(mock_service, "validate_input", ["test"], "validate_input should be called with test")
	success = success and assert_method_never_called(mock_service, "cleanup", "cleanup should never be called")

	if success:
		print("✅ Mock assertion extensions test passed")
	else:
		print("❌ Mock assertion extensions test failed")

	return success

# ------------------------------------------------------------------------------
# ADVANCED MOCKING SCENARIOS
# ------------------------------------------------------------------------------
func test_dependency_injection_with_mocks() -> bool:
	"""Test dependency injection using mocks"""
	print("🧪 Testing dependency injection with mocks...")

	var success = true

	# Create mock database
	var mock_db = create_mock("DependencyDatabase")
	mock_db.when("get_user_count").then_return(5)
	mock_db.when("create_user").then_return(true)
	mock_db.when("get_user_by_id").with_args([1]).then_return({"id": 1, "name": "Alice"})

	# Create real service with mock dependency
	var user_service = UserService.new(mock_db)

	# Test the service using the mock
	var count = user_service.get_user_count()
	success = success and assert_equals(count, 5, "Service should use mock database count")

	var created = user_service.create_user("Bob", "bob@example.com")
	success = success and assert_true(created, "Service should use mock database creation")

	var user = user_service.get_user_by_id(1)
	success = success and assert_equals(user.name, "Alice", "Service should use mock database user data")

	# Verify that the mock was called correctly
	var db_verifier = mock_db.verify("get_user_count")
	success = success and assert_true(db_verifier.was_called(), "Database get_user_count should be called")

	if success:
		print("✅ Dependency injection test passed")
	else:
		print("❌ Dependency injection test failed")

	return success

func test_partial_mock() -> bool:
	"""Test partial mocking capabilities"""
	print("🧪 Testing partial mock capabilities...")

	var success = true

	# Create a real email service
	var real_email_service = EmailService.new()

	# Create a partial mock that delegates unstubbed calls to real object
	var mock_email_service = create_partial_mock(real_email_service, "PartialEmailService")

	# Stub only the send_welcome_email method
	mock_email_service.when("send_welcome_email").then_return(false)

	# Test stubbed method
	var welcome_result = mock_email_service._call_method("send_welcome_email", ["test@example.com", "TestUser"])
	success = success and assert_false(welcome_result, "Stubbed method should return false")

	# Test unstubbed method (should delegate to real object)
	var reset_result = mock_email_service._call_method("send_password_reset", ["test@example.com"])
	success = success and assert_true(reset_result, "Unstubbed method should delegate to real object")

	var validation_result = mock_email_service._call_method("validate_email", ["test@example.com"])
	success = success and assert_false(validation_result, "Email validation should work through delegation")

	if success:
		print("✅ Partial mock test passed")
	else:
		print("❌ Partial mock test failed")

	return success

func test_mock_from_class() -> bool:
	"""Test creating mocks that behave like specific classes"""
	print("🧪 Testing mock from class creation...")

	var success = true

	# Create a mock that behaves like a Node
	var mock_node = create_mock_from_class("Node", "MockNode")

	# Test that it has class-like behavior
	var class_name_result = mock_node._call_method("get_class", [])
	var success1 = assert_equals(class_name_result, "Node", "Mock should return correct class name")
	success = success and success1

	var is_node = mock_node._call_method("is_class", ["Node"])
	success = success and assert_true(is_node, "Mock should behave like Node class")

	# Test default behaviors for common methods
	var visible = mock_node._call_method("is_visible", [])
	success = success and assert_null(visible, "Default is_ method should return null")

	var child_count = mock_node._call_method("get_child_count", [])
	success = success and assert_equals(child_count, 0, "Default count method should return 0")

	if success:
		print("✅ Mock from class test passed")
	else:
		print("❌ Mock from class test failed")

	return success

# ------------------------------------------------------------------------------
# MOCK LIFECYCLE AND MANAGEMENT
# ------------------------------------------------------------------------------
func test_mock_lifecycle() -> bool:
	"""Test mock lifecycle management"""
	print("🧪 Testing mock lifecycle management...")

	var success = true

	var mock1 = create_mock("LifecycleMock1")
	var mock2 = create_mock("LifecycleMock2")

	# Make some calls
	mock1._call_method("test_method", [])
	mock2._call_method("another_method", [])

	# Verify calls exist
	var calls1 = mock1.get_call_history()
	var calls2 = mock2.get_call_history()
	success = success and assert_equals(calls1.size(), 1, "First mock should have 1 call")
	success = success and assert_equals(calls2.size(), 1, "Second mock should have 1 call")

	# Reset individual mock
	mock1.reset()
	var calls1_after_reset = mock1.get_call_history()
	success = success and assert_equals(calls1_after_reset.size(), 0, "Mock should be empty after reset")

	# Calls on second mock should still exist
	var calls2_after_reset = mock2.get_call_history()
	success = success and assert_equals(calls2_after_reset.size(), 1, "Second mock should retain calls after first mock reset")

	# Cleanup all mocks
	cleanup_mocks()

	if success:
		print("✅ Mock lifecycle test passed")
	else:
		print("❌ Mock lifecycle test failed")

	return success

func test_complex_stubbing_scenarios() -> bool:
	"""Test complex stubbing scenarios"""
	print("🧪 Testing complex stubbing scenarios...")

	var success = true

	var mock_service = create_mock("ComplexService")

	# Multiple stubs for same method with different args
	mock_service.when("process").with_args(["data1"]).then_return("result1")
	mock_service.when("process").with_args(["data2"]).then_return("result2")
	mock_service.when("process").then_return("default_result")  # Fallback for other args

	# Test specific argument matching
	var result1 = mock_service._call_method("process", ["data1"])
	success = success and assert_equals(result1, "result1", "Should return result1 for data1")

	var result2 = mock_service._call_method("process", ["data2"])
	success = success and assert_equals(result2, "result2", "Should return result2 for data2")

	var default_result = mock_service._call_method("process", ["other_data"])
	success = success and assert_equals(default_result, "default_result", "Should return default for unmatched args")

	# Test callable stubbing
	mock_service.when("calculate").then_call(func(): return 42 * 2)

	var calc_result = mock_service._call_method("calculate", [])
	success = success and assert_equals(calc_result, 84, "Callable stub should execute and return result")

	if success:
		print("✅ Complex stubbing test passed")
	else:
		print("❌ Complex stubbing test failed")

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE TEST
# ------------------------------------------------------------------------------
func test_mock_performance() -> bool:
	"""Test mock performance and efficiency"""
	print("🧪 Testing mock performance...")

	var success = true

	var mock = create_mock("PerformanceMock")

	# Measure time for many mock calls
	var start_time = Time.get_time_dict_from_system()

	const NUM_CALLS = 1000
	for i in range(NUM_CALLS):
		mock._call_method("test_method", [i])

	var end_time = Time.get_time_dict_from_system()
	var elapsed = Time.get_unix_time_from_datetime_dict(end_time) - Time.get_unix_time_from_datetime_dict(start_time)

	# Verify all calls were recorded
	var call_count = mock.get_call_count("test_method")
	success = success and assert_equals(call_count, NUM_CALLS, "All calls should be recorded")

	# Performance should be reasonable (less than 0.1 seconds for 1000 calls)
	success = success and assert_less_than(elapsed, 0.1, "Mock performance should be reasonable")

	if success:
		print("✅ Mock performance test passed (%.4fs for %d calls)" % [elapsed, NUM_CALLS])
	else:
		print("❌ Mock performance test failed")

	return success

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	print("\n🚀 Running Mocking Utilities Test Suite\n")

	run_test("test_basic_mock_creation", func(): return test_basic_mock_creation())
	run_test("test_mock_stubbing", func(): return test_mock_stubbing())
	run_test("test_mock_verification", func(): return test_mock_verification())
	run_test("test_mock_assertion_extensions", func(): return test_mock_assertion_extensions())
	run_test("test_dependency_injection_with_mocks", func(): return test_dependency_injection_with_mocks())
	run_test("test_partial_mock", func(): return test_partial_mock())
	run_test("test_mock_from_class", func(): return test_mock_from_class())
	run_test("test_mock_lifecycle", func(): return test_mock_lifecycle())
	run_test("test_complex_stubbing_scenarios", func(): return test_complex_stubbing_scenarios())
	run_test("test_mock_performance", func(): return test_mock_performance())

	print("\n✨ Mocking Utilities Test Suite Complete ✨\n")
