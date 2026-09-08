extends Node
## Owns timer/end/restart only. No scoring or team rules in this first slice.
signal round_ended
@export var duration_seconds: float = 180.0
var remaining: float = 0.0
var ended: bool = false
var _restart_pending: bool = false
@onready var player = get_parent().get_node("Player")
@onready var dummy = get_parent().get_node("Dummy")

func _ready() -> void:
	process_physics_priority = -100
	remaining = maxf(0.0, duration_seconds)

func _physics_process(delta: float) -> void:
	if ended:
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining <= 0.0:
		end_round()

func end_round() -> void:
	if ended:
		return
	ended = true
	remaining = 0.0
	player.player_input.gameplay_enabled = false
	player.player_input.set_capture(false)
	for actor in [player, dummy]:
		actor.get_node("Health").damage_enabled = false
		actor.process_mode = Node.PROCESS_MODE_DISABLED
	round_ended.emit()

func restart_round() -> void:
	if not ended or _restart_pending:
		return
	_restart_pending = true
	call_deferred("_reload")

func _reload() -> void:
	var error: Error = get_tree().reload_current_scene()
	if error != OK:
		_restart_pending = false
		push_error("Round reload failed: %s" % error_string(error))
