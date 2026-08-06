Testing Utilities
=================

Overview
--------

GDSentry provides specialized utility classes for advanced testing scenarios.

**Available Utilities**:

- **MemoryProfiler** - Memory profiling and leak detection
- **DataDrivenTest** - Data-driven test execution
- **TestDataGenerator** - Test data generation
- **ScreenshotComparison** - Screenshot comparison utilities
- **TestScenarioTemplates** - Reusable test scenarios
- **OutputFormatter** - Test output formatting
- **FileSystemCompatibility** - Cross-version file operations

MemoryProfiler
--------------

**Location**: ``src/utilities/memory_profiler.gd``

**Purpose**: Advanced memory profiling and leak detection for comprehensive memory analysis.

Features
~~~~~~~~

- Real-time memory usage tracking with detailed statistics
- Intelligent leak detection algorithms with pattern recognition
- Memory growth analysis and trend detection
- Performance impact monitoring of memory operations
- Automated memory stress testing scenarios
- Memory usage pattern analysis and reporting

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    var profiler = MemoryProfiler.new()
    add_child(profiler)
    
    profiler.start_profiling("test_session")
    
    # Run test code
    for i in range(1000):
        var obj = MyObject.new()
    
    var report = profiler.stop_profiling()
    print("Peak memory: ", report.peak_memory_mb, " MB")

DataDrivenTest
--------------

**Location**: ``src/utilities/data_driven_test.gd``

**Purpose**: Execute tests with multiple data sets for comprehensive coverage.

Features
~~~~~~~~

- CSV and JSON data source support
- Parameterized test execution
- Data validation and transformation
- Result aggregation across data sets
- Failure isolation per data set

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    extends DataDrivenTest
    
    func test_damage_calculation():
        var test_data = [
            {"weapon": "sword", "armor": 10, "expected": 15},
            {"weapon": "axe", "armor": 5, "expected": 25}
        ]
        
        run_data_driven_test(test_data, func(data):
            var damage = calculate_damage(data.weapon, data.armor)
            assert_equals(damage, data.expected)
        )

TestDataGenerator
-----------------

**Location**: ``src/utilities/test_data_generator.gd``

**Purpose**: Generate realistic test data for comprehensive testing.

Features
~~~~~~~~

- Random data generation with constraints
- Realistic name, email, address generation
- Numeric data with statistical distributions
- Date and time generation
- Custom generator registration

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    var generator = TestDataGenerator.new()
    
    var player_name = generator.generate_name()
    var player_email = generator.generate_email()
    var player_level = generator.generate_int(1, 100)
    var damage = generator.generate_normal(50.0, 10.0)

ScreenshotComparison
--------------------

**Location**: ``src/utilities/screenshot_comparison.gd``

**Purpose**: Advanced screenshot comparison utilities for visual testing.

Features
~~~~~~~~

- Multiple comparison algorithms
- Difference highlighting and visualization
- Region-of-interest comparison
- Configurable tolerance levels
- Diff image generation

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    var comparator = ScreenshotComparison.new()
    
    var baseline = load_image("baseline.png")
    var current = capture_screenshot()
    
    var result = comparator.compare(baseline, current, 0.02)
    
    if not result.matches:
        comparator.generate_diff_image(baseline, current, "diff.png")

TestScenarioTemplates
---------------------

**Location**: ``src/utilities/test_scenario_templates.gd``

**Purpose**: Reusable test scenario templates for common testing patterns.

Features
~~~~~~~~

- Pre-built test scenarios for common patterns
- Customizable templates
- Common game testing patterns
- Automated setup and teardown

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    var template = TestScenarioTemplates.new()
    
    var scenario = template.create_combat_scenario({
        "player_health": 100,
        "enemy_count": 3,
        "enemy_type": "goblin"
    })
    
    scenario.execute()
    assert_true(scenario.player.is_alive())

OutputFormatter
---------------

**Location**: ``src/utilities/output_formatter.gd``

**Purpose**: Format test output for enhanced readability.

Features
~~~~~~~~

- Color-coded output
- Progress indicators
- Table formatting
- Tree structure display

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    var formatter = OutputFormatter.new()
    
    formatter.print_header("Test Suite: Player Tests")
    formatter.print_success("✓ test_player_movement")
    formatter.print_failure("✗ test_player_combat")

FileSystemCompatibility
-----------------------

**Location**: ``src/utilities/file_system_compatibility.gd``

**Purpose**: Cross-version file system operations for Godot 3.x and 4.x compatibility.

Features
~~~~~~~~

- Godot 3.x and 4.x compatibility layer
- Safe file operations with error handling
- Path normalization
- Directory management utilities

Usage Example
~~~~~~~~~~~~~

.. code-block:: gdscript

    var fs = load("res://src/utilities/file_system_compatibility.gd")
    
    var file = fs.open_file("res://data.json", FileAccess.READ)
    if file:
        var content = file.get_as_text()
        file.close()

Best Practices
--------------

Memory Profiling
~~~~~~~~~~~~~~~~

1. **Profile in Release Builds** - Debug builds have different memory characteristics
2. **Establish Baselines** - Know normal memory usage patterns
3. **Isolate Tests** - Profile one feature at a time
4. **Multiple Runs** - Average results across multiple runs
5. **Clean Up** - Ensure proper cleanup between tests

Data-Driven Testing
~~~~~~~~~~~~~~~~~~~

1. **Separate Data from Logic** - Keep test data in external files
2. **Validate Data** - Check data format before execution
3. **Descriptive Data** - Include meaningful identifiers
4. **Edge Cases** - Include boundary and error cases
5. **Maintainable** - Keep data sets manageable

Related Documentation
---------------------

- :doc:`reporter-systems` - Test reporting architecture
- :doc:`advanced-test-types` - Performance and visual testing
- :doc:`../api/gdscript/assertions` - Assertion API reference

Implementation Files
--------------------

- ``src/utilities/memory_profiler.gd``
- ``src/utilities/data_driven_test.gd``
- ``src/utilities/test_data_generator.gd``
- ``src/utilities/screenshot_comparison.gd``
- ``src/utilities/test_scenario_templates.gd``
- ``src/utilities/output_formatter.gd``
- ``src/utilities/file_system_compatibility.gd``
