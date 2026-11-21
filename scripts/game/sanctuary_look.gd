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
## AT-SE1: how close to a slab that strikes an edge of the hole's middle lies for the slab to be its edge (m).
const PLATE_EDGE_GAP := 0.6
## AT-SE2: the breathing room at the four mouths of the ways round the hole (B): a worn, paler patch of the nave's floor
## MOUTH_SIZE m (along the way, across), MOUTH_IN m before the hole's corner and in the middle of the way (between the
## hole and the line of columns), the floor's own stone lifted MOUTH_LIFT at the middle at MOUTH_ALPHA, soft to nothing
## at its edge (no ring, no rim: not a hazard); nothing drawn of the room's dress inside it. Stylized only.
const MOUTH_SIZE := Vector2(4.2, 1.8)
const MOUTH_IN := 0.5
const MOUTH_LIFT := Color(0.66, 0.63, 0.56)
const MOUTH_ALPHA := 0.085
const UNDER_LIGHT := Vector2(1.2, 8.0)
const UNDER_FLOOR := Color(0.55, 0.55, 0.55)

## Room redesign, lot B (docs/art/room_redesign_lotB_spec.md section 1): the sanctuary's biome in the stylized look,
## warm limestone (the one fighting room in warm stone), cold shadows, the hall's fires, its own air, the soft key over
## the nave at STY_KEY of its energy.
## The cycle of 2026-11-20 (docs/art/benchmark_hades2_style.md 7.2 row 6; ART_REVIEW.md 4.5 P1-B2): a pale yellow
## limestone (hue 34 to 42, under 0.2 of saturation, so the stone in the shafts stays under 0.25 and the cracked slabs'
## amber reads on it), the shafts ivory gold, the shadow cold: the colour from that contrast.
const STYLE := {
	&"stone": Color(0.39, 0.365, 0.325), &"shadow": Color(0.78, 0.86, 1.0), &"floor_stone": STY_FLOOR,
	&"slab_paint": STY_SLAB_PAINT, &"slab_hue": STY_SLAB_HUE, &"joint_cold": Color(0.9, 0.93, 1.0), &"olive_share": 0.04, &"metal": true,
	&"fire": CatacombHall.STYLE[&"fire"],
	&"air": {&"sky": Color(0.05, 0.05, 0.06), &"fog": Color(0.12, 0.11, 0.10), &"ambient": Color(0.76, 0.745, 0.70),
		&"ambient_gain": 1.6, &"moon": Color(0.95, 0.93, 0.9), &"moon_energy": 0.85, &"moon_shadow": true},
}
## The floor's limestone in the stylized look (room redesign fixes: it read neutral grey, nave luma 71 to 83 flat): a
## warmer stone, the slabs further apart in value and a little more in hue, fewer olive slabs.
const STY_FLOOR := Color(0.36, 0.343, 0.313)
## SW-G1 and SW-G2 (docs/art/sworn_reference_ideas.md 3.1; floor_biome.gdshaderinc, ArenaKit.paint_look's `floor`,
## put by style()): the painted floor's second colour of the biome in patches of 3 to 8 m, stronger near the edge, and
## the shadow of the vault's broken ribs (SW-S1) in the shafts: a quadripartite bay of gobo_scale m, stretched along
## STY_SHAFT_LEAN, on each shaft's floor (STY_GOBO_SHAFT: radius, weight; the guardian's smaller, STY_GOBO_GUARD).
## Pale dust, 1.5 times the limestone's value. G-2 of the Sworn P1 review: the ribs sharper and darker (strength 0.35,
## soft 0.03; were 0.25 and 0.05) so the broken vault reads in the shaft's pool.
## The cycle of 2026-11-20 (ART_REVIEW.md, the Salão's method by biome, docs/art/benchmark_hades2_style.md 7): the floor
## calm between neighbour slabs (ArenaKit.CALM_FLOOR) and the patches soft and large (ArenaKit.SOFT_PATCHES); the stone
## at most 0.25 of saturation, the colour from the warm and cold contrast (matrix row 6).
const STY_FLOOR_BIOME := {&"patch_color": Color(0.54, 0.517, 0.476),
	&"gobo_kind": 2, &"gobo_strength": 0.35, &"gobo_width": 0.1, &"gobo_base": 0.0, &"gobo_scale": 2.6, &"gobo_stretch": 1.5,
	&"gobo_along": -STY_SHAFT_LEAN, &"gobo_sway": 0.04, &"gobo_soft": 0.03, &"gobo_cover": 0.5}
## SW-S3 with SW-G3 (docs/art/sworn_reference_ideas.md 3.2; ArenaKit.framed, RAISED): a row of raised frames on the
## nave's floor, "noble floor". S-2 of the Sworn P1 review: at the grille's foot (1.6 m in from the west edge) the
## game's camera never showed them; now down the nave from the guardian's shaft eastward, between the two rows of
## columns, 2 m north of its axis (clear of the south row's columns on the screen), each its own size and value (never
## over the floor's, S-1) and one with a broken corner. Each: x from the west edge, z from the chancel's axis, size x,
## size z (m), broken corner, value.
const STY_FRAMES: Array[Array] = [
	[8.0, -2.0, 2.4, 2.6, false, 1.0],
	[11.0, -1.9, 2.6, 2.2, true, 0.96],
	[13.9, -2.1, 2.2, 2.4, false, 0.93],
]
const STY_GOBO_SHAFT := Vector2(9.0, 1.0)
const STY_GOBO_GUARD := Vector2(5.0, 0.8)
const STY_SLAB_PAINT := Vector2(0.78, 1.2)
const STY_SLAB_HUE := 7.0
## The stylized air in the browser's renderer (as the crypt's: there the painted stone lit grey-white).
const STY_COMPAT_AMBIENT := 0.45
const STY_COMPAT_MOON := 0.35
## LC-4: and the shafts and the nave's key a share there: the slab inside a shaft read luma 152 against 89 on the desktop
## (the same take) and the fighters in it went to silhouettes.
const STY_COMPAT_SHAFT := 0.25
## The soft key over the nave in the stylized look (spec 1.2: 0.6 of its energy when it draws no ring).
const STY_KEY := 0.6
## The shafts in ivory gold (spec 1.3: under the painted light's fire threshold, a lit edge and no flat pool), the new
## one over the guardian's spawn (energy, cone, height; no shadow, no dust of its own).
const STY_SHAFT := Color(0.96, 0.88, 0.70)
## Room redesign fixes (P-4: no circle on the floor): in the stylized look every shaft is a diffuse light (no specular:
## paint.gdshaderinc skips the bands and the pool's edge), warmer, weaker, its cone wider so it fades out over metres,
## leaning further so its fall on the floor is long along the light: colour, share of its energy, cone (degrees), lean
## (x, z m at the vault's height).
const STY_SHAFT_WARM := Color(1.0, 0.96, 0.89)
const STY_SHAFT_GAIN := 0.75
const STY_SHAFT_CONE := 30.0
const STY_SHAFT_LEAN := Vector2(-5.5, -7.0)
const STY_GUARD_SHAFT := Vector3(1.6, 18.0, 16.0)
## S1: the chancel's offerings behind the grille: three groups of four candles (two lit) with urns (z off the chancel's
## middle; x in from the grille), the urns' heights.
const OFFERINGS: Array[Vector2] = [Vector2(1.3, -4.4), Vector2(1.3, 4.4), Vector2(3.4, -1.6)]
const OFFERING_URNS: Array[float] = [0.42, 0.3]
## S2: the runner of faded petrol cloth from the grille to the altar (width; cloth, border; how much of the way).
const RUNNER_WIDTH := 1.4
const RUNNER_CLOTH := Color(0.11, 0.17, 0.18)
const RUNNER_BORDER := Color(0.30, 0.25, 0.15)
const RUNNER_Y := 0.012
## How far off the back wall's face the runner stops.
const RUNNER_BACK := 0.6
## S3: shards of the fallen drums leaning on a broken column's shaft, all inside its circle less 0.1 m (count; size:
## width, thickness; heights).
const DRUM_SHARDS := 3
const DRUM_SHARD := Vector2(0.34, 0.09)
const DRUM_SHARD_HEIGHT := Vector2(0.55, 1.15)
const DRUM_SHARD_IN := 0.1
## S4: hooded statues in the blind windows (x) on their sills, height; petrol banners on the pilasters (x), top, size.
const NICHE_STATUES: Array[float] = [-17.5, -1.0]
const NICHE_STATUE := 2.6
## ... each on a corbel over the sill (its height, width, how far out of the wall's face), so its body leans out over
## the floor only above the hero (OVERHEAD in tests/test_e5_looks.gd).
const NICHE_CORBEL := Vector3(0.5, 1.1, 0.5)
const PILASTER_BANNERS: Array[float] = [-14.0, 2.0]
const PILASTER_BANNER_TOP := 7.2
const PILASTER_BANNER := Vector2(1.0, 2.6)
## S5: moss and ivy cards on the walls (never the floor): its colour; a card's size (one for all: one material); over
## each blind window's head and along the north wall's top (x).
const MOSS := Color(0.20, 0.24, 0.17)
const MOSS_CARD := Vector2(2.6, 2.2)
const WALL_TOP_MOSS: Array[float] = [-19.5, -10.5, -4.0, 6.5, 10.0]
## S6 (B): the torn vault over the hole: broken ribs across the nave over its north and south lips (z, springing
## height), their span, ring, depth, the missing middle (m from the rib's middle), stones hanging from the broken ends
## (count, drop under them). All of it over 9 m and drawn against the north wall in the fight's camera.
const VAULT_RIBS: Array[Vector2] = [Vector2(-3.4, 9.0), Vector2(1.6, 9.8)]
const VAULT_SPAN := 13.0
const VAULT_RING := 0.62
const VAULT_DEEP := 0.75
const VAULT_GAP := Vector2(-2.8, 3.6)
const VAULT_HANG := 3
const VAULT_DROP := 0.9
## B: the shaft through the tear is cold (the room-designer's "cold light from above on the hole"; the shafts of A and
## the guardian's stay ivory gold).
const STY_TEAR_SHAFT := Color(0.84, 0.9, 0.98)
## B: the dust falling through the tear, denser (particles).
const STY_DUST := 48

var _key: OmniLight3D
var _shafts: Array[SpotLight3D] = []
var _hole_dust: CPUParticles3D
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
		# AT-SE1: where an edge that crumbles (RP-13) meets the hole, the slab itself is the edge: a clean sunk face, no
		# broken lip, no gold thread (the decorative edge never inside a slab that strikes, SW-G7 3.1)
		if on_hazard((a + b) * 0.5, PLATE_EDGE_GAP):
			lip_wall(a, b, out, faces)
			return
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
	BuildSteps.run(dress_steps())


## dress in steps (ArenaRoom.dress_steps; QA P1-1).
func dress_steps() -> Array[Callable]:
	return [
		func() -> void:
			wall_fill(WALL_FILL_COLOR, WALL_FILL_ENERGY)
			var box := layout.floor.bounds()
			_west = box.position.x
			_east = box.end.x
			_north = box.position.y
			_south = box.end.y
			_chancel = Vector2(_west, layout.boss_spawn.y)
			_north_wall(),
		_west_wall,
		_chancel_dress,
		func() -> void:
			_heap()
			_front(),
		func() -> void:
			_entry()
			_slabs(),
		func() -> void:
			_rubble()
			_candles()
			_lights(),
		func() -> Array[Callable]: return _dress_styled_steps(),
	]


func _lights() -> void:
	var key := key_light(KEY, KEY_ENERGY, KEY_HEIGHT)
	key.omni_range = KEY_REACH
	key.omni_attenuation = KEY_FALLOFF
	_key = key
	if _hole.is_empty():
		for p in MOON_AT:
			_shafts.append(moon_shaft(p, MOON, MOON_ENERGY, MOON_CONE, MOON_HEIGHT))
	else:
		_shafts.append(moon_shaft(MOON_AT[0], MOON, MOON_ENERGY_B, MOON_CONE, MOON_HEIGHT))
		var c := _middle(_hole)
		arena._dust(Vector3(c.x, 0.0, c.y))
		_hole_dust = arena.get_child(arena.get_child_count() - 1) as CPUParticles3D


## AT-SE2: the ways round the hole open at each end with a paler, worn patch (the "here you pass" of the floor).
func _mouths() -> void:
	if _hole.is_empty():
		return
	var lo := Vector2(INF, INF)
	var hi := -lo
	for p in _hole:
		lo = lo.min(p)
		hi = hi.max(p)
	var near := INF
	for o in layout.obstacles:
		if o.shape == ArenaObstacle.Shape.CIRCLE and o.center.x > lo.x - 4.0 and o.center.x < hi.x + 4.0:
			near = minf(near, absf(o.center.y) - o.radius)
	var way := (hi.y + near) * 0.5 if near < INF else hi.y + 0.9
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/soft_shadow.gdshader")
	mat.set_shader_parameter(&"color", MOUTH_LIFT)
	mat.set_shader_parameter(&"alpha", MOUTH_ALPHA)
	var node := Node3D.new()
	node.name = "Mouths"
	add_child(node)
	ArenaKit.style_only(node)
	for x: float in [lo.x - MOUTH_IN, hi.x + MOUTH_IN]:
		for z: float in [-way, way]:
			var mi := MeshInstance3D.new()
			var q := QuadMesh.new()
			q.size = MOUTH_SIZE
			mi.mesh = q
			mi.material_override = mat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5), Vector3(x, 0.009, z))
			node.add_child(mi)


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
		# AT-SE1: never beside a slab that strikes (the decorative slab would read as one more)
		if _clear(at, SLAB.length() * 0.6) and clear_of_plates(at, Vector2(SLAB.y, SLAB.x)):
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


# ---------- the stylized look (room redesign, lot B section 1) ----------

func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	var lit: Array[Vector4] = []
	for k in _shafts.size():
		var to: Vector2 = MOON_AT[k] if _hole.is_empty() else _middle(_hole)
		lit.append(Vector4(to.x, to.y, STY_GOBO_SHAFT.x, STY_GOBO_SHAFT.y))
	lit.append(Vector4(layout.boss_spawn.x, layout.boss_spawn.y, STY_GOBO_GUARD.x, STY_GOBO_GUARD.y))
	var frames := []
	for k in STY_FRAMES.size():
		var f: Array = STY_FRAMES[k]
		if not clear_of_plates(Vector2(_west + float(f[0]), _chancel.y + float(f[1])), Vector2(float(f[2]), float(f[3]))):
			continue
		frames.append(ArenaKit.framed_slab(Vector2(_west + float(f[0]), _chancel.y + float(f[1])), Vector2(float(f[2]), float(f[3])),
			ArenaKit.Framed.RAISED, f[4], float(f[5]), k))
	st[&"floor"] = ArenaKit.framed(ArenaKit.gobo(ArenaKit.CALM_FLOOR.merged(ArenaKit.SOFT_PATCHES).merged(STY_FLOOR_BIOME), lit), frames)
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	var shaft := STY_COMPAT_SHAFT if compat() else 1.0
	VisualProfile.vary(_key, {&"light_energy": KEY_ENERGY * STY_KEY * shaft})
	for k in _shafts.size():
		var to: Vector2 = MOON_AT[k]
		var warm := STY_SHAFT_WARM
		if not _hole.is_empty():
			# B: the shaft falls through the tear of the vault into the hole (S6), cold, the dust there denser
			to = _middle(_hole)
			warm = STY_TEAR_SHAFT
		VisualProfile.vary(_shafts[k], {&"transform": _leaning(to, MOON_HEIGHT), &"light_color": warm,
			&"light_energy": (MOON_ENERGY if _hole.is_empty() else MOON_ENERGY_B) * STY_SHAFT_GAIN * shaft, &"spot_angle": STY_SHAFT_CONE, &"light_specular": 0.0})
	if not _hole.is_empty():
		if _hole_dust != null:
			VisualProfile.vary(_hole_dust, {&"amount": STY_DUST})
	return st


## A shaft's place in the stylized look: from `height` m up, leaning STY_SHAFT_LEAN, onto `to`.
func _leaning(to: Vector2, height: float) -> Transform3D:
	var probe := Node3D.new()
	probe.look_at_from_position(Vector3(to.x + STY_SHAFT_LEAN.x, height, to.y + STY_SHAFT_LEAN.y), Vector3(to.x, 0.0, to.y))
	var t := probe.transform
	probe.free()
	return t


## The pieces only the stylized look shows (spec 1.4), on kit.styled() (never the room's random numbers): the shaft
## over the guardian, the chancel's offerings and runner, the shards at the broken columns, the statues in the blind
## windows and the banners on the pilasters, the moss on the walls; in B the torn vault.
func _dress_styled() -> void:
	BuildSteps.run(_dress_styled_steps())


## _dress_styled in steps (BuildSteps; QA P1-1: a frame each on a new room's black screen).
func _dress_styled_steps() -> Array[Callable]:
	var v := {}
	return [
		func() -> void:
			var sm := kit.styled()
			var face := _north - FACE_SET
			v[&"sm"] = sm
			v[&"face"] = face
			var share := STY_SHAFT_GAIN * (STY_COMPAT_SHAFT if compat() else 1.0)
			var guard := moon_shaft(layout.boss_spawn, STY_SHAFT_WARM, STY_GUARD_SHAFT.x * share, STY_GUARD_SHAFT.y,
				STY_GUARD_SHAFT.z, false, false)
			guard.transform = _leaning(layout.boss_spawn, STY_GUARD_SHAFT.z)
			guard.light_specular = 0.0
			ArenaKit.style_only(guard)
			_mouths(),
		func() -> void:
			_offerings(v[&"sm"]),
		func() -> void:
			_shards(v[&"sm"]),
		func() -> void:
			var sm: Masonry = v[&"sm"]
			var face: float = v[&"face"]
			for x in NICHE_STATUES:
				var at := Vector2(x, face - 0.05)
				sm.box(Vector3(x, WINDOW.z + 0.02 + NICHE_CORBEL.x * 0.5, face + NICHE_CORBEL.z * 0.5),
					Vector3(NICHE_CORBEL.y, NICHE_CORBEL.x, NICHE_CORBEL.z), 0.0, ashlar())
				kit.styled_build(func() -> void: kit.statue(at, 0.0, NICHE_STATUE, WINDOW.z + 0.02 + NICHE_CORBEL.x, ArenaKit.STATUE_VALUE, false))
			for x in PILASTER_BANNERS:
				var top := Vector3(x, PILASTER_BANNER_TOP, face + PILASTER.y + 0.06)
				kit.styled_build(func() -> void: kit.banner(top, 0.0, PILASTER_BANNER, ArenaKit.FACADE_LAYER, ArenaKit.Emblem.LION)),
		func() -> void:
			_moss(v[&"sm"], v[&"face"])
			if not _hole.is_empty():
				_torn_vault(v[&"sm"])
				_hole_depth(),
		_edge_pieces,
		func() -> void:
			_finials(v[&"sm"]),
	]


## Sworn P2 SW-G4: offerings at the foot of the nave's tall walls (ArenaRoom.offerings).
func sworn_offerings() -> bool:
	return true


## SW-S2: a finial on each snapped column (the nave's broken silhouette and the short stumps), inside its outline: a
## carved block set a little askew on the fracture (FINIAL_BLOCK: its side over the column's radius, its height) and,
## on every other one, a low pinnacle on it (FINIAL_SPIRE: its width over the radius, its height); never on a column
## that topples (RP-09: it would stay in the air). FINIAL_SEAT: how far under the fracture's highest tooth it sits.
const FINIAL_BLOCK := Vector2(1.05, 0.42)
const FINIAL_SPIRE := Vector2(0.62, 0.75)
const FINIAL_SEAT := 0.12


func _finials(sm: Masonry) -> void:
	var mat := sm.carved(0.0, Color(1.02, 1.0, 0.96))
	var k := 0
	for o in layout.obstacles:
		if o.piece != &"column" or o.hits_to_fall > 0:
			continue
		var top := o.height
		if o.height >= WHOLE_COLUMN:
			if column_kind(o.center, true) != ColumnKind.BROKEN:
				continue
			top = o.height * COLUMN_BROKEN
		var y := top + 0.43 - FINIAL_SEAT
		var side := o.radius * TombKit.COLUMN_SHAFT * FINIAL_BLOCK.x * 2.0
		var turn := float(posmod(hash(Vector2i(o.center * 10.0)), 628)) * 0.01
		var block := sm.block(Vector3(o.center.x, y, o.center.y), Vector3(side, FINIAL_BLOCK.y, side), turn, mat)
		block.rotate_object_local(Vector3.BACK, 0.06 * (1.0 if k % 2 == 0 else -1.0))
		if k % 2 == 0:
			sm.pinnacle(Vector3(o.center.x, y + FINIAL_BLOCK.y, o.center.y), side * FINIAL_SPIRE.x, FINIAL_SPIRE.y, mat)
		k += 1


## TA-HB2 (docs/gallery/hb/ART_REVIEW.md item 2, Santuário): the foreground past the south cut wall, out of the nave and
## off the floor: broken columns rising out of the dark below the room in two of the wall's gaps (EDGE_PILLARS: the gap
## of SOUTH_GAPS, out past the floor's edge, their foot below the floor, how far over it they reach; EDGE_PILLAR_RADIUS)
## and heaps of fallen blocks lying on the cut wall's top (EDGE_RUBBLE_AT: m along the south wall from its west end;
## EDGE_RUBBLE: out of the floor's edge onto the wall, its size). All open in a stipple round the paladin.
const EDGE_PILLARS: Array[Vector4] = [Vector4(1, 1.4, -3.6, 1.4), Vector4(2, 1.5, -3.6, 1.0)]
const EDGE_PILLAR_RADIUS := 0.5
const EDGE_RUBBLE_AT: Array[float] = [8.0, 25.0, 36.5]
const EDGE_RUBBLE := Vector2(0.55, 0.55)


func _edge_pieces() -> void:
	var edge := edge_kit()
	var west := _west_south_x()
	var k := 0
	for p in EDGE_PILLARS:
		var gap := SOUTH_GAPS[int(p.x)]
		var x := west + (gap.x + gap.y) * 0.5
		edge.broken_pillar(Vector3(x, p.z, _south + p.y), EDGE_PILLAR_RADIUS, p.w - p.z, Vector2(1, 0), k)
		k += 1
	for s in EDGE_RUBBLE_AT:
		edge.rubble(Vector3(west + s, CUT_WALL.x, _south + EDGE_RUBBLE.x), EDGE_RUBBLE.y, k)
		k += 1


## S1, S2: candles and urns on the chancel's floor behind the grille, and the faded petrol runner from the grille to
## the altar (a painted decal on its floor).
func _offerings(sm: Masonry) -> void:
	var y := CHANCEL_RISE
	var x0 := _west - BALUSTRADE_OUT - 0.25
	var urn := sm.carved(y, STONE)
	for g in OFFERINGS:
		var c := Vector2(x0 - g.x, _chancel.y + g.y)
		for i in 4:
			var p := c + Vector2(-0.18 + 0.12 * (i % 2), -0.27 + 0.18 * i)
			if i == 1 or i == 2:
				sm.candle(Vector3(p.x, y, p.y), 0.14 + 0.07 * i, 0.05)
			else:
				sm.candle_out(Vector3(p.x, y, p.y), 0.08 + 0.05 * (i % 3), 0.05)
		for k in OFFERING_URNS.size():
			sm.urn(Vector3(c.x - 0.45, y, c.y + (k - 0.5) * 0.42), OFFERING_URNS[k], urn)
	# from the grille to the back wall's foot (where the altar stands)
	var altar_front := _west - CHANCEL_DEEP - 0.2 - FACE_SET + RUNNER_BACK
	var length := x0 - 0.2 - altar_front
	var mi := MeshInstance3D.new()
	var q := PlaneMesh.new()
	q.size = Vector2(length, RUNNER_WIDTH)
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = CatacombHall.DECAL_SHADER
	mat.set_shader_parameter(&"rug_size", q.size)
	mat.set_shader_parameter(&"cloth", RUNNER_CLOTH)
	mat.set_shader_parameter(&"border", RUNNER_BORDER)
	mat.set_shader_parameter(&"gold", RUNNER_BORDER)
	mat.set_shader_parameter(&"diamond", 0.0)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(altar_front + length * 0.5, y + RUNNER_Y, _chancel.y)
	sm.root.add_child(mi)


## S3: shards of the fallen drums standing against the shaft of each broken column, inside its circle (less DRUM_SHARD_IN).
func _shards(sm: Masonry) -> void:
	var mat := stone()
	for o in layout.obstacles:
		if o.piece != &"column" or o.height >= WHOLE_COLUMN:
			continue
		var shaft_r := o.radius * TombKit.COLUMN_SHAFT
		var r := RandomNumberGenerator.new()
		r.seed = hash(Vector2i(o.center * 10.0)) + 11
		var turn := r.randf() * TAU
		for k in DRUM_SHARDS:
			var a := turn + TAU * k / DRUM_SHARDS + r.randf_range(-0.4, 0.4)
			var h := r.randf_range(DRUM_SHARD_HEIGHT.x, DRUM_SHARD_HEIGHT.y)
			var out := Vector2.from_angle(a)
			# the shard's outer face at the circle less DRUM_SHARD_IN, its corners inside it
			var d := minf(shaft_r + DRUM_SHARD.y * 0.5, o.radius - DRUM_SHARD_IN - DRUM_SHARD.y * 0.5) - 0.02
			var c := o.center + out * d
			var lean := r.randf_range(0.05, 0.14)
			var mi := sm.box(Vector3(c.x, TombKit.COLUMN_PLINTH + h * 0.5, c.y), Vector3(DRUM_SHARD.y, h, DRUM_SHARD.x), -a, mat)
			mi.rotate_object_local(Vector3.BACK, lean)


## S5: moss and ivy hanging on the north wall's face: over each blind window's head and along its top.
func _moss(sm: Masonry, face: float) -> void:
	var tops: Array[Vector3] = []
	for x in WINDOWS:
		tops.append(Vector3(x, WINDOW.z + WINDOW.y + 0.5, face + 0.03))
	for x in WALL_TOP_MOSS:
		tops.append(Vector3(x, WALL_HEIGHT - 0.05, face + 0.03))
	wall_moss(sm, tops, MOSS_CARD, MOSS)


## S6 (B): the vault torn over the hole: two ribs across the nave over the hole's lips, their middles fallen, stones
## hanging from the broken ends; all over 9 m (no sky, no sunset: the light is the shaft's).
func _torn_vault(sm: Masonry) -> void:
	var c := _middle(_hole)
	var mat := ashlar()
	var r := RandomNumberGenerator.new()
	r.seed = 9127
	for rib in VAULT_RIBS:
		var foot := Vector3(c.x, 0.0, rib.x)
		var kept := sm.broken_arch(foot, Vector2(0, 1), VAULT_SPAN, rib.y, VAULT_RING, VAULT_DEEP, mat, VAULT_GAP, 0.75)
		# the stones at the broken ends (nearest the gap on each side): a few hang from them, turned
		var ends: Array[MeshInstance3D] = [null, null]
		var best := [INF, INF]
		for mi in kept:
			var x := mi.position.x - foot.x
			var sd := 0 if x < 0.0 else 1
			var d := absf(x - (VAULT_GAP.x if sd == 0 else VAULT_GAP.y))
			if d < best[sd]:
				best[sd] = d
				ends[sd] = mi
		for k in VAULT_HANG:
			var end := ends[k % 2]
			if end == null:
				continue
			var p := end.position + Vector3(r.randf_range(-0.3, 0.3), -VAULT_DROP * (1.0 + floorf(k * 0.5)), r.randf_range(-0.2, 0.2))
			var piece_ := sm.box(p, Vector3(VAULT_RING, 0.55, VAULT_DEEP), r.randf_range(-0.3, 0.3), mat)
			piece_.rotate_object_local(Vector3.BACK, r.randf_range(-0.9, 0.9))


## AT-SE1 (B, stylized only): depth in the hole, broken rock ledges well under the floor with fallen masonry heaped on
## them (HOLE_DEPTH_LEDGES: share along the hole's long side, share across, depth, width), in the deep stone, dark in the mist.
const HOLE_DEPTH_LEDGES: Array[Vector4] = [Vector4(0.25, 0.4, -5.5, 3.2), Vector4(0.7, 0.6, -8.0, 4.0)]
const HOLE_DEPTH_SLAB := 0.7


func _hole_depth() -> void:
	var lo := Vector2(INF, INF)
	var hi := -lo
	for p in _hole:
		lo = lo.min(p)
		hi = hi.max(p)
	var sm := kit.styled()
	var mat := deep()
	var edge := edge_kit()
	var k := 0
	for l in HOLE_DEPTH_LEDGES:
		var at := Vector2(lerpf(lo.x, hi.x, l.x), lerpf(lo.y, hi.y, l.y))
		sm.box(Vector3(at.x, l.z - HOLE_DEPTH_SLAB * 0.5, at.y), Vector3(l.w, HOLE_DEPTH_SLAB, l.w * 0.7), k * 0.6, mat, false)
		edge.rubble(Vector3(at.x, l.z, at.y), l.w * 0.5, 40 + k)
		k += 1


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
