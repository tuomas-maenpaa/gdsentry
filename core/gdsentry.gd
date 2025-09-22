# GDSentry Framework Global Class
# Provides access to GDSentry classes without autoload complications
#
# This class provides static methods to access GDSentry classes
# so tests can use them without global registration issues
#
# Author: GDSentry Framework
# Created: Auto-generated for framework bootstrap

extends Node

# ------------------------------------------------------------------------------
# FRAMEWORK CONSTANTS
# ------------------------------------------------------------------------------
const VERSION = "1.0.0"
const FRAMEWORK_NAME = "GDSentry"

# ------------------------------------------------------------------------------
# STATIC CLASS ACCESS METHODS
# ------------------------------------------------------------------------------
static func SceneTreeTest() -> GDScript:
	"""Get the SceneTreeTest class"""
	return load("res://../base_classes/scene_tree_test.gd")

static func Node2DTest() -> GDScript:
	"""Get the Node2DTest class"""
	return load("res://../base_classes/node2d_test.gd")

static func GDTest() -> GDScript:
	"""Get the GDTest base class"""
	return load("res://../base_classes/gd_test.gd")

# ------------------------------------------------------------------------------
# STATIC UTILITY METHODS
# ------------------------------------------------------------------------------
static func get_version() -> String:
	"""Get the framework version"""
	return VERSION

static func get_framework_name() -> String:
	"""Get the framework name"""
	return FRAMEWORK_NAME

static func is_initialized() -> bool:
	"""Check if the framework is properly initialized"""
	return true

static func get_available_test_types() -> Array:
	"""Get list of available test types"""
	return [
		"SceneTreeTest",
		"Node2DTest",
		"VisualTest",
		"EventTest",
		"UITest",
		"PhysicsTest",
		"IntegrationTest",
		"PerformanceTest"
	]

static func get_available_assertions() -> Array:
	"""Get list of available assertion libraries"""
	return [
		"CollectionAssertions",
		"StringAssertions",
		"MathAssertions"
	]
