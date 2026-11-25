class_name GuardianLook
extends ArenaRoom
## The look of the two guardians' houses (art pack 2026-11-23, docs/art/guardian_knight_hall.md and
## docs/art/guardian_elder_chamber.md), decoupled from CryptLook: one class, a variant per house (the layout's look id:
## &"armory" the Knight's hall, &"chapel" the Elder's chamber). Both are the squares of make_data's _guardian_house:
## tall walls on the north and the west (the back of the picture), the south and the east cut low like a model opened up,
## the north-east corner cut by a short tall wall, the way in at the west wall's middle, the doors of the layout.
## Everything drawn stands behind the floor's edge (or hangs over it above 2.6 m): what blocks is the layout's
## (ArenaObstacle, drawn by piece()); no round mark on the floor (those are Morvath's).
##
## Armory (the Knight): cool slate stone, a raised gallery with a balustrade over the north wall's alcoves, which hold
## weapon racks and armour stands of the fallen order, lion banners, warm braziers (the layout's two and two more at the
## way in), and iron spikes standing at the foot of the walls in the four corners (the spike plates and the falling
## stones are there). Chapel (the Elder): pale grey marble, the four columns whole with their capitals, an apse in the
## north wall with a dais, an altar and a lectern, three lancet windows over it and the coloured shaft they let in,
## candles on the ledges and in the stands at the way in.

## C-2 (AD2-07): the far ruins read as arches and pillars in the mist on the right of the picture, not as black (the
## backdrop's mist, stone and edge, lifted from the old 0.1, 0.05 and 0.16).
## Sweep 2026-11-25 (item 3): dark in the room's blue (the bank reads about luma 0.1), no longer a flat light grey-blue panel.
const BACKDROP := {&"mist": Color(0.075, 0.09, 0.125), &"stone": Color(0.035, 0.045, 0.065), &"edge": Color(0.17, 0.2, 0.27)}
## C-2: the painted floor's stone and patches times this (the fight's floor read luma 148 to 158; 85 to 100 asked).
const STY_FLOOR_VALUE := 0.5
## C-4: the warm pools of the braziers on the floor, [x offset from the room's middle, z offset from the north wall,
## radius, energy] (the armory's braziers stand at ARMORY_BOWLS; the chapel's candles at its north ledges).
const POOLS := {
	&"armory": [[-3.6, 3.4, 3.4, 2.6], [3.6, 3.4, 3.4, 2.6]],
	&"chapel": [[-8.0, 3.2, 3.4, 2.4], [6.5, 3.2, 3.4, 2.4]],
}

const ARMORY := &"armory"
const CHAPEL := &"chapel"

## What differs per house (every number of the look; the rest below is shared). wall: height of the tall walls; north:
## the north wall's thickness; stone: the cut stone's tint; floor: catacomb_floor's uniforms; air: air(); key: the soft
## light over the middle (colour, energy, height, shift, falloff, reach); fill: the floor-only fill (colour, energy,
## height, reach, falloff, where); wall_fill: ArenaRoom.wall_fill (colour, energy); style: the stylized biome; patch:
## the painted floor's second colour.
const HOUSES := {
	ARMORY: {
		&"wall": 7.6, &"north": 1.4, &"stone": Color(0.9, 0.94, 1.02),
		&"floor": {&"unit": 1.1, &"stone_a": Color(0.30, 0.31, 0.35), &"stone_b": Color(0.43, 0.44, 0.50),
			&"joint_color": Color(0.07, 0.075, 0.09), &"moss_color": Color(0.22, 0.23, 0.26), &"petal_color": Color(0.24, 0.25, 0.28),
			&"missing": 0.06, &"cracked": 0.35},
		&"air": {&"sky": Color(0.1, 0.11, 0.14), &"fog": Color(0.1, 0.11, 0.14), &"fog_depth": Vector2(40.0, 80.0),
			&"ambient": Color(0.34, 0.34, 0.38), &"ambient_gain": 2.1, &"moon": Color(0.62, 0.66, 0.74), &"moon_energy": 0.6,
			&"moon_shadow": false},
		&"key": [Color(0.86, 0.8, 0.74), 1.7, 11.0, Vector2(-2.0, 1.0), 0.5, 28.0],
		&"fill": [Color(0.8, 0.78, 0.8), 1.8, 6.0, 17.0, 0.6, Vector2(-6.0, 0.0)],
		&"wall_fill": [Color(0.8, 0.82, 0.9), 1.6],
		&"style": {
			&"stone": Color(0.235, 0.27, 0.315), &"shadow": Color(0.86, 0.92, 1.0), &"floor_stone": Color(0.225, 0.255, 0.295),
			&"joint_cold": Color(0.9, 0.95, 1.0), &"olive_share": 0.0, &"metal": true, &"pool_gain": 1.3,
			&"fire": {&"candle_range": 3.4, &"candle_gain": 2.0, &"bowl_range": 5.0, &"bowl_attenuation": 0.7, &"bowl_gain": 1.6,
				&"compat": 0.4},
			&"air": {&"sky": Color(0.05, 0.062, 0.085), &"fog": Color(0.095, 0.115, 0.15), &"fog_depth": Vector2(40.0, 85.0),
				&"ambient": Color(0.74, 0.78, 0.85), &"ambient_gain": 2.7, &"moon": Color(0.92, 0.96, 1.0), &"moon_energy": 0.9,
				&"moon_shadow": true},
			&"backdrop": BACKDROP,
			&"shadow_glow": Color(0.22, 0.34, 0.55), &"vignette": CatacombHall.STY_VIGNETTE,
		},
		&"patch": Color(0.3, 0.34, 0.42),
	},
	CHAPEL: {
		&"wall": 8.6, &"north": 3.4, &"stone": Color(0.98, 0.98, 1.0),
		&"floor": {&"unit": 1.4, &"stone_a": Color(0.34, 0.33, 0.34), &"stone_b": Color(0.48, 0.47, 0.48),
			&"joint_color": Color(0.085, 0.085, 0.095), &"moss_color": Color(0.24, 0.24, 0.26), &"petal_color": Color(0.27, 0.27, 0.29),
			&"missing": 0.03, &"cracked": 0.2},
		&"air": {&"sky": Color(0.12, 0.12, 0.14), &"fog": Color(0.12, 0.12, 0.14), &"fog_depth": Vector2(40.0, 85.0),
			&"ambient": Color(0.34, 0.33, 0.35), &"ambient_gain": 2.1, &"moon": Color(0.66, 0.68, 0.74), &"moon_energy": 0.6,
			&"moon_shadow": false},
		&"key": [Color(0.84, 0.82, 0.8), 1.6, 12.0, Vector2(-2.0, 0.0), 0.5, 30.0],
		&"fill": [Color(0.8, 0.8, 0.84), 1.7, 6.0, 18.0, 0.6, Vector2(-6.0, 0.0)],
		&"wall_fill": [Color(0.82, 0.83, 0.9), 1.6],
		&"style": {
			&"stone": Color(0.315, 0.322, 0.34), &"shadow": Color(0.88, 0.92, 1.0), &"floor_stone": Color(0.3, 0.305, 0.325),
			&"joint_cold": Color(0.92, 0.95, 1.0), &"olive_share": 0.0, &"metal": true, &"pool_gain": 1.2,
			&"fire": {&"candle_range": 3.6, &"candle_gain": 2.2, &"bowl_range": 4.5, &"bowl_attenuation": 0.7, &"bowl_gain": 1.3,
				&"compat": 0.4},
			&"air": {&"sky": Color(0.055, 0.06, 0.075), &"fog": Color(0.11, 0.12, 0.145), &"fog_depth": Vector2(40.0, 85.0),
				&"ambient": Color(0.78, 0.8, 0.86), &"ambient_gain": 2.6, &"moon": Color(0.94, 0.96, 1.0), &"moon_energy": 0.85,
				&"moon_shadow": true},
			&"backdrop": BACKDROP,
			&"shadow_glow": Color(0.3, 0.4, 0.6), &"vignette": CatacombHall.STY_VIGNETTE,
		},
		&"patch": Color(0.42, 0.43, 0.48),
	},
}
## The browser's renderer (Compatibility) leaves both rooms darker: there the ambient, the key and the fill are this much
## stronger, and the stylized air and moon this much of what they are.
const COMPAT_LIGHT := 1.4
const STY_COMPAT_AMBIENT := 0.7
const STY_COMPAT_MOON := 0.6
## The painted floor's frame (stylized): calm radius (m), edge value, edge span (the Salão's method, as the other rooms).
const STY_FRAME := {&"calm_radius": 6.0, &"edge_value": 0.6, &"edge_span": Vector2(1.1, 2.0)}

## The cut corner's tall wall runs this far past each end of the cut (into its neighbours' thickness).
const CORNER_OVER := 0.9
## The west wall is open at the way in (half width round the hero's spawn) with stairs going up out of it.
const ENTRY_HALF := 2.0
const ENTRY_STEPS := 6
const ENTRY_STEP := Vector2(0.2, 0.45)
## A fire bowl's recess in a tall wall (half width, height, depth behind the face), its floor a little over the sill; an
## alcove's (width, height, depth) with its floor RECESS_FLOOR high.
const RECESS := Vector3(0.55, 3.2, 1.25)
const ALCOVE := Vector3(1.9, 3.4, 0.95)
const RECESS_FLOOR := 0.06
const ALCOVE_FLOOR := 0.2
## Old gold, used only as a thin sill at the way in (the elite's colour stays rare): bar size.
const SILL_GOLD := Vector3(0.05, 0.008, 0.05)

# ---- armory ----
## The alcoves of the north wall (x of each; 0 a weapon rack, 1 an armour stand) and of the west wall (z of each).
const ARMORY_NORTH: Array[Vector2] = [Vector2(-8.6, 0), Vector2(-5.4, 1), Vector2(-2.2, 0)]
const ARMORY_WEST: Array[Vector2] = [Vector2(-7.6, 1), Vector2(7.6, 0)]
## The way in's two bowls (z of each, how far behind the edge).
const ARMORY_BOWLS: Array[float] = [-3.6, 3.6]
const ARMORY_BOWL_DEPTH := 0.9
## The gallery over the north alcoves: x from, to; its shelf's height and thickness, how far it hangs over the floor, the
## corbels' spacing; the balustrade stands on it.
const GALLERY_X := Vector2(-10.2, 0.2)
const GALLERY_Y := 3.75
const GALLERY_THICK := 0.3
const GALLERY_HANG := 0.35
const GALLERY_CORBEL := 1.9
## Lion banners (top, size) over the north wall's alcoves and bowls (x) and the west wall's bowls (z).
const ARMORY_BANNER_TOP := 7.3
const ARMORY_BANNER_SIZE := Vector2(1.1, 2.4)
const ARMORY_BANNERS_NORTH: Array[float] = [-8.6, -5.4, -2.2, 1.5, 7.1]
const ARMORY_BANNERS_WEST: Array[float] = [-3.6, 3.6]
## Iron spikes at each corner's foot (count along each wall, spacing, height range, width, how far behind the edge): the
## danger's frame, grey iron.
const SPIKE_COUNT := 4
const SPIKE_GAP := 0.28
const SPIKE_HEIGHT := Vector2(0.55, 0.95)
const SPIKE_WIDTH := 0.1
const SPIKE_BEHIND := 0.12
## Props: the racks' wood and the petrol cloth of the tabards and shields.
const WOOD := Color(0.17, 0.12, 0.085)
const CLOTH := Color(0.045, 0.1, 0.115)
## The warm light in each north alcove (energy, reach, height).
const SCONCE := Vector3(0.9, 6.0, 2.4)

# ---- chapel ----
## The apse in the north wall (x from, to; depth behind the face; height of its arch), its dais (two steps: width, depth,
## height each), the altar (width, height, depth), the lectern's x.
const APSE_X := Vector2(-8.6, -2.4)
const APSE_DEPTH := 2.6
const APSE_ARCH := 5.6
const DAIS: Array[Vector3] = [Vector3(5.8, 2.4, 0.22), Vector3(4.6, 1.8, 0.44)]
const ALTAR := Vector3(2.4, 0.9, 1.0)
const LECTERN_X := -3.7
## The lancets over the altar (x from the apse's middle, width, bottom, height) and the glass colours: cold sky blue at
## the sides, dawn amber in the middle, no violet.
const LANCETS: Array[Vector4] = [Vector4(-1.7, 0.8, 4.6, 2.9), Vector4(0.0, 1.0, 4.6, 3.6), Vector4(1.7, 0.8, 4.6, 2.9)]
const LANCET_COLORS: Array[Color] = [Color(0.5, 0.68, 0.95), Color(1.0, 0.82, 0.46), Color(0.5, 0.68, 0.95)]
const LANCET_FRAME := 0.14
## The coloured shaft the window lets in: where it falls (x, z), colour, energy, cone, height; and in the stylized look
## (diffuse, no disc) its colour and energy.
const SHAFT_AT := Vector2(-2.0, -3.0)
const SHAFT := Color(0.66, 0.8, 1.0)
const SHAFT_ENERGY := 2.0
const SHAFT_CONE := 17.0
const SHAFT_HEIGHT := 14.0
const STY_SHAFT := Color(0.78, 0.86, 1.0)
const STY_SHAFT_ENERGY := 1.5
## The warm light over the altar's candles (energy, reach, height over the altar's top).
const ALTAR_LIGHT := Vector3(1.3, 7.0, 1.6)
## Candle groups on the sills (x on the north wall, z on the west wall; the first of each pair is lit with a light), how
## many candles in a group.
const CANDLES_NORTH: Array[float] = [-10.6, -0.4, 9.2]
const CANDLES_WEST: Array[float] = [-10.4, -6.8, 6.8, 10.4]
const GROUP_CANDLES := 3
const GROUP_LIGHT := 0.7
## The candle stands at the way in (z of each, height of the stem).
const STANDS: Array[float] = [-3.4, 3.4]
const STAND_HEIGHT := 1.5
## Blind lancet frames on the west wall (z of each) and their size (width, height, relief).
const FRAMES: Array[float] = [-8.0, -5.6, 5.6, 8.0]
const FRAME_SIZE := Vector3(1.4, 4.4, 0.3)

var _north := 0.0
var _west := 0.0
var _south := 0.0
var _east := 0.0
var _key: OmniLight3D
var _fill: OmniLight3D
var _shaft: SpotLight3D
var _wood: StandardMaterial3D
var _cloth: StandardMaterial3D
var _prop_stone: ShaderMaterial


## True for the Knight's hall.
func armory() -> bool:
	return layout.look == ARMORY


func _cfg() -> Dictionary:
	return HOUSES[ARMORY if armory() else CHAPEL]


func floor_look() -> Dictionary:
	return _cfg()[&"floor"]


func floor_layers() -> int:
	return 1 | FLOOR_LAYER


func stone_tint() -> Color:
	return _cfg()[&"stone"]


func air() -> Dictionary:
	var a: Dictionary = _cfg()[&"air"]
	if not compat():
		return a
	a = a.duplicate()
	a[&"ambient_gain"] = float(a[&"ambient_gain"]) * COMPAT_LIGHT
	return a


## The north door opens in the wall.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5


## No cliffs: the walls are drawn in dress; a door's mouth drops into the dark.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		cliff(a, b, out, faces, EXIT_STEPS * EXIT_RISE + 0.6)


## No abyss in a house.
func _abyss() -> void:
	pass


## A whole column gets its round capital (the chapel's four are the room's cover); the rest as ArenaRoom draws it.
func piece(o: ArenaObstacle) -> void:
	if o.piece == &"column" and o.height >= WHOLE_COLUMN:
		round_column(o)
		return
	super.piece(o)


func dress() -> void:
	BuildSteps.run(dress_steps())


func dress_steps() -> Array[Callable]:
	return [
		func() -> void:
			var wf: Array = _cfg()[&"wall_fill"]
			wall_fill(wf[0], float(wf[1]) * (COMPAT_LIGHT if compat() else 1.0))
			var box := layout.floor.bounds()
			_north = box.position.y
			_west = box.position.x
			_south = box.end.y
			_east = box.end.x
			_props(),
		_north_wall,
		_west_wall,
		_front_walls,
		_cut_corner,
		func() -> void:
			if armory():
				_armory_props()
			else:
				_chapel_props(),
		_lights,
	]


# ---------- the walls ----------

## The north wall: the fire bowls' recesses, the doors' openings, and the alcoves (armory) or the apse (chapel).
func _north_wall() -> void:
	var cfg := _cfg()
	var thick: float = cfg[&"north"]
	var mat := m.ashlar(0.0, stone_tint())
	var a := Vector2(_west - FACE_SET - FACE_THICK, _north)
	var cut := _cut_edge()
	var b := Vector2(_east + 1.2, _north)
	if cut.size() == 2:
		b.x = minf(cut[0].x, cut[1].x) + CORNER_OVER
	var open: Array[Vector4] = []
	var backs: Array[Vector4] = []
	var depths: Array[float] = []
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < _north:
			var s := o.center.x - a.x
			var r := Vector4(s - RECESS.x, s + RECESS.x, RECESS_FLOOR, RECESS.y)
			open.append(r)
			backs.append(r)
			depths.append(RECESS.z)
	for i in layout.exits.size():
		if in_wall(i):
			var e := layout.exits[i]
			var w := absf(e.mouth.size.x)
			var cx := e.mouth.get_center().x - a.x
			open.append(Vector4(cx - w * 0.5 - JAMB, cx + w * 0.5 + JAMB, 0.0, WALL_DOOR.y + 0.4))
	if armory():
		for al in ARMORY_NORTH:
			var s := al.x - a.x
			var r := Vector4(s - ALCOVE.x * 0.5, s + ALCOVE.x * 0.5, ALCOVE_FLOOR, ALCOVE.y)
			open.append(r)
			backs.append(r)
			depths.append(ALCOVE.z)
	else:
		var r := Vector4(APSE_X.x - a.x, APSE_X.y - a.x, 0.0, APSE_ARCH)
		open.append(r)
		backs.append(r)
		depths.append(APSE_DEPTH)
	wall(a, b, Vector2(0, -1), float(cfg[&"wall"]), open, mat, thick)
	for i in backs.size():
		wall_part(a, b, Vector2(0, -1), backs[i].x, backs[i].y, FACE_SET + depths[i], FACE_SET + thick, 0.0, backs[i].w, mat)


## The west wall: the way in with its arch, stairs and sill; in the armory the bowls' recesses and the alcoves.
func _west_wall() -> void:
	var mat := m.ashlar(0.0, stone_tint())
	var a := Vector2(_west, _south)
	var b := Vector2(_west, _north)
	var mid := 0.0  # PT-6: the west arch stays as it was (sealed); he now comes in from the south
	var open: Array[Vector4] = [Vector4(a.y - mid - ENTRY_HALF - JAMB, a.y - mid + ENTRY_HALF + JAMB, 0.0, WALL_DOOR.y + 0.4)]
	var backs: Array[Vector4] = []
	var depths: Array[float] = []
	if armory():
		for z in ARMORY_BOWLS:
			var r := Vector4(a.y - z - RECESS.x, a.y - z + RECESS.x, RECESS_FLOOR, RECESS.y)
			open.append(r)
			backs.append(r)
			depths.append(RECESS.z)
		for al in ARMORY_WEST:
			var r := Vector4(a.y - al.x - ALCOVE.x * 0.5, a.y - al.x + ALCOVE.x * 0.5, ALCOVE_FLOOR, ALCOVE.y)
			open.append(r)
			backs.append(r)
			depths.append(ALCOVE.z)
	wall(a, b, Vector2(-1, 0), float(_cfg()[&"wall"]), open, mat)
	for i in backs.size():
		wall_part(a, b, Vector2(-1, 0), backs[i].x, backs[i].y, FACE_SET + depths[i], FACE_SET + FACE_THICK, 0.0, backs[i].w, mat)
	# the way in: its arch, stairs going up out of the room, a thin old gold sill on the edge
	var w := ENTRY_HALF * 2.0
	door_arch(Vector2(_west, mid), Vector2(1, 0), w)
	m.stairs(Vector3(_west - 0.05, 0.0, mid), Vector2(-1, 0), w, ENTRY_STEPS, ENTRY_STEP.x, ENTRY_STEP.y, m.stone(0.0, stone_tint() * 0.8))
	tomb.bar(Vector3(_west + 0.04, SILL_GOLD.y * 0.5, mid), Vector3(SILL_GOLD.x, SILL_GOLD.y, w), 0.0, tomb.gold())


## The south and the east walls, cut low (ArenaRoom.cut_wall) with the doors' gaps.
func _front_walls() -> void:
	var skin := m.ashlar(0.0, stone_tint() * 0.9)
	var cut := _cut_edge()
	var east_end := _north
	if cut.size() == 2:
		east_end = maxf(cut[0].y, cut[1].y)
	var s_a := Vector2(_west - FACE_SET - FACE_THICK, _south)
	var s_b := Vector2(_east + CUT_WALL.y, _south)
	cut_wall(s_a, s_b, Vector2(0, 1), door_gaps(s_a, s_b, Vector2(0, 1)), skin)
	var e_a := Vector2(_east, _south)
	var e_b := Vector2(_east, east_end)
	cut_wall(e_a, e_b, Vector2(1, 0), door_gaps(e_a, e_b, Vector2(1, 0)), skin)


## The two points of the floor's outline that are neither along x nor along z (the cut corner), or empty.
func _cut_edge() -> Array[Vector2]:
	var poly := layout.floor.polys[0]
	var found: Array[Vector2] = []
	for i in poly.size():
		var p := poly[i]
		var q := poly[(i + 1) % poly.size()]
		if absf(p.x - q.x) > 0.5 and absf(p.y - q.y) > 0.5:
			found = [p, q]
	return found


## The cut north-east corner: a tall wall along the cut, running CORNER_OVER into its neighbours.
func _cut_corner() -> void:
	var cut := _cut_edge()
	if cut.size() != 2:
		return
	var along := (cut[1] - cut[0]).normalized()
	var out := Vector2(along.y, -along.x)
	if layout.floor.covers((cut[0] + cut[1]) * 0.5 + out * 0.3):
		out = -out
	wall(cut[0] - along * CORNER_OVER, cut[1] + along * CORNER_OVER, out, float(_cfg()[&"wall"]), [], m.ashlar(0.0, stone_tint()))


# ---------- props ----------

## The racks' wood, the petrol cloth and the props' stone (never the reserved four: warning red, Emeth, Morvath's violet,
## old gold).
func _props() -> void:
	_wood = StandardMaterial3D.new()
	_wood.albedo_color = WOOD
	_wood.roughness = 0.9
	_cloth = StandardMaterial3D.new()
	_cloth.albedo_color = CLOTH
	_cloth.roughness = 1.0
	_prop_stone = m.stone(0.0, stone_tint() * 0.8)


## A part of a prop: `local` in the frame `xf` (facing +z), `size`, a tilt (about the local z) and a lean (about x).
func _part_at(xf: Transform3D, local: Vector3, size: Vector3, mat: Material, tilt := 0.0, lean := 0.0) -> MeshInstance3D:
	var yaw := atan2(xf.basis.z.x, xf.basis.z.z)
	var mi := m.box(xf * local, size, yaw, mat, false)
	if tilt != 0.0:
		mi.rotate_object_local(Vector3.BACK, tilt)
	if lean != 0.0:
		mi.rotate_object_local(Vector3.RIGHT, lean)
	return mi


## The frame of a prop standing `depth` behind the edge at `at` (on the edge), facing `facing` (into the room).
func _frame_at(at: Vector2, facing: Vector2, depth: float, y := 0.0) -> Transform3D:
	var p := at - facing * depth
	return Transform3D(Basis(Vector3.UP, atan2(facing.x, facing.y)), Vector3(p.x, y, p.y))


# ---------- the armory ----------

func _armory_props() -> void:
	var sconce_y := SCONCE.z
	for al in ARMORY_NORTH:
		_alcove(_frame_at(Vector2(al.x, _north), Vector2(0, 1), FACE_SET + 0.6, ALCOVE_FLOOR), int(al.y))
		warm_light(Vector3(al.x, sconce_y, _north - FACE_SET - 0.2), SCONCE.x, false, SCONCE.y)
	for al in ARMORY_WEST:
		_alcove(_frame_at(Vector2(_west, al.x), Vector2(1, 0), FACE_SET + 0.6, ALCOVE_FLOOR), int(al.y))
	for z in ARMORY_BOWLS:
		kit.brazier(Vector2(_west - ARMORY_BOWL_DEPTH, z), RECESS_FLOOR, false)
	_gallery()
	for x in ARMORY_BANNERS_NORTH:
		kit.banner(Vector3(x, ARMORY_BANNER_TOP, _north - FACE_SET + 0.06), 0.0, ARMORY_BANNER_SIZE, 1, ArenaKit.Emblem.LION)
	for z in ARMORY_BANNERS_WEST:
		kit.banner(Vector3(_west - FACE_SET + 0.06, ARMORY_BANNER_TOP, z), PI * 0.5, ARMORY_BANNER_SIZE, 1, ArenaKit.Emblem.LION)
	_corner_spikes()


func _alcove(xf: Transform3D, kind: int) -> void:
	_part_at(xf, Vector3(0, 0.1, 0), Vector3(1.5, 0.2, 0.7), _prop_stone)
	if kind == 0:
		_rack(xf)
	else:
		_armour(xf)


## A weapon rack: two posts, two crossbars, spears with iron heads leaning a little, two swords on the lower bar.
func _rack(xf: Transform3D) -> void:
	var iron := tomb.iron()
	for sx: float in [-0.7, 0.7]:
		_part_at(xf, Vector3(sx, 1.2, 0.0), Vector3(0.09, 2.0, 0.09), _wood)
	for y: float in [0.8, 1.65]:
		_part_at(xf, Vector3(0, y, 0), Vector3(1.5, 0.07, 0.07), _wood)
	var xs: Array[float] = [-0.5, -0.17, 0.18, 0.5]
	for i in xs.size():
		var lean := 0.04 * (i - 1.5)
		_part_at(xf, Vector3(xs[i], 1.65, 0.1), Vector3(0.035, 2.5, 0.035), _wood, lean)
		var head := m.point(xf * Vector3(xs[i] - sin(lean) * 1.25, 2.9, 0.1), 0.1, 0.3, 0.0, 0.0, iron)
		head.rotate_object_local(Vector3.BACK, lean)
	for sx: float in [-0.25, 0.3]:
		_part_at(xf, Vector3(sx, 1.25, 0.12), Vector3(0.07, 0.95, 0.025), iron)
		_part_at(xf, Vector3(sx, 1.75, 0.12), Vector3(0.28, 0.05, 0.05), iron)


## An armour stand: a post on a base, the breastplate, pauldrons, a helm with a crest of the petrol cloth, a tabard,
## a round shield leaning at its foot.
func _armour(xf: Transform3D) -> void:
	var iron := tomb.iron()
	_part_at(xf, Vector3(0, 0.25, 0), Vector3(0.7, 0.1, 0.55), _wood)
	_part_at(xf, Vector3(0, 0.75, 0), Vector3(0.07, 1.0, 0.07), _wood)
	_part_at(xf, Vector3(0, 1.4, 0), Vector3(0.52, 0.62, 0.3), iron)
	_part_at(xf, Vector3(0, 1.1, 0.16), Vector3(0.36, 0.5, 0.025), _cloth)
	for sx: float in [-0.34, 0.34]:
		_part_at(xf, Vector3(sx, 1.68, 0.0), Vector3(0.22, 0.14, 0.26), iron)
		_part_at(xf, Vector3(sx * 1.05, 1.35, 0.0), Vector3(0.12, 0.5, 0.16), iron)
	var helm := m.shaft(Vector3.ZERO, 0.16, 0.3, iron)
	helm.position = xf * Vector3(0, 1.88, 0)
	_part_at(xf, Vector3(0, 2.1, -0.02), Vector3(0.04, 0.14, 0.3), _cloth)
	var tilt := Basis(Vector3.RIGHT, PI * 0.5 - 0.28)
	var shield := m.shaft(Vector3.ZERO, 0.4, 0.06, _cloth)
	shield.transform = Transform3D(xf.basis * tilt, xf * Vector3(0.3, 0.42, 0.34))
	var rim := m.shaft(Vector3.ZERO, 0.43, 0.04, iron)
	rim.transform = Transform3D(xf.basis * tilt, xf * Vector3(0.3, 0.4, 0.32))


## The raised gallery's shelf over the north alcoves: a slab hanging GALLERY_HANG over the floor's edge (above 2.6 m, so
## nothing of it stands on the floor), corbels under it, a balustrade along its lip.
func _gallery() -> void:
	var mat := ashlar()
	var x0 := GALLERY_X.x
	var x1 := GALLERY_X.y
	var back_z := _north - FACE_SET - 0.6
	var front_z := _north + GALLERY_HANG
	var mid_z := (back_z + front_z) * 0.5
	m.box(Vector3((x0 + x1) * 0.5, GALLERY_Y - GALLERY_THICK * 0.5, mid_z), Vector3(x1 - x0, GALLERY_THICK, front_z - back_z), 0.0, mat, false)
	var n := maxi(2, roundi((x1 - x0) / GALLERY_CORBEL))
	for i in n + 1:
		var x := lerpf(x0 + 0.3, x1 - 0.3, float(i) / n)
		m.box(Vector3(x, GALLERY_Y - GALLERY_THICK - 0.25, mid_z), Vector3(0.35, 0.5, front_z - back_z - 0.1), 0.0, mat, false)
	var lip := front_z - 0.15
	m.balustrade(Vector3(x0 + 0.2, GALLERY_Y, lip), Vector3(x1 - 0.2, GALLERY_Y, lip), true, mat)


## Iron spikes at the foot of the walls in the four corners, outside the edge (on the walls' sill; on the low walls' top):
## the danger's frame. Each corner: its point, the two ways along its walls into the room, the height each wall's top is.
func _corner_spikes() -> void:
	var iron := tomb.iron()
	var r := RandomNumberGenerator.new()
	r.seed = hash(layout.id)
	var low := CUT_WALL.x
	var sill := 0.06
	var corners: Array = [[Vector2(_west, _north), Vector2(0, 1), Vector2(1, 0), sill, sill],
		[Vector2(_west, _south), Vector2(0, -1), Vector2(1, 0), sill, low],
		[Vector2(_east, _south), Vector2(0, -1), Vector2(-1, 0), low, low]]
	for c: Array in corners:
		var at: Vector2 = c[0]
		var u: Vector2 = c[1]
		var v: Vector2 = c[2]
		for k in SPIKE_COUNT:
			var d := 0.25 + SPIKE_GAP * k
			_spike(at + u * d - v * SPIKE_BEHIND, float(c[3]), iron, r)
			_spike(at + v * d - u * SPIKE_BEHIND, float(c[4]), iron, r)
	var cut := _cut_edge()
	if cut.size() != 2:
		return
	var along := (cut[1] - cut[0]).normalized()
	var out := Vector2(along.y, -along.x)
	if layout.floor.covers((cut[0] + cut[1]) * 0.5 + out * 0.3):
		out = -out
	for k in SPIKE_COUNT:
		var d := 0.3 + SPIKE_GAP * k
		_spike(cut[0] + along * d + out * SPIKE_BEHIND, sill, iron, r)
		_spike(cut[1] - along * d + out * SPIKE_BEHIND, sill, iron, r)


func _spike(p: Vector2, y: float, iron: Material, r: RandomNumberGenerator) -> void:
	m.point(Vector3(p.x, y, p.y), SPIKE_WIDTH, r.randf_range(SPIKE_HEIGHT.x, SPIKE_HEIGHT.y), r.randf() * TAU, 0.0, iron)


# ---------- the chapel ----------

func _chapel_props() -> void:
	_apse()
	# the blind lancet frames of the west wall, between the way in and the corners
	var mat := ashlar()
	for z in FRAMES:
		m.pointed_arch(Vector3(_west - FACE_SET * 0.5, 0.0, z), Vector2(1, 0), FRAME_SIZE.x, FRAME_SIZE.y, 0.2, FRAME_SIZE.z, mat)
	# candles in groups on the walls' sill (the first of each wall with a light), the stands at the way in
	for i in CANDLES_NORTH.size():
		candles(Vector3(CANDLES_NORTH[i], RECESS_FLOOR, _north - 0.18), GROUP_CANDLES, true, i == 0, false, GROUP_LIGHT)
	for i in CANDLES_WEST.size():
		candles(Vector3(_west - 0.18, RECESS_FLOOR, CANDLES_WEST[i]), GROUP_CANDLES, true, i == 0, false, GROUP_LIGHT)
	for z in STANDS:
		_stand(Vector3(_west - 0.18, 0.0, z))


## A tall iron candle stand with a dish of candles, standing just behind the edge.
func _stand(at: Vector3) -> void:
	var iron := tomb.iron()
	m.shaft(at, 0.07, STAND_HEIGHT, iron)
	m.shaft(at, 0.16, 0.08, iron)
	m.shaft(at + Vector3(0, STAND_HEIGHT, 0), 0.2, 0.05, iron)
	candles(at + Vector3(0, STAND_HEIGHT + 0.05, 0), 4, true, true, false, 0.9)


## The apse behind the north wall's opening: its arch, a floor, a dais of two steps, the altar with its cloth, the
## lectern, tall candles, the three lancets in its back wall, the warm light over the altar and the coloured shaft.
func _apse() -> void:
	var cx := (APSE_X.x + APSE_X.y) * 0.5
	var width := APSE_X.y - APSE_X.x
	var face_z := _north - FACE_SET
	var back_z := face_z - APSE_DEPTH
	var mat := ashlar()
	door_arch(Vector2(cx, _north), Vector2(0, 1), width, FACE_SET + 0.45, APSE_ARCH)
	# the apse's floor (the wall's sill only reaches the face), then the dais from its back toward the room
	m.box(Vector3(cx, -0.3, (_north - FACE_SET + back_z) * 0.5), Vector3(width, 0.6, APSE_DEPTH + 0.02), 0.0, mat, false)
	var top := 0.0
	for d: Vector3 in DAIS:
		m.box(Vector3(cx, d.z * 0.5, back_z + d.y * 0.5 + 0.05), Vector3(d.x, d.z, d.y), 0.0, mat, false)
		top = d.z
	var altar := Vector3(cx, top, back_z + 0.3 + ALTAR.z * 0.5)
	m.box(altar + Vector3(0, ALTAR.y * 0.5, 0), ALTAR, 0.0, _prop_stone, false)
	m.box(altar + Vector3(0, ALTAR.y + 0.03, 0), Vector3(ALTAR.x + 0.2, 0.06, ALTAR.z + 0.2), 0.0, mat, false)
	m.box(altar + Vector3(0, ALTAR.y * 0.62, ALTAR.z * 0.5 + 0.02), Vector3(ALTAR.x * 0.7, ALTAR.y * 0.7, 0.03), 0.0, _cloth, false)
	for sx: float in [-0.8, 0.0, 0.8]:
		candles(altar + Vector3(sx, ALTAR.y + 0.06, 0.0), 3, true, false)
	for sx: float in [-1.9, 1.9]:
		var foot := Vector3(cx + sx, top, altar.z)
		m.shaft(foot, 0.04, 1.5, tomb.iron())
		candles(foot + Vector3(0, 1.5, 0), 2, true, false)
	# the lectern: a post and a slanted top, on the first step
	var lec := Vector3(LECTERN_X, DAIS[0].z, back_z + 2.1)
	m.box(lec + Vector3(0, 0.5, 0), Vector3(0.3, 1.0, 0.3), 0.0, _wood, false)
	var slope := m.box(lec + Vector3(0, 1.12, 0), Vector3(0.7, 0.07, 0.55), 0.0, _wood, false)
	slope.rotate_object_local(Vector3.RIGHT, -0.35)
	# the lancets: lit glass in stone frames
	var glass_z := back_z + 0.04
	for i in LANCETS.size():
		var l: Vector4 = LANCETS[i]
		var x := cx + l.x
		m.box(Vector3(x, l.z + l.w * 0.5, glass_z), Vector3(l.y + LANCET_FRAME * 2.0, l.w + LANCET_FRAME, 0.1), 0.0, mat, false)
		var pane := MeshInstance3D.new()
		pane.mesh = _lancet(l.y, l.w)
		pane.material_override = tomb.unlit(LANCET_COLORS[i])
		pane.position = Vector3(x, l.z, glass_z + 0.065)
		pane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pane.set_meta(&"air", true)
		add_child(pane)
	warm_light(altar + Vector3(0, ALTAR_LIGHT.z + ALTAR.y, 0.8), ALTAR_LIGHT.x, false, ALTAR_LIGHT.y)
	_shaft = moon_shaft(SHAFT_AT, SHAFT, SHAFT_ENERGY, SHAFT_CONE, SHAFT_HEIGHT, true, true)


## A lancet window's glass: a rectangle with a pointed head (its foot at the origin, facing +z).
func _lancet(width: float, height: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.BACK)
	var w := width * 0.5
	var shoulder := height - width
	var pts: Array[Vector3] = [Vector3(-w, 0, 0), Vector3(w, 0, 0), Vector3(w, shoulder, 0), Vector3(0, height, 0), Vector3(-w, shoulder, 0)]
	for tri: Array in [[0, 1, 2], [0, 2, 4], [4, 2, 3]]:
		for k: int in tri:
			st.add_vertex(pts[k])
	return st.commit()


# ---------- the light ----------

func _lights() -> void:
	var cfg := _cfg()
	var gain := COMPAT_LIGHT if compat() else 1.0
	var k: Array = cfg[&"key"]
	_key = key_light(k[0], float(k[1]) * gain, float(k[2]))
	_key.omni_attenuation = float(k[4])
	_key.omni_range = float(k[5])
	_key.position += Vector3((k[3] as Vector2).x, 0.0, (k[3] as Vector2).y)
	var f: Array = cfg[&"fill"]
	var at: Vector2 = f[5]
	_fill = OmniLight3D.new()
	_fill.position = Vector3(at.x, float(f[2]), at.y)
	_fill.light_color = f[0]
	_fill.light_energy = float(f[1]) * gain
	_fill.omni_range = float(f[3])
	_fill.omni_attenuation = float(f[4])
	_fill.light_cull_mask = FLOOR_LAYER
	add_child(_fill)
	var mid := layout.floor.bounds().get_center()
	var pools: Array = []
	for p: Array in POOLS[&"armory" if armory() else &"chapel"]:
		pools.append([mid.x + float(p[0]), _north + float(p[1]), p[2], p[3]])
	warm_pools(pools)


# ---------- the stylized look ----------

func style() -> Dictionary:
	var cfg := _cfg()
	var st: Dictionary = (cfg[&"style"] as Dictionary).duplicate(true)
	st[&"floor_stone"] = (st[&"floor_stone"] as Color) * STY_FLOOR_VALUE
	st[&"floor"] = ArenaKit.CALM_FLOOR.merged(ArenaKit.SOFT_PATCHES).merged({&"patch_color": (cfg[&"patch"] as Color) * STY_FLOOR_VALUE}).merged(STY_FRAME)
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	st[&"off"] = [_key, _fill]
	if _shaft != null:
		diffuse_lights([_shaft])
		VisualProfile.vary(_shaft, {&"light_color": STY_SHAFT, &"light_energy": STY_SHAFT_ENERGY})
	return st
