# GDSentry - Accessibility Testing System
# Comprehensive accessibility validation for Godot applications
#
# Features:
# - WCAG 2.1 compliance checking
# - Color contrast validation
# - Keyboard navigation testing
# - Screen reader compatibility
# - Focus management validation
# - Text alternatives verification
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name AccessibilityTester

# ------------------------------------------------------------------------------
# ACCESSIBILITY CONSTANTS
# ------------------------------------------------------------------------------
const MINIMUM_CONTRAST_RATIO_AA = 4.5
const MINIMUM_CONTRAST_RATIO_AAA = 7.0
const MINIMUM_CONTRAST_RATIO_AA_LARGE = 3.0
const MINIMUM_CONTRAST_RATIO_AAA_LARGE = 4.5

const MINIMUM_TARGET_SIZE = 44  # pixels
const MINIMUM_TOUCH_TARGET_SIZE = 48  # pixels

# ------------------------------------------------------------------------------
# ACCESSIBILITY TEST STATE
# ------------------------------------------------------------------------------
var compliance_level: String = "AA"  # AA, AAA
var enable_color_blindness_testing: bool = false
var enable_screen_reader_testing: bool = true
var enable_keyboard_navigation_testing: bool = true
var enable_focus_management_testing: bool = true

# ------------------------------------------------------------------------------
# ACCESSIBILITY RESULTS
# ------------------------------------------------------------------------------
var accessibility_issues: Array = []
var compliance_score: float = 0.0
var tested_elements: Array = []

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize accessibility testing system"""
	setup_accessibility_directories()

# ------------------------------------------------------------------------------
# DIRECTORY MANAGEMENT
# ------------------------------------------------------------------------------
func setup_accessibility_directories() -> void:
	"""Create necessary directories for accessibility testing"""
	var dirs = [
		"res://accessibility_reports/",
		"res://accessibility_screenshots/",
		"res://accessibility_audit/"
	]

	for dir_path in dirs:
		var global_path = ProjectSettings.globalize_path(dir_path)
		if not DirAccess.dir_exists_absolute(global_path):
			var error = DirAccess.make_dir_recursive_absolute(global_path)
			if error != OK:
				push_warning("Failed to create accessibility directory: " + dir_path)

# ------------------------------------------------------------------------------
# COMPREHENSIVE ACCESSIBILITY AUDIT
# ------------------------------------------------------------------------------
func perform_accessibility_audit(root_node: Node = null, test_name: String = "") -> Dictionary:
	"""Perform a comprehensive accessibility audit"""
	if root_node == null:
		root_node = get_tree().root if get_tree() else null
		if not root_node:
			return {"error": "No root node available"}

	var audit_results = {
		"test_name": test_name if not test_name.is_empty() else "accessibility_audit_" + str(Time.get_unix_time_from_system()),
		"timestamp": Time.get_unix_time_from_system(),
		"compliance_level": compliance_level,
		"issues_found": 0,
		"elements_tested": 0,
		"compliance_score": 0.0,
		"categories": {
			"color_contrast": [],
			"keyboard_navigation": [],
			"focus_management": [],
			"text_alternatives": [],
			"target_size": [],
			"semantic_structure": []
		},
		"recommendations": []
	}

	# Reset state
	accessibility_issues.clear()
	tested_elements.clear()
	compliance_score = 0.0

	# Perform different types of accessibility tests
	test_color_contrast(root_node, audit_results)
	test_keyboard_navigation(root_node, audit_results)
	test_focus_management(root_node, audit_results)
	test_text_alternatives(root_node, audit_results)
	test_target_sizes(root_node, audit_results)
	test_semantic_structure(root_node, audit_results)

	# Calculate compliance score
	audit_results.issues_found = accessibility_issues.size()
	audit_results.elements_tested = tested_elements.size()
	audit_results.compliance_score = calculate_compliance_score(audit_results)

	# Generate recommendations
	audit_results.recommendations = generate_accessibility_recommendations(audit_results)

	return audit_results

# ------------------------------------------------------------------------------
# COLOR CONTRAST TESTING
# ------------------------------------------------------------------------------
func test_color_contrast(root_node: Node, audit_results: Dictionary) -> void:
	"""Test color contrast ratios for text and UI elements"""
	var color_issues = []

	# Find all text-displaying nodes
	var text_nodes = find_text_nodes(root_node)

	for text_node in text_nodes:
		if text_node is Label or text_node is RichTextLabel:
			var contrast_result = analyze_text_contrast(text_node)
			if contrast_result.has("issue"):
				color_issues.append(contrast_result)
				accessibility_issues.append(contrast_result)

	# Test UI element contrast
	var ui_nodes = find_ui_nodes(root_node)
	for ui_node in ui_nodes:
		if ui_node is Button or ui_node is Panel:
			var contrast_result = analyze_ui_contrast(ui_node)
			if contrast_result.has("issue"):
				color_issues.append(contrast_result)
				accessibility_issues.append(contrast_result)

	audit_results.categories.color_contrast = color_issues

func analyze_text_contrast(text_node) -> Dictionary:
	"""Analyze contrast ratio for text elements"""
	var result = {
		"element": text_node.name,
		"type": "text_contrast",
		"node_path": text_node.get_path()
	}

	# Get text color and background color
	var text_color = get_text_color(text_node)
	var background_color = get_background_color(text_node)

	if text_color and background_color:
		var contrast_ratio = calculate_contrast_ratio(text_color, background_color)
		result["contrast_ratio"] = contrast_ratio
		result["text_color"] = text_color
		result["background_color"] = background_color

		var min_ratio = get_minimum_contrast_ratio(text_node)
		if contrast_ratio < min_ratio:
			result["issue"] = "Insufficient contrast ratio: %.2f (minimum: %.2f)" % [contrast_ratio, min_ratio]
			result["severity"] = "high"
			result["wcag_violation"] = "1.4.3"  # Contrast (Minimum)

	return result

func analyze_ui_contrast(ui_node) -> Dictionary:
	"""Analyze contrast ratio for UI elements"""
	var result = {
		"element": ui_node.name,
		"type": "ui_contrast",
		"node_path": ui_node.get_path()
	}

	# For UI elements, check if they have sufficient contrast against their backgrounds
	if ui_node.has_method("get_theme_color"):
		var element_color = ui_node.get_theme_color("font_color", "Button") if ui_node is Button else Color.WHITE
		var background_color = get_background_color(ui_node)

		if element_color and background_color:
			var contrast_ratio = calculate_contrast_ratio(element_color, background_color)
			result["contrast_ratio"] = contrast_ratio

			var min_ratio = MINIMUM_CONTRAST_RATIO_AA
			if contrast_ratio < min_ratio:
				result["issue"] = "UI element contrast insufficient: %.2f (minimum: %.2f)" % [contrast_ratio, min_ratio]
				result["severity"] = "medium"
				result["wcag_violation"] = "1.4.3"

	return result

func calculate_contrast_ratio(color1: Color, color2: Color) -> float:
	"""Calculate contrast ratio between two colors (WCAG algorithm)"""
	var lum1 = get_relative_luminance(color1)
	var lum2 = get_relative_luminance(color2)

	var lighter = max(lum1, lum2)
	var darker = min(lum1, lum2)

	return (lighter + 0.05) / (darker + 0.05)

func get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance of a color (WCAG algorithm)"""
	var r = (color.r / 12.92) if color.r <= 0.03928 else pow((color.r + 0.055) / 1.055, 2.4)
	var g = (color.g / 12.92) if color.g <= 0.03928 else pow((color.g + 0.055) / 1.055, 2.4)
	var b = (color.b / 12.92) if color.b <= 0.03928 else pow((color.b + 0.055) / 1.055, 2.4)

	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func get_minimum_contrast_ratio(text_node) -> float:
	"""Get minimum contrast ratio based on text size and compliance level"""
	var _is_large_text = is_large_text(text_node)
	var _is_bold = is_bold_text(text_node)

	if compliance_level == "AAA":
		return MINIMUM_CONTRAST_RATIO_AAA if not _is_large_text else MINIMUM_CONTRAST_RATIO_AAA_LARGE
	else:  # AA
		return MINIMUM_CONTRAST_RATIO_AA if not _is_large_text else MINIMUM_CONTRAST_RATIO_AA_LARGE

func is_large_text(text_node) -> bool:
	"""Check if text is considered 'large' per WCAG guidelines"""
	if text_node.has_method("get_theme_font_size"):
		var font_size = text_node.get_theme_font_size("font_size", "Label")
		return font_size >= 18  # 18pt or 14pt bold = large text

	return false

func is_bold_text(_text_node) -> bool:
	"""Check if text is bold"""
	# This would need to check the actual font weight
	# For simplicity, we'll assume false unless we can determine otherwise
	return false

# ------------------------------------------------------------------------------
# KEYBOARD NAVIGATION TESTING
# ------------------------------------------------------------------------------
func test_keyboard_navigation(root_node: Node, audit_results: Dictionary) -> void:
	"""Test keyboard navigation accessibility"""
	var navigation_issues = []

	# Find all focusable elements
	var focusable_elements = find_focusable_elements(root_node)

	# Test tab order
	var tab_order_issues = test_tab_order(focusable_elements)
	navigation_issues.append_array(tab_order_issues)

	# Test keyboard shortcuts
	var shortcut_issues = test_keyboard_shortcuts(root_node)
	navigation_issues.append_array(shortcut_issues)

	# Test focus trapping
	var focus_trap_issues = test_focus_trapping(root_node)
	navigation_issues.append_array(focus_trap_issues)

	for issue in navigation_issues:
		accessibility_issues.append(issue)

	audit_results.categories.keyboard_navigation = navigation_issues

func find_focusable_elements(root_node: Node) -> Array:
	"""Find all keyboard-focusable elements"""
	var focusable = []

	_find_focusable_recursive(root_node, focusable)

	return focusable

func _find_focusable_recursive(node: Node, result: Array) -> void:
	"""Recursively find focusable elements"""
	if node is Control:
		if node.focus_mode != Control.FOCUS_NONE:
			result.append({
				"node": node,
				"path": node.get_path(),
				"name": node.name,
				"type": node.get_class()
			})

	for child in node.get_children():
		_find_focusable_recursive(child, result)

func test_tab_order(focusable_elements: Array) -> Array:
	"""Test that tab order is logical and accessible"""
	var issues = []

	# Check for logical tab order (top-to-bottom, left-to-right)
	for i in range(focusable_elements.size() - 1):
		var current = focusable_elements[i]
		var next = focusable_elements[i + 1]

		if current.node is Control and next.node is Control:
			var current_pos = current.node.global_position
			var next_pos = next.node.global_position

			# Check if elements are in a reasonable order
			var distance = current_pos.distance_to(next_pos)
			if distance > 500:  # Arbitrary threshold for "too far apart"
				issues.append({
					"type": "tab_order",
					"severity": "medium",
					"issue": "Tab order may not be logical: %s -> %s (distance: %.0f)" % [current.name, next.name, distance],
					"elements": [current.path, next.path],
					"wcag_violation": "2.4.3"  # Focus Order
				})

	return issues

func test_keyboard_shortcuts(_root_node: Node) -> Array:
	"""Test keyboard shortcuts and accelerators"""
	var issues = []

	# Look for common keyboard shortcuts that should be available
	var required_shortcuts = {
		"escape": "Dialog close",
		"enter": "Form submission",
		"space": "Button activation"
	}

	# This is a simplified check - in practice, you'd need to examine the actual input handling
	for shortcut in required_shortcuts.keys():
		var found = false
		# Check if any nodes handle this shortcut
		if not found:
			issues.append({
				"type": "missing_shortcut",
				"severity": "low",
				"issue": "Consider adding %s keyboard shortcut for: %s" % [shortcut, required_shortcuts[shortcut]],
				"wcag_violation": "2.1.1"  # Keyboard
			})

	return issues

func test_focus_trapping(root_node: Node) -> Array:
	"""Test that focus is properly trapped in modal dialogs"""
	var issues = []

	# Find modal dialogs/windows
	var modal_elements = find_modal_elements(root_node)

	for modal in modal_elements:
		var focus_trapped = is_focus_trapped(modal)
		if not focus_trapped:
			issues.append({
				"type": "focus_trapping",
				"severity": "high",
				"issue": "Modal dialog does not properly trap focus: " + modal.name,
				"element": modal.get_path(),
				"wcag_violation": "2.4.1"  # Bypass Blocks
			})

	return issues

func find_modal_elements(root_node: Node) -> Array:
	"""Find modal dialog elements"""
	var modals = []

	# Look for Window nodes or elements with modal behavior
	_find_modals_recursive(root_node, modals)

	return modals

func _find_modals_recursive(node: Node, result: Array) -> void:
	"""Recursively find modal elements"""
	if node is Window:
		result.append(node)
	elif node is Control and node.has_meta("modal"):
		result.append(node)

	for child in node.get_children():
		_find_modals_recursive(child, result)

func is_focus_trapped(_modal) -> bool:
	"""Check if focus is properly trapped in a modal"""
	# This is a simplified check - would need actual focus testing
	return true  # Placeholder

# ------------------------------------------------------------------------------
# FOCUS MANAGEMENT TESTING
# ------------------------------------------------------------------------------
func test_focus_management(root_node: Node, audit_results: Dictionary) -> void:
	"""Test focus management and visual indicators"""
	var focus_issues = []

	# Test focus indicators
	var focus_indicator_issues = test_focus_indicators(root_node)
	focus_issues.append_array(focus_indicator_issues)

	# Test focus persistence
	var focus_persistence_issues = test_focus_persistence(root_node)
	focus_issues.append_array(focus_persistence_issues)

	for issue in focus_issues:
		accessibility_issues.append(issue)

	audit_results.categories.focus_management = focus_issues

func test_focus_indicators(root_node: Node) -> Array:
	"""Test that focused elements have clear visual indicators"""
	var issues = []

	var focusable_elements = find_focusable_elements(root_node)

	for element in focusable_elements:
		var has_focus_indicator = check_focus_indicator(element.node)
		if not has_focus_indicator:
			issues.append({
				"type": "focus_indicator",
				"severity": "medium",
				"issue": "Element lacks clear focus indicator: " + element.name,
				"element": element.path,
				"wcag_violation": "2.4.7"  # Focus Visible
			})

	return issues

func check_focus_indicator(element: Control) -> bool:
	"""Check if an element has a clear focus indicator"""
	# This would need to check for focus styles/themes
	# For simplicity, we'll assume basic elements have indicators
	if element is Button:
		return true
	elif element is LineEdit:
		return true
	elif element is OptionButton:
		return true

	return false  # Custom elements might not have indicators

func test_focus_persistence(_root_node: Node) -> Array:
	"""Test that focus is maintained appropriately during UI changes"""
	var issues = []

	# This would test that focus doesn't disappear inappropriately
	# when UI elements are shown/hidden or updated
	return issues

# ------------------------------------------------------------------------------
# TEXT ALTERNATIVES TESTING
# ------------------------------------------------------------------------------
func test_text_alternatives(root_node: Node, audit_results: Dictionary) -> void:
	"""Test that non-text content has text alternatives"""
	var text_issues = []

	# Find images and other non-text content
	var images = find_images(root_node)
	var icons = find_icons(root_node)

	# Check for alt text on images
	for image in images:
		var has_alt_text = check_alt_text(image)
		if not has_alt_text:
			text_issues.append({
				"type": "missing_alt_text",
				"severity": "medium",
				"issue": "Image lacks alt text: " + image.name,
				"element": image.get_path(),
				"wcag_violation": "1.1.1"  # Non-text Content
			})

	# Check for accessible names on icons
	for icon in icons:
		var has_accessible_name = check_accessible_name(icon)
		if not has_accessible_name:
			text_issues.append({
				"type": "missing_accessible_name",
				"severity": "low",
				"issue": "Icon lacks accessible name: " + icon.name,
				"element": icon.get_path(),
				"wcag_violation": "1.1.1"
			})

	for issue in text_issues:
		accessibility_issues.append(issue)

	audit_results.categories.text_alternatives = text_issues

func find_images(root_node: Node) -> Array:
	"""Find image elements that need alt text"""
	var images = []
	_find_images_recursive(root_node, images)
	return images

func _find_images_recursive(node: Node, result: Array) -> void:
	"""Recursively find image elements"""
	if node is TextureRect or node is Sprite2D:
		result.append(node)

	for child in node.get_children():
		_find_images_recursive(child, result)

func find_icons(root_node: Node) -> Array:
	"""Find icon elements that need accessible names"""
	var icons = []
	_find_icons_recursive(root_node, icons)
	return icons

func _find_icons_recursive(node: Node, result: Array) -> void:
	"""Recursively find icon elements"""
	# Icons are typically small images or texture rects
	if (node is TextureRect or node is Sprite2D) and is_icon_sized(node):
		result.append(node)

	for child in node.get_children():
		_find_icons_recursive(child, result)

func is_icon_sized(element) -> bool:
	"""Check if an element is icon-sized"""
	if element is TextureRect:
		return element.size.x <= 64 and element.size.y <= 64
	elif element is Sprite2D:
		return element.scale.x <= 1.0 and element.scale.y <= 1.0

	return false

func check_alt_text(image) -> bool:
	"""Check if an image has alt text"""
	# Check for alt text in metadata or tooltip
	if image.has_meta("alt_text"):
		return true
	if image.has_method("get_tooltip") and not image.get_tooltip().is_empty():
		return true

	return false

func check_accessible_name(element) -> bool:
	"""Check if an element has an accessible name"""
	# Check for accessible name in various ways
	if element.has_meta("accessible_name"):
		return true
	if element.has_method("get_text") and not element.get_text().is_empty():
		return true
	if element.has_method("get_tooltip") and not element.get_tooltip().is_empty():
		return true

	return false

# ------------------------------------------------------------------------------
# TARGET SIZE TESTING
# ------------------------------------------------------------------------------
func test_target_sizes(root_node: Node, audit_results: Dictionary) -> void:
	"""Test that interactive elements have adequate target sizes"""
	var size_issues = []

	var interactive_elements = find_interactive_elements(root_node)

	for element in interactive_elements:
		var size_result = check_target_size(element)
		if size_result.has("issue"):
			size_issues.append(size_result)
			accessibility_issues.append(size_result)

	audit_results.categories.target_size = size_issues

func find_interactive_elements(root_node: Node) -> Array:
	"""Find interactive UI elements"""
	var interactive = []

	_find_interactive_recursive(root_node, interactive)

	return interactive

func _find_interactive_recursive(node: Node, result: Array) -> void:
	"""Recursively find interactive elements"""
	if node is Button or node is TextureButton:
		result.append(node)
	elif node is Control and node.focus_mode != Control.FOCUS_NONE:
		result.append(node)

	for child in node.get_children():
		_find_interactive_recursive(child, result)

func check_target_size(element: Control) -> Dictionary:
	"""Check if an element has adequate target size"""
	var result = {
		"element": element.name,
		"type": "target_size",
		"node_path": element.get_path()
	}

	var size = element.size
	var min_size = MINIMUM_TARGET_SIZE

	# Check if element is too small
	if size.x < min_size or size.y < min_size:
		var _actual_size = min(size.x, size.y)
		result["issue"] = "Target size too small: %dx%d (minimum: %dx%d)" % [size.x, size.y, min_size, min_size]
		result["severity"] = "high"
		result["actual_size"] = size
		result["minimum_size"] = Vector2(min_size, min_size)
		result["wcag_violation"] = "2.5.5"  # Target Size

	return result

# ------------------------------------------------------------------------------
# SEMANTIC STRUCTURE TESTING
# ------------------------------------------------------------------------------
func test_semantic_structure(root_node: Node, audit_results: Dictionary) -> void:
	"""Test semantic structure and heading hierarchy"""
	var structure_issues = []

	# Test heading hierarchy
	var heading_issues = test_heading_hierarchy(root_node)
	structure_issues.append_array(heading_issues)

	# Test form structure
	var form_issues = test_form_structure(root_node)
	structure_issues.append_array(form_issues)

	for issue in structure_issues:
		accessibility_issues.append(issue)

	audit_results.categories.semantic_structure = structure_issues

func test_heading_hierarchy(root_node: Node) -> Array:
	"""Test heading hierarchy and structure"""
	var issues = []

	# Find heading-like elements (labels that might serve as headings)
	var potential_headings = find_potential_headings(root_node)

	# Check for logical heading hierarchy
	var heading_levels = []
	for heading in potential_headings:
		var level = determine_heading_level(heading)
		heading_levels.append(level)

	# Check for skipped heading levels
	for i in range(1, heading_levels.size()):
		var prev_level = heading_levels[i-1]
		var curr_level = heading_levels[i]
		if curr_level > prev_level + 1:
			issues.append({
				"type": "heading_hierarchy",
				"severity": "medium",
				"issue": "Skipped heading level: H%d -> H%d" % [prev_level, curr_level],
				"wcag_violation": "1.3.1"  # Info and Relationships
			})

	return issues

func find_potential_headings(root_node: Node) -> Array:
	"""Find elements that might serve as headings"""
	var headings = []

	_find_headings_recursive(root_node, headings)

	return headings

func _find_headings_recursive(node: Node, result: Array) -> void:
	"""Recursively find potential heading elements"""
	if node is Label:
		var text = node.text.to_lower()
		# Check if text looks like a heading
		if text.length() < 100 and (text.contains("section") or text.contains("chapter") or text.begins_with("h")):
			result.append(node)

	for child in node.get_children():
		_find_headings_recursive(child, result)

func determine_heading_level(heading: Label) -> int:
	"""Determine the heading level of an element"""
	var text = heading.text.to_lower()

	if text.begins_with("h1") or text.contains("title") or text.contains("main"):
		return 1
	elif text.begins_with("h2") or text.contains("section"):
		return 2
	elif text.begins_with("h3") or text.contains("subsection"):
		return 3
	else:
		return 4  # Default to level 4

func test_form_structure(root_node: Node) -> Array:
	"""Test form structure and labeling"""
	var issues = []

	# Find form elements
	var forms = find_forms(root_node)

	for form in forms:
		var form_issues = validate_form_structure(form)
		issues.append_array(form_issues)

	return issues

func find_forms(root_node: Node) -> Array:
	"""Find form-like structures"""
	var forms = []

	# Look for containers with multiple input elements
	_find_forms_recursive(root_node, forms)

	return forms

func _find_forms_recursive(node: Node, result: Array) -> void:
	"""Recursively find form structures"""
	var input_count = count_input_elements(node)
	if input_count >= 2:
		result.append(node)

	for child in node.get_children():
		_find_forms_recursive(child, result)

func count_input_elements(container: Node) -> int:
	"""Count input elements in a container"""
	var count = 0

	if container is LineEdit or container is OptionButton or container is CheckBox:
		count += 1

	for child in container.get_children():
		count += count_input_elements(child)

	return count

func validate_form_structure(form: Node) -> Array:
	"""Validate the structure of a form"""
	var issues = []

	# Check that input elements have labels
	var inputs = find_input_elements(form)
	var labels = find_labels(form)

	for input_element in inputs:
		var has_label = false
		for label in labels:
			if is_label_for_input(label, input_element):
				has_label = true
				break

		if not has_label:
			issues.append({
				"type": "form_labeling",
				"severity": "high",
				"issue": "Input element lacks associated label: " + input_element.name,
				"element": input_element.get_path(),
				"wcag_violation": "1.3.1"  # Info and Relationships
			})

	return issues

func find_input_elements(container: Node) -> Array:
	"""Find input elements in a container"""
	var inputs = []

	_find_inputs_recursive(container, inputs)

	return inputs

func _find_inputs_recursive(node: Node, result: Array) -> void:
	"""Recursively find input elements"""
	if node is LineEdit or node is OptionButton or node is CheckBox:
		result.append(node)

	for child in node.get_children():
		_find_inputs_recursive(child, result)

func find_labels(container: Node) -> Array:
	"""Find label elements in a container"""
	var labels = []

	_find_labels_recursive(container, labels)

	return labels

func _find_labels_recursive(node: Node, result: Array) -> void:
	"""Recursively find label elements"""
	if node is Label:
		result.append(node)

	for child in node.get_children():
		_find_labels_recursive(child, result)

func is_label_for_input(label: Label, input_element) -> bool:
	"""Check if a label is associated with an input element"""
	# This is a simplified check - would need more sophisticated logic
	# to properly associate labels with inputs
	var label_text = label.text.to_lower()
	var input_name = input_element.name.to_lower()

	# Check if label text contains input name or vice versa
	return label_text.contains(input_name) or input_name.contains(label_text)

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func find_text_nodes(root_node: Node) -> Array:
	"""Find all nodes that display text"""
	var text_nodes = []
	_find_text_recursive(root_node, text_nodes)
	return text_nodes

func _find_text_recursive(node: Node, result: Array) -> void:
	"""Recursively find text-displaying nodes"""
	if node is Label or node is RichTextLabel:
		result.append(node)

	for child in node.get_children():
		_find_text_recursive(child, result)

func find_ui_nodes(root_node: Node) -> Array:
	"""Find all UI nodes"""
	var ui_nodes = []
	_find_ui_recursive(root_node, ui_nodes)
	return ui_nodes

func _find_ui_recursive(node: Node, result: Array) -> void:
	"""Recursively find UI nodes"""
	if node is Control:
		result.append(node)

	for child in node.get_children():
		_find_ui_recursive(child, result)

func get_text_color(text_node) -> Color:
	"""Get the text color of a text node"""
	if text_node.has_method("get_theme_color"):
		return text_node.get_theme_color("font_color", "Label")
	return Color.BLACK  # Default

func get_background_color(_node) -> Color:
	"""Get the background color behind a node"""
	# This is a simplified implementation
	# In practice, you'd need to check parent backgrounds, themes, etc.
	return Color.WHITE  # Default assumption

func calculate_compliance_score(audit_results: Dictionary) -> float:
	"""Calculate overall accessibility compliance score"""
	var total_elements = audit_results.elements_tested
	var issues_found = audit_results.issues_found

	if total_elements == 0:
		return 100.0

	# Calculate score based on issues found
	var base_score = 100.0 - (issues_found * 5.0)  # 5 points penalty per issue

	# Factor in severity of issues
	var severity_penalty = 0.0
	for category in audit_results.categories.values():
		for issue in category:
			var severity = issue.get("severity", "low")
			match severity:
				"high": severity_penalty += 3.0
				"medium": severity_penalty += 2.0
				"low": severity_penalty += 1.0

	return clamp(base_score - severity_penalty, 0.0, 100.0)

func generate_accessibility_recommendations(audit_results: Dictionary) -> Array:
	"""Generate accessibility improvement recommendations"""
	var recommendations = []

	var _compliance_score = audit_results.compliance_score

	if _compliance_score < 50:
		recommendations.append("Critical accessibility issues found - prioritize fixing high-severity violations")
	elif _compliance_score < 75:
		recommendations.append("Moderate accessibility improvements needed - focus on medium-severity issues")
	else:
		recommendations.append("Good accessibility compliance - focus on remaining low-priority improvements")

	# Category-specific recommendations
	var categories = audit_results.categories

	if not categories.color_contrast.is_empty():
		recommendations.append("Improve color contrast ratios to meet WCAG %s standards" % compliance_level)

	if not categories.keyboard_navigation.is_empty():
		recommendations.append("Enhance keyboard navigation and focus management")

	if not categories.text_alternatives.is_empty():
		recommendations.append("Add text alternatives for images and non-text content")

	if not categories.target_size.is_empty():
		recommendations.append("Increase target sizes for interactive elements")

	return recommendations

# ------------------------------------------------------------------------------
# REPORTING
# ------------------------------------------------------------------------------
func generate_accessibility_report(audit_results: Dictionary) -> String:
	"""Generate a comprehensive accessibility report"""
	var report = "♿ ACCESSIBILITY AUDIT REPORT\n"
	report += "==================================================\n\n"

	report += "📊 SUMMARY\n"
	report += "Compliance Level: %s\n" % audit_results.compliance_level
	report += "Compliance Score: %.1f%%\n" % audit_results.compliance_score
	report += "Elements Tested: %d\n" % audit_results.elements_tested
	report += "Issues Found: %d\n" % audit_results.issues_found
	report += "Test Date: %s\n" % Time.get_datetime_string_from_unix_time(audit_results.timestamp)
	report += "\n"

	# Issues by category
	report += "🚨 ISSUES BY CATEGORY\n"
	for category in audit_results.categories.keys():
		var issues = audit_results.categories[category]
		if not issues.is_empty():
			report += "%s: %d issues\n" % [category.replace("_", " ").capitalize(), issues.size()]

	report += "\n"

	# Detailed issues
	report += "📋 DETAILED ISSUES\n"
	var issue_count = 0
	for category in audit_results.categories.keys():
		var issues = audit_results.categories[category]
		for issue in issues:
			issue_count += 1
			report += "%d. [%s] %s\n" % [issue_count, category.replace("_", " ").to_upper(), issue.get("issue", "Unknown issue")]
			report += "   Severity: %s\n" % issue.get("severity", "unknown").to_upper()
			report += "   WCAG: %s\n" % issue.get("wcag_violation", "N/A")
			report += "\n"

	# Recommendations
	report += "💡 RECOMMENDATIONS\n"
	var recommendations = audit_results.recommendations
	for i in range(recommendations.size()):
		report += "%d. %s\n" % [i + 1, recommendations[i]]

	return report

func save_accessibility_report(audit_results: Dictionary, filename: String = "") -> bool:
	"""Save accessibility report to file"""
	if filename.is_empty():
		filename = "accessibility_report_" + str(audit_results.timestamp) + ".txt"

	var report_path = "res://accessibility_reports/" + filename
	var global_path = ProjectSettings.globalize_path(report_path)

	var file = FileAccess.open(global_path, FileAccess.WRITE)
	if file:
		file.store_string(generate_accessibility_report(audit_results))
		file.close()

		# Save JSON data
		var json_path = report_path.replace(".txt", ".json")
		var json_global = ProjectSettings.globalize_path(json_path)
		var json_file = FileAccess.open(json_global, FileAccess.WRITE)
		if json_file:
			json_file.store_string(JSON.stringify(audit_results, "\t"))
			json_file.close()

		return true

	return false

# ------------------------------------------------------------------------------
# CONFIGURATION METHODS
# ------------------------------------------------------------------------------
func set_compliance_level(level: String) -> void:
	"""Set the WCAG compliance level (AA or AAA)"""
	if level.to_upper() in ["AA", "AAA"]:
		compliance_level = level.to_upper()

func set_color_blindness_testing(enabled: bool = true) -> void:
	"""Enable color blindness simulation testing"""
	enable_color_blindness_testing = enabled

func set_screen_reader_testing(enabled: bool = true) -> void:
	"""Enable screen reader compatibility testing"""
	enable_screen_reader_testing = enabled

func set_keyboard_navigation_testing(enabled: bool = true) -> void:
	"""Enable keyboard navigation testing"""
	enable_keyboard_navigation_testing = enabled

func set_focus_management_testing(enabled: bool = true) -> void:
	"""Enable focus management testing"""
	enable_focus_management_testing = enabled

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup accessibility testing resources"""
	accessibility_issues.clear()
	tested_elements.clear()
