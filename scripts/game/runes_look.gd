class_name RunesLook
extends ArenaRoom
## The look of the Câmara das Runas Instáveis (the chamber of the unstable runes, E5 spec docs/art/e5_spec.md section 3):
## a square room of dark cold stone where the floor is the room. Its slabs are the rune tiles of 3 m (rune_floor.gdshader:
## a frame of old gold sunk round each, three worn straight marks inside), the quiet stone of variant B smooth basalt
## (a box &"quiet" of the layout that stops nothing). The north wall (7 m of basalt) holds three tall stelae covered in
## straight carved marks, nothing legible, the door of X1 between them with its fire bowls in recesses; the west wall
## the arcade of the way in; south and east a balustrade over the abyss; the rune pillars (&"rune_pillar") of the layout
## with their own grooves of gold. Light from above, cold and wide; the only warmth on the floor is the runes' amber.
## The danger itself (patterns, timing, damage) is the gameplay's (ArenaHazard): it writes each tile's state here
## (set_tile, then apply once a frame) and this draws it: the floor's frames warm to amber, the sheet of light of a
## strike (rune_flash.gdshader), the pillars' grooves warming with any tile, up to four amber lights over the armed
## bands (Forward+ only, no shadows). Nothing round, anywhere (D-29).

## A tile's side (m) and what its alpha says it is (the shader reads it).
const TILE := 3.0
const RUNE := 1.0
const QUIET := 0.5
## The walls: height, the stelae (width, height, depth; their x on the north wall, the door between them), the ledge at
## each stele's foot for its candles (height, depth out of the wall), the carved marks on a stele (rows, strokes a row,
## stroke length range, width).
const WALL_HEIGHT := 7.0
const STELE := Vector3(1.2, 5.0, 0.4)
## The stele's cap: two stepped courses this tall.
const STELE_CAP := 0.22
const STELAE: Array[float] = [-8.5, -1.0, 11.0]
const LEDGE := Vector2(1.0, 0.25)
const MARK_ROWS := 9
const MARK_STROKES := 4
const MARK_LENGTH := Vector2(0.12, 0.3)
const MARK_WIDTH := 0.035
## The way in: an arcade in the west wall at the paladin's z (width), stairs going down out of it.
const ENTRY_WIDE := 4.0
const ENTRY_STEPS := 6
## A rune pillar: plinth (height, how much wider), cap (height, how much wider), the gold grooves up each face (how
## many, width, how far from the foot and the top).
const PILLAR_PLINTH := Vector2(0.35, 0.2)
const PILLAR_CAP := Vector2(0.3, 0.16)
const PILLAR_GROOVES := 2
const PILLAR_GROOVE := 0.06
const PILLAR_GROOVE_SPAN := Vector2(0.6, 0.6)
## The pillars' grooves: old gold at rest, amber (to this light) while any tile arms. C18 (QW-108): a third of what it
## was (1.0 lit them as orange stripes brighter than the tiles), and opening round the paladin with the pillar
## (rune_groove.gdshader).
const GROOVE_HEAT := 0.35
const GROOVE_SHADER := preload("res://assets/shaders/rune_groove.gdshader")
## The stone (spec 3.6): blue-black basalt, the floor a cold neutral stone, a slab a tile.
const STONE := Color(0.72, 0.74, 0.82)
const FLOOR := {
	&"unit": 3.0, &"stone_a": Color(0.27, 0.27, 0.30), &"stone_b": Color(0.36, 0.36, 0.40),
	&"joint_color": Color(0.06, 0.06, 0.08), &"moss_color": Color(0.27, 0.27, 0.30), &"petal_color": Color(0.27, 0.27, 0.30),
	&"missing": 0.0, &"cracked": 0.85, &"slab_value": Vector2(0.85, 1.12), &"slab_tilt": 1.0, &"corner_round": 0.05,
	&"wobble": 0.02,
}
## The air (spec 3.6).
const AIR := {
	&"sky": Color(0.06, 0.06, 0.075), &"fog": Color(0.1, 0.1, 0.12), &"fog_depth": Vector2(45.0, 100.0),
	&"ambient": Color(0.32, 0.32, 0.36), &"ambient_gain": 1.75, &"moon": Color(0.62, 0.66, 0.78), &"moon_energy": 0.7,
	&"moon_shadow": false,
}
const MIST := Color(0.03, 0.03, 0.06)
## The tower's faces under the floor: the same blue-black basalt going down into the dark.
const CLIFF := {&"stone_color": Color(0.07, 0.075, 0.1), &"edge_color": Color(0.14, 0.15, 0.2), &"mist_color": Color(0.03, 0.03, 0.06)}
## The cold light from above (spec 3.6; B a step colder), no shadow, wide and even.
const KEY := Color(0.78, 0.82, 0.95)
const KEY_B := Color(0.74, 0.8, 0.98)
const KEY_ENERGY := 1.8
const KEY_HEIGHT := 12.0
const KEY_REACH := 30.0
const KEY_FALLOFF := 0.5
## The north door's fire bowls: their pool kept within 2 m of the wall (spec 3.6: the amber on the floor is the runes').
const BOWL_ENERGY := 2.6
const BOWL_RANGE := 4.0
## B: the stelae's candles, half lit, one group with shadow.
const STELE_CANDLES := 1.4
## Lights over the armed bands (spec 3.4): at most, their energy at full arming, height, least range; only Forward+.
const ARM_LIGHTS := 4
const ARM_ENERGY := 1.0
const ARM_HEIGHT := 1.6
const ARM_RANGE := 5.0
const FLASH_SHADER := preload("res://assets/shaders/rune_flash.gdshader")
const FLOOR_SHADER := ArenaKit.RUNE_FLOOR
## The sheet of the strike: its colour (ivory-amber, spec 3.4) and how far inside the frame it starts.
const FLASH := Color(1.0, 0.88, 0.70)
const FLASH_INSET := 0.1

## The stylized look (room redesign lot D, docs/art/room_redesign_lotD_spec.md 1.3): pale cold stone, almost grey, so
## the amber of an armed tile reads alone; the north door's bowls with the hall's fire numbers (the lights over the armed
## tiles are the danger's: ArenaKit.NOT_FIRE, as they are, only diffuse, nothing round on the floor).
## The cycle of 2026-11-20 (ART_REVIEW.md, the Salão's method by biome): the pale stone colder (hue 232 to 242 on the
## screen) through the stone, the shadow and the air, the saturation at the low end; the floor is the danger, so only
## its rest grows quieter (STY_REST).
const STYLE := {
	&"stone": Color(0.335, 0.34, 0.395), &"shadow": Color(0.88, 0.9, 1.0), &"floor_stone": Color(0.33, 0.335, 0.385),
	&"joint_cold": Color(1.0, 1.0, 1.02), &"olive_share": 0.0, &"slab_hue": 2.0, &"edge_value": 1.0, &"metal": true, &"fire": CatacombHall.STYLE[&"fire"],
	&"air": {&"sky": Color(0.045, 0.05, 0.07), &"fog": Color(0.09, 0.10, 0.13), &"ambient": Color(0.69, 0.70, 0.79),
		&"ambient_gain": 1.7, &"moon": Color(0.9, 0.9, 0.93), &"moon_energy": 0.8, &"moon_shadow": false},
}
## Item 4 of the cycle: the grid at rest discreet (the frames' and marks' ivory trace nearer the stone,
## rune_tiles.gdshaderinc), the strong amber only on a tile that arms.
## Art review 2026-11-21 item 8: the quiet (safe) stone at most about 1.25 times its neighbours (paint_quiet_value 0.5 read near white).
const STY_REST := {&"paint_trace_share": 0.2, &"paint_quiet_value": 0.36}
## Art review 2026-11-21 item 1: the outer face of the wall keeps its stone to 1 m under the floor and sinks into the
## mist (near black) by 5 m, so the bottom of the frame is no flat, dark wall.
const STY_DEPTH_SINK := {&"sink_top": -1.0, &"sink_bottom": -5.0}
## The browser's renderer: the stylized air's share there.
const STY_COMPAT_AMBIENT := 0.7
const STY_COMPAT_MOON := 0.6
## Cadence review 7 (P1): in the browser's renderer an armed tile has no light over it (ARM_LIGHTS are Forward+ only)
## and its own light comes out without the linear to sRGB step: there the tile's light is COMPAT_GAIN times its own, its
## stone goes COMPAT_FILL of the way toward the amber at COMPAT_TONE, and it glows COMPAT_GLOW of the amber, both times
## the arming; the strike and its ember lay it toward the ivory-amber and glow COMPAT_STRIKE (the desktop's strike reads
## cream over the whole tile, here it was a pale grey gone in 0.1 s) (rune_tiles.gdshaderinc paint_compat_*; stylized
## only, the desktop untouched).
const COMPAT_GAIN := 1.6
const COMPAT_FILL := 0.4
const COMPAT_TONE := 0.6
const COMPAT_GLOW := 0.45
const COMPAT_STRIKE := 0.4
## R1 and R3: the glyphs of the pillars at rest and the marks of the stelae, dim carved ivory (never green); the
## pillars' grooves matte stone there (metallic, roughness). The cycle of 2026-11-20: a step dimmer (the grooves read
## as white stripes over the resting grid).
const STY_IVORY := Color(0.42, 0.40, 0.36)
## The light from above in the stylized look: near neutral (the floor's saturation stays low) and diffuse.
const STY_KEY := Color(0.86, 0.87, 0.9)
const STY_GROOVE := Vector2(0.05, 0.85)
## R2: the mechanism on the north wall between the first two stelae (x, its middle's height, the side of its outer
## lozenge: a square turned 45 degrees), its rings (sides as shares of the outer one), a bar's width and depth, the
## counterweights (size), the dark backing (its side over the outer ring's, its stone), its old gold (colour; metallic,
## roughness), and the faint cold spot that parts it from the wall (colour, energy, cone, where from: up, out).
const MECH := Vector3(-4.75, 3.5, 4.9)
const MECH_RINGS: Array[float] = [1.0, 0.7, 0.4]
const MECH_BAR := Vector2(0.14, 0.08)
const MECH_WEIGHT := Vector3(0.36, 0.5, 0.1)
const MECH_BACK := 1.06
const MECH_BACK_STONE := Color(0.55, 0.56, 0.6)
const MECH_GOLD := Color(0.42, 0.31, 0.13)
const MECH_METAL := Vector2(0.35, 0.75)
const MECH_SPOT := Color(0.78, 0.82, 0.95)
const MECH_SPOT_ENERGY := 1.2
const MECH_SPOT_CONE := 24.0
const MECH_SPOT_FROM := Vector2(9.5, 4.5)
## R4: the study's things on a shelf along the north-west cut, off the floor (its top's height; what stands along it,
## in order: 0 crate, 1 urn, 2 burnt candle, 3 folded cloth), the crates' side, the urns' height range, the cloth.
const STUDY_HEIGHT := 0.95
const STUDY: Array[int] = [0, 1, 2, 2, 3, 0, 1, 2, 1, 0]
const STUDY_CRATE := 0.24
const STUDY_URN := Vector2(0.22, 0.32)
const STUDY_CLOTH := Color(0.06, 0.13, 0.14)
const STY_SEED := 3917
## R5 (B): the crystal against the north wall's foot, off the floor, before the quiet stone's axis: its middle (x),
## how many prisms, their height and radius ranges, how far they lean back and aside (degrees), its colour (albedo
## share, the edge's glow peak: the brightest channel twice that, under 0.8).
const CRYSTAL_X := 1.5
const CRYSTAL_SPREAD := 1.1
const CRYSTALS := 6
const CRYSTAL_HEIGHT := Vector2(1.2, 3.0)
const CRYSTAL_RADIUS := Vector2(0.12, 0.28)
const CRYSTAL_LEAN := Vector2(4.0, 14.0)
const CRYSTAL_COLOR := Color(0.62, 0.68, 0.75)
const CRYSTAL_ALBEDO := 0.45
const CRYSTAL_PEAK := 0.35
const CRYSTAL_SHADER := preload("res://assets/shaders/crystal_edge.gdshader")

var _origin := Vector2.ZERO
var _grid := Vector2i.ZERO
var _image: Image
var _texture: ImageTexture
var _flash: ShaderMaterial
var _flash_mesh: MeshInstance3D
var _groove: ShaderMaterial
var _lights: Array[OmniLight3D] = []
var _heat := 0.0
var _quiet := false
var _marks: Array[MeshInstance3D] = []
var _key: OmniLight3D


func floor_shader() -> Shader:
	return FLOOR_SHADER


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


## The north door (X1) opens in the wall.
func in_wall(i: int) -> bool:
	return layout.exits[i].inward.y > 0.5


## The north and west sides and the north-west cut are walls (drawn in dress); the rest stands over the abyss behind
## a balustrade (dotted round the paladin on the edges the camera looks across).
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	if _walled(out):
		return
	broken_edge(a, b, out, faces)
	balustrade_edge(a, b, out, false)


func _walled(out: Vector2) -> bool:
	return out.y < -0.5 and out.x < 0.5 or out.x < -0.9


## The north door's fire bowls: a short warm pool by the wall only.
func piece(o: ArenaObstacle) -> void:
	match o.piece:
		&"brazier":
			var l := kit.brazier(o.center, 0.0, false)
			l.light_energy = BOWL_ENERGY
			l.omni_range = BOWL_RANGE
		&"rune_pillar":
			_pillar(o)
		_:
			super.piece(o)


func dress() -> void:
	var box := layout.floor.bounds()
	_origin = box.position
	_grid = Vector2i(ceili(box.size.x / TILE - 0.01), ceili(box.size.y / TILE - 0.01))
	for o in layout.obstacles:
		if o.piece == &"quiet":
			_quiet = true
	_tiles()
	_walls(box)
	_flash_sheet()
	var key := key_light(KEY_B if _quiet else KEY, KEY_ENERGY, KEY_HEIGHT)
	_key = key
	key.omni_range = KEY_REACH
	key.omni_attenuation = KEY_FALLOFF
	if compat():
		floor_mat.set_shader_parameter(&"paint_compat_gain", COMPAT_GAIN)
		floor_mat.set_shader_parameter(&"paint_compat_fill", COMPAT_FILL)
		floor_mat.set_shader_parameter(&"paint_compat_tone", COMPAT_TONE)
		floor_mat.set_shader_parameter(&"paint_compat_glow", COMPAT_GLOW)
		floor_mat.set_shader_parameter(&"paint_compat_strike", COMPAT_STRIKE)
	else:
		for k in ARM_LIGHTS:
			var l := OmniLight3D.new()
			l.light_color = ArenaKit.FIRE
			l.light_energy = 0.0
			l.omni_range = ARM_RANGE
			l.visible = false
			l.light_cull_mask = ~Arena.CROWD_LAYER
			l.set_meta(ArenaKit.NOT_FIRE, true)
			add_child(l)
			_lights.append(l)
	_dress_styled(box)


# ---------- the tiles' state (the gameplay writes it) ----------

## How many tiles across (columns west to east) and down (rows north to south).
func grid() -> Vector2i:
	return _grid


## The tile under a floor point (may be outside the grid near the edges).
func tile_at(p: Vector2) -> Vector2i:
	return Vector2i(floori((p.x - _origin.x) / TILE), floori((p.y - _origin.y) / TILE))


## The floor a tile covers.
func tile_rect(t: Vector2i) -> Rect2:
	return Rect2(_origin + Vector2(t) * TILE, Vector2(TILE, TILE))


## True when the tile is the quiet stone (never lights).
func is_quiet(t: Vector2i) -> bool:
	return _image.get_pixel(t.x, t.y).a < (RUNE + QUIET) * 0.5


## One tile's state: arming 0 to 1 (spec 3.4: 1.2 s), firing 1 at the strike falling to 0 (0.25 s), the ember left
## after it 1 falling to 0 (0.4 s). Seen at the next apply().
func set_tile(t: Vector2i, arm: float, fire: float, ember: float) -> void:
	if t.x < 0 or t.y < 0 or t.x >= _grid.x or t.y >= _grid.y:
		return
	var kind := _image.get_pixel(t.x, t.y).a
	if kind < (RUNE + QUIET) * 0.5:
		return
	_image.set_pixel(t.x, t.y, Color(clampf(arm, 0.0, 1.0), clampf(fire, 0.0, 1.0), clampf(ember, 0.0, 1.0), kind))


## Every tile back to rest.
func clear_tiles() -> void:
	for y in _grid.y:
		for x in _grid.x:
			var kind := _image.get_pixel(x, y).a
			_image.set_pixel(x, y, Color(0, 0, 0, kind))


## The way the chevrons of the armed tiles run (toward the next band; zero: none).
func set_chevrons(dir: Vector2) -> void:
	floor_mat.set_shader_parameter(&"chevron_dir", dir)


## Shows the tiles as set: the floor, the sheets of the strikes, the pillars' grooves and the lights over the armed bands.
func apply() -> void:
	_texture.update(_image)
	var armed: Array[Vector3] = []
	_heat = 0.0
	for y in _grid.y:
		for x in _grid.x:
			var c := _image.get_pixel(x, y)
			_heat = maxf(_heat, maxf(c.r, c.b * 0.5))
			if c.r > 0.02:
				var mid := tile_rect(Vector2i(x, y)).get_center()
				armed.append(Vector3(mid.x, mid.y, c.r))
	if _groove != null:
		_groove.set_shader_parameter(&"glow", ArenaKit.FIRE * (_heat * GROOVE_HEAT))
		_groove.set_shader_parameter(&"gold", TombKit.GOLD.lerp(ArenaKit.FIRE, _heat * 0.5))
		_groove.set_shader_parameter(&"heat", _heat)
	_place_lights(armed)


## The state as the shader reads it (one texel a tile).
func state_image() -> Image:
	return _image


## How warm the room is (the most armed tile): the pillars' grooves follow it.
func heat() -> float:
	return _heat


## The tiles and their state texture; the quiet stone from the layout.
func _tiles() -> void:
	_image = Image.create(_grid.x, _grid.y, false, Image.FORMAT_RGBA8)
	for y in _grid.y:
		for x in _grid.x:
			var mid := _origin + (Vector2(x, y) + Vector2(0.5, 0.5)) * TILE
			var kind := RUNE
			for o in layout.obstacles:
				if o.piece == &"quiet" and o.depth(mid, 0.0) > 0.0:
					kind = QUIET
			_image.set_pixel(x, y, Color(0, 0, 0, kind))
	_texture = ImageTexture.create_from_image(_image)
	floor_mat.set_shader_parameter(&"rune_state", _texture)
	floor_mat.set_shader_parameter(&"rune_grid", _grid)
	floor_mat.set_shader_parameter(&"rune_origin", _origin)
	# no calm middle: every tile reads the same
	floor_mat.set_shader_parameter(&"calm_radius", 0.0)


## The sheets of light of the strikes: one square a tile (inside its frame), folded away until the tile fires.
func _flash_sheet() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for y in _grid.y:
		for x in _grid.x:
			var r := tile_rect(Vector2i(x, y)).grow(-FLASH_INSET)
			var q: Array[Vector2] = [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
			var uv: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
			for k: int in [0, 1, 2, 0, 2, 3]:
				st.set_uv(uv[k])
				st.set_uv2(Vector2(x, y) + Vector2(0.5, 0.5))
				st.add_vertex(Vector3(q[k].x, 0.03, q[k].y))
	_flash = ShaderMaterial.new()
	_flash.shader = FLASH_SHADER
	_flash.set_shader_parameter(&"rune_state", _texture)
	_flash.set_shader_parameter(&"color", FLASH)
	_flash.set_shader_parameter(&"cap", ScreenTone.linear_peak(FLASH))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _flash
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.extra_cull_margin = 1.0
	add_child(mi)
	_flash_mesh = mi


## Up to ARM_LIGHTS warm lights over the armed tiles (spec 3.4): the tiles in reading order cut in even runs, a light
## over each run's middle, as strong as its most armed tile.
func _place_lights(armed: Array[Vector3]) -> void:
	if _lights.is_empty():
		return
	var runs := mini(_lights.size(), armed.size())
	for k in _lights.size():
		var l := _lights[k]
		if k >= runs:
			l.visible = false
			continue
		var from := armed.size() * k / runs
		var to := armed.size() * (k + 1) / runs
		var mid := Vector2.ZERO
		var most := 0.0
		var box := Rect2(Vector2(armed[from].x, armed[from].y), Vector2.ZERO)
		for i in range(from, to):
			mid += Vector2(armed[i].x, armed[i].y)
			most = maxf(most, armed[i].z)
			box = box.expand(Vector2(armed[i].x, armed[i].y))
		mid /= float(to - from)
		l.position = Vector3(mid.x, ARM_HEIGHT, mid.y)
		l.light_energy = ARM_ENERGY * most
		l.omni_range = maxf(ARM_RANGE, box.size.length() * 0.6 + TILE)
		l.visible = true


## The lab's states (tools/arena_lab.gd --state=): "arm" two bands of the sweep armed with their chevrons, "fire" one
## band striking and the other's ember ("fire_floor" the same without the sheet of light), "checker", "after"/"" at rest.
func demo(state: String) -> void:
	clear_tiles()
	match state:
		"arm":
			for x in _grid.x:
				set_tile(Vector2i(x, 1), 0.85, 0.0, 0.0)
				set_tile(Vector2i(x, 5), 0.5, 0.0, 0.0)
			set_chevrons(Vector2(0, 1))
		"fire", "fire_floor":
			# fire_floor: the floor alone, without the sheet of light over it
			_flash_mesh.visible = state == "fire"
			for x in _grid.x:
				set_tile(Vector2i(x, 1), 0.0, 0.7, 0.0)
				set_tile(Vector2i(x, 5), 0.0, 0.0, 0.6)
		"checker":
			for y in _grid.y:
				for x in _grid.x:
					if (x + y) % 2 == 0:
						set_tile(Vector2i(x, y), 0.9, 0.0, 0.0)
	apply()


# ---------- the walls ----------

## The north wall with its stelae, its door and the fire bowls' recesses; the north-west cut; the west wall with the
## arcade of the way in.
func _walls(box: Rect2) -> void:
	var mat := ashlar()
	var north := box.position.y
	var west := box.position.x
	var poly := layout.floor.polys[0]
	# the corners where the north and west walls meet the cut, and their far ends, from the outline
	var nw_a := Vector2(west, box.end.y)
	var nw_b := Vector2(box.end.x, north)
	var ne := Vector2(box.position.x, north)
	var sw := Vector2(west, box.position.y)
	for p in poly:
		if is_equal_approx(p.x, west):
			nw_a.y = minf(nw_a.y, p.y)
			sw.y = maxf(sw.y, p.y)
		if is_equal_approx(p.y, north):
			nw_b.x = minf(nw_b.x, p.x)
			ne.x = maxf(ne.x, p.x)
	var openings: Array[Vector4] = []
	var recesses: Array[Vector2] = []
	for i in layout.exits.size():
		var e := layout.exits[i]
		if in_wall(i):
			var w := absf(e.mouth.size.x)
			var s := e.mouth.get_center().x - nw_b.x
			openings.append(Vector4(s - w * 0.5 - JAMB, s + w * 0.5 + JAMB, 0.0, WALL_DOOR.y + 0.4))
			door_arch(Vector2(e.mouth.get_center().x, north), Vector2(0, 1), w, FACE_SET + 0.45)
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.y < north:
			var s := o.center.x - nw_b.x
			openings.append(Vector4(s - 0.75, s + 0.75, 0.0, 3.2))
			recesses.append(Vector2(s - 0.75, s + 0.75))
	var north_b := ne + Vector2(0.5, 0)
	wall(nw_b, north_b, Vector2(0, -1), WALL_HEIGHT, openings, mat)
	for r in recesses:
		wall_part(nw_b, north_b, Vector2(0, -1), r.x, r.y, FACE_SET + 1.25, FACE_SET + FACE_THICK, 0.0, 3.2, mat)
	# the north-west cut is the corner of the walls
	var cut_out := (nw_b - nw_a).orthogonal().normalized()
	if layout.floor.covers((nw_a + nw_b) * 0.5 + cut_out * 0.3):
		cut_out = -cut_out
	wall(nw_a, nw_b, cut_out, WALL_HEIGHT, [], mat)
	# the west wall with the arcade of the way in at the paladin's z
	var entry := layout.hero_spawn.y
	var s0 := sw.y - entry - ENTRY_WIDE * 0.5
	wall(sw, nw_a, Vector2(-1, 0), WALL_HEIGHT, [Vector4(s0 - JAMB, s0 + ENTRY_WIDE + JAMB, 0.0, WALL_DOOR.y + 0.4)], mat)
	door_arch(Vector2(west, entry), Vector2(1, 0), ENTRY_WIDE, FACE_SET + 0.45)
	m.stairs(Vector3(west - FACE_SET - 0.2, 0.0, entry), Vector2(-1, 0), ENTRY_WIDE, ENTRY_STEPS, 0.2, 0.45)
	tomb.bar(Vector3(west + 0.04, 0.004, entry), Vector3(0.05, 0.008, ENTRY_WIDE), 0.0, tomb.gold())
	for x in STELAE:
		_stele(Vector2(x, north), mat)


## A tall stele against the north wall (spec 3.1): a slab of basalt with rows of straight carved strokes in old gold
## (traces and angles, no curve, nothing legible), a ledge at its foot with candles (B: half of them lit, one group
## with shadow).
func _stele(at: Vector2, mat: Material) -> void:
	var face := at.y - 0.05
	var c := Vector3(at.x, 0.0, face - STELE.z * 0.5)
	m.block(c, Vector3(STELE.x + 0.3, 0.3, STELE.z + 0.1), 0.0, mat)
	m.block(c + Vector3(0, 0.3, 0), Vector3(STELE.x, STELE.y - 0.3, STELE.z), 0.0, mat)
	m.block(c + Vector3(0, STELE.y, 0), Vector3(STELE.x + 0.1, STELE_CAP, STELE.z + 0.06), 0.0, mat)
	m.block(c + Vector3(0, STELE.y + STELE_CAP, 0), Vector3(STELE.x * 0.6, STELE_CAP, STELE.z), 0.0, mat)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(at * 10.0))
	var gold := tomb.gold()
	var rows := MARK_ROWS
	for row in rows:
		var y := 1.4 + (STELE.y - 1.9) * (row + 0.5) / rows
		for k in MARK_STROKES:
			if r.randf() < 0.18:
				continue
			var x := at.x - STELE.x * 0.38 + STELE.x * 0.76 * (k + 0.5) / MARK_STROKES
			var turn := float(r.randi_range(0, 3)) * PI * 0.25
			var bar := tomb.bar(Vector3(x, y, face + 0.006), Vector3(r.randf_range(MARK_LENGTH.x, MARK_LENGTH.y), MARK_WIDTH, 0.012), 0.0, gold)
			bar.rotate_object_local(Vector3.BACK, turn)
			_marks.append(bar)
	# the ledge at its foot, out of the floor (between the wall's face and the edge)
	var ledge := Vector3(at.x, LEDGE.x, at.y - LEDGE.y * 0.5 - 0.04)
	m.box(ledge - Vector3(0, 0.06, 0), Vector3(STELE.x + 0.4, 0.12, LEDGE.y), 0.0, mat, false)
	var lit := _quiet and at.x < 0.0
	candle_line(ledge + Vector3(-STELE.x * 0.4, 0, 0), ledge + Vector3(STELE.x * 0.4, 0, 0), 4, lit)
	if lit and at.x < STELAE[1] + 0.1 and at.x > STELAE[1] - 0.1:
		warm_light(ledge + Vector3(0, 0.6, 0.6), STELE_CANDLES, true, 3.5)


## A rune pillar on its footprint (spec 3.2): basalt with a plinth and a cap, opening round the paladin behind it, two
## straight grooves of old gold up each face that warm to amber with the floor (apply).
func _pillar(o: ArenaObstacle) -> void:
	var mat := see(ashlar()) if o.see_through else ashlar()
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var w := minf(o.half.x, o.half.y) * 2.0
	var yaw := -o.yaw
	m.block(foot, Vector3(w + PILLAR_PLINTH.y, PILLAR_PLINTH.x, w + PILLAR_PLINTH.y), yaw, mat)
	m.block(foot, Vector3(w, o.height - PILLAR_CAP.x, w), yaw, mat)
	m.block(foot + Vector3(0, o.height - PILLAR_CAP.x, 0), Vector3(w + PILLAR_CAP.y, PILLAR_CAP.x, w + PILLAR_CAP.y), yaw, mat)
	if _groove == null:
		_groove = ShaderMaterial.new()
		_groove.shader = GROOVE_SHADER
		_groove.set_shader_parameter(&"gold", TombKit.GOLD)
		_groove.set_shader_parameter(&"see_through", 1.0 if o.see_through else 0.0)
	var span := o.height - PILLAR_GROOVE_SPAN.x - PILLAR_GROOVE_SPAN.y
	for f in 4:
		var face := Basis(Vector3.UP, yaw + PI * 0.5 * f)
		for k in PILLAR_GROOVES:
			var across := (float(k) - (PILLAR_GROOVES - 1) * 0.5) * w * 0.35
			var p := foot + face * Vector3(across, PILLAR_GROOVE_SPAN.x + span * 0.5, w * 0.5 + 0.004)
			var bar := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(PILLAR_GROOVE, span, 0.01)
			bar.mesh = bm
			bar.material_override = _groove
			bar.transform = Transform3D(face, p)
			bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(bar)


# ---------- the stylized look (room redesign lot D, docs/art/room_redesign_lotD_spec.md section 1) ----------

func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	st[&"floor"] = STY_REST
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	diffuse_lights()
	style_depths(STY_DEPTH_SINK)
	VisualProfile.vary(_key, {&"light_color": STY_KEY})
	# the fires and the danger's lights: as they are, but diffuse (a fire's drawn pool is a ring on the floor, D-29)
	for n in find_children("*", "OmniLight3D", true, false):
		VisualProfile.vary(n, {&"light_specular": 0.0})
	if _groove != null:
		VisualProfile.vary(_groove, {&"shader_parameter/ivory": STY_IVORY, &"shader_parameter/ivory_share": 1.0,
			&"shader_parameter/metallic": STY_GROOVE.x, &"shader_parameter/roughness": STY_GROOVE.y})
	var ivory := StandardMaterial3D.new()
	ivory.albedo_color = STY_IVORY
	ivory.roughness = 0.9
	for bar in _marks:
		VisualProfile.vary(bar, {&"material_override": ivory})
	return st


## The pieces only the stylized look shows (spec 1.4), on kit.styled(), never the room's random numbers: R2 the
## mechanism on the north wall, R4 the study's things on the north-west cut, R5 (B) the crystal at the north wall's foot.
func _dress_styled(box: Rect2) -> void:
	var sm := kit.styled()
	var north := box.position.y
	_mechanism(sm, north - FACE_SET)
	var poly := layout.floor.polys[0]
	# the north-west cut: the edge between the west side's top and the north side's west end
	var a := Vector2(box.position.x, box.end.y)
	var b := Vector2(box.end.x, north)
	for p in poly:
		if is_equal_approx(p.x, box.position.x):
			a.y = minf(a.y, p.y)
		if is_equal_approx(p.y, north):
			b.x = minf(b.x, p.x)
	if a.distance_to(b) > 1.0:
		_study(sm, a, b)
	if _quiet:
		_crystal(sm, north)
		_islands(sm)
	_tablets(sm)


## Sworn P2 SW-G4: offerings at the foot of the north and west walls, never at a stele's foot (its candles' ledge).
func sworn_offerings() -> bool:
	return true


func offer_free(p: Vector2) -> bool:
	return _off_stelae(p) and not (_quiet and absf(p.x - CRYSTAL_X) < CRYSTAL_SPREAD + 1.0 and p.y < 0.0)


func _off_stelae(p: Vector2) -> bool:
	var north := layout.floor.bounds().position.y
	for x in STELAE:
		if absf(p.x - x) < TABLET_CLEAR and absf(p.y - north) < 1.0:
			return false
	return true


## SW-R1: groups of carved stone tablets leaning on the north and west walls between the offerings (half a step of
## ArenaRoom.OFFER_EVERY along), standing on the sill off the floor, leaning back into the wall: TABLET (width, height,
## thickness) range by the group's place, TABLETS per group, leant TABLET_LEAN rad back; straight carved strokes (rows
## of TABLET_ROWS darker grooves, no curve, nothing legible, no amber); TABLET_CLEAR from a stele, a door or the way in.
const TABLET := Vector3(0.55, 1.15, 0.1)
const TABLETS := 3
const TABLET_LEAN := 0.13
const TABLET_ROWS := 5
const TABLET_CLEAR := 1.9
const TABLET_STONE := 0.86
const TABLET_GROOVE := 0.45


func _tablets(sm: Masonry) -> void:
	var mat := sm.carved(0.0, STONE * TABLET_STONE)
	var groove := sm.carved(0.0, STONE * TABLET_STONE * TABLET_GROOVE)
	var g := 0
	for w: Array in _wall_runs:
		var a: Vector2 = w[0]
		var b: Vector2 = w[1]
		var out: Vector2 = w[2]
		if not _tall(out) or absf(out.x) > 0.1 and absf(out.y) > 0.1:
			continue
		var openings: Array = w[4]
		var length := a.distance_to(b)
		var along := (b - a) / maxf(length, 0.001)
		var s := OFFER_FIRST + OFFER_EVERY * 0.5
		while s < length - 1.2:
			var p := a + along * s + out * (FACE_SET - TABLET.z * 0.5 - 0.06)
			var free := _off_stelae(p) and not _near_door(p, out, TABLET_CLEAR) and p.distance_to(layout.hero_spawn) > OFFER_CLEAR
			for o: Vector4 in openings:
				if s > o.x - TABLET_CLEAR and s < o.y + TABLET_CLEAR:
					free = false
			if free and g % 2 == 0:
				_tablet_group(sm, p, along, out, mat, groove, g)
			if free:
				g += 1
			s += OFFER_EVERY


func _tablet_group(sm: Masonry, at: Vector2, along: Vector2, out: Vector2, mat: Material, groove: Material, seed_: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = STY_SEED + 31 * seed_
	var yaw := atan2(out.x, out.y)
	var x := -TABLET.x * (TABLETS - 1) * 0.55
	for k in TABLETS:
		var w := TABLET.x * r.randf_range(0.75, 1.1)
		var h := TABLET.y * r.randf_range(0.55, 1.0)
		var p := at + along * x + out * r.randf_range(-0.02, 0.03)
		# the foot on the sill, the slab tipped back about its foot into the wall
		var basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, TABLET_LEAN * r.randf_range(0.7, 1.2))
		var foot := Vector3(p.x, 0.0, p.y)
		var slab := sm.box(foot + basis * Vector3(0, h * 0.5, 0), Vector3(w, h, TABLET.z), 0.0, mat, false)
		slab.basis = basis
		for row in TABLET_ROWS:
			var y := h * (0.2 + 0.65 * row / float(TABLET_ROWS - 1))
			var l := w * r.randf_range(0.35, 0.75)
			var off := r.randf_range(-0.5, 0.5) * (w - l) * 0.8
			var cut := sm.box(foot + basis * Vector3(off, y, -TABLET.z * 0.5 - 0.004), Vector3(l, 0.025, 0.01), 0.0, groove, false)
			cut.basis = basis
			if row % 2 == 1:
				var tick := sm.box(foot + basis * Vector3(off + l * 0.5, y + 0.05, -TABLET.z * 0.5 - 0.004), Vector3(0.025, 0.12, 0.01), 0.0, groove, false)
				tick.basis = basis
		x += w * 1.1


## R2: a lozenge of square rings of old gold on a dark backing, four bars from the hub to the outer ring and four
## counterweights on the middle ring's corners; nothing round (D-29). A faint cold spot from above parts it from the wall.
func _mechanism(sm: Masonry, face: float) -> void:
	var gold := StandardMaterial3D.new()
	gold.albedo_color = MECH_GOLD
	gold.metallic = MECH_METAL.x
	gold.roughness = MECH_METAL.y
	var mid := Vector3(MECH.x, MECH.y, face)
	var turn := Basis(Vector3.BACK, PI * 0.25)
	var back_side := MECH.z * MECH_BACK
	var back := sm.box(mid + Vector3(0, 0, 0.02), Vector3(back_side, back_side, 0.04), 0.0, sm.stone(0.0, STONE * MECH_BACK_STONE), false)
	back.basis = turn
	for share in MECH_RINGS:
		var side := MECH.z * share
		for k in 4:
			# the four sides of a square turned 45 degrees: each side's middle at side/2 along a diagonal
			var dir := Vector2.from_angle(PI * 0.25 + PI * 0.5 * k)
			var at := mid + Vector3(dir.x, dir.y, 0) * side * 0.5 + Vector3(0, 0, 0.04 + MECH_BAR.y * 0.5)
			var bar := sm.box(at, Vector3(side + MECH_BAR.x, MECH_BAR.x, MECH_BAR.y), 0.0, gold, false)
			bar.basis = Basis(Vector3.BACK, dir.angle() + PI * 0.5)
	var reach := MECH.z * 0.7071
	for k in 4:
		var dir := Vector2.from_angle(PI * 0.5 * k)
		var at := mid + Vector3(dir.x, dir.y, 0) * reach * 0.5 + Vector3(0, 0, 0.04 + MECH_BAR.y * 1.5)
		var bar := sm.box(at, Vector3(reach, MECH_BAR.x, MECH_BAR.y), 0.0, gold, false)
		bar.basis = Basis(Vector3.BACK, dir.angle())
		var w := mid + Vector3(dir.x, dir.y, 0) * reach * MECH_RINGS[1] + Vector3(0, 0, 0.04 + MECH_BAR.y * 2.0 + MECH_WEIGHT.z * 0.5)
		var weight := sm.box(w, MECH_WEIGHT, 0.0, gold, false)
		weight.basis = Basis(Vector3.BACK, dir.angle() + PI * 0.5)
	var hub := sm.box(mid + Vector3(0, 0, 0.04 + MECH_BAR.y * 2.0 + MECH_WEIGHT.z * 0.5), Vector3(0.5, 0.5, MECH_WEIGHT.z), 0.0, gold, false)
	hub.basis = turn
	var spot := SpotLight3D.new()
	sm.root.add_child(spot)
	spot.look_at_from_position(Vector3(MECH.x, MECH_SPOT_FROM.x, face + MECH_SPOT_FROM.y), mid)
	spot.light_color = MECH_SPOT
	spot.light_energy = MECH_SPOT_ENERGY
	spot.spot_angle = MECH_SPOT_CONE
	spot.spot_range = MECH_SPOT_FROM.x * 2.0
	spot.light_specular = 0.0
	spot.light_cull_mask = ~Arena.CROWD_LAYER


## R4: the study left on a shelf along the north-west cut (a to b on the floor's edge): crates, urns, burnt candles, a
## folded cloth; off the floor.
func _study(sm: Masonry, a: Vector2, b: Vector2) -> void:
	var out := (b - a).orthogonal().normalized()
	if layout.floor.covers((a + b) * 0.5 + out * 0.3):
		out = -out
	var line := wall_ledge(sm, a, b, out, STUDY_HEIGHT, ashlar())
	var along := (b - a).normalized()
	var yaw := atan2(-along.y, along.x)
	var r := RandomNumberGenerator.new()
	r.seed = STY_SEED
	var urn := sm.carved(0.0, CatacombHall.STY_URN_TINT)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = STUDY_CLOTH
	cloth.roughness = 0.95
	for i in STUDY.size():
		var p := line[0].lerp(line[1], (i + 0.5) / STUDY.size())
		match STUDY[i]:
			0:
				var s := STUDY_CRATE * r.randf_range(0.85, 1.0)
				sm.crate(p, Vector3(s, s * r.randf_range(0.8, 1.1), s), yaw + r.randf_range(-0.15, 0.15))
			1:
				sm.urn(p, r.randf_range(STUDY_URN.x, STUDY_URN.y), urn, r.randf() < 0.5)
			2:
				sm.candle_out(p + Vector3(along.x, 0, along.y) * r.randf_range(-0.08, 0.08), r.randf_range(0.08, 0.2), 0.05)
			3:
				sm.box(p + Vector3(0, 0.02, 0), Vector3(0.22, 0.04, 0.18), yaw, cloth, false)
				sm.box(p + Vector3(0, 0.055, 0), Vector3(0.2, 0.03, 0.1), yaw + 0.2, cloth, false)


## R5 (B): a cluster of six-sided prisms of cold ivory-blue glass at the north wall's foot, off the floor, leaning back
## into the wall, the light only along their edges (crystal_edge.gdshader); no light of its own.
func _crystal(sm: Masonry, north: float) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = STY_SEED + 5
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in CRYSTALS:
		var t := (k + 0.5) / CRYSTALS
		var h := lerpf(CRYSTAL_HEIGHT.x, CRYSTAL_HEIGHT.y, 1.0 - absf(t - 0.5) * 2.0 * r.randf_range(0.3, 0.8))
		var rad := r.randf_range(CRYSTAL_RADIUS.x, CRYSTAL_RADIUS.y)
		var foot := Vector3(CRYSTAL_X + (t - 0.5) * 2.0 * CRYSTAL_SPREAD, 0.0, north - rad - 0.04)
		var back := deg_to_rad(r.randf_range(CRYSTAL_LEAN.x, CRYSTAL_LEAN.y))
		var aside := deg_to_rad((t - 0.5) * 2.0 * CRYSTAL_LEAN.y)
		var basis := Basis(Vector3.BACK, -aside) * Basis(Vector3.RIGHT, -back) * Basis(Vector3.UP, r.randf() * PI)
		_prism(st, Transform3D(basis, foot), rad, h)
	st.generate_normals()
	var mat := ShaderMaterial.new()
	mat.shader = CRYSTAL_SHADER
	mat.set_shader_parameter(&"albedo", CRYSTAL_COLOR * CRYSTAL_ALBEDO)
	mat.set_shader_parameter(&"glow", CRYSTAL_COLOR)
	mat.set_shader_parameter(&"peak", CRYSTAL_PEAK)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	sm.root.add_child(mi)


## AT-RB1 (B): blocks of stone standing in the abyss past the south and east edges, their tops well under the floor
## (ISLANDS: x, z, top, side; each a slab of the depths' stone on a shaft), a frame of the runes' old gold sunk round the
## top as the A's tiles wear it. Off the floor, nothing stops there.
const ISLANDS: Array[Vector4] = [Vector4(18.0, -4.0, -1.4, 3.0), Vector4(21.0, 0.5, -2.4, 3.0), Vector4(18.5, 5.0, -3.2, 4.5),
	Vector4(-6.0, 15.0, -2.0, 3.0), Vector4(1.5, 16.5, -3.4, 3.0), Vector4(9.0, 14.8, -1.6, 3.0)]
const ISLAND_FOOT := -14.0
const ISLAND_SLAB := 0.5
const ISLAND_FRAME := Vector2(0.08, 0.05)
const ISLAND_INSET := 0.2


func _islands(sm: Masonry) -> void:
	var gold := StandardMaterial3D.new()
	gold.albedo_color = MECH_GOLD
	gold.metallic = MECH_METAL.x
	gold.roughness = MECH_METAL.y
	var mat := deep()
	sm.layers = 1 | ArenaKit.DEPTH_LAYER
	for i: Vector4 in ISLANDS:
		var h := i.z - ISLAND_FOOT
		sm.box(Vector3(i.x, ISLAND_FOOT + h * 0.5, i.y), Vector3(i.w * 0.7, h, i.w * 0.7), 0.0, mat, false)
		sm.box(Vector3(i.x, i.z - ISLAND_SLAB * 0.5, i.y), Vector3(i.w, ISLAND_SLAB, i.w), 0.0, mat, false)
		var half := i.w * 0.5 - ISLAND_INSET
		for k in 4:
			var dir := Vector2.from_angle(PI * 0.5 * k)
			var along := Vector2(-dir.y, dir.x)
			var size := Vector3(absf(along.x) * half * 2.0 + absf(dir.x) * ISLAND_FRAME.x, ISLAND_FRAME.y, absf(along.y) * half * 2.0 + absf(dir.y) * ISLAND_FRAME.x)
			sm.box(Vector3(i.x + dir.x * half, i.z + ISLAND_FRAME.y * 0.5, i.y + dir.y * half), size, 0.0, gold, false)
	sm.layers = 1


## One six-sided prism of `rad` from its foot up `h`, its last fifth a point (flat facets).
func _prism(st: SurfaceTool, xf: Transform3D, rad: float, h: float) -> void:
	var cap := h * 0.8
	var ring_lo: Array[Vector3] = []
	var ring_hi: Array[Vector3] = []
	for i in 6:
		var a := TAU * i / 6.0
		ring_lo.append(xf * Vector3(cos(a) * rad, -0.2, sin(a) * rad))
		ring_hi.append(xf * Vector3(cos(a) * rad, cap, sin(a) * rad))
	var tip := xf * Vector3(0, h, 0)
	var axis := xf * Vector3(0, h * 0.5, 0)
	for i in 6:
		var j := (i + 1) % 6
		_facet(st, ring_lo[i], ring_hi[i], ring_hi[j], axis)
		_facet(st, ring_lo[i], ring_hi[j], ring_lo[j], axis)
		_facet(st, ring_hi[i], tip, ring_hi[j], axis)


## A triangle turned to face away from `inside` (Godot's front faces wind clockwise).
static func _facet(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, inside: Vector3) -> void:
	if (c - a).cross(b - a).dot((a + b + c) / 3.0 - inside) < 0.0:
		var t := b
		b = c
		c = t
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)
