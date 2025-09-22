# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'GDSentry'
copyright = '2025, GDSentry Framework'
author = 'GDSentry Framework'
release = '1.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

import os
import sys
sys.path.insert(0, os.path.abspath('.'))

extensions = [
    'sphinx.ext.autodoc',      # API documentation from docstrings
    'sphinx.ext.viewcode',     # Add source code links
    'sphinx.ext.napoleon',     # Google/NumPy style docstrings
    'sphinx_copybutton',       # Copy code button
    'sphinx_design',           # Modern UI components
    'myst_parser',             # Markdown support
    'gdscript_extension',      # Custom GDScript documentation
]

# MyST Parser settings for Markdown support
myst_enable_extensions = [
    "colon_fence",
    "deflist",
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# Set the master document
master_doc = 'index'

# Configure parser separation to prevent MyST/RST conflicts
source_suffix = {
    '.rst': None,  # Use RST parser for .rst files
    '.md': 'myst_parser',  # Use MyST parser for .md files only
}

language = 'en'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

# Theme options for RTD theme
html_theme_options = {
    'canonical_url': '',
    'analytics_id': '',
    'prev_next_buttons_location': 'bottom',
    'style_external_links': False,
    'vcs_pageview_mode': '',
    'style_nav_header_background': '#2980B9',
    # Toc options
    'collapse_navigation': False,
    'sticky_navigation': True,
    'navigation_depth': 4,
    'includehidden': True,
    'titles_only': False
}

# Custom CSS (if needed)
html_css_files = [
    'custom.css',
]
