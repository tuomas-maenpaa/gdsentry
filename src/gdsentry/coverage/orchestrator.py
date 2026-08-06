"""
Coverage orchestrator - coordinates full coverage workflow
"""

import os
import sys
import json
import signal
import subprocess
import shutil
from pathlib import Path
from typing import List, Optional, Dict, Any
from dataclasses import dataclass

from gdsentry.coverage.config import CoverageConfig, ProjectInstrumentResult
from gdsentry.coverage.instrumenter import Instrumenter
from gdsentry.coverage.exceptions import InstrumentationError


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
        
        Workflow (18 steps from Spike 3):
        1. Parse CLI args
        2. Create directory structure
        3. Instrument files
        4. Create tracker singleton
        5. Modify project.godot (if needed)
        6. Launch Godot
        7. Wait for completion
        8. Read coverage_data.json
        9. Display terminal summary
        10. Cleanup instrumented files
        
        Args:
            test_args: Additional arguments to pass to test runner
            
        Returns:
            CoverageRunResult with success status and statistics
        """
        test_args = test_args or []
        errors = []
        
        try:
            # Step 2: Create directory structure
            self._create_directory_structure()
            
            # Step 3: Instrument files
            print("🔧 Instrumenting source files...")
            instrument_result = self._instrument_files()
            
            if not instrument_result.success:
                # E2: Instrumentation write error (fatal)
                return CoverageRunResult(
                    success=False,
                    test_exit_code=2,
                    errors=[f"Instrumentation failed: {instrument_result.files_failed} files"]
                )
            
            if instrument_result.files_failed > 0:
                # E12: Partial instrumentation (warning, continue)
                errors.append(
                    f"Warning: {instrument_result.files_failed} files could not be instrumented"
                )
            
            print(f"   Instrumented {instrument_result.files_instrumented} files "
                  f"({instrument_result.instrumented_lines} lines)")
            
            # Step 4: Create tracker singleton
            tracker_created = self._create_tracker_singleton()
            if not tracker_created:
                # E5: Tracker initialization fails (fatal)
                return CoverageRunResult(
                    success=False,
                    test_exit_code=2,
                    errors=["Failed to create coverage tracker singleton"]
                )
            
            # Step 5: Modify project.godot (if needed)
            # Note: For now, we'll use environment variables and expect
            # the tracker to be manually added as autoload
            # TODO: Auto-modify project.godot in future iteration
            
            # Step 6: Launch Godot
            print("🎮 Running tests with coverage...")
            exit_code = self._launch_godot(test_args)
            
            # Step 7: Wait for completion (done by _launch_godot)
            
            # Handle exit code
            if self._interrupted:
                # E10: User interrupted
                return CoverageRunResult(
                    success=False,
                    test_exit_code=130,
                    errors=["Interrupted by user"]
                )
            
            # Step 8: Read coverage_data.json
            coverage_data_path = self.config.output_dir / "coverage_data.json"
            html_report_path = self.config.output_dir / "html" / "index.html"
            
            if not coverage_data_path.exists():
                # E8: Coverage data missing
                if exit_code == 2:
                    errors.append("Coverage system reported failure")
                else:
                    errors.append("Coverage data not generated (Godot may have crashed)")
                
                return CoverageRunResult(
                    success=False,
                    test_exit_code=exit_code,
                    errors=errors
                )
            
            # Parse coverage data
            try:
                coverage_stats = self._read_coverage_data(coverage_data_path)
            except json.JSONDecodeError as e:
                # E9: Coverage data corrupt
                errors.append(f"Coverage data corrupt: {e}")
                return CoverageRunResult(
                    success=False,
                    test_exit_code=exit_code,
                    errors=errors
                )
            
            # Step 9: Display terminal summary
            self._display_summary(coverage_stats)
            
            # Check HTML report
            if not html_report_path.exists():
                # E7: HTML generation failed (warning, not fatal)
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
                errors=errors if errors else None
            )
            
        finally:
            # Step 10: Cleanup (always happens)
            self.cleanup()
    
    def cleanup(self) -> None:
        """
        Cleanup temporary files (always runs, even on error).
        
        Cleans up:
        - .gdsentry/coverage/instrumented/ directory
        - Modified project.godot (if applicable)
        
        Preserves:
        - .gdsentry/coverage/html/ reports
        - .gdsentry/coverage/coverage_data.json
        - Original source files
        """
        if self._cleanup_performed:
            return
        
        self._cleanup_performed = True
        
        # Kill Godot process if still running
        if self._godot_process and self._godot_process.poll() is None:
            try:
                self._godot_process.terminate()
                self._godot_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self._godot_process.kill()
            except Exception:
                pass
        
        # Remove instrumented directory
        instrumented_dir = self.config.output_dir / "instrumented"
        if instrumented_dir.exists():
            try:
                shutil.rmtree(instrumented_dir)
                print("🧹 Cleaned up instrumented files")
            except Exception as e:
                print(f"Warning: Failed to cleanup instrumented files: {e}")
    
    def _create_directory_structure(self) -> None:
        """Create required directory structure"""
        # Create output directory
        self.config.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Create instrumented directory
        instrumented_dir = self.config.output_dir / "instrumented"
        instrumented_dir.mkdir(exist_ok=True)
        
        # Create html directory (for reports)
        html_dir = self.config.output_dir / "html"
        html_dir.mkdir(exist_ok=True)
    
    def _instrument_files(self) -> ProjectInstrumentResult:
        """
        Instrument source files.
        
        Returns:
            ProjectInstrumentResult with instrumentation statistics
        """
        output_root = self.config.output_dir / "instrumented"
        
        return self.instrumenter.instrument_project(
            source_root=self.config.source_root,
            output_root=output_root
        )
    
    def _create_tracker_singleton(self) -> bool:
        """
        Create coverage tracker singleton.
        
        Returns:
            bool: True if successful, False otherwise
        """
        output_dir = self.config.output_dir / "instrumented"
        
        try:
            return self.instrumenter.create_tracker_singleton(output_dir)
        except Exception as e:
            print(f"Error: Failed to create tracker: {e}")
            return False
    
    def _launch_godot(self, test_args: List[str]) -> int:
        """
        Launch Godot process and wait for completion.
        
        Args:
            test_args: Arguments to pass to test runner
            
        Returns:
            int: Exit code from Godot process
        """
        # Check Godot exists (E3)
        godot_path = self.config.godot_path
        if not self._check_godot_exists(godot_path):
            print(f"Error: Godot not found at '{godot_path}'")
            print("Install Godot 4.x: https://godotengine.org/download")
            print("Or specify path with --godot-path")
            return 2
        
        # Build command
        instrumented_dir = self.config.output_dir / "instrumented"
        
        cmd = [
            godot_path,
            "--headless",
            "--path", str(instrumented_dir),
        ]
        
        # Add test arguments
        if test_args:
            cmd.extend(test_args)
        
        # Set environment variables
        env = os.environ.copy()
        env["GDSENTRY_COVERAGE"] = "1"
        env["GDSENTRY_COVERAGE_OUTPUT"] = str(self.config.output_dir.absolute())
        env["GDSENTRY_ORIGINAL_PATH"] = str(self.config.source_root.absolute())
        
        # Launch process
        try:
            self._godot_process = subprocess.Popen(
                cmd,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )
            
            # Stream output
            if self._godot_process.stdout:
                for line in self._godot_process.stdout:
                    print(line, end='')
            
            # Wait for completion
            exit_code = self._godot_process.wait(timeout=self.config.timeout)
            
            return exit_code
            
        except FileNotFoundError:
            # E3: Godot not found
            print(f"Error: Godot not found: {godot_path}")
            return 2
        except subprocess.TimeoutExpired:
            # E11: Test timeout
            print(f"\nError: Test execution timeout after {self.config.timeout}s")
            if self._godot_process:
                self._godot_process.kill()
            return 1
        except Exception as e:
            # E4: Godot crashes
            print(f"Error: Godot execution failed: {e}")
            return 127
    
    def _check_godot_exists(self, godot_path: str) -> bool:
        """
        Check if Godot executable exists.
        
        Args:
            godot_path: Path or command name for Godot
            
        Returns:
            bool: True if Godot is accessible
        """
        try:
            result = subprocess.run(
                [godot_path, "--version"],
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False
    
    def _read_coverage_data(self, coverage_data_path: Path) -> Dict[str, Any]:
        """
        Read and parse coverage data JSON.
        
        Args:
            coverage_data_path: Path to coverage_data.json
            
        Returns:
            Dict with coverage statistics
            
        Raises:
            json.JSONDecodeError: If JSON is invalid
        """
        with open(coverage_data_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Extract statistics (assuming analyzer output format)
        # For now, return raw data - will be replaced with actual analyzer output
        return data
    
    def _display_summary(self, coverage_stats: Dict[str, Any]) -> None:
        """
        Display coverage summary in terminal.
        
        Args:
            coverage_stats: Coverage statistics from analyzer
        """
        total_percent = coverage_stats.get("total_percent", 0.0)
        total_covered = coverage_stats.get("total_covered", 0)
        total_lines = coverage_stats.get("total_lines", 0)
        
        print("\n" + "=" * 60)
        print("📊 Coverage Report")
        print("=" * 60)
        print(f"  Coverage: {total_percent:.1f}% ({total_covered}/{total_lines} lines)")
        
        # Display per-file summary (optional, if files < 10)
        files = coverage_stats.get("files", [])
        if files and len(files) <= 10:
            print("\n  By File:")
            for file_info in files:
                file_name = file_info.get("file", "unknown")
                file_percent = file_info.get("percent", 0.0)
                file_covered = file_info.get("covered", 0)
                file_total = file_info.get("total", 0)
                print(f"    {file_name:40s} {file_percent:5.1f}% ({file_covered}/{file_total})")
        elif files:
            print(f"\n  {len(files)} files covered")
        
        html_path = self.config.output_dir / "html" / "index.html"
        if html_path.exists():
            print(f"\n  HTML Report: {html_path}")
        
        print("=" * 60 + "\n")
    
    def _signal_handler(self, signum, frame):
        """
        Handle interrupt signals (Ctrl+C, SIGTERM).
        
        Args:
            signum: Signal number
            frame: Stack frame
        """
        if not self._interrupted:
            self._interrupted = True
            print("\n\n🛑 Interrupted by user. Cleaning up...")
            
            # Terminate Godot if running
            if self._godot_process and self._godot_process.poll() is None:
                self._godot_process.terminate()
                try:
                    self._godot_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self._godot_process.kill()
            
            self.cleanup()
            sys.exit(130)
