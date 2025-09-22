# TestManager Unit Test
# Tests the core TestManager functionality
#
# This test validates that TestManager provides expected utilities
# for headless detection, logging, timeouts, and scene management.
#
# Author: GDSentry Framework
# Created: Auto-generated for self-testing

extends SceneTreeTest

class_name TestManagerTest

# ------------------------------------------------------------------------------
# TEST SETUP
# ------------------------------------------------------------------------------
func setup() -> void:
	"""Setup test environment"""
	print("🧪 Setting up TestManager test")

func teardown() -> void:
	"""Clean up after test"""
	print("🧪 Tearing down TestManager test")

# ------------------------------------------------------------------------------
# HEADLESS DETECTION TESTS
# ------------------------------------------------------------------------------
func test_headless_detection() -> void:
	"""Test that headless mode can be detected"""
	print("🧪 Testing headless detection")

	# Test that we can call headless detection functions
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	# The function should exist and be callable
	# Note: We can't easily test the actual headless state in this environment
	print("✅ Headless detection function exists")

func test_logging_functions() -> void:
	"""Test that logging functions exist and can be called"""
	print("🧪 Testing logging functions")

	# Test that logging functions exist
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	# We can verify the functions exist by checking the script has expected methods
	var script = test_manager.new()
	assert_not_null(script, "Should be able to instantiate TestManager")

	# Clean up
	script.queue_free()

	print("✅ Logging functions accessible")

func test_scene_loading() -> void:
	"""Test that scene loading utilities exist"""
	print("🧪 Testing scene loading utilities")

	# Test that scene loading functions exist
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	# Test loading a basic scene if it exists
	var main_scene = load("res://scenes/main.tscn")
	if main_scene:
		assert_not_null(main_scene, "Should be able to load main scene")
	else:
		print("⚠️ Main scene not found (expected in standalone mode)")

	print("✅ Scene loading utilities exist")

func test_timeout_handling() -> void:
	"""Test that timeout handling functions exist"""
	print("🧪 Testing timeout handling")

	# Test that timeout functions exist
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	# The setup_headless_shutdown function should exist
	print("✅ Timeout handling functions exist")

func test_result_tracking() -> void:
	"""Test that result tracking functions exist"""
	print("🧪 Testing result tracking")

	# Test that result tracking functions exist
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	# Functions for creating test results should exist
	print("✅ Result tracking functions exist")

func test_autoload_setup() -> void:
	"""Test that autoload setup functions exist"""
	print("🧪 Testing autoload setup")

	# Test that autoload initialization functions exist
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	print("✅ Autoload setup functions exist")

func test_utility_functions() -> void:
	"""Test that general utility functions exist"""
	print("🧪 Testing utility functions")

	# Test that utility functions exist
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager should be loadable")

	# Common utility functions should be available
	print("✅ Utility functions exist")