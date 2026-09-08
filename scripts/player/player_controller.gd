extends CharacterBody3D
@export var walk_speed: float = 10.0
@export var sprint_speed: float = 16.0
@export var jump_speed: float = 9.5
@export var gravity: float = 22.0
const FOOT_SNAP: float = 0.55
@onready var player_input = $PlayerInput
@onready var view = $View
@onready var posture = $Posture
@onready var health = $Health
@onready var knockback = $Knockback
@onready var broom = $Broom
@onready var motor = $ParkourMotor

func _ready() -> void:
	player_input.look_requested.connect(view.apply_look)
	health.died.connect(_on_died)
	floor_snap_length = FOOT_SNAP

func _physics_process(delta: float) -> void:
	if health.is_dead:
		if broom.mounted:
			broom.force_dismount()
		if posture.sliding:
			posture.end_slide()
		if motor:
			motor.reset()
		velocity.x = knockback.horizontal.x
		velocity.z = knockback.horizontal.z
		velocity.y = 0.0 if is_on_floor() and velocity.y <= 0.0 else velocity.y - gravity * delta
		move_and_slide()
		knockback.finish_step(self, delta)
		return
	if player_input.mount_toggled():
		_toggle_mount()
	if broom.mounted:
		_broom_physics(delta)
	else:
		_foot_physics(delta)

func _toggle_mount() -> void:
	if broom.mounted:
		broom.dismount()
		floor_snap_length = FOOT_SNAP
		return
	if posture.sliding:
		posture.end_slide()
	if posture.crouched:
		posture.set_crouched(false)
	if motor:
		motor.reset()
	broom.mount()

func _broom_physics(delta: float) -> void:
	if posture.sliding:
		posture.end_slide()
	if motor:
		motor.reset()
	var axis: Vector2 = player_input.fly_axis()
	var vertical: float = player_input.fly_vertical()
	var boost: bool = player_input.boost_held()
	var aileron: float = player_input.roll_axis()
	velocity = broom.integrate(delta, velocity, view.global_transform.basis, axis, vertical, knockback.horizontal, boost, aileron)
	move_and_slide()
	knockback.finish_step(self, delta)
	broom.update_visual(delta, axis, aileron)

func _foot_physics(delta: float) -> void:
	if motor.roll_time <= 0.0 and not posture.sliding:
		var want_crouch: bool = player_input.crouch_held() and not player_input.slide_held()
		posture.set_crouched(want_crouch)
	var desired: Vector3 = motor.step(delta, false)
	velocity.x = desired.x + knockback.horizontal.x
	velocity.y = desired.y
	velocity.z = desired.z + knockback.horizontal.z
	move_and_slide()
	motor.after_move()
	knockback.finish_step(self, delta)

func _on_died() -> void:
	broom.force_dismount()
	if posture.sliding:
		posture.end_slide()
	if motor:
		motor.reset()
	player_input.set_capture(false)

func apply_knockback(impulse: Vector3) -> void:
	if not impulse.is_finite():
		return
	knockback.add_impulse(impulse)
	velocity.y += impulse.y
	if motor and (motor.state == "HANG" or motor.state == "VAULT"):
		motor.state = "AIR"
		motor._route.clear()

func reset_for_respawn(spawn: Transform3D) -> void:
	broom.force_dismount()
	global_transform = spawn
	velocity = Vector3.ZERO
	knockback.horizontal = Vector3.ZERO
	floor_snap_length = FOOT_SNAP
	if motor:
		motor.reset()
	posture.reset_standing()
	view.rotation = Vector3.ZERO
	if view.has_method("set_roll"):
		view.set_roll(0.0)
	player_input.reset_for_respawn()
	$Combat.reset_for_respawn()
	health.reset_full()
	reset_physics_interpolation()
