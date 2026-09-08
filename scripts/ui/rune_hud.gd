extends Label
@onready var rune_queue = get_parent().get_parent().get_node("Player/RuneQueue")

func _ready() -> void:
	rune_queue.queue_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var slots: PackedStringArray = rune_queue.snapshot()
	var cells: PackedStringArray = PackedStringArray()
	for i in 3:
		if i < slots.size():
			cells.append("[%s]" % slots[i].capitalize())
		else:
			cells.append("[ ]")
	text = "1 Kenaz   2 —   3 —     C clear     %s  %s  %s" % [cells[0], cells[1], cells[2]]
