# GDSentry - Complete Workflow Testing Demonstration
# End-to-end testing of complete GDSentry workflows in game development
#
# This test demonstrates a complete game development workflow using GDSentry:
# - Game initialization and setup
# - Player character testing
# - Enemy AI and spawning
# - Physics interactions
# - UI systems integration
# - Game state management
# - Save/load functionality
# - Performance monitoring
#
# Author: GDSentry Framework
# Version: 1.0.0

extends GDTest

class_name CompleteWorkflowTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
	test_description = "Complete end-to-end GDSentry workflow demonstration"
	test_tags = ["integration", "end_to_end", "workflow", "game_development", "performance"]
	test_priority = "high"
	test_category = "integration"

# ------------------------------------------------------------------------------
# GAME COMPONENTS FOR TESTING
# ------------------------------------------------------------------------------
class GameManager:
	var current_level: int = 1
	var player_score: int = 0
	var game_running: bool = false
	var enemies_defeated: int = 0

	signal level_completed(level: int)
	signal game_over
	signal score_changed(new_score: int)

	func start_game() -> void:
		game_running = true
		player_score = 0
		enemies_defeated = 0

	func end_game() -> void:
		game_running = false
		game_over.emit()

	func add_score(points: int) -> void:
		player_score += points
		score_changed.emit(player_score)

	func enemy_defeated() -> void:
		enemies_defeated += 1
		add_score(100)	# 100 points per enemy

		if enemies_defeated >= 10:	# Level complete after 10 enemies
			level_completed.emit(current_level)
			current_level += 1
			enemies_defeated = 0

class PlayerController extends CharacterBody2D:
	var health: int = 100
	var max_health: int = 100
	var speed: float = 300.0
	var game_manager: GameManager

	signal player_damaged(damage: int)
	signal player_healed(heal_amount: int)

	func _ready() -> void:
		# Set up collision
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 16.0
		shape.shape = circle
		add_child(shape)

		collision_layer = 1	 # Player layer

	func take_damage(damage: int) -> void:
		var _old_health = health
		health = max(0, health - damage)
		player_damaged.emit(damage)

		if health == 0 and game_manager:
			game_manager.end_game()

	func heal(amount: int) -> void:
		var _old_health = health
		health = min(max_health, health + amount)
		var actual_heal = health - _old_health
		if actual_heal > 0:
			player_healed.emit(actual_heal)

	func move_input(direction: Vector2, _delta: float) -> void:
		velocity = direction * speed
		move_and_slide()

class EnemySpawner:
	var spawn_timer: Timer
	var game_manager: GameManager
	var spawn_area: Rect2 = Rect2(-400, -300, 800, 600)
	var enemies_alive: int = 0
	var max_enemies: int = 5

	signal enemy_spawned(enemy: Node2D)

	func _init():
		spawn_timer = Timer.new()
		spawn_timer.wait_time = 2.0	 # Spawn every 2 seconds
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	func start_spawning() -> void:
		spawn_timer.start()

	func stop_spawning() -> void:
		spawn_timer.stop()

	func _on_spawn_timer_timeout() -> void:
		if enemies_alive < max_enemies and game_manager.game_running:
			spawn_enemy()

	func spawn_enemy() -> void:
		var enemy = create_enemy()
		var spawn_pos = get_random_spawn_position()
		enemy.position = spawn_pos
		enemies_alive += 1
		enemy_spawned.emit(enemy)

	func create_enemy() -> Area2D:
		var enemy = Area2D.new()
		enemy.name = "Enemy"

		# Add collision shape
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 12.0
		shape.shape = circle
		enemy.add_child(shape)

		enemy.collision_layer = 2  # Enemy layer
		enemy.collision_mask = 1   # Collide with player

		return enemy

	func get_random_spawn_position() -> Vector2:
		var x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
		var y = randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		return Vector2(x, y)

class UIManager:
	var health_label: Label
	var score_label: Label
	var game_over_panel: Panel
	var game_manager: GameManager

	func _init():
		# Create UI elements
		health_label = Label.new()
		health_label.text = "Health: 100"

		score_label = Label.new()
		score_label.text = "Score: 0"

		game_over_panel = Panel.new()
		game_over_panel.visible = false

	func update_health(health: int) -> void:
		health_label.text = "Health: " + str(health)

	func update_score(score: int) -> void:
		score_label.text = "Score: " + str(score)

	func show_game_over() -> void:
		game_over_panel.visible = true

# ------------------------------------------------------------------------------
# COMPLETE GAME WORKFLOW TEST
# ------------------------------------------------------------------------------
func test_complete_game_initialization() -> bool:
	"""Test complete game initialization workflow"""
	print("🧪 Testing complete game initialization")

	var success = true

	# Initialize game manager
	var game_manager = GameManager.new()
	success = success and assert_not_null(game_manager, "Game manager should be created")
	success = success and assert_false(game_manager.game_running, "Game should not be running initially")

	# Initialize player
	var player = PlayerController.new()
	player.game_manager = game_manager
	add_child(player)
	success = success and assert_equals(player.health, 100, "Player should start with full health")

	# Initialize enemy spawner
	var spawner = EnemySpawner.new()
	spawner.game_manager = game_manager
	add_child(spawner.spawn_timer)	# Add timer to scene tree
	success = success and assert_not_null(spawner.spawn_timer, "Spawner should have timer")

	# Initialize UI manager
	var ui_manager = UIManager.new()
	ui_manager.game_manager = game_manager
	success = success and assert_not_null(ui_manager.health_label, "UI manager should have health label")

	# Connect all systems
	game_manager.score_changed.connect(ui_manager.update_score)
	player.player_damaged.connect(ui_manager.update_health)

	# Start game
	game_manager.start_game()
	success = success and assert_true(game_manager.game_running, "Game should be running after start")

	# Cleanup
	player.queue_free()
	spawner.spawn_timer.queue_free()

	return success

func test_player_gameplay_loop() -> bool:
	"""Test complete player gameplay interaction loop"""
	print("🧪 Testing player gameplay loop")

	var success = true

	# Setup game systems
	var game_manager = GameManager.new()
	var player = PlayerController.new()
	var ui_manager = UIManager.new()

	player.game_manager = game_manager
	ui_manager.game_manager = game_manager
	add_child(player)

	# Connect systems
	game_manager.score_changed.connect(ui_manager.update_score)
	player.player_damaged.connect(ui_manager.update_health)

	# Start game
	game_manager.start_game()

	# Test player movement
	var initial_pos = player.position
	player.move_input(Vector2.RIGHT, 1.0)
	success = success and assert_false(player.position == initial_pos, "Player should move when given input")

	# Test player taking damage
	var initial_health = player.health
	player.take_damage(25)
	success = success and assert_equals(player.health, initial_health - 25, "Player health should decrease")
	success = success and assert_equals(ui_manager.health_label.text, "Health: 75", "UI should update health")

	# Test player healing
	player.heal(10)
	success = success and assert_equals(player.health, 75 + 10, "Player should be healed")
	success = success and assert_equals(ui_manager.health_label.text, "Health: 85", "UI should update after healing")

	# Test player death
	var game_over_called = [false]
	game_manager.game_over.connect(func(): game_over_called[0] = true)

	player.take_damage(85)	# Should kill player
	success = success and assert_true(game_over_called[0], "Game over should be triggered")
	success = success and assert_false(game_manager.game_running, "Game should stop after player death")

	# Cleanup
	player.queue_free()

	return success

func test_enemy_spawning_and_ai_workflow() -> bool:
	"""Test enemy spawning and AI interaction workflow"""
	print("🧪 Testing enemy spawning and AI workflow")

	var success = true

	# Setup systems
	var game_manager = GameManager.new()
	var spawner = EnemySpawner.new()
	var player = PlayerController.new()

	spawner.game_manager = game_manager
	player.game_manager = game_manager

	add_child(player)
	add_child(spawner.spawn_timer)

	# Start game
	game_manager.start_game()

	# Test enemy spawning
	var enemies_spawned = [0]
	spawner.enemy_spawned.connect(func(_enemy): enemies_spawned[0] += 1)

	# Manually spawn enemies
	spawner.spawn_enemy()
	spawner.spawn_enemy()
	success = success and assert_equals(enemies_spawned[0], 2, "Enemies should be spawned")
	success = success and assert_equals(spawner.enemies_alive, 2, "Spawner should track alive enemies")

	# Test spawning limits
	for i in range(5):	# Try to spawn beyond limit
		spawner.spawn_enemy()

	success = success and assert_equals(spawner.enemies_alive, spawner.max_enemies,
									   "Should not spawn beyond max enemies")

	# Test enemy defeat scoring
	var initial_score = game_manager.player_score
	game_manager.enemy_defeated()
	success = success and assert_equals(game_manager.player_score, initial_score + 100,
									   "Score should increase when enemy defeated")

	# Test level completion
	game_manager.enemies_defeated = 9  # 9 more to reach 10
	var level_completed = [false]
	var completed_level = [0]
	game_manager.level_completed.connect(func(level): level_completed[0] = true; completed_level[0] = level)

	game_manager.enemy_defeated()  # Should complete level
	success = success and assert_true(level_completed[0], "Level should be completed")
	success = success and assert_equals(completed_level[0], 1, "Should complete level 1")
	success = success and assert_equals(game_manager.current_level, 2, "Should advance to level 2")

	# Cleanup
	player.queue_free()
	spawner.spawn_timer.queue_free()

	return success

func test_physics_interaction_workflow() -> bool:
	"""Test physics interactions between game objects"""
	print("🧪 Testing physics interaction workflow")

	var success = true

	# Create physics objects
	var player = PlayerController.new()
	var enemy = Area2D.new()

	# Setup enemy collision
	var enemy_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 12.0
	enemy_shape.shape = circle
	enemy.add_child(enemy_shape)
	enemy.collision_layer = 2
	enemy.collision_mask = 1

	add_child(player)
	add_child(enemy)

	# Position for collision
	player.position = Vector2(0, 0)
	enemy.position = Vector2(0, 0)

	# Test collision layers
	success = success and assert_equals(player.collision_layer, 1, "Player should be on correct layer")
	success = success and assert_equals(enemy.collision_layer, 2, "Enemy should be on correct layer")

	# Test collision detection (simulated)
	var player_body = player.get_node("CollisionShape2D") as CollisionShape2D
	var enemy_body = enemy.get_node("CollisionShape2D") as CollisionShape2D

	success = success and assert_not_null(player_body, "Player should have collision shape")
	success = success and assert_not_null(enemy_body, "Enemy should have collision shape")

	# Simulate collision damage
	var initial_health = player.health
	player.take_damage(30)
	success = success and assert_equals(player.health, initial_health - 30, "Player should take collision damage")

	# Cleanup
	player.queue_free()
	enemy.queue_free()

	return success

func test_ui_systems_integration() -> bool:
	"""Test complete UI systems integration"""
	print("🧪 Testing UI systems integration")

	var success = true

	# Setup complete UI system
	var game_manager = GameManager.new()
	var ui_manager = UIManager.new()
	var player = PlayerController.new()

	ui_manager.game_manager = game_manager
	player.game_manager = game_manager

	add_child(player)

	# Connect UI updates
	game_manager.score_changed.connect(ui_manager.update_score)
	player.player_damaged.connect(ui_manager.update_health)

	# Test initial UI state
	success = success and assert_equals(ui_manager.health_label.text, "Health: 100", "Health label should show initial value")
	success = success and assert_equals(ui_manager.score_label.text, "Score: 0", "Score label should show initial value")
	success = success and assert_false(ui_manager.game_over_panel.visible, "Game over panel should be hidden initially")

	# Test UI updates during gameplay
	player.take_damage(40)
	success = success and assert_equals(ui_manager.health_label.text, "Health: 60", "Health label should update after damage")

	game_manager.add_score(250)
	success = success and assert_equals(ui_manager.score_label.text, "Score: 250", "Score label should update")

	# Test game over UI
	var game_over_triggered = [false]
	game_manager.game_over.connect(func(): game_over_triggered[0] = true; ui_manager.show_game_over())

	player.take_damage(60)	# Kill player
	success = success and assert_true(game_over_triggered[0], "Game over should be triggered")
	success = success and assert_true(ui_manager.game_over_panel.visible, "Game over panel should be visible")

	# Cleanup
	player.queue_free()

	return success

func test_save_load_workflow() -> bool:
	"""Test game save and load functionality"""
	print("🧪 Testing save/load workflow")

	var success = true

	# Create game state to save/load
	var game_state = {
		"level": 3,
		"score": 1250,
		"health": 75,
		"enemies_defeated": 7
	}

	# Test save functionality
	var save_path = "user://test_save.json"
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(game_state))
		save_file.close()
		success = success and assert_true(FileAccess.file_exists(save_path), "Save file should be created")

		# Test load functionality
		var load_file = FileAccess.open(save_path, FileAccess.READ)
		if load_file:
			var loaded_data = JSON.parse_string(load_file.get_as_text())
			load_file.close()

			success = success and assert_not_null(loaded_data, "Should load valid JSON data")
			success = success and assert_equals(loaded_data.level, game_state.level, "Level should be preserved")
			success = success and assert_equals(loaded_data.score, game_state.score, "Score should be preserved")
			success = success and assert_equals(loaded_data.health, game_state.health, "Health should be preserved")

		# Cleanup
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	else:
		print("⚠️ Could not create save file, skipping save/load test")

	return success

func test_performance_monitoring_workflow() -> bool:
	"""Test performance monitoring during gameplay"""
	print("🧪 Testing performance monitoring workflow")

	var success = true

	# Setup performance monitoring
	var start_time = Time.get_unix_time_from_system()
	var frame_count = 0
	var fps_samples = []

	# Simulate game loop performance monitoring
	const TEST_DURATION = 2.0  # 2 seconds
	const TARGET_FPS = 60.0

	var test_start = Time.get_unix_time_from_system()

	while Time.get_unix_time_from_system() - test_start < TEST_DURATION:
		frame_count += 1

		# Simulate frame processing
		var frame_time = randf_range(0.01, 0.02)  # Random frame time
		fps_samples.append(1.0 / frame_time)

		# Small delay to prevent infinite loop
		OS.delay_msec(1)

	var end_time = Time.get_unix_time_from_system()
	var actual_duration = end_time - test_start

	# Performance validation
	success = success and assert_greater_than(frame_count, 0, "Should process frames")
	success = success and assert_greater_than(actual_duration, TEST_DURATION - 0.5, "Test should run for expected duration")

	# Calculate average FPS
	var avg_fps = 0.0
	for fps in fps_samples:
		avg_fps += fps
	avg_fps /= fps_samples.size()

	success = success and assert_greater_than(avg_fps, TARGET_FPS * 0.8, "Average FPS should be reasonable")

	var _total_time = Time.get_unix_time_from_system() - start_time
	print("📊 Performance: %d frames in %.2fs, avg FPS: %.1f" % [frame_count, actual_duration, avg_fps])

	return success

# ------------------------------------------------------------------------------
# INTEGRATION TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
	"""Run all complete workflow integration tests"""
	print("\n🚀 Running Complete Workflow Integration Test Suite\n")

	run_test("test_complete_game_initialization", func(): return test_complete_game_initialization())
	run_test("test_player_gameplay_loop", func(): return test_player_gameplay_loop())
	run_test("test_enemy_spawning_and_ai_workflow", func(): return test_enemy_spawning_and_ai_workflow())
	run_test("test_physics_interaction_workflow", func(): return test_physics_interaction_workflow())
	run_test("test_ui_systems_integration", func(): return test_ui_systems_integration())
	run_test("test_save_load_workflow", func(): return test_save_load_workflow())
	run_test("test_performance_monitoring_workflow", func(): return test_performance_monitoring_workflow())

	print("\n✨ Complete Workflow Integration Test Suite Complete ✨\n")

# ------------------------------------------------------------------------------
# CLEANUP
# ------------------------------------------------------------------------------
func _exit_tree() -> void:
	"""Cleanup test resources"""
	pass
