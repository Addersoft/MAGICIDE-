extends Node
## Hover + boost flight owner. PlayerController remains the only move_and_slide caller.
## Fire trail is always on while mounted; turns blue when boost (Shift) is active.
signal mount_changed(mounted: bool)
@export var hover_speed: float = 15.0
@export var boost_speed: float = 40.0
@export var climb_speed: float = 8.0
@export var damp: float = 22.0
@export var boost_damp: float = 14.0
@export var retrograde: float = 2.2
@export var altitude_lock: float = 36.0
@export var visual_roll_degrees: float = 28.0
@export var turn_bank_gain: float = 0.38
var mounted: bool = false
var boosting: bool = false
var roll: float = 0.0
var _look_yaw: float = 0.0
var _yaw_rate: float = 0.0
var _trail: GPUParticles3D
var _trail_mat: ParticleProcessMaterial
var _trail_draw: StandardMaterial3D
@onready var actor: CharacterBody3D = get_parent()
@onready var view: Node3D = actor.get_node("View")
@onready var visual: Node3D = actor.get_node("BroomVisual")
@onready var chase = actor.get_node("ChaseRig")
@onready var fps: Camera3D = view.get_node("Camera3D")

const COLOR_IDLE := Color(1.0, 0.45, 0.12, 1.0)
const COLOR_BOOST := Color(0.25, 0.55, 1.0, 1.0)

func _ready() -> void:
	_build_placeholder()
	_build_trail()
	visual.visible = false
	if _trail:
		_trail.emitting = false

func mount() -> bool:
	if mounted:
		return false
	mounted = true
	boosting = false
	_look_yaw = view.rotation.y
	_yaw_rate = 0.0
	roll = 0.0
	actor.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	actor.floor_snap_length = 0.0
	visual.visible = true
	if _trail:
		_trail.emitting = true
		_set_trail_color(COLOR_IDLE)
	chase.capture_from_eye(fps)
	mount_changed.emit(true)
	return true

func dismount() -> void:
	if not mounted:
		return
	force_dismount()

func force_dismount() -> void:
	var was_mounted: bool = mounted
	mounted = false
	boosting = false
	actor.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	actor.floor_snap_length = 0.2
	visual.visible = false
	visual.rotation = Vector3.ZERO
	roll = 0.0
	_yaw_rate = 0.0
	if _trail:
		_trail.emitting = false
	chase.release_to_eye(fps)
	if was_mounted:
		mount_changed.emit(false)

func integrate(delta: float, current: Vector3, yaw_basis: Basis, axis: Vector2, vertical: float, knock_h: Vector3, boost: bool = false) -> Vector3:
	boosting = boost and mounted
	var speed: float = boost_speed if boosting else hover_speed
	var rate: float = boost_damp if boosting else damp
	var look_yaw: float = yaw_basis.get_euler().y
	var dyaw: float = wrapf(look_yaw - _look_yaw, -PI, PI)
	_yaw_rate = dyaw / maxf(delta, 0.0001)
	_look_yaw = look_yaw
	var planar := Basis(Vector3.UP, dyaw) * Vector3(current.x, 0.0, current.z)
	var desired_h: Vector3 = yaw_basis * Vector3(axis.x, 0.0, axis.y) * speed
	var desired := Vector3(desired_h.x, vertical * climb_speed, desired_h.z)
	if desired_h.dot(planar) < 0.0 and planar.length() > 0.5:
		rate *= retrograde
	var alpha: float = 1.0 - exp(-rate * delta)
	var next := Vector3(
		lerpf(planar.x, desired.x, alpha),
		0.0,
		lerpf(planar.z, desired.z, alpha)
	)
	var y_rate: float = altitude_lock if absf(vertical) < 0.01 else damp
	next.y = lerpf(current.y, desired.y, 1.0 - exp(-y_rate * delta))
	next.x += knock_h.x
	next.z += knock_h.z
	return next

func update_visual(delta: float, axis: Vector2) -> void:
	if not mounted:
		return
	var turn_bank: float = clampf(_yaw_rate * turn_bank_gain, -1.0, 1.0)
	var target_roll: float = clampf(-axis.x + turn_bank, -1.0, 1.0) * deg_to_rad(visual_roll_degrees)
	roll = lerpf(roll, target_roll, 1.0 - exp(-12.0 * delta))
	visual.rotation = Vector3(view.rotation.x, view.rotation.y, roll)
	if _trail and _trail.emitting:
		_set_trail_color(COLOR_BOOST if boosting else COLOR_IDLE)
		_trail.amount = 48 if boosting else 28
		_trail.lifetime = 0.55 if boosting else 0.4

func _set_trail_color(c: Color) -> void:
	if _trail_mat:
		_trail_mat.color = c
	if _trail_draw:
		_trail_draw.albedo_color = c
		_trail_draw.emission = c
		_trail_draw.emission_energy_multiplier = 2.8 if boosting else 1.6

func _build_trail() -> void:
	_trail = GPUParticles3D.new()
	_trail.name = "BoostTrail"
	_trail.amount = 28
	_trail.lifetime = 0.4
	_trail.explosiveness = 0.0
	_trail.randomness = 0.35
	_trail.local_coords = false
	_trail.visibility_aabb = AABB(Vector3(-4, -4, -4), Vector3(8, 8, 8))
	_trail.emitting = false
	_trail.position = Vector3(0.0, 0.42, 1.15)

	_trail_mat = ParticleProcessMaterial.new()
	_trail_mat.direction = Vector3(0, 0, 1)
	_trail_mat.spread = 18.0
	_trail_mat.initial_velocity_min = 1.5
	_trail_mat.initial_velocity_max = 4.0
	_trail_mat.gravity = Vector3(0, 0.4, 0)
	_trail_mat.damping_min = 1.0
	_trail_mat.damping_max = 3.0
	_trail_mat.scale_min = 0.08
	_trail_mat.scale_max = 0.22
	_trail_mat.color = COLOR_IDLE
	_trail.process_material = _trail_mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.12
	_trail_draw = StandardMaterial3D.new()
	_trail_draw.albedo_color = COLOR_IDLE
	_trail_draw.emission_enabled = true
	_trail_draw.emission = COLOR_IDLE
	_trail_draw.emission_energy_multiplier = 1.6
	_trail_draw.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_trail_draw.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = _trail_draw
	_trail.draw_pass_1 = mesh

	visual.add_child(_trail)

func _build_placeholder() -> void:
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = 1.55
	body.mesh = capsule
	body.position = Vector3(0.0, 0.95, 0.0)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.18, 0.42, 0.48, 1.0)
	body.material_override = cloth
	visual.add_child(body)
	var stick := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.045
	cylinder.bottom_radius = 0.055
	cylinder.height = 1.7
	stick.mesh = cylinder
	stick.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	stick.position = Vector3(0.0, 0.42, 0.12)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.42, 0.26, 0.14, 1.0)
	stick.material_override = wood
	visual.add_child(stick)
	var bristles := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.02
	cone.bottom_radius = 0.18
	cone.height = 0.45
	bristles.mesh = cone
	bristles.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	bristles.position = Vector3(0.0, 0.42, 0.95)
	var straw := StandardMaterial3D.new()
	straw.albedo_color = Color(0.72, 0.55, 0.28, 1.0)
	bristles.material_override = straw
	visual.add_child(bristles)
