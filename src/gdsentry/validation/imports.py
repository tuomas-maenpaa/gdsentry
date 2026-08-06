"""GDScript import validation."""

import re
from pathlib import Path
from typing import List

from gdsentry.validation.gdscript import ValidationIssue


class ImportValidator:
    """
    Validates GDScript imports.

    Checks for:
    - Proper extends statements
    - Valid load() paths
    - Class reference consistency
    """

    def __init__(self, gdsentry_root: Path):
        """
        Initialize validator.

        Args:
            gdsentry_root: GDSentry framework root directory
        """
        self.gdsentry_root = gdsentry_root
        self.issues: List[ValidationIssue] = []

        # Expected paths for common GDSentry classes
        self.expected_paths = {
            "GDTest": "src/base_classes/gd_test.gd",
            "SceneTreeTest": "src/base_classes/scene_tree_test.gd",
            "NodeTest": "src/base_classes/node_test.gd",
            "Node2DTest": "src/base_classes/node2d_test.gd",
            "TestManager": "src/core/test_manager.gd",
            "TestDiscovery": "src/core/test_discovery.gd",
            "TestConfig": "src/core/test_config.gd",
            "TestRunner": "src/core/test_runner.gd",
        }

    def validate_file(self, file_path: Path) -> bool:
        """
        Validate imports in a GDScript file.

        Args:
            file_path: Path to file

        Returns:
            True if no errors found
        """
        try:
            content = file_path.read_text(encoding="utf-8")

            self._check_extends_statements(file_path, content)
            self._check_load_statements(file_path, content)
            self._check_class_references(file_path, content)

            return not any(issue.severity == "error" for issue in self.issues)

        except Exception as e:
            self.issues.append(
                ValidationIssue(
                    file=file_path,
                    severity="error",
                    message=f"Failed to read file: {e}",
                )
            )
            return False

    def validate_files(self, file_paths: List[Path]) -> bool:
        """Validate multiple files."""
        self.issues.clear()

        all_valid = True
        for file_path in file_paths:
            if not self.validate_file(file_path):
                all_valid = False

        return all_valid

    def get_errors(self) -> List[ValidationIssue]:
        """Get all errors."""
        return [issue for issue in self.issues if issue.severity == "error"]

    def get_warnings(self) -> List[ValidationIssue]:
        """Get all warnings."""
        return [issue for issue in self.issues if issue.severity == "warning"]

    def _check_extends_statements(self, file_path: Path, content: str) -> None:
        """Check extends statements."""
        lines = content.split("\n")

        for i, line in enumerate(lines, 1):
            line = line.strip()

            if line.startswith("extends"):
                extends_match = re.match(r"extends\s+([A-Za-z0-9_]+)", line)
                if extends_match:
                    class_name = extends_match.group(1)

                    # If it's a known class, check if it's loaded
                    if class_name in self.expected_paths:
                        expected_path = self.expected_paths[class_name]
                        load_statement = f'res://{expected_path}"'
                        if load_statement not in content:
                            self.issues.append(
                                ValidationIssue(
                                    file=file_path,
                                    line=i,
                                    severity="warning",
                                    message=f"Extending {class_name} without corresponding load statement",
                                )
                            )

    def _check_load_statements(self, file_path: Path, content: str) -> None:
        """Check load() statements."""
        load_pattern = r'load\(["\']([^"\']+)["\']\)'
        matches = re.finditer(load_pattern, content)

        for match in matches:
            resource_path = match.group(1)
            self._validate_load_path(file_path, resource_path)

    def _check_class_references(self, file_path: Path, content: str) -> None:
        """Check class references."""
        # Look for class instantiations
        class_pattern = r"(GDTest|SceneTreeTest|NodeTest|Node2DTest)\.new\(\)"
        matches = re.findall(class_pattern, content)

        for class_name in matches:
            if class_name in self.expected_paths:
                expected_path = self.expected_paths[class_name]
                load_statement = f"res://{expected_path}"

                if load_statement not in content:
                    self.issues.append(
                        ValidationIssue(
                            file=file_path,
                            severity="warning",
                            message=f"Using {class_name} without proper load statement",
                        )
                    )

    def _validate_load_path(self, file_path: Path, resource_path: str) -> None:
        """Validate a load() resource path."""
        if resource_path.startswith("res://"):
            local_path = self.gdsentry_root / resource_path.replace("res://", "")

            # Check if path exists
            if not local_path.exists():
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        severity="warning",
                        message=f"Load path may not exist: {resource_path}",
                    )
                )

        # Check for path issues
        if ".." in resource_path:
            self.issues.append(
                ValidationIssue(
                    file=file_path,
                    severity="warning",
                    message=f"Relative path in load statement: {resource_path}",
                )
            )

