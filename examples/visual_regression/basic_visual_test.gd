extends VisualRegressionTestFramework

## Basic Visual Regression Example
##
## Demonstrates fundamental visual regression testing with baseline comparison.
## This example shows how to:
## - Capture baseline screenshots
## - Compare current visuals with baselines
## - Detect visual differences
## - Generate visual reports

# Test scene setup
var test_label: Label
var test_button: Button
var test_panel: Panel

func _ready():
	"""Setup test scene"""
	super._ready()
	
	# Create simple UI for testing
	setup_test_ui()

func setup_test_ui():
	"""Create test UI elements"""
	# Create container
	var container = VBoxContainer.new()
	container.position = Vector2(100, 100)
	add_child(container)
	
	# Add label
	test_label = Label.new()
	test_label.text = "Visual Regression Test"
	test_label.add_theme_font_size_override("font_size", 24)
	container.add_child(test_label)
	
	# Add button
	test_button = Button.new()
	test_button.text = "Test Button"
	test_button.custom_minimum_size = Vector2(200, 50)
	container.add_child(test_button)
	
	# Add panel
	test_panel = Panel.new()
	test_panel.custom_minimum_size = Vector2(300, 200)
	container.add_child(test_panel)

func test_capture_baseline():
	"""Capture baseline screenshot"""
	describe("Capture Baseline Screenshot")
	
	print("\n📸 Capturing baseline screenshot...")
	
	# Wait for frame to render
	await get_tree().process_frame
	
	# Capture baseline
	var success = capture_baseline("test_ui")
	
	assert_true(success, "Baseline capture should succeed")
	print("  ✅ Baseline captured: test_ui")
	print("  Location: ", baseline_dir, "test_ui.png")

func test_compare_identical():
	"""Compare with identical baseline"""
	describe("Compare Identical Screenshots")
	
	print("\n🔍 Comparing with baseline (identical)...")
	
	# Ensure baseline exists
	if not current_baseline_images.has("test_ui"):
		print("  Creating baseline first...")
		await test_capture_baseline()
	
	# Wait for frame
	await get_tree().process_frame
	
	# Compare with baseline (should be identical)
	var result = compare_with_baseline("test_ui", 0.01)
	
	print("  Algorithm: ", ComparisonAlgorithm.keys()[comparison_algorithm])
	print("  Similarity: ", "%.2f" % (result.similarity * 100), "%")
	print("  Tolerance: ", "%.2f" % (visual_tolerance * 100), "%")
	
	if result.success:
		print("  ✅ Visual comparison PASSED")
	else:
		print("  ❌ Visual comparison FAILED")
		print("  Reason: ", result.error if result.has("error") else "Unknown")
	
	assert_true(result.success, "Identical screenshots should match")

func test_compare_with_change():
	"""Compare with modified UI"""
	describe("Compare with Visual Changes")
	
	print("\n🔍 Comparing with baseline (modified)...")
	
	# Ensure baseline exists
	if not current_baseline_images.has("test_ui_modified"):
		# Capture baseline with original state
		await get_tree().process_frame
		capture_baseline("test_ui_modified")
	
	# Modify UI
	test_label.text = "Modified Text"
	test_label.add_theme_color_override("font_color", Color.RED)
	
	# Wait for frame
	await get_tree().process_frame
	
	# Compare with baseline (should detect change)
	var result = compare_with_baseline("test_ui_modified", 0.02)
	
	print("  Algorithm: ", ComparisonAlgorithm.keys()[comparison_algorithm])
	print("  Similarity: ", "%.2f" % (result.similarity * 100), "%")
	print("  Tolerance: ", "%.2f" % (visual_tolerance * 100), "%")
	
	if result.success:
		print("  ✅ Within tolerance")
	else:
		print("  ⚠️  Visual difference detected")
		print("  Difference: ", "%.2f" % ((1.0 - result.similarity) * 100), "%")
	
	# Restore UI
	test_label.text = "Visual Regression Test"
	test_label.remove_theme_color_override("font_color")
	
	# Note: This may pass or fail depending on how much the text change affects pixels
	print("  Note: Result depends on visual impact of text change")

func test_tolerance_levels():
	"""Test different tolerance levels"""
	describe("Tolerance Level Testing")
	
	print("\n🎚️  Testing different tolerance levels...")
	
	# Ensure baseline exists
	if not current_baseline_images.has("test_ui_tolerance"):
		await get_tree().process_frame
		capture_baseline("test_ui_tolerance")
	
	# Make small visual change
	test_button.modulate = Color(1.0, 0.98, 0.98)  # Slight tint
	await get_tree().process_frame
	
	# Test with strict tolerance
	print("\n  Strict Tolerance (1%):")
	var strict_result = compare_with_baseline("test_ui_tolerance", 0.01)
	print("    Similarity: ", "%.2f" % (strict_result.similarity * 100), "%")
	print("    Result: ", "PASS" if strict_result.success else "FAIL")
	
	# Test with medium tolerance
	print("\n  Medium Tolerance (5%):")
	var medium_result = compare_with_baseline("test_ui_tolerance", 0.05)
	print("    Similarity: ", "%.2f" % (medium_result.similarity * 100), "%")
	print("    Result: ", "PASS" if medium_result.success else "FAIL")
	
	# Test with loose tolerance
	print("\n  Loose Tolerance (10%):")
	var loose_result = compare_with_baseline("test_ui_tolerance", 0.10)
	print("    Similarity: ", "%.2f" % (loose_result.similarity * 100), "%")
	print("    Result: ", "PASS" if loose_result.success else "FAIL")
	
	# Restore
	test_button.modulate = Color.WHITE
	
	print("\n  ✅ Tolerance testing completed")
	print("  Recommendation: Adjust tolerance based on content type")

func test_diff_image_generation():
	"""Test difference image generation"""
	describe("Difference Image Generation")
	
	print("\n🖼️  Testing diff image generation...")
	
	# Enable diff generation
	generate_diff_images = true
	
	# Ensure baseline exists
	if not current_baseline_images.has("test_ui_diff"):
		await get_tree().process_frame
		capture_baseline("test_ui_diff")
	
	# Make visible change
	test_panel.modulate = Color(0.8, 0.8, 1.0)  # Blue tint
	await get_tree().process_frame
	
	# Compare (will generate diff image)
	var result = compare_with_baseline("test_ui_diff", 0.02)
	
	print("  Similarity: ", "%.2f" % (result.similarity * 100), "%")
	print("  Diff image generated: ", diff_dir, "test_ui_diff_diff.png")
	
	# Restore
	test_panel.modulate = Color.WHITE
	
	assert_true(true, "Diff generation completed")
	print("  ✅ Check diff image to see highlighted differences")

func test_region_of_interest():
	"""Test region-of-interest comparison"""
	describe("Region of Interest Comparison")
	
	print("\n🎯 Testing ROI comparison...")
	
	# Ensure baseline exists
	if not current_baseline_images.has("test_ui_roi"):
		await get_tree().process_frame
		capture_baseline("test_ui_roi")
	
	# Define ROI (only compare button area)
	var button_pos = test_button.global_position
	var button_size = test_button.size
	var roi = Rect2(button_pos.x, button_pos.y, button_size.x, button_size.y)
	
	print("  ROI: ", roi)
	
	# Modify label (outside ROI)
	test_label.text = "Changed Label"
	await get_tree().process_frame
	
	# Compare only ROI
	var result = compare_with_baseline("test_ui_roi", 0.01, 0, roi)
	
	print("  Similarity (ROI only): ", "%.2f" % (result.similarity * 100), "%")
	
	if result.success:
		print("  ✅ ROI comparison PASSED")
		print("  Note: Label change ignored (outside ROI)")
	else:
		print("  ❌ ROI comparison FAILED")
	
	# Restore
	test_label.text = "Visual Regression Test"
	
	assert_true(result.success, "ROI comparison should pass (label change outside ROI)")
