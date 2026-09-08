class_name SpellCatalog
extends RefCounted
## Resolves a queue snapshot into a cast recipe. No world queries.
const TAG_DAMAGE: float = 12.0
const KENAZ_BASE: float = 12.0
const KENAZ_STEP: float = 4.0

static func resolve(queue: PackedStringArray) -> Dictionary:
	if queue.is_empty():
		return {"kind": "tag", "damage": TAG_DAMAGE, "label": "SNIPER TAG"}
	var copies: int = 0
	for rune_id in queue:
		if rune_id != "kenaz":
			return {"kind": "unsupported", "damage": 0.0, "label": "UNSUPPORTED"}
		copies += 1
	var damage: float = KENAZ_BASE + KENAZ_STEP * float(copies)
	return {"kind": "kenaz", "damage": damage, "copies": copies, "label": "KENAZ"}
