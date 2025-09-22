Physics Testing Tutorial
========================

Physics testing ensures that your game's physical interactions behave correctly and predictably. This tutorial covers GDSentry's comprehensive physics testing capabilities for collision detection, force application, and physics state validation.

.. note::
   **Prerequisites**: Basic familiarity with GDSentry testing and Godot's physics system. Complete the :doc:`../getting-started` guide first.

What is Physics Testing?
========================

Physics testing validates:
- Collision detection between objects
- Force and impulse responses
- Velocity and position changes
- Physics body interactions
- Joint and constraint behaviors
- Physics simulation determinism

Unlike visual testing that checks *appearance*, physics testing validates *behavior* under physical forces and interactions.

When to Use Physics Testing
===========================

Physics tests are essential for:

- **Collision Systems**: Character-enemy interactions, projectile collisions
- **Physics Puzzles**: Platforming mechanics, object interactions
- **Force-Based Gameplay**: Physics-based movement, environmental interactions
- **Destructible Environments**: Breaking objects, physics debris
- **Vehicle Physics**: Car movement, wheel traction
- **Ragdoll Systems**: Character physics, cloth simulation

Setting Up a Physics Test
=========================

Create a new test class that extends ``PhysicsTest``:

.. code-block:: gdscript

    extends GDSentry.PhysicsTest

    func test_ball_collision() -> bool:
        # Physics test implementation
        return true

Physics Test Configuration
==========================

Configure physics testing parameters:

.. code-block:: gdscript

    func before_test() -> void:
        # Configure physics testing parameters
        physics_fps = 60
        simulation_speed = 1.0
        collision_tolerance = 1.0
        velocity_tolerance = 0.1
        position_tolerance = 1.0
        physics_frame_wait = 2  # Wait 2 physics frames for stabilization

Creating Physics Bodies for Testing
===================================

Set up physics bodies in your test scene:

.. code-block:: gdscript

    func test_physics_body_creation() -> bool:
        # Create a test scene with physics bodies
        var scene = load_test_scene("res://scenes/physics_test.tscn")

        # Find or create physics bodies
        var ball = find_node_by_type(scene, RigidBody2D)
        var ground = find_node_by_type(scene, StaticBody2D)

        # Verify bodies exist and are configured
        assert_not_null(ball, "Ball physics body should exist")
        assert_not_null(ground, "Ground physics body should exist")

        # Check physics properties
        assert_true(ball is RigidBody2D, "Ball should be a rigid body")
        assert_gt(ball.mass, 0, "Ball should have mass")

        return true

Testing Collision Detection
===========================

Verify that objects collide as expected:

.. code-block:: gdscript

    func test_ball_ground_collision() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")
        var ball = find_node_by_type(scene, RigidBody2D)
        var ground = find_node_by_type(scene, Area2D)  # Using areas for collision detection

        # Position ball above ground
        ball.position = Vector2(400, 100)

        # Let physics run for a few frames
        await wait_for_physics_frames(physics_frame_wait)

        # Check that ball has collided with ground (stopped falling)
        assert_collision_detected(ball, ground, "Ball should collide with ground")

        return true

Testing Collision Avoidance
===========================

Verify that objects don't collide when they shouldn't:

.. code-block:: gdscript

    func test_objects_no_collision() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")
        var ball1 = find_node_by_name(scene, "Ball1")
        var ball2 = find_node_by_name(scene, "Ball2")

        # Position balls far apart
        ball1.position = Vector2(200, 300)
        ball2.position = Vector2(600, 300)

        # Let physics settle
        await wait_for_physics_frames(physics_frame_wait)

        # Verify no collision occurred
        assert_no_collision(ball1, ball2, "Separated balls should not collide")

        return true

Testing Velocity and Movement
=============================

Validate physics body movement:

.. code-block:: gdscript

    func test_ball_velocity() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")
        var ball = find_node_by_type(scene, RigidBody2D)

        # Set initial position and velocity
        ball.position = Vector2(400, 300)
        ball.linear_velocity = Vector2(100, -50)  # Move right and up

        # Let physics run
        await wait_for_physics_frames(5)

        # Check that velocity has changed (gravity affects Y velocity)
        assert_gt(ball.linear_velocity.x, 95, "Horizontal velocity should be maintained")
        assert_lt(ball.linear_velocity.y, -40, "Vertical velocity should decrease due to gravity")

        return true

Testing Force Application
=========================

Test how objects respond to forces:

.. code-block:: gdscript

    func test_force_application() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")
        var ball = find_node_by_type(scene, RigidBody2D)

        # Record initial velocity
        var initial_velocity = ball.linear_velocity

        # Apply a test force
        apply_test_impulse(ball, Vector2(200, -100))

        # Wait for physics to process
        await wait_for_physics_frames(physics_frame_wait)

        # Check velocity change
        var velocity_change = ball.linear_velocity - initial_velocity
        assert_gt(velocity_change.x, 180, "Horizontal velocity should increase significantly")
        assert_lt(velocity_change.y, -80, "Vertical velocity should decrease (upward force)")

        return true

Testing Force Response
======================

Validate complete force response behavior:

.. code-block:: gdscript

    func test_force_response() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")
        var ball = find_node_by_type(scene, RigidBody2D)

        # Test force response
        var test_force = Vector2(150, 0)  # Push right
        var expected_velocity_change = Vector2(15, 0)  # Expected response

        return assert_force_response(ball, test_force, expected_velocity_change, 2.0,
                                   "Ball should respond correctly to horizontal force")

Testing Angular Physics
=======================

Test rotation and angular velocity:

.. code-block:: gdscript

    func test_angular_velocity() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")
        var spinner = find_node_by_name(scene, "Spinner")

        # Apply torque to start spinning
        spinner.apply_torque_impulse(10.0)

        # Wait for physics
        await wait_for_physics_frames(physics_frame_wait)

        # Check angular velocity
        assert_gt(abs(spinner.angular_velocity), 0.1, "Object should be rotating")

        return true

Testing Joints and Constraints
==============================

Test physics joints and constraints:

.. code-block:: gdscript

    func test_joint_constraint() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")

        # Find objects connected by joint
        var parent = find_node_by_name(scene, "Parent")
        var child = find_node_by_name(scene, "Child")
        var joint = find_node_by_type(scene, PinJoint2D)

        assert_not_null(joint, "Joint should exist")

        # Apply force to parent
        apply_test_impulse(parent, Vector2(100, 0))

        # Wait for physics
        await wait_for_physics_frames(physics_frame_wait)

        # Check that child follows parent (constrained movement)
        var distance = parent.position.distance_to(child.position)
        assert_lt(distance, joint.softness + 5.0, "Child should follow parent within joint constraints")

        return true

Testing Physics Determinism
===========================

Ensure physics simulation is deterministic:

.. code-block:: gdscript

    func test_physics_determinism() -> bool:
        # Run the same physics simulation multiple times
        var results = []

        for i in range(3):
            var scene = load_test_scene("res://scenes/physics_test.tscn")
            var ball = find_node_by_type(scene, RigidBody2D)

            # Set identical initial conditions
            ball.position = Vector2(400, 100)
            ball.linear_velocity = Vector2(50, -30)

            # Run simulation
            await wait_for_physics_frames(10)

            # Record final position
            results.append(ball.position)

        # Check that all results are identical (deterministic)
        for i in range(1, results.size()):
            var distance = results[0].distance_to(results[i])
            assert_lt(distance, 0.1, "Physics should be deterministic - results should be identical")

        return true

Performance Testing in Physics
==============================

Monitor physics performance:

.. code-block:: gdscript

    func test_physics_performance() -> bool:
        var scene = load_test_scene("res://scenes/physics_test.tscn")

        # Start physics monitoring
        start_physics_monitoring()

        # Create many physics objects for stress test
        for i in range(50):
            var ball = RigidBody2D.new()
            ball.position = Vector2(randf() * 800, randf() * 600)
            scene.add_child(ball)

        # Run simulation
        await wait_for_physics_frames(60)  # 1 second at 60fps

        # Check physics performance
        var stats = get_physics_stats()
        assert_lt(stats.frame_time_avg, 16.7, "Physics should maintain 60fps performance")
        assert_lt(stats.collision_checks, 10000, "Collision checks should be reasonable")

        return true

Best Practices for Physics Testing
==================================

**Test Organization**
- Group physics tests by mechanic (collision, forces, joints)
- Use consistent physics settings across related tests
- Separate unit physics tests from integration tests

**Performance Considerations**
- Physics tests can be slower due to frame waiting
- Use appropriate tolerances for floating-point comparisons
- Run physics tests less frequently in CI/CD if they're slow

**Debugging Physics Tests**
- Use ``assert_physics_velocity()`` to check movement
- Visualize physics bodies with debug drawing
- Log physics stats for performance issues

**Test Data Management**
- Reset physics state between tests
- Use fixed random seeds for deterministic tests
- Clean up test objects after each test

Common Issues and Solutions
===========================

**Non-Deterministic Results**
- Ensure identical initial conditions
- Use fixed time steps
- Avoid random number generation in physics tests

**Timing Issues**
- Use ``await wait_for_physics_frames()`` instead of time delays
- Account for physics frame timing variations
- Test multiple physics frames for stabilization

**Collision Detection Problems**
- Use appropriate collision shapes
- Check collision layer/mask settings
- Ensure bodies are in the correct physics space

**Force Application Issues**
- Verify force magnitudes are appropriate for object mass
- Check force application points (center vs offset)
- Account for counter-forces (gravity, friction)

Next Steps
==========

Now that you understand physics testing:

1. **Practice**: Create physics tests for your game's collision systems
2. **Explore**: Try the :doc:`performance-testing` tutorial for benchmarking
3. **Advanced**: Learn about :doc:`ci-integration` for automated physics testing

.. seealso::
   :doc:`../examples` - More physics testing code examples
   :doc:`../best-practices` - Physics testing guidelines
   :doc:`../troubleshooting` - Troubleshooting physics test failures
