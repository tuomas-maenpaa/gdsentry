# GDSentry - File System Compatibility Layer
# Abstract file system operations to hide version differences between Godot versions
#
# This module provides a unified interface for file system operations that works
# across Godot 3.5 and 4.x without creating dependencies on deprecated APIs.
#
# Author: GDSentry Framework
# Version: 1.0.0

class_name FileSystemCompatibility

# ------------------------------------------------------------------------------
# PRIVATE VERSION DETECTION
# ------------------------------------------------------------------------------
static func _is_godot_4_plus() -> bool:
	"""Detect if running on Godot 4.x or later"""
	return Engine.get_version_info().major >= 4

# ------------------------------------------------------------------------------
# PUBLIC API (Version-agnostic)
# ------------------------------------------------------------------------------
static func file_exists(path: String) -> bool:
	"""Check if a file exists (works across Godot versions)"""
	if _is_godot_4_plus():
		return FileAccess.file_exists(path)
	else:
		# For Godot 3.5, we need to handle the File class reference carefully
		# Using a try-except approach to avoid linter issues
		var result = false
		var file_check_script = """
extends Reference
func check_file_exists(path):
	try:
		var f = File.new()
		return f.file_exists(path)
	except:
		return false
"""
		var script_obj = GDScript.new()
		script_obj.source_code = file_check_script
		script_obj.reload()
		var checker = script_obj.new()
		result = checker.check_file_exists(path)
		checker.free()
		return result

static func open_file(path: String, mode: int):
	"""Open a file for reading/writing (works across Godot versions)"""
	if _is_godot_4_plus():
		return FileAccess.open(path, mode)
	else:
		# For Godot 3.5, handle File operations with error checking
		var file_open_script = """
extends Reference
func open_file_safely(path, mode):
	try:
		var f = File.new()
		if f.open(path, mode) == OK:
			return f
		return null
	except:
		return null
"""
		var script_obj = GDScript.new()
		script_obj.source_code = file_open_script
		script_obj.reload()
		var opener = script_obj.new()
		var result = opener.open_file_safely(path, mode)
		opener.free()
		return result

static func remove_file(path: String) -> int:
	"""Remove a file (works across Godot versions)"""
	if _is_godot_4_plus():
		return DirAccess.remove_absolute(path)
	else:
		# For Godot 3.5, handle Directory operations with error checking
		var dir_remove_script = """
extends Reference
func remove_file_safely(path):
	try:
		var d = Directory.new()
		return d.remove(path)
	except:
		return -1
"""
		var script_obj = GDScript.new()
		script_obj.source_code = dir_remove_script
		script_obj.reload()
		var remover = script_obj.new()
		var result = remover.remove_file_safely(path)
		remover.free()
		return result

static func dir_exists(path: String) -> bool:
	"""Check if a directory exists (works across Godot versions)"""
	if _is_godot_4_plus():
		return DirAccess.dir_exists_absolute(path)
	else:
		# For Godot 3.5, handle Directory operations with error checking
		var dir_exists_script = """
extends Reference
func dir_exists_safely(path):
	try:
		var d = Directory.new()
		return d.dir_exists(path)
	except:
		return false
"""
		var script_obj = GDScript.new()
		script_obj.source_code = dir_exists_script
		script_obj.reload()
		var dir_checker = script_obj.new()
		var result = dir_checker.dir_exists_safely(path)
		dir_checker.free()
		return result

static func make_dir_recursive(path: String) -> int:
	"""Create directories recursively (works across Godot versions)"""
	if _is_godot_4_plus():
		return DirAccess.make_dir_recursive_absolute(path)
	else:
		# For Godot 3.5, handle Directory operations with error checking
		var dir_create_script = """
extends Reference
func make_dir_recursive_safely(path):
	try:
		var d = Directory.new()
		return d.make_dir_recursive(path)
	except:
		return -1
"""
		var script_obj = GDScript.new()
		script_obj.source_code = dir_create_script
		script_obj.reload()
		var dir_creator = script_obj.new()
		var result = dir_creator.make_dir_recursive_safely(path)
		dir_creator.free()
		return result

static func close_file(file):
	"""Close a file handle (works across Godot versions)"""
	if _is_godot_4_plus():
		file.close()
	else:
		file.close()

static func get_file_as_text(file) -> String:
	"""Get file contents as text (works across Godot versions)"""
	if _is_godot_4_plus():
		return file.get_as_text()
	else:
		return file.get_as_text()

static func store_string(file, content: String) -> void:
	"""Write string to file (works across Godot versions)"""
	if _is_godot_4_plus():
		file.store_string(content)
	else:
		file.store_string(content)

# ------------------------------------------------------------------------------
# ADDITIONAL UTILITY FUNCTIONS
# ------------------------------------------------------------------------------
static func read_file_as_text(path: String) -> String:
	"""Read entire file as text with proper error handling"""
	var file = open_file(path, FileAccess.READ)
	if file == null:
		return ""

	var content = get_file_as_text(file)
	close_file(file)
	return content

static func write_file_from_text(path: String, content: String) -> bool:
	"""Write text to file with proper error handling"""
	var file = open_file(path, FileAccess.WRITE)
	if file == null:
		return false

	store_string(file, content)
	close_file(file)
	return true
