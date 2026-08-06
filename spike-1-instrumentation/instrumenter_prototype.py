#!/usr/bin/env python3
"""
Simple line-based GDScript instrumenter prototype.
Injects CoverageTracker.hit() calls into executable lines.
"""

import re
from pathlib import Path
from typing import List, Tuple


class GDScriptInstrumenter:
    """Simple regex-based instrumenter for GDScript files."""
    
    # Patterns for lines to SKIP (not executable)
    SKIP_PATTERNS = [
        r'^\s*#',           # Comments
        r'^\s*$',           # Blank lines
        r'^\s*extends\s+',  # Class declarations
        r'^\s*class_name\s+',  # Class name declarations
        r'^\s*func\s+',     # Function declarations (signature line)
        r'^\s*var\s+\w+\s*:\s*\w+\s*$',  # Type-only var declarations
        r'^\s*const\s+',    # Constants (often just declarations)
        r'^\s*enum\s+',     # Enums
        r'^\s*signal\s+',   # Signals
        r'^\s*@',           # Annotations
        r'^\s*pass\s*$',    # Pass statements
        r'^\s*else\s*:\s*$',  # Else statement (just control structure)
        r'^\s*elif\s+',     # Elif (control structure, condition is executable though)
    ]
    
    # Patterns for executable lines
    EXECUTABLE_PATTERNS = [
        r'^\s*var\s+\w+\s*=',  # Variable with assignment
        r'^\s*\w+\s*=',        # Assignment
        r'^\s*return\s+',      # Return with value
        r'^\s*return\s*$',     # Return without value
        r'^\s*if\s+',          # If statement
        r'^\s*for\s+',         # For loop
        r'^\s*while\s+',       # While loop
        r'^\s*assert\s*\(',    # Assert
        r'^\s*print\s*\(',     # Print
        r'^\s*\w+\s*\(',       # Function call
    ]
    
    def __init__(self):
        self.skip_regex = [re.compile(p) for p in self.SKIP_PATTERNS]
        self.exec_regex = [re.compile(p) for p in self.EXECUTABLE_PATTERNS]
    
    def should_skip_line(self, line: str) -> bool:
        """Check if line should be skipped (not executable)."""
        for pattern in self.skip_regex:
            if pattern.match(line):
                return True
        return False
    
    def is_executable_line(self, line: str) -> bool:
        """Check if line is executable."""
        # Skip if matches skip patterns
        if self.should_skip_line(line):
            return False
        
        # Check if matches any executable pattern
        for pattern in self.exec_regex:
            if pattern.match(line):
                return True
        
        return False
    
    def get_indentation(self, line: str) -> str:
        """Extract leading whitespace from line."""
        match = re.match(r'^(\s*)', line)
        return match.group(1) if match else ''
    
    def instrument_file(self, source_path: Path, output_path: Path, 
                       tracker_call: str = "CoverageTracker.hit") -> Tuple[int, int]:
        """
        Instrument a GDScript file with coverage tracking calls.
        
        Returns:
            Tuple of (total_lines, instrumented_lines)
        """
        with open(source_path, 'r') as f:
            lines = f.readlines()
        
        instrumented_lines = []
        instrumented_count = 0
        
        for line_num, line in enumerate(lines, start=1):
            # Always add the original line
            instrumented_lines.append(line)
            
            # Check if we should instrument this line
            if self.is_executable_line(line):
                # Get indentation of the original line
                indent = self.get_indentation(line)
                
                # Create tracking call with same indentation
                tracking_call = f'{indent}{tracker_call}("{source_path.name}", {line_num})\n'
                
                # Insert BEFORE the original line (so we need to insert at current position)
                instrumented_lines.insert(-1, tracking_call)
                instrumented_count += 1
        
        # Write instrumented version
        with open(output_path, 'w') as f:
            f.writelines(instrumented_lines)
        
        return len(lines), instrumented_count
    
    def analyze_file(self, source_path: Path) -> dict:
        """Analyze a file and return statistics without instrumenting."""
        with open(source_path, 'r') as f:
            lines = f.readlines()
        
        stats = {
            'total_lines': len(lines),
            'blank_lines': 0,
            'comment_lines': 0,
            'executable_lines': 0,
            'declaration_lines': 0,
        }
        
        for line in lines:
            stripped = line.strip()
            if not stripped:
                stats['blank_lines'] += 1
            elif stripped.startswith('#'):
                stats['comment_lines'] += 1
            elif self.is_executable_line(line):
                stats['executable_lines'] += 1
            else:
                stats['declaration_lines'] += 1
        
        return stats


def main():
    """Test the instrumenter on test files"""
    import sys
    
    instrumenter = GDScriptInstrumenter()
    
    # Default to test_sample.gd if no argument
    if len(sys.argv) > 1:
        source = Path(sys.argv[1])
        output = source.parent / (source.stem + '_instrumented.gd')
    else:
        source = Path(__file__).parent / 'test_sample.gd'
        output = Path(__file__).parent / 'test_sample_instrumented.gd'
    
    if not source.exists():
        print(f"Error: {source} not found!")
        sys.exit(1)
    
    print(f"Analyzing {source.name}...")
    stats = instrumenter.analyze_file(source)
    print(f"  Total lines: {stats['total_lines']}")
    print(f"  Blank lines: {stats['blank_lines']}")
    print(f"  Comment lines: {stats['comment_lines']}")
    print(f"  Executable lines: {stats['executable_lines']}")
    print(f"  Declaration lines: {stats['declaration_lines']}")
    
    print(f"\nInstrumenting {source.name}...")
    total, instrumented = instrumenter.instrument_file(source, output)
    print(f"  Inserted {instrumented} tracking calls into {total} lines")
    print(f"  Output written to {output.name}")


if __name__ == '__main__':
    main()
