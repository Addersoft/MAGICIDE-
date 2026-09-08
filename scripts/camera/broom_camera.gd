extends Node3D
## Warhawk chase: boom sits in lagged aim space, banks with roll, catches the mouse late.
@export var back_distance: float = 4.0
@export var height: float = 1.55
@export var mount_blend: float = 0.3
@export var look_lag: float = 7.5
@export var pos_lag: float = 16.0
var _cam_pos: Vector3 = Vector3.ZERO
var _cam_basis: Basis = Basis.IDENTITY
var _blend: float = 1.0
var _blending: bool = false
@onready var actor: CharacterBody3D = get_parent()
@onready var view: Node3D = actor.get_node("View")
@onready var broom = actor.get_node("Broom")
@onready var camera: Camera3D = $Camera3D

func capture_from_eye(eye: Camera3D) -> void:
	camera.transform = Transform3D.IDENTITY
	global_transform = eye.global_transform
	_cam_pos = global_position
	_cam_basis = global_basis
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

func _desired_basis() -> Basis:
	var e: Vector3 = view.rotation
	e.z = broom.roll
	return Basis.from_euler(e)

func _physics_process(delta: float) -> void:
	if not camera.current:
		return
	var desired_basis: Basis = _desired_basis()
	var look_a: float = 1.0 - exp(-look_lag * delta)
	var from_q: Quaternion = _cam_basis.get_rotation_quaternion()
	var to_q: Quaternion = desired_basis.get_rotation_quaternion()
	_cam_basis = Basis(from_q.slerp(to_q, look_a)).orthonormalized()
	var desired_pos: Vector3 = actor.global_position + _cam_basis.y * height + _cam_basis.z * back_distance
	if _blending:
		_blend = minf(1.0, _blend + delta / maxf(0.05, mount_blend))
		var t: float = _blend * _blend * (3.0 - 2.0 * _blend)
		_cam_pos = _cam_pos.lerp(desired_pos, t)
		if _blend >= 1.0:
			_blending = false
	else:
		_cam_pos = _cam_pos.lerp(desired_pos, 1.0 - exp(-pos_lag * delta))
	var subject: Vector3 = actor.global_position + Vector3.UP * 1.1
	var query := PhysicsRayQueryParameters3D.create(subject, _cam_pos, 1, [actor.get_rid()])
	query.hit_from_inside = true
	var hit: Dictionary = actor.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		_cam_pos = hit.position + hit.normal * 0.18
	global_position = _cam_pos
	global_basis = _cam_basis
