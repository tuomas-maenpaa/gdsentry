Architecture Guide
==================

This document provides an overview of the GDSentry framework architecture, including system components, design patterns, and extension points.

Overview
--------

GDSentry is a comprehensive testing framework for Godot projects that provides:

* **Test Discovery & Management**: Automatic discovery and organization of tests
* **Assertion Framework**: Rich set of assertions for different data types
* **Reporter System**: Multiple output formats for test results
* **Plugin Architecture**: Extensible system for custom functionality

Core Components
---------------

Test Discovery & Management
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The test discovery system automatically finds and organizes tests based on:

* File naming conventions (``*_test.gd``)
* Class inheritance from base test classes
* Test method naming patterns

**Key Classes:**

* ``TestManager``: Central coordinator for test execution
* ``TestDiscovery``: Discovers and validates test files
* ``TestRunner``: Executes tests and manages lifecycle

**Example Usage:**

.. code-block:: gdscript

   # Automatic discovery
   var test_manager = TestManager.new()
   var tests = test_manager.discover_tests("res://tests/")

   # Manual test execution
   var runner = TestRunner.new()
   var results = runner.run_tests(tests)

Assertion Framework
~~~~~~~~~~~~~~~~~~~

The assertion framework provides comprehensive testing capabilities:

**Core Features:**

* Type-specific assertions (string, numeric, collection)
* Custom assertion extensibility
* Detailed failure reporting
* Fluent API design

**Key Components:**

* ``AssertionBuilder``: Fluent interface for building assertions
* ``StringAssertions``, ``NumericAssertions``, ``CollectionAssertions``: Type-specific assertion classes
* ``AssertionResult``: Standardized result format

**Example Usage:**

.. code-block:: gdscript

   func test_calculator():
       var calc = Calculator.new()

       assert_that(calc.add(2, 3)).is_equal_to(5)
       assert_that(calc.divide(10, 2)).is_greater_than(4)
       assert_that(calc.get_history()).is_not_empty()

Reporter System
~~~~~~~~~~~~~~~

The reporter system provides multiple output formats for test results:

**Built-in Reporters:**

* ``ConsoleReporter``: Human-readable console output
* ``JSONReporter``: Machine-readable JSON format
* ``HTMLReporter``: Rich HTML reports with styling
* ``JUnitReporter``: JUnit XML for CI/CD integration

**Architecture:**

.. code-block:: gdscript

   interface IReporter:
       func generate_report(results: TestResults) -> String
       func get_name() -> String

   class ReporterManager:
       func register_reporter(reporter: IReporter)
       func generate_reports(results: TestResults) -> Dictionary

**Extension Points:**

* Custom reporters can implement ``IReporter`` interface
* Multiple reporters can be registered simultaneously
* Results can be filtered and transformed before reporting

Plugin Architecture
~~~~~~~~~~~~~~~~~~~

GDSentry uses a plugin-based architecture for extensibility:

**Plugin Types:**

* **Test Type Plugins**: Add new test types (e.g., visual tests, physics tests)
* **Reporter Plugins**: Add new output formats
* **Utility Plugins**: Add helper functionality
* **Integration Plugins**: Connect with external tools and IDEs

**Plugin Loading:**

.. code-block:: gdscript

   var plugin_manager = PluginManager.new()
   plugin_manager.load_plugins_from_directory("res://plugins/")

   # Access plugin functionality
   var visual_tester = plugin_manager.get_plugin("VisualTestPlugin")

Design Patterns
---------------

Factory Pattern
~~~~~~~~~~~~~~~

Used extensively for creating test instances and reporters:

.. code-block:: gdscript

   class TestFactory:
       static func create_test_class(base_class: String, test_name: String):
           # Create appropriate test class based on requirements
           pass

   class ReporterFactory:
       static func create_reporter(format: String) -> IReporter:
           match format:
               "json":
                   return JSONReporter.new()
               "html":
                   return HTMLReporter.new()
               "junit":
                   return JUnitReporter.new()

Observer Pattern
~~~~~~~~~~~~~~~~

Used for test lifecycle management:

.. code-block:: gdscript

   class TestLifecycleManager:
       var observers = []

       func add_observer(observer):
           observers.append(observer)

       func notify_test_started(test):
           for observer in observers:
               observer.on_test_started(test)

Strategy Pattern
~~~~~~~~~~~~~~~~

Used for different test execution strategies:

.. code-block:: gdscript

   interface TestExecutionStrategy:
       func execute_test(test: TestCase) -> TestResult

   class ParallelExecutionStrategy implements TestExecutionStrategy:
       func execute_test(test: TestCase) -> TestResult:
           # Execute test in parallel with others
           pass

   class SequentialExecutionStrategy implements TestExecutionStrategy:
       func execute_test(test: TestCase) -> TestResult:
           # Execute test sequentially
           pass

Component Interactions
----------------------

Core Flow
~~~~~~~~~

1. **Discovery**: TestManager discovers test files and classes
2. **Validation**: Tests are validated for correct structure
3. **Execution**: TestRunner executes tests using configured strategy
4. **Reporting**: Results are passed to registered reporters
5. **Output**: Reports are generated and saved/published

**Sequence Diagram:**

::

   TestManager -> TestDiscovery: discover_tests()
   TestManager -> TestRunner: run_tests()
   TestRunner -> TestExecutionStrategy: execute()
   TestRunner -> ReporterManager: generate_reports()
   ReporterManager -> IReporter[]: generate_report()

Data Flow
~~~~~~~~~

**Test Data Lifecycle:**

1. Test data is generated or loaded
2. Data is passed to test methods
3. Assertions validate data against expectations
4. Results are captured and aggregated
5. Reports include relevant data context

**Error Handling Flow:**

1. Errors are caught at the test level
2. Error information is captured in TestResult
3. Results are passed to reporters
4. Detailed error context is preserved for debugging

Extension Points
----------------

Custom Test Types
~~~~~~~~~~~~~~~~~

Extend the framework with new test types:

.. code-block:: gdscript

   class CustomTestType extends Node2DTest:
       func setup_custom_environment():
           # Custom setup logic
           pass

       func custom_assertion_method():
           # Custom assertion logic
           pass

Custom Reporters
~~~~~~~~~~~~~~~~

Create custom output formats:

.. code-block:: gdscript

   class CustomReporter implements IReporter:
       func generate_report(results: TestResults) -> String:
           # Custom report generation
           return custom_format(results)

       func get_name() -> String:
           return "CustomReporter"

Custom Utilities
~~~~~~~~~~~~~~~

Add utility functions for common testing tasks:

.. code-block:: gdscript

   class TestUtils:
       static func create_mock_object():
           # Create mock objects for testing
           pass

       static func load_test_fixture(path: String):
           # Load test fixtures
           pass

IDE Integration
~~~~~~~~~~~~~~~

Integrate with development environments:

.. code-block:: gdscript

   class IDEIntegrationPlugin:
       func connect_to_ide():
           # Connect to IDE for live testing
           pass

       func send_test_results(results):
           # Send results back to IDE
           pass

Performance Considerations
--------------------------

Memory Management
~~~~~~~~~~~~~~~~~

* Object pooling for frequently created objects
* Proper cleanup of test resources
* Memory leak detection in long-running tests

Execution Optimization
~~~~~~~~~~~~~~~~~~~~~~

* Parallel test execution where safe
* Test dependency analysis to optimize order
* Caching of expensive setup operations

**Performance Monitoring:**

.. code-block:: gdscript

   class PerformanceMonitor:
       static func measure_execution_time(test_func: FuncRef) -> float:
           var start_time = OS.get_ticks_msec()
           test_func.call_func()
           var end_time = OS.get_ticks_msec()
           return end_time - start_time

       static func detect_memory_leaks():
           # Monitor memory usage patterns
           pass

Error Handling & Debugging
--------------------------

Error Types
~~~~~~~~~~~

**Test Execution Errors:**

* Syntax errors in test files
* Missing dependencies
* Timeout errors
* Assertion failures

**Framework Errors:**

* Reporter configuration errors
* Plugin loading failures
* Resource access errors

**Debugging Features:**

* Detailed stack traces for failures
* Step-through debugging support
* Test isolation for debugging
* Comprehensive logging system

Configuration Management
------------------------

Runtime Configuration
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: gdscript

   class TestConfig:
       var parallel_execution: bool = false
       var timeout_ms: int = 5000
       var reporter_configs: Dictionary = {}

       func load_from_file(path: String):
           # Load configuration from file
           pass

Environment Detection
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: gdscript

   class EnvironmentDetector:
       static func is_ci_environment() -> bool:
           return "CI" in OS.get_environment()

       static func get_available_memory() -> int:
           return OS.get_static_memory_usage()

       static func detect_godot_version() -> String:
           return Engine.get_version_info().major

Version Compatibility Strategy
------------------------------

Cross-Version Support
~~~~~~~~~~~~~~~~~~~~~

**Godot 3.5.x Compatibility:**

* Use compatibility layer for file operations
* Feature detection for version-specific APIs
* Graceful degradation for missing features

**Godot 4.x Enhancement:**

* Modern API usage where available
* Enhanced performance features
* Improved error handling

**Migration Strategy:**

1. Maintain backward compatibility
2. Add forward-compatible enhancements
3. Provide clear deprecation paths
4. Document version-specific behaviors

Future Architecture Considerations
----------------------------------

Scalability
~~~~~~~~~~~

* Distributed test execution
* Cloud-based test environments
* Large-scale test suite optimization

Advanced Features
~~~~~~~~~~~~~~~~~

* Machine learning-based test optimization
* Advanced mocking and stubbing
* Visual regression testing
* Performance benchmarking

Integration Ecosystem
~~~~~~~~~~~~~~~~~~~~~

* CI/CD pipeline integration
* IDE plugin ecosystem
* External tool connectors
* Cloud service integration

This architecture provides a solid foundation for a comprehensive testing framework while remaining extensible and maintainable.
