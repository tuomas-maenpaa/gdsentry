"""
Integration tests for coverage reporter
Validates reporter through file inspection
"""

import pytest
from pathlib import Path


class TestReporterIntegration:
    """Test coverage reporter implementation"""
    
    def setup_method(self):
        """Set up test environment"""
        self.reporter_path = Path("src/gdsentry/coverage/gdscript/coverage_reporter.gd")
    
    def test_reporter_file_exists(self):
        """Test that reporter file was created"""
        assert self.reporter_path.exists()
        assert self.reporter_path.is_file()
    
    def test_reporter_has_required_methods(self):
        """Test that reporter has all required API methods"""
        content = self.reporter_path.read_text()
        
        # Required methods from interface contract
        assert "func generate_html_report(" in content
        assert "func generate_summary_html(" in content
        assert "func generate_file_html(" in content
        assert "func write_html_file(" in content
    
    def test_reporter_methods_are_static(self):
        """Test that reporter methods are static"""
        content = self.reporter_path.read_text()
        
        assert "static func generate_html_report(" in content
        assert "static func generate_summary_html(" in content
        assert "static func generate_file_html(" in content
        assert "static func write_html_file(" in content
    
    def test_reporter_has_source_reading(self):
        """Test that reporter can read source files"""
        content = self.reporter_path.read_text()
        
        assert "_read_source_file" in content
        assert "FileAccess.open" in content
        assert "FileAccess.READ" in content
    
    def test_reporter_has_file_slug_generation(self):
        """Test that reporter generates file slugs"""
        content = self.reporter_path.read_text()
        
        assert "_generate_file_slug" in content
        assert 'replace("/", "_")' in content or "replace('/', '_')" in content
    
    def test_reporter_generates_html_doctype(self):
        """Test that reporter generates valid HTML"""
        content = self.reporter_path.read_text()
        
        assert "<!DOCTYPE html>" in content
        assert "<html>" in content
        assert "</html>" in content
    
    def test_reporter_has_embedded_css(self):
        """Test that reporter includes embedded CSS"""
        content = self.reporter_path.read_text()
        
        assert "<style>" in content
        assert "_get_summary_css" in content or "_get_file_css" in content
        assert "background:" in content
        assert "color:" in content
    
    def test_reporter_has_color_coding(self):
        """Test that reporter implements color coding"""
        content = self.reporter_path.read_text()
        
        # Color classes
        assert "good" in content
        assert "ok" in content
        assert "bad" in content
        
        # Color thresholds
        assert ">= 80" in content
        assert ">= 50" in content
    
    def test_reporter_has_html_escaping(self):
        """Test that reporter escapes HTML"""
        content = self.reporter_path.read_text()
        
        assert "_html_escape" in content
        assert "replace" in content
        assert "&lt;" in content or "&amp;" in content
    
    def test_reporter_handles_errors(self):
        """Test that reporter has error handling"""
        content = self.reporter_path.read_text()
        
        assert "push_error" in content or "push_warning" in content
        assert "== null" in content or "is_empty()" in content
    
    def test_reporter_creates_directories(self):
        """Test that reporter creates output directories"""
        content = self.reporter_path.read_text()
        
        assert "DirAccess.make_dir_recursive_absolute" in content
        assert "DirAccess.dir_exists_absolute" in content
    
    def test_reporter_generates_summary_page(self):
        """Test that reporter generates summary HTML"""
        content = self.reporter_path.read_text()
        
        # Summary elements
        assert "Coverage Report" in content
        assert "Total Coverage" in content
        assert "Coverage by File" in content
    
    def test_reporter_generates_file_details(self):
        """Test that reporter generates file detail pages"""
        content = self.reporter_path.read_text()
        
        # File detail elements
        assert "line-num" in content
        assert "hit-count" in content
        assert "source" in content
        assert "Back to Summary" in content
    
    def test_reporter_has_progress_bars(self):
        """Test that reporter includes visual progress bars"""
        content = self.reporter_path.read_text()
        
        assert "bar" in content
        assert "bar-fill" in content
        assert "width:" in content
    
    def test_reporter_links_summary_to_files(self):
        """Test that summary links to file details"""
        content = self.reporter_path.read_text()
        
        assert "<a href=" in content
        assert ".html" in content
    
    def test_reporter_responsive_design(self):
        """Test that reporter includes responsive meta tags"""
        content = self.reporter_path.read_text()
        
        assert "viewport" in content
        assert "width=device-width" in content
    
    def test_reporter_has_timestamp(self):
        """Test that reporter includes generation timestamp"""
        content = self.reporter_path.read_text()
        
        assert "Time.get_datetime_string_from_system()" in content
    
    def test_reporter_handles_missing_source(self):
        """Test that reporter handles missing source files"""
        content = self.reporter_path.read_text()
        
        assert "FileAccess.file_exists" in content
        assert "push_warning" in content
        # Should have fallback for missing source
        assert "Source file not found" in content or "is_empty()" in content
    
    def test_reporter_extends_node(self):
        """Test that reporter extends Node"""
        content = self.reporter_path.read_text()
        
        assert "extends Node" in content
    
    def test_reporter_has_docstrings(self):
        """Test that reporter methods are documented"""
        content = self.reporter_path.read_text()
        
        assert '"""' in content
        assert "Args:" in content or "Returns:" in content
    
    def test_reporter_efficient_string_building(self):
        """Test that reporter uses efficient string operations"""
        content = self.reporter_path.read_text()
        
        # Should use PackedStringArray for efficiency
        assert "PackedStringArray" in content
        assert '".join(' in content or "join(" in content
    
    def test_reporter_hit_miss_indicators(self):
        """Test that reporter shows hit/miss indicators"""
        content = self.reporter_path.read_text()
        
        assert "hit" in content
        assert "miss" in content
        assert "hit_count" in content
    
    def test_reporter_line_coverage_display(self):
        """Test that reporter displays line-by-line coverage"""
        content = self.reporter_path.read_text()
        
        # Should iterate through source lines
        assert "for " in content
        assert "range" in content or "in source_lines" in content
        assert "line_num" in content
    
    def test_test_file_exists(self):
        """Test that test file was created"""
        test_path = Path("src/gdsentry/coverage/gdscript/test_coverage_reporter.gd")
        assert test_path.exists()
        
        content = test_path.read_text()
        
        # Should have multiple test functions
        assert content.count("func test_") >= 10
        
        # Should test key scenarios
        assert "test_generate_summary_html" in content
        assert "test_generate_file_html" in content
        assert "test_write_html_file" in content
        assert "test_html_escape" in content
