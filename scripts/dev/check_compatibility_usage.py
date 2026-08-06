#!/usr/bin/env python3
"""Compatibility Layer Usage Checker for Pre-commit Hooks

This script checks that files using file system APIs properly
use the compatibility layer instead of direct version-specific calls.
"""

import sys
import os
import re
from pathlib import Path
from typing import List, Dict, Any, Set

class CompatibilityChecker:
    """Checks compatibility layer usage"""

    def __init__(self):
        self.errors = []
        self.warnings = []

        # APIs that require compatibility layer
        self.file_apis = [
            'FileAccess\.',
            'DirAccess\.',
        ]

        # Deprecated APIs
        self.deprecated_apis = [
            'File\.',
            'Directory\.',
            'OS\.get_name',
            'Input\.is_action_pressed',
        ]

        # Version branching patterns
        self.version_patterns = [
            'Engine\.get_version_info',
            'if.*major.*>=.*4',
            'if.*version.*>.*3',
        ]

    def check_file(self, file_path: str) -> bool:
        """Check compatibility usage in a file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            self._check_direct_api_usage(file_path, content)
            self._check_deprecated_usage(file_path, content)
            self._check_version_branching(file_path, content)
            self._check_compatibility_imports(file_path, content)

            return len(self.errors) == 0

        except Exception as e:
            self.errors.append(f"Error reading file {file_path}: {e}")
            return False

    def _check_direct_api_usage(self, file_path: str, content: str):
        """Check for direct API usage without compatibility layer"""
        for api_pattern in self.file_apis:
            if re.search(api_pattern, content):
                # Check if file uses compatibility layer
                if 'FileSystemCompatibility' not in content:
                    self.errors.append(f"{file_path}: Direct API usage '{api_pattern}' without compatibility layer")

    def _check_deprecated_usage(self, file_path: str, content: str):
        """Check for deprecated API usage"""
        for api_pattern in self.deprecated_apis:
            if re.search(api_pattern, content):
                # Check if it's in the compatibility layer itself
                if 'file_system_compatibility.gd' not in file_path:
                    self.warnings.append(f"{file_path}: Deprecated API usage '{api_pattern}'")

    def _check_version_branching(self, file_path: str, content: str):
        """Check for version branching anti-patterns"""
        for pattern in self.version_patterns:
            if re.search(pattern, content):
                # Check if it involves file APIs
                if re.search(r'(File|Directory|FileAccess|DirAccess)', content):
                    self.errors.append(f"{file_path}: Version branching with file APIs (use compatibility layer instead)")

    def _check_compatibility_imports(self, file_path: str, content: str):
        """Check that compatibility layer is properly imported"""
        if 'FileSystemCompatibility' in content:
            # Look for proper import
            if not re.search(r'load.*file_system_compatibility', content):
                self.warnings.append(f"{file_path}: FileSystemCompatibility used but not properly loaded")

    def get_results(self) -> Dict[str, Any]:
        """Get check results"""
        return {
            'errors': self.errors,
            'warnings': self.warnings,
            'total_issues': len(self.errors) + len(self.warnings)
        }

def main():
    """Main check function for pre-commit hook"""
    checker = CompatibilityChecker()
    files_checked = 0
    total_errors = 0
    total_warnings = 0

    # Check each file passed as argument
    for file_path in sys.argv[1:]:
        if os.path.isfile(file_path) and file_path.endswith('.gd'):
            files_checked += 1
            if checker.check_file(file_path):
                print(f"✅ {file_path}")
            else:
                print(f"❌ {file_path}")

    # Get results
    results = checker.get_results()

    # Output results
    if results['errors']:
        print("\n🚨 Compatibility Errors:")
        for error in results['errors']:
            print(f"  {error}")
        total_errors = len(results['errors'])

    if results['warnings']:
        print("\n⚠️  Compatibility Warnings:")
        for warning in results['warnings']:
            print(f"  {warning}")
        total_warnings = len(results['warnings'])

    # Summary
    print(f"\n📊 Compatibility Check: {files_checked} files, {total_errors} errors, {total_warnings} warnings")

    # Exit with error code if there are errors
    if total_errors > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
