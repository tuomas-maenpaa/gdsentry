extends SceneTree

# End-to-End Test: Coverage Tracker → Analyzer → Reporter

func _init():
	print("=== SPIKE 2: End-to-End Coverage Pipeline Test ===\n")
	
	var analyzer = preload("res://spike-2-gdscript-reporting/coverage_analyzer_prototype.gd")
	var reporter = preload("res://spike-2-gdscript-reporting/coverage_reporter_prototype.gd")
	
	# Phase 1: Mock Tracker Data (simulates what tracker would produce)
	print("Phase 1: Mock Coverage Tracking")
	print("-" .repeat(50))
	var start_time = Time.get_ticks_msec()
	var coverage_data = analyzer.get_mock_coverage_data()
	var track_time = Time.get_ticks_msec() - start_time
	print("Generated mock coverage data for %d files" % coverage_data.size())
	print("Time: %d ms\n" % track_time)
	
	# Phase 2: Coverage Analysis
	print("Phase 2: Coverage Analysis")
	print("-" .repeat(50))
	start_time = Time.get_ticks_msec()
	
	# Analyze each file
	var file_results = {}
	for file_path in coverage_data.keys():
		var file_data = coverage_data[file_path]
		var cov = analyzer.compute_file_coverage(file_data)
		var missed = analyzer.get_missed_lines(file_data)
		
		file_results[file_path] = {
			"coverage": cov,
			"missed_lines": missed
		}
	
	# Aggregate total
	var aggregate = analyzer.aggregate_total_coverage(coverage_data)
	
	var analysis_time = Time.get_ticks_msec() - start_time
	print("Analyzed %d files" % coverage_data.size())
	print("Total: %.1f%% coverage (%d/%d lines)" % [
		aggregate["percent"],
		aggregate["covered"],
		aggregate["total"]
	])
	print("Time: %d ms\n" % analysis_time)
	
	# Show per-file results
	for file_path in file_results.keys():
		var result = file_results[file_path]
		var cov = result["coverage"]
		var missed = result["missed_lines"]
		print("  %s: %.1f%% (%d missed)" % [
			file_path,
			cov["percent"],
			missed.size()
		])
	print()
	
	# Phase 3: HTML Report Generation
	print("Phase 3: HTML Report Generation")
	print("-" .repeat(50))
	start_time = Time.get_ticks_msec()
	
	# Generate summary HTML
	var summary_html = reporter.generate_summary_html(aggregate)
	print("Generated summary HTML: %d bytes" % summary_html.length())
	
	# Generate file detail HTML for each file
	var total_file_html_size = 0
	for file_path in coverage_data.keys():
		var file_data = coverage_data[file_path]
		
		# Create mock source lines
		var source_lines = []
		for line_num in range(1, file_data.size() + 1):
			source_lines.append("  // Line %d: mock source code content" % line_num)
		
		var file_html = reporter.generate_file_html(file_path, file_data, source_lines)
		total_file_html_size += file_html.length()
	
	var generation_time = Time.get_ticks_msec() - start_time
	print("Generated %d file detail HTML reports" % coverage_data.size())
	print("Total HTML size: %d bytes" % (summary_html.length() + total_file_html_size))
	print("Time: %d ms\n" % generation_time)
	
	# Phase 4: Write to Disk
	print("Phase 4: Write HTML to Disk")
	print("-" .repeat(50))
	start_time = Time.get_ticks_msec()
	
	# Write summary
	var summary_path = ".gdsentry/coverage/e2e_report.html"
	var write_success = reporter.write_html_file(summary_path, summary_html)
	
	if not write_success:
		print("❌ ERROR: Failed to write summary HTML")
		quit(1)
		return
	
	print("✅ Wrote summary: %s" % summary_path)
	
	# Write file details
	var files_written = 0
	for file_path in coverage_data.keys():
		var file_data = coverage_data[file_path]
		
		# Mock source lines
		var source_lines = []
		for line_num in range(1, file_data.size() + 1):
			source_lines.append("  // Line %d: mock source code" % line_num)
		
		var file_html = reporter.generate_file_html(file_path, file_data, source_lines)
		var file_output_path = ".gdsentry/coverage/e2e_%s.html" % file_path.replace(".", "_")
		
		if reporter.write_html_file(file_output_path, file_html):
			files_written += 1
	
	var write_time = Time.get_ticks_msec() - start_time
	print("✅ Wrote %d file detail reports" % files_written)
	print("Time: %d ms\n" % write_time)
	
	# Summary
	print("=" .repeat(50))
	print("PIPELINE SUMMARY")
	print("=" .repeat(50))
	var total_time = track_time + analysis_time + generation_time + write_time
	print("Files processed: %d" % coverage_data.size())
	print("Total lines: %d" % aggregate["total"])
	print("Coverage: %.1f%%" % aggregate["percent"])
	print()
	print("Timing Breakdown:")
	print("  Tracking (mock):   %3d ms" % track_time)
	print("  Analysis:          %3d ms" % analysis_time)
	print("  HTML generation:   %3d ms" % generation_time)
	print("  Disk I/O:          %3d ms" % write_time)
	print("  ---")
	print("  Total:             %3d ms" % total_time)
	print()
	print("✅ End-to-end pipeline successful!")
	print()
	print("View report: .gdsentry/coverage/e2e_report.html")
	
	quit()
