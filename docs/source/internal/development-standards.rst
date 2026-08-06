Development Standards
=====================

This document outlines the development standards and conventions used in the GDSentry project.

Version Compatibility
---------------------

**Target Versions**

* **Minimum supported**: Godot 3.5.x
* **Current development target**: Godot 4.4+
* **Compatibility approach**: Progressive enhancement with graceful degradation

**Guidelines**

* Always use compatibility layers for cross-version features
* Use feature detection rather than version checks when possible
* Provide clear documentation for version-specific behaviors
* Test on both minimum and target versions before releases

Naming Conventions
------------------

**Global Classes**

Global classes use PascalCase and represent major system components:

.. code-block:: gdscript

   class_name FileSystemCompatibility
   class_name TestReporter
   class_name DataDrivenTest

**Local Variables**

Local variables use snake_case to avoid conflicts with global classes:

.. code-block:: gdscript

   # Instead of:
   var FileSystemCompatibility = load(...)

   # Use:
   var file_system_compat = load(...)
   # or
   var filesystem_compatibility = load(...)

**Constants**

Constants use SCREAMING_SNAKE_CASE:

.. code-block:: gdscript

   const MAX_RETRY_ATTEMPTS = 3
   const DEFAULT_TIMEOUT_MS = 5000

**Private Functions**

Private functions are prefixed with underscore and use snake_case:

.. code-block:: gdscript

   func _initialize_reporter_manager():
   func _validate_test_structure():

**File Naming**

* Test files: ``*_test.gd`` (e.g., ``calculator_test.gd``)
* Utility files: ``*.gd`` with descriptive names
* Base classes: ``*base.gd`` or ``*test.gd``

Error Handling
--------------

**Result Pattern**

Use the Result pattern for operations that can fail:

.. code-block:: gdscript

   class Result:
       var success: bool
       var value
       var error_message: String

       static func ok(value):
           return Result.new(true, value, "")

       static func error(message: String):
           return Result.new(false, null, message)

**Error Handling Guidelines**

* Provide meaningful error messages
* Graceful degradation over crashes
* Log errors appropriately for debugging
* Handle edge cases explicitly

**Example Implementation**

.. code-block:: gdscript

   func load_test_file(path: String) -> Result:
       if not FileSystemCompatibility.file_exists(path):
           return Result.error("Test file not found: %s" % path)

       var content = FileSystemCompatibility.read_file_as_text(path)
       if content.empty():
           return Result.error("Test file is empty: %s" % path)

       return Result.ok(content)

Testing Requirements
--------------------

**Coverage Requirements**

* All new features must have corresponding tests
* Critical paths require 100% test coverage
* Cross-version testing is mandatory
* Performance regression testing is required

**Test Organization**

* Unit tests for individual functions
* Integration tests for component interactions
* End-to-end tests for complete workflows
* Performance tests for optimization validation

**Test Naming**

.. code-block:: gdscript

   func test_file_exists_with_valid_path():
   func test_file_exists_with_invalid_path_returns_false():
   func test_open_file_with_read_mode():
   func test_open_file_with_nonexistent_file_returns_null():

Code Quality
------------

**Documentation**

* All public functions must have docstrings
* Use Google-style or NumPy-style docstrings
* Include parameter and return type information
* Provide usage examples where appropriate

**Example Docstring**

.. code-block:: gdscript

   func calculate_total(items: Array, tax_rate: float = 0.0) -> float:
       """
       Calculate the total cost including tax.

       Args:
           items: Array of item prices (float values)
           tax_rate: Tax rate as decimal (e.g., 0.08 for 8%)

       Returns:
           Total cost including tax

       Example:
           var total = calculate_total([10.0, 20.0], 0.08)
           # Returns: 32.4
       """

**Code Style**

* Use 4 spaces for indentation (no tabs)
* Line length limit: 100 characters
* Group related functionality together
* Use blank lines to separate logical sections

**Performance Considerations**

* Avoid unnecessary object creation in loops
* Cache frequently accessed values
* Use efficient data structures
* Profile performance-critical sections

File Organization
-----------------

**Directory Structure**

::

   src/
   ├── core/           # Core framework functionality
   ├── assertions/     # Assertion implementations
   ├── base_classes/   # Base test classes
   ├── utilities/      # Utility functions
   ├── reporters/      # Test reporting system

**Import Organization**

.. code-block:: gdscript

   # Standard library imports first
   # Third-party imports second
   # Local imports last
   # Group related imports together

   # Core framework
   const GDSentry = preload("res://src/core/gdsentry.gd")
   const TestManager = preload("res://src/core/test_manager.gd")

   # Utilities
   const FileSystemCompat = preload("res://src/utilities/file_system_compatibility.gd")
   const TestDataGen = preload("res://src/utilities/test_data_generator.gd")

Version Control Practices
-------------------------

**Commit Messages**

Use clear, descriptive commit messages:

.. code-block:: text

   feat: add new assertion for array equality
   fix: resolve FileSystemCompatibility linter errors
   docs: update development standards documentation
   refactor: improve error handling in test runner

**Branch Naming**

* ``feature/feature-name`` for new features
* ``fix/issue-description`` for bug fixes
* ``docs/documentation-updates`` for documentation
* ``refactor/code-improvement`` for refactoring

**Pull Request Guidelines**

* Provide clear description of changes
* Include test cases for new functionality
* Update documentation as needed
* Ensure all tests pass

Migration Guidelines
--------------------

**Breaking Changes**

* Clearly document breaking changes
* Provide migration guides for users
* Use deprecation warnings before removal
* Support both old and new APIs during transition

**Version Deprecation**

.. code-block:: gdscript

   func deprecated_function():
       push_warning("deprecated_function is deprecated. Use new_function instead.")
       return new_function()

**Migration Path**

1. Introduce new functionality alongside old
2. Add deprecation warnings to old functionality
3. Update documentation to recommend new approaches
4. Remove deprecated functionality in major version updates

Best Practices
--------------

**Defensive Programming**

* Validate inputs to public functions
* Handle null/empty cases gracefully
* Provide sensible defaults where appropriate

**Resource Management**

* Properly clean up resources
* Use RAII patterns where applicable
* Avoid memory leaks in long-running operations

**Testing Best Practices**

* Write tests before implementing features (TDD)
* Use descriptive test names
* Test both success and failure cases
* Mock external dependencies appropriately

**Performance Optimization**

* Profile before optimizing
* Focus on bottlenecks identified by profiling
* Use efficient algorithms and data structures
* Consider memory usage in addition to speed

Troubleshooting
---------------

**Common Issues**

* **Naming conflicts**: Use snake_case for local variables to avoid conflicts with global classes
* **Version compatibility**: Always test on minimum supported version
* **Performance issues**: Profile and identify bottlenecks before optimizing

**Debugging Tips**

* Use Godot's built-in debugger effectively
* Add logging for complex operations
* Test incrementally during development
* Use version control to track changes and identify regressions
