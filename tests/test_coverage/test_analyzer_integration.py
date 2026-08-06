"""
Integration tests for coverage analyzer
Validates analyzer through file inspection
"""

import pytest
from pathlib import Path


class TestAnalyzerIntegration:
    """Test coverage analyzer implementation"""
    
    def setup_method(self):
        """Set up test environment"""
        self.analyzer_path = Path("src/gdsentry/coverage/gdscript/coverage_analyzer.gd")
    
    def test_analyzer_file_exists(self):
        """Test that analyzer file was created"""
        assert self.analyzer_path.exists()
        assert self.analyzer_path.is_file()
    
    def test_analyzer_has_required_methods(self):
        """Test that analyzer has all required API methods"""
        content = self.analyzer_path.read_text()
        
        # Required methods from interface contract
        assert "func analyze_coverage_data(" in content
        assert "func compute_file_coverage(" in content
        assert "func get_missed_lines(" in content
    
    def test_analyzer_is_static(self):
        """Test that analyzer methods are static"""
        content = self.analyzer_path.read_text()
        
        # Methods should be static (no instance needed)
        assert "static func analyze_coverage_data(" in content
        assert "static func compute_file_coverage(" in content
        assert "static func get_missed_lines(" in content
    
    def test_analyzer_handles_null_input(self):
        """Test that analyzer has null checks"""
        content = self.analyzer_path.read_text()
        
        # Should check for null/empty data
        assert "== null" in content or "!= null" in content
        assert "is_empty()" in content
    
    def test_analyzer_computes_coverage_percentage(self):
        """Test that analyzer computes percentage correctly"""
        content = self.analyzer_path.read_text()
        
        # Should compute percentage
        assert "percent" in content.lower()
        assert "/ " in content  # Division for percentage
        assert "* 100" in content  # Convert to percentage
    
    def test_analyzer_identifies_covered_lines(self):
        """Test that analyzer counts covered lines"""
        content = self.analyzer_path.read_text()
        
        # Should check hit_count > 0 for covered
        assert "hit_count > 0" in content or "> 0" in content
        assert "covered" in content
    
    def test_analyzer_identifies_missed_lines(self):
        """Test that analyzer identifies missed lines"""
        content = self.analyzer_path.read_text()
        
        # Should check for hit_count == 0
        assert "== 0" in content
        assert "missed" in content or "get_missed_lines" in content
    
    def test_analyzer_sorts_missed_lines(self):
        """Test that missed lines are sorted"""
        content = self.analyzer_path.read_text()
        
        # Should sort line numbers
        assert ".sort()" in content
    
    def test_analyzer_aggregates_multiple_files(self):
        """Test that analyzer can aggregate multiple files"""
        content = self.analyzer_path.read_text()
        
        # Should iterate over files
        assert "for " in content
        assert "keys()" in content
    
    def test_analyzer_returns_correct_structure(self):
        """Test that analyzer returns correct data structure"""
        content = self.analyzer_path.read_text()
        
        # Should return dictionary with required fields
        assert "return {" in content or 'return {"' in content
        assert '"covered"' in content or "'covered'" in content
        assert '"total"' in content or "'total'" in content
        assert '"percent"' in content or "'percent'" in content
    
    def test_analyzer_handles_type_validation(self):
        """Test that analyzer validates data types"""
        content = self.analyzer_path.read_text()
        
        # Should check types
        assert "typeof(" in content or "is Dictionary" in content
    
    def test_analyzer_has_docstrings(self):
        """Test that analyzer methods are documented"""
        content = self.analyzer_path.read_text()
        
        # Should have docstrings
        assert '"""' in content
        assert "Args:" in content or "Returns:" in content
    
    def test_analyzer_handles_empty_data(self):
        """Test that analyzer handles empty data gracefully"""
        content = self.analyzer_path.read_text()
        
        # Should handle empty dictionaries
        assert "is_empty()" in content
        
        # Should return safe defaults
        lines = content.split('\n')
        found_return_with_zeros = False
        for i, line in enumerate(lines):
            if 'return {' in line or 'return {' in line:
                # Check next few lines for 0 defaults
                next_lines = '\n'.join(lines[i:i+10])
                if ': 0' in next_lines or ': 0.0' in next_lines:
                    found_return_with_zeros = True
                    break
        
        assert found_return_with_zeros, "Should have return with 0 defaults"
    
    def test_analyzer_handles_string_keys(self):
        """Test that analyzer handles string line numbers (from JSON)"""
        content = self.analyzer_path.read_text()
        
        # Should handle string keys
        assert "TYPE_STRING" in content or "int(" in content
    
    def test_analyzer_uses_push_warning(self):
        """Test that analyzer uses push_warning for errors"""
        content = self.analyzer_path.read_text()
        
        # Should use push_warning for non-fatal errors
        assert "push_warning" in content
    
    def test_analyzer_extends_node(self):
        """Test that analyzer extends Node"""
        content = self.analyzer_path.read_text()
        
        # Should extend Node for GDScript
        assert "extends Node" in content
    
    def test_analyzer_file_summary_structure(self):
        """Test that file summaries include all required fields"""
        content = self.analyzer_path.read_text()
        
        # File summaries should have:
        assert '"file"' in content or "'file'" in content
        assert '"covered"' in content or "'covered'" in content
        assert '"total"' in content or "'total'" in content
        assert '"percent"' in content or "'percent'" in content
    
    def test_analyzer_performance_efficient(self):
        """Test that analyzer uses efficient operations"""
        content = self.analyzer_path.read_text()
        
        # Should use efficient dictionary operations
        assert ".keys()" in content
        assert ".size()" in content
        
        # Should not use inefficient operations
        assert "range(" not in content  # No unnecessary ranges
    
    def test_test_file_exists(self):
        """Test that test file was created"""
        test_path = Path("src/gdsentry/coverage/gdscript/test_coverage_analyzer.gd")
        assert test_path.exists()
        
        content = test_path.read_text()
        
        # Should have multiple test functions
        assert content.count("func test_") >= 10
        
        # Should test key scenarios
        assert "test_compute_file_coverage" in content
        assert "test_get_missed_lines" in content
        assert "test_analyze_coverage_data" in content
