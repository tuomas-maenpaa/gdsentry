# GDSentry - Test Scenario Templates Framework
# Comprehensive test scenario template system for GDSentry
#
# This framework provides predefined test scenario templates that enable:
# - Standardized testing patterns for common application workflows
# - Template composition and inheritance for complex scenarios
# - Scenario validation and verification framework
# - Integration with GDSentry's existing test types and data generators
# - Reusable scenario definitions for consistent testing across projects
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node

class_name TestScenarioTemplates

# ------------------------------------------------------------------------------
# FRAMEWORK CONSTANTS
# ------------------------------------------------------------------------------
const MAX_SCENARIO_DEPTH = 10
const DEFAULT_TIMEOUT = 30.0
const VALIDATION_TIMEOUT = 5.0

# ------------------------------------------------------------------------------
# FRAMEWORK METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

# ------------------------------------------------------------------------------
# CORE SCENARIO TEMPLATE CLASS
# ------------------------------------------------------------------------------
class ScenarioTemplate:
	var _name: String
	var _description: String
	var _tags: Array[String]
	var _steps: Array[ScenarioStep]
	var _validations: Array[ScenarioValidation]
	var _setup_steps: Array[ScenarioStep]
	var _teardown_steps: Array[ScenarioStep]
	var _metadata: Dictionary
	var _timeout: float
	var _parent_template: ScenarioTemplate
	var _child_templates: Array[ScenarioTemplate]
	var _variables: Dictionary
	var _data_generator

	func _init(template_name: String, description: String = ""):
		_name = template_name
		_description = description if not description.is_empty() else "Test scenario: " + template_name
		_tags = []
		_steps = []
		_validations = []
		_setup_steps = []
		_teardown_steps = []
		_metadata = {}
		_timeout = DEFAULT_TIMEOUT
		_parent_template = null
		_child_templates = []
		_variables = {}
		_data_generator = load("res://utilities/test_data_generator.gd").new()

	# ------------------------------------------------------------------------------
	# TEMPLATE CONFIGURATION
	# ------------------------------------------------------------------------------
	func set_description(description: String) -> ScenarioTemplate:
		"""Set template description"""
		_description = description
		return self

	func add_tag(tag: String) -> ScenarioTemplate:
		"""Add a tag to the template"""
		if not _tags.has(tag):
			_tags.append(tag)
		return self

	func add_tags(tags: Array[String]) -> ScenarioTemplate:
		"""Add multiple tags to the template"""
		for tag in tags:
			add_tag(tag)
		return self

	func set_timeout(timeout_seconds: float) -> ScenarioTemplate:
		"""Set execution timeout for the scenario"""
		_timeout = timeout_seconds
		return self

	func set_metadata(key: String, value) -> ScenarioTemplate:
		"""Set metadata for the template"""
		_metadata[key] = value
		return self

	func set_variable(name: String, value) -> ScenarioTemplate:
		"""Set a variable for use in steps"""
		_variables[name] = value
		return self

	# ------------------------------------------------------------------------------
	# STEP MANAGEMENT
	# ------------------------------------------------------------------------------
	func add_step(step_name: String, step_function: Callable, description: String = "") -> ScenarioTemplate:
		"""Add a step to the scenario"""
		var step = ScenarioStep.new(step_name, step_function, description)
		_steps.append(step)
		return self

	func add_setup_step(step_name: String, step_function: Callable, description: String = "") -> ScenarioTemplate:
		"""Add a setup step that runs before main steps"""
		var step = ScenarioStep.new(step_name, step_function, description)
		_setup_steps.append(step)
		return self

	func add_teardown_step(step_name: String, step_function: Callable, description: String = "") -> ScenarioTemplate:
		"""Add a teardown step that runs after main steps"""
		var step = ScenarioStep.new(step_name, step_function, description)
		_teardown_steps.append(step)
		return self

	func insert_step(index: int, step_name: String, step_function: Callable, description: String = "") -> ScenarioTemplate:
		"""Insert a step at specific position"""
		var step = ScenarioStep.new(step_name, step_function, description)
		if index >= 0 and index <= _steps.size():
			_steps.insert(index, step)
		else:
			_steps.append(step)
		return self

	func remove_step(step_name: String) -> ScenarioTemplate:
		"""Remove a step by name"""
		for i in range(_steps.size()):
			if _steps[i].name == step_name:
				_steps.remove_at(i)
				break
		return self

	# ------------------------------------------------------------------------------
	# VALIDATION MANAGEMENT
	# ------------------------------------------------------------------------------
	func add_validation(validation_name: String, validation_function: Callable, description: String = "") -> ScenarioTemplate:
		"""Add a validation to the scenario"""
		var validation = ScenarioValidation.new(validation_name, validation_function, description)
		_validations.append(validation)
		return self

	func add_assertion(assertion_name: String, assertion_function: Callable, description: String = "") -> ScenarioTemplate:
		"""Add an assertion (alias for validation)"""
		return add_validation(assertion_name, assertion_function, description)

	# ------------------------------------------------------------------------------
	# TEMPLATE INHERITANCE AND COMPOSITION
	# ------------------------------------------------------------------------------
	func extend(parent_template: ScenarioTemplate) -> ScenarioTemplate:
		"""Extend another template (inheritance)"""
		if _parent_template != null:
			push_warning("Template '%s' already extends another template. Multiple inheritance not supported." % _name)
			return self

		_parent_template = parent_template
		parent_template._child_templates.append(self)

		# Inherit properties
		if _description == "Test scenario: " + _name:
			_description = parent_template._description + " (extended)"
		if _tags.is_empty():
			_tags = parent_template._tags.duplicate()
		if _timeout == DEFAULT_TIMEOUT:
			_timeout = parent_template._timeout

		return self

	func compose(with_template: ScenarioTemplate) -> ScenarioTemplate:
		"""Compose with another template (adds steps without inheritance)"""
		# Add setup steps from composed template
		for step in with_template._setup_steps:
			_setup_steps.append(step)

		# Add main steps from composed template
		for step in with_template._steps:
			_steps.append(step)

		# Add validations from composed template
		for validation in with_template._validations:
			_validations.append(validation)

		# Add teardown steps from composed template
		for step in with_template._teardown_steps:
			_teardown_steps.append(step)

		return self

	# ------------------------------------------------------------------------------
	# SCENARIO EXECUTION
	# ------------------------------------------------------------------------------
	func generate() -> ScenarioInstance:
		"""Generate a scenario instance ready for execution"""
		var instance = ScenarioInstance.new(self)
		instance.initialize()
		return instance

	func execute() -> ScenarioResult:
		"""Execute the scenario directly"""
		var instance = generate()
		return instance.execute()

	# ------------------------------------------------------------------------------
	# TEMPLATE UTILITIES
	# ------------------------------------------------------------------------------
	func get_step_count() -> int:
		"""Get total number of steps"""
		return _setup_steps.size() + _steps.size() + _teardown_steps.size()

	func get_validation_count() -> int:
		"""Get number of validations"""
		return _validations.size()

	func has_tag(tag: String) -> bool:
		"""Check if template has a specific tag"""
		return _tags.has(tag)

	func to_dictionary() -> Dictionary:
		"""Convert template to dictionary for serialization"""
		return {
			"name": _name,
			"description": _description,
			"tags": _tags,
			"timeout": _timeout,
			"metadata": _metadata,
			"variables": _variables,
			"setup_steps": _setup_steps.map(func(s): return s.to_dictionary()),
			"steps": _steps.map(func(s): return s.to_dictionary()),
			"validations": _validations.map(func(v): return v.to_dictionary()),
			"teardown_steps": _teardown_steps.map(func(s): return s.to_dictionary()),
			"parent_template": _parent_template._name if _parent_template else ""
		}

	func _cleanup() -> void:
		"""Cleanup resources"""
		if _data_generator:
			_data_generator.queue_free()
		_data_generator = null

# ------------------------------------------------------------------------------
# SCENARIO STEP CLASS
# ------------------------------------------------------------------------------
class ScenarioStep:
	var name: String
	var function: Callable
	var description: String
	var timeout: float
	var retry_count: int
	var retry_delay: float

	func _init(step_name: String, step_function: Callable, step_description: String = ""):
		name = step_name
		function = step_function
		description = step_description if not step_description.is_empty() else step_name
		timeout = 10.0
		retry_count = 0
		retry_delay = 0.1

	func set_timeout(timeout_seconds: float) -> ScenarioStep:
		"""Set timeout for this step"""
		timeout = timeout_seconds
		return self

	func set_retry(retry_attempts: int, delay_seconds: float = 0.1) -> ScenarioStep:
		"""Set retry configuration"""
		retry_count = retry_attempts
		retry_delay = delay_seconds
		return self

	func to_dictionary() -> Dictionary:
		"""Convert to dictionary for serialization"""
		return {
			"name": name,
			"description": description,
			"timeout": timeout,
			"retry_count": retry_count,
			"retry_delay": retry_delay
		}

# ------------------------------------------------------------------------------
# SCENARIO VALIDATION CLASS
# ------------------------------------------------------------------------------
class ScenarioValidation:
	var name: String
	var function: Callable
	var description: String
	var severity: String  # "error", "warning", "info"
	var timeout: float

	func _init(validation_name: String, validation_function: Callable, validation_description: String = ""):
		name = validation_name
		function = validation_function
		description = validation_description if not validation_description.is_empty() else validation_name
		severity = "error"
		timeout = VALIDATION_TIMEOUT

	func set_severity(validation_severity: String) -> ScenarioValidation:
		"""Set validation severity level"""
		if ["error", "warning", "info"].has(validation_severity):
			severity = validation_severity
		else:
			push_warning("Invalid severity '%s', using 'error'" % validation_severity)
		return self

	func set_timeout(timeout_seconds: float) -> ScenarioValidation:
		"""Set timeout for this validation"""
		timeout = timeout_seconds
		return self

	func to_dictionary() -> Dictionary:
		"""Convert to dictionary for serialization"""
		return {
			"name": name,
			"description": description,
			"severity": severity,
			"timeout": timeout
		}

# ------------------------------------------------------------------------------
# SCENARIO INSTANCE CLASS
# ------------------------------------------------------------------------------
class ScenarioInstance:
	var template: ScenarioTemplate
	var context: Dictionary
	var results: Array[StepResult]
	var start_time: float
	var end_time: float

	func _init(scenario_template: ScenarioTemplate):
		template = scenario_template
		context = {}
		results = []
		start_time = 0.0
		end_time = 0.0

	func initialize() -> void:
		"""Initialize scenario instance"""
		# Copy template variables to context
		context = template._variables.duplicate(true)

		# Initialize template inheritance if present
		if template._parent_template:
			_inherit_from_parent()

	func _inherit_from_parent() -> void:
		"""Inherit properties from parent template"""
		var parent = template._parent_template

		# Inherit setup steps
		for step in parent._setup_steps:
			if not template._setup_steps.any(func(s): return s.name == step.name):
				template._setup_steps.insert(0, step)

		# Inherit main steps
		for step in parent._steps:
			if not template._steps.any(func(s): return s.name == step.name):
				template._steps.insert(0, step)

		# Inherit validations
		for validation in parent._validations:
			if not template._validations.any(func(v): return v.name == validation.name):
				template._validations.append(validation)

		# Inherit teardown steps
		for step in parent._teardown_steps:
			if not template._teardown_steps.any(func(s): return s.name == step.name):
				template._teardown_steps.append(step)

	func execute() -> ScenarioResult:
		"""Execute the scenario"""
		start_time = Time.get_ticks_usec() / 1000000.0

		var scenario_result = ScenarioResult.new(template._name)

		# Execute setup steps
		for step in template._setup_steps:
			var step_result = _execute_step(step)
			results.append(step_result)
			scenario_result.add_step_result(step_result)

			if not step_result.success:
				scenario_result.success = false
				scenario_result.error_message = "Setup failed: " + step_result.error_message
				break

		# Execute main steps (if setup succeeded)
		if scenario_result.success:
			for step in template._steps:
				var step_result = _execute_step(step)
				results.append(step_result)
				scenario_result.add_step_result(step_result)

				if not step_result.success:
					scenario_result.success = false
					scenario_result.error_message = "Step failed: " + step_result.error_message
					break

		# Execute validations (if main steps succeeded)
		if scenario_result.success:
			for validation in template._validations:
				var validation_result = _execute_validation(validation)
				scenario_result.add_validation_result(validation_result)

				if not validation_result.success and validation.severity == "error":
					scenario_result.success = false
					scenario_result.error_message = "Validation failed: " + validation_result.error_message
					break

		# Execute teardown steps (always run)
		for step in template._teardown_steps:
			var step_result = _execute_step(step)
			results.append(step_result)
			scenario_result.add_step_result(step_result)

		end_time = Time.get_ticks_usec() / 1000000.0
		scenario_result.execution_time = end_time - start_time

		return scenario_result

	func _execute_step(step: ScenarioStep) -> StepResult:
		"""Execute a single step"""
		var result = StepResult.new(step.name)
		result.start_time = Time.get_ticks_usec() / 1000000.0

		var success = true
		var error_msg = ""

		# Execute step function with retry logic
		for attempt in range(step.retry_count + 1):
			if attempt > 0:
				OS.delay_usec(int(step.retry_delay * 1000000))

			var thread = Thread.new()
			var result_data = {"success": false, "result": null, "error": ""}

			# Use call_deferred for thread safety
			thread.start(func():
				result_data.success = true
				result_data.result = step.function.call()
			)

			# Wait for completion or timeout
			var start_wait = Time.get_ticks_usec() / 1000000.0
			while thread.is_alive():
				if (Time.get_ticks_usec() / 1000000.0) - start_wait > step.timeout:
					thread.wait_to_finish()
					success = false
					error_msg = "Step timeout after %.2f seconds" % step.timeout
					break
				OS.delay_usec(10000)  # 10ms delay

			if thread.is_alive():
				thread.wait_to_finish()

			if result_data.success:
				result.result = result_data.result
				success = true
				break
			else:
				success = false
				error_msg = result_data.error if not result_data.error.is_empty() else "Step execution failed"

		result.end_time = Time.get_ticks_usec() / 1000000.0
		result.execution_time = result.end_time - result.start_time
		result.success = success
		result.error_message = error_msg

		return result

	func _execute_validation(validation: ScenarioValidation) -> ValidationResult:
		"""Execute a single validation"""
		var result = ValidationResult.new(validation.name)
		result.start_time = Time.get_ticks_usec() / 1000000.0

		var thread = Thread.new()
		var result_data = {"success": false, "result": null, "error": ""}

		thread.start(func():
			result_data.success = true
			result_data.result = validation.function.call()
		)

		# Wait for completion or timeout
		var start_wait = Time.get_ticks_usec() / 1000000.0
		while thread.is_alive():
			if (Time.get_ticks_usec() / 1000000.0) - start_wait > validation.timeout:
				thread.wait_to_finish()
				result.success = false
				result.error_message = "Validation timeout after %.2f seconds" % validation.timeout
				result.end_time = Time.get_ticks_usec() / 1000000.0
				result.execution_time = result.end_time - result.start_time
				return result
			OS.delay_usec(10000)

		if thread.is_alive():
			thread.wait_to_finish()

		result.end_time = Time.get_ticks_usec() / 1000000.0
		result.execution_time = result.end_time - result.start_time

		if result_data.success:
			result.success = result_data.result if typeof(result_data.result) == TYPE_BOOL else true
			result.result = result_data.result
		else:
			result.success = false
			result.error_message = result_data.error if not result_data.error.is_empty() else "Validation execution failed"

		return result

# ------------------------------------------------------------------------------
# RESULT CLASSES
# ------------------------------------------------------------------------------
class StepResult:
	var step_name: String
	var success: bool
	var result
	var error_message: String
	var start_time: float
	var end_time: float
	var execution_time: float

	func _init(name: String):
		step_name = name
		success = false
		result = null
		error_message = ""
		start_time = 0.0
		end_time = 0.0
		execution_time = 0.0

class ValidationResult:
	var validation_name: String
	var success: bool
	var result
	var error_message: String
	var start_time: float
	var end_time: float
	var execution_time: float

	func _init(name: String):
		validation_name = name
		success = false
		result = null
		error_message = ""
		start_time = 0.0
		end_time = 0.0
		execution_time = 0.0

class ScenarioResult:
	var scenario_name: String
	var success: bool
	var error_message: String
	var step_results: Array[StepResult]
	var validation_results: Array[ValidationResult]
	var execution_time: float
	var start_time: float
	var end_time: float

	func _init(name: String):
		scenario_name = name
		success = true
		error_message = ""
		step_results = []
		validation_results = []
		execution_time = 0.0
		start_time = Time.get_ticks_usec() / 1000000.0
		end_time = 0.0

	func add_step_result(result: StepResult) -> void:
		step_results.append(result)

	func add_validation_result(result: ValidationResult) -> void:
		validation_results.append(result)

	func get_successful_steps() -> Array[StepResult]:
		return step_results.filter(func(r): return r.success)

	func get_failed_steps() -> Array[StepResult]:
		return step_results.filter(func(r): return not r.success)

	func get_successful_validations() -> Array[ValidationResult]:
		return validation_results.filter(func(r): return r.success)

	func get_failed_validations() -> Array[ValidationResult]:
		return validation_results.filter(func(r): return not r.success)

# ------------------------------------------------------------------------------
# PREDEFINED SCENARIO TEMPLATES
# ------------------------------------------------------------------------------
var _templates: Dictionary = {}

func _init():
	"""Initialize predefined templates"""
	_create_authentication_templates()
	_create_ecommerce_templates()
	_create_crud_templates()
	_create_ui_templates()
	_create_api_templates()
	_create_performance_templates()

func _create_authentication_templates() -> void:
	"""Create authentication-related templates"""

	# User Registration Template
	var registration_template = ScenarioTemplate.new("user_registration", "Complete user registration workflow")
	registration_template.add_tags(["authentication", "registration", "user_management"])

	registration_template.add_setup_step("prepare_registration_data",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			var user_data = data_generator.create_user()
			return user_data
	)

	registration_template.add_step("validate_registration_form",
		func(user_data):
			return user_data.has("email") and user_data.has("name") and user_data.email.contains("@")
	)

	registration_template.add_step("submit_registration",
		func(user_data):
			# Simulate registration submission
			var registration_result = {
				"success": true,
				"user_id": user_data.id,
				"confirmation_sent": true
			}
			return registration_result
	)

	registration_template.add_validation("registration_successful",
		func(result): return result.success and result.has("user_id")
	)

	registration_template.add_validation("email_confirmation_sent",
		func(result): return result.confirmation_sent
	)

	_templates["user_registration"] = registration_template

	# User Login Template
	var login_template = ScenarioTemplate.new("user_login", "User authentication workflow")
	login_template.add_tags(["authentication", "login"])

	login_template.add_step("prepare_login_credentials",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			var user = data_generator.create_user()
			return {
				"email": user.email,
				"password": "secure_password_123"
			}
	)

	login_template.add_step("attempt_login",
		func(_credentials):
			# Simulate login attempt
			var login_result = {
				"success": true,
				"user_authenticated": true,
				"session_token": "session_" + str(randi())
			}
			return login_result
	)

	login_template.add_validation("login_successful",
		func(result): return result.success and result.user_authenticated
	)

	login_template.add_validation("session_created",
		func(result): return result.has("session_token") and result.session_token.begins_with("session_")
	)

	_templates["user_login"] = login_template

func _create_ecommerce_templates() -> void:
	"""Create e-commerce related templates"""

	# Product Purchase Template
	var purchase_template = ScenarioTemplate.new("product_purchase", "Complete product purchase workflow")
	purchase_template.add_tags(["ecommerce", "purchase", "transaction"])

	purchase_template.add_setup_step("setup_purchase_environment",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			return {
				"customer": data_generator.create_user(),
				"product": data_generator.create_product("electronics"),
				"quantity": data_generator.generate_int(1, 5)
			}
	)

	purchase_template.add_step("add_to_cart",
		func(env):
			var cart_item = {
				"product_id": env.product.id,
				"quantity": env.quantity,
				"unit_price": env.product.price,
				"total_price": env.product.price * env.quantity
			}
			return cart_item
	)

	purchase_template.add_step("process_payment",
		func(cart_item):
			# Simulate payment processing
			var payment_result = {
				"success": true,
				"transaction_id": "txn_" + str(randi()),
				"amount_charged": cart_item.total_price,
				"payment_method": "credit_card"
			}
			return payment_result
	)

	purchase_template.add_step("confirm_order",
		func(payment_result):
			var order = {
				"order_id": "order_" + str(randi()),
				"transaction_id": payment_result.transaction_id,
				"status": "confirmed",
				"estimated_delivery": "3-5 business days"
			}
			return order
	)

	purchase_template.add_validation("payment_successful",
		func(result): return result.success and result.has("transaction_id")
	)

	purchase_template.add_validation("order_confirmed",
		func(result): return result.status == "confirmed" and result.has("order_id")
	)

	_templates["product_purchase"] = purchase_template

func _create_crud_templates() -> void:
	"""Create CRUD operation templates"""

	# Data Creation Template
	var data_create_template = ScenarioTemplate.new("data_create", "Data creation workflow")
	data_create_template.add_tags(["crud", "create", "data_management"])

	data_create_template.add_step("prepare_data",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			return {
				"entity_type": "user",
				"data": data_generator.create_user(),
				"timestamp": Time.get_unix_time_from_system()
			}
	)

	data_create_template.add_step("validate_data",
		func(prepared_data):
			var data = prepared_data.data
			return data.has("id") and data.has("email") and data.email.contains("@")
	)

	data_create_template.add_step("persist_data",
		func(validated_data):
			# Simulate data persistence
			var persistence_result = {
				"success": true,
				"entity_id": validated_data.data.id,
				"created_at": Time.get_unix_time_from_system(),
				"version": 1
			}
			return persistence_result
	)

	data_create_template.add_validation("creation_successful",
		func(result): return result.success and result.has("entity_id")
	)

	_templates["data_create"] = data_create_template

func _create_ui_templates() -> void:
	"""Create UI interaction templates"""

	# Form Submission Template
	var form_template = ScenarioTemplate.new("form_submission", "Form submission workflow")
	form_template.add_tags(["ui", "form", "interaction"])

	form_template.add_step("fill_form_fields",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			return {
				"name": data_generator.generate_name().full_name,
				"email": data_generator.generate_email(),
				"message": data_generator.generate_string(100)
			}
	)

	form_template.add_step("validate_form",
		func(form_data):
			return form_data.name.length() > 0 and form_data.email.contains("@") and form_data.message.length() > 10
	)

	form_template.add_step("submit_form",
		func(_validated_data):
			# Simulate form submission
			var submission_result = {
				"success": true,
				"submission_id": "sub_" + str(randi()),
				"timestamp": Time.get_unix_time_from_system()
			}
			return submission_result
	)

	form_template.add_validation("form_submitted",
		func(result): return result.success and result.has("submission_id")
	)

	_templates["form_submission"] = form_template

func _create_api_templates() -> void:
	"""Create API interaction templates"""

	# API Request Template
	var api_template = ScenarioTemplate.new("api_request", "API request/response workflow")
	api_template.add_tags(["api", "http", "integration"])

	api_template.add_step("prepare_request",
		func():
			return {
				"url": "https://api.example.com/users",
				"method": "POST",
				"headers": {"Content-Type": "application/json"},
				"body": {
					"name": "Test User",
					"email": "test@example.com"
				}
			}
	)

	api_template.add_step("send_request",
		func(request_data):
			# Simulate API call
			var response = {
				"status_code": 201,
				"success": true,
				"data": {
					"id": "user_" + str(randi()),
					"name": request_data.body.name,
					"email": request_data.body.email,
					"created_at": Time.get_unix_time_from_system()
				},
				"response_time": 0.245
			}
			return response
	)

	api_template.add_validation("request_successful",
		func(response): return response.success and response.status_code == 201
	)

	api_template.add_validation("response_contains_data",
		func(response): return response.has("data") and response.data.has("id")
	)

	_templates["api_request"] = api_template

func _create_performance_templates() -> void:
	"""Create performance testing templates"""

	# Load Test Template
	var load_template = ScenarioTemplate.new("load_test", "Load testing scenario")
	load_template.add_tags(["performance", "load", "stress"])

	load_template.add_step("prepare_test_data",
		func():
			var data_generator = load("res://utilities/test_data_generator.gd").new()
			return {
				"user_count": 100,
				"users": data_generator.generate_users(100),
				"start_time": Time.get_ticks_usec()
			}
	)

	load_template.add_step("simulate_load",
		func(test_data):
			# Simulate concurrent user load
			var results = []
			for i in range(test_data.user_count):
				var user_result = {
					"user_id": test_data.users[i].id,
					"login_success": true,
					"response_time": randf_range(0.1, 2.0)
				}
				results.append(user_result)
				OS.delay_usec(1000)	 # 1ms delay between requests

			return {
				"results": results,
				"total_requests": results.size(),
				"successful_requests": results.filter(func(r): return r.login_success).size(),
				"end_time": Time.get_ticks_usec()
			}
	)

	load_template.add_validation("load_handled_successfully",
		func(load_result): return load_result.successful_requests == load_result.total_requests
	)

	load_template.add_validation("performance_within_limits",
		func(load_result):
			var avg_response_time = load_result.results.map(func(r): return r.response_time).reduce(func(acc, val): return acc + val, 0.0) / load_result.results.size()
			return avg_response_time < 1.0	# Average response time < 1 second
	)

	_templates["load_test"] = load_template

# ------------------------------------------------------------------------------
# TEMPLATE MANAGEMENT API
# ------------------------------------------------------------------------------
func get_template(template_name: String) -> ScenarioTemplate:
	"""Get a predefined template by name"""
	if _templates.has(template_name):
		return _templates[template_name]
	else:
		push_error("Template '%s' not found" % template_name)
		return null

func list_templates(filter_tags: Array[String] = []) -> Array[String]:
	"""List all available templates, optionally filtered by tags"""
	var template_names = _templates.keys()

	if filter_tags.is_empty():
		return template_names

	var filtered_names = []
	for template_name in template_names:
		var template = _templates[template_name]
		var has_all_tags = true
		for tag in filter_tags:
			if not template.has_tag(tag):
				has_all_tags = false
				break
		if has_all_tags:
			filtered_names.append(name)

	return filtered_names

func create_template(template_name: String, description: String = "") -> ScenarioTemplate:
	"""Create a new custom template"""
	var template = ScenarioTemplate.new(template_name, description)
	_templates[template_name] = template
	return template

func remove_template(template_name: String) -> bool:
	"""Remove a template"""
	if _templates.has(template_name):
		_templates.erase(template_name)
		return true
	return false

func get_template_info(template_name: String) -> Dictionary:
	"""Get information about a template"""
	if not _templates.has(template_name):
		return {}

	var template = _templates[template_name]
	return {
		"name": template._name,
		"description": template._description,
		"tags": template._tags,
		"step_count": template.get_step_count(),
		"validation_count": template.get_validation_count(),
		"timeout": template._timeout,
		"has_parent": template._parent_template != null,
		"parent_name": template._parent_template._name if template._parent_template else null
	}

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func create_scenario_runner() -> ScenarioRunner:
	"""Create a scenario runner for executing multiple scenarios"""
	return ScenarioRunner.new(self)

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup resources"""
	for template_name in _templates.keys():
		var template = _templates[template_name]
		if template:
			template._cleanup()
	_templates.clear()

# ------------------------------------------------------------------------------
# SCENARIO RUNNER CLASS (FOR BATCH EXECUTION)
# ------------------------------------------------------------------------------
class ScenarioRunner:
	var template_manager: TestScenarioTemplates
	var results: Array[ScenarioResult]
	var parallel_execution: bool
	var max_parallel_scenarios: int

	func _init(manager: TestScenarioTemplates):
		template_manager = manager
		results = []
		parallel_execution = false
		max_parallel_scenarios = 4

	func set_parallel_execution(enabled: bool, max_scenarios: int = 4) -> ScenarioRunner:
		"""Enable or disable parallel scenario execution"""
		parallel_execution = enabled
		max_parallel_scenarios = max_scenarios
		return self

	func run_scenarios(scenario_names: Array[String]) -> Array[ScenarioResult]:
		"""Run multiple scenarios"""
		results.clear()

		if parallel_execution:
			return _run_parallel(scenario_names)
		else:
			return _run_sequential(scenario_names)

	func _run_sequential(scenario_names: Array[String]) -> Array[ScenarioResult]:
		"""Run scenarios sequentially"""
		for scenario_name in scenario_names:
			var template = template_manager.get_template(scenario_name)
			if template:
				var result = template.execute()
				results.append(result)
			else:
				push_error("Scenario '%s' not found" % scenario_name)

		return results

	func _run_parallel(scenario_names: Array[String]) -> Array[ScenarioResult]:
		"""Run scenarios in parallel"""
		var threads = []
		var thread_results = []

		for i in range(scenario_names.size()):
			var scenario_name = scenario_names[i]
			var template = template_manager.get_template(scenario_name)

			if template:
				var thread = Thread.new()
				threads.append(thread)
				thread_results.append({"thread": thread, "scenario": scenario_name})

				thread.start(func():
					return template.execute()
				)

				# Limit concurrent threads
				if threads.size() >= max_parallel_scenarios:
					_wait_for_threads_completion(threads, thread_results)
					threads.clear()

		# Wait for remaining threads
		_wait_for_threads_completion(threads, thread_results)

		return results

	func _wait_for_threads_completion(threads: Array, _thread_results: Array) -> void:
		"""Wait for threads to complete and collect results"""
		for i in range(threads.size()):
			var thread = threads[i]
			var result = thread.wait_to_finish()
			results.append(result)

	func get_successful_scenarios() -> Array[ScenarioResult]:
		"""Get results for successful scenarios"""
		return results.filter(func(r): return r.success)

	func get_failed_scenarios() -> Array[ScenarioResult]:
		"""Get results for failed scenarios"""
		return results.filter(func(r): return not r.success)

	func generate_summary_report() -> Dictionary:
		"""Generate a summary report of all scenario executions"""
		var total_scenarios = results.size()
		var successful_scenarios = get_successful_scenarios().size()
		var failed_scenarios = get_failed_scenarios().size()

		var total_execution_time = results.map(func(r): return r.execution_time).reduce(func(acc, val): return acc + val, 0.0)

		return {
			"total_scenarios": total_scenarios,
			"successful_scenarios": successful_scenarios,
			"failed_scenarios": failed_scenarios,
			"success_rate": successful_scenarios / float(total_scenarios) * 100.0 if total_scenarios > 0 else 0.0,
			"total_execution_time": total_execution_time,
			"average_execution_time": total_execution_time / total_scenarios if total_scenarios > 0 else 0.0
		}
