class_name HallLife
extends RefCounted
## C-3 (AD2-08): the first hall's floor, lived on (stylized look only; nothing here collides or stands over 0.1 m): cracks,
## smudges of dust, a few slabs broken or half sunk, small rubble (the green stain of the old portal is gone, SL-01). Built on
## `kit.styled()` and floor_decal.gdshader's kinds 5 (a wet run) and 6; its own seed, so the run is the same.
## Everything keeps off the fight's middle (CENTRE_FREE m round the middle of the room), and the red warnings stay over it
## (the decals' alpha is under 0.9 and they lie under the warnings' priority).

const DECAL := preload("res://assets/shaders/floor_decal.gdshader")
const SEED := 3109
## The decals' height over the slabs (above the rugs' and the trails', under the warnings).
const Y := 0.01
## The cracks: how many, their length (m) and width, how far each leg runs, the colour.
const CRACKS := 4
const CRACK_LENGTH := Vector2(2.4, 4.8)
const CRACK_WIDTH := 0.13
const CRACK_LEG := Vector2(0.4, 0.9)
const CRACK_COLOR := Color(0.015, 0.016, 0.022)
## The dust: smudges (how many, their width m, length m), the colour of the dirt.
const DUST := 5
const DUST_WIDTH := Vector2(0.9, 1.6)
const DUST_LENGTH := Vector2(1.5, 3.0)
const DUST_COLOR := Color(0.07, 0.075, 0.085)
const DUST_ALPHA := 0.55
## The fight's middle, kept clear of cracks and loose stones: its centre and radius (m).
const CENTRE := CatacombHall.MIDDLE_AT
const CENTRE_FREE := 4.0
## Where decals may lie (the hall's floor, less its edge) and where loose pieces may (less the dais' stairs).
const FIELD := Rect2(-12.5, -11.5, 25.0, 23.0)
## The slabs broken or half sunk: their x, z, yaw (degrees), tilt (degrees, about x then z), the kind (size x, z).
const SLABS: Array[Vector4] = [Vector4(7.6, 4.6, 24.0, 4.0), Vector4(-6.5, 9.0, -12.0, -3.0), Vector4(10.6, -5.8, 70.0, 3.5)]
const SLAB_SIZE := Vector3(1.3, 0.12, 1.1)
const SLAB_SINK := 0.075
## The rubble: heaps (x, z), pieces in each, how far they spread and their size (m, under the knee).
const HEAPS: Array[Vector2] = [Vector2(7.6, 4.6), Vector2(-5.5, 8.8), Vector2(3.5, 10.0), Vector2(-2.0, -8.5)]
const HEAP_PIECES := 5
const HEAP_SPREAD := 0.9
const HEAP_SIZE := Vector2(0.06, 0.16)


static func dress(parent: Node3D, sty: Masonry) -> void:
	var node := Node3D.new()
	node.name = "HallLife"
	parent.add_child(node)
	ArenaKit.style_only(node)
	var r := RandomNumberGenerator.new()
	r.seed = SEED
	for i in DUST:
		var at := _spot(r)
		var way := Vector2.from_angle(r.randf() * TAU) * r.randf_range(DUST_LENGTH.x, DUST_LENGTH.y) * 0.5
		node.add_child(CatacombHall.floor_strip(PackedVector2Array([at - way, at + way]), r.randf_range(DUST_WIDTH.x, DUST_WIDTH.y),
			Y + 0.001 * i, decal(DUST_COLOR, DUST_ALPHA), true))
	for i in CRACKS:
		node.add_child(CatacombHall.floor_strip(_crack(r), CRACK_WIDTH, Y + 0.004 + 0.001 * i, decal(CRACK_COLOR, 0.9), true))
	for s in SLABS:
		_slab(sty, s)
	for h in HEAPS:
		_heap(sty, h)


## SL-01: the stream's damp and moss (used by CatacombHall._ground), a wet stone and a grey-green.
const WATER_DAMP := Color(0.09, 0.085, 0.085)
const WATER_MOSS := Color(0.13, 0.17, 0.1)


## A wet-run decal's material (kind 5) in `color`.
static func decal(color: Color, alpha: float, moss := false) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = DECAL
	mat.set_shader_parameter(&"kind", 5)
	mat.set_shader_parameter(&"alpha", alpha)
	if moss:
		mat.set_shader_parameter(&"wet_moss", 1.0)
		mat.set_shader_parameter(&"moss", color)
	else:
		mat.set_shader_parameter(&"wet", color)
	return mat


## A spot on the floor outside the fight's middle.
static func _spot(r: RandomNumberGenerator) -> Vector2:
	var p := Vector2.ZERO
	for _t in 24:
		p = FIELD.position + Vector2(r.randf(), r.randf()) * FIELD.size
		if p.distance_to(CENTRE) > CENTRE_FREE:
			break
	return p


## A crack: a run of legs turning by a right angle or a diagonal, as a joint or a split in the slab does.
static func _crack(r: RandomNumberGenerator) -> PackedVector2Array:
	var p := _spot(r)
	var path := PackedVector2Array([p])
	var dir := Vector2.from_angle(float(r.randi_range(0, 7)) * PI * 0.25)
	var run := 0.0
	var total := r.randf_range(CRACK_LENGTH.x, CRACK_LENGTH.y)
	while run < total:
		var leg := r.randf_range(CRACK_LEG.x, CRACK_LEG.y)
		p += dir * leg
		path.append(p)
		run += leg
		dir = dir.rotated(r.randf_range(-0.8, 0.8))
	return path


## One slab broken or half sunk: a thick tile a touch under the floor's top, tilted (so one edge dips), with a chip off it.
static func _slab(sty: Masonry, s: Vector4) -> void:
	var yaw := deg_to_rad(s.z)
	var mi := sty.box(Vector3(s.x, SLAB_SIZE.y * 0.5 - SLAB_SINK, s.y), SLAB_SIZE, yaw, null, false)
	mi.rotate_object_local(Vector3.RIGHT, deg_to_rad(s.w))
	mi.rotate_object_local(Vector3.FORWARD, deg_to_rad(s.w * 0.6))
	var chip := Vector3(SLAB_SIZE.x * 0.4, SLAB_SIZE.y * 0.8, SLAB_SIZE.z * 0.35)
	sty.box(Vector3(s.x + 0.7, chip.y * 0.5 - 0.04, s.y - 0.5), chip, yaw + 0.7, null, false)


## A heap of small fallen pieces, each askew.
static func _heap(sty: Masonry, at: Vector2) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(at * 10.0))
	for _k in HEAP_PIECES:
		var size := Vector3(r.randf_range(HEAP_SIZE.x, HEAP_SIZE.y), r.randf_range(HEAP_SIZE.x, HEAP_SIZE.y) * 0.7, r.randf_range(HEAP_SIZE.x, HEAP_SIZE.y))
		var p := at + Vector2.from_angle(r.randf() * TAU) * r.randf_range(0.3, HEAP_SPREAD)
		sty.box(Vector3(p.x, size.y * 0.5 - 0.02, p.y), size, r.randf() * TAU, null, false)
