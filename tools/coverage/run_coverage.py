#!/usr/bin/env python3
"""
Minimal coverage CLI for GDSentry (argparse, not Typer).

Usage (from tools/coverage, or with PYTHONPATH=tools/coverage):

  python run_coverage.py --source-root ../.. --output-dir .coverage_out
  python -m run_coverage --help

Requires: Python 3.10+ (stdlib only), Godot 4.x on PATH for full runs.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Allow running as a script without installing the package
_HERE = Path(__file__).resolve().parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from gdsentry_coverage.config import CoverageConfig
from gdsentry_coverage.orchestrator import CoverageOrchestrator, detect_framework_root


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Thin GDSentry coverage sidecar: instrument → Godot tests → report",
    )
    p.add_argument(
        "--source-root",
        type=Path,
        default=Path.cwd(),
        help="Root of .gd files to instrument (default: cwd)",
    )
    p.add_argument(
        "--output-dir",
        type=Path,
        default=Path(".coverage_out"),
        help="Coverage output directory (default: .coverage_out)",
    )
    p.add_argument(
        "--framework-root",
        type=Path,
        default=None,
        help="GDSentry root containing core/test_runner.gd (auto-detected if omitted)",
    )
    p.add_argument(
        "--project-path",
        type=Path,
        default=None,
        help="Godot --path when not using instrumented project (default: source-root)",
    )
    p.add_argument(
        "--godot-path",
        default="godot",
        help="Godot executable (default: godot)",
    )
    p.add_argument(
        "--timeout",
        type=int,
        default=600,
        help="Godot timeout seconds (default: 600)",
    )
    p.add_argument(
        "--exclude",
        action="append",
        default=[],
        help="Glob exclude pattern (repeatable)",
    )
    p.add_argument(
        "--pattern",
        action="append",
        default=None,
        help="Glob include pattern relative to source-root (default: **/*.gd)",
    )
    p.add_argument(
        "--no-instrumented-project",
        action="store_true",
        help="Run against --project-path / source-root instead of output/instrumented",
    )
    p.add_argument(
        "--instrument-only",
        action="store_true",
        help="Only instrument + write tracker; do not launch Godot",
    )
    p.add_argument(
        "test_args",
        nargs=argparse.REMAINDER,
        help="Args after -- are passed to core/test_runner.gd (e.g. -- --discover)",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    test_args = list(args.test_args or [])
    if test_args and test_args[0] == "--":
        test_args = test_args[1:]

    patterns = args.pattern if args.pattern else ["**/*.gd"]
    framework_root = args.framework_root
    if framework_root is None:
        try:
            framework_root = detect_framework_root(args.source_root)
        except FileNotFoundError:
            framework_root = None  # orchestrator will error on full run

    config = CoverageConfig(
        source_root=args.source_root.resolve(),
        output_dir=args.output_dir.resolve(),
        file_patterns=patterns,
        exclude_patterns=args.exclude,
        godot_path=args.godot_path,
        timeout=args.timeout,
        framework_root=framework_root,
        project_path=args.project_path.resolve() if args.project_path else None,
        use_instrumented_project=not args.no_instrumented_project,
    )

    orch = CoverageOrchestrator(config)

    if args.instrument_only:
        orch._create_directory_structure()
        result = orch._instrument_files()
        orch._create_tracker_singleton()
        if config.use_instrumented_project:
            orch._prepare_instrumented_project()
        print(
            f"Instrument-only done: {result.files_instrumented} ok, "
            f"{result.files_failed} failed → {config.output_dir / 'instrumented'}"
        )
        return 0 if result.success else 2

    run = orch.run_coverage(test_args=test_args)
    if run.errors:
        for err in run.errors:
            print(f"Note: {err}", file=sys.stderr)
    if not run.success:
        return run.test_exit_code or 2
    # Preserve Godot test exit code when coverage succeeded
    return run.test_exit_code


if __name__ == "__main__":
    raise SystemExit(main())
