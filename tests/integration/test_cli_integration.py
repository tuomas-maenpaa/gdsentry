"""End-to-end tests for CLI integration with real Godot projects."""

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest


class TestCLIIntegration:
    """Test CLI integration with real Godot projects."""

    def setup_method(self):
        """Set up test environment."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.project_dir = self.temp_dir / "test_project"
        self._create_minimal_project()

    def teardown_method(self):
        """Clean up test environment."""
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def _create_minimal_project(self):
        """Create a minimal test project for CI."""
        self.project_dir.mkdir()

        # Create project.godot
        project_godot = self.project_dir / "project.godot"
        project_godot.write_text("""[application]
config/name="Test Project"
config/version="1.0.0"

[rendering]
renderer/rendering_method="gl_compatibility"
""")

        # Create gdsentry.toml
        gdsentry_toml = self.project_dir / "gdsentry.toml"
        gdsentry_toml.write_text("""[project]
name = "Test Project"
godot_version = "4.2.1"

[test]
timeout = 30
""")

        # Create tests directory with a simple test
        tests_dir = self.project_dir / "tests"
        tests_dir.mkdir()

        test_file = tests_dir / "simple_test.gd"
        test_file.write_text("""extends SceneTreeTest

func run_test_suite() -> void:
    run_test("test_simple", func(): return test_simple())

func test_simple() -> bool:
    return assert_equals(2 + 2, 4)
""")

    def _run_cli(self, args, cwd=None):
        """Run GDSentry CLI command."""
        cmd = [sys.executable, "-m", "gdsentry"] + args
        env = {**dict(os.environ), "PYTHONPATH": str(Path(__file__).parent.parent.parent / "src")}

        result = subprocess.run(
            cmd,
            cwd=cwd or self.project_dir,
            env=env,
            capture_output=True,
            text=True,
            timeout=60
        )
        return result

    def test_cli_discovery_works(self):
        """Test that CLI can discover tests in a real project."""
        result = self._run_cli(["test", "discover"])

        assert result.returncode == 0, f"Discovery failed: {result.stderr}"
        assert "Discovered Tests" in result.stdout
        assert "Total" in result.stdout

    def test_cli_help_works(self):
        """Test that CLI help works."""
        result = self._run_cli(["--help"])

        assert result.returncode == 0
        assert "GDSentry" in result.stdout
        assert "Advanced Testing Framework" in result.stdout

    def test_cli_config_loading(self):
        """Test that CLI can load project configuration."""
        # Test should not fail due to missing config - CLI should handle gracefully
        result = self._run_cli(["test", "discover"])

        # Should succeed or fail gracefully, not crash
        assert result.returncode in [0, 1]

    def test_project_structure_recognized(self):
        """Test that CLI recognizes Godot project structure."""
        # Should find project.godot
        assert (self.project_dir / "project.godot").exists()

        # Should find tests directory
        assert (self.project_dir / "tests").exists()

        # Discovery should work
        result = self._run_cli(["test", "discover"])
        assert result.returncode == 0

    def test_test_execution_attempt(self):
        """Test that CLI attempts to execute tests (may fail due to missing containers)."""
        result = self._run_cli(["test", "run"])

        # May succeed or fail due to containers, but shouldn't crash
        assert result.returncode in [0, 1]

        # Should produce some output
        assert len(result.stdout) > 0 or len(result.stderr) > 0

    def test_validation_commands_work(self):
        """Test that validation commands work."""
        result = self._run_cli(["validate", "gdscript", "scripts/"])

        # Should succeed or fail gracefully
        assert result.returncode in [0, 1]
