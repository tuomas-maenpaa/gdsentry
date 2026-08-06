extends SceneTree

# Quick test script to verify mock data structure

func _init():
	var analyzer = preload("res://spike-2-gdscript-reporting/coverage_analyzer_prototype.gd")
	analyzer.test_mock_data()
	quit()
