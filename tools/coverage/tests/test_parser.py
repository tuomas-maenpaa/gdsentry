"""
Tests for GDScript parser
"""

import unittest
from gdsentry_coverage.parser import GDScriptParser


class TestGDScriptParser(unittest.TestCase):
    """Test GDScript parser line classification"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.parser = GDScriptParser()
    
    def test_blank_lines_not_executable(self):
        """Blank lines should not be executable"""
        assert not self.parser.is_executable_line("", 1)
        assert not self.parser.is_executable_line("   ", 2)
        assert not self.parser.is_executable_line("\t\t", 3)
    
    def test_comments_not_executable(self):
        """Comments should not be executable"""
        assert not self.parser.is_executable_line("# This is a comment", 1)
        assert not self.parser.is_executable_line("\t# Indented comment", 2)
        assert not self.parser.is_executable_line("    # Spaced comment", 3)
    
    def test_function_signature_not_executable(self):
        """Function signatures should not be executable"""
        assert not self.parser.is_executable_line("func calculate():", 1)
        assert not self.parser.is_executable_line("func calculate(x: int):", 2)
        assert not self.parser.is_executable_line("func calculate(x: int) -> int:", 3)
        assert not self.parser.is_executable_line("\tfunc _private_method():", 4)
    
    def test_class_name_not_executable(self):
        """class_name declarations should not be executable"""
        assert not self.parser.is_executable_line("class_name MyClass", 1)
        assert not self.parser.is_executable_line("class_name Player", 2)
    
    def test_extends_not_executable(self):
        """extends statements should not be executable"""
        assert not self.parser.is_executable_line("extends Node", 1)
        assert not self.parser.is_executable_line("extends Node2D", 2)
    
    def test_signal_not_executable(self):
        """signal declarations should not be executable"""
        assert not self.parser.is_executable_line("signal my_signal", 1)
        assert not self.parser.is_executable_line("signal player_hit(damage)", 2)
    
    def test_enum_not_executable(self):
        """enum declarations should not be executable"""
        assert not self.parser.is_executable_line("enum MyEnum {A, B, C}", 1)
        assert not self.parser.is_executable_line("enum State", 2)
    
    def test_const_not_executable(self):
        """const declarations should not be executable"""
        assert not self.parser.is_executable_line("const MAX_VALUE = 100", 1)
        assert not self.parser.is_executable_line("const PI = 3.14159", 2)
    
    def test_annotation_not_executable(self):
        """Annotations should not be executable"""
        assert not self.parser.is_executable_line("@export", 1)
        assert not self.parser.is_executable_line("@onready", 2)
        assert not self.parser.is_executable_line("@tool", 3)
    
    def test_control_flow_start_not_executable(self):
        """Control flow starts (if/for/while) without body are not executable"""
        assert not self.parser.is_executable_line("if x > 0:", 1)
        assert not self.parser.is_executable_line("for i in range(10):", 2)
        assert not self.parser.is_executable_line("while running:", 3)
        assert not self.parser.is_executable_line("elif x < 0:", 4)
        assert not self.parser.is_executable_line("else:", 5)
    
    def test_var_declaration_with_initialization_is_executable(self):
        """var with initialization is executable"""
        assert self.parser.is_executable_line("var x = 5", 1)
        assert self.parser.is_executable_line("var name = 'John'", 2)
        assert self.parser.is_executable_line("\tvar result = calculate()", 3)
    
    def test_var_declaration_type_only_not_executable(self):
        """var with type only (no initialization) is not executable"""
        assert not self.parser.is_executable_line("var x: int", 1)
        assert not self.parser.is_executable_line("var name: String", 2)
    
    def test_function_calls_are_executable(self):
        """Function calls are executable"""
        assert self.parser.is_executable_line("print('hello')", 1)
        assert self.parser.is_executable_line("obj.method()", 2)
        assert self.parser.is_executable_line("\tcalculate(x, y)", 3)
    
    def test_return_statements_are_executable(self):
        """Return statements are executable"""
        assert self.parser.is_executable_line("return x", 1)
        assert self.parser.is_executable_line("return x + y", 2)
        assert self.parser.is_executable_line("\treturn", 3)
    
    def test_assignments_are_executable(self):
        """Assignments are executable"""
        assert self.parser.is_executable_line("x = 5", 1)
        assert self.parser.is_executable_line("result = x + y", 2)
        assert self.parser.is_executable_line("\tvalue += 1", 3)
    
    def test_identify_executable_lines(self):
        """Test identifying all executable lines in source code"""
        source = """# Comment
extends Node

var x: int
var y = 5

func calculate():
\tvar result = x + y
\treturn result

func _ready():
\tprint("Ready")
"""
        executable = self.parser.identify_executable_lines(source)
        
        # Expected: line 5 (var y = 5), line 8 (var result), line 9 (return), line 12 (print)
        assert 5 in executable  # var y = 5
        assert 8 in executable  # var result = x + y
        assert 9 in executable  # return result
        assert 12 in executable  # print("Ready")
        
        # Not executable
        assert 1 not in executable  # comment
        assert 2 not in executable  # extends
        assert 4 not in executable  # var x: int (type only)
        assert 7 not in executable  # func calculate():
        assert 11 not in executable  # func _ready():
    
    def test_multiline_strings(self):
        """Test handling of multiline strings"""
        source = '''var text = """
This is a multiline
string that spans
multiple lines
"""

var x = 5
'''
        executable = self.parser.identify_executable_lines(source)
        
        # Only the var x = 5 should be executable
        # The multiline string lines (2-4) should not be
        assert 1 not in executable  # var text = """ (starts multiline)
        assert 2 not in executable  # inside multiline
        assert 3 not in executable  # inside multiline
        assert 4 not in executable  # inside multiline
        assert 5 not in executable  # """  (ends multiline)
        assert 7 in executable  # var x = 5


if __name__ == "__main__":
    unittest.main()
