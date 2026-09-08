extends CharacterBody3D
## Sole velocity and move_and_slide owner. Extract movement only when needed.
@export var walk_speed: float = 6.0
@export var sprint_speed: float = 9.0
@export var jump_speed: float = 7.0
@export var gravity: float = 20.0
@onready var player_input = $PlayerInput
@onready var view = $View

func _ready() -> void:
	player_input.look_requested.connect(view.apply_look)

func _physics_process(delta: float) -> void:
	var axis: Vector2 = player_input.movement_axis()
	var direction: Vector3 = view.horizontal_basis() * Vector3(axis.x, 0.0, axis.y)
	var speed: float = sprint_speed if player_input.sprint_held() else walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if is_on_floor():
		velocity.y = jump_speed if player_input.jump_requested() else 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
