.. _cross_architecture_testing:

Cross-Architecture Testing
=========================

GDSentry provides robust support for cross-architecture testing, allowing you to verify your Godot projects across different architectures (x86_64 and ARM64) regardless of your host system.

Version Support Policy
---------------------

GDSentry follows a structured version support policy for Godot versions across different architectures:

* **x86_64 Architecture**: Supports both Godot 3.5-stable and 4.2.2-stable
* **ARM64 Architecture**: Currently supports only Godot 4.2.2-stable

This policy ensures that:

1. We maintain compatibility with the latest stable version across all architectures
2. We provide extended support for the previous major version on x86_64
3. We focus ARM64 resources on the most recent stable version

Container Image Naming
---------------------

Container images follow a consistent naming convention:

* **Godot 3.5 Series**: ``gdsentry-godot-3.5:<architecture>``
* **Godot 4.2 Series**: ``gdsentry-godot-4.2:<architecture>``

For example:
  * ``gdsentry-godot-3.5:x86_64``
  * ``gdsentry-godot-4.2:arm64``

Supported Version Aliases
------------------------

For convenience, GDSentry supports various version aliases that map to the actual Godot versions:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Alias
     - Maps to
   * - ``3.5``
     - ``3.5-stable``
   * - ``3.5.0``, ``3.5.1``, ``3.5.2``
     - ``3.5-stable``
   * - ``4.2``
     - ``4.2.2-stable``
   * - ``4.2.0``, ``4.2.1``, ``4.2.2``
     - ``4.2.2-stable``

Validating Container Images
-------------------------

To ensure that all required container images are available for testing, use the ``validate`` command:

.. code-block:: bash

    gdsentry validate all

This command will:

1. Check all supported Godot versions for each architecture
2. Verify that the corresponding container images exist
3. Report any missing images with instructions on how to build them

Adding New Godot Versions
-----------------------

When a new Godot version is released and needs to be supported:

1. Update the centralized configuration in ``scripts/config/gdsentry-test-config.sh``
2. Add the new version to the appropriate arrays and functions
3. Build the new container images
4. Validate the configuration with ``gdsentry validate all``

.. code-block:: bash

    # Example: Adding Godot 5.0 support
    # 1. Update the configuration
    # 2. Build the container images
    gdsentry build all
    # 3. Validate the configuration
    gdsentry validate all

Cross-Architecture Commands
-------------------------

GDSentry provides several commands for cross-architecture testing:

.. code-block:: bash

    # Test on x86_64 architecture
    gdsentry test run --architecture x86_64

    # Test on ARM64 architecture
    gdsentry test run --architecture arm64

    # Test on all architectures
    gdsentry test run --all-architectures

    # Validate container images
    gdsentry validate all

For more information on cross-architecture testing, see the :ref:`getting_started` guide.

.. seealso::
   :doc:`cross-architecture-builds`
      Detailed guide on building containers for different architectures and troubleshooting build issues.

   :doc:`internal/implementation/slice-02-platform`
      **For Contributors:** Technical implementation details of platform detection and architecture compatibility.
