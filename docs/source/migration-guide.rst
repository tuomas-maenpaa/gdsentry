Migration Guide: v1.x to v2.0
===============================

This guide helps you migrate from GDSentry v1.x (Makefile-based) to v2.0 (CLI-based).

.. note::
   **Breaking Changes**: v2.0 introduces significant changes to improve the testing experience. This guide covers everything you need to know.

Overview of Changes
===================

**What Changed:**
- ❌ **Removed**: Makefile-based orchestration
- ❌ **Removed**: Copying GDSentry into your project
- ✅ **Added**: Standalone GDSentry CLI
- ✅ **Added**: External testing (CLI runs outside your project)
- ✅ **Added**: Container-based architecture support

**Why These Changes:**
- **Simpler workflow**: No more copying files into your project
- **Better isolation**: Test framework doesn't interfere with your game
- **Cross-platform**: Native support for different architectures
- **Modern tooling**: Standard CLI interface familiar to developers

Migration Steps
===============

Step 1: Install GDSentry CLI
----------------------------

**Before (v1.x):**
```bash
# No installation needed - you copied files
```

**After (v2.0):**
```bash
# Install CLI globally
pip install gdsentry

# Or use conda
conda install gdsentry

# Verify installation
gdsentry --help
```

Step 2: Remove Old GDSentry Files
----------------------------------

**Before (v1.x):** GDSentry lived in your project:
```
your-project/
├── gdsentry/           # ← REMOVE THIS
├── tests/
└── project.godot
```

**After (v2.0):** Clean project structure:
```
your-project/
├── tests/              # ← Your tests stay here
└── project.godot       # ← Your project stays here
```

**Migration Commands:**
```bash
# Remove old GDSentry files from your project
rm -rf gdsentry/
rm -rf gdsentry-*.zip

# Remove old autoload if it exists
# (Check Project → Project Settings → AutoLoad)
```

Step 3: Update Test File Names
------------------------------

**Before (v1.x):** Any filename worked:
```
tests/
├── player_tests.gd
├── combat.gd
└── ui_test.gd
```

**After (v2.0):** Must end with ``_test.gd``:
```
tests/
├── player_test.gd      # ← Renamed
├── combat_test.gd      # ← Renamed
└── ui_test.gd          # ← Already correct
```

**Migration Script:**
```bash
# Rename test files to match new pattern
cd your-project/tests
for file in *.gd; do
    if [[ $file != *_test.gd ]]; then
        mv "$file" "${file%.gd}_test.gd"
    fi
done
```

Step 4: Update Test Code
------------------------

**Test Structure:** No changes needed - your test code works the same.

**Base Classes:** Still available:
- ``SceneTreeTest`` - Unit tests
- ``Node2DTest`` - Visual tests
- ``IntegrationTest`` - System tests
- ``PerformanceTest`` - Performance tests

**Assertions:** All existing assertions work:
- ``assert_equals(a, b)``
- ``assert_true(condition)``
- ``assert_visible(node)``

Step 5: Replace Makefile Commands
----------------------------------

**Before (v1.x):**
```bash
# Old Makefile commands
scripts/setup-podman.sh              # Set up environment
gdsentry build all              # Build containers
gdsentry test run               # Run tests
gdsentry test run-framework     # Run framework tests
gdsentry info resources --cleanup              # Clean up
```

**After (v2.0):**
```bash
# New CLI commands
gdsentry build all          # Build containers
gdsentry test run           # Run project tests
gdsentry test run --scope framework  # Run framework tests
gdsentry build clean        # Clean up
```

Common Command Mappings:

+---------------------+-------------------------+
| Old (v1.x)          | New (v2.0)             |
+=====================+=========================+
| ``scripts/setup-podman.sh``      | ``pip install gdsentry`` |
+---------------------+-------------------------+
| ``gdsentry build all``      | ``gdsentry build all``   |
+---------------------+-------------------------+
| ``gdsentry test run``       | ``gdsentry test run``    |
+---------------------+-------------------------+
| ``gdsentry test run-quick`` | ``gdsentry test quick``  |
+---------------------+-------------------------+
| ``gdsentry info resources --cleanup``      | ``gdsentry build clean`` |
+---------------------+-------------------------+

Step 6: Update Configuration
----------------------------

**Before (v1.x):** JSON config files:
```json
{
  "test_timeout": 60.0,
  "test_discovery_scope": "framework"
}
```

**After (v2.0):** TOML config file (``gdsentry.toml``):
```toml
[project]
godot_version = "4.2.2"

[test]
timeout = 60.0

[report]
formats = ["console", "html"]
```

**Migration:**
```bash
# Convert JSON config to TOML
# Create gdsentry.toml in your project root
```

Step 7: Update CI/CD Pipelines
------------------------------

**GitHub Actions Example:**

**Before (v1.x):**
```yaml
- run: scripts/setup-podman.sh
- run: gdsentry build all
- run: gdsentry test run
```

**After (v2.0):**
```yaml
- run: pip install gdsentry
- run: gdsentry build all
- run: gdsentry test run
```

**Jenkins/GitLab:** Update pipeline scripts similarly.

Troubleshooting Migration
=========================

**"gdsentry command not found"**
- Ensure GDSentry CLI is installed: ``pip install gdsentry``
- Check PATH includes Python scripts directory
- Try ``python -m gdsentry`` instead

**"No tests discovered"**
- Verify test files end with ``_test.gd``
- Check test classes extend GDSentry base classes
- Run ``gdsentry test discover`` to debug

**"Container image not found"**
- Build containers first: ``gdsentry build all``
- Wait for build to complete (may take time)

**Old autoload conflicts**
- Remove GDTestManager from Project Settings → AutoLoad
- Restart Godot editor

**Configuration not loading**
- Rename config files from ``.json`` to ``gdsentry.toml``
- Convert JSON syntax to TOML
- Check file is in project root

Benefits of v2.0
================

**For Developers:**
- ✅ **Faster setup**: No copying files into projects
- ✅ **Cleaner projects**: No test framework clutter
- ✅ **Better isolation**: Framework doesn't interfere with game
- ✅ **Modern workflow**: Standard CLI tools

**For Teams:**
- ✅ **Consistent environments**: Container-based testing
- ✅ **Cross-platform**: Test on any architecture
- ✅ **CI/CD ready**: Native pipeline integration
- ✅ **Scalable**: Handles large test suites

**For Projects:**
- ✅ **No conflicts**: Framework versions don't clash
- ✅ **Updatable**: Easy to upgrade GDSentry
- ✅ **Portable**: Works across different machines
- ✅ **Maintainable**: Clear separation of concerns

Getting Help
============

- **Documentation**: :doc:`getting-started` | :doc:`user-guide` | :doc:`troubleshooting`
- **Example Code**: See :doc:`getting-started` and :doc:`user-guide` for complete examples
- **Issues**: `GitHub Issues <https://github.com/your-org/gdsentry/issues>`_

Need help migrating? `Open a discussion <https://github.com/your-org/gdsentry/discussions>`_.
