#!/usr/bin/env python3
"""Documentation Validation Script

Validates documentation for:
- File references to non-existent files
- Broken RST links
- Missing docstrings in GDScript files
- Documentation drift (outdated file paths)
- Circular dependencies
"""

import sys
import re
from pathlib import Path
from typing import List, Dict, Set, Tuple


class DocumentationValidator:
    """Validates documentation quality and accuracy"""

    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.stats: Dict[str, int] = {
            "files_checked": 0,
            "file_refs_checked": 0,
            "gdscript_files_checked": 0,
            "missing_docstrings": 0,
        }

    def validate_all(self) -> bool:
        """Run all validation checks"""
        print("🔍 Validating GDSentry Documentation...\n")

        self._validate_file_references()
        self._validate_gdscript_docstrings()
        self._validate_rst_structure()
        self._check_circular_dependencies()

        return self._print_results()

    def _validate_file_references(self):
        """Check that all file references in docs point to existing files"""
        print("📄 Checking file references...")

        docs_dir = self.project_root / "docs" / "source"
        if not docs_dir.exists():
            self.errors.append(f"Documentation directory not found: {docs_dir}")
            return

        # Patterns to match file references in RST
        patterns = [
            r"``([^`]+\.(?:py|gd|sh|toml|yaml|yml|json|md|rst))``",  # Code blocks
            r":file:`([^`]+)`",  # File role
            r"\.\. literalinclude:: ([^\n]+)",  # Literal includes
        ]

        for rst_file in docs_dir.rglob("*.rst"):
            self.stats["files_checked"] += 1
            content = rst_file.read_text(encoding="utf-8")

            for pattern in patterns:
                matches = re.findall(pattern, content)
                for match in matches:
                    self.stats["file_refs_checked"] += 1
                    # Clean up the path
                    file_path = match.strip()

                    # Skip URLs and special references
                    if file_path.startswith(("http://", "https://", "mailto:")):
                        continue
                    if file_path.startswith("$"):  # Environment variables
                        continue

                    # Try to resolve the path
                    if not self._check_file_exists(file_path):
                        self.errors.append(
                            f"{rst_file.relative_to(self.project_root)}: "
                            f"Referenced file not found: {file_path}"
                        )

    def _check_file_exists(self, file_path: str) -> bool:
        """Check if a referenced file exists"""
        # Try absolute path from project root
        abs_path = self.project_root / file_path
        if abs_path.exists():
            return True

        # Try relative to src/
        src_path = self.project_root / "src" / file_path
        if src_path.exists():
            return True

        # Try with leading slash removed
        if file_path.startswith("/"):
            no_slash = self.project_root / file_path[1:]
            if no_slash.exists():
                return True

        return False

    def _validate_gdscript_docstrings(self):
        """Check GDScript files for docstrings"""
        print("📝 Checking GDScript docstrings...")

        src_dir = self.project_root / "src"
        if not src_dir.exists():
            self.warnings.append(f"Source directory not found: {src_dir}")
            return

        for gd_file in src_dir.rglob("*.gd"):
            # Skip test files and examples
            if "test" in str(gd_file).lower() or "example" in str(gd_file).lower():
                continue

            self.stats["gdscript_files_checked"] += 1
            content = gd_file.read_text(encoding="utf-8")

            # Check for class docstring (triple-quoted string at top)
            has_docstring = self._has_gdscript_docstring(content)

            if not has_docstring:
                self.stats["missing_docstrings"] += 1
                self.warnings.append(
                    f"{gd_file.relative_to(self.project_root)}: Missing class docstring"
                )

    def _has_gdscript_docstring(self, content: str) -> bool:
        """Check if GDScript file has a docstring"""
        lines = content.split("\n")

        # Look for docstring in first 20 lines
        in_docstring = False
        for i, line in enumerate(lines[:20]):
            stripped = line.strip()

            # Skip comments and empty lines
            if stripped.startswith("#") or not stripped:
                continue

            # Check for triple-quoted docstring
            if '"""' in stripped:
                return True

            # Check for class declaration with comment
            if stripped.startswith("class ") and i > 0:
                # Check if previous lines have comments
                for prev_line in lines[max(0, i - 5) : i]:
                    if prev_line.strip().startswith("#"):
                        return True

        return False

    def _validate_rst_structure(self):
        """Validate RST file structure"""
        print("📚 Checking RST structure...")

        docs_dir = self.project_root / "docs" / "source"
        if not docs_dir.exists():
            return

        required_sections = {
            "architecture": ["layer-independence.rst", "plugin-system.rst"],
            "api/gdscript": ["assertions.rst"],
        }

        for section, files in required_sections.items():
            section_dir = docs_dir / section
            if not section_dir.exists():
                self.errors.append(f"Required documentation section missing: {section}")
                continue

            for required_file in files:
                file_path = section_dir / required_file
                if not file_path.exists():
                    self.errors.append(
                        f"Required documentation file missing: {section}/{required_file}"
                    )

    def _check_circular_dependencies(self):
        """Check for circular dependencies in Python code"""
        print("🔄 Checking for circular dependencies...")

        # Simple check: ensure common module has no imports from core or platform
        common_init = self.project_root / "src" / "gdsentry" / "common" / "__init__.py"
        if common_init.exists():
            content = common_init.read_text(encoding="utf-8")
            if "from gdsentry.core" in content or "from gdsentry.platform" in content:
                self.errors.append(
                    "Circular dependency detected: common module imports from core or platform"
                )

        # Check that platform doesn't import from core (except through common)
        platform_dir = self.project_root / "src" / "gdsentry" / "platform"
        if platform_dir.exists():
            for py_file in platform_dir.glob("*.py"):
                content = py_file.read_text(encoding="utf-8")
                # Check for direct core imports (excluding common)
                if re.search(r"from gdsentry\.core(?!\.)", content):
                    # Exclude imports from core.exceptions (backward compat)
                    if "from gdsentry.core.exceptions" not in content:
                        self.warnings.append(
                            f"{py_file.relative_to(self.project_root)}: "
                            f"Imports from core (should use common)"
                        )

    def _print_results(self) -> bool:
        """Print validation results"""
        print("\n" + "=" * 60)
        print("📊 Documentation Validation Results")
        print("=" * 60)

        # Print statistics
        print(f"\n✅ Files checked: {self.stats['files_checked']}")
        print(f"✅ File references checked: {self.stats['file_refs_checked']}")
        print(f"✅ GDScript files checked: {self.stats['gdscript_files_checked']}")

        # Print errors
        if self.errors:
            print(f"\n❌ Errors ({len(self.errors)}):")
            for error in self.errors:
                print(f"  • {error}")

        # Print warnings
        if self.warnings:
            print(f"\n⚠️  Warnings ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  • {warning}")

        # Summary
        print("\n" + "=" * 60)
        if self.errors:
            print("❌ VALIDATION FAILED")
            print(f"   {len(self.errors)} errors, {len(self.warnings)} warnings")
            return False
        elif self.warnings:
            print("⚠️  VALIDATION PASSED WITH WARNINGS")
            print(f"   {len(self.warnings)} warnings")
            return True
        else:
            print("✅ VALIDATION PASSED")
            print("   No errors or warnings")
            return True


def main():
    """Main entry point"""
    # Find project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    # Create validator
    validator = DocumentationValidator(project_root)

    # Run validation
    success = validator.validate_all()

    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
