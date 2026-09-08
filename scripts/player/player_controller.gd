extends CharacterBody3D
## Sole velocity and move_and_slide owner. Extract movement only when needed.
@export var walk_speed: float = 6.0
@export var sprint_speed: float = 9.0
@export var jump_speed: float = 7.0
@export var gravity: float = 20.0
@export var slide_speed: float = 15.0
@export var slide_duration: float = 0.7
@export var slide_friction: float = 12.0
var _slide_time: float = 0.0
var _slide_dir: Vector3 = Vector3.ZERO
@onready var player_input = $PlayerInput
@onready var view = $View
@onready var posture = $Posture
@onready var health = $Health
@onready var knockback = $Knockback
@onready var broom = $Broom

func _ready() -> void:
	player_input.look_requested.connect(view.apply_look)
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if health.is_dead:
		if broom.mounted:
			broom.force_dismount()
		if posture.sliding:
			posture.end_slide()
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
		return
	if posture.sliding:
		posture.end_slide()
	if posture.crouched and not posture.toggle():
		return
	broom.mount()

func _broom_physics(delta: float) -> void:
	if posture.sliding:
		posture.end_slide()
	var axis: Vector2 = player_input.fly_axis()
	var vertical: float = player_input.fly_vertical()
	velocity = broom.integrate(delta, velocity, view.horizontal_basis(), axis, vertical, knockback.horizontal)
	move_and_slide()
	knockback.finish_step(self, delta)
	broom.update_visual(delta, axis)

func _foot_physics(delta: float) -> void:
	if posture.sliding:
		_slide_physics(delta)
		return
	var axis: Vector2 = player_input.movement_axis()
	var planar: float = Vector2(velocity.x, velocity.z).length()
	var moving: bool = axis.length() > 0.2 or planar > 3.5
	if player_input.slide_requested() and is_on_floor() and moving:
		var dir := view.horizontal_basis() * Vector3(axis.x, 0.0, axis.y)
		if dir.length() < 0.15:
			dir = Vector3(velocity.x, 0.0, velocity.z)
		if dir.length() < 0.15:
			dir = view.horizontal_basis() * Vector3(0.0, 0.0, -1.0)
		dir.y = 0.0
		dir = dir.normalized()
		posture.begin_slide()
		_slide_time = slide_duration
		_slide_dir = dir
		var launch: float = minf(maxf(planar, walk_speed) * 1.55, slide_speed)
		velocity.x = dir.x * launch
		velocity.z = dir.z * launch
		_slide_physics(delta)
		return
	if player_input.crouch_toggled():
		posture.toggle()
	var direction: Vector3 = view.horizontal_basis() * Vector3(axis.x, 0.0, axis.y)
	var speed: float = sprint_speed if player_input.sprint_held() else walk_speed
	velocity.x = direction.x * speed + knockback.horizontal.x
	velocity.z = direction.z * speed + knockback.horizontal.z
	if is_on_floor() and velocity.y <= 0.0:
		velocity.y = jump_speed if player_input.jump_requested() else 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
	knockback.finish_step(self, delta)

func _slide_physics(delta: float) -> void:
	_slide_time -= delta
	var speed: float = Vector2(velocity.x, velocity.z).length()
	speed = maxf(0.0, speed - slide_friction * delta)
	if _slide_dir.length() > 0.01:
		velocity.x = _slide_dir.x * speed + knockback.horizontal.x
		velocity.z = _slide_dir.z * speed + knockback.horizontal.z
	if is_on_floor() and velocity.y <= 0.0:
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
	knockback.finish_step(self, delta)
	if _slide_time <= 0.0 or speed < 2.0 or not is_on_floor():
		posture.end_slide()

func _on_died() -> void:
	broom.force_dismount()
	if posture.sliding:
		posture.end_slide()
	player_input.set_capture(false)

func apply_knockback(impulse: Vector3) -> void:
	if not impulse.is_finite():
		return
	knockback.add_impulse(impulse)
	velocity.y += impulse.y

func reset_for_respawn(spawn: Transform3D) -> void:
	broom.force_dismount()
	global_transform = spawn
	velocity = Vector3.ZERO
	knockback.horizontal = Vector3.ZERO
	_slide_time = 0.0
	_slide_dir = Vector3.ZERO
	posture.reset_standing()
	view.rotation = Vector3.ZERO
	player_input.reset_for_respawn()
	$Combat.reset_for_respawn()
	health.reset_full()
	reset_physics_interpolation()
