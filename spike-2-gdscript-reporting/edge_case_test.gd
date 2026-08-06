extends SceneTree

# Edge Case Testing: 0%, 100%, empty, special characters

var analyzer = preload("res://spike-2-gdscript-reporting/coverage_analyzer_prototype.gd")
var reporter = preload("res://spike-2-gdscript-reporting/coverage_reporter_prototype.gd")

func _init():
	print("=== EDGE CASE TESTS ===\n")
	
	var all_passed = true
	
	all_passed = test_zero_coverage() and all_passed
	all_passed = test_full_coverage() and all_passed
	all_passed = test_empty_file() and all_passed
	all_passed = test_single_line() and all_passed
	all_passed = test_special_characters() and all_passed
	all_passed = test_large_file() and all_passed
	
	print()
	if all_passed:
		print("✅ ALL EDGE CASE TESTS PASSED")
	else:
		print("❌ SOME TESTS FAILED")
	
	quit(0 if all_passed else 1)


func test_zero_coverage() -> bool:
	"""Test file with 0% coverage"""
	print("Test 1: 0% Coverage")
	print("-" .repeat(50))
	
	var file_data = {}
	for line in range(1, 51):
		file_data[line] = 0  # All lines missed
	
	var cov = analyzer.compute_file_coverage(file_data)
	var missed = analyzer.get_missed_lines(file_data)
	
	var passed = true
	
	# Check coverage is 0%
	if cov["percent"] == 0.0 and cov["covered"] == 0 and cov["total"] == 50:
		print("✅ Coverage calculation: 0% (0/50)")
	else:
		print("❌ ERROR: Expected 0%, got %.1f%%" % cov["percent"])
		passed = false
	
	# Check all lines are missed
	if missed.size() == 50:
		print("✅ Missed lines: 50 (all)")
	else:
		print("❌ ERROR: Expected 50 missed, got %d" % missed.size())
		passed = false
	
	# Test HTML generation
	var source_lines = []
	for i in range(50):
		source_lines.append("  line content")
	
	var html = reporter.generate_file_html("zero_coverage.gd", file_data, source_lines)
	if html.contains("zero_coverage.gd") and html.length() > 0:
		print("✅ HTML generation works")
	else:
		print("❌ ERROR: HTML generation failed")
		passed = false
	
	print()
	return passed


func test_full_coverage() -> bool:
	"""Test file with 100% coverage"""
	print("Test 2: 100% Coverage")
	print("-" .repeat(50))
	
	var file_data = {}
	for line in range(1, 51):
		file_data[line] = line % 5 + 1  # All lines hit
	
	var cov = analyzer.compute_file_coverage(file_data)
	var missed = analyzer.get_missed_lines(file_data)
	
	var passed = true
	
	# Check coverage is 100%
	if cov["percent"] == 100.0 and cov["covered"] == 50 and cov["total"] == 50:
		print("✅ Coverage calculation: 100% (50/50)")
	else:
		print("❌ ERROR: Expected 100%, got %.1f%%" % cov["percent"])
		passed = false
	
	# Check no lines are missed
	if missed.size() == 0:
		print("✅ Missed lines: 0 (none)")
	else:
		print("❌ ERROR: Expected 0 missed, got %d" % missed.size())
		passed = false
	
	# Test HTML generation
	var source_lines = []
	for i in range(50):
		source_lines.append("  line content")
	
	var html = reporter.generate_file_html("full_coverage.gd", file_data, source_lines)
	if html.contains("full_coverage.gd") and html.length() > 0:
		print("✅ HTML generation works")
	else:
		print("❌ ERROR: HTML generation failed")
		passed = false
	
	print()
	return passed


func test_empty_file() -> bool:
	"""Test empty file (no lines)"""
	print("Test 3: Empty File")
	print("-" .repeat(50))
	
	var file_data = {}  # No lines
	
	var cov = analyzer.compute_file_coverage(file_data)
	var missed = analyzer.get_missed_lines(file_data)
	
	var passed = true
	
	# Check coverage is 0% with 0 total lines
	if cov["percent"] == 0.0 and cov["covered"] == 0 and cov["total"] == 0:
		print("✅ Coverage calculation: 0% (0/0)")
	else:
		print("❌ ERROR: Expected 0/0, got %d/%d" % [cov["covered"], cov["total"]])
		passed = false
	
	# Check no missed lines
	if missed.size() == 0:
		print("✅ Missed lines: 0")
	else:
		print("❌ ERROR: Expected 0 missed, got %d" % missed.size())
		passed = false
	
	# Test HTML generation
	var source_lines = []
	var html = reporter.generate_file_html("empty.gd", file_data, source_lines)
	if html.contains("empty.gd") and html.length() > 0:
		print("✅ HTML generation works")
	else:
		print("❌ ERROR: HTML generation failed")
		passed = false
	
	print()
	return passed


func test_single_line() -> bool:
	"""Test single line file"""
	print("Test 4: Single Line File")
	print("-" .repeat(50))
	
	var file_data = {1: 5}  # One line, hit 5 times
	
	var cov = analyzer.compute_file_coverage(file_data)
	var missed = analyzer.get_missed_lines(file_data)
	
	var passed = true
	
	# Check coverage is 100%
	if cov["percent"] == 100.0 and cov["covered"] == 1 and cov["total"] == 1:
		print("✅ Coverage calculation: 100% (1/1)")
	else:
		print("❌ ERROR: Expected 100% (1/1), got %.1f%% (%d/%d)" % [cov["percent"], cov["covered"], cov["total"]])
		passed = false
	
	# Check no missed lines
	if missed.size() == 0:
		print("✅ Missed lines: 0")
	else:
		print("❌ ERROR: Expected 0 missed, got %d" % missed.size())
		passed = false
	
	print()
	return passed


func test_special_characters() -> bool:
	"""Test source code with HTML special characters"""
	print("Test 5: Special Characters in Source")
	print("-" .repeat(50))
	
	var file_data = {1: 1, 2: 0, 3: 1}
	
	# Source with HTML special chars
	var source_lines = [
		"if x < 10 && y > 5:",
		"  print(\"<html>\")",
		"  return x & 0xFF"
	]
	
	var html = reporter.generate_file_html("special_chars.gd", file_data, source_lines)
	
	var passed = true
	
	# Check HTML escaping
	if html.contains("&lt;") and html.contains("&gt;") and html.contains("&quot;"):
		print("✅ HTML special characters escaped correctly")
	else:
		print("❌ ERROR: HTML special characters not escaped")
		passed = false
	
	# Check HTML is valid (contains expected structure)
	if html.contains("<!DOCTYPE html>") and html.contains("special_chars.gd"):
		print("✅ HTML structure valid")
	else:
		print("❌ ERROR: HTML structure invalid")
		passed = false
	
	print()
	return passed


func test_large_file() -> bool:
	"""Test very large file (5000 lines)"""
	print("Test 6: Large File (5000 lines)")
	print("-" .repeat(50))
	
	var file_data = {}
	for line in range(1, 5001):
		file_data[line] = 1 if (line % 2 == 0) else 0  # 50% coverage
	
	var start_time = Time.get_ticks_msec()
	var cov = analyzer.compute_file_coverage(file_data)
	var missed = analyzer.get_missed_lines(file_data)
	var analysis_time = Time.get_ticks_msec() - start_time
	
	var passed = true
	
	# Check coverage
	if cov["percent"] == 50.0 and cov["covered"] == 2500 and cov["total"] == 5000:
		print("✅ Coverage calculation: 50% (2500/5000)")
	else:
		print("❌ ERROR: Expected 50%, got %.1f%%" % cov["percent"])
		passed = false
	
	# Check missed lines
	if missed.size() == 2500:
		print("✅ Missed lines: 2500")
	else:
		print("❌ ERROR: Expected 2500 missed, got %d" % missed.size())
		passed = false
	
	# Check performance
	print("   Analysis time: %d ms" % analysis_time)
	if analysis_time < 100:  # Should be <100ms
		print("✅ Performance acceptable")
	else:
		print("⚠️  WARNING: Analysis took %d ms (expected <100ms)" % analysis_time)
	
	# Test HTML generation (with limited source)
	var source_lines = []
	for i in range(5000):
		source_lines.append("  line %d content" % (i + 1))
	
	start_time = Time.get_ticks_msec()
	var html = reporter.generate_file_html("large.gd", file_data, source_lines)
	var html_time = Time.get_ticks_msec() - start_time
	
	print("   HTML generation time: %d ms" % html_time)
	print("   HTML size: %.1f KB" % (float(html.length()) / 1024.0))
	
	if html.length() > 0:
		print("✅ HTML generation works")
	else:
		print("❌ ERROR: HTML generation failed")
		passed = false
	
	print()
	return passed
