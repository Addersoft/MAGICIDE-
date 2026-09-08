extends Node
## Horizontal external velocity, distinct from player input. No transforms or movement calls.
@export var deceleration: float = 12.0
var horizontal: Vector3 = Vector3.ZERO

func add_impulse(impulse: Vector3) -> void:
	horizontal += Vector3(impulse.x, 0.0, impulse.z)

func finish_step(body: CharacterBody3D, delta: float) -> void:
	for index in range(body.get_slide_collision_count()):
		var normal: Vector3 = body.get_slide_collision(index).get_normal()
		# Ground/ceiling normals must not add vertical velocity to horizontal state.
		var planar: Vector3 = Vector3(normal.x, 0.0, normal.z)
		if planar.length_squared() > 0.01:
			planar = planar.normalized()
			if horizontal.dot(planar) < 0.0:
				horizontal = horizontal.slide(planar)
	horizontal = horizontal.move_toward(Vector3.ZERO, deceleration * delta)
