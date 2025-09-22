Configuration Guide
===================

GDSentry uses a comprehensive configuration system that allows you to customize test discovery, execution, performance thresholds, and reporting to match your project's specific needs and workflow requirements.

Configuration Overview
======================

GDSentry supports configuration through:

1. **Configuration Files** (``.tres`` resource files)
2. **Command-line Profiles** (ci, development, performance, visual, smoke)
3. **Environment Variables** for runtime overrides
4. **Default Fallbacks** when no configuration is specified

Configuration files are stored as Godot ``.tres`` (text resource) files, making them version-controllable and easily editable.

Basic Configuration Setup
=========================

Creating a Configuration File
-----------------------------

1. In Godot Editor, create a new resource:
   - **File → New Resource**
   - Search for "GDTestConfig"
   - Save as ``res://gdsentry_config.tres`` or your preferred name

2. Configure the resource properties in the Inspector

3. Use the configuration:
   .. code-block:: bash

      godot --script gdsentry/core/test_runner.gd --config res://gdsentry_config.tres --discover

Minimal Working Configuration
-----------------------------

.. code-block:: gdscript

   # res://gdsentry_config.tres (minimal)
   [gd_resource type="Resource" script_class="GDTestConfig" load_steps=2 format=3]

   [ext_resource type="Script" path="res://gdsentry/core/test_config.gd" id="1"]

   [resource]
   script = ExtResource("1")
   test_directories = Array[String](["res://tests/"])
   recursive_discovery = true
   discovery_patterns = Array[String](["*_test.gd"])
   exclude_patterns = Array[String]([])
   execution_policies = {
       "stop_on_failure": false,
       "parallel_execution": false,
       "randomize_order": false,
       "fail_fast": false
   }
   timeout_settings = {
       "test_timeout": 30.0,
       "suite_timeout": 300.0,
       "global_timeout": 600.0
   }
   performance_thresholds = {
       "min_fps": 30,
       "max_memory_mb": 100,
       "max_objects": 10000,
       "max_physics_steps": 1000
   }
   output_settings = {
       "verbose": false,
       "show_progress": true,
       "show_timestamps": true,
       "color_output": true,
       "log_level": "INFO"
   }
   report_settings = {
       "enabled": true,
       "formats": Array[String](["json"]),
       "output_directory": "res://test_reports/",
       "include_screenshots": false,
       "include_metadata": true,
       "include_performance_data": true,
       "pretty_print": true,
       "timestamp_format": "%Y-%m-%d %H:%M:%S"
   }

Configuration Sections
======================

Test Discovery Configuration
----------------------------

**test_directories**: Array[String]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Directories to scan for test files.

.. code-block:: gdscript

   test_directories = [
       "res://tests/",
       "res://game/tests/",
       "res://addons/my_plugin/tests/"
   ]

**recursive_discovery**: bool
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Whether to scan subdirectories recursively.

.. code-block:: gdscript

   recursive_discovery = true  # Scan all subdirectories

**discovery_patterns**: Array[String]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File patterns to match for test discovery.

.. code-block:: gdscript

   discovery_patterns = ["*_test.gd", "*_spec.gd", "*Test.gd"]

**exclude_patterns**: Array[String]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File patterns to exclude from discovery.

.. code-block:: gdscript

   exclude_patterns = ["*.backup", "*_disabled.gd", "temp/*"]

Test Execution Configuration
----------------------------

**execution_policies**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Control how tests are executed.

.. code-block:: gdscript

   execution_policies = {
       "stop_on_failure": false,      # Continue after failures
       "parallel_execution": true,    # Run tests in parallel
       "randomize_order": false,      # Randomize test order
       "fail_fast": false            # Stop on first failure
   }

**timeout_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Timeout values for different execution levels.

.. code-block:: gdscript

   timeout_settings = {
       "test_timeout": 30.0,      # Individual test timeout (seconds)
       "suite_timeout": 300.0,    # Test suite timeout (seconds)
       "global_timeout": 600.0    # Total execution timeout (seconds)
   }

**retry_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure automatic retry behavior for flaky tests.

.. code-block:: gdscript

   retry_settings = {
       "max_retries": 3,              # Maximum retry attempts
       "retry_delay": 1.0,            # Delay between retries (seconds)
       "retry_on_failure_only": true  # Only retry failed tests
   }

Performance Configuration
-------------------------

**performance_thresholds**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Performance requirements and limits.

.. code-block:: gdscript

   performance_thresholds = {
       "min_fps": 60,              # Minimum acceptable FPS
       "max_memory_mb": 256,       # Maximum memory usage (MB)
       "max_objects": 50000,       # Maximum scene objects
       "max_physics_steps": 2000   # Maximum physics steps per frame
   }

**benchmark_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure benchmark test behavior.

.. code-block:: gdscript

   benchmark_settings = {
       "warmup_iterations": 10,       # Iterations to warm up before benchmarking
       "benchmark_iterations": 100,   # Number of benchmark iterations
       "performance_tolerance": 0.05  # Acceptable performance variation (5%)
   }

Output and Reporting Configuration
----------------------------------

**output_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Control console output behavior.

.. code-block:: gdscript

   output_settings = {
       "verbose": true,               # Detailed output
       "show_progress": true,         # Show progress bar
       "show_timestamps": true,       # Include timestamps
       "color_output": true,          # Colored console output
       "log_level": "DEBUG"           # Logging level (DEBUG, INFO, WARN, ERROR)
   }

**report_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure test report generation.

.. code-block:: gdscript

   report_settings = {
       "enabled": true,
       "formats": ["json", "html", "junit"],  # Report formats
       "output_directory": "res://test_reports/",
       "include_screenshots": true,           # Include screenshots in reports
       "include_metadata": true,              # Include test metadata
       "include_performance_data": true,      # Include performance metrics
       "pretty_print": true,                  # Pretty-print JSON output
       "timestamp_format": "%Y-%m-%d %H:%M:%S"
   }

Advanced Report Configuration
-----------------------------

**reporter_config**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Detailed configuration for each report format.

JUnit Configuration
-------------------
.. code-block:: gdscript

   "junit": {
       "include_system_out": false,        # Include stdout in report
       "include_system_err": true,         # Include stderr in report
       "include_properties": true,         # Include system properties
       "suite_name_template": "GDSentry.{category}",
       "test_name_template": "{class}.{test_name}"
   }

HTML Configuration
------------------
.. code-block:: gdscript

   "html": {
       "include_charts": true,             # Include performance charts
       "include_environment_info": true,   # Include system information
       "include_assertion_details": true,  # Include assertion details
       "max_error_length": 500,            # Maximum error message length
       "theme": "default",                 # Report theme
       "include_search": true,             # Include search functionality
       "include_filters": true             # Include filtering options
   }

JSON Configuration
------------------
.. code-block:: gdscript

   "json": {
       "include_assertion_details": true,  # Include assertion details
       "include_system_info": true,        # Include system information
       "include_environment_data": true,   # Include environment data
       "flatten_results": false,           # Flatten nested results
       "group_by_category": true           # Group by test category
   }

Visual Testing Configuration
----------------------------

**visual_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure visual regression testing.

.. code-block:: gdscript

   visual_settings = {
       "screenshot_directory": "res://test_screenshots/",
       "screenshot_format": "PNG",         # PNG, JPEG, WEBP
       "visual_tolerance": 0.01,           # Pixel difference tolerance (0-1)
       "baseline_directory": "res://test_screenshots/baseline/",
       "generate_diff_images": true        # Generate visual diff images
   }

**accessibility_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure accessibility testing features.

.. code-block:: gdscript

   accessibility_settings = {
       "check_contrast": true,             # Check color contrast ratios
       "check_keyboard_navigation": true,  # Verify keyboard navigation
       "check_screen_reader": false,       # Screen reader compatibility
       "minimum_contrast_ratio": 4.5       # WCAG AA standard
   }

Physics Testing Configuration
-----------------------------

**physics_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure physics simulation parameters.

.. code-block:: gdscript

   physics_settings = {
       "simulation_speed": 1.0,            # Physics simulation speed multiplier
       "collision_tolerance": 1.0,         # Collision detection tolerance (pixels)
       "physics_fps": 60,                  # Target physics FPS
       "fixed_timestep": true              # Use fixed timestep
   }

**collision_settings**: Dictionary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure collision detection testing.

.. code-block:: gdscript

   collision_settings = {
       "layer_mask_check": true,           # Verify collision layer masks
       "collision_shape_validation": true, # Validate collision shapes
       "overlap_tolerance": 0.1            # Acceptable overlap tolerance
   }

Configuration Profiles
======================

GDSentry includes predefined configuration profiles optimized for different use cases. Profiles can be used via command line or as starting points for custom configurations.

CI Profile
----------

Optimized for continuous integration environments.

**Characteristics:**
- Parallel execution enabled
- Fail-fast behavior
- Extended timeouts
- JUnit reporting for CI integration

.. code-block:: gdscript

   # Equivalent to --profile ci
   execution_policies = {
       "parallel_execution": true,
       "fail_fast": true
   }
   output_settings["verbose"] = true
   report_settings["formats"] = ["junit"]
   timeout_settings["test_timeout"] = 60.0

Development Profile
-------------------

Optimized for local development and debugging.

**Characteristics:**
- Verbose output for detailed feedback
- Screenshots for visual debugging
- Relaxed performance thresholds
- Sequential execution for stability

.. code-block:: gdscript

   # Equivalent to --profile development
   output_settings["verbose"] = true
   visual_settings["include_screenshots"] = true
   performance_thresholds["max_memory_mb"] = 500
   execution_policies["stop_on_failure"] = false

Performance Profile
-------------------

Optimized for performance benchmarking and profiling.

**Characteristics:**
- High iteration counts for accurate benchmarks
- Strict performance requirements
- Sequential execution to avoid interference
- Detailed performance reporting

.. code-block:: gdscript

   # Equivalent to --profile performance
   benchmark_settings["benchmark_iterations"] = 1000
   performance_thresholds["min_fps"] = 60
   execution_policies["parallel_execution"] = false
   output_settings["verbose"] = true

Visual Profile
--------------

Optimized for visual regression and UI testing.

**Characteristics:**
- High visual accuracy requirements
- Accessibility checking enabled
- Diff image generation
- Keyboard navigation testing

.. code-block:: gdscript

   # Equivalent to --profile visual
   visual_settings = {
       "generate_diff_images": true,
       "visual_tolerance": 0.001
   }
   accessibility_settings = {
       "check_contrast": true,
       "check_keyboard_navigation": true
   }

Smoke Profile
-------------

Optimized for quick smoke tests and basic validation.

**Characteristics:**
- Limited test scope (smoke tests only)
- Fast execution with short timeouts
- Fail-fast to catch critical issues quickly
- Minimal reporting

.. code-block:: gdscript

   # Equivalent to --profile smoke
   test_directories = ["res://tests/smoke/"]
   execution_policies["stop_on_failure"] = true
   timeout_settings["test_timeout"] = 10.0

Environment-Specific Configurations
===================================

Different environments often require different configurations. Here are common patterns:

Local Development Configuration
-------------------------------

.. code-block:: gdscript

   # res://gdsentry_config_dev.tres
   [resource]
   script = ExtResource("1")

   # Relaxed settings for development
   execution_policies = {
       "stop_on_failure": false,
       "parallel_execution": false,  # Sequential for easier debugging
       "fail_fast": false
   }

   output_settings = {
       "verbose": true,
       "color_output": true
   }

   # Include screenshots for visual debugging
   visual_settings = {
       "include_screenshots": true
   }

   # Higher memory limits for development
   performance_thresholds = {
       "max_memory_mb": 512
   }

CI/CD Configuration
-------------------

.. code-block:: gdscript

   # res://gdsentry_config_ci.tres
   [resource]
   script = ExtResource("1")

   # Optimized for CI environments
   execution_policies = {
       "parallel_execution": true,
       "fail_fast": true,
       "randomize_order": true
   }

   timeout_settings = {
       "test_timeout": 60.0,
       "global_timeout": 600.0
   }

   # CI-friendly reporting
   report_settings = {
       "formats": ["junit", "json"],
       "output_directory": "user://test_results/",
       "include_performance_data": true
   }

   # Stricter performance requirements for CI
   performance_thresholds = {
       "min_fps": 30,
       "max_memory_mb": 200
   }

Production Testing Configuration
--------------------------------

.. code-block:: gdscript

   # res://gdsentry_config_prod.tres
   [resource]
   script = ExtResource("1")

   # Comprehensive testing for production
   test_directories = [
       "res://tests/unit/",
       "res://tests/integration/",
       "res://tests/performance/"
   ]

   execution_policies = {
       "parallel_execution": true,
       "randomize_order": true,
       "fail_fast": false
   }

   # Extensive reporting
   report_settings = {
       "formats": ["html", "json", "junit"],
       "include_screenshots": true,
       "include_performance_data": true,
       "include_metadata": true
   }

   # Strict performance requirements
   performance_thresholds = {
       "min_fps": 60,
       "max_memory_mb": 150
   }

   benchmark_settings = {
       "benchmark_iterations": 1000,
       "performance_tolerance": 0.02
   }

Environment Variables
=====================

GDSentry supports environment variable overrides for runtime configuration:

GDSENTRY_CONFIG
-------------
Path to the default configuration file.

.. code-block:: bash

   export GDSENTRY_CONFIG="res://my_config.tres"
   godot --script gdsentry/core/test_runner.gd --discover

GDSENTRY_PROFILE
--------------
Default configuration profile.

.. code-block:: bash

   export GDSENTRY_PROFILE="ci"
   godot --script gdsentry/core/test_runner.gd --discover

GDSENTRY_REPORT_PATH
------------------
Default report output directory.

.. code-block:: bash

   export GDSENTRY_REPORT_PATH="user://reports/"
   godot --script gdsentry/core/test_runner.gd --report html --discover

Configuration Loading Priority
==============================

GDSentry loads configuration in this order (later sources override earlier ones):

1. **Built-in defaults** - GDSentry's default configuration
2. **Configuration file** - Loaded from ``--config`` parameter or ``GDSENTRY_CONFIG``
3. **Profile overrides** - Applied from ``--profile`` parameter or ``GDSENTRY_PROFILE``
4. **Command-line overrides** - Individual CLI parameters
5. **Environment overrides** - Environment variable settings

This allows flexible configuration where you can have a base configuration file, override specific settings with profiles, and further customize with command-line options.

Advanced Configuration Techniques
=================================

Dynamic Configuration
---------------------

Load configuration based on environment or project settings:

.. code-block:: gdscript

   # In your test setup or project script
   func load_environment_config() -> GDTestConfig:
       var config = GDTestConfig.new()

       # Load base configuration
       config.load_from_file("res://gdsentry_config_base.tres")

       # Apply environment-specific overrides
       match OS.get_environment("ENV"):
           "development":
               config.execution_policies["parallel_execution"] = false
               config.output_settings["verbose"] = true
           "ci":
               config.execution_policies["parallel_execution"] = true
               config.report_settings["formats"] = ["junit"]
           "production":
               config.performance_thresholds["min_fps"] = 60

       return config

Configuration Validation
------------------------

Add validation to ensure configuration values are reasonable:

.. code-block:: gdscript

   func validate_config(config: GDTestConfig) -> bool:
       var valid = true

       # Validate timeouts are reasonable
       if config.timeout_settings["test_timeout"] < 1.0:
           print("❌ Test timeout too short")
           valid = false

       # Validate performance thresholds
       if config.performance_thresholds["min_fps"] <= 0:
           print("❌ Invalid FPS threshold")
           valid = false

       # Validate directories exist
       for dir_path in config.test_directories:
           if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir_path)):
               print("⚠️  Test directory does not exist: " + dir_path)

       return valid

Custom Profiles
---------------

Create project-specific configuration profiles:

.. code-block:: gdscript

   # res://scripts/test_config_extensions.gd
   extends GDTestConfig

   static func get_mobile_profile() -> GDTestConfig:
       """Profile optimized for mobile testing"""
       var config = GDTestConfig.get_profile_config("performance")
       config.performance_thresholds["min_fps"] = 30  # Lower for mobile
       config.performance_thresholds["max_memory_mb"] = 50  # Stricter memory limits
       config.visual_settings["screenshot_format"] = "JPEG"  # Smaller files
       return config

   static func get_vr_profile() -> GDTestConfig:
       """Profile optimized for VR testing"""
       var config = GDTestConfig.get_profile_config("visual")
       config.performance_thresholds["min_fps"] = 90  # Higher for VR
       config.physics_settings["physics_fps"] = 90
       return config

Troubleshooting Configuration Issues
====================================

Common Configuration Problems
-----------------------------

**Configuration not loading:**
- Verify the ``.tres`` file path is correct
- Ensure the file contains valid GDTestConfig resource
- Check Godot editor console for loading errors

**Profile not applying:**
- Verify profile name matches exactly (case-sensitive)
- Check that profile exists in ``get_profile_config()``
- Use ``--verbose`` to see configuration loading details

**Environment variables ignored:**
- Ensure variables are exported in the shell
- Check variable names match exactly
- Use ``env`` command to verify variables are set

**Performance thresholds too strict:**
- Adjust thresholds based on your target hardware
- Use different profiles for different environments
- Consider baseline performance measurements

Configuration File Examples
===========================

Complete Example Configurations
-------------------------------

Basic Project Configuration:

.. code-block:: gdscript

   [gd_resource type="Resource" script_class="GDTestConfig" load_steps=2 format=3]

   [ext_resource type="Script" path="res://gdsentry/core/test_config.gd" id="1"]

   [resource]
   script = ExtResource("1")

   # Test discovery
   test_directories = Array[String](["res://tests/", "res://game/scripts/tests/"])
   recursive_discovery = true
   discovery_patterns = Array[String](["*_test.gd", "*Test.gd"])
   exclude_patterns = Array[String](["*.tmp", "*_backup.gd"])

   # Execution
   execution_policies = {
       "parallel_execution": true,
       "fail_fast": false,
       "randomize_order": false
   }
   timeout_settings = {
       "test_timeout": 45.0,
       "suite_timeout": 600.0
   }

   # Performance
   performance_thresholds = {
       "min_fps": 30,
       "max_memory_mb": 256
   }

   # Output
   output_settings = {
       "verbose": true,
       "color_output": true
   }
   report_settings = {
       "formats": Array[String](["html", "json"]),
       "output_directory": "res://test_reports/"
   }

Game-Specific Configuration:

.. code-block:: gdscript

   [resource]
   script = ExtResource("1")

   # Game-specific test directories
   test_directories = Array[String]([
       "res://tests/unit/",
       "res://tests/integration/",
       "res://tests/battle_system/",
       "res://tests/ui/"
   ])

   # Game performance requirements
   performance_thresholds = {
       "min_fps": 60,              # 60 FPS requirement
       "max_memory_mb": 512,       # Higher memory for game assets
       "max_objects": 100000       # Large open worlds
   }

   # Visual testing for game UI
   visual_settings = {
       "screenshot_directory": "res://test_screenshots/",
       "visual_tolerance": 0.005,  # High precision for game UI
       "generate_diff_images": true
   }

   # Physics simulation settings
   physics_settings = {
       "physics_fps": 60,
       "collision_tolerance": 0.5
   }
