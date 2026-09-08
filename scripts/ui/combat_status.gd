extends Label
@onready var combat = get_parent().get_parent().get_node("Player/Combat")
@onready var rune_queue = get_parent().get_parent().get_node("Player/RuneQueue")
var last_result: String = "Aim at the orange dummy"

func _ready() -> void:
	combat.shot_resolved.connect(_shot)
	combat.combat_reset.connect(_reset)
	combat.cast_failed.connect(_failed)
	rune_queue.queue_changed.connect(_queue)

func _shot(_position: Vector3, damage: float) -> void:
	var kind: String = combat.last_kind
	if damage > 0.0:
		last_result = "%s HIT — %.0f damage" % [kind.to_upper(), damage]
	else:
		last_result = "No damage"

func _failed(reason: String) -> void:
	last_result = reason

func _queue() -> void:
	pass

func _process(_delta: float) -> void:
	if not combat.controls.gameplay_enabled:
		text = "COMBAT  |  Round ended"
		return
	if combat.health.is_dead:
		text = "COMBAT  |  Disabled while dead"
		return
	var state: String = "READY" if combat.cooldown_remaining <= 0.0 else "%.1f s" % combat.cooldown_remaining
	var queue: String = _queue_text()
	var weapon: String = "SNIPER TAG" if rune_queue.is_empty() else "CAST " + SpellCatalog.resolve(rune_queue.snapshot()).get("label", "SPELL")
	text = "LMB  %s  |  %s  |  %s  |  %s" % [weapon, queue, state, last_result]

func _queue_text() -> String:
	var slots: PackedStringArray = rune_queue.snapshot()
	if slots.is_empty():
		return "Queue empty"
	var names: PackedStringArray = PackedStringArray()
	for rune_id in slots:
		names.append(rune_id.capitalize())
	return "Queue " + " > ".join(names)

func _reset() -> void:
	last_result = "Aim at the orange dummy"
