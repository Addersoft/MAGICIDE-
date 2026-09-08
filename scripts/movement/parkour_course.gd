extends Node3D
## Small authored training route built from original primitives, no downloaded assets.
func block(label: String, location: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label.replace(" ","_")
	body.position = location
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	body.add_child(mesh)
	add_child(body)
	var text := Label3D.new()
	text.text = label
	text.font_size = 40
	text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text.position = location + Vector3(0,size.y/2.0+0.4,0)
	add_child(text)

func _ready() -> void:
	block("WALL RUN",Vector3(-13,2,3),Vector3(0.5,4,14),Color(0.1,0.55,0.65))
	block("WALL RUN",Vector3(13,2,3),Vector3(0.5,4,14),Color(0.1,0.55,0.65))
	block("SPACE TO VAULT",Vector3(-8,0.4,2),Vector3(3,0.8,1),Color(0.85,0.55,0.15))
	block("LEDGE CATCH",Vector3(-9,1.1,-9),Vector3(3,2.2,3),Color(0.7,0.32,0.6))
	block("SLIDE UNDER",Vector3(8,1.5,-16),Vector3(5,0.4,3),Color(0.1,0.55,0.65))
	block("PILLAR",Vector3(10.2,0.65,-16),Vector3(0.5,1.3,3),Color(0.2,0.3,0.4))
	# A thin non-colliding grid makes momentum and landing distance easy to read.
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.24,0.31,0.38)
	for axis in range(2):
		for index in range(-9,10):
			var line := MeshInstance3D.new()
			var shape := BoxMesh.new()
			shape.size = Vector3(0.025,0.008,38) if axis == 0 else Vector3(38,0.008,0.025)
			line.mesh = shape
			line.position = Vector3(index*2,0.01,0) if axis == 0 else Vector3(0,0.01,index*2)
			line.material_override = mat
			add_child(line)
	for wall in ["North","South","East","West"]:
		get_parent().get_node("ArenaGraybox/"+wall).add_to_group("no_traversal")
