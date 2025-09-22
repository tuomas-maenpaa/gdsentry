# GDSentry - Editor Plugin
# Godot Editor integration for GDSentry testing framework
#
# Author: GDSentry Framework
# Version: 1.0.0

extends EditorPlugin

class_name GDSentryEditorPlugin

var ide_integration: IDEIntegration

func _enter_tree() -> void:
	"""Plugin activation"""
	print("🔌 GDSentry Editor Plugin activated")

	# Initialize IDE integration
	ide_integration = IDEIntegration.new()

	# Add custom types
	add_custom_type("GDSentryTestRunner", "Control", GDTestRunner, null)
	add_custom_type("GDSentryTestExplorer", "Control", GDTestDiscovery, null)

	# Add menu items
	add_tool_menu_item("Run GDSentry Tests", Callable(self, "run_gdsentry_tests"))
	add_tool_menu_item("Show Test Explorer", Callable(self, "show_test_explorer"))

func _exit_tree() -> void:
	"""Plugin deactivation"""
	print("🔌 GDSentry Editor Plugin deactivated")

	# Remove custom types
	remove_custom_type("GDSentryTestRunner")
	remove_custom_type("GDSentryTestExplorer")

func run_gdsentry_tests() -> void:
	"""Run GDSentry tests from editor menu"""
	print("▶️ Running GDSentry tests from editor...")

	if ide_integration:
		ide_integration.run_all_tests()

func show_test_explorer() -> void:
	"""Show test explorer panel"""
	print("📋 Showing test explorer...")

	if ide_integration:
		ide_integration.test_explorer_visible = true
		# Refresh the explorer
		ide_integration.refresh_test_explorer()
