extends Node
## Query-only traversal helper. Never teleports or moves an actor.
@onready var body: CharacterBody3D = get_parent()

func ray(from: Vector3, to: Vector3, mask: int = 1) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, mask, [body.get_rid()])
	return body.get_world_3d().direct_space_state.intersect_ray(query)

func standing_clear(feet: Vector3) -> bool:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.8
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, feet + Vector3(0, 0.91, 0))
	query.exclude = [body.get_rid()]
	query.collision_mask = 3
	query.margin = 0.001
	return body.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()

func side_wall() -> Dictionary:
	var motor = body.get_node_or_null("ParkourMotor")
	var flat: Vector3 = motor.horizontal if motor else Vector3.ZERO
	var side: Vector3 = flat.normalized().cross(Vector3.UP) if flat.length() > 2.0 else body.view.horizontal_basis().x
	var start: Vector3 = body.global_position + Vector3(0, 0.8, 0)
	for sign_value in [-1.0, 1.0]:
		var hit := ray(start, start + side * sign_value * 0.8)
		if not hit.is_empty() and absf(hit.normal.y) < 0.2:
			return hit
	return {}

func ledge() -> Dictionary:
	var forward: Vector3 = -body.view.horizontal_basis().z
	var feet: Vector3 = body.global_position
	var front := ray(feet + Vector3(0, 0.65, 0), feet + Vector3(0, 0.65, 0) + forward * 1.15)
	if front.is_empty() or absf(front.normal.y) > 0.2:
		return {}
	if front.collider.is_in_group("no_traversal"):
		return {}
	var inside: Vector3 = front.position - front.normal * 0.55
	var top := ray(Vector3(inside.x, feet.y + 2.35, inside.z), Vector3(inside.x, feet.y + 0.4, inside.z))
	if top.is_empty() or top.normal.y < 0.8:
		return {}
	var target: Vector3 = top.position + Vector3(0, 0.03, 0)
	if not standing_clear(target):
		return {}
	var outside: Vector3 = front.position + front.normal * 0.42
	outside.y = target.y
	if not standing_clear(outside):
		return {}
	return {"target": target, "outside": outside, "height": target.y - feet.y}
