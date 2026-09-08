extends Label
@onready var combat = get_parent().get_parent().get_node("Player/Combat")
var last_result: String = "Aim at the orange dummy"

func _ready() -> void:
	combat.shot_resolved.connect(_shot)
	combat.combat_reset.connect(_reset)

func _shot(_position: Vector3, damage: float) -> void:
	last_result = "HIT — %.0f damage" % damage if damage > 0.0 else "No damage"

func _process(_delta: float) -> void:
	if not combat.controls.gameplay_enabled:
		text = "SNIPER TAG  |  Round ended"
		return
	if combat.health.is_dead:
		text = "SNIPER TAG  |  Disabled while dead"
		return
	var state: String = "READY" if combat.cooldown_remaining <= 0.0 else "%.1f s" % combat.cooldown_remaining
	text = "LMB  SNIPER TAG  |  %s  |  %s" % [state, last_result]

func _reset() -> void:
	last_result = "Aim at the orange dummy"
