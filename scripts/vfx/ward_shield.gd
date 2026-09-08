extends Node3D
## Kingdom Hearts-style ward: shimmering iridescent faceted orb while RMB held.
const RADIUS: float = 1.35
var _shell: MeshInstance3D
var _inner: MeshInstance3D
var _mat: StandardMaterial3D
var _inner_mat: StandardMaterial3D
var _active: bool = false
var _pulse: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_shell = MeshInstance3D.new()
	_shell.mesh = _build_dodecahedron(RADIUS)
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.0)
	_mat.emission_enabled = true
	_mat.emission = Color(0.4, 0.9, 1.0)
	_mat.emission_energy_multiplier = 2.0
	_shell.material_override = _mat
	add_child(_shell)

	_inner = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = RADIUS * 0.88
	sphere.height = RADIUS * 1.76
	sphere.radial_segments = 18
	sphere.rings = 12
	_inner.mesh = sphere
	_inner_mat = StandardMaterial3D.new()
	_inner_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_inner_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_inner_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_inner_mat.albedo_color = Color(1.0, 0.55, 0.95, 0.0)
	_inner_mat.emission_enabled = true
	_inner_mat.emission = Color(0.9, 0.4, 1.0)
	_inner_mat.emission_energy_multiplier = 1.4
	_inner.material_override = _inner_mat
	add_child(_inner)
	visible = false
	position = Vector3(0.0, 0.95, 0.0)

func set_active(on: bool) -> void:
	_active = on
	if on:
		visible = true
		_pulse = 1.0
	else:
		_pulse = 0.0

func is_active() -> bool:
	return _active

func _process(delta: float) -> void:
	_time += delta
	var target: float = 1.0 if _active else 0.0
	_pulse = move_toward(_pulse, target, delta * 8.0)
	if _pulse <= 0.01 and not _active:
		visible = false
		return
	visible = true
	var hue: float = fmod(_time * 0.4, 1.0)
	_mat.albedo_color = Color.from_hsv(hue, 0.55, 1.0, 0.28 * _pulse)
	_mat.emission = Color.from_hsv(hue, 0.75, 1.0)
	_mat.emission_energy_multiplier = 1.8 + 1.4 * _pulse + 0.5 * sin(_time * 10.0)
	var hue2: float = fmod(hue + 0.48, 1.0)
	_inner_mat.albedo_color = Color.from_hsv(hue2, 0.45, 1.0, 0.14 * _pulse)
	_inner_mat.emission = Color.from_hsv(hue2, 0.7, 1.0)
	_inner_mat.emission_energy_multiplier = 1.3 + 0.9 * _pulse
	var s: float = 1.0 + 0.045 * sin(_time * 5.5) * _pulse
	scale = Vector3.ONE * s
	rotation.y += delta * 0.85
	rotation.x = sin(_time * 0.85) * 0.1
	position = Vector3(0.0, 0.95, 0.0)

func _build_dodecahedron(r: float) -> ArrayMesh:
	var phi: float = (1.0 + sqrt(5.0)) * 0.5
	var inv: float = 1.0 / phi
	var raw: Array[Vector3] = []
	for x in [-1.0, 1.0]:
		for y in [-1.0, 1.0]:
			for z in [-1.0, 1.0]:
				raw.append(Vector3(x, y, z))
	for x in [-1.0, 1.0]:
		for y in [-1.0, 1.0]:
			raw.append(Vector3(0.0, x * inv, y * phi))
			raw.append(Vector3(x * inv, y * phi, 0.0))
			raw.append(Vector3(y * phi, 0.0, x * inv))
	var verts: Array[Vector3] = []
	for v in raw:
		verts.append(v.normalized() * r)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(verts.size()):
		var dists: Array = []
		for j in range(verts.size()):
			if i == j:
				continue
			dists.append([verts[i].distance_squared_to(verts[j]), j])
		dists.sort_custom(func(a, b): return a[0] < b[0])
		var a: int = dists[0][1]
		var b: int = dists[1][1]
		var c: int = dists[2][1]
		_tri(st, verts, i, a, b)
		_tri(st, verts, i, b, c)
		_tri(st, verts, i, c, a)
	st.generate_normals()
	return st.commit()

func _tri(st: SurfaceTool, verts: Array, i: int, a: int, b: int) -> void:
	var n: Vector3 = (verts[i] + verts[a] + verts[b]).normalized()
	var mid: Vector3 = (verts[i] + verts[a] + verts[b]) / 3.0
	if mid.dot(n) < 0.0:
		n = -n
		st.set_normal(n)
		st.add_vertex(verts[i])
		st.set_normal(n)
		st.add_vertex(verts[b])
		st.set_normal(n)
		st.add_vertex(verts[a])
	else:
		st.set_normal(n)
		st.add_vertex(verts[i])
		st.set_normal(n)
		st.add_vertex(verts[a])
		st.set_normal(n)
		st.add_vertex(verts[b])
