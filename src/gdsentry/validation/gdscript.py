"""GDScript syntax and style validation."""

import re
from pathlib import Path
from typing import List, Optional

from pydantic import BaseModel


class ValidationIssue(BaseModel):
    """Represents a validation issue."""

    file: Path
    line: Optional[int] = None
    severity: str  # "error" or "warning"
    message: str

    def __str__(self) -> str:
        """String representation."""
        if self.line:
            return f"{self.file}:{self.line}: {self.message}"
        return f"{self.file}: {self.message}"


class GDScriptValidator:
    """
    Validates GDScript syntax and style.

    Checks for:
    - Syntax errors (unmatched quotes, parentheses)
    - Compatibility issues (deprecated APIs)
    - Style issues (trailing whitespace, tabs, line length)
    """

    def __init__(self, max_line_length: int = 120):
        """
        Initialize validator.

        Args:
            max_line_length: Maximum line length
        """
        self.max_line_length = max_line_length
        self.issues: List[ValidationIssue] = []

    def validate_file(self, file_path: Path) -> bool:
        """
        Validate a single GDScript file.

        Args:
            file_path: Path to file

        Returns:
            True if no errors found
        """
        try:
            content = file_path.read_text(encoding="utf-8")

            self._check_syntax(file_path, content)
            self._check_compatibility(file_path, content)
            self._check_style(file_path, content)

            # Return True if no errors (warnings are OK)
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
        """
        Validate multiple GDScript files.

        Args:
            file_paths: List of file paths

        Returns:
            True if all files have no errors
        """
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

    def _check_syntax(self, file_path: Path, content: str) -> None:
        """Check GDScript syntax."""
        lines = content.split("\n")

        for i, line in enumerate(lines, 1):
            # Check for common syntax errors
            if self._has_unmatched_quotes(line):
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        line=i,
                        severity="error",
                        message=f"Unmatched quotes: {line.strip()}",
                    )
                )

            if self._has_unmatched_parentheses(line):
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        line=i,
                        severity="error",
                        message=f"Unmatched parentheses: {line.strip()}",
                    )
                )

        # Check for extends without class_name
        extends_lines = [
            i for i, line in enumerate(lines, 1) if line.strip().startswith("extends")
        ]
        class_name_lines = [
            i
            for i, line in enumerate(lines, 1)
            if line.strip().startswith("class_name")
        ]

        if extends_lines and not class_name_lines:
            self.issues.append(
                ValidationIssue(
                    file=file_path,
                    severity="warning",
                    message="Found 'extends' without 'class_name' (consider adding class_name)",
                )
            )

    def _check_compatibility(self, file_path: Path, content: str) -> None:
        """Check for compatibility issues."""
        # Check for direct FileAccess usage
        if re.search(r"FileAccess\.", content) and "FileSystemCompatibility" not in content:
            self.issues.append(
                ValidationIssue(
                    file=file_path,
                    severity="warning",
                    message="Direct FileAccess usage found (consider using FileSystemCompatibility)",
                )
            )

        # Check for direct DirAccess usage
        if re.search(r"DirAccess\.", content) and "FileSystemCompatibility" not in content:
            self.issues.append(
                ValidationIssue(
                    file=file_path,
                    severity="warning",
                    message="Direct DirAccess usage found (consider using FileSystemCompatibility)",
                )
            )

        # Check for deprecated Godot 3.x APIs
        deprecated_apis = ["File.", "Directory.", "OS.get_name"]
        for api in deprecated_apis:
            if api in content:
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        severity="warning",
                        message=f"Potential deprecated API usage: {api}",
                    )
                )

    def _check_style(self, file_path: Path, content: str) -> None:
        """Check coding style."""
        lines = content.split("\n")

        for i, line in enumerate(lines, 1):
            # Check for trailing whitespace
            if line.rstrip() != line:
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        line=i,
                        severity="warning",
                        message="Trailing whitespace found",
                    )
                )

            # Check for tabs
            if "\t" in line:
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        line=i,
                        severity="warning",
                        message="Tab character found (use spaces instead)",
                    )
                )

            # Check line length
            if len(line) > self.max_line_length:
                self.issues.append(
                    ValidationIssue(
                        file=file_path,
                        line=i,
                        severity="warning",
                        message=f"Line too long ({len(line)} > {self.max_line_length} characters)",
                    )
                )

    def _has_unmatched_quotes(self, line: str) -> bool:
        """Check for unmatched quotes in a line."""
        # Don't count escaped quotes
        single_quotes = line.count("'") - line.count("\\'")
        double_quotes = line.count('"') - line.count('\\"')

        return (single_quotes % 2 != 0) or (double_quotes % 2 != 0)

    def _has_unmatched_parentheses(self, line: str) -> bool:
        """Check for unmatched parentheses in a line."""
        open_parens = line.count("(") + line.count("[") + line.count("{")
        close_parens = line.count(")") + line.count("]") + line.count("}")

        return open_parens != close_parens

