# GDSentry - Visual Regression Test Framework Usage Examples
# Practical examples demonstrating how to use the VisualRegressionTest framework
#
# This file provides comprehensive examples of using the VisualRegressionTest
# for various testing scenarios including:
# - Baseline creation and version management
# - Multiple comparison algorithms (pixel-by-pixel, perceptual, SSIM)
# - Region-of-interest comparison
# - Approval workflow for baseline changes
# - Report generation and CI/CD integration
# - Integration with GDSentry test cases
# - Advanced configuration and customization
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name VisualRegressionTestExample

# ------------------------------------------------------------------------------
# EXAMPLE SETUP
# ------------------------------------------------------------------------------
var visual_regression

func _ready() -> void:
	"""Initialize the example"""
	visual_regression = load("res://gdsentry/test_types/visual_regression_test.gd").new()

	print("🎯 GDSentry VisualRegressionTest Examples")
	print("=====================================\n")

	run_examples()

# ------------------------------------------------------------------------------
# BASIC BASELINE MANAGEMENT EXAMPLES
# ------------------------------------------------------------------------------
func example_baseline_creation() -> void:
	"""Example: Creating and managing baselines"""
	print("📋 Example 1: Baseline Creation and Management")
	print("-----------------------------------------------")

	# Create initial baseline with version control
	var baseline_name = "main_menu"
	var success = visual_regression.create_baseline_with_version(baseline_name, "Initial main menu layout")
	print("Created baseline '%s': %s" % [baseline_name, "Success" if success else "Failed"])

	# Create additional versions
	success = visual_regression.create_baseline_with_version(baseline_name, "Updated with new button styling")
	print("Created baseline version 2: %s" % ("Success" if success else "Failed"))

	success = visual_regression.create_baseline_with_version(baseline_name, "Final layout with responsive design")
	print("Created baseline version 3: %s" % ("Success" if success else "Failed"))

	# List all versions
	var versions = visual_regression.get_baseline_versions(baseline_name)
	print("Available versions for '%s': %s" % [baseline_name, str(versions)])

	# Switch between versions
	var switch_success = visual_regression.switch_baseline_version(baseline_name, 2)
	print("Switched to version 2: %s" % ("Success" if switch_success else "Failed"))

	print()

# ------------------------------------------------------------------------------
# VISUAL COMPARISON EXAMPLES
# ------------------------------------------------------------------------------
func example_visual_comparison() -> void:
	"""Example: Visual comparison with different algorithms"""
	print("🔍 Example 2: Visual Comparison")
	print("-------------------------------")

	# First, create a baseline (in real usage, this would be the reference image)
	var baseline_name = "comparison_test"
	visual_regression.create_baseline_with_version(baseline_name, "Test baseline")

	# Configure different comparison algorithms
	print("Testing different comparison algorithms:")

	# Pixel-by-pixel comparison (default)
	visual_regression.comparison_algorithm = 0  # PIXEL_BY_PIXEL
	var result1 = visual_regression.compare_with_baseline(baseline_name)
	print("Pixel-by-pixel: %s" % ("PASS" if result1.success else "FAIL"))

	# Perceptual hash comparison
	visual_regression.comparison_algorithm = 1  # PERCEPTUAL_HASH
	visual_regression.perceptual_threshold = 0.95
	var result2 = visual_regression.compare_with_baseline(baseline_name)
	print("Perceptual hash: %s" % ("PASS" if result2.success else "FAIL"))

	# Structural similarity comparison
	visual_regression.comparison_algorithm = 2  # STRUCTURAL_SIMILARITY
	var result3 = visual_regression.compare_with_baseline(baseline_name)
	print("Structural similarity: %s" % ("PASS" if result3.success else "FAIL"))

	print()

# ------------------------------------------------------------------------------
# REGION-OF-INTEREST EXAMPLES
# ------------------------------------------------------------------------------
func example_region_comparison() -> void:
	"""Example: Region-of-interest comparison"""
	print("🎯 Example 3: Region-of-Interest Comparison")
	print("-------------------------------------------")

	# Create baseline
	var baseline_name = "region_test"
	visual_regression.create_baseline_with_version(baseline_name, "Full screen baseline")

	# Compare specific regions
	var regions = [
		{"name": "Header", "rect": Rect2(0, 0, 800, 100)},
		{"name": "Navigation", "rect": Rect2(0, 100, 200, 400)},
		{"name": "Content", "rect": Rect2(200, 100, 600, 400)},
		{"name": "Footer", "rect": Rect2(0, 500, 800, 100)}
	]

	print("Comparing specific regions:")
	for region in regions:
		var result = visual_regression.compare_with_baseline(baseline_name, 0.01, region.rect)
		var status = "✓" if result.success else "✗"
		print("	 %s %s: %s" % [status, region.name, "PASS" if result.success else "FAIL"])

	print()

# ------------------------------------------------------------------------------
# APPROVAL WORKFLOW EXAMPLES
# ------------------------------------------------------------------------------
func example_approval_workflow() -> void:
	"""Example: Approval workflow for baseline changes"""
	print("✅ Example 4: Approval Workflow")
	print("------------------------------")

	# Simulate a visual change that needs approval
	var baseline_name = "ui_update"
	var differences = {
		"similarity": 0.87,
		"different_pixels": 2450,
		"total_pixels": 192000,
		"change_percentage": 1.27
	}

	# Create approval request
	var request_created = visual_regression.create_approval_request(
		baseline_name,
		differences,
		"Updated button colors and spacing according to new design system"
	)

	print("Approval request created: %s" % ("Yes" if request_created else "No"))

	if request_created:
		# Simulate approval process
		print("Approval status: PENDING")

		# Approve the change
		var approved = visual_regression.approve_baseline_change(baseline_name, "design_team_lead")
		print("Change approved: %s" % ("Yes" if approved else "No"))

		if approved:
			print("Approved by: design_team_lead")
			print("New baseline will be created on next test run")
	print()

# ------------------------------------------------------------------------------
# ADVANCED CONFIGURATION EXAMPLES
# ------------------------------------------------------------------------------
func example_advanced_configuration() -> void:
	"""Example: Advanced configuration options"""
	print("⚙️ Example 5: Advanced Configuration")
	print("-----------------------------------")

	# Configure comparison settings
	visual_regression.visual_tolerance = 0.02  # 2% tolerance
	visual_regression.perceptual_threshold = 0.90  # 90% perceptual similarity
	visual_regression.comparison_algorithm = 1  # PERCEPTUAL_HASH
	visual_regression.auto_approve_similar = true
	visual_regression.generate_diff_images = true

	print("Configuration updated:")
	print("	 Visual tolerance: %.1f%%" % (visual_regression.visual_tolerance * 100))
	print("	 Perceptual threshold: %.1f%%" % (visual_regression.perceptual_threshold * 100))
	print("	 Comparison algorithm: %s" % visual_regression.comparison_algorithm)
	print("	 Auto-approve similar: %s" % visual_regression.auto_approve_similar)
	print("	 Generate diff images: %s" % visual_regression.generate_diff_images)

	# Test with new configuration
	var baseline_name = "config_test"
	visual_regression.create_baseline_with_version(baseline_name, "Test with new config")

	var result = visual_regression.compare_with_baseline(baseline_name)
	print("Test with new configuration: %s" % ("PASS" if result.success else "FAIL"))

	print()

# ------------------------------------------------------------------------------
# REPORTING EXAMPLES
# ------------------------------------------------------------------------------
func example_reporting() -> void:
	"""Example: Report generation and export"""
	print("📊 Example 6: Reporting")
	print("----------------------")

	# Perform some test comparisons first
	var baseline_name = "reporting_test"
	visual_regression.create_baseline_with_version(baseline_name, "Test for reporting")

	for i in range(5):
		visual_regression.compare_with_baseline(baseline_name)
		OS.delay_usec(100000)  # Small delay between comparisons

	# Generate comprehensive report
	var report = visual_regression.generate_regression_report()

	print("Regression Report Summary:")
	print("	 Session ID: %s" % report.session_id)
	print("	 Total Comparisons: %d" % report.total_comparisons)
	print("	 Successful: %d" % report.successful_comparisons)
	print("	 Failed: %d" % report.failed_comparisons)
	print("	 Success Rate: %.1f%%" % report.success_rate)
	print("	 Duration: %.2fs" % report.duration)

	# Export reports
	var json_exported = visual_regression.export_regression_report("res://visual_regression_report.json")
	var html_exported = visual_regression.generate_html_report("res://visual_regression_report.html")

	print("Reports exported:")
	print("	 JSON: %s" % ("Yes" if json_exported else "No"))
	print("	 HTML: %s" % ("Yes" if html_exported else "No"))

	print()

# ------------------------------------------------------------------------------
# GDSENTRY INTEGRATION EXAMPLES
# ------------------------------------------------------------------------------
func example_gdsentry_integration() -> void:
	"""Example: Integration with GDSentry test cases"""
	print("🔗 Example 7: GDSentry Integration")
	print("-------------------------------")

	print("This example shows how to integrate VisualRegressionTest with GDSentry test cases:")
	print()

	# Example test case structure
	print("# Example GDSentry Test Case Structure:")
	print("extends VisualRegressionTest")
	print("")
	print("func setup():")
	print("	   # Visual regression setup is handled automatically")
	print("	   pass")
	print("")
	print("func test_main_menu_layout():")
	print("	   # Setup the main menu scene")
	print("	   var main_menu = load('res://scenes/main_menu.tscn').instantiate()")
	print("	   add_child(main_menu)")
	print("	   ")
	print("	   # Wait for rendering")
	print("	   await get_tree().process_frame")
	print("	   await get_tree().process_frame")
	print("	   ")
	print("	   # Assert visual match with baseline")
	print("	   var result = assert_visual_match('main_menu')")
	print("	   assert_true(result, 'Main menu should match baseline')")
	print("	   ")
	print("	   # Clean up")
	print("	   main_menu.queue_free()")
	print("")
	print("func test_button_hover_states():")
	print("	   # Test button hover states")
	print("	   var button_scene = load('res://scenes/test_button.tscn').instantiate()")
	print("	   add_child(button_scene)")
	print("	   ")
	print("	   # Test normal state")
	print("	   var result1 = assert_visual_match('button_normal')")
	print("	   assert_true(result1)")
	print("	   ")
	print("	   # Simulate hover")
	print("	   button_scene.get_node('Button').emit_signal('mouse_entered')")
	print("	   await get_tree().process_frame")
	print("	   ")
	print("	   # Test hover state")
	print("	   var result2 = assert_visual_match('button_hover')")
	print("	   assert_true(result2)")
	print("	   ")
	print("	   button_scene.queue_free()")
	print("")
	print("func test_responsive_layout():")
	print("	   # Test responsive layout at different screen sizes")
	print("	   var layout_scene = load('res://scenes/responsive_layout.tscn').instantiate()")
	print("	   add_child(layout_scene)")
	print("	   ")
	print("	   # Test desktop layout")
	print("	   get_viewport().size = Vector2(1920, 1080)")
	print("	   await get_tree().process_frame")
	print("	   var desktop_result = assert_visual_match('layout_desktop')")
	print("	   assert_true(desktop_result)")
	print("	   ")
	print("	   # Test mobile layout")
	print("	   get_viewport().size = Vector2(375, 667)")
	print("	   await get_tree().process_frame")
	print("	   var mobile_result = assert_visual_match('layout_mobile')")
	print("	   assert_true(mobile_result)")
	print("	   ")
	print("	   layout_scene.queue_free()")
	print("")
	print("func test_region_specific_changes():")
	print("	   # Test specific regions for changes")
	print("	   var complex_scene = load('res://scenes/complex_ui.tscn').instantiate()")
	print("	   add_child(complex_scene)")
	print("	   await get_tree().process_frame")
	print("	   ")
	print("	   # Test header region only")
	print("	   var header_region = Rect2(0, 0, 800, 80)")
	print("	   var header_result = assert_visual_match_region('complex_ui', header_region)")
	print("	   assert_true(header_result, 'Header should match baseline')")
	print("	   ")
	print("	   # Test content area")
	print("	   var content_region = Rect2(0, 80, 800, 400)")
	print("	   var content_result = assert_visual_match_region('complex_ui', content_region)")
	print("	   assert_true(content_result, 'Content area should match baseline')")
	print("	   ")
	print("	   complex_scene.queue_free()")
	print("")
	print("func test_baseline_version_management():")
	print("	   # Test with different baseline versions")
	print("	   var ui_scene = load('res://scenes/ui_scene.tscn').instantiate()")
	print("	   add_child(ui_scene)")
	print("	   await get_tree().process_frame")
	print("	   ")
	print("	   # Compare with version 1")
	print("	   switch_baseline_version('ui_scene', 1)")
	print("	   var v1_result = assert_visual_match('ui_scene')")
	print("	   ")
	print("	   # Compare with version 2")
	print("	   switch_baseline_version('ui_scene', 2)")
	print("	   var v2_result = assert_visual_match('ui_scene')")
	print("	   ")
	print("	   # At least one version should match")
	print("	   assert_true(v1_result or v2_result, 'UI should match at least one baseline version')")
	print("	   ")
	print("	   ui_scene.queue_free()")
	print("")
	print("func test_performance_regression():")
	print("	   # Test for performance regression")
	print("	   var heavy_scene = load('res://scenes/heavy_ui.tscn').instantiate()")
	print("	   add_child(heavy_scene)")
	print("	   await get_tree().process_frame")
	print("	   ")
	print("	   # Assert rendering performance")
	print("	   var perf_result = assert_rendering_performance(16.67)  # 60 FPS")
	print("	   assert_true(perf_result, 'Rendering should meet performance requirements')")
	print("	   ")
	print("	   heavy_scene.queue_free()")
	print()

	print("Key Integration Benefits:")
	print("	 • Automatic baseline management and version control")
	print("	 • Multiple comparison algorithms for different use cases")
	print("	 • Region-of-interest testing for partial UI validation")
	print("	 • Approval workflow for managing expected changes")
	print("	 • Comprehensive reporting for CI/CD integration")
	print("	 • Performance regression detection")
	print("	 • Seamless integration with existing GDSentry test patterns")
	print()

# ------------------------------------------------------------------------------
# CI/CD INTEGRATION EXAMPLES
# ------------------------------------------------------------------------------
func example_ci_cd_integration() -> void:
	"""Example: CI/CD integration patterns"""
	print("🔄 Example 8: CI/CD Integration")
	print("------------------------------")

	print("CI/CD Integration Patterns:")
	print()

	print("# 1. Baseline Management in CI/CD:")
	print("if [ \"$BASELINE_UPDATE\" = \"true\" ]; then")
	print("	   # Update baselines for expected changes")
	print("	   godot --script create_baselines.gd")
	print("else")
	print("	   # Run visual regression tests")
	print("	   godot --script run_visual_tests.gd")
	print("fi")
	print()

	print("# 2. Approval Workflow Integration:")
	print("if [ \"$APPROVE_CHANGES\" = \"true\" ]; then")
	print("	   # Auto-approve changes for automated deployments")
	print("	   godot --script approve_changes.gd --baseline main_ui")
	print("fi")
	print()

	print("# 3. Report Generation and Upload:")
	print("godot --script generate_reports.gd")
	print("if [ -f \"visual_regression_report.html\" ]; then")
	print("	   # Upload report to CI/CD artifacts")
	print("	   upload_artifact visual_regression_report.html")
	print("	   upload_artifact visual_regression_report.json")
	print("fi")
	print()

	print("# 4. Failure Handling:")
	print("if [ \"$VISUAL_TESTS_FAILED\" = \"true\" ]; then")
	print("	   echo \"Visual regression detected\"")
	print("	   # Generate diff images for review")
	print("	   godot --script generate_diffs.gd")
	print("	   # Notify team or create approval request")
	print("	   create_approval_request")
	print("fi")
	print()

	print("# 5. Performance Regression Detection:")
	print("godot --script performance_tests.gd")
	print("if [ \"$PERFORMANCE_REGRESSION\" = \"true\" ]; then")
	print("	   echo \"Performance regression detected\"")
	print("	   # Alert team and block deployment")
	print("	   notify_team \"Performance regression detected\"")
	print("	   exit 1")
	print("fi")
	print()

# ------------------------------------------------------------------------------
# PERFORMANCE AND SCALING EXAMPLES
# ------------------------------------------------------------------------------
func example_performance_scaling() -> void:
	"""Example: Performance testing and scaling"""
	print("⚡ Example 9: Performance & Scaling")
	print("----------------------------------")

	# Create multiple baselines for performance testing
	var baseline_names = ["ui_component_1", "ui_component_2", "ui_component_3", "full_screen"]

	print("Creating multiple baselines for performance testing:")

	var start_time = Time.get_ticks_usec() / 1000000.0
	for baseline_name in baseline_names:
		var success = visual_regression.create_baseline_with_version(baseline_name, "Performance test baseline")
		print("	 %s: %s" % [baseline_name, "✓" if success else "✗"])

	var end_time = Time.get_ticks_usec() / 1000000.0
	var creation_time = end_time - start_time

	print("Baseline creation time: %.3fs" % creation_time)
	print()

	# Test comparison performance
	print("Testing comparison performance:")

	start_time = Time.get_ticks_usec() / 1000000.0
	var comparison_count = 0

	for baseline_name in baseline_names:
		for i in range(5):	# 5 comparisons per baseline
			var _result = visual_regression.compare_with_baseline(baseline_name)
			comparison_count += 1

	end_time = Time.get_ticks_usec() / 1000000.0
	var comparison_time = end_time - start_time
	var avg_comparison_time = comparison_time / comparison_count

	print("Total comparisons: %d" % comparison_count)
	print("Total time: %.3fs" % comparison_time)
	print("Average per comparison: %.3fs" % avg_comparison_time)
	print("Comparisons per second: %.1f" % (comparison_count / comparison_time))
	print()

	# Generate performance report
	var perf_report = visual_regression.generate_regression_report()
	print("Performance Report:")
	print("	 Session duration: %.3fs" % perf_report.duration)
	print("	 Comparisons performed: %d" % perf_report.total_comparisons)
	print("	 Average comparison time: %.3fs" % (perf_report.duration / perf_report.total_comparisons))
	print()

# ------------------------------------------------------------------------------
# RUN ALL EXAMPLES
# ------------------------------------------------------------------------------
func run_examples() -> void:
	"""Run all examples"""
	example_baseline_creation()
	example_visual_comparison()
	example_region_comparison()
	example_approval_workflow()
	example_advanced_configuration()
	example_reporting()
	example_gdsentry_integration()
	example_ci_cd_integration()
	example_performance_scaling()

	print("🎉 All VisualRegressionTest examples completed!")
	print("\n💡 Key Takeaways:")
	print("	 • Baseline version control enables tracking visual changes over time")
	print("	 • Multiple comparison algorithms provide flexibility for different use cases")
	print("	 • Region-of-interest testing allows partial UI validation")
	print("	 • Approval workflow manages expected visual changes")
	print("	 • Comprehensive reporting supports CI/CD integration")
	print("	 • Performance monitoring prevents rendering regressions")
	print("	 • GDSentry integration provides seamless testing workflow")
	print("\n📖 For more advanced usage, see the VisualRegressionTest class documentation.")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	if visual_regression:
		visual_regression.queue_free()
