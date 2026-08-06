extends SceneTree

# Test HTML reporter - generate and write HTML files

func _init():
	var analyzer = preload("res://spike-2-gdscript-reporting/coverage_analyzer_prototype.gd")
	var reporter = preload("res://spike-2-gdscript-reporting/coverage_reporter_prototype.gd")
	
	print("=== Coverage Reporter Test ===\n")
	
	# Get mock data and analyze
	var coverage_data = analyzer.get_mock_coverage_data()
	var aggregate = analyzer.aggregate_total_coverage(coverage_data)
	
	print("Analyzed coverage: %.1f%% (%d/%d lines)\n" % [
		aggregate["percent"],
		aggregate["covered"],
		aggregate["total"]
	])
	
	# Test 1: Generate summary HTML
	print("--- Test 1: Generate Summary HTML ---")
	var summary_html = reporter.generate_summary_html(aggregate)
	print("Generated summary HTML: %d characters" % summary_html.length())
	
	# Check for key HTML elements
	var has_doctype = summary_html.contains("<!DOCTYPE html>")
	var has_title = summary_html.contains("Coverage Report")
	var has_table = summary_html.contains("<table>")
	var has_coverage = summary_html.contains("Total Coverage:")
	
	if has_doctype and has_title and has_table and has_coverage:
		print("✅ Summary HTML structure valid")
	else:
		print("❌ ERROR: Summary HTML missing key elements")
	
	print()
	
	# Test 2: Write summary HTML to disk
	print("--- Test 2: Write Summary HTML to Disk ---")
	var output_path = ".gdsentry/coverage/spike_report.html"
	var success = reporter.write_html_file(output_path, summary_html)
	
	if success:
		print("✅ Summary HTML written to: %s" % output_path)
		
		# Verify file exists
		if FileAccess.file_exists(output_path):
			var file_size = FileAccess.get_file_as_bytes(output_path).size()
			print("   File size: %d bytes" % file_size)
		else:
			print("❌ ERROR: File not found after writing")
	else:
		print("❌ ERROR: Failed to write HTML file")
	
	print()
	
	# Test 3: Generate file detail HTML (for first file)
	print("--- Test 3: Generate File Detail HTML ---")
	var test_file = "math.gd"
	var file_data = coverage_data[test_file]
	
	# Create mock source lines for math.gd
	var source_lines = []
	for i in range(50):
		source_lines.append("  line %d content (mock)" % (i + 1))
	
	var file_html = reporter.generate_file_html(test_file, file_data, source_lines)
	print("Generated file HTML for %s: %d characters" % [test_file, file_html.length()])
	
	# Check for key elements
	var has_line_num = file_html.contains("line-num")
	var has_hit_count = file_html.contains("hit-count")
	var has_source = file_html.contains("source")
	
	if has_line_num and has_hit_count and has_source:
		print("✅ File HTML structure valid")
	else:
		print("❌ ERROR: File HTML missing key elements")
	
	# Write file detail HTML
	var file_output_path = ".gdsentry/coverage/math.gd.html"
	var file_success = reporter.write_html_file(file_output_path, file_html)
	
	if file_success:
		print("✅ File detail HTML written to: %s" % file_output_path)
	else:
		print("❌ ERROR: Failed to write file detail HTML")
	
	print()
	print("=== Test Complete ===")
	print("Open .gdsentry/coverage/spike_report.html in browser to view")
	
	quit()
