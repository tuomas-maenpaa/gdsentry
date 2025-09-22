# GDSentry - Video Recorder Advanced Tests
# Comprehensive testing of video recording and analysis features
#
# Tests video recording including:
# - Frame-by-frame video recording
# - Automated behavior verification
# - Visual sequence analysis
# - Performance monitoring during recording
# - Video compression and optimization
# - Frame analysis and validation
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name VideoRecorderTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready():
	test_description = "Advanced video recording testing validation"
	test_tags = ["advanced", "video", "recording", "behavior_analysis"]
	test_priority = "high"
	test_category = "advanced"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all video recorder advanced tests"""
	print("\n🎥 Running Video Recorder Test Suite\n")

	run_test("test_video_recorder_initialization", func(): return test_video_recorder_initialization())
	run_test("test_recording_session_management", func(): return test_recording_session_management())
	run_test("test_frame_capture_and_storage", func(): return test_frame_capture_and_storage())
	run_test("test_video_compression_optimization", func(): return test_video_compression_optimization())
	run_test("test_behavior_pattern_analysis", func(): return test_behavior_pattern_analysis())
	run_test("test_performance_monitoring", func(): return test_performance_monitoring())
	run_test("test_frame_analysis_validation", func(): return test_frame_analysis_validation())
	run_test("test_video_recording_reporting", func(): return test_video_recording_reporting())

	print("\n🎥 Video Recorder Test Suite Complete\n")

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_video_recorder_initialization() -> bool:
	"""Test VideoRecorder initialization and basic properties"""
	var recorder = VideoRecorder.new()

	var success = assert_not_null(recorder, "VideoRecorder should instantiate successfully")
	success = success and assert_type(recorder, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(recorder.get_class(), "VideoRecorder", "Should be VideoRecorder class")

	# Test default configuration
	success = success and assert_equals(recorder.frame_rate, 30, "Default frame rate should be 30")
	success = success and assert_equals(recorder.quality, 0.8, "Default quality should be 0.8")
	success = success and assert_equals(recorder.max_duration, 300.0, "Default max duration should be 300 seconds")

	recorder.queue_free()
	return success

func test_recording_session_management() -> bool:
	"""Test recording session management functionality"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test recording start
	var start_success = recorder.start_recording_session("test_session", 10.0)
	success = success and assert_type(start_success, TYPE_BOOL, "Recording start should return boolean")
	if start_success:
		success = success and assert_true(recorder.recording_active, "Recording should be active after start")

	# Test recording status
	var is_recording = recorder.is_recording()
	success = success and assert_type(is_recording, TYPE_BOOL, "Recording status should return boolean")

	# Test recording stop
	var stop_success = recorder.stop_recording_session()
	success = success and assert_type(stop_success, TYPE_BOOL, "Recording stop should return boolean")
	if stop_success:
		success = success and assert_false(recorder.recording_active, "Recording should be inactive after stop")

	recorder.queue_free()
	return success

func test_frame_capture_and_storage() -> bool:
	"""Test frame capture and storage capabilities"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test frame capture
	var captured_frame = recorder.capture_current_frame()
	success = success and assert_type(captured_frame, TYPE_DICTIONARY, "Captured frame should be dictionary")

	# Test frame storage
	var frame_data = {
		"frame_number": 1,
		"timestamp": 1.5,
		"image_data": null,
		"metadata": {}
	}

	var stored = recorder.store_captured_frame(frame_data)
	success = success and assert_type(stored, TYPE_BOOL, "Frame storage should return boolean")

	# Test frame retrieval
	var frames = recorder.get_recorded_frames()
	success = success and assert_type(frames, TYPE_ARRAY, "Recorded frames should be array")

	# Test frame count
	var frame_count = recorder.get_frame_count()
	success = success and assert_type(frame_count, TYPE_INT, "Frame count should be integer")

	recorder.queue_free()
	return success

func test_video_compression_optimization() -> bool:
	"""Test video compression and optimization features"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test compression settings
	recorder.quality = 0.5
	success = success and assert_equals(recorder.quality, 0.5, "Quality setting should be applied")

	recorder.quality = 0.9
	success = success and assert_equals(recorder.quality, 0.9, "High quality setting should be applied")

	# Test compression algorithm selection
	var compression_types = ["lossless", "lossy", "auto"]
	for compression_type in compression_types:
		var set_compression = recorder.set_compression_type(compression_type)
		success = success and assert_type(set_compression, TYPE_BOOL, "Compression type setting should work")

	# Test file size optimization
	var optimized_size = recorder.optimize_video_size(1024 * 1024 * 100)  # 100MB
	success = success and assert_type(optimized_size, TYPE_INT, "Size optimization should return integer")

	recorder.queue_free()
	return success

func test_behavior_pattern_analysis() -> bool:
	"""Test behavior pattern analysis capabilities"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test pattern detection setup
	var pattern_setup = recorder.setup_behavior_pattern_detection()
	success = success and assert_type(pattern_setup, TYPE_BOOL, "Pattern detection setup should return boolean")

	# Test behavior pattern recording
	var test_pattern = {
		"pattern_type": "movement",
		"start_frame": 10,
		"end_frame": 50,
		"description": "Object movement pattern"
	}

	var pattern_recorded = recorder.record_behavior_pattern(test_pattern)
	success = success and assert_type(pattern_recorded, TYPE_BOOL, "Pattern recording should return boolean")

	# Test pattern analysis
	var patterns = recorder.analyze_behavior_patterns()
	success = success and assert_type(patterns, TYPE_DICTIONARY, "Pattern analysis should return dictionary")

	# Test pattern matching
	var similar_pattern = recorder.find_similar_patterns(test_pattern)
	success = success and assert_type(similar_pattern, TYPE_ARRAY, "Pattern matching should return array")

	recorder.queue_free()
	return success

func test_performance_monitoring() -> bool:
	"""Test performance monitoring during recording"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test performance tracking setup
	var perf_setup = recorder.setup_performance_monitoring()
	success = success and assert_type(perf_setup, TYPE_BOOL, "Performance monitoring setup should return boolean")

	# Test FPS monitoring
	var current_fps = recorder.get_current_recording_fps()
	success = success and assert_type(current_fps, TYPE_FLOAT, "FPS monitoring should return float")

	# Test memory usage during recording
	var memory_usage = recorder.get_recording_memory_usage()
	success = success and assert_type(memory_usage, TYPE_INT, "Memory usage should return integer")

	# Test performance metrics collection
	var metrics = recorder.collect_performance_metrics()
	success = success and assert_type(metrics, TYPE_DICTIONARY, "Performance metrics should be dictionary")

	# Test performance threshold checking
	var within_limits = recorder.check_performance_limits()
	success = success and assert_type(within_limits, TYPE_BOOL, "Performance limit check should return boolean")

	recorder.queue_free()
	return success

func test_frame_analysis_validation() -> bool:
	"""Test frame analysis and validation features"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test frame analysis setup (enable_frame_analysis is a property)
	recorder.enable_frame_analysis = true
	success = success and assert_true(recorder.enable_frame_analysis, "Frame analysis should be enabled")

	# Test individual frame analysis
	var mock_frame_data = {
		"frame_number": 1,
		"timestamp": 1.5,
		"image_data": null,
		"metadata": {"test": "mock_data"}
	}

	var frame_analysis = recorder.analyze_frame(mock_frame_data)
	success = success and assert_type(frame_analysis, TYPE_DICTIONARY, "Frame analysis should return dictionary")

	# Test frame validation (using the frame data)
	var frame_valid = recorder.validate_frame_quality(mock_frame_data)
	success = success and assert_type(frame_valid, TYPE_BOOL, "Frame validation should return boolean")

	# Test frame sequence analysis
	var frame_sequence = [mock_frame_data, mock_frame_data, mock_frame_data]
	var sequence_analysis = recorder.analyze_frame_sequence(frame_sequence)
	success = success and assert_type(sequence_analysis, TYPE_DICTIONARY, "Sequence analysis should return dictionary")

	recorder.queue_free()
	return success

func test_video_recording_reporting() -> bool:
	"""Test video recording reporting functionality"""
	var recorder = VideoRecorder.new()

	var success = true

	# Test recording session metadata
	var session_metadata = {
		"session_name": "test_session",
		"duration": 15.5,
		"total_frames": 465,
		"average_fps": 30.0
	}

	recorder.recording_metadata = session_metadata

	# Test report generation
	var report = recorder.generate_recording_report()
	success = success and assert_not_null(report, "Should generate recording report")
	success = success and assert_type(report, TYPE_STRING, "Report should be string")
	success = success and assert_true(report.length() > 0, "Report should not be empty")

	# Test statistics generation
	var stats = recorder.generate_recording_statistics()
	success = success and assert_not_null(stats, "Should generate recording statistics")
	success = success and assert_type(stats, TYPE_DICTIONARY, "Statistics should be dictionary")

	# Test behavior summary
	var behavior_summary = recorder.generate_behavior_analysis_summary()
	success = success and assert_not_null(behavior_summary, "Should generate behavior summary")
	success = success and assert_type(behavior_summary, TYPE_DICTIONARY, "Behavior summary should be dictionary")

	recorder.queue_free()
	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_scene_for_recording() -> Node:
	"""Create a test scene suitable for video recording"""
	var scene = Node.new()

	# Add some visual elements
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(64, 64, false, Image.FORMAT_RGB8)
	image.fill(Color(0.5, 0.5, 0.5))
	texture.set_image(image)
	sprite.texture = texture
	sprite.position = Vector2(100, 100)

	var label = Label.new()
	label.text = "Test Recording"
	label.position = Vector2(100, 200)

	var button = Button.new()
	button.text = "Test Button"
	button.position = Vector2(100, 250)
	button.size = Vector2(120, 40)

	scene.add_child(sprite)
	scene.add_child(label)
	scene.add_child(button)

	return scene

func create_mock_frame_sequence(frame_count: int) -> Array:
	"""Create a sequence of mock frames for testing"""
	var frames = []

	for i in range(frame_count):
		var image = Image.create(100, 100, false, Image.FORMAT_RGB8)

		# Create slightly different colors for each frame to simulate motion
		var color_variation = float(i) / float(frame_count)
		var color = Color(color_variation * 0.5, 0.5, color_variation * 0.3)
		image.fill(color)

		frames.append(image)

	return frames

func simulate_recording_workflow(recorder: VideoRecorder, duration_seconds: float) -> Dictionary:
	"""Simulate a complete recording workflow"""
	var results = {
		"frames_captured": 0,
		"duration": 0.0,
		"average_fps": 0.0
	}

	# Start recording
	recorder.start_recording_session("simulation_test", duration_seconds)

	# Simulate frame capture over time
	var frame_interval = 1.0 / recorder.frame_rate
	var elapsed_time = 0.0

	while elapsed_time < duration_seconds:
		var frame_data = recorder.capture_current_frame()
		if frame_data:
			recorder.store_captured_frame(frame_data)
			results.frames_captured += 1

		elapsed_time += frame_interval

	# Stop recording
	recorder.stop_recording_session()

	results.duration = elapsed_time
	results.average_fps = results.frames_captured / elapsed_time

	return results

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
