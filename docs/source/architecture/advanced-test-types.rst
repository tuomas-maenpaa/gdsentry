Advanced Test Types
====================

Overview
--------

GDSentry provides sophisticated test types beyond basic unit testing, enabling comprehensive quality assurance for Godot games. These advanced test types address specific testing challenges in game development:

- **Performance Benchmark Testing** - Statistical performance analysis with regression detection
- **Visual Regression Testing** - Automated visual comparison with multiple algorithms
- **Physics Testing** - Deterministic physics simulation validation
- **UI Testing** - Interactive UI component testing
- **Event Testing** - Event-driven system validation
- **Integration Testing** - Multi-component interaction testing

This document focuses on the two most sophisticated test types: Performance Benchmark and Visual Regression testing.

Performance Benchmark Testing
------------------------------

Architecture
~~~~~~~~~~~~

**Location**: ``src/test_types/performance_benchmark_test.gd``

**Class**: ``PerformanceBenchmarkTest`` (extends ``PerformanceTest``)

**Purpose**: Advanced performance testing with statistical analysis, baseline management, regression detection, and CI/CD integration.

Core Components
~~~~~~~~~~~~~~~

The performance benchmark framework consists of 5 specialized components:

1. **StatisticalAnalyzer**
   - Calculates mean, median, standard deviation, variance
   - Computes percentiles (p50, p95, p99)
   - Detects outliers using modified Z-score
   - Generates confidence intervals

2. **RegressionDetector**
   - Compares current results against baselines
   - Detects statistically significant performance regressions
   - Classifies severity (low, medium, high, critical)
   - Analyzes performance trends over time

3. **BaselineManager**
   - Stores performance baselines with timestamps
   - Manages baseline versions and retention
   - Compares current results with stored baselines
   - Persists baselines to JSON files

4. **CIGateChecker**
   - Evaluates performance against CI/CD thresholds
   - Configurable gates for performance, memory, FPS
   - Generates pass/fail reports for build pipelines
   - Provides detailed failure reasons

5. **TrendAnalyzer**
   - Analyzes historical performance data
   - Identifies trends (improving, degrading, stable)
   - Uses linear regression for trend detection
   - Forecasts future performance

Key Features
~~~~~~~~~~~~

**Statistical Analysis**:

.. code-block:: gdscript

   # Analyze benchmark results
   var stats = statistical_analyzer.calculate_basic_statistics(results)
   # Returns: mean, median, std_dev, p50, p95, p99, confidence_interval

**Regression Detection**:

.. code-block:: gdscript

   # Detect performance regression
   var regression = regression_detector.detect_performance_regression(
       current_stats, 
       baseline_stats
   )
   # Returns: regression_detected, severity, confidence, percent_change

**Baseline Management**:

.. code-block:: gdscript

   # Store baseline
   baseline_manager.store_baseline("v1.0.0", benchmark_results)
   
   # Compare with baseline
   var comparison = baseline_manager.compare_with_baseline(
       "v1.0.0", 
       current_results
   )

**CI/CD Gates**:

.. code-block:: gdscript

   # Check performance gates
   var gate_result = ci_gate_checker.check_performance_gate(
       benchmark_results,
       baseline_comparison
   )
   
   if not gate_result.gate_passed:
       print(ci_gate_checker.generate_gate_report(gate_result))
       # Fail build

Configuration
~~~~~~~~~~~~~

**Constants**:

- ``DEFAULT_CONFIDENCE_LEVEL``: 0.95 (95% confidence intervals)
- ``DEFAULT_OUTLIER_THRESHOLD``: 2.5 standard deviations
- ``DEFAULT_REGRESSION_THRESHOLD``: 0.10 (10% performance change)
- ``DEFAULT_BASELINE_RETENTION_DAYS``: 30 days
- ``DEFAULT_TREND_ANALYSIS_WINDOW``: 10 data points

**Configurable Thresholds**:

.. code-block:: gdscript

   # CI/CD gate thresholds
   ci_gate_checker.gate_thresholds = {
       "performance_regression": 0.05,  # 5% regression fails build
       "memory_regression": 10.0,       # 10MB increase fails build
       "fps_drop": 5.0                  # 5 FPS drop fails build
   }

Use Cases
~~~~~~~~~

1. **Automated Performance Testing**
   - Run benchmark suites in CI/CD
   - Detect performance regressions before merge
   - Track performance trends over releases

2. **Performance Profiling**
   - Identify bottlenecks in game systems
   - Compare different implementation approaches
   - Validate optimization efforts

3. **Capacity Planning**
   - Forecast performance under load
   - Identify performance degradation trends
   - Plan optimization work based on data

4. **Release Validation**
   - Ensure performance meets requirements
   - Compare against previous versions
   - Generate performance reports for stakeholders

Best Practices
~~~~~~~~~~~~~~

1. **Baseline Management**
   - Create baselines for each major release
   - Update baselines when intentional changes occur
   - Keep baselines for at least 30 days

2. **Statistical Rigor**
   - Run benchmarks multiple times (10+ iterations)
   - Use confidence intervals for comparisons
   - Filter outliers before analysis

3. **CI/CD Integration**
   - Set appropriate regression thresholds
   - Generate detailed reports on failures
   - Track trends across builds

4. **Performance Monitoring**
   - Monitor trends, not just point-in-time results
   - Investigate gradual degradation
   - Correlate performance with code changes

Visual Regression Testing
--------------------------

Architecture
~~~~~~~~~~~~

**Location**: ``src/test_types/visual_regression_test.gd``

**Class**: ``VisualRegressionTestFramework`` (extends ``VisualTest``)

**Purpose**: Automated visual testing with multiple comparison algorithms, baseline management, and approval workflows.

Comparison Algorithms
~~~~~~~~~~~~~~~~~~~~~

GDSentry provides 4 image comparison algorithms, each suited for different use cases:

1. **Pixel-by-Pixel** (``PIXEL_BY_PIXEL``)
   - Most accurate, most expensive
   - Compares every pixel between images
   - Provides detailed metrics (matching pixels, max difference, avg difference)
   - Use for: Exact visual validation, UI component testing

2. **Perceptual Hash** (``PERCEPTUAL_HASH``)
   - Fast, robust to minor changes
   - Generates perceptual hashes for comparison
   - Tolerant of compression artifacts, scaling
   - Use for: Screenshot comparison, visual smoke tests

3. **Structural Similarity** (``STRUCTURAL_SIMILARITY``)
   - Aligned with human perception
   - Compares luminance, contrast, structure (SSIM)
   - More forgiving than pixel-by-pixel
   - Use for: Quality assessment, perceptual validation

4. **Feature-Based** (``FEATURE_BASED``)
   - Robust to transformations
   - Extracts and matches visual features
   - Handles rotation, scaling, perspective changes
   - Use for: 3D scene comparison, camera angle variations
   - Note: Currently falls back to pixel-by-pixel (placeholder)

Algorithm Selection
~~~~~~~~~~~~~~~~~~~

Choose algorithm based on testing needs:

.. code-block:: gdscript

   # Exact UI validation
   comparison_algorithm = ComparisonAlgorithm.PIXEL_BY_PIXEL
   visual_tolerance = 0.01  # 1% difference allowed
   
   # General screenshot comparison
   comparison_algorithm = ComparisonAlgorithm.PERCEPTUAL_HASH
   perceptual_threshold = 0.95  # 95% similarity required
   
   # Perceptual quality testing
   comparison_algorithm = ComparisonAlgorithm.STRUCTURAL_SIMILARITY
   visual_tolerance = 0.05  # 5% SSIM difference allowed

Key Features
~~~~~~~~~~~~

**Baseline Management**:

.. code-block:: gdscript

   # Capture baseline
   capture_baseline("main_menu")
   
   # Compare with baseline
   var result = compare_with_baseline("main_menu", 0.02)
   
   if not result.success:
       print("Visual regression detected!")
       print("Similarity: ", result.similarity)

**Approval Workflow**:

.. code-block:: gdscript

   # Pending approvals for visual changes
   if result.requires_approval:
       pending_approvals["main_menu"] = {
           "state": ApprovalState.PENDING,
           "similarity": result.similarity,
           "timestamp": Time.get_unix_time_from_system()
       }
   
   # Approve changes
   approve_baseline_update("main_menu")

**Region-of-Interest (ROI) Testing**:

.. code-block:: gdscript

   # Compare specific region
   var roi = Rect2(100, 100, 200, 150)  # x, y, width, height
   var result = compare_with_baseline("hud", 0.01, 0, roi)

**Difference Highlighting**:

.. code-block:: gdscript

   # Generate diff image showing differences
   generate_diff_images = true
   var result = compare_with_baseline("scene")
   # Creates diff image at: .runtime/test-reports/visual/diff/scene_diff.png

Configuration
~~~~~~~~~~~~~

**Constants**:

- ``DEFAULT_PERCEPTUAL_THRESHOLD``: 0.95 (95% similarity)
- ``MAX_BASELINE_VERSIONS``: 10 versions retained
- ``AUTO_APPROVE_THRESHOLD``: 0.98 (98% similarity auto-approves)

**Comparison Algorithms**:

.. code-block:: gdscript

   enum ComparisonAlgorithm {
       PIXEL_BY_PIXEL,
       PERCEPTUAL_HASH,
       STRUCTURAL_SIMILARITY,
       FEATURE_BASED
   }

**Approval States**:

.. code-block:: gdscript

   enum ApprovalState {
       PENDING,
       APPROVED,
       REJECTED,
       AUTO_APPROVED
   }

Use Cases
~~~~~~~~~

1. **UI Regression Testing**
   - Validate UI layouts after changes
   - Detect unintended visual changes
   - Test responsive UI across resolutions

2. **Cross-Platform Validation**
   - Compare rendering across platforms
   - Detect platform-specific visual issues
   - Validate consistent appearance

3. **Rendering Validation**
   - Test shader changes
   - Validate lighting and effects
   - Detect rendering regressions

4. **Approval Workflows**
   - Review intentional visual changes
   - Approve baseline updates
   - Track visual change history

Best Practices
~~~~~~~~~~~~~~

1. **Baseline Management**
   - Create baselines on stable builds
   - Version baselines with releases
   - Review and approve changes explicitly

2. **Algorithm Selection**
   - Use pixel-by-pixel for exact validation
   - Use perceptual hash for general comparison
   - Use SSIM for quality assessment

3. **Tolerance Configuration**
   - Set tight tolerance for UI (1-2%)
   - Set loose tolerance for 3D scenes (5-10%)
   - Adjust based on platform variability

4. **CI/CD Integration**
   - Capture screenshots in CI
   - Compare against approved baselines
   - Fail builds on unapproved changes
   - Generate visual reports

Other Advanced Test Types
--------------------------

Physics Testing
~~~~~~~~~~~~~~~

**Location**: ``src/test_types/physics_test.gd``

**Purpose**: Deterministic physics simulation testing

**Features**:
- Deterministic physics step execution
- Collision detection validation
- Rigid body behavior testing
- Physics engine consistency checks

UI Testing
~~~~~~~~~~

**Location**: ``src/test_types/ui_test.gd``

**Purpose**: Interactive UI component testing

**Features**:
- UI interaction simulation (clicks, inputs)
- Focus and navigation testing
- Accessibility validation
- Theme and styling verification

Event Testing
~~~~~~~~~~~~~

**Location**: ``src/test_types/event_test.gd``

**Purpose**: Event-driven system validation

**Features**:
- Signal emission and handling
- Event ordering verification
- Event propagation testing
- Asynchronous event validation

Integration Testing
~~~~~~~~~~~~~~~~~~~

**Location**: ``src/test_types/integration_test.gd``

**Purpose**: Multi-component interaction testing

**Features**:
- Scene loading and initialization
- Component interaction validation
- System integration testing
- End-to-end workflow testing

Comparison Matrix
-----------------

Choosing the Right Test Type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+-------------------------+------------------+------------------+------------------+
| Test Type               | Use Case         | Complexity       | Execution Time   |
+=========================+==================+==================+==================+
| Performance Benchmark   | Performance      | High             | Minutes          |
|                         | validation       |                  |                  |
+-------------------------+------------------+------------------+------------------+
| Visual Regression       | Visual           | Medium           | Seconds          |
|                         | validation       |                  |                  |
+-------------------------+------------------+------------------+------------------+
| Physics                 | Physics          | Medium           | Seconds          |
|                         | behavior         |                  |                  |
+-------------------------+------------------+------------------+------------------+
| UI                      | UI interaction   | Medium           | Seconds          |
+-------------------------+------------------+------------------+------------------+
| Event                   | Event systems    | Low              | Milliseconds     |
+-------------------------+------------------+------------------+------------------+
| Integration             | System           | High             | Seconds-Minutes  |
|                         | integration      |                  |                  |
+-------------------------+------------------+------------------+------------------+

Related Documentation
---------------------

- :doc:`layer-independence` - Why test types are GDScript-only
- :doc:`python-gdscript-integration` - How test results flow to Python
- :doc:`plugin-system` - Creating custom test types

Implementation Files
--------------------

**Performance Testing**:
- ``src/test_types/performance_test.gd`` - Base performance testing
- ``src/test_types/performance_benchmark_test.gd`` - Advanced benchmarking

**Visual Testing**:
- ``src/test_types/visual_test.gd`` - Base visual testing
- ``src/test_types/visual_regression_test.gd`` - Advanced regression testing

**Other Test Types**:
- ``src/test_types/physics_test.gd``
- ``src/test_types/ui_test.gd``
- ``src/test_types/event_test.gd``
- ``src/test_types/integration_test.gd``

Conclusion
----------

Advanced test types enable comprehensive quality assurance for Godot games. Performance benchmark testing provides statistical rigor for performance validation, while visual regression testing automates visual quality assurance. Together with other specialized test types, GDSentry provides a complete testing solution for game development.
