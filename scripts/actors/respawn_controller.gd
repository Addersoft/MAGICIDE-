extends Node
## Owns one pending respawn per actor. Reuses the actor; no orphan timers or duplicate instances.
signal respawned
@export var respawn_delay: float = 3.0
const RETRY_DELAY: float = 0.25
var remaining: float = 0.0
var waiting: bool = false
var spawn_blocked: bool = false
var _spawn_transform: Transform3D
var _shape_transform: Transform3D
var _spawn_shape: Shape3D
@onready var actor: CharacterBody3D = get_parent()
@onready var health = actor.get_node("Health")

func _ready() -> void:
	_spawn_transform = actor.global_transform
	var collider: CollisionShape3D = actor.get_node("Collider")
	_spawn_shape = collider.shape.duplicate()
	_shape_transform = collider.transform
	_shape_transform.origin.y += 0.01
	health.died.connect(_on_died)

func _on_died() -> void:
	if waiting:
		return
	waiting = true
	spawn_blocked = false
	remaining = maxf(0.0, respawn_delay)

func _spawn_clear() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _spawn_shape
	query.transform = _spawn_transform * _shape_transform
	query.collision_mask = actor.collision_mask
	query.exclude = [actor.get_rid()]
	query.margin = 0.001
	return actor.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()

func _physics_process(delta: float) -> void:
	if not waiting:
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining > 0.0:
		return
	if not _spawn_clear():
		spawn_blocked = true
		remaining = RETRY_DELAY
		return
	waiting = false
	spawn_blocked = false
	remaining = 0.0
	actor.reset_for_respawn(_spawn_transform)
	respawned.emit()

func status_text() -> String:
	if spawn_blocked:
		return "Spawn blocked — waiting for clearance"
	return "Respawn in %.1f s" % remaining
