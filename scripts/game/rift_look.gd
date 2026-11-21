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
const DEEP := Color(0.62, 0.45, 1.0)
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
const HAZE_COLOR: Array[Color] = [Color(0.1, 0.06, 0.2), Color(0.15, 0.09, 0.3), Color(0.23, 0.14, 0.42)]
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
const RUIN_STONE := Color(0.05, 0.045, 0.07)
const RUIN_EDGE := Color(0.2, 0.17, 0.28)
const RUIN_MIST := Color(0.11, 0.095, 0.15)
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
## C18 (one tone for the scenery): sky, fog, far ruins, mist and haze kept violet but under 0.45 of saturation (the
## frame was a fifth saturated violet).
const AIR := {
	&"sky": Color(0.06, 0.05, 0.09), &"fog": Color(0.11, 0.09, 0.15), &"fog_depth": Vector2(60.0, 140.0),
	&"ambient": Color(0.34, 0.33, 0.42), &"ambient_gain": 2.25, &"moon": Color(0.72, 0.74, 0.86), &"moon_energy": 0.95,
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
const MIST := Color(0.11, 0.085, 0.17)
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

## Room redesign, lot B (docs/art/room_redesign_lotB_spec.md section 2): the rift's biome in the stylized look, indigo
## slate, the hall's fires, its own air; the violet only under the brink and far off.
## The cycle of 2026-11-20 (ART_REVIEW.md, the Salão's method by biome): the indigo fuller (hue 246 to 260 on the
## screen, docs/art/benchmark_hades2_style.md 7.2 row 2; scene saturation 0.30 to 0.40, short of Morvath's violet),
## the violet still only under the brink.
const STYLE := {
	&"stone": Color(0.28, 0.265, 0.355), &"shadow": Color(0.87, 0.85, 1.0), &"floor_stone": STY_FLOOR,
	&"edge_value": STY_EDGE_VALUE, &"joint_cold": Color(0.9, 0.88, 1.0), &"olive_share": 0.04, &"metal": true,
	&"fire": CatacombHall.STYLE[&"fire"], &"abyss_glow": Color(0.56, 0.52, 0.66),
	&"air": {&"sky": Color(0.05, 0.045, 0.08), &"fog": Color(0.10, 0.09, 0.14), &"ambient": Color(0.69, 0.68, 0.76),
		&"ambient_gain": 1.6, &"moon": Color(0.9, 0.9, 0.95), &"moon_energy": 0.8, &"moon_shadow": true},
}
## SW-G1 (docs/art/sworn_reference_ideas.md 3.1): the painted floor's second colour of the biome, in patches of 3 to 8 m,
## stronger near the edge (floor_biome.gdshaderinc; ArenaKit.paint_look's `floor`, put by style()).
## Grey salt, paler than the slate, 1.4 times the slab's value (the floor between them at patch_rest).
## The cycle of 2026-11-20: the patches soft (ArenaKit.SOFT_PATCHES), the floor calm (ArenaKit.CALM_FLOOR) and darker
## toward the room's far edges (edge_value from edge_span times the calm radius; the fight's middle stays).
const STY_FLOOR_BIOME := {&"patch_color": Color(0.42, 0.4, 0.51), &"edge_value": 0.5, &"edge_span": Vector2(1.1, 2.0)}
## Sworn P2 SW-F2: the salt gathered at the brink: the patches paler and greyer, faint in the middle of the floor (x of
## patch_share), most of the floor within patch_reach m of an edge (the rift's lips are edges) taken (patch_cut_edge).
const STY_SALT := {&"patch_color": Color(0.47, 0.465, 0.53), &"patch_share": Vector2(0.25, 0.85), &"patch_reach": 1.0,
	&"patch_cut_edge": 0.32}
## SW-F3: the stretch of the north edge (x from, to) in low merlons instead of the balustrade (ArenaRoom.merlons).
const MERLON_SPAN := Vector2(-16.5, -9.0)
## The floor's slate and how dark it falls toward the room's edge (room redesign fixes: the east platform's front read
## at luma 42, meta 50 to 65; the floor's middle stays near).
const STY_FLOOR := Color(0.285, 0.27, 0.37)
const STY_EDGE_VALUE := 1.0
## The stylized air in the browser's renderer (its ambient and moon lower, as the crypt's).
const STY_COMPAT_AMBIENT := 0.5
const STY_COMPAT_MOON := 0.6
## The haze and the lips' violet in the stylized look: this share of the way to their own grey (the haze's lightest
## (0.23, 0.14, 0.42) to about (0.24, 0.17, 0.38); the abyss's mist cards too); the lips' sheet on the slabs fainter (the violet under the brink).
const STY_HAZE_GREY := 0.4
## P2-B1 (ART_REVIEW.md 4.5): soft pools of key light over the fight fields (ArenaRoom.key_pool: x, z, radius), the
## west where he enters, the middle between the bridges, the east fight; their colour and energy. With the
## moon lower (STYLE's air), the floor nearest the camera in the near camera under 0.80 of the middle.
const STY_KEY_POOLS: Array[Vector3] = [Vector3(-16.0, 3.0, 7.0), Vector3(-2.5, -3.0, 5.0), Vector3(12.0, -1.0, 7.0)]
const STY_KEY_POOL_COLOR := Color(0.86, 0.85, 0.96)
const STY_KEY_POOL_ENERGY := 6.0
const STY_LIP_GLOW_ALPHA := 0.14
## B: the violet mist bank where the bridge was, in the stylized look (it lit the gap's middle at saturation 0.67).
const STY_FALLEN_MIST := Color(0.34, 0.26, 0.5)
const STY_FALLEN_MIST_ALPHA := 0.16
## The rift's height fog (Forward+) in the stylized look: albedo and emission nearer grey.
const STY_RIFT_FOG: Array[Color] = [Color(0.34, 0.32, 0.4), Color(0.17, 0.16, 0.21)]
## The violet lights deep in the rift (spec 2.2: 4 if the violet passes 3% of the frame).
const STY_DEEP_ENERGY := 4.0
## ... and paler (the piers and cliffs it lights read as columns of violet in the abyss of B at 0.8 saturation).
const STY_DEEP := Color(0.6, 0.5, 0.85)
## F1: fire bowls on small pillars on the bridges' north heads, out of the deck, over the rift (along the lip from
## the deck's side; out into the rift); the pillar's top, the bowl's scale, its light.
const HEAD_BOWL := Vector2(1.45, 0.42)
const HEAD_BOWL_TOP := 0.45
const HEAD_BOWL_SCALE := 0.5
const HEAD_BOWL_LIGHT := 2.6
const HEAD_BOWL_PILLAR := 0.5
## F2: shards of the room's stone hanging still in the rift, under the floor (count over the rift's holes, their
## size, height range of their middles, how far in from a hole's outline, how far from a bridge).
const SHARDS_HUNG := 16
const SHARD_SIZE := Vector2(0.4, 1.8)
const SHARD_Y := Vector2(-6.0, -1.6)
const SHARD_IN := 0.6
const SHARD_OFF_BRIDGE := 1.2
## F3: the broken arch over the rift's north mouth, past the floor's north edge (z, springing height, span, ring,
## depth, the missing stretch), and its chains (from the facade's corner; one hanging from the broken end).
const MOUTH_ARCH := Vector3(-19.0, -4.0, 11.5)
const MOUTH_ARCH_RING := Vector2(0.75, 0.9)
const MOUTH_ARCH_GAP := Vector2(0.6, 7.0)
const MOUTH_CHAIN_FROM := Vector3(2.6, 9.0, -16.8)
const MOUTH_CHAIN_HANG := 3.5
## F4 (B): the great arch of the fallen bridge behind its stumps (z, springing height; its radius share of the span 9 m
## (6 m), ring 0.8 m, depth, the missing half), a piece of the deck hung on two chains (its middle, size; the chains
## from the stumps' broken ends, this far north of their middles).
const FALLEN_ARCH := Vector2(-12.9, -7.3)
const FALLEN_ARCH_RADIUS := 0.667
const FALLEN_ARCH_RING := Vector2(0.8, 1.0)
const FALLEN_ARCH_GAP := Vector2(-1.0, 6.0)
const FALLEN_DECK := Vector3(-2.5, -3.2, -11.3)
const FALLEN_DECK_SIZE := Vector3(2.8, 0.55, 1.8)
const FALLEN_CHAIN_Z := -11.4
## SW-F1 (docs/art/sworn_reference_ideas.md 3.2): a column fallen across the rift's south hole (A and B), off the
## floor: its fluted drums lying across the gap from the west lip (its base there) to under the east one, broken in the
## middle, each half sagging into the gap from its end (its top FALLEN_COLUMN.y under the floor at the lips), the east
## half turned in the plane (no straight beam from lip to lip: it must never read as a way across), its capital hung in
## the break on the chain across it, chips of the break fallen below, chains down from the broken ends; the room's
## stone a step darker (FALLEN_COLUMN_VALUE: under the floor's value, over the rift's dark) on the depths' layer (lit by
## the rift's deep lights), no light of its own, nothing collides. F-1 and F-2 of the Sworn P1 review: a column, not a
## pipe nor a walkable beam.
## FALLEN_COLUMN: z, top at the lips (m), radius; FALLEN_COLUMN_SPAN: its west end (the base's plinth, under the lip)
## and east end (x, the rift's south hole runs from about -7.3 to 2.3 there; z 5, its north side, just south of the
## south bridge: from the game's camera the hole's near lip hides all but a metre or two below it further south);
## FALLEN_COLUMN_BREAK: the break's middle (x) and gap; FALLEN_COLUMN_SAG: how far each half dips (degrees);
## FALLEN_COLUMN_TWIST: the east half turned south about its end (degrees); FALLEN_COLUMN_DRUMS: drums a half, their radius a share of FALLEN_COLUMN's
## (FALLEN_COLUMN_DRUM_R), each turned about its axis; FALLEN_COLUMN_FLUTES: flutes round a drum and their depth (m);
## FALLEN_COLUMN_BASE: the base's plinth (along the axis, its side a share of the diameter) and torus (along the axis,
## its radius a share); FALLEN_CAPITAL: the capital's abacus (side, height), echinus (height, top radius as a share of
## the abacus's half side), the stump of shaft left on it (m); FALLEN_CAPITAL_AT: where it hangs from the break's middle
## (x, y of its middle, z) and its tilt (degrees); FALLEN_COLUMN_HANG: the chains' drop from the west and east broken
## ends.
const FALLEN_COLUMN := Vector3(5.0, -0.6, 0.7)
const FALLEN_COLUMN_SPAN := Vector2(-8.0, 3.4)
const FALLEN_COLUMN_BREAK := Vector2(-2.3, 0.9)
const FALLEN_COLUMN_SAG := 12.0
const FALLEN_COLUMN_TWIST := 15.0
const FALLEN_COLUMN_DRUMS := 3
const FALLEN_COLUMN_DRUM_R := Vector2(0.88, 1.0)
const FALLEN_COLUMN_FLUTES := Vector2(14, 0.06)
const FALLEN_COLUMN_VALUE := 0.7
const FALLEN_COLUMN_BASE := Vector4(0.3, 1.0, 0.24, 1.14)
const FALLEN_CAPITAL := Vector4(1.6, 0.3, 0.32, 0.95)
const FALLEN_CAPITAL_STUMP := 0.45
const FALLEN_CAPITAL_AT := Vector4(0.35, -1.9, 0.5, 34.0)
const FALLEN_COLUMN_HANG := Vector2(3.2, 4.4)
## F5 (B): the far vortex, an accent only: distance ahead of the camera (from the middle of its bounds), how far over
## the ray of the frame's top edge its middle stands (so only its lower part shows, in the top band of the frame, over
## where the north's enemies rise), its offset to the left of the view (m), size, colour (brightest channel 0.45), turn
## (turns a second).
const VORTEX := Vector3(80.0, 1.5, 6.0)
const VORTEX_SIZE := 10.0
const VORTEX_COLOR := Color(0.28, 0.2, 0.42)
const VORTEX_TURN := 0.02
const VORTEX_SHADER := preload("res://assets/shaders/far_vortex.gdshader")

var _fallen := false
var _haze_mats: Array[ShaderMaterial] = []
var _lip_mat: ShaderMaterial
var _deep_lights: Array[OmniLight3D] = []
var _fallen_mist: ShaderMaterial
var _rift_fog: FogMaterial


func floor_look() -> Dictionary:
	return FLOOR


func mist() -> Color:
	return MIST


## ENV-HB4 (ArenaRoom.under_look, only in the stylized look): the camera's side of the floor's edge on arches going
## down into the mist instead of a plain coursed wall.
const STY_UNDER := {&"set": ArenaRoom.LIP.y, &"top": -0.7}


func under_look() -> Dictionary:
	return STY_UNDER


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
		if railed:
			_ledges.append(PackedVector2Array([a, b, out]))
		_lip_glow(a, b, out)
		if railed:
			balustrade_edge(a, b, out, true)
		else:
			filet(a, b, out)
		return
	broken_edge(a, b, out, faces)
	if out.x < -0.9 and mid.y > ENTRY.x - 0.1 and mid.y < ENTRY.y + 0.1:
		return
	if out.y < -0.9 and minf(a.x, b.x) < MERLON_SPAN.y and maxf(a.x, b.x) > MERLON_SPAN.x:
		# SW-F3: a stretch of the north edge in low merlons (the stylized look; the classic keeps its balustrade)
		var lo := Vector2(maxf(minf(a.x, b.x), MERLON_SPAN.x), a.y)
		var hi := Vector2(minf(maxf(a.x, b.x), MERLON_SPAN.y), a.y)
		var dir := signf(b.x - a.x)
		var first := lo if dir > 0.0 else hi
		var last := hi if dir > 0.0 else lo
		if a.distance_to(first) > 1.0:
			balustrade_edge(a, first, out, false)
		merlons(first, last, out)
		if last.distance_to(b) > 1.0:
			balustrade_edge(last, b, out, false)
		return
	balustrade_edge(a, b, out, false)


var _glow: SurfaceTool
## The railed lips' sunk ledges (a, b, out), where the stylized look's fallen blocks lie (_edge_pieces).
var _ledges: Array[PackedVector2Array] = []


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
	_lip_mat = mi.material_override
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


## The abyss under the hall and inside the rift: the mist, violet lights deep in the rift and the hole (only the
## depths' layer), the glow along the rift, the haze filling the rift and the holes a few meters down (F-1).
func _abyss() -> void:
	var b := arena.shape().bounds()
	var from := kit.root.get_child_count()
	kit.abyss(b.size * 0.5 + Vector2(8, 8), DEPTH, false, mist())
	for i in range(from, kit.root.get_child_count()):
		var gi := kit.root.get_child(i) as GeometryInstance3D
		if gi != null and gi.material_override is ShaderMaterial and (gi.material_override as ShaderMaterial).get_shader_parameter(&"color") is Color:
			_haze_mats.append(gi.material_override)
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
		_deep_lights.append(l)
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
	var fog := kit.root.get_child(kit.root.get_child_count() - 1) as FogVolume
	if fog != null:
		_rift_fog = fog.material as FogMaterial
	if _fallen:
		var r := BRIDGES[0]
		kit.mist_bank(Vector3(r.get_center().x, -3.0, r.get_center().y), Vector2(r.size.x + 2.0, 7.0), FALLEN_MIST, FALLEN_MIST_ALPHA)
		var bank := kit.root.get_child(kit.root.get_child_count() - 1) as MeshInstance3D
		_fallen_mist = bank.material_override as ShaderMaterial


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
		_haze_mats.append(mat)
		mi.position = Vector3(area.get_center().x, HAZE_Y[k], area.get_center().y)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.extra_cull_margin = 4.0
		add_child(mi)


func dress() -> void:
	for i in BRIDGES.size():
		if layout.floor.covers(BRIDGES[i].get_center()):
			bridge(BRIDGES[i], i == 0, i != 0)
		else:
			_fallen_bridge(BRIDGES[i])
	_hole_blocks()
	_old_arches()
	_facade()
	_entry()
	_far()
	_inscriptions()
	_commit_glow()
	_dress_styled()


# ---------- the bridges ----------

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


# ---------- the stylized look (room redesign, lot B section 2) ----------

func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	st[&"floor"] = ArenaKit.CALM_FLOOR.merged(ArenaKit.SOFT_PATCHES).merged(STY_FLOOR_BIOME).merged(STY_SALT)
	if _compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	for m_ in _haze_mats:
		var c: Color = m_.get_shader_parameter(&"color")
		var grey := (c.r + c.g + c.b) / 3.0
		VisualProfile.vary(m_, {&"shader_parameter/color": c.lerp(Color(grey, grey, grey), STY_HAZE_GREY)})
	if _lip_mat != null:
		VisualProfile.vary(_lip_mat, {&"shader_parameter/alpha": STY_LIP_GLOW_ALPHA})
	if _rift_fog != null:
		VisualProfile.vary(_rift_fog, {&"albedo": STY_RIFT_FOG[0], &"emission": STY_RIFT_FOG[1]})
	if _fallen_mist != null:
		# where the bridge was (B): the violet under the brink, as faint and grey as the haze
		VisualProfile.vary(_fallen_mist, {&"shader_parameter/color": STY_FALLEN_MIST, &"shader_parameter/alpha": STY_FALLEN_MIST_ALPHA})
	for l in _deep_lights:
		VisualProfile.vary(l, {&"light_energy": l.light_energy * STY_DEEP_ENERGY / DEEP_ENERGY, &"light_color": STY_DEEP})
	return st


## The pieces only the stylized look shows (spec 2.3), on kit.styled() (never the room's random numbers), all off the
## floor: fire bowls on the bridges' north heads, shards hanging in the rift, the broken arch and chains at its north
## mouth; in B the fallen bridge's great broken arch with a piece of deck on chains, and the far vortex.
func _dress_styled() -> void:
	var sm := kit.styled()
	for r in BRIDGES:
		if layout.floor.covers(r.get_center()):
			for lip: float in [r.position.x, r.end.x]:
				var into := 1.0 if lip < (RIFT_X.x + RIFT_X.y) * 0.5 else -1.0
				var at := _into_rift(Vector2(lip + into * HEAD_BOWL.y, r.position.y - HEAD_BOWL.x), into)
				if at != Vector2.INF:
					_head_bowl(sm, at)
	_hung_shards(sm)
	_mouth_arch(sm)
	_aqueduct(sm)
	_fallen_column(sm)
	# P2-B1 (ART_REVIEW.md 4.5): the fight fields lit a step more than the floor nearest the camera
	for f: Vector3 in STY_KEY_POOLS:
		key_pool(f, STY_KEY_POOL_COLOR, STY_KEY_POOL_ENERGY)
	_edge_pieces()
	if _fallen:
		_fallen_arch(sm)
		_vortex()


## Sworn P2 SW-G6: the low dark foreground rising out of the haze past the edges the camera looks across.
func foreground_look() -> Dictionary:
	return STY_FOREGROUND


const STY_FOREGROUND := {&"out": Vector2(1.9, 3.2), &"top": Vector2(-0.8, 0.45), &"every": 6.5, &"tint": 0.55}


## TA-HB2 (docs/gallery/hb/ART_REVIEW.md item 2, Fendas): dead roots hanging from under each standing bridge's deck on
## the side the camera sees, their top hidden under its overhang (EDGE_ROOTS: how far under the deck's edge, down from
## the floor, how long; EDGE_ROOT_CLUMPS: the clumps' middles as a share of the span from its middle, their width, a
## share of the length); a heap of fallen blocks on every other railed lip's sunk ledge
## (EDGE_RUBBLE: out from the lip, its size). The north mouth keeps its broken arch (MOUTH_ARCH).
const EDGE_ROOTS := Vector3(0.25, 0.66, 2.8)
const EDGE_ROOT_CLUMPS: Array[Vector3] = [Vector3(-0.26, 0.8, 0.5), Vector3(0.18, 1.0, 0.62)]
const EDGE_RUBBLE := Vector2(0.5, 0.9)
## ... none near the fallen column (its z, FALLEN_COLUMN.x), which lies under the south hole's lips.
const EDGE_RUBBLE_CLEAR := 2.5


func _edge_pieces() -> void:
	var edge := edge_kit()
	var k := 0
	for r in BRIDGES:
		if not layout.floor.covers(r.get_center()):
			continue
		# in clumps, not a curtain the deck's whole length (an even row of roots read as a comb)
		for c: Vector3 in EDGE_ROOT_CLUMPS:
			var top := Vector3(r.get_center().x + c.x * r.size.x, -EDGE_ROOTS.y, r.end.y + DECK_OUT - EDGE_ROOTS.x)
			edge.root_curtain(top, c.y, EDGE_ROOTS.z * c.z, Vector2(1, 0), k)
			k += 1
	for i in range(0, _ledges.size(), 2):
		var l := _ledges[i]
		var at := (l[0] + l[1]) * 0.5 + l[2] * EDGE_RUBBLE.x
		if absf(at.y - FALLEN_COLUMN.x) < EDGE_RUBBLE_CLEAR:
			continue
		edge.rubble(Vector3(at.x, -LIP_SINK.x, at.y), EDGE_RUBBLE.y, i)


## F1: a small fire bowl on a pillar standing out of the rift's wall at `at` (off the floor): a corbel of the depths'
## stone under it, the pillar, the kit's brazier at half its size on top (its light a pool, no shadow).
func _head_bowl(sm: Masonry, at: Vector2) -> void:
	sm.layers = 1 | ArenaKit.DEPTH_LAYER
	sm.block(Vector3(at.x, ABUTMENT_FOOT * 0.5, at.y), Vector3(HEAD_BOWL_PILLAR + 0.2, -ABUTMENT_FOOT * 0.5 - 0.6, HEAD_BOWL_PILLAR + 0.2), 0.0, deep())
	sm.layers = 1
	sm.block(Vector3(at.x, -0.6, at.y), Vector3(HEAD_BOWL_PILLAR, HEAD_BOWL_TOP + 0.6, HEAD_BOWL_PILLAR), 0.0, stone())
	var foot := Vector3(at.x, HEAD_BOWL_TOP, at.y)
	kit.styled_build(func() -> void: kit.brazier(at, HEAD_BOWL_TOP, false, HEAD_BOWL_LIGHT), foot, HEAD_BOWL_SCALE)


## The first point from p going `into` the rift (x) that stands in a rift hole HEAD_BOWL_PILLAR from its outline (the
## lips are jagged), or INF.
func _into_rift(p: Vector2, into: float) -> Vector2:
	for k in 40:
		var q := p + Vector2(into * k * 0.05, 0.0)
		for h in layout.floor.holes:
			if Geometry2D.is_point_in_polygon(q, h) and _off_outline(q, h, HEAD_BOWL_PILLAR):
				return q
	return Vector2.INF


## F2: blocks of the room's stone hanging still in the rift's holes, under the floor, turned every way.
func _hung_shards(sm: Masonry) -> void:
	var holes: Array[PackedVector2Array] = []
	for h in layout.floor.holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		if _in_rift(c / maxf(1.0, h.size())):
			holes.append(h)
	if holes.is_empty():
		return
	var r := RandomNumberGenerator.new()
	r.seed = 2207
	var mat := ashlar()
	sm.layers = 1 | ArenaKit.DEPTH_LAYER
	var placed := 0
	var tries := 0
	while placed < SHARDS_HUNG and tries < SHARDS_HUNG * 40:
		tries += 1
		var p := Vector2(r.randf_range(RIFT_X.x, RIFT_X.y), r.randf_range(-16.0, 10.0))
		var inside := false
		for h in holes:
			if Geometry2D.is_point_in_polygon(p, h) and _off_outline(p, h, SHARD_IN):
				inside = true
		var near_bridge := false
		for b in BRIDGES:
			if b.grow(SHARD_OFF_BRIDGE).has_point(p) and layout.floor.covers(b.get_center()):
				near_bridge = true
		if not inside or near_bridge:
			continue
		var size := r.randf_range(SHARD_SIZE.x, SHARD_SIZE.y)
		var mi := sm.box(Vector3(p.x, r.randf_range(SHARD_Y.x, SHARD_Y.y), p.y), Vector3(size, size * r.randf_range(0.4, 0.8), size * r.randf_range(0.5, 0.9)), r.randf() * TAU, mat)
		mi.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.7, 0.7))
		mi.rotate_object_local(Vector3.BACK, r.randf_range(-0.7, 0.7))
		placed += 1
	sm.layers = 1


## True when p is at least d from every edge of the polygon.
static func _off_outline(p: Vector2, poly: PackedVector2Array, d: float) -> bool:
	for i in poly.size():
		var q := Geometry2D.get_closest_point_to_segment(p, poly[i], poly[(i + 1) % poly.size()])
		if p.distance_to(q) < d:
			return false
	return true


## F3: an arch of an older bridge broken over the rift's north mouth, past the floor's north edge, its east half gone,
## a chain from the facade's corner to its broken end and one hanging from it.
func _mouth_arch(sm: Masonry) -> void:
	var foot := Vector3((RIFT_X.x + RIFT_X.y) * 0.5, 0.0, MOUTH_ARCH.x)
	var kept := sm.broken_arch(foot, Vector2(0, 1), MOUTH_ARCH.z, MOUTH_ARCH.y, MOUTH_ARCH_RING.x, MOUTH_ARCH_RING.y,
		ashlar(), MOUTH_ARCH_GAP)
	var end := _broken_end(kept, foot, MOUTH_ARCH_GAP.x)
	if end == Vector3.INF:
		return
	kit.styled_build(func() -> void:
		kit.chain(MOUTH_CHAIN_FROM, end + Vector3(0, 0.3, 0), 1.6, 1.0)
		kit.chain(end, end + Vector3(0.4, -MOUTH_CHAIN_HANG, 0.2), 0.05, 0.8))


## Item 4 of the cycle of 2026-11-20 (depth past the edge): the dark masses of a ruined aqueduct rising out of the mist
## west of the room (STY_AQUEDUCT: x, from z, to z, the piers' foot height; STY_AQUEDUCT_PIERS: each pier's top over the
## floor, the last arches broken), its piers in the depths' unlit stone, chains from the room's west lip down to two
## of them, and spurs of rock south-west. All west or below the floor, so none hides the floor on the screen (a point h
## high hides the floor 1.73 h m behind it, to its north-west).
const STY_AQUEDUCT := Vector4(-30.0, -13.0, 13.0, -16.0)
const STY_AQUEDUCT_PIERS: Array[float] = [0.6, -0.4, 1.2, -1.6, 0.2]
const STY_AQUEDUCT_PIER := Vector2(1.6, 1.4)
const STY_AQUEDUCT_RING := Vector2(0.8, 1.3)
## The arches' radius as a share of their span (Masonry.voussoir_arch).
const STY_ARCH_RADIUS := 0.8
const STY_AQUEDUCT_GAPS: Array[Vector2] = [Vector2(-0.4, 1.8), Vector2(9.0, 9.0), Vector2(-2.6, 0.6), Vector2(9.0, 9.0)]
const STY_AQUEDUCT_CHAINS: Array[int] = [1, 3]
const STY_AQUEDUCT_CHAIN := Vector2(1.8, 1.3)
const STY_ROCKS: Array[Vector4] = [Vector4(-27.0, 19.0, -2.5, 2.2), Vector4(-24.0, 23.0, -4.0, 1.7), Vector4(-33.0, 15.5, -1.2, 2.6)]
const STY_ROCK_FOOT := -18.0
const STY_DEPTH_SEED := 9113


## ENV-HB4 (benchmark_hades2_style.md 4.1): the aqueduct's stone a step lighter than the cliffs' (the depth stone's
## tint), so its arches read against the violet dark, and a second, farther row behind it (the ruins in two depths:
## STY_AQUEDUCT_FAR as STY_AQUEDUCT, its piers' tops, its gaps), the mist fading it more.
const STY_AQUEDUCT_TINT := 3.0
const STY_AQUEDUCT_FAR := Vector4(-41.0, -19.0, 15.0, -20.0)
const STY_AQUEDUCT_FAR_PIERS: Array[float] = [2.2, 0.6, 2.8, -0.8, 1.6, 0.4]
const STY_AQUEDUCT_FAR_GAPS: Array[Vector2] = [Vector2(9.0, 9.0), Vector2(-1.2, 1.0), Vector2(9.0, 9.0), Vector2(0.2, 2.4)]
const STY_AQUEDUCT_FAR_TINT := 2.2
## The near row sinks into the mist lower down than the cliffs (sink_top, sink_bottom), so its piers keep their form.
const STY_AQUEDUCT_SINK := Vector2(-8.0, -40.0)


func _aqueduct(sm: Masonry) -> void:
	# the depths' own stone (deep(): the rift's cliffs), dark violet-indigo; a ruin card's stone read teal here
	var dark := deep()
	var lit := dark.duplicate() as ShaderMaterial
	lit.set_shader_parameter(&"tint", STY_AQUEDUCT_TINT)
	lit.set_shader_parameter(&"sink_top", STY_AQUEDUCT_SINK.x)
	lit.set_shader_parameter(&"sink_bottom", STY_AQUEDUCT_SINK.y)
	var far := dark.duplicate() as ShaderMaterial
	far.set_shader_parameter(&"tint", STY_AQUEDUCT_FAR_TINT)
	var tops := _aqueduct_row(sm, STY_AQUEDUCT, STY_AQUEDUCT_PIERS, STY_AQUEDUCT_GAPS, lit)
	_aqueduct_row(sm, STY_AQUEDUCT_FAR, STY_AQUEDUCT_FAR_PIERS, STY_AQUEDUCT_FAR_GAPS, far)
	depth_spurs(sm, STY_ROCKS, STY_ROCK_FOOT, lit, STY_DEPTH_SEED)
	var lip := -layout.half.x - 0.4
	kit.styled_build(func() -> void:
		for k: int in STY_AQUEDUCT_CHAINS:
			var t := tops[k]
			kit.chain(Vector3(lip, -0.3, t.z), t + Vector3(0, 0.1, 0), STY_AQUEDUCT_CHAIN.x, STY_AQUEDUCT_CHAIN.y))


## One row of the aqueduct (a: x, from z, to z, the piers' foot height; piers: each top; gaps: each arch's missing
## stones); returns the piers' tops.
func _aqueduct_row(sm: Masonry, a: Vector4, piers: Array[float], gaps: Array[Vector2], mat: ShaderMaterial) -> Array[Vector3]:
	var n := piers.size()
	var step := (a.z - a.y) / float(n - 1)
	var tops: Array[Vector3] = []
	for k in n:
		var z := a.y + step * k
		var top := piers[k]
		sm.box(Vector3(a.x, (a.w + top) * 0.5, z), Vector3(STY_AQUEDUCT_PIER.x, top - a.w, STY_AQUEDUCT_PIER.y), 0.0, mat, false)
		tops.append(Vector3(a.x, top, z))
		if k == n - 1:
			continue
		# the arch to the next pier, its outer apex at the lower top; some of its stones gone
		var span := step - STY_AQUEDUCT_PIER.y
		var rise := sqrt(pow(span * STY_ARCH_RADIUS, 2.0) - pow(span * (STY_ARCH_RADIUS - 0.5), 2.0)) + STY_AQUEDUCT_RING.x
		var spring := minf(top, piers[k + 1]) - rise
		sm.broken_arch(Vector3(a.x, spring, z + step * 0.5), Vector2(1, 0), span, 0.0, STY_AQUEDUCT_RING.x, STY_AQUEDUCT_RING.y,
			mat, gaps[k % gaps.size()], STY_ARCH_RADIUS)
	return tops


## SW-F1: the fallen column across the rift's south hole (FALLEN_COLUMN_*), under the floor's level, its two halves
## sagging from the lips to the break, the east one turned, its capital hung in the break.
func _fallen_column(sm: Masonry) -> void:
	# the room's dressed stone (as the hanging shards, F2; the depths' own stone is black against the rift's dark), a
	# step darker than the floor
	var mat := m.ashlar(0.0, stone_tint() * FALLEN_COLUMN_VALUE)
	var r := FALLEN_COLUMN.z
	var flutes := int(FALLEN_COLUMN_FLUTES.x)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4013
	var ends: Array[Vector3] = []
	sm.layers = 1 | ArenaKit.DEPTH_LAYER
	var sag := deg_to_rad(FALLEN_COLUMN_SAG)
	for side: float in [-1.0, 1.0]:
		# from the lip's end (held under the floor) toward the break, dipping; the east half turned north
		var from_x := FALLEN_COLUMN_SPAN.x if side < 0.0 else FALLEN_COLUMN_SPAN.y
		var to_x := FALLEN_COLUMN_BREAK.x + side * FALLEN_COLUMN_BREAK.y * 0.5
		var run := absf(to_x - from_x)
		var twist := deg_to_rad(FALLEN_COLUMN_TWIST) if side > 0.0 else 0.0
		var flat := Vector3(-side * cos(twist), 0.0, sin(twist))
		var dir := flat * cos(sag) + Vector3.DOWN * sin(sag)
		var length := run / cos(sag)
		var start := Vector3(from_x, FALLEN_COLUMN.y - r, FALLEN_COLUMN.x)
		var side_ax := dir.cross(Vector3.UP).normalized()
		var along := Basis(side_ax, dir, side_ax.cross(dir)).orthonormalized()
		var at := 0.0
		if side < 0.0:
			# the base at the west end: a square plinth under the lip, then the torus
			var plinth := sm.box(Vector3.ZERO, Vector3(r * 2.0 * FALLEN_COLUMN_BASE.y, FALLEN_COLUMN_BASE.x, r * 2.0 * FALLEN_COLUMN_BASE.y), 0.0, mat, false)
			plinth.transform = Transform3D(along, start + dir * FALLEN_COLUMN_BASE.x * 0.5)
			var torus := sm.shaft(Vector3.ZERO, r * FALLEN_COLUMN_BASE.w, FALLEN_COLUMN_BASE.z, mat)
			torus.transform = Transform3D(along, start + dir * (FALLEN_COLUMN_BASE.x + FALLEN_COLUMN_BASE.z * 0.5))
			at = FALLEN_COLUMN_BASE.x + FALLEN_COLUMN_BASE.z
		var drum := (length - at) / FALLEN_COLUMN_DRUMS
		for k in FALLEN_COLUMN_DRUMS:
			# the drum at the break shorter, snapped; each a little thinner or thicker and turned about its axis
			var len_ := drum - 0.08 - (drum * 0.3 if k == FALLEN_COLUMN_DRUMS - 1 else 0.0)
			var mid := start + dir * (at + drum * k + len_ * 0.5 + 0.04)
			mid.z += rng.randf_range(-0.06, 0.06)
			var mi := sm.fluted(Vector3.ZERO, r * rng.randf_range(FALLEN_COLUMN_DRUM_R.x, FALLEN_COLUMN_DRUM_R.y), len_, flutes,
				FALLEN_COLUMN_FLUTES.y, mat)
			mi.transform = Transform3D(along * Basis(Vector3.UP, rng.randf_range(0.0, TAU)), mid)
		ends.append(start + dir * (length - drum * 0.3))
	# the capital, broken off the east half's top, hung in the break: abacus, echinus and a stump of the shaft
	var cap := Vector3(FALLEN_COLUMN_BREAK.x + FALLEN_CAPITAL_AT.x, FALLEN_CAPITAL_AT.y, FALLEN_COLUMN.x + FALLEN_CAPITAL_AT.z)
	var tilt := Basis(Vector3(0.6, 0, 0.8).normalized(), deg_to_rad(FALLEN_CAPITAL_AT.w)) * Basis(Vector3.UP, 0.4)
	var parts: Array[MeshInstance3D] = []
	var abacus := sm.box(Vector3.ZERO, Vector3(FALLEN_CAPITAL.x, FALLEN_CAPITAL.y, FALLEN_CAPITAL.x), 0.0, mat, false)
	abacus.position = Vector3(0, FALLEN_CAPITAL.y * 0.5, 0)
	var bell := sm.shaft(Vector3.ZERO, FALLEN_CAPITAL.x * 0.5 * FALLEN_CAPITAL.w, FALLEN_CAPITAL.z, mat)
	var cyl := bell.mesh as CylinderMesh
	cyl.bottom_radius = r * FALLEN_COLUMN_DRUM_R.x
	bell.position = Vector3(0, -FALLEN_CAPITAL.z * 0.5, 0)
	var stump := sm.fluted(Vector3.ZERO, r * FALLEN_COLUMN_DRUM_R.x, FALLEN_CAPITAL_STUMP, flutes, FALLEN_COLUMN_FLUTES.y, mat)
	stump.position = Vector3(0, -FALLEN_CAPITAL.z - FALLEN_CAPITAL_STUMP * 0.5, 0)
	parts.append_array([abacus, bell, stump])
	for p: MeshInstance3D in parts:
		p.transform = Transform3D(tilt, cap) * p.transform
	# chips of the break fallen below it
	for k in 3:
		var p := Vector3(FALLEN_COLUMN_BREAK.x + rng.randf_range(-0.6, 0.6), rng.randf_range(-3.5, -2.0), FALLEN_COLUMN.x + rng.randf_range(-0.5, 0.5))
		var s := rng.randf_range(0.25, 0.45)
		var chip := sm.box(p, Vector3(s, s * 0.6, s * 0.8), rng.randf() * TAU, mat)
		chip.rotate_object_local(Vector3.RIGHT, rng.randf_range(-0.6, 0.6))
	sm.layers = 1
	var west := ends[0] + Vector3(0, r * 0.6, 0)
	var east := ends[1] + Vector3(0, r * 0.6, 0)
	var hook := cap + tilt * Vector3(0, FALLEN_CAPITAL.y, 0)
	kit.styled_build(func() -> void:
		kit.chain(west, hook, 0.3, 0.8)
		kit.chain(hook, east, 0.3, 0.8)
		kit.chain(ends[0], ends[0] + Vector3(0.3, -FALLEN_COLUMN_HANG.x, 0.2), 0.05, 0.8)
		kit.chain(ends[1], ends[1] + Vector3(-0.2, -FALLEN_COLUMN_HANG.y, -0.3), 0.05, 0.8))


## The position of the kept stone nearest a gap's edge (local x across the arch from foot), or INF.
static func _broken_end(kept: Array[MeshInstance3D], foot: Vector3, edge: float) -> Vector3:
	var best := INF
	var at := Vector3.INF
	for mi in kept:
		var d := absf(mi.position.x - foot.x - edge)
		if d < best:
			best = d
			at = mi.position
	return at


## F4 (B): the fallen bridge's great arch behind its stumps, half of it gone, under the brink; a piece of its deck
## hung on two chains from the stumps' broken ends.
func _fallen_arch(sm: Masonry) -> void:
	var r := BRIDGES[0]
	var foot := Vector3(r.get_center().x, 0.0, FALLEN_ARCH.x)
	sm.layers = 1 | ArenaKit.DEPTH_LAYER
	sm.broken_arch(foot, Vector2(0, 1), r.size.x, FALLEN_ARCH.y, FALLEN_ARCH_RING.x, FALLEN_ARCH_RING.y, ashlar(),
		FALLEN_ARCH_GAP, FALLEN_ARCH_RADIUS)
	var piece_ := sm.box(FALLEN_DECK, FALLEN_DECK_SIZE, 0.15, ashlar())
	piece_.rotate_object_local(Vector3.BACK, 0.35)
	sm.layers = 1
	var half := FALLEN_DECK_SIZE.x * 0.5
	var west := Vector3(r.position.x + STUMP, -0.3, FALLEN_CHAIN_Z)
	var east := Vector3(r.end.x - STUMP, -0.3, FALLEN_CHAIN_Z)
	kit.styled_build(func() -> void:
		kit.chain(west, FALLEN_DECK + Vector3(-half, 0.25 + half * 0.35, 0), 0.3, 1.0)
		kit.chain(east, FALLEN_DECK + Vector3(half, 0.25 - half * 0.35, 0), 0.3, 1.0))


## F5 (B): the far vortex, a turning card of desaturated violet far behind the rift's north mouth, high in the frame
## (over the facade's top on the screen, never where the north's enemies rise), no light.
func _vortex() -> void:
	var feel := Feel.live()
	var yaw := deg_to_rad(feel.cam_yaw)
	var c := layout.cam_bounds.get_center()
	var eye := Vector3(c.x, 0, c.y) + Feel.cam_offset_of(feel.cam_distance, feel.cam_pitch, feel.cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	var left := Vector3(-cos(yaw), 0, sin(yaw))
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2.ONE * VORTEX_SIZE
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = VORTEX_SHADER
	mat.set_shader_parameter(&"color", VORTEX_COLOR)
	mat.set_shader_parameter(&"turn", VORTEX_TURN)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# the frame's top edge at that distance: the camera's pitch less half its field of view
	var top := eye.y - VORTEX.x * tan(deg_to_rad(feel.cam_pitch - feel.cam_fov * 0.5))
	mi.transform = Transform3D(Basis(Vector3.UP, yaw), Vector3(eye.x, top + VORTEX.y, eye.z) + ahead * VORTEX.x + left * VORTEX.z)
	kit.styled().root.add_child(mi)


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
