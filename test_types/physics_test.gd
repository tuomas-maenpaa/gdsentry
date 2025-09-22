# GDSentry - Physics Test Class
# Specialized test class for physics simulation and validation
#
# Features:
# - Collision detection testing
# - Physics force and velocity validation
# - Physics body state verification
# - Joint and constraint testing
# - Physics performance monitoring
# - Deterministic physics testing
#
# Author: GDSentry Framework
# Version: 1.0.0

extends Node2DTest

class_name PhysicsTest

# ------------------------------------------------------------------------------
# PHYSICS TESTING CONSTANTS
# ------------------------------------------------------------------------------
const DEFAULT_PHYSICS_WAIT = 2
const COLLISION_TOLERANCE = 1.0
const VELOCITY_TOLERANCE = 0.1
const POSITION_TOLERANCE = 1.0
const FORCE_TEST_DURATION = 1.0

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
var config: GDTestConfig

# ------------------------------------------------------------------------------
# PHYSICS TEST STATE
# ------------------------------------------------------------------------------
var physics_fps: int = 60
var simulation_speed: float = 1.0
var collision_tolerance: float = COLLISION_TOLERANCE
var velocity_tolerance: float = VELOCITY_TOLERANCE
var position_tolerance: float = POSITION_TOLERANCE
var physics_frame_wait: int = DEFAULT_PHYSICS_WAIT

# ------------------------------------------------------------------------------
# PHYSICS MONITORING
# ------------------------------------------------------------------------------
var physics_stats: Dictionary = {}
var collision_history: Array = []

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------
func _ready() -> void:
	"""Initialize physics testing environment"""
	super._ready()

	# Initialize test configuration
	config = GDTestConfig.load_from_file()

	# Load physics test configuration
	load_physics_config()

	# Set up physics monitoring
	setup_physics_monitoring()

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------
func load_physics_config() -> void:
	"""Load physics testing configuration"""
	if config and config.physics_settings:
		physics_fps = config.physics_settings.get("physics_fps", 60)
		simulation_speed = config.physics_settings.get("simulation_speed", 1.0)
		collision_tolerance = config.collision_settings.get("overlap_tolerance", COLLISION_TOLERANCE)
		physics_frame_wait = config.collision_settings.get("physics_frame_wait", DEFAULT_PHYSICS_WAIT)

func setup_physics_monitoring() -> void:
	"""Set up physics monitoring and statistics collection"""
	physics_stats = {
		"frames_processed": 0,
		"collisions_detected": 0,
		"bodies_active": 0,
		"start_time": Time.get_ticks_usec()
	}

# ------------------------------------------------------------------------------
# COLLISION DETECTION TESTING
# ------------------------------------------------------------------------------
func assert_collision_detected(body1: Area2D, body2: Area2D, message: String = "") -> bool:
	"""Assert that two area bodies are colliding"""
	if not body1 or not body2:
		var error_msg = message if not message.is_empty() else "Cannot test collision with null area bodies"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	# Wait for physics to process
	await wait_for_physics_frames(physics_frame_wait)

	# Check for collision by testing overlap
	var collision_detected = _areas_are_colliding(body1, body2)

	if collision_detected:
		return true

	var final_error_msg = message if not message.is_empty() else "Expected collision between " + body1.name + " and " + body2.name
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_no_collision(body1: Area2D, body2: Area2D, message: String = "") -> bool:
	"""Assert that two area bodies are not colliding"""
	if not body1 or not body2:
		var error_msg = message if not message.is_empty() else "Cannot test collision with null area bodies"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	# Wait for physics to process
	await wait_for_physics_frames(physics_frame_wait)

	var collision_detected = _areas_are_colliding(body1, body2)

	if not collision_detected:
		return true

	var final_error_msg = message if not message.is_empty() else "Unexpected collision between " + body1.name + " and " + body2.name
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func _bodies_are_colliding(body1: PhysicsBody2D, body2: PhysicsBody2D) -> bool:
	"""Check if two physics bodies are colliding"""
	# Method 1: Check distance between bodies
	if body1 is RigidBody2D and body2 is RigidBody2D:
		var distance = body1.global_position.distance_to(body2.global_position)
		var combined_radius = _get_body_radius(body1) + _get_body_radius(body2)
		if distance <= combined_radius + collision_tolerance:
			return true

	# Method 2: Check for overlapping areas/shapes
	var shapes1 = _get_collision_shapes(body1)
	var shapes2 = _get_collision_shapes(body2)

	for shape1 in shapes1:
		for shape2 in shapes2:
			if _shapes_overlap(shape1, shape2, body1.global_transform, body2.global_transform):
				return true

	return false

func _areas_are_colliding(area1: Area2D, area2: Area2D) -> bool:
	"""Check if two areas are overlapping/colliding"""
	# Check if areas have overlapping collision shapes
	var shapes1 = _get_collision_shapes_from_area(area1)
	var shapes2 = _get_collision_shapes_from_area(area2)

	for shape1 in shapes1:
		for shape2 in shapes2:
			if _shapes_overlap(shape1, shape2, area1.global_transform, area2.global_transform):
				return true

	return false

func _get_collision_shapes_from_area(area: Area2D) -> Array:
	"""Get collision shapes from an Area2D"""
	var shapes = []
	for child in area.get_children():
		if child is CollisionShape2D:
			shapes.append(child)
	return shapes

func _get_body_radius(body: PhysicsBody2D) -> float:
	"""Estimate the radius of a physics body"""
	var max_radius = 0.0

	for child in body.get_children():
		if child is CollisionShape2D:
			var shape = child.shape
			if shape is CircleShape2D:
				max_radius = max(max_radius, shape.radius)
			elif shape is RectangleShape2D:
				var extents = shape.size / 2
				max_radius = max(max_radius, extents.length())
			elif shape is CapsuleShape2D:
				max_radius = max(max_radius, shape.height / 2 + shape.radius)

	return max_radius

func _get_collision_shapes(body: PhysicsBody2D) -> Array[CollisionShape2D]:
	"""Get all collision shapes from a physics body"""
	var shapes: Array[CollisionShape2D] = []

	for child in body.get_children():
		if child is CollisionShape2D:
			shapes.append(child)

	return shapes

func _shapes_overlap(shape1: CollisionShape2D, shape2: CollisionShape2D, transform1: Transform2D, transform2: Transform2D) -> bool:
	"""Check if two collision shapes overlap"""
	# Simplified overlap detection - in a real implementation, you'd use more sophisticated
	# collision detection algorithms based on the shape types
	var pos1 = transform1 * shape1.position
	var pos2 = transform2 * shape2.position

	var distance = pos1.distance_to(pos2)

	if shape1.shape is CircleShape2D and shape2.shape is CircleShape2D:
		return distance <= shape1.shape.radius + shape2.shape.radius + collision_tolerance
	elif shape1.shape is RectangleShape2D and shape2.shape is RectangleShape2D:
		var extents1 = shape1.shape.size / 2
		var extents2 = shape2.shape.size / 2
		var overlap_x = abs(pos1.x - pos2.x) <= (extents1.x + extents2.x + collision_tolerance)
		var overlap_y = abs(pos1.y - pos2.y) <= (extents1.y + extents2.y + collision_tolerance)
		return overlap_x and overlap_y

	return false

# ------------------------------------------------------------------------------
# PHYSICS STATE VERIFICATION
# ------------------------------------------------------------------------------
func assert_physics_velocity(body: PhysicsBody2D, expected_velocity: Vector2, tolerance: float = -1.0, message: String = "") -> bool:
	"""Assert that a physics body has the expected velocity"""
	if tolerance < 0:
		tolerance = velocity_tolerance

	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check velocity of null physics body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var actual_velocity = body.linear_velocity
	var velocity_diff = (actual_velocity - expected_velocity).length()

	if velocity_diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Velocity mismatch: expected " + str(expected_velocity) + ", got " + str(actual_velocity) + " (diff: " + str(velocity_diff) + ")"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_physics_position(body: PhysicsBody2D, expected_position: Vector2, tolerance: float = -1.0, message: String = "") -> bool:
	"""Assert that a physics body is at the expected position"""
	if tolerance < 0:
		tolerance = position_tolerance

	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check position of null physics body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var actual_position = body.global_position
	var position_diff = actual_position.distance_to(expected_position)

	if position_diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Position mismatch: expected " + str(expected_position) + ", got " + str(actual_position) + " (diff: " + str(position_diff) + ")"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_physics_rotation(body: PhysicsBody2D, expected_rotation: float, tolerance: float = 0.1, message: String = "") -> bool:
	"""Assert that a physics body has the expected rotation"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check rotation of null physics body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var actual_rotation = body.rotation
	var rotation_diff = abs(actual_rotation - expected_rotation)

	# Handle angle wrapping
	while rotation_diff > PI:
		rotation_diff -= 2 * PI
	rotation_diff = abs(rotation_diff)

	if rotation_diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Rotation mismatch: expected " + str(expected_rotation) + ", got " + str(actual_rotation) + " (diff: " + str(rotation_diff) + ")"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_physics_angular_velocity(body: PhysicsBody2D, expected_angular_velocity: float, tolerance: float = 0.1, message: String = "") -> bool:
	"""Assert that a physics body has the expected angular velocity"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check angular velocity of null physics body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var actual_angular_velocity = body.angular_velocity
	var velocity_diff = abs(actual_angular_velocity - expected_angular_velocity)

	if velocity_diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Angular velocity mismatch: expected " + str(expected_angular_velocity) + ", got " + str(actual_angular_velocity) + " (diff: " + str(velocity_diff) + ")"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

# ------------------------------------------------------------------------------
# FORCE AND IMPULSE TESTING
# ------------------------------------------------------------------------------
func apply_test_force(body: RigidBody2D, force: Vector2, duration: float = FORCE_TEST_DURATION) -> void:
	"""Apply a force to a rigid body for testing"""
	if not body:
		return

	body.apply_central_force(force)
	await wait_for_seconds(duration)
	body.apply_central_force(-force)  # Remove the force

func apply_test_impulse(body: RigidBody2D, impulse: Vector2) -> void:
	"""Apply an impulse to a rigid body for testing"""
	if not body:
		return

	body.apply_central_impulse(impulse)

func assert_force_response(body: RigidBody2D, force: Vector2, expected_velocity_change: Vector2, tolerance: float = 0.5, message: String = "") -> bool:
	"""Assert that a body responds correctly to a force"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot test force response on null body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	var initial_velocity = body.linear_velocity

	apply_test_impulse(body, force)

	# Wait for physics to process
	await wait_for_physics_frames(physics_frame_wait)

	var final_velocity = body.linear_velocity
	var actual_velocity_change = final_velocity - initial_velocity
	var velocity_diff = (actual_velocity_change - expected_velocity_change).length()

	if velocity_diff <= tolerance:
		return true

	var final_error_msg = message if not message.is_empty() else "Force response mismatch: expected change " + str(expected_velocity_change) + ", got " + str(actual_velocity_change) + " (diff: " + str(velocity_diff) + ")"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

# ------------------------------------------------------------------------------
# PHYSICS BODY STATE TESTING
# ------------------------------------------------------------------------------
func assert_physics_body_sleeping(body: RigidBody2D, message: String = "") -> bool:
	"""Assert that a physics body is sleeping"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check sleep state of null body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if body.sleeping:
		return true

	var final_error_msg = message if not message.is_empty() else "Physics body " + body.name + " is not sleeping"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_physics_body_awake(body: RigidBody2D, message: String = "") -> bool:
	"""Assert that a physics body is awake"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check sleep state of null body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if not body.sleeping:
		return true

	var final_error_msg = message if not message.is_empty() else "Physics body " + body.name + " is sleeping"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_physics_layer(body: PhysicsBody2D, expected_layer: int, message: String = "") -> bool:
	"""Assert that a physics body is on the expected collision layer"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check collision layer of null body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if body.collision_layer == expected_layer:
		return true

	var final_error_msg = message if not message.is_empty() else "Collision layer mismatch: expected " + str(expected_layer) + ", got " + str(body.collision_layer)
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_physics_mask(body: PhysicsBody2D, expected_mask: int, message: String = "") -> bool:
	"""Assert that a physics body has the expected collision mask"""
	if not body:
		var error_msg = message if not message.is_empty() else "Cannot check collision mask of null body"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if body.collision_mask == expected_mask:
		return true

	var final_error_msg = message if not message.is_empty() else "Collision mask mismatch: expected " + str(expected_mask) + ", got " + str(body.collision_mask)
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

# ------------------------------------------------------------------------------
# PHYSICS PERFORMANCE TESTING
# ------------------------------------------------------------------------------
func assert_physics_performance(max_frame_time: float = 16.67, message: String = "") -> bool:
	"""Assert that physics simulation performance is within acceptable limits"""
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)

	if physics_time <= max_frame_time:
		return true

	var error_msg = message if not message.is_empty() else "Physics frame time " + str(physics_time) + "ms exceeds limit " + str(max_frame_time) + "ms"
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

func assert_physics_active_bodies_count(expected_count: int, tolerance: int = 2, message: String = "") -> bool:
	"""Assert that the expected number of physics bodies are active"""
	var active_bodies = Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)

	if abs(active_bodies - expected_count) <= tolerance:
		return true

	var error_msg = message if not message.is_empty() else "Active physics bodies count mismatch: expected ~" + str(expected_count) + ", got " + str(active_bodies)
	GDTestManager.log_test_failure(current_test_name, error_msg)
	return false

# ------------------------------------------------------------------------------
# JOINT AND CONSTRAINT TESTING
# ------------------------------------------------------------------------------
func assert_joint_connected(joint: Joint2D, message: String = "") -> bool:
	"""Assert that a joint is properly connected"""
	if not joint:
		var error_msg = message if not message.is_empty() else "Cannot check connection of null joint"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if joint.node_a and joint.node_b:
		return true

	var final_error_msg = message if not message.is_empty() else "Joint " + joint.name + " is not properly connected"
	GDTestManager.log_test_failure(current_test_name, final_error_msg)
	return false

func assert_pin_joint_distance(pin_joint: PinJoint2D, expected_distance: float, tolerance: float = 1.0, message: String = "") -> bool:
	"""Assert that a pin joint maintains the expected distance"""
	if not pin_joint:
		var error_msg = message if not message.is_empty() else "Cannot check distance of null pin joint"
		GDTestManager.log_test_failure(current_test_name, error_msg)
		return false

	if not pin_joint.node_a or not pin_joint.node_b:
		var final_error_msg = message if not message.is_empty() else "Pin joint is not connected"
		GDTestManager.log_test_failure(current_test_name, final_error_msg)
		return false

	var body_a = get_node(pin_joint.node_a) as PhysicsBody2D
	var body_b = get_node(pin_joint.node_b) as PhysicsBody2D

	if not body_a or not body_b:
		var final_error_msg2 = message if not message.is_empty() else "Pin joint connected to invalid nodes"
		GDTestManager.log_test_failure(current_test_name, final_error_msg2)
		return false

	var actual_distance = body_a.global_position.distance_to(body_b.global_position)

	if abs(actual_distance - expected_distance) <= tolerance:
		return true

	var final_error_msg3 = message if not message.is_empty() else "Pin joint distance mismatch: expected " + str(expected_distance) + ", got " + str(actual_distance)
	GDTestManager.log_test_failure(current_test_name, final_error_msg3)
	return false

# ------------------------------------------------------------------------------
# UTILITY METHODS
# ------------------------------------------------------------------------------
func wait_for_physics_stable(body: PhysicsBody2D, timeout: float = 5.0) -> bool:
	"""Wait for a physics body to become stable (stop moving)"""
	if not body:
		return false

	var start_time = Time.get_ticks_usec()
	var last_velocity = body.linear_velocity

	while (Time.get_ticks_usec() - start_time) / 1000000.0 < timeout:
		await wait_for_physics_frames(1)

		var current_velocity = body.linear_velocity
		var velocity_diff = (current_velocity - last_velocity).length()

		if velocity_diff < velocity_tolerance:
			return true

		last_velocity = current_velocity

	return false

func reset_physics_world() -> void:
	"""Reset the physics world state"""
	# This would typically involve clearing all physics bodies and resetting the world
	# In a real implementation, you'd access the PhysicsServer2D
	pass

func set_physics_fps(fps: int) -> void:
	"""Set the physics simulation FPS"""
	physics_fps = fps
	Engine.physics_ticks_per_second = fps

func set_simulation_speed(speed: float) -> void:
	"""Set the physics simulation speed multiplier"""
	simulation_speed = speed
	Engine.time_scale = speed

# ------------------------------------------------------------------------------
# PHYSICS DEBUGGING UTILITIES
# ------------------------------------------------------------------------------
func enable_physics_debug(_enabled: bool = true) -> void:
	"""Enable physics debug visualization"""
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "PhysicsDebug"
	add_child(canvas_layer)

	# In a real implementation, you'd set up debug drawing for physics bodies
	# This is a simplified placeholder

func highlight_physics_body(body: PhysicsBody2D, color: Color = Color.RED, duration: float = 2.0) -> void:
	"""Highlight a physics body for debugging"""
	if not body:
		return

	# Create a visual indicator
	var indicator = ColorRect.new()
	indicator.color = color
	indicator.size = Vector2(20, 20)
	indicator.position = body.global_position - Vector2(10, 10)

	var canvas_layer = get_node_or_null("PhysicsDebug")
	if canvas_layer:
		canvas_layer.add_child(indicator)

		# Auto-remove after duration
		await wait_for_seconds(duration)
		if is_instance_valid(indicator):
			indicator.queue_free()

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup physics test resources"""
	super._exit_tree()
