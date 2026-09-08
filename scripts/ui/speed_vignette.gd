extends CanvasLayer
## Wind vignette at screen edges. Strength scales with planar movement speed.
@export var start_speed: float = 10.0
@export var full_speed: float = 20.0
@export var max_alpha: float = 0.62
@export var fade_rate: float = 10.0
var _strength: float = 0.0
var _corners: Array[ColorRect] = []

func _ready() -> void:
	layer = 25
	_build_corners()

func _player() -> CharacterBody3D:
	var root := get_tree().current_scene
	if root == null:
		return null
	return root.get_node_or_null("Player") as CharacterBody3D

func _build_corners() -> void:
	var specs := [
		{"a": [0.0, 0.0, 1.0, 0.0], "o": [0.0, 0.0, 0.0, 170.0]},
		{"a": [0.0, 1.0, 1.0, 1.0], "o": [0.0, -170.0, 0.0, 0.0]},
		{"a": [0.0, 0.0, 0.0, 1.0], "o": [0.0, 0.0, 190.0, 0.0]},
		{"a": [1.0, 0.0, 1.0, 1.0], "o": [-190.0, 0.0, 0.0, 0.0]},
	]
	for spec in specs:
		var rect := ColorRect.new()
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.anchor_left = spec.a[0]
		rect.anchor_top = spec.a[1]
		rect.anchor_right = spec.a[2]
		rect.anchor_bottom = spec.a[3]
		rect.offset_left = spec.o[0]
		rect.offset_top = spec.o[1]
		rect.offset_right = spec.o[2]
		rect.offset_bottom = spec.o[3]
		rect.color = Color(0.7, 0.88, 1.0, 0.0)
		add_child(rect)
		_corners.append(rect)

func _process(delta: float) -> void:
	var player := _player()
	var target := 0.0
	if player != null and is_instance_valid(player):
		var planar: float = Vector2(player.velocity.x, player.velocity.z).length()
		if planar > start_speed:
			target = clampf((planar - start_speed) / maxf(full_speed - start_speed, 0.01), 0.0, 1.0)
	_strength = lerpf(_strength, target, 1.0 - exp(-fade_rate * delta))
	var a: float = _strength * max_alpha
	var c := Color(0.68, 0.86, 1.0, a)
	for rect in _corners:
		rect.color = c
