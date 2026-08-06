"""Tests for development tools functionality."""

import pytest
from pathlib import Path
import tempfile
import shutil

from gdsentry.templates.init import ProjectInitializer, InitializationError
from gdsentry.templates.generator import TemplateGenerator, TemplateError


class TestProjectInitializer:
    """Test project initialization."""

    def test_initializer_creation(self):
        """Test creating project initializer."""
        project_root = Path.cwd()
        initializer = ProjectInitializer(project_root)

        assert initializer is not None
        assert initializer.project_root == project_root

    def test_initialize_creates_config(self):
        """Test that initialize creates configuration file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            initializer = ProjectInitializer(project_root)

            initializer.initialize("test_project", "4.2.2-stable", interactive=False)

            config_file = project_root / "gdsentry.toml"
            assert config_file.exists()

            content = config_file.read_text()
            assert "test_project" in content
            assert "4.2.2-stable" in content

    def test_initialize_creates_directories(self):
        """Test that initialize creates test directories."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            initializer = ProjectInitializer(project_root)

            initializer.initialize("test_project", "4.2.2-stable", interactive=False)

            assert (project_root / "tests").exists()
            assert (project_root / "tests" / "unit").exists()
            assert (project_root / "tests" / "integration").exists()
            assert (project_root / "tests" / "performance").exists()

    def test_initialize_creates_example_test(self):
        """Test that initialize creates example test."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            initializer = ProjectInitializer(project_root)

            initializer.initialize("test_project", "4.2.2-stable", interactive=False)

            example_test = project_root / "tests" / "example_test.gd"
            assert example_test.exists()

            content = example_test.read_text()
            assert "extends GDTest" in content
            assert "ExampleTest" in content

    def test_initialize_creates_readme(self):
        """Test that initialize creates README."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            initializer = ProjectInitializer(project_root)

            initializer.initialize("test_project", "4.2.2-stable", interactive=False)

            readme = project_root / "GDSENTRY_README.md"
            assert readme.exists()

            content = readme.read_text()
            assert "test_project" in content
            assert "GDSentry" in content

    def test_initialize_fails_if_config_exists(self):
        """Test that initialize fails if config already exists."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            initializer = ProjectInitializer(project_root)

            # Create first time
            initializer.initialize("test_project", "4.2.2-stable", interactive=False)

            # Try to create again - should fail
            with pytest.raises(InitializationError):
                initializer.initialize("test_project", "4.2.2-stable", interactive=False)

    def test_get_created_files(self):
        """Test getting list of created files."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            initializer = ProjectInitializer(project_root)

            initializer.initialize("test_project", "4.2.2-stable", interactive=False)

            created_files = initializer.get_created_files()

            assert len(created_files) == 3
            assert any("gdsentry.toml" in str(f) for f in created_files)
            assert any("GDSENTRY_README.md" in str(f) for f in created_files)
            assert any("example_test.gd" in str(f) for f in created_files)


class TestTemplateGenerator:
    """Test template generation."""

    def test_generator_creation(self):
        """Test creating template generator."""
        project_root = Path.cwd()
        generator = TemplateGenerator(project_root)

        assert generator is not None
        assert generator.project_root == project_root

    def test_generate_unit_test(self):
        """Test generating unit test."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            generator = TemplateGenerator(project_root)

            test_file = generator.generate_test(
                name="player_movement",
                test_type="unit",
            )

            assert test_file.exists()
            assert test_file.name == "player_movement_test.gd"

            content = test_file.read_text()
            assert "PlayerMovementTest" in content
            assert "extends GDTest" in content
            assert "unit" in content

    def test_generate_integration_test(self):
        """Test generating integration test."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            generator = TemplateGenerator(project_root)

            test_file = generator.generate_test(
                name="game_system",
                test_type="integration",
            )

            assert test_file.exists()
            content = test_file.read_text()
            assert "integration" in content

    def test_generate_performance_test(self):
        """Test generating performance test."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            generator = TemplateGenerator(project_root)

            test_file = generator.generate_test(
                name="pathfinding",
                test_type="performance",
            )

            assert test_file.exists()
            content = test_file.read_text()
            assert "performance" in content
            assert "benchmark" in content

    def test_generate_scene_test(self):
        """Test generating scene test."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            generator = TemplateGenerator(project_root)

            test_file = generator.generate_test(
                name="main_menu",
                test_type="scene",
            )

            assert test_file.exists()
            content = test_file.read_text()
            assert "SceneTreeTest" in content
            assert "scene" in content

    def test_generate_with_custom_output_dir(self):
        """Test generating test with custom output directory."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            output_dir = project_root / "custom" / "tests"
            generator = TemplateGenerator(project_root)

            test_file = generator.generate_test(
                name="custom_test",
                test_type="unit",
                output_dir=output_dir,
            )

            assert test_file.exists()
            assert test_file.parent == output_dir

    def test_generate_fails_if_file_exists(self):
        """Test that generation fails if file already exists."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            generator = TemplateGenerator(project_root)

            # Generate first time
            generator.generate_test(name="existing", test_type="unit")

            # Try to generate again - should fail
            with pytest.raises(TemplateError):
                generator.generate_test(name="existing", test_type="unit")

    def test_snake_case_to_pascal_case_conversion(self):
        """Test that snake_case names convert to PascalCase."""
        with tempfile.TemporaryDirectory() as tmpdir:
            project_root = Path(tmpdir)
            generator = TemplateGenerator(project_root)

            test_file = generator.generate_test(
                name="my_complex_test_name",
                test_type="unit",
            )

            content = test_file.read_text()
            assert "MyComplexTestNameTest" in content


class TestInitExceptions:
    """Test initialization exceptions."""

    def test_initialization_error(self):
        """Test InitializationError."""
        error = InitializationError("Test error")

        assert str(error) == "Test error"
        assert isinstance(error, Exception)

    def test_template_error(self):
        """Test TemplateError."""
        error = TemplateError("Test error")

        assert str(error) == "Test error"
        assert isinstance(error, Exception)


class TestInitCLI:
    """Test init CLI commands."""

    def test_init_commands_import(self):
        """Test that init commands can be imported."""
        from gdsentry.cli.commands import init

        assert init.app is not None
        assert hasattr(init, "init_project")
        assert hasattr(init, "generate_test")

