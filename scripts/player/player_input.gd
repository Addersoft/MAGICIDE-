extends Node
## Raw input ownership. No movement or camera transforms here.
signal primary_requested
signal look_requested(delta_pixels: Vector2)
signal capture_changed(captured: bool)
signal rune_insert_requested(index: int)
signal rune_clear_requested
var controls_active: bool = false
var gameplay_enabled: bool = true
var _discard_motion: bool = false
var _ctrl_was_down: bool = false

func _ready() -> void:
	set_capture(true)

func set_capture(captured: bool) -> void:
	if captured and (not gameplay_enabled or get_parent().get_node("Health").is_dead):
		return
	controls_active = captured
	_discard_motion = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE
	capture_changed.emit(captured)

func movement_axis() -> Vector2:
	if not controls_active:
		return Vector2.ZERO
	# S always available for backward; crouch is pure Ctrl tap, not Ctrl+S chord.
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).limit_length(1.0)

func fly_axis() -> Vector2:
	if not controls_active:
		return Vector2.ZERO
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).limit_length(1.0)

func fly_vertical() -> float:
	if not controls_active:
		return 0.0
	return clampf(Input.get_action_strength("jump") - Input.get_action_strength("crouch_modifier"), -1.0, 1.0)

func mount_toggled() -> bool:
	return controls_active and Input.is_action_just_pressed("mount_broom")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		set_capture(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		set_capture(false)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not controls_active:
		set_capture(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("primary_fire") and controls_active:
		if not event.ctrl_pressed:
			primary_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rune_1") and controls_active:
		rune_insert_requested.emit(0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rune_2") and controls_active:
		rune_insert_requested.emit(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rune_3") and controls_active:
		rune_insert_requested.emit(2)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rune_clear") and controls_active:
		rune_clear_requested.emit()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and controls_active:
		if _discard_motion:
			_discard_motion = false
			return
		look_requested.emit(event.screen_relative)

func jump_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("jump")

func jump_held() -> bool:
	return controls_active and Input.is_action_pressed("jump")

func sprint_held() -> bool:
	return controls_active and Input.is_action_pressed("sprint")

func boost_held() -> bool:
	## Shift while mounted = broom boost.
	return controls_active and Input.is_action_pressed("sprint")

func crouch_toggled() -> bool:
	## Tap Ctrl while stationary / near-stationary toggles crouch.
	if not controls_active:
		return false
	if not Input.is_action_just_pressed("crouch_modifier"):
		return false
	var axis := movement_axis()
	var planar_speed := 0.0
	var body = get_parent()
	if body is CharacterBody3D:
		planar_speed = Vector2(body.velocity.x, body.velocity.z).length()
	return axis.length() < 0.25 and planar_speed < 3.5

func slide_held() -> bool:
	## Hold Ctrl while moving = stay in / enter slide.
	if not controls_active:
		return false
	if not Input.is_action_pressed("crouch_modifier"):
		return false
	var axis := movement_axis()
	var body = get_parent()
	var planar_speed := 0.0
	if body is CharacterBody3D:
		planar_speed = Vector2(body.velocity.x, body.velocity.z).length()
	return axis.length() > 0.2 or planar_speed > 3.5

func slide_requested() -> bool:
	## Rising edge into slide: press Ctrl while already moving, or dedicated parkour_slide.
	if not controls_active:
		return false
	if Input.is_action_just_pressed("parkour_slide"):
		return true
	if Input.is_action_just_pressed("crouch_modifier"):
		var axis := movement_axis()
		var body = get_parent()
		var planar_speed := 0.0
		if body is CharacterBody3D:
			planar_speed = Vector2(body.velocity.x, body.velocity.z).length()
		return axis.length() > 0.2 or planar_speed > 3.5
	return false

func glide_held() -> bool:
	if not controls_active:
		return false
	return Input.is_action_pressed("parkour_glide") and not Input.is_action_pressed("sprint")

func dodge_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("parkour_dodge")

func roll_left_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("roll_left")

func roll_right_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("roll_right")

func reset_for_respawn() -> void:
	set_capture(false)
	_ctrl_was_down = Input.is_action_pressed("crouch_modifier")
