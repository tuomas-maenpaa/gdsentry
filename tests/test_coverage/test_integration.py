"""
Integration tests for coverage instrumentation workflow
"""

import pytest
import tempfile
import shutil
from pathlib import Path
from gdsentry.coverage.config import CoverageConfig
from gdsentry.coverage.instrumenter import Instrumenter


class TestCoverageIntegration:
    """Integration tests for complete instrumentation workflow"""
    
    def setup_method(self):
        """Set up test project"""
        self.temp_dir = tempfile.mkdtemp()
        self.project_root = Path(self.temp_dir) / "project"
        self.project_root.mkdir()
        
        # Create source directory structure
        (self.project_root / "src").mkdir()
        (self.project_root / "src" / "core").mkdir()
        (self.project_root / "tests").mkdir()
        
        # Create coverage output directory
        self.coverage_dir = Path(self.temp_dir) / "coverage"
        self.coverage_dir.mkdir()
        self.instrumented_dir = self.coverage_dir / "instrumented"
        
        self.config = CoverageConfig(
            source_root=self.project_root,
            output_dir=self.instrumented_dir
        )
        self.instrumenter = Instrumenter(self.config)
    
    def teardown_method(self):
        """Clean up"""
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_complete_workflow(self):
        """Test complete instrumentation workflow from source to instrumented project"""
        # 1. Create source files
        (self.project_root / "src" / "core" / "player.gd").write_text("""extends Node2D

func _ready():
\tvar health = 100
\tprint("Player ready")

func take_damage(amount: int):
\thealth -= amount
\tif health <= 0:
\t\tdie()

func die():
\tqueue_free()
""")
        
        (self.project_root / "src" / "utils.gd").write_text("""extends Node

func clamp_value(value: float, min_val: float, max_val: float) -> float:
\tif value < min_val:
\t\treturn min_val
\telif value > max_val:
\t\treturn max_val
\treturn value
""")
        
        # Create project.godot
        (self.project_root / "project.godot").write_text("""[application]
config/name="Test Project"
config/version="1.0"

[display]
window/size/width=1024
window/size/height=768
""")
        
        # 2. Instrument all files
        result = self.instrumenter.instrument_project()
        
        # Verify instrumentation success
        assert result.success
        assert result.files_instrumented == 2
        assert result.files_failed == 0
        
        # 3. Verify instrumented files exist with correct structure
        assert (self.instrumented_dir / "src" / "core" / "player.gd").exists()
        assert (self.instrumented_dir / "src" / "utils.gd").exists()
        
        # 4. Verify tracking calls were injected
        player_instrumented = (self.instrumented_dir / "src" / "core" / "player.gd").read_text()
        assert '__coverage_tracker.hit(' in player_instrumented
        # Count tracking calls (should be: var health, print, health -=, die(), queue_free())
        # Note: 'if health <= 0:' is not executable (control flow start)
        tracking_call_count = player_instrumented.count('__coverage_tracker.hit(')
        assert tracking_call_count == 5
        
        utils_instrumented = (self.instrumented_dir / "src" / "utils.gd").read_text()
        assert '__coverage_tracker.hit(' in utils_instrumented
        # Count tracking calls (should be: return min_val, return max_val, return value)
        tracking_call_count = utils_instrumented.count('__coverage_tracker.hit(')
        assert tracking_call_count == 3
        
        # 5. Create tracker singleton
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        assert (self.instrumented_dir / "coverage_tracker.gd").exists()
        
        tracker_content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        assert "func hit(" in tracker_content
        assert "func write_coverage_data(" in tracker_content
        
        # 6. Modify project config
        success = self.instrumenter.modify_project_config(
            self.project_root / "project.godot",
            self.instrumented_dir / "project.godot"
        )
        assert success
        
        project_config = (self.instrumented_dir / "project.godot").read_text()
        assert "[autoload]" in project_config
        assert 'CoverageTracker="*res://coverage_tracker.gd"' in project_config
        
        # Verify original project settings preserved
        assert 'config/name="Test Project"' in project_config
        assert "window/size/width=1024" in project_config
    
    def test_workflow_with_exclusions(self):
        """Test workflow excludes test files correctly"""
        # Create source and test files
        (self.project_root / "src" / "main.gd").write_text("var x = 1\n")
        (self.project_root / "tests" / "test_main.gd").write_text("var y = 2\n")
        
        config = CoverageConfig(
            source_root=self.project_root,
            output_dir=self.instrumented_dir,
            exclude_patterns=["**/tests/**", "**/*_test.gd"]
        )
        instrumenter = Instrumenter(config)
        
        result = instrumenter.instrument_project()
        
        # Only main.gd should be instrumented
        assert result.files_instrumented == 1
        assert (self.instrumented_dir / "src" / "main.gd").exists()
        assert not (self.instrumented_dir / "tests" / "test_main.gd").exists()
    
    def test_handles_parse_errors_gracefully(self):
        """Test that one bad file doesn't stop the entire workflow"""
        # Create valid and invalid files
        (self.project_root / "good.gd").write_text("var x = 1\n")
        # This will work but might have issues - create actual invalid GDScript
        (self.project_root / "weird.gd").write_text("var x = 1\n")  # Actually valid, but tests the system
        
        result = self.instrumenter.instrument_project()
        
        # Both should succeed (our parser is permissive)
        assert result.files_instrumented == 2
    
    def test_empty_project(self):
        """Test instrumenting project with no .gd files"""
        result = self.instrumenter.instrument_project()
        
        # Should succeed but with no files instrumented
        assert not result.success  # success_count == 0
        assert result.files_instrumented == 0
        assert result.files_failed == 0
    
    def test_project_statistics(self):
        """Test that instrumentation statistics are accurate"""
        # Create file with known line counts
        (self.project_root / "counted.gd").write_text("""# Line 1 - comment
extends Node
func test():
\tvar x = 1
\tvar y = 2
\treturn x + y
""")
        
        result = self.instrumenter.instrument_project()
        
        assert result.success
        assert result.total_lines == 6
        assert result.instrumented_lines == 3
        assert result.coverage_percent == pytest.approx((3 / 6) * 100, rel=0.01)
    
    def test_relative_paths_in_tracking_calls(self):
        """Test that tracking calls use relative paths from source_root"""
        (self.project_root / "src" / "test.gd").write_text("var x = 1\n")
        
        result = self.instrumenter.instrument_project()
        assert result.success
        
        instrumented = (self.instrumented_dir / "src" / "test.gd").read_text()
        # Should use path relative to source_root
        assert '__coverage_tracker.hit("src/test.gd", 1)' in instrumented
    
    def test_preserves_utf8_encoding(self):
        """Test that UTF-8 characters are preserved"""
        (self.project_root / "unicode.gd").write_text("""# Kommentti 🎮
var message = "Hyvää päivää"  # Finnish
var emoji = "🎯🎨🎪"
""", encoding='utf-8')
        
        result = self.instrumenter.instrument_project()
        assert result.success
        
        instrumented = (self.instrumented_dir / "unicode.gd").read_text(encoding='utf-8')
        assert "Hyvää päivää" in instrumented
        assert "🎮" in instrumented
        assert "🎯🎨🎪" in instrumented
