class_name BridgeLook
extends ArenaRoom
## The look of the Ponte dos Condenados (the bridge of the condemned, E5 spec docs/art/e5_spec.md section 2): long, open
## and windy. Platforms of blue-steel stone over a grey-blue abyss, joined by bridges of 5 m in arches (ArenaRoom.bridge,
## the Salão das Fendas' bridge; variant B one long bridge in three arches with a landing in its middle); the north
## edges of the platforms broken lips with the slabs standing out of the drop, the others and the platforms' faces low
## balustrades; a hooded statue on a plinth over the abyss at each end of a bridge, looking at it; the pylon of the
## layout (&"pylon") with two great chains climbing out of the picture to the north-west and one dropping into the
## abyss; banks of mist running sideways in the wind, a thread of violet far below, broken towers and far pylons in the
## haze. The moon is the light, cold and from above; amber lanterns at the bridges' heads. What blocks is the layout's
## (ArenaObstacle); the bridges and the landing are read from the floor (a polygon of four corners no wider than a
## bridge is a deck; a wider one between two decks is a landing).

## A deck at most this wide (z) is a bridge; its arches (a long bridge: one every BAY m).
const DECK_WIDE := 5.2
const BAY := 8.0
## The landing: its parapet, the statues on its outer corners (height), the deck's cornice under its wings.
const LANDING_STATUE := 2.2
## A statue at a bridge's end (spec 2.1): its height, its plinth (side, height over the floor), how far out over the
## abyss from the deck's side and into the gap from the platform, the pier under it down to this depth.
const HEAD_STATUE := 2.3
const HEAD_PLINTH := Vector2(1.1, 0.5)
const HEAD_OUT := Vector2(1.5, 1.0)
const HEAD_PIER := -6.0
## The pylon (spec 2.2): collars (heights), how much wider, the iron hooks of its chains, the chains (size, sag) to
## the north-west out of the picture and the one into the abyss.
const PYLON_COLLARS: Array[float] = [1.2, 3.6]
const PYLON_COLLAR := 0.3
const PYLON_CAP := 0.5
const CHAIN_SIZE := 2.0
const CHAIN_UP: Array[Vector3] = [Vector3(-16.0, 26.0, -30.0), Vector3(-6.0, 28.0, -34.0)]
const CHAIN_DOWN := Vector3(3.0, -14.0, -12.0)
const CHAIN_SAG := Vector2(2.5, 1.5)
## The way in (spec 2.4): stairs coming up from the west to the edge at the paladin's z (width).
const ENTRY_WIDE := 4.0
const ENTRY_STEPS := 6
## The posts each side of the way in: how far out of the edge and beside the stairs (clear of the floor).
const ENTRY_POST := 0.8
## The stone (spec 2.5): cold cut stone, the platforms' floor in blue steel.
const STONE := Color(0.94, 0.98, 1.05)
const FLOOR := {
	&"unit": 1.2, &"stone_a": Color(0.25, 0.27, 0.31), &"stone_b": Color(0.34, 0.37, 0.42),
	&"joint_color": Color(0.07, 0.08, 0.10), &"moss_color": Color(0.32, 0.34, 0.36), &"petal_color": Color(0.25, 0.27, 0.31),
	&"cracked": 0.5, &"missing": 0.12,
}
## The air (spec 2.5) and the moon (the light of the room, with shadow).
const AIR := {
	&"sky": Color(0.065, 0.07, 0.09), &"fog": Color(0.13, 0.14, 0.18), &"fog_depth": Vector2(55.0, 130.0),
	&"ambient": Color(0.32, 0.34, 0.40), &"ambient_gain": 2.05, &"moon": Color(0.68, 0.72, 0.84), &"moon_energy": 1.1,
	&"moon_shadow": true,
}
## The abyss: its grey-blue mist, the cliffs' stone, the light far below (only the depths), the thread of violet (a
## share of the rift's glow), the banks of mist running sideways (colour, alpha, height under the floor, drift; B
## higher and faster).
const MIST := Color(0.18, 0.21, 0.28)
const CLIFF := {&"stone_color": Color(0.05, 0.06, 0.08), &"edge_color": Color(0.12, 0.15, 0.2), &"mist_color": Color(0.18, 0.21, 0.28)}
const DEEP := Color(0.35, 0.42, 0.6)
const DEEP_ENERGY := 2.5
const DEEP_Y := -9.0
const VIOLET_SHARE := 0.4
const BANK := Color(0.2, 0.24, 0.32)
const BANK_ALPHA := Vector2(0.2, 0.3)
const BANK_Y := Vector2(-4.0, -1.6)
const BANK_DRIFT := Vector2(0.015, 0.03)
## The far: ruins in the haze to the north and west (their towers and pylons are the cards' own).
const RUIN_DIST: Array[float] = [70.0, 95.0]
const RUIN_HAZE: Array[float] = [0.35, 0.6]
const RUIN_SIZE := Vector2(320.0, 110.0)
const RUIN_TOP := 20.0
const RUIN_STONE := Color(0.035, 0.045, 0.07)
const RUIN_EDGE := Color(0.12, 0.16, 0.24)

var _decks: Array[Rect2] = []
var _landings: Array[Rect2] = []
var _long := false


func floor_look() -> Dictionary:
	return FLOOR


func stone_tint() -> Color:
	return STONE


func air() -> Dictionary:
	return AIR


func mist() -> Color:
	return MIST


func cliff_look() -> Dictionary:
	return CLIFF


## The bridges and the landing, from the floor's polygons (before anything is drawn).
func _floor() -> void:
	_read_floor()
	super._floor()


func _read_floor() -> void:
	_decks.clear()
	_landings.clear()
	var wide: Array[Rect2] = []
	for poly in layout.floor.polys:
		if poly.size() != 4:
			continue
		var r := Rect2(poly[0], Vector2.ZERO)
		for p in poly:
			r = r.expand(p)
		if r.size.y <= DECK_WIDE:
			_decks.append(r)
		else:
			wide.append(r)
	# a wide rect between two decks is a landing: the three are one long bridge
	for w in wide:
		var west := -1
		var east := -1
		for i in _decks.size():
			if absf(_decks[i].end.x - w.position.x) < 0.2:
				west = i
			if absf(_decks[i].position.x - w.end.x) < 0.2:
				east = i
		if west >= 0 and east >= 0:
			_landings.append(w)
			var joined := _decks[west].merge(_decks[east])
			var keep: Array[Rect2] = []
			for i in _decks.size():
				if i != west and i != east:
					keep.append(_decks[i])
			keep.append(joined)
			_decks = keep
			_long = true
	# C18 (ENV P1-2, Q-10 (a)): a wide rect lying across one deck (the B's long bridge is one deck through its landing)
	# is a landing too: the deck's parapets open along it and the landing's own go round its outer sides
	for w in wide:
		if w in _landings:
			continue
		for d in _decks:
			if w.position.x >= d.position.x - 0.2 and w.end.x <= d.end.x + 0.2 and w.position.y < d.position.y and w.end.y > d.end.y:
				_landings.append(w)
				_long = true
				break
	_decks.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)


## On a deck's side or a landing's (their parapets are the bridge's).
func _on_bridge(a: Vector2, b: Vector2) -> bool:
	var mid := (a + b) * 0.5
	for r in _decks + _landings:
		if mid.x > r.position.x - 0.1 and mid.x < r.end.x + 0.1 and mid.y > r.position.y - 0.1 and mid.y < r.end.y + 0.1:
			if absf(a.y - b.y) < 0.05 or absf(a.x - b.x) < 0.05:
				return true
	return false


## North edges of the platforms broken lips (spec 2.1); the others low balustrades (dotted on the ones the camera
## looks across), but none on the decks (their parapets) nor across the way in.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	if _on_bridge(a, b):
		return
	if out.y < -0.5:
		broken_lip(a, b, out, faces)
		return
	broken_edge(a, b, out, faces)
	var mid := (a + b) * 0.5
	if out.x < -0.9 and absf(mid.y - layout.hero_spawn.y) < ENTRY_WIDE * 0.5 + 0.2:
		return
	balustrade_edge(a, b, out, false)


## The abyss (spec 2.5): grey-blue mist, a cold light far below on the depths alone, a weak thread of violet in the
## gaps, banks of mist running sideways between the platforms and along the sides.
func _abyss() -> void:
	var b := arena.shape().bounds()
	kit.abyss(b.size * 0.5 + Vector2(10, 10), DEPTH, false, mist())
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var gaps: Array[float] = []
	for r in _decks:
		gaps.append(r.get_center().x)
	for x: float in gaps + [b.position.x - 6.0, b.end.x + 6.0]:
		var l := OmniLight3D.new()
		l.position = Vector3(x, DEEP_Y, b.get_center().y)
		l.light_color = DEEP
		l.light_energy = DEEP_ENERGY
		l.omni_range = 18.0
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		add_child(l)
	for x in gaps:
		kit.abyss_glow(Vector3(x, -16.0, b.get_center().y - 3.0), Vector2(8.0, 10.0), yaw, ArenaKit.ABYSS_GLOW_ENERGY * VIOLET_SHARE)
	var high := 1 if _long else 0
	var y := BANK_Y.y if _long else BANK_Y.x
	for x in gaps:
		for z: float in [b.position.y - 1.0, b.end.y + 1.0]:
			kit.mist_bank(Vector3(x, y, z), Vector2(9.0, 4.0 + high * 2.0), BANK, BANK_ALPHA.y, 0.0, 0.5, BANK_DRIFT[high])
	for z: float in [b.position.y - 6.0, b.end.y + 6.0]:
		kit.mist_bank(Vector3(b.get_center().x, y - 1.0, z), Vector2(b.size.x + 16.0, 5.0), BANK, BANK_ALPHA.x, 0.0, 0.6, BANK_DRIFT[high])


func dress() -> void:
	var east_most := _decks.size() - 1
	for i in _decks.size():
		var r := _decks[i]
		var open := Vector2.ZERO
		for w in _landings:
			if w.position.x > r.position.x and w.end.x < r.end.x:
				open = Vector2(w.position.x, w.end.x)
		var arches := maxi(1, roundi(r.size.x / BAY))
		# the bridge that leads to the battle (the east one) lights its heads with shadows (spec 2.5); B: its east end
		if _long:
			bridge(r, false, true, arches, open)
		else:
			bridge(r, i == east_most, i == east_most, arches, open)
		_head_statues(r)
	for w in _landings:
		_landing(w)
	_entry()
	_far()


# ---------- the bridges' ends, the landing ----------

## A hooded statue at each end of a bridge (spec 2.1): on a plinth over the abyss beside the deck (the west end on its
## south side, the east end on its north, opposite the lanterns), on a pier of the depths' stone, looking at the bridge.
func _head_statues(r: Rect2) -> void:
	var mat := ashlar()
	for end in 2:
		var west := end == 0
		var lip := r.position.x if west else r.end.x
		var side := r.end.y if west else r.position.y
		var away := 1.0 if west else -1.0
		var into := 1.0 if west else -1.0
		var at := Vector2(lip + into * HEAD_OUT.y, side + away * HEAD_OUT.x)
		m.block(Vector3(at.x, -0.4, at.y), Vector3(HEAD_PLINTH.x, HEAD_PLINTH.y + 0.4, HEAD_PLINTH.x), 0.0, mat)
		m.layers = 1 | ArenaKit.DEPTH_LAYER
		m.box(Vector3(at.x, (HEAD_PIER - 0.4) * 0.5, at.y), Vector3(HEAD_PLINTH.x - 0.1, -0.4 - HEAD_PIER, HEAD_PLINTH.x - 0.1), 0.0, deep(), false)
		m.layers = 1
		var look := r.get_center() - at
		kit.statue(at, atan2(look.x, look.y), HEAD_STATUE, HEAD_PLINTH.y, ArenaKit.STATUE_VALUE, false)


## The landing in the long bridge's middle (spec 2.3): its wings paved as the deck, the cornice under them, a parapet
## round its outer sides, a hooded statue on each outer corner (outside the floor).
func _landing(w: Rect2) -> void:
	var mat := ashlar()
	for z: Vector2 in [Vector2(w.position.y, w.position.y + (w.size.y - 5.0) * 0.5), Vector2(w.end.y - (w.size.y - 5.0) * 0.5, w.end.y)]:
		var wing := Rect2(w.position.x, z.x, w.size.x, z.y - z.x)
		deck(wing)
		m.box(Vector3(wing.get_center().x, -DECK * 0.5 - 0.02, wing.get_center().y), Vector3(wing.size.x + 0.6, DECK, wing.size.y + DECK_OUT), 0.0, mat, false)
	var mid := w.get_center()
	for z: float in [w.position.y - PARAPET.z, w.end.y + PARAPET.z]:
		parapet(Vector2(w.position.x - 0.1, z), Vector2(w.end.x + 0.1, z), Vector2(0.0, signf(z - mid.y)))
	for x: float in [w.position.x - PARAPET.z, w.end.x + PARAPET.z]:
		for zz: Vector2 in [Vector2(w.position.y, -2.5 - PARAPET.z), Vector2(2.5 + PARAPET.z, w.end.y)]:
			parapet(Vector2(x, zz.x), Vector2(x, zz.y), Vector2(signf(x - mid.x), 0.0))
	for c: Vector2 in [Vector2(w.position.x, w.position.y), Vector2(w.end.x, w.position.y), Vector2(w.position.x, w.end.y), Vector2(w.end.x, w.end.y)]:
		var out := Vector2(signf(c.x - w.get_center().x), signf(c.y - w.get_center().y))
		var at := c + out * 0.9
		m.block(Vector3(at.x, -0.4, at.y), Vector3(HEAD_PLINTH.x, HEAD_PLINTH.y + 0.4, HEAD_PLINTH.x), 0.0, mat)
		var look := w.get_center() - at
		kit.statue(at, atan2(look.x, look.y), LANDING_STATUE, HEAD_PLINTH.y, ArenaKit.STATUE_VALUE, false)


# ---------- the pylon, the way in, the far ----------

## The pylon of the layout (spec 2.2): cut stone with collars and a cap, opening round the paladin behind it, two great
## chains from its top to the north-west out of the picture and one down into the abyss.
func piece(o: ArenaObstacle) -> void:
	if o.piece != &"pylon":
		super.piece(o)
		return
	var mat := see(ashlar()) if o.see_through else ashlar()
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var size := Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0)
	var yaw := -o.yaw
	m.block(foot, Vector3(size.x + 0.3, 0.4, size.z + 0.3), yaw, mat)
	m.block(foot, Vector3(size.x, size.y - PYLON_CAP, size.z), yaw, mat)
	for y in PYLON_COLLARS:
		m.block(foot + Vector3(0, y, 0), Vector3(size.x + PYLON_COLLAR, 0.3, size.z + PYLON_COLLAR), yaw, mat)
	m.block(foot + Vector3(0, size.y - PYLON_CAP, 0), Vector3(size.x + PYLON_COLLAR, PYLON_CAP, size.z + PYLON_COLLAR), yaw, mat)
	var top := foot + Vector3(0, size.y - 0.2, 0)
	for k in CHAIN_UP.size():
		var from := top + Vector3((k - 0.5) * size.x * 0.6, 0, -size.z * 0.3)
		kit.chain(from, CHAIN_UP[k], CHAIN_SAG.x, CHAIN_SIZE)
	# the third one from its back down into the abyss
	kit.chain(foot + Vector3(0, size.y * 0.5, -size.z * 0.5), CHAIN_DOWN, CHAIN_SAG.y, CHAIN_SIZE)


## The way in (spec 2.4): a landing and stairs coming up from the west to the edge, posts beside them, the gold sill.
func _entry() -> void:
	var west := layout.floor.bounds().position.x
	var mid := layout.hero_spawn.y
	var w := ENTRY_WIDE
	m.block(Vector3(west - 1.2, -0.62, mid), Vector3(2.4, 0.6, w), 0.0, stone(), false)
	m.stairs(Vector3(west - 2.4 - 0.45 * ENTRY_STEPS, -0.02 - 0.2 * ENTRY_STEPS, mid), Vector2(1, 0), w, ENTRY_STEPS, 0.2, 0.45)
	for sd: float in [-1.0, 1.0]:
		m.post(Vector3(west - ENTRY_POST, 0.0, mid + sd * (w * 0.5 + ENTRY_POST)), 0.0, 1.1, stone())
	tomb.bar(Vector3(west + 0.04, 0.004, mid), Vector3(0.05, 0.008, w), 0.0, tomb.gold())


## The far (spec 2.5): broken towers and pylons in the haze to the north and west (two ruin cards).
func _far() -> void:
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var c := layout.cam_bounds.get_center() if layout.cam_bounds.has_area() else layout.floor.bounds().get_center()
	var eye := Vector3(c.x, 0, c.y) + Feel.cam_offset_of(Feel.live().cam_distance, Feel.live().cam_pitch, Feel.live().cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	for k in RUIN_DIST.size():
		var at := Vector3(eye.x, RUIN_TOP - RUIN_SIZE.y * 0.5, eye.z) + ahead * RUIN_DIST[k]
		kit.ruin_card(at, RUIN_SIZE, yaw, MIST, RUIN_HAZE[k], 8.0 - k * 2.0, 3.0 + k * 13.0, Vector2(-4.0, 6.0), Vector2(-12.0, -28.0))
		var card := get_child(get_child_count() - 1) as MeshInstance3D
		var cm := card.material_override as ShaderMaterial
		cm.set_shader_parameter(&"stone_color", RUIN_STONE)
		cm.set_shader_parameter(&"edge_color", RUIN_EDGE)
