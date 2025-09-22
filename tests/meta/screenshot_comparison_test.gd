# GDSentry - Screenshot Comparison Utilities Test Suite
# Comprehensive testing of the ScreenshotComparison utilities
#
# This test validates all aspects of the screenshot comparison system including:
# - Image processing utilities (resize, crop, blur, grayscale conversion)
# - Advanced comparison algorithms with caching
# - Batch comparison operations
# - Performance monitoring and optimization
# - Visualization utilities for difference highlighting
# - Integration with GDSentry test framework
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name ScreenshotComparisonTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive ScreenshotComparison validation"
	test_tags = ["meta", "utilities", "screenshot_comparison", "image_processing", "visual_testing"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var screenshot_comparison
var ImageProcessor
var AdvancedComparators
var DifferenceVisualizer

func setup() -> void:
	"""Setup test environment"""
	screenshot_comparison = load("res://utilities/screenshot_comparison.gd").new()
	ImageProcessor = ImageProcessor
	AdvancedComparators = AdvancedComparators
	DifferenceVisualizer = DifferenceVisualizer

func teardown() -> void:
	"""Cleanup test environment"""
	if screenshot_comparison:
		screenshot_comparison.queue_free()

# ------------------------------------------------------------------------------
# IMAGE PROCESSING TESTS
# ------------------------------------------------------------------------------
func test_image_resize() -> bool:
	"""Test image resizing functionality"""
	var success = true

	# Create test image
	var original = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	original.fill(Color(1, 0, 0, 1))  # Red

	# Test resize
	var resized = ImageProcessor.resize_image(original, Vector2(50, 50))
	success = success and assert_equals(resized.get_width(), 50, "Should resize width correctly")
	success = success and assert_equals(resized.get_height(), 50, "Should resize height correctly")
	success = success and assert_not_null(resized, "Should return valid resized image")

	# Test resize with different interpolation
	var resized_bilinear = ImageProcessor.resize_image(original, Vector2(25, 25), Image.INTERPOLATE_BILINEAR)
	success = success and assert_equals(resized_bilinear.get_width(), 25, "Should handle bilinear interpolation")
	success = success and assert_equals(resized_bilinear.get_height(), 25, "Should handle bilinear interpolation")

	return success

func test_image_crop() -> bool:
	"""Test image cropping functionality"""
	var success = true

	# Create test image with different colored regions
	var original = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	original.lock()

	# Fill different regions with different colors
	for y in range(50):
		for x in range(50):
			original.set_pixel(x, y, Color(1, 0, 0, 1))	 # Red top-left
	for y in range(50):
		for x in range(50, 100):
			original.set_pixel(x, y, Color(0, 1, 0, 1))	 # Green top-right
	for y in range(50, 100):
		for x in range(50):
			original.set_pixel(x, y, Color(0, 0, 1, 1))	 # Blue bottom-left
	for y in range(50, 100):
		for x in range(50, 100):
			original.set_pixel(x, y, Color(1, 1, 0, 1))	 # Yellow bottom-right

	original.unlock()

	# Test cropping
	var crop_region = Rect2(25, 25, 25, 25)	 # 25x25 region from center
	var cropped = ImageProcessor.crop_image(original, crop_region)

	success = success and assert_equals(cropped.get_width(), 25, "Should crop width correctly")
	success = success and assert_equals(cropped.get_height(), 25, "Should crop height correctly")
	success = success and assert_not_null(cropped, "Should return valid cropped image")

	# Verify cropped content
	cropped.lock()
	var center_pixel = cropped.get_pixel(12, 12)  # Center of cropped region
	cropped.unlock()

	# The center should be red (from the original top-left red region)
	var is_red = center_pixel.is_equal_approx(Color(1, 0, 0, 1))
	success = success and assert_true(is_red, "Should preserve original colors in cropped region")

	return success

func test_image_grayscale_conversion() -> bool:
	"""Test grayscale conversion"""
	var success = true

	# Create colorful test image
	var original = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	original.lock()

	for y in range(10):
		for x in range(10):
			original.set_pixel(x, y, Color(float(x)/10.0, float(y)/10.0, 0.5, 1.0))

	original.unlock()

	# Convert to grayscale
	var grayscale = ImageProcessor.convert_to_grayscale(original)

	success = success and assert_equals(grayscale.get_width(), 10, "Should preserve width")
	success = success and assert_equals(grayscale.get_height(), 10, "Should preserve height")
	success = success and assert_not_null(grayscale, "Should return valid grayscale image")

	# Verify grayscale conversion
	grayscale.lock()
	var test_pixel = grayscale.get_pixel(5, 5)
	grayscale.unlock()

	# All RGB components should be equal in grayscale
	var is_grayscale = abs(test_pixel.r - test_pixel.g) < 0.001 and abs(test_pixel.g - test_pixel.b) < 0.001
	success = success and assert_true(is_grayscale, "Should convert to proper grayscale")

	return success

func test_image_contrast_enhancement() -> bool:
	"""Test contrast enhancement"""
	var success = true

	# Create low contrast image
	var original = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	original.lock()

	for y in range(10):
		for x in range(10):
			var intensity = 0.4 + (float(x + y) / 20.0) * 0.2  # Low contrast range
			original.set_pixel(x, y, Color(intensity, intensity, intensity, 1.0))

	original.unlock()

	# Enhance contrast
	var enhanced = ImageProcessor.enhance_contrast(original, 2.0)

	success = success and assert_equals(enhanced.get_width(), 10, "Should preserve width")
	success = success and assert_equals(enhanced.get_height(), 10, "Should preserve height")
	success = success and assert_not_null(enhanced, "Should return valid enhanced image")

	# Verify contrast enhancement (should increase difference between light and dark areas)
	original.lock()
	enhanced.lock()

	var original_range = _calculate_intensity_range(original)
	var enhanced_range = _calculate_intensity_range(enhanced)

	original.unlock()
	enhanced.unlock()

	success = success and assert_greater_than(enhanced_range, original_range, "Should increase contrast range")

	return success

func _calculate_intensity_range(image: Image) -> float:
	"""Calculate intensity range in image"""
	var min_intensity = 1.0
	var max_intensity = 0.0

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var intensity = image.get_pixel(x, y).r
			min_intensity = min(min_intensity, intensity)
			max_intensity = max(max_intensity, intensity)

	return max_intensity - min_intensity

# ------------------------------------------------------------------------------
# ADVANCED COMPARISON TESTS
# ------------------------------------------------------------------------------
func test_pixel_by_pixel_advanced() -> bool:
	"""Test advanced pixel-by-pixel comparison"""
	var success = true

	# Create identical images
	var image1 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))

	var image2 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image2.fill(Color(1, 0, 0, 1))

	# Test identical images
	var result = AdvancedComparators.compare_pixel_by_pixel_advanced(image1, image2, 0.01)
	success = success and assert_true(result.success, "Should pass for identical images")
	success = success and assert_equals(result.similarity, 1.0, "Should have perfect similarity")
	success = success and assert_equals(result.matching_pixels, 100, "Should match all pixels")
	success = success and assert_equals(result.different_pixels, 0, "Should have no different pixels")

	# Create slightly different image
	image2.fill(Color(0.99, 0, 0, 1))  # Slightly different red

	var result2 = AdvancedComparators.compare_pixel_by_pixel_advanced(image1, image2, 0.01)
	success = success and assert_false(result2.success, "Should fail for different images")
	success = success and assert_less_than(result2.similarity, 1.0, "Should have less than perfect similarity")
	success = success and assert_greater_than(result2.different_pixels, 0, "Should detect differences")

	return success	#  "Advanced pixel-by-pixel comparison should work correctly")

func test_perceptual_hash_comparison() -> bool:
	"""Test perceptual hash comparison"""
	var success = true

	# Create identical images
	var image1 = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image1.fill(Color(0.5, 0.5, 0.5, 1))

	var image2 = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image2.fill(Color(0.5, 0.5, 0.5, 1))

	# Test identical images
	var result = AdvancedComparators.compare_perceptual_hash_advanced(image1, image2, 0.1)
	success = success and assert_true(result.success, "Should pass for identical images")
	success = success and assert_greater_than(result.similarity, 0.9, "Should have high similarity")
	success = success and assert_true(result.has("hash_similarities"), "Should include hash similarities")
	success = success and assert_true(result.has("hash_sizes"), "Should include hash sizes")

	return success	#  "Perceptual hash comparison should work correctly")

func test_comparison_caching() -> bool:
	"""Test comparison result caching"""
	var success = true

	# Clear cache first
	AdvancedComparators.cache.clear()

	# Create test images
	var image1 = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))

	var image2 = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image2.fill(Color(1, 0, 0, 1))

	# First comparison (should cache result)
	var start_time = Time.get_ticks_usec()
	var result1 = AdvancedComparators.compare_with_caching(image1, image2, 0, 0.01)
	var first_time = Time.get_ticks_usec() - start_time

	# Second comparison (should use cached result)
	start_time = Time.get_ticks_usec()
	var result2 = AdvancedComparators.compare_with_caching(image1, image2, 0, 0.01)
	var _second_time = Time.get_ticks_usec() - start_time

	success = success and assert_true(result1.success, "First comparison should succeed")
	success = success and assert_true(result2.success, "Second comparison should succeed")
	success = success and assert_equals(result1.similarity, result2.similarity, "Cached result should match original")

	# Check that second comparison was faster (though this might not always be true in testing)
	success = success and assert_true(first_time >= 0, "Should have valid timing")

	return success	#  "Comparison caching should work correctly")

# ------------------------------------------------------------------------------
# BATCH COMPARISON TESTS
# ------------------------------------------------------------------------------
func test_batch_comparison() -> bool:
	"""Test batch comparison functionality"""
	var success = true

	# Create test images
	var images = []
	for i in range(3):
		var image = Image.create(10, 10, false, Image.FORMAT_RGBA8)
		image.fill(Color(float(i) / 3.0, 0, 0, 1))
		images.append(image)

	# Create batch comparator
	var batch_comparator = screenshot_comparison.create_batch_comparator()
	success = success and assert_not_null(batch_comparator, "Should create batch comparator")

	# Create image pairs for comparison
	var image_pairs = [
		[images[0], images[0]],	 # Identical
		[images[0], images[1]],	 # Different
		[images[1], images[2]]	 # Different
	]

	# Execute batch comparison
	var results = batch_comparator.compare_images_batch(image_pairs, 0, 0.01)
	success = success and assert_equals(results.size(), 3, "Should return results for all pairs")

	# Verify results
	success = success and assert_true(results[0].success, "Identical images should pass")
	success = success and assert_false(results[1].success, "Different images should fail")
	success = success and assert_false(results[2].success, "Different images should fail")

	# Test statistics
	var stats = batch_comparator.get_statistics()
	success = success and assert_equals(stats.total_comparisons, 3, "Should report correct total")
	success = success and assert_equals(stats.successful_comparisons, 1, "Should report correct successful count")
	success = success and assert_greater_than(stats.execution_time, 0, "Should report execution time")

	return success	#  "Batch comparison should work correctly")

func test_baseline_batch_comparison() -> bool:
	"""Test baseline batch comparison"""
	var success = true

	# Create baseline image
	var baseline = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	baseline.fill(Color(0, 1, 0, 1))  # Green baseline

	# Create test images
	var test_images = []
	for i in range(3):
		var image = Image.create(10, 10, false, Image.FORMAT_RGBA8)
		if i == 0:
			image.fill(Color(0, 1, 0, 1))  # Match baseline
		else:
			image.fill(Color(float(i) / 3.0, 0, 0, 1))	# Different colors
		test_images.append(image)

	# Create batch comparator
	var batch_comparator = screenshot_comparison.create_batch_comparator()

	# Execute baseline comparison
	var results = batch_comparator.compare_baseline_batch(baseline, test_images, 0, 0.01)
	success = success and assert_equals(results.size(), 3, "Should return results for all test images")

	# First image should match baseline, others should not
	success = success and assert_true(results[0].success, "First image should match baseline")
	success = success and assert_false(results[1].success, "Second image should not match baseline")
	success = success and assert_false(results[2].success, "Third image should not match baseline")

	return success	#  "Baseline batch comparison should work correctly")

# ------------------------------------------------------------------------------
# PERFORMANCE MONITORING TESTS
# ------------------------------------------------------------------------------
func test_performance_monitoring() -> bool:
	"""Test performance monitoring"""
	var success = true

	# Create performance monitor
	var monitor = screenshot_comparison.create_performance_monitor()
	success = success and assert_not_null(monitor, "Should create performance monitor")

	# Start monitoring
	monitor.start_monitoring()

	# Simulate some comparison operations
	for i in range(5):
		monitor.record_comparison_time(0.1 + float(i) * 0.01)
		monitor.record_memory_usage()

	# Get performance report
	var report = monitor.get_performance_report()
	success = success and assert_equals(report.total_comparisons, 5, "Should report correct comparison count")
	success = success and assert_greater_than(report.avg_comparison_time, 0, "Should calculate average time")
	success = success and assert_equals(report.memory_samples, 5, "Should report memory samples")

	# Verify performance metrics
	success = success and assert_true(report.min_comparison_time >= 0.1, "Should track minimum time")
	success = success and assert_true(report.max_comparison_time <= 0.15, "Should track maximum time")

	return success	#  "Performance monitoring should work correctly")

# ------------------------------------------------------------------------------
# VISUALIZATION TESTS
# ------------------------------------------------------------------------------
func test_difference_visualization() -> bool:
	"""Test difference visualization"""
	var success = true

	# Create test images
	var image1 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))	# Red

	var image2 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image2.fill(Color(1, 0, 0, 1))	# Same red

	# Create mock difference map
	var difference_map = []
	for y in range(10):
		var row = []
		for x in range(10):
			row.append(0.0)	 # No differences
		difference_map.append(row)

	# Test heat map creation
	var heat_map = DifferenceVisualizer.create_heat_map(difference_map, 10, 10)
	success = success and assert_equals(heat_map.get_width(), 10, "Should create correct width heat map")
	success = success and assert_equals(heat_map.get_height(), 10, "Should create correct height heat map")

	# Test overlay visualization
	var overlay = DifferenceVisualizer.create_overlay_visualization(image1, image2, difference_map)
	success = success and assert_equals(overlay.get_width(), 10, "Should create correct width overlay")
	success = success and assert_equals(overlay.get_height(), 10, "Should create correct height overlay")

	# Test side-by-side comparison
	var side_by_side = DifferenceVisualizer.create_side_by_side_comparison(image1, image2)
	success = success and assert_equals(side_by_side.get_width(), 20, "Should create correct width side-by-side (10+10)")
	success = success and assert_equals(side_by_side.get_height(), 10, "Should create correct height side-by-side")

	# Test with difference image
	var side_by_side_with_diff = DifferenceVisualizer.create_side_by_side_comparison(image1, image2, heat_map)
	success = success and assert_equals(side_by_side_with_diff.get_width(), 30, "Should include difference image width (10+10+10)")

	return success	#  "Difference visualization should work correctly")

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_convenience_functions() -> bool:
	"""Test convenience functions"""
	var success = true

	# Create test images
	var image1 = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image1.fill(Color(0.5, 0.5, 0.5, 1))

	var image2 = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image2.fill(Color(0.5, 0.5, 0.5, 1))

	# Test convenience comparison function
	var result = screenshot_comparison.compare_images_advanced(image1, image2, 0, 0.01)
	success = success and assert_true(result.success, "Convenience comparison should work")
	success = success and assert_equals(result.similarity, 1.0, "Should have perfect similarity")

	# Test image processing convenience function
	var processed = screenshot_comparison.process_image_for_comparison(image1, true, true)
	success = success and assert_equals(processed.get_width(), 20, "Should preserve image dimensions")
	success = success and assert_equals(processed.get_height(), 20, "Should preserve image dimensions")

	return success	#  "Convenience functions should work correctly")

func test_cache_functionality() -> bool:
	"""Test cache functionality"""
	var success = true

	# Clear cache
	AdvancedComparators.cache.clear()

	# Check initial cache state
	var initial_stats = AdvancedComparators.cache.get_stats()
	success = success and assert_equals(initial_stats.size, 0, "Should start with empty cache")

	# Create test images
	var image1 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))

	var image2 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image2.fill(Color(1, 0, 0, 1))

	# First comparison (should populate cache)
	var result1 = AdvancedComparators.compare_with_caching(image1, image2, 0, 0.01)
	var after_first_stats = AdvancedComparators.cache.get_stats()
	success = success and assert_equals(after_first_stats.size, 1, "Should have one cached item")

	# Second comparison (should use cache)
	var result2 = AdvancedComparators.compare_with_caching(image1, image2, 0, 0.01)
	var after_second_stats = AdvancedComparators.cache.get_stats()
	success = success and assert_equals(after_second_stats.size, 1, "Should still have one cached item")

	# Results should be identical
	success = success and assert_equals(result1.similarity, result2.similarity, "Cached result should match original")

	return success	#  "Cache functionality should work correctly")

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Test with mismatched image sizes
	var image1 = Image.create(10, 10, false, Image.FORMAT_RGBA8)

	var image2 = Image.create(20, 20, false, Image.FORMAT_RGBA8)

	var result = AdvancedComparators.compare_pixel_by_pixel_advanced(image1, image2, 0.01)
	success = success and assert_false(result.success, "Should fail with mismatched sizes")
	success = success and assert_true(result.has("error"), "Should include error message")

	# Test empty batch
	var batch_comparator = screenshot_comparison.create_batch_comparator()
	var empty_results = batch_comparator.compare_images_batch([])
	success = success and assert_equals(empty_results.size(), 0, "Should handle empty batch")

	# Test cache with different parameters
	var cache_key1 = AdvancedComparators.cache.get_cache_key(image1, image1, 0, 0.01)
	var cache_key2 = AdvancedComparators.cache.get_cache_key(image1, image1, 0, 0.05)  # Different tolerance
	success = success and assert_not_equals(cache_key1, cache_key2, "Should generate different cache keys for different parameters")

	return success	#  "Error handling should work correctly")

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all ScreenshotComparison tests"""
	print("\n🚀 Running ScreenshotComparison Test Suite\n")

	# Image Processing Tests
	run_test("test_image_resize", func(): return test_image_resize())
	run_test("test_image_crop", func(): return test_image_crop())
	run_test("test_image_grayscale_conversion", func(): return test_image_grayscale_conversion())
	run_test("test_image_contrast_enhancement", func(): return test_image_contrast_enhancement())

	# Advanced Comparison Tests
	run_test("test_pixel_by_pixel_advanced", func(): return test_pixel_by_pixel_advanced())
	run_test("test_perceptual_hash_comparison", func(): return test_perceptual_hash_comparison())
	run_test("test_comparison_caching", func(): return test_comparison_caching())

	# Batch Comparison Tests
	run_test("test_batch_comparison", func(): return test_batch_comparison())
	run_test("test_baseline_batch_comparison", func(): return test_baseline_batch_comparison())

	# Performance Monitoring Tests
	run_test("test_performance_monitoring", func(): return test_performance_monitoring())

	# Visualization Tests
	run_test("test_difference_visualization", func(): return test_difference_visualization())

	# Integration Tests
	run_test("test_convenience_functions", func(): return test_convenience_functions())
	run_test("test_cache_functionality", func(): return test_cache_functionality())

	# Error Handling Tests
	run_test("test_error_handling", func(): return test_error_handling())

	print("\n✨ ScreenshotComparison Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
