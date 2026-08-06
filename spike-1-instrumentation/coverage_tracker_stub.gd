extends Node

# Minimal coverage tracker for spike testing
# Singleton that records line hits during test execution

var hits: Dictionary = {}  # { "file.gd": { line_num: hit_count } }
var enabled: bool = true

func _init():
	print("[CoverageTracker] Initialized")

static func hit(file: String, line: int) -> void:
	"""Record a line hit."""
	var tracker = _get_singleton()
	if tracker and tracker.enabled:
		if file not in tracker.hits:
			tracker.hits[file] = {}
		
		if line not in tracker.hits[file]:
			tracker.hits[file][line] = 0
		
		tracker.hits[file][line] += 1

static func enable() -> void:
	"""Enable coverage tracking."""
	var tracker = _get_singleton()
	if tracker:
		tracker.enabled = true
		print("[CoverageTracker] Enabled")

static func disable() -> void:
	"""Disable coverage tracking."""
	var tracker = _get_singleton()
	if tracker:
		tracker.enabled = false
		print("[CoverageTracker] Disabled")

static func reset() -> void:
	"""Clear all coverage data."""
	var tracker = _get_singleton()
	if tracker:
		tracker.hits.clear()
		print("[CoverageTracker] Reset")

static func get_report() -> Dictionary:
	"""Get the coverage data."""
	var tracker = _get_singleton()
	if tracker:
		return tracker.hits.duplicate(true)
	return {}

static func print_report() -> void:
	"""Print coverage report to console."""
	var tracker = _get_singleton()
	if not tracker:
		return
	
	print("\n=== Coverage Report ===")
	for file in tracker.hits:
		print("\nFile: %s" % file)
		var lines = tracker.hits[file].keys()
		lines.sort()
		for line in lines:
			var count = tracker.hits[file][line]
			print("  Line %d: %d hits" % [line, count])
	print("\n======================")

static func _get_singleton():
	"""Get the singleton instance."""
	# For this spike, we'll use a simple autoload approach
	# In production, this would be properly registered as autoload
	if not Engine.has_singleton("CoverageTracker"):
		# Fallback: try to get from root
		var root = Engine.get_main_loop().root
		if root:
			var tracker = root.get_node_or_null("/root/CoverageTracker")
			return tracker
	return null
