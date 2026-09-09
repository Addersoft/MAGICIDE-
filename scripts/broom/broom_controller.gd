extends Node
## Flight velocity/mode owner. PlayerController alone moves the collision body.
signal mount_changed(mounted: bool)
@export var hover_speed: float = 15.0
@export var boost_speed: float = 40.0
@export var hover_acceleration: float = 35.0
@export var boost_acceleration: float = 22.0
var mounted: bool = false
var boosting: bool = false
var flight_velocity: Vector3 = Vector3.ZERO
var altitude_target: float = 0.0
var roll_angle: float = 0.0
var bank_angle: float = 0.0
var notice: String = ""
var _previous_yaw: float = 0.0
@onready var actor = get_parent()

func toggle() -> bool:
	if actor.health.is_dead or not actor.player_input.controls_active or not actor.player_input.gameplay_enabled:
		return false
	if not actor.posture.can_stand():
		notice = "Need standing clearance to mount or dismount"
		return false
	if not mounted and (actor.motor.state == "HANG" or actor.motor.state == "VAULT"):
		notice = "Finish or drop from the ledge before mounting"
		return false
	if mounted:
		mounted = false
		boosting = false
		var horizontal := Vector3(flight_velocity.x,0,flight_velocity.z)
		actor.motor.reset()
		actor.motor.horizontal = horizontal.limit_length(actor.motor.speed_cap)
		actor.knockback.horizontal += horizontal-actor.motor.horizontal
		actor.velocity.y = flight_velocity.y
	else:
		flight_velocity = actor.velocity-actor.knockback.horizontal
		altitude_target = actor.global_position.y + (0.65 if actor.is_on_floor() else 0.0)
		actor.posture.reset_standing()
		actor.motor.reset()
		roll_angle = 0.0
		bank_angle = 0.0
		_previous_yaw = actor.view.rotation.y
		mounted = true
	actor.player_input.sync_context()
	notice = ""
	mount_changed.emit(mounted)
	return true

func step(delta: float) -> Vector3:
	var controls = actor.player_input
	var axis: Vector2 = controls.broom_axis()
	var vertical: float = controls.broom_altitude()
	var wants_boost: bool = controls.sprint_held()
	if boosting and not wants_boost:
		altitude_target = actor.global_position.y
	boosting = wants_boost
	var roll_input: float = controls.broom_roll()
	if absf(roll_input)>0.01:
		roll_angle = wrapf(roll_angle+roll_input*2.8*delta,-PI,PI)
	else:
		roll_angle = move_toward(roll_angle,0.0,1.4*delta)
	var yaw_rate: float = angle_difference(_previous_yaw,actor.view.rotation.y)/delta
	_previous_yaw = actor.view.rotation.y
	bank_angle = lerpf(bank_angle,clampf(-yaw_rate*0.2,-0.5,0.5) if boosting else 0.0,1.0-exp(-6.0*delta))
	if controls.broom_brake():
		flight_velocity = Vector3.ZERO
		altitude_target = actor.global_position.y
		return flight_velocity
	if boosting:
		var forward: Vector3 = -actor.view.global_basis.z
		var right: Vector3 = actor.view.global_basis.x.rotated(forward,-roll_angle)
		# Shift alone gives forward thrust; S requests reverse thrust/braking.
		var thrust: float = -axis.y if absf(axis.y)>0.01 else 1.0
		var heading: Vector3 = forward*thrust + right*axis.x
		if absf(vertical)>0.01:
			heading.y = vertical*0.65
		var desired: Vector3 = heading.normalized()*boost_speed
		flight_velocity = flight_velocity.move_toward(desired,boost_acceleration*delta)
		altitude_target = actor.global_position.y
	else:
		var wish: Vector3 = actor.view.horizontal_basis()*Vector3(axis.x,0,axis.y)
		var flat := Vector3(flight_velocity.x,0,flight_velocity.z)
		flat = flat.move_toward(wish*hover_speed,hover_acceleration*delta)
		altitude_target += vertical*6.0*delta
		var acceleration: float = (altitude_target-actor.global_position.y)*16.0-flight_velocity.y*8.0
		var climb: float = clampf(flight_velocity.y+acceleration*delta,-8.0,8.0)
		flight_velocity = Vector3(flat.x,climb,flat.z)
		if flat.length()<=hover_speed+0.01:
			flight_velocity = flight_velocity.limit_length(hover_speed)
	return flight_velocity

func after_move() -> void:
	for i in range(actor.get_slide_collision_count()):
		var normal: Vector3 = actor.get_slide_collision(i).get_normal()
		if flight_velocity.dot(normal)<0.0:
			flight_velocity = flight_velocity.slide(normal)
		if absf(normal.y)>0.5:
			altitude_target = actor.global_position.y
	if actor.is_on_floor() and flight_velocity.y<0.0:
		altitude_target = actor.global_position.y
		flight_velocity.y = 0.0

func reset() -> void:
	mounted = false
	boosting = false
	flight_velocity = Vector3.ZERO
	altitude_target = actor.global_position.y
	roll_angle = 0.0
	bank_angle = 0.0
	notice = ""
	mount_changed.emit(false)
