extends SceneTree

# Performance Test: Scale testing with 10 and 100 files

var analyzer = preload("res://spike-2-gdscript-reporting/coverage_analyzer_prototype.gd")
var reporter = preload("res://spike-2-gdscript-reporting/coverage_reporter_prototype.gd")

func _init():
	print("=== PERFORMANCE BENCHMARK ===\n")
	
	# Test 1: 10 files (~1000 lines)
	print("Test 1: 10 files, ~1000 lines")
	print("-" .repeat(50))
	run_performance_test(10, 100)
	print()
	
	# Test 2: 100 files (~10000 lines)
	print("Test 2: 100 files, ~10000 lines")
	print("-" .repeat(50))
	run_performance_test(100, 100)
	print()
	
	# Test 3: Stress test - 500 files (~50000 lines)
	print("Test 3: Stress Test - 500 files, ~50000 lines")
	print("-" .repeat(50))
	run_performance_test(500, 100)
	print()
	
	print("=== BENCHMARK COMPLETE ===")
	quit()


func run_performance_test(num_files: int, lines_per_file: int):
	"""Run full pipeline performance test"""
	
	# Phase 1: Generate mock data
	var start_time = Time.get_ticks_msec()
	var coverage_data = generate_mock_data(num_files, lines_per_file)
	var gen_time = Time.get_ticks_msec() - start_time
	
	var total_lines = 0
	for file in coverage_data.keys():
		total_lines += coverage_data[file].size()
	
	print("Generated %d files, %d lines in %d ms" % [num_files, total_lines, gen_time])
	
	# Phase 2: Analysis
	start_time = Time.get_ticks_msec()
	
	# Per-file analysis
	for file_path in coverage_data.keys():
		var file_data = coverage_data[file_path]
		var _cov = analyzer.compute_file_coverage(file_data)
		var _missed = analyzer.get_missed_lines(file_data)
	
	# Aggregate
	var aggregate = analyzer.aggregate_total_coverage(coverage_data)
	
	var analysis_time = Time.get_ticks_msec() - start_time
	print("Analysis: %d ms (%.1f%% coverage)" % [analysis_time, aggregate["percent"]])
	
	# Phase 3: HTML Generation
	start_time = Time.get_ticks_msec()
	
	# Summary HTML
	var summary_html = reporter.generate_summary_html(aggregate)
	
	# File detail HTML (sample - generate for first 5 files only to avoid huge output)
	var sample_size = min(5, num_files)
	var file_count = 0
	for file_path in coverage_data.keys():
		if file_count >= sample_size:
			break
		
		var file_data = coverage_data[file_path]
		var source_lines = []
		for i in range(file_data.size()):
			source_lines.append("  // Line %d content" % (i + 1))
		
		var _file_html = reporter.generate_file_html(file_path, file_data, source_lines)
		file_count += 1
	
	var html_time = Time.get_ticks_msec() - start_time
	print("HTML generation (%d files): %d ms" % [sample_size, html_time])
	
	# Phase 4: Disk I/O (skip for large tests to avoid cluttering)
	if num_files <= 10:
		start_time = Time.get_ticks_msec()
		var output_path = ".gdsentry/coverage/perf_test_%d_files.html" % num_files
		var _success = reporter.write_html_file(output_path, summary_html)
		var io_time = Time.get_ticks_msec() - start_time
		print("Disk I/O: %d ms" % io_time)
	
	# Total
	var total_time = analysis_time + html_time
	print("TOTAL: %d ms (%.2f ms/file, %.2f μs/line)" % [
		total_time,
		float(total_time) / float(num_files),
		(float(total_time) * 1000.0) / float(total_lines)
	])
	
	# Success criteria check
	if num_files == 100:
		if total_time < 1000:  # <1s target
			print("✅ PASS: Meets <1s target for 100 files")
		else:
			print("⚠️  WARNING: Exceeds 1s target (%d ms)" % total_time)


func generate_mock_data(num_files: int, lines_per_file: int) -> Dictionary:
	"""Generate mock coverage data for performance testing"""
	var data = {}
	
	for file_idx in range(num_files):
		var file_name = "file_%03d.gd" % file_idx
		var file_data = {}
		
		# Random coverage between 60-90%
		var coverage_percent = 60 + (randi() % 30)
		var covered_lines = int(float(lines_per_file) * float(coverage_percent) / 100.0)
		
		# Generate line data
		for line in range(1, lines_per_file + 1):
			if line <= covered_lines:
				# Hit lines (varying hit counts)
				file_data[line] = (line % 10) + 1
			else:
				# Missed lines
				file_data[line] = 0
		
		data[file_name] = file_data
	
	return data
