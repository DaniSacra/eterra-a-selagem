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
## The lion's gold on a banner (banner_lion.gdshader's default), faded from it.
const LION_GOLD := Color(0.65, 0.47, 0.18)
## The cold shaft on the altar (spec 6.2): colour, energy, cone, height.
const SHAFT := Color(0.70, 0.78, 0.92)
const SHAFT_ENERGY := 2.0
const SHAFT_CONE := 16.0
const SHAFT_HEIGHT := 12.0
## The hall's floor without its medallion, the room a step darker (spec 6.3).
const FLOOR := {&"calm_radius": 0.0}
const AIR := {&"ambient_gain": 0.9, &"sky": Color(0.02, 0.025, 0.03)}
## A dim cold fill so the floor reads between the shaft and the door.
const FILL := Color(0.62, 0.66, 0.78)
const FILL_ENERGY := 1.0
## Under the chapel: dark, no teal of the hall's abyss (a closed room).
const MIST := Color(0.03, 0.035, 0.045)
const CLIFF := {&"stone_color": Color(0.08, 0.08, 0.09), &"edge_color": Color(0.14, 0.14, 0.16), &"mist_color": Color(0.03, 0.035, 0.045)}

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
	moon_shaft(altar, SHAFT, SHAFT_ENERGY, SHAFT_CONE, SHAFT_HEIGHT, true, true)
	key_light(FILL, FILL_ENERGY, 10.0)


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
		_candle_light.light_energy = CANDLE_ENERGY
		return
	_candle_light.light_energy = 0.0
	_tween = create_tween()
	_tween.tween_property(_candle_light, "light_energy", CANDLE_ENERGY, seconds)


## The lab's states: "after" the candles lit.
func demo(state: String) -> void:
	if state == "after":
		kindle(0.0)


## The altar on its footprint (spec 6.2): plinth, body, the top slab with a lip, the lion raised on the face toward the
## room, the candles on top (burnt out; the lit ones hidden until kindle).
func _altar(o: ArenaObstacle) -> void:
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


## Faded banners with the lion on the north wall (spec 6.2), the east one torn short; one faded twin of the cloth's
## and the lion's materials for both.
func _banners(north: float) -> void:
	var faded: Material
	var lion: Material
	for k in BANNERS.size():
		var torn := k == BANNERS.size() - 1
		var size := Vector2(BANNER_SIZE.x, BANNER_SIZE.y * (BANNER_TORN if torn else 1.0))
		var before := get_child_count()
		kit.banner(Vector3(BANNERS[k], BANNER_TOP, north - FACE_SET + 0.06), 0.0, size, 1, ArenaKit.Emblem.LION)
		for i in range(before, get_child_count()):
			var mi := get_child(i) as MeshInstance3D
			if mi == null or mi.material_override == null:
				continue
			if mi.material_override is StandardMaterial3D:
				if faded == null:
					var f := (mi.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
					f.albedo_color = f.albedo_color.darkened(1.0 - BANNER_FADE).lerp(Color(0.3, 0.28, 0.27), 0.3)
					if f.emission_enabled:
						f.emission_energy_multiplier *= BANNER_FADE
					faded = f
				mi.material_override = faded
			elif mi.material_override is ShaderMaterial:
				if lion == null:
					var l := (mi.material_override as ShaderMaterial).duplicate() as ShaderMaterial
					var g: Variant = l.get_shader_parameter(&"gold")
					var gold: Color = g if g is Color else LION_GOLD
					l.set_shader_parameter(&"gold", gold.darkened(1.0 - BANNER_FADE))
					l.set_shader_parameter(&"glow", 0.35 * BANNER_FADE)
					lion = l
				mi.material_override = lion
