"""
Tests for GDScript instrumenter
"""

import unittest
import tempfile
from pathlib import Path
from gdsentry_coverage.config import CoverageConfig
from gdsentry_coverage.instrumenter import Instrumenter


class TestInstrumenter(unittest.TestCase):
    """Test GDScript code instrumentation"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.temp_dir = tempfile.mkdtemp()
        self.source_root = Path(self.temp_dir) / "source"
        self.output_dir = Path(self.temp_dir) / "output"
        self.source_root.mkdir(parents=True)
        self.output_dir.mkdir(parents=True)
        
        self.config = CoverageConfig(
            source_root=self.source_root,
            output_dir=self.output_dir
        )
        self.instrumenter = Instrumenter(self.config)
    
    def tearDown(self):
        """Clean up temporary files"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_instrument_simple_file(self):
        """Test instrumenting a simple GDScript file"""
        source = """extends Node

func calculate(x: int) -> int:
\tvar result = x * 2
\treturn result
"""
        source_file = self.source_root / "test.gd"
        source_file.write_text(source)
        
        output_file = self.output_dir / "test.gd"
        result = self.instrumenter.instrument_file(source_file, output_file)
        
        assert result.success
        assert result.instrumented_lines == 2  # var result, return
        assert result.total_lines == 5
        
        # Check instrumented content
        instrumented = output_file.read_text()
        assert '__coverage_tracker.hit("test.gd", 4)' in instrumented
        assert '__coverage_tracker.hit("test.gd", 5)' in instrumented
    
    def test_instrument_preserves_indentation(self):
        """Test that instrumentation preserves code indentation"""
        source = """func test():
\tif true:
\t\tvar x = 5
\t\tprint(x)
"""
        source_file = self.source_root / "indent.gd"
        source_file.write_text(source)
        
        output_file = self.output_dir / "indent.gd"
        result = self.instrumenter.instrument_file(source_file, output_file)
        
        assert result.success
        instrumented = output_file.read_text()
        
        # Check tracking call has same indentation as code
        assert '\t\t__coverage_tracker.hit("indent.gd", 3)' in instrumented
        assert '\t\t__coverage_tracker.hit("indent.gd", 4)' in instrumented
    
    def test_instrument_skips_non_executable_lines(self):
        """Test that non-executable lines are not instrumented"""
        source = """# Comment
extends Node
var x: int
var y = 5

func test():
\tpass
"""
        source_file = self.source_root / "skip.gd"
        source_file.write_text(source)
        
        output_file = self.output_dir / "skip.gd"
        result = self.instrumenter.instrument_file(source_file, output_file)
        
        assert result.success
        instrumented = output_file.read_text()
        
        # Should instrument line 4 (var y = 5) and line 7 (pass)
        assert '__coverage_tracker.hit("skip.gd", 4)' in instrumented
        assert '__coverage_tracker.hit("skip.gd", 7)' in instrumented
        
        # Should not instrument comments, extends, type-only var, func signature
        assert result.instrumented_lines == 2
    
    def test_instrument_file_not_found(self):
        """Test handling of non-existent file"""
        source_file = self.source_root / "nonexistent.gd"
        output_file = self.output_dir / "nonexistent.gd"
        
        result = self.instrumenter.instrument_file(source_file, output_file)
        
        assert not result.success
        assert len(result.errors) > 0
        assert "not found" in result.errors[0].lower()
    
    def test_instrument_creates_output_directory(self):
        """Test that output directory is created if it doesn't exist"""
        source = "var x = 5\n"
        source_file = self.source_root / "test.gd"
        source_file.write_text(source)
        
        # Output in nested directory that doesn't exist
        output_file = self.output_dir / "nested" / "deep" / "test.gd"
        result = self.instrumenter.instrument_file(source_file, output_file)
        
        assert result.success
        assert output_file.exists()
        assert output_file.parent.exists()
    
    def test_instrument_project_multiple_files(self):
        """Test instrumenting multiple files in a project"""
        # Create test files
        (self.source_root / "file1.gd").write_text("var x = 1\n")
        (self.source_root / "file2.gd").write_text("var y = 2\n")
        (self.source_root / "file3.gd").write_text("var z = 3\n")
        
        result = self.instrumenter.instrument_project()
        
        assert result.success
        assert result.files_instrumented == 3
        assert result.files_failed == 0
        assert result.total_files == 3
    
    def test_instrument_project_preserves_structure(self):
        """Test that directory structure is preserved"""
        # Create nested structure
        (self.source_root / "src").mkdir()
        (self.source_root / "src" / "core").mkdir()
        (self.source_root / "src" / "core" / "main.gd").write_text("var x = 1\n")
        
        result = self.instrumenter.instrument_project()
        
        assert result.success
        assert (self.output_dir / "src" / "core" / "main.gd").exists()
    
    def test_instrument_project_with_exclusions(self):
        """Test excluding files from instrumentation"""
        # Create test files
        (self.source_root / "include.gd").write_text("var x = 1\n")
        (self.source_root / "exclude_test.gd").write_text("var y = 2\n")
        
        config = CoverageConfig(
            source_root=self.source_root,
            output_dir=self.output_dir,
            exclude_patterns=["*test.gd"]
        )
        instrumenter = Instrumenter(config)
        
        result = instrumenter.instrument_project()
        
        assert result.success
        assert result.files_instrumented == 1
        assert (self.output_dir / "include.gd").exists()
        assert not (self.output_dir / "exclude_test.gd").exists()
    
    def test_instrument_relative_paths(self):
        """Test that relative paths are used in tracking calls"""
        source = "var x = 5\n"
        (self.source_root / "test.gd").write_text(source)
        
        result = self.instrumenter.instrument_project()
        
        instrumented = (self.output_dir / "test.gd").read_text()
        # Should use relative path
        assert '__coverage_tracker.hit("test.gd", 1)' in instrumented
    
    def test_create_tracker_singleton(self):
        """Test creating coverage tracker singleton"""
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        
        assert success
        tracker_file = self.output_dir / "coverage_tracker.gd"
        assert tracker_file.exists()
        
        content = tracker_file.read_text()
        assert "extends Node" in content
        assert "func hit(" in content
        assert "func write_coverage_data(" in content
    
    def test_modify_project_config_adds_autoload(self):
        """Test modifying project.godot to add autoload"""
        # Create original project.godot
        original = self.source_root / "project.godot"
        original.write_text("""[application]
config/name="Test"

[autoload]
Globals="*res://globals.gd"
""")
        
        output = self.output_dir / "project.godot"
        success = self.instrumenter.modify_project_config(original, output)
        
        assert success
        content = output.read_text()
        assert '__coverage_tracker="*res://coverage_tracker.gd"' in content
        assert 'Globals="*res://globals.gd"' in content
    
    def test_modify_project_config_creates_autoload_section(self):
        """Test creating [autoload] section if it doesn't exist"""
        # Create minimal project.godot
        original = self.source_root / "project.godot"
        original.write_text("[application]\nconfig/name=\"Test\"\n")
        
        output = self.output_dir / "project.godot"
        success = self.instrumenter.modify_project_config(original, output)
        
        assert success
        content = output.read_text()
        assert "[autoload]" in content
        assert '__coverage_tracker="*res://coverage_tracker.gd"' in content
    
    def test_modify_project_config_missing_original(self):
        """Test handling missing original project.godot"""
        original = self.source_root / "nonexistent.godot"
        output = self.output_dir / "project.godot"
        
        success = self.instrumenter.modify_project_config(original, output)
        
        assert success
        content = output.read_text()
        assert "[autoload]" in content
        assert '__coverage_tracker="*res://coverage_tracker.gd"' in content
    
    def test_instrument_complex_control_flow(self):
        """Test instrumenting complex control flow"""
        source = """func test():
\tif x > 0:
\t\tvar a = 1
\telif x < 0:
\t\tvar b = 2
\telse:
\t\tvar c = 3
\t
\tfor i in range(10):
\t\tprint(i)
\t
\twhile running:
\t\tupdate()
"""
        source_file = self.source_root / "control.gd"
        source_file.write_text(source)
        
        output_file = self.output_dir / "control.gd"
        result = self.instrumenter.instrument_file(source_file, output_file)
        
        assert result.success
        # Should instrument: var a, var b, var c, print(i), update()
        assert result.instrumented_lines == 5
    
    def test_get_indentation(self):
        """Test indentation extraction"""
        assert self.instrumenter._get_indentation("var x = 5") == ""
        assert self.instrumenter._get_indentation("\tvar x = 5") == "\t"
        assert self.instrumenter._get_indentation("    var x = 5") == "    "
        assert self.instrumenter._get_indentation("\t\tvar x = 5") == "\t\t"
    
    def test_build_tracking_call(self):
        """Test building tracking call"""
        call = self.instrumenter._build_tracking_call("test.gd", 42, "\t")
        assert call == '\t__coverage_tracker.hit("test.gd", 42)'
        
        call = self.instrumenter._build_tracking_call("path/to/file.gd", 1, "")
        assert call == '__coverage_tracker.hit("path/to/file.gd", 1)'


if __name__ == "__main__":
    unittest.main()
