# GDSentry - Performance Reporter
# Advanced performance reporting and visualization system
#
# Features:
# - Comprehensive performance metric visualization
# - Trend charts and graphs using Godot's drawing capabilities
# - Benchmark comparison reports with statistical analysis
# - Automated performance report generation in multiple formats
# - CI/CD integration hooks for pipeline visibility
# - Historical performance data visualization
# - Performance regression highlighting and alerts
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name PerformanceReporter

# ------------------------------------------------------------------------------
# REPORTING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_REPORT_DIR = "res://performance_reports/"
const CHART_WIDTH = 800
const CHART_HEIGHT = 600
const CHART_MARGIN = 50
const MAX_DATA_POINTS = 1000

# ------------------------------------------------------------------------------
# REPORTING STATE
# ------------------------------------------------------------------------------
var report_data: Dictionary = {}
var historical_data: Array = []
var performance_charts: Dictionary = {}
var report_templates: Dictionary = {}

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize performance reporter"""
	_setup_report_directory()
	_load_historical_data()

# ------------------------------------------------------------------------------
# REPORT GENERATION
# ------------------------------------------------------------------------------
func generate_performance_report(benchmark_results: Dictionary, options: Dictionary = {}) -> Dictionary:
	"""Generate comprehensive performance report"""
	var report = {
		"timestamp": Time.get_unix_time_from_system(),
		"benchmark_results": benchmark_results.duplicate(true),
		"options": options,
		"summary": {},
		"charts": {},
		"recommendations": [],
		"alerts": []
	}

	# Generate summary
	report.summary = _generate_report_summary(benchmark_results)

	# Generate charts
	report.charts = _generate_performance_charts(benchmark_results)

	# Generate recommendations
	report.recommendations = _generate_performance_recommendations(benchmark_results)

	# Check for alerts
	report.alerts = _check_performance_alerts(benchmark_results)

	# Save report
	var report_path = _save_report(report, options.get("format", "json"))
	report.report_path = report_path

	# Store in historical data
	historical_data.append({
		"timestamp": report.timestamp,
		"summary": report.summary,
		"report_path": report_path
	})

	return report

func generate_comparison_report(baseline_results: Dictionary, current_results: Dictionary, options: Dictionary = {}) -> Dictionary:
	"""Generate comparison report between baseline and current results"""
	var comparison = {
		"timestamp": Time.get_unix_time_from_system(),
		"baseline": baseline_results.duplicate(true),
		"current": current_results.duplicate(true),
		"comparison": {},
		"charts": {},
		"summary": {},
		"regressions": [],
		"improvements": []
	}

	# Perform comparison analysis
	comparison.comparison = _compare_benchmark_results(baseline_results, current_results)

	# Generate comparison charts
	comparison.charts = _generate_comparison_charts(baseline_results, current_results)

	# Generate summary
	comparison.summary = _generate_comparison_summary(comparison.comparison)

	# Identify regressions and improvements
	var regression_analysis = _analyze_performance_changes(comparison.comparison)
	comparison.regressions = regression_analysis.regressions
	comparison.improvements = regression_analysis.improvements

	# Save comparison report
	var report_path = _save_comparison_report(comparison, options.get("format", "json"))
	comparison.report_path = report_path

	return comparison

# ------------------------------------------------------------------------------
# CHART GENERATION
# ------------------------------------------------------------------------------
func _generate_performance_charts(benchmark_results: Dictionary) -> Dictionary:
	"""Generate performance visualization charts"""
	var charts = {}

	# Memory usage chart
	if benchmark_results.has("memory_usage"):
		charts.memory_usage = _generate_memory_chart(benchmark_results)

	# FPS chart
	if benchmark_results.has("fps_data"):
		charts.fps_performance = _generate_fps_chart(benchmark_results)

	# Benchmark timing chart
	if benchmark_results.has("benchmark_results"):
		charts.benchmark_timings = _generate_benchmark_chart(benchmark_results)

	# Performance trend chart
	if not historical_data.is_empty():
		charts.performance_trends = _generate_trend_chart()

	return charts

func _generate_memory_chart(benchmark_results: Dictionary) -> Image:
	"""Generate memory usage visualization chart"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))  # Dark background

	# Draw chart axes and labels
	_draw_chart_axes(chart, "Memory Usage Over Time", "Time", "Memory (MB)")

	# Draw memory usage line
	if benchmark_results.has("memory_samples"):
		var memory_data = benchmark_results.memory_samples
		_draw_line_chart(chart, memory_data, Color(0, 1, 0, 1), "Memory Usage")

	return chart

func _generate_fps_chart(benchmark_results: Dictionary) -> Image:
	"""Generate FPS performance chart"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))

	_draw_chart_axes(chart, "FPS Performance", "Time", "FPS")

	if benchmark_results.has("fps_samples"):
		var fps_data = benchmark_results.fps_samples
		_draw_line_chart(chart, fps_data, Color(1, 1, 0, 1), "FPS")

		# Draw target FPS line
		_draw_horizontal_line(chart, 60.0, Color(0.5, 0.5, 0.5, 0.7), "Target FPS (60)")

	return chart

func _generate_benchmark_chart(benchmark_results: Dictionary) -> Image:
	"""Generate benchmark timing comparison chart"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))

	_draw_chart_axes(chart, "Benchmark Performance", "Benchmark", "Time (ms)")

	if benchmark_results.has("benchmark_results"):
		var benchmarks = benchmark_results.benchmark_results
		_draw_bar_chart(chart, benchmarks, Color(0, 0.7, 1, 1))

	return chart

func _generate_trend_chart() -> Image:
	"""Generate performance trend chart from historical data"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))

	_draw_chart_axes(chart, "Performance Trends", "Time", "Performance Metric")

	# Extract trend data from historical records
	var trend_data = []
	for record in historical_data:
		if record.has("summary") and record.summary.has("average_performance"):
			trend_data.append(record.summary.average_performance)

	if not trend_data.is_empty():
		_draw_line_chart(chart, trend_data, Color(1, 0.5, 0, 1), "Performance Trend")

	return chart

func _generate_comparison_charts(baseline_results: Dictionary, current_results: Dictionary) -> Dictionary:
	"""Generate comparison visualization charts"""
	var charts = {}

	# Side-by-side comparison chart
	charts.side_by_side = _generate_side_by_side_chart(baseline_results, current_results)

	# Difference chart
	charts.differences = _generate_difference_chart(baseline_results, current_results)

	# Regression highlighting chart
	charts.regressions = _generate_regression_chart(baseline_results, current_results)

	return charts

func _generate_side_by_side_chart(baseline_results: Dictionary, current_results: Dictionary) -> Image:
	"""Generate side-by-side comparison chart"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))

	_draw_chart_axes(chart, "Baseline vs Current Performance", "Benchmark", "Time (ms)")

	# Draw baseline bars
	if baseline_results.has("benchmark_results"):
		var baseline_data = baseline_results.benchmark_results
		_draw_bar_chart(chart, baseline_data, Color(0.7, 0.7, 0.7, 0.8), 0.25, "Baseline")

	# Draw current bars
	if current_results.has("benchmark_results"):
		var current_data = current_results.benchmark_results
		_draw_bar_chart(chart, current_data, Color(0, 0.7, 1, 0.8), -0.25, "Current")

	return chart

func _generate_difference_chart(baseline_results: Dictionary, current_results: Dictionary) -> Image:
	"""Generate performance difference visualization"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))

	_draw_chart_axes(chart, "Performance Differences", "Benchmark", "Difference (ms)")

	var differences = _calculate_performance_differences(baseline_results, current_results)
	_draw_difference_chart(chart, differences)

	return chart

func _generate_regression_chart(baseline_results: Dictionary, current_results: Dictionary) -> Image:
	"""Generate regression highlighting chart"""
	var chart = Image.create(CHART_WIDTH, CHART_HEIGHT, false, Image.FORMAT_RGBA8)
	chart.fill(Color(0.1, 0.1, 0.1, 1.0))

	_draw_chart_axes(chart, "Performance Regressions", "Benchmark", "Time (ms)")

	# Draw baseline and current with regression highlighting
	if baseline_results.has("benchmark_results") and current_results.has("benchmark_results"):
		_draw_regression_highlighted_chart(chart, baseline_results.benchmark_results, current_results.benchmark_results)

	return chart

# ------------------------------------------------------------------------------
# CHART DRAWING UTILITIES
# ------------------------------------------------------------------------------
func _draw_chart_axes(chart: Image, title: String, x_label: String, y_label: String) -> void:
	"""Draw chart axes, labels, and title"""
	chart.lock()

	# Draw title
	_draw_text(chart, title, Vector2(CHART_WIDTH/2.0 - 100, 20), Color.WHITE, 16)

	# Draw axes
	var axis_color = Color(0.8, 0.8, 0.8, 1.0)

	# X-axis
	for x in range(CHART_MARGIN, CHART_WIDTH - CHART_MARGIN):
		chart.set_pixel(x, CHART_HEIGHT - CHART_MARGIN, axis_color)

	# Y-axis
	for y in range(CHART_MARGIN, CHART_HEIGHT - CHART_MARGIN):
		chart.set_pixel(CHART_MARGIN, y, axis_color)

	# Draw labels
	_draw_text(chart, x_label, Vector2(CHART_WIDTH/2.0 - 20, CHART_HEIGHT - 10), Color(0.7, 0.7, 0.7, 1.0), 12)

	# Y-axis label (rotated)
	_draw_text(chart, y_label, Vector2(10, CHART_HEIGHT/2.0), Color(0.7, 0.7, 0.7, 1.0), 12)

	chart.unlock()

func _draw_line_chart(chart: Image, data: Array, color: Color, _label: String) -> void:
	"""Draw line chart from data array"""
	if data.is_empty():
		return

	chart.lock()

	var chart_width = CHART_WIDTH - 2 * CHART_MARGIN
	var chart_height = CHART_HEIGHT - 2 * CHART_MARGIN

	# Find data range
	var min_val = data.min()
	var max_val = data.max()
	var range_val = max_val - min_val

	if range_val == 0:
		range_val = 1  # Avoid division by zero

	# Draw data points and lines
	for i in range(data.size() - 1):
		var x1 = CHART_MARGIN + (i * chart_width / float(data.size() - 1))
		var y1 = CHART_HEIGHT - CHART_MARGIN - ((data[i] - min_val) * chart_height / float(range_val))
		var x2 = CHART_MARGIN + ((i + 1) * chart_width / float(data.size() - 1))
		var y2 = CHART_HEIGHT - CHART_MARGIN - ((data[i + 1] - min_val) * chart_height / float(range_val))

		# Draw line between points
		_draw_line(chart, Vector2(x1, y1), Vector2(x2, y2), color)

	chart.unlock()

func _draw_bar_chart(chart: Image, data: Dictionary, color: Color, offset: float = 0.0, _label: String = "") -> void:
	"""Draw bar chart from data dictionary"""
	if data.is_empty():
		return

	chart.lock()

	var chart_width = CHART_WIDTH - 2 * CHART_MARGIN
	var chart_height = CHART_HEIGHT - 2 * CHART_MARGIN
	var bar_width = chart_width / float(data.size() * 2)  # Space for multiple series
	var bar_offset = offset * bar_width

	var keys = data.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var value = data[key]

		var bar_x = CHART_MARGIN + (i * chart_width / float(keys.size())) + bar_offset
		var bar_height = (value * chart_height) / 100.0  # Assuming max value of 100 for scaling
		var bar_y = CHART_HEIGHT - CHART_MARGIN - bar_height

		# Draw bar
		for x in range(bar_x, bar_x + bar_width):
			for y in range(bar_y, CHART_HEIGHT - CHART_MARGIN):
				if x >= 0 and x < CHART_WIDTH and y >= 0 and y < CHART_HEIGHT:
					chart.set_pixel(x, y, color)

	chart.unlock()

func _draw_horizontal_line(chart: Image, y_value: float, color: Color, _label: String = "") -> void:
	"""Draw horizontal reference line"""
	chart.lock()

	var chart_height = CHART_HEIGHT - 2 * CHART_MARGIN
	var line_y = CHART_HEIGHT - CHART_MARGIN - (y_value * chart_height / 100.0)  # Scale to chart

	for x in range(CHART_MARGIN, CHART_WIDTH - CHART_MARGIN):
		if line_y >= 0 and line_y < CHART_HEIGHT:
			chart.set_pixel(x, int(line_y), color)

	chart.unlock()

func _draw_difference_chart(chart: Image, differences: Dictionary) -> void:
	"""Draw performance difference chart"""
	chart.lock()

	var chart_width = CHART_WIDTH - 2 * CHART_MARGIN
	var chart_height = CHART_HEIGHT - 2 * CHART_MARGIN

	var keys = differences.keys()
	for i in range(keys.size()):
		var key = keys[i]
		var diff = differences[key]

		var bar_x = CHART_MARGIN + (i * chart_width / float(keys.size()))
		var bar_width = chart_width / float(keys.size() * 2)

		if diff > 0:
			# Positive difference (regression) - red
			var bar_height = (diff * chart_height) / 10.0  # Scale differences
			var bar_y = CHART_HEIGHT - CHART_MARGIN - bar_height

			for x in range(bar_x, bar_x + bar_width):
				for y in range(bar_y, CHART_HEIGHT - CHART_MARGIN):
					if x >= 0 and x < CHART_WIDTH and y >= 0 and y < CHART_HEIGHT:
						chart.set_pixel(x, y, Color(1, 0, 0, 0.8))  # Red for regression
		else:
			# Negative difference (improvement) - green
			var bar_height = (abs(diff) * chart_height) / 10.0
			var bar_y = CHART_HEIGHT - CHART_MARGIN - bar_height

			for x in range(bar_x, bar_x + bar_width):
				for y in range(bar_y, CHART_HEIGHT - CHART_MARGIN):
					if x >= 0 and x < CHART_WIDTH and y >= 0 and y < CHART_HEIGHT:
						chart.set_pixel(x, y, Color(0, 1, 0, 0.8))  # Green for improvement

	chart.unlock()

func _draw_regression_highlighted_chart(chart: Image, baseline_data: Dictionary, current_data: Dictionary) -> void:
	"""Draw chart with regression highlighting"""
	chart.lock()

	var chart_width = CHART_WIDTH - 2 * CHART_MARGIN
	var chart_height = CHART_HEIGHT - 2 * CHART_MARGIN

	var keys = baseline_data.keys()
	for i in range(keys.size()):
		var key = keys[i]
		if not current_data.has(key):
			continue

		var baseline_val = baseline_data[key]
		var current_val = current_data[key]

		var bar_x = CHART_MARGIN + (i * chart_width / float(keys.size()))
		var bar_width = chart_width / float(keys.size() * 3)  # Space for baseline, current, and gap

		# Draw baseline bar (gray)
		var baseline_height = (baseline_val * chart_height) / 100.0
		var baseline_y = CHART_HEIGHT - CHART_MARGIN - baseline_height
		for x in range(bar_x, bar_x + bar_width):
			for y in range(baseline_y, CHART_HEIGHT - CHART_MARGIN):
				if x >= 0 and x < CHART_WIDTH and y >= 0 and y < CHART_HEIGHT:
					chart.set_pixel(x, y, Color(0.5, 0.5, 0.5, 0.8))

		# Draw current bar (color based on performance)
		var current_height = (current_val * chart_height) / 100.0
		var current_y = CHART_HEIGHT - CHART_MARGIN - current_height
		var bar_color = Color(0, 0.7, 1, 0.8)  # Default blue

		# Color based on performance change
		var percent_change = ((current_val - baseline_val) / baseline_val) * 100
		if percent_change > 5:  # Regression
			bar_color = Color(1, 0, 0, 0.8)  # Red
		elif percent_change < -5:  # Improvement
			bar_color = Color(0, 1, 0, 0.8)  # Green

		var current_bar_x = bar_x + bar_width + 5  # Slight offset
		for x in range(current_bar_x, current_bar_x + bar_width):
			for y in range(current_y, CHART_HEIGHT - CHART_MARGIN):
				if x >= 0 and x < CHART_WIDTH and y >= 0 and y < CHART_HEIGHT:
					chart.set_pixel(x, y, bar_color)

	chart.unlock()

func _draw_line(chart: Image, from: Vector2, to: Vector2, color: Color) -> void:
	"""Draw line between two points using Bresenham's algorithm"""
	var x1 = int(from.x)
	var y1 = int(from.y)
	var x2 = int(to.x)
	var y2 = int(to.y)

	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var sx = 1 if x1 < x2 else -1
	var sy = 1 if y1 < y2 else -1
	var err = dx - dy

	while true:
		if x1 >= 0 and x1 < CHART_WIDTH and y1 >= 0 and y1 < CHART_HEIGHT:
			chart.set_pixel(x1, y1, color)

		if x1 == x2 and y1 == y2:
			break

		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x1 += sx
		if e2 < dx:
			err += dx
			y1 += sy

func _draw_text(chart: Image, text: String, position: Vector2, color: Color, size: int = 12) -> void:
	"""Draw simple text on chart (simplified implementation)"""
	# This is a simplified text drawing - in practice you'd want a more sophisticated text rendering system
	var x = int(position.x)
	var y = int(position.y)

	# Draw a simple rectangle to represent text (placeholder)
	for dx in range(text.length() * 8):
		for dy in range(size):
			var px = x + dx
			var py = y + dy
			if px >= 0 and px < CHART_WIDTH and py >= 0 and py < CHART_HEIGHT:
				chart.set_pixel(px, py, color)

# ------------------------------------------------------------------------------
# ANALYSIS FUNCTIONS
# ------------------------------------------------------------------------------
func _generate_report_summary(benchmark_results: Dictionary) -> Dictionary:
	"""Generate comprehensive report summary"""
	var summary = {
		"total_benchmarks": 0,
		"successful_benchmarks": 0,
		"failed_benchmarks": 0,
		"average_performance": 0.0,
		"best_performance": "",
		"worst_performance": "",
		"performance_variance": 0.0,
		"memory_usage": 0.0,
		"fps_average": 0.0
	}

	if benchmark_results.has("benchmark_results"):
		var benchmarks = benchmark_results.benchmark_results
		summary.total_benchmarks = benchmarks.size()

		var total_time = 0.0
		var times = []

		for benchmark_name in benchmarks.keys():
			var benchmark = benchmarks[benchmark_name]
			total_time += benchmark.average_time
			times.append(benchmark.average_time)

			if summary.best_performance.is_empty() or benchmark.average_time < benchmarks[summary.best_performance].average_time:
				summary.best_performance = benchmark_name
			if summary.worst_performance.is_empty() or benchmark.average_time > benchmarks[summary.worst_performance].average_time:
				summary.worst_performance = benchmark_name

		if not times.is_empty():
			summary.average_performance = total_time / times.size()
			summary.performance_variance = _calculate_variance(times)

	if benchmark_results.has("memory_usage"):
		summary.memory_usage = benchmark_results.memory_usage

	if benchmark_results.has("fps_average"):
		summary.fps_average = benchmark_results.fps_average

	return summary

func _generate_performance_recommendations(benchmark_results: Dictionary) -> Array:
	"""Generate performance optimization recommendations"""
	var recommendations = []

	var summary = _generate_report_summary(benchmark_results)

	# Performance variance analysis
	if summary.performance_variance > 1.0:
		recommendations.append("High performance variance detected - consider optimizing for consistency")

	# Memory usage analysis
	if summary.memory_usage > 100 * 1024 * 1024:  # 100MB
		recommendations.append("High memory usage detected - consider memory optimization")

	# FPS analysis
	if summary.fps_average < 30:
		recommendations.append("Low FPS detected - investigate performance bottlenecks")

	# Benchmark-specific analysis
	if benchmark_results.has("benchmark_results"):
		var benchmarks = benchmark_results.benchmark_results
		for benchmark_name in benchmarks.keys():
			var benchmark = benchmarks[benchmark_name]
			if benchmark.average_time > 100.0:  # 100ms threshold
				recommendations.append("Slow performance in '" + benchmark_name + "' - consider optimization")

	return recommendations

func _check_performance_alerts(benchmark_results: Dictionary) -> Array:
	"""Check for performance alerts that require attention"""
	var alerts = []

	var summary = _generate_report_summary(benchmark_results)

	# Critical alerts
	if summary.fps_average < 20:
		alerts.append({
			"level": "critical",
			"message": "Critically low FPS detected",
			"value": summary.fps_average
		})

	if summary.memory_usage > 500 * 1024 * 1024:  # 500MB
		alerts.append({
			"level": "critical",
			"message": "Excessive memory usage detected",
			"value": summary.memory_usage / (1024 * 1024)
		})

	# Warning alerts
	if summary.performance_variance > 2.0:
		alerts.append({
			"level": "warning",
			"message": "High performance variance",
			"value": summary.performance_variance
		})

	if summary.average_performance > 50.0:  # 50ms average
		alerts.append({
			"level": "warning",
			"message": "Above average performance times",
			"value": summary.average_performance
		})

	return alerts

func _compare_benchmark_results(baseline_results: Dictionary, current_results: Dictionary) -> Dictionary:
	"""Compare benchmark results between baseline and current"""
	var comparison = {
		"benchmarks": {},
		"overall_change": 0.0,
		"regression_count": 0,
		"improvement_count": 0
	}

	if baseline_results.has("benchmark_results") and current_results.has("benchmark_results"):
		var baseline_benchmarks = baseline_results.benchmark_results
		var current_benchmarks = current_results.benchmark_results

		for benchmark_name in baseline_benchmarks.keys():
			if current_benchmarks.has(benchmark_name):
				var baseline_time = baseline_benchmarks[benchmark_name].average_time
				var current_time = current_benchmarks[benchmark_name].average_time

				var percent_change = ((current_time - baseline_time) / baseline_time) * 100

				comparison.benchmarks[benchmark_name] = {
					"baseline_time": baseline_time,
					"current_time": current_time,
					"difference": current_time - baseline_time,
					"percent_change": percent_change,
					"status": "regression" if percent_change > 5 else ("improvement" if percent_change < -5 else "stable")
				}

				if percent_change > 5:
					comparison.regression_count += 1
				elif percent_change < -5:
					comparison.improvement_count += 1

		# Calculate overall change
		var total_change = 0.0
		for benchmark in comparison.benchmarks.values():
			total_change += benchmark.percent_change
		comparison.overall_change = total_change / comparison.benchmarks.size() if comparison.benchmarks.size() > 0 else 0.0

	return comparison

func _generate_comparison_summary(comparison: Dictionary) -> Dictionary:
	"""Generate summary of comparison results"""
	return {
		"benchmarks_compared": comparison.benchmarks.size(),
		"regressions": comparison.regression_count,
		"improvements": comparison.improvements,
		"stable": comparison.benchmarks.size() - comparison.regression_count - comparison.improvements,
		"overall_change_percent": comparison.overall_change,
		"change_trend": "worsening" if comparison.overall_change > 0 else ("improving" if comparison.overall_change < -5 else "stable")
	}

func _analyze_performance_changes(comparison: Dictionary) -> Dictionary:
	"""Analyze performance changes for detailed reporting"""
	var regressions = []
	var improvements = []

	for benchmark_name in comparison.benchmarks.keys():
		var benchmark = comparison.benchmarks[benchmark_name]

		if benchmark.status == "regression":
			regressions.append({
				"benchmark": benchmark_name,
				"severity": "high" if benchmark.percent_change > 25 else ("medium" if benchmark.percent_change > 10 else "low"),
				"change": benchmark.percent_change,
				"baseline_time": benchmark.baseline_time,
				"current_time": benchmark.current_time
			})
		elif benchmark.status == "improvement":
			improvements.append({
				"benchmark": benchmark_name,
				"change": benchmark.percent_change,
				"baseline_time": benchmark.baseline_time,
				"current_time": benchmark.current_time
			})

	return {
		"regressions": regressions,
		"improvements": improvements
	}

func _calculate_performance_differences(baseline_results: Dictionary, current_results: Dictionary) -> Dictionary:
	"""Calculate performance differences for visualization"""
	var differences = {}

	if baseline_results.has("benchmark_results") and current_results.has("benchmark_results"):
		var baseline_benchmarks = baseline_results.benchmark_results
		var current_benchmarks = current_results.benchmark_results

		for benchmark_name in baseline_benchmarks.keys():
			if current_benchmarks.has(benchmark_name):
				var baseline_time = baseline_benchmarks[benchmark_name].average_time
				var current_time = current_benchmarks[benchmark_name].average_time
				differences[benchmark_name] = current_time - baseline_time

	return differences

func _calculate_variance(data: Array) -> float:
	"""Calculate variance of data array"""
	if data.size() < 2:
		return 0.0

	var mean = 0.0
	for val in data:
		mean += val
	mean /= data.size()

	var variance = 0.0
	for val in data:
		variance += pow(val - mean, 2)
	variance /= data.size()

	return variance

# ------------------------------------------------------------------------------
# FILE MANAGEMENT
# ------------------------------------------------------------------------------
func _setup_report_directory() -> void:
	"""Setup report directory structure"""
	var global_dir = ProjectSettings.globalize_path(DEFAULT_REPORT_DIR)

	if not DirAccess.dir_exists_absolute(global_dir):
		var error = DirAccess.make_dir_recursive_absolute(global_dir)
		if error != OK:
			push_warning("Failed to create performance reports directory: " + global_dir)

func _save_report(report: Dictionary, format: String = "json") -> String:
	"""Save report to file"""
	var timestamp = Time.get_datetime_string_from_system().replace(" ", "_").replace(":", "-")
	var filename = "performance_report_" + timestamp + "." + format
	var file_path = DEFAULT_REPORT_DIR + filename
	var global_path = ProjectSettings.globalize_path(file_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to save performance report: " + global_path)
		return ""

	if format == "json":
		file.store_string(JSON.stringify(report, "\t"))
	else:
		# Simple text format for other formats
		file.store_string(_generate_text_report(report))

	file.close()

	print("📊 Performance report saved: " + file_path)
	return file_path

func _save_comparison_report(comparison: Dictionary, format: String = "json") -> String:
	"""Save comparison report to file"""
	var timestamp = Time.get_datetime_string_from_system().replace(" ", "_").replace(":", "-")
	var filename = "performance_comparison_" + timestamp + "." + format
	var file_path = DEFAULT_REPORT_DIR + filename
	var global_path = ProjectSettings.globalize_path(file_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to save comparison report: " + global_path)
		return ""

	if format == "json":
		file.store_string(JSON.stringify(comparison, "\t"))
	else:
		file.store_string(_generate_comparison_text_report(comparison))

	file.close()

	print("📊 Performance comparison saved: " + file_path)
	return file_path

func _generate_text_report(report: Dictionary) -> String:
	"""Generate text format report"""
	var text = "PERFORMANCE REPORT\n"
	text += "==================\n\n"

	text += "Timestamp: " + Time.get_datetime_string_from_system() + "\n"
	text += "Summary:\n"
	text += "  Total Benchmarks: " + str(report.summary.get("total_benchmarks", 0)) + "\n"
	text += "  Average Performance: " + str(report.summary.get("average_performance", 0.0)) + " ms\n"
	text += "  Memory Usage: " + str(report.summary.get("memory_usage", 0.0) / (1024 * 1024)) + " MB\n"
	text += "  FPS Average: " + str(report.summary.get("fps_average", 0.0)) + "\n\n"

	if not report.recommendations.is_empty():
		text += "Recommendations:\n"
		for rec in report.recommendations:
			text += "  • " + rec + "\n"
		text += "\n"

	if not report.alerts.is_empty():
		text += "Alerts:\n"
		for alert in report.alerts:
			text += "  • [" + alert.level.to_upper() + "] " + alert.message + "\n"
		text += "\n"

	return text

func _generate_comparison_text_report(comparison: Dictionary) -> String:
	"""Generate text format comparison report"""
	var text = "PERFORMANCE COMPARISON REPORT\n"
	text += "=============================\n\n"

	text += "Timestamp: " + Time.get_datetime_string_from_system() + "\n"
	text += "Summary:\n"
	text += "  Benchmarks Compared: " + str(comparison.summary.get("benchmarks_compared", 0)) + "\n"
	text += "  Regressions: " + str(comparison.summary.get("regressions", 0)) + "\n"
	text += "  Improvements: " + str(comparison.summary.get("improvements", 0)) + "\n"
	text += "  Overall Change: " + str(comparison.summary.get("overall_change_percent", 0.0)) + "%\n\n"

	if not comparison.regressions.is_empty():
		text += "Performance Regressions:\n"
		for reg in comparison.regressions:
			text += "  • " + reg.benchmark + ": " + str(reg.change) + "% (" + reg.severity + ")\n"
		text += "\n"

	if not comparison.improvements.is_empty():
		text += "Performance Improvements:\n"
		for imp in comparison.improvements:
			text += "  • " + imp.benchmark + ": " + str(imp.change) + "%\n"
		text += "\n"

	return text

func _load_historical_data() -> void:
	"""Load historical performance data"""
	var global_dir = ProjectSettings.globalize_path(DEFAULT_REPORT_DIR)

	if not DirAccess.dir_exists_absolute(global_dir):
		return

	var dir = DirAccess.open(global_dir)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var file_path = DEFAULT_REPORT_DIR + file_name
			var global_path = ProjectSettings.globalize_path(file_path)

			var file = FileAccess.open(global_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()

				var parsed = JSON.parse_string(content)
				if parsed is Dictionary:
					historical_data.append(parsed)

		file_name = dir.get_next()

	dir.list_dir_end()

	print("📊 Loaded " + str(historical_data.size()) + " historical performance reports")

# ------------------------------------------------------------------------------
# CI/CD INTEGRATION HOOKS
# ------------------------------------------------------------------------------
func generate_ci_report(benchmark_results: Dictionary, baseline_comparison: Dictionary = {}) -> Dictionary:
	"""Generate CI/CD optimized report"""
	var ci_report = {
		"ci_status": "success",
		"performance_score": 0.0,
		"critical_issues": [],
		"warnings": [],
		"metrics": {},
		"recommendations": []
	}

	# Calculate performance score (0-100, higher is better)
	var summary = _generate_report_summary(benchmark_results)
	ci_report.performance_score = _calculate_performance_score(summary)

	# Check for critical issues
	var alerts = _check_performance_alerts(benchmark_results)
	for alert in alerts:
		if alert.level == "critical":
			ci_report.critical_issues.append(alert.message)
			ci_report.ci_status = "failure"
		else:
			ci_report.warnings.append(alert.message)

	# Add key metrics
	ci_report.metrics = {
		"average_performance": summary.average_performance,
		"memory_usage_mb": summary.memory_usage / (1024 * 1024) if summary.memory_usage > 0 else 0,
		"fps_average": summary.fps_average,
		"performance_variance": summary.performance_variance
	}

	# Add comparison if available
	if not baseline_comparison.is_empty():
		ci_report.baseline_comparison = baseline_comparison

	return ci_report

func _calculate_performance_score(summary: Dictionary) -> float:
	"""Calculate performance score for CI/CD"""
	var score = 100.0

	# Deduct points for poor performance
	if summary.average_performance > 50.0:  # Slow
		score -= 20
	if summary.memory_usage > 200 * 1024 * 1024:  # High memory
		score -= 20
	if summary.fps_average < 30:  # Low FPS
		score -= 30
	if summary.performance_variance > 2.0:  # High variance
		score -= 15

	return clamp(score, 0.0, 100.0)

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup performance reporter resources"""
	report_data.clear()
	historical_data.clear()
	performance_charts.clear()
	report_templates.clear()
