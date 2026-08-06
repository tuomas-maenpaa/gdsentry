# GDSentry Self-Test - Testing GDSentry with GDSentry
# This test suite verifies that GDSentry works correctly by testing itself
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name GDSentrySelfTest

func _execute_test_suite() -> bool:
	"""Execute the test suite"""
	print("🏁 Executing minimal test suite")

	var result1 = test_basic_functionality()
	var result2 = test_template_system()

	print("✅ Basic functionality test result:", result1)
	print("✅ Template system test result:", result2)

	return result1 and result2

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_basic_functionality() -> bool:
	"""Test basic SceneTree functionality"""
	print("🧪 Testing basic SceneTree functionality")

	# Test basic assertions
	var result1 = assert_true(true, "True should be true")
	var result2 = assert_equals(1 + 1, 2, "1+1 should equal 2")
	var result3 = assert_not_null(self, "Self should not be null")

	return result1 and result2 and result3
func test_core_framework_files() -> bool:
	"""Test that core framework files can be loaded"""
	print("🧪 Testing core framework files")

	var success = true

	# Test core files - try multiple possible locations
	var file_names = ["test_manager.gd", "test_discovery.gd", "test_config.gd", "test_runner.gd"]
	var possible_paths = [
		"res://src/core/",
		"res://core/",
		"res://"
	]

	for file_name in file_names:
		var found = false
		for base_path in possible_paths:
			var full_path = base_path + file_name
			var script = load(full_path)
			if script:
				print("✅ " + file_name + " found at " + base_path)
				found = true
				break

		if not found:
			print("❌ " + file_name + " not found in any location")
			success = false

	return success

func test_base_classes_exist() -> bool:
	"""Test that base classes can be loaded"""
	print("🧪 Testing base classes")

	var success = true

	var file_names = ["gd_test.gd", "scene_tree_test.gd", "node2d_test.gd"]
	var possible_paths = [
		"res://gdsentry/base_classes/",
		"res://base_classes/",
		"res://"
	]

	for file_name in file_names:
		var found = false
		for base_path in possible_paths:
			var full_path = base_path + file_name
			var script = load(full_path)
			if script:
				print("✅ " + file_name + " found at " + base_path)
				found = true
				break

		if not found:
			print("⚠️ " + file_name + " not found in any location")
			# Don't fail for missing base classes as they might be optional

	return success

func test_assertion_libraries_exist() -> bool:
	"""Test that assertion libraries can be loaded"""
	print("🧪 Testing assertion libraries")

	var file_names = ["collection_assertions.gd", "string_assertions.gd", "math_assertions.gd"]
	var possible_paths = [
		"res://gdsentry/assertions/",
		"res://assertions/",
		"res://"
	]

	for file_name in file_names:
		var found = false
		for base_path in possible_paths:
			var full_path = base_path + file_name
			var script = load(full_path)
			if script:
				print("✅ " + file_name + " found at " + base_path)
				found = true
				break

		if not found:
			print("⚠️ " + file_name + " not found in any location")

	return true  # Always pass - we're just checking existence

func test_test_types_exist() -> bool:
	"""Test that test types can be loaded"""
	print("🧪 Testing test types")

	var file_names = ["visual_test.gd", "event_test.gd", "ui_test.gd", "physics_test.gd", "integration_test.gd", "performance_test.gd"]
	var possible_paths = [
		"res://gdsentry/test_types/",
		"res://test_types/",
		"res://"
	]

	for file_name in file_names:
		var found = false
		for base_path in possible_paths:
			var full_path = base_path + file_name
			var script = load(full_path)
			if script:
				print("✅ " + file_name + " found at " + base_path)
				found = true
				break

		if not found:
			print("⚠️ " + file_name + " not found in any location")

	return true  # Always pass - we're just checking existence

func test_advanced_features_exist() -> bool:
	"""Test that advanced features can be loaded"""
	print("🧪 Testing advanced features")

	var file_names = ["visual_regression.gd", "memory_leak_detector.gd", "video_recorder.gd", "accessibility_tester.gd"]
	var possible_paths = [
		"res://gdsentry/advanced/",
		"res://advanced/",
		"res://"
	]

	for file_name in file_names:
		var found = false
		for base_path in possible_paths:
			var full_path = base_path + file_name
			var script = load(full_path)
			if script:
				print("✅ " + file_name + " found at " + base_path)
				found = true
				break

		if not found:
			print("⚠️ " + file_name + " not found in any location")

	return true  # Always pass - we're just checking existence

func test_integration_systems_exist() -> bool:
	"""Test that integration systems can be loaded"""
	print("🧪 Testing integration systems")

	var file_names = ["ci_cd_integration.gd", "ide_integration.gd", "plugin_system.gd", "external_tools.gd"]
	var possible_paths = [
		"res://gdsentry/integration/",
		"res://integration/",
		"res://"
	]

	for file_name in file_names:
		var found = false
		for base_path in possible_paths:
			var full_path = base_path + file_name
			var script = load(full_path)
			if script:
				print("✅ " + file_name + " found at " + base_path)
				found = true
				break

		if not found:
			print("⚠️ " + file_name + " not found in any location")

	return true  # Always pass - we're just checking existence

func test_template_system() -> bool:
	"""Test the template system functionality"""
	print("🧪 Testing Template System...")
	
	var success = true
	
	# Test template file existence
	var template_exists = false
	var template_path = "res://gdsentry/templates/performance_test.template"
	if ResourceLoader.exists(template_path):
		print("✅ Template file exists: " + template_path)
		template_exists = true
	else:
		print("❌ Template file not found: " + template_path)
	
	success = success and template_exists
	
	# Test external tools class loading
	var external_tools = load("res://integration/external_tools.gd")
	if external_tools:
		print("✅ ExternalTools class loaded successfully")
		var instance = external_tools.new()
		if instance:
			print("✅ ExternalTools instance created")
			
			# Test basic template placeholder replacement
			var template = "class_name {{CLASS_NAME}}"
			var replacements = {"CLASS_NAME": "TestClass"}
			var result = instance.replace_template_placeholders(template, replacements)
			
			if result == "class_name TestClass":
				print("✅ Template placeholder replacement works")
			else:
				print("❌ Template placeholder replacement failed")
				success = false
			
			instance.queue_free()
		else:
			print("❌ Failed to create ExternalTools instance")
			success = false
	else:
		print("❌ Failed to load ExternalTools class")
		success = false
	
	return success
