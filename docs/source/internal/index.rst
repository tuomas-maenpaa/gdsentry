Internal Documentation
======================

.. admonition:: For Contributors
   :class: warning

   This section contains internal implementation details, architecture documentation, and development guidelines for GDSentry contributors. End users should refer to the main :doc:`../user-guide` and :doc:`../api-reference` sections.

GDSentry's internal architecture is designed around eight vertical slices, each representing a complete, self-contained feature that can be developed and tested independently. This approach ensures maintainable, well-documented code with clear integration points.

Architecture Overview
=====================

The system follows a layered architecture with clear separation of concerns:

.. toctree::
   :maxdepth: 2
   :caption: Core Architecture

   architecture
   output-design

Implementation Details
======================

Each slice represents a complete feature implementation, from configuration to user interface. The slices are designed to be developed in parallel while maintaining clear dependencies.

.. toctree::
   :maxdepth: 2
   :caption: Implementation Slices

   implementation/slice-01-config
   implementation/slice-02-platform
   implementation/slice-03-cli-framework
   implementation/slice-04-containers
   implementation/slice-05-test-execution
   implementation/slice-06-validation
   implementation/slice-07-documentation
   implementation/slice-08-dev-tools

Development Resources
=====================

.. toctree::
   :maxdepth: 1
   :caption: Development

   completion-summary

Key Design Principles
=====================

**Vertical Slice Architecture**
  Each slice is self-contained with its own tests, documentation, and integration points.

**Type Safety First**
  Full Pydantic models with strict mypy validation throughout the codebase.

**Local-Only Operations**
  No external dependencies, registries, or cloud services - everything runs locally.

**Cross-Platform Compatibility**
  Works identically on macOS, Linux, and Windows without shell compatibility issues.

**Self-Validating Framework**
  GDSentry tests itself using its own testing capabilities.

Getting Started for Contributors
=================================

1. **Read the Architecture**: Start with :doc:`architecture` to understand the system design
2. **Choose a Slice**: Pick an unstarted slice or contribute to an existing one
3. **Follow the Pattern**: Each slice follows the same structure and conventions
4. **Test Thoroughly**: Run the full test suite and ensure all integration points work
5. **Document Changes**: Update this documentation as the system evolves

.. seealso::
   :doc:`../contributing`
      General contribution guidelines and code standards.

   :doc:`../development-standards`
      Code quality requirements and development practices.

   :doc:`completion-summary`
      Final implementation status and remaining tasks.