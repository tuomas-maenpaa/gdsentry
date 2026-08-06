"""Tests for test discovery and execution functionality."""

import pytest
from pathlib import Path

from gdsentry.core.discovery import TestDiscovery, TestFile
from gdsentry.core.runner import TestRunner, TestResult, TestSummary
from gdsentry.core.reporter import TestReporter


class TestTestDiscovery:
    """Test test file discovery."""

    def test_discovery_creation(self):
        """Test that TestDiscovery can be created."""
        project_root = Path.cwd()
        discovery = TestDiscovery(project_root)

        assert discovery is not None
        assert discovery.project_root == project_root.resolve()
        assert discovery.tests_dir == project_root / "tests"

    def test_discover_all_finds_tests(self):
        """Test discovering all test files."""
        project_root = Path.cwd()
        discovery = TestDiscovery(project_root)

        tests = discovery.discover_all()

        # GDSentry has many test files
        assert len(tests) > 0

        # All should be TestFile instances
        for test in tests:
            assert isinstance(test, TestFile)
            assert test.path.exists()
            assert test.path.suffix == ".gd"

    def test_discover_by_category(self):
        """Test discovering tests by category."""
        project_root = Path.cwd()
        discovery = TestDiscovery(project_root)

        # Discover core tests
        core_tests = discovery.discover_by_category("core")

        if core_tests:
            for test in core_tests:
                assert test.category == "core"

    def test_discover_by_scope_framework(self):
        """Test discovering framework tests."""
        project_root = Path.cwd()
        discovery = TestDiscovery(project_root)

        framework_tests = discovery.discover_by_scope("framework")

        # Framework tests should be in meta/ directory
        if framework_tests:
            for test in framework_tests:
                assert test.category == "meta"

    def test_discover_by_scope_project(self):
        """Test discovering project tests."""
        project_root = Path.cwd()
        discovery = TestDiscovery(project_root)

        project_tests = discovery.discover_by_scope("project")

        # Project tests should exclude meta
        for test in project_tests:
            assert test.category != "meta"

    def test_count_tests(self):
        """Test counting tests by category."""
        project_root = Path.cwd()
        discovery = TestDiscovery(project_root)

        counts = discovery.count_tests()

        assert isinstance(counts, dict)

        # Should have some categories
        total = sum(counts.values())
        assert total > 0


class TestTestFile:
    """Test TestFile model."""

    def test_test_file_creation(self):
        """Test creating TestFile."""
        test_file = TestFile(
            path=Path("/workspace/tests/core/test_runner_test.gd"),
            relative_path=Path("tests/core/test_runner_test.gd"),
            name="test_runner_test.gd",
            category="core",
        )

        assert test_file.name == "test_runner_test.gd"
        assert test_file.category == "core"

    def test_test_file_string_representation(self):
        """Test TestFile string representation."""
        test_file = TestFile(
            path=Path("/workspace/tests/core/test.gd"),
            relative_path=Path("tests/core/test.gd"),
            name="test.gd",
            category="core",
        )

        assert str(test_file) == "core/test.gd"


class TestTestResult:
    """Test TestResult model."""

    def test_test_result_passed(self):
        """Test creating passing test result."""
        result = TestResult(
            test_file="my_test.gd",
            passed=True,
            duration=1.5,
            output="All tests passed",
        )

        assert result.passed is True
        assert result.duration == 1.5
        assert result.error is None

    def test_test_result_failed(self):
        """Test creating failed test result."""
        result = TestResult(
            test_file="my_test.gd",
            passed=False,
            duration=2.0,
            output="Test failed",
            error="Assertion failed",
        )

        assert result.passed is False
        assert result.error == "Assertion failed"


class TestTestSummary:
    """Test TestSummary model."""

    def test_empty_summary(self):
        """Test empty summary."""
        summary = TestSummary()

        assert summary.total_tests == 0
        assert summary.passed_tests == 0
        assert summary.failed_tests == 0
        assert summary.all_passed is False

    def test_summary_all_passed(self):
        """Test summary with all tests passed."""
        summary = TestSummary(
            total_tests=10,
            passed_tests=10,
            failed_tests=0,
            total_suites=5,
            passed_suites=5,
            duration=5.0,
            all_passed=True,
        )

        assert summary.all_passed is True
        assert summary.failed_tests == 0

    def test_summary_some_failed(self):
        """Test summary with some failures."""
        summary = TestSummary(
            total_tests=10,
            passed_tests=8,
            failed_tests=2,
            duration=5.0,
            all_passed=False,
        )

        assert summary.all_passed is False
        assert summary.failed_tests == 2


class TestTestReporter:
    """Test test result reporting."""

    def test_reporter_creation(self):
        """Test that TestReporter can be created."""
        reporter = TestReporter()
        assert reporter is not None

    def test_report_summary_all_passed(self):
        """Test reporting passed summary."""
        reporter = TestReporter()

        summary = TestSummary(
            total_tests=5,
            passed_tests=5,
            failed_tests=0,
            total_suites=2,
            passed_suites=2,
            total_assertions=20,
            passed_assertions=20,
            duration=3.5,
            all_passed=True,
        )

        # Should not raise
        reporter.report_summary(summary)

    def test_report_summary_some_failed(self):
        """Test reporting summary with failures."""
        reporter = TestReporter()

        summary = TestSummary(
            total_tests=5,
            passed_tests=3,
            failed_tests=2,
            duration=3.5,
            all_passed=False,
        )

        # Should not raise
        reporter.report_summary(summary)

    def test_report_results(self):
        """Test reporting individual results."""
        reporter = TestReporter()

        results = [
            TestResult(
                test_file="test1.gd", passed=True, duration=1.0, output="OK"
            ),
            TestResult(
                test_file="test2.gd",
                passed=False,
                duration=2.0,
                output="Failed",
                error="Error",
            ),
        ]

        # Should not raise
        reporter.report_results(results)

    def test_report_errors(self):
        """Test reporting errors."""
        reporter = TestReporter()

        results = [
            TestResult(
                test_file="failed_test.gd",
                passed=False,
                duration=1.5,
                output="Test output",
                error="Something went wrong",
            )
        ]

        # Should not raise
        reporter.report_errors(results)


class TestTestCLI:
    """Test test CLI commands."""

    def test_test_commands_import(self):
        """Test that test commands can be imported."""
        from gdsentry.cli.commands import test

        assert test.app is not None
        assert hasattr(test, "discover_tests")
        assert hasattr(test, "run_tests")
        assert hasattr(test, "quick_test")

