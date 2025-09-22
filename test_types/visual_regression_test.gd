# GDSentry - Visual Regression Test Class
# Advanced visual regression testing framework for GDSentry
#
# Features:
# - Baseline screenshot capture and storage with versioning
# - Advanced image comparison algorithms (pixel-by-pixel, perceptual)
# - Visual difference highlighting and reporting
# - Approval workflow for baseline updates
# - Multi-format report generation (HTML, JSON)
# - Region-of-interest (ROI) comparison
# - Performance monitoring and regression detection
# - Integration with CI/CD pipelines
#
# Author: GDSentry Framework
# Version: 2.0.0

extends VisualTest

class_name VisualRegressionTestFramework

# ------------------------------------------------------------------------------
# VISUAL REGRESSION TESTING CONSTANTS
# ------------------------------------------------------------------------------
# NOTE: DEFAULT_SCREENSHOT_DIR, BASELINE_DIR, DIFF_DIR, APPROVAL_DIR inherited from parent
const REPORTS_DIR = "res://test_reports/visual_regression/"
# APPROVAL_DIR inherited from parent

# Comparison algorithms
enum ComparisonAlgorithm {
	PIXEL_BY_PIXEL,
	PERCEPTUAL_HASH,
	STRUCTURAL_SIMILARITY,
	FEATURE_BASED
}

# Approval states
enum ApprovalState {
	PENDING,
	APPROVED,
	REJECTED,
	AUTO_APPROVED
}

# DEFAULT_TOLERANCE inherited from parent
const DEFAULT_PERCEPTUAL_THRESHOLD = 0.95
const MAX_BASELINE_VERSIONS = 10
const AUTO_APPROVE_THRESHOLD = 0.98

# ------------------------------------------------------------------------------
# VISUAL REGRESSION SPECIFIC STATE
# ------------------------------------------------------------------------------
# NOTE: config, screenshot_dir, baseline_dir, diff_dir, approval_dir, visual_tolerance, generate_diff_images, current_baseline_images inherited from parent

var reports_dir: String = REPORTS_DIR
var perceptual_threshold: float = DEFAULT_PERCEPTUAL_THRESHOLD
var auto_approve_similar: bool = true
var comparison_algorithm: ComparisonAlgorithm = ComparisonAlgorithm.PIXEL_BY_PIXEL

# Enhanced baseline management (extends parent functionality)
var baseline_versions: Dictionary = {}  # name -> [version1, version2, ...]
var pending_approvals: Dictionary = {}  # name -> approval_data
var comparison_results: Array = []

# Reporting and analytics
var test_session_id: String
# test_start_time inherited from Node2DTest
var test_end_time: float

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize visual regression testing environment"""
	super._ready()

	# Initialize test session
	test_session_id = "vr_" + str(randi()) + "_" + str(Time.get_unix_time_from_system())
	test_start_time = Time.get_ticks_usec() / 1000000.0

	# Initialize test configuration
	config = GDTestConfig.load_from_file()

	# Load visual regression test configuration
	load_visual_config()

	# Ensure all directories exist
	create_visual_directories()

	# Load baseline images and versions
	load_baseline_images()
	load_baseline_versions()

	# Load any pending approvals
	load_pending_approvals()

	print("🎯 Visual Regression Test initialized - Session: ", test_session_id)

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
func load_visual_config() -> void:
	"""Load visual regression testing configuration"""
	if config and config.visual_settings:
		screenshot_dir = config.visual_settings.get("screenshot_directory", DEFAULT_SCREENSHOT_DIR)
		baseline_dir = config.visual_settings.get("baseline_directory", BASELINE_DIR)
		diff_dir = config.visual_settings.get("diff_directory", DIFF_DIR)
		reports_dir = config.visual_settings.get("reports_directory", REPORTS_DIR)
		approval_dir = config.visual_settings.get("approval_directory", APPROVAL_DIR)

		visual_tolerance = config.visual_settings.get("visual_tolerance", DEFAULT_TOLERANCE)
		perceptual_threshold = config.visual_settings.get("perceptual_threshold", DEFAULT_PERCEPTUAL_THRESHOLD)

		generate_diff_images = config.visual_settings.get("generate_diff_images", true)
		auto_approve_similar = config.visual_settings.get("auto_approve_similar", true)

		var algorithm_str = config.visual_settings.get("comparison_algorithm", "pixel_by_pixel")
		comparison_algorithm = _parse_comparison_algorithm(algorithm_str)

func create_visual_directories() -> void:
	"""Create necessary directories for visual regression testing"""
	var dirs_to_create = [screenshot_dir, baseline_dir, diff_dir, reports_dir, approval_dir]

	for dir_path in dirs_to_create:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create visual regression test directory: " + dir_path)
			else:
				print("📁 Created directory: ", dir_path)

func load_baseline_images() -> void:
	"""Load baseline images for comparison"""
	var baseline_path = ProjectSettings.globalize_path(baseline_dir)
	if not DirAccess.dir_exists_absolute(baseline_path):
		return

	var dir = DirAccess.open(baseline_path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			var image_path = baseline_dir.path_join(file_name)
			var texture = load(image_path)
			if texture:
				current_baseline_images[file_name.get_basename()] = texture
		file_name = dir.get_next()

	dir.list_dir_end()

func load_baseline_versions() -> void:
	"""Load baseline version history"""
	var baseline_path = ProjectSettings.globalize_path(baseline_dir)
	if not DirAccess.dir_exists_absolute(baseline_path):
		return

	var dir = DirAccess.open(baseline_path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			# Parse versioned files (format: name_v1.png, name_v2.png, etc.)
			if file_name.ends_with(".png"):
				var base_name = file_name.get_basename()
				var version_parts = base_name.split("_v")

				if version_parts.size() == 2:
					var baseline_name = version_parts[0]
					var version = version_parts[1]

					if not baseline_versions.has(baseline_name):
						baseline_versions[baseline_name] = []

					baseline_versions[baseline_name].append(version)

					# Sort versions
					baseline_versions[baseline_name].sort_custom(func(a, b): return int(a) < int(b))

		file_name = dir.get_next()

	dir.list_dir_end()

func load_pending_approvals() -> void:
	"""Load any pending approval requests"""
	var approval_path = ProjectSettings.globalize_path(approval_dir)
	if not DirAccess.dir_exists_absolute(approval_path):
		return

	var dir = DirAccess.open(approval_path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var approval_file = approval_dir.path_join(file_name)
			var approval_data = _load_approval_data(approval_file)
			if approval_data:
				var baseline_name = file_name.get_basename()
				pending_approvals[baseline_name] = approval_data

		file_name = dir.get_next()

	dir.list_dir_end()

func _parse_comparison_algorithm(algorithm_str: String) -> ComparisonAlgorithm:
	"""Parse comparison algorithm string"""
	match algorithm_str.to_lower():
		"perceptual_hash", "phash":
			return ComparisonAlgorithm.PERCEPTUAL_HASH
		"structural_similarity", "ssim":
			return ComparisonAlgorithm.STRUCTURAL_SIMILARITY
		"feature_based", "features":
			return ComparisonAlgorithm.FEATURE_BASED
		"pixel_by_pixel", "pixel", _:
			return ComparisonAlgorithm.PIXEL_BY_PIXEL

func _load_approval_data(approval_file: String) -> Dictionary:
	"""Load approval data from JSON file"""
	var global_path = ProjectSettings.globalize_path(approval_file)
	var file = FileAccess.open(global_path, FileAccess.READ)

	if not file:
		return {}

	var json_content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_content)

	if parse_result != OK:
		push_warning("Failed to parse approval file: " + approval_file)
		return {}

	return json.get_data()

# ------------------------------------------------------------------------------
# SCREENSHOT CAPTURE
# ------------------------------------------------------------------------------
func take_screenshot(screenshot_name: String = "screenshot") -> Image:
	"""Take a screenshot of the current viewport"""
	var viewport = get_viewport()
	if not viewport:
		push_error("No viewport available for screenshot")
		return null

	var image = viewport.get_texture().get_image()
	if not image:
		push_error("Failed to capture screenshot")
		return null

	# Save screenshot if directory exists
	var screenshot_path = screenshot_dir.path_join(screenshot_name + ".png")
	var global_path = ProjectSettings.globalize_path(screenshot_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		image.save_png(global_path)
		file.close()
		print("📸 Screenshot saved: ", screenshot_path)

	return image

func take_timestamped_screenshot(screenshot_name: String = "test") -> Image:
	"""Take a screenshot with timestamp"""
	var timestamp = Time.get_datetime_string_from_system().replace(" ", "_").replace(":", "-")
	var final_name = screenshot_name + "_" + timestamp
	return take_screenshot(final_name)

# ------------------------------------------------------------------------------
# VISUAL COMPARISON
# ------------------------------------------------------------------------------
func compare_with_baseline(screenshot_name: String, tolerance: float = -1.0, algorithm: int = 0, region: Rect2 = Rect2()) -> Dictionary:
	"""Compare current screenshot with baseline image using regression testing"""
	if tolerance < 0:
		tolerance = visual_tolerance

	var current_image = take_screenshot(screenshot_name)
	if not current_image:
		return _create_comparison_result(false, "Failed to capture screenshot")

	if not current_baseline_images.has(screenshot_name):
		return _create_comparison_result(false, "No baseline image found for: " + screenshot_name)

	var baseline_texture = current_baseline_images[screenshot_name]
	var baseline_image = baseline_texture.get_image()

	if not baseline_image:
		return _create_comparison_result(false, "Failed to load baseline image")

	# Use specified region or full image
	var image_to_compare = current_image
	var baseline_to_compare = baseline_image

	if region != Rect2():
		image_to_compare = _extract_region(current_image, region)
		baseline_to_compare = _extract_region(baseline_image, region)

	# Perform comparison based on selected algorithm
	var result = Dictionary()
	match algorithm:
		ComparisonAlgorithm.PIXEL_BY_PIXEL:
			result = compare_images_pixel_by_pixel(image_to_compare, baseline_to_compare, tolerance)
		ComparisonAlgorithm.PERCEPTUAL_HASH:
			result = compare_images_perceptual_hash(image_to_compare, baseline_to_compare, perceptual_threshold)
		ComparisonAlgorithm.STRUCTURAL_SIMILARITY:
			result = compare_images_structural_similarity(image_to_compare, baseline_to_compare, tolerance)
		ComparisonAlgorithm.FEATURE_BASED:
			result = compare_images_feature_based(image_to_compare, baseline_to_compare, tolerance)

	# Store comparison result
	var comparison_data = {
		"screenshot_name": screenshot_name,
		"timestamp": Time.get_unix_time_from_system(),
		"algorithm": algorithm,
		"region": region,
		"result": result
	}
	comparison_results.append(comparison_data)

	# Handle auto-approval for similar images
	if not result.success and result.similarity >= AUTO_APPROVE_THRESHOLD and auto_approve_similar:
		result.success = true
		result.auto_approved = true
		print("🎯 Auto-approved similar image for '%s' (similarity: %.2f%%)" % [screenshot_name, result.similarity * 100])

	# Generate diff images if needed
	if not result.success and generate_diff_images:
		generate_diff_image(screenshot_name, image_to_compare, baseline_to_compare)

	return result

func compare_images(image1: Image, image2: Image, tolerance: float = -1.0) -> Dictionary:
	"""Compare two images and return similarity results"""
	if tolerance < 0:
		tolerance = visual_tolerance

	if image1.get_size() != image2.get_size():
		return {
			"success": false,
			"similarity": 0.0,
			"error": "Image sizes don't match",
			"size1": image1.get_size(),
			"size2": image2.get_size()
		}

	var total_pixels = image1.get_width() * image1.get_height()
	var matching_pixels = 0

	image1.lock()
	image2.lock()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)

			if color1.is_equal_approx(color2):
				matching_pixels += 1

	image1.unlock()
	image2.unlock()

	var similarity = float(matching_pixels) / float(total_pixels)

	return _create_comparison_result(similarity >= (1.0 - tolerance), "", {
		"similarity": similarity,
		"matching_pixels": matching_pixels,
		"total_pixels": total_pixels,
		"tolerance": tolerance
	})

func generate_diff_image(image_name: String, image1: Image, image2: Image) -> void:
	"""Generate a visual diff image highlighting differences"""
	var diff_image = Image.new()
	diff_image.copy_from(image1)
	diff_image.lock()

	image2.lock()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)

			if not color1.is_equal_approx(color2):
				# Highlight differences in red
				diff_image.set_pixel(x, y, Color(1, 0, 0, 1))
			else:
				# Keep original color but slightly transparent
				var blended = color1.lerp(Color(0, 0, 0, 0.5), 0.3)
				diff_image.set_pixel(x, y, blended)

	image2.unlock()
	diff_image.unlock()

	# Save diff image
	var diff_path = diff_dir.path_join(image_name + "_diff.png")
	var global_path = ProjectSettings.globalize_path(diff_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		diff_image.save_png(global_path)
		file.close()
		print("🔍 Diff image saved: ", diff_path)

# ------------------------------------------------------------------------------
# ADVANCED COMPARISON ALGORITHMS
# ------------------------------------------------------------------------------
func compare_images_pixel_by_pixel(image1: Image, image2: Image, tolerance: float) -> Dictionary:
	"""Enhanced pixel-by-pixel comparison with detailed metrics"""
	if image1.get_size() != image2.get_size():
		return _create_comparison_result(false, "Image sizes don't match", {
			"similarity": 0.0,
			"size1": image1.get_size(),
			"size2": image2.get_size()
		})

	var total_pixels = image1.get_width() * image1.get_height()
	var matching_pixels = 0
	var different_pixels = 0
	var max_difference = 0.0
	var total_difference = 0.0

	image1.lock()
	image2.lock()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)

			if color1.is_equal_approx(color2):
				matching_pixels += 1
			else:
				different_pixels += 1
				var difference = color1.distance_to(color2)
				total_difference += difference
				max_difference = max(max_difference, difference)

	image1.unlock()
	image2.unlock()

	var similarity = float(matching_pixels) / float(total_pixels)
	var avg_difference = total_difference / float(different_pixels) if different_pixels > 0 else 0.0

	return _create_comparison_result(similarity >= (1.0 - tolerance), "", {
		"similarity": similarity,
		"matching_pixels": matching_pixels,
		"different_pixels": different_pixels,
		"total_pixels": total_pixels,
		"tolerance": tolerance,
		"max_difference": max_difference,
		"avg_difference": avg_difference
	})

func compare_images_perceptual_hash(image1: Image, image2: Image, threshold: float) -> Dictionary:
	"""Compare images using perceptual hashing (simplified implementation)"""
	# This is a simplified perceptual hash implementation
	# In a real implementation, you'd use a proper perceptual hash library

	var hash1 = _calculate_simple_hash(image1)
	var hash2 = _calculate_simple_hash(image2)

	var similarity = _calculate_hash_similarity(hash1, hash2)

	return _create_comparison_result(similarity >= threshold, "", {
		"similarity": similarity,
		"threshold": threshold,
		"hash1": hash1,
		"hash2": hash2
	})

func compare_images_structural_similarity(image1: Image, image2: Image, tolerance: float) -> Dictionary:
	"""Compare images using structural similarity (simplified SSIM)"""
	if image1.get_size() != image2.get_size():
		return _create_comparison_result(false, "Image sizes don't match")

	# Simplified SSIM calculation
	var ssim_score = _calculate_simple_ssim(image1, image2)

	return _create_comparison_result(ssim_score >= (1.0 - tolerance), "", {
		"similarity": ssim_score,
		"tolerance": tolerance
	})

func compare_images_feature_based(image1: Image, image2: Image, tolerance: float) -> Dictionary:
	"""Compare images using feature-based analysis (simplified)"""
	# This would use more advanced computer vision techniques
	# For now, fall back to pixel-by-pixel comparison
	push_warning("Feature-based comparison not fully implemented, using pixel-by-pixel")
	return compare_images_pixel_by_pixel(image1, image2, tolerance)

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func _create_comparison_result(success: bool, error: String = "", data: Dictionary = {}) -> Dictionary:
	"""Create a standardized comparison result"""
	var result = {
		"success": success,
		"error": error,
		"timestamp": Time.get_unix_time_from_system(),
		"algorithm": comparison_algorithm
	}

	# Merge additional data
	for key in data.keys():
		result[key] = data[key]

	return result

func _extract_region(image: Image, region: Rect2) -> Image:
	"""Extract a region from an image"""
	var extracted = Image.create(int(region.size.x), int(region.size.y), false, image.get_format())

	image.lock()
	extracted.lock()

	for y in range(int(region.size.y)):
		for x in range(int(region.size.x)):
			var source_x = int(region.position.x + x)
			var source_y = int(region.position.y + y)

			if source_x >= 0 and source_x < image.get_width() and source_y >= 0 and source_y < image.get_height():
				var color = image.get_pixel(source_x, source_y)
				extracted.set_pixel(x, y, color)

	image.unlock()
	extracted.unlock()

	return extracted

func _calculate_simple_hash(image: Image) -> String:
	"""Calculate a simple hash for perceptual comparison"""
	var hash_value = 0
	image.lock()

	for y in range(0, image.get_height(), 4):  # Sample every 4th pixel
		for x in range(0, image.get_width(), 4):
			var color = image.get_pixel(x, y)
			var brightness = (color.r + color.g + color.b) / 3.0
			hash_value = hash_value * 31 + int(brightness * 255)

	image.unlock()

	return str(hash_value)

func _calculate_hash_similarity(hash1: String, hash2: String) -> float:
	"""Calculate similarity between two hashes"""
	if hash1 == hash2:
		return 1.0

	# Simple similarity based on string difference
	var diff_count = 0
	var min_length = min(hash1.length(), hash2.length())

	for i in range(min_length):
		if hash1[i] != hash2[i]:
			diff_count += 1

	diff_count += abs(hash1.length() - hash2.length())

	return 1.0 - (float(diff_count) / float(max(hash1.length(), hash2.length())))

func _calculate_simple_ssim(image1: Image, image2: Image) -> float:
	"""Calculate a simplified SSIM (Structural Similarity Index)"""
	if image1.get_size() != image2.get_size():
		return 0.0

	var total_pixels = image1.get_width() * image1.get_height()
	var ssim_sum = 0.0

	image1.lock()
	image2.lock()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)

			# Simple luminance comparison
			var lum1 = (color1.r + color1.g + color1.b) / 3.0
			var lum2 = (color2.r + color2.g + color2.b) / 3.0

			# SSIM formula (simplified)
			var c1 = 0.01 * 0.01  # Small constant to avoid division by zero
			var c2 = 0.03 * 0.03

			var mean1 = lum1
			var mean2 = lum2
			var var1 = 0.0  # Simplified variance
			var var2 = 0.0
			var covar = (lum1 - mean1) * (lum2 - mean2)

			var numerator = (2 * mean1 * mean2 + c1) * (2 * covar + c2)
			var denominator = (mean1 * mean1 + mean2 * mean2 + c1) * (var1 + var2 + c2)

			if denominator > 0:
				ssim_sum += numerator / denominator

	image1.unlock()
	image2.unlock()

	return ssim_sum / float(total_pixels)

# ------------------------------------------------------------------------------
# VISUAL ASSERTIONS
# ------------------------------------------------------------------------------
func assert_visual_match(baseline_name: String, tolerance: float = -1.0, message: String = "", algorithm: int = 0, region: Rect2 = Rect2()) -> bool:
	"""Assert that current visual state matches baseline"""
	var result = compare_with_baseline(baseline_name, tolerance, algorithm, region)

	if not result.success:
		var similarity_text = "%.2f%%" % (result.similarity * 100) if result.has("similarity") else "N/A"
		var error_msg = message if not message.is_empty() else "Visual mismatch for baseline '%s'. Similarity: %s" % [baseline_name, similarity_text]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_visual_match_region(baseline_name: String, region: Rect2, tolerance: float = -1.0, message: String = "", algorithm: int = 0) -> bool:
	"""Assert that a specific region matches baseline"""
	var result = compare_with_baseline(baseline_name, tolerance, algorithm, region)

	if not result.success:
		var similarity_text = "%.2f%%" % (result.similarity * 100) if result.has("similarity") else "N/A"
		var region_text = "Region: %s" % region
		var error_msg = message if not message.is_empty() else "Visual mismatch for baseline '%s' in %s. Similarity: %s" % [baseline_name, region_text, similarity_text]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_no_visual_regression(baseline_name: String, message: String = "", algorithm: int = 0) -> bool:
	"""Assert no visual regression from baseline (enhanced version)"""
	var result = compare_with_baseline(baseline_name, -1.0, algorithm)

	if not result.success:
		var similarity_text = "%.2f%%" % (result.similarity * 100) if result.has("similarity") else "N/A"
		var error_msg = message if not message.is_empty() else "Visual regression detected for '%s'. Similarity: %s. Check diff image for details." % [baseline_name, similarity_text]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_color_at_position(pixel_position: Vector2, expected_color: Color, _tolerance: float = 0.1, message: String = "") -> bool:
	"""Assert that a specific pixel has the expected color"""
	var screenshot = take_screenshot("temp_color_check")
	if not screenshot:
		var error_msg = message if not message.is_empty() else "Failed to capture screenshot for color check"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if pixel_position.x < 0 or pixel_position.y < 0 or pixel_position.x >= screenshot.get_width() or pixel_position.y >= screenshot.get_height():
		var error_msg = message if not message.is_empty() else "Position %s is outside screenshot bounds" % pixel_position
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var actual_color = screenshot.get_pixelv(pixel_position)

	if not actual_color.is_equal_approx(expected_color):
		var error_msg = message if not message.is_empty() else "Color at %s is %s, expected %s" % [pixel_position, actual_color, expected_color]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_no_visual_changes(_region: Rect2 = Rect2(), message: String = "") -> bool:
	"""Assert that a region has no visual changes from baseline"""
	# This would require storing the previous frame's screenshot
	# Implementation would depend on test setup
	var error_msg = message if not message.is_empty() else "assert_no_visual_changes not fully implemented"
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# BASELINE MANAGEMENT
# ------------------------------------------------------------------------------
func create_baseline(baseline_name: String) -> bool:
	"""Create a new baseline image from current visual state"""
	var image = take_screenshot("baseline_" + baseline_name)
	if not image:
		return false

	var baseline_path = baseline_dir.path_join(baseline_name + ".png")
	var global_path = ProjectSettings.globalize_path(baseline_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		image.save_png(global_path)
		file.close()

		# Update current baselines
		var texture = ImageTexture.create_from_image(image)
		current_baseline_images[baseline_name] = texture

		print("📋 Baseline created: ", baseline_path)
		return true

	return false

func update_baseline(baseline_name: String) -> bool:
	"""Update an existing baseline image"""
	return create_baseline(baseline_name)

func list_baselines() -> Array:
	"""List all available baseline images"""
	return current_baseline_images.keys()

# ------------------------------------------------------------------------------
# ENHANCED BASELINE MANAGEMENT (VISUAL REGRESSION)
# ------------------------------------------------------------------------------
func create_baseline_with_version(baseline_name: String, description: String = "") -> bool:
	"""Create a new baseline with version control"""
	var next_version = _get_next_version(baseline_name)

	# Create versioned baseline
	var versioned_name = baseline_name + "_v" + str(next_version)
	var success = take_screenshot(versioned_name) != null

	if success:
		# Update baseline versions
		if not baseline_versions.has(baseline_name):
			baseline_versions[baseline_name] = []
		baseline_versions[baseline_name].append(str(next_version))

		# Sort versions
		baseline_versions[baseline_name].sort_custom(func(a, b): return int(a) < int(b))

		# Update current baseline to latest version
		var baseline_path = baseline_dir.path_join(versioned_name + ".png")
		var texture = load(baseline_path)
		if texture:
			current_baseline_images[baseline_name] = texture

		# Create metadata
		var metadata = {
			"name": baseline_name,
			"version": next_version,
			"description": description,
			"created_at": Time.get_unix_time_from_system(),
			"session_id": test_session_id,
			"viewport_size": get_viewport().get_visible_rect().size
		}

		_save_baseline_metadata(baseline_name, next_version, metadata)

		print("📋 Baseline created: %s (v%d)" % [baseline_name, next_version])
	else:
		push_error("Failed to create baseline: " + baseline_name)

	return success

func _get_next_version(baseline_name: String) -> int:
	"""Get the next version number for a baseline"""
	if not baseline_versions.has(baseline_name) or baseline_versions[baseline_name].is_empty():
		return 1

	var latest_version = baseline_versions[baseline_name].back()
	return int(latest_version) + 1

func _save_baseline_metadata(baseline_name: String, version: int, metadata: Dictionary) -> void:
	"""Save baseline metadata"""
	var metadata_file = baseline_dir.path_join(baseline_name + "_v" + str(version) + "_metadata.json")
	var global_path = ProjectSettings.globalize_path(metadata_file)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(metadata, "\t")
		file.store_string(json_string)
		file.close()

func get_baseline_versions(baseline_name: String) -> Array:
	"""Get all versions of a baseline"""
	if baseline_versions.has(baseline_name):
		return baseline_versions[baseline_name].duplicate()
	return []

func switch_baseline_version(baseline_name: String, version: int) -> bool:
	"""Switch to a specific baseline version"""
	var version_str = str(version)
	if not baseline_versions.has(baseline_name) or not baseline_versions[baseline_name].has(version_str):
		push_error("Baseline version not found: %s v%d" % [baseline_name, version])
		return false

	var versioned_name = baseline_name + "_v" + version_str
	var baseline_path = baseline_dir.path_join(versioned_name + ".png")
	var texture = load(baseline_path)

	if texture:
		current_baseline_images[baseline_name] = texture
		print("🔄 Switched baseline: %s to version %d" % [baseline_name, version])
		return true

	return false

func create_approval_request(baseline_name: String, differences: Dictionary, reason: String = "") -> bool:
	"""Create an approval request for baseline changes"""
	var approval_data = {
		"baseline_name": baseline_name,
		"requested_at": Time.get_unix_time_from_system(),
		"session_id": test_session_id,
		"differences": differences,
		"reason": reason,
		"status": "pending",
		"approved_by": "",
		"approved_at": 0
	}

	var approval_file = approval_dir.path_join(baseline_name + ".json")
	var global_path = ProjectSettings.globalize_path(approval_file)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(approval_data, "\t")
		file.store_string(json_string)
		file.close()

		pending_approvals[baseline_name] = approval_data
		print("📝 Approval request created for: " + baseline_name)
		return true

	return false

func approve_baseline_change(baseline_name: String, approved_by: String = "auto") -> bool:
	"""Approve a baseline change"""
	if not pending_approvals.has(baseline_name):
		push_error("No pending approval found for: " + baseline_name)
		return false

	var approval_data = pending_approvals[baseline_name]
	approval_data["status"] = "approved"
	approval_data["approved_by"] = approved_by
	approval_data["approved_at"] = Time.get_unix_time_from_system()

	# Update approval file
	var approval_file = approval_dir.path_join(baseline_name + ".json")
	var global_path = ProjectSettings.globalize_path(approval_file)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(approval_data, "\t")
		file.store_string(json_string)
		file.close()

		print("✅ Baseline change approved: %s by %s" % [baseline_name, approved_by])
		return true

	return false

func reject_baseline_change(baseline_name: String, rejected_by: String = "auto", reason: String = "") -> bool:
	"""Reject a baseline change"""
	if not pending_approvals.has(baseline_name):
		push_error("No pending approval found for: " + baseline_name)
		return false

	var approval_data = pending_approvals[baseline_name]
	approval_data["status"] = "rejected"
	approval_data["approved_by"] = rejected_by
	approval_data["approved_at"] = Time.get_unix_time_from_system()
	approval_data["rejection_reason"] = reason

	# Update approval file
	var approval_file = approval_dir.path_join(baseline_name + ".json")
	var global_path = ProjectSettings.globalize_path(approval_file)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(approval_data, "\t")
		file.store_string(json_string)
		file.close()

		print("❌ Baseline change rejected: %s by %s" % [baseline_name, rejected_by])
		return true

	return false

# ------------------------------------------------------------------------------
# REPORTING AND ANALYTICS
# ------------------------------------------------------------------------------
func generate_regression_report() -> Dictionary:
	"""Generate a comprehensive visual regression report"""
	test_end_time = Time.get_ticks_usec() / 1000000.0

	var total_comparisons = comparison_results.size()
	var failed_comparisons = comparison_results.filter(func(r): return not r.result.success).size()
	var successful_comparisons = total_comparisons - failed_comparisons

	var report = {
		"session_id": test_session_id,
		"start_time": test_start_time,
		"end_time": test_end_time,
		"duration": test_end_time - test_start_time,
		"total_comparisons": total_comparisons,
		"successful_comparisons": successful_comparisons,
		"failed_comparisons": failed_comparisons,
		"success_rate": successful_comparisons / float(total_comparisons) * 100.0 if total_comparisons > 0 else 0.0,
		"comparison_results": comparison_results.duplicate(true),
		"baseline_versions": baseline_versions.duplicate(true),
		"pending_approvals": pending_approvals.duplicate(true),
		"configuration": {
			"comparison_algorithm": comparison_algorithm,
			"visual_tolerance": visual_tolerance,
			"perceptual_threshold": perceptual_threshold,
			"auto_approve_similar": auto_approve_similar
		}
	}

	return report

func export_regression_report(file_path: String) -> bool:
	"""Export regression report to JSON file"""
	var report = generate_regression_report()
	var json_string = JSON.stringify(report, "\t")

	var global_path = ProjectSettings.globalize_path(file_path)
	var file = FileAccess.open(global_path, FileAccess.WRITE)

	if not file:
		push_error("Failed to open file for report export: " + file_path)
		return false

	file.store_string(json_string)
	file.close()

	print("📊 Visual regression report exported: " + file_path)
	return true

func generate_html_report(output_path: String) -> bool:
	"""Generate an HTML report for visual regression results"""
	var report = generate_regression_report()

	var html_content = """
	<!DOCTYPE html>
	<html>
	<head>
		<title>Visual Regression Test Report</title>
		<style>
			body { font-family: Arial, sans-serif; margin: 20px; }
			.header { background: #f0f0f0; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
			.summary { display: flex; gap: 20px; margin-bottom: 20px; }
			.metric { background: white; padding: 15px; border: 1px solid #ddd; border-radius: 5px; flex: 1; }
			.comparison { margin-bottom: 20px; border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
			.success { color: green; }
			.failure { color: red; }
			.image-container { display: flex; gap: 10px; margin-top: 10px; }
			.image-container img { max-width: 200px; border: 1px solid #ddd; }
		</style>
	</head>
	<body>
		<div class="header">
			<h1>Visual Regression Test Report</h1>
			<p>Session ID: %s</p>
			<p>Generated: %s</p>
		</div>

		<div class="summary">
			<div class="metric">
				<h3>Total Comparisons</h3>
				<p style="font-size: 24px;">%d</p>
			</div>
			<div class="metric">
				<h3>Success Rate</h3>
				<p style="font-size: 24px; color: %s;">%.1f%%</p>
			</div>
			<div class="metric">
				<h3>Duration</h3>
				<p style="font-size: 24px;">%.2fs</p>
			</div>
		</div>

		<h2>Comparison Results</h2>
	""" % [
		report.session_id,
		Time.get_datetime_string_from_unix_time(int(Time.get_unix_time_from_system())),
		int(report.total_comparisons),
		"green" if report.success_rate >= 95.0 else "red",
		report.success_rate,
		report.duration
	]

	# Add comparison details
	for comparison in report.comparison_results:
		var status_class = "success" if comparison.result.success else "failure"
		var status_text = "PASS" if comparison.result.success else "FAIL"

		html_content += """
		<div class="comparison">
			<h3>%s</h3>
			<p><strong>Status:</strong> <span class="%s">%s</span></p>
			<p><strong>Algorithm:</strong> %s</p>
			<p><strong>Timestamp:</strong> %s</p>
		""" % [
			comparison.screenshot_name,
			status_class,
			status_text,
			comparison.algorithm,
			Time.get_datetime_string_from_unix_time(comparison.timestamp)
		]

		if comparison.result.has("similarity"):
			html_content += """<p><strong>Similarity:</strong> %.2f%%</p>""" % (comparison.result.similarity * 100)

		html_content += """</div>"""

	html_content += """
		</body>
		</html>
	"""

	var global_path = ProjectSettings.globalize_path(output_path)
	var file = FileAccess.open(global_path, FileAccess.WRITE)

	if not file:
		push_error("Failed to create HTML report: " + output_path)
		return false

	file.store_string(html_content)
	file.close()

	print("📊 HTML report generated: " + output_path)
	return true

# ------------------------------------------------------------------------------
# VISUAL PERFORMANCE TESTING
# ------------------------------------------------------------------------------
func assert_rendering_performance(max_frame_time: float = 16.67, message: String = "") -> bool:
	"""Assert that rendering performance is within acceptable limits"""
	# Wait for a few frames to stabilize
	await wait_for_render_frames(5)

	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var frame_time_ms = frame_time * 1000

	if frame_time_ms > max_frame_time:
		var error_msg = message if not message.is_empty() else "Frame time %.2fms exceeds limit %.2fms" % [frame_time_ms, max_frame_time]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_draw_calls_less_than(max_calls: int, message: String = "") -> bool:
	"""Assert that draw calls are within acceptable limits"""
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	if draw_calls > max_calls:
		var error_msg = message if not message.is_empty() else "Draw calls %d exceeds limit %d" % [draw_calls, max_calls]
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

# ------------------------------------------------------------------------------
# VISUAL DEBUGGING UTILITIES
# ------------------------------------------------------------------------------
func highlight_region(region: Rect2, color: Color = Color.RED, duration: float = 1.0) -> void:
	"""Highlight a region on screen for debugging"""
	var highlight = ColorRect.new()
	highlight.color = color
	highlight.rect_size = region.size
	highlight.position = region.position
	add_child(highlight)

	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(highlight):
		highlight.queue_free()

func mark_position(marker_position: Vector2, color: Color = Color.YELLOW, size: float = 10.0, duration: float = 1.0) -> void:
	"""Mark a position on screen for debugging"""
	var marker = ColorRect.new()
	marker.color = color
	marker.rect_size = Vector2(size, size)
	marker.position = marker_position - Vector2(size/2, size/2)
	add_child(marker)

	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(marker):
		marker.queue_free()

# ------------------------------------------------------------------------------
# CONFIGURATION UTILITIES
# ------------------------------------------------------------------------------
func set_visual_tolerance(tolerance: float) -> void:
	"""Set the visual comparison tolerance"""
	visual_tolerance = clamp(tolerance, 0.0, 1.0)

func set_screenshot_directory(directory: String) -> void:
	"""Set the directory for saving screenshots"""
	screenshot_dir = directory
	create_visual_directories()

func enable_diff_images(enabled: bool = true) -> void:
	"""Enable or disable diff image generation"""
	generate_diff_images = enabled

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup visual regression test resources"""
	# Generate final report if there were comparisons
	if not comparison_results.is_empty():
		var final_report = generate_regression_report()
		var report_file = reports_dir.path_join("session_" + test_session_id + "_final_report.json")
		export_regression_report(report_file)

		print("🎯 Visual Regression Test Session Complete")
		print("   Session ID: %s" % test_session_id)
		print("   Duration: %.2fs" % final_report.duration)
		print("   Comparisons: %d" % final_report.total_comparisons)
		print("   Success Rate: %.1f%%" % final_report.success_rate)
		print("   Report: %s" % report_file)

	# Clean up resources
	comparison_results.clear()
	baseline_versions.clear()
	pending_approvals.clear()
	current_baseline_images.clear()

	super._exit_tree()
