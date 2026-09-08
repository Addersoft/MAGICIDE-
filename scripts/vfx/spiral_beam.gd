extends Node3D
## Original procedural Special Beam Cannon-inspired presentation. No damage authority.
var origin: Vector3
var endpoint: Vector3
var has_impact: bool = true
var age: float = 0.0
const LIFETIME: float = 0.24
var _materials: Array[StandardMaterial3D] = []

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	result.albedo_color = color
	result.emission_enabled = true
	result.emission = Color(color.r,color.g,color.b)
	result.emission_energy_multiplier = 2.5
	_materials.append(result)
	return result

func _ready() -> void:
	global_position = origin
	var length: float = minf(origin.distance_to(endpoint),60.0)
	if length < 0.02:
		queue_free()
		return
	var direction: Vector3 = (endpoint-origin).normalized()
	look_at(origin+direction,Vector3.RIGHT if absf(direction.dot(Vector3.UP))>0.99 else Vector3.UP)
	var core := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.025
	cylinder.bottom_radius = 0.04
	cylinder.height = length
	cylinder.radial_segments = 8
	core.mesh = cylinder
	core.material_override = material(Color(1.0,0.95,0.65,1))
	core.rotation.x = PI/2.0
	core.position.z = -length/2.0
	add_child(core)
	var mesh := ImmediateMesh.new()
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	add_child(instance)
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES,material(Color(0.85,0.2,1.0,1)))
	var segments: int = clampi(ceili(length*18.0),24,240)
	for i in range(segments):
		var t0: float = float(i)/segments
		var t1: float = float(i+1)/segments
		var angle0: float = t0*length*4.8
		var angle1: float = t1*length*4.8
		var radius0: float = 0.075 + 0.055*sin(t0*PI)
		var radius1: float = 0.075 + 0.055*sin(t1*PI)
		var center0 := Vector3(cos(angle0)*radius0,sin(angle0)*radius0,-t0*length)
		var center1 := Vector3(cos(angle1)*radius1,sin(angle1)*radius1,-t1*length)
		for side in range(5):
			var a: float = float(side)*TAU/5.0
			var b: float = float(side+1)*TAU/5.0
			var offset_a := Vector3(cos(a),sin(a),0)*0.025
			var offset_b := Vector3(cos(b),sin(b),0)*0.025
			for vertex in [center0+offset_a,center1+offset_a,center1+offset_b,center0+offset_a,center1+offset_b,center0+offset_b]:
				mesh.surface_add_vertex(vertex)
	mesh.surface_end()
	if not has_impact:
		return
	var impact := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.16
	sphere.height = 0.32
	sphere.radial_segments = 12
	sphere.rings = 6
	impact.mesh = sphere
	impact.position.z = -length
	impact.material_override = material(Color(1.0,0.7,0.25,1))
	add_child(impact)

func _process(delta: float) -> void:
	age += delta
	var fade: float = clampf(1.0-age/LIFETIME,0.0,1.0)
	for mat in _materials:
		mat.albedo_color.a = fade
	if age >= LIFETIME:
		queue_free()
