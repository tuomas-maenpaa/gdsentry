"""Documentation building with Sphinx."""

import shutil
import subprocess
from pathlib import Path

from gdsentry.core.exceptions import GDSentryError


class DocsBuildError(GDSentryError):
    """Raised when documentation build fails."""

    pass


class DocBuilder:
    """
    Builds documentation with Sphinx.

    Provides:
    - HTML documentation building
    - PDF documentation building (if LaTeX installed)
    - Link checking
    - Clean builds
    """

    def __init__(self, gdsentry_root: Path):
        """
        Initialize doc builder.

        Args:
            gdsentry_root: GDSentry framework root directory
        """
        self.gdsentry_root = gdsentry_root
        self.docs_dir = gdsentry_root / "docs"
        self.source_dir = self.docs_dir / "source"
        self.build_dir = self.docs_dir / "build"

    def clean(self) -> None:
        """Clean build directory."""
        if self.build_dir.exists():
            shutil.rmtree(self.build_dir)
            self.build_dir.mkdir(parents=True)

    def build_html(self, clean: bool = False) -> None:
        """
        Build HTML documentation.

        Args:
            clean: Whether to clean before building

        Raises:
            DocsBuildError: If build fails
        """
        if clean:
            self.clean()

        try:
            result = subprocess.run(
                ["sphinx-build", "-b", "html", str(self.source_dir), str(self.build_dir / "html")],
                cwd=self.docs_dir,
                capture_output=True,
                text=True,
                timeout=300,
            )

            if result.returncode != 0:
                raise DocsBuildError(
                    f"HTML build failed:\n{result.stderr}"
                )

        except subprocess.TimeoutExpired:
            raise DocsBuildError("HTML build timed out after 5 minutes")
        except Exception as e:
            raise DocsBuildError(f"HTML build failed: {e}")

    def build_pdf(self, clean: bool = False) -> None:
        """
        Build PDF documentation.

        Args:
            clean: Whether to clean before building

        Raises:
            DocsBuildError: If build fails
        """
        if clean:
            self.clean()

        try:
            result = subprocess.run(
                ["sphinx-build", "-b", "latex", str(self.source_dir), str(self.build_dir / "latex")],
                cwd=self.docs_dir,
                capture_output=True,
                text=True,
                timeout=300,
            )

            if result.returncode != 0:
                raise DocsBuildError(
                    f"LaTeX build failed:\n{result.stderr}"
                )

            # Build PDF from LaTeX
            latex_dir = self.build_dir / "latex"
            result = subprocess.run(
                ["make", "all-pdf"],
                cwd=latex_dir,
                capture_output=True,
                text=True,
                timeout=600,
            )

            if result.returncode != 0:
                raise DocsBuildError(
                    f"PDF build failed:\n{result.stderr}"
                )

        except subprocess.TimeoutExpired:
            raise DocsBuildError("PDF build timed out")
        except Exception as e:
            raise DocsBuildError(f"PDF build failed: {e}")

    def linkcheck(self) -> list[str]:
        """
        Check documentation links.

        Returns:
            List of broken links

        Raises:
            DocsBuildError: If linkcheck fails
        """
        try:
            result = subprocess.run(
                ["sphinx-build", "-b", "linkcheck", str(self.source_dir), str(self.build_dir / "linkcheck")],
                cwd=self.docs_dir,
                capture_output=True,
                text=True,
                timeout=600,
            )

            # Parse output for broken links
            broken_links = []
            output_file = self.build_dir / "linkcheck" / "output.txt"

            if output_file.exists():
                content = output_file.read_text()
                for line in content.splitlines():
                    if "broken" in line.lower():
                        broken_links.append(line.strip())

            return broken_links

        except subprocess.TimeoutExpired:
            raise DocsBuildError("Link check timed out after 10 minutes")
        except Exception as e:
            raise DocsBuildError(f"Link check failed: {e}")

    def get_html_dir(self) -> Path:
        """Get HTML output directory."""
        return self.build_dir / "html"

    def get_index_file(self) -> Path:
        """Get index.html path."""
        return self.get_html_dir() / "index.html"

