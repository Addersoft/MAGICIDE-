extends Node
## Local attack authority. Shield (RMB) blocks LMB while held.
signal combat_reset
signal shot_resolved(hit_position: Vector3, damage: float)
signal cast_failed(reason: String)
signal shield_changed(active: bool)
const TAG_DAMAGE: float = 12.0
const TAG_COOLDOWN: float = 0.2
const QUERY_RANGE: float = 1000.0
const KNOCKBACK_SPEED: float = 5.0
const MUZZLE_LOCAL := Vector3(0.22, -0.23, -0.57)
var cooldown_remaining: float = 0.0
var last_kind: String = "tag"
var last_origin: Vector3 = Vector3.ZERO
var last_hit: bool = false
var shielding: bool = false
var _pending: bool = false
@onready var actor: CharacterBody3D = get_parent()
@onready var health = actor.get_node("Health")
@onready var controls = actor.get_node("PlayerInput")
@onready var aim: Node3D = actor.get_node("View")
@onready var rune_queue = actor.get_node("RuneQueue")
@onready var ward = actor.get_node_or_null("WardShield")

func _ready() -> void:
	controls.primary_requested.connect(request_tag)
	controls.rune_insert_requested.connect(_insert)
	controls.rune_clear_requested.connect(_clear)
	controls.capture_changed.connect(_capture_changed)
	health.died.connect(_cancel)
	health.died.connect(_on_died)

func _on_died() -> void:
	_set_shield(false)

func request_tag() -> void:
	if health.is_dead or not controls.controls_active or cooldown_remaining > 0.0:
		return
	if shielding:
		return
	_pending = true

func _insert(index: int) -> void:
	if health.is_dead or not controls.controls_active:
		return
	rune_queue.insert_bind(index)

func _clear() -> void:
	if health.is_dead or not controls.controls_active:
		return
	rune_queue.clear()

func _cancel() -> void:
	_pending = false

func _capture_changed(captured: bool) -> void:
	if not captured:
		_cancel()
		_set_shield(false)

func _set_shield(on: bool) -> void:
	if shielding == on:
		return
	shielding = on
	if ward != null and ward.has_method("set_active"):
		ward.set_active(on)
	shield_changed.emit(on)

func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	var want_shield: bool = controls.controls_active and not health.is_dead and controls.shield_held()
	_set_shield(want_shield)
	if not _pending:
		return
	_pending = false
	if health.is_dead or not controls.controls_active or cooldown_remaining > 0.0 or shielding:
		return
	var recipe: Dictionary = SpellCatalog.resolve(rune_queue.snapshot())
	var kind: String = str(recipe.get("kind", "unsupported"))
	if kind == "unsupported":
		cast_failed.emit("unsupported mix")
		return
	if kind != "tag":
		rune_queue.consume()
	last_kind = kind
	cooldown_remaining = TAG_COOLDOWN
	var origin: Vector3 = aim.global_position
	var direction: Vector3 = -aim.global_basis.z
	var endpoint: Vector3 = origin + direction * QUERY_RANGE
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint, 3, [actor.get_rid()])
	query.hit_from_inside = true
	var hit: Dictionary = actor.get_world_3d().direct_space_state.intersect_ray(query)
	var muzzle: Vector3 = aim.to_global(MUZZLE_LOCAL)
	var near_query := PhysicsRayQueryParameters3D.create(origin, muzzle, 3, [actor.get_rid()])
	near_query.hit_from_inside = true
	var near_hit: Dictionary = actor.get_world_3d().direct_space_state.intersect_ray(near_query)
	last_origin = muzzle
	if not near_hit.is_empty():
		hit = near_hit
		last_origin = origin
	else:
		var aim_point: Vector3 = hit.position if not hit.is_empty() else endpoint
		var muzzle_query := PhysicsRayQueryParameters3D.create(muzzle, aim_point + direction * 0.02, 3, [actor.get_rid()])
		muzzle_query.hit_from_inside = true
		hit = actor.get_world_3d().direct_space_state.intersect_ray(muzzle_query)
	last_hit = not hit.is_empty()
	var applied: float = 0.0
	var damage: float = float(recipe.get("damage", TAG_DAMAGE))
	if not hit.is_empty():
		endpoint = hit.position
		var target = hit.collider
		if target is Node:
			var target_health = target.get_node_or_null("Health")
			if target_health != null and target_health.has_method("apply_damage"):
				applied = target_health.apply_damage(damage)
				if applied > 0.0 and target.has_method("apply_knockback"):
					target.apply_knockback(direction * KNOCKBACK_SPEED)
	shot_resolved.emit(endpoint, applied)

func reset_for_respawn() -> void:
	_pending = false
	cooldown_remaining = 0.0
	last_kind = "tag"
	last_origin = Vector3.ZERO
	last_hit = false
	_set_shield(false)
	rune_queue.clear()
	combat_reset.emit()
