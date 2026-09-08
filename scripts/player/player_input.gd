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
var _crouch_chord_down: bool = false

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
	var backward: float = 0.0 if Input.is_action_pressed("crouch_modifier") else Input.get_action_strength("move_backward")
	return Vector2(Input.get_axis("move_left", "move_right"), backward - Input.get_action_strength("move_forward")).limit_length(1.0)

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
		# Reserve Ctrl+LMB for future Link; it must not also fire Tag.
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

func sprint_held() -> bool:
	return controls_active and Input.is_action_pressed("sprint")

func crouch_toggled() -> bool:
	var held: bool = Input.is_action_pressed("crouch_modifier") and Input.is_action_pressed("move_backward")
	var pressed: bool = held and not _crouch_chord_down
	_crouch_chord_down = held
	return controls_active and pressed

func reset_for_respawn() -> void:
	# Keep pointer released; a conscious click resumes play without firing.
	set_capture(false)
	_crouch_chord_down = Input.is_action_pressed("crouch_modifier") and Input.is_action_pressed("move_backward")
