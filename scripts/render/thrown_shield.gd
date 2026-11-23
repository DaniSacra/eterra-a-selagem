class_name ThrownShield
extends RefCounted
## The knight's shield in the air and on the floor (C1eMarks draws it, Horde.shields and Enemy.shield_lies say where): the
## very shield of his model, cut out of the baked mesh (BakedModel.parts "shield", the run that CrowdRenderer hides from his
## hand while it is away), so it is the same wood, rim and straps. Drawing only.

## Spin about the vertical axis while it flies (rad/s), and how far it is tipped at the throw (rad; flat when it lands).
const SPIN := 15.0
const TIP := 1.0


## The shield alone, centred, its face (the side the boss rises from) up: a mesh of the model's own triangles, UV and normals
## (so the model's albedo paints it). Null when the model has no shield part.
static func build(baked: BakedModel) -> ArrayMesh:
	var ids: Array = baked.parts.get("shield", [])
	if ids.is_empty() or baked.mesh == null:
		return null
	var arr := baked.mesh.surface_get_arrays(0)
	var pos: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var nor: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
	var uv: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var is_part := {}
	var centre := Vector3.ZERO
	for v: int in ids:
		is_part[v] = true
		centre += pos[v]
	centre /= ids.size()
	# the face: the area-weighted mean of the triangle normals, each turned to the side of the first (a round plate's axis)
	var face := Vector3.ZERO
	var first := Vector3.ZERO
	for t in range(0, idx.size(), 3):
		if not (is_part.has(idx[t]) and is_part.has(idx[t + 1]) and is_part.has(idx[t + 2])):
			continue
		var n := (pos[idx[t + 1]] - pos[idx[t]]).cross(pos[idx[t + 2]] - pos[idx[t]])
		if first == Vector3.ZERO:
			first = n
		face += n if n.dot(first) >= 0.0 else -n
	if face == Vector3.ZERO:
		return null
	face = face.normalized()
	# the boss side is the one that reaches further from the middle
	var up := -INF
	var down := INF
	for v: int in ids:
		var h := (pos[v] - centre).dot(face)
		up = maxf(up, h)
		down = minf(down, h)
	if -down > up:
		face = -face
	var turn := Basis(Quaternion(face, Vector3.UP))
	var remap := {}
	var out_pos := PackedVector3Array()
	var out_nor := PackedVector3Array()
	var out_uv := PackedVector2Array()
	var out_idx := PackedInt32Array()
	for t in range(0, idx.size(), 3):
		if not (is_part.has(idx[t]) and is_part.has(idx[t + 1]) and is_part.has(idx[t + 2])):
			continue
		for k in 3:
			var v := idx[t + k]
			if not remap.has(v):
				remap[v] = out_pos.size()
				out_pos.append(turn * (pos[v] - centre))
				out_nor.append(turn * nor[v])
				out_uv.append(uv[v])
			out_idx.append(remap[v])
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = out_pos
	out[Mesh.ARRAY_NORMAL] = out_nor
	out[Mesh.ARRAY_TEX_UV] = out_uv
	out[Mesh.ARRAY_INDEX] = out_idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out)
	return mesh


## Half the thickness of a built shield (m, model scale): how high it lies off the floor.
static func half_height(mesh: ArrayMesh) -> float:
	return mesh.get_aabb().size.y * 0.5


## The shield's turn `t` seconds into a flight of `total`: it spins about the vertical, tipped over at the throw and flat
## on landing (k = 1), so it comes down lying face up.
static func flight_basis(t: float, total: float) -> Basis:
	var k := clampf(t / maxf(total, 0.001), 0.0, 1.0)
	return Basis(Vector3.UP, SPIN * minf(t, total)) * Basis(Vector3.RIGHT, TIP * (1.0 - k) * (1.0 - k))


## Its height in the arc (m over `lift`): the arc of C1eMarks, 0 at both ends.
static func arc(k: float, peak: float) -> float:
	return sin(clampf(k, 0.0, 1.0) * PI) * peak


## The material: the model's own painting, a little self-lit so it reads in the dark as the crowd does.
static func material(baked: BakedModel) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = baked.albedo
	m.roughness = 0.65
	m.metallic = 0.15
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.emission_enabled = true
	m.emission_texture = baked.albedo
	m.emission_energy_multiplier = 0.35
	return m
