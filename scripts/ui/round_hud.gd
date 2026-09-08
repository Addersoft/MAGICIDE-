extends CanvasLayer
@onready var manager = get_parent().get_node("RoundManager")
@onready var clock: Label = $RoundClock
@onready var overlay: Control = $RoundEnd

func _ready() -> void:
	manager.round_ended.connect(_ended)
	$RoundEnd/Panel/Restart.pressed.connect(manager.restart_round)

func _process(_delta: float) -> void:
	var seconds: int = ceili(manager.remaining)
	clock.text = "%02d:%02d" % [seconds / 60, seconds % 60]

func _ended() -> void:
	overlay.show()
	$RoundEnd/Panel/Restart.grab_focus()
