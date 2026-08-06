Python-GDScript Integration Mechanisms
========================================

Overview
--------

This document details how GDSentry's Python orchestration layer and GDScript execution layer communicate and coordinate. While the layers are deliberately decoupled (see :doc:`layer-independence`), they must integrate at specific points to enable test execution and result reporting.

Integration Points
------------------

GDSentry has **3 primary integration points** between Python and GDScript:

1. **Subprocess invocation** - Python launches Godot
2. **Stdout protocol** - GDScript sends test results to Python
3. **Shared configuration** - Both layers read ``gdsentry.toml``

Python → GDScript Communication
--------------------------------

Test Execution Command
~~~~~~~~~~~~~~~~~~~~~~

**Mechanism**: Subprocess execution of Godot with test file

**Implementation**:

.. code-block:: python

   # src/gdsentry/core/runner.py
   process = subprocess.Popen(
       ["godot", "--headless", "--script", test_file],
       stdout=subprocess.PIPE,
       stderr=subprocess.PIPE,
       cwd=project_root
   )
   output, errors = process.communicate(timeout=timeout)

**Data Passed**:

- Test file path (e.g., ``tests/unit/test_player.gd``)
- Godot CLI arguments (``--headless``, ``--script``)
- Working directory (project root)
- Environment variables (optional)

**Nature**: Command-line invocation, no direct API calls

Configuration File Access
~~~~~~~~~~~~~~~~~~~~~~~~~

**Mechanism**: GDScript reads ``gdsentry.toml`` directly from filesystem

**Implementation**:

.. code-block:: gdscript

   # GDScript reads config file
   var config_path = "res://gdsentry.toml"
   var config = ConfigFile.new()
   config.load(config_path)
   var timeout = config.get_value("test", "timeout", 300)

**Data Passed**:

- Test configuration (timeouts, categories)
- Reporter settings (output formats, paths)
- Project metadata (name, version)

**Nature**: File-based, no active propagation from Python

**Trade-off**: Configuration changes require both layers to parse the same file format correctly.

GDScript → Python Communication
--------------------------------

Stdout Protocol (Primary)
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Mechanism**: GDScript test output captured via stdout

This is the **PRIMARY and ONLY mechanism** for test result communication.

**Protocol Format**:

.. code-block:: text

   TEST_START: test_player_movement
   ASSERTION_PASS: Player position updated
   ASSERTION_PASS: Velocity calculated correctly
   TEST_PASS: test_player_movement (0.15s)
   
   TEST_START: test_player_collision
   ASSERTION_FAIL: Expected collision, got none
   TEST_FAIL: test_player_collision (0.08s)

**Implementation (GDScript)**:

.. code-block:: gdscript

   # src/test_types/base/gd_test.gd
   func _report_test_start(test_name: String) -> void:
       print("TEST_START: " + test_name)
   
   func _report_assertion(passed: bool, message: String) -> void:
       var status = "PASS" if passed else "FAIL"
       print("ASSERTION_" + status + ": " + message)
   
   func _report_test_end(test_name: String, passed: bool, duration: float) -> void:
       var status = "PASS" if passed else "FAIL"
       print("TEST_" + status + ": " + test_name + " (" + str(duration) + "s)")

**Implementation (Python)**:

.. code-block:: python

   # src/gdsentry/core/runner.py
   def parse_test_output(output: str) -> TestResult:
       lines = output.strip().split('\n')
       test_name = None
       passed = True
       assertions = []
       
       for line in lines:
           if line.startswith('TEST_START:'):
               test_name = line.split(':', 1)[1].strip()
           elif line.startswith('ASSERTION_'):
               status = 'PASS' in line
               message = line.split(':', 1)[1].strip()
               assertions.append((status, message))
           elif line.startswith('TEST_'):
               passed = 'PASS' in line
       
       return TestResult(test_name, passed, assertions)

**Critical Characteristics**:

- **Text-based**: Human-readable, easy to debug
- **Line-oriented**: Each line is a discrete message
- **Stateless**: Each message is self-contained
- **Fragile**: Format changes break Python parser

Exit Codes
~~~~~~~~~~

**Mechanism**: Godot process exit code indicates overall success/failure

**Values**:

- ``0`` - All tests passed
- ``1`` - One or more tests failed
- ``Non-zero`` - Godot crash or execution error

**Limitation**: Cannot convey detailed test results, only binary success/failure

Reporter Output Files
~~~~~~~~~~~~~~~~~~~~~

**Mechanism**: GDScript reporters write files that Python may read

**File Locations**:

- ``.runtime/test-reports/*.json`` - JSON test reports
- ``.runtime/test-reports/*.html`` - HTML test reports
- ``.runtime/test-reports/*.xml`` - JUnit XML reports

**Nature**: Asynchronous side channel, not integrated with main test flow

**Use Case**: Rich reporting data that doesn't fit in stdout protocol

Coupling Analysis
-----------------

Tight Coupling: Stdout Protocol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Location**: Python ``runner.py`` parses GDScript stdout

**Coupling Type**: Format coupling

**Risk**: Changes to GDScript output format break Python parsing

**Mitigation Strategies**:

1. **Protocol versioning**: Add version identifier to output
2. **Backward compatibility**: Support multiple protocol versions
3. **Schema validation**: Define formal protocol specification
4. **Integration tests**: Test Python parser against GDScript output

**Current Status**: Protocol appears stable but **undocumented** (see Finding #2 in tier3 analysis)

Medium Coupling: File Path Conventions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Location**: Python discovers test files, GDScript loads them

**Coupling Type**: Convention coupling

**Agreement Required**:

- Test files use ``.gd`` or ``.tscn`` extensions
- Tests located in ``tests/`` directory
- Godot resource paths use ``res://`` prefix

**Flexibility**: Standard Godot conventions, well-established

Loose Coupling: Configuration File
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Location**: Both layers read ``gdsentry.toml``

**Coupling Type**: Data format coupling

**Risk**: Low - TOML is stable, well-specified format

**Independence**: Each layer reads only the sections it needs

Integration Patterns
--------------------

Pattern 1: Fire and Forget
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Python launches Godot and waits for completion:

.. code-block:: python

   # Launch test
   process = subprocess.Popen([...])
   
   # Wait for completion
   output, errors = process.communicate(timeout=300)
   
   # Parse results
   results = parse_output(output)

**Characteristics**:

- No bidirectional communication during execution
- Python blocks until GDScript completes
- Simple, reliable pattern

Pattern 2: Parallel Reporting
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Python and GDScript reporters operate independently:

.. code-block:: text

   Python Reporter          GDScript Reporter
   ----------------         -----------------
   Parse stdout      →      Write JSON file
   Aggregate results →      Write HTML file
   Print summary     →      Write JUnit XML

**Characteristics**:

- No coordination between reporters
- Each layer produces its own outputs
- Enables independent evolution

Pattern 3: Shared Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Both layers read the same configuration file:

.. code-block:: toml

   # gdsentry.toml
   [test]
   timeout = 300
   
   [reporter]
   formats = ["json", "html"]
   output_dir = ".runtime/test-reports"

**Characteristics**:

- Single source of truth for configuration
- No active synchronization needed
- File system provides coordination

Design Guidelines
-----------------

Extending the Stdout Protocol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When adding new test result data:

1. **Add new message types**: Use consistent ``PREFIX: data`` format
2. **Maintain backward compatibility**: Old parsers should ignore unknown messages
3. **Document the change**: Update protocol specification
4. **Version the protocol**: Consider adding ``PROTOCOL_VERSION: 2`` message

**Example**:

.. code-block:: gdscript

   # New message type for performance data
   print("PERFORMANCE_METRIC: fps=" + str(fps) + " memory=" + str(memory_mb))

.. code-block:: python

   # Python parser (backward compatible)
   if line.startswith('PERFORMANCE_METRIC:'):
       # Parse performance data (optional)
       metrics = parse_performance_line(line)
   elif line.startswith('TEST_'):
       # Existing test result parsing
       pass

Adding New Configuration Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When adding configuration:

1. **Choose appropriate section**: ``[test]``, ``[reporter]``, ``[project]``
2. **Provide defaults**: Both layers should have sensible defaults
3. **Document the option**: Update configuration documentation
4. **Handle missing values**: Gracefully handle old config files

**Example**:

.. code-block:: toml

   [test]
   parallel_execution = false  # New option

.. code-block:: python

   # Python (with default)
   parallel = config.get("test", "parallel_execution", False)

.. code-block:: gdscript

   # GDScript (with default)
   var parallel = config.get_value("test", "parallel_execution", false)

File-Based Integration
~~~~~~~~~~~~~~~~~~~~~~

When using file-based communication:

1. **Use .runtime/ directory**: All runtime files go here
2. **Use standard formats**: JSON, XML, HTML
3. **Handle missing files**: Don't assume files exist
4. **Clean up old files**: Prevent accumulation

Protocol Specification
----------------------

Stdout Protocol v1.0
~~~~~~~~~~~~~~~~~~~~

**Message Types**:

- ``TEST_START: <test_name>`` - Test execution begins
- ``TEST_PASS: <test_name> (<duration>s)`` - Test passed
- ``TEST_FAIL: <test_name> (<duration>s)`` - Test failed
- ``ASSERTION_PASS: <message>`` - Assertion succeeded
- ``ASSERTION_FAIL: <message>`` - Assertion failed
- ``ERROR: <message>`` - Execution error

**Format Rules**:

- One message per line
- Messages are case-sensitive
- Duration in seconds with 2 decimal places
- Test names may contain spaces

**Example Session**:

.. code-block:: text

   TEST_START: player movement
   ASSERTION_PASS: Initial position is (0, 0)
   ASSERTION_PASS: Velocity applied correctly
   TEST_PASS: player movement (0.15s)
   TEST_START: enemy AI
   ASSERTION_FAIL: Expected path finding, got null
   ERROR: NullReferenceException in enemy.gd:45
   TEST_FAIL: enemy AI (0.08s)

Future Enhancements
-------------------

Potential improvements to integration:

1. **Protocol Versioning**: Add ``PROTOCOL_VERSION: 1.0`` message
2. **Structured Output**: Consider JSON lines format for complex data
3. **Streaming Results**: Real-time result updates during long tests
4. **Bidirectional Communication**: Python → GDScript commands via stdin
5. **Schema Validation**: Formal protocol schema for validation

Related Documentation
---------------------

- :doc:`layer-independence` - Architectural principle
- :doc:`plugin-system` - GDScript plugin architecture
- ``trail-artifacts/05-completed-artifacts/tier3-output/p1-integration-analysis.md`` - Detailed analysis

Conclusion
----------

Python-GDScript integration in GDSentry is deliberately minimal, relying on three well-defined coupling points. The stdout protocol is the critical integration mechanism and should be carefully maintained and documented. This design enables independent evolution while providing necessary coordination for test execution and reporting.
