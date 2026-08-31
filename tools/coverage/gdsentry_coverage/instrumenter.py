"""
GDScript code instrumenter for coverage tracking
"""

import os
import re
from pathlib import Path
from typing import List, Optional
import glob
import fnmatch

from gdsentry_coverage.config import CoverageConfig, InstrumentResult, ProjectInstrumentResult
from gdsentry_coverage.exceptions import ParseError, InstrumentationError
from gdsentry_coverage.parser import GDScriptParser
from gdsentry_coverage.templates import COVERAGE_TRACKER_TEMPLATE


class Instrumenter:
    """Instruments GDScript files with coverage tracking calls"""
    
    def __init__(self, config: CoverageConfig):
        """
        Initialize instrumenter.
        
        Args:
            config: Coverage configuration
        """
        self.config = config
        self.parser = GDScriptParser()
    
    def instrument_file(self, source_path: Path, output_path: Path) -> InstrumentResult:
        """
        Instrument a single GDScript file.
        
        Args:
            source_path: Path to original .gd file
            output_path: Path to write instrumented file
            
        Returns:
            InstrumentResult with success status and statistics
        """
        errors = []
        
        try:
            # Read source file
            with open(source_path, 'r', encoding='utf-8') as f:
                source_code = f.read()
        except FileNotFoundError:
            return InstrumentResult(
                success=False,
                file_path=str(source_path),
                errors=[f"File not found: {source_path}"]
            )
        except UnicodeDecodeError as e:
            return InstrumentResult(
                success=False,
                file_path=str(source_path),
                errors=[f"Encoding error: {e}"]
            )
        except Exception as e:
            return InstrumentResult(
                success=False,
                file_path=str(source_path),
                errors=[f"Read error: {e}"]
            )
        
        try:
            # Identify executable lines
            executable_lines = self.parser.identify_executable_lines(source_code)
            
            # Instrument source code
            instrumented_code = self._inject_tracking_calls(
                source_code,
                executable_lines,
                source_path
            )
            
            # Create output directory if needed
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write instrumented file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(instrumented_code)
            
            lines = source_code.splitlines()
            return InstrumentResult(
                success=True,
                file_path=str(source_path),
                instrumented_lines=len(executable_lines),
                total_lines=len(lines)
            )
            
        except ParseError as e:
            return InstrumentResult(
                success=False,
                file_path=str(source_path),
                errors=[f"Parse error: {e}"]
            )
        except Exception as e:
            return InstrumentResult(
                success=False,
                file_path=str(source_path),
                errors=[f"Instrumentation error: {e}"]
            )
    
    def _inject_tracking_calls(
        self,
        source_code: str,
        executable_lines: List[int],
        source_path: Path
    ) -> str:
        """
        Inject tracking calls into source code.
        
        Args:
            source_code: Original source code
            executable_lines: List of line numbers to instrument
            source_path: Path to source file (for tracking call)
            
        Returns:
            Instrumented source code
        """
        lines = source_code.splitlines()
        executable_set = set(executable_lines)
        result_lines = []
        
        # Get relative path for tracking calls
        if self.config.relative_paths:
            try:
                rel_path = source_path.relative_to(self.config.source_root)
                file_identifier = str(rel_path).replace('\\', '/')
            except ValueError:
                # If not relative to source_root, use absolute
                file_identifier = str(source_path).replace('\\', '/')
        else:
            file_identifier = str(source_path).replace('\\', '/')
        
        for i, line in enumerate(lines, start=1):
            if i in executable_set:
                # Inject tracking call before this line
                indentation = self._get_indentation(line)
                tracking_call = self._build_tracking_call(file_identifier, i, indentation)
                result_lines.append(tracking_call)
            result_lines.append(line)
        
        return '\n'.join(result_lines)
    
    def _get_indentation(self, line: str) -> str:
        """
        Extract indentation from a line.
        
        Args:
            line: Line of code
            
        Returns:
            Indentation string (spaces/tabs)
        """
        match = re.match(r'^(\s*)', line)
        return match.group(1) if match else ''
    
    def _build_tracking_call(self, file_path: str, line_num: int, indentation: str) -> str:
        """
        Build coverage tracking call.
        
        Args:
            file_path: File identifier
            line_num: Line number
            indentation: Indentation to match
            
        Returns:
            Tracking call string
        """
        return f'{indentation}__coverage_tracker.hit("{file_path}", {line_num})'
    
    def instrument_project(
        self,
        source_root: Optional[Path] = None,
        output_root: Optional[Path] = None,
        file_patterns: Optional[List[str]] = None
    ) -> ProjectInstrumentResult:
        """
        Instrument all matching files in a project.
        
        Args:
            source_root: Project root directory (default: from config)
            output_root: Output directory (default: from config)
            file_patterns: Glob patterns for files to instrument (default: from config)
            
        Returns:
            ProjectInstrumentResult with statistics
        """
        source_root = source_root or self.config.source_root
        output_root = output_root or self.config.output_dir
        file_patterns = file_patterns or self.config.file_patterns
        
        # Find all matching files
        all_files = []
        for pattern in file_patterns:
            # Handle glob patterns
            matches = glob.glob(str(source_root / pattern), recursive=True)
            all_files.extend(Path(p) for p in matches)
        
        # Remove duplicates and filter out excluded patterns
        all_files = list(set(all_files))
        if self.config.exclude_patterns:
            filtered_files = []
            for file_path in all_files:
                excluded = False
                for exclude_pattern in self.config.exclude_patterns:
                    if fnmatch.fnmatch(str(file_path), exclude_pattern):
                        excluded = True
                        break
                if not excluded:
                    filtered_files.append(file_path)
            all_files = filtered_files
        
        # Instrument each file
        results = {}
        success_count = 0
        failure_count = 0
        total_lines = 0
        instrumented_lines = 0
        
        for source_path in all_files:
            # Calculate output path (preserve directory structure)
            try:
                rel_path = source_path.relative_to(source_root)
            except ValueError:
                # File not under source_root, skip
                continue
            
            output_path = output_root / rel_path
            
            # Instrument file
            result = self.instrument_file(source_path, output_path)
            results[str(source_path)] = result
            
            if result.success:
                success_count += 1
                total_lines += result.total_lines
                instrumented_lines += result.instrumented_lines
            else:
                failure_count += 1
        
        return ProjectInstrumentResult(
            success=success_count > 0,
            files_instrumented=success_count,
            files_failed=failure_count,
            total_lines=total_lines,
            instrumented_lines=instrumented_lines,
            file_results=results
        )
    
    def create_tracker_singleton(self, output_dir: Path) -> bool:
        """
        Generate coverage_tracker.gd singleton from template.
        
        Args:
            output_dir: Directory to write coverage_tracker.gd
            
        Returns:
            True if successful, False otherwise
        """
        try:
            output_path = output_dir / "coverage_tracker.gd"
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(COVERAGE_TRACKER_TEMPLATE)
            
            return True
        except Exception as e:
            print(f"Error creating tracker singleton: {e}")
            return False
    
    def modify_project_config(self, original_path: Path, output_path: Path) -> bool:
        """
        Copy and modify project.godot to add __coverage_tracker autoload.
        
        Args:
            original_path: Path to original project.godot
            output_path: Path to write modified project.godot
            
        Returns:
            True if successful, False otherwise
        """
        try:
            # Read original project.godot
            if not original_path.exists():
                # Create minimal project.godot
                content = "[application]\n\n[autoload]\n"
            else:
                with open(original_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            
            # Check if [autoload] section exists
            if '[autoload]' not in content:
                # Add [autoload] section
                content += '\n[autoload]\n'
            
            # Add __coverage_tracker autoload if not already present
            if '__coverage_tracker=' not in content:
                # Find [autoload] section and add after it
                lines = content.splitlines()
                result_lines = []
                added = False
                
                for line in lines:
                    result_lines.append(line)
                    if line.strip() == '[autoload]' and not added:
                        # Add __coverage_tracker right after [autoload] section
                        result_lines.append('__coverage_tracker="*res://coverage_tracker.gd"')
                        added = True
                
                content = '\n'.join(result_lines)
            
            # Write modified project.godot
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            return True
        except Exception as e:
            print(f"Error modifying project config: {e}")
            return False
