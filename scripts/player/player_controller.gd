extends CharacterBody3D
## M01 sole velocity and move_and_slide owner. Extract movement only when needed.
@export var walk_speed: float = 6.0
@export var gravity: float = 20.0
@onready var player_input = $PlayerInput
@onready var view = $View

func _ready() -> void:
	player_input.look_requested.connect(view.apply_look)

func _physics_process(delta: float) -> void:
	var axis: Vector2 = player_input.movement_axis()
	var direction: Vector3 = view.horizontal_basis() * Vector3(axis.x, 0.0, axis.y)
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
