extends SceneTree
var failures: int = 0
var respawns: int = 0
var deaths: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: ", message)

func ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func block_at(position: Vector3, size: Vector3) -> StaticBody3D:
	var block := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	block.add_child(collider)
	root.add_child(block)
	block.position = position
	return block

func run() -> void:
	var packed = load("res://scenes/boot/main.tscn")
	var scene = packed.instantiate()
	root.add_child(scene)
	await ticks(30)
	var player = scene.get_node("Player")
	var dummy = scene.get_node("Dummy")
	var health = player.get_node("Health")
	var life = player.get_node("Respawn")
	var combat = player.get_node("Combat")
	var controls = player.get_node("PlayerInput")
	var node_count: int = scene.find_children("*", "", true, false).size()
	life.respawned.connect(func(): respawns += 1)
	health.died.connect(func(): deaths += 1)
	player.position = Vector3(-8,0.1,8)
	player.get_node("Posture").toggle()
	player.get_node("View").rotation = Vector3(0.4,1,0)
	player.apply_knockback(Vector3(2,3,0))
	combat.request_tag()
	health.apply_damage(1000)
	check(health.is_dead and life.waiting, "Death schedules one respawn")
	health.apply_damage(1000)
	check(deaths == 1, "Repeated lethal damage does not duplicate death")
	await ticks(120)
	check(health.is_dead and respawns == 0, "Default delay does not respawn early")
	await ticks(65)
	check(not health.is_dead and health.current_health == 100.0 and respawns == 1, "Default three-second respawn restores HP once")
	check(Vector2(player.position.x, player.position.z).distance_to(Vector2(0,8)) < 0.01, "Player returns to original spawn")
	check(player.velocity.length() < 0.01 and player.get_node("Knockback").horizontal == Vector3.ZERO, "Respawn clears velocity and external impulse")
	check(not player.get_node("Posture").crouched and is_equal_approx(player.get_node("Collider").shape.height, 1.8), "Respawn restores standing capsule")
	check(player.get_node("View").rotation == Vector3.ZERO and is_equal_approx(player.get_node("View").position.y, 1.65), "Respawn restores FPS eye and aim")
	check(combat.cooldown_remaining == 0.0 and not life.waiting, "Combat ready and respawn schedule cleared")
	check(not controls.controls_active, "Respawn does not steal pointer capture")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	controls._unhandled_input(click)
	await ticks(2)
	check(controls.controls_active and combat.cooldown_remaining == 0.0, "Resume click captures without firing")
	# Fast repeat fixture, after default-delay behavior was tested above.
	life.respawn_delay = 0.05
	combat.request_tag()
	await ticks(2)
	check(combat.cooldown_remaining > 1.8, "Fast-reset fixture begins with active shot cooldown")
	for i in range(3):
		player.apply_knockback(Vector3(10,3,0))
		health.apply_damage(1000)
		await ticks(10)
		if i == 0:
			check(combat.cooldown_remaining == 0.0 and player.get_node("Knockback").horizontal == Vector3.ZERO, "Fast respawn clears unexpired cooldown and residual impulse")
	check(respawns == 4 and deaths == 4 and not health.is_dead, "Repeated death/respawn cycles remain one-to-one")
	check(scene.find_children("*", "", true, false).size() == node_count, "Repeated respawn does not add nodes")
	# Target's spawn blocked by solid geometry; it must stay dead until space clears.
	var dummy_life = dummy.get_node("Respawn")
	dummy_life.respawn_delay = 0.05
	dummy.position = Vector3(8,0.01,4)
	var blocker := block_at(Vector3(3,1,2), Vector3(1.5,2,1.5))
	await ticks(2)
	dummy.get_node("Health").apply_damage(1000)
	await ticks(10)
	check(dummy.get_node("Health").is_dead and dummy_life.spawn_blocked, "Occupied spawn postpones dummy respawn")
	check(scene.get_node("Dummy/Label3D").text.contains("blocked"), "Blocked spawn is explained in UI")
	blocker.queue_free()
	await ticks(20)
	check(not dummy.get_node("Health").is_dead and dummy.position.distance_to(Vector3(3,0,2)) < 0.05, "Dummy respawns when obstruction clears")
	check(dummy.get_node("Health").current_health == 100.0 and dummy.velocity.length() < 0.01, "Dummy resets health and movement")
	# Standing clearance must be used even if death happened while crouched.
	player.get_node("Posture").toggle()
	player.position = Vector3(-8,0.1,8)
	var roof := block_at(Vector3(0,1.5,8), Vector3(3,0.2,3))
	await ticks(2)
	health.apply_damage(1000)
	await ticks(10)
	check(health.is_dead and life.spawn_blocked, "Crouched death still checks full standing spawn shape")
	roof.queue_free()
	await ticks(20)
	check(not health.is_dead and not player.get_node("Posture").crouched, "Cleared spawn restores standing safely")
	# Reload with pending death must not leave scene-independent timers or callbacks.
	health.apply_damage(1000)
	scene.queue_free()
	await process_frame
	scene = packed.instantiate()
	root.add_child(scene)
	await ticks(20)
	check(scene.get_node("Player/Health").current_health == 100.0 and not scene.get_node("Player/Respawn").waiting, "Reload starts clean with no pending old respawn")
	scene.queue_free()
	await process_frame
	print("M06 failures: ", failures)
	quit(1 if failures else 0)
