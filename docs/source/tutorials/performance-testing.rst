Performance Testing Tutorial
============================

Performance testing ensures your game runs smoothly and efficiently. This tutorial covers GDSentry's comprehensive performance monitoring, benchmarking, and optimization validation capabilities.

.. note::
   **Prerequisites**: Basic familiarity with GDSentry testing. Complete the :doc:`../getting-started` guide first.

What is Performance Testing?
============================

Performance testing validates:
- Frame rate stability and minimum FPS requirements
- Memory usage and leak detection
- CPU processing time and bottlenecks
- Object count management
- Physics performance metrics
- Benchmarking and regression detection

Unlike functional testing that validates *correctness*, performance testing ensures your game *runs well* under various conditions.

When to Use Performance Testing
===============================

Performance tests are essential for:

- **Game Optimization**: Ensuring smooth 60fps gameplay
- **Memory Management**: Preventing memory leaks and bloat
- **Scalability Testing**: Performance under increased loads
- **Platform Compatibility**: Different hardware capabilities
- **Release Validation**: Final performance verification
- **Regression Prevention**: Catching performance degradation

Setting Up a Performance Test
=============================

Create a new test class that extends ``PerformanceTest``:

.. code-block:: gdscript

    extends GDSentry.PerformanceTest

    func test_game_performance() -> bool:
        # Performance test implementation
        return true

Performance Test Configuration
==============================

Configure performance testing parameters:

.. code-block:: gdscript

    func before_test() -> void:
        # Configure performance testing parameters
        target_fps = 60
        memory_threshold_mb = 100.0
        cpu_threshold_ms = 16.67  # ~60fps in milliseconds
        benchmark_iterations = 100
        warmup_iterations = 10
        performance_tolerance = 0.05

Frame Rate Testing
==================

Monitor and validate frame rate performance:

.. code-block:: gdscript

    func test_minimum_fps() -> bool:
        var game_scene = load_test_scene("res://scenes/game/main.tscn")

        # Ensure game maintains minimum 30 FPS for 2 seconds
        return assert_fps_above(30, 2.0, "Game should maintain at least 30 FPS")

Frame Rate Stability
====================

Verify frame rate remains consistent:

.. code-block:: gdscript

    func test_fps_stability() -> bool:
        var game_scene = load_test_scene("res://scenes/game/level1.tscn")

        # Ensure FPS stays within 10% of target (60 FPS) for 3 seconds
        return assert_fps_stable(60, 10.0, 3.0, "FPS should remain stable during gameplay")

Frame Drop Detection
====================

Detect and prevent significant frame rate drops:

.. code-block:: gdscript

    func test_no_frame_drops() -> bool:
        var game_scene = load_test_scene("res://scenes/game/intense_action.tscn")

        # Ensure no frame drops below 50 FPS for 5 seconds
        # (drop_threshold means how many FPS below target is considered a drop)
        return assert_no_frame_drops(5.0, 10, "No significant frame drops during intense action")

Memory Usage Testing
====================

Monitor memory consumption and detect leaks:

.. code-block:: gdscript

    func test_memory_usage() -> bool:
        var game_scene = load_test_scene("res://scenes/game/main.tscn")

        # Wait for scene to stabilize
        await wait_for_seconds(1.0)

        # Ensure memory usage stays below 200MB
        return assert_memory_usage_less_than(200.0, "Game memory usage should stay reasonable")

Memory Stability Testing
========================

Verify memory usage remains stable over time:

.. code-block:: gdscript

    func test_memory_stability() -> bool:
        var game_scene = load_test_scene("res://scenes/game/level1.tscn")

        # Monitor memory for 10 seconds, ensure it doesn't fluctuate more than 5MB
        return assert_memory_stable(10.0, 5.0, "Memory usage should remain stable")

Memory Leak Detection
=====================

Detect memory leaks in repeated operations:

.. code-block:: gdscript

    func test_no_memory_leaks() -> bool:
        # Test that creating and destroying 100 enemies doesn't leak memory
        var create_enemy = func():
            var enemy = Enemy.new()
            add_child(enemy)
            await wait_for_seconds(0.1)
            enemy.queue_free()

        # Run operation 50 times, ensure no more than 1MB memory growth
        return assert_no_memory_leaks(create_enemy, 50, 1.0, "Enemy creation/destruction should not leak memory")

CPU Performance Testing
=======================

Monitor CPU processing time:

.. code-block:: gdscript

    func test_cpu_performance() -> bool:
        var complex_scene = load_test_scene("res://scenes/game/complex_level.tscn")

        # Ensure CPU processing stays below 16.67ms (60fps equivalent)
        return assert_cpu_time_less_than(16.67, "CPU processing should maintain 60fps performance")

Physics Performance Testing
===========================

Monitor physics simulation performance:

.. code-block:: gdscript

    func test_physics_performance() -> bool:
        var physics_scene = load_test_scene("res://scenes/game/physics_heavy.tscn")

        # Ensure physics processing stays within performance limits
        return assert_physics_time_less_than(8.0, "Physics simulation should perform well")

Object Count Monitoring
=======================

Track object and node counts:

.. code-block:: gdscript

    func test_object_counts() -> bool:
        var game_scene = load_test_scene("res://scenes/game/level1.tscn")

        # Ensure reasonable object counts for performance
        return assert_objects_count_less_than(1000, "Object count should stay reasonable") and \
               assert_nodes_count_less_than(500, "Scene node count should stay reasonable")

Physics Object Monitoring
=========================

Monitor active physics objects:

.. code-block:: gdscript

    func test_physics_objects() -> bool:
        var physics_scene = load_test_scene("res://scenes/game/destruction.tscn")

        # Trigger some destruction
        trigger_destruction_event()

        # Wait for physics to settle
        await wait_for_seconds(2.0)

        # Ensure physics object count stays manageable
        return assert_physics_active_objects_less_than(200, "Active physics objects should stay reasonable")

Benchmarking Operations
=======================

Measure and analyze operation performance:

.. code-block:: gdscript

    func test_pathfinding_performance() -> bool:
        var level = load_test_scene("res://scenes/game/level1.tscn")
        var ai_system = level.get_node("AISystem")

        # Benchmark pathfinding operation
        var pathfind = func():
            return ai_system.find_path(Vector2(0, 0), Vector2(1000, 1000))

        var result = await benchmark_operation("pathfinding", pathfind, 50, 5)

        # Log benchmark results
        print("Pathfinding benchmark: ", result)

        # Assert performance requirements (average < 10ms)
        return assert_benchmark_performance("pathfinding", pathfind, 10.0, "Pathfinding should be fast")

Performance Regression Detection
================================

Detect performance degradation over time:

.. code-block:: gdscript

    func test_performance_regression() -> bool:
        var render = func():
            # Simulate rendering operation
            var sprite = Sprite2D.new()
            sprite.texture = load("res://textures/large_texture.png")
            add_child(sprite)
            await get_tree().process_frame
            sprite.queue_free()

        # Check against baseline performance (5ms average)
        return assert_performance_regression("rendering", render, 5.0, "Rendering performance should not regress")

Complex Performance Scenarios
=============================

Test performance under combined load:

.. code-block:: gdscript

    func test_combined_performance() -> bool:
        var game_scene = load_test_scene("res://scenes/game/complex_gameplay.tscn")

        # Start multiple performance monitoring checks
        var checks_passed = 0

        # Check FPS
        if await assert_fps_above(45, 1.0):
            checks_passed += 1

        # Check memory
        if await assert_memory_usage_less_than(150.0):
            checks_passed += 1

        # Check CPU
        if await assert_cpu_time_less_than(20.0):
            checks_passed += 1

        # Check object counts
        if await assert_objects_count_less_than(800):
            checks_passed += 1

        return checks_passed >= 3  # At least 3 out of 4 checks must pass

Performance Testing Best Practices
==================================

Test Organization
-----------------

- **Separate Performance Tests**: Keep performance tests in dedicated files
- **Use Appropriate Timeouts**: Performance tests may take longer to run
- **Baseline Establishment**: Establish performance baselines before optimization
- **Regular Monitoring**: Include performance tests in regular test suites

Environment Considerations
--------------------------

- **Consistent Hardware**: Run tests on similar hardware configurations
- **Background Process Control**: Minimize background system activity
- **Display Settings**: Test with target resolution and quality settings
- **Build Configuration**: Test release builds, not debug builds

Threshold Setting
-----------------

- **Realistic Targets**: Set thresholds based on target hardware requirements
- **Graduated Levels**: Different thresholds for minimum viable vs optimal performance
- **Tolerance Bands**: Account for natural performance variation
- **Platform-Specific**: Different thresholds for different target platforms

Debugging Performance Issues
============================

**FPS Problems**
- Use ``assert_fps_above()`` with shorter durations to isolate issues
- Profile with Godot's built-in profiler
- Check for expensive operations in ``_process()`` and ``_physics_process()``

**Memory Issues**
- Use ``assert_memory_stable()`` to identify memory growth patterns
- Monitor with Godot's memory profiler
- Check for object retention and circular references

**CPU Bottlenecks**
- Use ``benchmark_operation()`` to measure specific functions
- Profile expensive operations
- Consider async processing for heavy computations

**Object Count Issues**
- Monitor ``assert_objects_count_less_than()`` trends
- Implement object pooling for frequently created/destroyed objects
- Use scene instancing efficiently

CI/CD Integration
=================

Performance tests in automated pipelines:

.. code-block:: bash

    # Run performance tests with specific thresholds
    godot --script run_performance_tests.gd --target-fps 60 --memory-limit 200

    # Generate performance reports
    gdsentry --performance-report --output performance_results.json

Common Performance Issues
=========================

**False Positives**
- Account for system warmup time
- Run multiple iterations and use statistical analysis
- Consider environmental factors (background processes, thermal throttling)

**Inconsistent Results**
- Use longer test durations for stability
- Implement warmup periods before measurements
- Control for random number generation effects

**Platform Differences**
- Set platform-specific thresholds
- Test on target hardware configurations
- Account for different GPU capabilities

**Load Testing Challenges**
- Gradually increase load to identify breaking points
- Monitor multiple metrics simultaneously
- Use realistic usage patterns, not artificial stress tests

Next Steps
==========

Now that you understand performance testing:

1. **Implement**: Add performance tests to your GDSentry test suite
2. **Monitor**: Set up regular performance monitoring in development
3. **Optimize**: Use performance test results to guide optimization efforts
4. **Automate**: Integrate performance testing into your CI/CD pipeline

.. seealso::
   :doc:`../examples` - Performance testing code examples
   :doc:`ci-integration` - Integrating performance tests into CI/CD
   :doc:`../best-practices` - Performance testing guidelines
