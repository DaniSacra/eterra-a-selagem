class_name CryptLook
extends ArenaRoom
## The look of the Cripta dos Esquecidos (the crypt of the forgotten), spec docs/art/cycle12_arenas_spec.md section 2:
## a small closed crypt, no abyss in sight. Walls of cut stone 6.5 m high on the north and west (the back of the
## picture) with funerary niches (shelves of pots and bones, or a hooded statue with empty hands), the door of X1 in an
## arch between two fire bowls in recesses and two banners with the lion over them, the way in through an arcade in
## the west wall with its gold sill; to the north-east a heap of fallen blocks; south and east (the front) the walls
## cut at 0.9 m like a model opened up, their section on top, their outer face dropping into the dark. Small cold
## slabs, plain grave slabs, candles in pools on the pieces (some burnt out in variant B), a single cold shaft of
## light from a crack in the vault over the tomb (A) or the dividing wall's end (B), its dust falling. What blocks is
## the layout's (ArenaObstacle), drawn by ArenaRoom.piece; this draws the rest and the air.

## The walls of the back: height, thickness, how far the face stands behind the floor's edge (a ledge fills it, LEDGE
## high), a string course and the cornice (height, how far out).
const WALL_HEIGHT := 6.5
const WALL_THICK := 1.4
const WALL_SET := 0.3
const LEDGE := 0.9
const COURSE := Vector2(3.6, 0.12)
const CORNICE := Vector2(0.3, 0.18)
## The walls of the front, cut: height, thickness, how far their outer face drops into the dark, the dark fill seen on
## their cut top (share of the thickness) and fallen blocks outside them (per meter).
const FRONT := Vector2(0.9, 0.8)
const FRONT_DROP := 3.0
const FRONT_FILL := 0.55
const FRONT_FALLEN := 0.25
## Funerary niches (width, height, depth into the wall), their sill on the ledge: on the north wall at these x, on the
## west at these z; those in STATUE_NICHES (by order: north then west) hold a hooded statue instead of shelves.
const NICHE := Vector3(1.7, 3.1, 0.9)
const NORTH_NICHES: Array[float] = [-8.5, -2.5]
const WEST_NICHES: Array[float] = [-7.5, 8.5]
const STATUE_NICHES: Array[int] = [1, 2]
const STATUE := 2.1
## The recess of a fire bowl beside the north door (width, height, depth behind the face).
const RECESS := Vector3(1.5, 3.2, 1.25)
## The arcade of the way in, in the west wall (z from, to), its stairs going up out of the room.
const ENTRY := Vector2(2.5, 6.5)
const ENTRY_STEPS := 6
## Banners with the lion over the fire bowls (their top, size).
const BANNER_TOP := 6.0
const BANNER_SIZE := Vector2(1.1, 2.4)
## The heap of fallen blocks in the north-east corner: blocks (count, size range), its height from the floor's edge
## (LOW) to the walls (HIGH).
const HEAP := 46
const HEAP_BLOCK := Vector2(0.35, 1.2)
const HEAP_HEIGHT := Vector2(0.3, 3.5)
## The stone: cut stone a step colder and darker than the floor (spec 2.5), the niches' dark, the bones' grey.
const STONE := Color(0.92, 0.95, 1.02)
const WALL_TINT := 0.9
const HOLLOW := Color(0.24, 0.2, 0.26)
const BONE := Color(1.6, 1.55, 1.4)
## Grave slabs in the floor (width, length), in rows north and south of the middle (x of each, z of the row).
const SLAB := Vector2(0.9, 1.9)
const SLAB_ROWS: Array[Vector3] = [Vector3(-9.0, -8.3, 0), Vector3(-3.2, -8.3, 0), Vector3(3.2, -8.3, 0),
	Vector3(-8.6, 8.3, 0), Vector3(0.6, 8.3, 0), Vector3(7.2, 8.3, 0)]
const SLAB_STONE := 0.8
const SLAB_FRAME := 0.4
## The dark sunk border round each grave slab (ART_REVIEW C-4: a step deeper, so they can be counted): how far it
## reaches past the slab, its height, its stone.
const SLAB_BORDER := Vector2(0.1, 0.006)
const SLAB_BORDER_TINT := 0.35
## The steps of the way in and of the doors (ART_REVIEW C-3: they read as planks, lighter than all round them): their
## stone in the value of the walls' cut stone.
const STAIR_TINT := 0.8
## The floor (spec 2.5): small cold slabs, a step lighter than the walls' cut stone so the fight's ground reads 45 to 60
## away from the candles (ENV-01: was 0.24 and 0.34, the fight's floor at 27 to 42).
const FLOOR := {
	&"unit": 0.8, &"stone_a": Color(0.31, 0.31, 0.36), &"stone_b": Color(0.44, 0.43, 0.49),
	&"joint_color": Color(0.08, 0.08, 0.1), &"moss_color": Color(0.22, 0.22, 0.25), &"petal_color": Color(0.24, 0.24, 0.28),
	&"missing": 0.08, &"cracked": 0.3,
}
## The air (spec 2.5): no sky, a dark brown-black, the ambient a little over half the hall's, no moon to speak of.
const AIR := {
	&"sky": Color(0.035, 0.03, 0.04), &"fog": Color(0.035, 0.03, 0.04), &"fog_depth": Vector2(40.0, 80.0),
	&"ambient": Color(0.32, 0.30, 0.30), &"ambient_gain": 0.95, &"moon": Color(0.5, 0.55, 0.65), &"moon_energy": 0.1,
	&"moon_shadow": false,
}
## The cold shaft from the vault: colour, energy, cone, how high it starts, how far off the plumb (toward the back).
const COLD := Color(0.62, 0.74, 0.9)
## (ART_REVIEW C-1: at 2.5 the great tomb's lid went near white; the shaft stays the frame's middle.)
const COLD_ENERGY := 1.6
## The great tomb's lid under the shaft: lighter than its stone by this much (ArenaRoom.SARC_LID_LIGHT is 1.5 for the
## other sarcophagi; under the shaft that went white, ART_REVIEW C-1).
const TOMB_LID_LIGHT := 1.0
const COLD_ANGLE := 18.0
const COLD_HEIGHT := 14.0
const COLD_LEAN := Vector2(-2.0, -2.5)
## The soft key over the middle (no shadow): its colour and energy (the pools of fire stay the brighter).
const KEY := Color(0.85, 0.78, 0.74)
## ENV-01: the key hangs higher (KEY_HEIGHT; the hall's is 9 m) and falls off slower (KEY_FALLOFF, its attenuation, was
## 1.0; KEY_REACH, its range, was 19 m), so its pool spreads flat over the whole floor of the fight instead of a bright
## middle and dark bays (the fight's floor was 27 to 42 away from the candles, the aim 45 to 60).
const KEY_ENERGY := 1.8
const KEY_HEIGHT := 11.0
const KEY_FALLOFF := 0.5
const KEY_REACH := 26.0
## ...and stands this far off the floor's middle (x, z), toward the west bays the candles leave dark.
const KEY_SHIFT := Vector2(-3.0, 2.5)
## The browser's renderer (Compatibility) leaves the crypt darker than the desktop (ART_REVIEW G-1): there the key and
## the ambient are this much stronger.
const COMPAT_KEY := 1.4
const COMPAT_AMBIENT := 1.4
## M-1 (QA-02): the fight's floor in the west and north bays, far from the candles and the key, read 19 to 34 (the aim
## 45 or more). A soft fill over them that lights the floor alone (ArenaRoom.FLOOR_LAYER; the walls stay as dark as
## they were) and casts no shadow: its colour (the key's), energy, height, reach, falloff and where it stands (x, z).
const FLOOR_FILL := Color(0.8, 0.76, 0.78)
const FLOOR_FILL_ENERGY := 1.8
const FLOOR_FILL_HEIGHT := 6.0
const FLOOR_FILL_REACH := 16.0
const FLOOR_FILL_FALLOFF := 0.6
const FLOOR_FILL_AT := Vector2(-9.0, -1.5)
## Candle lights with shadow (energy) and the plain ones (spec 2.5: at most 6 without shadow).
const CANDLE_SHADOW_ENERGY := 1.6
const CANDLE_PLAIN := 6
## A hooded statue's own light (energy, reach, cone).
const STATUE_GLOW := Vector3(1.4, 5.0, 40.0)

var _north := 0.0
var _west := 0.0
var _south := 0.0
var _east := 0.0
var _plain_lights := 0


func floor_look() -> Dictionary:
	return FLOOR


func floor_layers() -> int:
	return 1 | FLOOR_LAYER


func stone_tint() -> Color:
	return STONE


## True in the browser's renderer (Compatibility).
static func _compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"


func air() -> Dictionary:
	if not _compat():
		return AIR
	var a := AIR.duplicate()
	a[&"ambient_gain"] = float(AIR[&"ambient_gain"]) * COMPAT_AMBIENT
	return a


## The north door (X1) opens in the wall.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5


## No cliffs: the walls and the heap are drawn in dress; a door's mouth drops into the dark.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		cliff(a, b, out, faces, EXIT_STEPS * EXIT_RISE + 0.6)


## No abyss in a crypt.
func _abyss() -> void:
	pass


func dress() -> void:
	var b := layout.floor.polys[0]
	var box := Rect2(b[0], Vector2.ZERO)
	for p in b:
		box = box.expand(p)
	_north = box.position.y
	_west = box.position.x
	_south = box.end.y
	_east = box.end.x
	_back_walls()
	_front_walls()
	_heap()
	_entry()
	_slabs()
	_candles()
	_cold_shaft()
	var key := key_light(KEY, KEY_ENERGY * (COMPAT_KEY if _compat() else 1.0), KEY_HEIGHT)
	key.omni_attenuation = KEY_FALLOFF
	key.omni_range = KEY_REACH
	key.position += Vector3(KEY_SHIFT.x, 0.0, KEY_SHIFT.y)
	var fill := OmniLight3D.new()
	fill.position = Vector3(FLOOR_FILL_AT.x, FLOOR_FILL_HEIGHT, FLOOR_FILL_AT.y)
	fill.light_color = FLOOR_FILL
	fill.light_energy = FLOOR_FILL_ENERGY * (COMPAT_KEY if _compat() else 1.0)
	fill.omni_range = FLOOR_FILL_REACH
	fill.omni_attenuation = FLOOR_FILL_FALLOFF
	fill.light_cull_mask = FLOOR_LAYER
	add_child(fill)
	# the doors' stairs (ArenaRoom._doors) take Masonry's plain stone at their foot: this room's is darker
	var plain := m.stone(-EXIT_RISE * EXIT_STEPS)
	var dark := _stair_stone(-EXIT_RISE * EXIT_STEPS)
	for k: StringName in [&"stone_a", &"stone_b"]:
		plain.set_shader_parameter(k, dark.get_shader_parameter(k))


## The stone of the steps: Masonry's plain stone at their foot in the value of the walls (STAIR_TINT).
func _stair_stone(base_y: float) -> ShaderMaterial:
	return m.stone(base_y, STONE * STAIR_TINT)


## The great tomb (under the cold shaft) keeps its lid in the value of its stone; the other sarcophagi as ArenaRoom
## draws them.
func sarcophagus(o: ArenaObstacle) -> Vector3:
	var long_x := o.half.x >= o.half.y
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	if half.x * 2.0 < TOMB_FROM:
		return super.sarcophagus(o)
	var yaw := -o.yaw + (0.0 if long_x else PI * 0.5)
	var lid := m.stone(0.0, stone_tint() * TOMB_LID_LIGHT)
	var st := stone()
	var hollow := m.stone(0.0, stone_tint() * 0.6)
	if o.see_through:
		st = see(st)
		lid = see(lid)
		hollow = see(hollow)
	return tomb.tomb(o.center, half, yaw, o.height, st, lid, hollow)


## A whole column gets a round moulded capital and a curved springer (column_head); the rest as ArenaRoom draws it.
func piece(o: ArenaObstacle) -> void:
	if o.piece == &"column" and o.height >= WHOLE_COLUMN:
		round_column(o)
		return
	super.piece(o)


# ---------- the walls ----------

## The north and the west walls, with their openings: niches, the fire bowls' recesses, the north door, the arcade.
func _back_walls() -> void:
	var t := WALL_SET + WALL_THICK
	var north_a := Vector2(_west - t, _north)
	var north: Array[Vector4] = []
	var deep: Array[float] = []
	var niche_low := LEDGE
	var niche_high := LEDGE + NICHE.y - NICHE.x * 0.4
	for x in NORTH_NICHES:
		north.append(Vector4(x - north_a.x - NICHE.x * 0.5, x - north_a.x + NICHE.x * 0.5, niche_low, niche_high))
		deep.append(-1.0)
	for i in layout.exits.size():
		var e := layout.exits[i]
		if not in_wall(i):
			continue
		var w := absf(e.mouth.size.x)
		var cx := e.mouth.get_center().x - north_a.x
		north.append(Vector4(cx - w * 0.5 - JAMB, cx + w * 0.5 + JAMB, 0.0, WALL_DOOR.y + 0.4))
		deep.append(0.0)
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			var s := o.center.x - north_a.x
			north.append(Vector4(s - RECESS.x * 0.5, s + RECESS.x * 0.5, 0.0, RECESS.y))
			deep.append(RECESS.z)
	_wall(north_a, Vector2(_east + 1.2, _north), Vector2(0, -1), north, deep)
	var west_a := Vector2(_west, _south + FRONT.y)
	var west: Array[Vector4] = []
	var wdeep: Array[float] = []
	for z in WEST_NICHES:
		west.append(Vector4(west_a.y - z - NICHE.x * 0.5, west_a.y - z + NICHE.x * 0.5, niche_low, niche_high))
		wdeep.append(-1.0)
	west.append(Vector4(west_a.y - ENTRY.y - JAMB, west_a.y - ENTRY.x + JAMB, 0.0, WALL_DOOR.y + 0.4))
	wdeep.append(0.0)
	_wall(west_a, Vector2(_west, _north), Vector2(-1, 0), west, wdeep)
	# the niches themselves, their shelves or statues
	var mat := ashlar()
	var hollow := m.stone(0.0, HOLLOW)
	var bone := m.stone(0.0, BONE)
	var k := 0
	for x in NORTH_NICHES:
		_niche(Vector2(x, _north), Vector2(0, 1), STATUE_NICHES.has(k), mat, hollow, bone)
		k += 1
	for z in WEST_NICHES:
		_niche(Vector2(_west, z), Vector2(1, 0), STATUE_NICHES.has(k), mat, hollow, bone)
		k += 1
	# the arches of the north door, the banners with the lion over the fire bowls
	for i in layout.exits.size():
		var e := layout.exits[i]
		if in_wall(i):
			door_arch(Vector2(e.mouth.get_center().x, _north), Vector2(0, 1), absf(e.mouth.size.x), WALL_SET + 0.45)
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			kit.banner(Vector3(o.center.x, BANNER_TOP, _north - WALL_SET + 0.06), 0.0, BANNER_SIZE, 1, ArenaKit.Emblem.LION)


func _niche(at: Vector2, facing: Vector2, statue: bool, mat: Material, hollow: Material, bone: Material) -> void:
	var face := at - facing * WALL_SET
	var floor_mid := tomb.niche(Vector3(face.x, LEDGE, face.y), facing, NICHE.x, NICHE.y, NICHE.z, mat, hollow, bone, not statue)
	if not statue:
		return
	kit.statue(Vector2(floor_mid.x, floor_mid.z), atan2(facing.x, facing.y), STATUE, floor_mid.y, ArenaKit.STATUE_VALUE, false)
	var front := Vector3(floor_mid.x + facing.x * 2.5, LEDGE + STATUE + 1.0, floor_mid.z + facing.y * 2.5)
	kit.statue_glow(front, floor_mid + Vector3(0, STATUE * 0.6, 0), STATUE_GLOW.x, STATUE_GLOW.y, STATUE_GLOW.z)


## A wall along a to b, its face WALL_SET behind the floor's edge (out: away from the room) with a ledge LEDGE high in
## front, WALL_HEIGHT tall; openings (x, y: from and to along it from a; z, w: from and to in height) where there is no
## wall, each a recess `deep` behind the face (0: through; below 0: the niche fills it).
func _wall(a: Vector2, b: Vector2, out: Vector2, openings: Array[Vector4], deep: Array[float]) -> void:
	var mat := m.ashlar(0.0, STONE * WALL_TINT)
	var length := a.distance_to(b)
	var t0 := WALL_SET
	var t1 := WALL_SET + WALL_THICK
	# the stretches with no opening: the whole height
	var cuts: Array[Vector2] = []
	for o in openings:
		cuts.append(Vector2(o.x, o.y))
	cuts.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	var s := 0.0
	for c in cuts:
		if c.x > s:
			_part(a, b, out, s, c.x, t0, t1, 0.0, WALL_HEIGHT, mat)
			_part(a, b, out, s, c.x, 0.0, t0, 0.0, LEDGE, mat)
		s = maxf(s, c.y)
	if s < length:
		_part(a, b, out, s, length, t0, t1, 0.0, WALL_HEIGHT, mat)
		_part(a, b, out, s, length, 0.0, t0, 0.0, LEDGE, mat)
	# round each opening: under it, over it, its back
	for i in openings.size():
		var o := openings[i]
		if o.z > 0.0:
			_part(a, b, out, o.x, o.y, t0, t1, 0.0, o.z, mat)
			_part(a, b, out, o.x, o.y, 0.0, t0, 0.0, minf(o.z, LEDGE), mat)
		if o.w < WALL_HEIGHT:
			_part(a, b, out, o.x, o.y, t0, t1, o.w, WALL_HEIGHT, mat)
		if deep[i] > 0.0:
			_part(a, b, out, o.x, o.y, t0 + deep[i], t1, o.z, o.w, mat)
		elif deep[i] < 0.0:
			_part(a, b, out, o.x, o.y, t0 + NICHE.z, t1, o.z, o.w, mat)
	# a string course and the cornice, the whole length
	_part(a, b, out, 0.0, length, t0 - COURSE.y, t0, COURSE.x, COURSE.x + 0.22, mat)
	_part(a, b, out, 0.0, length, t0 - CORNICE.y, t1, WALL_HEIGHT - CORNICE.x, WALL_HEIGHT, mat)


## One block of a wall: from s0 to s1 along a to b, from d0 to d1 out of the edge, from y0 to y1.
func _part(a: Vector2, b: Vector2, out: Vector2, s0: float, s1: float, d0: float, d1: float, y0: float, y1: float, mat: Material) -> void:
	if s1 - s0 < 0.02 or y1 - y0 < 0.02:
		return
	var along := (b - a).normalized()
	var c := a + along * (s0 + s1) * 0.5 + out * (d0 + d1) * 0.5
	m.box(Vector3(c.x, (y0 + y1) * 0.5, c.y), Vector3(s1 - s0, y1 - y0, d1 - d0), atan2(-along.y, along.x), mat, false)


## The south and east walls cut at FRONT.x (spec 2.1): cut stone on both faces, the dark fill between them on the
## cut, the outer face dropping into the dark, the doors' gaps, fallen blocks outside.
func _front_walls() -> void:
	var skin := m.ashlar(0.0, STONE * WALL_TINT)
	var fill := m.stone(0.0, HOLLOW * 1.4)
	var runs: Array = [[Vector2(_west - WALL_SET - WALL_THICK, _south), Vector2(_east + FRONT.y, _south), Vector2(0, 1)],
		[Vector2(_east, _south), Vector2(_east, _north - 0.5), Vector2(1, 0)]]
	for run: Array in runs:
		var a: Vector2 = run[0]
		var b: Vector2 = run[1]
		var out: Vector2 = run[2]
		var along := (b - a).normalized()
		var length := a.distance_to(b)
		var gaps: Array[Vector2] = []
		for e in layout.exits:
			if e.inward.dot(-out) > 0.9:
				var w := absf(e.mouth.size.dot(along))
				var s := (e.mouth.get_center() - a).dot(along)
				gaps.append(Vector2(s - w * 0.5 - EXIT_CHEEK.x, s + w * 0.5 + EXIT_CHEEK.x))
		var s0 := 0.0
		gaps.append(Vector2(length, length))
		for g in gaps:
			if g.x > s0:
				var skin_w := FRONT.y * (1.0 - FRONT_FILL) * 0.5
				_part(a, b, out, s0, g.x, 0.0, skin_w, -FRONT_DROP, FRONT.x, skin)
				_part(a, b, out, s0, g.x, FRONT.y - skin_w, FRONT.y, -FRONT_DROP, FRONT.x - 0.06, skin)
				_part(a, b, out, s0, g.x, skin_w, FRONT.y - skin_w, -FRONT_DROP, FRONT.x - 0.1, fill)
				_fallen(a, along, out, s0, g.x)
			s0 = g.y


## Blocks fallen outside a front wall between s0 and s1.
func _fallen(a: Vector2, along: Vector2, out: Vector2, s0: float, s1: float) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + along * s0) * 10.0))
	for k in floori((s1 - s0) * FRONT_FALLEN):
		var p := a + along * r.randf_range(s0 + 0.3, s1 - 0.3) + out * (FRONT.y + r.randf_range(0.3, 1.2))
		var size := r.randf_range(0.3, 0.7)
		var blk := m.box(Vector3(p.x, -r.randf_range(0.6, 2.2), p.y), Vector3(size, size * 0.7, size * 0.9), r.randf() * TAU, ashlar())
		blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))


## The heap of fallen blocks over the cut corner (spec 2.1): from HEAP_HEIGHT.x at the floor's edge to HEAP_HEIGHT.y
## at the walls, its foot the edge (no block on the floor).
func _heap() -> void:
	var poly := layout.floor.polys[0]
	# the cut: the edge of the outline that is neither along x nor along z
	var p := Vector2.ZERO
	var q := Vector2.ZERO
	for i in poly.size():
		var a := poly[i]
		var c := poly[(i + 1) % poly.size()]
		if absf(a.x - c.x) > 0.5 and absf(a.y - c.y) > 0.5:
			p = a
			q = c
	if p == q:
		return
	var along := (q - p).normalized()
	var out := Vector2(along.y, -along.x)
	if layout.floor.covers((p + q) * 0.5 + out * 0.3):
		out = -out
	var corner := Vector2(maxf(p.x, q.x), minf(p.y, q.y))
	var reach := (corner - p).dot(out)
	var r := RandomNumberGenerator.new()
	r.seed = 9127
	var mat := ashlar()
	# a mound under it, a little back from the edge
	var off := out * 0.5
	m.prism(PackedVector2Array([p + off, q + off, corner + Vector2(1.5, -1.5)]), -0.2, HEAP_HEIGHT.y * 0.45, m.stone(0.0, HOLLOW * 1.6))
	for k in HEAP:
		var size := r.randf_range(HEAP_BLOCK.x, HEAP_BLOCK.y)
		var d := r.randf_range(size * 0.75 + 0.05, reach + 1.2)
		var c := p + along * r.randf_range(0.0, p.distance_to(q)) + out * d
		var h := lerpf(HEAP_HEIGHT.x, HEAP_HEIGHT.y, clampf(d / (reach + 1.2), 0.0, 1.0))
		var blk := m.box(Vector3(c.x, h - size * 0.4, c.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, mat)
		blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.5, 0.5))
		blk.rotate_object_local(Vector3.BACK, r.randf_range(-0.4, 0.4))


## The way in (spec 2.4): stairs going up out of the arcade in the west wall, its arch, the gold sill on the edge.
func _entry() -> void:
	var mid := Vector2(_west, (ENTRY.x + ENTRY.y) * 0.5)
	var w := ENTRY.y - ENTRY.x
	door_arch(mid, Vector2(1, 0), w, WALL_SET + 0.45)
	m.stairs(Vector3(_west - 0.05, 0.0, mid.y), Vector2(-1, 0), w, ENTRY_STEPS, 0.2, 0.45, _stair_stone(0.0))
	tomb.bar(Vector3(_west + 0.04, 0.004, mid.y), Vector3(0.05, 0.008, w), 0.0, tomb.gold())


# ---------- the floor's slabs, candles and light ----------

func _slabs() -> void:
	var st := m.stone(0.0, STONE * SLAB_STONE)
	var fr := m.stone(0.0, STONE * SLAB_FRAME)
	var border := m.stone(0.0, HOLLOW * SLAB_BORDER_TINT)
	for s in SLAB_ROWS:
		var at := Vector2(s.x, s.y)
		if not _clear(at, SLAB.length() * 0.5):
			continue
		var h := SLAB * 0.5 + Vector2.ONE * SLAB_BORDER.x
		m.prism(PackedVector2Array([at - h, at + Vector2(h.x, -h.y), at + h, at + Vector2(-h.x, h.y)]), 0.0, SLAB_BORDER.y, border)
		tomb.slab(at, SLAB, 0.0, st, fr)


## True when nothing of the layout stands within `r` of p.
func _clear(p: Vector2, r: float) -> bool:
	for o in layout.obstacles:
		if o.blocks_move and o.depth(p, r) > 0.0:
			return false
	return true


## Candles on the pieces (spec 2.2 and 2.3): on the lids, the tomb's steps, the columns' bases, the ledges; three groups
## light the floor with shadows (A: the north sarcophagus, the tomb's west step, the south column; B: the two south
## sarcophagi and the dividing wall's foot), up to CANDLE_PLAIN more without. In B the west bay's are burnt out.
func _candles() -> void:
	var divider := _divider()
	var ossuary := divider != null
	for o in layout.obstacles:
		match o.piece:
			&"sarcophagus":
				var long_x := o.half.x >= o.half.y
				var half := o.half if long_x else Vector2(o.half.y, o.half.x)
				var axis := Vector3(1, 0, 0) if long_x else Vector3(0, 0, 1)
				var c := Vector3(o.center.x, o.height, o.center.y)
				if half.x * 2.0 >= ArenaRoom.TOMB_FROM:
					# the great tomb: candles on the upper step at its west end, and at its east end
					var west := c - axis * (half.x - 0.45)
					west.y = TombKit.TOMB_STEP * 2.0
					var side := Vector3(axis.z, 0, axis.x) * (half.y - 0.35)
					candle_line(west - side, west + side, 4)
					_light_at(west + Vector3(0, 0.6, 0), true)
					var east := c + axis * (half.x - 0.45)
					east.y = TombKit.TOMB_STEP * 2.0
					candle_line(east - side * 0.6, east + side * 0.6, 3)
					continue
				var against := arena.shape().edge_distance(o.center) < half.y + 0.4
				var end := c + axis * (half.x - 0.35) * (1.0 if o.center.x > 0.0 else -1.0)
				var lit := not (ossuary and against)
				candle_line(end - Vector3(axis.z, 0, axis.x) * 0.25, end + Vector3(axis.z, 0, axis.x) * 0.25, 3, lit)
				if lit:
					var shadow := (o.center.y < 0.0 and not against) if not ossuary else o.center.y > 0.0
					_light_at(end + Vector3(0, 0.5, 0), shadow)
			&"column":
				var ring := o.radius * 0.86
				var foot := Vector3(o.center.x, TombKit.COLUMN_BASE, o.center.y)
				var toward := Vector3(0.57, 0, 0.82)
				var a := foot + toward.rotated(Vector3.UP, 0.6) * ring
				var b := foot + toward.rotated(Vector3.UP, -0.6) * ring
				candle_line(a, b, 3)
				# the column nearest the camera lights its foot with shadows (A)
				if not ossuary and o.center.y > 0.0:
					_light_at(foot + toward * ring + Vector3(0, 0.5, 0), true)
	if ossuary:
		var tip := Vector3(divider.center.x, LEDGE * 0.5, divider.center.y + divider.half.y + 0.3)
		_light_at(tip + Vector3(0, 0.6, 0), true)
	# along the ledges of the back walls, plain
	for x: float in [-5.6, 0.6]:
		candle_line(Vector3(x - 0.3, LEDGE, _north - WALL_SET * 0.5), Vector3(x + 0.3, LEDGE, _north - WALL_SET * 0.5), 3, not ossuary or x > 0.5)
	for z: float in [-3.6, 1.8]:
		candle_line(Vector3(_west - WALL_SET * 0.5, LEDGE, z - 0.3), Vector3(_west - WALL_SET * 0.5, LEDGE, z + 0.3), 3, not ossuary)


## A warm light over candles: with shadow (counted) or plain (at most CANDLE_PLAIN).
func _light_at(at: Vector3, shadow: bool) -> void:
	if shadow:
		warm_light(at, CANDLE_SHADOW_ENERGY, true)
	elif _plain_lights < CANDLE_PLAIN:
		_plain_lights += 1
		warm_light(at)


## The dividing wall of the ossuary (variant B), if any: a tall wall-like block.
func _divider() -> ArenaObstacle:
	for o in layout.obstacles:
		if o.piece == &"block" and o.height > 2.0 and o.shape == ArenaObstacle.Shape.BOX:
			return o
	return null


## The dividing wall (variant B): cut stone with rows of shallow ossuary niches on both faces and, at its south end, a
## pillar with the raised sword on its panel (the Seal Chamber's pinnacle, slimmer).
func ruin_wall(o: ArenaObstacle) -> void:
	if o.height <= 2.0:
		super.ruin_wall(o)
		return
	var mat := see(ashlar())
	var long_x := o.half.x >= o.half.y
	var length := maxf(o.half.x, o.half.y) * 2.0
	var width := minf(o.half.x, o.half.y) * 2.0
	var yaw := 0.0 if long_x else PI * 0.5
	var basis := Basis(Vector3.UP, yaw)
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var pillar := width
	m.block(foot - basis * Vector3(pillar * 0.5, 0, 0) * (1.0 if long_x else -1.0), Vector3(length - pillar, o.height, width), yaw, mat, false)
	var hollow := see(m.stone(0.0, HOLLOW))
	var bone := see(m.stone(0.0, BONE))
	# the shallow niches: three rows of dark arched panels, a bundle of bones in each
	for sd: float in [-1.0, 1.0]:
		for row in 3:
			var y := 0.6 + row * 0.85
			var n := floori((length - pillar - 0.6) / 0.9)
			for k in n:
				var s := -length * 0.5 + 0.45 + 0.9 * (k + 0.5)
				var along := Vector3(s, 0, 0) if long_x else Vector3(0, 0, s)
				var face := Vector3(0, 0, sd * width * 0.5) if long_x else Vector3(sd * width * 0.5, 0, 0)
				m.box(foot + along + face * 0.99 + Vector3(0, y, 0), Vector3(0.62, 0.55, 0.02) if long_x else Vector3(0.02, 0.55, 0.62), 0.0, hollow, false)
				m.box(foot + along + face * 0.97 + Vector3(0, y - 0.18, 0), Vector3(0.45, 0.08, 0.08) if long_x else Vector3(0.08, 0.08, 0.45), 0.0, bone, false)
	# the pillar at the south end (the end toward +z when it runs along z), facing the room
	var tip := foot + (Vector3(o.half.x - pillar * 0.5, 0, 0) if long_x else Vector3(0, 0, o.half.y - pillar * 0.5))
	tomb.pinnacle(tip, 0.0 if not long_x else PI * 0.5, mat, Vector3(width - 0.16, o.height - 0.2, 0.45))


## The cold shaft of light from a crack in the vault (spec 2.5), on the great tomb (A) or the dividing wall's end (B),
## with its dust falling.
func _cold_shaft() -> void:
	var target := Vector2.ZERO
	var found := false
	var divider := _divider()
	if divider != null:
		target = divider.center + Vector2(0, divider.half.y + 0.8)
		found = true
	else:
		for o in layout.obstacles:
			if o.piece == &"sarcophagus" and maxf(o.half.x, o.half.y) * 2.0 >= ArenaRoom.TOMB_FROM:
				target = o.center
				found = true
	if not found:
		return
	var spot := SpotLight3D.new()
	add_child(spot)
	var to := Vector3(target.x, 0.0, target.y)
	spot.look_at_from_position(to + Vector3(COLD_LEAN.x, COLD_HEIGHT, COLD_LEAN.y), to)
	spot.light_color = COLD
	spot.light_energy = COLD_ENERGY
	spot.spot_angle = COLD_ANGLE
	# no fall-off with distance (only the range's window): the energy is what reaches the floor
	spot.spot_range = COLD_HEIGHT * 2.0
	spot.spot_attenuation = 0.0
	spot.shadow_enabled = true
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	arena._dust(to)
