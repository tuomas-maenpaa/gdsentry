extends Node

# GDSentry Coverage Analyzer
# Analyzes coverage data and computes statistics

## Analysis Functions

static func analyze_coverage_data(coverage_data: Dictionary) -> Dictionary:
	"""
	Analyze complete coverage dataset.
	
	Args:
		coverage_data: Full coverage data from tracker
		              Format: { "file.gd": { line_num: hit_count } }
	
	Returns:
		Dictionary with structure:
		{
			"total_covered": int,
			"total_lines": int,
			"total_percent": float,
			"files": Array[Dictionary]  # Per-file statistics
		}
	"""
	if coverage_data == null or coverage_data.is_empty():
		return {
			"total_covered": 0,
			"total_lines": 0,
			"total_percent": 0.0,
			"files": []
		}
	
	var total_covered = 0
	var total_lines = 0
	var file_summaries = []
	
	for file_path in coverage_data.keys():
		var file_data = coverage_data[file_path]
		
		if file_data == null or not file_data is Dictionary:
			push_warning("Invalid file data for: %s" % file_path)
			continue
		
		var file_stats = compute_file_coverage(file_data)
		
		total_covered += file_stats["covered"]
		total_lines += file_stats["total"]
		
		file_summaries.append({
			"file": file_path,
			"covered": file_stats["covered"],
			"total": file_stats["total"],
			"percent": file_stats["percent"],
			"missed_lines": get_missed_lines(file_data)
		})
	
	var total_percent = 0.0
	if total_lines > 0:
		total_percent = (float(total_covered) / float(total_lines)) * 100.0
	
	return {
		"total_covered": total_covered,
		"total_lines": total_lines,
		"total_percent": total_percent,
		"files": file_summaries
	}


static func compute_file_coverage(file_data: Dictionary) -> Dictionary:
	"""
	Compute coverage statistics for a single file.
	
	Args:
		file_data: Line data for one file { line_num: hit_count }
	
	Returns:
		Dictionary: { "covered": int, "total": int, "percent": float }
	"""
	if file_data == null or file_data.is_empty():
		return {
			"covered": 0,
			"total": 0,
			"percent": 0.0
		}
	
	var covered = 0
	var total = file_data.size()
	
	for line_num in file_data.keys():
		var hit_count = file_data[line_num]
		
		# Validate hit count is a number
		if typeof(hit_count) != TYPE_INT and typeof(hit_count) != TYPE_FLOAT:
			push_warning("Invalid hit count for line %s: %s" % [line_num, hit_count])
			continue
		
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
	
	Args:
		file_data: Line data for one file { line_num: hit_count }
	
	Returns:
		Array[int]: Sorted array of missed line numbers
	"""
	if file_data == null or file_data.is_empty():
		return []
	
	var missed = []
	
	for line_num in file_data.keys():
		var hit_count = file_data[line_num]
		
		# Validate types
		if typeof(hit_count) != TYPE_INT and typeof(hit_count) != TYPE_FLOAT:
			continue
		
		if hit_count == 0:
			# Ensure line_num is treated as int
			if typeof(line_num) == TYPE_INT:
				missed.append(line_num)
			elif typeof(line_num) == TYPE_STRING:
				# Handle string keys (from JSON)
				var line_int = int(line_num)
				if line_int > 0:
					missed.append(line_int)
	
	# Sort line numbers for easier reading
	missed.sort()
	return missed


static func get_coverage_summary(analysis_result: Dictionary) -> String:
	"""
	Generate human-readable coverage summary.
	
	Args:
		analysis_result: Result from analyze_coverage_data()
	
	Returns:
		String: Formatted summary text
	"""
	if analysis_result == null or analysis_result.is_empty():
		return "No coverage data available"
	
	var total_covered = analysis_result.get("total_covered", 0)
	var total_lines = analysis_result.get("total_lines", 0)
	var total_percent = analysis_result.get("total_percent", 0.0)
	var files = analysis_result.get("files", [])
	
	var summary = "Coverage Summary:\n"
	summary += "  Total: %d/%d lines (%.1f%%)\n" % [total_covered, total_lines, total_percent]
	summary += "  Files: %d\n" % files.size()
	
	return summary
