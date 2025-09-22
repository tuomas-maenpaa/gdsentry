# GDSentry - Video Recording Testing System
# Automated video capture and analysis for gameplay testing and validation
#
# Features:
# - Frame-by-frame video recording
# - Automated behavior verification
# - Visual sequence analysis
# - Performance monitoring during recording
# - Video compression and optimization
# - Frame analysis and validation
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name VideoRecorder

# ------------------------------------------------------------------------------
# VIDEO RECORDING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_FRAME_RATE = 30
const DEFAULT_QUALITY = 0.8
const DEFAULT_MAX_DURATION = 300.0  # 5 minutes
const DEFAULT_BUFFER_SIZE = 1024 * 1024 * 50  # 50MB buffer

# ------------------------------------------------------------------------------
# VIDEO RECORDING STATE
# ------------------------------------------------------------------------------
var recording_active: bool = false
var recording_start_time: float = 0.0
var frame_rate: int = DEFAULT_FRAME_RATE
var quality: float = DEFAULT_QUALITY
var max_duration: float = DEFAULT_MAX_DURATION
var current_frame: int = 0
var recorded_frames: Array = []
var recording_metadata: Dictionary = {}

# ------------------------------------------------------------------------------
# VIDEO ANALYSIS STATE
# ------------------------------------------------------------------------------
var enable_frame_analysis: bool = true
var frame_analysis_results: Array = []
var behavior_patterns: Dictionary = {}
var performance_during_recording: Array = []

# ------------------------------------------------------------------------------
# OUTPUT CONFIGURATION
# ------------------------------------------------------------------------------
var output_directory: String = "res://video_recordings/"
var output_format: String = "png_sequence"  # Options: png_sequence, webm, mp4
var compression_enabled: bool = true
var include_audio: bool = false

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize video recording system"""
	setup_recording_directories()

func _process(_delta: float) -> void:
	"""Handle frame recording during active recording"""
	if recording_active:
		record_frame()

# ------------------------------------------------------------------------------
# DIRECTORY MANAGEMENT
# ------------------------------------------------------------------------------
func setup_recording_directories() -> void:
	"""Create necessary directories for video recording"""
	var dirs = [
		"res://video_recordings/",
		"res://video_analysis/",
		"res://video_metadata/"
	]

	for dir_path in dirs:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create video recording directory: " + dir_path)

# ------------------------------------------------------------------------------
# VIDEO RECORDING CONTROL
# ------------------------------------------------------------------------------
func start_recording(test_name: String = "", resolution: Vector2 = Vector2.ZERO, fps: int = -1) -> bool:
	"""Start video recording"""
	if recording_active:
		push_warning("Video recording already active")
		return false

	# Set recording parameters
	if fps > 0:
		frame_rate = fps

	if resolution == Vector2.ZERO:
		resolution = get_viewport().size

	# Initialize recording state
	recording_active = true
	recording_start_time = Time.get_ticks_msec() / 1000.0
	current_frame = 0
	recorded_frames.clear()
	frame_analysis_results.clear()
	performance_during_recording.clear()

	# Set up metadata
	recording_metadata = {
		"test_name": test_name if not test_name.is_empty() else "recording_" + str(Time.get_unix_time_from_system()),
		"start_time": recording_start_time,
		"resolution": resolution,
		"frame_rate": frame_rate,
		"quality": quality,
		"godot_version": Engine.get_version_info().string,
		"platform": OS.get_name(),
		"frames": []
	}

	# Take initial frame
	record_frame()

	if OS.is_debug_build():
		print("🎬 Started video recording: ", recording_metadata.test_name)

	return true

func stop_recording() -> bool:
	"""Stop video recording and save results"""
	if not recording_active:
		push_warning("No active video recording to stop")
		return false

	recording_active = false

	# Finalize metadata
	recording_metadata["end_time"] = Time.get_ticks_msec() / 1000.0
	recording_metadata["duration"] = recording_metadata.end_time - recording_metadata.start_time
	recording_metadata["total_frames"] = recorded_frames.size()

	# Perform final analysis
	analyze_recorded_video()

	# Save recording
	var success = save_recording()

	if OS.is_debug_build():
		print("🎬 Stopped video recording: ", recording_metadata.test_name)
		print("   Duration: %.2fs, Frames: %d" % [recording_metadata.duration, recording_metadata.total_frames])

	return success

func record_frame() -> void:
	"""Record a single frame"""
	if not recording_active:
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var expected_frame_time = recording_start_time + (current_frame / float(frame_rate))

	# Skip frames if we're behind schedule (to maintain target FPS)
	if current_time < expected_frame_time:
		return

	# Capture screenshot
	var viewport = get_viewport()
	if not viewport:
		return

	var image = viewport.get_texture().get_image()
	if not image:
		return

	# Store frame data
	var frame_data = {
		"frame_number": current_frame,
		"timestamp": current_time - recording_start_time,
		"image": image,
		"performance": {
			"fps": Performance.get_monitor(Performance.TIME_FPS),
			"memory": Performance.get_monitor(Performance.MEMORY_STATIC),
			"objects": Performance.get_monitor(Performance.OBJECT_COUNT)
		}
	}

	recorded_frames.append(frame_data)
	performance_during_recording.append(frame_data.performance)

	# Perform real-time frame analysis if enabled
	if enable_frame_analysis:
		analyze_frame(frame_data)

	recording_metadata.frames.append({
		"number": current_frame,
		"timestamp": frame_data.timestamp,
		"has_analysis": enable_frame_analysis
	})

	current_frame += 1

	# Check duration limit
	if current_time - recording_start_time >= max_duration:
		stop_recording()

# ------------------------------------------------------------------------------
# FRAME ANALYSIS
# ------------------------------------------------------------------------------
func analyze_frame(frame_data: Dictionary) -> Dictionary:
	"""Analyze a single frame for visual changes and patterns"""
	var analysis = {
		"frame_number": frame_data.frame_number,
		"brightness": calculate_frame_brightness(frame_data.image),
		"contrast": calculate_frame_contrast(frame_data.image),
		"dominant_colors": extract_dominant_colors(frame_data.image, 5),
		"motion_level": 0.0,
		"ui_elements_detected": detect_ui_elements(frame_data.image),
		"changes_from_previous": {}
	}

	# Calculate motion level (difference from previous frame)
	if recorded_frames.size() > 1:
		var prev_frame = recorded_frames[recorded_frames.size() - 2]
		analysis.motion_level = calculate_frame_difference(frame_data.image, prev_frame.image)
		analysis.changes_from_previous = detect_visual_changes(frame_data.image, prev_frame.image)

	frame_analysis_results.append(analysis)
	return analysis

func calculate_frame_brightness(image: Image) -> float:
	"""Calculate average brightness of a frame"""
	image.lock()

	var total_brightness = 0.0
	var pixel_count = image.get_width() * image.get_height()

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color = image.get_pixel(x, y)
			total_brightness += color.get_luminance()

	image.unlock()

	return total_brightness / pixel_count

func calculate_frame_contrast(image: Image) -> float:
	"""Calculate contrast of a frame using standard deviation of luminance"""
	image.lock()

	var luminances = []
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color = image.get_pixel(x, y)
			luminances.append(color.get_luminance())

	# Calculate mean
	var mean = 0.0
	for lum in luminances:
		mean += lum
	mean /= luminances.size()

	# Calculate standard deviation
	var variance = 0.0
	for lum in luminances:
		variance += pow(lum - mean, 2)
	variance /= luminances.size()

	image.unlock()

	return sqrt(variance)

func extract_dominant_colors(image: Image, count: int) -> Array:
	"""Extract dominant colors from a frame using color quantization"""
	image.lock()

	var color_counts = {}
	var total_pixels = image.get_width() * image.get_height()

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color = image.get_pixel(x, y)
			var color_key = "%d,%d,%d" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]

			if color_counts.has(color_key):
				color_counts[color_key] += 1
			else:
				color_counts[color_key] = 1

	image.unlock()

	# Sort by frequency and return top colors
	var sorted_colors = []
	for color_key in color_counts.keys():
		sorted_colors.append({
			"color": color_key,
			"count": color_counts[color_key],
			"percentage": float(color_counts[color_key]) / float(total_pixels)
		})

	sorted_colors.sort_custom(func(a, b): return a.count > b.count)

	var result = []
	for i in range(min(count, sorted_colors.size())):
		var color_data = sorted_colors[i]
		var rgb = color_data.color.split(",")
		result.append(Color(
			int(rgb[0]) / 255.0,
			int(rgb[1]) / 255.0,
			int(rgb[2]) / 255.0,
			color_data.percentage
		))

	return result

func calculate_frame_difference(image1: Image, image2: Image) -> float:
	"""Calculate the difference between two frames"""
	if image1.get_size() != image2.get_size():
		return 1.0  # Maximum difference

	image1.lock()
	image2.lock()

	var total_difference = 0.0
	var pixel_count = image1.get_width() * image1.get_height()

	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)
			total_difference += color1.distance_to(color2)

	image1.unlock()
	image2.unlock()

	return total_difference / pixel_count

func detect_visual_changes(image1: Image, image2: Image) -> Dictionary:
	"""Detect specific types of visual changes between frames"""
	var changes = {
		"motion_detected": false,
		"ui_changes": false,
		"color_shifts": false,
		"structural_changes": false,
		"significant_regions": []
	}

	var difference_threshold = 0.1
	var motion_threshold = 0.05

	# Simple motion detection
	var avg_difference = calculate_frame_difference(image1, image2)
	changes.motion_detected = avg_difference > motion_threshold

	# Detect significant changes in regions (simplified)
	var region_size = 64
	image1.lock()
	image2.lock()

	for y in range(0, image1.get_height(), region_size):
		for x in range(0, image1.get_width(), region_size):
			var region_diff = calculate_region_difference(image1, image2, x, y, region_size)
			if region_diff > difference_threshold:
				changes.significant_regions.append({
					"x": x,
					"y": y,
					"difference": region_diff
				})

	image1.unlock()
	image2.unlock()

	return changes

func calculate_region_difference(image1: Image, image2: Image, start_x: int, start_y: int, size: int) -> float:
	"""Calculate difference in a specific region"""
	var end_x = min(start_x + size, image1.get_width())
	var end_y = min(start_y + size, image1.get_height())

	var total_difference = 0.0
	var pixel_count = 0

	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			var color1 = image1.get_pixel(x, y)
			var color2 = image2.get_pixel(x, y)
			total_difference += color1.distance_to(color2)
			pixel_count += 1

	return total_difference / pixel_count if pixel_count > 0 else 0.0

func detect_ui_elements(image: Image) -> Array:
	"""Detect potential UI elements in the frame (simplified)"""
	var elements = []

	# This is a very basic implementation
	# In a real system, you'd use computer vision techniques
	image.lock()

	# Look for high-contrast rectangular regions (potential buttons/text)
	for y in range(0, image.get_height() - 50, 50):
		for x in range(0, image.get_width() - 100, 100):
			if detect_high_contrast_region(image, x, y, 100, 50):
				elements.append({
					"type": "potential_button",
					"x": x,
					"y": y,
					"width": 100,
					"height": 50
				})

	image.unlock()

	return elements

func detect_high_contrast_region(image: Image, x: int, y: int, width: int, height: int) -> bool:
	"""Detect if a region has high contrast (potential UI element)"""
	var min_lum = 1.0
	var max_lum = 0.0

	for py in range(y, min(y + height, image.get_height())):
		for px in range(x, min(x + width, image.get_width())):
			var lum = image.get_pixel(px, py).get_luminance()
			min_lum = min(min_lum, lum)
			max_lum = max(max_lum, lum)

	return (max_lum - min_lum) > 0.5  # High contrast threshold

# ------------------------------------------------------------------------------
# VIDEO ANALYSIS
# ------------------------------------------------------------------------------
func analyze_recorded_video() -> Dictionary:
	"""Analyze the complete recorded video"""
	if recorded_frames.is_empty():
		return {}

	var analysis = {
		"duration": recording_metadata.duration,
		"frame_count": recorded_frames.size(),
		"average_fps": 0.0,
		"motion_analysis": analyze_motion_patterns(),
		"performance_analysis": analyze_performance_during_recording(),
		"behavior_patterns": detect_behavior_patterns(),
		"visual_consistency": analyze_visual_consistency()
	}

	# Calculate average FPS
	var total_fps = 0.0
	for frame in recorded_frames:
		total_fps += frame.performance.fps
	analysis.average_fps = total_fps / recorded_frames.size()

	return analysis

func analyze_motion_patterns() -> Dictionary:
	"""Analyze motion patterns throughout the recording"""
	var motion_levels = []
	for analysis in frame_analysis_results:
		motion_levels.append(analysis.motion_level)

	var avg_motion = 0.0
	for motion in motion_levels:
		avg_motion += motion
	avg_motion /= motion_levels.size()

	return {
		"average_motion": avg_motion,
		"peak_motion": motion_levels.max(),
		"motion_variance": calculate_variance(motion_levels),
		"motion_stability": 1.0 / (1.0 + calculate_variance(motion_levels))
	}

func analyze_performance_during_recording() -> Dictionary:
	"""Analyze performance metrics during recording"""
	var fps_values = []
	var memory_values = []
	var object_counts = []

	for perf in performance_during_recording:
		fps_values.append(perf.fps)
		memory_values.append(perf.memory)
		object_counts.append(perf.objects)

	return {
		"fps_average": calculate_average(fps_values),
		"fps_min": fps_values.min(),
		"fps_max": fps_values.max(),
		"memory_average": calculate_average(memory_values),
		"memory_peak": memory_values.max(),
		"objects_average": calculate_average(object_counts)
	}

func detect_behavior_patterns() -> Dictionary:
	"""Detect behavioral patterns in the video"""
	var patterns = {
		"static_frames": 0,
		"high_motion_frames": 0,
		"ui_interaction_frames": 0,
		"loading_frames": 0
	}

	var motion_threshold = 0.1
	var static_threshold = 0.01

	for analysis in frame_analysis_results:
		if analysis.motion_level < static_threshold:
			patterns.static_frames += 1
		elif analysis.motion_level > motion_threshold:
			patterns.high_motion_frames += 1

		if not analysis.ui_elements_detected.is_empty():
			patterns.ui_interaction_frames += 1

	return patterns

func analyze_visual_consistency() -> Dictionary:
	"""Analyze visual consistency throughout the recording"""
	var brightness_values = []
	var contrast_values = []

	for analysis in frame_analysis_results:
		brightness_values.append(analysis.brightness)
		contrast_values.append(analysis.contrast)

	return {
		"brightness_stability": 1.0 / (1.0 + calculate_variance(brightness_values)),
		"contrast_stability": 1.0 / (1.0 + calculate_variance(contrast_values)),
		"brightness_range": brightness_values.max() - brightness_values.min(),
		"contrast_range": contrast_values.max() - contrast_values.min()
	}

# ------------------------------------------------------------------------------
# SAVE AND EXPORT
# ------------------------------------------------------------------------------
func save_recording() -> bool:
	"""Save the recorded video in the specified format"""
	var success = false

	match output_format:
		"png_sequence":
			success = save_as_png_sequence()
		"webm":
			success = save_as_webm()
		"mp4":
			success = save_as_mp4()
		_:
			push_error("Unsupported output format: " + output_format)
			return false

	# Save metadata
	if success:
		success = save_recording_metadata()

	# Save analysis results
	if success and enable_frame_analysis:
		success = save_analysis_results()

	return success

func save_as_png_sequence() -> bool:
	"""Save recording as a sequence of PNG images"""
	var base_path = output_directory + recording_metadata.test_name + "/"
	var global_base_path = ProjectSettings.globalize_path(base_path)

	if not DirAccess.dir_exists_absolute(global_base_path):
		var error = DirAccess.make_dir_recursive_absolute(global_base_path)
		if error != OK:
			return false

	for i in range(recorded_frames.size()):
		var frame = recorded_frames[i]
		var filename = "frame_%04d.png" % i
		var file_path = base_path + filename
		var global_path = ProjectSettings.globalize_path(file_path)

		if compression_enabled:
			frame.image.save_png(global_path)
		else:
			# Save uncompressed
			var file = FileAccess.open(global_path, FileAccess.WRITE)
			if file:
				var png_data = frame.image.save_png_to_buffer()
				file.store_buffer(png_data)
				file.close()

	return true

func save_as_webm() -> bool:
	"""Save recording as WebM video (placeholder - would require external library)"""
	push_warning("WebM export not implemented in this version")
	return false

func save_as_mp4() -> bool:
	"""Save recording as MP4 video (placeholder - would require external library)"""
	push_warning("MP4 export not implemented in this version")
	return false

func save_recording_metadata() -> bool:
	"""Save recording metadata to JSON file"""
	var metadata_path = "res://video_metadata/" + recording_metadata.test_name + ".json"
	var global_path = ProjectSettings.globalize_path(metadata_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(recording_metadata, "\t"))
		file.close()
		return true

	return false

func save_analysis_results() -> bool:
	"""Save frame analysis results"""
	var analysis_path = "res://video_analysis/" + recording_metadata.test_name + "_analysis.json"
	var global_path = ProjectSettings.globalize_path(analysis_path)

	var analysis_data = {
		"metadata": recording_metadata,
		"frame_analysis": frame_analysis_results,
		"video_analysis": analyze_recorded_video(),
		"performance_data": performance_during_recording
	}

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(analysis_data, "\t"))
		file.close()
		return true

	return false

# ------------------------------------------------------------------------------
# VIDEO ASSERTIONS
# ------------------------------------------------------------------------------
func assert_video_duration(expected_duration: float, tolerance: float = 1.0, message: String = "") -> bool:
	"""Assert that the recorded video has the expected duration"""
	if not recording_metadata.has("duration"):
		var error_msg = message if not message.is_empty() else "No recording duration available"
		print("❌ " + error_msg)
		return false

	var actual_duration = recording_metadata.duration
	var diff = abs(actual_duration - expected_duration)

	if diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Video duration mismatch: expected %.2f s, got %.2f s (diff: %.2f s)" % [expected_duration, actual_duration, diff]
	print("❌ " + final_error_msg)
	return false

func assert_motion_detected(min_motion_level: float = 0.1, message: String = "") -> bool:
	"""Assert that motion was detected in the video"""
	var analysis = analyze_recorded_video()
	if analysis.is_empty():
		var error_msg = message if not message.is_empty() else "No video analysis available"
		print("❌ " + error_msg)
		return false

	var motion_analysis = analysis.get("motion_analysis", {})
	var avg_motion = motion_analysis.get("average_motion", 0.0)

	if avg_motion >= min_motion_level:
		return true

	var final_error_msg = message if not message.is_empty() else "Insufficient motion detected: %.4f (minimum required: %.4f)" % [avg_motion, min_motion_level]
	print("❌ " + final_error_msg)
	return false

func assert_visual_consistency(min_stability: float = 0.8, message: String = "") -> bool:
	"""Assert that the video maintains visual consistency"""
	var analysis = analyze_recorded_video()
	if analysis.is_empty():
		var error_msg = message if not message.is_empty() else "No video analysis available"
		print("❌ " + error_msg)
		return false

	var consistency = analysis.get("visual_consistency", {})
	var brightness_stability = consistency.get("brightness_stability", 0.0)
	var contrast_stability = consistency.get("contrast_stability", 0.0)
	var avg_stability = (brightness_stability + contrast_stability) / 2.0

	if avg_stability >= min_stability:
		return true

	var final_error_msg = message if not message.is_empty() else "Visual consistency too low: %.2f (minimum required: %.2f)" % [avg_stability, min_stability]
	print("❌ " + final_error_msg)
	return false

func assert_performance_stable(max_fps_variance: float = 5.0, message: String = "") -> bool:
	"""Assert that performance remained stable during recording"""
	var analysis = analyze_recorded_video()
	if analysis.is_empty():
		var error_msg = message if not message.is_empty() else "No video analysis available"
		print("❌ " + error_msg)
		return false

	var perf_analysis = analysis.get("performance_analysis", {})
	var fps_variance = perf_analysis.get("fps_max", 0.0) - perf_analysis.get("fps_min", 0.0)

	if fps_variance <= max_fps_variance:
		return true

	var final_error_msg = message if not message.is_empty() else "Performance unstable: FPS variance %.1f (maximum allowed: %.1f)" % [fps_variance, max_fps_variance]
	print("❌ " + final_error_msg)
	return false

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func calculate_average(values: Array) -> float:
	"""Calculate average of array values"""
	if values.is_empty():
		return 0.0

	var sum = 0.0
	for value in values:
		sum += value

	return sum / values.size()

func calculate_variance(values: Array) -> float:
	"""Calculate variance of array values"""
	if values.size() < 2:
		return 0.0

	var mean = calculate_average(values)
	var variance = 0.0

	for value in values:
		variance += pow(value - mean, 2)

	return variance / (values.size() - 1)

func set_recording_parameters(fps: int = -1, quality_val: float = -1.0, duration: float = -1.0) -> void:
	"""Set recording parameters"""
	if fps > 0:
		frame_rate = fps
	if quality_val >= 0:
		quality = quality_val
	if duration > 0:
		max_duration = duration

func set_output_format(format: String) -> void:
	"""Set output format for saved recordings"""
	var valid_formats = ["png_sequence", "webm", "mp4"]
	if valid_formats.has(format):
		output_format = format
	else:
		push_warning("Invalid output format: " + format)

func enable_compression(enabled: bool = true) -> void:
	"""Enable or disable video compression"""
	compression_enabled = enabled

func enable_audio_recording(enabled: bool = true) -> void:
	"""Enable or disable audio recording (placeholder)"""
	include_audio = enabled
	if enabled:
		push_warning("Audio recording not implemented in this version")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup video recording resources"""
	if recording_active:
		stop_recording()

	recorded_frames.clear()
	frame_analysis_results.clear()
	performance_during_recording.clear()
	recording_metadata.clear()
