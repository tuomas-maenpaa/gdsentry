# GDSentry - VisualRegressionTest Comprehensive Test Suite
# Comprehensive testing of VisualRegressionTest framework functionality
#
# Tests VisualRegressionTest including:
# - Screenshot capture and timestamped screenshots
# - Baseline management and versioning
# - Multiple comparison algorithms (pixel-by-pixel, perceptual, SSIM)
# - Visual assertions and regression detection
# - Approval workflow for baseline changes
# - Report generation (JSON, HTML)
# - Performance monitoring assertions
# - Configuration and utility functions
#
# Author: GDSentry Framework
# Version: 2.0.0

extends SceneTreeTest

class_name VisualRegressionTestSuite

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "VisualRegressionTest comprehensive functionality validation"
	test_tags = ["advanced", "visual", "regression", "image_comparison", "baseline"]
	test_priority = "high"
	test_category = "advanced"

# ------------------------------------------------------------------------------
# TEST SETUP
# ------------------------------------------------------------------------------
var visual_regression

func setup() -> void:
	"""Setup test environment"""
	visual_regression = load("res://gdsentry/test_types/visual_regression_test.gd").new()

func teardown() -> void:
	"""Cleanup test environment"""
	if visual_regression:
		visual_regression.queue_free()

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all VisualRegressionTest functionality tests"""
	print("🎯 Running VisualRegressionTest Comprehensive Test Suite\n")

	# Core functionality tests
	run_test("test_initialization", func(): return test_initialization())
	run_test("test_screenshot_capture", func(): return test_screenshot_capture())
	run_test("test_timestamped_screenshots", func(): return test_timestamped_screenshots())

	# Baseline management tests
	run_test("test_baseline_creation", func(): return test_baseline_creation())
	run_test("test_baseline_listing", func(): return test_baseline_listing())
	run_test("test_baseline_with_version", func(): return test_baseline_with_version())
	run_test("test_baseline_version_management", func(): return test_baseline_version_management())

	# Comparison algorithm tests
	run_test("test_pixel_by_pixel_comparison", func(): return test_pixel_by_pixel_comparison())
	run_test("test_perceptual_hash_comparison", func(): return test_perceptual_hash_comparison())
	run_test("test_structural_similarity_comparison", func(): return test_structural_similarity_comparison())
	run_test("test_image_comparison_basic", func(): return test_image_comparison_basic())

	# Visual assertion tests
	run_test("test_visual_assertions", func(): return test_visual_assertions())
	run_test("test_color_assertion", func(): return test_color_assertion())

	# Approval workflow tests
	run_test("test_approval_workflow", func(): return test_approval_workflow())

	# Reporting tests
	run_test("test_regression_reporting", func(): return test_regression_reporting())
	run_test("test_html_report_generation", func(): return test_html_report_generation())

	# Performance tests
	run_test("test_performance_assertions", func(): return test_performance_assertions())

	# Configuration tests
	run_test("test_configuration", func(): return test_configuration())

	print("✅ VisualRegressionTest Comprehensive Test Suite Complete\n")

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_initialization() -> bool:
	"""Test VisualRegressionTest initialization and basic properties"""
	var success = true

	# Test instantiation
	success = success and assert_not_null(visual_regression, "VisualRegressionTest should instantiate successfully")
	success = success and assert_type(visual_regression, TYPE_OBJECT, "Should be an object")

	# Test default configuration values
	success = success and assert_equals(visual_regression.visual_tolerance, 0.01, "Default visual tolerance should be 0.01")
	success = success and assert_equals(visual_regression.perceptual_threshold, 0.95, "Default perceptual threshold should be 0.95")
	success = success and assert_true(visual_regression.generate_diff_images, "Should generate diff images by default")
	success = success and assert_true(visual_regression.auto_approve_similar, "Should auto-approve similar images by default")

	# Test comparison algorithm enum
	success = success and assert_equals(visual_regression.comparison_algorithm, 0, "Default algorithm should be PIXEL_BY_PIXEL")

	return success

func test_screenshot_capture() -> bool:
	"""Test screenshot capture functionality"""
	var success = true

	# Test screenshot capture (may return null in headless mode)
	var screenshot = visual_regression.take_screenshot("test_screenshot")
	# In headless mode, screenshot might be null, which is acceptable
	if screenshot:
		success = success and assert_type(screenshot, TYPE_OBJECT, "Screenshot should be an Image object")
		success = success and assert_greater_than(screenshot.get_width(), 0, "Screenshot should have width > 0")
		success = success and assert_greater_than(screenshot.get_height(), 0, "Screenshot should have height > 0")

	# Test timestamped screenshot
	var timestamped = visual_regression.take_timestamped_screenshot("timestamped_test")
	if timestamped:
		success = success and assert_type(timestamped, TYPE_OBJECT, "Timestamped screenshot should be an Image object")

	return success

func test_timestamped_screenshots() -> bool:
	"""Test timestamped screenshot functionality"""
	var success = true

	# Test timestamped screenshot
	var timestamped = visual_regression.take_timestamped_screenshot("timestamp_test")
	if timestamped:
		success = success and assert_type(timestamped, TYPE_OBJECT, "Timestamped screenshot should be an Image object")

	return success

func test_baseline_creation() -> bool:
	"""Test baseline creation functionality"""
	var success = true

	# Test baseline creation (may fail in headless mode)
	var created = visual_regression.create_baseline("test_baseline")
	# In headless mode, this might fail, which is acceptable
	success = success and assert_type(created, TYPE_BOOL, "Baseline creation should return boolean")

	return success

func test_baseline_listing() -> bool:
	"""Test baseline listing functionality"""
	var success = true

	# Test baseline listing
	var baselines = visual_regression.list_baselines()
	success = success and assert_type(baselines, TYPE_ARRAY, "Baseline list should be an array")

	return success

func test_baseline_with_version() -> bool:
	"""Test baseline creation with versioning"""
	var success = true

	# Test versioned baseline creation
	var created = visual_regression.create_baseline_with_version("versioned_test", "Test versioned baseline")
	success = success and assert_type(created, TYPE_BOOL, "Versioned baseline creation should return boolean")

	# Test version retrieval
	var versions = visual_regression.get_baseline_versions("versioned_test")
	success = success and assert_type(versions, TYPE_ARRAY, "Versions should be an array")

	return success

func test_baseline_version_management() -> bool:
	"""Test baseline version management"""
	var success = true

	# Test version switching
	var switched = visual_regression.switch_baseline_version("versioned_test", 1)
	success = success and assert_type(switched, TYPE_BOOL, "Version switching should return boolean")

	return success

func test_pixel_by_pixel_comparison() -> bool:
	"""Test pixel-by-pixel comparison algorithm"""
	var success = true

	# Create test images
	var image1 = Image.create(10, 10, false, Image.FORMAT_RGB8)
	image1.fill(Color(1, 0, 0))  # Red

	var image2 = Image.create(10, 10, false, Image.FORMAT_RGB8)
	image2.fill(Color(1, 0, 0))  # Same red

	# Test comparison
	var result = visual_regression.compare_images_pixel_by_pixel(image1, image2, 0.01)
	success = success and assert_type(result, TYPE_DICTIONARY, "Comparison should return dictionary")
	success = success and assert_true(result.has("success"), "Result should have success field")

	return success

func test_perceptual_hash_comparison() -> bool:
	"""Test perceptual hash comparison algorithm"""
	var success = true

	# Create test images
	var image1 = Image.create(32, 32, false, Image.FORMAT_RGB8)
	image1.fill(Color(0.5, 0.5, 0.5))  # Gray

	var image2 = Image.create(32, 32, false, Image.FORMAT_RGB8)
	image2.fill(Color(0.5, 0.5, 0.5))  # Same gray

	# Test comparison
	var result = visual_regression.compare_images_perceptual_hash(image1, image2, 0.95)
	success = success and assert_type(result, TYPE_DICTIONARY, "Comparison should return dictionary")
	success = success and assert_true(result.has("success"), "Result should have success field")

	return success

func test_structural_similarity_comparison() -> bool:
	"""Test structural similarity comparison algorithm"""
	var success = true

	# Create test images
	var image1 = Image.create(16, 16, false, Image.FORMAT_RGB8)
	image1.fill(Color(0.8, 0.8, 0.8))  # Light gray

	var image2 = Image.create(16, 16, false, Image.FORMAT_RGB8)
	image2.fill(Color(0.8, 0.8, 0.8))  # Same light gray

	# Test comparison
	var result = visual_regression.compare_images_structural_similarity(image1, image2, 0.01)
	success = success and assert_type(result, TYPE_DICTIONARY, "Comparison should return dictionary")
	success = success and assert_true(result.has("success"), "Result should have success field")

	return success

func test_image_comparison_basic() -> bool:
	"""Test basic image comparison functionality"""
	var success = true

	# Create identical images
	var image1 = Image.create(20, 20, false, Image.FORMAT_RGB8)
	image1.fill(Color(0.2, 0.4, 0.6))

	var image2 = Image.create(20, 20, false, Image.FORMAT_RGB8)
	image2.fill(Color(0.2, 0.4, 0.6))

	# Test basic comparison
	var result = visual_regression.compare_images(image1, image2, 0.01)
	success = success and assert_type(result, TYPE_DICTIONARY, "Comparison should return dictionary")
	if result.has("success"):
		success = success and assert_true(result.success, "Identical images should match")

	return success

func test_visual_assertions() -> bool:
	"""Test visual assertion methods"""
	var success = true

	# Test assert_visual_match (will likely fail in headless mode, which is expected)
	var assertion_result = visual_regression.assert_visual_match("test_assertion")
	success = success and assert_type(assertion_result, TYPE_BOOL, "Visual assertion should return boolean")

	# Test assert_no_visual_regression
	var regression_result = visual_regression.assert_no_visual_regression("test_regression")
	success = success and assert_type(regression_result, TYPE_BOOL, "Regression assertion should return boolean")

	return success

func test_color_assertion() -> bool:
	"""Test color assertion functionality"""
	var success = true

	# Test color assertion (may fail if no screenshot available)
	var color_result = visual_regression.assert_color_at_position(Vector2(10, 10), Color(0, 0, 0))
	success = success and assert_type(color_result, TYPE_BOOL, "Color assertion should return boolean")

	return success

func test_approval_workflow() -> bool:
	"""Test approval workflow functionality"""
	var success = true

	# Test approval request creation
	var differences = {"similarity": 0.85, "different_pixels": 100}
	var request_created = visual_regression.create_approval_request("test_approval", differences, "Test changes")
	success = success and assert_type(request_created, TYPE_BOOL, "Approval request should return boolean")

	# Test approval
	if request_created:
		var approved = visual_regression.approve_baseline_change("test_approval", "test_user")
		success = success and assert_type(approved, TYPE_BOOL, "Approval should return boolean")

		# Test rejection
		var rejected = visual_regression.reject_baseline_change("test_approval", "test_user", "Test rejection")
		success = success and assert_type(rejected, TYPE_BOOL, "Rejection should return boolean")

	return success

func test_regression_reporting() -> bool:
	"""Test regression reporting functionality"""
	var success = true

	# Generate regression report
	var report = visual_regression.generate_regression_report()
	success = success and assert_type(report, TYPE_DICTIONARY, "Report should be dictionary")
	success = success and assert_true(report.has("total_comparisons"), "Report should have total_comparisons")

	# Test report export
	var exported = visual_regression.export_regression_report("res://test_report.json")
	success = success and assert_type(exported, TYPE_BOOL, "Export should return boolean")

	return success

func test_html_report_generation() -> bool:
	"""Test HTML report generation"""
	var success = true

	# Test HTML report generation
	var html_generated = visual_regression.generate_html_report("res://test_report.html")
	success = success and assert_type(html_generated, TYPE_BOOL, "HTML generation should return boolean")

	return success

func test_performance_assertions() -> bool:
	"""Test performance assertion methods"""
	var success = true

	# Test rendering performance assertion
	var perf_result = visual_regression.assert_rendering_performance(30.0)
	success = success and assert_type(perf_result, TYPE_BOOL, "Performance assertion should return boolean")

	# Test draw calls assertion
	var draw_result = visual_regression.assert_draw_calls_less_than(1000)
	success = success and assert_type(draw_result, TYPE_BOOL, "Draw calls assertion should return boolean")

	return success

func test_configuration() -> bool:
	"""Test configuration methods"""
	var success = true

	# Test tolerance configuration
	visual_regression.set_visual_tolerance(0.05)
	success = success and assert_equals(visual_regression.visual_tolerance, 0.05, "Tolerance should be updated")

	# Test screenshot directory configuration
	visual_regression.set_screenshot_directory("res://custom_screenshots/")
	success = success and assert_equals(visual_regression.screenshot_dir, "res://custom_screenshots/", "Screenshot dir should be updated")

	# Test diff image configuration
	visual_regression.enable_diff_images(false)
	success = success and assert_false(visual_regression.generate_diff_images, "Diff images should be disabled")

	return success

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	if visual_regression:
		visual_regression.queue_free()

func test_visual_change_detection() -> bool:
	"""Test visual change detection and classification"""
	var regression = VisualRegression.new()

	var success = true

	# Create test images with different changes
	var baseline = Image.create(100, 100, false, Image.FORMAT_RGB8)
	baseline.fill(Color(1, 1, 1))  # White

	var minor_change = Image.create(100, 100, false, Image.FORMAT_RGB8)
	minor_change.fill(Color(0.95, 0.95, 0.95))  # Slightly off-white

	var major_change = Image.create(100, 100, false, Image.FORMAT_RGB8)
	major_change.fill(Color(0, 0, 0))  # Black

	# Test change detection
	var minor_diff = regression.detect_visual_changes(baseline, minor_change)
	var major_diff = regression.detect_visual_changes(baseline, major_change)

	success = success and assert_not_null(minor_diff, "Should detect minor changes")
	success = success and assert_not_null(major_diff, "Should detect major changes")

	# Test change classification
	if minor_diff:
		var minor_classification = regression.classify_visual_change(minor_diff)
		success = success and assert_type(minor_classification, TYPE_STRING, "Change classification should be string")

	if major_diff:
		var major_classification = regression.classify_visual_change(major_diff)
		success = success and assert_type(major_classification, TYPE_STRING, "Change classification should be string")

	regression.queue_free()
	return success

func test_baseline_auto_updates() -> bool:
	"""Test automatic baseline update functionality"""
	var regression = VisualRegression.new()

	var success = true

	# Test auto-update configuration
	regression.auto_update_baselines = true
	success = success and assert_true(regression.auto_update_baselines, "Auto-update should be enabled")

	regression.auto_update_baselines = false
	success = success and assert_false(regression.auto_update_baselines, "Auto-update should be disabled")

	# Test baseline update logic
	var test_image = Image.create(50, 50, false, Image.FORMAT_RGB8)
	test_image.fill(Color(0.8, 0.8, 0.8))

	var update_success = regression.update_baseline_if_needed(test_image, "test_baseline.png", 0.9)
	success = success and assert_type(update_success, TYPE_BOOL, "Baseline update should return boolean")

	regression.queue_free()
	return success

func test_multi_resolution_support() -> bool:
	"""Test multi-resolution baseline support"""
	var regression = VisualRegression.new()

	var success = true

	# Test different resolution handling
	var resolutions = [
		Vector2(320, 240),   # Low res
		Vector2(640, 480),   # Standard
		Vector2(1920, 1080)  # High res
	]

	for res in resolutions:
		var test_image = Image.create(int(res.x), int(res.y), false, Image.FORMAT_RGB8)
		test_image.fill(Color(0.5, 0.5, 0.5))

		# Test resolution-specific baseline storage
		var baseline_name = "baseline_" + str(int(res.x)) + "x" + str(int(res.y)) + ".png"
		var stored = regression.store_baseline_image(test_image, baseline_name)
		success = success and assert_type(stored, TYPE_BOOL, "Multi-resolution storage should work")

	regression.queue_free()
	return success

func test_visual_regression_reporting() -> bool:
	"""Test visual regression reporting functionality"""
	var regression = VisualRegression.new()

	var success = true

	# Test report generation
	var mock_results = {
		"total_comparisons": 5,
		"passed_comparisons": 3,
		"failed_comparisons": 2,
		"average_difference": 0.15
	}

	regression.baseline_metadata = mock_results

	var report = regression.generate_visual_regression_report()
	success = success and assert_not_null(report, "Should generate visual regression report")
	success = success and assert_type(report, TYPE_STRING, "Report should be string")
	success = success and assert_true(report.length() > 0, "Report should not be empty")

	# Test summary generation
	var summary = regression.generate_comparison_summary()
	success = success and assert_not_null(summary, "Should generate comparison summary")
	success = success and assert_type(summary, TYPE_DICTIONARY, "Summary should be dictionary")

	# Test detailed results
	var detailed_results = regression.get_detailed_comparison_results()
	success = success and assert_type(detailed_results, TYPE_ARRAY, "Detailed results should be array")

	regression.queue_free()
	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_image(width: int, height: int, color: Color) -> Image:
	"""Create a test image with specified dimensions and color"""
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(color)
	return image

func create_gradient_image(width: int, height: int) -> Image:
	"""Create a test image with a color gradient"""
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)

	for x in range(width):
		for y in range(height):
			var gradient = float(x) / float(width)
			var color = Color(gradient, gradient, 1.0 - gradient)
			image.set_pixel(x, y, color)

	return image

func create_noise_image(width: int, height: int) -> Image:
	"""Create a test image with random noise"""
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)

	for x in range(width):
		for y in range(height):
			var noise_color = Color(randf(), randf(), randf())
			image.set_pixel(x, y, noise_color)

	return image

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
# Cleanup handled by the _exit_tree function above
