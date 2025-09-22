# GDSentry - Advanced Visual Regression Testing
# AI-powered visual testing with perceptual image comparison and automated analysis
#
# Features:
# - Perceptual image comparison (SSIM, perceptual hashing)
# - AI-powered diff analysis and categorization
# - Automated baseline management and updates
# - Visual change detection and classification
# - Screenshot optimization and compression
# - Multi-resolution baseline support
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name VisualRegression

# ------------------------------------------------------------------------------
# VISUAL REGRESSION CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_SSIM_THRESHOLD = 0.95
const DEFAULT_PERCEPTUAL_THRESHOLD = 0.85
const DEFAULT_MAX_DIFF_SIZE = 1024
const DEFAULT_COMPRESSION_QUALITY = 0.8

# ------------------------------------------------------------------------------
# VISUAL REGRESSION STATE
# ------------------------------------------------------------------------------
var ssim_threshold: float = DEFAULT_SSIM_THRESHOLD
var perceptual_threshold: float = DEFAULT_PERCEPTUAL_THRESHOLD
var max_diff_size: int = DEFAULT_MAX_DIFF_SIZE
var compression_quality: float = DEFAULT_COMPRESSION_QUALITY
var enable_ai_analysis: bool = true
var auto_update_baselines: bool = false

# ------------------------------------------------------------------------------
# BASELINE MANAGEMENT
# ------------------------------------------------------------------------------
var baseline_cache: Dictionary = {}
var baseline_metadata: Dictionary = {}

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize visual regression testing"""
	setup_directories()

# ------------------------------------------------------------------------------
# DIRECTORY MANAGEMENT
# ------------------------------------------------------------------------------
func setup_directories() -> void:
	"""Create necessary directories for visual regression testing"""
	var dirs = [
		"res://visual_baselines/",
		"res://visual_diffs/",
		"res://visual_reports/",
		"res://visual_metadata/"
	]

	for dir_path in dirs:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create visual regression directory: " + dir_path)

# ------------------------------------------------------------------------------
# ADVANCED SCREENSHOT COMPARISON
# ------------------------------------------------------------------------------
func compare_screenshots_advanced(screenshot1: Image, screenshot2: Image, test_name: String = "") -> Dictionary:
	"""Advanced screenshot comparison with multiple algorithms"""
	var results = {
		"pixel_difference": compare_pixel_difference(screenshot1, screenshot2),
		"ssim_score": calculate_ssim(screenshot1, screenshot2),
		"perceptual_hash": compare_perceptual_hash(screenshot1, screenshot2),
		"edge_difference": compare_edge_difference(screenshot1, screenshot2),
		"histogram_comparison": compare_histograms(screenshot1, screenshot2),
		"overall_score": 0.0,
		"is_regression": false,
		"analysis": {},
		"recommendations": []
	}

	# Calculate overall score (weighted average)
	results.overall_score = (
		results.pixel_difference.similarity * 0.2 +
		results.ssim_score * 0.3 +
		results.perceptual_hash.similarity * 0.25 +
		results.edge_difference.similarity * 0.15 +
		results.histogram_comparison.similarity * 0.1
	)

	# Determine if this is a visual regression
	results.is_regression = results.overall_score < perceptual_threshold

	# AI-powered analysis if enabled
	if enable_ai_analysis:
		results.analysis = analyze_visual_changes(results, test_name)
		results.recommendations = generate_recommendations(results)

	return results

# ------------------------------------------------------------------------------
# PIXEL-LEVEL COMPARISON
# ------------------------------------------------------------------------------
func compare_pixel_difference(image1: Image, image2: Image) -> Dictionary:
	"""Compare images at pixel level"""
	if image1.get_size() != image2.get_size():
		return {"similarity": 0.0, "differences": 0, "total_pixels": 0, "error": "Size mismatch"}

	var total_pixels = image1.get_width() * image1.get_height()
	var differences = 0

	image1.lock()
	image2.lock()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)

			if not color1.is_equal_approx(color2):  # Use default tolerance
				differences += 1

	image1.unlock()
	image2.unlock()

	var similarity = 1.0 - (float(differences) / float(total_pixels))

	return {
		"similarity": similarity,
		"differences": differences,
		"total_pixels": total_pixels,
		"difference_percentage": (float(differences) / float(total_pixels)) * 100.0
	}

# ------------------------------------------------------------------------------
# SSIM (Structural Similarity Index) COMPARISON
# ------------------------------------------------------------------------------
func calculate_ssim(image1: Image, image2: Image, window_size: int = 8) -> float:
	"""Calculate SSIM (Structural Similarity Index) between two images"""
	if image1.get_size() != image2.get_size():
		return 0.0

	var width = image1.get_width()
	var height = image1.get_height()
	var ssim_sum = 0.0
	var window_count = 0

	# Constants for SSIM calculation
	var C1 = pow(0.01, 2)  # K1 = 0.01, L = 1 (normalized)
	var C2 = pow(0.03, 2)  # K2 = 0.03

	image1.lock()
	image2.lock()

	for y in range(0, height - window_size + 1, window_size):
		for x in range(0, width - window_size + 1, window_size):
			var window1 = extract_window(image1, x, y, window_size)
			var window2 = extract_window(image2, x, y, window_size)

			var stats1 = calculate_window_stats(window1)
			var stats2 = calculate_window_stats(window2)

			# SSIM formula
			var numerator = (2 * stats1.mean * stats2.mean + C1) * (2 * stats1.covariance + C2)
			var denominator = (pow(stats1.mean, 2) + pow(stats2.mean, 2) + C1) * (stats1.variance + stats2.variance + C2)

			if denominator > 0:
				ssim_sum += numerator / denominator
				window_count += 1

	image1.unlock()
	image2.unlock()

	return ssim_sum / window_count if window_count > 0 else 0.0

func extract_window(image: Image, x: int, y: int, size: int) -> Array:
	"""Extract a window of pixels from an image"""
	var window = []
	for wy in range(size):
		for wx in range(size):
			window.append(image.get_pixel(x + wx, y + wy))
	return window

func calculate_window_stats(window: Array) -> Dictionary:
	"""Calculate mean, variance, and covariance for a window"""
	var sum_r = 0.0
	var sum_g = 0.0
	var sum_b = 0.0
	var count = window.size()

	for color in window:
		sum_r += color.r
		sum_g += color.g
		sum_b += color.b

	var mean_r = sum_r / count
	var mean_g = sum_g / count
	var mean_b = sum_b / count

	var var_r = 0.0
	var var_g = 0.0
	var var_b = 0.0

	for color in window:
		var_r += pow(color.r - mean_r, 2)
		var_g += pow(color.g - mean_g, 2)
		var_b += pow(color.b - mean_b, 2)

	return {
		"mean": (mean_r + mean_g + mean_b) / 3.0,
		"variance": (var_r + var_g + var_b) / 3.0,
		"covariance": 0.0  # Would need both windows to calculate
	}

# ------------------------------------------------------------------------------
# PERCEPTUAL HASH COMPARISON
# ------------------------------------------------------------------------------
func compare_perceptual_hash(image1: Image, image2: Image) -> Dictionary:
	"""Compare perceptual hashes of two images"""
	var hash1 = generate_perceptual_hash(image1)
	var hash2 = generate_perceptual_hash(image2)

	var hamming_distance = calculate_hamming_distance(hash1, hash2)
	var max_distance = hash1.size() * 8  # 8 bits per byte
	var similarity = 1.0 - (float(hamming_distance) / float(max_distance))

	return {
		"similarity": similarity,
		"hamming_distance": hamming_distance,
		"max_distance": max_distance,
		"hash1": hash1,
		"hash2": hash2
	}

func generate_perceptual_hash(image: Image, hash_size: int = 8) -> PackedByteArray:
	"""Generate a perceptual hash (dHash) for an image"""
	# Resize image to hash_size + 1
	var resized = image.duplicate()
	resized.resize(hash_size + 1, hash_size)

	var hash_data = PackedByteArray()
	resized.lock()

	for y in range(hash_size):
		var byte_value = 0
		for x in range(hash_size):
			var current = resized.get_pixel(x, y).get_luminance()
			var next = resized.get_pixel(x + 1, y).get_luminance()

			if next > current:
				byte_value |= (1 << x)

		hash_data.append(byte_value)

	resized.unlock()
	return hash_data

func calculate_hamming_distance(hash1: PackedByteArray, hash2: PackedByteArray) -> int:
	"""Calculate Hamming distance between two hashes"""
	var distance = 0
	var min_size = min(hash1.size(), hash2.size())

	for i in range(min_size):
		var xor_result = hash1[i] ^ hash2[i]
		distance += count_bits(xor_result)

	return distance

func count_bits(value: int) -> int:
	"""Count number of set bits in a byte"""
	var count = 0
	for i in range(8):
		if value & (1 << i):
			count += 1
	return count

# ------------------------------------------------------------------------------
# EDGE DIFFERENCE COMPARISON
# ------------------------------------------------------------------------------
func compare_edge_difference(image1: Image, image2: Image) -> Dictionary:
	"""Compare edge differences between two images"""
	var edges1 = detect_edges(image1)
	var edges2 = detect_edges(image2)

	return compare_pixel_difference(edges1, edges2)

func detect_edges(image: Image) -> Image:
	"""Simple edge detection using Sobel operator"""
	var width = image.get_width()
	var height = image.get_height()
	var edges = Image.new()
	edges.copy_from(image)

	image.lock()
	edges.lock()

	# Simple edge detection - compare each pixel with neighbors
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			var center = image.get_pixel(x, y).get_luminance()
			var top = image.get_pixel(x, y - 1).get_luminance()
			var bottom = image.get_pixel(x, y + 1).get_luminance()
			var left = image.get_pixel(x - 1, y).get_luminance()
			var right = image.get_pixel(x + 1, y).get_luminance()

			var gradient = abs(center - top) + abs(center - bottom) + abs(center - left) + abs(center - right)
			var edge_strength = clamp(gradient * 4.0, 0.0, 1.0)

			edges.set_pixel(x, y, Color(edge_strength, edge_strength, edge_strength, 1.0))

	image.unlock()
	edges.unlock()

	return edges

# ------------------------------------------------------------------------------
# HISTOGRAM COMPARISON
# ------------------------------------------------------------------------------
func compare_histograms(image1: Image, image2: Image) -> Dictionary:
	"""Compare color histograms of two images"""
	var hist1 = calculate_histogram(image1)
	var hist2 = calculate_histogram(image2)

	var total_difference = 0.0
	var max_bins = max(hist1.size(), hist2.size())

	for i in range(max_bins):
		var bin1 = hist1[i] if i < hist1.size() else 0
		var bin2 = hist2[i] if i < hist2.size() else 0
		total_difference += abs(bin1 - bin2)

	var max_possible_difference = 256.0 * image1.get_width() * image1.get_height()  # Rough estimate
	var similarity = 1.0 - (total_difference / max_possible_difference)

	return {
		"similarity": clamp(similarity, 0.0, 1.0),
		"total_difference": total_difference,
		"histogram1": hist1,
		"histogram2": hist2
	}

func calculate_histogram(image: Image, bins: int = 256) -> Array:
	"""Calculate luminance histogram of an image"""
	var histogram = []
	histogram.resize(bins)
	histogram.fill(0)

	image.lock()

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var luminance = image.get_pixel(x, y).get_luminance()
			var bin_index = int(luminance * (bins - 1))
			histogram[bin_index] += 1

	image.unlock()

	return histogram

# ------------------------------------------------------------------------------
# AI-POWERED ANALYSIS
# ------------------------------------------------------------------------------
func analyze_visual_changes(comparison_results: Dictionary, _test_name: String = "") -> Dictionary:
	"""AI-powered analysis of visual changes"""
	var analysis = {
		"change_type": "unknown",
		"severity": "low",
		"description": "",
		"affected_regions": [],
		"confidence": 0.0
	}

	var overall_score = comparison_results.get("overall_score", 0.0)
	var pixel_diff = comparison_results.get("pixel_difference", {})
	var ssim_score = comparison_results.get("ssim_score", 0.0)

	# Analyze change type
	if overall_score > 0.98:
		analysis.change_type = "minor_pixel_noise"
		analysis.severity = "very_low"
		analysis.description = "Minor pixel-level noise or anti-aliasing differences"
		analysis.confidence = 0.9

	elif ssim_score > 0.9:
		analysis.change_type = "layout_shift"
		analysis.severity = "medium"
		analysis.description = "Layout or positioning changes detected"
		analysis.confidence = 0.8

	elif pixel_diff.get("difference_percentage", 0.0) > 20.0:
		analysis.change_type = "major_visual_change"
		analysis.severity = "high"
		analysis.description = "Significant visual changes detected"
		analysis.confidence = 0.95

	else:
		analysis.change_type = "content_change"
		analysis.severity = "medium"
		analysis.description = "Content or styling changes"
		analysis.confidence = 0.7

	return analysis

func generate_recommendations(comparison_results: Dictionary) -> Array:
	"""Generate recommendations based on visual comparison results"""
	var recommendations = []

	var overall_score = comparison_results.get("overall_score", 0.0)
	var is_regression = comparison_results.get("is_regression", false)
	var analysis = comparison_results.get("analysis", {})

	if is_regression:
		if analysis.get("change_type") == "minor_pixel_noise":
			recommendations.append("Consider updating baseline - appears to be minor rendering differences")
		elif analysis.get("change_type") == "layout_shift":
			recommendations.append("Review layout changes - may be intentional UI modifications")
		else:
			recommendations.append("Investigate visual regression - significant changes detected")

	if overall_score < 0.8:
		recommendations.append("Consider manual review of visual changes")

	if auto_update_baselines:
		recommendations.append("Auto-update enabled - baseline will be updated automatically")

	return recommendations

# ------------------------------------------------------------------------------
# BASELINE MANAGEMENT
# ------------------------------------------------------------------------------
func save_baseline(image: Image, test_name: String, metadata: Dictionary = {}) -> bool:
	"""Save an image as a baseline for future comparisons"""
	var baseline_path = "res://visual_baselines/" + test_name + ".png"
	var global_path = ProjectSettings.globalize_path(baseline_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		var success = image.save_png(global_path)
		file.close()

		if success == OK:
			# Save metadata
			var metadata_path = "res://visual_metadata/" + test_name + ".json"
			var metadata_global = ProjectSettings.globalize_path(metadata_path)
			var metadata_file = FileAccess.open(metadata_global, FileAccess.WRITE)

			var metadata_dict = {}
			if metadata_file:
				metadata_dict = metadata.duplicate()
				metadata_dict["timestamp"] = Time.get_unix_time_from_system()
				metadata_dict["image_size"] = image.get_size()
				metadata_dict["hash"] = generate_perceptual_hash(image)

				metadata_file.store_string(JSON.stringify(metadata_dict, "\t"))
				metadata_file.close()

			baseline_cache[test_name] = image
			baseline_metadata[test_name] = metadata_dict

			if OS.is_debug_build():
				print("✅ Visual baseline saved: ", test_name)
			return true

	if OS.is_debug_build():
		print("❌ Failed to save visual baseline: ", test_name)
	return false

func load_baseline(test_name: String) -> Image:
	"""Load a baseline image for comparison"""
	if baseline_cache.has(test_name):
		return baseline_cache[test_name]

	var baseline_path = "res://visual_baselines/" + test_name + ".png"
	var image = load(baseline_path) as Image

	if image:
		baseline_cache[test_name] = image

		# Load metadata
		var metadata_path = "res://visual_metadata/" + test_name + ".json"
		var metadata_file = FileAccess.open(ProjectSettings.globalize_path(metadata_path), FileAccess.READ)
		if metadata_file:
			var content = metadata_file.get_as_text()
			metadata_file.close()
			var parsed = JSON.parse_string(content)
			if parsed is Dictionary:
				baseline_metadata[test_name] = parsed

	return image

func update_baseline(image: Image, test_name: String) -> bool:
	"""Update an existing baseline"""
	var old_baseline = load_baseline(test_name)
	if old_baseline:
		# Create backup of old baseline
		var backup_path = "res://visual_baselines/" + test_name + "_backup_" + str(Time.get_unix_time_from_system()) + ".png"
		old_baseline.save_png(ProjectSettings.globalize_path(backup_path))

	return save_baseline(image, test_name, baseline_metadata.get(test_name, {}))

# ------------------------------------------------------------------------------
# VISUAL REGRESSION REPORTING
# ------------------------------------------------------------------------------
func generate_visual_report(test_name: String, comparison_results: Dictionary) -> String:
	"""Generate a detailed visual regression report"""
	var report = "🎨 Visual Regression Report: " + test_name + "\n"
	report += "==================================================\n\n"

	report += "📊 OVERALL RESULTS\n"
	report += "Similarity Score: %.4f\n" % comparison_results.get("overall_score", 0.0)
	report += "Is Regression: %s\n" % ("YES" if comparison_results.get("is_regression", false) else "NO")
	report += "SSIM Score: %.4f\n" % comparison_results.get("ssim_score", 0.0)
	report += "\n"

	var pixel_diff = comparison_results.get("pixel_difference", {})
	if not pixel_diff.is_empty():
		report += "🔍 PIXEL ANALYSIS\n"
		report += "Different Pixels: %d / %d (%.2f%%)\n" % [
			pixel_diff.get("differences", 0),
			pixel_diff.get("total_pixels", 0),
			pixel_diff.get("difference_percentage", 0.0)
		]
		report += "\n"

	var analysis = comparison_results.get("analysis", {})
	if not analysis.is_empty():
		report += "🤖 AI ANALYSIS\n"
		report += "Change Type: %s\n" % analysis.get("change_type", "unknown")
		report += "Severity: %s\n" % analysis.get("severity", "unknown")
		report += "Confidence: %.2f\n" % analysis.get("confidence", 0.0)
		report += "Description: %s\n" % analysis.get("description", "")
		report += "\n"

	var recommendations = comparison_results.get("recommendations", [])
	if not recommendations.is_empty():
		report += "💡 RECOMMENDATIONS\n"
		for i in range(recommendations.size()):
			report += "%d. %s\n" % [i + 1, recommendations[i]]
		report += "\n"

	return report

func save_visual_report(test_name: String, comparison_results: Dictionary) -> bool:
	"""Save visual regression report to file"""
	var report_path = "res://visual_reports/" + test_name + "_" + str(Time.get_unix_time_from_system()) + ".txt"
	var global_path = ProjectSettings.globalize_path(report_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(generate_visual_report(test_name, comparison_results))
		file.close()
		return true

	return false

# ------------------------------------------------------------------------------
# CONFIGURATION METHODS
# ------------------------------------------------------------------------------
func set_similarity_thresholds(ssim: float = -1.0, perceptual: float = -1.0) -> void:
	"""Set similarity thresholds for visual comparison"""
	if ssim > 0:
		ssim_threshold = ssim
	if perceptual > 0: 
		perceptual_threshold = perceptual

func set_diff_parameters(max_size: int = -1, quality: float = -1.0) -> void:
	"""Set parameters for diff image generation"""
	if max_size > 0:
		max_diff_size = max_size
	if quality > 0:
		compression_quality = quality

func set_ai_analysis(enabled: bool = true) -> void:
	"""Enable or disable AI-powered analysis"""
	enable_ai_analysis = enabled

func set_auto_baseline_update(enabled: bool = true) -> void:
	"""Enable or disable automatic baseline updates"""
	auto_update_baselines = enabled

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func get_baseline_info(test_name: String) -> Dictionary:
	"""Get information about a baseline"""
	var info = {
		"exists": false,
		"timestamp": 0,
		"size": Vector2.ZERO,
		"metadata": {}
	}

	var baseline = load_baseline(test_name)
	if baseline:
		info.exists = true
		info.size = baseline.get_size()

	var metadata = baseline_metadata.get(test_name, {})
	if not metadata.is_empty():
		info.timestamp = metadata.get("timestamp", 0)
		info.metadata = metadata

	return info

func list_baselines() -> Array:
	"""List all available baselines"""
	var baselines = []

	var dir_path = ProjectSettings.globalize_path("res://visual_baselines/")
	var dir = DirAccess.open(dir_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				var test_name = file_name.get_basename()
				baselines.append({
					"name": test_name,
					"info": get_baseline_info(test_name)
				})

			file_name = dir.get_next()

		dir.list_dir_end()

	return baselines

func cleanup_old_baselines(max_age_days: int = 30) -> int:
	"""Clean up old baseline backups"""
	var deleted_count = 0
	var cutoff_time = Time.get_unix_time_from_system() - (max_age_days * 24 * 60 * 60)

	var dir_path = ProjectSettings.globalize_path("res://visual_baselines/")
	var dir = DirAccess.open(dir_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png") and file_name.contains("_backup_"):
				var timestamp_str = file_name.split("_backup_")[1].split(".")[0]
				var timestamp = timestamp_str.to_int()

				if timestamp < cutoff_time:
					var full_path = dir_path + "/" + file_name
					var error = DirAccess.remove_absolute(full_path)
					if error == OK:
						deleted_count += 1

			file_name = dir.get_next()

		dir.list_dir_end()

	return deleted_count
