extends Node
## Owns collider height and requested eye height. Never writes body velocity.
const STANDING_HEIGHT: float = 1.8
const CROUCH_HEIGHT: float = 1.0
var crouched: bool = false
var sliding: bool = false
@onready var body: CharacterBody3D = get_parent()
@onready var collider: CollisionShape3D = body.get_node("Collider")
@onready var view = body.get_node("View")
var _standing_shape: CapsuleShape3D

func _ready() -> void:
	collider.shape = collider.shape.duplicate()
	_standing_shape = collider.shape.duplicate()

func can_stand() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _standing_shape
	query.transform = body.global_transform * Transform3D(Basis.IDENTITY, Vector3(0, STANDING_HEIGHT / 2.0 + 0.01, 0))
	query.collision_mask = body.collision_mask
	query.exclude = [body.get_rid()]
	query.margin = 0.001
	return body.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()

func _apply_height(height: float, eye: float) -> void:
	collider.shape.height = height
	collider.position.y = height / 2.0
	view.set_eye_height(eye)

func toggle() -> bool:
	if crouched and not can_stand():
		return false
	crouched = not crouched
	sliding = false
	var height: float = CROUCH_HEIGHT if crouched else STANDING_HEIGHT
	_apply_height(height, 0.85 if crouched else 1.65)
	return true

func begin_slide() -> void:
	sliding = true
	crouched = false
	_apply_height(CROUCH_HEIGHT, 0.85)

func end_slide() -> void:
	if not sliding:
		return
	sliding = false
	if can_stand():
		crouched = false
		_apply_height(STANDING_HEIGHT, 1.65)
	else:
		crouched = true
		_apply_height(CROUCH_HEIGHT, 0.85)

func reset_standing() -> void:
	# Respawn owner has already validated the full standing capsule at the spawn.
	crouched = false
	sliding = false
	_apply_height(STANDING_HEIGHT, 1.65)
