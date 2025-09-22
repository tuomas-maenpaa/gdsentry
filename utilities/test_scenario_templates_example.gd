# GDSentry - Test Scenario Templates Usage Examples
# Practical examples demonstrating how to use the TestScenarioTemplates framework
#
# This file provides comprehensive examples of using the TestScenarioTemplates
# for various testing scenarios including:
# - Using predefined templates
# - Creating custom templates
# - Template inheritance and composition
# - Batch execution of multiple scenarios
# - Integration with GDSentry test cases
# - Advanced template customization
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestScenarioTemplatesExample

# ------------------------------------------------------------------------------
# EXAMPLE SETUP
# ------------------------------------------------------------------------------
var templates

func _ready() -> void:
	"""Initialize the example"""
	templates = load("res://utilities/test_scenario_templates.gd").new()
	add_child(templates)

	print("🎯 GDSentry TestScenarioTemplates Examples")
	print("=======================================\n")

	run_examples()

# ------------------------------------------------------------------------------
# PREDEFINED TEMPLATE EXAMPLES
# ------------------------------------------------------------------------------
func example_predefined_templates() -> void:
	"""Example: Using predefined templates"""
	print("📋 Example 1: Predefined Templates")
	print("----------------------------------")

	# List all available templates
	var available_templates = templates.list_templates()
	print("Available Templates:")
	for template_name in available_templates:
		var info = templates.get_template_info(template_name)
		print("	 • %s: %s" % [template_name, info.description])
	print()

	# Execute user registration template
	print("Executing User Registration Template:")
	var registration_template = templates.get_template("user_registration")
	var registration_result = registration_template.execute()

	print("	 Result: %s" % ["SUCCESS" if registration_result.success else "FAILED"])
	print("	 Execution Time: %.3f seconds" % registration_result.execution_time)
	print("	 Steps Executed: %d" % registration_result.step_results.size())
	print("	 Validations Passed: %d" % registration_result.get_successful_validations().size())
	print()

	# Execute product purchase template
	print("Executing Product Purchase Template:")
	var purchase_template = templates.get_template("product_purchase")
	var purchase_result = purchase_template.execute()

	print("	 Result: %s" % ["SUCCESS" if purchase_result.success else "FAILED"])
	print("	 Execution Time: %.3f seconds" % purchase_result.execution_time)

	# Show detailed step results
	print("	 Step Details:")
	for step_result in purchase_result.step_results:
		var status = "✓" if step_result.success else "✗"
		print("	   %s %s: %.3fs" % [status, step_result.step_name, step_result.execution_time])
	print()

# ------------------------------------------------------------------------------
# CUSTOM TEMPLATE CREATION EXAMPLES
# ------------------------------------------------------------------------------
func example_custom_template_creation() -> void:
	"""Example: Creating custom templates"""
	print("🔧 Example 2: Custom Template Creation")
	print("--------------------------------------")

	# Create a custom API testing template
	var api_test_template = templates.create_template("api_health_check", "API health check workflow")
	api_test_template.add_tags(["api", "health", "monitoring"])

	# Configure template properties
	api_test_template.set_timeout(30.0)
	api_test_template.set_metadata("category", "infrastructure")
	api_test_template.set_metadata("owner", "devops_team")

	# Add setup step
	api_test_template.add_setup_step("initialize_api_client",
		func():
			print("	   Initializing API client...")
			return {
				"base_url": "https://api.example.com",
				"timeout": 10,
				"headers": {"Authorization": "Bearer test-token"}
			}
	)

	# Add main test steps
	api_test_template.add_step("check_api_status",
		func(_client_config):
			print("	   Checking API status...")
			OS.delay_usec(500000)  # Simulate network delay
			return {
				"status": "healthy",
				"response_time": 0.245,
				"version": "v2.1.0"
			}
	)

	api_test_template.add_step("validate_api_response",
		func(status_result):
			print("	   Validating API response...")
			return status_result.status == "healthy" and status_result.response_time < 1.0
	)

	# Add validations
	api_test_template.add_validation("api_healthy",
		func(validation_result): return validation_result.status == "healthy",
		"API must be in healthy state"
	)

	api_test_template.add_validation("response_time_acceptable",
		func(validation_result): return validation_result.response_time < 1.0,
		"Response time must be under 1 second"
	)

	api_test_template.add_validation("version_current",
		func(validation_result): return validation_result.version.begins_with("v2"),
		"API version must be v2.x"
	)

	# Execute the custom template
	print("Executing Custom API Health Check Template:")
	var result = api_test_template.execute()

	print("	 Result: %s" % ["SUCCESS" if result.success else "FAILED"])
	print("	 Total Steps: %d" % result.step_results.size())
	print("	 Total Validations: %d" % result.validation_results.size())
	print()

# ------------------------------------------------------------------------------
# TEMPLATE INHERITANCE EXAMPLES
# ------------------------------------------------------------------------------
func example_template_inheritance() -> void:
	"""Example: Template inheritance"""
	print("🔗 Example 3: Template Inheritance")
	print("----------------------------------")

	# Create base template
	var base_test_template = templates.create_template("base_test", "Base testing template")
	base_test_template.add_tag("base")

	base_test_template.add_setup_step("setup_environment",
		func():
			print("	   Setting up test environment...")
			return {"environment": "test", "timestamp": Time.get_unix_time_from_system()}
	)

	base_test_template.add_teardown_step("cleanup_environment",
		func():
			print("	   Cleaning up test environment...")
			return true
	)

	base_test_template.add_validation("environment_properly_setup",
		func(env): return env.has("environment") and env.environment == "test"
	)

	# Create child template that inherits from base
	var specific_test_template = templates.create_template("specific_test", "Specific test extending base")
	specific_test_template.extend(base_test_template)

	# Add specific functionality
	specific_test_template.add_step("run_specific_test",
		func(env):
			print("	   Running specific test logic...")
			return {"test_result": "passed", "env": env}
	)

	specific_test_template.add_validation("specific_test_passed",
		func(validation_result): return validation_result.test_result == "passed"
	)

	# Execute child template
	print("Executing Inherited Template:")
	var result = specific_test_template.execute()

	print("	 Result: %s" % ["SUCCESS" if result.success else "FAILED"])
	print("	 Inherited Setup Steps: %d" % base_test_template._setup_steps.size())
	print("	 Child Specific Steps: %d" % (specific_test_template._steps.size() - base_test_template._steps.size()))
	print("	 Total Steps Executed: %d" % result.step_results.size())
	print()

# ------------------------------------------------------------------------------
# TEMPLATE COMPOSITION EXAMPLES
# ------------------------------------------------------------------------------
func example_template_composition() -> void:
	"""Example: Template composition"""
	print("🧩 Example 4: Template Composition")
	print("----------------------------------")

	# Create component templates
	var authentication_component = templates.create_template("auth_component")
	authentication_component.add_step("authenticate_user",
		func():
			print("	   Authenticating user...")
			return {"user_id": "user_123", "authenticated": true}
	)

	var data_processing_component = templates.create_template("data_component")
	data_processing_component.add_step("process_data",
		func():
			print("	   Processing data...")
			return {"processed_records": 150, "success": true}
	)

	var reporting_component = templates.create_template("report_component")
	reporting_component.add_step("generate_report",
		func():
			print("	   Generating report...")
			return {"report_id": "report_456", "format": "PDF"}
	)

	# Compose a comprehensive workflow
	var comprehensive_workflow = templates.create_template("comprehensive_workflow", "Multi-component workflow")
	comprehensive_workflow.compose(authentication_component)
	comprehensive_workflow.compose(data_processing_component)
	comprehensive_workflow.compose(reporting_component)

	# Add workflow-specific validation
	comprehensive_workflow.add_validation("workflow_complete",
		func(results): return results.size() == 3 and results.all(func(r): return r.success)
	)

	# Execute composed workflow
	print("Executing Composed Workflow:")
	var result = comprehensive_workflow.execute()

	print("	 Result: %s" % ["SUCCESS" if result.success else "FAILED"])
	print("	 Components Integrated: 3")
	print("	 Total Steps: %d" % result.step_results.size())
	print("	 Execution Order:")
	for i in range(result.step_results.size()):
		var step_result = result.step_results[i]
		print("	   %d. %s" % [i + 1, step_result.step_name])
	print()

# ------------------------------------------------------------------------------
# BATCH EXECUTION EXAMPLES
# ------------------------------------------------------------------------------
func example_batch_execution() -> void:
	"""Example: Batch scenario execution"""
	print("📊 Example 5: Batch Execution")
	print("----------------------------")

	# Create scenario runner
	var runner = templates.create_scenario_runner()

	# Define scenarios to run
	var scenario_batch = [
		"user_registration",
		"user_login",
		"product_purchase",
		"form_submission"
	]

	print("Executing Scenario Batch:")
	print("	 Scenarios: %s" % str(scenario_batch))

	# Execute scenarios sequentially
	var start_time = Time.get_ticks_usec() / 1000000.0
	var results = runner.run_scenarios(scenario_batch)
	var end_time = Time.get_ticks_usec() / 1000000.0

	print("	 Total Execution Time: %.3f seconds" % (end_time - start_time))
	print()

	# Analyze results
	var successful_results = runner.get_successful_scenarios()
	var failed_results = runner.get_failed_scenarios()

	print("Batch Results Summary:")
	print("	 Total Scenarios: %d" % results.size())
	print("	 Successful: %d" % successful_results.size())
	print("	 Failed: %d" % failed_results.size())
	print("	 Success Rate: %.1f%%" % (successful_results.size() / float(results.size()) * 100.0))
	print()

	# Generate detailed report
	var report = runner.generate_summary_report()
	print("Detailed Report:")
	print("	 Average Execution Time: %.3f seconds" % report.average_execution_time)
	print("	 Total Execution Time: %.3f seconds" % report.total_execution_time)
	print()

	# Show individual scenario results
	print("Individual Scenario Results:")
	for result in results:
		var status = "✓" if result.success else "✗"
		print("	 %s %s: %.3fs" % [status, result.scenario_name, result.execution_time])
	print()

# ------------------------------------------------------------------------------
# ADVANCED TEMPLATE CUSTOMIZATION EXAMPLES
# ------------------------------------------------------------------------------
func example_advanced_customization() -> void:
	"""Example: Advanced template customization"""
	print("⚙️ Example 6: Advanced Customization")
	print("-----------------------------------")

	# Create template with advanced features
	var advanced_template = templates.create_template("advanced_workflow", "Advanced workflow with customization")
	advanced_template.add_tags(["advanced", "custom", "workflow"])

	# Set custom variables
	advanced_template.set_variable("max_retries", 3)
	advanced_template.set_variable("timeout_per_step", 15.0)
	advanced_template.set_variable("notification_enabled", true)

	# Add steps with custom logic
	advanced_template.add_step("initialize_with_config",
		func():
			print("	   Initializing with custom configuration...")
			return {
				"config": {
					"retries": advanced_template._variables.max_retries,
					"timeout": advanced_template._variables.timeout_per_step,
					"notifications": advanced_template._variables.notification_enabled
				},
				"start_time": Time.get_unix_time_from_system()
			}
	)

	advanced_template.add_step("execute_with_retry_logic",
		func(config):
			print("	   Executing with retry logic...")
			var attempt = 0
			var max_attempts = config.config.retries
			var operation_result = null

			while attempt < max_attempts:
				attempt += 1
				print("		 Attempt %d/%d..." % [attempt, max_attempts])

				# Simulate operation that might fail
				var success = randf() > 0.3	 # 70% success rate
				if success:
					operation_result = {
						"success": true,
						"attempts_used": attempt,
						"data": "operation_result_" + str(randi())
					}
					break
				else:
					print("		   Attempt %d failed, retrying..." % attempt)
					OS.delay_usec(100000)  # 100ms delay

			if not operation_result:
				operation_result = {"success": false, "error": "Max retries exceeded"}

			return operation_result
	)

	# Add conditional validation
	advanced_template.add_validation("operation_succeeded",
		func(validation_result): return validation_result.success,
		"Main operation must succeed"
	).set_severity("error")

	advanced_template.add_validation("reasonable_attempt_count",
		func(validation_result): return validation_result.attempts_used <= 2,
		"Should not require excessive retries"
	).set_severity("warning")

	# Execute advanced template
	print("Executing Advanced Template:")
	var result = advanced_template.execute()

	print("	 Result: %s" % ["SUCCESS" if result.success else "FAILED"])
	print("	 Custom Variables Used: %d" % advanced_template._variables.size())
	print("	 Step Execution Details:")

	for step_result in result.step_results:
		print("	   • %s: %s (%.3fs)" % [
			step_result.step_name,
			"SUCCESS" if step_result.success else "FAILED",
			step_result.execution_time
		])

	if not result.validation_results.is_empty():
		print("	 Validation Results:")
		for validation_result in result.validation_results:
			var status = "✓" if validation_result.success else "✗"
			print("	   %s %s (%s)" % [
				status,
				validation_result.validation_name,
				validation_result.error_message if not validation_result.success else "passed"
			])
	print()

# ------------------------------------------------------------------------------
# GDSENTRY INTEGRATION EXAMPLES
# ------------------------------------------------------------------------------
func example_gdsentry_integration() -> void:
	"""Example: Integration with GDSentry test cases"""
	print("🔗 Example 7: GDSentry Integration")
	print("-------------------------------")

	print("This example shows how to integrate TestScenarioTemplates with GDSentry test cases:")
	print()

	# Example test case structure
	print("# Example GDSentry Test Case Structure:")
	print("extends SceneTreeTest")
	print("")
	print("var templates")
	print("")
	print("func setup():")
	print("	   templates = load(\"res://utilities/test_scenario_templates.gd\").new()")
	print("	   add_child(templates)")
	print("")
	print("func test_user_registration_workflow():")
	print("	   # Get predefined template")
	print("	   var registration_template = templates.get_template('user_registration')")
	print("	   ")
	print("	   # Execute scenario")
	print("	   var result = registration_template.execute()")
	print("	   ")
	print("	   # Assert results")
	print("	   assert_true(result.success, 'Registration should succeed')")
	print("	   assert_greater_than(result.step_results.size(), 0, 'Should have executed steps')")
	print("	   assert_equals(result.validation_results.size(), 2, 'Should have 2 validations')")
	print("")
	print("func test_custom_business_workflow():")
	print("	   # Create custom template for business logic")
	print("	   var business_template = templates.create_template('business_workflow')")
	print("	   business_template.add_step('validate_business_rules', func(): return true)")
	print("	   business_template.add_step('process_business_logic', func(): return {'result': 'success'})")
	print("	   business_template.add_validation('business_logic_executed', func(r): return r.result == 'success')")
	print("	   ")
	print("	   # Execute and verify")
	print("	   var result = business_template.execute()")
	print("	   assert_true(result.success)")
	print("")
	print("func test_batch_scenario_execution():")
	print("	   # Test multiple scenarios together")
	print("	   var runner = templates.create_scenario_runner()")
	print("	   var scenarios = ['user_registration', 'product_purchase', 'api_request']")
	print("	   var results = runner.run_scenarios(scenarios)")
	print("	   ")
	print("	   # Verify batch execution")
	print("	   assert_equals(results.size(), 3)")
	print("	   assert_true(results.all(func(r): return r.success), 'All scenarios should succeed')")
	print()

	print("Key Integration Points:")
	print("	 • Templates can be used directly in GDSentry test methods")
	print("	 • Template results integrate seamlessly with GDSentry assertions")
	print("	 • Batch execution enables comprehensive test suite validation")
	print("	 • Custom templates allow business-specific test scenarios")
	print()

# ------------------------------------------------------------------------------
# PERFORMANCE AND LOAD TESTING EXAMPLES
# ------------------------------------------------------------------------------
func example_performance_testing() -> void:
	"""Example: Performance and load testing"""
	print("⚡ Example 8: Performance Testing")
	print("-------------------------------")

	# Use predefined load test template
	var load_template = templates.get_template("load_test")

	print("Executing Load Test Template:")
	var start_time = Time.get_ticks_usec() / 1000000.0
	var load_result = load_template.execute()
	var end_time = Time.get_ticks_usec() / 1000000.0

	print("	 Load Test Duration: %.3f seconds" % (end_time - start_time))
	print("	 Result: %s" % ["SUCCESS" if load_result.success else "FAILED"])

	# Extract performance metrics from results
	if load_result.success and not load_result.step_results.is_empty():
		var load_step = load_result.step_results[1]	 # The "simulate_load" step
		if load_step.result and load_step.result.has("results"):
			var load_data = load_step.result
			var response_times = load_data.results.map(func(r): return r.response_time)
			var avg_response_time = response_times.reduce(func(acc, val): return acc + val, 0.0) / response_times.size()
			var max_response_time = response_times.max()
			var min_response_time = response_times.min()

			print("	 Performance Metrics:")
			print("	   Total Requests: %d" % load_data.total_requests)
			print("	   Successful Requests: %d" % load_data.successful_requests)
			print("	   Success Rate: %.1f%%" % (load_data.successful_requests / float(load_data.total_requests) * 100.0))
			print("	   Average Response Time: %.3f seconds" % avg_response_time)
			print("	   Min Response Time: %.3f seconds" % min_response_time)
			print("	   Max Response Time: %.3f seconds" % max_response_time)
	print()

# ------------------------------------------------------------------------------
# RUN ALL EXAMPLES
# ------------------------------------------------------------------------------
func run_examples() -> void:
	"""Run all examples"""
	example_predefined_templates()
	example_custom_template_creation()
	example_template_inheritance()
	example_template_composition()
	example_batch_execution()
	example_advanced_customization()
	example_gdsentry_integration()
	example_performance_testing()

	print("🎉 All TestScenarioTemplates examples completed!")
	print("\n💡 Key Takeaways:")
	print("	 • Predefined templates provide quick-start testing capabilities")
	print("	 • Custom templates enable domain-specific test scenarios")
	print("	 • Inheritance and composition support complex workflow modeling")
	print("	 • Batch execution enables comprehensive test suite validation")
	print("	 • GDSentry integration provides seamless testing framework compatibility")
	print("	 • Performance testing templates support load and stress testing")
	print("\n📖 For more advanced usage, see the TestScenarioTemplates class documentation.")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	if templates:
		templates.queue_free()
