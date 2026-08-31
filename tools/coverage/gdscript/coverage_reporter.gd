extends Node

# GDSentry Coverage Reporter
# Generates HTML coverage reports from analyzed coverage data

## Main API

static func generate_html_report(analysis: Dictionary, source_root: String, output_dir: String) -> bool:
	"""
	Generate complete HTML coverage report.
	
	Args:
		analysis: Result from CoverageAnalyzer.analyze_coverage_data()
		source_root: Path to original source files
		output_dir: Directory to write HTML files
	
	Returns:
		bool: true if successful, false otherwise
	"""
	if analysis == null or analysis.is_empty():
		push_error("Cannot generate report: analysis data is empty")
		return false
	
	# Create output directory
	if not DirAccess.dir_exists_absolute(output_dir):
		var err = DirAccess.make_dir_recursive_absolute(output_dir)
		if err != OK:
			push_error("Failed to create output directory: %s" % output_dir)
			return false
	
	# Generate summary HTML
	var summary_html = generate_summary_html(analysis)
	var summary_path = output_dir + "/index.html"
	if not write_html_file(summary_path, summary_html):
		push_error("Failed to write summary HTML: %s" % summary_path)
		return false
	
	# Generate per-file HTML
	var files = analysis.get("files", [])
	for file_info in files:
		var file_path = file_info.get("file", "")
		if file_path.is_empty():
			continue
		
		var file_slug = _generate_file_slug(file_path)
		var file_html_path = output_dir + "/" + file_slug + ".html"
		
		# Read source file
		var source_path = source_root + "/" + file_path
		var source_lines = _read_source_file(source_path)
		
		if source_lines.is_empty():
			push_warning("Could not read source file: %s" % source_path)
			# Create placeholder HTML
			source_lines = ["# Source file not found"]
		
		# Get line data from coverage_data (need to reconstruct from analysis)
		var line_data = {}
		var missed_lines = file_info.get("missed_lines", [])
		var total_lines = file_info.get("total", 0)
		
		# Mark all lines (hit = 1, missed = 0)
		for i in range(1, total_lines + 1):
			if i in missed_lines:
				line_data[i] = 0
			else:
				line_data[i] = 1  # Simplified: we don't have actual hit counts here
		
		var file_html = generate_file_html(file_path, line_data, source_lines, file_info)
		if not write_html_file(file_html_path, file_html):
			push_warning("Failed to write file HTML: %s" % file_html_path)
			# Continue with other files
	
	print("[Reporter] Generated HTML report: %s" % output_dir)
	return true


static func generate_summary_html(analysis: Dictionary) -> String:
	"""
	Generate HTML summary page with coverage statistics.
	
	Args:
		analysis: Result from CoverageAnalyzer.analyze_coverage_data()
	
	Returns:
		String: HTML content
	"""
	var html = PackedStringArray()
	
	# Header
	html.append("<!DOCTYPE html>")
	html.append("<html>")
	html.append("<head>")
	html.append("  <meta charset='utf-8'>")
	html.append("  <meta name='viewport' content='width=device-width, initial-scale=1.0'>")
	html.append("  <title>Coverage Report - GDSentry</title>")
	html.append(_get_summary_css())
	html.append("</head>")
	html.append("<body>")
	
	# Title
	html.append("  <h1>📊 Code Coverage Report</h1>")
	
	# Summary box
	var total_percent = analysis.get("total_percent", 0.0)
	var total_covered = analysis.get("total_covered", 0)
	var total_lines = analysis.get("total_lines", 0)
	var coverage_class = _get_coverage_class(total_percent)
	
	html.append("  <div class='summary'>")
	html.append("    <div class='total'>")
	html.append("      Total Coverage: <span class='%s'>%.1f%%</span>" % [coverage_class, total_percent])
	html.append("    </div>")
	html.append("    <p>%d / %d lines covered</p>" % [total_covered, total_lines])
	
	# Visual bar
	var bar_color = _get_bar_color(total_percent)
	html.append("    <div class='bar'>")
	html.append("      <div class='bar-fill' style='width: %.1f%%; background: %s;'></div>" % [
		total_percent, bar_color
	])
	html.append("    </div>")
	html.append("  </div>")
	
	# File table
	html.append("  <h2>Coverage by File</h2>")
	html.append("  <table>")
	html.append("    <thead>")
	html.append("      <tr>")
	html.append("        <th>File</th>")
	html.append("        <th>Coverage</th>")
	html.append("        <th>Lines</th>")
	html.append("        <th>Visual</th>")
	html.append("      </tr>")
	html.append("    </thead>")
	html.append("    <tbody>")
	
	# File rows
	var files = analysis.get("files", [])
	for file_info in files:
		var file_name = file_info.get("file", "unknown")
		var file_percent = file_info.get("percent", 0.0)
		var file_covered = file_info.get("covered", 0)
		var file_total = file_info.get("total", 0)
		var file_class = _get_coverage_class(file_percent)
		var file_bar_color = _get_bar_color(file_percent)
		var file_slug = _generate_file_slug(file_name)
		
		html.append("      <tr>")
		html.append("        <td><a href='%s.html'><strong>%s</strong></a></td>" % [file_slug, file_name])
		html.append("        <td class='percent %s'>%.1f%%</td>" % [file_class, file_percent])
		html.append("        <td>%d / %d</td>" % [file_covered, file_total])
		html.append("        <td>")
		html.append("          <div class='bar'>")
		html.append("            <div class='bar-fill' style='width: %.1f%%; background: %s;'></div>" % [
			file_percent, file_bar_color
		])
		html.append("          </div>")
		html.append("        </td>")
		html.append("      </tr>")
	
	html.append("    </tbody>")
	html.append("  </table>")
	
	# Footer
	var timestamp = Time.get_datetime_string_from_system()
	html.append("  <p class='footer'>")
	html.append("    Generated by GDSentry Coverage · %s" % timestamp)
	html.append("  </p>")
	html.append("</body>")
	html.append("</html>")
	
	return "\n".join(html)


static func generate_file_html(file_path: String, line_data: Dictionary, source_lines: Array, file_info: Dictionary) -> String:
	"""
	Generate HTML for line-by-line coverage view of a single file.
	
	Args:
		file_path: Name of the file
		line_data: { line_num: hit_count } dictionary
		source_lines: Array of source code lines
		file_info: File statistics from analysis
	
	Returns:
		String: HTML content
	"""
	var html = PackedStringArray()
	
	html.append("<!DOCTYPE html>")
	html.append("<html>")
	html.append("<head>")
	html.append("  <meta charset='utf-8'>")
	html.append("  <meta name='viewport' content='width=device-width, initial-scale=1.0'>")
	html.append("  <title>%s - Coverage</title>" % file_path)
	html.append(_get_file_css())
	html.append("</head>")
	html.append("<body>")
	
	# Header with back link
	html.append("  <div class='header'>")
	html.append("    <a href='index.html' class='back'>← Back to Summary</a>")
	html.append("    <h1>📄 %s</h1>" % file_path)
	
	# File stats
	var file_percent = file_info.get("percent", 0.0)
	var file_covered = file_info.get("covered", 0)
	var file_total = file_info.get("total", 0)
	var coverage_class = _get_coverage_class(file_percent)
	
	html.append("    <div class='stats'>")
	html.append("      Coverage: <span class='%s'>%.1f%%</span> (%d / %d lines)" % [
		coverage_class, file_percent, file_covered, file_total
	])
	html.append("    </div>")
	html.append("  </div>")
	
	# Line by line
	html.append("  <div class='code'>")
	for i in range(source_lines.size()):
		var line_num = i + 1
		var hit_count = line_data.get(line_num, -1)  # -1 = not tracked
		var source = source_lines[i] if i < source_lines.size() else ""
		
		var status_class = ""
		var hit_display = ""
		
		if hit_count == -1:
			# Line not tracked (non-executable)
			status_class = "not-tracked"
			hit_display = ""
		elif hit_count > 0:
			status_class = "hit"
			hit_display = str(hit_count)
		else:
			status_class = "miss"
			hit_display = "0"
		
		html.append("    <div class='line %s'>" % status_class)
		html.append("      <div class='line-num'>%d</div>" % line_num)
		html.append("      <div class='hit-count'>%s</div>" % hit_display)
		html.append("      <div class='source'>%s</div>" % _html_escape(source))
		html.append("    </div>")
	
	html.append("  </div>")
	html.append("</body>")
	html.append("</html>")
	
	return "\n".join(html)


static func write_html_file(file_path: String, html_content: String) -> bool:
	"""
	Write HTML content to file.
	
	Args:
		file_path: Path to write HTML file
		html_content: HTML content string
	
	Returns:
		bool: true if successful, false otherwise
	"""
	if file_path.is_empty() or html_content.is_empty():
		return false
	
	# Create directory if needed
	var dir = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			push_error("Failed to create directory: %s (error: %d)" % [dir, err])
			return false
	
	# Write file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("Failed to open file for writing: %s (error: %d)" % [file_path, error])
		return false
	
	file.store_string(html_content)
	file.close()
	
	return true


## Private Helper Functions

static func _read_source_file(file_path: String) -> Array:
	"""
	Read source file and return array of lines.
	
	Args:
		file_path: Path to source file
	
	Returns:
		Array: Lines of source code (empty if file not found)
	"""
	if not FileAccess.file_exists(file_path):
		return []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return []
	
	var lines = []
	while not file.eof_reached():
		var line = file.get_line()
		lines.append(line)
	
	file.close()
	return lines


static func _generate_file_slug(file_path: String) -> String:
	"""
	Generate URL-safe filename slug from file path.
	
	Args:
		file_path: Original file path (e.g., "src/core/player.gd")
	
	Returns:
		String: Slug (e.g., "src_core_player_gd")
	"""
	return file_path.replace("/", "_").replace("\\", "_").replace(".", "_")


static func _get_coverage_class(percent: float) -> String:
	"""Get CSS class based on coverage percentage"""
	if percent >= 80.0:
		return "good"
	elif percent >= 50.0:
		return "ok"
	else:
		return "bad"


static func _get_bar_color(percent: float) -> String:
	"""Get color for progress bar based on coverage percentage"""
	if percent >= 80.0:
		return "#28a745"  # Green
	elif percent >= 50.0:
		return "#ffc107"  # Yellow
	else:
		return "#dc3545"  # Red


static func _html_escape(text: String) -> String:
	"""Escape HTML special characters"""
	return text.replace("&", "&amp;") \
	           .replace("<", "&lt;") \
	           .replace(">", "&gt;") \
	           .replace("\"", "&quot;") \
	           .replace("'", "&#39;")


static func _get_summary_css() -> String:
	"""Get embedded CSS for summary page"""
	return """  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
    h1 { color: #333; margin-bottom: 20px; }
    h2 { color: #555; margin-top: 30px; }
    .summary { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .total { font-size: 24px; font-weight: bold; margin: 15px 0; }
    .good { color: #28a745; }
    .ok { color: #ffc107; }
    .bad { color: #dc3545; }
    table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background: #007bff; color: white; font-weight: bold; }
    tr:hover { background: #f8f9fa; }
    a { color: #007bff; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .percent { font-weight: bold; }
    .bar { height: 20px; background: #e9ecef; border-radius: 4px; overflow: hidden; }
    .bar-fill { height: 100%; transition: width 0.3s; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; text-align: center; }
  </style>"""


static func _get_file_css() -> String:
	"""Get embedded CSS for file detail page"""
	return """  <style>
    body { font-family: 'Courier New', Monaco, monospace; margin: 0; background: #f5f5f5; }
    .header { background: white; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .header h1 { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial; color: #333; margin: 10px 0; }
    .back { color: #007bff; text-decoration: none; font-family: Arial; }
    .back:hover { text-decoration: underline; }
    .stats { font-family: Arial; color: #666; margin-top: 10px; }
    .good { color: #28a745; font-weight: bold; }
    .ok { color: #ffc107; font-weight: bold; }
    .bad { color: #dc3545; font-weight: bold; }
    .code { background: white; }
    .line { display: flex; border-bottom: 1px solid #eee; }
    .line-num { background: #f8f9fa; padding: 4px 10px; width: 60px; text-align: right; color: #666; border-right: 2px solid #dee2e6; user-select: none; }
    .hit-count { padding: 4px 10px; width: 50px; text-align: center; font-weight: bold; border-right: 2px solid #dee2e6; }
    .source { padding: 4px 10px; flex: 1; white-space: pre; overflow-x: auto; }
    .hit { background: #d4edda; }
    .miss { background: #f8d7da; }
    .not-tracked { background: white; }
    .hit .hit-count { background: #28a745; color: white; }
    .miss .hit-count { background: #dc3545; color: white; }
    .not-tracked .hit-count { background: transparent; }
  </style>"""
