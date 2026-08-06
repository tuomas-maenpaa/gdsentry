"""
Unit tests for coverage orchestrator
"""

import pytest
import json
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock
from dataclasses import dataclass

from gdsentry.coverage.orchestrator import CoverageOrchestrator, CoverageRunResult
from gdsentry.coverage.config import CoverageConfig, ProjectInstrumentResult


@pytest.fixture
def temp_dir(tmp_path):
    """Create temporary directory structure"""
    source_dir = tmp_path / "src"
    output_dir = tmp_path / ".gdsentry" / "coverage"
    
    source_dir.mkdir(parents=True)
    output_dir.mkdir(parents=True)
    
    return tmp_path, source_dir, output_dir


@pytest.fixture
def config(temp_dir):
    """Create test configuration"""
    _, source_dir, output_dir = temp_dir
    
    return CoverageConfig(
        source_root=source_dir,
        output_dir=output_dir,
        godot_path="godot",
        timeout=60
    )


class TestCoverageOrchestrator:
    """Test coverage orchestrator"""
    
    def test_orchestrator_initialization(self, config):
        """Test orchestrator can be initialized"""
        orchestrator = CoverageOrchestrator(config)
        
        assert orchestrator.config == config
        assert orchestrator.instrumenter is not None
        assert orchestrator._godot_process is None
        assert not orchestrator._cleanup_performed
        assert not orchestrator._interrupted
    
    def test_create_directory_structure(self, config, temp_dir):
        """Test directory creation"""
        orchestrator = CoverageOrchestrator(config)
        orchestrator._create_directory_structure()
        
        _, _, output_dir = temp_dir
        assert (output_dir / "instrumented").exists()
        assert (output_dir / "html").exists()
    
    def test_cleanup_removes_instrumented_dir(self, config, temp_dir):
        """Test cleanup removes instrumented directory"""
        orchestrator = CoverageOrchestrator(config)
        
        _, _, output_dir = temp_dir
        instrumented_dir = output_dir / "instrumented"
        instrumented_dir.mkdir(parents=True, exist_ok=True)
        
        # Create dummy file
        (instrumented_dir / "test.gd").write_text("# test")
        
        orchestrator.cleanup()
        
        assert not instrumented_dir.exists()
        assert orchestrator._cleanup_performed
    
    def test_cleanup_is_idempotent(self, config):
        """Test cleanup can be called multiple times"""
        orchestrator = CoverageOrchestrator(config)
        
        orchestrator.cleanup()
        orchestrator.cleanup()  # Should not error
        
        assert orchestrator._cleanup_performed
    
    def test_cleanup_preserves_html_reports(self, config, temp_dir):
        """Test cleanup preserves HTML reports"""
        orchestrator = CoverageOrchestrator(config)
        
        _, _, output_dir = temp_dir
        html_dir = output_dir / "html"
        html_dir.mkdir(parents=True, exist_ok=True)
        report = html_dir / "index.html"
        report.write_text("<html></html>")
        
        orchestrator.cleanup()
        
        assert report.exists()
    
    def test_cleanup_preserves_coverage_data(self, config, temp_dir):
        """Test cleanup preserves coverage_data.json"""
        orchestrator = CoverageOrchestrator(config)
        
        _, _, output_dir = temp_dir
        coverage_data = output_dir / "coverage_data.json"
        coverage_data.write_text('{"test": true}')
        
        orchestrator.cleanup()
        
        assert coverage_data.exists()
    
    def test_check_godot_exists_with_valid_path(self, config):
        """Test Godot check with valid executable"""
        orchestrator = CoverageOrchestrator(config)
        
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = Mock(returncode=0)
            
            result = orchestrator._check_godot_exists("godot")
            
            assert result is True
            mock_run.assert_called_once()
    
    def test_check_godot_exists_with_invalid_path(self, config):
        """Test Godot check with invalid executable"""
        orchestrator = CoverageOrchestrator(config)
        
        with patch('subprocess.run', side_effect=FileNotFoundError):
            result = orchestrator._check_godot_exists("nonexistent")
            
            assert result is False
    
    def test_read_coverage_data_valid_json(self, config, temp_dir):
        """Test reading valid coverage data"""
        orchestrator = CoverageOrchestrator(config)
        
        _, _, output_dir = temp_dir
        coverage_data_path = output_dir / "coverage_data.json"
        
        test_data = {
            "total_percent": 75.0,
            "total_covered": 15,
            "total_lines": 20
        }
        coverage_data_path.write_text(json.dumps(test_data))
        
        result = orchestrator._read_coverage_data(coverage_data_path)
        
        assert result == test_data
    
    def test_read_coverage_data_invalid_json(self, config, temp_dir):
        """Test reading invalid JSON raises error"""
        orchestrator = CoverageOrchestrator(config)
        
        _, _, output_dir = temp_dir
        coverage_data_path = output_dir / "coverage_data.json"
        coverage_data_path.write_text("invalid json{")
        
        with pytest.raises(json.JSONDecodeError):
            orchestrator._read_coverage_data(coverage_data_path)
    
    def test_display_summary_basic(self, config, capsys):
        """Test coverage summary display"""
        orchestrator = CoverageOrchestrator(config)
        
        coverage_stats = {
            "total_percent": 72.5,
            "total_covered": 145,
            "total_lines": 200,
            "files": []
        }
        
        orchestrator._display_summary(coverage_stats)
        
        captured = capsys.readouterr()
        assert "Coverage Report" in captured.out
        assert "72.5%" in captured.out
        assert "145/200" in captured.out
    
    def test_display_summary_with_files(self, config, capsys):
        """Test coverage summary with per-file breakdown"""
        orchestrator = CoverageOrchestrator(config)
        
        coverage_stats = {
            "total_percent": 75.0,
            "total_covered": 15,
            "total_lines": 20,
            "files": [
                {
                    "file": "test.gd",
                    "percent": 75.0,
                    "covered": 15,
                    "total": 20
                }
            ]
        }
        
        orchestrator._display_summary(coverage_stats)
        
        captured = capsys.readouterr()
        assert "test.gd" in captured.out
    
    def test_coverage_run_result_dataclass(self):
        """Test CoverageRunResult dataclass"""
        result = CoverageRunResult(
            success=True,
            test_exit_code=0,
            coverage_percent=75.0,
            covered_lines=15,
            total_lines=20
        )
        
        assert result.success
        assert result.test_exit_code == 0
        assert result.coverage_percent == 75.0
        assert result.errors == []
    
    def test_coverage_run_result_with_errors(self):
        """Test CoverageRunResult with errors"""
        result = CoverageRunResult(
            success=False,
            test_exit_code=2,
            errors=["Instrumentation failed"]
        )
        
        assert not result.success
        assert len(result.errors) == 1
        assert result.errors[0] == "Instrumentation failed"
    
    @patch('gdsentry.coverage.orchestrator.Instrumenter')
    def test_instrument_files_calls_instrumenter(self, mock_instrumenter_class, config):
        """Test _instrument_files calls instrumenter"""
        orchestrator = CoverageOrchestrator(config)
        
        mock_result = ProjectInstrumentResult(
            success=True,
            files_instrumented=5,
            instrumented_lines=100,
            total_lines=120
        )
        orchestrator.instrumenter.instrument_project = Mock(return_value=mock_result)
        
        result = orchestrator._instrument_files()
        
        assert result.success
        assert result.files_instrumented == 5
        orchestrator.instrumenter.instrument_project.assert_called_once()
    
    @patch('gdsentry.coverage.orchestrator.Instrumenter')
    def test_create_tracker_singleton_calls_instrumenter(self, mock_instrumenter_class, config):
        """Test _create_tracker_singleton calls instrumenter"""
        orchestrator = CoverageOrchestrator(config)
        orchestrator.instrumenter.create_tracker_singleton = Mock(return_value=True)
        
        result = orchestrator._create_tracker_singleton()
        
        assert result is True
        orchestrator.instrumenter.create_tracker_singleton.assert_called_once()
    
    def test_signal_handler_sets_interrupted_flag(self, config):
        """Test signal handler sets interrupted flag"""
        orchestrator = CoverageOrchestrator(config)
        
        assert not orchestrator._interrupted
        
        # Can't easily test sys.exit(130), but we can test the flag
        with patch('sys.exit'):
            orchestrator._signal_handler(2, None)
        
        assert orchestrator._interrupted
    
    @patch('subprocess.Popen')
    @patch('gdsentry.coverage.orchestrator.CoverageOrchestrator._check_godot_exists')
    def test_launch_godot_success(self, mock_check, mock_popen, config):
        """Test successful Godot launch"""
        orchestrator = CoverageOrchestrator(config)
        
        mock_check.return_value = True
        mock_process = Mock()
        mock_process.stdout = []
        mock_process.wait.return_value = 0
        mock_popen.return_value = mock_process
        
        exit_code = orchestrator._launch_godot([])
        
        assert exit_code == 0
        mock_popen.assert_called_once()
    
    @patch('gdsentry.coverage.orchestrator.CoverageOrchestrator._check_godot_exists')
    def test_launch_godot_not_found(self, mock_check, config):
        """Test Godot not found error"""
        orchestrator = CoverageOrchestrator(config)
        
        mock_check.return_value = False
        
        exit_code = orchestrator._launch_godot([])
        
        assert exit_code == 2
    
    def test_orchestrator_has_instrumenter(self, config):
        """Test orchestrator has instrumenter"""
        orchestrator = CoverageOrchestrator(config)
        
        assert hasattr(orchestrator, 'instrumenter')
        assert orchestrator.instrumenter is not None
    
    def test_orchestrator_has_config(self, config):
        """Test orchestrator has config"""
        orchestrator = CoverageOrchestrator(config)
        
        assert orchestrator.config == config
