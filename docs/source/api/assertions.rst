Assertions
==========

GDSentry provides comprehensive assertion methods for validating test conditions across different data types. All assertions return a boolean value indicating success or failure, and automatically log detailed failure messages when tests fail.

Collection Assertions
----------------------

Array Assertions
----------------

assert_array_equals()
~~~~~~~~~~~~~~~~~~~~~

Asserts that two arrays are exactly equal, including order and values.

**Parameters:**
- actual: The array to test
- expected: The expected array
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var result = [1, 2, 3]
   assert_array_equals(result, [1, 2, 3])  # Passes
   assert_array_equals(result, [3, 2, 1])  # Fails

assert_array_size()
~~~~~~~~~~~~~~~~~~~

Asserts that an array has the expected number of elements.

**Parameters:**
- array: The array to check
- expected_size: The expected number of elements
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var items = ["sword", "shield", "potion"]
   assert_array_size(items, 3)  # Passes

assert_array_contains()
~~~~~~~~~~~~~~~~~~~~~~~

Asserts that an array contains a specific element.

**Parameters:**
- array: The array to search
- element: The element to find
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var inventory = ["sword", "shield", "potion"]
   assert_array_contains(inventory, "sword")  # Passes

Dictionary Assertions
---------------------

assert_dict_equals()
~~~~~~~~~~~~~~~~~~~~

Asserts that two dictionaries are exactly equal.

**Parameters:**
- actual: The dictionary to test
- expected: The expected dictionary
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var result = {"health": 100, "mana": 50}
   assert_dict_equals(result, {"health": 100, "mana": 50})  # Passes

assert_dict_has_key()
~~~~~~~~~~~~~~~~~~~~~

Asserts that a dictionary contains a specific key.

**Parameters:**
- dict: The dictionary to search
- key: The key to find
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var player = {"name": "Hero", "level": 5}
   assert_dict_has_key(player, "name")  # Passes

Math Assertions
----------------

assert_float_equals()
~~~~~~~~~~~~~~~~~~~~~

Asserts that two floating-point values are equal within a tolerance.

**Parameters:**
- actual: The actual float value
- expected: The expected float value
- tolerance: Maximum allowed difference (default: 0.0001)
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var result = 1.0 / 3.0  # 0.333333...
   assert_float_equals(result, 0.3333, 0.0001)  # Passes

assert_vector2_equals()
~~~~~~~~~~~~~~~~~~~~~~~

Asserts that two Vector2 values are equal within a tolerance.

**Parameters:**
- actual: The actual Vector2 value
- expected: The expected Vector2 value
- tolerance: Maximum allowed difference per component (default: 0.0001)
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var position = Vector2(10.1, 20.2)
   assert_vector2_equals(position, Vector2(10.1, 20.2))  # Passes

String Assertions
------------------

assert_string_equals()
~~~~~~~~~~~~~~~~~~~~~~

Asserts that two strings are equal, with optional case-insensitive comparison.

**Parameters:**
- actual: The actual string
- expected: The expected string
- ignore_case: Whether to ignore case differences (default: false)
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var name = "Player"
   assert_string_equals(name, "Player")  # Passes
   assert_string_equals(name, "player", true)  # Passes (case insensitive)

assert_string_contains()
~~~~~~~~~~~~~~~~~~~~~~~~

Asserts that a string contains a specific substring.

**Parameters:**
- string: The string to search
- substring: The substring to find
- ignore_case: Whether to ignore case differences (default: false)
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var message = "Hello World"
   assert_string_contains(message, "World")  # Passes

assert_string_length()
~~~~~~~~~~~~~~~~~~~~~~

Asserts that a string has the expected length.

**Parameters:**
- string: The string to check
- expected_length: Expected number of characters
- message: Optional custom error message

**Example:**
.. code-block:: gdscript

   var password = "secret123"
   assert_string_length(password, 9)  # Passes

Complete Assertion Reference
============================

GDSentry provides **90+ assertion methods** across three main categories:

**Collection Assertions (24 methods):**
- Array operations: ``assert_array_equals``, ``assert_array_size``, ``assert_array_contains``, etc.
- Dictionary operations: ``assert_dict_equals``, ``assert_dict_has_key``, ``assert_dict_contains``, etc.
- Set operations: ``assert_arrays_equal_unordered``, ``assert_array_subset``, ``assert_array_intersection``, etc.

**Math Assertions (35 methods):**
- Floating-point: ``assert_float_equals``, ``assert_float_zero``, ``assert_float_in_range``, etc.
- Vector operations: ``assert_vector2_equals``, ``assert_vector3_equals``, ``assert_vector2_length``, etc.
- Transform/Rect: ``assert_transform2d_equals``, ``assert_rect_equals``, ``assert_point_in_rect``, etc.
- Statistical: ``assert_array_mean``, ``assert_array_variance``, ``assert_random_distribution``, etc.

**String Assertions (31 methods):**
- Basic comparisons: ``assert_string_equals``, ``assert_string_contains``, ``assert_string_length``, etc.
- Pattern matching: ``assert_string_matches_pattern``, ``assert_string_email_format``, etc.
- Character validation: ``assert_string_is_numeric``, ``assert_string_is_alphabetic``, etc.
- Naming conventions: ``assert_string_camel_case``, ``assert_string_snake_case``, etc.

All assertion methods follow the same documentation pattern shown above, with:
- Complete method signature including parameter types and default values
- Detailed parameter descriptions
- Practical code examples demonstrating usage
- Clear indication of when assertions pass or fail

For the complete list of all available assertions, see the source code in ``assertions/`` directory or use the auto-generated API documentation.

.. seealso::
   :doc:`../api/test-classes`
      Learn which test classes provide access to these assertion methods.

   :doc:`../examples`
      Practical examples showing these assertions in real test scenarios.

   :doc:`../user-guide`
      Best practices for choosing the right assertions for different test cases.

   :doc:`../troubleshooting`
      Solutions for common assertion-related errors and debugging tips.
