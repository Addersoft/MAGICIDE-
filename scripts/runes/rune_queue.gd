extends Node
## Owns the three-slot combat queue. Newest rune is index 0 (slot 1).
signal queue_changed
const MAX_SLOTS: int = 3
## Match bind keys 1/2/3. Empty string means unbound.
@export var bound: PackedStringArray = PackedStringArray(["kenaz", "", ""])
var slots: PackedStringArray = PackedStringArray()

func insert_bind(index: int) -> bool:
	if index < 0 or index >= bound.size():
		return false
	var rune: String = str(bound[index])
	if rune.is_empty():
		return false
	var next := PackedStringArray()
	next.append(rune)
	for i in mini(slots.size(), MAX_SLOTS - 1):
		next.append(slots[i])
	slots = next
	queue_changed.emit()
	return true

func push_id(rune_id: String) -> bool:
	if rune_id.is_empty():
		return false
	var next := PackedStringArray()
	next.append(rune_id)
	for i in mini(slots.size(), MAX_SLOTS - 1):
		next.append(slots[i])
	slots = next
	queue_changed.emit()
	return true

func clear() -> void:
	if slots.is_empty():
		return
	slots = PackedStringArray()
	queue_changed.emit()

func consume() -> PackedStringArray:
	var taken: PackedStringArray = slots.duplicate()
	if not slots.is_empty():
		slots = PackedStringArray()
		queue_changed.emit()
	return taken

func snapshot() -> PackedStringArray:
	return slots.duplicate()

func is_empty() -> bool:
	return slots.is_empty()
