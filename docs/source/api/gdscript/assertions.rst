GDScript Assertion API
======================

Overview
--------

GDSentry provides three specialized assertion libraries for comprehensive test validation:

- **MathAssertions** - Numerical and mathematical validation
- **CollectionAssertions** - Array and dictionary validation
- **StringAssertions** - String and text validation

All assertion functions are static and can be called directly without instantiation.

MathAssertions
--------------

**Location**: ``src/assertions/math_assertions.gd``

**Import**: ``extends MathAssertions`` or use static calls

Floating Point Assertions
~~~~~~~~~~~~~~~~~~~~~~~~~~

assert_float_equals
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_float_equals(
        actual: float,
        expected: float,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that two floats are equal within tolerance.

**Parameters**:

- ``actual`` - The actual float value
- ``expected`` - The expected float value
- ``tolerance`` - Maximum acceptable difference (default: 0.0001)
- ``message`` - Custom error message

**Returns**: ``true`` if assertion passes, ``false`` otherwise

**Example**:

.. code-block:: gdscript

    assert_float_equals(3.14159, PI, 0.00001)
    assert_float_equals(result, 42.0, 0.1, "Result should be approximately 42")

assert_float_not_equals
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_float_not_equals(
        actual: float,
        expected: float,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that two floats are not equal within tolerance.

assert_float_zero
^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_float_zero(
        value: float,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that float value is zero within tolerance.

assert_float_positive
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_float_positive(
        value: float,
        message: String = ""
    ) -> bool

Assert that float value is positive (> 0).

assert_float_negative
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_float_negative(
        value: float,
        message: String = ""
    ) -> bool

Assert that float value is negative (< 0).

assert_float_in_range
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_float_in_range(
        value: float,
        min_val: float,
        max_val: float,
        message: String = ""
    ) -> bool

Assert that float value is within specified range [min_val, max_val].

**Example**:

.. code-block:: gdscript

    assert_float_in_range(player.health, 0.0, 100.0)

Vector Assertions
~~~~~~~~~~~~~~~~~

assert_vector2_equals
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_vector2_equals(
        actual: Vector2,
        expected: Vector2,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that two Vector2 are equal within tolerance (uses distance).

**Example**:

.. code-block:: gdscript

    assert_vector2_equals(player.position, Vector2(100, 200), 0.1)

assert_vector3_equals
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_vector3_equals(
        actual: Vector3,
        expected: Vector3,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that two Vector3 are equal within tolerance (uses distance).

assert_vector2_zero
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_vector2_zero(
        value: Vector2,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that Vector2 is zero vector within tolerance.

assert_vector3_zero
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_vector3_zero(
        value: Vector3,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that Vector3 is zero vector within tolerance.

assert_vector2_normalized
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_vector2_normalized(
        value: Vector2,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that Vector2 is normalized (length ≈ 1).

**Example**:

.. code-block:: gdscript

    var direction = velocity.normalized()
    assert_vector2_normalized(direction)

assert_vector3_normalized
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_vector3_normalized(
        value: Vector3,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Assert that Vector3 is normalized (length ≈ 1).

Range and Boundary Assertions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

assert_in_range
^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_in_range(
        value: float,
        min_val: float,
        max_val: float,
        message: String = ""
    ) -> bool

Assert that value is within range [min_val, max_val].

assert_between
^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_between(
        value: float,
        lower: float,
        upper: float,
        message: String = ""
    ) -> bool

Assert that value is strictly between lower and upper (exclusive).

assert_approximately
^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_approximately(
        actual: float,
        expected: float,
        tolerance: float = 0.0001,
        message: String = ""
    ) -> bool

Alias for ``assert_float_equals``.

CollectionAssertions
--------------------

**Location**: ``src/assertions/collection_assertions.gd``

**Import**: ``extends CollectionAssertions`` or use static calls

Array Assertions
~~~~~~~~~~~~~~~~

assert_array_equals
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_equals(
        actual: Array,
        expected: Array,
        message: String = ""
    ) -> bool

Assert that two arrays are equal (same elements in same order).

**Example**:

.. code-block:: gdscript

    assert_array_equals([1, 2, 3], player.inventory_ids)

assert_array_contains
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_contains(
        array: Array,
        element: Variant,
        message: String = ""
    ) -> bool

Assert that array contains the specified element.

**Example**:

.. code-block:: gdscript

    assert_array_contains(available_weapons, "sword")

assert_array_not_contains
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_not_contains(
        array: Array,
        element: Variant,
        message: String = ""
    ) -> bool

Assert that array does not contain the specified element.

assert_array_empty
^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_empty(
        array: Array,
        message: String = ""
    ) -> bool

Assert that array is empty.

assert_array_not_empty
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_not_empty(
        array: Array,
        message: String = ""
    ) -> bool

Assert that array is not empty.

assert_array_size
^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_size(
        array: Array,
        expected_size: int,
        message: String = ""
    ) -> bool

Assert that array has the expected size.

**Example**:

.. code-block:: gdscript

    assert_array_size(player.active_buffs, 3)

assert_array_all
^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_all(
        array: Array,
        predicate: Callable,
        message: String = ""
    ) -> bool

Assert that all elements in array satisfy the predicate.

**Example**:

.. code-block:: gdscript

    assert_array_all(enemies, func(e): return e.health > 0)

assert_array_any
^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_any(
        array: Array,
        predicate: Callable,
        message: String = ""
    ) -> bool

Assert that at least one element in array satisfies the predicate.

assert_array_sorted
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_array_sorted(
        array: Array,
        ascending: bool = true,
        message: String = ""
    ) -> bool

Assert that array is sorted in specified order.

Dictionary Assertions
~~~~~~~~~~~~~~~~~~~~~

assert_dict_equals
^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_dict_equals(
        actual: Dictionary,
        expected: Dictionary,
        message: String = ""
    ) -> bool

Assert that two dictionaries are equal (same keys and values).

assert_dict_has_key
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_dict_has_key(
        dict: Dictionary,
        key: Variant,
        message: String = ""
    ) -> bool

Assert that dictionary contains the specified key.

**Example**:

.. code-block:: gdscript

    assert_dict_has_key(player_stats, "health")

assert_dict_has_value
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_dict_has_value(
        dict: Dictionary,
        value: Variant,
        message: String = ""
    ) -> bool

Assert that dictionary contains the specified value.

assert_dict_empty
^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_dict_empty(
        dict: Dictionary,
        message: String = ""
    ) -> bool

Assert that dictionary is empty.

assert_dict_not_empty
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_dict_not_empty(
        dict: Dictionary,
        message: String = ""
    ) -> bool

Assert that dictionary is not empty.

assert_dict_size
^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_dict_size(
        dict: Dictionary,
        expected_size: int,
        message: String = ""
    ) -> bool

Assert that dictionary has the expected number of keys.

StringAssertions
----------------

**Location**: ``src/assertions/string_assertions.gd``

**Import**: ``extends StringAssertions`` or use static calls

Basic String Assertions
~~~~~~~~~~~~~~~~~~~~~~~

assert_string_equals
^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_equals(
        actual: String,
        expected: String,
        message: String = ""
    ) -> bool

Assert that two strings are equal (case-sensitive).

**Example**:

.. code-block:: gdscript

    assert_string_equals(player.name, "Hero")

assert_string_equals_ignore_case
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_equals_ignore_case(
        actual: String,
        expected: String,
        message: String = ""
    ) -> bool

Assert that two strings are equal (case-insensitive).

assert_string_contains
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_contains(
        string: String,
        substring: String,
        message: String = ""
    ) -> bool

Assert that string contains the specified substring.

**Example**:

.. code-block:: gdscript

    assert_string_contains(error_message, "failed")

assert_string_not_contains
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_not_contains(
        string: String,
        substring: String,
        message: String = ""
    ) -> bool

Assert that string does not contain the specified substring.

assert_string_starts_with
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_starts_with(
        string: String,
        prefix: String,
        message: String = ""
    ) -> bool

Assert that string starts with the specified prefix.

**Example**:

.. code-block:: gdscript

    assert_string_starts_with(file_path, "res://")

assert_string_ends_with
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_ends_with(
        string: String,
        suffix: String,
        message: String = ""
    ) -> bool

Assert that string ends with the specified suffix.

assert_string_empty
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_empty(
        string: String,
        message: String = ""
    ) -> bool

Assert that string is empty.

assert_string_not_empty
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_not_empty(
        string: String,
        message: String = ""
    ) -> bool

Assert that string is not empty.

assert_string_length
^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_length(
        string: String,
        expected_length: int,
        message: String = ""
    ) -> bool

Assert that string has the expected length.

Pattern Matching Assertions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

assert_string_matches
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_matches(
        string: String,
        pattern: String,
        message: String = ""
    ) -> bool

Assert that string matches the specified glob pattern.

**Example**:

.. code-block:: gdscript

    assert_string_matches(filename, "*.gd")

assert_string_matches_regex
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_matches_regex(
        string: String,
        regex_pattern: String,
        message: String = ""
    ) -> bool

Assert that string matches the specified regular expression.

**Example**:

.. code-block:: gdscript

    assert_string_matches_regex(email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")

Character Type Assertions
~~~~~~~~~~~~~~~~~~~~~~~~~

assert_string_is_numeric
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_is_numeric(
        string: String,
        message: String = ""
    ) -> bool

Assert that string contains only numeric characters.

assert_string_is_alpha
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_is_alpha(
        string: String,
        message: String = ""
    ) -> bool

Assert that string contains only alphabetic characters.

assert_string_is_alphanumeric
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    static func assert_string_is_alphanumeric(
        string: String,
        message: String = ""
    ) -> bool

Assert that string contains only alphanumeric characters.

Usage Examples
--------------

Basic Test with Assertions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: gdscript

    extends GDTest
    
    func test_player_movement():
        var player = Player.new()
        player.move(Vector2(10, 0))
        
        # Math assertions
        assert_vector2_equals(player.position, Vector2(10, 0), 0.1)
        assert_float_positive(player.velocity.x)
        
        # Collection assertions
        assert_array_not_empty(player.movement_history)
        assert_array_contains(player.movement_history, Vector2(10, 0))
        
        # String assertions
        assert_string_equals(player.state, "moving")

Complex Validation
~~~~~~~~~~~~~~~~~~

.. code-block:: gdscript

    func test_inventory_system():
        var inventory = Inventory.new()
        inventory.add_item("sword", 1)
        inventory.add_item("potion", 5)
        
        # Dictionary assertions
        assert_dict_has_key(inventory.items, "sword")
        assert_dict_size(inventory.items, 2)
        
        # Array assertions
        var item_names = inventory.get_item_names()
        assert_array_contains(item_names, "sword")
        assert_array_sorted(item_names)
        
        # Math assertions
        var total_weight = inventory.get_total_weight()
        assert_float_in_range(total_weight, 0.0, 100.0)

Custom Error Messages
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: gdscript

    func test_with_custom_messages():
        var damage = calculate_damage(player, enemy)
        
        assert_float_positive(
            damage,
            "Damage should be positive when player attacks enemy"
        )
        
        assert_float_in_range(
            damage,
            10.0,
            100.0,
            "Damage should be between 10 and 100 for this weapon"
        )

Best Practices
--------------

Tolerance Selection
~~~~~~~~~~~~~~~~~~~

**Floating Point Comparisons**:

- Use ``0.0001`` for general float comparisons
- Use ``0.001`` for physics calculations
- Use ``0.01`` for UI positioning
- Use ``0.1`` for loose gameplay validation

**Vector Comparisons**:

- Use ``0.1`` for position comparisons
- Use ``0.01`` for direction vectors
- Use ``0.001`` for normalized vectors

Assertion Granularity
~~~~~~~~~~~~~~~~~~~~~

1. **One Assertion Per Concept**
   
   .. code-block:: gdscript

       # Good: Separate assertions for separate concepts
       assert_float_positive(health)
       assert_float_in_range(health, 0.0, 100.0)
       
       # Avoid: Combining multiple checks in one assertion

2. **Descriptive Messages**
   
   .. code-block:: gdscript

       # Good: Clear context
       assert_array_size(
           enemies,
           3,
           "Wave 1 should spawn exactly 3 enemies"
       )
       
       # Avoid: Generic or missing messages
       assert_array_size(enemies, 3)

3. **Test One Thing**
   
   .. code-block:: gdscript

       # Good: Focused test
       func test_player_takes_damage():
           player.take_damage(10)
           assert_float_equals(player.health, 90.0)
       
       # Avoid: Testing multiple unrelated things

Error Message Guidelines
~~~~~~~~~~~~~~~~~~~~~~~~

1. **Include Context**: What was being tested
2. **Include Expected**: What should have happened
3. **Include Actual**: What actually happened
4. **Include Why**: Why it matters (optional)

.. code-block:: gdscript

    assert_string_contains(
        log_output,
        "Player connected",
        "Server log should contain player connection message for multiplayer session tracking"
    )

Related Documentation
---------------------

- :doc:`../../architecture/reporter-systems` - Test reporting
- :doc:`../../architecture/advanced-test-types` - Performance and visual testing
- :doc:`../../architecture/testing-utilities` - Test utilities

Implementation Files
--------------------

- ``src/assertions/math_assertions.gd`` - Math assertions (42 functions)
- ``src/assertions/collection_assertions.gd`` - Collection assertions (28 functions)
- ``src/assertions/string_assertions.gd`` - String assertions (36 functions)
