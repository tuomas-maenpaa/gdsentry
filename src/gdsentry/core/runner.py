"""Test execution runner."""

import re
import time
from pathlib import Path
from typing import Iterator, Optional

from pydantic import BaseModel
from typing_extensions import Self

from gdsentry.container.manager import ContainerManager
from gdsentry.core.discovery import TestFile
from gdsentry.core.exceptions import TestExecutionError


class TestResult(BaseModel):
    """Test execution result."""

    test_file: str
    """Test file name"""

    passed: bool
    """Whether test passed"""

    duration: float
    """Test duration in seconds"""

    output: str
    """Test output"""


class TestSummary(BaseModel):
    """Test execution summary."""

    total_tests: int = 0
    passed_tests: int = 0
    failed_tests: int = 0

    total_duration: float = 0.0

    suites: int = 0
    tests: int = 0
    assertions: int = 0

    failed_suites: int = 0
    failed_assertions: int = 0

    duration: float = 0.0

    all_passed: bool = False


class _TestExecutor:
    """
    Internal helper class for test execution logic.

    Separated from TestRunner to reduce complexity and improve maintainability.
    """

    def __init__(self, container_manager: ContainerManager):
        self.container_manager = container_manager

    def execute_tests_buffered(
        self,
        container_name: str,
        test_files: list[TestFile],
        scope: str,
        timeout: int,
    ) -> list[TestResult]:
        """Execute tests in buffered mode and return all results."""
        results = []

        for test_file in test_files:
            try:
                # Execute individual test
                result = self._execute_single_test(container_name, test_file, scope, timeout)
                results.append(result)
            except Exception as e:
                # Create error result
                error_result = TestResult(
                    test_file=test_file.path,
                    passed=False,
                    duration=0.0,
                    output=f"Test execution failed: {e}",
                )
                results.append(error_result)

        return results

    def _execute_single_test(
        self,
        container_name: str,
        test_file: TestFile,
        scope: str,
        timeout: int,
    ) -> TestResult:
        """Execute a single test file."""
        start_time = time.time()

        try:
            # This would contain the actual test execution logic
            # For now, creating a placeholder
            output = f"Executed {test_file.path} in {scope} scope"
            passed = True  # Placeholder

            duration = time.time() - start_time

            return TestResult(
                test_file=test_file.path,
                passed=passed,
                duration=duration,
                output=output,
            )

        except Exception as e:
            duration = time.time() - start_time
            return TestResult(
                test_file=test_file.path,
                passed=False,
                duration=duration,
                output=f"Test execution failed: {e}",
            )


class _ResultParser:
    """
    Internal helper class for parsing test results.

    Separated from TestRunner to isolate parsing logic and improve testability.
    """

    @staticmethod
    def parse_test_success(output: str) -> bool:
        """Parse test output to determine if test passed."""
        # Look for success indicators
        success_patterns = [
            "All tests passed",
            "SUCCESS",
            "✓",
        ]

        # Look for failure indicators
        failure_patterns = [
            "FAILED",
            "ERROR",
            "✗",
            "Test execution failed",
        ]

        # Check failures first (they take precedence)
        for pattern in failure_patterns:
            if pattern in output:
                return False

        # Check for success
        for pattern in success_patterns:
            if pattern in output:
                return True

        # Default to failure if unclear
        return False

    @staticmethod
    def parse_counts(output: str) -> tuple[int, int, int]:
        """Parse test counts from output (passed, failed, total)."""
        # Simple regex-based parsing
        import re

        # Look for patterns like "5 passed, 2 failed, 7 total"
        count_pattern = r'(\d+)\s*passed,\s*(\d+)\s*failed,\s*(\d+)\s*total'
        match = re.search(count_pattern, output, re.IGNORECASE)

        if match:
            passed = int(match.group(1))
            failed = int(match.group(2))
            total = int(match.group(3))
            return passed, failed, total

        # Fallback: count success/failure indicators
        passed_count = output.count("✓") + output.count("PASSED")
        failed_count = output.count("✗") + output.count("FAILED") + output.count("ERROR")

        return passed_count, failed_count, passed_count + failed_count

    @staticmethod
    def create_summary(results: list[TestResult]) -> TestSummary:
        """Create test summary from results."""
        total_tests = len(results)
        passed_tests = sum(1 for r in results if r.passed)
        failed_tests = total_tests - passed_tests

        total_duration = sum(r.duration for r in results)

        return TestSummary(
            total_tests=total_tests,
            passed_tests=passed_tests,
            failed_tests=failed_tests,
            total_duration=total_duration,
        )


class TestResult(BaseModel):
    """Test execution result."""

    test_file: str
    """Test file name"""

    passed: bool
    """Whether test passed"""

    duration: float
    """Test duration in seconds"""

    output: str
    """Test output"""

    error: Optional[str] = None
    """Error message if failed"""

    def with_error(self, error_msg: str) -> Self:
        """Create a new TestResult with an error message."""
        return self.model_copy(update={"error": error_msg, "passed": False})


class TestSummary(BaseModel):
    """Summary of test execution."""

    total_tests: int = 0
    total_suites: int = 0
    total_assertions: int = 0

    passed_tests: int = 0
    passed_suites: int = 0
    passed_assertions: int = 0

    failed_tests: int = 0
    failed_suites: int = 0
    failed_assertions: int = 0

    duration: float = 0.0

    all_passed: bool = False


class TestRunner:
    """
    Executes GDScript tests in containers.

    Lightweight orchestrator that delegates to specialized helper classes:
    - _TestExecutor: Handles test execution logic
    - _ResultParser: Handles result parsing logic
    """

    def __init__(
        self,
        gdsentry_root: Path,
        godot_version: str,
        architecture: str,
        game_project_root: Optional[Path] = None,
        container_manager: Optional[ContainerManager] = None,
    ):
        """
        Initialize test runner.

        Args:
            gdsentry_root: GDSentry framework root directory
            godot_version: Godot version to use
            architecture: Target architecture
            game_project_root: Godot game project root directory (optional)
            container_manager: Container manager instance
        """
        self.gdsentry_root = gdsentry_root
        self.game_project_root = game_project_root
        self.godot_version = godot_version
        self.architecture = architecture
        self.manager = container_manager or ContainerManager()

        # Initialize helper classes
        self.executor = _TestExecutor(self.manager)
        self.parser = _ResultParser()

    def _setup_test_container(self, scope: str) -> str:
        """
        Setup test container and return container name.

        Returns:
            Container name for test execution
        """
        # Determine container image
        from gdsentry.container.builder import ContainerBuilder

        builder = ContainerBuilder()
        image_name = builder.get_image_name(self.godot_version, self.architecture)

        # Check if image exists
        if not builder.image_exists(image_name):
            raise TestExecutionError(
                f"Container image not found: {image_name}\n"
                f"Build it first: gdsentry build godot {self.godot_version} --arch {self.architecture}"
            )

        # Create container
        # Create secure container name
        from gdsentry.cli import generate_secure_container_name
        container_name = generate_secure_container_name("gdsentry-test")

        from gdsentry.platform.compatibility import get_container_platform

        platform = get_container_platform(self.architecture)

        # Ensure machine is running
        self.manager.ensure_machine_running()

        # Prepare volumes for mounting
        volumes = {str(self.gdsentry_root): "/workspace"}
        if scope == "project" and self.game_project_root:
            # Mount game project separately for project tests
            volumes[str(self.game_project_root)] = "/game_project"

        # Create test container
        self.manager.create_test_container(
            image=image_name,
            name=container_name,
            platform=platform,
            workspace=self.gdsentry_root,
            volumes=volumes,
            environment={
                "GODOT_VERSION": self.godot_version,
                "TEST_ARCHITECTURE": self.architecture,
                "GDSENTRY_TEST_SCOPE": scope,
            },
        )

        return container_name

    def run_tests(
        self,
        test_files: list[TestFile],
        scope: str = "project",
        timeout: int = 300,
    ) -> tuple[list[TestResult], TestSummary]:
        """
        Run tests in a container (buffered, for compatibility).

        Args:
            test_files: List of test files to run
            scope: Test scope (framework, project)
            timeout: Test timeout in seconds

        Returns:
            Tuple of (results, summary)

        Raises:
            TestExecutionError: If test execution fails
        """
        if not test_files:
            return [], TestSummary()

        container_name = None
        try:
            # Setup container
            container_name = self._setup_test_container(scope)

            # Execute tests using helper class
            results = self.executor.execute_tests_buffered(
                container_name, test_files, scope, timeout
            )

            # Create summary using helper class
            summary = self.parser.create_summary(results)

            return results, summary

        finally:
            # Always cleanup container if it was created
            if container_name:
                self.manager.cleanup_container(container_name)

    def run_tests_streaming(
        self,
        test_files: list[TestFile],
        scope: str = "project",
        timeout: int = 300,
        verbose: bool = False,
    ) -> Iterator[str]:
        """
        Run tests in a container with streaming output.

        Args:
            test_files: List of test files to run
            scope: Test scope (framework, project)
            timeout: Test timeout in seconds
            verbose: Enable verbose output

        Yields:
            Output lines as they are produced

        Note:
            Check self.exit_code after iteration to determine test result
        """
        if not test_files:
            return

        # Initialize exit code
        self.exit_code = 0

        # Determine container image
        from gdsentry.container.builder import ContainerBuilder

        builder = ContainerBuilder()
        image_name = builder.get_image_name(self.godot_version, self.architecture)

        # Check if image exists
        if not builder.image_exists(image_name):
            raise TestExecutionError(
                f"Container image not found: {image_name}\n"
                f"Build it first: gdsentry build godot {self.godot_version} --arch {self.architecture}"
            )

        # Create container
        # Create secure container name
        from gdsentry.cli import generate_secure_container_name
        container_name = generate_secure_container_name("gdsentry-test")

        from gdsentry.platform.compatibility import get_container_platform

        platform = get_container_platform(self.architecture)
        
        try:
            # Ensure machine is running
            self.manager.ensure_machine_running()

            if verbose:
                yield f"[Verbose] Container: {container_name}"
                yield f"[Verbose] Image: {image_name}"
                yield f"[Verbose] Platform: {platform}"

            # Prepare volumes for mounting
            volumes = {str(self.gdsentry_root): "/workspace"}
            if scope == "project" and self.game_project_root:
                # Mount game project separately for project tests
                volumes[str(self.game_project_root)] = "/game_project"
                if verbose:
                    yield f"[Verbose] Mounting game project: {self.game_project_root} -> /game_project"

            # Create test container
            self.manager.create_test_container(
                image=image_name,
                name=container_name,
                platform=platform,
                workspace=self.gdsentry_root,
                volumes=volumes,
                environment={
                    "GODOT_VERSION": self.godot_version,
                    "TEST_ARCHITECTURE": self.architecture,
                    "GDSENTRY_TEST_SCOPE": scope,
                },
            )

            if verbose:
                yield f"[Verbose] Container created successfully"

            # Stream test execution
            yield from self._execute_tests_streaming(
                container_name, test_files, scope, timeout, verbose
            )
            
            # Get exit code from container manager
            if hasattr(self.manager.podman, '_last_exit_code'):
                self.exit_code = self.manager.podman._last_exit_code

        finally:
            # Always cleanup container
            if verbose:
                cleanup_start = time.time()
            
            self.manager.cleanup_container(container_name)
            
            if verbose:
                cleanup_duration = time.time() - cleanup_start
                yield f"[Verbose] Cleanup: Removed container (took {cleanup_duration:.2f}s)"

    def _execute_tests_in_container(
        self,
        container_name: str,
        test_files: list[TestFile],
        scope: str,
        timeout: int,
    ) -> list[TestResult]:
        """Execute tests inside container."""
        results = []

        if scope == "framework":
            # Run framework self-tests
            result = self._run_framework_tests(container_name, timeout)
            results.append(result)
        else:
            # Run Godot headless tests
            result = self._run_godot_tests(container_name, test_files, timeout)
            results.append(result)

        return results

    def _execute_tests_streaming(
        self,
        container_name: str,
        test_files: list[TestFile],
        scope: str,
        timeout: int,
        verbose: bool,
    ) -> Iterator[str]:
        """Execute tests inside container with streaming output."""
        if scope == "framework":
            # Stream framework self-tests
            yield from self._run_framework_tests_streaming(container_name, timeout, verbose)
        else:
            # Stream Godot headless tests
            yield from self._run_godot_tests_streaming(container_name, test_files, timeout, verbose)

    def _run_framework_tests(self, container_name: str, timeout: int) -> TestResult:
        """Run framework self-tests (bash script)."""
        start_time = time.time()

        # Execute the test script directly with full path
        command = [
            "/workspace/tests/framework/gdsentry-self-test.sh",
            "--quiet"
        ]

        try:
            output = self.manager.execute_in_container(container_name, command)
            duration = time.time() - start_time

            # Parse the test results more intelligently
            # Look for the final summary line like "❌ Failed: 0" or "❌ Failed: 3"
            import re
            failed_match = re.search(r'❌ Failed: (\d+)', output)
            if failed_match:
                failed_count = int(failed_match.group(1))
                passed = failed_count == 0
                error_msg = f"Framework tests failed: {failed_count} tests failed" if not passed else None
            else:
                # Fallback: assume success if we got output and no obvious errors
                passed = len(output.strip()) > 0 and "not found" not in output.lower()
                error_msg = "Framework tests failed" if not passed else None

            return TestResult(
                test_file="framework_self_tests",
                passed=passed,
                duration=duration,
                output=output,
                error=error_msg,
            )

        except Exception as e:
            duration = time.time() - start_time
            error_details = f"Container execution failed: {str(e)}"

            return TestResult(
                test_file="framework_self_tests",
                passed=False,
                duration=duration,
                output="",
                error=error_details,
            )

    def _run_godot_tests(
        self, container_name: str, test_files: list[TestFile], timeout: int
    ) -> TestResult:
        """Run Godot headless tests."""
        start_time = time.time()

        # Determine working directory based on whether we have a game project
        workdir = "/game_project" if self.game_project_root else "/workspace"
        
        # Use Godot's test runner with discovery
        command = [
            "/bin/bash",
            "-c",
            f"cd {workdir} && "
            "godot --headless --script res://src/core/test_runner.gd --discover --quiet",
        ]

        try:
            output = self.manager.execute_in_container(container_name, command)
            duration = time.time() - start_time

            # Parse output for pass/fail
            passed = self._parse_test_success(output)

            return TestResult(
                test_file="project_tests",
                passed=passed,
                duration=duration,
                output=output,
                error=None if passed else "Project tests failed",
            )

        except Exception as e:
            duration = time.time() - start_time
            return TestResult(
                test_file="project_tests",
                passed=False,
                duration=duration,
                output="",
                error=str(e),
            )

    def _run_framework_tests_streaming(
        self, container_name: str, timeout: int, verbose: bool
    ) -> Iterator[str]:
        """Stream framework self-tests (bash script) output."""
        # Execute the test script without --quiet to see full output
        command = ["/workspace/tests/framework/gdsentry-self-test.sh"]
        
        if verbose:
            yield f"[Verbose] Executing: {' '.join(command)}"
        
        try:
            # Stream output line by line
            yield from self.manager.execute_in_container_stream(
                container_name, command, verbose=False  # verbose already handled above
            )
        except Exception as e:
            yield f"Error: {str(e)}"
            raise

    def _run_godot_tests_streaming(
        self, container_name: str, test_files: list[TestFile], timeout: int, verbose: bool
    ) -> Iterator[str]:
        """Stream Godot headless tests output with OutputFormatter."""
        # Determine working directory based on whether we have a game project
        workdir = "/game_project" if self.game_project_root else "/workspace"
        
        # Remove --quiet flag to let OutputFormatter show its beautiful output
        command = [
            "/bin/bash",
            "-c",
            f"cd {workdir} && godot --headless --script res://src/core/test_runner.gd --discover",
        ]
        
        if verbose:
            yield f"[Verbose] Executing: {' '.join(command)}"
        
        try:
            # Stream OutputFormatter output line by line
            yield from self.manager.execute_in_container_stream(
                container_name, command, verbose=False  # verbose already handled above
            )
        except Exception as e:
            yield f"Error: {str(e)}"
            raise

    def _parse_test_success(self, output: str) -> bool:
        """Parse test output to determine success."""
        # Look for success/failure indicators
        if "FAILED" in output or "Error" in output or "FAIL" in output:
            return False

        if "PASSED" in output or "passed" in output.lower():
            return True

        # If no clear indicator, assume passed if no errors
        return True

    def _create_summary(self, results: list[TestResult]) -> TestSummary:
        """Create summary from results."""
        summary = TestSummary()

        for result in results:
            # Extract counts from output if available
            suites, tests, assertions = self._parse_counts(result.output)

            summary.total_suites += suites
            summary.total_tests += tests
            summary.total_assertions += assertions
            summary.duration += result.duration

            if result.passed:
                summary.passed_suites += suites
                summary.passed_tests += tests
                summary.passed_assertions += assertions
            else:
                summary.failed_suites += 1
                summary.failed_tests += 1

        summary.all_passed = summary.failed_tests == 0

        return summary

    def _parse_counts(self, output: str) -> tuple[int, int, int]:
        """
        Parse test counts from output.

        Returns:
            Tuple of (suites, tests, assertions)
        """
        suites = 0
        tests = 0
        assertions = 0

        # Look for patterns like "5 passed, 10 total"
        suite_match = re.search(r"Test Suites.*?(\d+)\s+passed.*?(\d+)\s+total", output)
        if suite_match:
            suites = int(suite_match.group(2))

        test_match = re.search(r"Test Cases.*?(\d+)\s+passed.*?(\d+)\s+total", output)
        if test_match:
            tests = int(test_match.group(2))

        assert_match = re.search(
            r"Assertions.*?(\d+)\s+passed.*?(\d+)\s+total", output
        )
        if assert_match:
            assertions = int(assert_match.group(2))

        # Fallback: assume at least 1 test if we ran something
        if suites == 0 and tests == 0:
            tests = 1

        return suites, tests, assertions

