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
	controls.controls_active = true
	view.rotation = Vector3.ZERO

	check(InputMap.action_get_events("mount_broom")[0].physical_keycode == KEY_F, "F mapped to mount_broom")
	check(fps.current and not chase.camera.current, "On-foot camera is first person")
	check(not broom.mounted, "Starts dismounted")

	Input.action_press("mount_broom")
	await ticks(2)
	Input.action_release("mount_broom")
	check(broom.mounted, "F mounts the broom")
	check(chase.camera.current and not fps.current, "Mounted camera is third-person chase")
	check(player.get_node("BroomVisual").visible, "Broom subject mesh is visible")
	check(player.motion_mode == CharacterBody3D.MOTION_MODE_FLOATING, "Mounted body uses floating motion")

	Input.action_press("jump")
	await ticks(30)
	Input.action_release("jump")
	var hover_y: float = player.position.y
	check(hover_y > 1.2, "Space climbs in hover")
	await ticks(45)
	check(absf(player.position.y - hover_y) < 0.35, "Anti-grav bubble holds altitude after climb")

	Input.action_press("move_forward")
	await ticks(45)
	var forward_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
	check(absf(forward_speed - 15.0) < 0.8, "Hover forward settles near 15 m/s")
	check(player.velocity.z < -10.0, "W travels along look forward (-Z at yaw 0)")
	Input.action_release("move_forward")
	await ticks(20)
	check(Vector2(player.velocity.x, player.velocity.z).length() < 0.6, "Release stops on a dime")

	Input.action_press("move_backward")
	await ticks(30)
	check(player.velocity.z > 10.0, "S is first-class reverse")
	Input.action_release("move_backward")
	await ticks(20)

	Input.action_press("move_left")
	await ticks(30)
	check(player.velocity.x < -10.0, "A strafes left in the look frame")
	Input.action_release("move_left")
	await ticks(20)

	Input.action_press("move_right")
	await ticks(30)
	check(player.velocity.x > 10.0, "D strafes right in the look frame")
	Input.action_release("move_right")
	await ticks(20)

	player.velocity = Vector3.ZERO
	player.position = Vector3(0.0, 6.0, 8.0)
	view.rotation.y = PI
	Input.action_press("move_forward")
	await ticks(30)
	check(player.velocity.z > 10.0, "180 yaw then W travels the new forward")
	Input.action_release("move_forward")
	await ticks(20)

	Input.action_press("move_forward")
	await ticks(25)
	Input.action_press("move_backward")
	Input.action_release("move_forward")
	await ticks(18)
	check(player.velocity.z < -4.0, "Opposing S is instant retrograde, not a long coast")
	Input.action_release("move_backward")
	await ticks(20)

	player.velocity = Vector3.ZERO
	player.position = Vector3(0.0, 6.0, 8.0)
	view.rotation.y = 0.0
	await ticks(25)
	var chase_pos: Vector3 = chase.global_position
	var subject: Vector3 = player.global_position + Vector3.UP * 1.1
	var to_cam: Vector3 = chase_pos - player.global_position
	check(to_cam.y > 1.2, "Chase camera sits above the subject")
	check(chase_pos.distance_to(subject) > 2.5, "Chase camera stays behind the subject, not in the skull")
	check(not fps.current, "FPS camera stays off while mounted")

	Input.action_press("crouch_modifier")
	await ticks(25)
	check(player.velocity.y < -4.0, "Ctrl descends while mounted")
	Input.action_release("crouch_modifier")
	await ticks(15)

	Input.action_press("mount_broom")
	await ticks(2)
	Input.action_release("mount_broom")
	check(not broom.mounted, "F dismounts")
	check(fps.current and not chase.camera.current, "Dismount restores first person")
	check(player.motion_mode == CharacterBody3D.MOTION_MODE_GROUNDED, "Dismount restores grounded motion")

	player.position = Vector3(0.0, 5.0, 8.0)
	await ticks(20)
	check(player.velocity.y < -1.0, "Dismount in air restores gravity")

	await ticks(90)
	player.position = Vector3(0.0, 0.1, 8.0)
	view.rotation = Vector3.ZERO
	await ticks(20)
	controls.controls_active = true
	Input.action_press("mount_broom")
	await ticks(2)
	Input.action_release("mount_broom")
	check(broom.mounted, "Can remount after landing")
	player.health.apply_damage(1000.0)
	await ticks(2)
	check(not broom.mounted, "Death force-dismounts")
	check(fps.current, "Death restores the FPS camera")
	player.get_node("Respawn").remaining = 0.01
	await ticks(8)
	check(player.health.current_health == 100.0 and not broom.mounted, "Respawn stays on foot")
	check(fps.current, "Respawn camera is first person")

	scene.queue_free()
	await process_frame
	print("M09 failures: ", failures)
	quit(1 if failures else 0)
