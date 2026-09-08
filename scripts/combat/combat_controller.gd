extends Node
## Local M05 attack authority. Rune dispatch and networking are future milestones.
signal shot_resolved(hit_position: Vector3, damage: float)
const TAG_DAMAGE: float = 12.0
const TAG_COOLDOWN: float = 2.0
const QUERY_RANGE: float = 1000.0 # Covers the bounded 40 m arena; no damage falloff.
const KNOCKBACK_SPEED: float = 5.0
var cooldown_remaining: float = 0.0
var _pending: bool = false
@onready var actor: CharacterBody3D = get_parent()
@onready var health = actor.get_node("Health")
@onready var controls = actor.get_node("PlayerInput")
@onready var camera: Camera3D = actor.get_node("View/Camera3D")

func _ready() -> void:
	controls.primary_requested.connect(request_tag)
	controls.capture_changed.connect(_capture_changed)
	health.died.connect(_cancel)

func request_tag() -> void:
	if health.is_dead or not controls.controls_active or cooldown_remaining > 0.0:
		return
	_pending = true

func _cancel() -> void:
	_pending = false

func _capture_changed(captured: bool) -> void:
	if not captured:
		_cancel()

func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	if not _pending:
		return
	_pending = false
	if health.is_dead or not controls.controls_active or cooldown_remaining > 0.0:
		return
	cooldown_remaining = TAG_COOLDOWN
	var origin: Vector3 = camera.global_position
	var direction: Vector3 = -camera.global_basis.z
	var endpoint: Vector3 = origin + direction * QUERY_RANGE
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint, 3, [actor.get_rid()])
	query.hit_from_inside = true
	var hit: Dictionary = actor.get_world_3d().direct_space_state.intersect_ray(query)
	var applied: float = 0.0
	if not hit.is_empty():
		endpoint = hit.position
		var target = hit.collider
		if target is Node:
			var target_health = target.get_node_or_null("Health")
			if target_health != null and target_health.has_method("apply_damage"):
				applied = target_health.apply_damage(TAG_DAMAGE)
				if applied > 0.0 and target.has_method("apply_knockback"):
					target.apply_knockback(direction * KNOCKBACK_SPEED)
	shot_resolved.emit(endpoint, applied)
