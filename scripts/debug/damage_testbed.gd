extends Node
## Temporary M04 fixture. Not a weapon or production damage authority.
@onready var player = get_parent().get_node("Player")
@onready var dummy_health = get_parent().get_node("Dummy/Health")
@onready var status: Label = get_parent().get_node("HUD/HealthStatus")
@onready var dummy_label: Label3D = get_parent().get_node("Dummy/Label3D")

func _ready() -> void:
	player.get_node("Health").health_changed.connect(_refresh)
	dummy_health.health_changed.connect(_refresh)
	_refresh(0.0, 0.0)

func _refresh(_current: float, _maximum: float) -> void:
	var hp = player.get_node("Health")
	status.text = "Player: %.0f / %.0f    Dummy: %.0f / %.0f" % [hp.current_health,hp.max_health,dummy_health.current_health,dummy_health.max_health]
	if not player.player_input.gameplay_enabled:
		status.text += "\nRound ended"
	elif hp.is_dead:
		status.text += "\nDEAD — " + player.get_node("Respawn").status_text()
	elif not player.player_input.controls_active:
		status.text += "\nClick to resume"
	dummy_label.text = "DUMMY  %.0f HP" % dummy_health.current_health
	if dummy_health.is_dead:
		dummy_label.text = "DUMMY — DEAD\n" + get_parent().get_node("Dummy/Respawn").status_text()

func _unhandled_input(event: InputEvent) -> void:
	if not player.player_input.controls_active or player.health.is_dead:
		return
	if event.is_action_pressed("test_hurt_player"):
		player.health.apply_damage(25.0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("test_hurt_dummy"):
		dummy_health.apply_damage(25.0)
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	_refresh(0.0, 0.0)
