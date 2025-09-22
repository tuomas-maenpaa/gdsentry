:orphan:

Configuration Guide
===================

GDSentry uses a flexible configuration system that allows you to customize test discovery, execution, performance thresholds, and reporting to match your project's specific needs and workflow requirements.

.. admonition:: Quick Configuration
   :class: tip

   **Just want to get started?** GDSentry works with zero configuration!

   The configuration system is **optional** and designed for teams that need:
   - Custom test discovery patterns
   - Performance thresholds
   - CI/CD integration
   - Team-specific reporting formats

Configuration Methods
=====================

GDSentry supports multiple configuration approaches, listed in order of precedence:

1. **Command-line arguments** (highest priority)
2. **Configuration files** (``.tres`` resource files)
3. **Environment variables**
4. **Built-in defaults** (lowest priority)

This hierarchy allows you to have base configurations in files while overriding specific settings for different environments.

Configuration Files
===================

Configuration files use Godot's ``.tres`` (text resource) format, making them version-controllable and easily editable.

Basic Configuration Setup
-------------------------

**Option 1: Through Godot Editor (Recommended)**

1. In Godot Editor: **File → New Resource**
2. Search for and select **"GDTestConfig"**
3. Configure properties in the Inspector
4. Save as ``res://gdsentry_config.tres``

**Option 2: Manual File Creation**

Create ``res://gdsentry_config.tres``:

.. code-block:: gdscript
   :caption: Basic configuration file

   [gd_resource type="Resource" script_class="GDTestConfig" load_steps=2 format=3]

   [ext_resource type="Script" path="res://gdsentry/core/test_config.gd" id="1"]

   [resource]
   script = ExtResource("1")
   test_directories = Array[String](["res://tests/"])
   recursive_discovery = true
   discovery_patterns = Array[String](["*_test.gd"])

Configuration Sections
======================

Test Discovery Settings
-----------------------

Control how GDSentry finds and loads your tests:

.. code-block:: gdscript
   :caption: Test discovery configuration

   # Directories to search for tests
   test_directories = Array[String]([
       "res://tests/",
       "res://integration_tests/",
       "res://performance_tests/"
   ])

   # Whether to search subdirectories
   recursive_discovery = true

   # File patterns that identify test files
   discovery_patterns = Array[String]([
       "*_test.gd",
       "test_*.gd",
       "*Tests.gd"
   ])

   # Patterns to exclude from discovery
   exclusion_patterns = Array[String]([
       "**/.*",           # Hidden files
       "**/node_modules/**", # Dependencies
       "**/build/**"      # Build artifacts
   ])

   # Maximum directory depth for recursive discovery
   max_discovery_depth = 5

**When to customize:**
- Multiple test directory structures
- Non-standard test file naming
- Need to exclude specific directories
- Performance issues with deep directory structures

Test Execution Settings
-----------------------

Control how tests are executed:

.. code-block:: gdscript
   :caption: Execution configuration

   execution_policies = {
       # Run tests in parallel for faster execution
       "parallel_execution": true,

       # Stop on first test failure
       "fail_fast": false,

       # Randomize test order to catch dependencies
       "randomize_order": false,

       # Maximum number of parallel test runners
       "max_parallel_runners": 4,

       # Retry failed tests (useful for flaky tests)
       "retry_failed_tests": false,
       "max_retries": 2
   }

   # Global timeout settings
   timeout_settings = {
       # Default timeout for individual tests (seconds)
       "test_timeout": 30.0,

       # Timeout for entire test suite (seconds)
       "suite_timeout": 300.0,

       # Timeout for test setup/teardown (seconds)
       "setup_timeout": 10.0
   }

**When to customize:**
- CI/CD environments with time constraints
- Flaky tests requiring retry logic
- Performance testing requiring longer timeouts
- Debugging specific test execution issues

Performance Thresholds
----------------------

Set performance expectations for your game:

.. code-block:: gdscript
   :caption: Performance thresholds

   performance_thresholds = {
       # Frame rate expectations
       "min_fps": 30.0,
       "target_fps": 60.0,

       # Memory usage limits (MB)
       "max_memory_usage": 512.0,
       "memory_leak_threshold": 50.0,

       # Load time expectations (seconds)
       "max_scene_load_time": 2.0,
       "max_startup_time": 5.0,

       # CPU/GPU usage limits (percentage)
       "max_cpu_usage": 80.0,
       "max_gpu_usage": 85.0
   }

   # Benchmark settings
   benchmark_settings = {
       # Number of iterations for performance tests
       "benchmark_iterations": 10,

       # Warm-up iterations before measurement
       "warmup_iterations": 3,

       # Statistical confidence level
       "confidence_level": 0.95
   }

Output and Reporting
--------------------

Configure test output and report generation:

.. code-block:: gdscript
   :caption: Reporting configuration

   report_settings = {
       # Output formats: console, html, junit, json, xml
       "formats": Array[String](["console", "html", "junit"]),

       # Output directory for reports
       "output_directory": "res://test_reports/",

       # Include performance metrics in reports
       "include_performance_data": true,

       # Include code coverage information
       "include_coverage": false,

       # Report detail level: minimal, normal, verbose
       "detail_level": "normal"
   }

   # Console output customization
   console_output = {
       # Show passing tests in output
       "show_passing_tests": true,

       # Use color in console output
       "use_colors": true,

       # Show execution time for each test
       "show_execution_time": true,

       # Show test metadata (tags, priority)
       "show_metadata": false
   }

Test Type Specific Settings
---------------------------

Different test types may need specific configuration:

.. code-block:: gdscript
   :caption: Test type configurations

   # Visual/UI testing settings
   visual_test_settings = {
       # Default viewport size for visual tests
       "viewport_size": Vector2(1920, 1080),

       # Enable/disable VSync for consistent timing
       "disable_vsync": true,

       # Screenshot comparison tolerance
       "image_comparison_tolerance": 0.02,

       # Wait time for UI stabilization (seconds)
       "ui_stabilization_time": 0.5
   }

   # Physics testing settings
   physics_test_settings = {
       # Physics iterations per test frame
       "physics_iterations": 8,

       # Fixed delta time for consistent physics
       "fixed_delta_time": 0.016667,  # 60 FPS

       # Collision detection precision
       "collision_precision": 0.001
   }

   # Performance testing settings
   performance_test_settings = {
       # Disable debug features for accurate measurement
       "disable_debug_output": true,

       # Force garbage collection before tests
       "force_gc_before_tests": true,

       # Profile memory allocations
       "profile_memory": true
   }

Configuration Profiles
======================

Profiles provide pre-configured settings for common scenarios:

Built-in Profiles
-----------------

.. code-block:: bash

   # CI/CD optimized profile
   --profile ci
   # Equivalent to:
   # --parallel --fail-fast --report junit,json --no-colors

   # Development profile
   --profile development
   # Equivalent to:
   # --verbose --show-passing --use-colors

   # Performance testing profile
   --profile performance
   # Equivalent to:
   # --disable-vsync --force-gc --profile-memory

   # Visual regression testing
   --profile visual
   # Equivalent to:
   # --viewport-size 1920x1080 --disable-vsync

   # Quick smoke tests
   --profile smoke
   # Equivalent to:
   # --filter tags:smoke --fail-fast

Custom Profiles
---------------

Create custom profiles by defining them in your configuration file:

.. code-block:: gdscript
   :caption: Custom profile definitions

   custom_profiles = {
       "mobile_testing": {
           "visual_test_settings": {
               "viewport_size": Vector2(1080, 1920)  # Portrait mobile
           },
           "performance_thresholds": {
               "min_fps": 30.0,  # Lower FPS target for mobile
               "max_memory_usage": 256.0  # Tighter memory constraints
           }
       },

       "nightly_tests": {
           "execution_policies": {
               "parallel_execution": true,
               "randomize_order": true
           },
           "report_settings": {
               "formats": Array[String](["html", "junit", "json"]),
               "include_performance_data": true,
               "include_coverage": true
           }
       }
   }

Environment Variables
=====================

Override configuration settings using environment variables:

.. code-block:: bash
   :caption: Environment variable examples

   # Override test directories
   export GDSENTRY_TEST_DIRS="res://tests/,res://integration/"

   # Set execution mode
   export GDSENTRY_PARALLEL=true
   export GDSENTRY_FAIL_FAST=true

   # Configure reporting
   export GDSENTRY_REPORT_FORMAT="junit,html"
   export GDSENTRY_REPORT_DIR="build/test-results/"

   # Performance settings
   export GDSENTRY_FPS_THRESHOLD=60
   export GDSENTRY_MEMORY_LIMIT=512

**Common environment variables:**

.. list-table:: Common Environment Variables
   :header-rows: 1
   :widths: 30 40 30

   * - Variable
     - Purpose
     - Example
   * - ``GDSENTRY_TEST_DIRS``
     - Test directories
     - ``res://tests/``
   * - ``GDSENTRY_PARALLEL``
     - Enable parallel execution
     - ``true``
   * - ``GDSENTRY_FAIL_FAST``
     - Stop on first failure
     - ``true``
   * - ``GDSENTRY_VERBOSE``
     - Verbose output
     - ``true``
   * - ``GDSENTRY_REPORT_FORMAT``
     - Report formats
     - ``junit,html``

Practical Configuration Examples
================================

Development Team Configuration
------------------------------

.. code-block:: gdscript
   :caption: team_config.tres - Shared team settings

   [resource]
   script = ExtResource("1")

   # Standard test discovery
   test_directories = Array[String](["res://tests/"])
   recursive_discovery = true
   discovery_patterns = Array[String](["*_test.gd"])

   # Development-friendly execution
   execution_policies = {
       "parallel_execution": false,  # Easier debugging
       "fail_fast": true,           # Quick feedback
       "randomize_order": false     # Predictable order
   }

   # Reasonable timeouts for development
   timeout_settings = {
       "test_timeout": 30.0,
       "suite_timeout": 600.0  # 10 minutes max
   }

   # Console output optimized for development
   console_output = {
       "show_passing_tests": true,
       "use_colors": true,
       "show_execution_time": true,
       "show_metadata": true
   }

CI/CD Configuration
-------------------

.. code-block:: gdscript
   :caption: ci_config.tres - Optimized for automated testing

   [resource]
   script = ExtResource("1")

   # Comprehensive test discovery
   test_directories = Array[String]([
       "res://tests/",
       "res://integration_tests/"
   ])

   # Fast execution for CI
   execution_policies = {
       "parallel_execution": true,
       "fail_fast": true,
       "max_parallel_runners": 8
   }

   # Stricter timeouts for CI
   timeout_settings = {
       "test_timeout": 60.0,
       "suite_timeout": 900.0  # 15 minutes max
   }

   # CI-friendly reporting
   report_settings = {
       "formats": Array[String](["junit", "json"]),
       "output_directory": "build/test-results/",
       "include_performance_data": true,
       "detail_level": "minimal"
   }

   console_output = {
       "use_colors": false,  # Better for CI logs
       "show_passing_tests": false  # Reduce noise
   }

Performance Testing Configuration
---------------------------------

.. code-block:: gdscript
   :caption: performance_config.tres - Optimized for performance testing

   [resource]
   script = ExtResource("1")

   # Only performance tests
   test_directories = Array[String](["res://tests/performance/"])
   discovery_patterns = Array[String](["*_performance_test.gd"])

   # Sequential execution for accurate measurement
   execution_policies = {
       "parallel_execution": false,
       "fail_fast": false  # Run all performance tests
   }

   # Extended timeouts for performance tests
   timeout_settings = {
       "test_timeout": 120.0,  # 2 minutes per test
       "suite_timeout": 3600.0  # 1 hour max
   }

   # Strict performance thresholds
   performance_thresholds = {
       "min_fps": 60.0,
       "max_memory_usage": 256.0,
       "max_scene_load_time": 1.0
   }

   # Performance-optimized settings
   performance_test_settings = {
       "disable_debug_output": true,
       "force_gc_before_tests": true,
       "profile_memory": true
   }

   # Detailed performance reporting
   report_settings = {
       "formats": Array[String](["html", "json"]),
       "include_performance_data": true,
       "detail_level": "verbose"
   }

Using Configuration Files
=========================

Command Line Usage
------------------

.. code-block:: bash

   # Use specific configuration file
   godot --script gdsentry/core/test_runner.gd --config res://ci_config.tres --discover

   # Use configuration with profile
   godot --script gdsentry/core/test_runner.gd --config res://team_config.tres --profile development

   # Override configuration with command-line arguments
   godot --script gdsentry/core/test_runner.gd --config res://team_config.tres --parallel --verbose

Multiple Configuration Files
----------------------------

You can maintain different configuration files for different purposes:

.. code-block:: text

   your_project/
   ├── gdsentry_config.tres        # Default configuration
   ├── ci_config.tres           # CI/CD configuration
   ├── performance_config.tres  # Performance testing
   ├── mobile_config.tres       # Mobile testing
   └── debug_config.tres        # Debugging configuration

Configuration Validation
========================

GDSentry validates configuration files on startup and provides helpful error messages:

.. code-block:: text

   ERROR: Invalid configuration in ci_config.tres
   - max_parallel_runners must be between 1 and 16 (found: 32)
   - output_directory path does not exist: invalid/path/
   - Unknown report format: 'excel' (valid: console, html, junit, json, xml)

   Use --validate-config to check configuration without running tests

Validation Command
------------------

.. code-block:: bash

   # Validate configuration file
   godot --script gdsentry/core/test_runner.gd --config my_config.tres --validate-config

   # Validate with specific profile
   godot --script gdsentry/core/test_runner.gd --config my_config.tres --profile ci --validate-config

Configuration Tips and Best Practices
=====================================

Version Control
---------------

**✅ Do commit:**
- Base configuration files (``gdsentry_config.tres``)
- Team-shared configurations (``team_config.tres``)
- CI/CD configurations (``ci_config.tres``)

**❌ Don't commit:**
- Personal configuration files (``my_local_config.tres``)
- Files with sensitive information
- Temporary debugging configurations

Performance Considerations
--------------------------

1. **Parallel execution** can speed up tests but may cause issues with:
   - Tests that modify global state
   - File system operations
   - Resource contention

2. **Test discovery** performance:
   - Limit ``max_discovery_depth`` for deep directory structures
   - Use specific ``test_directories`` instead of searching entire project
   - Optimize ``discovery_patterns`` to be as specific as possible

3. **Memory management**:
   - Enable ``force_gc_before_tests`` for performance tests
   - Set appropriate ``max_memory_usage`` thresholds
   - Monitor memory leaks with ``memory_leak_threshold``

Common Patterns
---------------

**Development Configuration:**
- Verbose output for debugging
- Sequential execution for predictable results
- Longer timeouts for debugging sessions
- Show all test metadata

**CI/CD Configuration:**
- Parallel execution for speed
- Fail-fast for quick feedback
- Minimal output to reduce log noise
- Multiple report formats for different tools

**Performance Configuration:**
- Sequential execution for accurate measurement
- Disabled debug features
- Extended timeouts
- Detailed performance reporting

**Mobile Testing Configuration:**
- Mobile-specific viewport sizes
- Lower performance thresholds
- Memory-conscious settings
- Device-specific test patterns

Troubleshooting Configuration
=============================

Common Issues
-------------

**Configuration file not found:**

.. code-block:: bash

   ERROR: Configuration file not found: res://gdsentry_config.tres

**Solution:** Ensure the file exists and uses correct ``res://`` path.

**Invalid configuration format:**

.. code-block:: bash

   ERROR: Failed to load configuration: Expected GDTestConfig resource

**Solution:** Verify the file was created as a GDTestConfig resource, not a generic Resource.

**Profile not found:**

.. code-block:: bash

   ERROR: Unknown profile 'my_profile'. Available profiles: ci, development, performance, visual, smoke

**Solution:** Check profile name spelling or define custom profile in configuration file.

For more troubleshooting help, see :doc:`troubleshooting`.

Advanced Configuration Topics
=============================

For advanced configuration topics including:

- **Custom test runners** and execution strategies
- **Plugin system** configuration
- **Integration** with external tools
- **Custom assertion** configuration
- **Continuous monitoring** setup

See the :doc:`advanced/fixtures` and :doc:`tutorials/ci-integration` guides.

Related Documentation
=====================

- :doc:`getting-started` - Basic setup and installation
- :doc:`api/test-runner` - Complete command-line reference
- :doc:`tutorials/ci-integration` - CI/CD integration examples
- :doc:`troubleshooting` - Solutions for configuration issues
- :doc:`best-practices` - Testing best practices and patterns
