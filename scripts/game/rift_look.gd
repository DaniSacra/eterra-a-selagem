class_name RiftLook
extends ArenaRoom
## The look of the Salão das Fendas (the hall of the rifts), spec docs/art/cycle12_arenas_spec.md section 3: a big hall
## split by a long rift of abyss, crossed by two bridges of stone in arches (variant B: the north one fell, its stumps
## left, pieces hanging by a chain, violet mist rising where it was) or round its south end. The west lip of the rift
## has a broken balustrade, the east one is a bare edge with a thread of old gold inlaid along it, as is the hole on
## a platform; the lips are broken (chunks of the brink standing out, stones missing); inside, the walls go dark at
## once and a violet haze fills it a few meters down (the art review's F-1 to F-6: the rift reads as one rift, the
## bridges as bridges with their own paving, kerbs, open parapets and the abutments they spring from); the north facade of the east platform holds the door of X1 under a
## porch with two fire bowls, two hooded statues with empty hands and two banners with the lion; the outer edges stand
## over the abyss behind low balustrades, a tower and two great chains across the top of the picture, far ruins in a
## violet mist. What blocks is the layout's (ArenaObstacle), drawn by ArenaRoom.piece; this draws the rest and the air.

## The decks of the bridges over the rift (Rect2 on the floor: the walkable 5 m and the rift's width under them); a
## bridge stands when the floor covers its middle (variant B: the north one fell).
const BRIDGES: Array[Rect2] = [Rect2(-7.0, -12.0, 9.0, 5.0), Rect2(-7.0, -1.0, 9.0, 5.0)]
## A bridge: its deck's thickness under the floor (the cornice) and how far it stands out of the walkable 5 m on each
## side (the parapet stands on it), the arch under it (its crown this far under the deck, the ring's width), the piers
## going down into the mist. The arch, its haunches and the piers are the depths' dark stone (no light of their own).
const DECK := 0.6
const DECK_OUT := 0.65
const ARCH_CROWN := 2.5
const ARCH_RING := 0.7
const ARCH_RADIUS := 0.8
## The deck's own paving over the floor (F-2, so a bridge never reads as a strip of the floor): slabs running along the
## span (length range, rows across between the kerbs, the joint, their top over the floor, their stone times the
## arena's), a kerb of lighter stone along both sides of the walkable 5 m (width, top, stone), a dark seam where the
## deck meets the platform (width), the joints' and seams' stone (the depths' dark).
const DECK_SLAB := Vector2(1.1, 2.1)
const DECK_ROWS := 4
const DECK_JOINT := 0.06
const DECK_TOP := 0.016
const DECK_TINT := Color(0.8, 0.8, 0.8)
const KERB := Vector3(0.3, 0.022, 1.1)
const SEAM := 0.08
const SEAM_TOP := 0.008
## The open parapet outside the walkable 5 m (spec 1.3: low, 0.5 m wide; never see-through): its height, its depth, its
## middle's distance out of the walkable edge; the curb and the rail (height, depth); balusters (side, spacing, the
## belly's side and height); a post every PARAPET_POST meters (side).
const PARAPET := Vector3(0.9, 0.4, 0.32)
const PARAPET_CURB := Vector2(0.18, 0.4)
const PARAPET_RAIL := Vector2(0.16, 0.38)
const BALUSTER := Vector4(0.13, 0.42, 0.2, 0.16)
const PARAPET_POST := 3.0
const PARAPET_POST_SIDE := 0.36
## A pillar at each of the four heads (F-2: 1.4 m; side, cap) and under each the abutment (F-3, "pegão") the bridge
## springs from: a block of cut stone against the rift's wall beside the deck (along the wall out of the walkable edge,
## into the rift, its cut stone this deep, then the depths' stone down to ABUTMENT_FOOT).
const HEAD := Vector3(0.55, 1.4, 0.2)
const HEAD_LANTERN := Vector3(0.5, 1.0, 0.5)
const ABUTMENT := Vector3(1.35, 1.1, 1.3)
const ABUTMENT_FOOT := -5.0
## Its lanterns (one at each head, diagonally; the first of each with shadow, spec 3.5): warm, a little stronger.
const BRIDGE_LAMP_ENERGY := 1.5
const BRIDGE_LAMP_RANGE := 4.5
## The rift's broken lips (spec 1.3, F-3): chunks of the brink's slabs standing out past the drop (length along the
## lip, how far out at each end, their top sunk under the floor), a stretch with none between them (a missing stone),
## each chunk's cut stone under its paving and the depths' stone hanging lower (heights); the ledge under the west
## lip's balustrade (out of the drop); stones hanging in a gap (share, size, depth).
const LIP_TOOTH := Vector2(0.4, 1.2)
const LIP_OUT := Vector2(0.3, 1.0)
const LIP_SINK := Vector2(0.03, 0.16)
const LIP_GAP := Vector2(0.3, 0.9)
const LIP_STONE := 0.45
const LIP_HANG := Vector2(1.2, 2.6)
const LIP_LEDGE := 1.05
const LIP_FALLEN_SHARE := 0.45
const LIP_FALLEN := Vector2(0.35, 0.7)
const LIP_FALLEN_DEPTH := Vector2(0.3, 1.1)
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
## The violet over the lips (F-1: no light, so nothing inside the rift is lit by it): a sheet of violet on the slabs
## along every lip of the rift and the holes, strongest at the drop and gone LIP_GLOW_WIDTH in (colour, alpha).
const LIP_GLOW_WIDTH := 1.5
const LIP_GLOW := Color(0.18, 0.07, 0.45)
const LIP_GLOW_ALPHA := 0.32
## The violet haze inside the rift and the holes (F-1, spec 3.5: the mist filling it under y -2): sheets at these
## heights (colour, alpha each), patchy and drifting, past the rift's north mouth fading out over the abyss
## (HAZE_NORTH: how far beyond the floor's north edge).
const HAZE_Y: Array[float] = [-1.5, -2.7, -4.4]
const HAZE_COLOR: Array[Color] = [Color(0.08, 0.022, 0.24), Color(0.13, 0.035, 0.4), Color(0.2, 0.055, 0.58)]
const HAZE_ALPHA: Array[float] = [0.4, 0.6, 1.0]
const HAZE_PATCHY: Array[float] = [0.9, 0.75, 0.35]
const HAZE_NORTH := 6.0
## How far the sheets reach past the holes' bounds (under the floor, hidden), and the share of a sheet faded at its
## ends; the lip strips' ends.
const HAZE_MARGIN := 1.0
const HAZE_FADE := 0.06
const LIP_GLOW_FADE := 0.1
## The height of what is painted over the floor (the lips' violet, the inscriptions).
const OVERLAY_Y := 0.01
## Forward+: the height fog filling the rift from y -2 down (spec 3.5).
const RIFT_FOG := Vector2(-2.0, -9.0)
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
## The air (spec 3.5): blue-violet, the moon cold from behind. F-4: the moon is the hall's key (no omni over the
## middle: its falloff left the far corners of the platforms at half the middle's value), a little more ambient.
const AIR := {
	&"sky": Color(0.04, 0.03, 0.10), &"fog": Color(0.10, 0.05, 0.20), &"fog_depth": Vector2(60.0, 140.0),
	&"ambient": Color(0.32, 0.30, 0.48), &"ambient_gain": 1.15, &"moon": Color(0.72, 0.74, 0.86), &"moon_energy": 0.8,
	&"moon_shadow": true,
}
## G-1: the browser's renderer (Compatibility, no contact shadows, lighting in other space) turns this air bluer and
## loses the red: there the ambient and the moon are more neutral and the ambient higher, and the violet haze is
## lifted (times its colours), so the same crops match the desktop within a few steps.
const AIR_COMPAT := {&"ambient": Color(0.44, 0.42, 0.56), &"ambient_gain": 1.5, &"moon": Color(0.86, 0.8, 0.82), &"moon_energy": 0.8}
const HAZE_COMPAT := 1.6
## The abyss's mist, violet (the hall's is teal), and the cliffs' stone going down into it (F-1, F-5): the depths'
## dark stone, nearly black 1.5 m under the brink (sink), the violet only further down (glow), no cold edge that
## would read as a lit wall.
const MIST := Color(0.1, 0.05, 0.2)
const CLIFF := {
	&"stone_color": Color(0.035, 0.026, 0.065), &"edge_color": Color(0.07, 0.045, 0.13), &"mist_color": Color(0.012, 0.006, 0.03),
	&"sink_top": -0.2, &"sink_bottom": -1.4, &"glow_color": Color(0.5, 0.24, 1.0), &"glow_energy": 0.06,
	&"glow_top": -2.0, &"glow_bottom": -10.0, &"glow_side": -20.0,
}
## The gold inscriptions between the rift and the hole (F-6, spec 3.5: straight runs and broken arcs, a carving
## under 15% contrast, never closed): straight runs along the rift's east lip (x; z from, to), arcs round the hole
## (radius out of its middle; bearings from, to, degrees: 0 north, 90 east), the band's width, a point every
## INSCRIPTION_STEP meters, the shader's strength.
const INSCRIPTION_RUNS: Array[Vector3] = [Vector3(3.9, -11.5, -8.4), Vector3(3.9, -6.6, -3.4), Vector3(3.9, 1.0, 3.6)]
const INSCRIPTION_ARC := 5.2
const INSCRIPTION_ARCS: Array[Vector2] = [Vector2(212.0, 252.0), Vector2(262.0, 300.0), Vector2(312.0, 338.0)]
const INSCRIPTION_WIDTH := 0.55
const INSCRIPTION_STEP := 0.5
const INSCRIPTION_STRENGTH := 0.55
const HAZE_SHADER := preload("res://assets/shaders/rift_haze.gdshader")
const INSCRIPTION_SHADER := preload("res://assets/shaders/garden_inscription.gdshader")
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
	if not _compat():
		return AIR
	var a := AIR.duplicate()
	a.merge(AIR_COMPAT, true)
	return a


func _compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"


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
	if kind == Edge.HOLE:
		var railed := _in_rift(mid + out * 2.0) and mid.x < (RIFT_X.x + RIFT_X.y) * 0.5 and out.x > 0.0
		broken_lip(a, b, out, faces, LIP_LEDGE if railed else 0.0)
		_lip_glow(a, b, out)
		if railed:
			balustrade_edge(a, b, out, true)
		else:
			filet(a, b, out)
		return
	broken_edge(a, b, out, faces)
	if out.x < -0.9 and mid.y > ENTRY.x - 0.1 and mid.y < ENTRY.y + 0.1:
		return
	balustrade_edge(a, b, out, false)


## A lip of the rift or of a hole (spec 1.3, F-3): the wall going down into the dark (the cliffs' one mesh), and along
## it chunks of the brink's slabs standing out past the drop at uneven lengths (paved with the floor's slabs, sunk a
## little, cut stone under the paving, the depths' stone hanging lower), stretches with none between them (a stone
## missing; sometimes one fallen in the gap), loose shards below. ledge: a shelf this far out under a balustrade, the
## chunks past it. Nothing on the walkable floor.
func broken_lip(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool, ledge := 0.0) -> void:
	_wall(a, b, out, faces)
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0))
	var cut := stone()
	if ledge > 0.0:
		_chunk(PackedVector2Array([a, b, b + out * ledge, a + out * ledge]), -LIP_SINK.x, LIP_HANG.x)
	var s := r.randf_range(0.0, LIP_GAP.x)
	while s < length - LIP_TOOTH.x * 0.5:
		var l := minf(r.randf_range(LIP_TOOTH.x, LIP_TOOTH.y), length - s)
		var p0 := a + along * s + out * ledge
		var p1 := a + along * (s + l) + out * ledge
		var o0 := r.randf_range(LIP_OUT.x, LIP_OUT.y)
		var o1 := r.randf_range(LIP_OUT.x, LIP_OUT.y)
		var tip := (p0 + p1) * 0.5 + out * maxf(o0, o1) * r.randf_range(0.7, 1.15) + along * l * r.randf_range(-0.15, 0.15)
		_chunk(PackedVector2Array([p0, p1, p1 + out * o1, tip, p0 + out * o0]), -r.randf_range(LIP_SINK.x, LIP_SINK.y),
			r.randf_range(LIP_HANG.x, LIP_HANG.y))
		s += l
		var gap := r.randf_range(LIP_GAP.x, LIP_GAP.y)
		if r.randf() < LIP_FALLEN_SHARE and s + gap < length:
			var g := a + along * (s + gap * 0.5) + out * (ledge + r.randf_range(0.2, 0.6))
			var size := r.randf_range(LIP_FALLEN.x, LIP_FALLEN.y)
			var fallen := m.box(Vector3(g.x, -r.randf_range(LIP_FALLEN_DEPTH.x, LIP_FALLEN_DEPTH.y), g.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, cut)
			fallen.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))
		s += gap
	# shards falling just below
	for k in floori(length * SHARDS):
		var p3 := a.lerp(b, r.randf()) + out * (ledge + r.randf_range(0.6, 2.0))
		var size := r.randf_range(SHARD.x, SHARD.y)
		var sh := m.box(Vector3(p3.x, -r.randf_range(0.8, 2.5), p3.y), Vector3(size, size * 0.8, size * 0.9), r.randf() * TAU, cut)
		sh.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.8, 0.8))


## The plain wall under a lip from the floor down into the abyss (the cliffs' mesh, the depths' dark stone; no
## straight kerb along it: the chunks are the brink).
func _wall(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool) -> void:
	var q: Array[Vector3] = [Vector3(a.x, 0.0, a.y), Vector3(b.x, 0.0, b.y), Vector3(b.x, -DEPTH, b.y), Vector3(a.x, -DEPTH, a.y)]
	# facing out of the floor (clockwise as seen from outside)
	if (b - a).cross(out) < 0.0:
		q = [q[1], q[0], q[3], q[2]]
	for k: int in [0, 1, 2, 0, 2, 3]:
		faces.add_vertex(q[k])


## One chunk of the brink on the footprint poly: the floor's paving on top at `top`, cut stone under it, the depths'
## dark stone hanging `hang` meters lower, a little inset. On the depths' layer too (the violet from below).
func _chunk(poly: PackedVector2Array, top: float, hang: float) -> void:
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	m.prism(poly, top - 0.04, top, _paving())
	m.prism(poly, top - LIP_STONE, top - 0.04, stone())
	var c := Vector2.ZERO
	for p in poly:
		c += p
	c /= poly.size()
	var inset := PackedVector2Array()
	for p in poly:
		inset.append(p + (c - p).limit_length(0.06))
	m.prism(inset, top - LIP_STONE - hang, top - LIP_STONE, _deep())
	m.layers = 1


var _glow: SurfaceTool


## The violet on the slabs along a lip (F-1: painted, no light): a strip LIP_GLOW_WIDTH wide inside the edge a to b,
## strongest at the drop (one mesh for them all, _commit_glow).
func _lip_glow(a: Vector2, b: Vector2, out: Vector2) -> void:
	if _glow == null:
		_glow = SurfaceTool.new()
		_glow.begin(Mesh.PRIMITIVE_TRIANGLES)
	var inward := -out * LIP_GLOW_WIDTH
	var v: Array[Vector3] = [Vector3(a.x, OVERLAY_Y, a.y), Vector3(b.x, OVERLAY_Y, b.y),
		Vector3(b.x + inward.x, OVERLAY_Y, b.y + inward.y), Vector3(a.x + inward.x, OVERLAY_Y, a.y + inward.y)]
	var uv: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	for k: int in [0, 1, 2, 0, 2, 3]:
		_glow.set_uv(uv[k])
		_glow.set_normal(Vector3.UP)
		_glow.add_vertex(v[k])


func _commit_glow() -> void:
	if _glow == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = _glow.commit()
	mi.material_override = _haze_material(LIP_GLOW, LIP_GLOW_ALPHA, LIP_GLOW_FADE, Vector2.ZERO, 1.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	_glow = null


func _haze_material(color: Color, alpha: float, fade_u: float, fade_v: Vector2, ramp := 0.0) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = HAZE_SHADER
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"alpha", alpha)
	mat.set_shader_parameter(&"fade_u", fade_u)
	mat.set_shader_parameter(&"fade_v", fade_v)
	mat.set_shader_parameter(&"ramp", ramp)
	return mat


var _deep_mat: ShaderMaterial
var _paving_mat: ShaderMaterial


## The depths' dark stone of this hall (the cliffs' look): arches, piers, the lips' hanging stone, joints.
func _deep() -> ShaderMaterial:
	if _deep_mat == null:
		_deep_mat = m.depth_stone(mist()).duplicate() as ShaderMaterial
		for k in CLIFF:
			_deep_mat.set_shader_parameter(k, CLIFF[k])
	return _deep_mat


## The floor's slabs (the same look as the floor) for the chunks of the brink.
func _paving() -> ShaderMaterial:
	if _paving_mat == null:
		var b := arena.shape().bounds()
		_paving_mat = kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3)
		for k in FLOOR:
			_paving_mat.set_shader_parameter(k, FLOOR[k])
	return _paving_mat


## The abyss under the hall and inside the rift: the mist, violet lights deep in the rift and the hole (only the
## depths' layer), the glow along the rift, the haze filling the rift and the holes a few meters down (F-1).
func _abyss() -> void:
	var b := arena.shape().bounds()
	kit.abyss(b.size * 0.5 + Vector2(8, 8), DEPTH, false, mist())
	_fallen = not layout.floor.covers(BRIDGES[0].get_center())
	var gain := FALLEN_GAIN if _fallen else 1.0
	var rift_mid := (RIFT_X.x + RIFT_X.y) * 0.5 + 0.5
	var spots: Array[Vector2] = []
	for z in DEEP_SPOTS:
		spots.append(Vector2(rift_mid, z))
	var rift := Rect2()
	for h in layout.floor.holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		c /= maxf(1.0, h.size())
		var box := Rect2(h[0], Vector2.ZERO)
		for v in h:
			box = box.expand(v)
		if _in_rift(c):
			rift = box if rift.size == Vector2.ZERO else rift.merge(box)
			continue
		spots.append(c)
		_haze(box.grow(HAZE_MARGIN), 0.0)
	for s in spots:
		var l := OmniLight3D.new()
		l.position = Vector3(s.x, DEEP_Y, s.y)
		l.light_color = DEEP
		l.light_energy = DEEP_ENERGY * gain
		l.omni_range = 16.0
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		add_child(l)
	# the rift's haze runs out of its north mouth over the abyss and fades there
	var south := rift.end.y
	rift.position.y = b.position.y - HAZE_NORTH
	rift.size.y = south - rift.position.y
	_haze(rift.grow_individual(HAZE_MARGIN, 0.0, HAZE_MARGIN, HAZE_MARGIN), HAZE_NORTH / rift.size.y)
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	for z: float in [-12.0, -5.0, 2.0, 7.5]:
		kit.abyss_glow(Vector3(rift_mid, GLOW_FOOT, z), GLOW_SIZE, yaw, ArenaKit.ABYSS_GLOW_ENERGY * gain)
	for s in spots.slice(DEEP_SPOTS.size()):
		kit.abyss_glow(Vector3(s.x, GLOW_FOOT, s.y), GLOW_SIZE * 0.75, yaw, ArenaKit.ABYSS_GLOW_ENERGY * gain)
	kit.abyss_fog(Vector3(rift_mid, (RIFT_FOG.x + RIFT_FOG.y) * 0.5, rift.get_center().y),
		Vector3(RIFT_X.y - RIFT_X.x + 2.0, RIFT_FOG.x - RIFT_FOG.y, rift.size.y))
	if _fallen:
		var r := BRIDGES[0]
		kit.mist_bank(Vector3(r.get_center().x, -3.0, r.get_center().y), Vector2(r.size.x + 2.0, 7.0), FALLEN_MIST, FALLEN_MIST_ALPHA)


## The violet haze sheets over the floor rect `area` (one per HAZE_Y), fading out at its edges (north: that share of
## it fades toward the north).
func _haze(area: Rect2, north: float) -> void:
	for k in HAZE_Y.size():
		var mi := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = area.size
		mi.mesh = pm
		var colour := HAZE_COLOR[k] * (HAZE_COMPAT if _compat() else 1.0)
		var mat := _haze_material(colour, HAZE_ALPHA[k], HAZE_FADE, Vector2(maxf(north, HAZE_FADE), HAZE_FADE))
		mat.set_shader_parameter(&"patchy", HAZE_PATCHY[k])
		mi.material_override = mat
		mi.position = Vector3(area.get_center().x, HAZE_Y[k], area.get_center().y)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.extra_cull_margin = 4.0
		add_child(mi)


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
	_inscriptions()
	_commit_glow()


# ---------- the bridges ----------

## A bridge over the rift (spec 1.3, F-2): its own paving over the floor (slabs along the span, kerbs, dark seams at
## the heads), the deck's cornice of cut stone under it, an open parapet outside the 5 m on each side, a pillar at
## each of the four heads on the abutment it springs from (two with a lantern, diagonally; two with candles), an arch
## of voussoirs under it with its crown ARCH_CROWN under the deck, its haunches and the piers down into the mist in the
## depths' dark stone. first: the north bridge (its west head's lantern casts shadows; the south bridge's east one).
func _bridge(r: Rect2, first: bool) -> void:
	var mat := ashlar()
	var deep := _deep()
	var cx := r.get_center().x
	var cz := r.get_center().y
	var span := r.size.x
	m.box(Vector3(cx, -DECK * 0.5 - 0.02, cz), Vector3(span + 1.0, DECK, r.size.y + DECK_OUT * 2.0), 0.0, mat, false)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	# the arch: its crown ARCH_CROWN under the deck, springing from the rift's walls, and the fill over its haunches
	var rr := span * ARCH_RADIUS
	var hx := rr - span * 0.5
	var rise := sqrt((rr + ARCH_RING) * (rr + ARCH_RING) - hx * hx)
	var spring := -ARCH_CROWN - rise
	m.voussoir_arch(Vector3(cx, spring, cz), Vector2(0, 1), span, 0.0, ARCH_RING, r.size.y, deep, ARCH_RADIUS)
	var slices := 8
	for k in slices:
		var x0 := -span * 0.5 + span * k / slices
		var x1 := x0 + span / slices
		var xm := absf((x0 + x1) * 0.5)
		# the arch's outer curve over this slice (the arc whose centre is on the other side)
		var y := spring + sqrt(maxf(0.0, (rr + ARCH_RING) * (rr + ARCH_RING) - (xm + hx) * (xm + hx)))
		if y < -DECK - 0.05:
			m.box(Vector3(cx + (x0 + x1) * 0.5, (y - DECK) * 0.5, cz), Vector3(x1 - x0 + 0.02, -DECK - y, r.size.y * 0.92), 0.0, deep, false)
	for sd: float in [-1.0, 1.0]:
		var px := cx + sd * (span * 0.5 + 0.6)
		m.box(Vector3(px, (spring - DEPTH) * 0.5, cz), Vector3(1.6, DEPTH + spring, r.size.y * 0.9), 0.0, deep, false)
	m.layers = 1
	_deck(r)
	for z: float in [r.position.y - PARAPET.z, r.end.y + PARAPET.z]:
		_parapet(Vector2(r.position.x + ABUTMENT.x * 0.5, z), Vector2(r.end.x - ABUTMENT.x * 0.5, z))
	# the four heads: north-west and south-east with lanterns (the first of the pair casting shadows), the others candles
	for k in 4:
		var west := k == 0 or k == 3
		var north := k == 0 or k == 2
		var lip := r.position.x if west else r.end.x
		var into := 1.0 if west else -1.0
		var side := r.position.y if north else r.end.y
		var away := -1.0 if north else 1.0
		_abutment(Vector2(lip, side), into, away)
		var head := Vector2(lip + into * ABUTMENT.x * 0.5, side + away * PARAPET.z)
		if k < 2:
			var l := tomb.lantern(Vector3(head.x, 0.0, head.y), 0.0, stone(), TombKit.WARM, ~Arena.CROWD_LAYER, HEAD_LANTERN)
			l.light_energy = BRIDGE_LAMP_ENERGY
			l.omni_range = BRIDGE_LAMP_RANGE
			l.shadow_enabled = (k == 0) == first
		else:
			_head(head)
			candles(Vector3(head.x, HEAD.y, head.y), 3)


## The abutment a bridge springs from at one corner (F-3): against the rift's wall at `corner` (where the lip meets the
## deck's side), reaching `into` the rift (x sign) and `away` from the deck (z sign): cut stone under the floor, then
## the depths' stone down into the haze.
func _abutment(corner: Vector2, into: float, away: float) -> void:
	var c := corner + Vector2(into * ABUTMENT.x * 0.5, away * ABUTMENT.z * 0.5)
	m.box(Vector3(c.x, -0.03 - ABUTMENT.y * 0.5, c.y), Vector3(ABUTMENT.x, ABUTMENT.y, ABUTMENT.z), 0.0, ashlar(), false)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	var top := -0.03 - ABUTMENT.y
	m.box(Vector3(c.x, (top + ABUTMENT_FOOT) * 0.5, c.y), Vector3(ABUTMENT.x - 0.1, top - ABUTMENT_FOOT, ABUTMENT.z - 0.1), 0.0, _deep(), false)
	m.layers = 1


## A head pillar of a bridge (F-2): plinth, shaft and cap, HEAD.y tall.
func _head(at: Vector2) -> void:
	var mat := stone()
	m.block(Vector3(at.x, 0.0, at.y), Vector3(HEAD.x + 0.12, Masonry.CURB * 0.7, HEAD.x + 0.12), 0.0, mat)
	m.block(Vector3(at.x, 0.0, at.y), Vector3(HEAD.x, HEAD.y - HEAD.z, HEAD.x), 0.0, mat)
	m.block(Vector3(at.x, HEAD.y - HEAD.z, at.y), Vector3(HEAD.x + 0.14, HEAD.z, HEAD.x + 0.14), 0.0, mat)


## The deck's own paving over the floor (F-2): the depths' dark stone under it all (the joints, and the seams where it
## meets the platforms), a kerb of lighter stone in lengths along each side, slabs running along the span in
## DECK_ROWS staggered rows between the kerbs.
func _deck(r: Rect2) -> void:
	var x0 := r.position.x + SEAM
	var x1 := r.end.x - SEAM
	m.prism(_rect(r.position.x, r.end.x, r.position.y, r.end.y), 0.0, SEAM_TOP, _deep())
	var kerb := m.stone(0.0, stone_tint() * KERB.z)
	var slab := m.stone(0.0, stone_tint() * DECK_TINT)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(r.position * 10.0))
	var rows: Array[Vector2] = [Vector2(r.position.y, r.position.y + KERB.x)]
	var inner := (r.size.y - KERB.x * 2.0) / DECK_ROWS
	for k in DECK_ROWS:
		var z := r.position.y + KERB.x + inner * k
		rows.append(Vector2(z, z + inner))
	rows.append(Vector2(r.end.y - KERB.x, r.end.y))
	for k in rows.size():
		var is_kerb := k == 0 or k == rows.size() - 1
		var x := x0
		var first := true
		while x < x1 - 0.05:
			var l := rng.randf_range(DECK_SLAB.x, DECK_SLAB.y) * (0.5 if first and k % 2 == 1 else 1.0)
			first = false
			if x1 - (x + l) < DECK_SLAB.x * 0.5:
				l = x1 - x
			var j := DECK_JOINT * 0.5
			m.prism(_rect(x + j, x + l - j, rows[k].x + j, rows[k].y - j), 0.0, KERB.y if is_kerb else DECK_TOP, kerb if is_kerb else slab)
			x += l


func _rect(x0: float, x1: float, z0: float, z1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, z0), Vector2(x1, z0), Vector2(x1, z1), Vector2(x0, z1)])


## The open parapet of a bridge from a to b (along x; spec 1.3: 0.9 m, never see-through): a curb, a rail, posts every
## PARAPET_POST meters and bellied balusters between them, the violet seen through it.
func _parapet(a: Vector2, b: Vector2) -> void:
	var mat := stone()
	var length := b.x - a.x
	var mid := (a + b) * 0.5
	m.box(Vector3(mid.x, PARAPET_CURB.x * 0.5, mid.y), Vector3(length, PARAPET_CURB.x, PARAPET_CURB.y), 0.0, mat, false)
	m.box(Vector3(mid.x, PARAPET.x - PARAPET_RAIL.x * 0.5, mid.y), Vector3(length, PARAPET_RAIL.x, PARAPET_RAIL.y), 0.0, mat, false)
	var posts := maxi(1, roundi(length / PARAPET_POST))
	var bay := length / posts
	for i in posts + 1:
		m.box(Vector3(a.x + bay * i, PARAPET.x * 0.5 + 0.03, mid.y), Vector3(PARAPET_POST_SIDE, PARAPET.x + 0.06, PARAPET.y), 0.0, mat)
	var shaft := PARAPET.x - PARAPET_RAIL.x - PARAPET_CURB.x
	var n := floori(length / BALUSTER.y)
	for i in n:
		var x := a.x + (i + 0.5) * length / n
		var t := (x - a.x) / bay
		if absf(t - roundf(t)) * bay < PARAPET_POST_SIDE:
			continue
		m.box(Vector3(x, PARAPET_CURB.x + shaft * 0.5, mid.y), Vector3(BALUSTER.x, shaft, BALUSTER.x), 0.0, mat)
		m.box(Vector3(x, PARAPET_CURB.x + shaft * 0.35, mid.y), Vector3(BALUSTER.z, BALUSTER.w, BALUSTER.z), 0.0, mat)


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


# ---------- the floor ----------

## The gold inscriptions between the rift and the hole (F-6, spec 3.5): straight runs along the rift's east lip and
## broken arcs round a hole east of it, carved (no glow), cut wherever the floor ends or something stands.
func _inscriptions() -> void:
	for run in INSCRIPTION_RUNS:
		var pts: Array[Vector2] = []
		var z := run.y
		while z <= run.z + 0.01:
			pts.append(Vector2(run.x, z))
			z += INSCRIPTION_STEP
		_carve(pts)
	var turn := rad_to_deg(INSCRIPTION_STEP / INSCRIPTION_ARC)
	for h in layout.floor.holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		c /= maxf(1.0, h.size())
		if c.x < RIFT_X.y:
			continue
		for arc in INSCRIPTION_ARCS:
			var pts: Array[Vector2] = []
			var bearing := arc.x
			while bearing <= arc.y + 0.01:
				pts.append(c + Vector2(sin(deg_to_rad(bearing)), -cos(deg_to_rad(bearing))) * INSCRIPTION_ARC)
				bearing += turn
			_carve(pts)


## The inscription along pts, split where a point is not on clear floor (half the band's width from any edge or
## anything that blocks).
func _carve(pts: Array[Vector2]) -> void:
	var run: Array[Vector2] = []
	for p in pts:
		var clear := arena.shape().contains(p, INSCRIPTION_WIDTH)
		for o in layout.obstacles:
			if o.blocks_move and o.depth(p, INSCRIPTION_WIDTH) > 0.0:
				clear = false
		if clear:
			run.append(p)
			continue
		_band(run)
		run = []
	_band(run)


## A band of the inscription along the polyline pts, INSCRIPTION_WIDTH wide, a hair over the floor (UV.x meters
## along it, UV.y across: garden_inscription.gdshader).
func _band(pts: Array[Vector2]) -> void:
	if pts.size() < 2:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var along := 0.0
	var prev: Array[Vector3] = []
	var prev_u := 0.0
	for i in pts.size():
		if i > 0:
			along += pts[i].distance_to(pts[i - 1])
		var d := (pts[mini(i + 1, pts.size() - 1)] - pts[maxi(i - 1, 0)]).normalized()
		var side := Vector2(-d.y, d.x) * INSCRIPTION_WIDTH * 0.5
		var pair: Array[Vector3] = [Vector3(pts[i].x - side.x, OVERLAY_Y, pts[i].y - side.y), Vector3(pts[i].x + side.x, OVERLAY_Y, pts[i].y + side.y)]
		if i > 0:
			# wound to face up (a positive cross seen from above, as the floor's)
			var quad: Array[Vector3] = [prev[0], pair[0], pair[1], prev[1]]
			var uv: Array[Vector2] = [Vector2(prev_u, 0), Vector2(along, 0), Vector2(along, 1), Vector2(prev_u, 1)]
			for k: int in [0, 1, 2, 0, 2, 3]:
				st.set_uv(uv[k])
				st.set_normal(Vector3.UP)
				st.add_vertex(quad[k])
		prev = pair
		prev_u = along
	var mat := ShaderMaterial.new()
	mat.shader = INSCRIPTION_SHADER
	mat.set_shader_parameter(&"arc_length", along)
	mat.set_shader_parameter(&"strength", INSCRIPTION_STRENGTH)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
