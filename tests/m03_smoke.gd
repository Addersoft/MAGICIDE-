extends SceneTree
var failures: int = 0
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
	var player = scene.get_node("Player")
	var posture = player.get_node("Posture")
	var controls = player.get_node("PlayerInput")
	await ticks(30)
	controls.controls_active = true
	check(InputMap.action_get_events("crouch_modifier")[0].physical_keycode == KEY_CTRL, "Control key mapping")
	Input.action_press("crouch_modifier")
	Input.action_press("move_backward")
	await ticks(3)
	check(posture.crouched, "CTRL+S crouches when still")
	check(absf(player.get_node("Collider").shape.height - 1.0)<0.01 and absf(player.get_node("View").position.y-0.85)<0.01, "Collider and eye lowered")
	await ticks(5)
	check(posture.crouched, "Held chord does not repeat")
	Input.action_release("move_backward")
	await ticks(2)
	Input.action_press("move_backward")
	await ticks(2)
	check(not posture.crouched, "Fresh chord stands in open space")
	Input.action_release("move_backward")
	Input.action_release("crouch_modifier")
	await ticks(2)
	posture.toggle()
	# Dedicated 1.3 m clearance fixture: standing cannot fit, crouching can.
	var roof := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4,0.2,4)
	shape.shape = box
	roof.add_child(shape)
	root.add_child(roof)
	roof.position = player.position + Vector3(0,1.4,0)
	await ticks(3)
	check(not posture.toggle() and posture.crouched, "Blocked stand remains crouched")
	check(absf(player.get_node("View").position.y-0.85)<0.01, "Blocked stand keeps eye low")
	roof.queue_free()
	await ticks(3)
	check(posture.toggle() and not posture.crouched, "Stand works once obstruction removed")
	var speed_before := Vector3(4,2,-7)
	player.velocity = speed_before
	posture.toggle()
	check(player.velocity == speed_before, "Posture operation preserves all velocity components")
	controls.set_capture(false)
	Input.action_press("crouch_modifier")
	Input.action_press("move_backward")
	await ticks(2)
	check(posture.crouched, "Released capture blocks crouch")
	Input.action_release("crouch_modifier")
	Input.action_release("move_backward")
	scene.queue_free()
	await process_frame
	print("M03 failures: ",failures)
	quit(1 if failures else 0)
