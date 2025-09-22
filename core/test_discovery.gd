# GDSentry - Test Discovery System
# Automatic discovery and categorization of test files
#
# Features:
# - Recursive directory scanning
# - Pattern-based test identification
# - Test categorization and tagging
# - Dependency resolution
# - Test filtering and selection
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name GDTestDiscovery

# ------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_TEST_DIRECTORIES: Array[String] = [
	"res://tests/",
	"res://gdsentry/examples/",
	"res://test/"
]

const TEST_BASE_CLASSES: Array[String] = [
	"GDTest",
	"SceneTreeTest",
	"NodeTest",
	"Node2DTest",
	"VisualTest",
	"EventTest",
	"UITest",
	"PhysicsTest",
	"IntegrationTest",
	"PerformanceTest"
]

# ------------------------------------------------------------------------------
# DISCOVERY RESULTS
# ------------------------------------------------------------------------------
class TestDiscoveryResult:
	var test_scripts: Array[Dictionary] = []
	var total_found: int = 0
	var categorized: Dictionary = {}
	var errors: Array[String] = []

	func add_test_script(path: String, category: String, metadata: Dictionary = {}) -> void:
		var test_info = {
			"path": path,
			"category": category,
			"metadata": metadata,
			"file_name": path.get_file(),
			"directory": path.get_base_dir()
		}
		test_scripts.append(test_info)
		total_found += 1

		if not categorized.has(category):
			categorized[category] = []
		categorized[category].append(test_info)

	func get_tests_by_category(category: String) -> Array:
		return categorized.get(category, [])

	func get_all_test_paths() -> Array[String]:
		var paths: Array[String] = []
		for test_info in test_scripts:
			paths.append(test_info.path)
		return paths

# ------------------------------------------------------------------------------
# MAIN DISCOVERY METHOD
# ------------------------------------------------------------------------------
func discover_tests(custom_directories: Array[String] = [], recursive: bool = true) -> TestDiscoveryResult:
	"""Discover all test scripts in the project"""
	var result = TestDiscoveryResult.new()

	# Use default directories if none specified
	var search_dirs = custom_directories if not custom_directories.is_empty() else DEFAULT_TEST_DIRECTORIES

	print("🔍 GDTestDiscovery: Starting test discovery...")
	print("   Search directories:", search_dirs)
	print("   Recursive search:", recursive)

	for dir_path in search_dirs:
		if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir_path)):
			_scan_directory(dir_path, result, recursive)
		else:
			print("⚠️  Directory not found: ", dir_path)

	print("✅ Discovery complete. Found", result.total_found, "test scripts")
	_print_discovery_summary(result)

	return result

# ------------------------------------------------------------------------------
# DIRECTORY SCANNING
# ------------------------------------------------------------------------------
func _scan_directory(dir_path: String, result: TestDiscoveryResult, recursive: bool = true) -> void:
	"""Scan a directory for test scripts"""
	var dir = DirAccess.open(dir_path)
	if not dir:
		result.errors.append("Cannot open directory: " + dir_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = dir_path.path_join(file_name)

		if dir.current_is_dir() and recursive and not file_name.begins_with("."):
			# Recurse into subdirectories
			_scan_directory(full_path, result, recursive)
		elif file_name.ends_with(".gd") and _is_test_script(full_path):
			var category = _categorize_test_script(full_path)
			var metadata = _extract_test_metadata(full_path)
			result.add_test_script(full_path, category, metadata)

		file_name = dir.get_next()

	dir.list_dir_end()

# ------------------------------------------------------------------------------
# TEST SCRIPT IDENTIFICATION
# ------------------------------------------------------------------------------
func _is_test_script(script_path: String) -> bool:
	"""Check if a script is a test script by examining its content"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return false

	var content = file.get_as_text()
	file.close()

	# Check for test base class inheritance
	for base_class in TEST_BASE_CLASSES:
		if content.find("extends " + base_class) != -1:
			return true

	# Check for test class name pattern
	# Temporarily disabled due to parsing issues
	# if content.find("class_name ") != -1:
	# 	var lines = content.split("\n")
	# 	for i in range(lines.size()):
	# 		var current_line = lines[i].strip_edges()
	# 		if current_line.begins_with("class_name "):
	# 			var class_name_part = current_line.substr(11)
	# 			var class_name = class_name_part.strip_edges()
	# 			if class_name.ends_with("Test"):
	# 				return true

	return false

func _categorize_test_script(script_path: String) -> String:
	"""Categorize a test script based on its content and path"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return "unknown"

	var content = file.get_as_text()
	file.close()

	# Check for specific test types
	if content.find("extends VisualTest") != -1 or content.find("extends Node2DTest") != -1:
		return "visual"
	elif content.find("extends UITest") != -1:
		return "ui"
	elif content.find("extends PhysicsTest") != -1:
		return "physics"
	elif content.find("extends EventTest") != -1:
		return "event"
	elif content.find("extends IntegrationTest") != -1:
		return "integration"
	elif content.find("extends PerformanceTest") != -1:
		return "performance"
	elif content.find("extends SceneTreeTest") != -1:
		return "unit"
	elif content.find("extends GDTest") != -1:
		return "general"

	# Fallback to path-based categorization
	var path_lower = script_path.to_lower()
	if path_lower.find("/visual/") != -1 or path_lower.find("/ui/") != -1:
		return "visual"
	elif path_lower.find("/physics/") != -1:
		return "physics"
	elif path_lower.find("/integration/") != -1:
		return "integration"
	elif path_lower.find("/performance/") != -1:
		return "performance"
	elif path_lower.find("/unit/") != -1:
		return "unit"

	return "general"

func _extract_test_metadata(script_path: String) -> Dictionary:
	"""Extract metadata from a test script"""
	var metadata = {}
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return metadata

	var content = file.get_as_text()
	file.close()

	var lines = content.split("\n")

	for line in lines:
		line = line.strip_edges()

		# Check for export variables that might be test metadata
		if line.begins_with("@export"):
			var var_line = line.substr(7).strip_edges()
			if var_line.find("test_") != -1:
				# Extract variable name
				var colon_pos = var_line.find(":")
				if colon_pos != -1:
					var var_name = var_line.substr(0, colon_pos).strip_edges()
					metadata[var_name] = "exported"

		# Check for test description comments
		if line.begins_with("#") and line.to_lower().find("test") != -1:
			if not metadata.has("description"):
				metadata["description"] = line.substr(1).strip_edges()

		# Check for tags
		if line.find("test_tags") != -1:
			var bracket_start = line.find("[")
			var bracket_end = line.find("]")
			if bracket_start != -1 and bracket_end != -1:
				var tags_str = line.substr(bracket_start + 1, bracket_end - bracket_start - 1)
				var tags = tags_str.split(",")
				for i in range(tags.size()):
					tags[i] = tags[i].strip_edges().trim_prefix('"').trim_suffix('"')
				metadata["tags"] = tags

	return metadata

# ------------------------------------------------------------------------------
# TEST FILTERING AND SELECTION
# ------------------------------------------------------------------------------
func filter_tests(discovery_result: TestDiscoveryResult, filters: Dictionary) -> TestDiscoveryResult:
	"""Filter test scripts based on criteria"""
	var filtered_result = TestDiscoveryResult.new()

	for test_info in discovery_result.test_scripts:
		if _matches_filters(test_info, filters):
			filtered_result.add_test_script(test_info.path, test_info.category, test_info.metadata)

	return filtered_result

func _matches_filters(test_info: Dictionary, filters: Dictionary) -> bool:
	"""Check if a test matches the given filters"""
	# Category filter
	if filters.has("category") and test_info.category != filters.category:
		return false

	# Tags filter
	if filters.has("tags"):
		var required_tags = filters.tags
		var test_tags = test_info.metadata.get("tags", [])
		for required_tag in required_tags:
			if not test_tags.has(required_tag):
				return false

	# Path pattern filter
	if filters.has("path_pattern"):
		var pattern = filters.path_pattern
		if not test_info.path.match(pattern):
			return false

	# Name pattern filter
	if filters.has("name_pattern"):
		var pattern = filters.name_pattern
		if not test_info.file_name.match(pattern):
			return false

	return true

# ------------------------------------------------------------------------------
# DEPENDENCY RESOLUTION
# ------------------------------------------------------------------------------
func resolve_dependencies(discovery_result: TestDiscoveryResult) -> Array:
	"""Resolve test dependencies and return execution order"""
	var test_graph = _build_dependency_graph(discovery_result)
	return _topological_sort(test_graph)

func _build_dependency_graph(discovery_result: TestDiscoveryResult) -> Dictionary:
	"""Build a dependency graph from test scripts"""
	var graph = {}

	for test_info in discovery_result.test_scripts:
		var dependencies = _extract_dependencies(test_info.path)
		graph[test_info.path] = dependencies

	return graph

func _extract_dependencies(script_path: String) -> Array[String]:
	"""Extract dependencies from a test script"""
	var dependencies = []
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return dependencies

	var content = file.get_as_text()
	file.close()

	# Look for @export var test_dependencies or similar patterns
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.find("test_dependencies") != -1 or line.find("dependencies") != -1:
			# This is a simplified extraction - could be enhanced
			var bracket_start = line.find("[")
			var bracket_end = line.find("]")
			if bracket_start != -1 and bracket_end != -1:
				var deps_str = line.substr(bracket_start + 1, bracket_end - bracket_start - 1)
				var deps = deps_str.split(",")
				for dep in deps:
					dep = dep.strip_edges().trim_prefix('"').trim_suffix('"')
					if not dep.is_empty():
						dependencies.append(dep)

	return dependencies

func _topological_sort(graph: Dictionary) -> Array:
	"""Perform topological sort on dependency graph"""
	var result = []
	var visited = {}
	var visiting = {}

	for node in graph.keys():
		if not visited.has(node):
			_topological_sort_visit(node, graph, visited, visiting, result)

	result.reverse()
	return result

func _topological_sort_visit(node: String, graph: Dictionary, visited: Dictionary, visiting: Dictionary, result: Array) -> void:
	"""Visit node in topological sort"""
	if visiting.has(node):
		push_error("Circular dependency detected involving: " + node)
		return

	if visited.has(node):
		return

	visiting[node] = true

	for dependency in graph[node]:
		_topological_sort_visit(dependency, graph, visited, visiting, result)

	visiting.erase(node)
	visited[node] = true
	result.append(node)

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func _print_discovery_summary(result: TestDiscoveryResult) -> void:
	"""Print a summary of discovery results"""
	print("\n📊 Discovery Summary:")
	print("   Total test scripts found:", result.total_found)

	if result.categorized.size() > 0:
		print("   Categorized by type:")
		for category in result.categorized.keys():
			var count = result.categorized[category].size()
			print("     •", category, ":", count)

	if result.errors.size() > 0:
		print("   Errors encountered:")
		for error in result.errors:
			print("     ❌", error)

# ------------------------------------------------------------------------------
# PUBLIC API METHODS
# ------------------------------------------------------------------------------
func discover_all_tests() -> TestDiscoveryResult:
	"""Convenience method to discover all tests in default locations"""
	return discover_tests()

func discover_tests_in_directory(dir_path: String) -> TestDiscoveryResult:
	"""Convenience method to discover tests in a specific directory"""
	return discover_tests([dir_path])

func get_test_categories() -> Array[String]:
	"""Get list of available test categories"""
	return ["unit", "visual", "ui", "physics", "event", "integration", "performance", "general"]

func validate_test_script(script_path: String) -> Dictionary:
	"""Validate a test script and return validation results"""
	var result = {
		"is_valid": false,
		"errors": [],
		"warnings": [],
		"suggestions": []
	}

	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		result.errors.append("Cannot open file: " + script_path)
		return result

	var content = file.get_as_text()
	file.close()

	# Check for required extends
	var has_valid_extend = false
	for base_class in TEST_BASE_CLASSES:
		if content.find("extends " + base_class) != -1:
			has_valid_extend = true
			break

	if not has_valid_extend:
		result.errors.append("Test script must extend a GDSentry base class")

	# Check for run_test_suite method
	if content.find("func run_test_suite") == -1:
		result.warnings.append("Test script should implement run_test_suite() method")

	# Check for proper structure
	if content.find("func _ready()") != -1 and content.find("run_test_suite()") == -1:
		result.suggestions.append("Consider calling run_test_suite() in _ready()")

	result.is_valid = result.errors.is_empty()

	return result
