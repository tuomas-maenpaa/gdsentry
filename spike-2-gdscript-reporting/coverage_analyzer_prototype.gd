extends Node

# Coverage Analyzer Prototype
# Tests data structures and analysis logic for code coverage

## Mock Coverage Tracker Data
## Format: { "file.gd": { line_num: hit_count } }

static func get_mock_coverage_data() -> Dictionary:
	"""
	Create mock coverage data for 3 files:
	- math.gd: 50 lines, ~70% coverage
	- player.gd: 120 lines, ~75% coverage  
	- enemy.gd: 80 lines, ~65% coverage
	"""
	var coverage_data = {}
	
	# File 1: math.gd (50 lines, 35 covered = 70%)
	coverage_data["math.gd"] = {}
	for line in range(1, 51):
		if line <= 35:
			# Lines 1-35 are hit (various hit counts)
			coverage_data["math.gd"][line] = (line % 5) + 1  # 1-5 hits
		else:
			# Lines 36-50 are missed
			coverage_data["math.gd"][line] = 0
	
	# File 2: player.gd (120 lines, 90 covered = 75%)
	coverage_data["player.gd"] = {}
	for line in range(1, 121):
		if line <= 90:
			# Lines 1-90 are hit
			coverage_data["player.gd"][line] = (line % 7) + 1  # 1-7 hits
		else:
			# Lines 91-120 are missed
			coverage_data["player.gd"][line] = 0
	
	# File 3: enemy.gd (80 lines, 52 covered = 65%)
	coverage_data["enemy.gd"] = {}
	for line in range(1, 81):
		if line <= 52:
			# Lines 1-52 are hit
			coverage_data["enemy.gd"][line] = (line % 4) + 1  # 1-4 hits
		else:
			# Lines 53-80 are missed
			coverage_data["enemy.gd"][line] = 0
	
	return coverage_data


## Analysis Functions

static func compute_file_coverage(file_data: Dictionary) -> Dictionary:
	"""
	Compute coverage statistics for a single file.
	Returns: { "covered": int, "total": int, "percent": float }
	"""
	var covered = 0
	var total = file_data.size()
	
	for line_num in file_data.keys():
		var hit_count = file_data[line_num]
		if hit_count > 0:
			covered += 1
	
	var percent = 0.0
	if total > 0:
		percent = (float(covered) / float(total)) * 100.0
	
	return {
		"covered": covered,
		"total": total,
		"percent": percent
	}


static func get_missed_lines(file_data: Dictionary) -> Array:
	"""
	Get array of line numbers that were not hit.
	Returns: Array[int]
	"""
	var missed = []
	
	for line_num in file_data.keys():
		var hit_count = file_data[line_num]
		if hit_count == 0:
			missed.append(line_num)
	
	# Sort line numbers for easier reading
	missed.sort()
	return missed


static func aggregate_total_coverage(all_files: Dictionary) -> Dictionary:
	"""
	Aggregate coverage across all files.
	Returns: { "covered": int, "total": int, "percent": float, "files": Array }
	"""
	var total_covered = 0
	var total_lines = 0
	var file_summaries = []
	
	for file_path in all_files.keys():
		var file_data = all_files[file_path]
		var file_cov = compute_file_coverage(file_data)
		
		total_covered += file_cov["covered"]
		total_lines += file_cov["total"]
		
		file_summaries.append({
			"file": file_path,
			"covered": file_cov["covered"],
			"total": file_cov["total"],
			"percent": file_cov["percent"]
		})
	
	var total_percent = 0.0
	if total_lines > 0:
		total_percent = (float(total_covered) / float(total_lines)) * 100.0
	
	return {
		"covered": total_covered,
		"total": total_lines,
		"percent": total_percent,
		"files": file_summaries
	}


## Test function
static func test_mock_data():
	"""Test that mock data is structured correctly"""
	var data = get_mock_coverage_data()
	
	print("=== Mock Coverage Data Test ===")
	print("Files: ", data.keys())
	
	for file in data.keys():
		var file_data = data[file]
		print("\n%s: %d lines" % [file, file_data.size()])
		
		var hit_count = 0
		var miss_count = 0
		
		for line in file_data.keys():
			if file_data[line] > 0:
				hit_count += 1
			else:
				miss_count += 1
		
		var percent = (float(hit_count) / float(file_data.size())) * 100.0
		print("  Hit: %d, Missed: %d, Coverage: %.1f%%" % [hit_count, miss_count, percent])
	
	print("\n✅ Mock data structure validated")
