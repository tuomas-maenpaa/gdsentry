"""Tests for CLI docs commands."""

from pathlib import Path
from unittest.mock import Mock, patch

import pytest
from typer.testing import CliRunner

from gdsentry.cli.app import app

runner = CliRunner()


class TestDocsCommands:
    """Test docs command group."""

    def test_docs_help(self):
        """Test docs command help."""
        result = runner.invoke(app, ["docs", "--help"])
        assert result.exit_code == 0
        assert "docs" in result.stdout.lower()
        assert "Documentation building and serving" in result.stdout

    def test_build_docs_help(self):
        """Test docs build command help."""
        result = runner.invoke(app, ["docs", "build", "--help"])
        assert result.exit_code == 0
        assert "build" in result.stdout.lower()

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_build_docs_html_success(self, mock_builder_class, mock_load_config):
        """Test building HTML documentation successfully."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_html.return_value = None
        mock_builder.get_html_dir.return_value = Path("/fake/project/docs/build/html")
        mock_builder.get_index_file.return_value = Path("/fake/project/docs/build/html/index.html")

        result = runner.invoke(app, ["docs", "build"])

        assert result.exit_code == 0
        assert "HTML documentation built successfully" in result.stdout
        assert "index.html" in result.stdout
        mock_builder.build_html.assert_called_once_with(clean=False)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_build_docs_html_with_clean(self, mock_builder_class, mock_load_config):
        """Test building HTML documentation with clean option."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        result = runner.invoke(app, ["docs", "build", "--clean"])

        assert result.exit_code == 0
        mock_builder.build_html.assert_called_once_with(clean=True)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_build_docs_pdf_success(self, mock_builder_class, mock_load_config):
        """Test building PDF documentation successfully."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_pdf.return_value = None
        mock_builder.build_dir = Path("/fake/project/docs/build")

        result = runner.invoke(app, ["docs", "build", "--format", "pdf"])

        assert result.exit_code == 0
        assert "PDF documentation built successfully" in result.stdout
        assert "/latex" in result.stdout  # Check that latex directory path is displayed
        mock_builder.build_pdf.assert_called_once_with(clean=False)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_build_docs_invalid_format(self, mock_builder_class, mock_load_config):
        """Test building documentation with invalid format."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        result = runner.invoke(app, ["docs", "build", "--format", "invalid"])

        assert result.exit_code == 1
        assert "Unknown format: invalid" in result.stdout

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_build_docs_build_error(self, mock_builder_class, mock_load_config):
        """Test building documentation with build error."""
        from gdsentry.docs.builder import DocsBuildError

        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.build_html.side_effect = DocsBuildError("Sphinx build failed")

        result = runner.invoke(app, ["docs", "build"])

        assert result.exit_code == 1
        assert "Documentation build failed: Sphinx build failed" in result.stdout

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    @patch("gdsentry.cli.commands.docs.DocServer")
    def test_serve_docs_success(self, mock_server_class, mock_builder_class, mock_load_config):
        """Test serving documentation successfully."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_server = Mock()
        mock_server_class.return_value = mock_server
        mock_server.serve.return_value = None

        result = runner.invoke(app, ["docs", "serve"])

        assert result.exit_code == 0
        assert "Starting documentation server on port 8000" in result.stdout
        mock_server.serve.assert_called_once_with(watch=True, open_browser=True)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    @patch("gdsentry.cli.commands.docs.DocServer")
    def test_serve_docs_custom_port(self, mock_server_class, mock_builder_class, mock_load_config):
        """Test serving documentation with custom port."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_server = Mock()
        mock_server_class.return_value = mock_server

        result = runner.invoke(app, ["docs", "serve", "--port", "9000"])

        assert result.exit_code == 0
        mock_server_class.assert_called_once_with(mock_builder, port=9000)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    @patch("gdsentry.cli.commands.docs.DocServer")
    def test_serve_docs_no_watch(self, mock_server_class, mock_builder_class, mock_load_config):
        """Test serving documentation without file watching."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_server = Mock()
        mock_server_class.return_value = mock_server

        result = runner.invoke(app, ["docs", "serve", "--no-watch"])

        assert result.exit_code == 0
        mock_server.serve.assert_called_once_with(watch=False, open_browser=True)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    @patch("gdsentry.cli.commands.docs.DocServer")
    def test_serve_docs_no_browser(self, mock_server_class, mock_builder_class, mock_load_config):
        """Test serving documentation without opening browser."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_server = Mock()
        mock_server_class.return_value = mock_server

        result = runner.invoke(app, ["docs", "serve", "--no-browser"])

        assert result.exit_code == 0
        mock_server.serve.assert_called_once_with(watch=True, open_browser=False)

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    @patch("gdsentry.cli.commands.docs.DocServer")
    def test_serve_docs_keyboard_interrupt(self, mock_server_class, mock_builder_class, mock_load_config):
        """Test serving documentation with keyboard interrupt."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_server = Mock()
        mock_server_class.return_value = mock_server
        mock_server.serve.side_effect = KeyboardInterrupt()

        result = runner.invoke(app, ["docs", "serve"])

        assert result.exit_code == 0
        assert "Server stopped" in result.stdout

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    @patch("gdsentry.cli.commands.docs.DocServer")
    def test_serve_docs_error(self, mock_server_class, mock_builder_class, mock_load_config):
        """Test serving documentation with error."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder

        mock_server = Mock()
        mock_server_class.return_value = mock_server
        mock_server.serve.side_effect = Exception("Server startup failed")

        result = runner.invoke(app, ["docs", "serve"])

        assert result.exit_code == 1
        assert "Server error: Server startup failed" in result.stdout

    def test_serve_help(self):
        """Test docs serve command help."""
        result = runner.invoke(app, ["docs", "serve", "--help"])
        assert result.exit_code == 0
        assert "serve" in result.stdout.lower()

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_check_links_success(self, mock_builder_class, mock_load_config):
        """Test link checking with no broken links."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.linkcheck.return_value = []

        result = runner.invoke(app, ["docs", "linkcheck"])

        assert result.exit_code == 0
        assert "All links are valid! ✓" in result.stdout

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_check_links_broken_found(self, mock_builder_class, mock_load_config):
        """Test link checking with broken links found."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.linkcheck.return_value = [
            "https://broken-link-1.com",
            "https://broken-link-2.com",
            "https://broken-link-3.com"
        ]
        mock_builder.build_dir = Path("/fake/project/docs/build")

        result = runner.invoke(app, ["docs", "linkcheck"])

        assert result.exit_code == 1
        assert "Found 3 broken links" in result.stdout
        assert "broken-link-1.com" in result.stdout

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_check_links_build_error(self, mock_builder_class, mock_load_config):
        """Test link checking with build error."""
        from gdsentry.docs.builder import DocsBuildError

        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.linkcheck.side_effect = DocsBuildError("Link check failed")

        result = runner.invoke(app, ["docs", "linkcheck"])

        assert result.exit_code == 1
        assert "Link check failed: Link check failed" in result.stdout

    def test_linkcheck_help(self):
        """Test docs linkcheck command help."""
        result = runner.invoke(app, ["docs", "linkcheck", "--help"])
        assert result.exit_code == 0
        assert "linkcheck" in result.stdout.lower()

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_clean_docs_success(self, mock_builder_class, mock_load_config):
        """Test cleaning documentation build directory."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.clean.return_value = None
        mock_builder.build_dir = Path("/fake/project/docs/build")

        result = runner.invoke(app, ["docs", "clean"])

        assert result.exit_code == 0
        assert "Build directory cleaned" in result.stdout
        assert "/fake/project/docs/build" in result.stdout
        mock_builder.clean.assert_called_once()

    @patch("gdsentry.cli.commands.docs.load_config")
    @patch("gdsentry.cli.commands.docs.DocBuilder")
    def test_clean_docs_error(self, mock_builder_class, mock_load_config):
        """Test cleaning documentation with error."""
        mock_config = Mock()
        mock_config.project.project_root = Path("/fake/project")
        mock_load_config.return_value = mock_config

        mock_builder = Mock()
        mock_builder_class.return_value = mock_builder
        mock_builder.clean.side_effect = Exception("Clean failed")

        result = runner.invoke(app, ["docs", "clean"])

        assert result.exit_code == 1
        assert "Clean failed: Clean failed" in result.stdout

    def test_clean_help(self):
        """Test docs clean command help."""
        result = runner.invoke(app, ["docs", "clean", "--help"])
        assert result.exit_code == 0
        assert "clean" in result.stdout.lower()
