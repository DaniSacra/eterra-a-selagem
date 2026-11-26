class_name Canal
extends RefCounted
## SL-01b: the stone-lined water channel of the first rooms, one piece for the Salao's river and the Antessala's stream a
## dash crosses (GapFloor), so both read as the same canal: dark wet damp round it, a low stone kerb on each bank (the
## water lies below its top: the channel reads sunken though the slabs are one flat plate), the water on top
## (shallow_water.gdshader, with its rim shadow and reflected streaks). Display only: nothing here collides; a kerb is
## KERB_HEIGHT m high and only the floor-level eye sees it as a step.

const WATER := preload("res://assets/shaders/shallow_water.gdshader")
## Heights over the slabs (m): the damp, the water, and a kerb's top. The water is a hair over the damp, both under the
## warnings' priority; the kerb stands KERB_HEIGHT over the slabs (a stone the paladin steps over).
const DAMP_Y := 0.012
const WATER_Y := 0.016
const KERB_HEIGHT := 0.11
## A kerb's width (m) and how much the stones vary in colour (a share of the stone's colour, per slab).
const KERB_WIDTH := 0.3
const KERB_SHADE := Vector2(0.72, 1.12)
## The damp bank as wide as the water, times this; the moss a little wider.
const BANK := 1.55
const MOSS_BANK := 2.1
const KERB_STONE := Color(0.26, 0.25, 0.235)
const KERB_SIDE := Color(0.17, 0.18, 0.20)
## Points of the smoothed line per segment of the given path.
const SMOOTH := 4
const SEED := 6203

static var _stone: StandardMaterial3D
static var _side: StandardMaterial3D


## The water's material: the hall's shallow stream's, with the warm light's reflection at `sheen_at`. `deep` darkens it
## (the stream no one wades), compat lowers the glints.
static func water(sheen_at: Vector2, deep := false, compat := false) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = WATER
	mat.set_shader_parameter(&"sheen_at", sheen_at)
	if deep:
		mat.set_shader_parameter(&"deep", Color(0.02, 0.05, 0.08))
		mat.set_shader_parameter(&"shallow", Color(0.07, 0.13, 0.17))
	if compat:
		mat.set_shader_parameter(&"glint", 0.25)
		mat.set_shader_parameter(&"sheen", 0.15)
		mat.set_shader_parameter(&"reflect_amount", 0.12)
	return mat


## A Catmull-Rom smoothing of a centreline (SMOOTH points a segment), with its widths swelling and narrowing between
## `range` (the widths' ends) as the line runs. Returns [line, widths].
static func smooth(points: Array[Vector2], range: Vector2) -> Array:
	var line := PackedVector2Array()
	var widths := PackedFloat32Array()
	for i in points.size() - 1:
		var p0 := points[maxi(i - 1, 0)]
		var p1 := points[i]
		var p2 := points[i + 1]
		var p3 := points[mini(i + 2, points.size() - 1)]
		for k in SMOOTH:
			var t := float(k) / SMOOTH
			line.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t
				+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t * t * t))
			var along := (float(i) + t) / float(points.size() - 1)
			widths.append(lerpf(range.x, range.y, 0.5 + 0.5 * sin(along * TAU * 1.5 + 0.6)))
	line.append(points[points.size() - 1])
	widths.append(range.x)
	return [line, widths]


## Dresses a channel along `line` (x, z; its widths per point) under `parent`: damp, moss, water and, when `kerb`, the
## stone on both banks, left open over each `fords` range (shares of the line's length: where the paladin wades across).
static func dress(parent: Node3D, line: PackedVector2Array, widths: PackedFloat32Array, mat: ShaderMaterial,
		kerb := true, fords: Array[Vector2] = []) -> void:
	var damp := HallLife.decal(HallLife.WATER_DAMP, 0.5)
	var moss := HallLife.decal(HallLife.WATER_MOSS, 0.6, true)
	var wide := PackedFloat32Array()
	var mossy := PackedFloat32Array()
	for w in widths:
		wide.append(w * BANK)
		mossy.append(w * MOSS_BANK)
	parent.add_child(CatacombHall.floor_strip(line, 1.0, DAMP_Y - 0.002, moss, false, mossy))
	parent.add_child(CatacombHall.floor_strip(line, 1.0, DAMP_Y, damp, false, wide))
	parent.add_child(CatacombHall.floor_strip(line, 1.0, WATER_Y, mat, false, widths))
	if kerb:
		parent.add_child(_kerb(line, widths, fords))


## The kerbs of both banks as one mesh with two surfaces: the stones' tops (each a slab a little darker or lighter) and
## the inner wall dropping to the water.
static func _kerb(line: PackedVector2Array, widths: PackedFloat32Array, fords: Array[Vector2]) -> MeshInstance3D:
	var top := SurfaceTool.new()
	top.begin(Mesh.PRIMITIVE_TRIANGLES)
	var wall := SurfaceTool.new()
	wall.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r := RandomNumberGenerator.new()
	r.seed = SEED
	var total := 0.0
	for i in range(1, line.size()):
		total += line[i - 1].distance_to(line[i])
	var run := 0.0
	for i in range(1, line.size()):
		var seg := line[i - 1].distance_to(line[i])
		var t := (run + seg * 0.5) / maxf(total, 0.001)
		run += seg
		var open := false
		for f in fords:
			open = open or (t >= f.x and t <= f.y)
		if open:
			continue
		for side: float in [-1.0, 1.0]:
			var shade := r.randf_range(KERB_SHADE.x, KERB_SHADE.y)
			var d0 := _across(line, i - 1) * side
			var d1 := _across(line, i) * side
			var in0 := line[i - 1] + d0 * widths[i - 1] * 0.5
			var in1 := line[i] + d1 * widths[i] * 0.5
			var out0 := in0 + d0 * KERB_WIDTH
			var out1 := in1 + d1 * KERB_WIDTH
			var c := Color(shade, shade, shade)
			_quad(top, _v(in0, KERB_HEIGHT), _v(in1, KERB_HEIGHT), _v(out1, KERB_HEIGHT), _v(out0, KERB_HEIGHT), Vector3.UP, c)
			var n := Vector3(-d0.x, 0.0, -d0.y)
			_quad(wall, _v(in0, WATER_Y), _v(in1, WATER_Y), _v(in1, KERB_HEIGHT), _v(in0, KERB_HEIGHT), n, Color.WHITE)
	var mesh := ArrayMesh.new()
	top.commit(mesh)
	wall.commit(mesh)
	mesh.surface_set_material(0, _stone_mat())
	mesh.surface_set_material(1, _side_mat())
	var mi := MeshInstance3D.new()
	mi.name = "CanalKerb"
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


static func _v(p: Vector2, y: float) -> Vector3:
	return Vector3(p.x, y, p.y)


## The unit across the line at point i (to its left).
static func _across(line: PackedVector2Array, i: int) -> Vector2:
	var d := (line[mini(i + 1, line.size() - 1)] - line[maxi(i - 1, 0)]).normalized()
	return Vector2(-d.y, d.x)


static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3, color: Color) -> void:
	st.set_color(color)
	st.set_normal(normal)
	for v: Vector3 in [a, b, c, a, c, d]:
		st.add_vertex(v)


static func _stone_mat() -> StandardMaterial3D:
	if _stone == null:
		_stone = StandardMaterial3D.new()
		_stone.albedo_color = KERB_STONE
		_stone.vertex_color_use_as_albedo = true
		_stone.roughness = 0.9
		_stone.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _stone


static func _side_mat() -> StandardMaterial3D:
	if _side == null:
		_side = StandardMaterial3D.new()
		_side.albedo_color = KERB_SIDE
		_side.roughness = 0.8
		_side.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _side
