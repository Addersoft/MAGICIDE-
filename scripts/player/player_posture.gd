extends Node
## Owns collider height and requested eye height. Never writes body velocity.
const STANDING_HEIGHT: float = 1.8
const CROUCH_HEIGHT: float = 1.0
var crouched: bool = false
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

func toggle() -> bool:
	if crouched and not can_stand():
		return false
	crouched = not crouched
	var height: float = CROUCH_HEIGHT if crouched else STANDING_HEIGHT
	collider.shape.height = height
	collider.position.y = height / 2.0
	view.set_eye_height(0.85 if crouched else 1.65)
	return true
