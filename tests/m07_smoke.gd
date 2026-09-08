extends SceneTree
var failures: int = 0
var endings: int = 0
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
	current_scene = scene
	var manager = scene.get_node("RoundManager")
	manager.round_ended.connect(func(): endings += 1)
	check(manager.remaining == 180.0, "Round defaults to 180 seconds")
	await ticks(60)
	check(absf(manager.remaining - 179.0) < 0.03, "Timer follows fixed simulation time")
	var player = scene.get_node("Player")
	var dummy = scene.get_node("Dummy")
	var health = player.get_node("Health")
	var combat = player.get_node("Combat")
	# Stop a shot and an almost-ready respawn on the same tick as expiry.
	dummy.get_node("Health").apply_damage(1000)
	dummy.get_node("Respawn").remaining = 0.005
	player.player_input.controls_active = true
	combat.request_tag()
	manager.remaining = 0.005
	await ticks(2)
	check(manager.ended and manager.remaining == 0.0 and endings == 1, "Expiry ends round exactly once and clamps timer")
	check(combat.cooldown_remaining == 0.0, "Expiry cancels pending shot before combat tick")
	check(dummy.get_node("Health").is_dead, "Expiry stops pending respawn")
	check(not player.player_input.controls_active, "Round end releases pointer")
	player.player_input.set_capture(true)
	check(not player.player_input.controls_active, "Ended round cannot recapture gameplay")
	check(health.apply_damage(25) == 0.0 and health.current_health == 100.0, "Ended round rejects direct damage")
	var location: Vector3 = player.position
	Input.action_press("move_forward")
	Input.action_press("jump")
	await ticks(10)
	check(player.position == location, "Ended round freezes actor simulation")
	manager.end_round()
	check(endings == 1, "Repeated end request does not emit twice")
	check(scene.get_node("HUD/RoundEnd").visible and scene.get_node("HUD/RoundClock").text == "00:00", "End overlay and zero timer shown")
	Input.action_release("move_forward")
	Input.action_release("jump")
	# Exercise actual restart button and SceneTree reload, not a mocked actor reset.
	scene.get_node("HUD/RoundEnd/Panel/Restart").pressed.emit()
	manager.restart_round()
	await ticks(10)
	scene = current_scene
	manager = scene.get_node("RoundManager")
	player = scene.get_node("Player")
	dummy = scene.get_node("Dummy")
	check(not manager.ended and manager.remaining > 179.0, "Restart creates a fresh three-minute round")
	check(player.health.current_health == 100.0 and dummy.get_node("Health").current_health == 100.0, "Restart restores both actor health states")
	check(not dummy.get_node("Respawn").waiting and player.get_node("Combat").cooldown_remaining == 0.0, "Restart removes old respawn and attack state")
	check(Vector2(player.position.x,player.position.z).distance_to(Vector2(0,8)) < 0.01 and dummy.position.distance_to(Vector3(3,0,2)) < 0.05, "Restart restores spawn positions")
	check(not scene.get_node("HUD/RoundEnd").visible and player.process_mode != Node.PROCESS_MODE_DISABLED, "Restart restores play and hides overlay")
	var count: int = scene.find_children("*", "", true, false).size()
	for i in range(3):
		manager = current_scene.get_node("RoundManager")
		manager.end_round()
		manager.restart_round()
		await ticks(5)
	check(current_scene.find_children("*", "", true, false).size() == count, "Repeated round restarts keep node count stable")
	current_scene.queue_free()
	await process_frame
	print("M07 failures: ",failures)
	quit(1 if failures else 0)
