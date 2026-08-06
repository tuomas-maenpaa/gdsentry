Version Compatibility
======================

This document outlines the version compatibility strategy for GDSentry, including supported Godot versions, compatibility layers, and migration guidelines.

Supported Versions
------------------

Current Support Matrix
~~~~~~~~~~~~~~~~~~~~~~

**Minimum Supported Version:** Godot 3.5.x

**Current Development Target:** Godot 4.4+

**Compatibility Strategy:** Progressive enhancement with backward compatibility

Version Support Details
~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Version Support Matrix
   :header-rows: 1
   :widths: 20 20 60

   * - Godot Version
     - Support Level
     - Notes
   * - 3.5.x
     - Full Support
     - Minimum supported version, all features available
   * - 3.6.x
     - Full Support
     - Compatible, may have some performance differences
   * - 4.0.x
     - Limited Support
     - Basic functionality, some features may not work
   * - 4.1.x
     - Good Support
     - Most features work, some enhancements available
   * - 4.2.x
     - Full Support
     - All 4.x features available
   * - 4.3.x
     - Full Support
     - All 4.x features available
   * - 4.4+
     - Full Support
     - Current development target, all features available

Compatibility Principles
------------------------

Design Philosophy
~~~~~~~~~~~~~~~~~

**Backward Compatibility First**

* All existing code must continue to work
* New features are additive, not replacing
* Clear deprecation paths for obsolete functionality

**Progressive Enhancement**

* Basic functionality works on all supported versions
* Enhanced features available on newer versions
* Graceful degradation when features aren't available

**Feature Detection over Version Checks**

* Use capability detection rather than version numbers
* Runtime checks for available APIs
* Fallback implementations for missing features

Compatibility Layers
--------------------

FileSystemCompatibility Layer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Purpose:** Abstract file system operations across Godot versions

**Key Features:**

* Unified API for file and directory operations
* Automatic version detection
* Fallback implementations for missing APIs

**Usage Example:**

.. code-block:: gdscript

   # Works on both Godot 3.5 and 4.x
   var file_exists = FileSystemCompatibility.file_exists("path/to/file")
   var content = FileSystemCompatibility.read_file_as_text("path/to/file")
   var success = FileSystemCompatibility.write_file_from_text("path/to/file", "content")

**Implementation Details:**

* Runtime detection of Godot version
* Dynamic API adaptation
* Error handling for version-specific edge cases

API Compatibility Layer
~~~~~~~~~~~~~~~~~~~~~~~

**Purpose:** Provide consistent API surface across versions

**Key Components:**

* Version-agnostic wrappers for Godot APIs
* Feature availability detection
* Consistent error handling

**Example Implementation:**

.. code-block:: gdscript

   class APICompatibility:
       static func get_scene_tree():
           # Returns SceneTree regardless of Godot version
           if Engine.get_version_info().major >= 4:
               return get_tree()
           else:
               return get_tree()  # Same in 3.5

       static func create_timer(time_sec: float):
           # Create timer with consistent API
           if Engine.get_version_info().major >= 4:
               return get_tree().create_timer(time_sec)
           else:
               var timer = Timer.new()
               timer.wait_time = time_sec
               get_tree().root.add_child(timer)
               timer.start()
               return timer

Testing Compatibility
~~~~~~~~~~~~~~~~~~~~~~

**Cross-Version Testing Strategy:**

* Test suite runs on all supported versions
* Version-specific test cases where needed
* Automated testing in CI/CD pipeline

**Testing Infrastructure:**

.. code-block:: gdscript

   class VersionCompatibilityTester:
       static func test_feature_availability():
           var features = {
               "file_system": _test_file_system_compatibility(),
               "scene_management": _test_scene_management(),
               "resource_loading": _test_resource_loading()
           }
           return features

       static func _test_file_system_compatibility() -> bool:
           # Test file operations work on current version
           var temp_file = "user://test_file.tmp"
           var success = FileSystemCompatibility.write_file_from_text(temp_file, "test")
           if not success:
               return false

           var content = FileSystemCompatibility.read_file_as_text(temp_file)
           FileSystemCompatibility.remove_file(temp_file)
           return content == "test"

Version Detection
-----------------

Detection Methods
~~~~~~~~~~~~~~~~~

**Engine Version Info:**

.. code-block:: gdscript

   static func get_godot_version_info() -> Dictionary:
       return Engine.get_version_info()

   static func is_godot_4_plus() -> bool:
       return Engine.get_version_info().major >= 4

   static func is_godot_4_2_plus() -> bool:
       var info = Engine.get_version_info()
       return info.major > 4 or (info.major == 4 and info.minor >= 2)

**Feature Detection:**

.. code-block:: gdscript

   static func has_feature(feature_name: String) -> bool:
       match feature_name:
           "modern_file_api":
               return is_godot_4_plus()
           "scene_tree_signals":
               return is_godot_4_plus()
           "resource_uids":
               return is_godot_4_2_plus()
           "custom_resources":
               return is_godot_4_plus()
       return false

**Runtime Environment Detection:**

.. code-block:: gdscript

   class EnvironmentDetector:
       static func is_editor() -> bool:
           return Engine.is_editor_hint()

       static func is_standalone() -> bool:
           return not Engine.is_editor_hint()

       static func is_ci_environment() -> bool:
           return OS.has_environment("CI")

       static func get_platform() -> String:
           return OS.get_name()

Migration Guidelines
--------------------

Upgrading from Godot 3.5 to 4.x
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Recommended Migration Path:**

1. **Phase 1: Compatibility Testing**
   - Run existing tests on Godot 4.x
   - Identify compatibility issues
   - Update compatibility layers as needed

2. **Phase 2: Feature Enhancement**
   - Gradually adopt 4.x specific features
   - Use progressive enhancement approach
   - Maintain 3.5.x compatibility during transition

3. **Phase 3: Full Migration**
   - Remove 3.5.x compatibility code
   - Update minimum version requirements
   - Optimize for 4.x features

**Migration Checklist:**

- [ ] Test suite passes on target version
- [ ] No deprecation warnings
- [ ] Documentation updated for new version
- [ ] Release notes include migration guide
- [ ] CI/CD pipeline tests new version

Common Migration Issues
~~~~~~~~~~~~~~~~~~~~~~~

**File System API Changes:**

.. code-block:: gdscript

   # Godot 3.5
   var file = File.new()
   file.open("path", File.READ)
   var content = file.get_as_text()
   file.close()

   # Godot 4.x
   var file = FileAccess.open("path", FileAccess.READ)
   var content = file.get_as_text()
   file.close()

   # GDSentry unified approach
   var content = FileSystemCompatibility.read_file_as_text("path")

**Scene Tree API Changes:**

.. code-block:: gdscript

   # Godot 3.5 - Node group management
   get_tree().call_group("enemies", "take_damage", 10)

   # Godot 4.x - Enhanced group calls
   get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "take_damage", 10)

   # GDSentry compatibility layer
   SceneTreeCompatibility.call_group_safely("enemies", "take_damage", 10)

**Resource Loading Changes:**

.. code-block:: gdscript

   # Godot 3.5
   var scene = load("res://scenes/game.tscn").instance()

   # Godot 4.x
   var scene = load("res://scenes/game.tscn").instantiate()

   # GDSentry compatibility layer
   var scene = ResourceCompatibility.load_scene("res://scenes/game.tscn")

Deprecation Strategy
--------------------

Deprecation Process
~~~~~~~~~~~~~~~~~~~

**1. Deprecation Warning Phase:**

.. code-block:: gdscript

   func deprecated_function():
       push_warning("deprecated_function() is deprecated. Use new_function() instead.")
       return new_function()

**2. Documentation Phase:**

* Mark deprecated functions in documentation
* Provide migration examples
* Update code examples to use new APIs

**3. Removal Phase:**

* Remove deprecated functionality in major version
* Provide clear upgrade path
* Update breaking changes documentation

**Deprecation Timeline:**

.. list-table:: Deprecation Timeline
   :header-rows: 1
   :widths: 20 40 40

   * - Version
     - Action
     - Timeline
   * - v1.x
     - Add deprecation warnings
     - Current version
   * - v2.0
     - Update documentation
     - Next minor version
   * - v3.0
     - Remove deprecated features
     - Next major version

Version-Specific Features
-------------------------

Godot 3.5.x Features
~~~~~~~~~~~~~~~~~~~~

**Fully Supported:**

* Basic file operations (File, Directory)
* Scene management and node hierarchy
* Signal system and groups
* Resource loading and saving
* Basic physics and collision detection

**Limitations:**

* No modern FileAccess API
* Limited async/await support
* Older GDScript syntax requirements
* No built-in UID system for resources

Godot 4.x Enhancements
~~~~~~~~~~~~~~~~~~~~~~

**New Features Available:**

* Modern FileAccess and DirAccess APIs
* Enhanced async/await support
* Improved GDScript performance
* Resource UID system
* Better error handling and debugging
* Enhanced editor integration

**Progressive Enhancement Examples:**

.. code-block:: gdscript

   # Basic functionality (works on 3.5+)
   func basic_file_operation(path: String) -> String:
       return FileSystemCompatibility.read_file_as_text(path)

   # Enhanced functionality (4.x only)
   func enhanced_file_operation(path: String) -> String:
       if not VersionDetector.is_godot_4_plus():
           return basic_file_operation(path)

       # Use 4.x specific features
       var file = FileAccess.open(path, FileAccess.READ)
       var content = file.get_as_text()
       file.close()
       return content

Testing Across Versions
-----------------------

Cross-Version Test Suite
~~~~~~~~~~~~~~~~~~~~~~~~

**Test Organization:**

* Core tests: Run on all supported versions
* Version-specific tests: Run only on compatible versions
* Integration tests: Validate compatibility layers

**Test Configuration:**

.. code-block:: gdscript

   class VersionAwareTestRunner:
       func run_tests_for_version(version: String):
           var core_tests = load_core_tests()
           var version_tests = load_version_specific_tests(version)

           var all_tests = core_tests + version_tests
           return run_test_suite(all_tests)

       func load_version_specific_tests(version: String) -> Array:
           match version:
               "3.5":
                   return load("res://tests/godot35_specific_tests.gd")
               "4.0":
                   return load("res://tests/godot4_specific_tests.gd")
               "4.2+":
                   return load("res://tests/godot4_advanced_tests.gd")
           return []

**CI/CD Integration:**

* Automated testing on multiple Godot versions
* Version compatibility validation
* Performance regression detection
* Compatibility layer testing

Future Compatibility Planning
-----------------------------

Upcoming Godot Versions
~~~~~~~~~~~~~~~~~~~~~~~

**Monitoring and Planning:**

* Track Godot development roadmap
* Identify potential breaking changes
* Plan compatibility strategies
* Update testing infrastructure

**Preparation Checklist:**

- [ ] Review Godot release notes for new versions
- [ ] Identify potential compatibility issues
- [ ] Develop compatibility strategies
- [ ] Update test suite for new features
- [ ] Plan migration timeline

Long-term Compatibility Strategy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Sustainability Planning:**

1. **Maintain Compatibility Window:** Keep supporting reasonable version range
2. **Regular Compatibility Updates:** Periodic review and updates
3. **Community Contribution:** Encourage community compatibility patches
4. **Documentation Maintenance:** Keep compatibility docs current

**Version Support Policy:**

* **Full Support:** Actively maintained, all features work
* **Limited Support:** Basic functionality, some features may not work
* **Deprecated Support:** Still works but no new features
* **End of Support:** No longer tested or maintained

**Example Policy Implementation:**

.. code-block:: gdscript

   class VersionSupportPolicy:
       const SUPPORT_WINDOW_MONTHS = 24
       const DEPRECATION_WINDOW_MONTHS = 12

       static func get_support_level(version: String) -> String:
           var age_months = calculate_version_age(version)
           if age_months <= SUPPORT_WINDOW_MONTHS:
               return "FULL_SUPPORT"
           elif age_months <= SUPPORT_WINDOW_MONTHS + DEPRECATION_WINDOW_MONTHS:
               return "LIMITED_SUPPORT"
           else:
               return "DEPRECATED"

This comprehensive approach ensures GDSentry remains compatible across Godot versions while providing a clear path for future development and maintenance.
