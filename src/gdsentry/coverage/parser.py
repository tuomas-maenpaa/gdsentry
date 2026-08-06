"""
GDScript parser for identifying executable lines
"""

import re
from typing import List, Set


class GDScriptParser:
    """Parser for identifying executable lines in GDScript"""
    
    # Patterns for non-executable lines
    COMMENT_PATTERN = re.compile(r'^\s*#')
    BLANK_PATTERN = re.compile(r'^\s*$')
    
    # Declaration patterns (non-executable)
    FUNC_SIGNATURE_PATTERN = re.compile(r'^\s*func\s+\w+\s*\(.*\)\s*(->\s*\w+)?\s*:\s*$')
    CLASS_NAME_PATTERN = re.compile(r'^\s*class_name\s+\w+')
    EXTENDS_PATTERN = re.compile(r'^\s*extends\s+')
    SIGNAL_PATTERN = re.compile(r'^\s*signal\s+\w+')
    ENUM_PATTERN = re.compile(r'^\s*enum\s+\w+')
    CONST_PATTERN = re.compile(r'^\s*const\s+\w+\s*=')
    VAR_DECLARATION_PATTERN = re.compile(r'^\s*var\s+\w+\s*:\s*\w+\s*$')  # Type-only declaration
    EXPORT_PATTERN = re.compile(r'^\s*@export')
    ANNOTATION_PATTERN = re.compile(r'^\s*@\w+')
    
    # Control flow start patterns (the line itself is not executable, but contains ':')
    CONTROL_FLOW_START_PATTERN = re.compile(r'^\s*(if|elif|for|while|match|class)\s.*:\s*$')
    ELSE_PATTERN = re.compile(r'^\s*else\s*:\s*$')
    
    def __init__(self):
        self._in_multiline_string = False
        self._multiline_string_delimiter = None
    
    def is_executable_line(self, line: str, line_num: int, context: dict = None) -> bool:
        """
        Determine if a line is executable (should be instrumented).
        
        Args:
            line: The line of code
            line_num: Line number (1-indexed)
            context: Optional context dict for multi-line tracking
            
        Returns:
            True if line should be instrumented, False otherwise
        """
        # Handle multiline strings
        if context and 'in_multiline_string' in context:
            if context['in_multiline_string']:
                # Check if this line ends the multiline string
                delimiter = context.get('multiline_string_delimiter', '"""')
                if delimiter in line:
                    context['in_multiline_string'] = False
                    context['multiline_string_delimiter'] = None
                return False
        
        # Check for multiline string start
        if '"""' in line or "'''" in line:
            # Count occurrences
            triple_double = line.count('"""')
            triple_single = line.count("'''")
            
            if triple_double == 1 or triple_single == 1:
                # Start of multiline string
                if context is not None:
                    context['in_multiline_string'] = True
                    context['multiline_string_delimiter'] = '"""' if triple_double == 1 else "'''"
                return False
        
        # Blank lines
        if self.BLANK_PATTERN.match(line):
            return False
        
        # Comments
        if self.COMMENT_PATTERN.match(line):
            return False
        
        # Annotations
        if self.ANNOTATION_PATTERN.match(line):
            return False
        
        # Class name
        if self.CLASS_NAME_PATTERN.match(line):
            return False
        
        # Extends
        if self.EXTENDS_PATTERN.match(line):
            return False
        
        # Signal
        if self.SIGNAL_PATTERN.match(line):
            return False
        
        # Enum
        if self.ENUM_PATTERN.match(line):
            return False
        
        # Const (these are declarations, not executable)
        if self.CONST_PATTERN.match(line):
            return False
        
        # Function signature
        if self.FUNC_SIGNATURE_PATTERN.match(line):
            return False
        
        # Else statement
        if self.ELSE_PATTERN.match(line):
            return False
        
        # Control flow start (if/for/while/etc with only ':')
        # These lines themselves don't execute, the body does
        if self.CONTROL_FLOW_START_PATTERN.match(line):
            # Check if there's code after the colon on the same line
            if ':' in line:
                after_colon = line.split(':', 1)[1].strip()
                if after_colon and not after_colon.startswith('#'):
                    # There's executable code after the colon
                    return True
            return False
        
        # Var declaration without initialization (type-only)
        if self.VAR_DECLARATION_PATTERN.match(line):
            return False
        
        # Everything else is likely executable
        # This includes:
        # - var x = value (with initialization)
        # - function calls
        # - return statements
        # - assignments
        # - expressions
        return True
    
    def identify_executable_lines(self, source_code: str) -> List[int]:
        """
        Identify all executable line numbers in source code.
        
        Args:
            source_code: Complete GDScript source code
            
        Returns:
            List of line numbers (1-indexed) that are executable
        """
        lines = source_code.splitlines()
        executable_lines = []
        context = {}
        
        for i, line in enumerate(lines, start=1):
            if self.is_executable_line(line, i, context):
                executable_lines.append(i)
        
        return executable_lines
