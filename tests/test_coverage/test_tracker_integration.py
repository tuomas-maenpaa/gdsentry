"""
Integration tests for coverage tracker
Tests the tracker by creating instrumented code and validating behavior
"""

import pytest
import tempfile
import json
from pathlib import Path
from gdsentry.coverage.config import CoverageConfig
from gdsentry.coverage.instrumenter import Instrumenter


class TestTrackerIntegration:
    """Test coverage tracker through instrumented code"""
    
    def setup_method(self):
        """Set up test environment"""
        self.temp_dir = tempfile.mkdtemp()
        self.project_root = Path(self.temp_dir) / "project"
        self.project_root.mkdir()
        self.instrumented_dir = Path(self.temp_dir) / "instrumented"
        self.instrumented_dir.mkdir()
        
        self.config = CoverageConfig(
            source_root=self.project_root,
            output_dir=self.instrumented_dir
        )
        self.instrumenter = Instrumenter(self.config)
    
    def teardown_method(self):
        """Clean up"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_tracker_template_exists(self):
        """Test that tracker template is available"""
        from gdsentry.coverage.templates import COVERAGE_TRACKER_TEMPLATE
        
        assert len(COVERAGE_TRACKER_TEMPLATE) > 0
        assert "extends Node" in COVERAGE_TRACKER_TEMPLATE
        assert "func hit(" in COVERAGE_TRACKER_TEMPLATE
        assert "func write_coverage_data(" in COVERAGE_TRACKER_TEMPLATE
        assert "signal coverage_written" in COVERAGE_TRACKER_TEMPLATE
    
    def test_tracker_can_be_generated(self):
        """Test that tracker singleton can be generated"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        
        assert success
        tracker_file = self.instrumented_dir / "coverage_tracker.gd"
        assert tracker_file.exists()
        
        content = tracker_file.read_text()
        assert "extends Node" in content
        assert "func hit(file_path: String, line_num: int)" in content
        assert "signal coverage_written" in content
    
    def test_tracker_has_all_required_methods(self):
        """Test that tracker has all required API methods"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        # Required methods from interface contract
        assert "func hit(file_path: String, line_num: int)" in content
        assert "func write_coverage_data(" in content
        assert "func reset()" in content
        assert "func get_stats()" in content
        
        # Required features
        assert "_coverage_data: Dictionary" in content
        assert "NOTIFICATION_WM_CLOSE_REQUEST" in content
        assert "signal coverage_written" in content
    
    def test_tracker_data_structure(self):
        """Test that tracker uses correct data structure"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        # Should use nested dictionary structure
        assert "_coverage_data: Dictionary = {}" in content
        assert "not _coverage_data.has(file_path)" in content
        assert "_coverage_data[file_path] = {}" in content
    
    def test_tracker_json_output_format(self):
        """Test that tracker writes correct JSON format"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        # Should create proper JSON structure
        assert '"format_version": "1.0"' in content
        assert '"timestamp":' in content
        assert '"files": _coverage_data' in content
    
    def test_tracker_error_handling(self):
        """Test that tracker has error handling"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        # Should handle file errors
        assert "FileAccess.open" in content
        assert "if file == null:" in content
        assert "push_error" in content
        assert "_write_error_file" in content
        assert "coverage_written.emit" in content
    
    def test_tracker_environment_configuration(self):
        """Test that tracker reads from environment"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        assert 'OS.get_environment("GDSENTRY_COVERAGE_OUTPUT")' in content
        assert 'OS.get_environment("GDSENTRY_COVERAGE")' in content
    
    def test_tracker_with_instrumented_code(self):
        """Test tracker generation alongside instrumented code"""
        # Create source file
        (self.project_root / "test.gd").write_text("""extends Node

func test_function():
\tvar x = 5
\tvar y = 10
\treturn x + y
""")
        
        # Instrument
        result = self.instrumenter.instrument_project()
        assert result.success
        
        # Generate tracker
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        # Verify both exist
        assert (self.instrumented_dir / "test.gd").exists()
        assert (self.instrumented_dir / "coverage_tracker.gd").exists()
        
        # Verify instrumented code references tracker
        instrumented = (self.instrumented_dir / "test.gd").read_text()
        assert "__coverage_tracker.hit(" in instrumented
    
    def test_tracker_notification_hook(self):
        """Test that tracker has notification hook for cleanup"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        # Should have notification handler
        assert "func _notification(what: int)" in content
        assert "NOTIFICATION_WM_CLOSE_REQUEST" in content
        assert "write_coverage_data()" in content
    
    def test_tracker_signal_definition(self):
        """Test that tracker defines coverage_written signal"""
        success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert success
        
        content = (self.instrumented_dir / "coverage_tracker.gd").read_text()
        
        # Signal should be defined
        assert "signal coverage_written(path: String, success: bool)" in content
        
        # Signal should be emitted
        assert "coverage_written.emit(path, true)" in content
        assert "coverage_written.emit(path, false)" in content
    
    def test_complete_workflow_with_tracker(self):
        """Test complete workflow: instrument + generate tracker + modify config"""
        # Create source
        (self.project_root / "main.gd").write_text("var x = 1\n")
        (self.project_root / "project.godot").write_text("[application]\n")
        
        # Instrument
        result = self.instrumenter.instrument_project()
        assert result.success
        
        # Generate tracker
        tracker_success = self.instrumenter.create_tracker_singleton(self.instrumented_dir)
        assert tracker_success
        
        # Modify config
        config_success = self.instrumenter.modify_project_config(
            self.project_root / "project.godot",
            self.instrumented_dir / "project.godot"
        )
        assert config_success
        
        # Verify all pieces
        assert (self.instrumented_dir / "main.gd").exists()
        assert (self.instrumented_dir / "coverage_tracker.gd").exists()
        assert (self.instrumented_dir / "project.godot").exists()
        
        # Verify project.godot has autoload
        project_config = (self.instrumented_dir / "project.godot").read_text()
        assert 'CoverageTracker="*res://coverage_tracker.gd"' in project_config
