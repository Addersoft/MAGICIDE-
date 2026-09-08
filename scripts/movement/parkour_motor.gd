extends Node
## Jump always works while sprinting. Q/E = clockwise/counter parkour barrel-roll.
@export_range(9.0, 30.0) var speed_cap: float = 24.0
@export_range(35.0, 150.0) var ground_acceleration: float = 95.0
@export_range(1.0, 34.0) var ground_braking: float = 28.0
@export_range(1.0, 40.0) var air_acceleration: float = 30.0
@export_range(0.1, 10.0) var slide_friction: float = 1.8
@export_range(0.2, 0.8) var roll_duration: float = 0.48
@export_range(8.0, 22.0) var roll_speed: float = 15.0
@export_range(0.2, 3.0) var roll_cooldown_time: float = 0.45

const BUFFER: float = 0.28
const COYOTE: float = 0.26
const FOOT_SNAP: float = 0.55
var horizontal: Vector3 = Vector3.ZERO
var state: String = "GROUND"
var coyote: float = 0.0
var jump_buffer: float = 0.0
var slide_time: float = 0.0
var dodge_time: float = 0.0
var dodge_cooldown: float = 0.0
var wall_budget: float = 1.25
var wall_lock: float = 0.0
var glide_budget: float = 1.2
var roll_time: float = 0.0
var roll_cooldown: float = 0.0
var roll_sign: float = 0.0
var _restore_standing: bool = false
var _last_wall: Vector3 = Vector3.ZERO
var _route: Array[Vector3] = []
var _traverse_time: float = 0.0
var _hang_target: Vector3
var _ledge_target: Vector3
var _ledge_outside: Vector3
var _jump_cut: bool = false
var _jump_active: bool = false
var _exit_direction: Vector3 = Vector3.FORWARD
@onready var actor = get_parent()
@onready var probe = actor.get_node("TraversalProbe")

func reset() -> void:
	horizontal = Vector3.ZERO
	state = "GROUND"
	coyote = 0.0
	jump_buffer = 0.0
	slide_time = 0.0
	dodge_time = 0.0
	dodge_cooldown = 0.0
	wall_budget = 1.25
	glide_budget = 1.2
	wall_lock = 0.0
	roll_time = 0.0
	roll_cooldown = 0.0
	roll_sign = 0.0
	_restore_standing = false
	_last_wall = Vector3.ZERO
	_route.clear()
	_traverse_time = 0.0
	_jump_cut = false
	_jump_active = false
	_exit_direction = Vector3.FORWARD
	if actor.has_node("View") and actor.view.has_method("set_roll"):
		actor.view.set_roll(0.0)

func accelerate(wish: Vector3, wish_speed: float, acceleration: float, delta: float) -> void:
	if wish.is_zero_approx():
		return
	var add: float = wish_speed - horizontal.dot(wish)
	if add > 0.0:
		horizontal += wish * minf(add, acceleration * delta)
	horizontal = horizontal.limit_length(speed_cap)

func _near_floor() -> bool:
	if actor.is_on_floor():
		return true
	var feet: Vector3 = actor.global_position
	var hit: Dictionary = probe.ray(feet + Vector3(0, 0.25, 0), feet + Vector3(0, -0.7, 0))
	return not hit.is_empty() and hit.normal.y > 0.55

func _finish_slide() -> void:
	slide_time = 0.0
	if actor.posture.has_method("end_slide"):
		actor.posture.end_slide()
	elif _restore_standing and actor.posture.crouched and actor.posture.can_stand():
		actor.posture.toggle()
	_restore_standing = false

func start_slide() -> bool:
	if not _near_floor() or horizontal.length() < 4.0 or slide_time > 0.0:
		return false
	_restore_standing = not actor.posture.crouched
	if actor.posture.has_method("begin_slide"):
		actor.posture.begin_slide()
	elif not actor.posture.crouched:
		actor.posture.toggle()
	slide_time = 1.25
	return true

func start_roll(sign: float) -> bool:
	if roll_cooldown > 0.0 or roll_time > 0.0:
		return false
	if state == "HANG" or state == "VAULT":
		return false
	roll_sign = sign
	roll_time = roll_duration
	roll_cooldown = roll_cooldown_time
	_finish_slide()
	var right: Vector3 = actor.view.horizontal_basis().x
	var forward: Vector3 = -actor.view.horizontal_basis().z
	var keep: Vector3 = horizontal
	if keep.length() < 5.0:
		keep = forward * 9.0
	# Dive-roll: mostly forward, with a side component so Q/E are directional
	var side: Vector3 = right * sign * roll_speed
	horizontal = (keep.normalized() * maxf(keep.length(), 10.0) + side).limit_length(speed_cap)
	state = "ROLL"
	actor.floor_snap_length = 0.0
	return true

func _begin_mantle(target: Vector3, outside: Vector3) -> void:
	_route.assign([Vector3(actor.global_position.x, outside.y, actor.global_position.z), target])
	_exit_direction = Vector3(target.x - outside.x, 0, target.z - outside.z).normalized()
	state = "VAULT"
	_traverse_time = 0.0
	jump_buffer = 0.0
	coyote = 0.0

func _traverse(delta: float, jump: bool, drop: bool) -> Vector3:
	_traverse_time += delta
	if not probe.standing_clear(_ledge_target):
		state = "AIR"
		_route.clear()
		return Vector3(0, -2, 0)
	if state == "HANG":
		if drop or _traverse_time > 2.0:
			state = "AIR"
			wall_lock = 0.3
			return Vector3(0, -2, 0)
		if jump:
			_begin_mantle(_ledge_target, _ledge_outside)
		else:
			return (_hang_target - actor.global_position).limit_length(10.0 * delta) / delta
	if _traverse_time > 0.8:
		state = "AIR"
		_route.clear()
		return Vector3(0, -2, 0)
	while not _route.is_empty() and actor.global_position.distance_to(_route[0]) < 0.055:
		_route.pop_front()
	if _route.is_empty():
		state = "AIR"
		horizontal = _exit_direction * maxf(horizontal.length(), 6.0)
		return horizontal
	return (_route[0] - actor.global_position).limit_length(9.0 * delta) / delta

func step(delta: float, crouch_pressed: bool) -> Vector3:
	var input = actor.player_input
	var jump_edge: bool = input.jump_requested()
	var slide: bool = input.slide_requested()
	var wish_axis: Vector2 = input.movement_axis()
	var wish: Vector3 = actor.view.horizontal_basis() * Vector3(wish_axis.x, 0, wish_axis.y)
	var on_floor: bool = actor.is_on_floor() or _near_floor()
	var grounded: bool = on_floor
	var vy: float = actor.velocity.y
	wall_lock = maxf(0.0, wall_lock - delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	roll_cooldown = maxf(0.0, roll_cooldown - delta)
	if jump_edge:
		jump_buffer = BUFFER
	else:
		jump_buffer = maxf(0.0, jump_buffer - delta)

	if input.roll_left_requested():
		start_roll(-1.0)
	elif input.roll_right_requested():
		start_roll(1.0)

	if state == "HANG" or state == "VAULT":
		if not input.controls_active:
			state = "AIR"
			_route.clear()
			return Vector3(0, -2, 0)
		return _traverse(delta, jump_edge, slide or crouch_pressed)

	if not input.controls_active:
		horizontal = Vector3.ZERO
		_finish_slide()
		roll_time = 0.0
		state = "GROUND" if grounded else "AIR"
		if actor.view.has_method("set_roll"):
			actor.view.set_roll(0.0)
		return Vector3(0, 0 if grounded else vy - actor.gravity * delta, 0)

	if grounded:
		coyote = COYOTE
		wall_budget = 1.25
		glide_budget = 1.2
		_jump_cut = false
		_jump_active = false
	else:
		coyote = maxf(0.0, coyote - delta)

	if slide or (input.has_method("slide_held") and input.slide_held()):
		# Don't start a new slide on the same frame a jump is buffered — jump wins,
		# then landing+Ctrl can slide again.
		if grounded and horizontal.length() > 3.5 and jump_buffer <= 0.0:
			if slide_time <= 0.0:
				start_slide()
			else:
				slide_time = maxf(slide_time, 0.4)

	var wall: Dictionary = probe.side_wall() if not grounded else {}
	var wall_valid: bool = not wall.is_empty() and (wall_lock <= 0.0 or wall.normal.dot(_last_wall) < 0.5)

	var jumped: bool = false
	var can_floor_jump: bool = jump_buffer > 0.0 and (grounded or coyote > 0.0)
	if can_floor_jump:
		var was_sliding: bool = slide_time > 0.0 or actor.posture.sliding
		# Same vertical jump standing or sprinting — sprint only keeps speed.
		vy = actor.jump_speed
		actor.floor_snap_length = 0.0
		if was_sliding:
			var launch: Vector3 = horizontal
			if launch.length() < 4.0:
				launch = -actor.view.horizontal_basis().z * actor.sprint_speed
			horizontal = launch.limit_length(speed_cap)
			vy = actor.jump_speed + 1.5
			_finish_slide()
		elif input.sprint_held():
			var fwd: Vector3 = -actor.view.horizontal_basis().z
			if not wish.is_zero_approx():
				fwd = wish.normalized()
			horizontal = fwd * maxf(horizontal.length(), actor.sprint_speed)
		jumped = true
		jump_buffer = 0.0
		coyote = 0.0
		grounded = false
		_jump_cut = false
		_jump_active = true
		if actor.posture.crouched and actor.posture.has_method("set_crouched"):
			actor.posture.set_crouched(false)
	elif jump_buffer > 0.0 and wall_valid:
		var along: Vector3 = horizontal.slide(wall.normal)
		if along.length() < 3.0:
			along = -actor.view.horizontal_basis().z.slide(wall.normal) * 9.0
		horizontal = (along + wall.normal * 7.0).limit_length(speed_cap)
		vy = actor.jump_speed
		actor.floor_snap_length = 0.0
		_last_wall = wall.normal
		wall_lock = 0.3
		jumped = true
		jump_buffer = 0.0
		coyote = 0.0
		grounded = false
		_jump_cut = false
		_jump_active = true
		_finish_slide()

	# Never steal a buffered jump into a mantle.
	if not jumped and jump_buffer <= 0.0 and not input.sprint_held() and wish_axis.y < -0.25 and wall_lock <= 0.0 and ((jump_edge and on_floor) or (not on_floor and vy < 1.0)):
		var ledge: Dictionary = probe.ledge()
		if not ledge.is_empty():
			_ledge_target = ledge.target
			_ledge_outside = ledge.outside
			if on_floor and ledge.height <= 1.35:
				_begin_mantle(ledge.target, ledge.outside)
				return _traverse(delta, false, false)
			elif not on_floor and ledge.height > 1.0:
				state = "HANG"
				_traverse_time = 0.0
				_hang_target = ledge.outside - Vector3(0, 1.3, 0)
				return _traverse(delta, false, false)

	if roll_time > 0.0:
		roll_time = maxf(0.0, roll_time - delta)
		state = "ROLL"
		var progress: float = 1.0 - (roll_time / roll_duration)
		# One full barrel: Q counter-clockwise, E clockwise, from the player's view.
		var roll_angle: float = progress * TAU * roll_sign
		if actor.view.has_method("set_roll"):
			actor.view.set_roll(roll_angle)
		if actor.view.has_method("set_eye_height"):
			actor.view.set_eye_height(lerpf(1.65, 0.72, sin(progress * PI)))
		if not grounded and not jumped:
			vy -= actor.gravity * 0.85 * delta
		elif not jumped:
			vy = 2.2 * (1.0 - progress)  # small hop through the tumble
		if roll_time <= 0.0:
			if actor.view.has_method("set_roll"):
				actor.view.set_roll(0.0)
			if actor.view.has_method("set_eye_height") and not actor.posture.crouched:
				actor.view.set_eye_height(1.65)
			roll_sign = 0.0
			if grounded:
				actor.floor_snap_length = FOOT_SNAP
	elif grounded and slide_time > 0.0 and not jumped:
		slide_time = maxf(0.0, slide_time - delta)
		horizontal = horizontal.move_toward(Vector3.ZERO, slide_friction * delta)
		if not wish.is_zero_approx():
			horizontal = horizontal.lerp(wish.normalized() * maxf(horizontal.length(), 6.0), 2.0 * delta)
		var slope: Vector3 = Vector3.DOWN.slide(actor.get_floor_normal())
		horizontal += Vector3(slope.x, 0, slope.z) * actor.gravity * delta
		state = "SLIDE"
		if slide_time <= 0.0 or horizontal.length() < 2.5:
			_finish_slide()
	elif not grounded and not jumped and wall_valid and wish_axis.y < -0.2 and horizontal.length() > 4.0 and wall_budget > 0.0:
		state = "WALL RUN"
		wall_budget = maxf(0.0, wall_budget - delta)
		_last_wall = wall.normal
		horizontal = horizontal.slide(wall.normal)
		var along: Vector3 = horizontal.normalized() if horizontal.length() > 0.1 else -actor.view.horizontal_basis().z
		accelerate(along, 12.0, 24.0, delta)
		vy = clampf(vy, -1.5, 2.5)
	else:
		state = "GROUND" if grounded else "AIR"
		if grounded and not jumped:
			horizontal = horizontal.move_toward(Vector3.ZERO, ground_braking * delta)
			var target_speed: float = actor.sprint_speed if input.sprint_held() else actor.walk_speed
			if actor.posture.crouched and not actor.posture.sliding:
				target_speed = actor.walk_speed * 0.55
			accelerate(wish.normalized() if not wish.is_zero_approx() else Vector3.ZERO, target_speed, ground_acceleration, delta)
		elif not jumped:
			var target_speed: float = actor.sprint_speed if input.sprint_held() else actor.walk_speed
			accelerate(wish.normalized() if not wish.is_zero_approx() else Vector3.ZERO, target_speed, air_acceleration, delta)

	if grounded and not jumped and roll_time <= 0.0:
		vy = 0.0
		actor.floor_snap_length = FOOT_SNAP
	elif not jumped and state != "ROLL":
		var gravity_scale: float = 0.15 if state == "WALL RUN" else 1.0
		if input.glide_held() and glide_budget > 0.0 and vy <= 0.0:
			glide_budget = maxf(0.0, glide_budget - delta)
			gravity_scale = 0.2
			vy = maxf(vy, -2.5)
			state = "GLIDE"
		vy -= actor.gravity * gravity_scale * delta
		# Variable jump: only cut if they tap. Holding Space keeps full jump (sprint or not).
		if _jump_active and not input.jump_held() and vy > 4.0 and not _jump_cut:
			vy = 4.0
			_jump_cut = true

	horizontal = horizontal.limit_length(speed_cap)
	return Vector3(horizontal.x, vy, horizontal.z)

func after_move() -> void:
	for i in range(actor.get_slide_collision_count()):
		var normal: Vector3 = actor.get_slide_collision(i).get_normal()
		var planar := Vector3(normal.x, 0, normal.z)
		if planar.length_squared() > 0.5 and horizontal.dot(planar) < 0.0:
			horizontal = horizontal.slide(planar.normalized())
