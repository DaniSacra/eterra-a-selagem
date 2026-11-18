class_name SanctuaryLook
extends ArenaRoom
## The look of the Santuário Desmoronado (the crumbled sanctuary, E5 spec docs/art/e5_spec.md section 1): the nave of a
## church under the earth, its vault half fallen. Walls of 9 m on the north (four blind pointed windows with broken
## tracery, pilasters with the springing of the vault) and on the west beside the chancel; the chancel raised 0.6 m
## behind a low grille over the west edge (out of the walkable floor), with the altar, a great blind window, two banners
## with the lion and two hooded statues in niches, a fire bowl on each of the grille's end pillars; to the north-east the
## fallen vault in a heap (slabs, voussoirs, a piece of arch); south and east the walls cut at 0.9 m with gaps onto the
## dark. The floor the palest of the arenas: grey limestone. Light: shafts of moon from holes in the vault (two in A,
## one stronger in B), the chancel's fires and its candles. Variant B: the nave's floor gave way (a hole of the layout)
## onto a crypt 6 m below, its fallen drums and a faint candle down there, nothing violet. What blocks is the layout's
## (ArenaObstacle), drawn by ArenaRoom.piece; the chancel is drawn behind the west edge across from boss_spawn (where
## the guardian rises), so its place comes from the layout too.

## The walls: height (north, west, the chancel's), the north wall's blind windows (width, height, sill; their x avoid
## the doors and the corners), the pilasters on its face (x of each, width, depth) and the springing of the vault over
## each (blocks, rise, reach into the room).
const WALL_HEIGHT := 9.0
const WINDOW := Vector3(2.4, 5.0, 2.6)
const WINDOWS: Array[float] = [-17.5, -10.5, -1.0, 11.5]
const PILASTER := Vector2(0.8, 0.45)
const PILASTERS: Array[float] = [-21.0, -14.0, -7.0, 2.0, 13.0]
const SPRING := Vector3(3.0, 1.6, 1.7)
## The chancel (spec 1.1, 1.5): how deep behind the west edge, its width (along the edge, centred on boss_spawn), its
## floor this much over the nave's and this much lighter, the grille's end pillars (side, height) with their fire bowls,
## the altar (size, its gold band: height under its top, height), its distance from the edge, the great blind window
## (width, height, sill), the banners (top, size; at this share of the half width), the statues' niches (height of the
## figure; at this share of the half width).
const CHANCEL_DEEP := 5.5
const CHANCEL_WIDE := 13.2
const CHANCEL_RISE := 0.6
const CHANCEL_LIGHT := 1.1
const GRILLE_PILLAR := Vector2(0.75, 1.6)
## How far out of the west edge the grille's end pillars stand (spec 1.1: x -22.8; their fire bowls clear of the floor).
const GRILLE_OUT := 0.95
const ALTAR := Vector3(1.4, 1.3, 3.0)
const ALTAR_BAND := Vector2(0.28, 0.06)
const ALTAR_BACK := 3.0
const BIG_WINDOW := Vector3(3.0, 7.0, 1.2)
const BANNER_TOP := 7.6
const BANNER_SIZE := Vector2(1.2, 2.2)
const BANNER_AT := 0.62
const STATUE := 2.4
const STATUE_AT := 0.86
const NICHE := Vector3(1.5, 3.2, 0.7)
## The fallen vault over the north-east cut: blocks (count, size range), from LOW at the edge to HIGH by the walls, and
## a piece of fallen arch half buried in it (span, ring).
const HEAP := 60
const HEAP_BLOCK := Vector2(0.35, 1.3)
const HEAP_HEIGHT := Vector2(0.3, 4.0)
const HEAP_ARCH := Vector2(4.5, 0.6)
## The front: gaps in the south cut wall (from, to along it from its west end), blocks fallen in the south-west cut
## (count, top).
const SOUTH_GAPS: Array[Vector2] = [Vector2(3.5, 6.0), Vector2(19.0, 21.5), Vector2(30.5, 33.0)]
const SW_BLOCKS := 14
const SW_TOP := 0.9
## The way in (spec 1.4): stairs coming up from the east to the edge (z from, to), the gold sill.
const ENTRY := Vector2(0.0, 4.0)
const ENTRY_STEPS := 6
## Grave slabs in a row down the nave's middle (every SLAB_STEP m along x between SLAB_FROM and SLAB_TO), their size.
const SLAB := Vector2(0.9, 1.9)
const SLAB_STEP := 4.0
const SLAB_SPAN := Vector2(-14.0, 14.0)
const SLAB_STONE := 0.82
const SLAB_FRAME := 0.5
## Low rubble along the walls and round the drums (top at most 0.15 m; per meter of wall).
const RUBBLE := 0.5
const RUBBLE_SIZE := Vector2(0.12, 0.3)
## The stone (spec 1.5): columns and walls a step darker than the floor, a little warm.
const STONE := Color(1.0, 0.98, 0.95)
const WALL_TINT := 0.85
## The floor (spec 1.5): grey warm limestone, the palest of the arenas, almost no moss, no medallion.
const FLOOR := {
	&"unit": 1.2, &"stone_a": Color(0.31, 0.30, 0.29), &"stone_b": Color(0.41, 0.39, 0.37),
	&"joint_color": Color(0.10, 0.09, 0.09), &"moss_color": Color(0.30, 0.29, 0.28), &"petal_color": Color(0.31, 0.30, 0.29),
	&"missing": 0.06, &"cracked": 0.3, &"split2": 0.45, &"tinted": 0.15,
}
## The air (spec 1.5).
const AIR := {
	&"sky": Color(0.05, 0.055, 0.07), &"fog": Color(0.10, 0.11, 0.14), &"fog_depth": Vector2(50.0, 110.0),
	&"ambient": Color(0.34, 0.34, 0.36), &"ambient_gain": 1.0, &"moon": Color(0.70, 0.78, 0.92), &"moon_energy": 0.4,
	&"moon_shadow": false,
}
## The moon's shafts (spec 1.5): colour, energy (A; B the one stronger), cone, height, where they fall (A: both; B: the
## first), the dust over the hole in B.
const MOON := Color(0.70, 0.78, 0.92)
const MOON_ENERGY := 2.2
const MOON_ENERGY_B := 2.8
const MOON_CONE := 22.0
const MOON_HEIGHT := 16.0
const MOON_AT: Array[Vector2] = [Vector2(-9.0, 0.0), Vector2(9.0, 2.0)]
## A soft key over the nave (no shadow), cool grey, so the nave between the shafts reads (spec 1.5: about #3a3936).
const KEY := Color(0.82, 0.82, 0.86)
const KEY_ENERGY := 3.0
const KEY_HEIGHT := 12.0
const KEY_REACH := 34.0
const KEY_FALLOFF := 0.6
## The altar's candles (one group with shadow) and the chancel's fire bowls (with shadow); the north door's bowls without.
const ALTAR_CANDLES := 1.6
## The crypt under the nave's hole (B, spec 1.3): its floor this far down, the faint candle (energy, range) on the
## depths' layer only, the dust falling into it.
const UNDER := 6.0
const UNDER_LIGHT := Vector2(1.2, 8.0)
const UNDER_FLOOR := Color(0.55, 0.55, 0.55)

var _west := 0.0
var _east := 0.0
var _north := 0.0
var _south := 0.0
var _chancel := Vector2.ZERO
var _hole := PackedVector2Array()


func floor_look() -> Dictionary:
	return FLOOR


func stone_tint() -> Color:
	return STONE


func air() -> Dictionary:
	return AIR


## The north door (X1) and the west one (X3) open in the walls; the south one goes down between cheeks.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5 or layout.exits[i].inward.x > 0.5


## No cliffs round the room: its walls are drawn in dress. The hole of B has a sunk broken lip, with the gold thread on
## the faces turned to the camera.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		cliff(a, b, out, faces, EXIT_STEPS * EXIT_RISE + 0.6)
	elif kind == Edge.HOLE:
		# C18 (ENV P1-3): the Rift's sunk lip (broken_lip, every chunk under the floor): the broken edge's slabs at the
		# floor's height read as floor 0.4 m and more past where the paladin stops
		broken_lip(a, b, out, faces)
		var yaw := deg_to_rad(Feel.live().cam_yaw)
		if out.dot(Vector2(sin(yaw), cos(yaw))) < -0.2:
			filet(a, b, out)


## No abyss: a closed church. In B, the crypt seen through the hole.
func _abyss() -> void:
	for h in layout.floor.holes:
		_hole = h
		_under(h)


## The north door's fire bowls stand in the wall without shadows (the chancel's and the moon's cast them, spec 1.5).
func piece(o: ArenaObstacle) -> void:
	if o.piece == &"brazier":
		kit.brazier(o.center, 0.0, false).shadow_enabled = false
		return
	if o.piece == &"column" and o.height >= WHOLE_COLUMN:
		# the nave's columns in three silhouettes, some snapped (C18, ART P1-5)
		round_column(o, true)
		return
	super.piece(o)


## The far walls' fill (ArenaRoom.wall_fill, C18): its colour and energy.
const WALL_FILL_COLOR := Color(0.78, 0.8, 0.88)
const WALL_FILL_ENERGY := 0.5


func dress() -> void:
	wall_fill(WALL_FILL_COLOR, WALL_FILL_ENERGY)
	var box := layout.floor.bounds()
	_west = box.position.x
	_east = box.end.x
	_north = box.position.y
	_south = box.end.y
	_chancel = Vector2(_west, layout.boss_spawn.y)
	_north_wall()
	_west_wall()
	_chancel_dress()
	_heap()
	_front()
	_entry()
	_slabs()
	_rubble()
	_candles()
	var key := key_light(KEY, KEY_ENERGY, KEY_HEIGHT)
	key.omni_range = KEY_REACH
	key.omni_attenuation = KEY_FALLOFF
	if _hole.is_empty():
		for p in MOON_AT:
			moon_shaft(p, MOON, MOON_ENERGY, MOON_CONE, MOON_HEIGHT)
	else:
		moon_shaft(MOON_AT[0], MOON, MOON_ENERGY_B, MOON_CONE, MOON_HEIGHT)
		var c := _middle(_hole)
		arena._dust(Vector3(c.x, 0.0, c.y))


# ---------- the walls ----------

## The north wall from the west corner to the cut: pilasters with the vault springing from them, the blind windows,
## the doors in it and the recesses of the fire bowls of the layout.
func _north_wall() -> void:
	var cut := _corner_x()
	var a := Vector2(_west - FACE_SET - FACE_THICK, _north)
	var b := Vector2(cut + 0.6, _north)
	var openings: Array[Vector4] = []
	for i in layout.exits.size():
		var e := layout.exits[i]
		if e.inward.y > 0.5:
			var w := absf(e.mouth.size.x)
			var s := e.mouth.get_center().x - a.x
			openings.append(Vector4(s - w * 0.5 - JAMB, s + w * 0.5 + JAMB, 0.0, WALL_DOOR.y + 0.4))
	var recesses: Array[Vector2] = []
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			var s := o.center.x - a.x
			openings.append(Vector4(s - 0.75, s + 0.75, 0.0, 3.2))
			recesses.append(Vector2(s - 0.75, s + 0.75))
	var mat := m.ashlar(0.0, STONE * WALL_TINT)
	wall(a, b, Vector2(0, -1), WALL_HEIGHT, openings, mat)
	for r in recesses:
		wall_part(a, b, Vector2(0, -1), r.x, r.y, FACE_SET + 1.25, FACE_SET + FACE_THICK, 0.0, 3.2, mat)
	for i in layout.exits.size():
		if layout.exits[i].inward.y > 0.5:
			var e := layout.exits[i]
			door_arch(Vector2(e.mouth.get_center().x, _north), Vector2(0, 1), absf(e.mouth.size.x), FACE_SET + 0.45)
	for x in PILASTERS:
		var foot := Vector3(x, 0.0, _north - FACE_SET + PILASTER.y * 0.5)
		m.block(foot, Vector3(PILASTER.x, WALL_HEIGHT - 1.4, PILASTER.y), 0.0, mat)
		_springing(Vector3(x, WALL_HEIGHT - 1.4, _north - FACE_SET + PILASTER.y), Vector3(0, 0, 1), mat)
	for x in WINDOWS:
		blind_window(Vector3(x, WINDOW.z, _north - FACE_SET), Vector2(0, 1), WINDOW.x, WINDOW.y, mat)


## The west wall: from the south-west cut to the chancel and from the chancel to the north corner, with its door.
func _west_wall() -> void:
	var mat := m.ashlar(0.0, STONE * WALL_TINT)
	var z0 := _chancel.y - CHANCEL_WIDE * 0.5
	var z1 := _chancel.y + CHANCEL_WIDE * 0.5
	var south := _west_south()
	for run: Vector2 in [Vector2(_north - FACE_SET - FACE_THICK, z0), Vector2(z1, south)]:
		if run.y - run.x < 0.2:
			continue
		var a := Vector2(_west, run.y)
		var b := Vector2(_west, run.x)
		var openings: Array[Vector4] = []
		for e in layout.exits:
			if e.inward.x > 0.5:
				var s := run.y - e.mouth.get_center().y
				var w := absf(e.mouth.size.y)
				if s > 0.0 and s < run.y - run.x:
					openings.append(Vector4(s - w * 0.5 - JAMB, s + w * 0.5 + JAMB, 0.0, WALL_DOOR.y + 0.4))
		wall(a, b, Vector2(-1, 0), WALL_HEIGHT, openings, mat)
	for e in layout.exits:
		if e.inward.x > 0.5:
			door_arch(Vector2(_west, e.mouth.get_center().y), Vector2(1, 0), absf(e.mouth.size.y), FACE_SET + 0.45)
	for z: float in [z0 - PILASTER.x * 0.5, z1 + PILASTER.x * 0.5]:
		m.block(Vector3(_west - FACE_SET + PILASTER.y * 0.5, 0.0, z), Vector3(PILASTER.y, WALL_HEIGHT - 1.4, PILASTER.x), 0.0, mat)
		_springing(Vector3(_west - FACE_SET + PILASTER.y, WALL_HEIGHT - 1.4, z), Vector3(1, 0, 0), mat)


## The springing of the vault from the top of a pilaster: blocks climbing and leaning out into the room along `into`.
func _springing(top: Vector3, into: Vector3, mat: Material) -> void:
	var yaw := atan2(-into.z, into.x)
	for k in 3:
		var t := (k + 0.5) / 3.0
		var vo := m.box(top + into * SPRING.z * t * t + Vector3(0, SPRING.y * t, 0), Vector3(0.7, SPRING.y / 3.0 + 0.1, 0.9), yaw, mat, false)
		vo.rotate_object_local(Vector3.BACK, 0.5 * t)


# ---------- the chancel ----------

## The chancel behind the grille (spec 1.1, 1.5): its raised floor out of the walkable one, the grille on the west edge
## with its two end pillars and fire bowls, the altar with its gold band and candles, the great blind window behind,
## the banners with the lion and the hooded statues in niches; its own walls.
func _chancel_dress() -> void:
	var x0 := _west - BALUSTRADE_OUT - 0.25
	var x1 := _west - CHANCEL_DEEP
	var z0 := _chancel.y - CHANCEL_WIDE * 0.5
	var z1 := _chancel.y + CHANCEL_WIDE * 0.5
	var floor_mat := kit.floor_material(0.0, Vector2.ZERO, 6.0)
	for k in FLOOR:
		floor_mat.set_shader_parameter(k, FLOOR[k] * CHANCEL_LIGHT if FLOOR[k] is Color else FLOOR[k])
	m.prism(rect_poly(x1 - 0.2, x0, z0, z1), -0.6, CHANCEL_RISE, floor_mat)
	# the riser under the grille, the grille itself (the walkable edge), its end pillars and their fire bowls
	m.block(Vector3(_west - BALUSTRADE_OUT * 0.5 - 0.12, -0.6, _chancel.y), Vector3(BALUSTRADE_OUT + 0.25, 0.6, CHANCEL_WIDE), 0.0, ashlar())
	var gx := _west + BALUSTRADE_OUT * 0.3 - BALUSTRADE_OUT
	m.balustrade(Vector3(gx, 0.0, z0 + 0.6), Vector3(gx, 0.0, z1 - 0.6), true, see(stone()))
	for z: float in [z0 + 0.6 - GRILLE_PILLAR.x * 0.4, z1 - 0.6 + GRILLE_PILLAR.x * 0.4]:
		var p := Vector2(_west - GRILLE_OUT, z)
		m.block(Vector3(p.x, 0.0, p.y), Vector3(GRILLE_PILLAR.x, GRILLE_PILLAR.y, GRILLE_PILLAR.x), 0.0, ashlar())
		kit.brazier(p, GRILLE_PILLAR.y - ArenaKit.BRAZIER_PEDESTAL - Masonry.POST_STEP.y - Masonry.POST_CAP.y, false)
	# the walls of the chancel: its back and two sides
	var mat := m.ashlar(0.0, STONE * WALL_TINT)
	var back := x1 - 0.2
	wall(Vector2(back, z1 + 1.0), Vector2(back, z0 - 1.0), Vector2(-1, 0), WALL_HEIGHT, [], mat)
	wall(Vector2(_west - FACE_SET, z0), Vector2(back - FACE_SET, z0), Vector2(0, -1), WALL_HEIGHT, [], mat, 0.8)
	wall(Vector2(back - FACE_SET, z1), Vector2(_west - FACE_SET, z1), Vector2(0, 1), WALL_HEIGHT, [], mat, 0.8)
	blind_window(Vector3(back - FACE_SET, CHANCEL_RISE + BIG_WINDOW.z, _chancel.y), Vector2(1, 0), BIG_WINDOW.x, BIG_WINDOW.y, mat)
	# the altar: a chamfered block, its plain front with a band of old gold (no shine), candles on it
	var altar_x := back - FACE_SET - ALTAR_BACK + ALTAR.x * 0.5 + 1.2
	var foot := Vector3(altar_x, CHANCEL_RISE, _chancel.y)
	m.block(foot, Vector3(ALTAR.x + 0.4, 0.15, ALTAR.z + 0.4), 0.0, stone())
	m.block(foot + Vector3(0, 0.15, 0), Vector3(ALTAR.x, ALTAR.y - 0.15, ALTAR.z), 0.0, m.stone(0.0, STONE * 1.1))
	tomb.bar(foot + Vector3(ALTAR.x * 0.5 + 0.005, ALTAR.y - ALTAR_BAND.x, 0), Vector3(0.012, ALTAR_BAND.y, ALTAR.z - 0.1), 0.0, tomb.gold())
	candle_line(foot + Vector3(-0.2, ALTAR.y, -ALTAR.z * 0.4), foot + Vector3(-0.2, ALTAR.y, ALTAR.z * 0.4), 5)
	warm_light(foot + Vector3(0.8, ALTAR.y + 0.8, 0), ALTAR_CANDLES, true, 4.0)
	for sd: float in [-1.0, 1.0]:
		candle_line(Vector3(x0 - 0.6, CHANCEL_RISE, _chancel.y + sd * 1.8), Vector3(x0 - 0.6, CHANCEL_RISE, _chancel.y + sd * 2.6), 3)
	# the banners and the statues in their niches, on the back wall
	var face := back - FACE_SET
	for sd: float in [-1.0, 1.0]:
		var bz := _chancel.y + sd * CHANCEL_WIDE * 0.5 * BANNER_AT
		kit.banner(Vector3(face + 0.06, BANNER_TOP, bz), PI * 0.5, BANNER_SIZE, 1, ArenaKit.Emblem.LION)
		var sz := _chancel.y + sd * CHANCEL_WIDE * 0.5 * STATUE_AT
		var floor_mid := tomb.niche(Vector3(face, CHANCEL_RISE, sz), Vector2(1, 0), NICHE.x, NICHE.y, NICHE.z, mat, m.stone(0.0, WINDOW_PANEL), mat, false)
		kit.statue(Vector2(floor_mid.x, floor_mid.z), PI * 0.5, STATUE, floor_mid.y, ArenaKit.STATUE_VALUE, false)


# ---------- the fallen vault, the front, the way in ----------

## The heap of the fallen vault over the north-east cut (spec 1.1): blocks from HEAP_HEIGHT.x at the edge to .y by the
## walls, a mound under them, a piece of an arch half buried; its foot is the edge (nothing on the floor).
func _heap() -> void:
	var cut := _cut_edge(Vector2(1, -1))
	if cut.is_empty():
		return
	var p: Vector2 = cut[0]
	var q: Vector2 = cut[1]
	var along := (q - p).normalized()
	var out := Vector2(along.y, -along.x)
	if layout.floor.covers((p + q) * 0.5 + out * 0.3):
		out = -out
	var corner := Vector2(maxf(p.x, q.x), minf(p.y, q.y))
	var reach := (corner - p).dot(out)
	var r := RandomNumberGenerator.new()
	r.seed = 5531
	var mat := m.ashlar(0.0, STONE * WALL_TINT)
	var off := out * 0.4
	m.prism(PackedVector2Array([p + off, q + off, corner + Vector2(2.0, -2.0)]), -0.3, HEAP_HEIGHT.y * 0.45, m.stone(0.0, STONE * 0.45))
	# the walls run on behind the heap to the corner
	wall(Vector2(p.x - 0.2, _north), Vector2(corner.x + 3.0, _north), Vector2(0, -1), WALL_HEIGHT, [], mat)
	wall(Vector2(_east, corner.y - 3.0), Vector2(_east, q.y + 0.2), Vector2(1, 0), WALL_HEIGHT * 0.45, [], mat)
	for k in HEAP:
		var size := r.randf_range(HEAP_BLOCK.x, HEAP_BLOCK.y)
		var d := r.randf_range(size * 0.75 + 0.05, reach + 1.5)
		var c := p + along * r.randf_range(0.0, p.distance_to(q)) + out * d
		var h := lerpf(HEAP_HEIGHT.x, HEAP_HEIGHT.y, clampf(d / (reach + 1.5), 0.0, 1.0))
		var blk := m.box(Vector3(c.x, h - size * 0.4, c.y), Vector3(size, size * 0.45, size * 0.9), r.randf() * TAU, mat)
		blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.5, 0.5))
		blk.rotate_object_local(Vector3.BACK, r.randf_range(-0.4, 0.4))
	var mid := (p + q) * 0.5 + out * (reach * 0.55)
	var arch_foot := Vector3(mid.x, HEAP_HEIGHT.y * 0.2, mid.y)
	m.voussoir_arch(arch_foot, along.rotated(0.4), HEAP_ARCH.x, -1.2, HEAP_ARCH.y, 0.9, mat)


## The front (spec 1.1): the south wall cut at 0.9 m with its gaps onto the dark and the doors' gaps, the east one north
## and south of the way in, the blocks fallen in the south-west cut.
func _front() -> void:
	var south_a := Vector2(_west_south_x(), _south)
	var south_b := Vector2(_east + CUT_WALL.y, _south)
	var gaps := door_gaps(south_a, south_b, Vector2(0, 1))
	gaps.append_array(SOUTH_GAPS)
	cut_wall(south_a, south_b, Vector2(0, 1), gaps)
	var cut := _cut_edge(Vector2(1, 1))
	var east_from := _north if cut.is_empty() else maxf(cut[0].y, cut[1].y)
	var east_a := Vector2(_east, _south)
	var east_b := Vector2(_east, east_from)
	var east_gaps := door_gaps(east_a, east_b, Vector2(1, 0))
	east_gaps.append(Vector2(_south - ENTRY.y - 0.3, _south - ENTRY.x + 0.3))
	cut_wall(east_a, east_b, Vector2(1, 0), east_gaps)
	# the south-west cut: low blocks fallen out of the wall there, never over 0.9 m, off the floor
	var sw := _cut_edge(Vector2(-1, 1))
	if sw.is_empty():
		return
	var p: Vector2 = sw[0]
	var q: Vector2 = sw[1]
	var out := Vector2(-1, 1).normalized()
	var r := RandomNumberGenerator.new()
	r.seed = 7710
	var mat := ashlar()
	for k in SW_BLOCKS:
		var size := r.randf_range(0.4, 0.9)
		var c := p.lerp(q, r.randf()) + out * r.randf_range(size * 0.6 + 0.1, 2.5)
		var blk := m.box(Vector3(c.x, minf(size * 0.3, SW_TOP - size * 0.3), c.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, mat)
		blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.3, 0.3))


## The way in (spec 1.4): stairs coming up from the east to the edge, posts beside them, the gold sill.
func _entry() -> void:
	var mid := (ENTRY.x + ENTRY.y) * 0.5
	var w := ENTRY.y - ENTRY.x
	m.block(Vector3(_east + 1.2, -0.62, mid), Vector3(2.4, 0.6, w), 0.0, stone(), false)
	m.stairs(Vector3(_east + 2.4 + 0.45 * ENTRY_STEPS, -0.02 - 0.2 * ENTRY_STEPS, mid), Vector2(-1, 0), w, ENTRY_STEPS, 0.2, 0.45)
	for sd: float in [-1.0, 1.0]:
		m.post(Vector3(_east + 0.5, 0.0, mid + sd * (w * 0.5 + 0.5)), 0.0, 1.1, stone())
	tomb.bar(Vector3(_east - 0.04, 0.004, mid), Vector3(0.05, 0.008, w), 0.0, tomb.gold())


# ---------- the floor's slabs, rubble and candles ----------

## Plain grave slabs in a row down the nave's middle (spec 1.2), where the floor is clear.
func _slabs() -> void:
	var st := m.stone(0.0, STONE * SLAB_STONE)
	var fr := m.stone(0.0, STONE * SLAB_FRAME)
	var z := layout.boss_spawn.y
	var x := SLAB_SPAN.x
	while x <= SLAB_SPAN.y + 0.01:
		var at := Vector2(x, z)
		if _clear(at, SLAB.length() * 0.6):
			tomb.slab(at, Vector2(SLAB.y, SLAB.x), 0.0, st, fr)
		x += SLAB_STEP


## Low rubble (top under 0.15 m) along the north wall's foot and round the drums of a fallen column.
func _rubble() -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 3307
	var mat := ashlar()
	var spots: Array[Vector2] = []
	var x := _west + 0.6
	while x < _corner_x() - 0.5:
		if r.randf() < RUBBLE:
			spots.append(Vector2(x, _north + r.randf_range(0.15, 0.6)))
		x += 1.0
	for o in layout.obstacles:
		if o.piece == &"drums":
			for k in 8:
				spots.append(o.center + Vector2.from_angle(r.randf() * TAU) * r.randf_range(0.9, 1.9))
	for p in spots:
		if not arena.shape().contains(p, 0.1) or not _clear(p, 0.3):
			continue
		var size := r.randf_range(RUBBLE_SIZE.x, RUBBLE_SIZE.y)
		m.box(Vector3(p.x, size * 0.2, p.y), Vector3(size, size * 0.4, size * 0.8), r.randf() * TAU, mat)


## Candles (spec 1.2): on the sarcophagi's lids and the bases of the back row of columns, plain (no light of their own).
func _candles() -> void:
	for o in layout.obstacles:
		if o.piece == &"sarcophagus":
			var long_x := o.half.x >= o.half.y
			var axis := Vector3(1, 0, 0) if long_x else Vector3(0, 0, 1)
			var end := Vector3(o.center.x, o.height, o.center.y) + axis * (maxf(o.half.x, o.half.y) - 0.35)
			candle_line(end - Vector3(axis.z, 0, axis.x) * 0.25, end + Vector3(axis.z, 0, axis.x) * 0.25, 3)
		elif o.piece == &"column" and o.center.y < 0.0:
			var foot := Vector3(o.center.x, TombKit.COLUMN_BASE, o.center.y)
			var toward := Vector3(0.57, 0, 0.82) * o.radius * 0.86
			candle_line(foot + toward.rotated(Vector3.UP, 0.6), foot + toward.rotated(Vector3.UP, -0.6), 2)


# ---------- the crypt under the hole (B) ----------

## What is seen through the hole of B (spec 1.3): 6 m down, the floor of a crypt, the drums and capitals of the
## columns that fell, a faint candle, the dust falling in. Only the depths' layer is lit by that candle.
func _under(h: PackedVector2Array) -> void:
	var c := _middle(h)
	var box := Rect2(h[0], Vector2.ZERO)
	for v in h:
		box = box.expand(v)
	box = box.grow(1.5)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	var floor_mat := kit.floor_material(0.0, Vector2.ZERO, 3.0)
	for k in FLOOR:
		floor_mat.set_shader_parameter(k, FLOOR[k] * UNDER_FLOOR.r if FLOOR[k] is Color else FLOOR[k])
	m.prism(rect_poly(box.position.x, box.end.x, box.position.y, box.end.y), -UNDER - 0.3, -UNDER, floor_mat)
	var r := RandomNumberGenerator.new()
	r.seed = 6619
	var mat := stone()
	for k in 7:
		var p := c + Vector2(r.randf_range(-box.size.x, box.size.x), r.randf_range(-box.size.y, box.size.y)) * 0.3
		var mi := m.shaft(Vector3(p.x, -UNDER, p.y), r.randf_range(0.42, 0.5), r.randf_range(0.8, 1.2), mat)
		mi.basis = Basis(Vector3.UP, r.randf() * TAU) * Basis(Vector3.RIGHT, PI * 0.5 + r.randf_range(-0.2, 0.2))
		mi.position = Vector3(p.x, -UNDER + 0.45, p.y)
	for k in 2:
		var p := c + Vector2(r.randf_range(-2.0, 2.0), r.randf_range(-1.5, 1.5))
		var cap := m.box(Vector3(p.x, -UNDER + 0.25, p.y), Vector3(1.3, 0.45, 1.3), r.randf() * TAU, mat)
		cap.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.3, 0.3))
	candle_line(Vector3(c.x - 1.5, -UNDER, c.y + 0.5), Vector3(c.x - 0.9, -UNDER, c.y + 0.9), 3)
	m.layers = 1
	var l := OmniLight3D.new()
	l.position = Vector3(c.x - 1.2, -UNDER + 1.0, c.y + 0.7)
	l.light_color = CANDLE_COLOR
	l.light_energy = UNDER_LIGHT.x
	l.omni_range = UNDER_LIGHT.y
	l.light_cull_mask = ArenaKit.DEPTH_LAYER
	add_child(l)


# ---------- reading the layout ----------

## The edge of the floor's outline that is cut across a corner on the side `toward` (x and z signs), or [] if none.
func _cut_edge(toward: Vector2) -> Array[Vector2]:
	var poly := layout.floor.polys[0]
	for i in poly.size():
		var a := poly[i]
		var c := poly[(i + 1) % poly.size()]
		if absf(a.x - c.x) > 0.5 and absf(a.y - c.y) > 0.5:
			var mid := (a + c) * 0.5 - layout.floor.bounds().get_center()
			if signf(mid.x) == signf(toward.x) and signf(mid.y) == signf(toward.y):
				return [a, c]
	return []


## Where the north wall stops (the north-east cut's west end), or the east side.
func _corner_x() -> float:
	var cut := _cut_edge(Vector2(1, -1))
	return _east if cut.is_empty() else minf(cut[0].x, cut[1].x)


## Where the west wall stops to the south (the south-west cut's north end), or the south side.
func _west_south() -> float:
	var cut := _cut_edge(Vector2(-1, 1))
	return _south if cut.is_empty() else minf(cut[0].y, cut[1].y)


## Where the south wall starts to the west (the south-west cut's east end), or the west side.
func _west_south_x() -> float:
	var cut := _cut_edge(Vector2(-1, 1))
	return _west - FACE_SET - FACE_THICK if cut.is_empty() else maxf(cut[0].x, cut[1].x)


func _middle(h: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for v in h:
		c += v
	return c / maxf(1.0, h.size())


## True when nothing of the layout that blocks stands within r of p, and p is on the floor.
func _clear(p: Vector2, r: float) -> bool:
	if not layout.floor.covers(p):
		return false
	for o in layout.obstacles:
		if o.blocks_move and o.depth(p, r) > 0.0:
			return false
	return true
