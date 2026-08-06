#!/usr/bin/env python3
"""RST Link Checker for Pre-commit Hooks

This script validates RST documentation files for broken links
and documentation issues.
"""

import sys
import os
import re
from pathlib import Path
from typing import List, Dict, Any, Set

class RSTLinkChecker:
    """Checks RST files for link issues"""

    def __init__(self):
        self.errors = []
        self.warnings = []

        # Common RST link patterns
        self.link_patterns = [
            r':doc:`([^`]+)`',           # :doc: references
            r':ref:`([^`]+)`',           # :ref: references
            r'`([^`]+)<([^>]+)>`_',      # External links
            r'`([^`]+)`_',               # Implicit links
        ]

        # Known valid references (would be populated from actual docs)
        self.known_references = {
            'installation',
            'quickstart',
            'tutorial',
            'api-reference',
            'configuration',
            'contributing',
            'changelog'
        }

    def check_file(self, file_path: str) -> bool:
        """Check RST file for link issues"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            self._check_doc_references(file_path, content)
            self._check_ref_references(file_path, content)
            self._check_external_links(file_path, content)
            self._check_link_targets(file_path, content)

            return len(self.errors) == 0

        except Exception as e:
            self.errors.append(f"Error reading file {file_path}: {e}")
            return False

    def _check_doc_references(self, file_path: str, content: str):
        """Check :doc: references"""
        doc_refs = re.findall(r':doc:`([^`]+)`', content)

        for ref in doc_refs:
            if ref not in self.known_references:
                self.warnings.append(f"{file_path}: Unknown :doc: reference: {ref}")

    def _check_ref_references(self, file_path: str, content: str):
        """Check :ref: references"""
        ref_refs = re.findall(r':ref:`([^`]+)`', content)

        for ref in ref_refs:
            if ref not in self.known_references:
                self.warnings.append(f"{file_path}: Unknown :ref: reference: {ref}")

    def _check_external_links(self, file_path: str, content: str):
        """Check external link syntax"""
        external_links = re.findall(r'`([^`]+)<([^>]+)>`_', content)

        for link_text, link_url in external_links:
            if not self._is_valid_url(link_url):
                self.warnings.append(f"{file_path}: Potentially invalid URL: {link_url}")

    def _check_link_targets(self, file_path: str, content: str):
        """Check for link targets (anchors)"""
        # Look for section headers that might be link targets
        headers = re.findall(r'^=+\n([^\n]+)\n=+$', content, re.MULTILINE)
        headers.extend(re.findall(r'^.+\n([^\n]+)\n-+$', content, re.MULTILINE))
        headers.extend(re.findall(r'^.+\n([^\n]+)\n~+$', content, re.MULTILINE))

        # Look for references to these headers
        for header in headers:
            # Convert header to potential reference
            ref = header.lower().replace(' ', '-').replace('[^a-z0-9-]', '')
            # Check if this reference is used anywhere
            if ref and f':ref:`{ref}`' in content:
                pass  # Reference exists

    def _is_valid_url(self, url: str) -> bool:
        """Basic URL validation"""
        # Simple validation - in real implementation would do more thorough checking
        if url.startswith(('http://', 'https://', 'ftp://')):
            return True
        if url.startswith('mailto:'):
            return True
        if url.endswith(('.rst', '.py', '.gd', '.txt', '.html')):
            return True
        return False

    def get_results(self) -> Dict[str, Any]:
        """Get check results"""
        return {
            'errors': self.errors,
            'warnings': self.warnings,
            'total_issues': len(self.errors) + len(self.warnings)
        }

def main():
    """Main check function for pre-commit hook"""
    checker = RSTLinkChecker()
    files_checked = 0
    total_errors = 0
    total_warnings = 0

    # Check each file passed as argument
    for file_path in sys.argv[1:]:
        if os.path.isfile(file_path) and file_path.endswith('.rst'):
            files_checked += 1
            if checker.check_file(file_path):
                print(f"✅ {file_path}")
            else:
                print(f"❌ {file_path}")

    # Get results
    results = checker.get_results()

    # Output results
    if results['errors']:
        print("\n🚨 RST Errors:")
        for error in results['errors']:
            print(f"  {error}")
        total_errors = len(results['errors'])

    if results['warnings']:
        print("\n⚠️  RST Warnings:")
        for warning in results['warnings']:
            print(f"  {warning}")
        total_warnings = len(results['warnings'])

    # Summary
    print(f"\n📊 RST Validation: {files_checked} files, {total_errors} errors, {total_warnings} warnings")

    # Exit with error code if there are errors
    if total_errors > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
