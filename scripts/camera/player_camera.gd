extends Node3D
## Sole view orientation owner. Parent body never pitches.
@export_range(0.01, 1.0) var sensitivity_degrees: float = 0.12
@export var invert_y: bool = false

func apply_look(delta_pixels: Vector2) -> void:
	rotation.y = wrapf(rotation.y - deg_to_rad(delta_pixels.x * sensitivity_degrees), -PI, PI)
	var vertical_sign: float = 1.0 if invert_y else -1.0
	rotation.x = clampf(rotation.x + deg_to_rad(delta_pixels.y * sensitivity_degrees) * vertical_sign, deg_to_rad(-85.0), deg_to_rad(85.0))

func horizontal_basis() -> Basis:
	return Basis(Vector3.UP, rotation.y)
