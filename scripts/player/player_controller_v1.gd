extends CharacterBody3D
## Sole actor transform/velocity and move_and_slide owner. Motor supplies locomotion intent.
@export var walk_speed: float = 6.0
@export var sprint_speed: float = 9.0
@export var jump_speed: float = 7.0
@export var gravity: float = 20.0
@onready var player_input = $PlayerInput
@onready var view = $View
@onready var posture = $Posture
@onready var health = $Health
@onready var knockback = $Knockback
@onready var motor = $ParkourMotor
@onready var broom = $Broom
var _stomp_lock: float = 0.0

func _ready() -> void:
	player_input.look_requested.connect(view.apply_look)
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	_stomp_lock = maxf(0.0,_stomp_lock-delta)
	if health.is_dead:
		velocity.x = knockback.horizontal.x
		velocity.z = knockback.horizontal.z
		velocity.y = 0.0 if is_on_floor() and velocity.y <= 0.0 else velocity.y-gravity*delta
	else:
		if player_input.mount_requested():
			broom.toggle()
		if broom.mounted:
			velocity = broom.step(delta)
		else:
			velocity = _foot_velocity(delta)
		velocity.x += knockback.horizontal.x
		velocity.z += knockback.horizontal.z
	var fall_speed: float = velocity.y
	move_and_slide()
	if broom.mounted:
		broom.after_move()
	else:
		motor.after_move()
	knockback.finish_step(self,delta)
	if not health.is_dead and not broom.mounted and fall_speed < -3.0 and _stomp_lock <= 0.0:
		for i in range(get_slide_collision_count()):
			var contact = get_slide_collision(i)
			var target = contact.get_collider()
			if contact.get_normal().y > 0.65 and target is Node and target.has_node("Health"):
				if target.get_node("Health").apply_damage(20.0) > 0.0:
					velocity.y = jump_speed
					_stomp_lock = 0.4
					break
	if absf(global_position.x) > 62.0 or absf(global_position.z) > 62.0 or global_position.y < -8.0:
		health.apply_damage(1000.0)

func _foot_velocity(delta: float) -> Vector3:
	var crouch: bool = player_input.crouch_toggled()
	if crouch and motor.state != "HANG" and motor.state != "VAULT":
		posture.toggle()
	return motor.step(delta,crouch)

func _on_died() -> void:
	player_input.set_capture(false)
	broom.reset()
	view.reset_motion()
	motor.reset()

func apply_knockback(impulse: Vector3) -> void:
	if not impulse.is_finite():
		return
	knockback.add_impulse(impulse)
	velocity.y += impulse.y
	if broom.mounted:
		broom.flight_velocity.y += impulse.y
	if motor.state == "HANG" or motor.state == "VAULT":
		motor.reset()

func reset_for_respawn(spawn: Transform3D) -> void:
	global_transform = spawn
	velocity = Vector3.ZERO
	knockback.horizontal = Vector3.ZERO
	motor.reset()
	broom.reset()
	_stomp_lock = 0.0
	posture.reset_standing()
	view.rotation = Vector3.ZERO
	view.reset_motion()
	player_input.reset_for_respawn()
	$Combat.reset_for_respawn()
	health.reset_full()
	reset_physics_interpolation()
