Reporter Systems
================

Overview
--------

GDSentry's reporter system provides flexible, extensible test result reporting in multiple formats. The system operates entirely within the **GDScript execution layer** and generates reports from test execution data.

**Key Features**:

- Multiple output formats (JUnit XML, HTML, JSON)
- Extensible reporter architecture
- Centralized reporter management
- Rich test result data structures
- CI/CD integration support
- Screenshot and metadata inclusion

Architecture
------------

Component Hierarchy
~~~~~~~~~~~~~~~~~~~

.. code-block:: text

    ReporterManager (Coordinator)
         │
         ├─── TestReporter (Abstract Base)
         │         │
         │         ├─── JUnitReporter (XML format)
         │         ├─── HTMLReporter (HTML format)
         │         └─── JSONReporter (JSON format)
         │
         └─── TestResult (Data Structures)
                   │
                   ├─── TestResultData
                   ├─── TestAssertionData
                   └─── TestSuiteResult

Core Components
---------------

TestReporter (Abstract Base)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Location**: ``src/reporters/base/test_reporter.gd``

**Purpose**: Defines the standard interface for all reporter implementations.

**Key Responsibilities**:

- Configuration management
- Output directory handling
- Format validation
- Error handling
- Abstract method definitions

**Configuration Options**:

.. code-block:: gdscript

    var output_directory: String = "res://.runtime/test-reports/"
    var include_screenshots: bool = false
    var include_metadata: bool = true
    var pretty_print: bool = true
    var timestamp_format: String = "%Y-%m-%d %H:%M:%S"
    var suppress_console_errors: bool = false

**Abstract Methods** (must be implemented by subclasses):

- ``generate_report(test_suite, output_path)`` - Generate report in specific format
- ``get_supported_formats()`` - Return supported format strings
- ``get_default_filename()`` - Return default filename
- ``get_format_extension()`` - Return file extension

TestResult Data Structures
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Location**: ``src/reporters/base/test_result.gd``

**Purpose**: Comprehensive data structures for capturing test execution results.

TestResultData
^^^^^^^^^^^^^^

Captures individual test execution information:

.. code-block:: gdscript

    class TestResultData:
        var test_name: String
        var test_class: String
        var test_category: String
        var status: String  # "passed", "failed", "skipped", "error"
        var execution_time: float
        var error_message: String
        var stack_trace: String
        var assertions: Array[TestAssertionData]
        var metadata: Dictionary

**Methods**:

- ``mark_passed()`` - Mark test as passed
- ``mark_failed(message, trace)`` - Mark test as failed
- ``mark_error(message, trace)`` - Mark test as error
- ``mark_skipped(reason)`` - Mark test as skipped
- ``add_assertion(assertion)`` - Add assertion result
- ``get_assertion_count()`` - Get total assertions
- ``get_passed_assertion_count()`` - Get passed assertions
- ``get_failed_assertion_count()`` - Get failed assertions

TestAssertionData
^^^^^^^^^^^^^^^^^

Captures individual assertion results:

.. code-block:: gdscript

    class TestAssertionData:
        var type: String  # "equals", "true", "false", etc.
        var expected: Variant
        var actual: Variant
        var passed: bool
        var message: String
        var timestamp: float

TestSuiteResult
^^^^^^^^^^^^^^^

Aggregates results from multiple tests:

.. code-block:: gdscript

    class TestSuiteResult:
        var suite_name: String
        var test_results: Array[TestResultData]
        var start_time: float
        var end_time: float
        var execution_time: float

**Aggregation Methods**:

- ``get_total_tests()`` - Total test count
- ``get_passed_tests()`` - Passed test count
- ``get_failed_tests()`` - Failed test count
- ``get_error_tests()`` - Error test count
- ``get_skipped_tests()`` - Skipped test count
- ``get_total_assertions()`` - Total assertion count
- ``get_passed_assertions()`` - Passed assertion count
- ``get_failed_assertions()`` - Failed assertion count
- ``get_success_rate()`` - Success percentage
- ``has_failures()`` - Check for any failures

Reporter Implementations
------------------------

JUnitReporter
~~~~~~~~~~~~~

**Location**: ``src/reporters/formats/junit_reporter.gd``

**Format**: JUnit XML (industry standard for CI/CD)

**Use Case**: Jenkins, GitLab CI, GitHub Actions, Azure DevOps

**Output Structure**:

.. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
        <testsuite name="GDSentry Test Suite" tests="10" failures="1" errors="0" skipped="0" time="2.345">
            <testcase name="test_example" classname="TestClass" time="0.123">
                <system-out>Test output</system-out>
            </testcase>
            <testcase name="test_failure" classname="TestClass" time="0.234">
                <failure message="Assertion failed">Stack trace</failure>
            </testcase>
        </testsuite>
    </testsuites>

**Configuration**:

.. code-block:: gdscript

    var include_system_out: bool = true
    var include_system_err: bool = true
    var include_properties: bool = true
    var group_by_class: bool = true

HTMLReporter
~~~~~~~~~~~~

**Location**: ``src/reporters/formats/html_reporter.gd``

**Format**: HTML with embedded CSS

**Use Case**: Human-readable reports, documentation, archival

**Features**:

- Color-coded test results
- Expandable assertion details
- Execution time visualization
- Screenshot embedding
- Responsive design
- Dark/light theme support

**Configuration**:

.. code-block:: gdscript

    var include_css: bool = true
    var include_javascript: bool = true
    var embed_screenshots: bool = true
    var show_assertion_details: bool = true
    var theme: String = "light"  # "light" or "dark"

JSONReporter
~~~~~~~~~~~~

**Location**: ``src/reporters/formats/json_reporter.gd``

**Format**: Structured JSON

**Use Case**: Programmatic consumption, APIs, dashboards, analysis

**Schema Version**: 1.0

**Output Structure**:

.. code-block:: json

    {
        "schema_version": "1.0",
        "suite_name": "GDSentry Test Suite",
        "start_time": 1698012345.678,
        "end_time": 1698012347.890,
        "execution_time": 2.212,
        "summary": {
            "total_tests": 10,
            "passed_tests": 9,
            "failed_tests": 1,
            "error_tests": 0,
            "skipped_tests": 0,
            "success_rate": 90.0
        },
        "test_results": [...]
    }

**Configuration**:

.. code-block:: gdscript

    var include_assertion_details: bool = true
    var include_system_info: bool = true
    var include_environment_data: bool = true
    var flatten_results: bool = false
    var group_by_category: bool = true

ReporterManager
~~~~~~~~~~~~~~~

**Location**: ``src/reporters/manager/reporter_manager.gd``

**Purpose**: Central coordinator for managing multiple reporters.

**Key Features**:

- Reporter registration and lifecycle
- Multi-format report generation
- Configuration management
- Error handling and recovery
- Format validation

**Usage**:

.. code-block:: gdscript

    var manager = ReporterManager.new()
    manager.initialize()
    
    # Register reporters
    manager.register_reporter("junit", JUnitReporter.new())
    manager.register_reporter("html", HTMLReporter.new())
    manager.register_reporter("json", JSONReporter.new())
    
    # Configure
    manager.configure_reporter("junit", {"include_system_out": true})
    
    # Generate reports
    manager.generate_all_reports(test_suite)

**Methods**:

- ``initialize()`` - Initialize with default reporters
- ``register_reporter(format, reporter)`` - Register custom reporter
- ``unregister_reporter(format)`` - Remove reporter
- ``configure_reporter(format, config)`` - Configure specific reporter
- ``generate_report(format, test_suite, output_path)`` - Generate single format
- ``generate_all_reports(test_suite)`` - Generate all registered formats
- ``get_available_formats()`` - List registered formats

Report Generation Flow
----------------------

1. **Test Execution**
   
   - Tests execute in GDScript layer
   - Results captured in TestResultData structures
   - Assertions recorded in TestAssertionData
   - Suite aggregates all results in TestSuiteResult

2. **Report Generation**
   
   - ReporterManager receives TestSuiteResult
   - Each registered reporter processes the data
   - Reporters transform data to their specific format
   - Output written to ``.runtime/test-reports/``

3. **Output Organization**

   .. code-block:: text

       .runtime/test-reports/
       ├── junit/
       │   └── test_results.xml
       ├── html/
       │   └── test_report.html
       ├── json/
       │   └── test_results.json
       └── screenshots/
           ├── test_1_screenshot.png
           └── test_2_screenshot.png

CI/CD Integration
-----------------

JUnit XML Integration
~~~~~~~~~~~~~~~~~~~~~

**Jenkins**:

.. code-block:: groovy

    post {
        always {
            junit '.runtime/test-reports/junit/*.xml'
        }
    }

**GitLab CI**:

.. code-block:: yaml

    test:
      script:
        - python -m gdsentry.cli test
      artifacts:
        reports:
          junit: .runtime/test-reports/junit/*.xml

**GitHub Actions**:

.. code-block:: yaml

    - name: Run Tests
      run: python -m gdsentry.cli test
    
    - name: Publish Test Results
      uses: EnricoMi/publish-unit-test-result-action@v2
      with:
        files: .runtime/test-reports/junit/*.xml

HTML Report Artifacts
~~~~~~~~~~~~~~~~~~~~~

**GitLab CI**:

.. code-block:: yaml

    artifacts:
      paths:
        - .runtime/test-reports/html/
      expire_in: 1 week

**GitHub Actions**:

.. code-block:: yaml

    - name: Upload HTML Report
      uses: actions/upload-artifact@v3
      with:
        name: test-report
        path: .runtime/test-reports/html/

JSON API Integration
~~~~~~~~~~~~~~~~~~~~

**Example: Parse and analyze JSON results**:

.. code-block:: python

    import json
    
    with open('.runtime/test-reports/json/test_results.json') as f:
        results = json.load(f)
    
    if results['summary']['success_rate'] < 95.0:
        print("Warning: Test success rate below threshold")
        exit(1)

Creating Custom Reporters
--------------------------

To create a custom reporter:

1. **Extend TestReporter**:

   .. code-block:: gdscript

       extends TestReporter
       
       class_name CustomReporter

2. **Implement Abstract Methods**:

   .. code-block:: gdscript

       func generate_report(test_suite, output_path: String) -> void:
           # Generate custom format
           var custom_data = _transform_data(test_suite)
           _write_output(custom_data, output_path)
       
       func get_supported_formats() -> Array[String]:
           return ["custom"]
       
       func get_default_filename() -> String:
           return "test_report"
       
       func get_format_extension() -> String:
           return ".custom"

3. **Register with ReporterManager**:

   .. code-block:: gdscript

       var manager = ReporterManager.new()
       manager.register_reporter("custom", CustomReporter.new())

Best Practices
--------------

Report Configuration
~~~~~~~~~~~~~~~~~~~~

1. **CI/CD Environments**
   
   - Enable JUnit XML for pipeline integration
   - Disable pretty printing for smaller files
   - Include system info for debugging
   - Set appropriate output directories

2. **Local Development**
   
   - Enable HTML for human-readable results
   - Include screenshots for visual tests
   - Enable pretty printing for readability
   - Include assertion details

3. **Production Monitoring**
   
   - Enable JSON for programmatic analysis
   - Include environment data
   - Group by category for organization
   - Store historical results

Output Management
~~~~~~~~~~~~~~~~~

1. **Use .runtime/ Directory**
   
   - All reports in ``.runtime/test-reports/``
   - Excluded from version control
   - Centralized cleanup
   - CI/CD artifact collection

2. **Organize by Format**
   
   - Separate subdirectories per format
   - Consistent naming conventions
   - Timestamp-based archival
   - Automatic cleanup of old reports

3. **Screenshot Handling**
   
   - Store in dedicated subdirectory
   - Reference from reports
   - Compress for CI/CD artifacts
   - Clean up after report generation

Error Handling
~~~~~~~~~~~~~~

1. **Graceful Degradation**
   
   - Continue if one reporter fails
   - Log errors without stopping execution
   - Provide partial results when possible
   - Validate output before writing

2. **Validation**
   
   - Check test suite data completeness
   - Validate output paths
   - Verify file write permissions
   - Confirm format compatibility

3. **Recovery**
   
   - Retry on transient failures
   - Fall back to console output
   - Preserve raw data for manual recovery
   - Log detailed error information

Related Documentation
---------------------

- :doc:`layer-independence` - Python-GDScript separation
- :doc:`stdout-protocol` - Communication mechanism
- :doc:`advanced-test-types` - Performance and visual testing
- :doc:`../api/gdscript/assertions` - Assertion libraries

Implementation Files
--------------------

**Base Classes**:

- ``src/reporters/base/test_reporter.gd`` - Abstract reporter base
- ``src/reporters/base/test_result.gd`` - Data structures

**Format Implementations**:

- ``src/reporters/formats/junit_reporter.gd`` - JUnit XML
- ``src/reporters/formats/html_reporter.gd`` - HTML
- ``src/reporters/formats/json_reporter.gd`` - JSON

**Management**:

- ``src/reporters/manager/reporter_manager.gd`` - Reporter coordinator

**Templates**:

- ``src/reporters/templates/`` - HTML templates and CSS
