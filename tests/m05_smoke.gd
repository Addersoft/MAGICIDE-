extends SceneTree
var failures: int = 0
var shots: int = 0
var last_damage: float = -1.0

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

func click(controls: Node, ctrl: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.ctrl_pressed = ctrl
	controls._unhandled_input(event)

func run() -> void:
	var scene = load("res://scenes/boot/main.tscn").instantiate()
	root.add_child(scene)
	await ticks(30)
	var player = scene.get_node("Player")
	var dummy = scene.get_node("Dummy")
	var health = dummy.get_node("Health")
	var combat = player.get_node("Combat")
	var controls = player.get_node("PlayerInput")
	var view = player.get_node("View")
	combat.shot_resolved.connect(func(_point, damage): shots += 1; last_damage = damage)
	controls.controls_active = true
	view.look_at(dummy.position + Vector3(0,1.3,0))
	var before: Vector3 = dummy.position
	click(controls)
	await ticks(2)
	check(health.current_health == 88.0 and last_damage == 12.0, "LMB hits target for 12 HP")
	check(player.health.current_health == 100.0, "Ray excludes caster")
	check(combat.cooldown_remaining > 1.9 and combat.cooldown_remaining <= 2.0, "Accepted shot starts two-second cooldown")
	for i in range(5):
		click(controls)
		await ticks(1)
	check(shots == 1 and health.current_health == 88.0, "Repeated clicks during cooldown rejected")
	await ticks(55)
	check(dummy.position.distance_to(before) > 0.5, "Hit visibly displaces dummy")
	check(dummy.get_node("Knockback").horizontal.length() < 0.01, "Knockback decays to rest")
	check(combat.cooldown_remaining > 0.8, "Cooldown not expired after one second")
	await ticks(65)
	check(combat.cooldown_remaining == 0.0, "Cooldown expires in simulation time")
	# Occlusion fixture between stationary target and eye.
	dummy.position = Vector3(0,0.01,-3)
	dummy.velocity = Vector3.ZERO
	var wall := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3,4,0.2)
	collider.shape = shape
	wall.add_child(collider)
	root.add_child(wall)
	wall.position = Vector3(0,2,2)
	await ticks(3)
	view.look_at(dummy.position + Vector3(0,1.3,0))
	click(controls)
	await ticks(2)
	check(health.current_health == 88.0 and last_damage == 0.0 and shots == 2, "Wall blocks damage")
	check(combat.cooldown_remaining > 1.9, "Blocked shot still consumes cooldown")
	wall.queue_free()
	await ticks(123)
	controls.set_capture(false)
	click(controls)
	await ticks(2)
	check(shots == 2 and controls.controls_active, "Recapture click does not fire")
	click(controls, true)
	await ticks(2)
	check(shots == 2, "Ctrl+LMB reserved without firing Tag")
	# Queue then cancel before next physics step.
	click(controls)
	controls.set_capture(false)
	await ticks(2)
	check(shots == 2, "Capture loss cancels queued shot")
	controls.set_capture(true)
	view.look_at(dummy.position + Vector3(0,1.3,0))
	click(controls)
	await ticks(2)
	check(health.current_health == 76.0 and shots == 3, "Next ready shot deals same damage")
	# External impulses survive normal no-input player movement.
	player.apply_knockback(Vector3(4,3,0))
	await ticks(2)
	check(player.velocity.x > 3 and player.velocity.y > 0, "Player movement preserves external horizontal and vertical impulse")
	player.get_node("Posture").toggle()
	check(player.get_node("Knockback").horizontal.x > 3, "Crouch does not clear external impulse")
	await ticks(130)
	click(controls)
	player.health.apply_damage(1000)
	await ticks(2)
	check(shots == 3, "Death cancels queued attack")

	# Collision must discard blocked impulse rather than leave pressure accumulating.
	dummy.position = Vector3(18.8,0.01,5)
	dummy.velocity = Vector3.ZERO
	dummy.get_node("Knockback").horizontal = Vector3.ZERO
	await ticks(2)
	dummy.apply_knockback(Vector3(20,0,0))
	await ticks(30)
	check(dummy.position.x <= 19.11, "Knockback cannot push dummy through boundary wall")
	check(dummy.get_node("Knockback").horizontal.length() < 0.01, "Wall collision clears blocked impulse")
	scene.queue_free()
	await process_frame
	print("M05 failures: ", failures)
	quit(1 if failures else 0)
