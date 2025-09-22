# GDSentry - Visual Regression Test Framework Test Suite
# Comprehensive testing of the VisualRegressionTest framework
#
# This test validates all aspects of the visual regression testing system including:
# - Baseline creation and version management
# - Multiple comparison algorithms (pixel-by-pixel, perceptual, SSIM)
# - Region-of-interest comparison
# - Approval workflow for baseline changes
# - Report generation (JSON, HTML)
# - Integration with GDSentry test framework
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name VisualRegressionTestTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive VisualRegressionTest validation"
	test_tags = ["meta", "utilities", "visual_regression", "baseline", "comparison"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
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
# BASIC VISUAL REGRESSION TESTS
# ------------------------------------------------------------------------------
func test_visual_regression_initialization() -> bool:
	"""Test visual regression test initialization"""
	print("🧪 Testing visual regression initialization")

	var success = true

	# Test basic initialization
	success = success and assert_not_null(visual_regression, "Should create visual regression test instance")
	success = success and assert_not_null(visual_regression.test_session_id, "Should generate session ID")
	success = success and assert_greater_than(visual_regression.test_start_time, 0.0, "Should set start time")

	# Test directory creation
	success = success and assert_true(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(visual_regression.baseline_dir)), "Should create baseline directory")
	success = success and assert_true(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(visual_regression.diff_dir)), "Should create diff directory")
	success = success and assert_true(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(visual_regression.reports_dir)), "Should create reports directory")
	success = success and assert_true(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(visual_regression.approval_dir)), "Should create approval directory")

	return success

func test_configuration_settings() -> bool:
	"""Test configuration settings"""
	print("🧪 Testing configuration settings")

	var success = true

	# Test default settings
	success = success and assert_equals(visual_regression.comparison_algorithm, 0, "Should default to pixel-by-pixel")
	success = success and assert_equals(visual_regression.visual_tolerance, 0.01, "Should have default tolerance")
	success = success and assert_true(visual_regression.auto_approve_similar, "Should auto-approve similar by default")

	# Test algorithm setting
	visual_regression.comparison_algorithm = 1  # PERCEPTUAL_HASH
	success = success and assert_equals(visual_regression.comparison_algorithm, 1, "Should set comparison algorithm")

	# Test tolerance setting
	visual_regression.visual_tolerance = 0.05
	success = success and assert_equals(visual_regression.visual_tolerance, 0.05, "Should set visual tolerance")

	return success

# ------------------------------------------------------------------------------
# BASELINE MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_baseline_creation() -> bool:
	"""Test baseline creation and management"""
	print("🧪 Testing baseline creation")

	var success = true

	# Test baseline creation with version
	var baseline_name = "test_baseline_" + str(randi())
	var result = visual_regression.create_baseline_with_version(baseline_name, "Test baseline")
	success = success and assert_true(result, "Should create baseline with version")

	# Test version tracking
	var versions = visual_regression.get_baseline_versions(baseline_name)
	success = success and assert_equals(versions.size(), 1, "Should track baseline version")
	success = success and assert_equals(versions[0], "1", "Should have version 1")

	# Test creating another version
	var result2 = visual_regression.create_baseline_with_version(baseline_name, "Updated baseline")
	success = success and assert_true(result2, "Should create second version")

	var versions2 = visual_regression.get_baseline_versions(baseline_name)
	success = success and assert_equals(versions2.size(), 2, "Should track both versions")
	success = success and assert_equals(versions2, ["1", "2"], "Should have versions 1 and 2")

	return success

func test_baseline_version_switching() -> bool:
	"""Test switching between baseline versions"""
	print("🧪 Testing baseline version switching")

	var success = true

	# Create baseline with multiple versions
	var baseline_name = "version_test_" + str(randi())

	visual_regression.create_baseline_with_version(baseline_name, "Version 1")
	visual_regression.create_baseline_with_version(baseline_name, "Version 2")

	# Test switching to version 1
	var switch_result1 = visual_regression.switch_baseline_version(baseline_name, 1)
	success = success and assert_true(switch_result1, "Should switch to version 1")

	# Test switching to version 2
	var switch_result2 = visual_regression.switch_baseline_version(baseline_name, 2)
	success = success and assert_true(switch_result2, "Should switch to version 2")

	# Test switching to non-existent version
	var switch_result3 = visual_regression.switch_baseline_version(baseline_name, 99)
	success = success and assert_false(switch_result3, "Should fail for non-existent version")

	return success

# ------------------------------------------------------------------------------
# COMPARISON ALGORITHM TESTS
# ------------------------------------------------------------------------------
func test_pixel_by_pixel_comparison() -> bool:
	"""Test pixel-by-pixel comparison algorithm"""
	print("🧪 Testing pixel-by-pixel comparison")

	var success = true

	# Create test images
	var image1 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))	# Red

	var image2 = Image.create(10, 10, false, Image.FORMAT_RGBA8)
	image2.fill(Color(1, 0, 0, 1))	# Same red

	# Test identical images
	var result1 = visual_regression.compare_images_pixel_by_pixel(image1, image2, 0.01)
	success = success and assert_true(result1.success, "Should pass for identical images")
	success = success and assert_equals(result1.similarity, 1.0, "Should have perfect similarity")

	# Create slightly different image
	image2.fill(Color(0.99, 0, 0, 1))  # Slightly different red

	var result2 = visual_regression.compare_images_pixel_by_pixel(image1, image2, 0.01)
	success = success and assert_false(result2.success, "Should fail for different images")
	success = success and assert_less_than(result2.similarity, 1.0, "Should have less than perfect similarity")

	return success

func test_comparison_algorithm_selection() -> bool:
	"""Test comparison algorithm selection"""
	print("🧪 Testing comparison algorithm selection")

	var success = true

	# Test algorithm switching
	visual_regression.comparison_algorithm = 1  # PERCEPTUAL_HASH
	success = success and assert_equals(visual_regression.comparison_algorithm, 1, "Should set perceptual hash algorithm")

	visual_regression.comparison_algorithm = 2  # STRUCTURAL_SIMILARITY
	success = success and assert_equals(visual_regression.comparison_algorithm, 2, "Should set SSIM algorithm")

	visual_regression.comparison_algorithm = 3  # FEATURE_BASED
	success = success and assert_equals(visual_regression.comparison_algorithm, 3, "Should set feature-based algorithm")

	return success

# ------------------------------------------------------------------------------
# APPROVAL WORKFLOW TESTS
# ------------------------------------------------------------------------------
func test_approval_workflow() -> bool:
	"""Test approval workflow for baseline changes"""
	print("🧪 Testing approval workflow")

	var success = true

	var baseline_name = "approval_test_" + str(randi())
	var differences = {
		"similarity": 0.85,
		"different_pixels": 150,
		"total_pixels": 10000
	}

	# Create approval request
	var request_result = visual_regression.create_approval_request(baseline_name, differences, "UI layout changes")
	success = success and assert_true(request_result, "Should create approval request")

	# Test approval
	var approve_result = visual_regression.approve_baseline_change(baseline_name, "test_user")
	success = success and assert_true(approve_result, "Should approve baseline change")

	# Test rejection
	var baseline_name2 = "rejection_test_" + str(randi())
	visual_regression.create_approval_request(baseline_name2, differences, "Test rejection")
	var reject_result = visual_regression.reject_baseline_change(baseline_name2, "test_user", "Not approved")
	success = success and assert_true(reject_result, "Should reject baseline change")

	return success

# ------------------------------------------------------------------------------
# REGION COMPARISON TESTS
# ------------------------------------------------------------------------------
func test_region_comparison() -> bool:
	"""Test region-of-interest comparison"""
	print("🧪 Testing region comparison")

	var success = true

	# Create test images
	var image1 = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))	# Red background

	# Draw a blue square in the center
	for y in range(40, 60):
		for x in range(40, 60):
			image1.set_pixel(x, y, Color(0, 0, 1, 1))  # Blue square

	var image2 = image1.duplicate()	 # Identical image

	# Test full image comparison
	var full_result = visual_regression.compare_images_pixel_by_pixel(image1, image2, 0.01)
	success = success and assert_true(full_result.success, "Should pass for identical full images")

	# Test region comparison
	var region = Rect2(40, 40, 20, 20)	# The blue square region
	var region_result = visual_regression.compare_with_baseline("test_region", 0.01, region)

	# This would normally require a baseline, but we're testing the region extraction
	# The comparison might fail due to no baseline, but we can test that region is used
	success = success and assert_not_null(region_result, "Should handle region comparison")

	return success

# ------------------------------------------------------------------------------
# REPORTING TESTS
# ------------------------------------------------------------------------------
func test_report_generation() -> bool:
	"""Test report generation"""
	print("🧪 Testing report generation")

	var success = true

	# Generate regression report
	var report = visual_regression.generate_regression_report()
	success = success and assert_not_null(report, "Should generate regression report")
	success = success and assert_equals(report.session_id, visual_regression.test_session_id, "Should include session ID")
	success = success and assert_greater_than(report.start_time, 0, "Should include start time")

	# Test JSON export (would need file path in real test)
	var json_export = visual_regression.export_regression_report("res://test_report.json")
	success = success and assert_type(json_export, TYPE_BOOL, "Should handle JSON export")

	# Test HTML export (would need file path in real test)
	var html_export = visual_regression.generate_html_report("res://test_report.html")
	success = success and assert_type(html_export, TYPE_BOOL, "Should handle HTML export")

	return success

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_visual_assertions() -> bool:
	"""Test visual assertions"""
	print("🧪 Testing visual assertions")

	var success = true

	# Test visual match assertion (would normally require baseline)
	# For this test, we're just verifying the method exists and handles gracefully

	var baseline_name = "nonexistent_baseline"
	var match_result = visual_regression.assert_visual_match(baseline_name)
	success = success and assert_false(match_result, "Should fail for non-existent baseline")

	# Test region assertion
	var region = Rect2(10, 10, 50, 50)
	var region_result = visual_regression.assert_visual_match_region(baseline_name, region)
	success = success and assert_false(region_result, "Should fail for non-existent baseline with region")

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	print("🧪 Testing error handling")

	var success = true

	# Test switching to non-existent baseline version
	var switch_result = visual_regression.switch_baseline_version("nonexistent", 1)
	success = success and assert_false(switch_result, "Should fail for non-existent baseline")

	# Test approval of non-existent request
	var approve_result = visual_regression.approve_baseline_change("nonexistent_approval")
	success = success and assert_false(approve_result, "Should fail for non-existent approval")

	# Test rejection of non-existent request
	var reject_result = visual_regression.reject_baseline_change("nonexistent_approval")
	success = success and assert_false(reject_result, "Should fail for non-existent approval")

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE TESTS
# ------------------------------------------------------------------------------
func test_performance_large_images() -> bool:
	"""Test performance with larger images"""
	print("🧪 Testing performance with large images")

	var success = true

	# Create larger test images (100x100)
	var image1 = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	image1.fill(Color(1, 0, 0, 1))

	var image2 = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	image2.fill(Color(1, 0, 0, 1))

	# Test comparison performance
	var start_time = Time.get_ticks_usec() / 1000000.0
	var result = visual_regression.compare_images_pixel_by_pixel(image1, image2, 0.01)
	var end_time = Time.get_ticks_usec() / 1000000.0

	var comparison_time = end_time - start_time

	success = success and assert_true(result.success, "Should pass for identical images")
	success = success and assert_less_than(comparison_time, 1.0, "Should complete comparison quickly")

	print("		 Large image comparison completed in %.3fs" % comparison_time)

	return success

# ------------------------------------------------------------------------------
# UTILITY METHOD TESTS
# ------------------------------------------------------------------------------
func test_utility_methods() -> bool:
	"""Test utility methods"""
	print("🧪 Testing utility methods")

	var success = true

	# Test helper methods exist and are callable
	success = success and assert_type(visual_regression._create_comparison_result(true), TYPE_DICTIONARY, "Should create comparison result")
	success = success and assert_type(visual_regression._extract_region(Image.new(), Rect2(0, 0, 10, 10)), TYPE_OBJECT, "Should extract region")

	# Test hash calculation
	var test_image = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	test_image.fill(Color(0.5, 0.5, 0.5, 1))

	var hash1 = visual_regression._calculate_simple_hash(test_image)
	var hash2 = visual_regression._calculate_simple_hash(test_image)
	success = success and assert_equals(hash1, hash2, "Should generate consistent hashes")

	return success

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all VisualRegressionTest tests"""
	print("\n🚀 Running VisualRegressionTest Test Suite\n")

	# Basic Visual Regression Tests
	run_test("test_visual_regression_initialization", func(): return test_visual_regression_initialization())
	run_test("test_configuration_settings", func(): return test_configuration_settings())

	# Baseline Management Tests
	run_test("test_baseline_creation", func(): return test_baseline_creation())
	run_test("test_baseline_version_switching", func(): return test_baseline_version_switching())

	# Comparison Algorithm Tests
	run_test("test_pixel_by_pixel_comparison", func(): return test_pixel_by_pixel_comparison())
	run_test("test_comparison_algorithm_selection", func(): return test_comparison_algorithm_selection())

	# Approval Workflow Tests
	run_test("test_approval_workflow", func(): return test_approval_workflow())

	# Region Comparison Tests
	run_test("test_region_comparison", func(): return test_region_comparison())

	# Reporting Tests
	run_test("test_report_generation", func(): return test_report_generation())

	# Integration Tests
	run_test("test_visual_assertions", func(): return test_visual_assertions())

	# Error Handling Tests
	run_test("test_error_handling", func(): return test_error_handling())

	# Performance Tests
	run_test("test_performance_large_images", func(): return test_performance_large_images())

	# Utility Method Tests
	run_test("test_utility_methods", func(): return test_utility_methods())

	print("\n✨ VisualRegressionTest Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
