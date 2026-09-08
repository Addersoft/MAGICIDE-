extends Node
## Raw input ownership. No movement or camera transforms here.
signal look_requested(delta_pixels: Vector2)
signal capture_changed(captured: bool)
var controls_active: bool = false
var _discard_motion: bool = false

func _ready() -> void:
	set_capture(true)

func set_capture(captured: bool) -> void:
	controls_active = captured
	_discard_motion = captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE
	capture_changed.emit(captured)

func movement_axis() -> Vector2:
	if not controls_active:
		return Vector2.ZERO
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

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
	elif event is InputEventMouseMotion and controls_active:
		if _discard_motion:
			_discard_motion = false
			return
		look_requested.emit(event.screen_relative)

func jump_requested() -> bool:
	return controls_active and Input.is_action_just_pressed("jump")

func sprint_held() -> bool:
	return controls_active and Input.is_action_pressed("sprint")
