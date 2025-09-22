Mocking Framework
=================

GDSentry provides a sophisticated mocking framework that allows you to create test doubles for dependencies, stub method calls, and verify interactions between objects. Mocking is essential for writing focused unit tests that isolate the code under test from external dependencies.

Overview
========

Mocking allows you to:

- **Isolate units under test** by replacing real dependencies with controllable test doubles
- **Stub method calls** to return predetermined values or throw exceptions
- **Verify method invocations** to ensure correct interaction patterns
- **Test error conditions** and edge cases that are difficult to reproduce with real objects

The GDSentry mocking framework consists of three main components:

1. **MockObject** - The core mock object that records calls and returns stubbed values
2. **MockStubBuilder** - Fluent API for configuring method stubbing
3. **MockVerifier** - Fluent API for verifying method calls and arguments

Creating Mock Objects
=====================

Basic Mock Creation
-------------------

Create a simple mock object with an optional name:

.. code-block:: gdscript

   extends SceneTreeTest

   func test_user_service_with_mock_database() -> bool:
       # Create a mock database
       var mock_db = create_mock("Database")

       # Use the mock in your test
       var user_service = UserService.new(mock_db)

       # Test the service
       var user = user_service.get_user_by_id(123)
       return assert_not_null(user)

Mock Objects from Classes
-------------------------

Create a mock that behaves like a specific class:

.. code-block:: gdscript

   func test_with_class_mock() -> bool:
       # Create a mock that behaves like a Database class
       var mock_db = create_mock_from_class("Database", "MockDatabase")

       # The mock will respond to common class methods
       assert_equals(mock_db.get_class(), "Database")

       # Test is_class method
       assert_true(mock_db.is_class("Database"))
       assert_false(mock_db.is_class("FileSystem"))

       return true

Partial Mocks
-------------

Create partial mocks that delegate unstubbed methods to real objects:

.. code-block:: gdscript

   func test_partial_mock() -> bool:
       # Create a real database connection
       var real_db = DatabaseConnection.new()
       real_db.connect_to("localhost")

       # Create a partial mock that delegates to the real object
       var mock_db = create_partial_mock(real_db, "PartialDatabase")

       # Stub specific methods
       when(mock_db, "execute_query").then_return([])

       # Unstubbed methods delegate to the real object
       var connected = mock_db.is_connected()  # Calls real method

       return assert_true(connected)

Method Stubbing
===============

Basic Method Stubbing
---------------------

Configure methods to return specific values:

.. code-block:: gdscript

   func test_stubbing_return_values() -> bool:
       var mock_service = create_mock("APIService")

       # Stub method to return a specific value
       when(mock_service, "get_user_data").then_return({"name": "John", "id": 123})

       # Use in test
       var user_data = mock_service.get_user_data()
       assert_equals(user_data.name, "John")
       assert_equals(user_data.id, 123)

       return true

Stubbing with Arguments
-----------------------

Configure different return values based on arguments:

.. code-block:: gdscript

   func test_stubbing_with_arguments() -> bool:
       var mock_calculator = create_mock("Calculator")

       # Stub method with specific arguments
       mock_calculator.when("add").with_args([2, 3]).then_return(5)
       mock_calculator.when("add").with_args([10, 20]).then_return(30)

       # Test different argument combinations
       assert_equals(mock_calculator.add(2, 3), 5)
       assert_equals(mock_calculator.add(10, 20), 30)

       # Unstubbed arguments return default values (null for non-special methods)
       assert_null(mock_calculator.add(1, 1))

       return true

Dynamic Return Values
---------------------

Use callables to compute return values dynamically:

.. code-block:: gdscript

   func test_dynamic_stubbing() -> bool:
       var mock_random = create_mock("RandomGenerator")

       # Return a computed value
       var always_five = func() -> int: return 5
       when(mock_random, "next_int").then_call(always_five)

       # Return a value based on arguments
       var sum_args = func(a: int, b: int) -> int: return a + b
       mock_random.when("combine").with_args([2, 3]).then_call(sum_args)

       assert_equals(mock_random.next_int(), 5)
       assert_equals(mock_random.combine(2, 3), 5)  # 2 + 3

       return true

Default Return Values
---------------------

Mock objects provide intelligent defaults for unstubbed methods:

.. code-block:: gdscript

   func test_default_return_values() -> bool:
       var mock_obj = create_mock("TestObject")

       # Methods starting with "get_" return null
       assert_null(mock_obj.get_user())
       assert_null(mock_obj.get_config())

       # Methods starting with "is_" return false
       assert_false(mock_obj.is_valid())
       assert_false(mock_obj.is_connected())

       # Methods starting with "has_" return false
       assert_false(mock_obj.has_permission())
       assert_false(mock_obj.has_data())

       # Methods starting with "can_" return false
       assert_false(mock_obj.can_save())

       # Methods starting with "count" or "size" return 0
       assert_equals(mock_obj.count_items(), 0)
       assert_equals(mock_obj.get_size(), 0)

       return true

Method Call Verification
========================

Basic Call Verification
-----------------------

Verify that methods were called:

.. code-block:: gdscript

   func test_basic_verification() -> bool:
       var mock_service = create_mock("EmailService")
       var email_sender = EmailSender.new(mock_service)

       # Perform action that should call the mock
       email_sender.send_welcome_email("user@example.com")

       # Verify the method was called
       assert_method_called(mock_service, "send_email")

       return true

Call Count Verification
-----------------------

Verify methods were called specific number of times:

.. code-block:: gdscript

   func test_call_count_verification() -> bool:
       var mock_list = create_mock("ShoppingList")
       var shopping_manager = ShoppingManager.new(mock_list)

       # Add multiple items
       shopping_manager.add_item("apples")
       shopping_manager.add_item("bread")
       shopping_manager.add_item("milk")

       # Verify add_item was called 3 times
       assert_method_called_times(mock_list, "add_item", 3)

       # Verify remove_item was never called
       assert_method_never_called(mock_list, "remove_item")

       return true

Argument Verification
---------------------

Verify methods were called with specific arguments:

.. code-block:: gdscript

   func test_argument_verification() -> bool:
       var mock_printer = create_mock("Printer")
       var document_processor = DocumentProcessor.new(mock_printer)

       # Process a document
       document_processor.print_document("report.pdf", "color")

       # Verify method was called with specific arguments
       assert_method_called_with(mock_printer, "print", ["report.pdf", "color"])

       return true

Advanced Verification Patterns
------------------------------

Using the fluent verification API:

.. code-block:: gdscript

   func test_fluent_verification() -> bool:
       var mock_cache = create_mock("Cache")
       var data_loader = DataLoader.new(mock_cache)

       # Load data (should interact with cache)
       data_loader.load_user_data(123)

       # Fluent verification
       var cache_verifier = verify(mock_cache, "get")

       # Verify call occurred
       assert_true(cache_verifier.was_called())

       # Verify call count
       assert_true(cache_verifier.was_called_times(1))

       # Verify specific arguments
       assert_true(cache_verifier.was_called_with([123]))

       # Alternative assertion methods
       assert_method_called(mock_cache, "get")
       assert_method_called_times(mock_cache, "get", 1)
       assert_method_called_with(mock_cache, "get", [123])

       return true

Multiple Call Verification
--------------------------

Verify patterns across multiple calls:

.. code-block:: gdscript

   func test_multiple_calls() -> bool:
       var mock_logger = create_mock("Logger")
       var batch_processor = BatchProcessor.new(mock_logger)

       # Process batch that logs multiple times
       batch_processor.process_items(["item1", "item2", "item3"])

       # Verify logging occurred for each item
       var log_verifier = verify(mock_logger, "log")

       assert_true(log_verifier.was_called_times(3))

       # Check that specific messages were logged
       assert_true(mock_logger.verify("log").was_called_with(["Processing item1"]))
       assert_true(mock_logger.verify("log").was_called_with(["Processing item2"]))
       assert_true(mock_logger.verify("log").was_called_with(["Processing item3"]))

       return true

Mock Lifecycle Management
=========================

Automatic Cleanup
-----------------

Mocks are automatically tracked and cleaned up:

.. code-block:: gdscript

   func after_each() -> void:
       # Automatically clean up all mocks created in this test
       cleanup_mocks()

Manual Mock Management
----------------------

Explicitly manage mock lifecycles when needed:

.. code-block:: gdscript

   func test_manual_cleanup() -> bool:
       var mock_service = create_mock("APIService")

       # Use mock in test
       var client = APIClient.new(mock_service)
       client.make_request("users")

       # Verify interaction
       assert_method_called(mock_service, "make_request")

       # Manual cleanup if needed
       cleanup_mocks()

       return true

Best Practices
==============

When to Use Mocks
-----------------

**Use mocks when:**
- Testing code that depends on external systems (databases, APIs, file systems)
- Isolating units under test from complex dependencies
- Testing error conditions and edge cases
- Verifying interaction patterns between objects

**Don't use mocks for:**
- Testing simple data transformations
- Testing code with no external dependencies
- Integration tests that need real system behavior

Keeping Tests Focused
---------------------

.. code-block:: gdscript

   # Good: Focused unit test with mocked dependency
   func test_payment_processing() -> bool:
       var mock_gateway = create_mock("PaymentGateway")
       when(mock_gateway, "charge").with_args([100.00]).then_return({"success": true, "transaction_id": "txn_123"})

       var payment_service = PaymentService.new(mock_gateway)
       var result = payment_service.process_payment(100.00, "card_456")

       assert_true(result.success)
       assert_method_called_with(mock_gateway, "charge", [100.00])

       return true

   # Bad: Over-mocking simple logic
   func test_simple_calculation() -> bool:
       var mock_math = create_mock("MathUtils")  # Unnecessary complexity
       when(mock_math, "add").then_return(5)

       var calculator = Calculator.new(mock_math)
       var result = calculator.add(2, 3)  # Should just test the real method

       return assert_equals(result, 5)

Mock Naming Conventions
-----------------------

Use descriptive names for better test readability:

.. code-block:: gdscript

   # Good: Descriptive mock names
   var mock_user_repository = create_mock("UserRepository")
   var mock_payment_processor = create_mock("PaymentProcessor")
   var mock_email_service = create_mock("EmailService")

   # Avoid: Generic names
   var mock1 = create_mock("Mock1")
   var m = create_mock()

Verifying Important Interactions
--------------------------------

Focus verification on important behavioral contracts:

.. code-block:: gdscript

   func test_order_processing_workflow() -> bool:
       var mock_inventory = create_mock("InventoryService")
       var mock_payment = create_mock("PaymentService")
       var mock_notification = create_mock("NotificationService")

       # Setup reasonable defaults
       when(mock_inventory, "check_stock").then_return(true)
       when(mock_payment, "process").then_return({"success": true})
       when(mock_notification, "send").then_return(true)

       # Execute workflow
       var order_processor = OrderProcessor.new(mock_inventory, mock_payment, mock_notification)
       var result = order_processor.process_order(order_data)

       # Verify critical business rules
       assert_true(result.success)

       # Verify important interactions occurred
       assert_method_called(mock_inventory, "check_stock")      # Stock was checked
       assert_method_called(mock_payment, "process")            # Payment was processed
       assert_method_called(mock_notification, "send")          # Confirmation was sent

       # Don't verify implementation details
       # assert_method_called_times(mock_inventory, "update_stock", 1)  # Too specific

       return true

Advanced Mocking Patterns
=========================

Spy Pattern
-----------

Create spies that wrap real objects while tracking calls:

.. code-block:: gdscript

   func test_spy_pattern() -> bool:
       # Create a real logger
       var real_logger = ConsoleLogger.new()

       # Create a spy that wraps the real logger
       var spy_logger = create_partial_mock(real_logger, "SpyLogger")

       # Use in application
       var app = Application.new(spy_logger)
       app.start()

       # Verify logging calls were made
       assert_method_called(spy_logger, "log")
       assert_method_called_times(spy_logger, "info", 2)

       return true

Mock Chains and Dependencies
----------------------------

Mock complex object relationships:

.. code-block:: gdscript

   func test_mock_dependencies() -> bool:
       # Create mock database
       var mock_db = create_mock("Database")
       when(mock_db, "connect").then_return(true)
       when(mock_db, "query").then_return([{"id": 1, "name": "John"}])

       # Create mock cache that depends on database
       var mock_cache = create_mock("Cache")
       mock_cache.when("get").with_args(["user_1"]).then_call(func():
           return mock_db.query("SELECT * FROM users WHERE id = 1")
       )

       # Create service with mocked dependencies
       var user_service = UserService.new(mock_db, mock_cache)

       # Test the service
       var user = user_service.get_user(1)

       # Verify interactions
       assert_method_called(mock_cache, "get")
       assert_method_called(mock_db, "query")

       return assert_not_null(user)

Exception Stubbing
------------------

Configure mocks to throw exceptions:

.. code-block:: gdscript

   func test_exception_handling() -> bool:
       var mock_network = create_mock("NetworkClient")

       # Configure mock to throw exception
       var network_error = func() -> void:
           push_error("Network connection failed")
           return null
       when(mock_network, "send_request").then_call(network_error)

       var api_client = APIClient.new(mock_network)

       # Test error handling
       var success = api_client.make_api_call("users")

       assert_false(success)
       assert_method_called(mock_network, "send_request")

       return true

Sequential Call Stubbing
------------------------

Configure different responses for sequential calls:

.. code-block:: gdscript

   func test_sequential_calls() -> bool:
       var mock_queue = create_mock("MessageQueue")

       # First call returns success, second returns failure
       var call_count = 0
       var sequential_response = func() -> Dictionary:
           call_count += 1
           if call_count == 1:
               return {"success": true, "message": "Message sent"}
           else:
               return {"success": false, "error": "Queue full"}

       when(mock_queue, "send_message").then_call(sequential_response)

       var messenger = Messenger.new(mock_queue)

       # First message succeeds
       var result1 = messenger.send_message("Hello")
       assert_true(result1.success)

       # Second message fails
       var result2 = messenger.send_message("World")
       assert_false(result2.success)

       return true

Mock Verification Helpers
=========================

GDSentry provides helper methods for common verification patterns:

.. code-block:: gdscript

   # Basic verification helpers
   assert_method_called(mock, "method_name")
   assert_method_never_called(mock, "method_name")
   assert_method_called_times(mock, "method_name", expected_count)
   assert_method_called_with(mock, "method_name", expected_args)

   # Fluent API
   verify(mock, "method_name").was_called()
   verify(mock, "method_name").was_called_times(2)
   verify(mock, "method_name").was_called_with([arg1, arg2])
   verify(mock, "method_name").was_never_called()

Troubleshooting
===============

Common Mocking Issues
---------------------

**Mock not recording calls:**
- Ensure the mock is properly injected into the system under test
- Verify the method name matches exactly (case-sensitive)
- Check that the mock is not being replaced by a real object

**Stubbing not working:**
- Verify method name and arguments match exactly
- Check argument order in ``with_args()``
- Ensure stubbing occurs before the method call

**Verification failing unexpectedly:**
- Check that the mock is the same instance used in the test
- Verify method names match exactly
- Ensure test cleanup doesn't interfere with verification

**Memory leaks with mocks:**
- Always call ``cleanup_mocks()`` in ``after_each()``
- Avoid storing mock references in global variables
- Use ``create_mock()`` instead of manual MockObject construction

Debugging Mock Interactions
---------------------------

Enable verbose mock logging for debugging:

.. code-block:: gdscript

   func test_with_debugging() -> bool:
       var mock_service = create_mock("DebugService")

       # Enable detailed logging (if supported)
       mock_service._debug_mode = true

       # Use in test...
       var client = Client.new(mock_service)
       client.do_something()

       # Check call history
       var calls = mock_service.get_calls("do_something")
       print("Method calls: ", calls)

       return assert_method_called(mock_service, "do_something")

.. seealso::
   :doc:`../api/test-classes`
      Base test classes that support mocking functionality.

   :doc:`../api/assertions`
      Assertion methods for verifying mock interactions.

   :doc:`../advanced/fixtures`
      Alternative approach to test data management.

   :doc:`../user-guide`
      Best practices for when and how to use mocking effectively.
