"""Integration tests for streaming functionality in test runner."""

import tempfile
from pathlib import Path
from unittest.mock import Mock, patch

import pytest

from gdsentry.cli.app import app
from gdsentry.core.discovery import TestFile
from gdsentry.core.runner import TestRunner
from typer.testing import CliRunner

runner = CliRunner()


class TestStreamingFunctionality:
    """Test streaming functionality in test runner."""

    def test_streaming_framework_tests_basic(self):
        """Test basic streaming of framework tests in containers."""
        # Create a mock container manager that streams output
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            # Mock the streaming method to yield test output lines
            mock_manager.execute_in_container_stream.return_value = [
                "Running GDSentry framework tests...",
                "✓ Test discovery working",
                "✓ Test execution working",
                "✓ Test reporting working",
                "Framework tests completed successfully"
            ]

            # Create test runner
            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            # Test framework streaming - need at least one dummy test file to trigger execution
            test_files = [TestFile(path=Path("dummy"), category="framework", relative_path=Path("dummy"), name="dummy")]
            lines = list(test_runner.run_tests_streaming(test_files, scope="framework", verbose=False))

            assert len(lines) == 5
            assert "Running GDSentry framework tests..." in lines[0]
            assert "Framework tests completed successfully" in lines[-1]

            # Verify container operations
            mock_manager.ensure_machine_running.assert_called_once()
            mock_manager.create_test_container.assert_called_once()
            mock_manager.cleanup_container.assert_called_once()

    def test_streaming_project_tests_basic(self):
        """Test basic streaming of project tests."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            # Mock streaming output for Godot tests
            mock_manager.execute_in_container_stream.return_value = [
                "Godot Test Runner - Starting...",
                "[INFO] Loading test: test_player.gd",
                "[PASS] test_player_movement",
                "[PASS] test_player_health",
                "[INFO] Test suite completed: 2 passed, 0 failed",
                "Output formatting complete"
            ]

            # Create test runner
            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            # Create mock test files
            test_files = [
                TestFile(
                    path=Path("tests/unit/test_player.gd"),
                    category="unit",
                    relative_path=Path("tests/unit/test_player.gd"),
                    name="test_player.gd"
                )
            ]

            lines = list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))

            assert len(lines) == 6
            assert "Godot Test Runner - Starting..." in lines[0]
            assert "[PASS] test_player_movement" in lines[2]
            assert "Output formatting complete" in lines[-1]

    def test_streaming_with_verbose_mode(self):
        """Test streaming with verbose mode enabled."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            mock_manager.execute_in_container_stream.return_value = [
                "Test execution output line 1",
                "Test execution output line 2"
            ]

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = []
            lines = list(test_runner.run_tests_streaming(test_files, scope="framework", verbose=True))

            # Should include verbose container information
            verbose_lines = [line for line in lines if "[Verbose]" in line]
            assert len(verbose_lines) >= 3  # Container info, creation, cleanup

            # Should include the actual test output
            test_lines = [line for line in lines if "Test execution output" in line]
            assert len(test_lines) == 2

    def test_streaming_error_handling(self):
        """Test streaming handles errors gracefully."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            # Mock streaming that raises an exception
            mock_manager.execute_in_container_stream.side_effect = Exception("Container execution failed")

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = []
            with pytest.raises(Exception, match="Container execution failed"):
                list(test_runner.run_tests_streaming(test_files, scope="framework", verbose=False))

    def test_streaming_container_cleanup_on_error(self):
        """Test that containers are cleaned up even when streaming fails."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            # Mock streaming that fails
            mock_manager.execute_in_container_stream.side_effect = Exception("Streaming failed")

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = []
            with pytest.raises(Exception):
                list(test_runner.run_tests_streaming(test_files, scope="framework", verbose=False))

            # Container cleanup should still be called
            mock_manager.cleanup_container.assert_called_once()

    def test_streaming_different_test_scopes(self):
        """Test streaming works with different test scopes."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            # Test framework scope
            mock_manager.execute_in_container_stream.return_value = ["Framework test output"]
            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            # Framework scope
            lines = list(test_runner.run_tests_streaming([], scope="framework", verbose=False))
            assert len(lines) == 1
            assert "Framework test output" in lines[0]

            # Reset mock
            mock_manager.reset_mock()
            mock_manager.execute_in_container_stream.return_value = ["Project test output"]

            # Project scope
            test_files = [TestFile(path=Path("test.gd"), category="unit", relative_path=Path("test.gd"), name="test.gd")]
            lines = list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))
            assert len(lines) == 1
            assert "Project test output" in lines[0]

    def test_streaming_empty_test_files(self):
        """Test streaming handles empty test file list."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            # Empty test files should return immediately
            lines = list(test_runner.run_tests_streaming([], scope="project", verbose=False))
            assert len(lines) == 0

            # No container operations should be performed
            mock_manager.ensure_machine_running.assert_not_called()
            mock_manager.create_test_container.assert_not_called()

    def test_streaming_container_image_not_found(self):
        """Test streaming handles missing container images."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            # Mock image not existing
            with patch("gdsentry.container.builder.ContainerBuilder") as mock_builder_class:
                mock_builder = Mock()
                mock_builder_class.return_value = mock_builder
                mock_builder.image_exists.return_value = False
                mock_builder.get_image_name.return_value = "missing-image"

                test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

                test_files = [TestFile(path=Path("test.gd"), category="unit", relative_path=Path("test.gd"), name="test.gd")]

                from gdsentry.core.exceptions import TestExecutionError
                with pytest.raises(TestExecutionError, match="Container image not found"):
                    list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))

    def test_streaming_verbose_cleanup_timing(self):
        """Test verbose mode shows cleanup timing."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            mock_manager.execute_in_container_stream.return_value = ["Test output"]

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = []
            lines = list(test_runner.run_tests_streaming(test_files, scope="framework", verbose=True))

            # Should include cleanup timing information
            cleanup_lines = [line for line in lines if "Cleanup:" in line and "took" in line]
            assert len(cleanup_lines) == 1

    def test_streaming_multiple_test_files(self):
        """Test streaming with multiple test files."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            mock_manager.execute_in_container_stream.return_value = [
                "Starting test execution...",
                "[INFO] Loading test: test_player.gd",
                "[PASS] test_player_movement",
                "[INFO] Loading test: test_enemy.gd",
                "[PASS] test_enemy_ai",
                "[FAIL] test_enemy_collision",
                "Test execution complete: 2 passed, 1 failed"
            ]

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = [
                TestFile(path=Path("tests/unit/test_player.gd"), category="unit", relative_path=Path("tests/unit/test_player.gd"), name="test_player.gd"),
                TestFile(path=Path("tests/unit/test_enemy.gd"), category="unit", relative_path=Path("tests/unit/test_enemy.gd"), name="test_enemy.gd"),
            ]

            lines = list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))

            assert len(lines) == 7
            assert "[PASS] test_player_movement" in lines
            assert "[PASS] test_enemy_ai" in lines
            assert "[FAIL] test_enemy_collision" in lines
            assert "2 passed, 1 failed" in lines[-1]


class TestStreamingCLIIntegration:
    """Test streaming functionality through CLI."""

    def test_cli_streaming_framework_tests(self):
        """Test CLI streaming for framework tests in containers."""
        with patch("gdsentry.cli.commands.test.TestRunner") as mock_runner_class:
            mock_runner = Mock()
            mock_runner_class.return_value = mock_runner

            # Mock streaming output and successful exit code
            mock_runner.run_tests_streaming.return_value = [
                "Streaming framework test output...",
                "✓ Framework test 1 passed",
                "✓ Framework test 2 passed",
                "All framework tests passed"
            ]
            mock_runner.exit_code = 0  # Indicate successful test execution

            # Mock test discovery - need some test files for container execution
            with patch("gdsentry.cli.commands.test.discover_tests") as mock_discover:
                mock_discover.return_value = [
                    Mock(relative_path="tests/framework/dummy.gd", category="framework")
                ]

                result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "30"])

                assert result.exit_code == 0
                # CLI should print each streamed line
                assert "Streaming framework test output..." in result.stdout
                assert "All framework tests passed" in result.stdout

    def test_cli_streaming_with_verbose(self):
        """Test CLI streaming with verbose output."""
        with patch("gdsentry.cli.commands.test.TestRunner") as mock_runner_class:
            mock_runner = Mock()
            mock_runner_class.return_value = mock_runner

            mock_runner.run_tests_streaming.return_value = [
                "[Verbose] Container info",
                "Test output line 1",
                "Test output line 2",
                "[Verbose] Cleanup completed"
            ]
            mock_runner.exit_code = 0

            with patch("gdsentry.cli.commands.test.discover_tests") as mock_discover:
                mock_discover.return_value = [
                    Mock(relative_path="tests/framework/dummy.gd", category="framework")
                ]

                result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--verbose", "--timeout", "30"])

                assert result.exit_code == 0
                assert "[Verbose] Container info" in result.stdout
                assert "[Verbose] Cleanup completed" in result.stdout
                assert "Test output line 1" in result.stdout

    def test_cli_streaming_error_handling(self):
        """Test CLI handles streaming errors properly."""
        with patch("gdsentry.cli.commands.test.TestRunner") as mock_runner_class:
            mock_runner = Mock()
            mock_runner_class.return_value = mock_runner

            from gdsentry.core.exceptions import TestExecutionError
            mock_runner.run_tests_streaming.side_effect = TestExecutionError("Streaming failed")

            with patch("gdsentry.cli.commands.test.discover_tests") as mock_discover:
                mock_discover.return_value = [
                    Mock(relative_path="tests/framework/dummy.gd", category="framework")
                ]

                result = runner.invoke(app, ["test", "run-container", "--scope", "framework", "--timeout", "30"])

                assert result.exit_code == 2  # Infrastructure failure
                assert "Streaming failed" in result.stdout

    def test_cli_streaming_project_tests(self):
        """Test CLI streaming for project tests."""
        with patch("gdsentry.cli.commands.test.TestRunner") as mock_runner_class:
            mock_runner = Mock()
            mock_runner_class.return_value = mock_runner

            mock_runner.run_tests_streaming.return_value = [
                "Running project tests...",
                "[INFO] Executing test suite",
                "[PASS] All tests passed",
                "Project tests completed"
            ]
            mock_runner.exit_code = 0

            # Mock test discovery to return some files
            with patch("gdsentry.cli.commands.test.discover_tests") as mock_discover:
                mock_discover.return_value = [
                    Mock(relative_path="tests/unit/test_example.gd", category="unit")
                ]

                result = runner.invoke(app, ["test", "run-container", "--scope", "project", "--timeout", "30"])

                assert result.exit_code == 0
                assert "Running project tests..." in result.stdout
                assert "Project tests completed" in result.stdout

    def test_cli_streaming_no_tests_found(self):
        """Test CLI streaming when no tests are found."""
        with patch("gdsentry.cli.commands.test.discover_tests") as mock_discover:
            mock_discover.return_value = []

            result = runner.invoke(app, ["test", "run-container", "--scope", "project", "--timeout", "30"])

            assert result.exit_code == 0
            assert "No tests to run" in result.stdout


class TestStreamingOutputFormatting:
    """Test streaming output formatting and parsing."""

    def test_streaming_output_contains_expected_patterns(self):
        """Test that streaming output contains expected formatting patterns."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            mock_manager.execute_in_container_stream.return_value = [
                "Godot Test Runner Output:",
                "[INFO] Test discovery started",
                "[PASS] ✓ test_player_can_move",
                "[PASS] ✓ test_player_can_jump",
                "[FAIL] ✗ test_player_collision - Assertion failed",
                "[SUMMARY] Tests: 3, Passed: 2, Failed: 1",
                "Output formatting completed"
            ]

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = [TestFile(path=Path("test.gd"), category="unit", relative_path=Path("test.gd"), name="test.gd")]
            lines = list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))

            assert len(lines) == 7
            assert "[INFO]" in lines[1]
            assert "[PASS] ✓" in lines[2]
            assert "[FAIL] ✗" in lines[4]
            assert "[SUMMARY]" in lines[5]

    def test_streaming_progress_indicators(self):
        """Test streaming shows progress indicators."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            mock_manager.execute_in_container_stream.return_value = [
                "Starting test execution...",
                "⠋ Discovering tests...",
                "✓ Tests discovered: 5 files",
                "⠴ Running tests...",
                "✓ Test 1/5 completed",
                "✓ Test 2/5 completed",
                "✓ Test 3/5 completed",
                "✓ Test 4/5 completed",
                "✓ Test 5/5 completed",
                "All tests completed successfully"
            ]

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = [TestFile(path=Path("test.gd"), category="unit", relative_path=Path("test.gd"), name="test.gd")]
            lines = list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))

            # Should contain progress indicators
            progress_lines = [line for line in lines if "⠋" in line or "⠴" in line or "✓" in line]
            assert len(progress_lines) >= 6  # Multiple progress indicators

    def test_streaming_error_formatting(self):
        """Test streaming formats error output correctly."""
        with patch("gdsentry.core.runner.ContainerManager") as mock_manager_class:
            mock_manager = Mock()
            mock_manager_class.return_value = mock_manager

            mock_manager.execute_in_container_stream.return_value = [
                "Test execution started",
                "[ERROR] Script error in test_player.gd:42",
                "  Assertion failed: expected 100, got 50",
                "  Stack trace:",
                "    at test_player.gd:42:_test_movement",
                "[ERROR] Test suite aborted due to errors",
                "Execution terminated"
            ]

            test_runner = TestRunner(Path("/fake/project"), "4.2.1-stable", "x86_64", mock_manager)

            test_files = [TestFile(path=Path("test.gd"), category="unit", relative_path=Path("test.gd"), name="test.gd")]
            lines = list(test_runner.run_tests_streaming(test_files, scope="project", verbose=False))

            assert "[ERROR]" in lines[1]
            assert "[ERROR]" in lines[5]
            assert "Assertion failed" in lines[2]
            assert "Stack trace:" in lines[3]
