# GDSentry - Memory Leak Detector Advanced Tests
# Comprehensive testing of memory leak detection and monitoring features
#
# Tests memory monitoring including:
# - Heap analysis and object tracking
# - Memory leak detection algorithms
# - Reference counting analysis
# - Garbage collection monitoring
# - Memory usage profiling
# - Automated leak detection
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name MemoryLeakDetectorTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready():
	test_description = "Advanced memory leak detection validation"
	test_tags = ["advanced", "memory", "leak_detection", "profiling"]
	test_priority = "high"
	test_category = "advanced"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all memory leak detector advanced tests"""
	run_test("test_memory_leak_detector_initialization", func(): return test_memory_leak_detector_initialization())
	run_test("test_memory_snapshot_creation", func(): return test_memory_snapshot_creation())
	run_test("test_object_tracking_system", func(): return test_object_tracking_system())
	run_test("test_reference_counting_analysis", func(): return test_reference_counting_analysis())
	run_test("test_leak_detection_algorithms", func(): return test_leak_detection_algorithms())
	run_test("test_memory_growth_monitoring", func(): return test_memory_growth_monitoring())
	run_test("test_garbage_collection_monitoring", func(): return test_garbage_collection_monitoring())
	run_test("test_memory_profiling_reports", func(): return test_memory_profiling_reports())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_memory_leak_detector_initialization() -> bool:
	"""Test MemoryLeakDetector initialization and basic properties"""
	var detector = MemoryLeakDetector.new()

	var success = assert_not_null(detector, "MemoryLeakDetector should instantiate successfully")
	success = success and assert_type(detector, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(detector.get_class(), "MemoryLeakDetector", "Should be MemoryLeakDetector class")

	# Test default configuration
	success = success and assert_equals(detector.leak_threshold, 1024 * 1024, "Default leak threshold should be 1MB")
	success = success and assert_equals(detector.growth_threshold, 0.1, "Default growth threshold should be 10%")
	success = success and assert_true(detector.enable_auto_detection, "Auto detection should be enabled by default")

	detector.queue_free()
	return success

func test_memory_snapshot_creation() -> bool:
	"""Test memory snapshot creation and management"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test snapshot creation
	var snapshot = detector.create_memory_snapshot()
	success = success and assert_not_null(snapshot, "Should create memory snapshot")
	success = success and assert_type(snapshot, TYPE_DICTIONARY, "Snapshot should be dictionary")

	# Test snapshot contains expected data
	if snapshot:
		success = success and assert_true(snapshot.has("timestamp"), "Snapshot should have timestamp")
		success = success and assert_true(snapshot.has("total_memory"), "Snapshot should have total memory")
		success = success and assert_true(snapshot.has("object_count"), "Snapshot should have object count")

	# Test snapshot storage
	var initial_count = detector.memory_snapshots.size()
	detector.store_memory_snapshot(snapshot)
	var final_count = detector.memory_snapshots.size()
	success = success and assert_equals(final_count, initial_count + 1, "Should store snapshot in array")

	detector.queue_free()
	return success

func test_object_tracking_system() -> bool:
	"""Test object tracking and registry system"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test object registration
	var test_object = Node.new()
	var object_id = detector.register_object(test_object)

	success = success and assert_type(object_id, TYPE_STRING, "Should return object ID string")
	success = success and assert_true(object_id.length() > 0, "Object ID should not be empty")

	# Test object lookup
	var found_object = detector.get_tracked_object(object_id)
	success = success and assert_equals(found_object, test_object, "Should retrieve correct object")

	# Test object unregistration
	var unregistered = detector.unregister_object(object_id)
	success = success and assert_true(unregistered, "Should successfully unregister object")

	# Test object no longer found after unregistration
	var not_found_object = detector.get_tracked_object(object_id)
	success = success and assert_null(not_found_object, "Should not find unregistered object")

	detector.queue_free()
	test_object.queue_free()
	return success

func test_reference_counting_analysis() -> bool:
	"""Test reference counting analysis capabilities"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test reference count tracking
	var test_object = Node.new()
	var initial_refs = detector.get_reference_count(test_object)
	success = success and assert_type(initial_refs, TYPE_INT, "Reference count should be integer")

	# Test reference count changes
	var child = Node.new()
	test_object.add_child(child)

	var after_refs = detector.get_reference_count(test_object)
	success = success and assert_type(after_refs, TYPE_INT, "Updated reference count should be integer")

	# Test circular reference detection
	var circular_detected = detector.detect_circular_references([test_object, child])
	success = success and assert_type(circular_detected, TYPE_BOOL, "Circular reference detection should return boolean")

	detector.queue_free()
	test_object.queue_free()
	return success

func test_leak_detection_algorithms() -> bool:
	"""Test leak detection algorithm implementation"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test basic leak detection
	var test_objects = [Node.new(), Node.new(), Node.new()]
	var leaks_found = detector.analyze_potential_leaks(test_objects)

	success = success and assert_type(leaks_found, TYPE_ARRAY, "Leak analysis should return array")

	# Test leak threshold validation
	var threshold_exceeded = detector.check_memory_threshold(2 * 1024 * 1024)  # 2MB
	success = success and assert_type(threshold_exceeded, TYPE_BOOL, "Threshold check should return boolean")

	# Test suspicious object identification
	var suspicious = detector.identify_suspicious_objects(test_objects)
	success = success and assert_type(suspicious, TYPE_ARRAY, "Suspicious object detection should return array")

	# Cleanup
	for obj in test_objects:
		obj.queue_free()

	detector.queue_free()
	return success

func test_memory_growth_monitoring() -> bool:
	"""Test memory growth monitoring and trend analysis"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test growth trend calculation
	var growth_trend = detector.calculate_memory_growth_trend()
	success = success and assert_type(growth_trend, TYPE_FLOAT, "Growth trend should be float")

	# Test growth threshold validation
	var excessive_growth = detector.validate_growth_threshold(0.15)  # 15%
	success = success and assert_type(excessive_growth, TYPE_BOOL, "Growth validation should return boolean")

	# Test memory trend analysis
	var trend_analysis = detector.analyze_memory_trends()
	success = success and assert_not_null(trend_analysis, "Trend analysis should return data")
	success = success and assert_type(trend_analysis, TYPE_DICTIONARY, "Trend analysis should be dictionary")

	detector.queue_free()
	return success

func test_garbage_collection_monitoring() -> bool:
	"""Test garbage collection monitoring capabilities"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test GC monitoring setup
	var gc_enabled = detector.setup_garbage_collection_monitoring()
	success = success and assert_type(gc_enabled, TYPE_BOOL, "GC monitoring setup should return boolean")

	# Test GC event tracking
	var gc_events = detector.get_garbage_collection_events()
	success = success and assert_type(gc_events, TYPE_ARRAY, "GC events should be array")

	# Test GC statistics
	var gc_stats = detector.get_garbage_collection_statistics()
	success = success and assert_not_null(gc_stats, "GC statistics should exist")
	success = success and assert_type(gc_stats, TYPE_DICTIONARY, "GC statistics should be dictionary")

	detector.queue_free()
	return success

func test_memory_profiling_reports() -> bool:
	"""Test memory profiling and reporting functionality"""
	var detector = MemoryLeakDetector.new()

	var success = true

	# Test profiling report generation
	var report = detector.generate_memory_profile_report()
	success = success and assert_not_null(report, "Should generate memory report")
	success = success and assert_type(report, TYPE_STRING, "Report should be string")

	# Test leak summary generation
	var leak_summary = detector.generate_leak_detection_summary()
	success = success and assert_not_null(leak_summary, "Should generate leak summary")
	success = success and assert_type(leak_summary, TYPE_DICTIONARY, "Leak summary should be dictionary")

	# Test detailed profiling data
	var profiling_data = detector.get_detailed_memory_profile()
	success = success and assert_not_null(profiling_data, "Should provide profiling data")
	success = success and assert_type(profiling_data, TYPE_DICTIONARY, "Profiling data should be dictionary")

	# Test report contains expected sections
	if report and report.length() > 0:
		success = success and assert_true(report.contains("Memory"), "Report should contain memory information")
		success = success and assert_true(report.contains("Profile") or report.contains("Snapshot"), "Report should contain profiling data")

	detector.queue_free()
	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_memory_intensive_scene() -> Node:
	"""Create a scene with multiple objects to test memory tracking"""
	var scene = Node.new()

	# Create multiple nodes to track
	for i in range(10):
		var node = Node.new()
		node.name = "TestNode_" + str(i)
		scene.add_child(node)

		# Add some properties to increase memory footprint
		var data = []
		for j in range(100):
			data.append("test_data_" + str(j))
		node.set_meta("test_data", data)

	return scene

func create_circular_reference_scenario() -> Array:
	"""Create objects with circular references for testing"""
	var obj_a = Node.new()
	var obj_b = Node.new()

	# Create circular reference through metadata
	obj_a.set_meta("reference", obj_b)
	obj_b.set_meta("reference", obj_a)

	return [obj_a, obj_b]

func simulate_memory_pressure() -> void:
	"""Simulate memory pressure by creating many objects"""
	var temp_objects = []
	for i in range(1000):
		var obj = Node.new()
		obj.name = "PressureTest_" + str(i)
		temp_objects.append(obj)

	# Let garbage collector handle cleanup
	temp_objects.clear()

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
