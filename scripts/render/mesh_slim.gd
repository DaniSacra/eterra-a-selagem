class_name MeshSlim
extends RefCounted
## Makes a heavy painted model light enough for the crowd (tools/bake.gd): the Meshy figures come with about 15
## thousand triangles and a texture cut into more than a thousand small islands, so the seams stop any simplifier
## long before the target. Here the mesh is welded by position (the seams go away), simplified, given smooth normals
## and a new atlas of few large charts, and the old painting is carried over to that atlas.
##
## Arrays are Mesh.ARRAY_* arrays of one indexed triangle surface; bones and weights (any count per vertex) are kept.
## unwrap needs the editor's build of Godot (xatlas), which is what runs the bake tools and the tests.

## Positions closer than this (meters) are one vertex.
const WELD := 0.00001
## The simplifier takes faces up to this many degrees apart as one smooth surface.
const SMOOTH_ANGLE := 60.0
## How far from the light surface the old painting is searched, along the normal, in shares of the model's size:
## first near, then farther where the simplifier moved the surface more.
const REACH := [0.012, 0.05]
## Texels around each chart filled with its edge colour, so that smaller mipmaps do not bleed the background in.
const BLEED := 12


## One vertex per position (seams of texture and of hard edges closed): VERTEX, INDEX and, when there, BONES and
## WEIGHTS. Normals and UVs are dropped (see smooth and unwrap). Triangles squeezed to a line are left out.
static func weld(arrays: Array) -> Array:
	var src_v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var src_i: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var skinned: bool = arrays[Mesh.ARRAY_BONES] != null
	var src_b: PackedInt32Array = arrays[Mesh.ARRAY_BONES] if skinned else PackedInt32Array()
	var src_w: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS] if skinned else PackedFloat32Array()
	var per := src_b.size() / maxi(src_v.size(), 1)
	var ids := {}
	var remap := PackedInt32Array()
	var verts := PackedVector3Array()
	var bones := PackedInt32Array()
	var weights := PackedFloat32Array()
	for i in src_v.size():
		var key := src_v[i].snappedf(WELD)
		if not ids.has(key):
			ids[key] = verts.size()
			verts.append(src_v[i])
			for k in per:
				bones.append(src_b[i * per + k])
				weights.append(src_w[i * per + k])
		remap.append(ids[key])
	var index := PackedInt32Array()
	for t in range(0, src_i.size(), 3):
		var a := remap[src_i[t]]
		var b := remap[src_i[t + 1]]
		var c := remap[src_i[t + 2]]
		if a != b and b != c and a != c:
			index.append(a)
			index.append(b)
			index.append(c)
	return _arrays(verts, index, bones, weights)


## The same surface with about `triangles` triangles, on vertices of the original (so skin weights stay true), the
## unused ones dropped: the level of the engine's own chain of simpler meshes (each about half the one before)
## nearest to that count. Meant for welded arrays: seams stop the simplifier. Normals, when given, guide it; the
## result has none (see smooth).
static func simplify(arrays: Array, triangles: int) -> Array:
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	if index.size() / 3 <= triangles:
		return arrays
	var plain := []
	plain.resize(Mesh.ARRAY_MAX)
	plain[Mesh.ARRAY_VERTEX] = arrays[Mesh.ARRAY_VERTEX]
	plain[Mesh.ARRAY_NORMAL] = arrays[Mesh.ARRAY_NORMAL]
	plain[Mesh.ARRAY_INDEX] = index
	var chain := ImporterMesh.new()
	chain.add_surface(Mesh.PRIMITIVE_TRIANGLES, plain)
	chain.generate_lods(SMOOTH_ANGLE, 0.0, [])
	var best := index
	for level in chain.get_surface_lod_count(0):
		var lod := chain.get_surface_lod_indices(0, level)
		if _apart(lod.size() / 3, triangles) < _apart(best.size() / 3, triangles):
			best = lod
	return _compact(arrays, best)


## How far a count is from the wanted one, the same for twice as many and for half.
static func _apart(count: int, wanted: int) -> float:
	return absf(log(maxf(count, 1.0) / maxf(wanted, 1.0)))


## Normals for a welded surface: each vertex takes the mean of its faces, the larger faces weighing more.
static func smooth(arrays: Array) -> Array:
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var normals := PackedVector3Array()
	normals.resize(verts.size())
	for t in range(0, index.size(), 3):
		# Godot's front faces wind clockwise
		var n := (verts[index[t + 2]] - verts[index[t]]).cross(verts[index[t + 1]] - verts[index[t]])
		for k in 3:
			normals[index[t + k]] += n
	for i in normals.size():
		normals[i] = normals[i].normalized() if normals[i].length_squared() > 0.0 else Vector3.UP
	var out := arrays.duplicate()
	out[Mesh.ARRAY_NORMAL] = normals
	return out


## A new texture layout of few large charts (xatlas), as TEX_UV. Vertices are split along the new seams, keeping
## their normals and skin. texel: meters of the surface per texel of the atlas it is meant for (it sets the gap
## between the charts).
static func unwrap(arrays: Array, texel: float) -> Array:
	var mesh := ArrayMesh.new()
	var src := arrays.duplicate()
	src[Mesh.ARRAY_TEX_UV] = null
	src[Mesh.ARRAY_TEX_UV2] = null
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, src)
	if mesh.lightmap_unwrap(Transform3D.IDENTITY, texel) != OK:
		push_error("MeshSlim.unwrap: no unwrapper in this build (run with the editor's Godot)")
		return []
	var out := mesh.surface_get_arrays(0)
	out[Mesh.ARRAY_TEX_UV] = out[Mesh.ARRAY_TEX_UV2]
	out[Mesh.ARRAY_TEX_UV2] = null
	out[Mesh.ARRAY_TANGENT] = null
	return out


## The painting of one model carried to another of the same shape: for every texel of `to` (its TEX_UV, normals
## needed), the colour of `image` where the surface of `from` (its TEX_UV) lies nearest along the normal. Returns a
## square RGB image of `size`, the charts bled into the gaps.
static func transfer(from: Array, image: Image, to: Array, size: int) -> Image:
	var src_v: PackedVector3Array = from[Mesh.ARRAY_VERTEX]
	var src_uv: PackedVector2Array = from[Mesh.ARRAY_TEX_UV]
	var src_i: PackedInt32Array = from[Mesh.ARRAY_INDEX]
	var faces := PackedVector3Array()
	faces.resize(src_i.size())
	var lo := Vector3.INF
	var hi := -Vector3.INF
	for k in src_i.size():
		var p := src_v[src_i[k]]
		faces[k] = p
		lo = lo.min(p)
		hi = hi.max(p)
	var old := TriangleMesh.new()
	old.create_from_faces(faces)
	var extent := (hi - lo).length()
	var paint := image.duplicate() as Image
	if paint.is_compressed():
		paint.decompress()
	paint.convert(Image.FORMAT_RGB8)
	var pw := paint.get_width()
	var ph := paint.get_height()
	var out := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	var filled := PackedByteArray()
	filled.resize(size * size)
	var dst_v: PackedVector3Array = to[Mesh.ARRAY_VERTEX]
	var dst_n: PackedVector3Array = to[Mesh.ARRAY_NORMAL]
	var dst_uv: PackedVector2Array = to[Mesh.ARRAY_TEX_UV]
	var dst_i: PackedInt32Array = to[Mesh.ARRAY_INDEX]
	for t in range(0, dst_i.size(), 3):
		var ia := dst_i[t]
		var ib := dst_i[t + 1]
		var ic := dst_i[t + 2]
		var a := dst_uv[ia] * size
		var b := dst_uv[ib] * size
		var c := dst_uv[ic] * size
		var area := (b - a).cross(c - a)
		if absf(area) < 0.000001:
			continue
		# half a texel around the triangle too: the charts' edges are sampled by the filter
		var x0 := maxi(int(floorf(minf(a.x, minf(b.x, c.x)) - 0.5)), 0)
		var x1 := mini(int(ceilf(maxf(a.x, maxf(b.x, c.x)) + 0.5)), size - 1)
		var y0 := maxi(int(floorf(minf(a.y, minf(b.y, c.y)) - 0.5)), 0)
		var y1 := mini(int(ceilf(maxf(a.y, maxf(b.y, c.y)) + 0.5)), size - 1)
		var slack := 0.75 / sqrt(absf(area))
		for y in range(y0, y1 + 1):
			for x in range(x0, x1 + 1):
				var q := Vector2(x + 0.5, y + 0.5)
				var wa := (b - q).cross(c - q) / area
				var wb := (c - q).cross(a - q) / area
				var wc := 1.0 - wa - wb
				if wa < -slack or wb < -slack or wc < -slack:
					continue
				var inside := wa >= 0.0 and wb >= 0.0 and wc >= 0.0
				var at := x + y * size
				# a texel just outside its triangle never replaces one that is inside another
				if filled[at] == 2 or (filled[at] == 1 and not inside):
					continue
				var p := dst_v[ia] * wa + dst_v[ib] * wb + dst_v[ic] * wc
				var n := (dst_n[ia] * wa + dst_n[ib] * wb + dst_n[ic] * wc).normalized()
				for reach: float in REACH:
					var hit := old.intersect_segment(p + n * extent * reach, p - n * extent * reach)
					if hit.is_empty():
						continue
					var f: int = hit.face_index * 3
					var w := Geometry3D.get_triangle_barycentric_coords(hit.position, faces[f], faces[f + 1], faces[f + 2])
					var uv := src_uv[src_i[f]] * w.x + src_uv[src_i[f + 1]] * w.y + src_uv[src_i[f + 2]] * w.z
					out.set_pixel(x, y, paint.get_pixel(clampi(int(fposmod(uv.x, 1.0) * pw), 0, pw - 1), clampi(int(fposmod(uv.y, 1.0) * ph), 0, ph - 1)))
					filled[at] = 2 if inside else 1
					break
	_bleed(out, filled, size)
	return out


## Welded, simplified to about `triangles` (see simplify), smoothed, unwrapped and repainted:
## [arrays, image of `size`].
static func slim(arrays: Array, image: Image, triangles: int, size: int) -> Array:
	var light := smooth(simplify(smooth(weld(arrays)), triangles))
	var verts: PackedVector3Array = light[Mesh.ARRAY_VERTEX]
	var index: PackedInt32Array = light[Mesh.ARRAY_INDEX]
	var area := 0.0
	for t in range(0, index.size(), 3):
		area += (verts[index[t + 1]] - verts[index[t]]).cross(verts[index[t + 2]] - verts[index[t]]).length() * 0.5
	# the atlas fills about two thirds of the square
	var flat := unwrap(light, sqrt(area / (size * size * 0.66)))
	if flat.is_empty():
		return []
	return [flat, transfer(arrays, image, flat, size)]


static func triangles(arrays: Array) -> int:
	return (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3


## Grows the painted texels into the empty ones around them, BLEED texels far; what is still empty takes the mean
## colour of the painting.
static func _bleed(image: Image, filled: PackedByteArray, size: int) -> void:
	var edge: Array[int] = []
	var sum := Vector3.ZERO
	var count := 0
	for at in size * size:
		if filled[at] > 0:
			edge.append(at)
			var c := image.get_pixel(at % size, at / size)
			sum += Vector3(c.r, c.g, c.b)
			count += 1
	for pass_i in BLEED:
		var next: Array[int] = []
		for at in edge:
			var x := at % size
			var y := at / size
			var c := image.get_pixel(x, y)
			for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx := x + d.x
				var ny := y + d.y
				if nx < 0 or ny < 0 or nx >= size or ny >= size or filled[nx + ny * size] > 0:
					continue
				filled[nx + ny * size] = 1
				image.set_pixel(nx, ny, c)
				next.append(nx + ny * size)
		edge = next
	var mean := sum / maxf(count, 1.0)
	for at in size * size:
		if filled[at] == 0:
			image.set_pixel(at % size, at / size, Color(mean.x, mean.y, mean.z))


## The vertices that `index` uses, in a new surface (same attributes).
static func _compact(arrays: Array, index: PackedInt32Array) -> Array:
	var src_v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var skinned: bool = arrays[Mesh.ARRAY_BONES] != null
	var src_b: PackedInt32Array = arrays[Mesh.ARRAY_BONES] if skinned else PackedInt32Array()
	var src_w: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS] if skinned else PackedFloat32Array()
	var per := src_b.size() / maxi(src_v.size(), 1)
	var remap := {}
	var verts := PackedVector3Array()
	var bones := PackedInt32Array()
	var weights := PackedFloat32Array()
	var out_i := PackedInt32Array()
	for i in index:
		if not remap.has(i):
			remap[i] = verts.size()
			verts.append(src_v[i])
			for k in per:
				bones.append(src_b[i * per + k])
				weights.append(src_w[i * per + k])
		out_i.append(remap[i])
	return _arrays(verts, out_i, bones, weights)


static func _arrays(verts: PackedVector3Array, index: PackedInt32Array, bones: PackedInt32Array, weights: PackedFloat32Array) -> Array:
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = verts
	out[Mesh.ARRAY_INDEX] = index
	if not bones.is_empty():
		out[Mesh.ARRAY_BONES] = bones
		out[Mesh.ARRAY_WEIGHTS] = weights
	return out
