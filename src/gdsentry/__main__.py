"""Entry point for python -m gdsentry.

This module enables 'python -m gdsentry' to work during development.
For normal usage in conda environment, use 'gdsentry' command directly.
"""

from gdsentry.cli.app import main

if __name__ == "__main__":
    main()

