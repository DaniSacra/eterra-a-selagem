class_name AltarLook
extends ArenaRoom
## The look of the Altar Esquecido (the forgotten altar, E5 spec docs/art/e5_spec.md section 6): a small chapel of the
## catacombs, no fight. The hall's floor without its medallion and the hall's air a step darker; the north wall with a
## deep blind arch over the altar of the layout (&"altar": a block with the lion of Eterra raised on its front in the
## altar's stone, eleven candles burnt out on it) and a worn band of carving in the arch, nothing legible; faded
## banners with the lion, one torn; the benches of the layout; one cold shaft of light on the altar, with shadow and
## dust. After the event (kindle) the candles burn and warm the altar with one light with shadow.

## The walls: height; the blind arch over the altar (width, height, how deep it is sunk).
const WALL_HEIGHT := 6.5
const ARCH := Vector3(5.2, 5.6, 0.45)
const ARCH_PANEL := Color(0.15, 0.15, 0.17)
## The worn band (spec 6.2): size, height of its middle, its strokes (rows, a row, length range, width), the share worn
## away, the stone a little lighter than the wall's.
const BAND := Vector2(4.0, 0.6)
const BAND_AT := 2.8
const BAND_ROWS := 2
const BAND_STROKES := 22
const BAND_STROKE := Vector2(0.05, 0.14)
const BAND_WIDTH := 0.022
const BAND_WORN := 0.4
const BAND_STONE := Color(1.12, 1.1, 1.06)
const BAND_CUT := Color(0.4, 0.38, 0.36)
## The altar (spec 6.2): plinth, the top slab's lip, the lion on its front (size, how far up its middle).
const ALTAR_PLINTH := Vector2(0.2, 0.18)
const ALTAR_LIP := Vector2(0.14, 0.08)
const LION_SIZE := 1.0
const LION_UP := 0.6
const LION_SHADER := preload("res://assets/shaders/altar_lion.gdshader")
## The eleven candles on the altar (spec 6.2): how many, how far in from the front and the ends.
const CANDLES := 11
const CANDLE_IN := Vector2(0.35, 0.3)
## After the event: the candles' light (with shadow), its reach, the seconds it takes to come up by default.
const CANDLE_ENERGY := 1.6
const CANDLE_REACH := 7.0
const KINDLE_TIME := 1.2
## Banners on the north wall each side of the arch: x, top, size; the torn one's share of the length; how faded.
const BANNERS: Array[float] = [-6.0, 6.0]
const BANNER_TOP := 5.6
const BANNER_SIZE := Vector2(1.3, 3.4)
const BANNER_TORN := 0.62
const BANNER_FADE := 0.4
## The cold shaft on the altar (spec 6.2): colour, energy, cone, height.
const SHAFT := Color(0.70, 0.78, 0.92)
const SHAFT_ENERGY := 2.0
const SHAFT_CONE := 16.0
const SHAFT_HEIGHT := 12.0
## The hall's floor without its medallion, the room a step darker (spec 6.3).
const FLOOR := {&"calm_radius": 0.0}
const AIR := {&"ambient_gain": 1.35, &"sky": Color(0.02, 0.025, 0.03)}
## A dim cold fill so the floor reads between the shaft and the door.
const FILL := Color(0.62, 0.66, 0.78)
const FILL_ENERGY := 1.0
## Under the chapel: dark, no teal of the hall's abyss (a closed room).
const MIST := Color(0.03, 0.035, 0.045)
const CLIFF := {&"stone_color": Color(0.08, 0.08, 0.09), &"edge_color": Color(0.14, 0.14, 0.16), &"mist_color": Color(0.03, 0.035, 0.045)}

## The stylized look (spec 3.2): warm calm stone, the altar's candles lit at 3 m and 1.2 of the light (their light
## keeps its shadow, the room's only one: ArenaKit.KEEP_SHADOW), a dark still air.
## The cycle of 2026-11-20 (docs/art/benchmark_hades2_style.md 7.2 row 7b; ART_REVIEW.md 4.5 P1-B1): an earthy reddish
## stone and air (hue 18 to 28, 14 degrees or more from the Santuário's yellow limestone, and more saturated than it).
## C1V N3 (docs/art/identidade_c1v.md 2.1, the hall's recipe, only in the stylized look): the shadow band's tint, the room's own hue
## (docs/art/plano_pintado_a_mao.md 5); the vignette is the hall's.
const STY_SHADOW_GLOW := Color(0.50, 0.25, 0.35)
const STYLE := {
	&"stone": Color(0.365, 0.308, 0.278), &"shadow": Color(0.84, 0.9, 1.0), &"floor_stone": Color(0.348, 0.293, 0.265),
	&"olive_share": 0.06, &"edge_value": 1.0, &"metal": true,
	&"fire": {&"candle_range": 3.0, &"candle_gain": 1.2, &"bowl_range": 7.5, &"bowl_gain": 2.2},
	&"air": {&"sky": Color(0.03, 0.03, 0.035), &"fog": Color(0.1, 0.095, 0.085), &"ambient": Color(0.72, 0.635, 0.575),
		&"ambient_gain": 3.2, &"moon": Color(0.9, 0.88, 0.84), &"moon_energy": 0.8, &"moon_shadow": false},
	&"shadow_glow": STY_SHADOW_GLOW, &"vignette": CatacombHall.STY_VIGNETTE,
	&"c1v": {&"warm": Vector2(-4.0, 0.0), &"energy": 0.6, &"shaft": CatacombHall.STY_SHAFT_AT},
}
## SW-G1 (docs/art/sworn_reference_ideas.md 3.1): the painted floor's second colour of the biome, in patches of 3 to 8 m,
## stronger near the edge (floor_biome.gdshaderinc; ArenaKit.paint_look's `floor`, put by style()).
## Pale warm dust and old wax, 1.4 times the slab's value (the floor between them at patch_rest).
## The cycle of 2026-11-20 (ART_REVIEW.md, the Salão's method by biome, docs/art/benchmark_hades2_style.md 7): the floor
## calm between neighbour slabs (ArenaKit.CALM_FLOOR) and the patches soft and large (ArenaKit.SOFT_PATCHES); only HB2 and the frame (matrix
## row 7): the floor darkens toward the walls past STY_FRAME (calm_radius in m, edge_value, edge_span).
const STY_FLOOR_BIOME := {&"patch_color": Color(0.49, 0.43, 0.37)}
const STY_FRAME := {&"calm_radius": 6.0, &"edge_value": 0.6, &"edge_span": Vector2(1.1, 2.0)}
## The far ruins in the stylized look: a warm grey haze, their stone and edge (style_backdrop).
const STY_BACKDROP := [Color(0.17, 0.16, 0.145), Color(0.075, 0.07, 0.065), Color(0.21, 0.19, 0.16)]
## The browser's renderer: the stylized air's share there (the painted stone lights grey-white).
const STY_COMPAT_AMBIENT := 0.7
const STY_COMPAT_MOON := 0.6
## The shaft in the stylized look: pale old gold, weaker, diffuse and without its shadow (the candles keep theirs).
const STY_SHAFT := Color(0.96, 0.88, 0.70)
const STY_SHAFT_ENERGY := 1.6
## A1: the offerings before the candles on the altar's top: (x along it, kind (see _offering), z back from the top's
## front), how far in from its front they stand, the urns' height range; the shelves at the north wall's foot (from, to
## x), their top's height and the room between two offerings; the bowl (top, foot radius, height); the cloths.
const OFFERINGS: Array[Vector3] = [Vector3(-1.45, 0, 0.12), Vector3(-1.1, 2, 0.1), Vector3(-0.6, 1, 0.16),
	Vector3(0.0, 3, 0.12), Vector3(0.55, 2, 0.12), Vector3(1.05, 0, 0.14), Vector3(1.45, 1, 0.1)]
const OFFERING_IN := 0.12
const OFFERING_URN := Vector2(0.22, 0.33)
const SHELVES: Array[Vector2] = [Vector2(-8.6, -3.6), Vector2(3.6, 7.6)]
const SHELF_HEIGHT := 0.95
const SHELF_STEP := 0.55
const BOWL := Vector3(0.15, 0.09, 0.07)
const CLOTH_THICK := 0.035
const STY_CLOTH_PETROL := Color(0.06, 0.13, 0.14)
const STY_CLOTH_UMBER := Color(0.2, 0.14, 0.1)
const STY_URN := Color(0.95, 0.9, 0.84)
const STY_SEED := 7151
## A2: moss and ivy cards on the arch and the band (x from the altar's middle, the top's height, out of the wall's face).
const IVY: Array[Vector3] = [Vector3(-2.35, 4.4, 0.48), Vector3(2.2, 4.4, 0.48), Vector3(-1.7, 3.2, 0.15), Vector3(1.4, 3.15, 0.15)]
const IVY_CARD := Vector2(1.3, 1.6)
const STY_MOSS := Color(0.20, 0.24, 0.17)
## A3: the petals (card size, cell, a petal's length range, cover, height over the floor, colours).
const PETALS := Vector2(5.0, 1.6)
const PETAL_CELL := 0.12
const PETAL_SIZE := Vector2(0.05, 0.08)
const PETAL_COVER := 0.22
const PETAL_Y := 0.008
const PETAL_PALE := Color(0.66, 0.63, 0.56)
const PETAL_LILAC := Color(0.44, 0.40, 0.47)

var _shaft: SpotLight3D
var _far: Array[Node] = []
var _altar_o: ArenaObstacle
var _out: Node3D
var _lit: Node3D
var _candle_light: OmniLight3D
var _tween: Tween


func floor_look() -> Dictionary:
	return FLOOR


func air() -> Dictionary:
	return AIR


func mist() -> Color:
	return MIST


func cliff_look() -> Dictionary:
	return CLIFF


func in_wall(i: int) -> bool:
	var u := layout.exits[i].inward
	return u.y > 0.5 or u.x > 0.5


func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	closed_edge(a, b, out, WALL_HEIGHT, ashlar())


func piece(o: ArenaObstacle) -> void:
	if o.piece == &"altar":
		_altar(o)
		return
	super.piece(o)


func dress() -> void:
	var box := layout.floor.bounds()
	var north := box.position.y
	var altar := Vector2(box.get_center().x, north)
	for o in layout.obstacles:
		if o.piece == &"altar":
			altar = o.center
	_arch(Vector2(altar.x, north))
	_banners(north)
	_shaft = moon_shaft(altar, SHAFT, SHAFT_ENERGY, SHAFT_CONE, SHAFT_HEIGHT, true, true)
	key_light(FILL, FILL_ENERGY, 10.0)
	var from := get_child_count()
	backdrop(MIST * 2.0, Color(0.035, 0.045, 0.06), Color(0.14, 0.2, 0.24))
	_far = added_since(from)
	_dress_styled(north, _altar_o)


## True once the candles burn.
func lit() -> bool:
	return _lit != null and _lit.visible


## After the event (spec 6.4): the candles on the altar burn and their light comes up in `seconds` (0: at once).
func kindle(seconds := KINDLE_TIME) -> void:
	if _lit == null:
		return
	_lit.visible = true
	_out.visible = false
	_candle_light.visible = true
	if _tween != null:
		_tween.kill()
	if seconds <= 0.0 or not is_inside_tree():
		_candle_light.light_energy = _kindled_energy()
		return
	_candle_light.light_energy = 0.0
	_tween = create_tween()
	_tween.tween_property(_candle_light, "light_energy", _kindled_energy(), seconds)


## The lab's states: "after" the candles lit.
func demo(state: String) -> void:
	if state == "after":
		kindle(0.0)


## The altar on its footprint (spec 6.2): plinth, body, the top slab with a lip, the lion raised on the face toward the
## room, the candles on top (burnt out; the lit ones hidden until kindle).
func _altar(o: ArenaObstacle) -> void:
	_altar_o = o
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var size := Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0)
	var yaw := -o.yaw
	var basis := Basis(Vector3.UP, yaw)
	var mat := stone()
	m.block(foot, Vector3(size.x + ALTAR_PLINTH.y * 2.0, ALTAR_PLINTH.x, size.z + ALTAR_PLINTH.y * 2.0), yaw, mat)
	m.block(foot, Vector3(size.x, size.y - ALTAR_LIP.x, size.z), yaw, mat)
	m.block(foot + Vector3(0, size.y - ALTAR_LIP.x, 0), Vector3(size.x + ALTAR_LIP.y * 2.0, ALTAR_LIP.x, size.z + ALTAR_LIP.y * 2.0), yaw, mat)
	var lion := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(LION_SIZE, LION_SIZE)
	lion.mesh = q
	var lm := ShaderMaterial.new()
	lm.shader = LION_SHADER
	lm.set_shader_parameter(&"lion", ArenaKit.LION_FIELD)
	lion.material_override = lm
	lion.transform = Transform3D(basis, foot + basis * Vector3(0, LION_UP, size.z * 0.5 + 0.004))
	add_child(lion)
	# the candles: one row along the back of the top, burnt out and lit twins
	_out = Node3D.new()
	_lit = Node3D.new()
	_lit.visible = false
	add_child(_out)
	add_child(_lit)
	var out_m := Masonry.new(_out)
	var lit_m := Masonry.new(_lit)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(o.center * 10.0))
	for k in CANDLES:
		var t := (k + 0.5) / CANDLES
		var x := lerpf(-size.x * 0.5 + CANDLE_IN.y, size.x * 0.5 - CANDLE_IN.y, t)
		var z := -size.z * 0.5 + CANDLE_IN.x + r.randf_range(-0.08, 0.25)
		var p := foot + basis * Vector3(x, size.y, z)
		var h := lerpf(CANDLE_HEIGHT.x, CANDLE_HEIGHT.y, r.randf())
		var rad := lerpf(CANDLE_RADIUS.x, CANDLE_RADIUS.y, r.randf() * 0.7)
		out_m.candle_out(p, h, rad)
		lit_m.candle(p, h, rad)
	out_m.merge()
	lit_m.merge()
	_candle_light = warm_light(foot + Vector3(0, size.y + 0.8, 0) + basis * Vector3(0, 0, size.z * 0.5 + 0.4), CANDLE_ENERGY, true, CANDLE_REACH)
	_candle_light.visible = false
	_candle_light.set_meta(ArenaKit.KEEP_SHADOW, true)
	# painted as a bowl's pool (STYLE fire bowl_*): the altar's candles together light the room, not one candle's reach
	_candle_light.set_meta(ArenaKit.BOWL, true)


## The blind arch over the altar (spec 6.2): a dark panel sunk in the north wall under a pointed frame, the worn band
## of carving across it.
func _arch(foot: Vector2) -> void:
	var mat := ashlar()
	var face := foot.y - FACE_SET
	var base := Vector3(foot.x, 0.0, face)
	var straight := ARCH.y - ARCH.x * 0.55
	var dark := m.stone(0.0, ARCH_PANEL)
	# the panel on the wall's face, the frame standing ARCH.z out of it
	m.box(base + Vector3(0, straight * 0.5, 0.03), Vector3(ARCH.x, straight, 0.06), 0.0, dark, false)
	var head := m.box(base + Vector3(0, straight, 0.03), Vector3(ARCH.x * 0.7071, ARCH.x * 0.7071, 0.06), 0.0, dark, false)
	head.basis = Basis.from_scale(Vector3(1.0, 1.25, 1.0)) * Basis(Vector3.BACK, PI * 0.25)
	m.pointed_arch(base + Vector3(0, 0, ARCH.z * 0.5), Vector2(0, 1), ARCH.x, ARCH.y, 0.3, ARCH.z, mat)
	# the band, its carving worn away in stretches
	var band_z := face + 0.09
	m.box(Vector3(foot.x, BAND_AT, band_z), Vector3(BAND.x, BAND.y, 0.05), 0.0, m.stone(0.0, BAND_STONE), false)
	var cut := m.stone(0.0, BAND_CUT)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(foot * 10.0))
	for row in BAND_ROWS:
		var y := BAND_AT - BAND.y * 0.25 + BAND.y * 0.5 * row
		for k in BAND_STROKES:
			var x := foot.x - BAND.x * 0.46 + BAND.x * 0.92 * (k + 0.5) / BAND_STROKES
			if r.randf() < BAND_WORN or absf(sin(x * 1.7 + row)) < 0.25:
				continue
			var bar := m.box(Vector3(x, y, band_z + 0.028), Vector3(BAND_WIDTH, r.randf_range(BAND_STROKE.x, BAND_STROKE.y), 0.008), 0.0, cut, false)
			bar.rotate_object_local(Vector3.BACK, float(r.randi_range(-1, 1)) * PI * 0.25)


## Faded banners with the lion on the north wall (spec 6.2), the east one torn short (ArenaRoom.fade_banners: one faded
## twin of the cloth's and the lion's materials for both).
func _banners(north: float) -> void:
	for k in BANNERS.size():
		var torn := k == BANNERS.size() - 1
		var size := Vector2(BANNER_SIZE.x, BANNER_SIZE.y * (BANNER_TORN if torn else 1.0))
		var before := get_child_count()
		kit.banner(Vector3(BANNERS[k], BANNER_TOP, north - FACE_SET + 0.06), 0.0, size, 1, ArenaKit.Emblem.LION)
		var added: Array[Node] = []
		for i in range(before, get_child_count()):
			added.append(get_child(i))
		fade_banners(added, BANNER_FADE)


# ---------- the stylized look (room redesign lot D, docs/art/room_redesign_lotD_spec.md section 3) ----------

func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	st[&"floor"] = ArenaKit.CALM_FLOOR.merged(ArenaKit.SOFT_PATCHES).merged(STY_FLOOR_BIOME).merged(STY_FRAME)
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	diffuse_lights([_shaft])
	VisualProfile.vary(_shaft, {&"light_color": STY_SHAFT, &"light_energy": STY_SHAFT_ENERGY})
	style_backdrop(_far, STY_BACKDROP[0], STY_BACKDROP[1], STY_BACKDROP[2])
	return st


## The candles' light once lit: the look's (the stylized look's energy is stylize_fires').
func _kindled_energy() -> float:
	if VisualProfile.stylized():
		return float(VisualProfile.styled(_candle_light, &"light_energy", CANDLE_ENERGY))
	return CANDLE_ENERGY


## The pieces only the stylized look shows (spec 3.3), on kit.styled(), never the room's random numbers: A1 offerings
## on the altar's top before its candles and on shelves at the north wall's foot, A2 moss and ivy on the blind arch and
## the worn band, A3 pale petals on the floor before the altar's step.
func _dress_styled(north: float, altar: ArenaObstacle) -> void:
	var sm := kit.styled()
	var r := RandomNumberGenerator.new()
	r.seed = STY_SEED
	var urn := sm.carved(0.0, STY_URN)
	if altar != null:
		var foot := Vector3(altar.center.x, altar.height, altar.center.y)
		var basis := Basis(Vector3.UP, -altar.yaw)
		var front := altar.half.y - OFFERING_IN
		for k in OFFERINGS.size():
			var o: Vector3 = OFFERINGS[k]
			var p := foot + basis * Vector3(o.x, 0.0, front - o.z)
			_offering(sm, p, int(o.y), urn, r, -altar.yaw)
		_petals(sm, Vector2(altar.center.x, altar.center.y + altar.half.y + ALTAR_PLINTH.y))
	for span: Vector2 in SHELVES:
		var line := wall_ledge(sm, Vector2(span.x, north), Vector2(span.y, north), Vector2(0, -1), SHELF_HEIGHT, ashlar())
		var n := int(absf(span.y - span.x) / SHELF_STEP)
		for i in n:
			var p := line[0].lerp(line[1], (i + 0.5) / n)
			_offering(sm, p, i % 4, urn, r, 0.0)
	var face := north - FACE_SET
	var tops: Array[Vector3] = []
	for t: Vector3 in IVY:
		tops.append(Vector3(altar.center.x + t.x if altar != null else t.x, t.y, face + t.z))
	wall_moss(sm, tops, IVY_CARD, STY_MOSS)
	if altar != null:
		for sd: float in [-1.0, 1.0]:
			_basin(sm, Vector2(altar.center.x + sd * BASIN_AT, north))


## Sworn P2 SW-G4: offerings at the foot of the north and west walls, never under the basins.
func sworn_offerings() -> bool:
	return true


func offer_free(p: Vector2) -> bool:
	var north := layout.floor.bounds().position.y
	return absf(absf(p.x - _altar_x()) - BASIN_AT) > 1.0 or absf(p.y - north) > 1.0


func _altar_x() -> float:
	for o in layout.obstacles:
		if o.piece == &"altar":
			return o.center.x
	return layout.floor.bounds().get_center().x


## SW-A-1: two pedestals either side of the altar (BASIN_AT m from its middle, between it and the shelves), each a
## half column engaged in the north wall on the sill, off the floor, with a basin of dark water on it (half a bowl out
## of the wall's face: BASIN radius, its rim's height, its depth), and a narrow cold spot from above on it alone
## (diffuse, no shadow, never on the crowd): the local symmetry that marks the special place.
const BASIN_AT := 2.75
const BASIN := Vector3(0.27, 1.02, 0.12)
const BASIN_SHAFT := 0.16
const BASIN_WATER_DEEP := Color(0.035, 0.05, 0.06)
const BASIN_WATER_PALE := Color(0.42, 0.5, 0.54)
const BASIN_SPOT := Vector4(7.0, 9.0, 1.4, 1.2)
const BASIN_SPOT_COLOR := Color(0.78, 0.86, 0.95)
const WATER_SHADER := preload("res://assets/shaders/dark_water.gdshader")


func _basin(sm: Masonry, at: Vector2) -> void:
	var face := at.y - FACE_SET
	var mat := ashlar()
	var c := Vector3(at.x, 0.0, face)
	# the foot, the shaft and the bowl: their middles on the wall's face, so only the half toward the room shows
	sm.block(c, Vector3(BASIN.x * 1.7, 0.16, BASIN.x * 1.7), PI * 0.25, mat)
	sm.shaft(c + Vector3(0, 0.16, 0), BASIN_SHAFT, BASIN.y - 0.16 - BASIN.z, mat)
	var bowl := sm.shaft(c + Vector3(0, BASIN.y - BASIN.z, 0), BASIN.x, BASIN.z, mat)
	(bowl.mesh as CylinderMesh).bottom_radius = BASIN.x * 0.6
	sm.shaft(c + Vector3(0, BASIN.y, 0), BASIN.x + 0.02, 0.025, mat)
	var mi := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = BASIN.x - 0.035
	disc.bottom_radius = disc.top_radius
	disc.height = 0.004
	disc.radial_segments = 24
	mi.mesh = disc
	var water := ShaderMaterial.new()
	water.shader = WATER_SHADER
	water.set_shader_parameter(&"form", 0)
	water.set_shader_parameter(&"deep", BASIN_WATER_DEEP)
	water.set_shader_parameter(&"pale", BASIN_WATER_PALE)
	water.set_shader_parameter(&"size", Vector2.ONE * BASIN.x * 2.0)
	mi.material_override = water
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = c + Vector3(0, BASIN.y - 0.03, 0)
	sm.root.add_child(mi)
	var spot := SpotLight3D.new()
	sm.root.add_child(spot)
	spot.look_at_from_position(c + Vector3(0, BASIN_SPOT.x, BASIN_SPOT.z), c + Vector3(0, BASIN.y, 0.1))
	spot.light_color = BASIN_SPOT_COLOR
	spot.light_energy = BASIN_SPOT.w
	spot.spot_angle = BASIN_SPOT.y
	spot.spot_range = BASIN_SPOT.x * 1.5
	spot.light_specular = 0.0
	spot.shadow_enabled = false
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	spot.set_meta(ArenaKit.NOT_FIRE, true)


## One offering at `p` (on a top): 0 an urn, 1 an open urn, 2 a folded cloth (petrol or umber), 3 the old gold bowl.
func _offering(sm: Masonry, p: Vector3, kind: int, urn: Material, r: RandomNumberGenerator, yaw: float) -> void:
	match kind:
		0:
			sm.urn(p, r.randf_range(OFFERING_URN.x, OFFERING_URN.y), urn)
		1:
			sm.urn(p, r.randf_range(OFFERING_URN.x, OFFERING_URN.y) * 0.8, urn, false)
		2:
			var cloth := _cloth(STY_CLOTH_PETROL if r.randf() < 0.5 else STY_CLOTH_UMBER)
			var size := Vector3(r.randf_range(0.16, 0.22), CLOTH_THICK, r.randf_range(0.14, 0.18))
			sm.box(p + Vector3(0, size.y * 0.5, 0), size, yaw + r.randf_range(-0.3, 0.3), cloth, false)
			sm.box(p + Vector3(0, size.y * 1.5, 0), size * Vector3(0.9, 1.0, 0.5), yaw + r.randf_range(-0.3, 0.3), cloth, false)
		3:
			if _bowl_mat == null:
				_bowl_mat = StandardMaterial3D.new()
				_bowl_mat.albedo_color = ArenaKit.STY_GOLD
				_bowl_mat.roughness = ArenaKit.STY_METAL.x
				_bowl_mat.metallic = ArenaKit.STY_METAL.y
			var bowl := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = BOWL.x
			cyl.bottom_radius = BOWL.y
			cyl.height = BOWL.z
			cyl.radial_segments = 12
			cyl.rings = 1
			bowl.mesh = cyl
			bowl.material_override = _bowl_mat
			bowl.position = p + Vector3(0, BOWL.z * 0.5, 0)
			sm.root.add_child(bowl)


var _bowl_mat: StandardMaterial3D
var _cloths := {}


func _cloth(c: Color) -> StandardMaterial3D:
	if not _cloths.has(c):
		var m_ := StandardMaterial3D.new()
		m_.albedo_color = c
		m_.roughness = 0.95
		_cloths[c] = m_
	return _cloths[c]


## A3: pale ivory and dim lilac petals on the floor before the step (floor_decal kind 3, as the fountain's flowers),
## densest at the step (`at`: the step's front middle).
func _petals(sm: Masonry, at: Vector2) -> void:
	var mi := MeshInstance3D.new()
	var q := PlaneMesh.new()
	q.size = PETALS
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = CatacombHall.DECAL_SHADER
	mat.set_shader_parameter(&"kind", 3)
	mat.set_shader_parameter(&"rug_size", PETALS)
	mat.set_shader_parameter(&"leaf_dark", PETAL_LILAC)
	mat.set_shader_parameter(&"leaf_light", PETAL_PALE)
	mat.set_shader_parameter(&"litter_cell", PETAL_CELL)
	mat.set_shader_parameter(&"litter_size", PETAL_SIZE)
	mat.set_shader_parameter(&"litter_cover", PETAL_COVER)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(at.x, PETAL_Y, at.y + PETALS.y * 0.5)
	sm.root.add_child(mi)
