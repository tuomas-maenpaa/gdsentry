"""
Performance tests for coverage tracker
Validates that tracker meets performance requirements
"""

import pytest
import tempfile
from pathlib import Path
from gdsentry.coverage.config import CoverageConfig
from gdsentry.coverage.instrumenter import Instrumenter


class TestTrackerPerformance:
    """Performance validation for coverage tracker"""
    
    def setup_method(self):
        """Set up test environment"""
        self.temp_dir = tempfile.mkdtemp()
        self.output_dir = Path(self.temp_dir)
        
        config = CoverageConfig(
            source_root=self.output_dir,
            output_dir=self.output_dir
        )
        self.instrumenter = Instrumenter(config)
    
    def teardown_method(self):
        """Clean up"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_tracker_hit_performance_characteristics(self):
        """
        Test that tracker hit() method has O(1) characteristics
        
        The actual performance requirement (<0.1μs per hit) can only be
        validated in Godot runtime. This test validates the algorithmic
        complexity is correct (O(1) operations only).
        """
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        
        # Verify hit() uses O(1) operations only
        hit_method = self._extract_method(content, "func hit(")
        
        # Should use dictionary lookups (O(1))
        assert ".has(" in hit_method
        assert "[" in hit_method and "]" in hit_method
        
        # Should NOT use O(n) operations
        assert "for " not in hit_method.lower()
        assert "while " not in hit_method.lower()
        assert ".find(" not in hit_method
        assert ".search(" not in hit_method
        
        # Should increment counter (O(1))
        assert "+= 1" in hit_method
    
    def test_tracker_memory_efficiency(self):
        """Test that tracker uses efficient data structures"""
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        
        # Should use Dictionary (hash table - O(1) access)
        assert "_coverage_data: Dictionary" in content
        
        # Should NOT use Array for main storage (O(n) access)
        hit_method = self._extract_method(content, "func hit(")
        assert ": Array" not in hit_method
    
    def test_tracker_no_allocations_per_hit(self):
        """Test that hit() doesn't allocate on hot path after warmup"""
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        hit_method = self._extract_method(content, "func hit(")
        
        # After first hit, should only do:
        # 1. Dictionary lookup (no allocation)
        # 2. Integer increment (no allocation)
        # No string operations in hot path
        lines = [l.strip() for l in hit_method.split('\n') if l.strip()]
        increment_line_idx = None
        for i, line in enumerate(lines):
            if "+= 1" in line:
                increment_line_idx = i
                break
        
        assert increment_line_idx is not None, "Should have increment operation"
        
        # Lines after guards should be minimal
        post_guard_lines = lines[increment_line_idx:]
        assert len(post_guard_lines) <= 2  # Just increment and maybe return
    
    def test_tracker_write_performance_acceptable(self):
        """
        Test that write_coverage_data() uses efficient serialization
        
        JSON.stringify() is O(n) where n is data size, which is acceptable
        for end-of-test writes (not hot path).
        """
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        write_method = self._extract_method(content, "func write_coverage_data(")
        
        # Should use JSON.stringify (efficient built-in)
        assert "JSON.stringify" in write_method
        
        # Should use FileAccess (efficient I/O)
        assert "FileAccess.open" in write_method
        assert ".store_string(" in write_method
    
    def test_get_stats_performance_acceptable(self):
        """
        Test that get_stats() uses acceptable O(n) iteration
        
        This is a debug/monitoring method, not hot path, so O(n) is fine.
        """
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        stats_method = self._extract_method(content, "func get_stats(")
        
        # O(n) iteration is acceptable for stats
        assert "for " in stats_method.lower()
        assert ".values()" in stats_method
    
    def test_reset_performance(self):
        """Test that reset() is efficient"""
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        reset_method = self._extract_method(content, "func reset(")
        
        # Should use .clear() which is O(1) amortized
        assert ".clear()" in reset_method
        
        # Should be very short (just one operation)
        assert len(reset_method.split('\n')) <= 5
    
    def test_instrumenter_performance_acceptable(self):
        """
        Test that instrumenter performance is acceptable
        
        From Spike 1: Target is <100ms per file for instrumentation.
        This validates the implementation doesn't add unnecessary overhead.
        """
        # Create test file
        source_root = self.output_dir / "source"
        source_root.mkdir()
        
        # Create a realistic file (100 lines)
        test_file = source_root / "test.gd"
        lines = []
        lines.append("extends Node\n")
        lines.append("\n")
        lines.append("func test_function():\n")
        for i in range(50):
            lines.append(f"\tvar x{i} = {i}\n")
        lines.append("\treturn x0\n")
        test_file.write_text("".join(lines))
        
        # Time instrumentation
        import time
        start = time.perf_counter()
        
        result = self.instrumenter.instrument_file(
            test_file,
            self.output_dir / "test.gd"
        )
        
        elapsed = time.perf_counter() - start
        
        assert result.success
        # Should be much faster than 100ms target
        assert elapsed < 0.1, f"Instrumentation took {elapsed*1000:.2f}ms (should be <100ms)"
        
        # Typically should be <10ms
        if elapsed < 0.01:
            print(f"✓ Instrumentation: {elapsed*1000:.2f}ms (excellent)")
    
    def _extract_method(self, content: str, method_signature: str) -> str:
        """Extract a method body from GDScript content"""
        lines = content.split('\n')
        in_method = False
        method_lines = []
        indent_level = 0
        
        for line in lines:
            if method_signature in line:
                in_method = True
                method_lines.append(line)
                # Get base indentation
                indent_level = len(line) - len(line.lstrip())
                continue
            
            if in_method:
                if line.strip() and not line.startswith('\t' * (indent_level // 4 + 1)):
                    # New method at same or higher level
                    if not line.strip().startswith('#'):
                        break
                method_lines.append(line)
        
        return '\n'.join(method_lines)
    
    def test_tracker_scalability(self):
        """
        Test that tracker can handle large numbers of files and lines
        
        Requirement: Should handle 100 files with 10K lines each
        = 1M total lines without issues
        """
        success = self.instrumenter.create_tracker_singleton(self.output_dir)
        assert success
        
        content = (self.output_dir / "coverage_tracker.gd").read_text()
        
        # Verify data structure can scale
        # Dictionary of Dictionaries scales to millions of entries
        assert "_coverage_data: Dictionary" in content
        
        # Verify no fixed-size buffers or arrays that would limit scalability
        assert ": Array[" not in content  # No typed arrays that might have limits
        
        # Verify JSON serialization can handle large data
        # (JSON.stringify in Godot handles large objects)
        assert "JSON.stringify(_coverage_data" in content
