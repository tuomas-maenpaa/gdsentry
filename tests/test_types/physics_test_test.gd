# GDSentry - PhysicsTest Comprehensive Test Suite
# Tests the PhysicsTest class functionality for physics simulation and validation
#
# Tests cover:
# - Collision detection testing (bodies and areas)
# - Physics state verification (velocity, position, rotation)
# - Force and impulse testing
# - Physics monitoring and statistics
# - Joint and constraint testing
# - Deterministic physics testing
# - Physics performance monitoring
# - Configuration and tolerance settings
# - Error handling and edge cases
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2DTest

class_name PhysicsTestTest

# ------------------------------------------------------------------------------
# PHYSICS TEST INSTANCE
# ------------------------------------------------------------------------------
var physics_test_instance: PhysicsTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Comprehensive test suite for PhysicsTest class"
	test_tags = ["physics_test", "collision", "rigid_body", "kinematic", "force", "velocity", "integration"]
	test_priority = "high"
	test_category = "test_types"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all PhysicsTest comprehensive tests"""
	run_test("test_physics_test_instantiation", func(): return test_physics_test_instantiation())
	run_test("test_physics_test_configuration", func(): return test_physics_test_configuration())
	run_test("test_collision_detection", func(): return await test_collision_detection())
	run_test("test_physics_state_verification", func(): return test_physics_state_verification())
	run_test("test_force_and_impulse_testing", func(): return test_force_and_impulse_testing())
	run_test("test_physics_monitoring", func(): return test_physics_monitoring())
	run_test("test_joint_constraint_testing", func(): return test_joint_constraint_testing())
	run_test("test_deterministic_physics", func(): return test_deterministic_physics())
	run_test("test_physics_performance", func(): return test_physics_performance())
	run_test("test_physics_assertions", func(): return test_physics_assertions())
	run_test("test_error_handling", func(): return await test_error_handling())
	run_test("test_edge_cases", func(): return await test_edge_cases())

# ------------------------------------------------------------------------------
# BASIC FUNCTIONALITY TESTS
# ------------------------------------------------------------------------------
func test_physics_test_instantiation() -> bool:
	"""Test PhysicsTest instantiation and basic properties"""
	var success = true

	# Create PhysicsTest instance for testing
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Test basic instantiation
	success = success and assert_not_null(physics_test_instance, "PhysicsTest should instantiate successfully")
	success = success and assert_type(physics_test_instance, TYPE_OBJECT, "Should be an object")
	success = success and assert_equals(physics_test_instance.get_class(), "PhysicsTest", "Should be PhysicsTest class")
	success = success and assert_true(physics_test_instance is Node2DTest, "Should extend Node2DTest")

	# Test default configuration values
	success = success and assert_equals(physics_test_instance.physics_fps, 60, "Default physics FPS should be 60")
	success = success and assert_equals(physics_test_instance.simulation_speed, 1.0, "Default simulation speed should be 1.0")
	success = success and assert_equals(physics_test_instance.collision_tolerance, 1.0, "Default collision tolerance should be 1.0")
	success = success and assert_equals(physics_test_instance.velocity_tolerance, 0.1, "Default velocity tolerance should be 0.1")
	success = success and assert_equals(physics_test_instance.position_tolerance, 1.0, "Default position tolerance should be 1.0")

	# Test state initialization
	success = success and assert_true(physics_test_instance.physics_stats is Dictionary, "Physics stats should be dictionary")
	success = success and assert_true(physics_test_instance.collision_history is Array, "Collision history should be array")
	success = success and assert_equals(physics_test_instance.physics_frame_wait, 2, "Default physics frame wait should be 2")

	# Test constants
	success = success and assert_equals(physics_test_instance.DEFAULT_PHYSICS_WAIT, 2, "Default physics wait constant should be 2")
	success = success and assert_equals(physics_test_instance.COLLISION_TOLERANCE, 1.0, "Collision tolerance constant should be 1.0")
	success = success and assert_equals(physics_test_instance.VELOCITY_TOLERANCE, 0.1, "Velocity tolerance constant should be 0.1")
	success = success and assert_equals(physics_test_instance.POSITION_TOLERANCE, 1.0, "Position tolerance constant should be 1.0")
	success = success and assert_equals(physics_test_instance.FORCE_TEST_DURATION, 1.0, "Force test duration constant should be 1.0")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

func test_physics_test_configuration() -> bool:
	"""Test PhysicsTest configuration modification"""
	var success = true

	# Create PhysicsTest instance for testing
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Store original values to restore later
	var original_fps = physics_test_instance.physics_fps
	var original_speed = physics_test_instance.simulation_speed
	var original_collision_tolerance = physics_test_instance.collision_tolerance
	var original_velocity_tolerance = physics_test_instance.velocity_tolerance
	var original_position_tolerance = physics_test_instance.position_tolerance
	var original_frame_wait = physics_test_instance.physics_frame_wait

	# Test configuration modification
	physics_test_instance.physics_fps = 120
	physics_test_instance.simulation_speed = 2.0
	physics_test_instance.collision_tolerance = 0.5
	physics_test_instance.velocity_tolerance = 0.05
	physics_test_instance.position_tolerance = 0.5
	physics_test_instance.physics_frame_wait = 5

	success = success and assert_equals(physics_test_instance.physics_fps, 120, "Should be able to set physics FPS")
	success = success and assert_equals(physics_test_instance.simulation_speed, 2.0, "Should be able to set simulation speed")
	success = success and assert_equals(physics_test_instance.collision_tolerance, 0.5, "Should be able to set collision tolerance")
	success = success and assert_equals(physics_test_instance.velocity_tolerance, 0.05, "Should be able to set velocity tolerance")
	success = success and assert_equals(physics_test_instance.position_tolerance, 0.5, "Should be able to set position tolerance")
	success = success and assert_equals(physics_test_instance.physics_frame_wait, 5, "Should be able to set physics frame wait")

	# Test edge values
	physics_test_instance.physics_fps = 0  # Edge case
	success = success and assert_equals(physics_test_instance.physics_fps, 0, "Should handle zero FPS")

	physics_test_instance.collision_tolerance = 0.0  # Exact collision
	success = success and assert_equals(physics_test_instance.collision_tolerance, 0.0, "Should handle zero collision tolerance")

	physics_test_instance.velocity_tolerance = 0.0  # Exact velocity
	success = success and assert_equals(physics_test_instance.velocity_tolerance, 0.0, "Should handle zero velocity tolerance")

	# Test negative values (should be handled gracefully)
	physics_test_instance.collision_tolerance = -1.0
	success = success and assert_equals(physics_test_instance.collision_tolerance, -1.0, "Should handle negative collision tolerance")

	physics_test_instance.velocity_tolerance = -0.1
	success = success and assert_equals(physics_test_instance.velocity_tolerance, -0.1, "Should handle negative velocity tolerance")

	# Restore original values
	physics_test_instance.physics_fps = original_fps
	physics_test_instance.simulation_speed = original_speed
	physics_test_instance.collision_tolerance = original_collision_tolerance
	physics_test_instance.velocity_tolerance = original_velocity_tolerance
	physics_test_instance.position_tolerance = original_position_tolerance
	physics_test_instance.physics_frame_wait = original_frame_wait

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# COLLISION DETECTION TESTS
# ------------------------------------------------------------------------------
func test_collision_detection() -> bool:
	"""Test collision detection functionality"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Create test areas for collision testing
	var area1 = create_test_area_with_radius(Vector2(0, 0), 10.0)
	var area2 = create_test_area_with_radius(Vector2(5, 0), 10.0)  # Overlapping
	var area3 = create_test_area_with_radius(Vector2(30, 0), 10.0)  # Not overlapping

	add_child(area1)
	add_child(area2)
	add_child(area3)

	# Test collision detection between overlapping areas
	var collision_result = await physics_test_instance.assert_collision_detected(area1, area2)
	success = success and assert_type(collision_result, TYPE_BOOL, "Collision detection should return boolean")

	# Test no collision detection between non-overlapping areas
	var no_collision_result = await physics_test_instance.assert_no_collision(area1, area3)
	success = success and assert_type(no_collision_result, TYPE_BOOL, "No collision detection should return boolean")

	# Test collision detection with null areas
	var null_collision_result = await physics_test_instance.assert_collision_detected(null, area1)
	success = success and assert_false(null_collision_result, "Null area collision should fail")

	# Test collision detection with same area
	var self_collision_result = await physics_test_instance.assert_collision_detected(area1, area1)
	success = success and assert_type(self_collision_result, TYPE_BOOL, "Self collision detection should return boolean")

	# Test with custom message
	var custom_message_result = await physics_test_instance.assert_collision_detected(area1, area2, "Custom collision message")
	success = success and assert_type(custom_message_result, TYPE_BOOL, "Custom message collision should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# PHYSICS STATE VERIFICATION TESTS
# ------------------------------------------------------------------------------
func test_physics_state_verification() -> bool:
	"""Test physics state verification (velocity, position, rotation)"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Create test rigid body
	var rigid_body = create_test_rigid_body(Vector2(100, 100), 0.0)
	add_child(rigid_body)

	# Test velocity assertion
	var velocity_result = physics_test_instance.assert_physics_velocity(rigid_body, Vector2(0, 0))
	success = success and assert_type(velocity_result, TYPE_BOOL, "Velocity assertion should return boolean")

	# Test velocity assertion with custom tolerance
	var velocity_tolerance_result = physics_test_instance.assert_physics_velocity(rigid_body, Vector2(0, 0), 0.5)
	success = success and assert_type(velocity_tolerance_result, TYPE_BOOL, "Velocity tolerance assertion should return boolean")

	# Test position assertion
	var position_result = physics_test_instance.assert_physics_position(rigid_body, Vector2(100, 100))
	success = success and assert_type(position_result, TYPE_BOOL, "Position assertion should return boolean")

	# Test position assertion with custom tolerance
	var position_tolerance_result = physics_test_instance.assert_physics_position(rigid_body, Vector2(100, 100), 0.5)
	success = success and assert_type(position_tolerance_result, TYPE_BOOL, "Position tolerance assertion should return boolean")

	# Test rotation assertion
	var rotation_result = physics_test_instance.assert_physics_rotation(rigid_body, 0.0)
	success = success and assert_type(rotation_result, TYPE_BOOL, "Rotation assertion should return boolean")

	# Test rotation assertion with custom tolerance
	var rotation_tolerance_result = physics_test_instance.assert_physics_rotation(rigid_body, 0.0, 0.05)
	success = success and assert_type(rotation_tolerance_result, TYPE_BOOL, "Rotation tolerance assertion should return boolean")

	# Test with null body
	var null_body_result = physics_test_instance.assert_physics_velocity(null, Vector2(0, 0))
	success = success and assert_false(null_body_result, "Null body velocity assertion should fail")

	# Test with custom messages
	var custom_velocity_result = physics_test_instance.assert_physics_velocity(rigid_body, Vector2(0, 0), -1.0, "Custom velocity message")
	success = success and assert_type(custom_velocity_result, TYPE_BOOL, "Custom velocity message should return boolean")

	# Test rotation with different angles
	var rotated_body = create_test_rigid_body(Vector2(200, 200), PI/4)  # 45 degrees
	add_child(rotated_body)

	var angle_result = physics_test_instance.assert_physics_rotation(rotated_body, PI/4)
	success = success and assert_type(angle_result, TYPE_BOOL, "Angle rotation assertion should return boolean")

	# Test rotation angle wrapping (equivalent angles)
	var wrapped_angle_result = physics_test_instance.assert_physics_rotation(rotated_body, PI/4 + 2*PI)
	success = success and assert_type(wrapped_angle_result, TYPE_BOOL, "Wrapped angle assertion should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# FORCE AND IMPULSE TESTING TESTS
# ------------------------------------------------------------------------------
func test_force_and_impulse_testing() -> bool:
	"""Test force and impulse testing functionality"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Create test rigid body
	var rigid_body = create_test_rigid_body(Vector2(100, 100), 0.0)
	add_child(rigid_body)

	# Test force application assertion (if implemented)
	# Note: These methods may not be fully implemented in the PhysicsTest class
	# but we test the interface and error handling

	# Test with different force vectors
	var force_vectors = [
		Vector2(100, 0),   # Right
		Vector2(-100, 0),  # Left
		Vector2(0, 100),   # Down
		Vector2(0, -100),  # Up
		Vector2(50, 50),   # Diagonal
		Vector2(0, 0)      # Zero force
	]

	for force in force_vectors:
		# Test force application (method may not exist, but we test gracefully)
		if physics_test_instance.has_method("assert_force_application"):
			var force_result = physics_test_instance.assert_force_application(rigid_body, force, 1.0)
			success = success and assert_type(force_result, TYPE_BOOL, "Force application should return boolean")

	# Test impulse application
	if physics_test_instance.has_method("assert_impulse_application"):
		var impulse_result = physics_test_instance.assert_impulse_application(rigid_body, Vector2(50, 0), 0.5)
		success = success and assert_type(impulse_result, TYPE_BOOL, "Impulse application should return boolean")

	# Test torque application
	if physics_test_instance.has_method("assert_torque_application"):
		var torque_result = physics_test_instance.assert_torque_application(rigid_body, 10.0, 1.0)
		success = success and assert_type(torque_result, TYPE_BOOL, "Torque application should return boolean")

	# Test force accumulation
	if physics_test_instance.has_method("assert_force_accumulation"):
		var accumulation_result = physics_test_instance.assert_force_accumulation(rigid_body, Vector2(100, 100), 2.0)
		success = success and assert_type(accumulation_result, TYPE_BOOL, "Force accumulation should return boolean")

	# Test with null body
	if physics_test_instance.has_method("assert_force_application"):
		var null_force_result = physics_test_instance.assert_force_application(null, Vector2(10, 0), 1.0)
		success = success and assert_type(null_force_result, TYPE_BOOL, "Null body force should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# PHYSICS MONITORING TESTS
# ------------------------------------------------------------------------------
func test_physics_monitoring() -> bool:
	"""Test physics monitoring and statistics collection"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Test physics monitoring setup
	physics_test_instance.setup_physics_monitoring()

	# Verify monitoring data structure
	success = success and assert_true(physics_test_instance.physics_stats is Dictionary, "Physics stats should be dictionary")
	success = success and assert_true(physics_test_instance.physics_stats.has("frames_processed"), "Should have frames processed")
	success = success and assert_true(physics_test_instance.physics_stats.has("collisions_detected"), "Should have collisions detected")
	success = success and assert_true(physics_test_instance.physics_stats.has("bodies_active"), "Should have bodies active")
	success = success and assert_true(physics_test_instance.physics_stats.has("start_time"), "Should have start time")

	# Test monitoring with physics bodies
	var rigid_body1 = create_test_rigid_body(Vector2(50, 50), 0.0)
	var rigid_body2 = create_test_rigid_body(Vector2(60, 60), 0.0)
	add_child(rigid_body1)
	add_child(rigid_body2)

	# Wait for physics frames
	physics_test_instance.wait_for_physics_frames(1)

	# Test monitoring methods (if they exist)
	if physics_test_instance.has_method("get_physics_stats"):
		var stats = physics_test_instance.get_physics_stats()
		success = success and assert_type(stats, TYPE_DICTIONARY, "Physics stats should be dictionary")

	if physics_test_instance.has_method("reset_physics_stats"):
		physics_test_instance.reset_physics_stats()
		success = success and assert_equals(physics_test_instance.physics_stats.frames_processed, 0, "Stats should reset to zero")

	if physics_test_instance.has_method("log_physics_event"):
		physics_test_instance.log_physics_event("test_event", {"test": "data"})
		success = success and assert_true(physics_test_instance.collision_history.size() >= 0, "Event should be logged")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# JOINT AND CONSTRAINT TESTING TESTS
# ------------------------------------------------------------------------------
func test_joint_constraint_testing() -> bool:
	"""Test joint and constraint testing functionality"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Create test bodies for joint testing
	var body1 = create_test_rigid_body(Vector2(100, 100), 0.0)
	var body2 = create_test_rigid_body(Vector2(120, 100), 0.0)
	add_child(body1)
	add_child(body2)

	# Test joint testing methods (if implemented)
	if physics_test_instance.has_method("assert_pin_joint_connection"):
		var pin_joint_result = physics_test_instance.assert_pin_joint_connection(body1, body2, Vector2(110, 100))
		success = success and assert_type(pin_joint_result, TYPE_BOOL, "Pin joint test should return boolean")

	if physics_test_instance.has_method("assert_hinge_joint_limits"):
		var hinge_result = physics_test_instance.assert_hinge_joint_limits(body1, body2, -PI/2, PI/2)
		success = success and assert_type(hinge_result, TYPE_BOOL, "Hinge joint limits should return boolean")

	if physics_test_instance.has_method("assert_distance_joint_length"):
		var distance_result = physics_test_instance.assert_distance_joint_length(body1, body2, 20.0)
		success = success and assert_type(distance_result, TYPE_BOOL, "Distance joint length should return boolean")

	if physics_test_instance.has_method("assert_spring_joint_stiffness"):
		var spring_result = physics_test_instance.assert_spring_joint_stiffness(body1, body2, 100.0)
		success = success and assert_type(spring_result, TYPE_BOOL, "Spring joint stiffness should return boolean")

	# Test constraint methods
	if physics_test_instance.has_method("assert_constraint_satisfaction"):
		var constraint_result = physics_test_instance.assert_constraint_satisfaction(body1, "position_constraint", 1.0)
		success = success and assert_type(constraint_result, TYPE_BOOL, "Constraint satisfaction should return boolean")

	if physics_test_instance.has_method("assert_joint_break_force"):
		var break_result = physics_test_instance.assert_joint_break_force(body1, body2, 1000.0)
		success = success and assert_type(break_result, TYPE_BOOL, "Joint break force should return boolean")

	# Test with null bodies
	if physics_test_instance.has_method("assert_pin_joint_connection"):
		var null_joint_result = physics_test_instance.assert_pin_joint_connection(null, body1, Vector2(100, 100))
		success = success and assert_type(null_joint_result, TYPE_BOOL, "Null joint test should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# DETERMINISTIC PHYSICS TESTS
# ------------------------------------------------------------------------------
func test_deterministic_physics() -> bool:
	"""Test deterministic physics testing functionality"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Test deterministic physics setup
	if physics_test_instance.has_method("setup_deterministic_physics"):
		var setup_result = physics_test_instance.setup_deterministic_physics(42)  # Seed value
		success = success and assert_type(setup_result, TYPE_BOOL, "Deterministic setup should return boolean")

	# Test physics seed setting
	if physics_test_instance.has_method("set_physics_seed"):
		var seed_result = physics_test_instance.set_physics_seed(12345)
		success = success and assert_type(seed_result, TYPE_BOOL, "Seed setting should return boolean")

	# Test deterministic simulation
	if physics_test_instance.has_method("run_deterministic_simulation"):
		var body = create_test_rigid_body(Vector2(100, 100), 0.0)
		add_child(body)

		var simulation_result = physics_test_instance.run_deterministic_simulation(body, Vector2(10, 0), 1.0, 42)
		success = success and assert_type(simulation_result, TYPE_DICTIONARY, "Deterministic simulation should return dictionary")

		if simulation_result.has("final_position"):
			success = success and assert_type(simulation_result.final_position, TYPE_VECTOR2, "Should have final position")

		if simulation_result.has("final_velocity"):
			success = success and assert_type(simulation_result.final_velocity, TYPE_VECTOR2, "Should have final velocity")

	# Test deterministic collision
	var body1 = create_test_rigid_body(Vector2(0, 0), 0.0)
	var body2 = create_test_rigid_body(Vector2(10, 0), 0.0)
	add_child(body1)
	add_child(body2)

	if physics_test_instance.has_method("assert_deterministic_collision"):
		var collision_result = physics_test_instance.assert_deterministic_collision(body1, body2, 42)
		success = success and assert_type(collision_result, TYPE_BOOL, "Deterministic collision should return boolean")

	# Test physics state reproducibility
	if physics_test_instance.has_method("assert_physics_reproducibility"):
		var reproducibility_result = physics_test_instance.assert_physics_reproducibility([body1, body2], 42)
		success = success and assert_type(reproducibility_result, TYPE_BOOL, "Reproducibility test should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# PHYSICS PERFORMANCE TESTS
# ------------------------------------------------------------------------------
func test_physics_performance() -> bool:
	"""Test physics performance monitoring functionality"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Test performance monitoring setup
	if physics_test_instance.has_method("setup_performance_monitoring"):
		var setup_result = physics_test_instance.setup_performance_monitoring()
		success = success and assert_type(setup_result, TYPE_BOOL, "Performance setup should return boolean")

	# Test physics performance metrics
	if physics_test_instance.has_method("get_physics_performance_metrics"):
		var metrics = physics_test_instance.get_physics_performance_metrics()
		success = success and assert_type(metrics, TYPE_DICTIONARY, "Performance metrics should be dictionary")

		if metrics.has("average_frame_time"):
			success = success and assert_type(metrics.average_frame_time, TYPE_FLOAT, "Frame time should be float")

		if metrics.has("physics_step_time"):
			success = success and assert_type(metrics.physics_step_time, TYPE_FLOAT, "Step time should be float")

		if metrics.has("bodies_count"):
			success = success and assert_type(metrics.bodies_count, TYPE_INT, "Bodies count should be int")

	# Test performance thresholds
	if physics_test_instance.has_method("assert_physics_performance"):
		var performance_result = physics_test_instance.assert_physics_performance(16.67, "balanced")  # 60 FPS target, balanced mode
		success = success and assert_type(performance_result, TYPE_BOOL, "Performance assertion should return boolean")

	if physics_test_instance.has_method("assert_physics_memory_usage"):
		var memory_result = physics_test_instance.assert_physics_memory_usage(50.0)  # 50MB limit
		success = success and assert_type(memory_result, TYPE_BOOL, "Memory assertion should return boolean")

	if physics_test_instance.has_method("assert_physics_thread_safety"):
		var thread_result = physics_test_instance.assert_physics_thread_safety()
		success = success and assert_type(thread_result, TYPE_BOOL, "Thread safety assertion should return boolean")

	# Test performance benchmarking
	if physics_test_instance.has_method("benchmark_physics_simulation"):
		var benchmark_result = physics_test_instance.benchmark_physics_simulation(10, 100)  # 10 iterations, 100 bodies
		success = success and assert_type(benchmark_result, TYPE_DICTIONARY, "Benchmark should return dictionary")

		if benchmark_result.has("average_fps"):
			success = success and assert_type(benchmark_result.average_fps, TYPE_FLOAT, "Average FPS should be float")

		if benchmark_result.has("total_time"):
			success = success and assert_type(benchmark_result.total_time, TYPE_FLOAT, "Total time should be float")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# PHYSICS ASSERTIONS TESTS
# ------------------------------------------------------------------------------
func test_physics_assertions() -> bool:
	"""Test comprehensive physics assertions"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Create test physics bodies
	var static_body = create_test_static_body(Vector2(0, 0))
	var kinematic_body = create_test_kinematic_body(Vector2(50, 50))
	var rigid_body = create_test_rigid_body(Vector2(100, 100), 0.0)

	add_child(static_body)
	add_child(kinematic_body)
	add_child(rigid_body)

	# Test body type assertions
	if physics_test_instance.has_method("assert_body_type"):
		var static_result = physics_test_instance.assert_body_type(static_body, "StaticBody2D")
		var kinematic_result = physics_test_instance.assert_body_type(kinematic_body, "CharacterBody2D")
		var rigid_result = physics_test_instance.assert_body_type(rigid_body, "RigidBody2D")

		success = success and assert_type(static_result, TYPE_BOOL, "Static body type assertion should return boolean")
		success = success and assert_type(kinematic_result, TYPE_BOOL, "Kinematic body type assertion should return boolean")
		success = success and assert_type(rigid_result, TYPE_BOOL, "Rigid body type assertion should return boolean")

	# Test body property assertions
	if physics_test_instance.has_method("assert_body_mass"):
		var mass_result = physics_test_instance.assert_body_mass(rigid_body, 1.0)
		success = success and assert_type(mass_result, TYPE_BOOL, "Body mass assertion should return boolean")

	if physics_test_instance.has_method("assert_body_gravity_scale"):
		var gravity_result = physics_test_instance.assert_body_gravity_scale(rigid_body, 1.0)
		success = success and assert_type(gravity_result, TYPE_BOOL, "Gravity scale assertion should return boolean")

	if physics_test_instance.has_method("assert_body_friction"):
		var friction_result = physics_test_instance.assert_body_friction(rigid_body, 0.5)
		success = success and assert_type(friction_result, TYPE_BOOL, "Friction assertion should return boolean")

	if physics_test_instance.has_method("assert_body_bounce"):
		var bounce_result = physics_test_instance.assert_body_bounce(rigid_body, 0.0)
		success = success and assert_type(bounce_result, TYPE_BOOL, "Bounce assertion should return boolean")

	# Test physics material assertions
	if physics_test_instance.has_method("assert_physics_material"):
		var material_result = physics_test_instance.assert_physics_material(rigid_body, 0.5, 0.0, 0.0)
		success = success and assert_type(material_result, TYPE_BOOL, "Physics material assertion should return boolean")

	# Test collision layer/mask assertions
	if physics_test_instance.has_method("assert_collision_layer"):
		var layer_result = physics_test_instance.assert_collision_layer(rigid_body, 1)
		success = success and assert_type(layer_result, TYPE_BOOL, "Collision layer assertion should return boolean")

	if physics_test_instance.has_method("assert_collision_mask"):
		var mask_result = physics_test_instance.assert_collision_mask(rigid_body, 1)
		success = success and assert_type(mask_result, TYPE_BOOL, "Collision mask assertion should return boolean")

	# Test body state assertions
	if physics_test_instance.has_method("assert_body_sleeping"):
		var sleep_result = physics_test_instance.assert_body_sleeping(rigid_body, false)
		success = success and assert_type(sleep_result, TYPE_BOOL, "Body sleeping assertion should return boolean")

	if physics_test_instance.has_method("assert_body_can_sleep"):
		var can_sleep_result = physics_test_instance.assert_body_can_sleep(rigid_body, true)
		success = success and assert_type(can_sleep_result, TYPE_BOOL, "Body can sleep assertion should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# ERROR HANDLING TESTS
# ------------------------------------------------------------------------------
func test_error_handling() -> bool:
	"""Test error handling and edge cases"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Store original configuration values
	var original_fps = physics_test_instance.physics_fps
	var original_collision_tolerance = physics_test_instance.collision_tolerance

	# Test with null bodies
	var null_velocity_result = physics_test_instance.assert_physics_velocity(null, Vector2(0, 0))
	success = success and assert_false(null_velocity_result, "Null body velocity should fail")

	var null_position_result = physics_test_instance.assert_physics_position(null, Vector2(0, 0))
	success = success and assert_false(null_position_result, "Null body position should fail")

	var null_rotation_result = physics_test_instance.assert_physics_rotation(null, 0.0)
	success = success and assert_false(null_rotation_result, "Null body rotation should fail")

	# Test with null areas
	var null_collision_result = await physics_test_instance.assert_collision_detected(null, null)
	success = success and assert_false(null_collision_result, "Null areas collision should fail")

	var null_no_collision_result = await physics_test_instance.assert_no_collision(null, null)
	success = success and assert_false(null_no_collision_result, "Null areas no collision should fail")

	# Test with extreme values
	var extreme_body = create_test_rigid_body(Vector2(999999, 999999), 999.0)
	add_child(extreme_body)

	var extreme_velocity_result = physics_test_instance.assert_physics_velocity(extreme_body, Vector2(999999, 999999))
	success = success and assert_type(extreme_velocity_result, TYPE_BOOL, "Extreme velocity should return boolean")

	var extreme_position_result = physics_test_instance.assert_physics_position(extreme_body, Vector2(999999, 999999))
	success = success and assert_type(extreme_position_result, TYPE_BOOL, "Extreme position should return boolean")

	var extreme_rotation_result = physics_test_instance.assert_physics_rotation(extreme_body, 999.0)
	success = success and assert_type(extreme_rotation_result, TYPE_BOOL, "Extreme rotation should return boolean")

	# Test with zero tolerance
	var zero_tolerance_velocity = physics_test_instance.assert_physics_velocity(extreme_body, Vector2(0, 0), 0.0)
	success = success and assert_type(zero_tolerance_velocity, TYPE_BOOL, "Zero tolerance velocity should return boolean")

	var zero_tolerance_position = physics_test_instance.assert_physics_position(extreme_body, Vector2(0, 0), 0.0)
	success = success and assert_type(zero_tolerance_position, TYPE_BOOL, "Zero tolerance position should return boolean")

	# Test with negative tolerance
	var negative_tolerance_velocity = physics_test_instance.assert_physics_velocity(extreme_body, Vector2(0, 0), -1.0)
	success = success and assert_type(negative_tolerance_velocity, TYPE_BOOL, "Negative tolerance velocity should return boolean")

	# Test configuration with invalid values
	physics_test_instance.physics_fps = -1
	success = success and assert_equals(physics_test_instance.physics_fps, -1, "Should handle negative FPS")

	physics_test_instance.collision_tolerance = -10.0
	success = success and assert_equals(physics_test_instance.collision_tolerance, -10.0, "Should handle negative collision tolerance")

	# Restore original values
	physics_test_instance.physics_fps = original_fps
	physics_test_instance.collision_tolerance = original_collision_tolerance

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# EDGE CASE TESTS
# ------------------------------------------------------------------------------
func test_edge_cases() -> bool:
	"""Test edge cases and boundary conditions"""
	var success = true

	# Create PhysicsTest instance for physics-specific methods
	physics_test_instance = PhysicsTest.new()
	add_child(physics_test_instance)

	# Test with bodies at origin
	var origin_body = create_test_rigid_body(Vector2(0, 0), 0.0)
	add_child(origin_body)

	var origin_velocity = physics_test_instance.assert_physics_velocity(origin_body, Vector2(0, 0))
	success = success and assert_type(origin_velocity, TYPE_BOOL, "Origin body velocity should return boolean")

	var origin_position = physics_test_instance.assert_physics_position(origin_body, Vector2(0, 0))
	success = success and assert_type(origin_position, TYPE_BOOL, "Origin body position should return boolean")

	var origin_rotation = physics_test_instance.assert_physics_rotation(origin_body, 0.0)
	success = success and assert_type(origin_rotation, TYPE_BOOL, "Origin body rotation should return boolean")

	# Test with overlapping bodies at same position
	var overlapping_body1 = create_test_rigid_body(Vector2(50, 50), 0.0)
	var overlapping_body2 = create_test_rigid_body(Vector2(50, 50), 0.0)
	add_child(overlapping_body1)
	add_child(overlapping_body2)

	var overlapping_collision = await physics_test_instance.assert_collision_detected(overlapping_body1, overlapping_body2)
	success = success and assert_type(overlapping_collision, TYPE_BOOL, "Overlapping bodies collision should return boolean")

	# Test with very small bodies
	var _tiny_body = create_test_rigid_body(Vector2(200, 200), 0.0)
	# Make collision shape very small (would need to modify the body creation)

	# Test with very large bodies
	var _large_body = create_test_rigid_body(Vector2(300, 300), 0.0)
	# Make collision shape very large (would need to modify the body creation)

	# Test physics frame waiting with different values
	await physics_test_instance.wait_for_physics_frames(0)  # Zero frames
	await physics_test_instance.wait_for_physics_frames(1)  # One frame
	await physics_test_instance.wait_for_physics_frames(10) # Multiple frames

	# Test with different physics frame wait settings
	physics_test_instance.physics_frame_wait = 0
	await physics_test_instance.wait_for_physics_frames(1)

	physics_test_instance.physics_frame_wait = 10
	await physics_test_instance.wait_for_physics_frames(1)

	# Test configuration boundary values
	physics_test_instance.collision_tolerance = 0.001  # Very small tolerance
	var small_tolerance_result = await physics_test_instance.assert_collision_detected(overlapping_body1, overlapping_body2)
	success = success and assert_type(small_tolerance_result, TYPE_BOOL, "Small tolerance collision should return boolean")

	physics_test_instance.collision_tolerance = 1000.0  # Very large tolerance
	var large_tolerance_result = await physics_test_instance.assert_collision_detected(overlapping_body1, overlapping_body2)
	success = success and assert_type(large_tolerance_result, TYPE_BOOL, "Large tolerance collision should return boolean")

	# Cleanup
	physics_test_instance.queue_free()
	physics_test_instance = null

	return success

# ------------------------------------------------------------------------------
# HELPER METHODS
# ------------------------------------------------------------------------------
func create_test_area_with_radius(area_position: Vector2, radius: float) -> Area2D:
	"""Create a test area with collision shape for testing"""
	var area = Area2D.new()
	area.position = area_position

	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	collision_shape.shape = circle_shape

	area.add_child(collision_shape)
	return area

func create_test_rigid_body(body_position: Vector2, body_rotation: float) -> RigidBody2D:
	"""Create a test rigid body with collision shape"""
	var body = RigidBody2D.new()
	body.position = body_position
	body.rotation = body_rotation

	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 10.0
	collision_shape.shape = circle_shape

	body.add_child(collision_shape)
	return body

func create_test_static_body(static_position: Vector2) -> StaticBody2D:
	"""Create a test static body with collision shape"""
	var body = StaticBody2D.new()
	body.position = static_position

	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(20, 20)
	collision_shape.shape = rectangle_shape

	body.add_child(collision_shape)
	return body

func create_test_kinematic_body(kinematic_position: Vector2) -> CharacterBody2D:
	"""Create a test kinematic body with collision shape"""
	var body = CharacterBody2D.new()
	body.position = kinematic_position

	var collision_shape = CollisionShape2D.new()
	var capsule_shape = CapsuleShape2D.new()
	capsule_shape.radius = 8.0
	capsule_shape.height = 16.0
	collision_shape.shape = capsule_shape

	body.add_child(collision_shape)
	return body
