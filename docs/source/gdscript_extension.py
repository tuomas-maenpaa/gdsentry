"""
Sphinx extension for GDScript documentation extraction.
"""

import os
import re
from typing import Dict, List, Any
from sphinx.application import Sphinx
from sphinx.util.docutils import SphinxDirective
from docutils import nodes
from docutils.parsers.rst import Directive


class GDScriptAutoDirective(SphinxDirective):
    """
    Directive for automatically extracting documentation from GDScript files.
    Usage: .. gdscript-auto:: path/to/file.gd
    """

    has_content = False
    required_arguments = 1
    optional_arguments = 0

    def run(self) -> List[nodes.Node]:
        filepath = self.arguments[0]

        # Make path relative to docs/source if not absolute
        if not os.path.isabs(filepath):
            # Get the directory containing the current RST file
            source_dir = os.path.dirname(self.env.doc2path(self.env.docname, base=None))
            filepath = os.path.join(source_dir, filepath)
            # Normalize the path
            filepath = os.path.normpath(filepath)

        print(f"Processing GDScript file: {filepath}")

        if not os.path.exists(filepath):
            error_node = nodes.error()
            error_node += nodes.Text(f"GDScript file not found: {filepath}")
            return [error_node]

        try:
            content = self.extract_gdscript_docs(filepath)
            container = nodes.container()

            if content:
                for item in content:
                    para = nodes.paragraph()
                    para += nodes.Text(item)
                    container += para
            else:
                para = nodes.paragraph()
                para += nodes.Text("No documentation found in this file.")
                container += para

            return [container]
        except Exception as e:
            print(f"Error processing GDScript file: {e}")
            error_node = nodes.error()
            error_node += nodes.Text(f"Error processing GDScript file: {e}")
            return [error_node]

    def extract_gdscript_docs(self, filepath: str) -> List[str]:
        """Extract documentation from GDScript file."""
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        docs = []

        # Extract class docstrings
        class_pattern = r'class_name\s+(\w+).*?\n(.*?)(?=\nclass|\nfunc|\n\Z)'
        class_matches = re.findall(class_pattern, content, re.DOTALL)

        for class_name, class_content in class_matches:
            # Extract class docstring
            docstring_match = re.search(r'"""\s*(.*?)\s*"""', class_content, re.DOTALL)
            if docstring_match:
                docs.append(f"**Class {class_name}**: {docstring_match.group(1).strip()}")

        # Extract function docstrings
        func_pattern = r'func\s+(\w+)\s*\([^)]*\)\s*->\s*[^:]+:\s*\n\s*"""(.*?)"""'
        func_matches = re.findall(func_pattern, content, re.DOTALL)

        for func_name, docstring in func_matches:
            docs.append(f"**Function {func_name}**: {docstring.strip()}")

        return docs if docs else ["No documentation found in this file."]


def setup(app: Sphinx) -> Dict[str, Any]:
    """Setup the GDScript extension."""
    app.add_directive('gdscript-auto', GDScriptAutoDirective)

    return {
        'version': '1.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
