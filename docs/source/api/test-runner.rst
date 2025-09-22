Test Runner CLI
===============

GDSentry provides a comprehensive command-line interface for executing tests in various environments, including CI/CD pipelines, automated testing, and local development workflows.

Basic Usage
===========

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd [options]

The test runner supports headless execution and integrates seamlessly with Godot's project system.

Discovery Options
=================

``--discover``, ``-f``
----------------------
Automatically discovers and runs all tests in the project.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --discover --verbose

``--test-path PATH``, ``-p PATH``
---------------------------------
Runs a specific test script file.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --test-path res://tests/unit/player_test.gd

``--file PATH``
---------------
Alias for ``--test-path``.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --file res://tests/ui/menu_test.gd

``--test-dir DIR``, ``-d DIR``
------------------------------
Runs all tests in the specified directory.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --test-dir tests/unit/

Configuration Options
=====================

``--config PATH``, ``-c PATH``
------------------------------
Loads a specific configuration file.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --config res://gdsentry_config.tres --discover

``--profile NAME``
------------------
Uses a predefined configuration profile (ci, development, performance, visual, smoke).

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --profile ci --discover

Filtering Options
=================

``--filter category:NAME``
--------------------------
Filter tests by category.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --filter category:unit --discover

``--filter tags:TAG1,TAG2``
---------------------------
Filter tests by tags (comma-separated).

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --filter tags:ui,integration --discover

``--pattern PATTERN``
---------------------
Filter by path pattern using wildcards.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --pattern "*_test.gd" --discover

Execution Options
=================

``--parallel``
--------------
Enable parallel test execution for faster runs.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --parallel --discover

``--fail-fast``
---------------
Stop execution immediately after the first test failure.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --fail-fast --test-dir tests/critical/

``--timeout SECONDS``, ``-t SECONDS``
-------------------------------------
Set the timeout for individual tests in seconds.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --timeout 10 --discover

``--randomize [SEED]``
----------------------
Randomize test execution order. Optional seed for reproducible runs.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --randomize 12345 --discover

Output and Reporting Options
============================

``--verbose``, ``-v``
---------------------
Enable verbose output with detailed test information.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --verbose --discover

``--report FORMAT``
-------------------
Specify report formats (comma-separated: json, junit, html).

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --report json,junit --discover

``--report-path PATH``
----------------------
Specify the output directory for reports.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --report html --report-path reports/ --discover

Other Options
=============

``--dry-run``
-------------
Show what tests would be executed without actually running them.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --dry-run --discover

``--help``, ``-h``
------------------
Display the comprehensive help message with all available options.

.. code-block:: bash

   godot --script gdsentry/core/test_runner.gd --help

Common Usage Scenarios
======================

Running All Tests
-----------------

.. code-block:: bash

   # Run all tests with verbose output
   godot --script gdsentry/core/test_runner.gd --discover --verbose

   # Run all tests in parallel for faster execution
   godot --script gdsentry/core/test_runner.gd --parallel --discover

Running Specific Tests
----------------------

.. code-block:: bash

   # Run a specific test file
   godot --script gdsentry/core/test_runner.gd --test-path res://tests/player_controller_test.gd

   # Run all tests in the unit directory
   godot --script gdsentry/core/test_runner.gd --test-dir tests/unit/

   # Run tests matching a pattern
   godot --script gdsentry/core/test_runner.gd --pattern "player_*_test.gd" --discover

Filtered Test Execution
-----------------------

.. code-block:: bash

   # Run only unit tests
   godot --script gdsentry/core/test_runner.gd --filter category:unit --discover

   # Run tests with specific tags
   godot --script gdsentry/core/test_runner.gd --filter tags:critical,smoke --discover

   # Run tests for a specific feature
   godot --script gdsentry/core/test_runner.gd --filter tags:inventory --discover

CI/CD Integration
-----------------

.. code-block:: bash

   # Run tests in CI with JUnit reporting
   godot --script gdsentry/core/test_runner.gd --profile ci --report junit --report-path reports/

   # Fail fast in CI pipelines
   godot --script gdsentry/core/test_runner.gd --fail-fast --timeout 30 --discover

   # Run performance tests in CI
   godot --script gdsentry/core/test_runner.gd --profile performance --report json --discover

Local Development
-----------------

.. code-block:: bash

   # Quick test run during development
   godot --script gdsentry/core/test_runner.gd --discover

   # Debug a specific failing test
   godot --script gdsentry/core/test_runner.gd --verbose --test-path res://tests/failing_test.gd

   # Run tests with custom configuration
   godot --script gdsentry/core/test_runner.gd --config res://my_config.tres --discover

Performance Testing
-------------------

.. code-block:: bash

   # Run performance tests with detailed output
   godot --script gdsentry/core/test_runner.gd --profile performance --verbose --discover

   # Generate performance reports
   godot --script gdsentry/core/test_runner.gd --profile performance --report html,json --discover

Debugging and Troubleshooting
-----------------------------

.. code-block:: bash

   # Dry run to see what would be executed
   godot --script gdsentry/core/test_runner.gd --dry-run --discover

   # Verbose output for debugging
   godot --script gdsentry/core/test_runner.gd --verbose --fail-fast --discover

   # Test with extended timeout for slow operations
   godot --script gdsentry/core/test_runner.gd --timeout 60 --test-path res://tests/slow_test.gd

Exit Codes
==========

The test runner returns the following exit codes:

- ``0``: All tests passed successfully
- ``1``: One or more tests failed
- ``2``: Test execution error (configuration, file not found, etc.)

Report Formats
==============

GDSentry supports multiple report formats for different use cases:

Console Output
--------------
Real-time test progress and results displayed in the terminal.

JUnit XML
---------
Standard XML format compatible with CI/CD systems and test reporting tools.

.. code-block:: xml

   <testsuites>
     <testsuite name="PlayerTest" tests="3" failures="0" time="0.123">
       <testcase name="test_movement" time="0.045"/>
       <testcase name="test_jump" time="0.034"/>
       <testcase name="test_collision" time="0.044"/>
     </testsuite>
   </testsuites>

HTML Reports
------------
Interactive web-based reports with detailed test results, performance metrics, and visualizations.

JSON Output
-----------
Structured data format for programmatic processing and integration with other tools.

.. code-block:: json

   {
     "summary": {
       "total_tests": 15,
       "passed": 14,
       "failed": 1,
       "duration": 2.5
     },
     "tests": [
       {
         "name": "test_player_movement",
         "status": "passed",
         "duration": 0.123,
         "category": "unit"
       }
     ]
   }

Configuration Profiles
======================

GDSentry includes predefined configuration profiles optimized for different use cases:

``ci``
------
Optimized for continuous integration environments:
- Parallel execution enabled
- JUnit reporting
- Fail-fast behavior
- Extended timeouts

``development``
---------------
Optimized for local development:
- Verbose output
- HTML reporting
- Sequential execution
- Shorter timeouts

``performance``
---------------
Optimized for performance testing:
- Parallel execution
- Performance-specific timeouts
- Detailed performance metrics
- JSON reporting

``visual``
----------
Optimized for visual/UI testing:
- Sequential execution for stability
- Visual regression reporting
- Extended timeouts for rendering
- HTML reports with screenshots

``smoke``
---------
Optimized for quick smoke tests:
- Fast execution
- Minimal reporting
- Critical test filtering
- Quick feedback

Advanced Usage
==============

Combining Options
-----------------

.. code-block:: bash

   # Complex test run with multiple filters and options
   godot --script gdsentry/core/test_runner.gd \
     --profile development \
     --filter category:integration \
     --filter tags:critical \
     --parallel \
     --timeout 45 \
     --report html,json \
     --report-path reports/ \
     --verbose \
     --discover

Environment Variables
---------------------

GDSentry respects several environment variables:

``GDSENTRY_CONFIG``
^^^^^^^^^^^^^^^^^
Path to the default configuration file.

.. code-block:: bash

   export GDSENTRY_CONFIG="res://my_project_config.tres"
   godot --script gdsentry/core/test_runner.gd --discover

``GDSENTRY_PROFILE``
^^^^^^^^^^^^^^^^^^
Default configuration profile.

.. code-block:: bash

   export GDSENTRY_PROFILE="ci"
   godot --script gdsentry/core/test_runner.gd --discover

``GDSENTRY_REPORT_PATH``
^^^^^^^^^^^^^^^^^^^^^^
Default report output directory.

.. code-block:: bash

   export GDSENTRY_REPORT_PATH="user://test_reports/"
   godot --script gdsentry/core/test_runner.gd --report html --discover

Script Integration
------------------

The test runner can be integrated into shell scripts and build processes:

.. code-block:: bash

   #!/bin/bash
   # run_tests.sh

   echo "Running GDSentry test suite..."

   # Run unit tests
   godot --script gdsentry/core/test_runner.gd --filter category:unit --discover
   UNIT_EXIT_CODE=$?

   if [ $UNIT_EXIT_CODE -ne 0 ]; then
       echo "Unit tests failed!"
       exit 1
   fi

   # Run integration tests
   godot --script gdsentry/core/test_runner.gd --filter category:integration --discover
   INTEGRATION_EXIT_CODE=$?

   if [ $INTEGRATION_EXIT_CODE -ne 0 ]; then
       echo "Integration tests failed!"
       exit 1
   fi

   echo "All tests passed!"
   exit 0

Troubleshooting
===============

Common Issues
-------------

**No tests found**
^^^^^^^^^^^^^^^^^^
- Verify test files end with ``_test.gd``
- Check that test classes extend GDSentry base classes
- Ensure test methods start with ``test_``
- Verify file paths and permissions

**Tests fail with import errors**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Check that the GDSentry framework is properly copied to ``res://gdsentry/``
- Verify autoload configuration (GDTestManager)
- Ensure all dependencies are available

**Performance issues**
^^^^^^^^^^^^^^^^^^^^^^
- Use ``--parallel`` for faster execution
- Consider using ``--profile ci`` for optimized settings
- Reduce timeout values for faster feedback
- Use filtering to run only relevant tests

**CI/CD integration problems**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Use headless Godot builds (``--headless`` flag if available)
- Ensure proper display setup for visual tests
- Configure appropriate timeouts for CI environments
- Use JUnit output for better CI integration
