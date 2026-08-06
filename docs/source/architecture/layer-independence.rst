Layer Independence via Process Isolation
=========================================

Overview
--------

GDSentry's architecture is built on a fundamental principle: **Layer Independence via Process Isolation**. The Python orchestration layer and GDScript execution layer are deliberately decoupled through process boundaries, enabling independent evolution of each layer.

This is not a limitation—it's an intentional architectural design that provides significant benefits while accepting well-understood trade-offs.

Architectural Principle
-----------------------

**Principle**: Python orchestration and GDScript execution are deliberately decoupled through process boundaries, enabling independent evolution of each layer.

The Two Layers
--------------

Python Orchestration Layer
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Responsibilities**:

- Command-line interface (CLI)
- Test discovery and filtering
- Test execution orchestration
- Container management
- Configuration management
- Validation (GDScript syntax, imports, licenses)
- Python-level reporting and aggregation

**Location**: ``src/gdsentry/``

**Key Components**:

- CLI commands (``cli/commands/``)
- Test runner (``core/runner.py``)
- Test discovery (``core/discovery.py``)
- Configuration (``core/config.py``)
- Platform detection (``platform/detection.py``)
- Common utilities (``common/exceptions.py``)

GDScript Execution Layer
~~~~~~~~~~~~~~~~~~~~~~~~

**Responsibilities**:

- Test execution within Godot Engine
- Test type implementations (unit, integration, performance, visual)
- Assertion libraries
- Test reporting (JSON, HTML, JUnit formats)
- Testing utilities
- Plugin system

**Location**: ``src/`` (GDScript files)

**Key Components**:

- Test types (``test_types/``)
- Assertions (``assertions/``)
- Reporters (``reporters/``)
- Utilities (``utilities/``)
- Integration layer (``integration/``)

Decoupling Mechanism
---------------------

Process Isolation
~~~~~~~~~~~~~~~~~

The layers communicate through **process boundaries**:

1. Python launches Godot as a subprocess
2. Godot executes GDScript tests
3. Test results flow back via stdout
4. Python parses stdout and aggregates results

**Implementation**:

.. code-block:: python

   # Python layer (simplified)
   process = subprocess.Popen(
       ["godot", "--headless", "--script", test_file],
       stdout=subprocess.PIPE,
       stderr=subprocess.PIPE
   )
   output, errors = process.communicate()
   results = parse_test_output(output)

Communication Protocol
~~~~~~~~~~~~~~~~~~~~~~

**Primary Mechanism**: Stdout protocol

- GDScript tests print structured output to stdout
- Python parses this output to extract test results
- Protocol includes test names, status, assertions, timing

**Secondary Mechanisms**:

- **Shared configuration**: ``gdsentry.toml`` read by both layers
- **File-based reports**: GDScript reporters write to ``.runtime/test-reports/``

Minimal Coupling Points
~~~~~~~~~~~~~~~~~~~~~~~

The architecture maintains only **3 coupling points**:

1. **Subprocess invocation**: Python calls Godot CLI
2. **Stdout protocol**: Structured text output from GDScript
3. **Shared config file**: ``gdsentry.toml`` configuration

All coupling uses well-established mechanisms (CLI, stdout, files)—no custom RPC, no shared memory, no tight integration.

Benefits Realized
-----------------

1. Independent Evolution
~~~~~~~~~~~~~~~~~~~~~~~~

Python and GDScript layers can evolve independently without affecting each other:

- Update Python CLI without touching GDScript
- Add new GDScript test types without Python changes
- Refactor reporters in either layer independently

2. Language Isolation
~~~~~~~~~~~~~~~~~~~~~

No cross-language binding complexity:

- No Python-Godot FFI bindings required
- No GDNative/GDExtension complexity
- Each layer uses its native ecosystem

3. Process Stability
~~~~~~~~~~~~~~~~~~~~

GDScript crashes don't crash Python orchestrator:

- Godot crashes are isolated to subprocess
- Python can detect failures and report them
- Test suite continues even if individual tests crash

4. Testability
~~~~~~~~~~~~~~

Each layer is testable independently:

- Python layer: Standard pytest tests
- GDScript layer: Self-tests within Godot
- No need for complex integration test setup

5. Simplicity
~~~~~~~~~~~~~

No complex integration code:

- Standard subprocess management
- Simple text parsing
- No RPC framework overhead
- No serialization complexity

Trade-offs Accepted
-------------------

1. Communication Cost
~~~~~~~~~~~~~~~~~~~~~

Subprocess + stdout parsing has overhead:

- Process creation cost per test file
- Text parsing overhead
- Cannot pass complex objects directly

**Mitigation**: Batch tests when possible, optimize stdout protocol

2. Protocol Fragility
~~~~~~~~~~~~~~~~~~~~~

Stdout protocol is text-based and could break:

- Changes to GDScript output format require Python parser updates
- No schema validation
- Debugging can be challenging

**Mitigation**: Document protocol specification, add protocol versioning

3. Limited Data Flow
~~~~~~~~~~~~~~~~~~~~

Only stdout available for test results:

- Cannot stream rich data structures
- Limited to text-based communication
- File system used for complex reports

**Mitigation**: Use file-based reports for rich data (JSON, HTML)

4. No Rich Integration
~~~~~~~~~~~~~~~~~~~~~~

Cannot pass complex objects between layers:

- No direct Python-GDScript object sharing
- No callbacks from GDScript to Python
- Limited to simple data types in protocol

**Mitigation**: Design for message-passing, not object sharing

Evidence of Intentional Design
-------------------------------

This is not accidental decoupling. Evidence:

Consistent Pattern
~~~~~~~~~~~~~~~~~~

- **All 13 components** analyzed show the same decoupling pattern
- No exceptions, no inconsistencies
- Pattern is universal across the codebase

Architectural Boundaries Respected
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Python layer: Orchestration, CLI, validation, containerization
- GDScript layer: Test execution, reporting, assertions, utilities
- Clear separation of concerns by language
- Each layer has complete capabilities for its domain

Deliberate Choice
~~~~~~~~~~~~~~~~~

- Godot runs as subprocess (not embedded)
- Could have used Godot Python bindings (GDNative/GDExtension)
- Chose subprocess model for isolation
- This was an architectural decision, not a technical limitation

Parallel Systems
~~~~~~~~~~~~~~~~

- Dual reporter systems (Python and GDScript)
- Separate assertion libraries
- Plugin system is GDScript-only
- Each layer is self-sufficient

Module Organization
~~~~~~~~~~~~~~~~~~~

The Python layer uses a modular structure to avoid circular dependencies:

- **common/** - Shared utilities and exceptions (no dependencies on other modules)
- **core/** - Core framework functionality (depends on common)
- **platform/** - Platform detection and compatibility (depends on common)
- **cli/** - Command-line interface (depends on core and platform)
- **container/** - Container management (depends on core)

This organization ensures clean dependency graphs and maintainable code structure.

No Accidental Indicators
~~~~~~~~~~~~~~~~~~~~~~~~~

No evidence of accidental decoupling:

- ❌ No half-built integration attempts
- ❌ No deprecated tight-coupling code
- ❌ No TODO comments about "should integrate"
- ❌ No architectural debt patterns

Design Guidelines
-----------------

When to Maintain Separation
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**DO** keep layers separate when:

- Feature belongs clearly to one layer
- No cross-layer data flow required
- Layer-specific implementation is simpler

**Examples**:

- New test types → GDScript only
- New CLI commands → Python only
- New assertion methods → GDScript only

When to Add Integration
~~~~~~~~~~~~~~~~~~~~~~~

**DO** add integration when:

- Feature requires coordination between layers
- Data must flow from GDScript to Python
- Configuration affects both layers

**Examples**:

- New test result fields → Update stdout protocol
- New configuration options → Update both parsers
- New report formats → Coordinate file locations

Protocol Evolution
~~~~~~~~~~~~~~~~~~

When evolving the stdout protocol:

1. **Version the protocol**: Add version identifier to output
2. **Maintain backward compatibility**: Support old formats during transition
3. **Document changes**: Update protocol specification
4. **Test both sides**: Verify Python parser and GDScript output

Related Documentation
---------------------

- :doc:`python-gdscript-integration` - Detailed integration mechanisms
- :doc:`plugin-system` - GDScript plugin architecture
- ``trail-artifacts/05-completed-artifacts/tier3-output/p1-integration-analysis.md`` - Comprehensive analysis

Conclusion
----------

Layer Independence via Process Isolation is a **core architectural principle** of GDSentry. It enables independent evolution, language isolation, and process stability while accepting communication overhead and protocol fragility.

This design is intentional, well-evidenced, and should be preserved as the framework evolves.
