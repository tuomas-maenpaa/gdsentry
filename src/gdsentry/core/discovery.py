"""Test discovery - find GDScript test files."""

from pathlib import Path
from typing import Dict, List, Optional

from pydantic import BaseModel


class TestFile(BaseModel):
    """Represents a discovered test file."""

    path: Path
    """Absolute path to test file"""

    relative_path: Path
    """Path relative to project root"""

    name: str
    """Test file name"""

    category: str
    """Test category (based on directory)"""

    def __str__(self) -> str:
        """String representation."""
        return f"{self.category}/{self.name}"


class TestDiscovery:
    """
    Discovers GDScript test files in a project.

    Searches for .gd files matching test patterns in the tests directory.
    Properly distinguishes between GDSentry framework tests and user project tests.
    """

    def __init__(self, gdsentry_root: Path, game_project_root: Optional[Path] = None):
        """
        Initialize test discovery.

        Args:
            gdsentry_root: GDSentry framework root directory
            game_project_root: Godot game project root directory (optional)
        """
        self.gdsentry_root = gdsentry_root.resolve()
        self.game_project_root = game_project_root.resolve() if game_project_root else None
        
        # Framework tests are always in gdsentry_root/tests/
        self.framework_tests_dir = self.gdsentry_root / "tests"
        
        # Project tests are in game_project_root/tests/ or game_project_root/src/tests/
        if self.game_project_root:
            # Try both common locations
            if (self.game_project_root / "tests").exists():
                self.project_tests_dir: Optional[Path] = self.game_project_root / "tests"
            elif (self.game_project_root / "src" / "tests").exists():
                self.project_tests_dir = self.game_project_root / "src" / "tests"
            else:
                self.project_tests_dir = None
        else:
            # No game project, no project tests
            self.project_tests_dir = None

    def discover_all(self, pattern: str = "*_test.gd") -> List[TestFile]:
        """
        Discover all test files (both framework and project).

        Args:
            pattern: Glob pattern for test files

        Returns:
            List of discovered test files
        """
        framework = self._discover_framework_tests()
        project = self._discover_project_tests()
        
        all_tests = framework + project
        all_tests.sort(key=lambda t: (t.category, t.name))
        
        return all_tests

    def discover_by_scope(self, scope: str) -> List[TestFile]:
        """
        Discover tests by scope.

        Args:
            scope: Test scope (framework, project, both)

        Returns:
            List of test files for the scope
        """
        if scope == "framework":
            # Framework self-tests
            return self._discover_framework_tests()
        elif scope == "project":
            # User project tests
            return self._discover_project_tests()
        else:  # both
            framework = self._discover_framework_tests()
            project = self._discover_project_tests()
            return framework + project

    def discover_by_category(self, category: str) -> List[TestFile]:
        """
        Discover tests by category.

        Args:
            category: Test category (e.g., "core", "integration", "meta")

        Returns:
            List of test files in the category
        """
        test_files = []
        
        # Check framework tests
        framework_category_dir = self.framework_tests_dir / category
        if framework_category_dir.exists():
            for test_file in framework_category_dir.glob("*_test.gd"):
                if test_file.is_file():
                    test_files.append(self._create_test_file(test_file, is_framework=True))
        
        # Check project tests
        if self.project_tests_dir:
            project_category_dir = self.project_tests_dir / category
            if project_category_dir.exists():
                for test_file in project_category_dir.glob("*_test.gd"):
                    if test_file.is_file():
                        test_files.append(self._create_test_file(test_file, is_framework=False))

        test_files.sort(key=lambda t: t.name)
        return test_files

    def discover_by_filter(self, filter_pattern: str) -> List[TestFile]:
        """
        Discover tests by filter pattern.

        Args:
            filter_pattern: Glob pattern to filter tests

        Returns:
            Filtered list of test files
        """
        all_tests = self.discover_all()

        if filter_pattern == "*" or not filter_pattern:
            return all_tests

        # Filter by pattern matching against relative path
        filtered = []
        for test in all_tests:
            if test.relative_path.match(filter_pattern):
                filtered.append(test)

        return filtered

    def _discover_framework_tests(self) -> List[TestFile]:
        """Discover GDSentry framework self-tests.
        
        Framework tests are ALL tests in gdsentry_root/tests/ directory.
        """
        if not self.framework_tests_dir.exists():
            return []

        test_files = []
        for test_file in self.framework_tests_dir.rglob("*_test.gd"):
            if test_file.is_file():
                test_files.append(self._create_test_file(test_file, is_framework=True))

        return test_files

    def _discover_project_tests(self) -> List[TestFile]:
        """Discover user project tests.
        
        Project tests are in game_project_root/tests/ or game_project_root/src/tests/.
        Returns empty list if no game project or no tests directory.
        """
        if not self.project_tests_dir or not self.project_tests_dir.exists():
            return []

        test_files = []
        for test_file in self.project_tests_dir.rglob("*_test.gd"):
            if test_file.is_file():
                test_files.append(self._create_test_file(test_file, is_framework=False))

        return test_files

    def _create_test_file(self, file_path: Path, is_framework: bool) -> TestFile:
        """Create TestFile from path.
        
        Args:
            file_path: Path to test file
            is_framework: True if framework test, False if project test
        """
        if is_framework:
            base_dir = self.framework_tests_dir
            root = self.gdsentry_root
        else:
            base_dir = self.project_tests_dir
            root = self.game_project_root
        
        relative = file_path.relative_to(root) if root else file_path
        category = self._get_category(file_path, base_dir)

        return TestFile(
            path=file_path,
            relative_path=relative,
            name=file_path.name,
            category=category,
        )

    def _get_category(self, file_path: Path, tests_dir: Path) -> str:
        """Get category from file path.
        
        Args:
            file_path: Path to test file
            tests_dir: Base tests directory
        """
        relative = file_path.relative_to(tests_dir)

        # If in subdirectory, use that as category
        if len(relative.parts) > 1:
            return relative.parts[0]

        # Otherwise, use "general"
        return "general"

    def count_tests(self) -> Dict[str, int]:
        """
        Count tests by category.

        Returns:
            Dictionary of category -> count
        """
        all_tests = self.discover_all()

        counts: Dict[str, int] = {}
        for test in all_tests:
            category = test.category
            counts[category] = counts.get(category, 0) + 1

        return counts

