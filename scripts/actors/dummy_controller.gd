extends CharacterBody3D
## Single movement owner for the passive target; no AI or attacks.
@onready var knockback = $Knockback

func apply_knockback(impulse: Vector3) -> void:
	if not impulse.is_finite():
		return
	knockback.add_impulse(impulse)
	velocity.y += impulse.y

func _physics_process(delta: float) -> void:
	velocity.x = knockback.horizontal.x
	velocity.z = knockback.horizontal.z
	if not is_on_floor() or velocity.y > 0.0:
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	knockback.finish_step(self, delta)
