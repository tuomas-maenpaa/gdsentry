# GDSentry - Plugin System
# Extensible plugin architecture for GDSentry framework
#
# Features:
# - Plugin discovery and loading
# - Custom test types and assertions
# - Custom reporters and output formats
# - Integration plugins for external tools
# - Plugin dependency management
# - Hot-reload capability for development
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name PluginSystem

# ------------------------------------------------------------------------------
# PLUGIN SYSTEM CONSTANTS
# ------------------------------------------------------------------------------
const PLUGIN_CONFIG_FILE = "plugin.json"
const PLUGIN_DIRECTORY = "res://gdsentry_plugins/"
const BUILT_IN_PLUGINS_DIR = "res://gdsentry/plugins/"

# ------------------------------------------------------------------------------
# PLUGIN REGISTRIES
# ------------------------------------------------------------------------------
var loaded_plugins: Dictionary = {}
var plugin_registry: Dictionary = {}
var test_type_plugins: Dictionary = {}
var assertion_plugins: Dictionary = {}
var reporter_plugins: Dictionary = {}
var integration_plugins: Dictionary = {}

# ------------------------------------------------------------------------------
# PLUGIN LIFECYCLE STATE
# ------------------------------------------------------------------------------
var plugins_initialized: bool = false
var plugin_load_order: Array = []
var plugin_dependencies: Dictionary = {}

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize plugin system"""
	setup_plugin_directories()
	discover_built_in_plugins()
	initialize_plugin_system()

func setup_plugin_directories() -> void:
	"""Create necessary plugin directories"""
	var dirs = [
		PLUGIN_DIRECTORY,
		PLUGIN_DIRECTORY + "custom/",
		PLUGIN_DIRECTORY + "temp/",
		PLUGIN_DIRECTORY + "cache/"
	]

	for dir_path in dirs:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create plugin directory: " + dir_path)

func discover_built_in_plugins() -> void:
	"""Discover built-in plugins that come with GDSentry"""
	var built_in_dir = ProjectSettings.globalize_path(BUILT_IN_PLUGINS_DIR)

	if DirAccess.dir_exists_absolute(built_in_dir):
		var dir = DirAccess.open(built_in_dir)
		if dir:
			dir.list_dir_begin()
			var plugin_name = dir.get_next()

			while plugin_name != "":
				if dir.current_is_dir() and not plugin_name.begins_with("."):
					var plugin_path = BUILT_IN_PLUGINS_DIR + plugin_name + "/"
					load_plugin(plugin_path, true)

				plugin_name = dir.get_next()

			dir.list_dir_end()

func initialize_plugin_system() -> void:
	"""Initialize the plugin system and load all plugins"""
	if plugins_initialized:
		return

	print("🔌 Initializing GDSentry Plugin System...")

	# Load plugins in dependency order
	load_plugins_in_dependency_order()

	# Initialize all loaded plugins
	for plugin_id in plugin_load_order:
		var plugin = loaded_plugins[plugin_id]
		if plugin and plugin.has_method("initialize"):
			var success = plugin.initialize()
			if not success:
				push_warning("Failed to initialize plugin: " + plugin_id)

	# Register plugin components
	register_plugin_components()

	plugins_initialized = true
	print("✅ Plugin system initialized with " + str(loaded_plugins.size()) + " plugins")

# ------------------------------------------------------------------------------
# PLUGIN LOADING AND MANAGEMENT
# ------------------------------------------------------------------------------
func load_plugin(plugin_path: String, is_built_in: bool = false) -> bool:
	"""Load a plugin from the specified path"""
	var config_path = plugin_path + PLUGIN_CONFIG_FILE
	var global_config_path = ProjectSettings.globalize_path(config_path)

	if not FileAccess.file_exists(global_config_path):
		if OS.is_debug_build():
			print("⚠️  Plugin config not found: " + config_path)
		return false

	# Load plugin configuration
	var config_file = FileAccess.open(global_config_path, FileAccess.READ)
	if not config_file:
		push_error("Failed to open plugin config: " + config_path)
		return false

	var config_text = config_file.get_as_text()
	config_file.close()

	var config = JSON.parse_string(config_text)
	if config == null:
		push_error("Invalid plugin config JSON: " + config_path)
		return false

	# Validate plugin configuration
	if not validate_plugin_config(config):
		push_error("Invalid plugin configuration: " + config_path)
		return false

	var plugin_id = config.get("id", "")
	var plugin_name = config.get("name", "")

	# Check if plugin is already loaded
	if loaded_plugins.has(plugin_id):
		if OS.is_debug_build():
			print("⚠️  Plugin already loaded: " + plugin_id)
		return true

	# Load plugin script
	var script_path = plugin_path + config.get("script", "")
	var plugin_script = load(script_path)

	if not plugin_script:
		push_error("Failed to load plugin script: " + script_path)
		return false

	# Instantiate plugin
	var plugin_instance = plugin_script.new()
	if not plugin_instance:
		push_error("Failed to instantiate plugin: " + plugin_id)
		return false

	# Set plugin metadata
	plugin_instance.plugin_id = plugin_id
	plugin_instance.plugin_name = plugin_name
	plugin_instance.plugin_path = plugin_path
	plugin_instance.is_built_in = is_built_in
	plugin_instance.config = config

	# Store plugin dependencies
	var dependencies = config.get("dependencies", [])
	plugin_dependencies[plugin_id] = dependencies

	# Register plugin
	loaded_plugins[plugin_id] = plugin_instance
	plugin_registry[plugin_id] = config

	if OS.is_debug_build():
		print("📦 Loaded plugin: " + plugin_name + " (" + plugin_id + ")")

	return true

func validate_plugin_config(config: Dictionary) -> bool:
	"""Validate plugin configuration"""
	var required_fields = ["id", "name", "version", "type", "script"]

	for field in required_fields:
		if not config.has(field) or config[field].is_empty():
			push_error("Plugin config missing required field: " + field)
			return false

	var plugin_type = config.get("type", "")
	var valid_types = ["test_type", "assertion", "reporter", "integration", "utility"]

	if not valid_types.has(plugin_type):
		push_error("Invalid plugin type: " + plugin_type)
		return false

	return true

func load_plugins_in_dependency_order() -> void:
	"""Load plugins in dependency order to avoid circular dependencies"""
	var loaded = {}
	var loading = {}

	for plugin_id in plugin_dependencies.keys():
		if not loaded.has(plugin_id):
			load_plugin_with_dependencies(plugin_id, loaded, loading)

func load_plugin_with_dependencies(plugin_id: String, loaded: Dictionary, loading: Dictionary) -> void:
	"""Load a plugin and its dependencies recursively"""
	if loaded.has(plugin_id):
		return

	if loading.has(plugin_id):
		push_error("Circular dependency detected for plugin: " + plugin_id)
		return

	loading[plugin_id] = true

	# Load dependencies first
	for dependency in plugin_dependencies.get(plugin_id, []):
		if not loaded.has(dependency):
			load_plugin_with_dependencies(dependency, loaded, loading)

	loading.erase(plugin_id)
	loaded[plugin_id] = true
	plugin_load_order.append(plugin_id)

# ------------------------------------------------------------------------------
# PLUGIN REGISTRATION
# ------------------------------------------------------------------------------
func register_plugin_components() -> void:
	"""Register all plugin components with the framework"""
	for plugin_id in loaded_plugins.keys():
		var plugin = loaded_plugins[plugin_id]
		var config = plugin_registry[plugin_id]
		var plugin_type = config.get("type", "")

		match plugin_type:
			"test_type":
				register_test_type_plugin(plugin, config)
			"assertion":
				register_assertion_plugin(plugin, config)
			"reporter":
				register_reporter_plugin(plugin, config)
			"integration":
				register_integration_plugin(plugin, config)

func register_test_type_plugin(plugin, config: Dictionary) -> void:
	"""Register a test type plugin"""
	var test_types = config.get("test_types", [])

	for test_type in test_types:
		var type_name = test_type.get("name", "")
		if not type_name.is_empty():
			test_type_plugins[type_name] = plugin
			if OS.is_debug_build():
				print("📝 Registered test type: " + type_name)

func register_assertion_plugin(plugin, config: Dictionary) -> void:
	"""Register an assertion plugin"""
	var assertions = config.get("assertions", [])

	for assertion in assertions:
		var assertion_name = assertion.get("name", "")
		if not assertion_name.is_empty():
			assertion_plugins[assertion_name] = plugin
			if OS.is_debug_build():
				print("🔍 Registered assertion: " + assertion_name)

func register_reporter_plugin(plugin, config: Dictionary) -> void:
	"""Register a reporter plugin"""
	var reporters = config.get("reporters", [])

	for reporter in reporters:
		var reporter_name = reporter.get("name", "")
		if not reporter_name.is_empty():
			reporter_plugins[reporter_name] = plugin
			if OS.is_debug_build():
				print("📊 Registered reporter: " + reporter_name)

func register_integration_plugin(plugin, config: Dictionary) -> void:
	"""Register an integration plugin"""
	var integrations = config.get("integrations", [])

	for integration in integrations:
		var integration_name = integration.get("name", "")
		if not integration_name.is_empty():
			integration_plugins[integration_name] = plugin
			if OS.is_debug_build():
				print("🔗 Registered integration: " + integration_name)

# ------------------------------------------------------------------------------
# PLUGIN INTERFACE METHODS
# ------------------------------------------------------------------------------
func get_test_type_plugin(test_type: String):
	"""Get a test type plugin by name"""
	return test_type_plugins.get(test_type)

func get_assertion_plugin(assertion_name: String):
	"""Get an assertion plugin by name"""
	return assertion_plugins.get(assertion_name)

func get_reporter_plugin(reporter_name: String):
	"""Get a reporter plugin by name"""
	return reporter_plugins.get(reporter_name)

func get_integration_plugin(integration_name: String):
	"""Get an integration plugin by name"""
	return integration_plugins.get(integration_name)

func call_plugin_method(plugin, method_name: String, args: Array = []):
	"""Call a method on a plugin"""
	if not plugin or not plugin.has_method(method_name):
		return null

	return plugin.callv(method_name, args)

# ------------------------------------------------------------------------------
# PLUGIN LIFECYCLE MANAGEMENT
# ------------------------------------------------------------------------------
func enable_plugin(plugin_id: String) -> bool:
	"""Enable a loaded plugin"""
	if not loaded_plugins.has(plugin_id):
		push_error("Plugin not found: " + plugin_id)
		return false

	var plugin = loaded_plugins[plugin_id]
	if plugin.has_method("enable"):
		return plugin.enable()

	return true

func disable_plugin(plugin_id: String) -> bool:
	"""Disable a loaded plugin"""
	if not loaded_plugins.has(plugin_id):
		push_error("Plugin not found: " + plugin_id)
		return false

	var plugin = loaded_plugins[plugin_id]
	if plugin.has_method("disable"):
		return plugin.disable()

	return true

func reload_plugin(plugin_id: String) -> bool:
	"""Reload a plugin"""
	if not loaded_plugins.has(plugin_id):
		push_error("Plugin not found: " + plugin_id)
		return false

	var _config = plugin_registry[plugin_id]
	var plugin_path = loaded_plugins[plugin_id].plugin_path

	# Disable current plugin
	disable_plugin(plugin_id)

	# Remove from registries
	loaded_plugins.erase(plugin_id)

	# Reload plugin
	return load_plugin(plugin_path, loaded_plugins[plugin_id].is_built_in)

func unload_plugin(plugin_id: String) -> bool:
	"""Unload a plugin completely"""
	if not loaded_plugins.has(plugin_id):
		return true

	# Disable plugin first
	disable_plugin(plugin_id)

	# Remove from all registries
	loaded_plugins.erase(plugin_id)
	plugin_registry.erase(plugin_id)

	# Remove from type-specific registries
	for registry in [test_type_plugins, assertion_plugins, reporter_plugins, integration_plugins]:
		for key in registry.keys():
			if registry[key] == loaded_plugins[plugin_id]:
				registry.erase(key)

	plugin_load_order.erase(plugin_id)
	plugin_dependencies.erase(plugin_id)

	if OS.is_debug_build():
		print("📦 Unloaded plugin: " + plugin_id)

	return true

# ------------------------------------------------------------------------------
# PLUGIN DISCOVERY AND INSTALLATION
# ------------------------------------------------------------------------------
func discover_external_plugins() -> Array:
	"""Discover plugins from external sources"""
	var discovered_plugins = []

	# Scan plugin directory for external plugins
	var plugin_dir = ProjectSettings.globalize_path(PLUGIN_DIRECTORY)

	if DirAccess.dir_exists_absolute(plugin_dir):
		var dir = DirAccess.open(plugin_dir)
		if dir:
			dir.list_dir_begin()
			var plugin_name = dir.get_next()

			while plugin_name != "":
				if dir.current_is_dir() and not plugin_name.begins_with("."):
					var plugin_path = PLUGIN_DIRECTORY + plugin_name + "/"
					var config_path = plugin_path + PLUGIN_CONFIG_FILE

					if FileAccess.file_exists(ProjectSettings.globalize_path(config_path)):
						discovered_plugins.append({
							"name": plugin_name,
							"path": plugin_path,
							"config_path": config_path
						})

				plugin_name = dir.get_next()

			dir.list_dir_end()

	return discovered_plugins

func install_plugin(_plugin_url: String) -> bool:
	"""Install a plugin from a URL"""
	# This would handle downloading and installing plugins
	# For now, return false as this requires HTTP client implementation
	push_warning("Plugin installation from URL not implemented")
	return false

func create_plugin_template(plugin_type: String, plugin_name: String) -> String:
	"""Create a plugin template based on type"""
	var template = ""

	match plugin_type:
		"test_type":
			template = create_test_type_plugin_template(plugin_name)
		"assertion":
			template = create_assertion_plugin_template(plugin_name)
		"reporter":
			template = create_reporter_plugin_template(plugin_name)
		"integration":
			template = create_integration_plugin_template(plugin_name)

	return template

func create_test_type_plugin_template(plugin_name: String) -> String:
	"""Create a test type plugin template"""
	var template = "# GDSentry Test Type Plugin - " + plugin_name + "\n"
	template += "# Custom test type plugin for GDSentry framework\n\n"
	template += "extends Node\n\n"
	template += "class_name " + plugin_name + "TestTypePlugin\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN METADATA\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "var plugin_id: String = \"" + plugin_name.to_lower() + "\"\n"
	template += "var plugin_name: String = \"" + plugin_name + "\"\n"
	template += "var plugin_path: String = \"\"\n"
	template += "var is_built_in: bool = false\n"
	template += "var config: Dictionary = {}\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN LIFECYCLE\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func initialize() -> bool:\n"
	template += "\t\"\"\"Initialize the plugin\"\"\"\n"
	template += "\tprint(\"🔌 Initializing " + plugin_name + " plugin\")\n"
	template += "\treturn true\n\n"
	template += "func enable() -> bool:\n"
	template += "\t\"\"\"Enable the plugin\"\"\"\n"
	template += "\tprint(\"▶️ Enabling " + plugin_name + " plugin\")\n"
	template += "\treturn true\n\n"
	template += "func disable() -> bool:\n"
	template += "\t\"\"\"Disable the plugin\"\"\"\n"
	template += "\tprint(\"⏹️ Disabling " + plugin_name + " plugin\")\n"
	template += "\treturn true\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# TEST TYPE IMPLEMENTATION\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func get_test_base_class() -> String:\n"
	template += "\t\"\"\"Get the base class name for this test type\"\"\"\n"
	template += "\treturn \"GDSentry.SceneTreeTest\"\n\n"
	template += "func get_test_template() -> String:\n"
	template += "\t\"\"\"Get the test template for this test type\"\"\"\n"
	template += "\treturn \"\"\"extends GDSentry.SceneTreeTest\\n\\n"
	template += "func _ready():\\n"
	template += "\ttest_description = \"Custom " + plugin_name + " test\"\\n"
	template += "\ttest_tags = [\"custom\", \"" + plugin_name.to_lower() + "\"]\\n\\n"
	template += "func run_test_suite() -> void:\\n"
	template += "\trun_test(\"custom_test\", func(): return custom_test())\\n\\n"
	template += "func custom_test() -> bool:\\n"
	template += "\t# Your custom test implementation here\\n"
	template += "\treturn assert_true(true, \"Custom test passed\")\\n"
	template += "\"\"\"\n\n"
	template += "func get_supported_assertions() -> Array:\n"
	template += "\t\"\"\"Get list of supported assertions for this test type\"\"\"\n"
	template += "\treturn [\"assert_true\", \"assert_false\", \"assert_equals\"]\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# CLEANUP\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func _exit_tree() -> void:\n"
	template += "\t\"\"\"Cleanup plugin resources\"\"\"\n"
	template += "\tpass\n"

	return template

func create_assertion_plugin_template(plugin_name: String) -> String:
	"""Create an assertion plugin template"""
	var template = "# GDSentry Assertion Plugin - " + plugin_name + "\n"
	template += "# Custom assertion plugin for GDSentry framework\n\n"
	template += "extends Node\n\n"
	template += "class_name " + plugin_name + "AssertionPlugin\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN METADATA\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "var plugin_id: String = \"" + plugin_name.to_lower() + "_assertions\"\n"
	template += "var plugin_name: String = \"" + plugin_name + " Assertions\"\n"
	template += "var plugin_path: String = \"\"\n"
	template += "var is_built_in: bool = false\n"
	template += "var config: Dictionary = {}\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN LIFECYCLE\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func initialize() -> bool:\n"
	template += "\t\"\"\"Initialize the plugin\"\"\"\n"
	template += "\tprint(\"🔌 Initializing " + plugin_name + " assertion plugin\")\n"
	template += "\treturn true\n\n"
	template += "func enable() -> bool:\n"
	template += "\t\"\"\"Enable the plugin\"\"\"\n"
	template += "\tprint(\"▶️ Enabling " + plugin_name + " assertion plugin\")\n"
	template += "\treturn true\n\n"
	template += "func disable() -> bool:\n"
	template += "\t\"\"\"Disable the plugin\"\"\"\n"
	template += "\tprint(\"⏹️ Disabling " + plugin_name + " assertion plugin\")\n"
	template += "\treturn true\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# ASSERTION IMPLEMENTATION\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func assert_custom_condition(condition, message: String = \"\") -> bool:\n"
	template += "\t\"\"\"Custom assertion for " + plugin_name + " specific conditions\"\"\"\n"
	template += "\tif condition:\n"
	template += "\t\treturn true\n\n"
	template += "\tvar error_msg = message if not message.is_empty() else \"Custom condition failed\"\n"
	template += "\tprint(\"❌ \" + error_msg)\n"
	template += "\treturn false\n\n"
	template += "func assert_plugin_specific(value, expected, message: String = \"\") -> bool:\n"
	template += "\t\"\"\"Plugin-specific assertion\"\"\"\n"
	template += "\tif value == expected:\n"
	template += "\t\treturn true\n\n"
	template += "\tvar error_msg = message if not message.is_empty() else \"Plugin-specific assertion failed\"\n"
	template += "\tprint(\"❌ \" + error_msg)\n"
	template += "\treturn false\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# CLEANUP\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func _exit_tree() -> void:\n"
	template += "\t\"\"\"Cleanup plugin resources\"\"\"\n"
	template += "\tpass\n"

	return template

func create_reporter_plugin_template(plugin_name: String) -> String:
	"""Create a reporter plugin template"""
	var template = "# GDSentry Reporter Plugin - " + plugin_name + "\n"
	template += "# Custom reporter plugin for GDSentry framework\n\n"
	template += "extends Node\n\n"
	template += "class_name " + plugin_name + "ReporterPlugin\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN METADATA\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "var plugin_id: String = \"" + plugin_name.to_lower() + "_reporter\"\n"
	template += "var plugin_name: String = \"" + plugin_name + " Reporter\"\n"
	template += "var plugin_path: String = \"\"\n"
	template += "var is_built_in: bool = false\n"
	template += "var config: Dictionary = {}\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN LIFECYCLE\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func initialize() -> bool:\n"
	template += "\t\"\"\"Initialize the plugin\"\"\"\n"
	template += "\tprint(\"🔌 Initializing " + plugin_name + " reporter plugin\")\n"
	template += "\treturn true\n\n"
	template += "func enable() -> bool:\n"
	template += "\t\"\"\"Enable the plugin\"\"\"\n"
	template += "\tprint(\"▶️ Enabling " + plugin_name + " reporter plugin\")\n"
	template += "\treturn true\n\n"
	template += "func disable() -> bool:\n"
	template += "\t\"\"\"Disable the plugin\"\"\"\n"
	template += "\tprint(\"⏹️ Disabling " + plugin_name + " reporter plugin\")\n"
	template += "\treturn true\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# REPORTER IMPLEMENTATION\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func generate_report(test_results: Dictionary, format: String = \"custom\") -> String:\n"
	template += "\t\"\"\"Generate a custom report\"\"\"\n"
	template += "\tvar report = \"📊 " + plugin_name + " Test Report\\\\n\"\n"
	template += "\treport += \"=\" * 40 + \"\\\\n\\\\n\"\n\n"
	template += "\treport += \"Total Tests: \" + str(test_results.get(\"total_tests\", 0)) + \"\\\\n\"\n"
	template += "\treport += \"Passed: \" + str(test_results.get(\"passed_tests\", 0)) + \"\\\\n\"\n"
	template += "\treport += \"Failed: \" + str(test_results.get(\"failed_tests\", 0)) + \"\\\\n\"\n"
	template += "\treport += \"Duration: \" + str(test_results.get(\"total_time\", 0.0)) + \"s\\\\n\"\n\n"
	template += "\treturn report\n\n"
	template += "func save_report(report_content: String, file_path: String) -> bool:\n"
	template += "\t\"\"\"Save report to file\"\"\"\n"
	template += "\tvar global_path = ProjectSettings.globalize_path(file_path)\n"
	template += "\tvar file = FileAccess.open(global_path, FileAccess.WRITE)\n\n"
	template += "\tif file:\n"
	template += "\t\tfile.store_string(report_content)\n"
	template += "\t\tfile.close()\n"
	template += "\t\treturn true\n\n"
	template += "\treturn false\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# CLEANUP\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func _exit_tree() -> void:\n"
	template += "\t\"\"\"Cleanup plugin resources\"\"\"\n"
	template += "\tpass\n"

	return template

func create_integration_plugin_template(plugin_name: String) -> String:
	"""Create an integration plugin template"""
	var template = "# GDSentry Integration Plugin - " + plugin_name + "\n"
	template += "# Custom integration plugin for GDSentry framework\n\n"
	template += "extends Node\n\n"
	template += "class_name " + plugin_name + "IntegrationPlugin\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN METADATA\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "var plugin_id: String = \"" + plugin_name.to_lower() + "_integration\"\n"
	template += "var plugin_name: String = \"" + plugin_name + " Integration\"\n"
	template += "var plugin_path: String = \"\"\n"
	template += "var is_built_in: bool = false\n"
	template += "var config: Dictionary = {}\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# PLUGIN LIFECYCLE\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func initialize() -> bool:\n"
	template += "\t\"\"\"Initialize the plugin\"\"\"\n"
	template += "\tprint(\"🔌 Initializing " + plugin_name + " integration plugin\")\n"
	template += "\treturn true\n\n"
	template += "func enable() -> bool:\n"
	template += "\t\"\"\"Enable the plugin\"\"\"\n"
	template += "\tprint(\"▶️ Enabling " + plugin_name + " integration plugin\")\n"
	template += "\treturn true\n\n"
	template += "func disable() -> bool:\n"
	template += "\t\"\"\"Disable the plugin\"\"\"\n"
	template += "\tprint(\"⏹️ Disabling " + plugin_name + " integration plugin\")\n"
	template += "\treturn true\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# INTEGRATION IMPLEMENTATION\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func setup_integration() -> bool:\n"
	template += "\t\"\"\"Set up integration with external tool\"\"\"\n"
	template += "\tprint(\"🔗 Setting up " + plugin_name + " integration\")\n"
	template += "\treturn true\n\n"
	template += "func teardown_integration() -> bool:\n"
	template += "\t\"\"\"Clean up integration\"\"\"\n"
	template += "\tprint(\"🔗 Tearing down " + plugin_name + " integration\")\n"
	template += "\treturn true\n\n"
	template += "func send_test_results(results: Dictionary) -> bool:\n"
	template += "\t\"\"\"Send test results to external system\"\"\"\n"
	template += "\tprint(\"📤 Sending test results to " + plugin_name + "\")\n"
	template += "\treturn true\n\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "# CLEANUP\n"
	template += "# ------------------------------------------------------------------------------\n"
	template += "func _exit_tree() -> void:\n"
	template += "\t\"\"\"Cleanup plugin resources\"\"\"\n"
	template += "\tpass\n"

	return template

# ------------------------------------------------------------------------------
# PLUGIN MANAGEMENT UTILITIES
# ------------------------------------------------------------------------------
func list_loaded_plugins() -> Array:
	"""Get list of all loaded plugins"""
	var plugin_list = []

	for plugin_id in loaded_plugins.keys():
		var plugin = loaded_plugins[plugin_id]
		var config = plugin_registry.get(plugin_id, {})

		plugin_list.append({
			"id": plugin_id,
			"name": plugin.plugin_name,
			"type": config.get("type", "unknown"),
			"version": config.get("version", "unknown"),
			"built_in": plugin.is_built_in
		})

	return plugin_list

func get_plugin_info(plugin_id: String) -> Dictionary:
	"""Get detailed information about a specific plugin"""
	if not loaded_plugins.has(plugin_id):
		return {"error": "Plugin not found"}

	var plugin = loaded_plugins[plugin_id]
	var config = plugin_registry.get(plugin_id, {})

	return {
		"id": plugin_id,
		"name": plugin.plugin_name,
		"type": config.get("type", "unknown"),
		"version": config.get("version", "unknown"),
		"description": config.get("description", ""),
		"author": config.get("author", "unknown"),
		"dependencies": config.get("dependencies", []),
		"built_in": plugin.is_built_in,
		"path": plugin.plugin_path,
		"enabled": plugin.is_processing()
	}

func validate_plugin_dependencies() -> Dictionary:
	"""Validate that all plugin dependencies are satisfied"""
	var validation_results = {
		"valid": true,
		"missing_dependencies": [],
		"circular_dependencies": [],
		"warnings": []
	}

	for plugin_id in loaded_plugins.keys():
		var dependencies = plugin_dependencies.get(plugin_id, [])

		for dependency in dependencies:
			if not loaded_plugins.has(dependency):
				validation_results.missing_dependencies.append({
					"plugin": plugin_id,
					"missing_dependency": dependency
				})
				validation_results.valid = false

	return validation_results

# ------------------------------------------------------------------------------
# HOT RELOAD SUPPORT
# ------------------------------------------------------------------------------
func enable_hot_reload() -> void:
	"""Enable hot reload for plugin development"""
	# This would monitor plugin files for changes and reload them automatically
	print("🔄 Hot reload enabled for plugin development")

func disable_hot_reload() -> void:
	"""Disable hot reload"""
	print("🔄 Hot reload disabled")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup plugin system resources"""
	# Unload all plugins
	for plugin_id in loaded_plugins.keys():
		unload_plugin(plugin_id)

	loaded_plugins.clear()
	plugin_registry.clear()
	test_type_plugins.clear()
	assertion_plugins.clear()
	reporter_plugins.clear()
	integration_plugins.clear()
	plugin_load_order.clear()
	plugin_dependencies.clear()
