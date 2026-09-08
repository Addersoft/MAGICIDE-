extends SceneTree
var failures: int = 0
var deaths: int = 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: ",message)
func ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func run() -> void:
	var scene = load("res://scenes/boot/main.tscn").instantiate()
	root.add_child(scene)
	await ticks(30)
	var player = scene.get_node("Player")
	var health = player.get_node("Health")
	var dummy = scene.get_node("Dummy/Health")
	health.died.connect(func(): deaths += 1)
	check(health.current_health == 100.0 and dummy.current_health == 100.0, "Both actors start at 100 HP")
	check(health.apply_damage(-1.0) == 0.0 and health.apply_damage(NAN) == 0.0 and health.apply_damage(INF) == 0.0 and health.current_health == 100.0, "Invalid damage rejected")
	check(health.apply_damage(25.0) == 25.0 and health.current_health == 75.0, "Damage subtracts HP")
	check(dummy.current_health == 100.0, "Actors have independent health")
	dummy.apply_damage(1000.0)
	check(dummy.is_dead and dummy.current_health == 0.0, "Dummy lethal damage clamps to zero")
	check(scene.get_node("Dummy/Label3D").text.contains("DEAD"), "Dummy death presentation updates")
	# A listener recursively applying damage must not emit death twice.
	health.health_changed.connect(func(_a, _b): health.apply_damage(1.0) if health.is_dead else 0.0)
	check(health.apply_damage(999.0) == 75.0, "Overkill returns actual removed HP")
	check(health.is_dead and deaths == 1, "Reentrant lethal damage emits death once")
	health.apply_damage(10.0)
	check(deaths == 1 and health.current_health == 0.0, "Dead target rejects subsequent damage")
	player.player_input.set_capture(true)
	check(not player.player_input.controls_active, "Dead player cannot recapture controls")
	Input.action_press("move_forward")
	Input.action_press("jump")
	await ticks(3)
	check(player.velocity.length() < 0.01, "Dead player cannot move or jump")
	check(scene.get_node("HUD/HealthStatus").text.contains("DEAD"), "Player death HUD updates")
	Input.action_release("move_forward")
	Input.action_release("jump")
	scene.queue_free()
	await process_frame
	print("M04 failures: ",failures)
	quit(1 if failures else 0)
