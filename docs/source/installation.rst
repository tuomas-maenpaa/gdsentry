Installation Guide
==================

This guide covers installing and setting up GDSentry CLI for testing your Godot projects.

System Requirements
===================

**Required:**

- **Python**: 3.9 or higher
- **Godot**: 4.x (recommended) or 3.5+
- **Operating System**: Linux, macOS, or Windows

**Recommended:**

- **Python**: 3.12+ (latest stable)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 500MB free space

**Optional (for cross-architecture testing):**

- **Podman** or **Docker** for containerized testing
- **QEMU** for cross-architecture emulation

Installation Methods
===================

Choose the installation method that best fits your workflow:

Development Installation (Current)
----------------------------------

Since GDSentry is currently in development and not yet published to package repositories, install from source:

.. code-block:: bash

    # Clone the repository
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry

    # Set up conda environment (recommended)
    conda env create -f environment.yml
    conda activate gdsentry

    # Install in development mode
    pip install -e .

    # Verify installation
    gdsentry --help

Using conda (When Published)
----------------------------

Once published, you can install using conda:

.. code-block:: bash

    conda install gdsentry

Or from conda-forge:

.. code-block:: bash

    conda install -c conda-forge gdsentry

Using pip (When Published)
--------------------------

Install from PyPI when published:

.. code-block:: bash

    pip install gdsentry

For user-specific installation:

.. code-block:: bash

    pip install --user gdsentry

Using pipx (When Published)
---------------------------

For isolated installation:

.. code-block:: bash

    pipx install gdsentry

Platform-Specific Setup
========================

Linux
-----

**Ubuntu/Debian:**

.. code-block:: bash

    # Install system dependencies
    sudo apt update
    sudo apt install python3 python3-pip git

    # Clone and install GDSentry (development)
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

**Fedora/CentOS:**

.. code-block:: bash

    # Install system dependencies
    sudo dnf install python3 python3-pip git

    # Clone and install GDSentry (development)
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

**Arch Linux:**

.. code-block:: bash

    # Install system dependencies
    sudo pacman -S python python-pip git

    # Clone and install GDSentry (development)
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

macOS
-----

**Using Homebrew:**

.. code-block:: bash

    # Install Python and git (if not already installed)
    brew install python git

    # Clone and install GDSentry (development)
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

**Using conda (recommended for Apple Silicon):**

.. code-block:: bash

    # Install Miniconda (if not already installed)
    brew install --cask miniconda

    # Set up conda environment
    conda init zsh  # or bash
    conda create -n gdsentry python=3.12
    conda activate gdsentry

    # Clone and install GDSentry (development)
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

Windows
-------

**Using pip:**

.. code-block:: powershell

    # Install Python and git from python.org/git-scm.com (if not already installed)

    # Open Command Prompt or PowerShell
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

**Using conda:**

.. code-block:: powershell

    # Install Miniconda from conda.io (if not already installed)

    # Open Anaconda Prompt
    conda create -n gdsentry python=3.12
    conda activate gdsentry

    # Clone and install GDSentry (development)
    git clone https://github.com/your-org/gdsentry.git
    cd gdsentry
    pip install -e .

**Note:** On Windows, you may need to add Python to your PATH during installation.

Verification
============

After installation, verify GDSentry is working:

.. code-block:: bash

    # Check version (if available)
    gdsentry --help

You should see the GDSentry CLI help output with available commands.

Test with a sample project:

.. code-block:: bash

    # Create a test directory
    mkdir gdsentry-test && cd gdsentry-test

    # Create a simple test file
    cat > test_example.gd << 'EOF'
    extends SceneTreeTest

    func run_test_suite() -> void:
        run_test("test_example", func(): return test_example())

    func test_example() -> bool:
        return assert_equals(2 + 2, 4)
    EOF

    # Run the test
    gdsentry test run

You should see output indicating the test passed.

Container Setup (Optional)
===========================

For cross-architecture testing, set up Podman or Docker:

**Linux:**

.. code-block:: bash

    # Install Podman
    sudo apt install podman  # Ubuntu/Debian
    # OR
    sudo dnf install podman  # Fedora/CentOS

**macOS:**

.. code-block:: bash

    # Install Podman Desktop
    brew install podman-desktop

    # Initialize Podman machine
    podman machine init
    podman machine start

**Windows:**

.. code-block:: powershell

    # Install Podman Desktop from podman.io
    # Follow the installation wizard

Troubleshooting Installation
===========================

**"gdsentry command not found"**

- **pip install --user**: Commands may not be in PATH. Add ``~/.local/bin`` to your PATH.
- **conda**: Activate the conda environment with ``conda activate gdsentry``.
- **pipx**: Commands are installed in ``~/.local/bin`` - ensure it's in PATH.

**"Permission denied" errors**

- Use ``pip install --user gdsentry`` instead of ``sudo pip install``.
- On Windows, run Command Prompt as Administrator.

**Import errors or missing dependencies**

- Ensure you're using Python 3.9+.
- Try reinstalling: ``pip uninstall gdsentry && pip install gdsentry``

**Godot-related errors**

- Ensure Godot is installed and accessible via command line.
- GDSentry will automatically detect Godot installations.

**Container errors**

- Ensure Podman/Docker is installed and running.
- On macOS/Windows, ensure the Podman machine is started.

Upgrading
=========

To upgrade to the latest version:

.. code-block:: bash

    # Using pip
    pip install --upgrade gdsentry

    # Using conda
    conda update gdsentry

    # Using pipx
    pipx upgrade gdsentry

Uninstalling
============

To remove GDSentry:

.. code-block:: bash

    # Using pip
    pip uninstall gdsentry

    # Using conda
    conda remove gdsentry

    # Using pipx
    pipx uninstall gdsentry

Next Steps
==========

Once installed, you're ready to:

1. **Write tests** in your Godot project - see :doc:`user-guide`
2. **Run tests** with ``gdsentry test run`` - see :doc:`quick-reference`
3. **Set up CI/CD** - see :doc:`tutorials/ci-integration`
4. **Explore advanced features** - see :doc:`advanced/index`

For help and support, see :doc:`troubleshooting`.
