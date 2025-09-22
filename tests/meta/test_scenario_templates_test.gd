# GDSentry - Test Scenario Templates Test Suite
# Comprehensive testing of the TestScenarioTemplates framework
#
# This test validates all aspects of the scenario templates system including:
# - Template creation and configuration
# - Step and validation management
# - Template inheritance and composition
# - Scenario execution and result handling
# - Predefined template functionality
# - Batch execution and reporting
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends SceneTreeTest

class_name TestScenarioTemplatesTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive TestScenarioTemplates validation"
	test_tags = ["meta", "utilities", "scenario_templates", "templates", "execution"]
	test_priority = "high"
	test_category = "meta"

# ------------------------------------------------------------------------------
# SETUP AND TEARDOWN
# ------------------------------------------------------------------------------
var templates

func setup() -> void:
	"""Setup test environment"""
	templates = load("res://utilities/test_scenario_templates.gd").new()

func teardown() -> void:
	"""Cleanup test environment"""
	if templates:
		templates.queue_free()

# ------------------------------------------------------------------------------
# BASIC TEMPLATE CREATION TESTS
# ------------------------------------------------------------------------------
func test_template_creation() -> bool:
	"""Test basic template creation and configuration"""
	print("🧪 Testing basic template creation")

	var success = true

	# Test template creation
	var template = templates.create_template("test_template", "Test template description")
	success = success and assert_not_null(template, "Should create template")
	success = success and assert_equals(template._name, "test_template", "Should set template name")
	success = success and assert_equals(template._description, "Test template description", "Should set template description")

	# Test template configuration
	template.add_tag("test").add_tag("basic")
	success = success and assert_true(template.has_tag("test"), "Should add tags")
	success = success and assert_true(template.has_tag("basic"), "Should add multiple tags")

	template.set_timeout(60.0)
	success = success and assert_equals(template._timeout, 60.0, "Should set timeout")

	template.set_metadata("version", "1.0")
	success = success and assert_equals(template._metadata["version"], "1.0", "Should set metadata")

	template.set_variable("test_var", "test_value")
	success = success and assert_equals(template._variables["test_var"], "test_value", "Should set variables")

	return success

func test_step_management() -> bool:
	"""Test step creation and management"""
	print("🧪 Testing step management")

	var success = true

	var template = templates.create_template("step_test")

	# Test adding steps
	template.add_step("step1", func(): return "result1", "First step")
	template.add_step("step2", func(): return "result2", "Second step")

	success = success and assert_equals(template._steps.size(), 2, "Should add steps")

	# Test setup and teardown steps
	template.add_setup_step("setup", func(): return "setup_done", "Setup step")
	template.add_teardown_step("teardown", func(): return "cleanup_done", "Teardown step")

	success = success and assert_equals(template._setup_steps.size(), 1, "Should add setup step")
	success = success and assert_equals(template._teardown_steps.size(), 1, "Should add teardown step")

	# Test step insertion
	template.insert_step(1, "inserted_step", func(): return "inserted", "Inserted step")
	success = success and assert_equals(template._steps.size(), 3, "Should insert step")
	success = success and assert_equals(template._steps[1].name, "inserted_step", "Should insert at correct position")

	# Test step removal
	template.remove_step("inserted_step")
	success = success and assert_equals(template._steps.size(), 2, "Should remove step")

	return success

func test_validation_management() -> bool:
	"""Test validation creation and management"""
	print("🧪 Testing validation management")

	var success = true

	var template = templates.create_template("validation_test")

	# Test adding validations
	template.add_validation("validation1", func(): return true, "First validation")
	template.add_validation("validation2", func(): return false, "Second validation")

	success = success and assert_equals(template._validations.size(), 2, "Should add validations")

	# Test validation configuration
	var validation = template._validations[0]
	validation.set_severity("warning")
	success = success and assert_equals(validation.severity, "warning", "Should set severity")

	validation.set_timeout(5.0)
	success = success and assert_equals(validation.timeout, 5.0, "Should set timeout")

	return success

# ------------------------------------------------------------------------------
# TEMPLATE INHERITANCE TESTS
# ------------------------------------------------------------------------------
func test_template_inheritance() -> bool:
	"""Test template inheritance functionality"""
	print("🧪 Testing template inheritance")

	var success = true

	# Create parent template
	var parent_template = templates.create_template("parent_template", "Parent template")
	parent_template.add_tag("parent")
	parent_template.add_step("parent_step", func(): return "parent_result", "Parent step")
	parent_template.add_validation("parent_validation", func(): return true, "Parent validation")

	# Create child template
	var child_template = templates.create_template("child_template", "Child template")
	child_template.extend(parent_template)

	success = success and assert_not_null(child_template._parent_template, "Should set parent template")
	success = success and assert_equals(child_template._parent_template._name, "parent_template", "Should reference correct parent")

	# Test inheritance during execution
	var instance = child_template.generate()
	success = success and assert_not_null(instance, "Should create instance with inheritance")

	return success

func test_template_composition() -> bool:
	"""Test template composition functionality"""
	print("🧪 Testing template composition")

	var success = true

	# Create component templates
	var component1 = templates.create_template("component1")
	component1.add_step("comp1_step", func(): return "comp1_result")

	var component2 = templates.create_template("component2")
	component2.add_step("comp2_step", func(): return "comp2_result")

	# Create composite template
	var composite = templates.create_template("composite")
	composite.compose(component1)
	composite.compose(component2)

	success = success and assert_equals(composite._steps.size(), 2, "Should compose steps from components")
	success = success and assert_equals(composite._steps[0].name, "comp1_step", "Should maintain step order")
	success = success and assert_equals(composite._steps[1].name, "comp2_step", "Should add all component steps")

	return success

# ------------------------------------------------------------------------------
# SCENARIO EXECUTION TESTS
# ------------------------------------------------------------------------------
func test_scenario_execution() -> bool:
	"""Test scenario execution"""
	print("🧪 Testing scenario execution")

	var success = true

	# Create and configure template
	var template = templates.create_template("execution_test")
	template.add_step("simple_step", func(): return "success", "Simple test step")
	template.add_validation("simple_validation", func(): return true, "Simple validation")

	# Execute scenario
	var result = template.execute()

	success = success and assert_not_null(result, "Should return execution result")
	success = success and assert_true(result.success, "Should execute successfully")
	success = success and assert_equals(result.scenario_name, "execution_test", "Should set scenario name")
	success = success and assert_greater_than(result.execution_time, 0.0, "Should record execution time")

	# Check step results
	success = success and assert_equals(result.step_results.size(), 1, "Should have step results")
	var step_result = result.step_results[0]
	success = success and assert_true(step_result.success, "Step should succeed")
	success = success and assert_equals(step_result.result, "success", "Step should return correct result")

	# Check validation results
	success = success and assert_equals(result.validation_results.size(), 1, "Should have validation results")
	var validation_result = result.validation_results[0]
	success = success and assert_true(validation_result.success, "Validation should succeed")

	return success

func test_scenario_failure_handling() -> bool:
	"""Test scenario failure handling"""
	print("🧪 Testing scenario failure handling")

	var success = true

	# Create template with failing step
	var template = templates.create_template("failure_test")
	template.add_step("failing_step", func(): return null, "Step that fails")
	template.add_step("never_executed", func(): return "should_not_run", "This should not execute")

	# Execute scenario
	var result = template.execute()

	success = success and assert_false(result.success, "Should detect failure")
	success = success and assert_equals(result.step_results.size(), 1, "Should stop at first failure")
	success = success and assert_false(result.step_results[0].success, "Should record step failure")

	return success

# ------------------------------------------------------------------------------
# PREDEFINED TEMPLATE TESTS
# ------------------------------------------------------------------------------
func test_predefined_templates() -> bool:
	"""Test predefined template functionality"""
	print("🧪 Testing predefined templates")

	var success = true

	# Test template listing
	var template_names = templates.list_templates()
	success = success and assert_greater_than(template_names.size(), 0, "Should have predefined templates")

	# Test getting specific templates
	var registration_template = templates.get_template("user_registration")
	success = success and assert_not_null(registration_template, "Should find user_registration template")

	var login_template = templates.get_template("user_login")
	success = success and assert_not_null(login_template, "Should find user_login template")

	var purchase_template = templates.get_template("product_purchase")
	success = success and assert_not_null(purchase_template, "Should find product_purchase template")

	# Test template tags
	success = success and assert_true(registration_template.has_tag("authentication"), "Registration template should have authentication tag")
	success = success and assert_true(login_template.has_tag("login"), "Login template should have login tag")

	return success

func test_template_execution_examples() -> bool:
	"""Test execution of predefined templates"""
	print("🧪 Testing predefined template execution")

	var success = true

	# Test user registration template execution
	var registration_template = templates.get_template("user_registration")
	var registration_result = registration_template.execute()

	success = success and assert_not_null(registration_result, "Should execute registration template")
	success = success and assert_true(registration_result.success, "Registration should succeed")

	# Test user login template execution
	var login_template = templates.get_template("user_login")
	var login_result = login_template.execute()

	success = success and assert_not_null(login_result, "Should execute login template")
	success = success and assert_true(login_result.success, "Login should succeed")

	# Test product purchase template execution
	var purchase_template = templates.get_template("product_purchase")
	var purchase_result = purchase_template.execute()

	success = success and assert_not_null(purchase_result, "Should execute purchase template")
	success = success and assert_true(purchase_result.success, "Purchase should succeed")

	return success

# ------------------------------------------------------------------------------
# TEMPLATE MANAGEMENT TESTS
# ------------------------------------------------------------------------------
func test_template_management() -> bool:
	"""Test template management operations"""
	print("🧪 Testing template management")

	var success = true

	# Test template info
	var info = templates.get_template_info("user_registration")
	success = success and assert_not_null(info, "Should get template info")
	success = success and assert_equals(info["name"], "user_registration", "Should have correct name")
	success = success and assert_true(info["tags"].has("authentication"), "Should have authentication tag")

	# Test template filtering
	var auth_templates = templates.list_templates(["authentication"])
	success = success and assert_greater_than(auth_templates.size(), 0, "Should find authentication templates")
	success = success and assert_true(auth_templates.has("user_registration"), "Should include registration template")

	var ecommerce_templates = templates.list_templates(["ecommerce"])
	success = success and assert_greater_than(ecommerce_templates.size(), 0, "Should find ecommerce templates")
	success = success and assert_true(ecommerce_templates.has("product_purchase"), "Should include purchase template")

	return success

# ------------------------------------------------------------------------------
# BATCH EXECUTION TESTS
# ------------------------------------------------------------------------------
func test_batch_execution() -> bool:
	"""Test batch scenario execution"""
	print("🧪 Testing batch execution")

	var success = true

	# Create scenario runner
	var runner = templates.create_scenario_runner()
	success = success and assert_not_null(runner, "Should create scenario runner")

	# Test sequential execution
	var scenario_names = ["user_registration", "user_login"]
	var results = runner.run_scenarios(scenario_names)

	success = success and assert_equals(results.size(), 2, "Should execute all scenarios")
	success = success and assert_true(results[0].success, "First scenario should succeed")
	success = success and assert_true(results[1].success, "Second scenario should succeed")

	# Test summary report
	var report = runner.generate_summary_report()
	success = success and assert_equals(report["total_scenarios"], 2, "Should report correct total")
	success = success and assert_equals(report["successful_scenarios"], 2, "Should report correct success count")
	success = success and assert_equals(report["success_rate"], 100.0, "Should report 100% success rate")

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	print("🧪 Testing error handling")

	var success = true

	# Test getting non-existent template
	var null_template = templates.get_template("non_existent_template")
	success = success and assert_null(null_template, "Should return null for non-existent template")

	# Test template info for non-existent template
	var empty_info = templates.get_template_info("non_existent_template")
	success = success and assert_true(empty_info.is_empty(), "Should return empty info for non-existent template")

	# Test step execution with timeout
	var template = templates.create_template("timeout_test")
	template.add_step("slow_step", func():
		OS.delay_usec(100000)  # 100ms delay
		return "completed"
	)
	template.set_timeout(0.05)	# 50ms timeout

	var result = template.execute()
	success = success and assert_false(result.success, "Should timeout with short timeout")

	return success

# ------------------------------------------------------------------------------
# INTEGRATION TESTS
# ------------------------------------------------------------------------------
func test_template_with_data_generator() -> bool:
	"""Test template integration with TestDataGenerator"""
	print("🧪 Testing template integration with data generator")

	var success = true

	# Create template that uses TestDataGenerator
	var template = templates.create_template("data_integration_test")

	template.add_step("generate_user_data",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			var generated_user_data = data_generator.create_user()
			return generated_user_data
	)

	template.add_validation("user_data_valid",
		func(validation_user_data):
			return validation_user_data.has("id") and validation_user_data.has("email") and validation_user_data.email.contains("@")
	)

	# Execute template
	var result = template.execute()
	success = success and assert_true(result.success, "Should execute with data generator integration")

	# Verify generated data
	var user_data = result.step_results[0].result
	success = success and assert_not_null(user_data, "Should generate user data")
	success = success and assert_true(user_data.has("email"), "Should have email field")

	return success

# ------------------------------------------------------------------------------
# PERFORMANCE TESTS
# ------------------------------------------------------------------------------
func test_performance_templates() -> bool:
	"""Test performance-related templates"""
	print("🧪 Testing performance templates")

	var success = true

	# Test load test template
	var load_template = templates.get_template("load_test")
	success = success and assert_not_null(load_template, "Should find load test template")

	# Execute load test (with smaller dataset for testing)
	var result = load_template.execute()
	success = success and assert_not_null(result, "Should execute load test")

	return success

# ------------------------------------------------------------------------------
# TEST SUITE EXECUTION
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all TestScenarioTemplates tests"""
	print("\n🚀 Running TestScenarioTemplates Test Suite\n")

	# Basic Template Creation
	run_test("test_template_creation", func(): return test_template_creation())
	run_test("test_step_management", func(): return test_step_management())
	run_test("test_validation_management", func(): return test_validation_management())

	# Template Inheritance & Composition
	run_test("test_template_inheritance", func(): return test_template_inheritance())
	run_test("test_template_composition", func(): return test_template_composition())

	# Scenario Execution
	run_test("test_scenario_execution", func(): return test_scenario_execution())
	run_test("test_scenario_failure_handling", func(): return test_scenario_failure_handling())

	# Predefined Templates
	run_test("test_predefined_templates", func(): return test_predefined_templates())
	run_test("test_template_execution_examples", func(): return test_template_execution_examples())

	# Template Management
	run_test("test_template_management", func(): return test_template_management())

	# Batch Execution
	run_test("test_batch_execution", func(): return test_batch_execution())

	# Error Handling
	run_test("test_error_handling", func(): return test_error_handling())

	# Integration Tests
	run_test("test_template_with_data_generator", func(): return test_template_with_data_generator())
	run_test("test_performance_templates", func(): return test_performance_templates())

	print("\n✨ TestScenarioTemplates Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
