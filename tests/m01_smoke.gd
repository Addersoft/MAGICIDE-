extends SceneTree
var failures: int = 0
var player: CharacterBody3D

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: ", message)

func ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func run() -> void:
	var scene = load("res://scenes/boot/main.tscn").instantiate()
	root.add_child(scene)
	player = scene.get_node("Player")
	await ticks(30)
	check(player.is_on_floor(), "Player settles on floor")
	check(scene.find_children("Player", "CharacterBody3D", true, false).size() == 1, "Exactly one player")
	check(player.get_node("View/Camera3D").current, "First-person camera active")
	var controls = player.get_node("PlayerInput")
	var view = player.get_node("View")
	controls.controls_active = true
	var start: Vector3 = player.position
	Input.action_press("move_forward")
	await ticks(60)
	Input.action_release("move_forward")
	check(absf(start.z - player.position.z - 6.0) < 0.15, "Forward travel is 6 m in 60 ticks")
	await ticks(2)
	check(Vector2(player.velocity.x, player.velocity.z).length() < 0.001, "Release stops horizontal movement")
	player.position = Vector3(0,0.01,8)
	view.rotation.x = deg_to_rad(70.0)
	Input.action_press("move_forward")
	Input.action_press("move_right")
	await ticks(10)
	check(absf(Vector2(player.velocity.x, player.velocity.z).length() - 6.0) < 0.01, "Diagonal speed normalized with pitched view")
	check(player.position.y < 0.1, "Pitch does not lift player")
	Input.action_release("move_right")
	view.rotation = Vector3.ZERO
	player.position = Vector3(0,0.01,-10)
	await ticks(60)
	Input.action_release("move_forward")
	check(player.position.z > -12.2, "Obstacle blocks forward motion")
	view.apply_look(Vector2(0,100000))
	check(absf(view.rotation.x) <= deg_to_rad(85.01), "Pitch clamped")
	controls.set_capture(false)
	Input.action_press("move_forward")
	await ticks(2)
	check(player.velocity.x == 0.0 and player.velocity.z == 0.0, "Released capture disables movement")
	Input.action_release("move_forward")
	scene.queue_free()
	await process_frame
	print("M01 failures: ", failures)
	quit(1 if failures else 0)
