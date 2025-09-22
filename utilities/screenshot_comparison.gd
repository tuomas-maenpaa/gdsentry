# GDSentry - Screenshot Comparison Utilities
# Advanced screenshot comparison and image processing utilities
#
# This module provides comprehensive screenshot comparison capabilities including:
# - Advanced image processing and filtering
# - Batch comparison operations with performance optimization
# - Comparison result caching and reuse
# - Advanced difference visualization techniques
# - Integration utilities for various comparison scenarios
# - Performance monitoring and optimization
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name ScreenshotComparison

# ------------------------------------------------------------------------------
# UTILITIES CONSTANTS
# ------------------------------------------------------------------------------
const CACHE_SIZE_LIMIT = 50
const MAX_IMAGE_SIZE = 4096
const DEFAULT_COMPARISON_TIMEOUT = 30.0

# ------------------------------------------------------------------------------
# UTILITIES METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

# ------------------------------------------------------------------------------
# IMAGE PROCESSING UTILITIES
# ------------------------------------------------------------------------------
class ImageProcessor:
	static func resize_image(image: Image, new_size: Vector2, interpolation: Image.Interpolation = Image.INTERPOLATE_BILINEAR) -> Image:
		"""Resize an image to specified dimensions"""
		var resized = Image.new()
		resized.copy_from(image)
		resized.resize(int(new_size.x), int(new_size.y), interpolation)
		return resized

	static func crop_image(image: Image, region: Rect2) -> Image:
		"""Crop an image to specified region"""
		var cropped = Image.create(int(region.size.x), int(region.size.y), false, image.get_format())

		image.lock()
		cropped.lock()

		for y in range(region.size.y):
			for x in range(region.size.x):
				var source_x = region.position.x + x
				var source_y = region.position.y + y

				if source_x >= 0 and source_x < image.get_width() and source_y >= 0 and source_y < image.get_height():
					var color = image.get_pixel(source_x, source_y)
					cropped.set_pixel(x, y, color)

		image.unlock()
		cropped.unlock()

		return cropped

	static func apply_blur(image: Image, _radius: float = 1.0) -> Image:
		"""Apply Gaussian blur to an image"""
		var blurred = Image.new()
		blurred.copy_from(image)

		# Simple blur implementation
		blurred.lock()
		var width = blurred.get_width()
		var height = blurred.get_height()

		for y in range(height):
			for x in range(width):
				var color_sum = Color(0, 0, 0, 0)
				var sample_count = 0

				# Sample neighboring pixels
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var sample_x = clamp(x + dx, 0, width - 1)
						var sample_y = clamp(y + dy, 0, height - 1)
						color_sum += blurred.get_pixel(sample_x, sample_y)
						sample_count += 1

				blurred.set_pixel(x, y, color_sum / sample_count)

		blurred.unlock()
		return blurred

	static func convert_to_grayscale(image: Image) -> Image:
		"""Convert image to grayscale"""
		var grayscale = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)

		image.lock()
		grayscale.lock()

		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var color = image.get_pixel(x, y)
				var gray_value = (color.r + color.g + color.b) / 3.0
				var gray_color = Color(gray_value, gray_value, gray_value, color.a)
				grayscale.set_pixel(x, y, gray_color)

		image.unlock()
		grayscale.unlock()

		return grayscale

	static func enhance_contrast(image: Image, factor: float = 1.2) -> Image:
		"""Enhance image contrast"""
		var enhanced = Image.new()
		enhanced.copy_from(image)
		enhanced.lock()

		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var color = enhanced.get_pixel(x, y)
				var enhanced_color = Color(
					clamp((color.r - 0.5) * factor + 0.5, 0.0, 1.0),
					clamp((color.g - 0.5) * factor + 0.5, 0.0, 1.0),
					clamp((color.b - 0.5) * factor + 0.5, 0.0, 1.0),
					color.a
				)
				enhanced.set_pixel(x, y, enhanced_color)

		enhanced.unlock()
		return enhanced

	static func normalize_image(image: Image) -> Image:
		"""Normalize image for better comparison"""
		# Convert to grayscale and enhance contrast
		var normalized = convert_to_grayscale(image)
		normalized = enhance_contrast(normalized, 1.5)
		return normalized

# ------------------------------------------------------------------------------
# COMPARISON RESULT CACHING
# ------------------------------------------------------------------------------
class ComparisonCache:
	var cache: Dictionary = {}
	var access_order: Array = []
	var max_size: int = CACHE_SIZE_LIMIT

	func get_cache_key(image1: Image, image2: Image, algorithm: int, tolerance: float, region: Rect2 = Rect2()) -> String:
		"""Generate a unique cache key for comparison parameters"""
		var key_parts = [
			str(image1.get_width()) + "x" + str(image1.get_height()),
			str(image2.get_width()) + "x" + str(image2.get_height()),
			str(algorithm),
			str(tolerance)
		]

		if region != Rect2():
			key_parts.append(str(region))

		return ",".join(key_parts)

	func get_cached_result(key: String) -> Dictionary:
		"""Retrieve cached comparison result"""
		if cache.has(key):
			# Move to end of access order (most recently used)
			access_order.erase(key)
			access_order.append(key)
			return cache[key].duplicate(true)
		return {}

	func put(key: String, result: Dictionary) -> void:
		"""Store comparison result in cache"""
		if cache.size() >= max_size and not cache.has(key):
			# Remove least recently used item
			var lru_key = access_order.pop_front()
			cache.erase(lru_key)

		cache[key] = result.duplicate(true)

		# Update access order
		if access_order.has(key):
			access_order.erase(key)
		access_order.append(key)

	func clear() -> void:
		"""Clear all cached results"""
		cache.clear()
		access_order.clear()

	func get_stats() -> Dictionary:
		"""Get cache statistics"""
		return {
			"size": cache.size(),
			"max_size": max_size,
			"hit_rate": 0.0,  # Would need to track hits/misses for this
			"access_order_size": access_order.size()
		}

# ------------------------------------------------------------------------------
# ADVANCED COMPARISON ALGORITHMS
# ------------------------------------------------------------------------------
class AdvancedComparators:
	static var cache: ComparisonCache = ComparisonCache.new()

	static func compare_with_caching(image1: Image, image2: Image, algorithm: int, tolerance: float, region: Rect2 = Rect2()) -> Dictionary:
		"""Compare images with caching for performance"""
		var cache_key = cache.get_cache_key(image1, image2, algorithm, tolerance, region)
		var cached_result = cache.get_cached_result(cache_key)

		if not cached_result.is_empty():
			return cached_result

		# Perform comparison
		var result = Dictionary()
		match algorithm:
			0:	# Pixel by pixel
				result = compare_pixel_by_pixel_advanced(image1, image2, tolerance, region)
			1:	# Perceptual hash
				result = compare_perceptual_hash_advanced(image1, image2, tolerance)
			2:	# Structural similarity
				result = compare_structural_similarity_advanced(image1, image2, tolerance, region)
			3:	# Feature based
				result = compare_feature_based_advanced(image1, image2, tolerance, region)
			_:
				result = {"success": false, "error": "Unknown algorithm"}

		# Cache result
		cache.put(cache_key, result)
		return result

	static func compare_pixel_by_pixel_advanced(image1: Image, image2: Image, tolerance: float, region: Rect2 = Rect2()) -> Dictionary:
		"""Advanced pixel-by-pixel comparison with detailed metrics"""
		if image1.get_size() != image2.get_size():
			return {"success": false, "error": "Image sizes don't match"}

		# Use region if specified
		var img1 = image1 if region == Rect2() else ImageProcessor.crop_image(image1, region)
		var img2 = image2 if region == Rect2() else ImageProcessor.crop_image(image2, region)

		if img1.get_size() != img2.get_size():
			return {"success": false, "error": "Region sizes don't match"}

		var total_pixels = img1.get_width() * img1.get_height()
		var matching_pixels = 0
		var different_pixels = 0
		var max_difference = 0.0
		var total_difference = 0.0
		var difference_map = []

		img1.lock()
		img2.lock()

		for y in range(img1.get_height()):
			var row_differences = []
			for x in range(img1.get_width()):
				var color1 = img1.get_pixel(x, y)
				var color2 = img2.get_pixel(x, y)

				if color1.is_equal_approx(color2):
					matching_pixels += 1
					row_differences.append(0.0)
				else:
					different_pixels += 1
					var difference = color1.distance_to(color2)
					total_difference += difference
					max_difference = max(max_difference, difference)
					row_differences.append(difference)

			difference_map.append(row_differences)

		img1.unlock()
		img2.unlock()

		var similarity = float(matching_pixels) / float(total_pixels)
		var avg_difference = total_difference / float(different_pixels) if different_pixels > 0 else 0.0

		return {
			"success": similarity >= (1.0 - tolerance),
			"similarity": similarity,
			"matching_pixels": matching_pixels,
			"different_pixels": different_pixels,
			"total_pixels": total_pixels,
			"tolerance": tolerance,
			"max_difference": max_difference,
			"avg_difference": avg_difference,
			"difference_map": difference_map,
			"algorithm": "pixel_by_pixel_advanced"
		}

	static func compare_perceptual_hash_advanced(image1: Image, image2: Image, tolerance: float) -> Dictionary:
		"""Advanced perceptual hash comparison with multiple hash sizes"""
		# Normalize images for better comparison
		var norm1 = ImageProcessor.normalize_image(image1)
		var norm2 = ImageProcessor.normalize_image(image2)

		# Generate multiple hash sizes for robustness
		var hash_sizes = [8, 16, 32]
		var similarities = []

		for size in hash_sizes:
			var hash1 = generate_dhash(norm1, size)
			var hash2 = generate_dhash(norm2, size)
			var similarity = calculate_hash_similarity(hash1, hash2)
			similarities.append(similarity)

		# Use average similarity across different hash sizes
		var avg_similarity = 0.0
		for sim in similarities:
			avg_similarity += sim
		avg_similarity /= similarities.size()

		return {
			"success": avg_similarity >= (1.0 - tolerance),
			"similarity": avg_similarity,
			"hash_similarities": similarities,
			"hash_sizes": hash_sizes,
			"tolerance": tolerance,
			"algorithm": "perceptual_hash_advanced"
		}

	static func generate_dhash(image: Image, size: int) -> String:
		"""Generate difference hash for image"""
		# Resize image to hash size + 1
		var resized = ImageProcessor.resize_image(image, Vector2(size + 1, size))
		resized = ImageProcessor.convert_to_grayscale(resized)

		resized.lock()
		var hash_string = ""

		for y in range(size):
			for x in range(size):
				var pixel1 = resized.get_pixel(x, y).r
				var pixel2 = resized.get_pixel(x + 1, y).r
				hash_string += "1" if pixel1 > pixel2 else "0"

		resized.unlock()
		return hash_string

	static func calculate_hash_similarity(hash1: String, hash2: String) -> float:
		"""Calculate similarity between two hashes"""
		if hash1.length() != hash2.length():
			return 0.0

		var differences = 0
		for i in range(hash1.length()):
			if hash1[i] != hash2[i]:
				differences += 1

		return 1.0 - (float(differences) / float(hash1.length()))

	static func compare_structural_similarity_advanced(image1: Image, image2: Image, tolerance: float, region: Rect2 = Rect2()) -> Dictionary:
		"""Advanced SSIM comparison with multiple window sizes"""
		# Use region if specified
		var img1 = image1 if region == Rect2() else ImageProcessor.crop_image(image1, region)
		var img2 = image2 if region == Rect2() else ImageProcessor.crop_image(image2, region)

		if img1.get_size() != img2.get_size():
			return {"success": false, "error": "Image sizes don't match"}

		# Calculate SSIM with different window sizes
		var window_sizes = [8, 11, 16]
		var ssim_scores = []

		for window_size in window_sizes:
			var ssim = calculate_ssim(img1, img2, window_size)
			ssim_scores.append(ssim)

		# Use weighted average (larger windows have more weight)
		var weighted_sum = 0.0
		var total_weight = 0.0
		for i in range(ssim_scores.size()):
			var weight = float(i + 1) / float(ssim_scores.size())
			weighted_sum += ssim_scores[i] * weight
			total_weight += weight

		var final_ssim = weighted_sum / total_weight

		return {
			"success": final_ssim >= (1.0 - tolerance),
			"similarity": final_ssim,
			"ssim_scores": ssim_scores,
			"window_sizes": window_sizes,
			"tolerance": tolerance,
			"algorithm": "structural_similarity_advanced"
		}

	static func calculate_ssim(image1: Image, image2: Image, window_size: int) -> float:
		"""Calculate SSIM for images with given window size"""
		if image1.get_size() != image2.get_size():
			return 0.0

		# Convert to grayscale for luminance comparison
		var gray1 = ImageProcessor.convert_to_grayscale(image1)
		var gray2 = ImageProcessor.convert_to_grayscale(image2)

		var width = gray1.get_width()
		var height = gray1.get_height()
		var total_ssim = 0.0
		var window_count = 0

		gray1.lock()
		gray2.lock()

		# Slide window across image
		for y in range(0, height - window_size + 1, window_size / 2.0):
			for x in range(0, width - window_size + 1, window_size / 2.0):
				var window1 = extract_window(gray1, x, y, window_size)
				var window2 = extract_window(gray2, x, y, window_size)

				var ssim = calculate_window_ssim(window1, window2)
				total_ssim += ssim
				window_count += 1

		gray1.unlock()
		gray2.unlock()

		return total_ssim / float(window_count) if window_count > 0 else 0.0

	static func extract_window(image: Image, x: int, y: int, size: int) -> Array:
		"""Extract pixel values from image window"""
		var window = []
		for wy in range(size):
			for wx in range(size):
				var color = image.get_pixel(x + wx, y + wy)
				window.append(color.r)
		return window

	static func calculate_window_ssim(window1: Array, window2: Array) -> float:
		"""Calculate SSIM for a window"""
		if window1.size() != window2.size():
			return 0.0

		# Calculate mean
		var mean1 = 0.0
		var mean2 = 0.0
		for i in range(window1.size()):
			mean1 += window1[i]
			mean2 += window2[i]
		mean1 /= window1.size()
		mean2 /= window2.size()

		# Calculate variance and covariance
		var var1 = 0.0
		var var2 = 0.0
		var covar = 0.0

		for i in range(window1.size()):
			var diff1 = window1[i] - mean1
			var diff2 = window2[i] - mean2
			var1 += diff1 * diff1
			var2 += diff2 * diff2
			covar += diff1 * diff2

		var1 /= window1.size()
		var2 /= window2.size()
		covar /= window1.size()

		# SSIM formula
		var c1 = 0.01 * 0.01  # Small constants to avoid division by zero
		var c2 = 0.03 * 0.03

		var numerator = (2 * mean1 * mean2 + c1) * (2 * covar + c2)
		var denominator = (mean1 * mean1 + mean2 * mean2 + c1) * (var1 + var2 + c2)

		return numerator / denominator if denominator > 0 else 0.0

	static func compare_feature_based_advanced(image1: Image, image2: Image, tolerance: float, region: Rect2 = Rect2()) -> Dictionary:
		"""Advanced feature-based comparison using edge detection"""
		# Use region if specified
		var img1 = image1 if region == Rect2() else ImageProcessor.crop_image(image1, region)
		var img2 = image2 if region == Rect2() else ImageProcessor.crop_image(image2, region)

		# Convert to grayscale
		var gray1 = ImageProcessor.convert_to_grayscale(img1)
		var gray2 = ImageProcessor.convert_to_grayscale(img2)

		# Detect edges using simple Sobel operator
		var edges1 = detect_edges(gray1)
		var edges2 = detect_edges(gray2)

		# Compare edge images
		var edge_comparison = compare_pixel_by_pixel_advanced(edges1, edges2, tolerance)

		return {
			"success": edge_comparison.success,
			"similarity": edge_comparison.similarity,
			"edge_matching_pixels": edge_comparison.matching_pixels,
			"edge_different_pixels": edge_comparison.different_pixels,
			"tolerance": tolerance,
			"algorithm": "feature_based_advanced"
		}

	static func detect_edges(image: Image) -> Image:
		"""Simple edge detection using Sobel operator"""
		var edges = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)

		image.lock()
		edges.lock()

		var sobel_x = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
		var sobel_y = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]

		for y in range(1, image.get_height() - 1):
			for x in range(1, image.get_width() - 1):
				var gx = 0.0
				var gy = 0.0

				# Apply Sobel kernels
				for ky in range(3):
					for kx in range(3):
						var pixel = image.get_pixel(x + kx - 1, y + ky - 1).r
						gx += pixel * sobel_x[ky][kx]
						gy += pixel * sobel_y[ky][kx]

				var magnitude = sqrt(gx * gx + gy * gy)
				var edge_color = Color(magnitude, magnitude, magnitude, 1.0)
				edges.set_pixel(x, y, edge_color)

		image.unlock()
		edges.unlock()

		return edges

# ------------------------------------------------------------------------------
# BATCH COMPARISON UTILITIES
# ------------------------------------------------------------------------------
class BatchComparator:
	var results: Array = []
	var start_time: float = 0.0
	var end_time: float = 0.0

	func compare_images_batch(image_pairs: Array, algorithm: int = 0, tolerance: float = 0.01) -> Array:
		"""Compare multiple image pairs in batch"""
		results.clear()
		start_time = Time.get_ticks_usec() / 1000000.0

		for pair in image_pairs:
			if pair.size() >= 2:
				var image1 = pair[0]
				var image2 = pair[1]
				var region = pair[2] if pair.size() > 2 else Rect2()

				var result = AdvancedComparators.compare_with_caching(image1, image2, algorithm, tolerance, region)
				results.append(result)

		end_time = Time.get_ticks_usec() / 1000000.0

		return results.duplicate()

	func compare_baseline_batch(baseline_image: Image, test_images: Array, algorithm: int = 0, tolerance: float = 0.01) -> Array:
		"""Compare multiple test images against single baseline"""
		var image_pairs = []
		for test_image in test_images:
			image_pairs.append([baseline_image, test_image])

		return compare_images_batch(image_pairs, algorithm, tolerance)

	func get_successful_comparisons() -> Array:
		"""Get results for successful comparisons"""
		return results.filter(func(r): return r.success)

	func get_failed_comparisons() -> Array:
		"""Get results for failed comparisons"""
		return results.filter(func(r): return not r.success)

	func get_statistics() -> Dictionary:
		"""Get batch comparison statistics"""
		var successful = get_successful_comparisons().size()
		var total = results.size()

		return {
			"total_comparisons": total,
			"successful_comparisons": successful,
			"failed_comparisons": total - successful,
			"success_rate": successful / float(total) * 100.0 if total > 0 else 0.0,
			"execution_time": end_time - start_time,
			"avg_comparison_time": (end_time - start_time) / float(total) if total > 0 else 0.0
		}

# ------------------------------------------------------------------------------
# VISUALIZATION UTILITIES
# ------------------------------------------------------------------------------
class DifferenceVisualizer:
	static func create_heat_map(difference_map: Array, width: int, height: int) -> Image:
		"""Create a heat map visualization of differences"""
		var heat_map = Image.create(width, height, false, Image.FORMAT_RGBA8)
		heat_map.lock()

		var max_diff = 0.0
		for row in difference_map:
			for diff in row:
				max_diff = max(max_diff, diff)

		for y in range(height):
			for x in range(width):
				var diff_value = difference_map[y][x] if y < difference_map.size() and x < difference_map[y].size() else 0.0
				var intensity = diff_value / max_diff if max_diff > 0 else 0.0

				# Heat map colors: blue (low) -> red (high)
				var color = Color(intensity, 0.0, 1.0 - intensity, 1.0)
				heat_map.set_pixel(x, y, color)

		heat_map.unlock()
		return heat_map

	static func create_overlay_visualization(image1: Image, image2: Image, difference_map: Array) -> Image:
		"""Create overlay visualization showing differences"""
		var overlay = Image.create(image1.get_width(), image1.get_height(), false, Image.FORMAT_RGBA8)

		image1.lock()
		image2.lock()
		overlay.lock()

		for y in range(image1.get_height()):
			for x in range(image1.get_width()):
				var color1 = image1.get_pixel(x, y)
				var _color2 = image2.get_pixel(x, y)
				var diff_value = difference_map[y][x] if y < difference_map.size() and x < difference_map[y].size() else 0.0

				var final_color = color1
				if diff_value > 0.1:  # Significant difference
					# Blend with red highlight
					final_color = color1.lerp(Color(1, 0, 0, 0.7), 0.3)

				overlay.set_pixel(x, y, final_color)

		image1.unlock()
		image2.unlock()
		overlay.unlock()

		return overlay

	static func create_side_by_side_comparison(image1: Image, image2: Image, difference_image: Image = null) -> Image:
		"""Create side-by-side comparison image"""
		var total_width = image1.get_width() + image2.get_width()
		var max_height = max(image1.get_height(), image2.get_height())

		if difference_image:
			total_width += difference_image.get_width()
			max_height = max(max_height, difference_image.get_height())

		var comparison = Image.create(total_width, max_height, false, Image.FORMAT_RGBA8)
		comparison.lock()

		# Copy first image
		image1.lock()
		for y in range(image1.get_height()):
			for x in range(image1.get_width()):
				comparison.set_pixel(x, y, image1.get_pixel(x, y))
		image1.unlock()

		# Copy second image
		image2.lock()
		for y in range(image2.get_height()):
			for x in range(image2.get_width()):
				comparison.set_pixel(x + image1.get_width(), y, image2.get_pixel(x, y))
		image2.unlock()

		# Copy difference image if provided
		if difference_image:
			difference_image.lock()
			for y in range(difference_image.get_height()):
				for x in range(difference_image.get_width()):
					comparison.set_pixel(x + image1.get_width() + image2.get_width(), y, difference_image.get_pixel(x, y))
			difference_image.unlock()

		comparison.unlock()
		return comparison

# ------------------------------------------------------------------------------
# PERFORMANCE MONITORING
# ------------------------------------------------------------------------------
class PerformanceMonitor:
	var comparison_times: Array = []
	var memory_usage: Array = []
	var start_time: float = 0.0

	func start_monitoring() -> void:
		"""Start performance monitoring"""
		comparison_times.clear()
		memory_usage.clear()
		start_time = Time.get_ticks_usec() / 1000000.0

	func record_comparison_time(execution_time: float) -> void:
		"""Record comparison execution time"""
		comparison_times.append(execution_time)

	func record_memory_usage() -> void:
		"""Record current memory usage"""
		var mem_info = {
			"static": Performance.get_monitor(Performance.MEMORY_STATIC),
			"dynamic": 0,  # Dynamic memory monitoring not available in Godot 4
			"static_max": Performance.get_monitor(Performance.MEMORY_STATIC_MAX),
			"dynamic_max": 0  # Dynamic memory max not available in Godot 4
		}
		memory_usage.append(mem_info)

	func get_performance_report() -> Dictionary:
		"""Generate performance report"""
		var total_comparisons = comparison_times.size()
		var avg_time = 0.0
		var min_time = INF
		var max_time = 0.0

		for time in comparison_times:
			avg_time += time
			min_time = min(min_time, time)
			max_time = max(max_time, time)

		avg_time /= float(total_comparisons) if total_comparisons > 0 else 1.0

		var end_time = Time.get_ticks_usec() / 1000000.0
		var total_duration = end_time - start_time

		return {
			"total_comparisons": total_comparisons,
			"total_duration": total_duration,
			"comparisons_per_second": total_comparisons / total_duration if total_duration > 0 else 0.0,
			"avg_comparison_time": avg_time,
			"min_comparison_time": min_time,
			"max_comparison_time": max_time,
			"memory_samples": memory_usage.size(),
			"peak_memory_usage": _get_peak_memory_usage()
		}

	func _get_peak_memory_usage() -> Dictionary:
		"""Get peak memory usage statistics"""
		var peak_static = 0
		var peak_dynamic = 0

		for mem_sample in memory_usage:
			peak_static = max(peak_static, mem_sample.static)
			peak_dynamic = max(peak_dynamic, mem_sample.dynamic)

		return {
			"static": peak_static,
			"dynamic": peak_dynamic
		}

# ------------------------------------------------------------------------------
# INTEGRATION UTILITIES
# ------------------------------------------------------------------------------
func create_batch_comparator() -> BatchComparator:
	"""Create a new batch comparator instance"""
	return BatchComparator.new()

func create_performance_monitor() -> PerformanceMonitor:
	"""Create a new performance monitor instance"""
	return PerformanceMonitor.new()

func compare_images_advanced(image1: Image, image2: Image, algorithm: int = 0, tolerance: float = 0.01, region: Rect2 = Rect2()) -> Dictionary:
	"""Convenience function for advanced image comparison"""
	return AdvancedComparators.compare_with_caching(image1, image2, algorithm, tolerance, region)

func process_image_for_comparison(image: Image, normalize: bool = true, enhance_contrast: bool = false) -> Image:
	"""Process image for optimal comparison"""
	var processed = image

	if normalize:
		processed = ImageProcessor.normalize_image(processed)

	if enhance_contrast:
		processed = ImageProcessor.enhance_contrast(processed, 1.2)

	return processed

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	AdvancedComparators.cache.clear()
