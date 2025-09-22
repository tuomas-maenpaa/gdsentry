# GDSentry - Configuration Management System
# Project-specific configuration for GDSentry test execution
#
# Features:
# - Project-specific test configuration
# - Environment-specific settings
# - Test execution policies
# - Timeout and performance thresholds
# - Output formatting preferences
# - Custom assertion configurations
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Resource

class_name GDTestConfig

# ------------------------------------------------------------------------------
# CONFIGURATION PROPERTIES
# ------------------------------------------------------------------------------
@export_group("Test Discovery")
@export var test_directories: Array[String] = [
	"res://tests/",
	"res://gdsentry/examples/"
]
@export var recursive_discovery: bool = true
@export var discovery_patterns: Array[String] = [
	"*.gd"
]
@export var exclude_patterns: Array[String] = [
	"*.backup",
	"*.tmp"
]

@export_group("Test Execution")
@export var execution_policies: Dictionary = {
	"stop_on_failure": false,
	"parallel_execution": false,
	"randomize_order": false,
	"fail_fast": false
}
@export var timeout_settings: Dictionary = {
	"test_timeout": 30.0,
	"suite_timeout": 300.0,
	"global_timeout": 600.0
}
@export var retry_settings: Dictionary = {
	"max_retries": 0,
	"retry_delay": 1.0,
	"retry_on_failure_only": true
}

@export_group("Performance Thresholds")
@export var performance_thresholds: Dictionary = {
	"min_fps": 30,
	"max_memory_mb": 100,
	"max_objects": 10000,
	"max_physics_steps": 1000
}
@export var benchmark_settings: Dictionary = {
	"warmup_iterations": 10,
	"benchmark_iterations": 100,
	"performance_tolerance": 0.05
}

@export_group("Output and Reporting")
@export var output_settings: Dictionary = {
	"verbose": false,
	"show_progress": true,
	"show_timestamps": true,
	"color_output": true,
	"log_level": "INFO"
}
@export var report_settings: Dictionary = {
	"enabled": true,
	"formats": ["json"],  # Available: "json", "junit", "html"
	"output_directory": "res://test_reports/",
	"include_screenshots": false,
	"include_metadata": true,
	"include_performance_data": true,
	"pretty_print": true,
	"timestamp_format": "%Y-%m-%d %H:%M:%S"
}

# Advanced reporter configuration
@export var reporter_config: Dictionary = {
	"junit": {
		"include_system_out": false,
		"include_system_err": true,
		"include_properties": true,
		"suite_name_template": "GDSentry.{category}",
		"test_name_template": "{class}.{test_name}"
	},
	"html": {
		"include_charts": true,
		"include_environment_info": true,
		"include_assertion_details": true,
		"max_error_length": 500,
		"theme": "default",
		"include_search": true,
		"include_filters": true
	},
	"json": {
		"include_assertion_details": true,
		"include_system_info": true,
		"include_environment_data": true,
		"flatten_results": false,
		"group_by_category": true
	}
}

@export_group("Visual Testing")
@export var visual_settings: Dictionary = {
	"screenshot_directory": "res://test_screenshots/",
	"screenshot_format": "PNG",
	"visual_tolerance": 0.01,
	"baseline_directory": "res://test_screenshots/baseline/",
	"generate_diff_images": true
}
@export var accessibility_settings: Dictionary = {
	"check_contrast": true,
	"check_keyboard_navigation": true,
	"check_screen_reader": false,
	"minimum_contrast_ratio": 4.5
}

@export_group("Physics Testing")
@export var physics_settings: Dictionary = {
	"simulation_speed": 1.0,
	"collision_tolerance": 1.0,
	"physics_fps": 60,
	"fixed_timestep": true
}
@export var collision_settings: Dictionary = {
	"layer_mask_check": true,
	"overlap_tolerance": 0.5,
	"physics_frame_wait": 2
}

@export_group("UI Testing")
@export var ui_settings: Dictionary = {
	"input_delay": 0.1,
	"animation_wait_time": 0.5,
	"focus_timeout": 5.0,
	"element_timeout": 10.0
}
@export var form_settings: Dictionary = {
	"clear_form_before_test": true,
	"validate_required_fields": true,
	"check_form_validation": true
}

@export_group("Integration Testing")
@export var integration_settings: Dictionary = {
	"service_timeout": 30.0,
	"mock_external_services": true,
	"network_retry_count": 3,
	"database_reset_between_tests": true
}

# ------------------------------------------------------------------------------
# CONFIGURATION MANAGEMENT
# ------------------------------------------------------------------------------
static func load_from_file(config_path: String = "res://gdsentry_config.tres") -> GDTestConfig:
	"""Load configuration from a .tres file"""
	if ResourceLoader.exists(config_path):
		var config = ResourceLoader.load(config_path) as GDTestConfig
		if config:
			print("✅ GDTestConfig: Loaded configuration from:", config_path)
			return config

	# Return default configuration if file doesn't exist
	print("⚠️  GDTestConfig: Configuration file not found, using defaults:", config_path)
	return GDTestConfig.new()

static func save_to_file(config: GDTestConfig, config_path: String = "res://gdsentry_config.tres") -> bool:
	"""Save configuration to a .tres file"""
	var error = ResourceSaver.save(config, config_path)
	if error == OK:
		print("✅ GDTestConfig: Configuration saved to:", config_path)
		return true
	else:
		print("❌ GDTestConfig: Failed to save configuration:", error)
		return false

static func create_default_config() -> GDTestConfig:
	"""Create a default configuration with sensible defaults"""
	var config = GDTestConfig.new()

	# Set some common overrides from defaults
	config.execution_policies["stop_on_failure"] = false
	config.output_settings["verbose"] = false
	config.performance_thresholds["max_memory_mb"] = 200

	return config

# ------------------------------------------------------------------------------
# CONFIGURATION VALIDATION
# ------------------------------------------------------------------------------
func validate_configuration() -> Dictionary:
	"""Validate the current configuration and return validation results"""
	var results = {
		"is_valid": true,
		"errors": [],
		"warnings": [],
		"info": []
	}

	# Validate test directories
	for dir_path in test_directories:
		if not dir_path.begins_with("res://"):
			results.errors.append("Test directory must use res:// protocol: " + dir_path)
			results.is_valid = false

	# Validate timeouts
	for timeout_key in timeout_settings.keys():
		var timeout_value = timeout_settings[timeout_key]
		if timeout_value <= 0:
			results.errors.append("Timeout must be positive: " + timeout_key + " = " + str(timeout_value))
			results.is_valid = false

	# Validate performance thresholds
	if performance_thresholds.get("min_fps", 0) <= 0:
		results.errors.append("Minimum FPS must be positive")
		results.is_valid = false

	if performance_thresholds.get("max_memory_mb", 0) <= 0:
		results.errors.append("Maximum memory must be positive")
		results.is_valid = false

	# Validate visual settings
	if visual_settings.get("visual_tolerance", 0) < 0 or visual_settings.get("visual_tolerance", 0) > 1:
		results.errors.append("Visual tolerance must be between 0 and 1")
		results.is_valid = false

	# Warnings for potentially problematic settings
	if execution_policies.get("parallel_execution", false):
		results.warnings.append("Parallel execution may cause issues with visual tests")

	if timeout_settings.get("test_timeout", 30) > 300:
		results.warnings.append("Very long test timeout may indicate hanging tests")

	if performance_thresholds.get("max_memory_mb", 100) > 500:
		results.warnings.append("High memory limit may hide memory leaks")

	return results

# ------------------------------------------------------------------------------
# CONFIGURATION MERGING
# ------------------------------------------------------------------------------
func merge_with(other_config: GDTestConfig) -> GDTestConfig:
	"""Merge this configuration with another, with other_config taking precedence"""
	var merged_config = GDTestConfig.new()

	# Deep merge all dictionary properties
	merged_config.execution_policies = _deep_merge_dict(execution_policies, other_config.execution_policies)
	merged_config.timeout_settings = _deep_merge_dict(timeout_settings, other_config.timeout_settings)
	merged_config.performance_thresholds = _deep_merge_dict(performance_thresholds, other_config.performance_thresholds)
	merged_config.output_settings = _deep_merge_dict(output_settings, other_config.output_settings)
	merged_config.report_settings = _deep_merge_dict(report_settings, other_config.report_settings)
	merged_config.visual_settings = _deep_merge_dict(visual_settings, other_config.visual_settings)
	merged_config.physics_settings = _deep_merge_dict(physics_settings, other_config.physics_settings)
	merged_config.ui_settings = _deep_merge_dict(ui_settings, other_config.ui_settings)

	# Merge arrays (other_config takes precedence)
	merged_config.test_directories = other_config.test_directories if not other_config.test_directories.is_empty() else test_directories
	merged_config.discovery_patterns = other_config.discovery_patterns if not other_config.discovery_patterns.is_empty() else discovery_patterns
	merged_config.exclude_patterns = other_config.exclude_patterns if not other_config.exclude_patterns.is_empty() else exclude_patterns

	return merged_config

func _deep_merge_dict(base: Dictionary, override: Dictionary) -> Dictionary:
	"""Deep merge two dictionaries"""
	var result = base.duplicate(true)

	for key in override.keys():
		var override_value = override[key]
		if result.has(key) and result[key] is Dictionary and override_value is Dictionary:
			result[key] = _deep_merge_dict(result[key], override_value)
		else:
			result[key] = override_value

	return result

# ------------------------------------------------------------------------------
# ENVIRONMENT-SPECIFIC CONFIGURATIONS
# ------------------------------------------------------------------------------
static func get_environment_config() -> GDTestConfig:
	"""Get configuration based on current environment"""
	var config = GDTestConfig.new()

	# Detect environment
	var is_ci = OS.has_environment("CI") or OS.has_environment("CONTINUOUS_INTEGRATION")
	var is_headless = GDTestManager.is_headless_mode()
	var is_debug = OS.is_debug_build()

	if is_ci:
		# CI environment configuration
		config.execution_policies["parallel_execution"] = true
		config.execution_policies["fail_fast"] = true
		config.output_settings["verbose"] = true
		config.report_settings["generate_html_report"] = true
		config.timeout_settings["test_timeout"] = 60.0
		config.performance_thresholds["max_memory_mb"] = 300

	elif is_headless:
		# Headless environment configuration
		config.execution_policies["parallel_execution"] = false
		config.visual_settings["include_screenshots"] = false
		config.ui_settings["input_delay"] = 0.05  # Faster for headless

	else:
		# Local development configuration
		config.output_settings["verbose"] = is_debug
		config.execution_policies["stop_on_failure"] = false
		config.visual_settings["include_screenshots"] = true

	return config

# ------------------------------------------------------------------------------
# CONFIGURATION PROFILES
# ------------------------------------------------------------------------------
static func get_profile_config(profile_name: String) -> GDTestConfig:
	"""Get configuration for a specific profile"""
	var config = GDTestConfig.new()

	match profile_name:
		"ci":
			config.execution_policies["parallel_execution"] = true
			config.execution_policies["fail_fast"] = true
			config.output_settings["verbose"] = true
			config.report_settings["generate_html_report"] = true
			config.timeout_settings["test_timeout"] = 60.0

		"development":
			config.output_settings["verbose"] = true
			config.execution_policies["stop_on_failure"] = false
			config.visual_settings["include_screenshots"] = true
			config.performance_thresholds["max_memory_mb"] = 500

		"performance":
			config.benchmark_settings["benchmark_iterations"] = 1000
			config.performance_thresholds["min_fps"] = 60
			config.execution_policies["parallel_execution"] = false
			config.output_settings["verbose"] = true

		"visual":
			config.visual_settings["generate_diff_images"] = true
			config.visual_settings["visual_tolerance"] = 0.001
			config.accessibility_settings["check_contrast"] = true
			config.accessibility_settings["check_keyboard_navigation"] = true

		"smoke":
			config.test_directories = ["res://tests/smoke/"]
			config.execution_policies["stop_on_failure"] = true
			config.timeout_settings["test_timeout"] = 10.0

		_:
			print("⚠️  GDTestConfig: Unknown profile '" + profile_name + "', using default")

	return config

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func get_setting(path: String, default_value = null):
	"""Get a nested setting value using dot notation (e.g., "execution_policies.stop_on_failure")"""
	var parts = path.split(".")
	var current = self

	for part in parts:
		if current is Dictionary:
			if current.has(part):
				current = current[part]
			else:
				return default_value
		else:
			# Try to get property from the object
			if current.has_method("get"):
				current = current.get(part)
			else:
				return default_value

	return current

func set_setting(path: String, value) -> bool:
	"""Set a nested setting value using dot notation"""
	var parts = path.split(".")
	var current = self

	# Navigate to the parent of the target setting
	for i in range(parts.size() - 1):
		var part = parts[i]
		if current is Dictionary:
			if not current.has(part):
				current[part] = {}
			current = current[part]
		else:
			return false

	# Set the final value
	var final_key = parts[parts.size() - 1]
	if current is Dictionary:
		current[final_key] = value
		return true

	return false

func print_configuration() -> void:
	"""Print current configuration for debugging"""
	print("📋 GDSentry Configuration:")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("Test Directories:", test_directories)
	print("Recursive Discovery:", recursive_discovery)
	print("Execution Policies:", execution_policies)
	print("Timeout Settings:", timeout_settings)
	print("Performance Thresholds:", performance_thresholds)
	print("Output Settings:", output_settings)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

# ------------------------------------------------------------------------------
# CONFIGURATION TEMPLATES
# ------------------------------------------------------------------------------
static func create_template_config(template_name: String) -> GDTestConfig:
	"""Create a configuration template for common use cases"""
	var config = GDTestConfig.new()

	match template_name:
		"minimal":
			config.test_directories = ["res://tests/"]
			config.execution_policies["stop_on_failure"] = true
			config.output_settings["verbose"] = false

		"comprehensive":
			config.test_directories = [
				"res://tests/unit/",
				"res://tests/visual/",
				"res://tests/integration/"
			]
			config.execution_policies["parallel_execution"] = true
			config.report_settings["generate_html_report"] = true
			config.visual_settings["generate_diff_images"] = true
			config.performance_thresholds["min_fps"] = 30

		"gamedev":
			config.test_directories = ["res://tests/"]
			config.visual_settings["include_screenshots"] = true
			config.physics_settings["collision_tolerance"] = 2.0
			config.ui_settings["animation_wait_time"] = 1.0
			config.performance_thresholds["min_fps"] = 60

	return config