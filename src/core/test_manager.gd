# GDSentry - Test Manager
# Core testing utilities for project-agnostic Godot testing
#
# This is an enhanced version of the original TestManager,
# made generic for any Godot project
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name GDTestManager

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_HEADLESS_TIMEOUT: float = 30.0
const DEFAULT_TEST_TIMEOUT: float = 5.0

# Test result structure template
const TEST_RESULT_TEMPLATE: Dictionary = {
	"total_tests": 0,
	"passed_tests": 0,
	"failed_tests": 0,
	"test_details": [],
	"execution_time": 0.0,
	"start_time": 0.0,
	"end_time": 0.0
}

# ------------------------------------------------------------------------------
# STATIC HEADLESS DETECTION
# ------------------------------------------------------------------------------
static func is_headless_mode() -> bool:
	"""Check if running in headless mode using robust multi-method detection"""

	# Method 1: Check for --headless command line argument (most reliable)
	var args: Array = OS.get_cmdline_args()
	for arg: String in args:
		if arg == "--headless":
			print("🧪 GDTestManager: --headless argument detected - HEADLESS MODE")
			return true

	# Method 2: Check if DisplayServer exists and has screens
	if DisplayServer and DisplayServer.get_screen_count() == 0:
		print("🧪 GDTestManager: No screens available - HEADLESS MODE")
		return true

	# Method 3: Check if we're in a server environment by checking OS type
	if OS.get_name() == "Server":
		print("🧪 GDTestManager: OS is Server - HEADLESS MODE")
		return true

	# Method 4: Check if DisplayServer exists but has no windows
	if DisplayServer and DisplayServer.get_window_list().size() == 0:
		print("🧪 GDTestManager: DisplayServer exists but no windows - HEADLESS MODE")
		return true

	# Method 5: Check environment variables for headless indicators
	if OS.has_environment("DISPLAY") and OS.get_environment("DISPLAY") == "":
		print("🧪 GDTestManager: DISPLAY environment variable is empty - HEADLESS MODE")
		return true

	print("🧪 GDTestManager: Not in headless mode")
	return false

# ------------------------------------------------------------------------------
# VERSION DETECTION
# ------------------------------------------------------------------------------
static func _is_godot_4_plus() -> bool:
	"""Detect if running on Godot 4.x or later"""
	return Engine.get_version_info().major >= 4

# ------------------------------------------------------------------------------
# STATIC TIMER FACTORY
# ------------------------------------------------------------------------------
static func create_test_timer(wait_time: float, one_shot: bool = true, autostart: bool = true, timer_name: String = "") -> Timer:
	"""Create a properly configured Timer for test use (version-aware)
	Args:
		wait_time: Duration in seconds
		one_shot: Whether timer should fire only once
		autostart: Whether timer should start automatically
		  - Godot 3.x: autostart works before adding to tree
		  - Godot 4.x: timer must be added to tree first, then started
		timer_name: Optional name for the timer
	Returns:
		Configured Timer instance - caller must add to tree before timer starts (Godot 4.x requirement)"""
	
	var timer: Timer = Timer.new()
	if not timer:
		push_error("🧪 GDTestManager: Failed to create timer")
		return null
	
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	
	# Version-aware autostart handling
	if _is_godot_4_plus():
		# Godot 4.x: Must be added to tree before starting, so disable autostart
		timer.autostart = false
	else:
		# Godot 3.x: autostart works fine
		timer.autostart = autostart
	
	if not timer_name.is_empty():
		timer.name = timer_name
	
	return timer

# ------------------------------------------------------------------------------
# STATIC SHUTDOWN TIMER MANAGEMENT
# ------------------------------------------------------------------------------
static func setup_headless_shutdown(target_node: Node, timeout: float = DEFAULT_HEADLESS_TIMEOUT) -> Timer:
	"""Set up automatic shutdown for headless mode with configurable timeout
	Returns the timer instance for additional configuration if needed"""

	# Check if running in headless mode
	if is_headless_mode():
		print("🧪 GDTestManager: HEADLESS MODE DETECTED - Setting up auto-shutdown")

		# Create timer with autostart (version-aware handling)
		var timer: Timer = create_test_timer(timeout, true, true, "HeadlessShutdownTimer")
		if not timer:
			push_error("🧪 GDTestManager: Failed to create headless shutdown timer")
			return null
		
		# Connect timeout signal
		timer.timeout.connect(_on_headless_shutdown_timeout)

		# Add timer to tree
		target_node.add_child(timer)
		
		# In Godot 4.x, manually start since autostart was disabled
		if _is_godot_4_plus():
			timer.start()

		print("🧪 GDTestManager: Headless shutdown timer created - will quit in " + str(timer.wait_time) + " seconds")
		return timer
	else:
		print("🧪 GDTestManager: Not in headless mode - no auto-shutdown timer needed")
		return null

static func _on_headless_shutdown_timeout() -> void:
	"""Called when headless shutdown timer expires"""
	print("🧪 GDTestManager: HEADLESS SHUTDOWN TIMER EXPIRED - Quitting application")
	print("🧪 GDTestManager: This prevents headless mode from running indefinitely")
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var scene_tree: SceneTree = main_loop as SceneTree
		scene_tree.quit()

# ------------------------------------------------------------------------------
# STATIC LOGGING UTILITIES
# ------------------------------------------------------------------------------
static func log_test_start(test_name: String) -> void:
	"""Log test start with consistent formatting"""
	print("🧪 " + test_name + ": Starting test execution")

static func log_test_success(test_name: String, duration: float = -1.0) -> void:
	"""Log test success with consistent formatting"""
	var duration_text: String = ""
	if duration >= 0.0:
		duration_text = " (%.1fs)" % duration
	print("✅ " + test_name + ": PASSED" + duration_text)

static func log_test_failure(test_name: String, error_message: String = "") -> void:
	"""Log test failure with consistent formatting"""
	var error_text: String = ""
	if not error_message.is_empty():
		error_text = " - " + error_message
	print("❌ " + test_name + ": FAILED" + error_text)

static func log_test_info(test_name: String, message: String) -> void:
	"""Log test info with consistent formatting"""
	print("ℹ️ " + test_name + ": " + message)

# ------------------------------------------------------------------------------
# STATIC TEST RESULT MANAGEMENT
# ------------------------------------------------------------------------------
static func create_test_results() -> Dictionary:
	"""Create a new test results dictionary"""
	return TEST_RESULT_TEMPLATE.duplicate(true)

static func add_test_result(results: Dictionary, test_name: String, passed: bool, details: String = "") -> void:
	"""Add a test result to the results dictionary"""
	# Initialize counters if they don't exist
	if not results.has("total_tests"):
		results.total_tests = 0
	if not results.has("passed_tests"):
		results.passed_tests = 0
	if not results.has("failed_tests"):
		results.failed_tests = 0

	# Update counters
	results.total_tests += 1

	if passed:
		results.passed_tests += 1
	else:
		results.failed_tests += 1

	var result_detail: Dictionary = {
		"name": test_name,
		"passed": passed,
		"details": details,
		"timestamp": Time.get_unix_time_from_system()
	}

	# Ensure test_details exists and is an Array
	if not results.has("test_details"):
		results.test_details = []
	elif not results.test_details is Array:
		results.test_details = []
	
	results.test_details.append(result_detail)

static func print_test_results(results: Dictionary, _test_suite_name: String = "Test Suite") -> void:
	"""Print formatted test results in enterprise-grade hierarchical format"""
	
	# Print individual test cases with indentation
	var test_details = results.get("test_details", [])
	if test_details.size() > 0:
		for detail: Dictionary in test_details:
			var status_icon: String = "✅" if detail.passed else "❌"
			var detail_duration_text: String = ""
			if detail.has("execution_time"):
				detail_duration_text = " (%.2fs)" % detail.execution_time
			else:
				detail_duration_text = " (0.00s)"
			print("      %s %s%s" % [status_icon, detail.name, detail_duration_text])
	
	# Print suite summary line
	var suite_status = "PASSED" if results.failed_tests == 0 else "FAILED"
	var test_count_text = ""
	if test_details.size() > 0:
		test_count_text = " | Tests: %d/%d" % [results.passed_tests, results.total_tests]
	var duration_text = " | Duration: %.2fs" % results.execution_time if results.execution_time > 0.0 else ""
	print("      Status: %s%s%s" % [suite_status, test_count_text, duration_text])

# ------------------------------------------------------------------------------
# STATIC SCENE MANAGEMENT UTILITIES
# ------------------------------------------------------------------------------
static func load_scene_safely(scene_path: String) -> PackedScene:
	"""Load a scene with error handling
	Returns null if loading fails"""

	if not FileAccess.file_exists(scene_path):
		push_error("🧪 GDTestManager: Scene file not found: " + scene_path)
		return null

	var scene: PackedScene = load(scene_path) as PackedScene
	if not scene:
		push_error("🧪 GDTestManager: Failed to load scene: " + scene_path)
		return null

	return scene

static func instantiate_scene_safely(scene: PackedScene) -> Node:
	"""Instantiate a scene with error handling
	Returns null if instantiation fails"""

	if not scene:
		push_error("🧪 GDTestManager: Cannot instantiate null scene")
		return null

	var instance: Node = scene.instantiate()
	if not instance:
		push_error("🧪 GDTestManager: Failed to instantiate scene")
		return null

	return instance

# ------------------------------------------------------------------------------
# STATIC NODE UTILITIES
# ------------------------------------------------------------------------------
static func find_node_by_name(root: Node, node_name: String) -> Node:
	"""Recursively find a node by name
	Returns null if not found"""

	if root.name == node_name:
		return root

	for child: Node in root.get_children():
		var found: Node = find_node_by_name(child, node_name)
		if found:
			return found

	return null

static func find_nodes_by_type(root: Node, node_type: String) -> Array[Node]:
	"""Recursively find all nodes of a specific type
	Returns array of all nodes matching the type"""

	var found_nodes: Array[Node] = []

	if not root:
		return found_nodes

	if root.get_class() == node_type:
		found_nodes.append(root)

	for child: Node in root.get_children():
		found_nodes.append_array(find_nodes_by_type(child, node_type))

	return found_nodes

static func validate_node_path(root: Node, path: String) -> bool:
	"""Validate that a node path exists from the given root
	Returns true if the path is valid"""

	if not root:
		return false

	var node: Node = root.get_node_or_null(path)
	return node != null

# ------------------------------------------------------------------------------
# STATIC UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
static func get_current_time_string() -> String:
	"""Get current time as formatted string"""
	var time_dict: Dictionary = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]

static func calculate_execution_time(start_time: float, end_time: float) -> float:
	"""Calculate execution time in seconds"""
	return end_time - start_time

static func format_duration(seconds: float) -> String:
	"""Format duration in human-readable format"""
	if seconds < 1.0:
		return "%.1fms" % (seconds * 1000)
	elif seconds < 60.0:
		return "%.2fs" % seconds
	else:
		var minutes: int = int(seconds / 60)
		var remaining_seconds: int = int(seconds) % 60
		return "%dm %ds" % [minutes, remaining_seconds]

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	# This node serves as a singleton for the testing framework
	# It can be accessed via get_node("/root/GDTestManager") if needed
	pass
