extends Node
## Raw input ownership. No movement or camera transforms here.
signal primary_requested
signal look_requested(delta_pixels: Vector2)
signal capture_changed(captured: bool)
var controls_active: bool = false
var gameplay_enabled: bool = true
var _discard_motion: bool = false
var _crouch_chord_down: bool = false
var _primary_blocked_until_release: bool = false

func _ready() -> void:
	set_capture(true)

func set_capture(captured: bool) -> void:
	if captured and (not gameplay_enabled or get_parent().get_node("Health").is_dead):
		return
	controls_active = captured
	_discard_motion = captured
	_primary_blocked_until_release = captured and Input.is_action_pressed("primary_fire")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE
	capture_changed.emit(captured)

func movement_axis() -> Vector2:
	if not controls_active:
		return Vector2.ZERO
	var backward: float = 0.0 if Input.is_action_pressed("crouch_modifier") else Input.get_action_strength("move_backward")
	return Vector2(Input.get_axis("move_left", "move_right"), backward - Input.get_action_strength("move_forward")).limit_length(1.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		set_capture(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("primary_fire"):
		_primary_blocked_until_release = false
	if event.is_action_pressed("release_mouse"):
		set_capture(false)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not controls_active:
		set_capture(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("primary_fire") and controls_active:
		# Movement modifiers never consume a wand shot.
		if gameplay_enabled and not _primary_blocked_until_release:
			primary_requested.emit()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and controls_active:
		if _discard_motion:
			_discard_motion = false
			return
		look_requested.emit(event.screen_relative)

func jump_requested() -> bool:
	return controls_active and gameplay_enabled and Input.is_action_just_pressed("jump")

func sprint_held() -> bool:
	return controls_active and Input.is_action_pressed("sprint")

func crouch_toggled() -> bool:
	var held: bool = Input.is_action_pressed("crouch_modifier") and Input.is_action_pressed("move_backward")
	var pressed: bool = held and not _crouch_chord_down
	_crouch_chord_down = held
	return controls_active and pressed

func reset_for_respawn() -> void:
	set_capture(false)
	_crouch_chord_down = Input.is_action_pressed("crouch_modifier") and Input.is_action_pressed("move_backward")

func jump_held() -> bool:
	return controls_active and Input.is_action_pressed("jump")

func slide_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("parkour_slide")

func dodge_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("parkour_dodge")

func glide_held() -> bool:
	return controls_active and Input.is_action_pressed("parkour_glide") and not Input.is_action_pressed("sprint")

func sync_context() -> void:
	_crouch_chord_down = Input.is_action_pressed("crouch_modifier") and Input.is_action_pressed("move_backward")

func mount_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("broom_mount")

func broom_axis() -> Vector2:
	return Input.get_vector("move_left","move_right","move_forward","move_backward") if controls_active else Vector2.ZERO

func broom_altitude() -> float:
	return Input.get_action_strength("jump")-Input.get_action_strength("crouch_modifier") if controls_active else 0.0

func broom_roll() -> float:
	return Input.get_axis("broom_roll_left","broom_roll_right") if controls_active else 0.0

func broom_brake() -> bool:
	return controls_active and Input.is_action_pressed("broom_brake")

func primary_held() -> bool:
	var held := Input.is_action_pressed("primary_fire")
	if not held:
		_primary_blocked_until_release = false
	return controls_active and gameplay_enabled and held and not _primary_blocked_until_release
