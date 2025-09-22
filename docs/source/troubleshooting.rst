Troubleshooting Guide
=====================

This guide helps you diagnose and resolve common issues when using GDSentry. Each section covers specific problem areas with step-by-step solutions.

Installation and Setup Issues
=============================

GDTestManager Autoload Not Found
--------------------------------

**Error:** ``"GDTestManager: Attempt to call function 'create_test_results' in base 'null instance' on a null instance"``

**Symptoms:**
- Tests fail immediately with null reference errors
- Console shows "GDTestManager not found" messages
- Test discovery doesn't work

**Solutions:**

1. **Verify Autoload Configuration:**

   - Open Project → Project Settings → AutoLoad tab
   - Ensure GDTestManager is listed with:

     - **Path:** ``res://gdsentry/core/test_manager.gd``
     - **Node Name:** ``GDTestManager``
     - **Enable** checkbox is checked

2. **Check File Path:**
   - Verify ``gdsentry/`` directory is in your project's root
   - Ensure ``core/test_manager.gd`` exists at the correct path
   - Check file permissions if on Unix systems

3. **Restart Godot:**
   - Close and reopen your Godot project
   - Autoload changes require a full restart

4. **Manual Verification:**

   .. code-block:: gdscript

      # In any script, verify autoload is available:
      func _ready():
         var test_manager = get_node("/root/GDTestManager")
         if test_manager:
            print("GDTestManager found!")
         else:
            print("ERROR: GDTestManager not found")

Class Not Found Errors
----------------------

**Error:** ``"Parse Error: Class 'SceneTreeTest' not found"``

**Symptoms:**
- Test files show parse errors
- Cannot extend GDSentry base classes
- Editor shows red error indicators

**Solutions:**

1. **Check GDSentry Installation:**
   - Verify ``gdsentry/`` directory is in your project root
   - Ensure all ``.gd`` files are present in ``gdsentry/base_classes/``
   - Check that ``project.godot`` doesn't exclude the gdsentry directory

2. **Verify Project Structure:**
   .. code-block::

      your_project/
      ├── project.godot
      ├── gdsentry/
      │   ├── base_classes/
      │   │   ├── gd_test.gd
      │   │   ├── scene_tree_test.gd
      │   │   └── node2d_test.gd
      │   └── core/
      └── scripts/

3. **Check Project Settings:**
   - Open Project → Project Settings
   - Verify "gdsentry" is not in the excluded directories list
   - Ensure script search paths include the project root

4. **Restart Godot Editor:**
   - Close and reopen the project
   - Sometimes Godot needs to re-scan for scripts

Test Discovery Problems
-----------------------

**Error:** ``"No tests found"`` or ``"Test discovery completed: 0 tests found"``

**Symptoms:**
- Test runner reports zero tests
- Test methods are not being discovered
- Console shows discovery but no execution

**Solutions:**

1. **Check File Naming:**
   - Test files must end with ``_test.gd``
   - Examples: ``player_test.gd``, ``ui_manager_test.gd``
   - Files ending with ``Test.gd`` also work

2. **Verify Class Inheritance:**

   - Test classes must extend GDSentry base classes:

     - ``extends SceneTreeTest``
     - ``extends Node2DTest``
     - ``extends UITest``
     - ``extends PerformanceTest``

3. **Check Method Names:**
   - Test methods must start with ``test_``
   - Examples: ``test_player_movement()``, ``test_calculate_damage()``
   - Private methods (starting with ``_``) are not discovered

4. **Verify Test Suite Method:**
   - Each test class needs ``run_test_suite()`` method
   - This method calls ``run_test()`` for each test method

5. **Check Directory Structure:**
   - Test files should be in directories specified in configuration
   - Default locations: ``res://tests/``, ``res://gdsentry/examples/``

Common Test Failures
====================

Method Signature Mismatch
-------------------------

**Error:** ``"Too many arguments for 'assert_equals' call"`` or similar

**Symptoms:**
- Test methods fail with argument count errors
- Assertions don't work as expected

**Solutions:**

1. **Check Assertion Signatures:**
   - ``assert_equals(actual, expected, message="")``
   - ``assert_array_contains(array, element, message="")``
   - ``assert_string_contains(string, substring, message="")``

2. **Use Correct Import:**
   - GDSentry assertions are available automatically in test classes
   - No manual imports needed

3. **Reference API Documentation:**
   - See :doc:`api/assertions` for complete method signatures
   - Check parameter order and types

Timeout Errors
--------------

**Error:** ``"Test timeout exceeded"`` or ``"Test did not complete within timeout period"``

**Symptoms:**
- Tests fail with timeout messages
- Long-running tests get killed
- Async operations don't complete

**Solutions:**

1. **Increase Test Timeout:**

   - Set timeout in test metadata:

     .. code-block:: gdscript

        func _init():
           test_timeout = 60.0  # 60 seconds

2. **Check for Infinite Loops:**
   - Ensure test methods have proper exit conditions
   - Verify async operations complete with ``await``

3. **Profile Slow Tests:**

   - Add timing measurements:

     .. code-block:: gdscript

        var start_time = Time.get_ticks_usec()
        # Your test code here
        var duration = (Time.get_ticks_usec() - start_time) / 1000000.0
        print("Test took: %.2fs" % duration)

4. **Use Appropriate Test Types:**
   - Move slow tests to separate files
   - Use ``IntegrationTest`` for slower end-to-end tests

Null Reference Errors
---------------------

**Error:** ``"Invalid get index 'property' (on base 'null instance')"``

**Symptoms:**
- Tests fail with null reference exceptions
- Objects not initialized properly

**Solutions:**

1. **Check Object Initialization:**
   .. code-block:: gdscript

      func test_object_creation():
          var player = Player.new()
          assert_not_null(player, "Player should be created successfully")
          assert_not_null(player.health, "Player health should be initialized")

2. **Verify Dependencies:**
   - Ensure required scenes are loaded
   - Check that autoloads are available
   - Verify resource paths exist

3. **Use Null Checks:**

   .. code-block:: gdscript

      func test_safe_operations():
         var scene = load_test_scene("res://scenes/player.tscn")
         if scene:
            var player = find_node_by_type(scene, "Player")
            if player:
               # Safe to use player
               assert_true(player.is_alive())
              else:
                  fail_test("Player node not found")
          else:
              fail_test("Scene failed to load")

Scene Loading Failures
----------------------

**Error:** ``"Failed to load scene"`` or ``"Scene file not found"``

**Symptoms:**
- ``load_test_scene()`` returns null
- Visual tests cannot run

**Solutions:**

1. **Verify Scene Paths:**
   - Use ``res://`` protocol for all paths
   - Check file exists in FileSystem dock
   - Verify correct file extension (``.tscn``)

2. **Check Scene Validity:**
   .. code-block:: gdscript

      func test_scene_exists():
          var scene_path = "res://scenes/player.tscn"
          assert_true(ResourceLoader.exists(scene_path), "Scene file should exist")
          var scene = load_test_scene(scene_path)
          assert_not_null(scene, "Scene should load successfully")

3. **Handle Loading Errors:**

   .. code-block:: gdscript

      func test_scene_with_fallback():
         var scene = load_test_scene("res://scenes/player.tscn")
         if not scene:
            print("Primary scene failed, trying fallback...")
            scene = load_test_scene("res://scenes/fallback_player.tscn")
         assert_not_null(scene, "Either primary or fallback scene should load")

Platform-Specific Issues
========================

Windows Path Issues
-------------------

**Problems:**
- Backslash vs forward slash conflicts
- Long path name limitations
- Permission issues with Program Files

**Solutions:**

1. **Use Forward Slashes:**
   - Always use ``res://`` and ``/`` in paths
   - GDSentry handles platform conversion automatically

2. **Avoid Long Paths:**
   - Keep project paths reasonably short
   - Use relative paths where possible

3. **Check Permissions:**
   - Run Godot as administrator if needed
   - Ensure project directory is writable

macOS Permission Problems
-------------------------

**Problems:**
- Sandbox restrictions in development
- Gatekeeper blocking executables
- Library path issues

**Solutions:**

1. **Bypass Gatekeeper:**
   - Right-click Godot app and select "Open"
   - Or run: ``xattr -rd com.apple.quarantine /Applications/Godot.app``

2. **Check Library Paths:**
   - Ensure dynamic libraries are in correct locations
   - Use ``otool -L`` to check library dependencies

3. **Project Permissions:**
   - Ensure project directory has read/write permissions
   - Check if external drives have proper permissions

Linux Headless Configuration
----------------------------

**Problems:**
- Display server not available
- OpenGL context issues
- Font rendering problems

**Solutions:**

1. **Use Proper Headless Flags:**
   .. code-block:: bash

      # Correct headless execution
      godot --headless --script gdsentry/core/test_runner.gd --discover

2. **Check Display Environment:**
   - Ensure ``DISPLAY`` environment variable is not set
   - Or set to empty: ``export DISPLAY=""``

3. **Handle Font Issues:**
   - Some Linux systems need font configuration
   - Use fallback fonts if default fonts unavailable

CI/CD Platform Differences
--------------------------

**GitHub Actions:**
- Use ``barichello/godot-ci`` Docker image
- Ensure proper working directory
- Check artifact upload permissions

**GitLab CI:**
- Use ``barichello/godot-ci`` image
- Configure artifact expiration
- Check runner resource limits

**Jenkins:**
- Install Godot on agent machines
- Configure workspace permissions
- Check Java version compatibility

Test Type Debugging
===================

SceneTreeTest Issues
--------------------

**Problems:**
- Tests run too slowly
- Memory leaks in unit tests
- Isolation problems between tests

**Debugging:**

1. **Profile Test Performance:**

   .. code-block:: gdscript

      extends SceneTreeTest

      func test_with_performance_monitoring():
         var start_mem = Performance.get_monitor(Performance.MEMORY_STATIC)
         var start_time = Time.get_ticks_usec()

         # Your test code here
         var calculator = Calculator.new()
         for i in range(1000):
            calculator.add(i, i+1)

         var end_time = Time.get_ticks_usec()
         var end_mem = Performance.get_monitor(Performance.MEMORY_STATIC)

          print("Test took: %.2fms" % ((end_time - start_time) / 1000.0))
          print("Memory delta: %.1fMB" % ((end_mem - start_mem) / (1024*1024)))

2. **Check for Test Pollution:**
   - Ensure tests don't modify global state
   - Use fresh instances for each test
   - Clean up resources in test methods

Node2DTest Problems
-------------------

**Problems:**
- Visual elements not found
- Scene tree issues
- Node hierarchy problems

**Debugging:**

1. **Inspect Scene Hierarchy:**
   .. code-block:: gdscript

      func test_with_scene_inspection():
          var scene = load_test_scene("res://scenes/ui/menu.tscn")
          assert_not_null(scene, "Scene should load")

          # Print scene hierarchy for debugging
          print_scene_hierarchy(scene)

          # Find expected nodes
          var buttons = find_nodes_by_type(scene, "Button")
          print("Found %d buttons" % buttons.size())

          for button in buttons:
              print("Button: %s at %s" % [button.name, button.position])

2. **Wait for Scene Initialization:**
   .. code-block:: gdscript

      func test_with_proper_waiting():
          var scene = load_test_scene("res://scenes/ui/menu.tscn")
          await wait_for_frames(5)  # Allow scene to initialize

          var title = find_nodes_by_type(scene, "Label")[0]
          assert_visible(title, "Title should be visible after initialization")

3. **Handle Dynamic Content:**
   - Some UI elements may load asynchronously
   - Use ``wait_for_element()`` for dynamic content
   - Check node ready states

PerformanceTest Inconsistencies
-------------------------------

**Problems:**
- Inconsistent benchmark results
- FPS measurements vary widely
- Memory measurements unreliable

**Debugging:**

1. **Stabilize Test Environment:**
   .. code-block:: gdscript

      func before_all():
          # Warm up the engine
          await wait_for_frames(60)  # 1 second at 60 FPS

          # Disable VSync for consistent timing
          DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

2. **Use Statistical Analysis:**

   .. code-block:: gdscript

      func test_with_statistical_analysis():
         var samples = []
         for i in range(10):
            var fps = measure_current_fps()
            samples.append(fps)
              await wait_for_frames(6)  # Brief pause between samples

          var avg_fps = calculate_mean(samples)
          var std_dev = calculate_standard_deviation(samples, avg_fps)

          # Use statistical bounds instead of exact values
          assert_greater_than(avg_fps - 2*std_dev, 50, "Average FPS should be stable")

3. **Control Test Variables:**
   - Run tests at consistent times
   - Avoid background processes
   - Use fixed window sizes
   - Control scene complexity

UITest Element Finding Problems
-------------------------------

**Problems:**
- UI elements not found by expected criteria
- Timing issues with dynamic UI
- Complex selector requirements

**Debugging:**

1. **Debug Element Finding:**

   .. code-block:: gdscript

      func test_with_element_debugging():
         var form = load_scene("res://scenes/ui/login_form.tscn")

         # Try different finding strategies
         var email_field = find_control_by_name("EmailField")
         if not email_field:
            email_field = find_control_by_name("email_field")
          if not email_field:
              # Fall back to type-based finding
              var line_edits = find_controls_by_type("LineEdit")
              email_field = line_edits[0] if line_edits.size() > 0 else null

          assert_not_null(email_field, "Email field should be found by some method")

2. **Handle Dynamic UI:**
   .. code-block:: gdscript

      func test_dynamic_ui_elements():
          var app = load_scene("res://scenes/ui/dynamic_app.tscn")

          # Wait for initial load
          await wait_for_ui_update(2.0)

          # Trigger UI changes
          click_button_by_text("Load Data")

          # Wait for dynamic content
          await wait_for_ui_update(3.0)

          # Now try to find the new elements
          var data_table = find_control_by_name("DataTable")
          assert_not_null(data_table, "Data table should appear after loading")

3. **Use Robust Selectors:**
   - Combine multiple finding strategies
   - Use hierarchical paths when needed
   - Implement retry logic for timing-sensitive elements

Performance Optimization
========================

Test Execution Speed
--------------------

**Slow Test Suite Problems:**
- Large test suites take too long to run
- Individual tests are slow
- CI/CD pipelines timeout

**Optimizations:**

1. **Parallel Execution:**
   .. code-block:: bash

      # Enable parallel test execution
      godot --script gdsentry/core/test_runner.gd --parallel --discover

2. **Selective Test Running:**
   .. code-block:: bash

      # Run only fast unit tests
      godot --script gdsentry/core/test_runner.gd --filter category:unit --discover

      # Skip slow integration tests during development
      godot --script gdsentry/core/test_runner.gd --filter "tags:!slow" --discover

3. **Optimize Test Structure:**
   - Split large test files into smaller ones
   - Use setup/teardown efficiently
   - Avoid unnecessary scene loading

4. **Profile Slow Tests:**
   - Add timing measurements to identify bottlenecks
   - Optimize asset loading
   - Reduce visual test complexity

Memory Usage Optimization
-------------------------

**Memory Problems:**
- Tests consume excessive memory
- Memory leaks between test runs
- Out of memory errors in CI/CD

**Solutions:**

1. **Monitor Memory Usage:**
   .. code-block:: gdscript

      func test_with_memory_monitoring():
          var start_mem = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024*1024)

          # Your test code here
          var large_data = generate_test_data(10000)

          var end_mem = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024*1024)
          var mem_delta = end_mem - start_mem

          assert_less_than(mem_delta, 50, "Test should not use more than 50MB")

2. **Clean Up Resources:**
   .. code-block:: gdscript

      func after_each():
          # Force garbage collection
          # Note: Godot doesn't have direct GC control, but we can help
          pass

3. **Use Efficient Data Structures:**
   - Prefer arrays over dictionaries for large datasets
   - Pool resources where possible
   - Clean up test scenes properly

4. **Memory-Aware Test Design:**
   - Split large tests into smaller ones
   - Use streaming for large assets
   - Implement memory budgets per test

CI/CD Performance Tuning
------------------------

**Pipeline Optimization:**

1. **Caching Strategies:**
   - Cache GDSentry framework between runs
   - Cache compiled scripts
   - Use Docker layer caching for dependencies

2. **Parallel Pipeline Stages:**
   - Run unit tests and integration tests in parallel
   - Split test execution across multiple agents
   - Use matrix builds for different configurations

3. **Selective Testing:**
   - Run full suite only on main branches
   - Use change detection for pull requests
   - Skip unchanged test files

4. **Resource Optimization:**
   - Use appropriate instance sizes for test runners
   - Configure memory limits appropriately
   - Optimize container images for size and speed

Advanced Debugging Techniques
=============================

Verbose Logging
---------------

Enable detailed logging for troubleshooting:

.. code-block:: gdscript

   # In test setup
   func _ready():
       # Enable verbose GDSentry logging
       GDTestManager.set_log_level(GDTestManager.LOG_LEVEL_DEBUG)

   # Or use environment variables
   export GDSENTRY_LOG_LEVEL=DEBUG
   godot --script gdsentry/core/test_runner.gd --verbose --discover

Test Isolation Verification
---------------------------

Ensure tests don't interfere with each other:

.. code-block:: gdscript

   class TestIsolationChecker:
       static var global_state = {}

       static func mark_test_start(test_name: String):
           global_state[test_name] = {
               "start_time": Time.get_ticks_usec(),
               "initial_memory": Performance.get_monitor(Performance.MEMORY_STATIC)
           }

       static func check_test_isolation(test_name: String):
           var current_mem = Performance.get_monitor(Performance.MEMORY_STATIC)
           var initial_mem = global_state[test_name].initial_memory

           var mem_leak = current_mem - initial_mem
           if mem_leak > 1024 * 1024:  # 1MB leak threshold
               push_warning("Test '%s' may have memory leak: %.1fMB" % [test_name, mem_leak / (1024*1024)])

Custom Diagnostic Tools
-----------------------

Create custom debugging utilities:

.. code-block:: gdscript

   class TestDebugger:

       static func dump_scene_tree(node: Node, indent = ""):
           print("%s%s (%s)" % [indent, node.name, node.get_class()])
           for child in node.get_children():
               dump_scene_tree(child, indent + "  ")

       static func profile_function_call(callable: Callable, iterations = 100):
           var times = []
           for i in range(iterations):
               var start = Time.get_ticks_usec()
               callable.call()
               var end = Time.get_ticks_usec()
               times.append(end - start)

           var avg_time = calculate_mean(times)
           var std_dev = calculate_standard_deviation(times, avg_time)

           return {
               "average_time": avg_time,
               "standard_deviation": std_dev,
               "min_time": times.min(),
               "max_time": times.max()
           }

       static func wait_for_condition(condition: Callable, timeout = 5.0, check_interval = 0.1):
           var start_time = Time.get_ticks_usec()
           while (Time.get_ticks_usec() - start_time) / 1000000.0 < timeout:
               if condition.call():
                   return true
               await wait_for_frames(int(check_interval * 60))  # Convert to frames
           return false

Getting Help
============

When all else fails:

1. **Check Documentation:**
   - Review :doc:`getting-started` for basic setup
   - Check :doc:`user-guide` for usage patterns
   - Consult :doc:`api/test-classes` for class-specific issues

2. **Community Resources:**
   - GitHub Issues: Report bugs and get help
   - Godot Forums: GDSentry discussion threads
   - Discord: Real-time community support

3. **Diagnostic Information:**
   Always include when reporting issues:
   - GDSentry version
   - Godot version and platform
   - Complete error messages
   - Test code that reproduces the issue
   - Project structure and configuration

4. **Minimal Reproduction:**
   Create a minimal test case that demonstrates the problem
   - Isolate the failing functionality
   - Remove unrelated code
   - Include only necessary dependencies

This troubleshooting guide covers the most common GDSentry issues. For additional help, see the :doc:`quick-reference` for common patterns and the :doc:`api/test-runner` for command-line options.
