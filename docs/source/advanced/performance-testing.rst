Performance Testing Framework
=============================

GDSentry provides a comprehensive performance testing framework for measuring, monitoring, and validating the performance characteristics of your Godot games. Performance testing ensures your game maintains acceptable frame rates, memory usage, and responsiveness under various conditions.

Overview
========

Performance testing capabilities include:

- **FPS monitoring** and validation
- **Memory usage tracking** and leak detection
- **CPU performance benchmarking**
- **Frame time analysis** and stability testing
- **Performance regression detection**
- **Statistical analysis** of performance metrics

The performance testing framework consists of:

1. **PerformanceTest** - Core performance testing functionality
2. **Performance assertions** - FPS, memory, and timing validations
3. **Benchmarking utilities** - Operation timing and comparison
4. **Performance monitoring** - Real-time metrics collection

Setting Up Performance Testing
==============================

Basic Performance Test Structure
--------------------------------

Create a performance test that extends PerformanceTest:

.. code-block:: gdscript

   extends PerformanceTest
   class_name GamePerformanceTest

   func run_test_suite() -> void:
       run_test("test_game_fps", func(): return await test_game_fps())
       run_test("test_memory_usage", func(): return await test_memory_usage())
       run_test("test_pathfinding_performance", func(): return await test_pathfinding_performance())

Performance Test Configuration
------------------------------

Configure performance testing parameters:

.. code-block:: gdscript

   func _ready() -> void:
       # Configure target performance levels
       target_fps = 60
       memory_threshold_mb = 256.0
       cpu_threshold_ms = 16.67  # ~60 FPS in milliseconds

       # Configure benchmarking
       warmup_iterations = 10
       benchmark_iterations = 100
       performance_tolerance = 0.05  # 5% tolerance for regressions

FPS Testing
===========

Basic FPS Validation
--------------------

Test that your game maintains acceptable frame rates:

.. code-block:: gdscript

   func test_game_fps() -> bool:
       # Load your main game scene
       var game_scene = load_scene("res://scenes/main_game.tscn")

       # Wait for scene to stabilize
       await wait_for_frames(30)

       # Assert FPS stays above 30 for 2 seconds
       return assert_fps_above(30, 2.0, "Game should maintain 30+ FPS")

FPS Testing with Scene Changes
------------------------------

Test FPS during gameplay state changes:

.. code-block:: gdscript

   func test_menu_to_game_transition_fps() -> bool:
       # Start in menu
       var menu = load_scene("res://scenes/menu.tscn")
       await wait_for_frames(10)

       var menu_fps_ok = assert_fps_above(55, 1.0, "Menu should be smooth")

       # Transition to game
       var game_scene = load_scene("res://scenes/game.tscn")
       await wait_for_frames(20)  # Allow loading and initialization

       var game_fps_ok = assert_fps_above(45, 2.0, "Game should maintain playable FPS")

       return menu_fps_ok and game_fps_ok

Target FPS Validation
---------------------

Test against specific performance targets:

.. code-block:: gdscript

   func test_performance_targets() -> bool:
       var game = load_scene("res://scenes/game.tscn")
       await wait_for_frames(30)

       # Different quality settings may have different targets
       var quality_level = Settings.get_quality_level()

       match quality_level:
           Settings.Quality.HIGH:
               return assert_fps_above(60, 3.0, "High quality should maintain 60 FPS")
           Settings.Quality.MEDIUM:
               return assert_fps_above(45, 3.0, "Medium quality should maintain 45 FPS")
           Settings.Quality.LOW:
               return assert_fps_above(30, 3.0, "Low quality should maintain 30 FPS")

       return false

Memory Testing
==============

Memory Usage Validation
-----------------------

Test that memory usage stays within acceptable limits:

.. code-block:: gdscript

   func test_memory_usage() -> bool:
       # Load game scene
       var game = load_scene("res://scenes/game.tscn")
       await wait_for_frames(10)

       # Populate with some game objects
       spawn_test_entities(50)
       await wait_for_frames(20)

       # Check memory usage
       return assert_memory_usage_less_than(200.0,
           "Game should use less than 200MB with 50 entities")

Memory Stability Testing
------------------------

Test that memory usage remains stable over time:

.. code-block:: gdscript

   func test_memory_stability() -> bool:
       var game = load_scene("res://scenes/game.tscn")
       await wait_for_frames(10)

       # Test memory stability over 5 seconds
       return assert_memory_stable(5.0, 10.0,
           "Memory usage should remain stable within 10MB")

Memory Leak Detection
---------------------

Detect memory leaks in repetitive operations:

.. code-block:: gdscript

   func test_no_memory_leaks() -> bool:
       var initial_memory = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024 * 1024)

       # Perform operation that might leak memory
       var operation = func():
           var objects = []
           for i in range(100):
               objects.append(Node.new())
           # Objects go out of scope and should be garbage collected
           return objects.size()

       return assert_no_memory_leaks(operation, 5, 5.0,
           "Creating 100 nodes repeatedly should not leak memory")

Benchmarking
============

Function Benchmarking
---------------------

Measure execution time of specific functions:

.. code-block:: gdscript

   func test_pathfinding_benchmark() -> bool:
       var pathfinder = AStarPathfinder.new()
       var large_map = generate_large_test_map(100, 100)

       # Benchmark pathfinding performance
       return assert_benchmark_performance(
           "pathfinding_100x100",
           func(): return pathfinder.find_path(large_map, Vector2(0, 0), Vector2(99, 99)),
           50.0,  # Max 50ms average
           "Pathfinding should complete within 50ms on 100x100 map"
       )

Performance Regression Testing
------------------------------

Detect performance regressions compared to baseline:

.. code-block:: gdscript

   func test_no_performance_regression() -> bool:
       var physics_calculator = PhysicsCalculator.new()

       # Baseline: known good performance (measured previously)
       var baseline_average_ms = 25.0

       return assert_performance_regression(
           "physics_calculation",
           func(): return physics_calculator.calculate_trajectory(1000),
           baseline_average_ms,
           "Physics calculation performance should not regress"
       )

Custom Benchmarking
-------------------

Create custom benchmarking scenarios:

.. code-block:: gdscript

   func test_rendering_performance() -> bool:
       var renderer = GameRenderer.new()
       var complex_scene = generate_complex_scene()

       # Warm up the renderer
       for i in range(5):
           renderer.render_scene(complex_scene)
           await wait_for_next_frame()

       # Benchmark actual performance
       var benchmark_result = await benchmark_operation(
           "complex_scene_rendering",
           func(): return renderer.render_scene(complex_scene),
           50,  # 50 iterations
           5    # 5 warmup iterations
       )

       # Validate results
       assert_true(benchmark_result.average_time < 33.0,
           "Complex scene should render in less than 33ms (30 FPS)")

       assert_true(benchmark_result.standard_deviation < 5.0,
           "Rendering time should be consistent")

       return true

Advanced Performance Testing
============================

Multi-Scenario Performance Testing
----------------------------------

Test performance across different game scenarios:

.. code-block:: gdscript

   func test_multi_scenario_performance() -> bool:
       var scenarios = [
           {"name": "menu", "scene": "res://scenes/menu.tscn", "min_fps": 55},
           {"name": "gameplay", "scene": "res://scenes/game.tscn", "min_fps": 45},
           {"name": "combat", "scene": "res://scenes/combat.tscn", "min_fps": 40},
           {"name": "loading", "scene": "res://scenes/loading.tscn", "min_fps": 50}
       ]

       var success = true

       for scenario in scenarios:
           var scene = load_scene(scenario.scene)
           await wait_for_frames(30)  # Allow scene to stabilize

           var fps_ok = assert_fps_above(scenario.min_fps, 2.0,
               "%s scenario should maintain %d FPS" % [scenario.name, scenario.min_fps])

           success = success and fps_ok

           # Clean up scene
           scene.queue_free()
           await wait_for_next_frame()

       return success

Load Testing
------------

Test performance under increasing load:

.. code-block:: gdscript

   func test_performance_under_load() -> bool:
       var game = load_scene("res://scenes/game.tscn")
       var entity_spawner = find_node_by_type(game, "EntitySpawner")

       var load_levels = [10, 50, 100, 200]
       var success = true

       for entity_count in load_levels:
           # Spawn entities
           entity_spawner.spawn_entities(entity_count)
           await wait_for_frames(60)  # Allow physics to stabilize

           # Calculate expected minimum FPS based on load
           var expected_min_fps = max(30, 60 - (entity_count / 10))

           var fps_ok = assert_fps_above(expected_min_fps, 3.0,
               "%d entities should maintain %d FPS" % [entity_count, expected_min_fps])

           success = success and fps_ok

           # Clean up for next iteration
           entity_spawner.clear_entities()
           await wait_for_frames(10)

       return success

Performance Profiling
---------------------

Detailed performance analysis:

.. code-block:: gdscript

   func test_detailed_performance_profile() -> bool:
       var profiler = PerformanceProfiler.new()

       # Start profiling
       profiler.start_profiling()

       # Run performance-critical code
       var game = load_scene("res://scenes/game.tscn")
       simulate_gameplay(10.0)  # 10 seconds of gameplay

       # Stop profiling and get results
       var profile_results = profiler.stop_profiling()

       # Analyze results
       assert_true(profile_results.average_fps >= 50,
           "Average FPS should be at least 50")

       assert_true(profile_results.memory_peak_mb <= 300,
           "Peak memory usage should not exceed 300MB")

       assert_true(profile_results.frame_time_95th_percentile <= 25.0,
           "95th percentile frame time should be under 25ms")

       return true

Statistical Analysis
====================

Performance Statistics
----------------------

Analyze performance distributions:

.. code-block:: gdscript

   func test_performance_statistics() -> bool:
       var frame_times = []

       # Collect frame time samples
       for i in range(300):  # 5 seconds at 60 FPS
           var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
           frame_times.append(frame_time)
           await wait_for_next_frame()

       # Calculate statistics
       var mean = calculate_mean(frame_times)
       var std_dev = calculate_standard_deviation(frame_times, mean)
       var percentile_95 = calculate_percentile(frame_times, 0.95)

       # Validate statistical properties
       assert_true(mean < 16.67, "Average frame time should be under 16.67ms (60 FPS)")
       assert_true(std_dev < 2.0, "Frame time variation should be minimal")
       assert_true(percentile_95 < 25.0, "95th percentile should be under 25ms")

       return true

Trend Analysis
--------------

Detect performance trends over time:

.. code-block:: gdscript

   func test_performance_trends() -> bool:
       var measurements = []

       # Take measurements over time
       for minute in range(5):
           var fps_samples = []
           for sample in range(60):  # 1 second of samples
               fps_samples.append(Performance.get_monitor(Performance.TIME_FPS))
               await wait_for_next_frame()

           var avg_fps = calculate_mean(fps_samples)
           measurements.append(avg_fps)

           await wait_for_frames(60)  # Wait 1 second before next measurement

       # Check for performance degradation
       var initial_fps = measurements[0]
       var final_fps = measurements[measurements.size() - 1]
       var degradation = (initial_fps - final_fps) / initial_fps

       assert_true(degradation < 0.1,
           "Performance should not degrade more than 10% over 5 minutes")

       return true

Performance Reporting
=====================

Generate Performance Reports
----------------------------

Create comprehensive performance reports:

.. code-block:: gdscript

   func test_generate_performance_report() -> bool:
       var reporter = PerformanceReporter.new()

       # Run various performance tests
       var fps_test = await run_fps_test(60, 5.0)
       var memory_test = await run_memory_test(200.0, 10.0)
       var benchmark_test = await run_benchmark_test("physics_simulation")

       # Generate report
       var report_data = {
           "timestamp": Time.get_unix_time_from_system(),
           "fps_results": fps_test,
           "memory_results": memory_test,
           "benchmark_results": benchmark_test,
           "system_info": get_system_info(),
           "build_info": get_build_info()
       }

       var success = reporter.generate_html_report(report_data, "performance_report.html")
       assert_true(success, "Performance report should be generated")

       success = success and reporter.generate_json_report(report_data, "performance_report.json")
       assert_true(success, "JSON performance report should be generated")

       return success

CI/CD Integration
=================

Automated Performance Gates
---------------------------

Set up performance requirements for CI/CD:

.. code-block:: bash

   # Run performance tests in CI
   godot --script gdsentry/core/test_runner.gd \
     --profile performance \
     --filter category:performance \
     --report json \
     --discover

   # Check performance requirements
   # (This would be implemented in your CI script)
   if [ "$(cat test_results.json | jq '.performance.average_fps')" -lt 45 ]; then
       echo "Performance requirements not met!"
       exit 1
   fi

Performance Baselines
---------------------

Establish and track performance baselines:

.. code-block:: gdscript

   func test_performance_baselines() -> bool:
       var baseline_manager = PerformanceBaselineManager.new()

       # Load existing baselines
       var baselines = baseline_manager.load_baselines("performance_baselines.json")

       # Run current performance tests
       var current_results = await run_performance_test_suite()

       # Compare against baselines
       var comparison = baseline_manager.compare_to_baselines(current_results, baselines)

       # Check for regressions
       for metric in comparison.metrics:
           var regression = comparison.get_regression_percentage(metric)

           if regression > 0.1:  # 10% regression threshold
               push_error("Performance regression in %s: %.1f%% worse than baseline" %
                         [metric, regression * 100])
               return false

       # Update baselines if tests pass
       baseline_manager.save_baselines(current_results, "performance_baselines.json")

       return true

Performance Alerting
--------------------

Set up performance alerting thresholds:

.. code-block:: gdscript

   func test_performance_alerts() -> bool:
       var alert_manager = PerformanceAlertManager.new()

       # Define alert thresholds
       var thresholds = {
           "fps_drop": {"threshold": 45, "severity": "warning"},
           "memory_spike": {"threshold": 300.0, "severity": "critical"},
           "frame_time_spike": {"threshold": 50.0, "severity": "warning"}
       }

       # Monitor performance during test
       var monitor = PerformanceMonitor.new()
       monitor.start_monitoring()

       # Run performance-critical operations
       stress_test_game_performance()

       # Stop monitoring and check alerts
       var metrics = monitor.stop_monitoring()
       var alerts = alert_manager.check_thresholds(metrics, thresholds)

       # Report any alerts
       for alert in alerts:
           match alert.severity:
               "warning":
                   print("⚠️  Performance warning: %s" % alert.message)
               "critical":
                   push_error("🚨 Critical performance issue: %s" % alert.message)
                   return false

       return alerts.filter(func(a): return a.severity == "critical").is_empty()

Best Practices
==============

Performance Test Organization
-----------------------------

Structure performance tests for maintainability:

.. code-block:: gdscript

   # Organize by performance aspect
   class FPSPerformanceTests extends PerformanceTest:
       func test_menu_fps() -> bool: ...
       func test_gameplay_fps() -> bool: ...
       func test_combat_fps() -> bool: ...

   class MemoryPerformanceTests extends PerformanceTest:
       func test_memory_usage() -> bool: ...
       func test_memory_leaks() -> bool: ...
       func test_memory_stability() -> bool: ...

   class BenchmarkTests extends PerformanceTest:
       func test_algorithm_performance() -> bool: ...
       func test_rendering_performance() -> bool: ...
       func test_physics_performance() -> bool: ...

Test Environment Consistency
----------------------------

Ensure consistent testing conditions:

.. code-block:: gdscript

   func setup_consistent_test_environment() -> void:
       # Disable VSync for consistent timing
       DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

       # Set fixed window size
       DisplayServer.window_set_size(Vector2(1920, 1080))

       # Disable audio to reduce CPU overhead
       AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

       # Warm up the engine
       await wait_for_frames(60)  # 1 second at 60 FPS

Warm-up and Stabilization
-------------------------

Properly warm up systems before measurement:

.. code-block:: gdscript

   func test_proper_warmup() -> bool:
       var game = load_scene("res://scenes/game.tscn")

       # Warm-up phase - let systems stabilize
       print("Warming up...")
       for i in range(300):  # 5 seconds
           await wait_for_next_frame()

       print("Starting measurement...")

       # Measurement phase
       var start_time = Time.get_ticks_usec()
       var frame_count = 0

       for i in range(360):  # 6 seconds at 60 FPS
           await wait_for_next_frame()
           frame_count += 1

       var end_time = Time.get_ticks_usec()
       var duration_sec = (end_time - start_time) / 1000000.0
       var avg_fps = frame_count / duration_sec

       return assert_greater_than(avg_fps, 55.0, "Should maintain 55+ FPS after warmup")

Statistical Significance
------------------------

Ensure performance measurements are statistically valid:

.. code-block:: gdscript

   func test_statistical_significance() -> bool:
       var sample_count = 30  # Multiple runs for statistical validity
       var fps_samples = []

       for run in range(sample_count):
           # Reset test conditions
           reset_game_state()

           # Measure FPS for 2 seconds
           var fps = await measure_fps(2.0)
           fps_samples.append(fps)

           # Brief pause between runs
           await wait_for_frames(30)

       # Calculate statistics
       var mean_fps = calculate_mean(fps_samples)
       var std_dev = calculate_standard_deviation(fps_samples, mean_fps)
       var confidence_interval = calculate_confidence_interval(fps_samples, 0.95)

       # Validate statistical properties
       assert_greater_than(mean_fps, 50.0, "Average FPS should be above 50")

       assert_less_than(std_dev, mean_fps * 0.1,
           "FPS variation should be less than 10% of mean")

       # Ensure confidence interval doesn't include unacceptable performance
       assert_greater_than(confidence_interval.min, 45.0,
           "95% confidence interval should not include FPS below 45")

       return true

Performance Test Maintenance
----------------------------

Keep performance tests current and relevant:

.. code-block:: gdscript

   # Regular baseline updates
   func test_update_performance_baselines() -> bool:
       var baseline_updater = PerformanceBaselineUpdater.new()

       # Run comprehensive performance suite
       var results = await run_full_performance_test_suite()

       # Update baselines if performance has legitimately improved
       var updated = baseline_updater.update_baselines_if_improved(results)

       if updated:
           print("Performance baselines updated - legitimate improvements detected")

       return true

   # Performance requirement reviews
   func test_validate_performance_requirements() -> bool:
       var requirement_validator = PerformanceRequirementValidator.new()

       # Check if current requirements are still relevant
       var current_hardware = get_current_hardware_capabilities()
       var recommended_requirements = requirement_validator.get_recommended_requirements(current_hardware)

       # Validate that our targets are reasonable
       var validation_result = requirement_validator.validate_requirements_against_hardware(
           get_current_performance_targets(), current_hardware)

       return assert_true(validation_result.is_reasonable,
           "Performance requirements should be reasonable for target hardware")

Troubleshooting
===============

Common Performance Testing Issues
---------------------------------

**Inconsistent FPS measurements:**
- Ensure consistent test environment (same hardware, no background processes)
- Use proper warmup periods before measurement
- Disable VSync for accurate timing
- Account for frame rate limiter variations

**Memory measurement inaccuracies:**
- Wait for garbage collection between measurements
- Account for Godot's internal memory management
- Use multiple samples to account for natural variation
- Consider memory fragmentation effects

**Benchmark timing variations:**
- Use high-precision timing functions
- Account for system scheduling variations
- Run benchmarks multiple times and use statistical analysis
- Consider CPU frequency scaling and thermal throttling

**False performance regressions:**
- Establish proper statistical significance thresholds
- Account for natural system variation
- Use confidence intervals for regression detection
- Validate that regressions are real, not measurement artifacts

Performance Debugging
---------------------

Isolate performance bottlenecks:

.. code-block:: gdscript

   func debug_performance_bottleneck() -> bool:
       var profiler = PerformanceDebugger.new()

       # Enable detailed profiling
       profiler.enable_detailed_profiling()

       # Run operation with profiling
       var result = await profile_operation(func(): return expensive_operation())

       # Analyze results
       var bottlenecks = profiler.identify_bottlenecks(result)

       # Report findings
       for bottleneck in bottlenecks:
           match bottleneck.type:
               "cpu":
                   print("🚨 CPU bottleneck: %s taking %.2fms" % [bottleneck.location, bottleneck.duration])
               "memory":
                   print("🚨 Memory bottleneck: %s allocation spike" % bottleneck.location)
               "rendering":
                   print("🚨 Rendering bottleneck: %s draw calls" % bottleneck.location)

       # Fail test if critical bottlenecks found
       var critical_bottlenecks = bottlenecks.filter(func(b): return b.is_critical)
       return assert_true(critical_bottlenecks.is_empty(),
           "Critical performance bottlenecks detected")

Environmental Factors
---------------------

Account for environmental performance variations:

.. code-block:: gdscript

   func test_environmental_factors() -> bool:
       var env_detector = PerformanceEnvironmentDetector.new()

       # Detect current environment
       var environment = env_detector.detect_environment()

       # Adjust expectations based on environment
       match environment.type:
           "ci":
               # CI environments may be slower
               target_fps = 40
               memory_threshold_mb = 400
           "developer_machine":
               # Developer machines are typically faster
               target_fps = 55
               memory_threshold_mb = 300
           "target_hardware":
               # Target platform specifications
               target_fps = 30
               memory_threshold_mb = 150

       # Log environment for debugging
       print("Testing in %s environment" % environment.type)
       print("CPU: %s, RAM: %dMB, GPU: %s" % [
           environment.cpu_model,
           environment.ram_mb,
           environment.gpu_model
       ])

       # Run performance test with adjusted expectations
       return await run_performance_test_with_target(target_fps, memory_threshold_mb)

.. seealso::
   :doc:`../api/test-classes`
      PerformanceTest class for performance validation.

   :doc:`../tutorials/ci-integration`
      Running performance tests in CI/CD pipelines.

   :doc:`../user-guide`
      Best practices for performance testing scenarios.

   :doc:`../troubleshooting`
      Solutions for performance test issues and optimization tips.
