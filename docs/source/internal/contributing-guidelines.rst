Contributing Guidelines
=======================

This document provides guidelines for contributing to the GDSentry project. We welcome contributions from the community and appreciate your interest in improving the framework.

Getting Started
---------------

Before You Begin
~~~~~~~~~~~~~~~

1. **Read the Documentation**: Familiarize yourself with the project by reading the user guide and architecture documentation
2. **Set Up Development Environment**: Ensure you have Godot 3.5+ and 4.4+ available for testing
3. **Understand the Codebase**: Review the architecture guide and development standards
4. **Join the Community**: Check our communication channels for discussions

Development Environment Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Required Tools:**

* Godot 3.5.x (minimum supported version)
* Godot 4.4+ (current development target)
* Git for version control
* Text editor with GDScript support

**Optional Tools:**

* IDE with Godot integration (VSCode, etc.)
* Docker for containerized testing
* CI/CD tools for automated testing

**Environment Configuration:**

.. code-block:: bash

   # Clone the repository
   git clone https://github.com/your-org/gdsentry.git
   cd gdsentry

   # Set up development environment
   # (Details in development setup scripts)

Contribution Workflow
---------------------

1. Fork and Clone
~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Fork the repository on GitHub
   # Clone your fork locally
   git clone https://github.com/your-username/gdsentry.git
   cd gdsentry

   # Add upstream remote
   git remote add upstream https://github.com/original-org/gdsentry.git

2. Create a Feature Branch
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Fetch latest changes
   git fetch upstream
   git checkout -b feature/your-feature-name

   # Or for bug fixes
   git checkout -b fix/issue-description

3. Make Your Changes
~~~~~~~~~~~~~~~~~~~~

* Follow the development standards
* Write tests for new functionality
* Update documentation as needed
* Ensure all tests pass

4. Test Your Changes
~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Run tests locally
   ./scripts/dev/test-local-changes.sh

   # Test on both Godot versions if applicable
   # Run full test suite
   ./scripts/ci/run-full-ci.sh

5. Commit Your Changes
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Stage your changes
   git add .

   # Write a clear commit message
   git commit -m "feat: add new assertion for array equality

   - Add is_equal_to assertion for arrays
   - Include comprehensive tests
   - Update documentation with examples"

6. Push and Create Pull Request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Push to your fork
   git push origin feature/your-feature-name

   # Create a pull request on GitHub
   # Fill out the PR template with details

Code Standards
--------------

General Guidelines
~~~~~~~~~~~~~~~~~~

* Follow the naming conventions outlined in development standards
* Write clear, descriptive comments
* Keep functions focused and single-purpose
* Use meaningful variable names

**GDScript Specific:**

.. code-block:: gdscript

   # Good: Clear and descriptive
   func calculate_average_score(scores: Array) -> float:
       if scores.empty():
           return 0.0
       var total = 0.0
       for score in scores:
           total += score
       return total / scores.size()

   # Avoid: Unclear and complex
   func calc_avg(a: Array) -> float:
       return a.reduce(func(acc, val): return acc + val, 0.0) / a.size()

Testing Requirements
~~~~~~~~~~~~~~~~~~~~

**For New Features:**

* Unit tests covering all code paths
* Integration tests for component interactions
* Edge case testing
* Cross-version compatibility testing

**For Bug Fixes:**

* Test case that reproduces the bug
* Test case that validates the fix
* Regression tests to prevent reoccurrence

**Example Test Structure:**

.. code-block:: gdscript

   class_name CalculatorTest extends GDTest:
       func test_addition():
           var calc = Calculator.new()
           var result = calc.add(2, 3)
           assert_that(result).is_equal_to(5)

       func test_division_by_zero():
           var calc = Calculator.new()
           var result = calc.divide(10, 0)
           assert_that(result).is_null()

       func test_large_numbers():
           var calc = Calculator.new()
           var result = calc.multiply(999999, 999999)
           assert_that(result).is_equal_to(999998000001)

Documentation Requirements
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Code Documentation:**

* All public functions must have docstrings
* Include parameter descriptions
* Document return values
* Provide usage examples

**User-Facing Documentation:**

* Update user guide for new features
* Add examples to tutorials
* Update API reference
* Include migration notes for breaking changes

**Example Function Documentation:**

.. code-block:: gdscript

   func load_test_data(file_path: String, options: Dictionary = {}) -> Result:
       """
       Load test data from a file with configurable options.

       This function supports loading data in various formats and provides
       flexible configuration for different use cases.

       Args:
           file_path: Path to the test data file
           options: Configuration options (optional)
               - format: Data format ("json", "csv", "yaml") - defaults to "json"
               - encoding: File encoding - defaults to "utf-8"
               - validate_schema: Whether to validate data structure - defaults to true

       Returns:
           Result object containing either loaded data or error information

       Example:
           var result = load_test_data("data/tests.json", {"format": "json"})
           if result.success:
               var data = result.value
               print("Loaded %d test cases" % data.size())
           else:
               print("Error: %s" % result.error_message)
       """

Pull Request Requirements
-------------------------

Required Information
~~~~~~~~~~~~~~~~~~~~

**PR Title:**
Use clear, descriptive titles that follow conventional commit format:

.. code-block:: text

   feat: add support for custom test reporters
   fix: resolve memory leak in test execution
   docs: update API documentation for v2.0
   refactor: improve error handling in core components

**PR Description:**
Include the following sections:

* **Description**: What the PR does and why it's needed
* **Changes**: Summary of code changes
* **Testing**: How the changes were tested
* **Documentation**: Any documentation updates
* **Breaking Changes**: Any breaking changes and migration path

**Example PR Description:**

.. code-block:: markdown

   ## Description

   This PR adds support for custom test reporters, allowing users to create
   their own output formats for test results.

   ## Changes

   - Added IReporter interface for custom reporter implementations
   - Implemented ReporterFactory for dynamic reporter creation
   - Added example custom reporter in examples directory
   - Updated documentation with reporter development guide

   ## Testing

   - Added comprehensive unit tests for ReporterFactory
   - Created integration tests for custom reporter workflow
   - Verified compatibility with existing reporters
   - Tested on both Godot 3.5 and 4.4

   ## Documentation

   - Updated architecture guide with reporter system details
   - Added tutorial for creating custom reporters
   - Updated API reference with new interfaces

   ## Breaking Changes

   None. This is a backward-compatible enhancement.

Review Process
--------------

What to Expect
~~~~~~~~~~~~~~

1. **Automated Checks**: CI/CD pipeline will run tests and checks
2. **Initial Review**: Maintainers will review your PR for standards compliance
3. **Feedback**: You may receive requests for changes or improvements
4. **Approval**: Once approved, your PR will be merged

**Common Review Feedback:**

* Code style and formatting issues
* Missing tests or documentation
* Performance considerations
* Version compatibility concerns

**Addressing Feedback:**

* Respond promptly to comments
* Make requested changes
* Update PR description if scope changes
* Re-request review when ready

Code Review Checklist
~~~~~~~~~~~~~~~~~~~~~

**For Reviewers:**

- [ ] Code follows project standards
- [ ] Tests are comprehensive and pass
- [ ] Documentation is updated
- [ ] Performance impact considered
- [ ] Version compatibility verified
- [ ] Security implications assessed

**For Contributors:**

- [ ] All tests pass
- [ ] Code style consistent
- [ ] Documentation complete
- [ ] Performance acceptable
- [ ] No breaking changes

Community Guidelines
--------------------

Communication
~~~~~~~~~~~~~

* Be respectful and constructive in discussions
* Use clear, professional language
* Provide helpful feedback and suggestions
* Ask questions when unsure

**Channels:**

* **GitHub Issues**: Bug reports, feature requests, questions
* **Discussions**: General discussions and brainstorming
* **Pull Requests**: Code contributions and reviews
* **Documentation**: Questions about usage and implementation

Reporting Issues
~~~~~~~~~~~~~~~~

**Bug Reports:**

Include the following information:

* Godot version and platform
* Steps to reproduce the issue
* Expected vs actual behavior
* Error messages and stack traces
* Minimal reproduction case

**Feature Requests:**

* Clear description of the feature
* Use case and motivation
* Proposed implementation approach
* Alternative solutions considered

**Example Bug Report:**

.. code-block:: markdown

   ## Bug Report

   ### Environment
   - Godot version: 4.4
   - Platform: Linux
   - GDSentry version: 1.0.0

   ### Description
   The JSONReporter is not properly escaping special characters in test names,
   causing malformed JSON output.

   ### Steps to Reproduce
   1. Create a test with special characters in the name: `test_calculator_add()`
   2. Run tests with JSONReporter
   3. Observe malformed JSON in output

   ### Expected Behavior
   Test names with special characters should be properly escaped in JSON output.

   ### Actual Behavior
   JSON output contains unescaped characters, breaking JSON parsers.

   ### Additional Information
   Error occurs with characters like: quotes, backslashes, newlines.

Contributing Examples
---------------------

Example Contribution
~~~~~~~~~~~~~~~~~~~~

Here's an example of contributing a new assertion type:

**1. Create the Implementation:**

.. code-block:: gdscript

   # src/assertions/dictionary_assertions.gd
   class_name DictionaryAssertions

   class DictionaryAssertionBuilder:
       var _actual: Dictionary

       func is_equal_to(expected: Dictionary):
           # Implementation here
           pass

       func has_key(key):
           # Implementation here
           pass

**2. Write Tests:**

.. code-block:: gdscript

   # tests/assertions/dictionary_assertions_test.gd
   class_name DictionaryAssertionsTest extends GDTest:

       func test_is_equal_to_with_matching_dictionaries():
           var actual = {"key": "value", "number": 42}
           var expected = {"key": "value", "number": 42}

           assert_that(actual).is_equal_to(expected)

       func test_has_key_with_existing_key():
           var dict = {"name": "test", "value": 123}

           assert_that(dict).has_key("name")

**3. Update Documentation:**

Update the API reference and add examples to the user guide.

**4. Create Pull Request:**

Follow the PR guidelines and provide comprehensive description.

Best Practices
--------------

Development Workflow
~~~~~~~~~~~~~~~~~~~~

* Work in small, focused increments
* Test frequently during development
* Use feature branches for new work
* Keep commits focused and well-documented

**Example Workflow:**

1. Create feature branch
2. Write failing test for new functionality
3. Implement minimum code to gdsentry test run pass
4. Refactor and improve implementation
5. Add additional test cases
6. Update documentation
7. Run full test suite
8. Create pull request

Debugging Tips
~~~~~~~~~~~~~~

**Common Debugging Strategies:**

* Use Godot's built-in debugger
* Add print statements for data flow
* Isolate problematic code sections
* Test with minimal reproduction cases

**Debugging Commands:**

.. code-block:: gdscript

   # Add debug prints
   print("Debug: Variable value = ", some_variable)

   # Use assertions for debugging
   assert(some_condition, "Debug assertion failed")

   # Break into debugger on specific conditions
   if some_error_condition:
       breakpoint  # Godot will break here

Performance Optimization
~~~~~~~~~~~~~~~~~~~~~~~~

**Profiling Guidelines:**

1. Identify performance bottlenecks
2. Measure current performance
3. Implement optimizations
4. Measure improvement
5. Ensure no regressions

**Example Performance Test:**

.. code-block:: gdscript

   func test_performance_large_dataset():
       var large_array = []
       for i in range(10000):
           large_array.append(i)

       var start_time = OS.get_ticks_usec()
       var result = process_large_array(large_array)
       var end_time = OS.get_ticks_usec()

       var execution_time = end_time - start_time
       assert_that(execution_time).is_less_than(1000000)  # Less than 1 second

Version Control Best Practices
------------------------------

Branch Strategy
~~~~~~~~~~~~~~~

* ``main``: Stable, production-ready code
* ``develop``: Latest development changes
* ``feature/*``: New features
* ``fix/*``: Bug fixes
* ``docs/*``: Documentation updates
* ``refactor/*``: Code refactoring

**Branch Naming Examples:**

.. code-block:: text

   feature/async-test-execution
   fix/memory-leak-in-reporter
   docs/update-api-reference
   refactor/improve-error-handling

Commit Message Guidelines
~~~~~~~~~~~~~~~~~~~~~~~~~

**Format:**

.. code-block:: text

   type(scope): description

   body (optional)

**Types:**

* ``feat``: New feature
* ``fix``: Bug fix
* ``docs``: Documentation
* ``refactor``: Code refactoring
* ``test``: Test additions/changes
* ``chore``: Maintenance tasks

**Examples:**

.. code-block:: text

   feat(assertions): add dictionary assertions support

   - Implement DictionaryAssertions class
   - Add comprehensive test coverage
   - Update API documentation

   fix(reporter): resolve JSON escaping issue

   - Fix special character handling in JSONReporter
   - Add proper escaping for quotes and backslashes
   - Update existing tests

   docs: update architecture guide

   - Add section on plugin architecture
   - Update component interaction diagrams
   - Include extension point examples

Thank You
---------

Thank you for your interest in contributing to GDSentry! Your contributions help make the framework better for everyone. We appreciate your time, expertise, and passion for improving the Godot testing ecosystem.

If you have any questions about contributing, don't hesitate to ask in our community channels. We're here to help you succeed in your contributions.
