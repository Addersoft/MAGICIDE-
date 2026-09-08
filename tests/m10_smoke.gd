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

func ticks(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func run() -> void:
	var scene = load("res://scenes/boot/main.tscn").instantiate()
	root.add_child(scene)
	await ticks(20)
	var player = scene.get_node("Player")
	var broom = player.get_node("Broom")
	var chase = player.get_node("ChaseRig")
	var fps: Camera3D = player.get_node("View/Camera3D")
	var controls = player.get_node("PlayerInput")
	var view = player.get_node("View")
	var posture = player.get_node("Posture")
	controls.controls_active = true
	view.rotation = Vector3.ZERO

	Input.action_press("mount_broom")
	await ticks(2)
	Input.action_release("mount_broom")
	check(broom.mounted, "F mounts")
	await ticks(30)

	# Camera lags mouse, then catches it.
	view.rotation.y = 0.0
	await ticks(40)
	view.rotation.y = deg_to_rad(50.0)
	await ticks(2)
	var cam_yaw_early: float = absf(chase.global_transform.basis.get_euler().y)
	var aim_yaw: float = absf(view.rotation.y)
	check(cam_yaw_early < aim_yaw * 0.72, "Chase orientation lags the mouse flick")
	await ticks(45)
	var cam_yaw_late: float = chase.global_transform.basis.get_euler().y
	check(absf(wrapf(cam_yaw_late - view.rotation.y, -PI, PI)) < 0.1, "Chase catches the mouse after the lag")

	# Camera banks with roll (strafe left).
	view.rotation.y = 0.0
	await ticks(25)
	Input.action_press("move_left")
	await ticks(25)
	check(absf(broom.roll) > 0.12, "Broom banks when strafing")
	check(absf(chase.global_transform.basis.y.x) > 0.04, "Camera follows broom roll")
	Input.action_release("move_left")
	await ticks(25)

	# Turn on a dime: 180 look while holding W redirects travel immediately.
	player.velocity = Vector3.ZERO
	player.position = Vector3(0.0, 6.0, 8.0)
	view.rotation.y = 0.0
	Input.action_press("move_forward")
	await ticks(30)
	check(player.velocity.z < -10.0, "Pre-flick W is look-forward")
	view.rotation.y = PI
	await ticks(3)
	check(player.velocity.z > 8.0, "180 look redirects travel on a dime")
	Input.action_release("move_forward")
	await ticks(20)

	# Mounted Ctrl still descends, does not slide.
	Input.action_press("crouch_modifier")
	await ticks(25)
	check(player.velocity.y < -4.0, "Mounted Ctrl still descends")
	check(not posture.sliding, "Mounted Ctrl is not a slide")
	Input.action_release("crouch_modifier")
	await ticks(10)

	Input.action_press("mount_broom")
	await ticks(2)
	Input.action_release("mount_broom")
	check(not broom.mounted, "F dismounts")
	check(fps.current, "Dismount restores FPS")

	# On-foot walk/run + Ctrl is slide.
	player.position = Vector3(0.0, 0.1, 8.0)
	view.rotation = Vector3.ZERO
	await ticks(25)
	controls.controls_active = true
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await ticks(8)
	Input.action_press("crouch_modifier")
	await ticks(3)
	check(posture.sliding, "Ctrl while running starts slide")
	check(not posture.crouched, "Running Ctrl is slide, not crouch")
	check(player.get_node("Collider").shape.height < 1.2, "Slide lowers the collider")
	Input.action_release("crouch_modifier")
	Input.action_release("move_forward")
	Input.action_release("sprint")
	await ticks(80)
	check(not posture.sliding, "Slide ends on its own")

	scene.queue_free()
	await process_frame
	print("M10 failures: ", failures)
	quit(1 if failures else 0)
