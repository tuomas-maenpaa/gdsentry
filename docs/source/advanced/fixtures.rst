Test Fixtures
=============

Test fixtures provide a powerful dependency management system for GDSentry tests, allowing you to define reusable test data and resources that are automatically initialized, shared between tests, and cleaned up when no longer needed. Fixtures help maintain test isolation while reducing code duplication.

Overview
========

Fixtures solve common testing challenges:

- **Shared test data** that needs to be initialized once and reused
- **Complex object graphs** with interdependent components
- **Resource management** (databases, connections, temporary files)
- **Test isolation** while maintaining performance
- **Dependency resolution** for complex test setups

The GDSentry fixture system provides:

- **Automatic dependency resolution** - Fixtures can depend on other fixtures
- **Lazy initialization** - Fixtures are created only when needed
- **Automatic cleanup** - Resources are properly disposed of after tests
- **Circular dependency detection** - Prevents infinite loops
- **State management** - Track fixture lifecycle and handle failures gracefully

Basic Fixture Usage
===================

Registering Fixtures
--------------------

Create a fixture with a factory method:

.. code-block:: gdscript

   extends SceneTreeTest

   func before_all() -> void:
       # Register a simple fixture
       register_fixture("database", func(): return create_test_database())

   func create_test_database() -> TestDatabase:
       var db = TestDatabase.new()
       db.connect("memory")  # In-memory database
       db.initialize_schema()
       return db

   func test_user_creation() -> bool:
       # Access the fixture
       var db = get_fixture("database")

       # Use in test
       var user_id = db.create_user("john@example.com", "John Doe")
       var user = db.get_user(user_id)

       return assert_equals(user.email, "john@example.com")

Fixture Dependencies
====================

Creating Dependent Fixtures
---------------------------

Fixtures can depend on other fixtures:

.. code-block:: gdscript

   func before_all() -> void:
       # Base fixture
       register_fixture("database", func(): return create_test_database())

       # Fixture that depends on database
       register_fixture("user_service", func(): return create_user_service(), ["database"])

       # Fixture that depends on user_service
       register_fixture("api_client", func(): return create_api_client(), ["user_service"])

   func create_user_service() -> UserService:
       var db = get_fixture("database")  # Access dependency
       return UserService.new(db)

   func create_api_client() -> APIClient:
       var user_service = get_fixture("user_service")  # Access dependency
       return APIClient.new(user_service)

Automatic Resolution
--------------------

Dependencies are resolved automatically:

.. code-block:: gdscript

   func test_api_workflow() -> bool:
       # Accessing api_client automatically initializes:
       # 1. database (base dependency)
       # 2. user_service (depends on database)
       # 3. api_client (depends on user_service)
       var api = get_fixture("api_client")

       # All dependencies are ready to use
       var user = api.create_user("test@example.com")
       var profile = api.get_user_profile(user.id)

       return assert_not_null(profile)

Complex Dependency Chains
-------------------------

Handle complex dependency relationships:

.. code-block:: gdscript

   func before_all() -> void:
       # Infrastructure layer
       register_fixture("database", func(): return create_database())
       register_fixture("cache", func(): return create_cache())
       register_fixture("message_queue", func(): return create_message_queue())

       # Service layer
       register_fixture("user_repository", func(): return create_user_repository(),
                       ["database", "cache"])
       register_fixture("notification_service", func(): return create_notification_service(),
                       ["message_queue"])

       # Application layer
       register_fixture("user_service", func(): return create_user_service(),
                       ["user_repository", "notification_service"])
       register_fixture("payment_service", func(): return create_payment_service(),
                       ["database", "message_queue"])

       # API layer
       register_fixture("user_api", func(): return create_user_api(),
                       ["user_service"])
       register_fixture("payment_api", func(): return create_payment_api(),
                       ["payment_service"])

Fixture Lifecycle
=================

Initialization States
---------------------

Fixtures progress through well-defined states:

.. code-block:: text

   UNINITIALIZED → INITIALIZING → READY → CLEANING_UP → CLEANED_UP
                         ↓
                      FAILED

- **UNINITIALIZED**: Fixture registered but not yet created
- **INITIALIZING**: Factory method is being called
- **READY**: Fixture successfully created and available
- **FAILED**: Initialization failed (dependencies missing, factory error)
- **CLEANING_UP**: Cleanup methods are being executed
- **CLEANED_UP**: Fixture properly disposed

Lazy Initialization
-------------------

Fixtures are created only when first accessed:

.. code-block:: gdscript

   func before_all() -> void:
       register_fixture("expensive_resource", func(): return create_expensive_resource())

   func test_that_does_not_need_resource() -> bool:
       # expensive_resource is not created yet
       return assert_true(true)

   func test_that_needs_resource() -> bool:
       # Now expensive_resource gets initialized
       var resource = get_fixture("expensive_resource")
       return assert_not_null(resource)

Automatic Cleanup
-----------------

Fixtures are automatically cleaned up after test suites:

.. code-block:: gdscript

   func after_all() -> void:
       # cleanup_all_fixtures() is called automatically
       # All registered fixtures are cleaned up in reverse dependency order
       pass

Custom Cleanup Methods
======================

Cleanup Configuration
---------------------

Specify cleanup methods when registering fixtures:

.. code-block:: gdscript

   func before_all() -> void:
       register_fixture("temp_files", func(): return create_temp_files(),
                       [], ["cleanup_temp_files"])

   func create_temp_files() -> TempFileManager:
       var manager = TempFileManager.new()
       manager.create_temp_file("test1.txt", "content1")
       manager.create_temp_file("test2.txt", "content2")
       return manager

Database Cleanup
----------------

Clean up database state between tests:

.. code-block:: gdscript

   func before_all() -> void:
       register_fixture("test_db", func(): return create_test_database(),
                       [], ["reset_tables", "close_connection"])

   func create_test_database() -> TestDatabase:
       var db = TestDatabase.new()
       db.connect("test.db")
       db.create_tables()
       return db

   func test_database_operations() -> bool:
       var db = get_fixture("test_db")

       # Perform test operations
       db.insert_user({"name": "Alice", "email": "alice@test.com"})
       var users = db.get_all_users()

       assert_equals(users.size(), 1)
       assert_equals(users[0].name, "Alice")

       return true

   # cleanup_all_fixtures() will automatically call:
   # db.reset_tables() and db.close_connection()

File System Cleanup
-------------------

Clean up temporary files and directories:

.. code-block:: gdscript

   func before_all() -> void:
       register_fixture("temp_dir", func(): return create_temp_directory(),
                       [], ["remove_temp_directory"])

   func create_temp_directory() -> TempDirectory:
       var temp_dir = TempDirectory.new()
       temp_dir.create("test_project")
       temp_dir.write_file("config.ini", "[settings]\nkey=value")
       return temp_dir

   func test_file_operations() -> bool:
       var temp_dir = get_fixture("temp_dir")

       # Test file operations
       var config_content = temp_dir.read_file("config.ini")
       assert_true(config_content.contains("key=value"))

       # Create additional test files
       temp_dir.write_file("test.txt", "test content")

       return true

   # cleanup_all_fixtures() will call temp_dir.remove_temp_directory()

Manual Fixture Management
=========================

Manual Cleanup
--------------

Clean up specific fixtures when needed:

.. code-block:: gdscript

   func test_with_manual_cleanup() -> bool:
       # Setup
       var db = get_fixture("database")

       # Perform test
       db.insert_test_data()
       var result = db.perform_query()

       # Manual cleanup if needed
       cleanup_fixture("database")

       return assert_not_null(result)

Fixture Reset
-------------

Reset fixtures without full cleanup:

.. code-block:: gdscript

   func test_with_reset() -> bool:
       var db = get_fixture("database")

       # Modify database state
       db.insert_user("test@example.com")

       # Reset fixture (cleans up and marks as uninitialized)
       reset_fixture("database")

       # Next access will re-initialize the fixture
       var fresh_db = get_fixture("database")
       var users = fresh_db.get_all_users()

       return assert_equals(users.size(), 0)  # Fresh database

Advanced Patterns
=================

Fixture Inheritance
-------------------

Create base fixtures that can be extended:

.. code-block:: gdscript

   class BaseTest extends SceneTreeTest:

       func before_all() -> void:
           # Base fixtures available to all tests
           register_fixture("config", func(): return load_base_config())

       func load_base_config() -> Config:
           var config = Config.new()
           config.load("res://config/base.cfg")
           return config

   class APITest extends BaseTest:

       func before_all() -> void:
           super.before_all()  # Get base fixtures

           # Add API-specific fixtures
           register_fixture("api_server", func(): return create_api_server(),
                           ["config"])

Shared Fixtures Across Test Classes
-----------------------------------

Use static fixtures that persist across test classes:

.. code-block:: gdscript

   # Global fixture registry (in a singleton or autoload)
   class FixtureRegistry:
       static var fixtures = {}

       static func register_global_fixture(name: String, factory: Callable) -> void:
           fixtures[name] = factory

       static func get_global_fixture(name: String) -> Object:
           if fixtures.has(name):
               return fixtures[name].call()
           return null

   # In test classes
   class DatabaseTest extends SceneTreeTest:

       func before_all() -> void:
           if not FixtureRegistry.fixtures.has("shared_db"):
               FixtureRegistry.register_global_fixture("shared_db",
                   func(): return create_shared_database())

       func test_database_connection() -> bool:
           var db = FixtureRegistry.get_global_fixture("shared_db")
           return assert_true(db.is_connected())

Conditional Fixtures
--------------------

Create fixtures based on test conditions:

.. code-block:: gdscript

   func before_all() -> void:
       # Always available
       register_fixture("basic_config", func(): return load_config("basic"))

       # Conditional fixtures
       if OS.get_name() == "Windows":
           register_fixture("windows_service", func(): return create_windows_service(),
                           ["basic_config"])
       elif OS.get_name() == "Linux":
           register_fixture("linux_service", func(): return create_linux_service(),
                           ["basic_config"])

   func test_cross_platform() -> bool:
       var config = get_fixture("basic_config")

       # Use platform-specific service if available
       var service = get_fixture(OS.get_name().to_lower() + "_service")
       if service:
           return assert_true(service.is_available())
       else:
           return assert_true(true)  # Skip on unsupported platforms

Fixture Factories with Parameters
---------------------------------

Create parameterized fixtures:

.. code-block:: gdscript

   func before_all() -> void:
       # Factory that creates different database configurations
       register_fixture("dev_db", func(): return create_database("dev"))
       register_fixture("test_db", func(): return create_database("test"))
       register_fixture("prod_db", func(): return create_database("prod"))

   func create_database(environment: String) -> Database:
       var db = Database.new()
       match environment:
           "dev":
               db.connect("dev.db")
               db.enable_debug_logging()
           "test":
               db.connect(":memory:")  # In-memory for tests
           "prod":
               db.connect("prod.db")
               db.enable_connection_pooling()
       return db

   func test_multiple_environments() -> bool:
       var dev_db = get_fixture("dev_db")
       var test_db = get_fixture("test_db")

       # Test different configurations
       assert_true(dev_db.has_debug_logging())
       assert_false(test_db.has_debug_logging())

       return true

Error Handling and Recovery
===========================

Handling Fixture Failures
-------------------------

Gracefully handle fixture initialization failures:

.. code-block:: gdscript

   func test_with_fixture_error_handling() -> bool:
       var db = get_fixture("database")

       if not db:
           push_error("Database fixture failed to initialize")
           return false

       # Continue with test
       return assert_true(db.is_connected())

Fixture Validation
------------------

Validate fixture state before use:

.. code-block:: gdscript

   func validate_fixture(fixture_name: String) -> bool:
       var fixture = get_fixture(fixture_name)
       if not fixture:
           return false

       # Validate fixture is in expected state
       if fixture.has_method("is_ready"):
           return fixture.is_ready()
       elif fixture.has_method("ping"):
           return fixture.ping()

       return true

   func test_with_validation() -> bool:
       if not validate_fixture("network_service"):
           skip_test("Network service not available")
           return true

       var service = get_fixture("network_service")
       return assert_true(service.make_request())

Circular Dependency Detection
-----------------------------

The fixture system automatically detects circular dependencies:

.. code-block:: gdscript

   func before_all() -> void:
       # This would cause a circular dependency error:
       register_fixture("a", func(): return A.new(), ["c"])  # A depends on C
       register_fixture("b", func(): return B.new(), ["a"])  # B depends on A
       register_fixture("c", func(): return C.new(), ["b"])  # C depends on B

       # Result: Error when accessing any fixture due to circular dependency

Best Practices
==============

Fixture Naming Conventions
--------------------------

Use clear, descriptive fixture names:

.. code-block:: gdscript

   # Good: Descriptive names
   register_fixture("user_database", ...)
   register_fixture("payment_service", ...)
   register_fixture("email_notification_service", ...)

   # Avoid: Generic names
   register_fixture("db", ...)
   register_fixture("service", ...)
   register_fixture("fixture1", ...)

Fixture Granularity
-------------------

Choose appropriate fixture granularity:

.. code-block:: gdscript

   # Good: Focused fixtures
   register_fixture("user_repository", ...)
   register_fixture("product_repository", ...)
   register_fixture("order_service", ...)

   # Avoid: Monolithic fixtures
   register_fixture("entire_application", ...)  # Too broad

   # Avoid: Micro-fixtures
   register_fixture("user_name_validator", ...)
   register_fixture("email_format_checker", ...)  # Too granular

Fixture Isolation
-----------------

Ensure fixtures don't interfere with each other:

.. code-block:: gdscript

   func before_each() -> void:
       # Reset shared fixtures between tests
       reset_fixture("user_database")

   func test_user_creation() -> bool:
       var db = get_fixture("user_database")
       db.create_user("alice@example.com")
       return assert_equals(db.count_users(), 1)

   func test_user_deletion() -> bool:
       var db = get_fixture("user_database")  # Fresh state
       db.create_user("bob@example.com")
       db.delete_user("bob@example.com")
       return assert_equals(db.count_users(), 0)

Performance Considerations
--------------------------

Optimize fixture usage for performance:

.. code-block:: gdscript

   # Use lazy initialization for expensive fixtures
   register_fixture("slow_api_client", func(): return create_slow_api_client())

   # Group fast fixtures together
   func before_all() -> void:
       register_fixture("config", func(): return load_config())        # Fast
       register_fixture("validator", func(): return create_validator()) # Fast
       register_fixture("database", func(): return create_database())   # Slow

   # Use in tests efficiently
   func test_validation() -> bool:
       var validator = get_fixture("validator")  # Only creates if needed
       return assert_true(validator.is_valid("test@example.com"))

   func test_database_query() -> bool:
       var db = get_fixture("database")  # Expensive, but shared
       var result = db.query("SELECT * FROM users")
       return assert_not_null(result)

Fixture Documentation
---------------------

Document fixture purposes and dependencies:

.. code-block:: gdscript

   func before_all() -> void:
       # Database fixture: Provides isolated test database
       # Dependencies: None
       # Cleanup: Automatically drops all tables and closes connections
       register_fixture("test_database", func(): return create_isolated_database(),
                       [], ["drop_tables", "close_connection"])

       # API client fixture: Provides configured HTTP client for testing
       # Dependencies: config (for API endpoints and timeouts)
       # Cleanup: Automatically cancels pending requests
       register_fixture("api_client", func(): return create_api_client(),
                       ["config"], ["cancel_requests"])

Testing Fixture Behavior
========================

Testing Fixture Creation
------------------------

Test that fixtures are created correctly:

.. code-block:: gdscript

   func test_fixture_creation() -> bool:
       register_fixture("test_service", func(): return TestService.new())

       var service = get_fixture("test_service")

       assert_not_null(service)
       assert_true(service is TestService)
       assert_true(service.is_ready())

       return true

Testing Fixture Dependencies
----------------------------

Verify dependency resolution works:

.. code-block:: gdscript

   func test_fixture_dependencies() -> bool:
       register_fixture("base_service", func(): return BaseService.new())
       register_fixture("dependent_service", func(): return DependentService.new(),
                       ["base_service"])

       var dependent = get_fixture("dependent_service")

       # dependent_service should have automatically initialized base_service
       var base = get_fixture("base_service")

       assert_not_null(dependent)
       assert_not_null(base)
       assert_true(dependent.has_base_service())

       return true

Testing Fixture Cleanup
-----------------------

Verify fixtures are cleaned up properly:

.. code-block:: gdscript

   func test_fixture_cleanup() -> bool:
       var temp_dir_path = ""

       register_fixture("temp_directory", func():
           var temp_dir = TempDirectory.new()
           temp_dir_path = temp_dir.create()
           temp_dir.write_file("test.txt", "content")
           return temp_dir
       , [], ["delete_directory"])

       # Create and use fixture
       var temp_dir = get_fixture("temp_directory")
       assert_true(FileAccess.file_exists(temp_dir_path + "/test.txt"))

       # Cleanup should remove files
       cleanup_all_fixtures()

       # Verify cleanup worked
       return assert_false(DirAccess.dir_exists_absolute(temp_dir_path))

Troubleshooting
===============

Common Fixture Issues
---------------------

**Fixture not found:**
- Check fixture name spelling (case-sensitive)
- Ensure fixture is registered before accessing
- Verify fixture registration succeeded

**Circular dependency error:**
- Review dependency chains
- Remove circular references
- Consider restructuring fixtures

**Fixture initialization failure:**
- Check factory method returns valid object
- Verify dependencies are available
- Review error messages in console

**Fixture cleanup failure:**
- Ensure cleanup methods exist on fixture objects
- Check cleanup method return values
- Implement proper error handling in cleanup methods

**Performance issues:**
- Avoid creating expensive fixtures unnecessarily
- Use lazy initialization effectively
- Consider sharing fixtures across tests when appropriate

Debugging Fixtures
------------------

Enable detailed fixture logging:

.. code-block:: gdscript

   func test_with_debugging() -> bool:
       # Enable verbose fixture logging (if implemented)
       GDTest.enable_fixture_debugging(true)

       register_fixture("debug_service", func(): return create_service())

       var service = get_fixture("debug_service")

       # Logs will show:
       # - Fixture registration
       # - Dependency resolution
       # - Initialization steps
       # - Cleanup operations

       return assert_not_null(service)

Fixture State Inspection
------------------------

Inspect fixture states for debugging:

.. code-block:: gdscript

   func inspect_fixture_state() -> void:
       for fixture_name in _fixture_order:
           var fixture_data = _fixtures[fixture_name].data
           print("Fixture '%s': %s" % [fixture_name, get_state_name(fixture_data.state)])

   func get_state_name(state: int) -> String:
       match state:
           TestFixture.FixtureState.UNINITIALIZED: return "UNINITIALIZED"
           TestFixture.FixtureState.INITIALIZING: return "INITIALIZING"
           TestFixture.FixtureState.READY: return "READY"
           TestFixture.FixtureState.FAILED: return "FAILED"
           TestFixture.FixtureState.CLEANING_UP: return "CLEANING_UP"
           TestFixture.FixtureState.CLEANED_UP: return "CLEANED_UP"
           _: return "UNKNOWN"

.. seealso::
   :doc:`../api/test-classes`
      Base test classes that support fixture functionality.

   :doc:`../advanced/mocking`
      Alternative approach to test dependency management.

   :doc:`../user-guide`
      Best practices for organizing test data and resources.

   :doc:`../troubleshooting`
      Solutions for common fixture-related issues.
