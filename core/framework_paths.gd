# GDSentry - Framework Path Resolver
#
# Auto-detects the framework root so GDSentry works regardless of its folder
# name in the project (gdsentry/, .gdsentry/, addons/gdsentry/, or standalone).
#
# Resolution order:
# 1. Explicit framework_root override (authoritative; must pass marker check)
# 2. Self-locate from this script's resource_path
# 3. Candidate scan for marker core/test_manager.gd
# 4. Failure — never silently fall back to an unverified path
#
# Note: No class_name declaration. Scripts inside a directory beginning with
# "." are not scanned by Godot's editor and class_name would not be globally
# registered. Use the preloaded script object directly:
#
#   const _Paths = preload("./framework_paths.gd")
#   if not _Paths.setup(_Paths):
#       return
#   var root = _Paths.root()
#
# Author: GDSentry Framework
# Version: 1.0.0

extends RefCounted

const MARKER_RELATIVE := "core/test_manager.gd"

const CANDIDATES: Array[String] = [
	"res://gdsentry",
	"res://.gdsentry",
	"res://addons/gdsentry",
	"res://",
]

static var _root: String = ""
static var _last_strategy: String = ""

# Initialise from this script's resource_path (self-locate), then candidate scan.
# Returns false and clears _root on failure.
static func setup(this_script: GDScript) -> bool:
	_clear_root()
	if this_script == null:
		_fail("self-locate", "setup() received a null script")
		return false

	var script_path: String = this_script.resource_path
	if script_path.is_empty():
		_fail("self-locate", "script resource_path is empty")
		return _try_candidate_scan()

	var derived: String = _normalize_root(script_path.get_base_dir().get_base_dir())
	if _has_marker(derived):
		_root = derived
		_last_strategy = "self-locate"
		return true

	push_error(
		"GDSentry: self-locate derived '%s' but marker '%s' is missing; trying candidates"
		% [derived, MARKER_RELATIVE]
	)
	return _try_candidate_scan()

# Initialise with an authoritative override. Must pass marker check or fail.
static func setup_with_override(root_path: String) -> bool:
	_clear_root()
	var normalized: String = _normalize_root(root_path)
	if normalized.is_empty():
		_fail("override", "framework_root override is empty")
		return false

	if not _has_marker(normalized):
		_fail(
			"override",
			"framework_root '%s' does not contain marker '%s'" % [normalized, MARKER_RELATIVE]
		)
		return false

	_root = normalized
	_last_strategy = "override"
	return true

# Convenience: override if non-empty, otherwise self-locate via this_script.
static func setup_from_config(this_script: GDScript, framework_root_override: String = "") -> bool:
	if not framework_root_override.strip_edges().is_empty():
		return setup_with_override(framework_root_override)
	return setup(this_script)

static func root() -> String:
	return _root

static func is_ready() -> bool:
	return not _root.is_empty()

static func last_strategy() -> String:
	return _last_strategy

static func framework(relative_path: String) -> String:
	return _join(_root, relative_path)

static func base_class(file_name: String) -> String:
	return _join(_join(_root, "base_classes"), file_name)

static func reporter(relative_path: String) -> String:
	return _join(_join(_root, "reporters"), relative_path)

static func utility(file_name: String) -> String:
	return _join(_join(_root, "utilities"), file_name)

static func examples() -> String:
	return _join(_root, "examples")

static func core(file_name: String = "") -> String:
	if file_name.is_empty():
		return _join(_root, "core")
	return _join(_join(_root, "core"), file_name)

static func test_types(file_name: String = "") -> String:
	if file_name.is_empty():
		return _join(_root, "test_types")
	return _join(_join(_root, "test_types"), file_name)

static func has_marker_at(root_path: String) -> bool:
	return _has_marker(_normalize_root(root_path))

static func clear() -> void:
	"""Clear resolved root without logging (for tests / re-init)."""
	_clear_root()

static func _try_candidate_scan() -> bool:
	var tried: Array[String] = []
	for candidate in CANDIDATES:
		var normalized: String = _normalize_root(candidate)
		tried.append(normalized)
		if _has_marker(normalized):
			_root = normalized
			_last_strategy = "candidate:%s" % normalized
			return true

	_fail(
		"candidate-scan",
		"could not locate GDSentry framework root (marker '%s'). Tried: %s. Set framework_root in gdsentry_config.tres or install under gdsentry/, .gdsentry/, or addons/gdsentry/."
		% [MARKER_RELATIVE, ", ".join(tried)]
	)
	return false

static func _has_marker(root_path: String) -> bool:
	if root_path.is_empty():
		return false
	var marker_path: String = _join(root_path, MARKER_RELATIVE)
	return ResourceLoader.exists(marker_path) or FileAccess.file_exists(marker_path)

static func _normalize_root(path: String) -> String:
	var cleaned: String = path.strip_edges()
	while cleaned.ends_with("/") and cleaned != "res://":
		cleaned = cleaned.left(cleaned.length() - 1)
	if cleaned == "res:":
		return "res://"
	return cleaned

static func _join(base: String, relative: String) -> String:
	if base.is_empty():
		return relative
	if relative.is_empty():
		return base
	if base.ends_with("/"):
		return base + relative.lstrip("/")
	return base + "/" + relative.lstrip("/")

static func _clear_root() -> void:
	_root = ""
	_last_strategy = ""

static func _fail(strategy: String, message: String) -> void:
	_clear_root()
	push_error("GDSentry framework root resolution failed [%s]: %s" % [strategy, message])
