extends VisualRegressionTestFramework

## Comparison Algorithm Example
##
## Demonstrates all 4 comparison algorithms and when to use each.
## This example shows how to:
## - Use pixel-by-pixel comparison
## - Use perceptual hash comparison
## - Use structural similarity (SSIM)
## - Use feature-based comparison
## - Select appropriate algorithm for use case

var test_sprite: Sprite2D
var test_color_rect: ColorRect

func _ready():
	"""Setup test scene"""
	super._ready()
	setup_test_scene()

func setup_test_scene():
	"""Create test scene with visual elements"""
	# Create sprite
	test_sprite = Sprite2D.new()
	test_sprite.position = Vector2(200, 200)
	# Note: In real test, load actual texture
	add_child(test_sprite)
	
	# Create color rect
	test_color_rect = ColorRect.new()
	test_color_rect.position = Vector2(400, 200)
	test_color_rect.size = Vector2(200, 150)
	test_color_rect.color = Color(0.3, 0.5, 0.8)
	add_child(test_color_rect)

func test_pixel_by_pixel_algorithm():
	"""Test pixel-by-pixel comparison algorithm"""
	describe("Pixel-by-Pixel Algorithm")
	
	print("\n🔬 Testing PIXEL_BY_PIXEL algorithm...")
	print("  Use case: Exact UI validation, pixel-perfect comparison")
	print("  Speed: Slow (compares every pixel)")
	print("  Accuracy: Highest")
	
	# Configure algorithm
	comparison_algorithm = ComparisonAlgorithm.PIXEL_BY_PIXEL
	visual_tolerance = 0.01  # 1% tolerance
	
	# Capture baseline
	await get_tree().process_frame
	capture_baseline("pixel_test")
	
	# Compare with baseline
	var result = compare_with_baseline("pixel_test", visual_tolerance)
	
	print("\n  Results:")
	print("    Similarity: ", "%.4f" % (result.similarity * 100), "%")
	print("    Matching pixels: ", result.get("matching_pixels", "N/A"))
	print("    Different pixels: ", result.get("different_pixels", "N/A"))
	print("    Max difference: ", "%.4f" % result.get("max_difference", 0.0))
	
	assert_true(result.success, "Identical images should match")
	print("\n  ✅ Pixel-by-pixel comparison completed")
	print("  Recommendation: Use for UI components requiring exact validation")

func test_perceptual_hash_algorithm():
	"""Test perceptual hash comparison algorithm"""
	describe("Perceptual Hash Algorithm")
	
	print("\n🔬 Testing PERCEPTUAL_HASH algorithm...")
	print("  Use case: General screenshot comparison, smoke tests")
	print("  Speed: Fast (hash-based)")
	print("  Accuracy: Medium (robust to minor changes)")
	
	# Configure algorithm
	comparison_algorithm = ComparisonAlgorithm.PERCEPTUAL_HASH
	perceptual_threshold = 0.95  # 95% similarity
	
	# Capture baseline
	await get_tree().process_frame
	capture_baseline("phash_test")
	
	# Make minor change (perceptual hash should tolerate)
	test_color_rect.color = Color(0.3, 0.5, 0.81)  # Slight color change
	await get_tree().process_frame
	
	# Compare with baseline
	var result = compare_with_baseline("phash_test", 0.0, 0, Rect2())
	
	print("\n  Results:")
	print("    Similarity: ", "%.4f" % (result.similarity * 100), "%")
	print("    Hash 1: ", result.get("hash1", "N/A"))
	print("    Hash 2: ", result.get("hash2", "N/A"))
	
	# Restore
	test_color_rect.color = Color(0.3, 0.5, 0.8)
	
	print("\n  ✅ Perceptual hash comparison completed")
	print("  Recommendation: Use for fast screenshot comparison")
	print("  Note: Tolerates compression, scaling, minor color changes")

func test_structural_similarity_algorithm():
	"""Test SSIM comparison algorithm"""
	describe("Structural Similarity (SSIM) Algorithm")
	
	print("\n🔬 Testing STRUCTURAL_SIMILARITY algorithm...")
	print("  Use case: Quality assessment, perceptual validation")
	print("  Speed: Medium (statistical comparison)")
	print("  Accuracy: High (aligned with human perception)")
	
	# Configure algorithm
	comparison_algorithm = ComparisonAlgorithm.STRUCTURAL_SIMILARITY
	visual_tolerance = 0.05  # 5% SSIM difference
	
	# Capture baseline
	await get_tree().process_frame
	capture_baseline("ssim_test")
	
	# Compare with baseline
	var result = compare_with_baseline("ssim_test", visual_tolerance)
	
	print("\n  Results:")
	print("    SSIM Score: ", "%.4f" % (result.similarity * 100), "%")
	print("    Tolerance: ", "%.2f" % (visual_tolerance * 100), "%")
	
	assert_true(result.success, "SSIM comparison should pass")
	print("\n  ✅ SSIM comparison completed")
	print("  Recommendation: Use for perceptual quality testing")
	print("  Note: Better aligned with human visual perception than pixel-by-pixel")

func test_feature_based_algorithm():
	"""Test feature-based comparison algorithm"""
	describe("Feature-Based Algorithm")
	
	print("\n🔬 Testing FEATURE_BASED algorithm...")
	print("  Use case: 3D scenes with camera variations")
	print("  Speed: Medium-Slow (feature extraction)")
	print("  Accuracy: Robust to transformations")
	print("  Note: Currently falls back to pixel-by-pixel")
	
	# Configure algorithm
	comparison_algorithm = ComparisonAlgorithm.FEATURE_BASED
	visual_tolerance = 0.10  # 10% tolerance for transformations
	
	# Capture baseline
	await get_tree().process_frame
	capture_baseline("feature_test")
	
	# Compare with baseline
	var result = compare_with_baseline("feature_test", visual_tolerance)
	
	print("\n  Results:")
	print("    Similarity: ", "%.4f" % (result.similarity * 100), "%")
	print("    Note: Using pixel-by-pixel fallback")
	
	print("\n  ⚠️  Feature-based comparison (placeholder)")
	print("  Recommendation: Use when implemented for 3D scene comparison")
	print("  Future: Will support SIFT, SURF, ORB feature matching")

func test_algorithm_comparison():
	"""Compare all algorithms on same image"""
	describe("Algorithm Comparison")
	
	print("\n📊 Comparing all algorithms on same baseline...")
	
	# Capture baseline
	await get_tree().process_frame
	capture_baseline("algo_compare")
	
	# Make subtle change
	test_color_rect.color = Color(0.31, 0.51, 0.81)
	await get_tree().process_frame
	
	print("\n  Testing with subtle color change...")
	
	# Test each algorithm
	var results = {}
	
	# Pixel-by-pixel
	comparison_algorithm = ComparisonAlgorithm.PIXEL_BY_PIXEL
	results["pixel"] = compare_with_baseline("algo_compare", 0.05)
	
	# Perceptual hash
	comparison_algorithm = ComparisonAlgorithm.PERCEPTUAL_HASH
	results["phash"] = compare_with_baseline("algo_compare", 0.0)
	
	# SSIM
	comparison_algorithm = ComparisonAlgorithm.STRUCTURAL_SIMILARITY
	results["ssim"] = compare_with_baseline("algo_compare", 0.05)
	
	# Feature-based
	comparison_algorithm = ComparisonAlgorithm.FEATURE_BASED
	results["feature"] = compare_with_baseline("algo_compare", 0.05)
	
	# Print comparison
	print("\n  Algorithm Results:")
	print("    Pixel-by-Pixel: ", "%.2f" % (results.pixel.similarity * 100), "% - ", 
	      "PASS" if results.pixel.success else "FAIL")
	print("    Perceptual Hash: ", "%.2f" % (results.phash.similarity * 100), "% - ",
	      "PASS" if results.phash.success else "FAIL")
	print("    SSIM: ", "%.2f" % (results.ssim.similarity * 100), "% - ",
	      "PASS" if results.ssim.success else "FAIL")
	print("    Feature-Based: ", "%.2f" % (results.feature.similarity * 100), "% - ",
	      "PASS" if results.feature.success else "FAIL")
	
	# Restore
	test_color_rect.color = Color(0.3, 0.5, 0.8)
	
	print("\n  ✅ Algorithm comparison completed")
	print("\n  Observations:")
	print("    - Pixel-by-pixel: Most sensitive to changes")
	print("    - Perceptual hash: Robust to minor changes")
	print("    - SSIM: Balanced sensitivity and robustness")
	print("    - Feature-based: Currently uses pixel-by-pixel fallback")

func test_algorithm_selection_guide():
	"""Print algorithm selection guide"""
	describe("Algorithm Selection Guide")
	
	print("\n📖 Algorithm Selection Guide:")
	print("\n  1. PIXEL_BY_PIXEL")
	print("     When: Exact UI validation, pixel-perfect comparison")
	print("     Tolerance: 1-2% for UI, 5-10% for 3D")
	print("     Speed: ⚠️  Slow")
	print("     Example: Button layouts, text rendering, UI components")
	
	print("\n  2. PERCEPTUAL_HASH")
	print("     When: General screenshot comparison, smoke tests")
	print("     Tolerance: 95%+ similarity threshold")
	print("     Speed: ✅ Fast")
	print("     Example: Full-screen screenshots, quick validation")
	
	print("\n  3. STRUCTURAL_SIMILARITY")
	print("     When: Quality assessment, perceptual validation")
	print("     Tolerance: 3-5% for quality testing")
	print("     Speed: ➡️  Medium")
	print("     Example: Image quality, rendering quality, visual fidelity")
	
	print("\n  4. FEATURE_BASED")
	print("     When: 3D scenes with camera variations")
	print("     Tolerance: 10-15% for transformations")
	print("     Speed: ⚠️  Medium-Slow")
	print("     Example: 3D scenes, rotated views, scaled content")
	print("     Status: ⚠️  Placeholder (uses pixel-by-pixel)")
	
	print("\n  Decision Tree:")
	print("    Need exact validation? → PIXEL_BY_PIXEL")
	print("    Need fast comparison? → PERCEPTUAL_HASH")
	print("    Need perceptual quality? → STRUCTURAL_SIMILARITY")
	print("    Need transformation robustness? → FEATURE_BASED (when implemented)")
	
	assert_true(true, "Guide printed")
	print("\n  ✅ Selection guide completed")
