# GDSentry - Reporter Manager
# Central coordinator for managing multiple test reporters
#
# The ReporterManager provides a unified interface for generating test reports
# in multiple formats simultaneously. It handles reporter registration, configuration,
# and coordinated report generation across all registered reporters.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_OUTPUT_DIR = "res://test_reports/"
const SUPPORTED_FORMATS = ["junit", "html", "json"]

# ------------------------------------------------------------------------------
# STATE
# ------------------------------------------------------------------------------
var reporters: Dictionary = {}  # format -> reporter instance
var active_reporters: Array[String] = []
var global_config: Dictionary = {}
var is_initialized: bool = false

# Preload required classes
var TestReporter
var TestResult

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init() -> void:
	"""Initialize the reporter manager"""
	_setup_default_configuration()

func _ready() -> void:
	"""Load required classes when the node is ready"""
	_load_required_classes()

func initialize() -> void:
	"""Initialize the reporter manager with default reporters"""
	if is_initialized:
		return

	_register_default_reporters()
	is_initialized = true
	print("ReporterManager: Initialized with ", reporters.size(), " reporters")

func _load_required_classes() -> void:
	"""Load the required classes dynamically"""
	TestReporter = load("res://reporters/base/test_reporter.gd")
	if not TestReporter:
		push_error("ReporterManager: Failed to load TestReporter class")

	TestResult = load("res://reporters/base/test_result.gd")
	if not TestResult:
		push_error("ReporterManager: Failed to load TestResult class")

# ------------------------------------------------------------------------------
# REPORTER REGISTRATION
# ------------------------------------------------------------------------------
func register_reporter(format: String, reporter_class: GDScript, config: Dictionary = {}) -> bool:
	"""Register a new reporter for a specific format

	Args:
		format: The format identifier (e.g., "junit", "html", "json")
		reporter_class: The GDScript class for the reporter
		config: Configuration dictionary for the reporter

	Returns:
		bool: True if registration successful, false otherwise
	"""
	if reporters.has(format):
		push_warning("ReporterManager: Reporter for format '" + format + "' already registered")
		return false

	# Validate the reporter class
	if not _validate_reporter_class(reporter_class):
		push_error("ReporterManager: Invalid reporter class for format '" + format + "'")
		return false

	# Merge global config with format-specific config
	var merged_config = global_config.duplicate()
	if config.has("reporting") and config.reporting.has(format):
		merged_config.merge(config.reporting[format])

	# Create reporter instance
	var reporter = reporter_class.new(merged_config)
	if not reporter:
		push_error("ReporterManager: Failed to create reporter instance for format '" + format + "'")
		return false

	reporters[format] = reporter
	# Add reporter as child for proper scene tree lifecycle management
	if reporter and is_inside_tree():
		add_child(reporter)
	print("ReporterManager: Registered reporter for format '" + format + "'")
	return true

func unregister_reporter(format: String) -> bool:
	"""Unregister a reporter for a specific format

	Args:
		format: The format identifier to unregister

	Returns:
		bool: True if unregistration successful, false otherwise
	"""
	if not reporters.has(format):
		push_warning("ReporterManager: No reporter registered for format '" + format + "'")
		return false

	var reporter = reporters[format]
	if reporter:
		if reporter.has_method("cleanup"):
			reporter.cleanup()
		# Remove from scene tree and free
		if reporter.is_inside_tree():
			remove_child(reporter)
		if is_instance_valid(reporter):
			reporter.free()

	reporters.erase(format)
	active_reporters.erase(format)
	print("ReporterManager: Unregistered reporter for format '" + format + "'")
	return true

func get_reporter(format: String):
	"""Get a registered reporter instance

	Args:
		format: The format identifier

	Returns:
		TestReporter: The reporter instance or null if not found
	"""
	return reporters.get(format)

func list_registered_reporters() -> Array[String]:
	"""Get list of all registered reporter formats

	Returns:
		Array[String]: Array of registered format identifiers
	"""
	return reporters.keys()

# ------------------------------------------------------------------------------
# REPORTER ACTIVATION
# ------------------------------------------------------------------------------
func set_active_reporters(formats: Array[String]) -> void:
	"""Set which reporters should be active for report generation

	Args:
		formats: Array of format identifiers to activate
	"""
	active_reporters.clear()

	for format in formats:
		if reporters.has(format):
			if not active_reporters.has(format):
				active_reporters.append(format)
		else:
			push_warning("ReporterManager: Cannot activate unknown format '" + format + "'")

	print("ReporterManager: Set active reporters: ", active_reporters)

func get_active_reporters() -> Array[String]:
	"""Get list of currently active reporter formats

	Returns:
		Array[String]: Array of active format identifiers
	"""
	return active_reporters.duplicate()

# ------------------------------------------------------------------------------
# REPORT GENERATION
# ------------------------------------------------------------------------------
func generate_reports(test_suite, output_dir: String = "") -> Dictionary:
	"""Generate reports using all active reporters

	Args:
		test_suite: The complete test suite results
		output_dir: Output directory (uses default if empty)

	Returns:
		Dictionary: Report generation results with success/failure status
	"""
	var results = {
		"success": true,
		"reports_generated": [],
		"errors": [],
		"total_time": 0.0
	}

	if not is_initialized:
		initialize()

	if active_reporters.is_empty():
		push_warning("ReporterManager: No active reporters configured")
		results.success = false
		results.errors.append("No active reporters configured")
		return results

	if not output_dir.is_empty():
		_update_output_directory(output_dir)

	var start_time = Time.get_unix_time_from_system()

	for format in active_reporters:
		var report_result = generate_single_report(format, test_suite)
		results.reports_generated.append(report_result)

		if not report_result.success:
			results.success = false
			results.errors.append("Failed to generate " + format + " report: " + report_result.error)

	results.total_time = Time.get_unix_time_from_system() - start_time

	if results.success:
		print("ReporterManager: Successfully generated ", results.reports_generated.size(), " reports in ", "%.2f" % results.total_time, "s")
	else:
		print("ReporterManager: Report generation completed with ", results.errors.size(), " errors")

	return results

func generate_single_report(format: String, test_suite) -> Dictionary:
	"""Generate a report for a specific format

	Args:
		format: The format identifier
		test_suite: The test suite results

	Returns:
		Dictionary: Report generation result
	"""
	var result = {
		"format": format,
		"success": false,
		"output_path": "",
		"error": "",
		"generation_time": 0.0
	}

	if not reporters.has(format):
		result.error = "No reporter registered for format '" + format + "'"
		return result

	var reporter = reporters[format]
	if not reporter:
		result.error = "Reporter instance is null"
		return result

	# Validate test suite
	if not reporter.validate_test_suite(test_suite):
		result.error = "Invalid test suite data"
		return result

	# Generate output path
	var output_path = _generate_output_path(reporter, format)

	# Ensure output directory exists before validating
	if reporter.has_method("_ensure_output_directory"):
		reporter._ensure_output_directory()

	# Validate output path
	if not reporter.validate_output_path(output_path):
		result.error = "Invalid output path: " + output_path
		return result

	result.output_path = output_path

	# Generate report
	var report_start_time = Time.get_unix_time_from_system()

	# Generate report synchronously for test execution
	reporter.generate_report(test_suite, output_path)

	result.generation_time = Time.get_unix_time_from_system() - report_start_time
	result.success = true

	return result

# ------------------------------------------------------------------------------
# ASYNC REPORT GENERATION
# ------------------------------------------------------------------------------
func _generate_report_async(reporter, test_suite, output_path: String, _result: Dictionary) -> void:
	"""Asynchronous report generation to avoid blocking"""
	reporter.generate_report(test_suite, output_path)

# ------------------------------------------------------------------------------
# CONFIGURATION MANAGEMENT
# ------------------------------------------------------------------------------
func configure(config: Dictionary) -> void:
	"""Apply global configuration to all reporters

	Args:
		config: Configuration dictionary
	"""
	global_config = config

	# Update existing reporters with new configuration
	for reporter in reporters.values():
		if reporter and reporter.has_method("configure"):
			reporter.configure(config)

	# Set active reporters from config
	if config.has("reporting") and config.reporting.has("enabled") and config.reporting.enabled:
		if config.reporting.has("formats"):
			set_active_reporters(config.reporting.formats)

func _setup_default_configuration() -> void:
	"""Set up default configuration"""
	global_config = {
		"reporting": {
			"enabled": true,
			"formats": ["junit"],
			"output_directory": DEFAULT_OUTPUT_DIR,
			"include_screenshots": false,
			"include_metadata": true,
			"pretty_print": true
		}
	}

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func _validate_reporter_class(reporter_class: GDScript) -> bool:
	"""Validate that a reporter class implements the required interface

	Args:
		reporter_class: The GDScript class to validate

	Returns:
		bool: True if valid, false otherwise
	"""
	if not reporter_class:
		return false

	# Check if it has the required methods (since we can't use 'is' with dynamic loading)
	var instance = reporter_class.new()
	var has_required_interface = instance and instance.has_method("generate_report") and instance.has_method("get_supported_formats")
	if not has_required_interface:
		if instance:
			instance.queue_free()
		return false

	# Check required methods exist
	var required_methods = [
		"generate_report",
		"get_supported_formats",
		"get_default_filename",
		"get_format_extension"
	]

	for method in required_methods:
		if not instance.has_method(method):
			push_error("ReporterManager: Reporter class missing required method: " + method)
			instance.queue_free()
			return false

	instance.queue_free()
	return true

func _update_output_directory(output_dir: String) -> void:
	"""Update output directory for all reporters

	Args:
		output_dir: New output directory path
	"""
	for reporter in reporters.values():
		if reporter and reporter.has_method("configure"):
			reporter.configure({"output_directory": output_dir})

func _generate_output_path(reporter, _format: String) -> String:
	"""Generate the full output path for a reporter

	Args:
		reporter: The reporter instance
		format: The format identifier

	Returns:
		String: Full output path
	"""
	var filename = reporter.get_default_filename()
	var extension = reporter.get_format_extension()
	var base_path = reporter.output_directory

	return base_path.path_join(filename + extension)

# ------------------------------------------------------------------------------
# DEFAULT REPORTER REGISTRATION
# ------------------------------------------------------------------------------
func _register_default_reporters() -> void:
	"""Register the default reporters that come with GDSentry"""
	# Register JUnit XML reporter for CI/CD integration
	if ResourceLoader.exists("res://reporters/formats/junit_reporter.gd"):
		var junit_reporter = load("res://reporters/formats/junit_reporter.gd")
		if junit_reporter:
			register_reporter("junit", junit_reporter)
			register_reporter("xml", junit_reporter)  # Alias for convenience
		else:
			push_warning("ReporterManager: Failed to load JUnit reporter")
	else:
		push_warning("ReporterManager: JUnit reporter not found at expected location")

	# Register HTML reporter for human-readable reports
	if ResourceLoader.exists("res://reporters/formats/html_reporter.gd"):
		var html_reporter = load("res://reporters/formats/html_reporter.gd")
		if html_reporter:
			register_reporter("html", html_reporter)
			register_reporter("htm", html_reporter)  # Alternative extension
		else:
			push_warning("ReporterManager: Failed to load HTML reporter")
	else:
		push_warning("ReporterManager: HTML reporter not found at expected location")

	# Register JSON reporter for programmatic consumption
	if ResourceLoader.exists("res://reporters/formats/json_reporter.gd"):
		var json_reporter = load("res://reporters/formats/json_reporter.gd")
		if json_reporter:
			register_reporter("json", json_reporter)
		else:
			push_warning("ReporterManager: Failed to load JSON reporter")
	else:
		push_warning("ReporterManager: JSON reporter not found at expected location")

	var registered_count = reporters.size()
	if registered_count > 0:
		print("ReporterManager: Successfully registered ", registered_count, " default reporters")
	else:
		push_warning("ReporterManager: No default reporters could be registered")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func cleanup() -> void:
	"""Clean up all reporters and resources"""
	for reporter in reporters.values():
		if reporter:
			if reporter.has_method("cleanup"):
				reporter.cleanup()
			# Remove from scene tree and free
			if reporter.is_inside_tree():
				remove_child(reporter)
			if is_instance_valid(reporter):
				reporter.free()

	reporters.clear()
	active_reporters.clear()
	is_initialized = false

func _exit_tree() -> void:
	"""Called when the manager is removed from the scene tree"""
	cleanup()
