# GDSentry - Performance Benchmark Framework
# Advanced performance testing with automated benchmark suites, statistical analysis, and regression detection
#
# Enhanced Features:
# - Automated benchmark suite execution with configurable scenarios
# - Advanced statistical analysis (confidence intervals, percentiles, outliers)
# - Performance baseline management with historical trending
# - Regression detection algorithms with configurable thresholds
# - Automated performance profiling and bottleneck identification
# - CI/CD integration with performance gate checking
# - Comparative analysis across different configurations
# - Memory profiling with leak detection and pattern analysis
# - Performance trend analysis and forecasting
#
# Integration with:
# - GDSentry test framework for seamless integration
# - PerformanceTest for basic functionality
# - Statistical analysis utilities
# - Baseline management system
#
# Author: GDSentry Framework
# Version: 2.0.0

extends PerformanceTest

class_name PerformanceBenchmarkTest

# ------------------------------------------------------------------------------
# BENCHMARK FRAMEWORK CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_CONFIDENCE_LEVEL = 0.95
const DEFAULT_OUTLIER_THRESHOLD = 2.5  # Standard deviations
const DEFAULT_REGRESSION_THRESHOLD = 0.10  # 10% performance change
const DEFAULT_BASELINE_RETENTION_DAYS = 30
const DEFAULT_TREND_ANALYSIS_WINDOW = 10

# ------------------------------------------------------------------------------
# BENCHMARK FRAMEWORK STATE
# ------------------------------------------------------------------------------
var benchmark_suites: Dictionary = {}
var statistical_analyzer: StatisticalAnalyzer = null
var regression_detector: RegressionDetector = null
var baseline_manager: BaselineManager = null
var ci_gate_checker: CIGateChecker = null
var trend_analyzer: TrendAnalyzer = null

var current_benchmark_context: Dictionary = {}
var performance_profiles: Dictionary = {}
var benchmark_history: Array = []

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize the advanced performance benchmark framework"""
	super._ready()

	# Initialize advanced components
	statistical_analyzer = StatisticalAnalyzer.new()
	regression_detector = RegressionDetector.new()
	baseline_manager = BaselineManager.new()
	ci_gate_checker = CIGateChecker.new()
	trend_analyzer = TrendAnalyzer.new()

	# Components are managed directly (SceneTreeTest doesn't support add_child)

	# Setup default benchmark suites
	setup_default_benchmark_suites()

	# Initialize performance profiling
	setup_advanced_performance_monitoring()

# ------------------------------------------------------------------------------
# STATISTICAL ANALYSIS COMPONENT
# ------------------------------------------------------------------------------
class StatisticalAnalyzer:
	var confidence_level: float = DEFAULT_CONFIDENCE_LEVEL

	func calculate_basic_statistics(data: Array) -> Dictionary:
		"""Calculate basic statistical measures"""
		if data.is_empty():
			return {}

		var sorted_data = data.duplicate()
		sorted_data.sort()

		var n = data.size()
		var sum = data.reduce(func(acc, val): return acc + val, 0.0)
		var mean = sum / n

		# Variance and standard deviation
		var variance = 0.0
		for val in data:
			variance += pow(val - mean, 2)
		variance /= n
		var std_dev = sqrt(variance)

		# Percentiles
		var p50 = _calculate_percentile(sorted_data, 50)
		var p95 = _calculate_percentile(sorted_data, 95)
		var p99 = _calculate_percentile(sorted_data, 99)

		# Confidence interval
		var ci_margin = _calculate_confidence_interval_margin(std_dev, n, confidence_level)
		var ci_lower = mean - ci_margin
		var ci_upper = mean + ci_margin

		return {
			"count": n,
			"mean": mean,
			"median": p50,
			"std_dev": std_dev,
			"variance": variance,
			"min": sorted_data[0],
			"max": sorted_data.back(),
			"p50": p50,
			"p95": p95,
			"p99": p99,
			"confidence_interval": {
				"lower": ci_lower,
				"upper": ci_upper,
				"margin": ci_margin,
				"level": confidence_level
			}
		}

	func detect_outliers(data: Array, threshold: float = DEFAULT_OUTLIER_THRESHOLD) -> Dictionary:
		"""Detect statistical outliers using modified Z-score"""
		var stats = calculate_basic_statistics(data)
		if stats.is_empty():
			return {"outliers": [], "outlier_indices": []}

		var outliers = []
		var outlier_indices = []

		for i in range(data.size()):
			var z_score = abs(data[i] - stats.mean) / stats.std_dev
			if z_score > threshold:
				outliers.append(data[i])
				outlier_indices.append(i)

		return {
			"outliers": outliers,
			"outlier_indices": outlier_indices,
			"outlier_count": outliers.size(),
			"outlier_percentage": float(outliers.size()) / data.size() * 100
		}

	func _calculate_percentile(sorted_data: Array, percentile: float) -> float:
		"""Calculate percentile from sorted data"""
		var n = sorted_data.size()
		var index = (percentile / 100.0) * (n - 1)
		var lower = floor(index)
		var upper = ceil(index)
		var weight = index - lower

		if upper >= n:
			return sorted_data.back()
		if lower == upper:
			return sorted_data[lower]

		return sorted_data[lower] * (1 - weight) + sorted_data[upper] * weight

	func _calculate_confidence_interval_margin(std_dev: float, sample_size: int, confidence: float) -> float:
		"""Calculate confidence interval margin using t-distribution approximation"""
		# For simplicity, use normal distribution approximation
		var z_score = 1.96 if confidence >= 0.95 else 1.645  # 95% or 90% confidence
		return z_score * std_dev / sqrt(sample_size)

# ------------------------------------------------------------------------------
# REGRESSION DETECTOR COMPONENT
# ------------------------------------------------------------------------------
class RegressionDetector:
	var regression_threshold: float = DEFAULT_REGRESSION_THRESHOLD

	func detect_performance_regression(current_stats: Dictionary, baseline_stats: Dictionary) -> Dictionary:
		"""Detect performance regression with statistical significance"""
		var regression_info = {
			"regression_detected": false,
			"regression_type": "none",
			"severity": "none",
			"confidence": 0.0,
			"details": {}
		}

		# Check for mean regression
		var current_mean = current_stats.get("mean", 0)
		var baseline_mean = baseline_stats.get("mean", 0)

		if baseline_mean > 0:
			var percent_change = (current_mean - baseline_mean) / baseline_mean

			if abs(percent_change) > regression_threshold:
				regression_info.regression_detected = true
				regression_info.regression_type = "mean" if percent_change > 0 else "improvement"
				regression_info.severity = _calculate_severity(abs(percent_change))
				regression_info.details = {
					"current_mean": current_mean,
					"baseline_mean": baseline_mean,
					"percent_change": percent_change * 100,
					"absolute_change": current_mean - baseline_mean
				}

				# Calculate statistical confidence
				regression_info.confidence = _calculate_regression_confidence(current_stats, baseline_stats)

		return regression_info

	func detect_trend_regression(trend_data: Array, window_size: int = DEFAULT_TREND_ANALYSIS_WINDOW) -> Dictionary:
		"""Detect regression based on performance trends"""
		if trend_data.size() < window_size:
			return {"trend_regression": false, "trend_direction": "insufficient_data"}

		var recent_data = trend_data.slice(-window_size)
		var trend_slope = _calculate_trend_slope(recent_data)

		var trend_regression = {
			"trend_regression": false,
			"trend_direction": "stable",
			"trend_slope": trend_slope,
			"recent_average": _calculate_average(recent_data),
			"volatility": _calculate_volatility(recent_data)
		}

		# Detect significant downward trend
		if trend_slope < -regression_threshold:
			trend_regression.trend_regression = true
			trend_regression.trend_direction = "degrading"

		return trend_regression

	func _calculate_severity(percent_change: float) -> String:
		"""Calculate regression severity"""
		if percent_change > 0.5: return "critical"
		if percent_change > 0.25: return "high"
		if percent_change > 0.1: return "medium"
		return "low"

	func _calculate_regression_confidence(current_stats: Dictionary, baseline_stats: Dictionary) -> float:
		"""Calculate confidence level of regression detection"""
		var current_std = current_stats.get("std_dev", 0)
		var baseline_std = baseline_stats.get("std_dev", 0)
		var avg_std = (current_std + baseline_std) / 2

		# Simple confidence calculation based on standard deviation overlap
		if avg_std == 0: return 1.0

		var mean_diff = abs(current_stats.get("mean", 0) - baseline_stats.get("mean", 0))
		var confidence = max(0, 1 - (avg_std / mean_diff))

		return min(confidence, 1.0)

	func _calculate_trend_slope(data: Array) -> float:
		"""Calculate linear trend slope"""
		var n = data.size()
		if n < 2: return 0.0

		var sum_x = 0.0
		var sum_y = 0.0
		var sum_xy = 0.0
		var sum_x2 = 0.0

		for i in range(n):
			sum_x += i
			sum_y += data[i]
			sum_xy += i * data[i]
			sum_x2 += i * i

		var slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
		return slope / _calculate_average(data)  # Normalize

	func _calculate_average(data: Array) -> float:
		"""Calculate average of array"""
		if data.is_empty(): return 0.0
		return data.reduce(func(acc, val): return acc + val, 0.0) / data.size()

	func _calculate_volatility(data: Array) -> float:
		"""Calculate volatility (coefficient of variation)"""
		if data.is_empty(): return 0.0

		var mean = _calculate_average(data)
		if mean == 0: return 0.0

		var variance = 0.0
		for val in data:
			variance += pow(val - mean, 2)
		variance /= data.size()

		return sqrt(variance) / mean

# ------------------------------------------------------------------------------
# BASELINE MANAGER COMPONENT
# ------------------------------------------------------------------------------
class BaselineManager:
	var retention_days: int = DEFAULT_BASELINE_RETENTION_DAYS
	var baseline_storage: Dictionary = {}

	func store_baseline(baseline_name: String, data: Dictionary) -> bool:
		"""Store performance baseline data"""
		var baseline_entry = {
			"name": baseline_name,
			"timestamp": Time.get_unix_time_from_system(),
			"data": data.duplicate(true),
			"metadata": {
				"godot_version": Engine.get_version_info(),
				"system_info": OS.get_name() + " " + OS.get_version(),
				"cpu_info": OS.get_processor_name(),
				"memory_info": OS.get_memory_info().physical
			}
		}

		baseline_storage[baseline_name] = baseline_entry
		return save_baseline_to_file(baseline_name, baseline_entry)

	func retrieve_baseline(baseline_name: String) -> Dictionary:
		"""Retrieve baseline data"""
		if baseline_storage.has(baseline_name):
			return baseline_storage[baseline_name]

		# Try to load from file
		return load_baseline_from_file(baseline_name)

	func compare_with_baseline(baseline_name: String, current_data: Dictionary) -> Dictionary:
		"""Compare current data with stored baseline"""
		var baseline_data = retrieve_baseline(baseline_name)
		if baseline_data.is_empty():
			return {"success": false, "error": "Baseline not found"}

		var comparison = {
			"success": true,
			"baseline_timestamp": baseline_data.timestamp,
			"comparison_timestamp": Time.get_unix_time_from_system(),
			"age_days": (Time.get_unix_time_from_system() - baseline_data.timestamp) / 86400,
			"metrics_comparison": {}
		}

		# Compare key metrics
		var baseline_metrics = baseline_data.data
		for metric_name in current_data.keys():
			if baseline_metrics.has(metric_name):
				var current_value = current_data[metric_name]
				var baseline_value = baseline_metrics[metric_name]

				var percent_change = 0.0
				if baseline_value != 0:
					percent_change = (current_value - baseline_value) / baseline_value * 100

				comparison.metrics_comparison[metric_name] = {
					"current": current_value,
					"baseline": baseline_value,
					"change": current_value - baseline_value,
					"percent_change": percent_change
				}

		return comparison

	func cleanup_old_baselines() -> int:
		"""Clean up baselines older than retention period"""
		var current_time = Time.get_unix_time_from_system()
		var cutoff_time = current_time - (retention_days * 86400)
		var removed_count = 0

		var keys_to_remove = []
		for baseline_name in baseline_storage.keys():
			var baseline = baseline_storage[baseline_name]
			if baseline.timestamp < cutoff_time:
				keys_to_remove.append(baseline_name)

		for key in keys_to_remove:
			baseline_storage.erase(key)
			remove_baseline_file(key)
			removed_count += 1

		return removed_count

	func save_baseline_to_file(baseline_name: String, data: Dictionary) -> bool:
		"""Save baseline to file"""
		var baseline_dir = "res://performance_baselines/"
		var global_dir = ProjectSettings.globalize_path(baseline_dir)

		if not DirAccess.dir_exists_absolute(global_dir):
			var error = DirAccess.make_dir_recursive_absolute(global_dir)
			if error != OK: return false

		var file_path = baseline_dir + baseline_name + ".json"
		var global_path = ProjectSettings.globalize_path(file_path)

		var file = FileAccess.open(global_path, FileAccess.WRITE)
		if not file: return false

		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		return true

	func load_baseline_from_file(baseline_name: String) -> Dictionary:
		"""Load baseline from file"""
		var file_path = "res://performance_baselines/" + baseline_name + ".json"
		var global_path = ProjectSettings.globalize_path(file_path)

		var file = FileAccess.open(global_path, FileAccess.READ)
		if not file: return {}

		var content = file.get_as_text()
		file.close()

		var parsed = JSON.parse_string(content)
		if parsed is Dictionary:
			baseline_storage[baseline_name] = parsed
			return parsed

		return {}

	func remove_baseline_file(baseline_name: String) -> void:
		"""Remove baseline file"""
		var file_path = "res://performance_baselines/" + baseline_name + ".json"
		var global_path = ProjectSettings.globalize_path(file_path)

		if FileAccess.file_exists(global_path):
			DirAccess.remove_absolute(global_path)

# ------------------------------------------------------------------------------
# CI/CD GATE CHECKER COMPONENT
# ------------------------------------------------------------------------------
class CIGateChecker:
	var gate_thresholds: Dictionary = {
		"performance_regression": 0.05,  # 5% regression threshold
		"memory_regression": 10.0,       # 10MB memory increase
		"fps_drop": 5.0                  # 5 FPS drop
	}

	func check_performance_gate(benchmark_results: Dictionary, baseline_comparison: Dictionary) -> Dictionary:
		"""Check if performance meets CI/CD gate requirements"""
		var gate_results = {
			"gate_passed": true,
			"failures": [],
			"warnings": [],
			"metrics": {}
		}

		# Check performance regression
		if baseline_comparison.has("metrics_comparison"):
			for metric_name in baseline_comparison.metrics_comparison.keys():
				var comparison = baseline_comparison.metrics_comparison[metric_name]
				var percent_change = comparison.percent_change

				if metric_name == "average_time" and abs(percent_change) > gate_thresholds.performance_regression * 100:
					if percent_change > 0:  # Performance regression
						gate_results.failures.append({
							"type": "performance_regression",
							"metric": metric_name,
							"change": percent_change,
							"threshold": gate_thresholds.performance_regression * 100
						})
						gate_results.gate_passed = false
					else:  # Performance improvement
						gate_results.warnings.append({
							"type": "performance_improvement",
							"metric": metric_name,
							"change": -percent_change  # Show as positive
						})

		# Check memory usage
		if benchmark_results.has("memory_usage"):
			var current_memory = benchmark_results.memory_usage
			var baseline_memory = baseline_comparison.get("baseline_memory", 0)

			if current_memory - baseline_memory > gate_thresholds.memory_regression:
				gate_results.failures.append({
					"type": "memory_regression",
					"current": current_memory,
					"baseline": baseline_memory,
					"increase": current_memory - baseline_memory,
					"threshold": gate_thresholds.memory_regression
				})
				gate_results.gate_passed = false

		# Check FPS requirements
		if benchmark_results.has("average_fps"):
			var current_fps = benchmark_results.average_fps
			var baseline_fps = baseline_comparison.get("baseline_fps", 60)

			if baseline_fps - current_fps > gate_thresholds.fps_drop:
				gate_results.failures.append({
					"type": "fps_drop",
					"current": current_fps,
					"baseline": baseline_fps,
					"drop": baseline_fps - current_fps,
					"threshold": gate_thresholds.fps_drop
				})
				gate_results.gate_passed = false

		return gate_results

	func generate_gate_report(gate_results: Dictionary) -> String:
		"""Generate human-readable gate report"""
		var report = "🚦 CI/CD Performance Gate Report\n"
		report += "=".repeat(40) + "\n\n"

		report += "Gate Status: "
		report += "✅ PASSED" if gate_results.gate_passed else "❌ FAILED"
		report += "\n\n"

		if not gate_results.failures.is_empty():
			report += "❌ Failures:\n"
			for failure in gate_results.failures:
				report += "  • " + failure.type + ": "
				match failure.type:
					"performance_regression":
						report += "%.1f%% regression (threshold: %.1f%%)" % [failure.change, failure.threshold]
					"memory_regression":
						report += "%.1f MB increase (threshold: %.1f MB)" % [failure.increase, failure.threshold]
					"fps_drop":
						report += "%.1f FPS drop (threshold: %.1f FPS)" % [failure.drop, failure.threshold]
				report += "\n"

		if not gate_results.warnings.is_empty():
			report += "\n⚠️ Warnings:\n"
			for warning in gate_results.warnings:
				report += "  • " + warning.type + ": "
				report += "%.1f%% improvement" % warning.change
				report += "\n"

		return report

# ------------------------------------------------------------------------------
# TREND ANALYZER COMPONENT
# ------------------------------------------------------------------------------
class TrendAnalyzer:
	var analysis_window: int = DEFAULT_TREND_ANALYSIS_WINDOW

	func analyze_performance_trend(historical_data: Array) -> Dictionary:
		"""Analyze performance trends over time"""
		if historical_data.size() < analysis_window:
			return {"trend": "insufficient_data", "confidence": 0.0}

		var trend_analysis = {
			"trend": "stable",
			"direction": 0.0,  # -1 = degrading, 0 = stable, 1 = improving
			"confidence": 0.0,
			"volatility": 0.0,
			"forecast": {},
			"insights": []
		}

		# Calculate trend direction
		var recent_data = historical_data.slice(-analysis_window)
		var trend_slope = _calculate_trend_slope(recent_data)

		# Determine trend direction
		if abs(trend_slope) < 0.01:
			trend_analysis.trend = "stable"
			trend_analysis.direction = 0.0
		elif trend_slope > 0:
			trend_analysis.trend = "improving"
			trend_analysis.direction = 1.0
		else:
			trend_analysis.trend = "degrading"
			trend_analysis.direction = -1.0

		# Calculate confidence and volatility
		trend_analysis.confidence = _calculate_trend_confidence(recent_data)
		trend_analysis.volatility = _calculate_volatility(recent_data)

		# Generate forecast
		trend_analysis.forecast = _generate_forecast(recent_data, 5)  # 5 period forecast

		# Generate insights
		trend_analysis.insights = _generate_trend_insights(trend_analysis)

		return trend_analysis

	func _calculate_trend_slope(data: Array) -> float:
		"""Calculate trend slope using linear regression"""
		var n = data.size()
		if n < 2: return 0.0

		var sum_x = 0.0
		var sum_y = 0.0
		var sum_xy = 0.0
		var sum_x2 = 0.0

		for i in range(n):
			sum_x += i
			sum_y += data[i]
			sum_xy += i * data[i]
			sum_x2 += i * i

		var slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
		return slope

	func _calculate_trend_confidence(data: Array) -> float:
		"""Calculate confidence in trend analysis"""
		var n = data.size()
		if n < 2: return 0.0

		var _mean = data.reduce(func(acc, val): return acc + val, 0.0) / n
		var r_squared = _calculate_r_squared(data)

		# Confidence based on R-squared and sample size
		var base_confidence = r_squared * 0.8 + (min(n, 20) / 20.0) * 0.2
		return clamp(base_confidence, 0.0, 1.0)

	func _calculate_r_squared(data: Array) -> float:
		"""Calculate R-squared for trend fit"""
		var n = data.size()
		if n < 2: return 0.0

		var x_values = []
		for i in range(n):
			x_values.append(float(i))

		var slope = _calculate_trend_slope(data)
		var intercept = (data.reduce(func(acc, val): return acc + val, 0.0) / n) - slope * (x_values.reduce(func(acc, val): return acc + val, 0.0) / n)

		var ss_res = 0.0
		var ss_tot = 0.0
		var mean_y = data.reduce(func(acc, val): return acc + val, 0.0) / n

		for i in range(n):
			var predicted = slope * x_values[i] + intercept
			ss_res += pow(data[i] - predicted, 2)
			ss_tot += pow(data[i] - mean_y, 2)

		return 1 - (ss_res / ss_tot) if ss_tot > 0 else 0.0

	func _calculate_volatility(data: Array) -> float:
		"""Calculate data volatility"""
		var n = data.size()
		if n < 2: return 0.0

		var mean = data.reduce(func(acc, val): return acc + val, 0.0) / n
		var variance = 0.0

		for val in data:
			variance += pow(val - mean, 2)

		variance /= n
		return sqrt(variance) / mean if mean > 0 else 0.0

	func _generate_forecast(data: Array, periods: int) -> Dictionary:
		"""Generate performance forecast"""
		var slope = _calculate_trend_slope(data)
		var _n = data.size()
		var last_value = data.back()

		var forecast = {}
		for i in range(1, periods + 1):
			var predicted_value = last_value + slope * i
			forecast["period_" + str(i)] = predicted_value

		return forecast

	func _generate_trend_insights(trend_analysis: Dictionary) -> Array:
		"""Generate human-readable trend insights"""
		var insights = []

		match trend_analysis.trend:
			"improving":
				insights.append("Performance is trending upward with %.1f%% confidence" % (trend_analysis.confidence * 100))
			"degrading":
				insights.append("Performance is trending downward with %.1f%% confidence" % (trend_analysis.confidence * 100))
			"stable":
				insights.append("Performance is stable with %.1f%% volatility" % (trend_analysis.volatility * 100))

		if trend_analysis.volatility > 0.1:
			insights.append("High performance volatility detected - consider investigating stability issues")

		return insights

# ------------------------------------------------------------------------------
# BENCHMARK SUITE MANAGEMENT
# ------------------------------------------------------------------------------
func setup_default_benchmark_suites() -> void:
	"""Setup default benchmark suites"""
	# CPU Performance Suite
	benchmark_suites["cpu_performance"] = {
		"name": "CPU Performance Suite",
		"description": "Comprehensive CPU performance benchmarking",
		"benchmarks": [
			{
				"name": "mathematical_operations",
				"operation": func(): _math_operations(1000),
				"iterations": 100,
				"description": "Complex mathematical operations"
			},
			{
				"name": "string_processing",
				"operation": func(): _string_processing(100),
				"iterations": 50,
				"description": "String manipulation and processing"
			},
			{
				"name": "array_operations",
				"operation": func(): _array_operations(1000),
				"iterations": 75,
				"description": "Array manipulation operations"
			}
		]
	}

	# Memory Performance Suite
	benchmark_suites["memory_performance"] = {
		"name": "Memory Performance Suite",
		"description": "Memory allocation and management benchmarking",
		"benchmarks": [
			{
				"name": "object_allocation",
				"operation": func(): _object_allocation(100),
				"iterations": 50,
				"description": "Object creation and destruction"
			},
			{
				"name": "memory_copy",
				"operation": func(): _memory_copy_operations(1000),
				"iterations": 30,
				"description": "Memory copy and manipulation"
			}
		]
	}

	# Rendering Performance Suite
	benchmark_suites["rendering_performance"] = {
		"name": "Rendering Performance Suite",
		"description": "Rendering pipeline performance benchmarking",
		"benchmarks": [
			{
				"name": "draw_calls",
				"operation": func(): _simulate_draw_calls(50),
				"iterations": 20,
				"description": "Rendering draw call simulation"
			}
		]
	}

func run_benchmark_suite(suite_name: String) -> bool:
	"""Run a complete benchmark suite"""
	if not benchmark_suites.has(suite_name):
		push_error("Benchmark suite not found: " + suite_name)
		return false

	var suite = benchmark_suites[suite_name]
	var suite_results = {
		"suite_name": suite_name,
		"description": suite.description,
		"timestamp": Time.get_unix_time_from_system(),
		"benchmarks": {},
		"summary": {},
		"recommendations": []
	}

	print("🏃 Running benchmark suite: " + suite.name)

	for benchmark in suite.benchmarks:
		print("  📊 Running benchmark: " + benchmark.name)
		var result = await benchmark_operation(
			benchmark.name,
			benchmark.operation,
			benchmark.iterations
		)

		suite_results.benchmarks[benchmark.name] = result

	# Calculate suite summary
	suite_results.summary = _calculate_suite_summary(suite_results.benchmarks)

	# Generate recommendations
	suite_results.recommendations = _generate_suite_recommendations(suite_results)

	# Store in history
	benchmark_history.append(suite_results)

	return true

func _calculate_suite_summary(results: Dictionary) -> Dictionary:
	"""Calculate summary statistics for benchmark suite"""
	var summary = {
		"total_benchmarks": results.size(),
		"average_performance": 0.0,
		"best_performance": "",
		"worst_performance": "",
		"performance_variance": 0.0
	}

	var performances = []
	var best_time = INF
	var worst_time = 0.0

	for benchmark_name in results.keys():
		var result = results[benchmark_name]
		var avg_time = result.average_time

		performances.append(avg_time)

		if avg_time < best_time:
			best_time = avg_time
			summary.best_performance = benchmark_name

		if avg_time > worst_time:
			worst_time = avg_time
			summary.worst_performance = benchmark_name

	if not performances.is_empty():
		summary.average_performance = performances.reduce(func(acc, val): return acc + val, 0.0) / performances.size()

		# Calculate variance
		var variance = 0.0
		for perf in performances:
			variance += pow(perf - summary.average_performance, 2)
		variance /= performances.size()
		summary.performance_variance = variance

	return summary

func _generate_suite_recommendations(suite_results: Dictionary) -> Array:
	"""Generate performance recommendations based on suite results"""
	var recommendations = []

	var summary = suite_results.summary

	# Performance variance analysis
	if summary.performance_variance > 0.1:
		recommendations.append("High performance variance detected - consider optimizing for consistency")

	# Best/worst performance analysis
	if summary.best_performance != summary.worst_performance:
		var best_result = suite_results.benchmarks[summary.best_performance]
		var worst_result = suite_results.benchmarks[summary.worst_performance]

		if worst_result.average_time > best_result.average_time * 2:
			recommendations.append("Significant performance gap between benchmarks - investigate " + summary.worst_performance)

	return recommendations

# ------------------------------------------------------------------------------
# ADVANCED PERFORMANCE PROFILING
# ------------------------------------------------------------------------------
func setup_advanced_performance_monitoring() -> void:
	"""Setup advanced performance monitoring with profiling"""
	performance_profiles = {
		"cpu_profile": {
			"samples": [],
			"peak_usage": 0.0,
			"average_usage": 0.0,
			"bottlenecks": []
		},
		"memory_profile": {
			"samples": [],
			"peak_usage": 0,
			"leak_suspects": [],
			"growth_rate": 0.0
		},
		"rendering_profile": {
			"draw_calls": [],
			"frame_times": [],
			"bottlenecks": []
		}
	}

func start_performance_profiling(profile_name: String = "default") -> void:
	"""Start detailed performance profiling"""
	current_benchmark_context = {
		"profile_name": profile_name,
		"start_time": Time.get_ticks_usec(),
		"initial_memory": Performance.get_monitor(Performance.MEMORY_STATIC),
		"samples": []
	}

func capture_performance_sample() -> void:
	"""Capture a performance sample during profiling"""
	if current_benchmark_context.is_empty():
		return

	var sample = {
		"timestamp": Time.get_ticks_usec(),
		"cpu_usage": Performance.get_monitor(Performance.TIME_PROCESS),
		"memory_usage": Performance.get_monitor(Performance.MEMORY_STATIC),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"fps": Performance.get_monitor(Performance.TIME_FPS)
	}

	current_benchmark_context.samples.append(sample)

func stop_performance_profiling() -> Dictionary:
	"""Stop profiling and return comprehensive analysis"""
	if current_benchmark_context.is_empty():
		return {"error": "No active profiling session"}

	var end_time = Time.get_ticks_usec()
	var duration = (end_time - current_benchmark_context.start_time) / 1000000.0

	var analysis = {
		"profile_name": current_benchmark_context.profile_name,
		"duration": duration,
		"sample_count": current_benchmark_context.samples.size(),
		"analysis": _analyze_performance_samples(current_benchmark_context.samples)
	}

	current_benchmark_context.clear()
	return analysis

func _analyze_performance_samples(samples: Array) -> Dictionary:
	"""Analyze performance samples for bottlenecks and patterns"""
	if samples.is_empty():
		return {"error": "No samples to analyze"}

	var analysis = {
		"cpu_analysis": _analyze_cpu_usage(samples),
		"memory_analysis": _analyze_memory_usage(samples),
		"rendering_analysis": _analyze_rendering_performance(samples),
		"bottlenecks": [],
		"recommendations": []
	}

	# Identify bottlenecks
	analysis.bottlenecks = _identify_bottlenecks(analysis)

	# Generate recommendations
	analysis.recommendations = _generate_performance_recommendations(analysis)

	return analysis

func _analyze_cpu_usage(samples: Array) -> Dictionary:
	"""Analyze CPU usage patterns"""
	var cpu_times = samples.map(func(s): return s.cpu_usage)
	var stats = statistical_analyzer.calculate_basic_statistics(cpu_times)

	return {
		"statistics": stats,
		"outliers": statistical_analyzer.detect_outliers(cpu_times),
		"peak_cpu_time": stats.max if stats.has("max") else 0,
		"average_cpu_time": stats.mean if stats.has("mean") else 0
	}

func _analyze_memory_usage(samples: Array) -> Dictionary:
	"""Analyze memory usage patterns"""
	var memory_samples = samples.map(func(s): return s.memory_usage)
	var stats = statistical_analyzer.calculate_basic_statistics(memory_samples)

	var initial_memory = memory_samples[0] if not memory_samples.is_empty() else 0
	var final_memory = memory_samples.back() if not memory_samples.is_empty() else 0
	var memory_growth = final_memory - initial_memory

	return {
		"statistics": stats,
		"memory_growth": memory_growth,
		"growth_rate": memory_growth / samples.size() if samples.size() > 0 else 0,
		"leak_suspected": memory_growth > 10 * 1024 * 1024  # 10MB growth
	}

func _analyze_rendering_performance(samples: Array) -> Dictionary:
	"""Analyze rendering performance"""
	var fps_samples = samples.map(func(s): return s.fps)
	var draw_call_samples = samples.map(func(s): return s.draw_calls)

	var fps_stats = statistical_analyzer.calculate_basic_statistics(fps_samples)
	var draw_call_stats = statistical_analyzer.calculate_basic_statistics(draw_call_samples)

	return {
		"fps_statistics": fps_stats,
		"draw_call_statistics": draw_call_stats,
		"average_fps": fps_stats.mean if fps_stats.has("mean") else 0,
		"frame_drops": fps_samples.filter(func(fps): return fps < 30).size()
	}

func _identify_bottlenecks(analysis: Dictionary) -> Array:
	"""Identify performance bottlenecks"""
	var bottlenecks = []

	var cpu_analysis = analysis.cpu_analysis
	var memory_analysis = analysis.memory_analysis
	var rendering_analysis = analysis.rendering_analysis

	# CPU bottlenecks
	if cpu_analysis.has("statistics") and cpu_analysis.statistics.has("p95"):
		if cpu_analysis.statistics.p95 > 16.67:  # 60 FPS threshold
			bottlenecks.append("High CPU usage detected - consider optimizing processing")

	# Memory bottlenecks
	if memory_analysis.leak_suspected:
		bottlenecks.append("Memory leak suspected - investigate memory management")

	if memory_analysis.growth_rate > 1024 * 1024:  # 1MB per sample growth
		bottlenecks.append("High memory growth rate - potential memory leak")

	# Rendering bottlenecks
	if rendering_analysis.has("fps_statistics") and rendering_analysis.fps_statistics.has("mean"):
		if rendering_analysis.fps_statistics.mean < 30:
			bottlenecks.append("Low frame rate detected - optimize rendering pipeline")

	if rendering_analysis.frame_drops > analysis.sample_count * 0.1:  # 10% frame drops
		bottlenecks.append("Excessive frame drops - investigate rendering bottlenecks")

	return bottlenecks

func _generate_performance_recommendations(analysis: Dictionary) -> Array:
	"""Generate performance optimization recommendations"""
	var recommendations = []

	for bottleneck in analysis.bottlenecks:
		match bottleneck:
			"High CPU usage detected - consider optimizing processing":
				recommendations.append("Profile CPU-intensive functions and optimize algorithms")
				recommendations.append("Consider using multi-threading for CPU-bound operations")
			"Memory leak suspected - investigate memory management":
				recommendations.append("Use the profiler to identify memory leaks")
				recommendations.append("Implement proper object cleanup and pooling")
			"High memory growth rate - potential memory leak":
				recommendations.append("Monitor object creation patterns")
				recommendations.append("Implement object reuse and caching strategies")
			"Low frame rate detected - optimize rendering pipeline":
				recommendations.append("Reduce draw calls and optimize rendering")
				recommendations.append("Implement level-of-detail (LOD) systems")
			"Excessive frame drops - investigate rendering bottlenecks":
				recommendations.append("Profile rendering pipeline for bottlenecks")
				recommendations.append("Optimize shader usage and texture compression")

	return recommendations

# ------------------------------------------------------------------------------
# SAMPLE BENCHMARK OPERATIONS
# ------------------------------------------------------------------------------
func _math_operations(count: int) -> void:
	"""Sample mathematical operations for benchmarking"""
	var result = 0.0
	for i in range(count):
		result += sin(float(i) * 0.01) * cos(float(i) * 0.01)
		result += sqrt(abs(float(i))) * tan(float(i) * 0.001)
		result += pow(float(i % 100), 2.5)
	# Use result to prevent optimization
	if result > 1000000:
		result = result * 0.1

func _string_processing(count: int) -> void:
	"""Sample string processing operations"""
	var test_string = "This is a test string for performance benchmarking"
	for i in range(count):
		var processed = test_string.replace("test", "benchmark")
		processed = processed.to_upper()
		processed = processed.substr(0, 20)
		processed = processed + str(i)

func _array_operations(count: int) -> void:
	"""Sample array manipulation operations"""
	var test_array = []
	for i in range(count):
		test_array.append(i * 2)
		test_array.shuffle()
		test_array.sort()
		test_array.remove_at(0)

func _object_allocation(count: int) -> void:
	"""Sample object allocation and destruction"""
	var objects = []
	for i in range(count):
		var obj = {
			"id": i,
			"name": "object_" + str(i),
			"data": [],
			"metadata": {}
		}
		for j in range(10):
			obj.data.append(j)
		objects.append(obj)
	# Objects are automatically cleaned up when function exits

func _memory_copy_operations(count: int) -> void:
	"""Sample memory copy operations"""
	var source_data = []
	for i in range(count):
		source_data.append("data_" + str(i))

	for i in range(100):  # Copy operations
		var copy = source_data.duplicate()
		copy.shuffle()

func _simulate_draw_calls(count: int) -> void:
	"""Simulate draw call operations"""
	# This would typically involve creating and manipulating visual elements
	# For benchmarking, we'll simulate the overhead
	for i in range(count):
		var simulated_draw = {
			"vertices": i * 100,
			"indices": i * 150,
			"textures": i % 5
		}
		# Simulate processing overhead
		var processing_time = simulated_draw.vertices * 0.001
		if processing_time > 10:
			processing_time = processing_time * 0.1

# ------------------------------------------------------------------------------
# INTEGRATION METHODS
# ------------------------------------------------------------------------------
func run_comprehensive_benchmark() -> bool:
	"""Run comprehensive benchmark suite with all available suites"""
	var comprehensive_results = {
		"timestamp": Time.get_unix_time_from_system(),
		"suites": {},
		"overall_summary": {},
		"recommendations": []
	}

	print("🚀 Running Comprehensive Performance Benchmark Suite")

	for suite_name in benchmark_suites.keys():
		print("📊 Running suite: " + suite_name)
		var suite_result = await run_benchmark_suite(suite_name)
		comprehensive_results.suites[suite_name] = suite_result

	# Calculate overall summary
	comprehensive_results.overall_summary = _calculate_comprehensive_summary(comprehensive_results.suites)

	# Generate comprehensive recommendations
	comprehensive_results.recommendations = _generate_comprehensive_recommendations(comprehensive_results)

	# Store comprehensive results in history
	benchmark_history.append({
		"type": "comprehensive",
		"results": comprehensive_results
	})

	return true

func _calculate_comprehensive_summary(suites: Dictionary) -> Dictionary:
	"""Calculate comprehensive summary across all suites"""
	var summary = {
		"total_suites": suites.size(),
		"total_benchmarks": 0,
		"average_performance": 0.0,
		"performance_distribution": {},
		"suite_performance": {}
	}

	var all_performances = []

	for suite_name in suites.keys():
		var suite = suites[suite_name]
		var suite_summary = suite.summary
		summary.suite_performance[suite_name] = suite_summary
		summary.total_benchmarks += suite_summary.total_benchmarks

		# Collect all benchmark performances
		for benchmark_name in suite.benchmarks.keys():
			var benchmark = suite.benchmarks[benchmark_name]
			all_performances.append(benchmark.average_time)

	if not all_performances.is_empty():
		summary.average_performance = all_performances.reduce(func(acc, val): return acc + val, 0.0) / all_performances.size()

		# Calculate performance distribution
		var stats = statistical_analyzer.calculate_basic_statistics(all_performances)
		summary.performance_distribution = {
			"fastest": stats.min if stats.has("min") else 0,
			"slowest": stats.max if stats.has("max") else 0,
			"median": stats.p50 if stats.has("p50") else 0,
			"p95": stats.p95 if stats.has("p95") else 0
		}

	return summary

func _generate_comprehensive_recommendations(comprehensive_results: Dictionary) -> Array:
	"""Generate comprehensive performance recommendations"""
	var recommendations = []

	var overall_summary = comprehensive_results.overall_summary

	# Performance distribution analysis
	var distribution = overall_summary.performance_distribution
	if distribution.p95 > distribution.median * 2:
		recommendations.append("High performance variance across benchmarks - focus on optimization consistency")

	# Suite performance analysis
	for suite_name in overall_summary.suite_performance.keys():
		var suite_perf = overall_summary.suite_performance[suite_name]
		if suite_perf.performance_variance > 0.2:
			recommendations.append("High variance in " + suite_name + " suite - investigate specific benchmarks")

	# Overall performance assessment
	if overall_summary.average_performance > 10.0:  # Arbitrary threshold
		recommendations.append("Overall performance is above optimal threshold - consider optimization strategies")

	return recommendations

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup benchmark framework resources"""
	# Generate final comprehensive report if benchmarks were run
	if not benchmark_history.is_empty():
		generate_comprehensive_report()

	# Cleanup components
	if statistical_analyzer:
		statistical_analyzer.queue_free()
	if regression_detector:
		regression_detector.queue_free()
	if baseline_manager:
		baseline_manager.queue_free()
	if ci_gate_checker:
		ci_gate_checker.queue_free()
	if trend_analyzer:
		trend_analyzer.queue_free()

	# Call parent cleanup
	super._exit_tree()

# ------------------------------------------------------------------------------
# REPORTING
# ------------------------------------------------------------------------------
func generate_comprehensive_report() -> bool:
	"""Generate comprehensive performance benchmark report"""
	var report = "📊 Comprehensive Performance Benchmark Report\n"
	report += "=".repeat(60) + "\n\n"

	report += "Benchmark Framework: PerformanceBenchmarkTest\n"
	report += "Timestamp: " + Time.get_datetime_string_from_system() + "\n"
	report += "Total Benchmark Suites: " + str(benchmark_history.size()) + "\n\n"

	for suite_result in benchmark_history:
		report += "🏃 Suite: " + suite_result.suite_name + "\n"
		report += "Description: " + suite_result.description + "\n"
		report += "Benchmarks Run: " + str(suite_result.summary.total_benchmarks) + "\n"
		report += "Average Performance: %.2f ms\n" % suite_result.summary.average_performance
		report += "Performance Variance: %.4f\n" % suite_result.summary.performance_variance

		if not suite_result.recommendations.is_empty():
			report += "Recommendations:\n"
			for rec in suite_result.recommendations:
				report += "  • " + rec + "\n"

		report += "\n"

	report += "🎯 Key Insights:\n"
	var insights = _extract_key_insights()
	for insight in insights:
		report += "  • " + insight + "\n"

	print(report)
	return true

func _extract_key_insights() -> Array:
	"""Extract key insights from benchmark history"""
	var insights = []

	if benchmark_history.is_empty():
		return ["No benchmark data available"]

	var total_benchmarks = 0
	var avg_performance = 0.0

	for suite in benchmark_history:
		total_benchmarks += suite.summary.total_benchmarks
		avg_performance += suite.summary.average_performance

	avg_performance /= benchmark_history.size()

	insights.append("Total benchmarks executed: " + str(total_benchmarks))
	insights.append("Average suite performance: %.2f ms" % avg_performance)

	# Find best and worst performing suites
	var best_suite = ""
	var worst_suite = ""
	var best_perf = INF
	var worst_perf = 0

	for suite in benchmark_history:
		var perf = suite.summary.average_performance
		if perf < best_perf:
			best_perf = perf
			best_suite = suite.suite_name
		if perf > worst_perf:
			worst_perf = perf
			worst_suite = suite.suite_name

	if best_suite != worst_suite:
		insights.append("Best performing suite: " + best_suite + " (%.2f ms)" % best_perf)
		insights.append("Suite needing attention: " + worst_suite + " (%.2f ms)" % worst_perf)

	return insights
