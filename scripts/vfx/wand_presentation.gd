extends Node3D
const Beam = preload("res://scripts/vfx/spiral_beam.gd")
@onready var actor = get_parent()
@onready var camera: Camera3D = actor.get_node("View/Camera3D")
@onready var combat = actor.get_node("Combat")
var _wand: Node3D
var _tip: MeshInstance3D
var _beam: Node3D
var _pulse: float = 0.0

func _ready() -> void:
	_wand = Node3D.new()
	actor.get_node("View").add_child(_wand)
	_wand.position = Vector3(0.22,-0.23,-0.32)
	var stick := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.height = 0.5
	cylinder.top_radius = 0.009
	cylinder.bottom_radius = 0.024
	cylinder.radial_segments = 8
	stick.mesh = cylinder
	stick.rotation.x = PI/2.0
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.24,0.13,0.29)
	stick.material_override = material
	_wand.add_child(stick)
	_tip = MeshInstance3D.new()
	var gem := SphereMesh.new()
	gem.radius = 0.035
	gem.height = 0.07
	gem.radial_segments = 10
	gem.rings = 5
	_tip.mesh = gem
	_tip.position.z = -0.25
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = Color(0.85,0.3,1)
	_tip.material_override = glow
	_wand.add_child(_tip)
	combat.shot_resolved.connect(_shot)
	combat.combat_reset.connect(clear)
	actor.get_node("Health").died.connect(clear)
	var round = actor.get_parent().get_node_or_null("RoundManager")
	if round != null:
		round.round_ended.connect(clear)

func _shot(endpoint: Vector3, _damage: float) -> void:
	clear()
	_beam = Beam.new()
	_beam.origin = combat.last_origin
	_beam.endpoint = endpoint
	_beam.has_impact = combat.last_hit
	actor.get_parent().add_child(_beam)
	_pulse = 1.0

func clear() -> void:
	if is_instance_valid(_beam):
		_beam.queue_free()
	_beam = null
	_pulse = 0.0

func _process(delta: float) -> void:
	_pulse = maxf(0.0,_pulse-delta*7.0)
	_wand.position.z = -0.32 + _pulse*0.035
	var readiness: float = 1.0-clampf(combat.cooldown_remaining/combat.TAG_COOLDOWN,0.0,1.0)
	_tip.scale = Vector3.ONE*(0.7+readiness*0.3+_pulse*1.4)
