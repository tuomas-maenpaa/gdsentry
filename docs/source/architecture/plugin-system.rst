GDScript Plugin System
======================

Overview
--------

GDSentry includes an extensible plugin system that allows developers to extend the framework with custom test types, assertions, reporters, and integrations. The plugin system is **GDScript-only** and operates entirely within the Godot execution layer.

This is an intentional design choice that aligns with the Layer Independence principle (see :doc:`layer-independence`).

Plugin Architecture
-------------------

Core Concepts
~~~~~~~~~~~~~

**Plugin System Location**: ``src/integration/plugin_system.gd``

**Plugin Types**:

1. **Test Type Plugins** - Custom test implementations
2. **Assertion Plugins** - Custom assertion libraries
3. **Reporter Plugins** - Custom output formats
4. **Integration Plugins** - External tool integrations
5. **Utility Plugins** - Helper functions and utilities

**Plugin Discovery**:

- Built-in plugins: ``res://gdsentry/plugins/``
- Custom plugins: ``res://gdsentry_plugins/``

Plugin Structure
~~~~~~~~~~~~~~~~

Each plugin consists of:

1. **Plugin configuration** (``plugin.json``)
2. **Plugin script** (GDScript implementation)
3. **Optional resources** (scenes, assets, etc.)

**Directory Layout**:

.. code-block:: text

   gdsentry_plugins/
   └── my_custom_plugin/
       ├── plugin.json          # Plugin metadata
       ├── my_plugin.gd         # Plugin implementation
       └── resources/           # Optional resources
           └── icon.png

Plugin Configuration
--------------------

plugin.json Format
~~~~~~~~~~~~~~~~~~

.. code-block:: json

   {
     "id": "my_custom_plugin",
     "name": "My Custom Plugin",
     "version": "1.0.0",
     "type": "test_type",
     "script": "my_plugin.gd",
     "description": "Custom test type for specific use case",
     "author": "Your Name",
     "dependencies": ["core_assertions"]
   }

**Required Fields**:

- ``id`` - Unique plugin identifier
- ``name`` - Human-readable plugin name
- ``version`` - Semantic version (e.g., "1.0.0")
- ``type`` - Plugin type (test_type, assertion, reporter, integration, utility)
- ``script`` - Path to plugin script relative to plugin directory

**Optional Fields**:

- ``description`` - Plugin description
- ``author`` - Plugin author
- ``dependencies`` - Array of plugin IDs this plugin depends on

Plugin Types
------------

Test Type Plugins
~~~~~~~~~~~~~~~~~

Extend the framework with custom test types.

**Base Class**: Inherit from ``GDTest`` or custom base

**Example**:

.. code-block:: gdscript

   # my_custom_test.gd
   extends GDTest
   
   class_name MyCustomTest
   
   func initialize() -> bool:
       print("Initializing custom test type")
       return true
   
   func run_test() -> void:
       # Custom test execution logic
       pass

**Registration**: Automatically registered when plugin loads

Assertion Plugins
~~~~~~~~~~~~~~~~~

Add custom assertion methods.

**Example**:

.. code-block:: gdscript

   # custom_assertions.gd
   extends Node
   
   class_name CustomAssertions
   
   func assert_within_range(value: float, min_val: float, max_val: float, message: String = "") -> bool:
       var passed = value >= min_val and value <= max_val
       if not passed:
           push_error("Assertion failed: " + message)
       return passed

Reporter Plugins
~~~~~~~~~~~~~~~~

Create custom output formats.

**Base Class**: Inherit from ``TestReporter``

**Example**:

.. code-block:: gdscript

   # markdown_reporter.gd
   extends TestReporter
   
   class_name MarkdownReporter
   
   func generate_report(test_suite, output_path: String) -> void:
       var markdown = "# Test Results\n\n"
       # Generate markdown content
       save_report(output_path, markdown)

Integration Plugins
~~~~~~~~~~~~~~~~~~~

Integrate with external tools and services.

**Example**:

.. code-block:: gdscript

   # slack_integration.gd
   extends Node
   
   class_name SlackIntegration
   
   func send_test_results(results: Dictionary) -> void:
       # Send results to Slack webhook
       pass

Plugin Lifecycle
----------------

Discovery Phase
~~~~~~~~~~~~~~~

1. System scans ``res://gdsentry/plugins/`` for built-in plugins
2. System scans ``res://gdsentry_plugins/`` for custom plugins
3. Each plugin directory is checked for ``plugin.json``

Loading Phase
~~~~~~~~~~~~~

1. Plugin configuration is validated
2. Dependencies are resolved
3. Plugins are loaded in dependency order
4. Plugin scripts are instantiated

Initialization Phase
~~~~~~~~~~~~~~~~~~~~

1. Plugin ``initialize()`` method is called
2. Plugin components are registered with framework
3. Plugin becomes available for use

**Code Flow**:

.. code-block:: gdscript

   # Plugin system initialization
   func initialize_plugin_system() -> void:
       print("🔌 Initializing GDSentry Plugin System...")
       
       # Load plugins in dependency order
       load_plugins_in_dependency_order()
       
       # Initialize all loaded plugins
       for plugin_id in plugin_load_order:
           var plugin = loaded_plugins[plugin_id]
           if plugin and plugin.has_method("initialize"):
               plugin.initialize()
       
       # Register plugin components
       register_plugin_components()
       
       plugins_initialized = true

Dependency Management
---------------------

Plugin Dependencies
~~~~~~~~~~~~~~~~~~~

Plugins can declare dependencies on other plugins:

.. code-block:: json

   {
     "id": "advanced_assertions",
     "dependencies": ["core_assertions", "math_utils"]
   }

**Dependency Resolution**:

- Dependencies are loaded before dependent plugins
- Circular dependencies are detected and reported
- Missing dependencies cause plugin load failure

Load Order
~~~~~~~~~~

Plugins are loaded in topological order based on dependencies:

.. code-block:: text

   core_assertions (no dependencies)
   ↓
   math_utils (depends on core_assertions)
   ↓
   advanced_assertions (depends on core_assertions, math_utils)

Creating a Plugin
-----------------

Step 1: Create Plugin Directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   mkdir -p gdsentry_plugins/my_plugin

Step 2: Create plugin.json
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: json

   {
     "id": "my_plugin",
     "name": "My Plugin",
     "version": "1.0.0",
     "type": "test_type",
     "script": "my_plugin.gd",
     "description": "My custom test type"
   }

Step 3: Implement Plugin Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: gdscript

   # my_plugin.gd
   extends GDTest
   
   class_name MyPlugin
   
   var plugin_id: String
   var plugin_name: String
   var plugin_path: String
   var is_built_in: bool
   var config: Dictionary
   
   func initialize() -> bool:
       print("Initializing " + plugin_name)
       # Plugin initialization logic
       return true
   
   func run_test() -> void:
       # Test execution logic
       pass

Step 4: Test Plugin
~~~~~~~~~~~~~~~~~~~

1. Place plugin in ``gdsentry_plugins/my_plugin/``
2. Run GDSentry tests
3. Plugin will be automatically discovered and loaded

Plugin API
----------

Required Methods
~~~~~~~~~~~~~~~~

**initialize() -> bool**

Called during plugin initialization. Return ``true`` on success.

.. code-block:: gdscript

   func initialize() -> bool:
       # Setup plugin
       return true

Optional Methods
~~~~~~~~~~~~~~~~

**cleanup() -> void**

Called when plugin is unloaded.

.. code-block:: gdscript

   func cleanup() -> void:
       # Cleanup resources
       pass

**get_capabilities() -> Array**

Return array of capabilities this plugin provides.

.. code-block:: gdscript

   func get_capabilities() -> Array:
       return ["custom_assertions", "performance_metrics"]

Plugin Metadata
~~~~~~~~~~~~~~~

Plugins receive metadata during loading:

- ``plugin_id`` - Unique identifier
- ``plugin_name`` - Display name
- ``plugin_path`` - File system path
- ``is_built_in`` - Whether plugin is built-in
- ``config`` - Full configuration dictionary

Design Rationale
----------------

Why GDScript-Only?
~~~~~~~~~~~~~~~~~~

The plugin system is deliberately GDScript-only for several reasons:

1. **Layer Independence**: Maintains separation between Python orchestration and GDScript execution
2. **Godot Integration**: Plugins need deep Godot Engine integration
3. **Test Execution Context**: Plugins operate during test execution (GDScript layer)
4. **Simplicity**: No cross-language plugin coordination required

**Trade-offs**:

- Python layer cannot directly extend via plugins
- Plugin discovery happens in GDScript, not Python
- Configuration must be GDScript-compatible (JSON)

Why Not Python Plugins?
~~~~~~~~~~~~~~~~~~~~~~~~

Python layer extensibility is achieved through:

- **Python packages**: Standard Python packaging and imports
- **CLI commands**: New commands via Click framework
- **Reporters**: Python reporter classes

This provides Python extensibility without needing a plugin system.

Best Practices
--------------

Plugin Design
~~~~~~~~~~~~~

1. **Single Responsibility**: Each plugin should do one thing well
2. **Clear Dependencies**: Declare all dependencies explicitly
3. **Error Handling**: Handle errors gracefully, don't crash framework
4. **Documentation**: Include clear documentation in plugin
5. **Versioning**: Use semantic versioning

Performance
~~~~~~~~~~~

1. **Lazy Loading**: Load resources only when needed
2. **Minimal Initialization**: Keep ``initialize()`` fast
3. **Resource Cleanup**: Clean up resources in ``cleanup()``

Compatibility
~~~~~~~~~~~~~

1. **Godot Version**: Specify compatible Godot versions
2. **GDSentry Version**: Test against target GDSentry version
3. **API Stability**: Use stable APIs, avoid internal implementation details

Security
~~~~~~~~

1. **Validate Input**: Validate all external input
2. **Sandbox Awareness**: Plugins run with full Godot permissions
3. **Code Review**: Review plugin code before use

Built-in Plugins
----------------

GDSentry includes several built-in plugins:

- **Core Test Types**: Unit, integration, performance, visual
- **Core Assertions**: Math, string, collection assertions
- **Standard Reporters**: JSON, HTML, JUnit XML
- **Utilities**: File system, data-driven tests, memory profiling

These serve as examples for custom plugin development.

Troubleshooting
---------------

Plugin Not Loading
~~~~~~~~~~~~~~~~~~

**Check**:

1. ``plugin.json`` exists and is valid JSON
2. Required fields are present
3. Plugin script path is correct
4. Dependencies are available

**Debug**:

.. code-block:: gdscript

   # Enable debug output
   if OS.is_debug_build():
       print("Plugin load attempt: " + plugin_path)

Circular Dependencies
~~~~~~~~~~~~~~~~~~~~~

**Error**: "Circular dependency detected for plugin: X"

**Solution**: Review dependency chain, remove circular references

Plugin Initialization Failed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Check**:

1. ``initialize()`` method exists
2. Method returns ``bool``
3. No errors during initialization

Future Enhancements
-------------------

Potential improvements:

1. **Hot Reload**: Reload plugins without restarting
2. **Plugin Marketplace**: Central repository for community plugins
3. **Version Constraints**: Specify compatible version ranges
4. **Plugin Sandboxing**: Limit plugin permissions
5. **Plugin API Documentation**: Auto-generated API docs

Related Documentation
---------------------

- :doc:`layer-independence` - Why plugins are GDScript-only
- :doc:`python-gdscript-integration` - Layer communication
- ``src/integration/plugin_system.gd`` - Plugin system implementation

Conclusion
----------

The GDScript plugin system provides powerful extensibility while maintaining architectural boundaries. By keeping plugins in the GDScript layer, the system preserves Layer Independence while enabling rich customization of test execution, assertions, and reporting.
