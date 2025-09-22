# GDSentry - IDE Integration System (Simple)
extends Node
class_name IDEIntegration

var detected_ide: String = "unknown"
var godot_version: String = ""
var editor_interface = null
var plugin_instance: EditorPlugin = null

var test_explorer_visible: bool = false
var test_results_panel: Control = null
var test_runner_panel: Control = null
var performance_monitor: Control = null

func _ready() -> void:
	detected_ide = "godot_editor"

func detect_ide_environment() -> void:
	if Engine.is_editor_hint():
		detected_ide = "godot_editor"
		godot_version = Engine.get_version_info().string
		if ClassDB.class_exists("EditorInterface"):
			editor_interface = EditorInterface
	elif OS.has_environment("VSCODE_PID"):
		detected_ide = "vscode"
	elif OS.has_environment("JETBRAINS_IDE"):
		detected_ide = "jetbrains"
	else:
		detected_ide = "unknown"
	print("IDE Integration: Detected " + detected_ide)

func setup_editor_integration() -> void:
	match detected_ide:
		"godot_editor":
			setup_godot_editor_integration()
		"vscode":
			setup_vscode_integration()
		"jetbrains":
			setup_jetbrains_integration()

func setup_godot_editor_integration() -> void:
	if not editor_interface:
		print("Godot Editor integration requires EditorInterface")
		return
	create_editor_plugin()
	add_editor_menu_items()
	create_dockable_panels()
	print("Godot Editor integration initialized")

func create_editor_plugin() -> EditorPlugin:
	plugin_instance = GDSentryEditorPlugin.new()
	plugin_instance.ide_integration = self
	if editor_interface:
		editor_interface.get_editor_main_screen().add_child(plugin_instance)
	return plugin_instance

func add_editor_menu_items() -> void:
	pass

func create_dockable_panels() -> void:
	test_results_panel = create_test_explorer_panel()
	if test_results_panel:
		add_dockable_panel("Test Explorer", test_results_panel)

	test_runner_panel = create_test_runner_panel()
	if test_runner_panel:
		add_dockable_panel("Test Runner", test_runner_panel)

	performance_monitor = create_performance_monitor_panel()
	if performance_monitor:
		add_dockable_panel("Performance Monitor", performance_monitor)

func add_dockable_panel(panel_name: String, panel: Control) -> void:
	if editor_interface and panel:
		editor_interface.get_editor_main_screen().add_child(panel)
		print("Added dockable panel: " + panel_name)

func create_test_explorer_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "🧪 GDSentry Test Explorer"
	header.add_child(title)
	
	var refresh_button = Button.new()
	refresh_button.text = "🔄 Refresh"
	refresh_button.connect("pressed", Callable(self, "refresh_test_explorer"))
	header.add_child(refresh_button)
	
	vbox.add_child(header)
	
	var test_tree = Tree.new()
	test_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	test_tree.connect("item_selected", Callable(self, "on_test_selected"))
	vbox.add_child(test_tree)
	
	var button_container = HBoxContainer.new()
	
	var run_selected_button = Button.new()
	run_selected_button.text = "▶️ Run Selected"
	run_selected_button.connect("pressed", Callable(self, "run_selected_tests"))
	button_container.add_child(run_selected_button)
	
	var run_all_button = Button.new()
	run_all_button.text = "▶️ Run All"
	run_all_button.connect("pressed", Callable(self, "run_all_tests"))
	button_container.add_child(run_all_button)
	
	var debug_button = Button.new()
	debug_button.text = "🐛 Debug"
	debug_button.connect("pressed", Callable(self, "debug_selected_test"))
	button_container.add_child(debug_button)
	
	vbox.add_child(button_container)
	panel.add_child(vbox)
	
	return panel

func refresh_test_explorer() -> void:
	print("🔄 Refreshing test explorer...")

func on_test_selected() -> void:
	print("📋 Test selected in explorer")

func run_selected_tests() -> void:
	print("▶️ Running selected tests...")

func run_all_tests() -> void:
	print("▶️ Running all tests...")

func debug_selected_test() -> void:
	print("🐛 Debugging selected test...")

func create_test_runner_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	
	var header = Label.new()
	header.text = "🚀 GDSentry Test Runner"
	vbox.add_child(header)
	
	var progress_bar = ProgressBar.new()
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(progress_bar)
	
	var status_label = Label.new()
	status_label.text = "Ready to run tests..."
	vbox.add_child(status_label)
	
	var results_text = TextEdit.new()
	results_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	results_text.editable = false
	vbox.add_child(results_text)
	
	var button_container = HBoxContainer.new()
	
	var run_button = Button.new()
	run_button.text = "▶️ Run Tests"
	run_button.connect("pressed", Callable(self, "run_tests_from_panel"))
	button_container.add_child(run_button)
	
	var stop_button = Button.new()
	stop_button.text = "⏹️ Stop"
	stop_button.connect("pressed", Callable(self, "stop_test_execution"))
	button_container.add_child(stop_button)
	
	var clear_button = Button.new()
	clear_button.text = "🗑️ Clear"
	clear_button.connect("pressed", Callable(self, "clear_test_results"))
	button_container.add_child(clear_button)
	
	vbox.add_child(button_container)
	panel.add_child(vbox)
	
	return panel

func run_tests_from_panel() -> void:
	print("▶️ Running tests from panel...")

func stop_test_execution() -> void:
	print("⏹️ Stopping test execution...")

func clear_test_results() -> void:
	print("🗑️ Clearing test results...")

func create_performance_monitor_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	
	var header = Label.new()
	header.text = "📊 Performance Monitor"
	vbox.add_child(header)
	
	var fps_container = HBoxContainer.new()
	var fps_label = Label.new()
	fps_label.text = "FPS: "
	fps_container.add_child(fps_label)
	
	var fps_value = Label.new()
	fps_value.text = "60.0"
	fps_container.add_child(fps_value)
	vbox.add_child(fps_container)
	
	var memory_container = HBoxContainer.new()
	var memory_label = Label.new()
	memory_label.text = "Memory: "
	memory_container.add_child(memory_label)
	
	var memory_value = Label.new()
	memory_value.text = "50.2 MB"
	memory_container.add_child(memory_value)
	vbox.add_child(memory_container)
	
	var graph_placeholder = ColorRect.new()
	graph_placeholder.color = Color(0.2, 0.2, 0.2, 0.5)
	graph_placeholder.custom_minimum_size = Vector2(0, 100)
	vbox.add_child(graph_placeholder)
	
	var button_container = HBoxContainer.new()
	
	var start_button = Button.new()
	start_button.text = "▶️ Start Monitoring"
	start_button.connect("pressed", Callable(self, "start_performance_monitoring"))
	button_container.add_child(start_button)
	
	var stop_button = Button.new()
	stop_button.text = "⏹️ Stop"
	stop_button.connect("pressed", Callable(self, "stop_performance_monitoring"))
	button_container.add_child(stop_button)
	
	vbox.add_child(button_container)
	panel.add_child(vbox)
	
	return panel

func start_performance_monitoring() -> void:
	print("▶️ Starting performance monitoring...")

func stop_performance_monitoring() -> void:
	print("⏹️ Stopping performance monitoring...")

func setup_vscode_integration() -> void:
	print("🔧 Setting up VSCode integration...")

func setup_jetbrains_integration() -> void:
	print("🔧 Setting up JetBrains integration...")

func _exit_tree() -> void:
	if plugin_instance:
		plugin_instance.queue_free()
	
	if test_results_panel:
		test_results_panel.queue_free()
	if test_runner_panel:
		test_runner_panel.queue_free()
	if performance_monitor:
		performance_monitor.queue_free()
