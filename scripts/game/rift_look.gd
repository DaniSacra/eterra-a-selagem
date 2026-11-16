class_name RiftLook
extends ArenaRoom
## The look of the Salão das Fendas (the hall of the rifts), spec docs/art/cycle12_arenas_spec.md section 3: a big hall
## split by a long rift of abyss, crossed by two bridges of stone in arches (variant B: the north one fell, its stumps
## left, pieces hanging by a chain, violet mist rising where it was) or round its south end. The west lip of the rift
## has a broken balustrade, the east one is a bare edge with a thread of old gold inlaid along it, as is the hole on
## a platform; violet light comes up from inside; the north facade of the east platform holds the door of X1 under a
## porch with two fire bowls, two hooded statues with empty hands and two banners with the lion; the outer edges stand
## over the abyss behind low balustrades, a tower and two great chains across the top of the picture, far ruins in a
## violet mist. What blocks is the layout's (ArenaObstacle), drawn by ArenaRoom.piece; this draws the rest and the air.

## The decks of the bridges over the rift (Rect2 on the floor: the walkable 5 m and the rift's width under them); a
## bridge stands when the floor covers its middle (variant B: the north one fell).
const BRIDGES: Array[Rect2] = [Rect2(-7.0, -12.0, 9.0, 5.0), Rect2(-7.0, -1.0, 9.0, 5.0)]
## A bridge: its deck's thickness under the floor (the cornice), the low parapet (height, width) outside the 5 m, the
## arch under it (its crown this far under the deck, the ring's width), the piers going down into the mist.
const DECK := 0.6
const PARAPET := Vector2(0.9, 0.5)
const ARCH_CROWN := 2.5
const ARCH_RING := 0.7
const ARCH_RADIUS := 0.8
## Its lanterns (one at each head, diagonally; the first of each with shadow, spec 3.5): warm, a little stronger.
const BRIDGE_LAMP_ENERGY := 1.5
const BRIDGE_LAMP_RANGE := 4.5
## The fallen bridge (variant B): how much of the deck stays at each head (m), the chain and the hanging pieces.
const STUMP := 1.5
const HANGING := 2
## The rift lies between these x (its middle splits its west and east lips).
const RIFT_X := Vector2(-8.0, 3.0)
## The facade of the east platform (spec 3.5): its height, thickness, the porch round the door (x from, to; depth;
## its floor raised this much, not walkable), the statues (x) and banners (x; top; size).
const FACADE_HEIGHT := 10.0
const FACADE_THICK := 2.0
const PORCH := Vector4(7.4, 16.6, 1.4, 0.45)
const STATUES: Array[float] = [4.6, 19.4]
const STATUE := 3.4
const BANNERS: Array[float] = [4.6, 19.4]
const BANNER_TOP := 8.6
const BANNER_SIZE := Vector2(1.5, 3.4)
const BUTTRESS := Vector2(1.2, 0.8)
## The way in on the west edge (z from, to) and its stairs coming up.
const ENTRY := Vector2(4.5, 8.5)
const ENTRY_STEPS := 6
## The violet from below (spec 3.5): lights deep in the rift and the hole (colour, energy, depth), the glow cards along
## the rift, and the light that comes up over the lips and paints the slabs near them (energy, its reach, height).
const DEEP := Color(0.55, 0.25, 1.0)
const DEEP_ENERGY := 5.0
const DEEP_Y := -10.0
const DEEP_SPOTS: Array[float] = [-9.0, -2.0, 5.0]
## The violet over the lips: where along the rift (z; never over a bridge: one more where the fallen one was).
const LIP_SPOTS: Array[float] = [-14.0, -4.0, 7.0]
const LIP_FALLEN := -9.5
const LIP_LIGHT := Color(0.55, 0.3, 1.0)
const LIP_ENERGY := 3.0
const LIP_REACH := 7.5
const LIP_Y := 0.6
const GLOW_FOOT := -14.0
const GLOW_SIZE := Vector2(9.0, 13.0)
## Variant B: the violet stronger and a bank of violet mist where the bridge was.
const FALLEN_GAIN := 1.3
const FALLEN_MIST := Color(0.5, 0.3, 0.9)
const FALLEN_MIST_ALPHA := 0.25
## The tower beyond the north-west corner and the two great chains from it to the facade (from, to, sag), link size.
const TOWER := Vector3(-27.0, -24.0, 3.5)
const TOWER_TOP := 16.0
const CHAINS: Array[Array] = [
	[Vector3(-26.0, 14.0, -23.0), Vector3(3.0, 9.0, -16.6), 3.0],
	[Vector3(-26.0, 12.5, -22.0), Vector3(20.5, 8.5, -16.6), 4.5],
]
const CHAIN_SIZE := 2.6
## Far ruins in the violet mist (distance from the camera, haze, column), the cards' size and top.
const RUIN_DIST: Array[float] = [80.0, 98.0]
const RUIN_HAZE: Array[float] = [0.35, 0.6]
const RUIN_COLUMN: Array[float] = [7.0, 5.0]
const RUIN_TOPS: Array[Vector2] = [Vector2(-2.0, 5.0), Vector2(-6.0, 6.0)]
const RUIN_SINK: Array[Vector2] = [Vector2(-10.0, -24.0), Vector2(-14.0, -30.0)]
const RUIN_SIZE := Vector2(300.0, 110.0)
const RUIN_TOP := 22.0
const RUIN_STONE := Color(0.05, 0.03, 0.09)
const RUIN_EDGE := Color(0.2, 0.12, 0.36)
const RUIN_MIST := Color(0.09, 0.05, 0.18)
## The cut stone, colder (spec 3.5); fallen blocks on the hole's lip nearest the camera.
const STONE := Color(0.92, 0.96, 1.06)
## The floor (spec 3.5): big slabs, bluer, cracked; the gold of the thread.
const FLOOR := {
	&"unit": 1.4, &"stone_a": Color(0.22, 0.23, 0.30), &"stone_b": Color(0.31, 0.32, 0.42),
	&"joint_color": Color(0.07, 0.07, 0.1), &"crack_color": Color(0.08, 0.04, 0.12), &"moss_color": Color(0.2, 0.2, 0.28),
	&"petal_color": Color(0.22, 0.23, 0.30), &"cracked": 0.45, &"missing": 0.12,
}
## The air (spec 3.5): blue-violet, the moon cold from behind.
const AIR := {
	&"sky": Color(0.04, 0.03, 0.10), &"fog": Color(0.10, 0.05, 0.20), &"fog_depth": Vector2(60.0, 140.0),
	&"ambient": Color(0.32, 0.30, 0.48), &"ambient_gain": 1.0, &"moon": Color(0.55, 0.65, 0.9), &"moon_energy": 0.3,
	&"moon_shadow": true,
}
## The soft key over the middle (no shadow), cold.
const KEY := Color(0.72, 0.74, 0.9)
const KEY_ENERGY := 6.5
## The abyss's mist, violet (the hall's is teal), and the cliffs' stone going down into it.
const MIST := Color(0.1, 0.05, 0.2)
const CLIFF := {&"stone_color": Color(0.06, 0.045, 0.11), &"edge_color": Color(0.2, 0.12, 0.34), &"mist_color": Color(0.1, 0.05, 0.2)}
## Blind pointed arches of an older building in the rift's walls (z of each, on both walls): their foot's depth, span,
## ring.
const OLD_ARCHES: Array[float] = [-14.0, -4.0, 7.0]
const OLD_ARCH := Vector3(-9.5, 3.2, 0.5)

var _fallen := false


func floor_look() -> Dictionary:
	return FLOOR


func mist() -> Color:
	return MIST


func cliff_look() -> Dictionary:
	return CLIFF


func stone_tint() -> Color:
	return STONE


func air() -> Dictionary:
	return AIR


## The north door (X1) opens in the facade.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5


## The bridge whose side runs along a to b (the edge between its deck and the rift), or -1.
func _bridge_side(a: Vector2, b: Vector2) -> int:
	var mid := (a + b) * 0.5
	for i in BRIDGES.size():
		var r := BRIDGES[i]
		if mid.x > r.position.x - 0.05 and mid.x < r.end.x + 0.05 and absf(a.y - b.y) < 0.05 \
				and (absf(mid.y - r.position.y) < 0.05 or absf(mid.y - r.end.y) < 0.05):
			return i
	return -1


func _in_rift(p: Vector2) -> bool:
	return p.x > RIFT_X.x and p.x < RIFT_X.y


func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	var mid := (a + b) * 0.5
	if kind == Edge.HOLE and _bridge_side(a, b) >= 0:
		return
	if kind == Edge.OUTER and out.y < -0.9 and mid.x > RIFT_X.y:
		# under the facade: no cliff, the facade stands on it
		return
	broken_edge(a, b, out, faces)
	if kind == Edge.HOLE:
		if _in_rift(mid + out * 2.0) and mid.x < (RIFT_X.x + RIFT_X.y) * 0.5 and out.x > 0.0:
			balustrade_edge(a, b, out, true)
		else:
			filet(a, b, out)
		return
	if out.x < -0.9 and mid.y > ENTRY.x - 0.1 and mid.y < ENTRY.y + 0.1:
		return
	balustrade_edge(a, b, out, false)


## The abyss under the hall and inside the rift: the mist, violet lights deep in the rift and the hole, the glow
## along the rift, the violet that comes up over the lips.
func _abyss() -> void:
	var b := arena.shape().bounds()
	kit.abyss(b.size * 0.5 + Vector2(8, 8), DEPTH, false, mist())
	_fallen = not layout.floor.covers(BRIDGES[0].get_center())
	var gain := FALLEN_GAIN if _fallen else 1.0
	var rift_mid := (RIFT_X.x + RIFT_X.y) * 0.5 + 0.5
	var spots: Array[Vector2] = []
	for z in DEEP_SPOTS:
		spots.append(Vector2(rift_mid, z))
	for h in layout.floor.holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		c /= maxf(1.0, h.size())
		if not _in_rift(c):
			spots.append(c)
	for s in spots:
		var l := OmniLight3D.new()
		l.position = Vector3(s.x, DEEP_Y, s.y)
		l.light_color = DEEP
		l.light_energy = DEEP_ENERGY * gain
		l.omni_range = 16.0
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		add_child(l)
	# the violet coming up over the lips (no shadow), never over a bridge
	var lips: Array[Vector2] = []
	for z in LIP_SPOTS:
		lips.append(Vector2(rift_mid, z))
	if _fallen:
		lips.append(Vector2(rift_mid, LIP_FALLEN))
	lips.append_array(spots.slice(DEEP_SPOTS.size()))
	for s in lips:
		var lip := OmniLight3D.new()
		lip.position = Vector3(s.x, LIP_Y, s.y)
		lip.light_color = LIP_LIGHT
		lip.light_energy = LIP_ENERGY * gain
		lip.omni_range = LIP_REACH
		lip.omni_attenuation = 1.6
		lip.light_cull_mask = ArenaKit.WARM_MASK
		add_child(lip)
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	for z: float in [-12.0, -5.0, 2.0, 7.5]:
		kit.abyss_glow(Vector3(rift_mid, GLOW_FOOT, z), GLOW_SIZE, yaw, ArenaKit.ABYSS_GLOW_ENERGY * gain)
	for s in spots.slice(DEEP_SPOTS.size()):
		kit.abyss_glow(Vector3(s.x, GLOW_FOOT, s.y), GLOW_SIZE * 0.75, yaw, ArenaKit.ABYSS_GLOW_ENERGY * gain)
	kit.abyss_fog(Vector3(rift_mid, -12.0, -3.0), Vector3(10.0, 10.0, 30.0))
	if _fallen:
		var r := BRIDGES[0]
		kit.mist_bank(Vector3(r.get_center().x, -3.0, r.get_center().y), Vector2(r.size.x + 2.0, 7.0), FALLEN_MIST, FALLEN_MIST_ALPHA)


func dress() -> void:
	for i in BRIDGES.size():
		if layout.floor.covers(BRIDGES[i].get_center()):
			_bridge(BRIDGES[i], i == 0)
		else:
			_fallen_bridge(BRIDGES[i])
	_hole_blocks()
	_old_arches()
	_facade()
	_entry()
	_far()
	key_light(KEY, KEY_ENERGY)


# ---------- the bridges ----------

## A bridge over the rift (spec 1.3): its deck under the floor's slabs, a low parapet outside the 5 m on each side,
## an arch of voussoirs under it with its crown ARCH_CROWN under the deck, piers down into the mist, a pillar with a
## lantern at each head (diagonally). first: the north bridge (its west head's lantern casts shadows; the south
## bridge's east one does).
func _bridge(r: Rect2, first: bool) -> void:
	var mat := ashlar()
	var cx := r.get_center().x
	var cz := r.get_center().y
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	m.box(Vector3(cx, -DECK * 0.5 - 0.02, cz), Vector3(r.size.x + 1.0, DECK, r.size.y + PARAPET.y * 2.0), 0.0, mat, false)
	# the arch: its crown ARCH_CROWN under the deck, springing from the rift's walls, and the fill over its haunches
	var span := r.size.x
	var rr := span * ARCH_RADIUS
	var hx := rr - span * 0.5
	var rise := sqrt((rr + ARCH_RING) * (rr + ARCH_RING) - hx * hx)
	var spring := -ARCH_CROWN - rise
	m.voussoir_arch(Vector3(cx, spring, cz), Vector2(0, 1), span, 0.0, ARCH_RING, r.size.y, mat, ARCH_RADIUS)
	var slices := 8
	for k in slices:
		var x0 := -span * 0.5 + span * k / slices
		var x1 := x0 + span / slices
		var xm := absf((x0 + x1) * 0.5)
		# the arch's outer curve over this slice (the arc whose centre is on the other side)
		var y := spring + sqrt(maxf(0.0, (rr + ARCH_RING) * (rr + ARCH_RING) - (xm + hx) * (xm + hx)))
		if y < -DECK - 0.05:
			m.box(Vector3(cx + (x0 + x1) * 0.5, (y - DECK) * 0.5, cz), Vector3(x1 - x0 + 0.02, -DECK - y, r.size.y * 0.92), 0.0, mat, false)
	for sd: float in [-1.0, 1.0]:
		var px := cx + sd * (span * 0.5 + 0.6)
		m.box(Vector3(px, (spring - DEPTH) * 0.5, cz), Vector3(1.6, DEPTH + spring, r.size.y * 0.9), 0.0, mat, false)
	m.layers = 1
	# the parapets, outside the walkable 5 m, and a pillar at each head (on the rift's side of the edge)
	for side: float in [r.position.y - PARAPET.y * 0.5, r.end.y + PARAPET.y * 0.5]:
		m.block(Vector3(cx, 0.0, side), Vector3(span - 0.2, PARAPET.x - 0.12, PARAPET.y), 0.0, mat)
		m.block(Vector3(cx, PARAPET.x - 0.12, side), Vector3(span, 0.12, PARAPET.y + 0.1), 0.0, mat, false)
	var heads: Array[Vector2] = [Vector2(r.position.x + 0.45, r.position.y - PARAPET.y * 0.5), Vector2(r.end.x - 0.45, r.end.y + PARAPET.y * 0.5)]
	var others: Array[Vector2] = [Vector2(r.end.x - 0.45, r.position.y - PARAPET.y * 0.5), Vector2(r.position.x + 0.45, r.end.y + PARAPET.y * 0.5)]
	for k in heads.size():
		var h := heads[k]
		var l := tomb.lantern(Vector3(h.x, 0.0, h.y), 0.0, stone(), TombKit.WARM, ~Arena.CROWD_LAYER, Vector3(0.5, 1.0, 0.5))
		l.light_energy = BRIDGE_LAMP_ENERGY
		l.omni_range = BRIDGE_LAMP_RANGE
		l.shadow_enabled = (k == 0) == first
	for h in others:
		m.post(Vector3(h.x, 0.0, h.y), 0.0, 1.0, stone())
		candles(Vector3(h.x, 1.0 + Masonry.POST_STEP.y + Masonry.POST_CAP.y, h.y), 3)


## The bridge that fell (spec 3.3): at each head STUMP meters of broken deck with its teeth, closed by the
## balustrade of the edge, and pieces of the deck hanging by chains into the rift.
func _fallen_bridge(r: Rect2) -> void:
	var mat := ashlar()
	var cz := r.get_center().y
	var rng := RandomNumberGenerator.new()
	rng.seed = 4410
	for sd: float in [-1.0, 1.0]:
		var edge_x := r.position.x if sd < 0.0 else r.end.x
		var x := edge_x - sd * STUMP * 0.5
		m.box(Vector3(x, -DECK * 0.5 - 0.08, cz), Vector3(STUMP, DECK, r.size.y), 0.0, mat, false)
		# the broken end: teeth of uneven length
		for k in 5:
			var z := r.position.y + r.size.y * (k + 0.5) / 5.0
			var l := rng.randf_range(0.2, 0.9)
			m.box(Vector3(x - sd * (STUMP * 0.5 + l * 0.5), -DECK * 0.5 - 0.1 - rng.randf_range(0.0, 0.15), z), Vector3(l, DECK * 0.8, r.size.y / 5.0 - 0.05), rng.randf_range(-0.1, 0.1), mat)
		# the parapet's stumps
		for side: float in [r.position.y - PARAPET.y * 0.5, r.end.y + PARAPET.y * 0.5]:
			m.block(Vector3(x, -0.1, side), Vector3(STUMP, PARAPET.x * rng.randf_range(0.4, 0.9), PARAPET.y), 0.0, mat)
		if sd > 0.0:
			# the east head is closed by a balustrade too (the west one has the rift's)
			balustrade_edge(Vector2(edge_x, r.position.y), Vector2(edge_x, r.end.y), Vector2(-1, 0), false)
	# pieces of the deck hanging on chains from the stumps
	for k in HANGING:
		var from := Vector3(r.position.x + STUMP * 0.8 if k == 0 else r.end.x - STUMP * 0.8, -0.4, r.position.y + 1.2 + k * 2.4)
		var to := from + Vector3(2.2 if k == 0 else -2.0, -4.5 - k, 0.4)
		kit.chain(from, to, 0.4, 1.2)
		var piece := m.box(to + Vector3(0, -0.5, 0), Vector3(1.6, 0.6, 2.2), rng.randf() * 0.6, mat)
		piece.rotate_object_local(Vector3.BACK, rng.randf_range(-0.6, 0.6))


## Blocks of cut stone fallen on the lip of the hole, at its two points nearest the camera (spec 3.1), off the floor.
func _hole_blocks() -> void:
	var cam := Vector2(sin(deg_to_rad(Feel.live().cam_yaw)), cos(deg_to_rad(Feel.live().cam_yaw)))
	for h in layout.floor.holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		c /= maxf(1.0, h.size())
		if _in_rift(c):
			continue
		var best: Array[Vector2] = []
		var pts := Array(h)
		pts.sort_custom(func(p: Vector2, q: Vector2) -> bool: return (p - c).dot(cam) > (q - c).dot(cam))
		for k in 2:
			var p: Vector2 = pts[k]
			var inside := c + (p - c) * 0.82
			m.box(Vector3(inside.x, -0.1, inside.y), Vector3(0.8, 0.6, 0.6), float(k) * 0.7 + 0.3, ashlar())


## The blind arches of an older building in the rift's walls (spec 3.1: no light of their own).
func _old_arches() -> void:
	var mat := m.depth_stone(MIST, 0.6, 1.4)
	m.layers = ArenaKit.DEPTH_LAYER
	for z in OLD_ARCHES:
		for sd: float in [-1.0, 1.0]:
			# the west wall faces east (+x), the east wall west
			var facing := Vector2(-sd, 0.0)
			var x := RIFT_X.x + 1.0 if sd < 0.0 else RIFT_X.y - 1.0
			var on := Vector2(x, z)
			# only where the wall stands (the floor behind it, the rift in front)
			if not layout.floor.covers(on - facing * 1.6) or layout.floor.covers(on + facing * 1.0):
				continue
			var wall_x := on.x - facing.x * 0.95
			var foot := Vector3(wall_x, OLD_ARCH.x, on.y)
			m.arch_ring(foot, facing, OLD_ARCH.y, OLD_ARCH.z, 0.3, mat, 0.8)
			for k: float in [-1.0, 1.0]:
				m.box(foot + Vector3(0, -2.0, k * (OLD_ARCH.y * 0.5 + 0.25)), Vector3(0.3, 4.0, 0.5), 0.0, mat, false)
	m.layers = 1


# ---------- the facade, the way in, the far ----------

## The facade over the east platform's north edge (spec 3.5): 10 m of cut stone with buttresses, the porch round the
## door of X1 (its floor raised, the fire bowls of the layout in it), the door's arch, two hooded statues with empty
## hands on plinths against it, two banners with the lion, a cornice.
func _facade() -> void:
	var north := layout.floor.bounds().position.y
	var x0 := RIFT_X.y - 0.5
	var x1 := layout.floor.bounds().end.x + 1.5
	var mat := ashlar()
	var face := north - 0.02
	# the wall, the porch cut back into it, the door's opening through the porch's back
	var door := Vector2.ZERO
	for i in layout.exits.size():
		if in_wall(i):
			var e := layout.exits[i]
			door = Vector2(e.mouth.position.x, e.mouth.end.x)
	_slab(x0, PORCH.x, face, face - FACADE_THICK, 0.0, FACADE_HEIGHT, mat)
	_slab(PORCH.y, x1, face, face - FACADE_THICK, 0.0, FACADE_HEIGHT, mat)
	var back := face - PORCH.z
	_slab(PORCH.x, door.x - JAMB, back, face - FACADE_THICK, 0.0, FACADE_HEIGHT, mat)
	_slab(door.y + JAMB, PORCH.y, back, face - FACADE_THICK, 0.0, FACADE_HEIGHT, mat)
	_slab(door.x - JAMB, door.y + JAMB, back, face - FACADE_THICK, WALL_DOOR.y + 0.5, FACADE_HEIGHT, mat)
	# the porch's raised floor beside the door's mouth, and its lintel
	_slab(PORCH.x, door.x, face, back, 0.0, PORCH.w, stone())
	_slab(door.y, PORCH.y, face, back, 0.0, PORCH.w, stone())
	_slab(PORCH.x - 0.4, PORCH.y + 0.4, face + 0.25, back, FACADE_HEIGHT - 3.2, FACADE_HEIGHT - 2.4, mat)
	door_arch(Vector2((door.x + door.y) * 0.5, north), Vector2(0, 1), door.y - door.x, PORCH.z + 0.45)
	# buttresses, a cornice
	for bx: float in [x0 + 0.6, PORCH.x - BUTTRESS.x * 0.5, PORCH.y + BUTTRESS.x * 0.5, x1 - 1.5]:
		m.block(Vector3(bx, 0.0, face - BUTTRESS.y * 0.5 - 0.02), Vector3(BUTTRESS.x, FACADE_HEIGHT - 1.2, BUTTRESS.y), 0.0, mat)
		m.point(Vector3(bx, FACADE_HEIGHT - 1.2, face - BUTTRESS.y * 0.5 - 0.02), BUTTRESS.x, 0.9, 0.0, 0.3, mat)
	_slab(x0, x1, face + 0.18, face - 0.6, FACADE_HEIGHT - 0.4, FACADE_HEIGHT, mat)
	# the statues on their plinths and their light, the banners
	for sx in STATUES:
		m.block(Vector3(sx, 0.0, face - 0.75), Vector3(1.3, 0.6, 1.3), 0.0, mat)
		kit.statue(Vector2(sx, face - 0.75), 0.0, STATUE, 0.6, ArenaKit.STATUE_VALUE, false)
		kit.statue_glow(Vector3(sx + 1.5, 3.5, face + 3.5), Vector3(sx, 2.2, face - 0.75), 1.6, 8.0, 35.0)
	for bx in BANNERS:
		kit.banner(Vector3(bx, BANNER_TOP, face + 0.06), 0.0, BANNER_SIZE, 1, ArenaKit.Emblem.LION)


## A block of the facade from x0 to x1, z0 to z1 (either order), y0 to y1.
func _slab(x0: float, x1: float, z0: float, z1: float, y0: float, y1: float, mat: Material) -> void:
	if absf(x1 - x0) < 0.02 or absf(z1 - z0) < 0.02 or y1 - y0 < 0.02:
		return
	m.box(Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, (z0 + z1) * 0.5), Vector3(absf(x1 - x0), y1 - y0, absf(z1 - z0)), 0.0, mat, false)


## The way in (spec 3.4): a landing and stairs coming up from the west to the edge, the gold sill on it.
func _entry() -> void:
	var west := layout.floor.bounds().position.x
	var mid := (ENTRY.x + ENTRY.y) * 0.5
	var w := ENTRY.y - ENTRY.x
	m.block(Vector3(west - 1.2, -0.62, mid), Vector3(2.4, 0.6, w), 0.0, stone(), false)
	m.stairs(Vector3(west - 2.4 - 0.45 * ENTRY_STEPS, -0.02 - 0.2 * ENTRY_STEPS, mid), Vector2(1, 0), w, ENTRY_STEPS, 0.2, 0.45)
	for sd: float in [-1.0, 1.0]:
		m.post(Vector3(west - 0.5, 0.0, mid + sd * (w * 0.5 + 0.5)), 0.0, 1.1, stone())
	tomb.bar(Vector3(west + 0.04, 0.004, mid), Vector3(0.05, 0.008, w), 0.0, tomb.gold())


## The far: the tower beyond the north-west corner, the great chains from it to the facade, the ruins in the mist.
func _far() -> void:
	var mat := m.depth_stone(RUIN_MIST, 0.4)
	m.layers = ArenaKit.DEPTH_LAYER
	m.box(Vector3(TOWER.x, (TOWER_TOP - DEPTH) * 0.5, TOWER.y), Vector3(TOWER.z, TOWER_TOP + DEPTH, TOWER.z), 0.3, mat, false)
	m.point(Vector3(TOWER.x, TOWER_TOP, TOWER.y), TOWER.z * 1.1, 3.0, 0.3, 0.0, mat)
	m.layers = 1
	for ch in CHAINS:
		kit.chain(ch[0], ch[1], ch[2], CHAIN_SIZE)
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var c := layout.cam_bounds.get_center()
	var eye := Vector3(c.x, 0, c.y) + Feel.cam_offset_of(Feel.live().cam_distance, Feel.live().cam_pitch, Feel.live().cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	for k in RUIN_DIST.size():
		var at := Vector3(eye.x, RUIN_TOP - RUIN_SIZE.y * 0.5, eye.z) + ahead * RUIN_DIST[k]
		kit.ruin_card(at, RUIN_SIZE, yaw, RUIN_MIST, RUIN_HAZE[k], RUIN_COLUMN[k], 7.0 + k * 11.0, RUIN_TOPS[k], RUIN_SINK[k])
		var card := get_child(get_child_count() - 1) as MeshInstance3D
		var cm := card.material_override as ShaderMaterial
		cm.set_shader_parameter(&"stone_color", RUIN_STONE)
		cm.set_shader_parameter(&"edge_color", RUIN_EDGE)
