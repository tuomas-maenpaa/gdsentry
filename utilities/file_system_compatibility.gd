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
# CONSTANTS (Version-agnostic)
# ------------------------------------------------------------------------------
const READ = FileAccess.READ if _is_godot_4_plus() else File.READ
const WRITE = FileAccess.WRITE if _is_godot_4_plus() else File.WRITE

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
		var file = File.new()
		return file.file_exists(path)

static func open_file(path: String, mode: int):
	"""Open a file for reading/writing (works across Godot versions)"""
	if _is_godot_4_plus():
		return FileAccess.open(path, mode)
	else:
		var file = File.new()
		if file.open(path, mode) == OK:
			return file
		return null

static func remove_file(path: String) -> int:
	"""Remove a file (works across Godot versions)"""
	if _is_godot_4_plus():
		return DirAccess.remove_absolute(path)
	else:
		var dir = Directory.new()
		return dir.remove(path)

static func dir_exists(path: String) -> bool:
	"""Check if a directory exists (works across Godot versions)"""
	if _is_godot_4_plus():
		return DirAccess.dir_exists_absolute(path)
	else:
		var dir = Directory.new()
		return dir.dir_exists(path)

static func make_dir_recursive(path: String) -> int:
	"""Create directories recursively (works across Godot versions)"""
	if _is_godot_4_plus():
		return DirAccess.make_dir_recursive_absolute(path)
	else:
		var dir = Directory.new()
		return dir.make_dir_recursive(path)

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
