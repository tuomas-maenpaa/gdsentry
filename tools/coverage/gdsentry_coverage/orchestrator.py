"""
Coverage orchestrator - coordinates full coverage workflow

Adapted for hybrid B+C1 layout: godot --headless --script core/test_runner.gd
(no Typer CLI, no Podman/container deps, no gdsentry.toml platform).
"""

import html
import json
import os
import signal
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional

from gdsentry_coverage.config import CoverageConfig, ProjectInstrumentResult
from gdsentry_coverage.instrumenter import Instrumenter


@dataclass
class CoverageRunResult:
    """Result of a complete coverage run"""

    success: bool
    test_exit_code: int
    coverage_percent: float = 0.0
    covered_lines: int = 0
    total_lines: int = 0
    html_report_path: Optional[Path] = None
    coverage_data_path: Optional[Path] = None
    errors: List[str] = None

    def __post_init__(self):
        if self.errors is None:
            self.errors = []


def detect_framework_root(start: Optional[Path] = None) -> Path:
    """
    Locate GDSentry framework root (directory containing core/test_runner.gd).

    Searches: start, start/.gdsentry, cwd, cwd/.gdsentry, parents.
    """
    start = (start or Path.cwd()).resolve()
    candidates = [
        start,
        start / ".gdsentry",
        Path.cwd(),
        Path.cwd() / ".gdsentry",
    ]
    # Walk parents from start
    for parent in [start, *start.parents]:
        candidates.append(parent)
        candidates.append(parent / ".gdsentry")

    seen = set()
    for candidate in candidates:
        candidate = candidate.resolve()
        if candidate in seen:
            continue
        seen.add(candidate)
        marker = candidate / "core" / "test_runner.gd"
        if marker.is_file():
            return candidate

    raise FileNotFoundError(
        "Could not find framework root (core/test_runner.gd). "
        "Pass --framework-root or run from a GDSentry checkout / nested .gdsentry."
    )


class CoverageOrchestrator:
    """Orchestrates the complete coverage workflow"""

    def __init__(self, config: CoverageConfig):
        """
        Initialize orchestrator.

        Args:
            config: Coverage configuration
        """
        self.config = config
        self.instrumenter = Instrumenter(config)
        self._godot_process: Optional[subprocess.Popen] = None
        self._cleanup_performed = False
        self._interrupted = False

        # Register signal handlers
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)

    def run_coverage(self, test_args: Optional[List[str]] = None) -> CoverageRunResult:
        """
        Run complete coverage workflow.

        Args:
            test_args: Additional arguments to pass to test runner

        Returns:
            CoverageRunResult with success status and statistics
        """
        test_args = test_args or []
        errors = []

        try:
            self._create_directory_structure()

            print("Instrumenting source files...")
            instrument_result = self._instrument_files()

            if not instrument_result.success:
                return CoverageRunResult(
                    success=False,
                    test_exit_code=2,
                    errors=[f"Instrumentation failed: {instrument_result.files_failed} files"],
                )

            if instrument_result.files_failed > 0:
                errors.append(
                    f"Warning: {instrument_result.files_failed} files could not be instrumented"
                )

            print(
                f"   Instrumented {instrument_result.files_instrumented} files "
                f"({instrument_result.instrumented_lines} lines)"
            )

            tracker_created = self._create_tracker_singleton()
            if not tracker_created:
                return CoverageRunResult(
                    success=False,
                    test_exit_code=2,
                    errors=["Failed to create coverage tracker singleton"],
                )

            # Prepare project.godot with __coverage_tracker autoload (instrumented tree)
            if self.config.use_instrumented_project:
                self._prepare_instrumented_project()

            print("Running tests with coverage...")
            exit_code = self._launch_godot(test_args)

            if self._interrupted:
                return CoverageRunResult(
                    success=False,
                    test_exit_code=130,
                    errors=["Interrupted by user"],
                )

            coverage_data_path = self.config.output_dir / "coverage_data.json"
            html_report_path = self.config.output_dir / "html" / "index.html"

            if not coverage_data_path.exists():
                if exit_code == 2:
                    errors.append("Coverage system reported failure")
                else:
                    errors.append(
                        "Coverage data not generated (Godot may have crashed, "
                        "or tracker autoload was not loaded)"
                    )

                return CoverageRunResult(
                    success=False,
                    test_exit_code=exit_code,
                    errors=errors,
                )

            try:
                coverage_stats = self._read_coverage_data(coverage_data_path)
            except json.JSONDecodeError as e:
                errors.append(f"Coverage data corrupt: {e}")
                return CoverageRunResult(
                    success=False,
                    test_exit_code=exit_code,
                    errors=errors,
                )

            self._display_summary(coverage_stats)

            # Thin Python HTML (GDScript reporter is shipped but not auto-invoked here)
            try:
                self._write_minimal_html(coverage_stats)
            except Exception as e:
                errors.append(f"HTML report generation failed: {e}")
                html_report_path = None

            if html_report_path and not html_report_path.exists():
                errors.append("HTML report generation failed")
                html_report_path = None

            return CoverageRunResult(
                success=True,
                test_exit_code=exit_code,
                coverage_percent=coverage_stats.get("total_percent", 0.0),
                covered_lines=coverage_stats.get("total_covered", 0),
                total_lines=coverage_stats.get("total_lines", 0),
                html_report_path=html_report_path,
                coverage_data_path=coverage_data_path,
                errors=errors if errors else None,
            )

        finally:
            self.cleanup()

    def cleanup(self) -> None:
        """Cleanup temporary instrumented files (preserves reports and coverage_data.json)."""
        if self._cleanup_performed:
            return

        self._cleanup_performed = True

        if self._godot_process and self._godot_process.poll() is None:
            try:
                self._godot_process.terminate()
                self._godot_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self._godot_process.kill()
            except Exception:
                pass

        instrumented_dir = self.config.output_dir / "instrumented"
        if instrumented_dir.exists():
            try:
                shutil.rmtree(instrumented_dir)
                print("Cleaned up instrumented files")
            except Exception as e:
                print(f"Warning: Failed to cleanup instrumented files: {e}")

    def _create_directory_structure(self) -> None:
        """Create required directory structure"""
        self.config.output_dir.mkdir(parents=True, exist_ok=True)
        (self.config.output_dir / "instrumented").mkdir(exist_ok=True)
        (self.config.output_dir / "html").mkdir(exist_ok=True)

    def _instrument_files(self) -> ProjectInstrumentResult:
        """Instrument source files into output_dir/instrumented."""
        output_root = self.config.output_dir / "instrumented"
        return self.instrumenter.instrument_project(
            source_root=self.config.source_root,
            output_root=output_root,
        )

    def _create_tracker_singleton(self) -> bool:
        """Create coverage tracker singleton under instrumented/."""
        output_dir = self.config.output_dir / "instrumented"
        try:
            return self.instrumenter.create_tracker_singleton(output_dir)
        except Exception as e:
            print(f"Error: Failed to create tracker: {e}")
            return False

    def _prepare_instrumented_project(self) -> None:
        """
        Copy non-GD essentials into instrumented/ and add tracker autoload.

        Stubbed lightly: copies project.godot (modified) and does not full copytree
        of the whole framework (that would be heavy). Prefer running with
        --path pointing at a prepared project, or disable use_instrumented_project
        and rely on an existing autoload in the live project.
        """
        instrumented = self.config.output_dir / "instrumented"
        source = self.config.source_root
        original_project = source / "project.godot"
        # Also check parent if source is a subdirectory
        if not original_project.exists() and (source.parent / "project.godot").exists():
            original_project = source.parent / "project.godot"

        out_project = instrumented / "project.godot"
        ok = self.instrumenter.modify_project_config(original_project, out_project)
        if not ok:
            print("Warning: could not write instrumented project.godot")

        # Copy tracker template file name already written; ensure gdscript assets available
        # (optional — analyzer/reporter are for Godot-side use, not required for launch)

    def _resolve_framework_root(self) -> Path:
        if self.config.framework_root:
            root = Path(self.config.framework_root).resolve()
            marker = root / "core" / "test_runner.gd"
            if not marker.is_file():
                raise FileNotFoundError(f"No core/test_runner.gd under {root}")
            return root
        return detect_framework_root(self.config.source_root)

    def _launch_godot(self, test_args: List[str]) -> int:
        """
        Launch Godot with hybrid B+C1 runner:

            godot --path <project> --headless --script <framework>/core/test_runner.gd …
        """
        godot_path = self.config.godot_path
        if not self._check_godot_exists(godot_path):
            print(f"Error: Godot not found at '{godot_path}'")
            print("Install Godot 4.x: https://godotengine.org/download")
            print("Or specify path with --godot-path")
            return 2

        try:
            framework_root = self._resolve_framework_root()
        except FileNotFoundError as e:
            print(f"Error: {e}")
            return 2

        runner_script = framework_root / self.config.test_runner_script
        if not runner_script.is_file():
            print(f"Error: test runner not found: {runner_script}")
            return 2

        if self.config.use_instrumented_project:
            project_path = self.config.output_dir / "instrumented"
        else:
            project_path = Path(
                self.config.project_path or self.config.source_root
            ).resolve()

        # Prefer absolute script path so --path can be the instrumented tree
        # while still loading the real framework runner from framework_root.
        cmd = [
            godot_path,
            "--path",
            str(project_path),
            "--headless",
            "--script",
            str(runner_script),
        ]

        if test_args:
            cmd.extend(test_args)

        env = os.environ.copy()
        env["GDSENTRY_COVERAGE"] = "1"
        # Trailing slash matches tracker default style
        out = str(self.config.output_dir.absolute())
        if not out.endswith(os.sep):
            out = out + os.sep
        env["GDSENTRY_COVERAGE_OUTPUT"] = out
        env["GDSENTRY_ORIGINAL_PATH"] = str(self.config.source_root.absolute())
        env["GDSENTRY_FRAMEWORK_ROOT"] = str(framework_root)

        print(f"   Command: {' '.join(cmd)}")

        try:
            self._godot_process = subprocess.Popen(
                cmd,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            if self._godot_process.stdout:
                for line in self._godot_process.stdout:
                    print(line, end="")

            return self._godot_process.wait(timeout=self.config.timeout)

        except FileNotFoundError:
            print(f"Error: Godot not found: {godot_path}")
            return 2
        except subprocess.TimeoutExpired:
            print(f"\nError: Test execution timeout after {self.config.timeout}s")
            if self._godot_process:
                self._godot_process.kill()
            return 1
        except Exception as e:
            print(f"Error: Godot execution failed: {e}")
            return 127

    def _check_godot_exists(self, godot_path: str) -> bool:
        """Check if Godot executable exists."""
        try:
            result = subprocess.run(
                [godot_path, "--version"],
                capture_output=True,
                timeout=5,
            )
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

    def _analyze_raw_coverage(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyze tracker JSON into summary stats (Python stand-in for GDScript analyzer).

        Tracker format: { "format_version", "timestamp", "files": { path: { line: hits } } }
        """
        files_raw = data.get("files", data)
        if not isinstance(files_raw, dict):
            return {
                "total_covered": 0,
                "total_lines": 0,
                "total_percent": 0.0,
                "files": [],
            }

        # Already-analyzed shape?
        if "total_percent" in data and "files" in data and isinstance(data["files"], list):
            return data

        total_covered = 0
        total_lines = 0
        file_summaries = []

        for file_path, line_data in files_raw.items():
            if not isinstance(line_data, dict):
                continue
            covered = 0
            missed = []
            for line_key, hits in line_data.items():
                try:
                    line_num = int(line_key)
                except (TypeError, ValueError):
                    continue
                hit_count = int(hits) if hits is not None else 0
                if hit_count > 0:
                    covered += 1
                else:
                    missed.append(line_num)
            file_total = len(line_data)
            percent = (covered / file_total * 100.0) if file_total else 0.0
            total_covered += covered
            total_lines += file_total
            file_summaries.append(
                {
                    "file": file_path,
                    "covered": covered,
                    "total": file_total,
                    "percent": percent,
                    "missed_lines": missed,
                }
            )

        total_percent = (total_covered / total_lines * 100.0) if total_lines else 0.0
        return {
            "total_covered": total_covered,
            "total_lines": total_lines,
            "total_percent": total_percent,
            "files": file_summaries,
        }

    def _read_coverage_data(self, coverage_data_path: Path) -> Dict[str, Any]:
        """Read and analyze coverage_data.json."""
        with open(coverage_data_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return self._analyze_raw_coverage(data)

    def _write_minimal_html(self, coverage_stats: Dict[str, Any]) -> Path:
        """Write a minimal HTML summary (stdlib only; not the full GDScript reporter)."""
        html_dir = self.config.output_dir / "html"
        html_dir.mkdir(parents=True, exist_ok=True)
        index = html_dir / "index.html"

        total_percent = coverage_stats.get("total_percent", 0.0)
        total_covered = coverage_stats.get("total_covered", 0)
        total_lines = coverage_stats.get("total_lines", 0)
        files = coverage_stats.get("files", []) or []

        rows = []
        for file_info in files:
            name = html.escape(str(file_info.get("file", "unknown")))
            pct = float(file_info.get("percent", 0.0))
            cov = int(file_info.get("covered", 0))
            tot = int(file_info.get("total", 0))
            rows.append(
                f"<tr><td>{name}</td><td>{pct:.1f}%</td><td>{cov}/{tot}</td></tr>"
            )

        body = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>GDSentry Coverage</title>
  <style>
    body {{ font-family: system-ui, sans-serif; margin: 2rem; }}
    table {{ border-collapse: collapse; width: 100%; max-width: 960px; }}
    th, td {{ border: 1px solid #ccc; padding: 0.4rem 0.6rem; text-align: left; }}
    th {{ background: #f0f0f0; }}
  </style>
</head>
<body>
  <h1>Coverage Report</h1>
  <p>Total: <strong>{total_percent:.1f}%</strong> ({total_covered}/{total_lines} lines)</p>
  <p><em>Thin Python summary — full GDScript reporter lives in tools/coverage/gdscript/</em></p>
  <table>
    <thead><tr><th>File</th><th>%</th><th>Lines</th></tr></thead>
    <tbody>
      {"".join(rows) if rows else "<tr><td colspan='3'>No file data</td></tr>"}
    </tbody>
  </table>
</body>
</html>
"""
        index.write_text(body, encoding="utf-8")
        return index

    def _display_summary(self, coverage_stats: Dict[str, Any]) -> None:
        """Display coverage summary in terminal."""
        total_percent = coverage_stats.get("total_percent", 0.0)
        total_covered = coverage_stats.get("total_covered", 0)
        total_lines = coverage_stats.get("total_lines", 0)

        print("\n" + "=" * 60)
        print("Coverage Report")
        print("=" * 60)
        print(f"  Coverage: {total_percent:.1f}% ({total_covered}/{total_lines} lines)")

        files = coverage_stats.get("files", [])
        if files and len(files) <= 10:
            print("\n  By File:")
            for file_info in files:
                file_name = file_info.get("file", "unknown")
                file_percent = file_info.get("percent", 0.0)
                file_covered = file_info.get("covered", 0)
                file_total = file_info.get("total", 0)
                print(
                    f"    {file_name:40s} {file_percent:5.1f}% "
                    f"({file_covered}/{file_total})"
                )
        elif files:
            print(f"\n  {len(files)} files covered")

        html_path = self.config.output_dir / "html" / "index.html"
        if html_path.exists():
            print(f"\n  HTML Report: {html_path}")

        print("=" * 60 + "\n")

    def _signal_handler(self, signum, frame):
        """Handle interrupt signals (Ctrl+C, SIGTERM)."""
        if not self._interrupted:
            self._interrupted = True
            print("\n\nInterrupted by user. Cleaning up...")

            if self._godot_process and self._godot_process.poll() is None:
                self._godot_process.terminate()
                try:
                    self._godot_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self._godot_process.kill()

            self.cleanup()
            sys.exit(130)
