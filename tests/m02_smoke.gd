extends SceneTree
var failures: int = 0

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
	var player = scene.get_node("Player")
	var controls = player.get_node("PlayerInput")
	await ticks(30)
	controls.controls_active = true
	check(InputMap.action_get_events("jump")[0].physical_keycode == KEY_SPACE, "Space mapped to jump")
	check(InputMap.action_get_events("sprint")[0].physical_keycode == KEY_SHIFT, "Shift mapped to sprint")
	Input.action_press("sprint")
	Input.action_press("move_forward")
	var start: Vector3 = player.position
	await ticks(60)
	check(absf(start.z - player.position.z - 9.0) < 0.16, "Sprint travels 9 metres per second")
	Input.action_press("move_right")
	await ticks(2)
	check(absf(Vector2(player.velocity.x,player.velocity.z).length()-9.0)<0.01, "Diagonal sprint normalized")
	Input.action_release("sprint")
	await ticks(2)
	check(absf(Vector2(player.velocity.x,player.velocity.z).length()-6.0)<0.01, "Release Shift restores walk speed")
	Input.action_release("move_forward")
	Input.action_release("move_right")
	player.position=Vector3(0,0.01,8)
	await ticks(5)
	Input.action_press("jump")
	await ticks(2)
	check(player.velocity.y > 0 and player.position.y > 0.1, "Ground jump launches upward")
	Input.action_release("jump")
	await ticks(5)
	var previous_y_speed: float = player.velocity.y
	Input.action_press("jump")
	await ticks(2)
	check(player.velocity.y < previous_y_speed, "Airborne press cannot double jump")
	await ticks(90)
	check(player.is_on_floor() and absf(player.position.y)<0.05, "Held jump lands without automatic repeat")
	Input.action_release("jump")
	await ticks(2)
	controls.set_capture(false)
	Input.action_press("jump")
	Input.action_press("sprint")
	Input.action_press("move_forward")
	await ticks(3)
	check(player.is_on_floor() and player.velocity.length()<0.01, "Released capture blocks jump and sprint movement")
	Input.action_release("jump")
	Input.action_release("sprint")
	Input.action_release("move_forward")
	controls.controls_active=true
	player.position=Vector3(9,0.01,1)
	await ticks(5)
	Input.action_press("jump")
	await ticks(8)
	check(player.position.y < 0.3 and player.velocity.y <= 0, "Low beam blocks upward jump")
	Input.action_release("jump")
	scene.queue_free()
	await process_frame
	print("M02 failures: ",failures)
	quit(1 if failures else 0)
