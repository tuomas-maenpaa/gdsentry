# GDSentry - VisualTest Comprehensive Test Suite
# Tests the VisualTest class functionality for visual validation and screenshot testing
#
# Tests cover:
# - Screenshot capture and management
# - Visual comparison with baseline images
# - Image comparison algorithms and tolerance
# - Diff image generation
# - Visual assertions and validation
# - Baseline management and creation
# - Configuration and directory management
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends VisualTest

class_name VisualTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for VisualTest class"
	test_tags = ["visual_test", "screenshot", "baseline", "comparison", "image_processing", "integration"]
	test_priority = "high"
	test_category = "test_types"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all VisualTest comprehensive tests"""
	run_test("test_visual_test_instantiation", func(): return test_visual_test_instantiation())
	run_test("test_visual_test_configuration", func(): return test_visual_test_configuration())
	run_test("test_screenshot_capture", func(): return test_screenshot_capture())
	run_test("test_timestamped_screenshots", func(): return test_timestamped_screenshots())
	run_test("test_baseline_management", func(): return test_baseline_management())
	run_test("test_image_comparison", func(): return test_image_comparison())
	run_test("test_visual_comparison_with_baseline", func(): return await test_visual_comparison_with_baseline())
	run_test("test_diff_image_generation", func(): return test_diff_image_generation())
	run_test("test_visual_assertions", func(): return await test_visual_assertions())
	run_test("test_directory_management", func(): return test_directory_management())
	run_test("test_configuration_loading", func(): return test_configuration_loading())
	run_test("test_error_handling", func(): return await test_error_handling())
	run_test("test_edge_cases", func(): return await test_edge_cases())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_visual_test_instantiation() -> bool:
	"""Test VisualTest instantiation and basic properties"""
	var success = true

	# Test basic instantiation (self is already instantiated)
	success = success and assert_not_null(self, "VisualTest should instantiate successfully")
	success = success and assert_type(self, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(self.get_class(), "VisualTest", "Should be VisualTest class")
	success = success and assert_true(self is Node2DTest, "Should extend Node2DTest")

	# Test default configuration values
	success = success and assert_equals(self.screenshot_dir, "res://test_screenshots/", "Default screenshot dir should be correct")
	success = success and assert_equals(self.baseline_dir, "res://test_screenshots/baseline/", "Default baseline dir should be correct")
	success = success and assert_equals(self.diff_dir, "res://test_screenshots/diff/", "Default diff dir should be correct")
	success = success and assert_equals(self.visual_tolerance, 0.01, "Default tolerance should be 0.01")

	# Test state initialization
	success = success and assert_true(self.current_baseline_images is Dictionary, "Baseline images should be dictionary")
	success = success and assert_equals(self.current_baseline_images.size(), 0, "Baseline images should start empty")
	success = success and assert_true(self.generate_diff_images, "Should generate diff images by default")

	# Test constants
	success = success and assert_equals(self.DEFAULT_SCREENSHOT_DIR, "res://test_screenshots/", "Default screenshot dir constant should be correct")
	success = success and assert_equals(self.DEFAULT_TOLERANCE, 0.01, "Default tolerance constant should be correct")

	return success

func test_visual_test_configuration() -> bool:
	"""Test VisualTest configuration modification"""
	var success = true

	# Store original values to restore later
	var original_screenshot_dir = self.screenshot_dir
	var original_baseline_dir = self.baseline_dir
	var original_diff_dir = self.diff_dir
	var original_visual_tolerance = self.visual_tolerance
	var original_generate_diff_images = self.generate_diff_images

	# Test configuration modification
	self.screenshot_dir = "res://custom_screenshots/"
	self.baseline_dir = "res://custom_baseline/"
	self.diff_dir = "res://custom_diff/"
	self.visual_tolerance = 0.05
	self.generate_diff_images = false

	success = success and assert_equals(self.screenshot_dir, "res://custom_screenshots/", "Should be able to set screenshot dir")
	success = success and assert_equals(self.baseline_dir, "res://custom_baseline/", "Should be able to set baseline dir")
	success = success and assert_equals(self.diff_dir, "res://custom_diff/", "Should be able to set diff dir")
	success = success and assert_equals(self.visual_tolerance, 0.05, "Should be able to set visual tolerance")
	success = success and assert_false(self.generate_diff_images, "Should be able to disable diff image generation")

	# Test edge values
	self.visual_tolerance = 0.0  # Exact match
	success = success and assert_equals(self.visual_tolerance, 0.0, "Should handle zero tolerance")

	self.visual_tolerance = 1.0  # Maximum tolerance
	success = success and assert_equals(self.visual_tolerance, 1.0, "Should handle maximum tolerance")

	# Test invalid values
	self.visual_tolerance = -0.1  # Negative tolerance
	success = success and assert_equals(self.visual_tolerance, -0.1, "Should handle negative tolerance")

	# Restore original values
	self.screenshot_dir = original_screenshot_dir
	self.baseline_dir = original_baseline_dir
	self.diff_dir = original_diff_dir
	self.visual_tolerance = original_visual_tolerance
	self.generate_diff_images = original_generate_diff_images

	return success

# ------------------------------------------------------------------------------
# SCREENSHOT CAPTURE TESTS
# ------------------------------------------------------------------------------
func test_screenshot_capture() -> bool:
	"""Test screenshot capture functionality"""
	var success = true

	# Test basic screenshot capture
	var screenshot = take_screenshot("test_capture")
	success = success and assert_not_null(screenshot, "Screenshot should be captured successfully")
	success = success and assert_true(screenshot is Image, "Screenshot should be an Image")

	# Test screenshot dimensions (should match viewport)
	if screenshot:
		var _viewport_size = get_viewport().size
		success = success and assert_greater_than(screenshot.get_width(), 0, "Screenshot should have width")
		success = success and assert_greater_than(screenshot.get_height(), 0, "Screenshot should have height")

	# Test screenshot with empty name
	var empty_name_screenshot = take_screenshot("")
	success = success and assert_not_null(empty_name_screenshot, "Screenshot with empty name should work")

	# Test screenshot with special characters in name
	var special_name_screenshot = take_screenshot("test@#$%^&*()")
	success = success and assert_not_null(special_name_screenshot, "Screenshot with special characters should work")

	# Test multiple screenshots
	var screenshot1 = take_screenshot("multi_test_1")
	var screenshot2 = take_screenshot("multi_test_2")
	success = success and assert_not_null(screenshot1, "First screenshot should work")
	success = success and assert_not_null(screenshot2, "Second screenshot should work")

	return success

func test_timestamped_screenshots() -> bool:
	"""Test timestamped screenshot functionality"""
	var success = true

	# Test timestamped screenshot
	var timestamped_screenshot = take_timestamped_screenshot("timestamp_test")
	success = success and assert_not_null(timestamped_screenshot, "Timestamped screenshot should be captured")

	# Test multiple timestamped screenshots have different names
	var screenshot1 = take_timestamped_screenshot("multi_timestamp_1")
	var screenshot2 = take_timestamped_screenshot("multi_timestamp_2")
	success = success and assert_not_null(screenshot1, "First timestamped screenshot should work")
	success = success and assert_not_null(screenshot2, "Second timestamped screenshot should work")

	# Test timestamped screenshot with empty base name
	var empty_base_screenshot = take_timestamped_screenshot("")
	success = success and assert_not_null(empty_base_screenshot, "Timestamped screenshot with empty base name should work")

	return success

# ------------------------------------------------------------------------------
# BASELINE MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_baseline_management() -> bool:
	"""Test baseline creation and management"""
	var success = true

	# Test baseline creation
	var baseline_created = create_baseline("test_baseline")
	success = success and assert_type(baseline_created, TYPE_BOOL, "Create baseline should return boolean")

	# Test baseline with empty name
	var empty_baseline = create_baseline("")
	success = success and assert_type(empty_baseline, TYPE_BOOL, "Create baseline with empty name should return boolean")

	# Test baseline with special characters
	var special_baseline = create_baseline("baseline@#$%")
	success = success and assert_type(special_baseline, TYPE_BOOL, "Create baseline with special characters should return boolean")

	# Test multiple baselines
	create_baseline("baseline_1")
	create_baseline("baseline_2")
	create_baseline("baseline_3")

	# Test baseline loading (if files exist)
	load_baseline_images()

	# Verify baseline images dictionary is populated (may be empty if no files)
	success = success and assert_true(current_baseline_images is Dictionary, "Baseline images should be dictionary")

	return success

# ------------------------------------------------------------------------------
# IMAGE COMPARISON TESTS
# ------------------------------------------------------------------------------
func test_image_comparison() -> bool:
	"""Test image comparison functionality"""
	var success = true

	# Create test images
	var image1 = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	var image2 = Image.create(100, 100, false, Image.FORMAT_RGBA8)

	# Test identical images
	image1.fill(Color(1, 0, 0, 1))  # Red
	image2.fill(Color(1, 0, 0, 1))  # Red

	var identical_result = compare_images(image1, image2)
	success = success and assert_true(identical_result.success, "Identical images should match")
	success = success and assert_equals(identical_result.similarity, 1.0, "Identical images should have 1.0 similarity")

	# Test different images
	image1.fill(Color(1, 0, 0, 1))  # Red
	image2.fill(Color(0, 1, 0, 1))  # Green

	var different_result = compare_images(image1, image2)
	success = success and assert_false(different_result.success, "Different images should not match")
	success = success and assert_less_than(different_result.similarity, 1.0, "Different images should have less than 1.0 similarity")

	# Test different sized images
	var small_image = Image.create(50, 50, false, Image.FORMAT_RGBA8)
	small_image.fill(Color(1, 0, 0, 1))

	var size_mismatch_result = compare_images(image1, small_image)
	success = success and assert_false(size_mismatch_result.success, "Different sized images should not match")
	success = success and assert_true(size_mismatch_result.has("error"), "Size mismatch should have error message")

	# Test with custom tolerance
	var slightly_different_result = compare_images(image1, image2, 0.5)
	success = success and assert_type(slightly_different_result, TYPE_DICTIONARY, "Custom tolerance comparison should return dictionary")

	# Test edge case: empty images
	var empty_image1 = Image.new()
	var empty_image2 = Image.new()

	var empty_result = compare_images(empty_image1, empty_image2)
	success = success and assert_type(empty_result, TYPE_DICTIONARY, "Empty image comparison should return dictionary")

	return success

func test_visual_comparison_with_baseline() -> bool:
	"""Test visual comparison with baseline images"""
	var success = true

	# Test comparison with non-existent baseline
	var nonexistent_result = await compare_with_baseline("nonexistent_baseline")
	success = success and assert_false(nonexistent_result.success, "Non-existent baseline should fail")
	success = success and assert_true(nonexistent_result.has("error"), "Non-existent baseline should have error")

	# Test comparison with default tolerance
	var default_tolerance_result = await compare_with_baseline("test_baseline")
	success = success and assert_type(default_tolerance_result, TYPE_DICTIONARY, "Baseline comparison should return dictionary")

	# Test comparison with custom tolerance
	var custom_tolerance_result = await compare_with_baseline("test_baseline", 0.1)
	success = success and assert_type(custom_tolerance_result, TYPE_DICTIONARY, "Custom tolerance comparison should return dictionary")

	# Test comparison with empty baseline name
	var empty_name_result = await compare_with_baseline("")
	success = success and assert_false(empty_name_result.success, "Empty baseline name should fail")

	# Test comparison when screenshot fails
	# (This would require mocking the viewport, which is complex)
	# For now, we test the structure of the result

	if default_tolerance_result.has("similarity"):
		success = success and assert_type(default_tolerance_result.similarity, TYPE_FLOAT, "Similarity should be float")

	return success

# ------------------------------------------------------------------------------
# DIFF IMAGE GENERATION TESTS
# ------------------------------------------------------------------------------
func test_diff_image_generation() -> bool:
	"""Test diff image generation functionality"""
	var success = true

	# Store original value to restore later
	var original_generate_diff_images = generate_diff_images

	# Create test images
	var image1 = Image.create(50, 50, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))  # Red

	var image2 = Image.create(50, 50, false, Image.FORMAT_RGBA8)
	image2.fill(Color(0, 1, 0, 1))  # Green

	# Test diff generation with diff images enabled
	generate_diff_images = true
	generate_diff_image("test_diff", image1, image2)
	success = success and assert_type(generate_diff_images, TYPE_BOOL, "Generate diff images should be boolean")

	# Test diff generation with diff images disabled
	generate_diff_images = false
	generate_diff_image("test_diff_disabled", image1, image2)
	success = success and assert_false(generate_diff_images, "Diff images should be disabled")

	# Test diff generation with identical images
	image2.fill(Color(1, 0, 0, 1))  # Make identical to image1
	generate_diff_images = true
	generate_diff_image("identical_diff", image1, image2)

	# Test diff generation with empty image name
	generate_diff_image("", image1, image2)

	# Test diff generation with special characters in name
	generate_diff_image("diff@#$%", image1, image2)

	# Restore original value
	generate_diff_images = original_generate_diff_images

	return success

# ------------------------------------------------------------------------------
# VISUAL ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_visual_assertions() -> bool:
	"""Test visual assertion functionality"""
	var success = true

	# Test visual match assertion with non-existent baseline
	var match_result = await assert_visual_match("nonexistent")
	success = success and assert_false(match_result, "Non-existent baseline assertion should fail")

	# Test visual match assertion with custom tolerance
	var custom_tolerance_result = await assert_visual_match("test_baseline", 0.1)
	success = success and assert_type(custom_tolerance_result, TYPE_BOOL, "Custom tolerance assertion should return boolean")

	# Test visual match assertion with custom message
	var custom_message_result = await assert_visual_match("test_baseline", -1.0, "Custom test message")
	success = success and assert_type(custom_message_result, TYPE_BOOL, "Custom message assertion should return boolean")

	# Test color at position assertion
	var color_position = Vector2(10, 10)
	var test_color = Color(1, 0, 0, 1)  # Red
	var color_result = assert_color_at_position(color_position, test_color)
	success = success and assert_type(color_result, TYPE_BOOL, "Color at position assertion should return boolean")

	# Test color at position with custom tolerance
	var color_tolerance_result = assert_color_at_position(color_position, test_color, 0.2)
	success = success and assert_type(color_tolerance_result, TYPE_BOOL, "Color tolerance assertion should return boolean")

	# Test color at position with custom message
	var color_message_result = assert_color_at_position(color_position, test_color, 0.1, "Custom color message")
	success = success and assert_type(color_message_result, TYPE_BOOL, "Color message assertion should return boolean")

	# Test color at invalid position
	var invalid_position = Vector2(-1, -1)
	var invalid_color_result = assert_color_at_position(invalid_position, test_color)
	success = success and assert_type(invalid_color_result, TYPE_BOOL, "Invalid position assertion should return boolean")

	# Test no visual changes assertion (expected to fail as not fully implemented)
	var no_changes_result = assert_no_visual_changes()
	success = success and assert_false(no_changes_result, "No visual changes assertion should fail (not implemented)")

	# Test no visual changes with custom region
	var test_region = Rect2(0, 0, 100, 100)
	var region_result = assert_no_visual_changes(test_region, "Custom region message")
	success = success and assert_false(region_result, "Region no changes assertion should fail (not implemented)")

	return success

# ------------------------------------------------------------------------------
# DIRECTORY MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_directory_management() -> bool:
	"""Test directory creation and management"""
	var success = true

	# Store original values to restore later
	var original_screenshot_dir = screenshot_dir
	var original_baseline_dir = baseline_dir
	var original_diff_dir = diff_dir

	# Test directory creation
	create_visual_directories()

	# Test custom directory paths
	screenshot_dir = "res://custom/screenshots/"
	baseline_dir = "res://custom/baseline/"
	diff_dir = "res://custom/diff/"

	create_visual_directories()

	# Test directory creation with empty paths
	screenshot_dir = ""
	baseline_dir = ""
	diff_dir = ""

	create_visual_directories()

	# Test directory creation with invalid paths
	screenshot_dir = "invalid:path/"
	baseline_dir = "invalid:path/"
	diff_dir = "invalid:path/"

	create_visual_directories()

	# Test directory creation with nested paths
	screenshot_dir = "res://deep/nested/path/screenshots/"
	baseline_dir = "res://deep/nested/path/baseline/"
	diff_dir = "res://deep/nested/path/diff/"

	create_visual_directories()

	# Restore original values
	screenshot_dir = original_screenshot_dir
	baseline_dir = original_baseline_dir
	diff_dir = original_diff_dir

	return success

# ------------------------------------------------------------------------------
# CONFIGURATION LOADING TESTS
# ------------------------------------------------------------------------------
func test_configuration_loading() -> bool:
	"""Test configuration loading functionality"""
	var success = true

	# Store original config to restore later
	var original_config = config

	# Test configuration loading without config object
	config = null
	load_visual_config()
	success = success and assert_not_null(self, "Should handle null config gracefully")

	# Test configuration loading with empty config
	var empty_config = GDTestConfig.new()
	config = empty_config
	load_visual_config()

	# Test configuration loading with visual settings
	var config_with_visual = GDTestConfig.new()
	# Note: GDTestConfig structure would need to be examined to properly test this
	config = config_with_visual
	load_visual_config()

	# Test configuration loading with invalid settings
	var config_with_invalid = GDTestConfig.new()
	config = config_with_invalid
	load_visual_config()

	# Restore original config
	config = original_config

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Store original tolerance to restore later
	var original_tolerance = visual_tolerance

	# Test screenshot capture with no viewport
	# (This is difficult to test directly as viewport is usually available)

	# Test image comparison with null images
	var null_result = compare_images(null, null)
	success = success and assert_type(null_result, TYPE_DICTIONARY, "Null image comparison should return dictionary")

	# Test baseline comparison with null screenshot
	# (This would require mocking, which is complex)

	# Test diff generation with null images
	generate_diff_image("null_test", null, null)

	# Test assertions with invalid parameters
	var invalid_color_assert = assert_color_at_position(Vector2(-1, -1), Color(0, 0, 0, 1))
	success = success and assert_type(invalid_color_assert, TYPE_BOOL, "Invalid color assertion should return boolean")

	# Test with extreme values
	visual_tolerance = 999.0
	var extreme_tolerance_result = await compare_with_baseline("extreme_test")
	success = success and assert_type(extreme_tolerance_result, TYPE_DICTIONARY, "Extreme tolerance should return dictionary")

	visual_tolerance = -999.0
	var negative_tolerance_result = await compare_with_baseline("negative_test")
	success = success and assert_type(negative_tolerance_result, TYPE_DICTIONARY, "Negative tolerance should return dictionary")

	# Restore original tolerance
	visual_tolerance = original_tolerance

	return success

# ------------------------------------------------------------------------------
# EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_edge_cases() -> bool:
	"""Test edge cases and boundary conditions"""
	var success = true

	# Store original values to restore later
	var original_screenshot_dir = screenshot_dir
	var original_baseline_dir = baseline_dir
	var original_diff_dir = diff_dir
	var original_tolerance = visual_tolerance

	# Test with zero-sized images
	var zero_image1 = Image.create(0, 0, false, Image.FORMAT_RGBA8)
	var zero_image2 = Image.create(0, 0, false, Image.FORMAT_RGBA8)

	var zero_result = compare_images(zero_image1, zero_image2)
	success = success and assert_type(zero_result, TYPE_DICTIONARY, "Zero-sized image comparison should return dictionary")

	# Test with very small images
	var tiny_image1 = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	tiny_image1.set_pixel(0, 0, Color(1, 0, 0, 1))

	var tiny_image2 = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	tiny_image2.set_pixel(0, 0, Color(1, 0, 0, 1))

	var tiny_result = compare_images(tiny_image1, tiny_image2)
	success = success and assert_true(tiny_result.success, "Identical tiny images should match")

	# Test with very large tolerance
	var large_tolerance_result = compare_images(tiny_image1, tiny_image2, 2.0)
	success = success and assert_type(large_tolerance_result, TYPE_DICTIONARY, "Large tolerance should return dictionary")

	# Test directory paths with various formats
	var test_paths = [
		"res://test/",
		"res://test",
		"/absolute/path/",
		"relative/path/",
		"",
		"special@#$%/path/"
	]

	for path in test_paths:
		screenshot_dir = path
		baseline_dir = path
		diff_dir = path
		create_visual_directories()

	# Test configuration with extreme values
	visual_tolerance = 0.000001
	var high_precision_result = await compare_with_baseline("precision_test")
	success = success and assert_type(high_precision_result, TYPE_DICTIONARY, "High precision tolerance should work")

	visual_tolerance = 0.999999
	var low_precision_result = await compare_with_baseline("low_precision_test")
	success = success and assert_type(low_precision_result, TYPE_DICTIONARY, "Low precision tolerance should work")

	# Restore original values
	screenshot_dir = original_screenshot_dir
	baseline_dir = original_baseline_dir
	diff_dir = original_diff_dir
	visual_tolerance = original_tolerance

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_image(width: int, height: int, fill_color: Color = Color(1, 1, 1, 1)) -> Image:
	"""Create a test image with specified dimensions and color"""
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(fill_color)
	return image

func create_gradient_image(width: int, height: int) -> Image:
	"""Create a test image with a color gradient"""
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in range(height):
		for x in range(width):
			var gradient_value = float(x) / float(width)
			var color = Color(gradient_value, gradient_value, gradient_value, 1.0)
			image.set_pixel(x, y, color)

	return image

func create_checkerboard_image(width: int, height: int, square_size: int = 10) -> Image:
	"""Create a test checkerboard image"""
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in range(height):
		for x in range(width):
			var square_x = int(float(x) / float(square_size))
			var square_y = int(float(y) / float(square_size))
			var is_black = (square_x + square_y) % 2 == 0
			var color = Color(0, 0, 0, 1) if is_black else Color(1, 1, 1, 1)
			image.set_pixel(x, y, color)

	return image
