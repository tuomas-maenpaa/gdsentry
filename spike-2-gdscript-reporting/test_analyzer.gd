extends SceneTree

# Test coverage analyzer logic correctness

func _init():
	var analyzer = preload("res://spike-2-gdscript-reporting/coverage_analyzer_prototype.gd")
	
	print("=== Coverage Analyzer Logic Test ===\n")
	
	# Get mock data
	var data = analyzer.get_mock_coverage_data()
	print("Loaded mock data for %d files\n" % data.size())
	
	# Test 1: compute_file_coverage for each file
	print("--- Test 1: File Coverage Computation ---")
	for file_path in data.keys():
		var file_data = data[file_path]
		var cov = analyzer.compute_file_coverage(file_data)
		
		print("%s:" % file_path)
		print("  Covered: %d / %d lines" % [cov["covered"], cov["total"]])
		print("  Coverage: %.2f%%" % cov["percent"])
		
		# Manual verification
		var expected_covered = 0
		for line in file_data.keys():
			if file_data[line] > 0:
				expected_covered += 1
		
		if cov["covered"] == expected_covered and cov["total"] == file_data.size():
			print("  ✅ Calculation correct")
		else:
			print("  ❌ ERROR: Expected %d covered, got %d" % [expected_covered, cov["covered"]])
	
	print()
	
	# Test 2: get_missed_lines
	print("--- Test 2: Missed Line Detection ---")
	for file_path in data.keys():
		var file_data = data[file_path]
		var missed = analyzer.get_missed_lines(file_data)
		
		# Manual count of missed lines
		var expected_missed_count = 0
		for line in file_data.keys():
			if file_data[line] == 0:
				expected_missed_count += 1
		
		print("%s: %d missed lines" % [file_path, missed.size()])
		if missed.size() == expected_missed_count:
			print("  ✅ Missed line count correct")
			# Show first few missed lines
			var sample = missed.slice(0, min(5, missed.size()) - 1)
			print("  Sample: %s" % str(sample))
		else:
			print("  ❌ ERROR: Expected %d missed, got %d" % [expected_missed_count, missed.size()])
	
	print()
	
	# Test 3: aggregate_total_coverage
	print("--- Test 3: Total Aggregation ---")
	var aggregate = analyzer.aggregate_total_coverage(data)
	
	print("Total Coverage:")
	print("  Covered: %d / %d lines" % [aggregate["covered"], aggregate["total"]])
	print("  Coverage: %.2f%%" % aggregate["percent"])
	
	# Manual verification
	var manual_covered = 0
	var manual_total = 0
	for file_path in data.keys():
		var file_data = data[file_path]
		manual_total += file_data.size()
		for line in file_data.keys():
			if file_data[line] > 0:
				manual_covered += 1
	
	if aggregate["covered"] == manual_covered and aggregate["total"] == manual_total:
		print("  ✅ Aggregation correct")
	else:
		print("  ❌ ERROR: Expected %d/%d, got %d/%d" % [manual_covered, manual_total, aggregate["covered"], aggregate["total"]])
	
	print("\nFile summaries:")
	for file_sum in aggregate["files"]:
		print("  %s: %.1f%% (%d/%d)" % [
			file_sum["file"],
			file_sum["percent"],
			file_sum["covered"],
			file_sum["total"]
		])
	
	print("\n=== All Tests Complete ===")
	quit()
