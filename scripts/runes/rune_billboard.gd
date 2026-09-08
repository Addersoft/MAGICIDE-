extends Node3D
## World-space queue over the caster. Presentation only.
@onready var queue = get_parent().get_node("RuneQueue")
@onready var marks: Array[MeshInstance3D] = [$Slot0, $Slot1, $Slot2]

func _ready() -> void:
	queue.queue_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var slots: PackedStringArray = queue.snapshot()
	for i in marks.size():
		var mesh: MeshInstance3D = marks[i]
		if i >= slots.size():
			mesh.visible = false
			continue
		mesh.visible = true
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = _color_for(slots[i])
		mesh.set_surface_override_material(0, mat)

func _color_for(rune_id: String) -> Color:
	if rune_id == "kenaz":
		return Color(1.0, 0.45, 0.12, 1.0)
	return Color(0.55, 0.58, 0.65, 1.0)
