# GDSentry - Visual Test Class
# Advanced visual testing with regression framework integration
#
# Enhanced Features:
# - Screenshot capture and comparison
# - Visual layout validation
# - Color and appearance testing
# - Rendering performance monitoring
# - Visual regression detection and approval workflow
# - Baseline image management with versioning
# - Advanced comparison algorithms (pixel-by-pixel, perceptual, SSIM)
# - Automated screenshot capture with scene setup
# - Test result correlation and reporting
# - CI/CD pipeline integration
# - Batch processing capabilities
# - Performance monitoring and optimization
#
# Integration with:
# - VisualRegressionTest for advanced regression testing
# - ScreenshotComparison for advanced image processing
# - GDSentry test framework for seamless integration
#
# Author: GDSentry Framework
# Version: 2.0.0

extends Node2DTest

class_name VisualTest

# ------------------------------------------------------------------------------
# VISUAL TESTING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_SCREENSHOT_DIR = "res://test_screenshots/"
const BASELINE_DIR = "res://test_screenshots/baseline/"
const DIFF_DIR = "res://test_screenshots/diff/"
const APPROVAL_DIR = "res://test_screenshots/approval/"
const DEFAULT_TOLERANCE = 0.01

# ------------------------------------------------------------------------------
# INTEGRATION CONSTANTS
# ------------------------------------------------------------------------------
const VISUAL_REGRESSION_TEST_SCRIPT = "res://test_types/visual_regression_test.gd"
const SCREENSHOT_COMPARISON_SCRIPT = "res://utilities/screenshot_comparison.gd"

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var config: GDTestConfig

# ------------------------------------------------------------------------------
# VISUAL TEST STATE
# ------------------------------------------------------------------------------
var screenshot_dir: String = DEFAULT_SCREENSHOT_DIR
var baseline_dir: String = BASELINE_DIR
var diff_dir: String = DIFF_DIR
var approval_dir: String = APPROVAL_DIR
var visual_tolerance: float = DEFAULT_TOLERANCE
var generate_diff_images: bool = true
var current_baseline_images: Dictionary = {}

# ------------------------------------------------------------------------------
# INTEGRATION STATE
# ------------------------------------------------------------------------------
var visual_regression_test: Node = null
var screenshot_comparison: Node = null
var use_advanced_comparison: bool = true
var auto_capture_baselines: bool = false
var ci_mode: bool = false
var correlation_data: Dictionary = {}
var performance_data: Dictionary = {}

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize visual testing environment with advanced integration"""
	super._ready()

	# Initialize test configuration
	config = GDTestConfig.load_from_file()

	# Load visual test configuration
	load_visual_config()

	# Initialize advanced integration components
	initialize_integration()

	# Ensure directories exist
	create_visual_directories()

	# Load baseline images
	load_baseline_images()

	# Setup CI/CD mode if detected
	detect_ci_mode()

# ------------------------------------------------------------------------------
# INTEGRATION INITIALIZATION
# ------------------------------------------------------------------------------
func initialize_integration() -> void:
	"""Initialize integration with advanced visual testing components"""
	# Load VisualRegressionTest for advanced regression testing
	if ResourceLoader.exists(VISUAL_REGRESSION_TEST_SCRIPT):
		var regression_script = load(VISUAL_REGRESSION_TEST_SCRIPT)
		if regression_script:
			visual_regression_test = regression_script.new()
			add_child(visual_regression_test)
			print("🔗 VisualRegressionTest integration loaded")

	# Load ScreenshotComparison for advanced image processing
	if ResourceLoader.exists(SCREENSHOT_COMPARISON_SCRIPT):
		var comparison_script = load(SCREENSHOT_COMPARISON_SCRIPT)
		if comparison_script:
			screenshot_comparison = comparison_script.new()
			add_child(screenshot_comparison)
			print("🔗 ScreenshotComparison integration loaded")

	# Configure integration settings
	if config and config.visual_settings:
		use_advanced_comparison = config.visual_settings.get("use_advanced_comparison", true)
		auto_capture_baselines = config.visual_settings.get("auto_capture_baselines", false)

func detect_ci_mode() -> void:
	"""Detect if running in CI/CD environment"""
	ci_mode = OS.has_environment("CI") or OS.has_environment("CONTINUOUS_INTEGRATION") or OS.has_environment("GITHUB_ACTIONS")

	if ci_mode:
		print("🏗️ CI/CD mode detected - enabling automated baseline capture")
		auto_capture_baselines = true
		# In CI mode, ensure we have deterministic output
		visual_tolerance = config.visual_settings.get("ci_tolerance", 0.02) if config else 0.02

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
func load_visual_config() -> void:
	"""Load visual testing configuration"""
	if config and config.visual_settings:
		screenshot_dir = config.visual_settings.get("screenshot_directory", DEFAULT_SCREENSHOT_DIR)
		baseline_dir = config.visual_settings.get("baseline_directory", BASELINE_DIR)
		visual_tolerance = config.visual_settings.get("visual_tolerance", DEFAULT_TOLERANCE)
		generate_diff_images = config.visual_settings.get("generate_diff_images", true)

func create_visual_directories() -> void:
	"""Create necessary directories for visual testing with approval workflow"""
	var dirs_to_create = [screenshot_dir, baseline_dir, diff_dir, approval_dir]

	# Add versioned baseline directories if using VisualRegressionTest
	if visual_regression_test:
		var versions = ["v1", "v2", "v3"]  # Support multiple baseline versions
		for version in versions:
			dirs_to_create.append(baseline_dir.path_join(version))
			dirs_to_create.append(diff_dir.path_join(version))
			dirs_to_create.append(approval_dir.path_join(version))

	for dir_path in dirs_to_create:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create visual test directory: " + dir_path)

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
# AUTOMATED SCREENSHOT CAPTURE
# ------------------------------------------------------------------------------
func take_automated_screenshot(screenshot_name: String, setup_callback: Callable = Callable(), wait_time: float = 0.1) -> Image:
	"""Take a screenshot with automated scene setup"""
	# Execute setup callback if provided
	if setup_callback.is_valid():
		setup_callback.call()

	# Wait for scene to stabilize
	if wait_time > 0:
		await get_tree().create_timer(wait_time).timeout

	# Ensure viewport is ready
	await wait_for_render_frames(3)

	return take_screenshot(screenshot_name)

func take_multiple_screenshots(screenshot_names: Array, setup_callbacks: Array = [], wait_time: float = 0.1) -> Dictionary:
	"""Take multiple screenshots with different setups"""
	var results = {}

	for i in range(screenshot_names.size()):
		var screenshot_name = screenshot_names[i]
		var setup_callback = setup_callbacks[i] if i < setup_callbacks.size() else Callable()

		var image = await take_automated_screenshot(screenshot_name, setup_callback, wait_time)
		results[screenshot_name] = image

	return results

func capture_scene_state(scene_name: String, include_ui: bool = true, include_background: bool = true) -> Image:
	"""Capture the current scene state with options"""
	# Configure viewport for capture
	var viewport = get_viewport()
	if viewport:
		# Store original settings
		var original_clear_mode = viewport.transparent_bg
		var original_msaa = viewport.msaa_3d

		# Configure for clean capture
		if not include_background:
			viewport.transparent_bg = true

		if not include_ui:
			# Hide UI elements temporarily
			_hide_ui_elements()

		await wait_for_render_frames(2)

		var image = take_screenshot(scene_name)

		# Restore original settings
		viewport.transparent_bg = original_clear_mode
		viewport.msaa_3d = original_msaa

		if not include_ui:
			_show_ui_elements()

		return image

	return null

func _hide_ui_elements() -> void:
	"""Hide UI elements for clean screenshot"""
	var ui_elements = get_tree().get_nodes_in_group("ui")
	for element in ui_elements:
		if element is CanvasItem:
			element.visible = false

func _show_ui_elements() -> void:
	"""Show UI elements after screenshot"""
	var ui_elements = get_tree().get_nodes_in_group("ui")
	for element in ui_elements:
		if element is CanvasItem:
			element.visible = true

# ------------------------------------------------------------------------------
# VISUAL COMPARISON
# ------------------------------------------------------------------------------
func compare_with_baseline(screenshot_name: String, tolerance: float = -1.0, algorithm: int = 0, region: Rect2 = Rect2()) -> Dictionary:
	"""Compare current screenshot with baseline image using advanced algorithms"""
	if tolerance < 0:
		tolerance = visual_tolerance

	var current_image = take_screenshot(screenshot_name)
	if not current_image:
		return {"success": false, "error": "Failed to capture screenshot", "correlation_id": generate_correlation_id()}

	if not current_baseline_images.has(screenshot_name):
		# Try to use VisualRegressionTest if available
		if visual_regression_test and use_advanced_comparison:
			return await compare_with_visual_regression(screenshot_name, current_image, tolerance, algorithm, region)

		return {"success": false, "error": "No baseline image found for: " + screenshot_name, "correlation_id": generate_correlation_id()}

	var baseline_texture = current_baseline_images[screenshot_name]
	var baseline_image = baseline_texture.get_image()

	if not baseline_image:
		return {"success": false, "error": "Failed to load baseline image", "correlation_id": generate_correlation_id()}

	# Use advanced comparison if available and enabled
	var result = Dictionary()
	if use_advanced_comparison and screenshot_comparison:
		result = screenshot_comparison.compare_images_advanced(current_image, baseline_image, algorithm, tolerance, region)
	else:
		result = compare_images(current_image, baseline_image, tolerance)

	# Add correlation data
	result.correlation_id = generate_correlation_id()
	result.test_name = current_test_name
	result.baseline_name = screenshot_name
	result.timestamp = Time.get_unix_time_from_system()

	# Store correlation data for reporting
	correlation_data[screenshot_name] = result

	if not result.success and generate_diff_images:
		if use_advanced_comparison and screenshot_comparison:
			generate_advanced_diff_image(screenshot_name, current_image, baseline_image, result)
		else:
			generate_diff_image(screenshot_name, current_image, baseline_image)

	return result

func compare_with_visual_regression(screenshot_name: String, current_image: Image, tolerance: float, algorithm: int, region: Rect2) -> Dictionary:
	"""Compare using VisualRegressionTest framework"""
	if not visual_regression_test:
		return {"success": false, "error": "VisualRegressionTest not available", "correlation_id": generate_correlation_id()}

	# Use VisualRegressionTest's comparison method
	var result = await visual_regression_test.assert_visual_match(current_image, screenshot_name, tolerance, algorithm, region)

	# Add correlation data
	result.correlation_id = generate_correlation_id()
	result.test_name = current_test_name
	result.baseline_name = screenshot_name
	result.timestamp = Time.get_unix_time_from_system()

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

	return {
		"success": similarity >= (1.0 - tolerance),
		"similarity": similarity,
		"matching_pixels": matching_pixels,
		"total_pixels": total_pixels,
		"tolerance": tolerance
	}

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

func generate_advanced_diff_image(image_name: String, image1: Image, image2: Image, comparison_result: Dictionary) -> void:
	"""Generate advanced diff image using ScreenshotComparison utilities"""
	if not screenshot_comparison:
		generate_diff_image(image_name, image1, image2)
		return

	# Use advanced visualization from ScreenshotComparison
	var heat_map = screenshot_comparison.DifferenceVisualizer.create_heat_map(
		comparison_result.get("difference_map", []), image1.get_width(), image1.get_height()
	)

	var overlay = screenshot_comparison.DifferenceVisualizer.create_overlay_visualization(
		image1, image2, comparison_result.get("difference_map", [])
	)

	# Save advanced diff images
	var heat_map_path = diff_dir.path_join(image_name + "_heatmap.png")
	var overlay_path = diff_dir.path_join(image_name + "_overlay.png")

	# Save heat map
	var heat_map_global = ProjectSettings.globalize_path(heat_map_path)
	var file1 = FileAccess.open(heat_map_global, FileAccess.WRITE)
	if file1:
		heat_map.save_png(heat_map_global)
		file1.close()
		print("🔥 Heat map saved: ", heat_map_path)

	# Save overlay
	var overlay_global = ProjectSettings.globalize_path(overlay_path)
	var file2 = FileAccess.open(overlay_global, FileAccess.WRITE)
	if file2:
		overlay.save_png(overlay_global)
		file2.close()
		print("🔄 Overlay saved: ", overlay_path)

# ------------------------------------------------------------------------------
# UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
func generate_correlation_id() -> String:
	"""Generate a unique correlation ID for test results"""
	var timestamp = str(Time.get_unix_time_from_system()).replace(".", "")
	var random_suffix = str(randi() % 10000)
	return "corr_" + timestamp + "_" + random_suffix

func wait_for_render_frames(frames: int = 1) -> void:
	"""Wait for specified number of render frames"""
	for i in range(frames):
		await get_tree().process_frame

# ------------------------------------------------------------------------------
# VISUAL ASSERTIONS
# ------------------------------------------------------------------------------
func assert_visual_match(baseline_name: String, tolerance: float = -1.0, message: String = "", algorithm: int = 0, region: Rect2 = Rect2()) -> bool:
	"""Assert that current visual state matches baseline with advanced algorithms"""
	var result = await compare_with_baseline(baseline_name, tolerance, algorithm, region)

	if not result.success:
		var algorithm_name = get_algorithm_name(algorithm)
		var similarity_pct = result.get("similarity", 0.0) * 100
		var error_msg = message if not message.is_empty() else "Visual mismatch for baseline '%s' using %s. Similarity: %.2f%%" % [baseline_name, algorithm_name, similarity_pct]

		# Add correlation information
		if result.has("correlation_id"):
			error_msg += " (Correlation ID: %s)" % result.correlation_id

		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_visual_match_region(baseline_name: String, region: Rect2, tolerance: float = -1.0, message: String = "", algorithm: int = 0) -> bool:
	"""Assert that a specific region matches baseline"""
	return await assert_visual_match(baseline_name, tolerance, message, algorithm, region)

func assert_no_visual_regression(baseline_name: String, message: String = "", algorithm: int = 0) -> bool:
	"""Assert no visual regression against baseline using VisualRegressionTest"""
	if not visual_regression_test:
		var error_msg = message if not message.is_empty() else "VisualRegressionTest not available for regression testing"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var result = await visual_regression_test.assert_no_visual_regression(baseline_name, algorithm)

	if not result.success:
		var error_msg = message if not message.is_empty() else "Visual regression detected for baseline '%s'" % baseline_name
		if result.has("correlation_id"):
			error_msg += " (Correlation ID: %s)" % result.correlation_id
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	return true

func assert_visual_match_with_retry(baseline_name: String, tolerance: float = -1.0, max_retries: int = 3, message: String = "") -> bool:
	"""Assert visual match with retry mechanism for flaky tests"""
	for attempt in range(max_retries):
		var result = await compare_with_baseline(baseline_name, tolerance)

		if result.success:
			return true

		if attempt < max_retries - 1:
			print("⚠️ Visual comparison attempt %d failed, retrying..." % (attempt + 1))
			await get_tree().create_timer(0.5).timeout  # Wait before retry

	var error_msg = message if not message.is_empty() else "Visual match failed after %d attempts for baseline '%s'" % [max_retries, baseline_name]
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func get_algorithm_name(algorithm: int) -> String:
	"""Get human-readable name for comparison algorithm"""
	match algorithm:
		0: return "Pixel-by-Pixel"
		1: return "Perceptual Hash"
		2: return "Structural Similarity"
		3: return "Feature-Based"
		_: return "Unknown Algorithm (%d)" % algorithm

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
# BASELINE MANAGEMENT WITH APPROVAL WORKFLOW
# ------------------------------------------------------------------------------
func create_baseline_with_approval(baseline_name: String, auto_approve: bool = false) -> Dictionary:
	"""Create baseline with approval workflow integration"""
	if not visual_regression_test:
		var success = create_baseline(baseline_name)
		return {"success": success, "correlation_id": generate_correlation_id()}

	var image = take_screenshot("baseline_" + baseline_name)
	if not image:
		return {"success": false, "error": "Failed to capture screenshot"}

	var result = visual_regression_test.create_baseline_with_approval(baseline_name, image, auto_approve)
	result.correlation_id = generate_correlation_id()

	return result

func approve_baseline_change(baseline_name: String, version: String = "latest") -> bool:
	"""Approve a baseline change using VisualRegressionTest"""
	if not visual_regression_test:
		push_warning("VisualRegressionTest not available for approval workflow")
		return false

	return visual_regression_test.approve_baseline_change(baseline_name, version)

func reject_baseline_change(baseline_name: String, reason: String = "") -> bool:
	"""Reject a baseline change"""
	if not visual_regression_test:
		push_warning("VisualRegressionTest not available for approval workflow")
		return false

	return visual_regression_test.reject_baseline_change(baseline_name, reason)

func get_baseline_versions(baseline_name: String) -> Array:
	"""Get available versions for a baseline"""
	if not visual_regression_test:
		return ["v1"]  # Default version

	return visual_regression_test.get_baseline_versions(baseline_name)

# ------------------------------------------------------------------------------
# BATCH PROCESSING
# ------------------------------------------------------------------------------
func batch_visual_comparison(baseline_names: Array, tolerance: float = -1.0, algorithm: int = 0) -> Dictionary:
	"""Perform batch visual comparison for multiple baselines"""
	var results = {}
	var success_count = 0
	var total_count = baseline_names.size()

	for baseline_name in baseline_names:
		var result = await compare_with_baseline(baseline_name, tolerance, algorithm)
		results[baseline_name] = result

		if result.success:
			success_count += 1

		# Add to performance data
		performance_data[baseline_name] = {
			"execution_time": Time.get_unix_time_from_system() - result.timestamp,
			"success": result.success,
			"similarity": result.get("similarity", 0.0)
		}

	return {
		"results": results,
		"summary": {
			"total": total_count,
			"successful": success_count,
			"failed": total_count - success_count,
			"success_rate": float(success_count) / float(total_count) * 100.0
		}
	}

func batch_screenshot_capture(screenshot_names: Array, setup_callbacks: Array = []) -> Dictionary:
	"""Capture multiple screenshots with different setups"""
	return await take_multiple_screenshots(screenshot_names, setup_callbacks)

# ------------------------------------------------------------------------------
# CI/CD INTEGRATION
# ------------------------------------------------------------------------------
func generate_ci_report(report_path: String = "") -> String:
	"""Generate CI/CD compatible test report"""
	if report_path.is_empty():
		report_path = "res://test_reports/visual_test_report.json"

	var report = {
		"test_suite": "VisualTest",
		"timestamp": Time.get_datetime_string_from_system(),
		"ci_mode": ci_mode,
		"correlation_data": correlation_data,
		"performance_data": performance_data,
		"summary": {
			"total_comparisons": correlation_data.size(),
			"successful_comparisons": _count_successful_comparisons(),
			"failed_comparisons": _count_failed_comparisons(),
			"average_similarity": _calculate_average_similarity()
		},
		"configuration": {
			"visual_tolerance": visual_tolerance,
			"use_advanced_comparison": use_advanced_comparison,
			"generate_diff_images": generate_diff_images
		}
	}

	# Add integration status
	report.integration_status = {
		"visual_regression_test": visual_regression_test != null,
		"screenshot_comparison": screenshot_comparison != null,
		"auto_capture_baselines": auto_capture_baselines
	}

	# Save report
	var global_path = ProjectSettings.globalize_path(report_path)
	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
		print("📊 CI Report generated: ", report_path)
		return report_path

	push_error("Failed to save CI report to: " + report_path)
	return ""

func _count_successful_comparisons() -> int:
	"""Count successful comparisons from correlation data"""
	var count = 0
	for result in correlation_data.values():
		if result.get("success", false):
			count += 1
	return count

func _count_failed_comparisons() -> int:
	"""Count failed comparisons from correlation data"""
	return correlation_data.size() - _count_successful_comparisons()

func _calculate_average_similarity() -> float:
	"""Calculate average similarity across all comparisons"""
	if correlation_data.is_empty():
		return 0.0

	var total_similarity = 0.0
	var count = 0

	for result in correlation_data.values():
		if result.has("similarity"):
			total_similarity += result.similarity
			count += 1

	return total_similarity / float(count) if count > 0 else 0.0

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
# INTEGRATION STATUS AND DIAGNOSTICS
# ------------------------------------------------------------------------------
func get_integration_status() -> Dictionary:
	"""Get status of all integration components"""
	return {
		"visual_regression_test": {
			"available": visual_regression_test != null,
			"loaded": ResourceLoader.exists(VISUAL_REGRESSION_TEST_SCRIPT)
		},
		"screenshot_comparison": {
			"available": screenshot_comparison != null,
			"loaded": ResourceLoader.exists(SCREENSHOT_COMPARISON_SCRIPT)
		},
		"ci_mode": ci_mode,
		"auto_capture_baselines": auto_capture_baselines,
		"use_advanced_comparison": use_advanced_comparison
	}

func print_integration_status() -> void:
	"""Print integration status for debugging"""
	var status = get_integration_status()
	print("🔗 VisualTest Integration Status:")
	print("  • VisualRegressionTest: ", "✅ Loaded" if status.visual_regression_test.available else "❌ Not Available")
	print("  • ScreenshotComparison: ", "✅ Loaded" if status.screenshot_comparison.available else "❌ Not Available")
	print("  • CI Mode: ", "✅ Enabled" if status.ci_mode else "❌ Disabled")
	print("  • Auto Capture Baselines: ", "✅ Enabled" if status.auto_capture_baselines else "❌ Disabled")
	print("  • Advanced Comparison: ", "✅ Enabled" if status.use_advanced_comparison else "❌ Disabled")

# ------------------------------------------------------------------------------
# CONFIGURATION UTILITIES
# ------------------------------------------------------------------------------
func set_advanced_comparison_enabled(enabled: bool) -> void:
	"""Enable or disable advanced comparison algorithms"""
	use_advanced_comparison = enabled

func set_auto_capture_baselines(enabled: bool) -> void:
	"""Enable or disable automatic baseline capture"""
	auto_capture_baselines = enabled

func set_ci_mode(enabled: bool) -> void:
	"""Manually set CI mode"""
	ci_mode = enabled
	if ci_mode:
		auto_capture_baselines = true
		visual_tolerance = config.visual_settings.get("ci_tolerance", 0.02) if config else 0.02

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup visual test resources and integration components"""
	# Generate final CI report if in CI mode
	if ci_mode and not correlation_data.is_empty():
		generate_ci_report()

	# Clean up integration components
	if visual_regression_test:
		visual_regression_test.queue_free()
	if screenshot_comparison:
		screenshot_comparison.queue_free()

	# Clear correlation and performance data
	correlation_data.clear()
	performance_data.clear()

	# Clean up temporary screenshots if needed
	super._exit_tree()
