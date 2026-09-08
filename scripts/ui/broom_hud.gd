extends Label
@onready var broom = get_parent().get_parent().get_node("Player/Broom")

func _process(_delta: float) -> void:
	if broom.mounted:
		text = "BROOM  HOVER  |  15 m/s anti-grav  |  F dismount  |  Space up  Ctrl down  S reverse"
	else:
		text = "ON FOOT  FPS  |  F mount broom"
