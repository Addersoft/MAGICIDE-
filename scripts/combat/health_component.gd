extends Node
## Sole owner of HP and lethal transition. No respawn or presentation responsibilities.
signal health_changed(current: float, maximum: float)
signal died
@export var max_health: float = 100.0
var current_health: float = 0.0
var is_dead: bool = false
var damage_enabled: bool = true

func _ready() -> void:
	max_health = maxf(1.0, max_health) if is_finite(max_health) else 100.0
	current_health = max_health

func apply_damage(amount: float) -> float:
	if not damage_enabled or is_dead or not is_finite(amount) or amount <= 0.0:
		return 0.0
	var applied: float = minf(amount, current_health)
	current_health = maxf(0.0, current_health - applied)
	# Commit death before notifying listeners, including reentrant damage callbacks.
	var lethal: bool = current_health == 0.0
	if lethal:
		is_dead = true
	health_changed.emit(current_health, max_health)
	if lethal:
		died.emit()
	return applied

func reset_full() -> void:
	# Lifecycle-only: callers must reset physical/action state before restoring health.
	is_dead = false
	current_health = max_health
	health_changed.emit(current_health, max_health)
