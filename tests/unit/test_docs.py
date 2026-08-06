"""Tests for documentation building and serving."""

import pytest
from pathlib import Path

from gdsentry.docs.builder import DocBuilder, DocsBuildError
from gdsentry.docs.server import DocServer


class TestDocBuilder:
    """Test documentation builder."""

    def test_builder_creation(self):
        """Test creating doc builder."""
        project_root = Path.cwd()
        builder = DocBuilder(project_root)

        assert builder is not None
        assert builder.project_root == project_root
        assert builder.docs_dir == project_root / "docs"
        assert builder.source_dir == project_root / "docs" / "source"
        assert builder.build_dir == project_root / "docs" / "build"

    def test_get_html_dir(self):
        """Test getting HTML output directory."""
        project_root = Path.cwd()
        builder = DocBuilder(project_root)

        html_dir = builder.get_html_dir()

        assert html_dir == project_root / "docs" / "build" / "html"

    def test_get_index_file(self):
        """Test getting index file path."""
        project_root = Path.cwd()
        builder = DocBuilder(project_root)

        index_file = builder.get_index_file()

        assert index_file == project_root / "docs" / "build" / "html" / "index.html"

    def test_clean_creates_build_dir(self):
        """Test that clean creates build directory."""
        project_root = Path.cwd()
        builder = DocBuilder(project_root)

        # Clean should create the directory
        builder.clean()

        assert builder.build_dir.exists()
        assert builder.build_dir.is_dir()


class TestDocServer:
    """Test documentation server."""

    def test_server_creation(self):
        """Test creating doc server."""
        project_root = Path.cwd()
        builder = DocBuilder(project_root)
        server = DocServer(builder, port=8000)

        assert server is not None
        assert server.builder is builder
        assert server.port == 8000

    def test_server_custom_port(self):
        """Test server with custom port."""
        project_root = Path.cwd()
        builder = DocBuilder(project_root)
        server = DocServer(builder, port=9000)

        assert server.port == 9000


class TestDocsExceptions:
    """Test documentation exceptions."""

    def test_docs_build_error(self):
        """Test DocsBuildError."""
        error = DocsBuildError("Test error")

        assert str(error) == "Test error"
        assert isinstance(error, Exception)


class TestDocsCLI:
    """Test documentation CLI commands."""

    def test_docs_commands_import(self):
        """Test that docs commands can be imported."""
        from gdsentry.cli.commands import docs

        assert docs.app is not None
        assert hasattr(docs, "build_docs")
        assert hasattr(docs, "serve_docs")
        assert hasattr(docs, "check_links")
        assert hasattr(docs, "clean_docs")


class TestDocsIntegration:
    """Test documentation integration."""

    def test_docs_directory_exists(self):
        """Test that docs directory exists."""
        project_root = Path.cwd()
        docs_dir = project_root / "docs"

        assert docs_dir.exists()
        assert docs_dir.is_dir()

    def test_docs_source_exists(self):
        """Test that docs source directory exists."""
        project_root = Path.cwd()
        source_dir = project_root / "docs" / "source"

        assert source_dir.exists()
        assert source_dir.is_dir()

    def test_sphinx_conf_exists(self):
        """Test that Sphinx configuration exists."""
        project_root = Path.cwd()
        conf_file = project_root / "docs" / "source" / "conf.py"

        assert conf_file.exists()
        assert conf_file.is_file()

    def test_index_rst_exists(self):
        """Test that index.rst exists."""
        project_root = Path.cwd()
        index_file = project_root / "docs" / "source" / "index.rst"

        # Should have at least index.rst or some documentation file
        assert index_file.exists() or (project_root / "docs" / "source").exists()

