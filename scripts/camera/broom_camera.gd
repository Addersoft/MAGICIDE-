extends Node3D
## Warhawk-style chase camera. World-space spring; stays upright; subject stays in frame.
@export var back_distance: float = 4.0
@export var height: float = 2.0
@export var look_height: float = 1.1
@export var mount_blend: float = 0.3
@export var follow_damp: float = 12.0
var _cam_pos: Vector3 = Vector3.ZERO
var _blend: float = 1.0
var _blending: bool = false
@onready var actor: CharacterBody3D = get_parent()
@onready var view: Node3D = actor.get_node("View")
@onready var camera: Camera3D = $Camera3D

func capture_from_eye(eye: Camera3D) -> void:
	camera.transform = Transform3D.IDENTITY
	global_transform = eye.global_transform
	_cam_pos = global_position
	camera.current = true
	eye.current = false
	_blend = 0.0
	_blending = true

func release_to_eye(eye: Camera3D) -> void:
	camera.current = false
	eye.current = true
	camera.transform = Transform3D.IDENTITY
	_blending = false
	_blend = 1.0

func _physics_process(delta: float) -> void:
	if not camera.current:
		return
	var subject: Vector3 = actor.global_position + Vector3.UP * look_height
	var back: Vector3 = view.horizontal_basis() * Vector3(0.0, 0.0, 1.0)
	var desired: Vector3 = actor.global_position + Vector3.UP * height + back * back_distance
	if _blending:
		_blend = minf(1.0, _blend + delta / maxf(0.05, mount_blend))
		var t: float = _blend * _blend * (3.0 - 2.0 * _blend)
		_cam_pos = _cam_pos.lerp(desired, t)
		if _blend >= 1.0:
			_blending = false
	else:
		_cam_pos = _cam_pos.lerp(desired, 1.0 - exp(-follow_damp * delta))
	var query := PhysicsRayQueryParameters3D.create(subject, _cam_pos, 1, [actor.get_rid()])
	query.hit_from_inside = true
	var hit: Dictionary = actor.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		_cam_pos = hit.position + hit.normal * 0.18
	global_position = _cam_pos
	if not global_position.is_equal_approx(subject):
		look_at(subject, Vector3.UP)
