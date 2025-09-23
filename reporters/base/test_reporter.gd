# GDSentry - Abstract Test Reporter Base Class
# Defines the standard interface for all test reporter implementations
#
# This abstract base class provides the foundation for creating different
# types of test reporters (JUnit XML, HTML, JSON, etc.) with consistent
# interfaces and behaviors.
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestReporter

# ------------------------------------------------------------------------------
# DEPENDENCIES
# ------------------------------------------------------------------------------
# Note: TestResult types are used in method signatures but loaded by concrete implementations

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_OUTPUT_DIR = "res://test_reports/"

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var output_directory: String = DEFAULT_OUTPUT_DIR
var include_screenshots: bool = false
var include_metadata: bool = true
var pretty_print: bool = true
var timestamp_format: String = "%Y-%m-%d %H:%M:%S"

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _init(config: Dictionary = {}) -> void:
	"""Initialize reporter with configuration"""
	_apply_configuration(config)
	# Note: _ensure_output_directory() is called when needed, not during init
	# to avoid creating unnecessary directories

# ------------------------------------------------------------------------------
# ABSTRACT METHODS (MUST BE IMPLEMENTED BY SUBCLASSES)
# ------------------------------------------------------------------------------
func generate_report(_test_suite, _output_path: String) -> void:
	"""Generate the test report in the specific format

	Args:
		_test_suite: The complete test suite results to report on
		_output_path: Full path where the report should be saved
	"""
	push_error("TestReporter: generate_report() must be implemented by subclass")
	assert(false, "Abstract method not implemented")

func get_supported_formats() -> Array[String]:
	"""Return array of supported output formats

	Returns:
		Array of format strings (e.g., ["xml", "html", "json"])
	"""
	push_error("TestReporter: get_supported_formats() must be implemented by subclass")
	assert(false, "Abstract method not implemented")
	return []

func get_default_filename() -> String:
	"""Return the default filename for this reporter type

	Returns:
		Default filename without extension (e.g., "test_report")
	"""
	push_error("TestReporter: get_default_filename() must be implemented by subclass")
	assert(false, "Abstract method not implemented")
	return ""

func get_format_extension() -> String:
	"""Return the file extension for this reporter's format

	Returns:
		File extension including dot (e.g., ".xml", ".html", ".json")
	"""
	push_error("TestReporter: get_format_extension() must be implemented by subclass")
	assert(false, "Abstract method not implemented")
	return ""

# ------------------------------------------------------------------------------
# CONFIGURATION METHODS
# ------------------------------------------------------------------------------
func configure(config: Dictionary) -> void:
	"""Apply configuration settings to the reporter"""
	_apply_configuration(config)

func _apply_configuration(config: Dictionary) -> void:
	"""Internal method to apply configuration settings"""
	# Check for output_directory in the config
	if config.has("output_directory"):
		output_directory = config.output_directory
	# Also check for reporting.output_directory (from CLI args)
	elif config.has("reporting") and config.reporting.has("output_directory"):
		output_directory = config.reporting.output_directory
	# Handle both direct properties and nested reporting properties
	if config.has("include_screenshots"):
		include_screenshots = config.include_screenshots
	elif config.has("reporting") and config.reporting.has("include_screenshots"):
		include_screenshots = config.reporting.include_screenshots

	if config.has("include_metadata"):
		include_metadata = config.include_metadata
	elif config.has("reporting") and config.reporting.has("include_metadata"):
		include_metadata = config.reporting.include_metadata

	if config.has("pretty_print"):
		pretty_print = config.pretty_print
	elif config.has("reporting") and config.reporting.has("pretty_print"):
		pretty_print = config.reporting.pretty_print

	if config.has("timestamp_format"):
		timestamp_format = config.timestamp_format
	elif config.has("reporting") and config.reporting.has("timestamp_format"):
		timestamp_format = config.reporting.timestamp_format

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
var FileSystemCompatibility = load("res://utilities/file_system_compatibility.gd")

func _ensure_output_directory() -> void:
	"""Ensure the output directory exists"""
	var dir_path = output_directory

		# Handle res:// paths
		if dir_path.begins_with("res://"):
			dir_path = ProjectSettings.globalize_path(dir_path)
		# Handle relative paths by converting to absolute
		elif not dir_path.begins_with("/"):
			var dir_access = DirAccess.open("res://")
			if dir_access:
				var current_dir = dir_access.get_current_dir()
				dir_path = current_dir.path_join(dir_path).simplify_path()

		if not FileSystemCompatibility.dir_exists(dir_path):
			var result = FileSystemCompatibility.make_dir_recursive(dir_path)
			if result != OK:
				push_warning("TestReporter: Failed to create output directory: " + output_directory)

func get_output_path(filename: String = "") -> String:
	"""Get the full output path for a report file"""
	if filename.is_empty():
		filename = get_default_filename() + get_format_extension()

	var base_path = output_directory

	# Handle res:// paths
	if base_path.begins_with("res://"):
		base_path = ProjectSettings.globalize_path(base_path)
	# Handle relative paths by converting to absolute
	elif not base_path.begins_with("/"):
		var dir_access = DirAccess.open("res://")
		if dir_access:
			var current_dir = dir_access.get_current_dir()
			base_path = current_dir.path_join(base_path).simplify_path()

	if not filename.begins_with("/"):
		filename = base_path.path_join(filename)

	return filename

func format_timestamp(unix_time: float) -> String:
	"""Format a Unix timestamp according to the configured format"""
	var datetime = Time.get_datetime_dict_from_unix_time(int(unix_time))
	return timestamp_format.format({
		"Y": "%04d" % datetime.year,
		"m": "%02d" % datetime.month,
		"d": "%02d" % datetime.day,
		"H": "%02d" % datetime.hour,
		"M": "%02d" % datetime.minute,
		"S": "%02d" % datetime.second
	})

func escape_xml(text: String) -> String:
	"""Escape special characters for XML output"""
	text = text.replace("&", "&amp;")
	text = text.replace("<", "&lt;")
	text = text.replace(">", "&gt;")
	text = text.replace("\"", "&quot;")
	text = text.replace("'", "&apos;")
	return text

func escape_html(text: String) -> String:
	"""Escape special characters for HTML output"""
	return escape_xml(text)  # XML escaping covers HTML escaping

func format_duration(seconds: float, precision: int = 2) -> String:
	"""Format duration in seconds to a human-readable string"""
	if seconds < 1.0:
		return "%.0fms" % (seconds * 1000)
	elif seconds < 60.0:
		return "%.{0}f s".format([precision]) % seconds
	else:
		var minutes = floor(seconds / 60)
		var remaining_seconds = fmod(seconds, 60)
		return "%dm %.{0}f s".format([precision]) % [minutes, remaining_seconds]

# ------------------------------------------------------------------------------
# VALIDATION METHODS
# ------------------------------------------------------------------------------
func validate_test_suite(test_suite) -> bool:
	"""Validate that the test suite has the required data"""
	if not test_suite:
		push_error("TestReporter: Test suite is null")
		return false

	if test_suite.suite_name.is_empty():
		push_warning("TestReporter: Test suite has empty name")

	if test_suite.test_results.is_empty():
		push_warning("TestReporter: Test suite has no test results")

	return true

func validate_output_path(output_path: String) -> bool:
	"""Validate that the output path is writable"""
	if output_path.is_empty():
		push_error("TestReporter: Output path is empty")
		return false

	# Check if directory exists
	var dir_path = output_path.get_base_dir()
	if not FileSystemCompatibility.dir_exists(ProjectSettings.globalize_path(dir_path)):
		push_error("TestReporter: Output directory does not exist: " + dir_path)
		return false

	return true

# ------------------------------------------------------------------------------
# COMMON REPORTING HELPERS
# ------------------------------------------------------------------------------
func generate_summary_stats(test_suite) -> Dictionary:
	"""Generate common summary statistics for reports"""
	return {
		"total_tests": test_suite.get_total_tests(),
		"passed_tests": test_suite.get_passed_tests(),
		"failed_tests": test_suite.get_failed_tests(),
		"error_tests": test_suite.get_error_tests(),
		"skipped_tests": test_suite.get_skipped_tests(),
		"total_assertions": test_suite.get_total_assertions(),
		"passed_assertions": test_suite.get_passed_assertions(),
		"failed_assertions": test_suite.get_failed_assertions(),
		"success_rate": test_suite.get_success_rate(),
		"execution_time": test_suite.execution_time,
		"formatted_execution_time": format_duration(test_suite.execution_time),
		"has_failures": test_suite.has_failures(),
		"timestamp": format_timestamp(Time.get_unix_time_from_system())
	}

# ------------------------------------------------------------------------------
# ERROR HANDLING
# ------------------------------------------------------------------------------
func handle_generation_error(error_message: String, output_path: String) -> void:
	"""Handle errors during report generation"""
	push_error("TestReporter: Failed to generate report - " + error_message)
	push_error("TestReporter: Output path: " + output_path)

	# Try to write error information to a fallback file
	var error_file = output_path.get_basename() + "_error.log"
	var file = FileSystemCompatibility.open_file(error_file, FileSystemCompatibility.WRITE)
	if file:
		FileSystemCompatibility.store_string(file, "Report generation failed at: " + format_timestamp(Time.get_unix_time_from_system()) + "\n")
		FileSystemCompatibility.store_string(file, "Error: " + error_message + "\n")
		FileSystemCompatibility.store_string(file, "Output path: " + output_path + "\n")
		FileSystemCompatibility.close_file(file)
		print("TestReporter: Error details written to: " + error_file)
	else:
		print("TestReporter: Failed to write error log")

# ------------------------------------------------------------------------------
# CLEANUP METHODS
# ------------------------------------------------------------------------------
func cleanup() -> void:
	"""Clean up resources used by the reporter"""
	# Default implementation does nothing
	# Subclasses can override to clean up temporary files, etc.
	pass

func _exit_tree() -> void:
	"""Called when the reporter is removed from the scene tree"""
	cleanup()
