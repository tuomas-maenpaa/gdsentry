GDSentry - Advanced Godot Testing Framework
=========================================

GDSentry represents a fundamental shift in how developers approach testing within the Godot ecosystem. Traditional testing frameworks focus narrowly on unit testing, but GDSentry recognizes that game development demands comprehensive validation across multiple dimensions: visual correctness, performance requirements, UI interactions, and system integration.

.. admonition:: Quick Start
   :class: tip

   **New to Testing?** → :doc:`getting-started` (5 minutes to first test)

   **Experienced Tester?** → :doc:`user-guide` (comprehensive patterns)

   **Need Quick Help?** → :doc:`quick-reference` (essential commands & patterns)

What Makes GDSentry Different?
============================

✅ **Game-Focused Testing**: Visual tests, UI interactions, physics validation, performance monitoring
✅ **Zero Configuration**: Works out-of-the-box with any Godot project
✅ **Comprehensive Tooling**: Mocking, fixtures, CI/CD integration, detailed reporting
✅ **Production Ready**: Used in shipped games, battle-tested across Godot 3.x and 4.x

.. code-block:: gdscript
   :caption: Your first test in 30 seconds

   extends SceneTreeTest

   func run_test_suite() -> void:
       run_test("test_player_health", func(): return test_player_health())

   func test_player_health() -> bool:
       var player = Player.new()
       player.take_damage(20)
       return assert_equals(player.health, 80)

Getting Started
===============

Choose your path based on your experience and needs:

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: 🚀 Quick Start
      :link: getting-started
      :link-type: doc

      Installation, setup, and your first test

      **5 minutes** • Perfect for newcomers

   .. grid-item-card:: 📖 Complete Guide
      :link: user-guide
      :link-type: doc

      Comprehensive testing patterns

      **30 minutes** • Deep dive into capabilities

   .. grid-item-card:: ⚡ Quick Reference
      :link: quick-reference
      :link-type: doc

      Essential commands and patterns

      **2 minutes** • For rapid development

   .. grid-item-card:: 🔧 Troubleshooting
      :link: troubleshooting
      :link-type: doc

      Solutions to common issues

      **As needed** • When things go wrong

Core Capabilities
=================

**Visual Testing**
  Validate UI layouts, animations, and visual states. Perfect for ensuring your game looks right across different screen sizes and configurations.

**Performance Testing**
  Monitor FPS, memory usage, and execution times. Catch performance regressions before they reach players.

**UI Interaction Testing**
  Simulate user input, test button interactions, and validate accessibility features.

**Physics Testing**
  Verify collision detection, force applications, and physics state consistency.

**Integration Testing**
  Test complete game flows and multi-system interactions.

**Mocking & Fixtures**
  Isolate code under test with sophisticated mocking capabilities and dependency management.

.. toctree::
   :maxdepth: 2
   :caption: Getting Started
   :name: getting-started-toc

   overview
   getting-started
   configuration

.. toctree::
   :maxdepth: 2
   :caption: User Guide
   :name: user-guide-toc

   user-guide
   examples
   best-practices
   troubleshooting

.. toctree::
   :maxdepth: 2
   :caption: Advanced Features
   :name: advanced-toc

   advanced/mocking
   advanced/fixtures
   advanced/visual-testing
   advanced/performance-testing
   advanced/ui-testing

.. toctree::
   :maxdepth: 2
   :caption: API Reference
   :name: api-reference-toc

   api/test-classes
   api/assertions
   api/test-runner

.. toctree::
   :maxdepth: 1
   :caption: Tutorials
   :name: tutorials-toc

   tutorials/ci-integration

.. toctree::
   :maxdepth: 1
   :caption: Quick Access
   :name: quick-access-toc

   quick-reference

Community & Support
===================

**Get Help**
  :doc:`troubleshooting` • :doc:`quick-reference` • :doc:`examples`

**Contribute**
  `GitHub Repository <https://github.com/username/gdsentry>`_ • `Issue Tracker <https://github.com/username/gdsentry/issues>`_ • `Discussions <https://github.com/username/gdsentry/discussions>`_

**What's New**
  Recent improvements include advanced mocking, fixture management, visual testing, performance monitoring, and comprehensive CI/CD integration.

Indices and Tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
