"""License header validation."""

from pathlib import Path
from typing import List

from gdsentry.validation.gdscript import ValidationIssue


class LicenseChecker:
    """
    Checks license headers in source files.

    Validates that files have appropriate headers with:
    - Project identification (GDSentry)
    - Author information
    - Version information (optional)
    """

    def __init__(self):
        """Initialize license checker."""
        self.issues: List[ValidationIssue] = []

    def check_file(self, file_path: Path) -> bool:
        """
        Check license header in a file.

        Args:
            file_path: Path to file

        Returns:
            True if no errors found
        """
        try:
            content = file_path.read_text(encoding="utf-8")
            file_ext = file_path.suffix

            if file_ext in [".gd", ".py", ".sh"]:
                if not self._has_license_header(content, file_ext):
                    self.issues.append(
                        ValidationIssue(
                            file=file_path,
                            severity="warning",
                            message="Missing or invalid license header",
                        )
                    )

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

    def check_files(self, file_paths: List[Path]) -> bool:
        """Check multiple files."""
        self.issues.clear()

        all_valid = True
        for file_path in file_paths:
            if not self.check_file(file_path):
                all_valid = False

        return all_valid

    def get_errors(self) -> List[ValidationIssue]:
        """Get all errors."""
        return [issue for issue in self.issues if issue.severity == "error"]

    def get_warnings(self) -> List[ValidationIssue]:
        """Get all warnings."""
        return [issue for issue in self.issues if issue.severity == "warning"]

    def _has_license_header(self, content: str, file_ext: str) -> bool:
        """Check if content has proper license header."""
        lines = content.split("\n", 10)  # Check first 10 lines

        # For GDScript, check for GDSentry header comment
        if file_ext == ".gd":
            for line in lines[:7]:
                if line.strip().startswith("# GDSentry"):
                    return True
                if line.strip().startswith("# Author:"):
                    return True

        # For Python, check for docstring with license
        elif file_ext == ".py":
            if '"""' in "\n".join(lines[:7]):
                for line in lines[:7]:
                    if "GDSentry" in line or "Author:" in line:
                        return True

        # For shell scripts, check for comment header
        elif file_ext == ".sh":
            for line in lines[:7]:
                if line.strip().startswith("# GDSentry"):
                    return True
                if line.strip().startswith("# Author:"):
                    return True

        return False

