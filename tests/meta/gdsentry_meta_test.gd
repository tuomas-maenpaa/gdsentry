# GDSentry Meta-Level Test
# Validates that GDSentry framework mechanics exist and can be loaded
#
# This test focuses on validating the existence of framework components
# rather than testing their functionality. It's a meta-test that ensures
# the framework structure is intact and accessible.
#
# Author: GDSentry Framework
# Created: Auto-generated for self-testing

extends "res://base_classes/scene_tree_test.gd"

class_name GDSentryMetaTest

# ------------------------------------------------------------------------------
# META-TEST VALIDATION
# ------------------------------------------------------------------------------
func test_framework_components_exist() -> void:
	"""Test that core framework components exist and can be loaded"""
	print("🔍 META: Testing framework component existence")

	# Test that core components can be loaded
	var test_manager = load("res://gdsentry/core/test_manager.gd")
	assert_not_null(test_manager, "TestManager script should exist")

	var test_discovery = load("res://gdsentry/core/test_discovery.gd")
	assert_not_null(test_discovery, "TestDiscovery script should exist")

	var test_config = load("res://gdsentry/core/test_config.gd")
	assert_not_null(test_config, "TestConfig script should exist")

	var test_runner = load("res://gdsentry/core/test_runner.gd")
	assert_not_null(test_runner, "TestRunner script should exist")

	print("✅ META: Core components exist")

func test_base_classes_exist() -> void:
	"""Test that base test classes exist and can be loaded"""
	print("🔍 META: Testing base class existence")

	# Test that base classes can be loaded
	var gd_test = load("res://gdsentry/base_classes/gd_test.gd")
	assert_not_null(gd_test, "GDTest base class should exist")

	var scene_tree_test = load("res://gdsentry/base_classes/scene_tree_test.gd")
	assert_not_null(scene_tree_test, "SceneTreeTest class should exist")

	var node2d_test = load("res://gdsentry/base_classes/node2d_test.gd")
	assert_not_null(node2d_test, "Node2DTest class should exist")

	print("✅ META: Base classes exist")

func test_assertion_libraries_exist() -> void:
	"""Test that assertion libraries exist and can be loaded"""
	print("🔍 META: Testing assertion library existence")

	# Test that assertion libraries can be loaded
	var collection_assertions = load("res://gdsentry/assertions/collection_assertions.gd")
	assert_not_null(collection_assertions, "Collection assertions should exist")

	var string_assertions = load("res://gdsentry/assertions/string_assertions.gd")
	assert_not_null(string_assertions, "String assertions should exist")

	var math_assertions = load("res://gdsentry/assertions/math_assertions.gd")
	assert_not_null(math_assertions, "Math assertions should exist")

	print("✅ META: Assertion libraries exist")

func test_specialized_tests_exist() -> void:
	"""Test that specialized test types exist and can be loaded"""
	print("🔍 META: Testing specialized test existence")

	# Test that specialized test types can be loaded
	var visual_test = load("res://gdsentry/test_types/visual_test.gd")
	assert_not_null(visual_test, "VisualTest class should exist")

	var event_test = load("res://gdsentry/test_types/event_test.gd")
	assert_not_null(event_test, "EventTest class should exist")

	var ui_test = load("res://gdsentry/test_types/ui_test.gd")
	assert_not_null(ui_test, "UITest class should exist")

	var physics_test = load("res://gdsentry/test_types/physics_test.gd")
	assert_not_null(physics_test, "PhysicsTest class should exist")

	var integration_test = load("res://gdsentry/test_types/integration_test.gd")
	assert_not_null(integration_test, "IntegrationTest class should exist")

	var performance_test = load("res://gdsentry/test_types/performance_test.gd")
	assert_not_null(performance_test, "PerformanceTest class should exist")

	print("✅ META: Specialized tests exist")

func test_advanced_features_exist() -> void:
	"""Test that advanced features exist and can be loaded"""
	print("🔍 META: Testing advanced features existence")

	# Test that advanced features can be loaded
	var visual_regression = load("res://gdsentry/advanced/visual_regression.gd")
	assert_not_null(visual_regression, "Visual regression should exist")

	var memory_leak_detector = load("res://gdsentry/advanced/memory_leak_detector.gd")
	assert_not_null(memory_leak_detector, "Memory leak detector should exist")

	var video_recorder = load("res://gdsentry/advanced/video_recorder.gd")
	assert_not_null(video_recorder, "Video recorder should exist")

	var accessibility_tester = load("res://gdsentry/advanced/accessibility_tester.gd")
	assert_not_null(accessibility_tester, "Accessibility tester should exist")

	print("✅ META: Advanced features exist")

func test_integration_systems_exist() -> void:
	"""Test that integration systems exist and can be loaded"""
	print("🔍 META: Testing integration systems existence")

	# Test that integration systems can be loaded
	var ci_cd_integration = load("res://gdsentry/integration/ci_cd_integration.gd")
	assert_not_null(ci_cd_integration, "CI/CD integration should exist")

	var ide_integration = load("res://gdsentry/integration/ide_integration.gd")
	assert_not_null(ide_integration, "IDE integration should exist")

	var plugin_system = load("res://gdsentry/integration/plugin_system.gd")
	assert_not_null(plugin_system, "Plugin system should exist")

	var external_tools = load("res://gdsentry/integration/external_tools.gd")
	assert_not_null(external_tools, "External tools integration should exist")

	print("✅ META: Integration systems exist")

func test_directory_structure() -> void:
	"""Test that the expected directory structure exists"""
	print("🔍 META: Testing directory structure")

	# Test that expected directories exist (using FileAccess for directory checks)
	var dir = DirAccess.open("res://")

	assert_true(dir.dir_exists("gdsentry"), "gdsentry directory should exist")
	assert_true(dir.dir_exists("gdsentry/core"), "gdsentry/core directory should exist")
	assert_true(dir.dir_exists("gdsentry/base_classes"), "gdsentry/base_classes directory should exist")
	assert_true(dir.dir_exists("gdsentry/assertions"), "gdsentry/assertions directory should exist")
	assert_true(dir.dir_exists("gdsentry/test_types"), "gdsentry/test_types directory should exist")
	assert_true(dir.dir_exists("gdsentry/advanced"), "gdsentry/advanced directory should exist")
	assert_true(dir.dir_exists("gdsentry/integration"), "gdsentry/integration directory should exist")
	assert_true(dir.dir_exists("gdsentry/tests"), "gdsentry/tests directory should exist")

	print("✅ META: Directory structure is correct")

func test_framework_constants() -> void:
	"""Test that framework has expected constants and configuration"""
	print("🔍 META: Testing framework constants")

	# Test that we can access basic framework information
	var config = load("res://gdsentry/core/test_config.gd")
	assert_not_null(config, "Should be able to load test config")

	# Test that we have access to basic project information
	var project_info = ProjectSettings.get_setting("application/config/name")
	assert_not_null(project_info, "Should be able to access project information")

	print("✅ META: Framework constants accessible")
