class_name TrialLook
extends ArenaRoom
## The look of the Provação (the trial, E5 spec docs/art/e5_spec.md section 5): a closed, low chamber of dark violet
## stone, quiet before the choice. Walls of 8 m on the sides away from the camera, the low cut wall in front; broken
## pillars engaged in the chamfered corners; a floor of small dark slabs with thin lilac veins running through them
## (trial_veins.gdshader) that stop short of the block; on the block of the layout (&"trial_block") in the middle the
## cracked stele with the Provação's seal and the lilac light in its fissure (AP-1, ART-01.4; _block), lit from above
## by one ivory spot, the room's only shadow; the way out north under its arch with cold ivory lanterns on the wall. After the choice (settle) the veins
## and the crack lose 60% of their light. The entry slab with the same crack, in the room before the trial, is
## entry_slab (the gameplay places it where the door to the trial is offered).

## Veins and crack after the choice: this share of their light (spec 5.3: 60% less), in this many seconds by default.
const SETTLED := 0.4
const SETTLE_TIME := 1.5
## The walls (spec 5.2): height, the dark violet stone.
const WALL_HEIGHT := 8.0
const STONE := Color(0.62, 0.58, 0.72)
## The pillars in the corners: how far out along the corner's diagonal from the floor's cut, radius, broken heights.
const PILLAR_OUT := 0.75
const PILLAR_R := 0.42
const PILLAR_TOPS: Array[float] = [3.4, 2.1, 1.5, 2.7]
## The floor (spec 5.2): small dark slabs.
const FLOOR := {
	&"unit": 1.6, &"stone_a": Color(0.24, 0.23, 0.27), &"stone_b": Color(0.30, 0.29, 0.33),
	&"joint_color": Color(0.06, 0.05, 0.07), &"moss_color": Color(0.24, 0.23, 0.27), &"petal_color": Color(0.24, 0.23, 0.27),
	&"missing": 0.05, &"cracked": 0.6,
}
## The air (spec 5.4).
## AP-1 (ART-04.2): sky and fog a step lighter (the far ruins fade into them; the frame's luma from 43 into 50 to 60).
const AIR := {
	&"sky": Color(0.15, 0.14, 0.18), &"fog": Color(0.2, 0.19, 0.235), &"fog_depth": Vector2(40.0, 90.0),
	&"ambient": Color(0.24, 0.22, 0.28), &"ambient_gain": 2.0, &"moon": Color(0.6, 0.58, 0.7), &"moon_energy": 0.5,
	&"moon_shadow": false,
}
const MIST := Color(0.065, 0.055, 0.085)
## The rock under the broken floor round the chamber (ArenaRoom._apron's hanging stone; the hall's teal before).
const CLIFF := {&"stone_color": Color(0.085, 0.078, 0.1), &"edge_color": Color(0.16, 0.15, 0.19),
	&"mist_color": Color(0.12, 0.11, 0.145), &"glow_color": Color(0.3, 0.24, 0.42)}
## The far ruins' mist, stone and edge behind the chamber (ArenaRoom.backdrop).
const BACKDROP_MIST := Color(0.2, 0.19, 0.235)
const BACKDROP_STONE := Color(0.08, 0.075, 0.095)
const BACKDROP_EDGE := Color(0.24, 0.22, 0.3)
## The lilac of the cracks, the veins' and the crack's brightest channel.
const LILAC := Color(0.52, 0.36, 0.78)
const VEIN_GLOW := 0.5
const CRACK_GLOW := 0.8
const VEIN_CLEAR := 1.5
## The spot over the block (spec 5.2): ivory, energy, cone, height; with shadow.
const SPOT := Color(1.0, 0.95, 0.85)
const SPOT_ENERGY := 3.0
const SPOT_CONE := 20.0
const SPOT_HEIGHT := 10.0
## A soft fill from above so the floor reads (no shadow).
const FILL := Color(0.6, 0.55, 0.75)
const FILL_ENERGY := 5.0
## AP-1 (ART-04.2): a light on the floor alone (FLOOR_LAYER, the Cripta's FLOOR_FILL): the chamber's luma from 43 into
## 50 to 60 without washing the walls (colour, energy, height, reach, fall-off, where over the floor).
const FLOOR_FILL := Color(0.78, 0.74, 0.86)
const FLOOR_FILL_ENERGY := 1.6
const FLOOR_FILL_HEIGHT := 6.0
const FLOOR_FILL_REACH := 15.0
const FLOOR_FILL_FALLOFF := 0.6
const FLOOR_FILL_AT := Vector2(-1.5, 2.0)
## The cold ivory lanterns of the way out, hung on the wall beside the arch (height, bracket).
const LANTERN_AT := 2.3
const LANTERN_BRACKET := Vector3(0.24, 0.12, 0.24)
## The stele (AP-1, ART-01.4; it was a box with a lilac X on its top and front, read as a prototype's crate): on the
## block's footprint (its collision, the layout's &"trial_block", did not change) a stepped plinth and an upright slab of
## worn stone turned to the camera, gabled, split by a crack from its shoulder to its foot (the right part leaning
## STELE_LEAN degrees off), the cracked seal of the Provação in relief on its face (the crystal diamond of trial_seal.png,
## a low pyramid of four facets) and the lilac light only in the fissure (stele_crack.gdshader; settle dims it).
## Its shape on the face (x across, y up, m): foot width and height, the shoulder's width share and height share.
const STELE := Vector2(1.12, 2.3)
const STELE_SHOULDER := Vector2(0.88, 0.8)
const STELE_THICK := 0.4
const STELE_PLINTH := Vector2(0.22, 0.1)
const STELE_TINT := Color(1.45, 1.42, 1.5)
const STELE_LEAN := 1.6
## The crack on the face: points (m from the face's foot middle), past the outline at both ends; its gap.
const STELE_CRACK: Array[Vector2] = [Vector2(0.62, 2.2), Vector2(0.3, 1.86), Vector2(0.34, 1.62), Vector2(0.06, 1.3),
	Vector2(0.12, 1.02), Vector2(-0.1, 0.7), Vector2(-0.02, 0.42), Vector2(-0.2, 0.12), Vector2(-0.24, -0.2)]
const STELE_GAP := 0.05
## The seal: its middle's height (m), half width and half height, how far it stands out, its stone a little lighter.
const SEAL := Vector4(1.25, 0.32, 0.44, 0.07)
const SEAL_TINT := Color(1.75, 1.7, 1.8)
const STELE_CRACK_SHADER := preload("res://assets/shaders/stele_crack.gdshader")
## Prism (Masonry.prism: footprint x, z, extruded along y) to the stele's face (x across, y up, z out of the face).
const FACE_AXES := Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0))
## The entry slab (spec 5.1): side, frame, the wisps over it (size, alpha, height).
const SLAB_SIDE := 2.4
const SLAB_FRAME := 0.15
const WISP := Vector2(1.6, 0.8)
const WISP_ALPHA := 0.25
const WISP_Y := 0.6
const VEIN_SHADER := preload("res://assets/shaders/trial_veins.gdshader")
const CRACK_SHADER := preload("res://assets/shaders/x_crack.gdshader")

## The stylized look (room redesign lot D, docs/art/room_redesign_lotD_spec.md 2.2): greyed lilac stone, no fire, the
## only lilac light the stele's crack and the veins; every other light diffuse (no disc on the floor).
const STYLE := {
	&"stone": Color(0.338, 0.317, 0.352), &"shadow": Color(0.923, 0.843, 0.98), &"floor_stone": Color(0.31, 0.295, 0.325),
	&"olive_share": 0.0, &"metal": true,
	&"air": {&"sky": Color(0.17, 0.15, 0.21), &"fog": Color(0.23, 0.2, 0.27), &"ambient": Color(0.64, 0.58, 0.72),
		&"ambient_gain": 2.3, &"moon": Color(0.74, 0.68, 0.86), &"moon_energy": 0.6, &"moon_shadow": false},
}
## The far ruins in the stylized look: a lilac haze, their stone and edge (style_backdrop).
const STY_BACKDROP := [Color(0.26, 0.22, 0.31), Color(0.12, 0.105, 0.14), Color(0.32, 0.27, 0.38)]
const STY_COMPAT_AMBIENT := 0.7
const STY_COMPAT_MOON := 0.6
## T1: three squares turned 45 degrees round the stele, painted on the floor (their sides, m), grooves of this width in
## the joints' value, a little worn; nothing round (the stele's cracked seal is the symbol).
const LOZENGES := Vector3(4.0, 7.0, 10.0)
const LOZENGE_GROOVE := 0.08
const LOZENGE_COLOR := Color(0.115, 0.108, 0.125)
const LOZENGE_WORN := 0.18
const LOZENGE_Y := 0.005
## T2: faded petrol banners with the lion, torn (the altar's fade): on the north wall (x) and the west wall (z), top,
## size.
const BANNER_NORTH := -3.6
const BANNER_WEST := 2.6
const BANNER_TOP := 5.6
const BANNER_SIZE := Vector2(1.2, 2.8)
## T3: cold fire bowls high on corbels at the north wall's ends (x), the corbel's top, the bowl's scale; never lit.
const COLD_BOWLS: Array[float] = [-5.4, 5.4]
const CORBEL := Vector3(0.8, 0.22, 0.62)
const CORBEL_TOP := 3.25
const COLD_BOWL_SCALE := 0.5
## T4: broken urns on shelves at the foot of the back walls (north: from, to x; west: from, to z), the shelf's height,
## the urns' height range, the room between two.
const SHELF_NORTH := Vector2(2.9, 6.1)
const SHELF_WEST := Vector2(1.2, 4.6)
const SHELF_HEIGHT := 0.95
const SHELF_URN := Vector2(0.2, 0.3)
const SHELF_STEP := 0.6
const STY_SEED := 5303

static var _cold: TombKit.Lamp

var _level := 1.0
var _veins: ShaderMaterial
var _cracks: Array[ShaderMaterial] = []
var _tween: Tween
var _spot: SpotLight3D
var _far: Array[Node] = []


func floor_look() -> Dictionary:
	return FLOOR


func floor_layers() -> int:
	return 1 | FLOOR_LAYER


func stone_tint() -> Color:
	return STONE


func air() -> Dictionary:
	return AIR


func mist() -> Color:
	return MIST


func cliff_look() -> Dictionary:
	return CLIFF


func in_wall(i: int) -> bool:
	var u := layout.exits[i].inward
	return u.y > 0.5 or u.x > 0.5


func door_lamp() -> TombKit.Lamp:
	return cold_lamp()


## The cold ivory lantern of the trial's way out (no shadow).
static func cold_lamp() -> TombKit.Lamp:
	if _cold == null:
		_cold = TombKit.Lamp.new(Color(0.9, 0.9, 0.95), Color(1.5, 1.45, 1.3), Color(0.92, 0.9, 0.86), 1.4, 4.5)
	return _cold


func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	closed_edge(a, b, out, WALL_HEIGHT, ashlar())


func piece(o: ArenaObstacle) -> void:
	if o.piece == &"trial_block":
		_block(o)
		return
	super.piece(o)


func dress() -> void:
	_corners()
	_vein_sheet()
	var block := Vector2.ZERO
	for o in layout.obstacles:
		if o.piece == &"trial_block":
			block = o.center
	_spot = moon_shaft(block, SPOT, SPOT_ENERGY, SPOT_CONE, SPOT_HEIGHT, true, true)
	var fill := key_light(FILL, FILL_ENERGY, 9.0)
	fill.shadow_enabled = false
	var floor_fill := OmniLight3D.new()
	floor_fill.position = Vector3(FLOOR_FILL_AT.x, FLOOR_FILL_HEIGHT, FLOOR_FILL_AT.y)
	floor_fill.light_color = FLOOR_FILL
	floor_fill.light_energy = FLOOR_FILL_ENERGY
	floor_fill.omni_range = FLOOR_FILL_REACH
	floor_fill.omni_attenuation = FLOOR_FILL_FALLOFF
	floor_fill.light_cull_mask = FLOOR_LAYER
	add_child(floor_fill)
	_lanterns()
	var from := get_child_count()
	backdrop(BACKDROP_MIST, BACKDROP_STONE, BACKDROP_EDGE)
	_far = added_since(from)
	_dress_styled(block)


## The light of the veins and the cracks (1 before the choice, SETTLED after it).
func vein_level() -> float:
	return _level


## After the choice (spec 5.3): the veins and the cracks lose their light in `seconds` (0: at once).
func settle(seconds := SETTLE_TIME) -> void:
	if _tween != null:
		_tween.kill()
	if seconds <= 0.0 or not is_inside_tree():
		_set_level(SETTLED)
		return
	_tween = create_tween()
	_tween.tween_method(_set_level, _level, SETTLED, seconds)


func _set_level(v: float) -> void:
	_level = v
	if _veins != null:
		_veins.set_shader_parameter(&"level", v)
	for c in _cracks:
		c.set_shader_parameter(&"level", v)


## The lab's states: "after" the choice made.
func demo(state: String) -> void:
	_set_level(SETTLED if state == "after" else 1.0)


## A broken pillar engaged in each chamfered corner (spec 5.2), outside the floor.
func _corners() -> void:
	var poly := layout.floor.polys[0]
	var mid := layout.floor.bounds().get_center()
	var k := 0
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		var d := b - a
		if absf(d.x) < 0.05 or absf(d.y) < 0.05:
			continue
		var c := (a + b) * 0.5
		var out := (c - mid).normalized()
		var at := c + Vector2(signf(out.x), signf(out.y)).normalized() * (PILLAR_OUT + PILLAR_R)
		tomb.column(at, PILLAR_R, PILLAR_TOPS[k % PILLAR_TOPS.size()], ashlar(), true)
		k += 1


## The veins: a sheet of the floor's own triangles 1 cm over it.
func _vein_sheet() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for poly in layout.floor.polys:
		var tris := Geometry2D.triangulate_polygon(poly)
		for t in tris:
			st.add_vertex(Vector3(poly[t].x, 0.01, poly[t].y))
	_veins = ShaderMaterial.new()
	_veins.shader = VEIN_SHADER
	_veins.set_shader_parameter(&"color", LILAC)
	_veins.set_shader_parameter(&"glow", VEIN_GLOW)
	_veins.set_shader_parameter(&"clear", VEIN_CLEAR)
	for o in layout.obstacles:
		if o.piece == &"trial_block":
			_veins.set_shader_parameter(&"block_center", o.center)
			_veins.set_shader_parameter(&"block_half", o.half)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _veins
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


## The stele on the block's footprint (STELE*; the collision is the block's, unchanged).
func _block(o: ArenaObstacle) -> void:
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var mat := ashlar()
	var step := STELE_PLINTH.y * 0.6
	m.block(foot, Vector3(o.half.x * 2.0, STELE_PLINTH.x, o.half.y * 2.0), -o.yaw, mat)
	m.block(foot + Vector3(0, STELE_PLINTH.x, 0), Vector3(o.half.x * 2.0 - step * 2.0, STELE_PLINTH.y, o.half.y * 2.0 - step * 2.0), -o.yaw, mat)
	var base := foot + Vector3(0, STELE_PLINTH.x + STELE_PLINTH.y, 0)
	var face := Transform3D(Basis(Vector3.UP, deg_to_rad(Feel.live().cam_yaw)), base)
	var w := STELE.x * 0.5
	var ws := w * STELE_SHOULDER.x
	var hs := STELE.y * STELE_SHOULDER.y
	var outline := PackedVector2Array([Vector2(-w, 0), Vector2(w, 0), Vector2(ws, hs), Vector2(ws * 0.45, STELE.y - 0.1),
		Vector2(0, STELE.y), Vector2(-ws * 0.45, STELE.y - 0.1), Vector2(-ws, hs)])
	var path := PackedVector2Array(STELE_CRACK)
	var band: PackedVector2Array = Geometry2D.offset_polyline(path, STELE_GAP * 0.5)[0]
	var glow_band: PackedVector2Array = Geometry2D.offset_polyline(path, STELE_GAP * 0.5 + STELE_LEAN * 0.03)[0]
	var stone := m.stone(base.y, STONE * STELE_TINT)
	var seal := m.stone(base.y, STONE * SEAL_TINT)
	var lean := deg_to_rad(STELE_LEAN)
	var tilt := Transform3D(Basis(Vector3.BACK, -lean), Vector3(w, 0, 0) - Basis(Vector3.BACK, -lean) * Vector3(w, 0, 0))
	var half_t := STELE_THICK * 0.5
	# the slab in two parts either side of the crack, the right one leaning off
	for piece in Geometry2D.clip_polygons(outline, band):
		_face_slab(piece, -half_t, half_t, stone, face * (tilt if _right_of(piece, path) else Transform3D.IDENTITY))
	# the seal in two tiers, cut by the same crack
	var tiers: Array[PackedVector2Array] = []
	for k in 2:
		var s := 1.0 - 0.34 * k
		var mid := Vector2(0, SEAL.x)
		tiers.append(PackedVector2Array([mid + Vector2(0, SEAL.z * s), mid + Vector2(SEAL.y * s, 0), mid - Vector2(0, SEAL.z * s), mid - Vector2(SEAL.y * s, 0)]))
		for piece in Geometry2D.clip_polygons(tiers[k], band):
			_face_slab(piece, half_t - 0.01, half_t + SEAL.w * (k + 1) * 0.5, seal, face * (tilt if _right_of(piece, path) else Transform3D.IDENTITY))
	# the lilac light, only inside the fissure (behind the faces, through the gap, in each tier of the seal)
	var light := ShaderMaterial.new()
	light.shader = STELE_CRACK_SHADER
	light.set_shader_parameter(&"color", LILAC)
	light.set_shader_parameter(&"glow", CRACK_GLOW)
	light.set_shader_parameter(&"foot_y", base.y)
	light.set_shader_parameter(&"height", STELE.y)
	_cracks.append(light)
	for g in Geometry2D.intersect_polygons(outline, glow_band):
		_face_slab(g, -half_t + 0.02, half_t - 0.004, light, face).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for k in 2:
		for g in Geometry2D.intersect_polygons(tiers[k], glow_band):
			_face_slab(g, half_t - 0.012, half_t + SEAL.w * (k + 1) * 0.5 - 0.004, light, face).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## A slab of the stele: `outline` on its face (x across, y up) from z0 to z1 out of the face, placed by `xf`.
func _face_slab(outline: PackedVector2Array, z0: float, z1: float, mat: Material, xf: Transform3D) -> MeshInstance3D:
	var pts := PackedVector2Array()
	for p in outline:
		pts.append(Vector2(p.x, -p.y))
	var mi := m.prism(pts, z0, z1, mat)
	mi.transform = xf * Transform3D(FACE_AXES, Vector3.ZERO)
	return mi


## True when the piece's middle lies right of the crack at its height.
static func _right_of(piece: PackedVector2Array, path: PackedVector2Array) -> bool:
	var c := Vector2.ZERO
	for p in piece:
		c += p
	c /= piece.size()
	for i in path.size() - 1:
		var a := path[i]
		var b := path[i + 1]
		if (c.y - a.y) * (c.y - b.y) <= 0.0 and absf(a.y - b.y) > 0.001:
			return c.x > lerpf(a.x, b.x, (c.y - a.y) / (b.y - a.y))
	return c.x > 0.0


## A quad of the cross crack under `parent`, its face along basis.z, `size` across.
static func crack(parent: Node3D, at: Vector3, basis: Basis, size: Vector2) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = CRACK_SHADER
	mat.set_shader_parameter(&"color", LILAC)
	mat.set_shader_parameter(&"glow", CRACK_GLOW)
	var q := QuadMesh.new()
	q.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = q
	mi.material_override = mat
	mi.transform = Transform3D(basis, at)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mat


## The cold ivory lanterns hung on the wall each side of the way out's arch.
func _lanterns() -> void:
	for i in layout.exits.size():
		if i >= exits_used or not in_wall(i):
			continue
		var e := layout.exits[i]
		var u := e.inward
		var side := Vector2(-u.y, u.x)
		var w := absf(e.mouth.size.dot(side))
		var edge_mid := e.mouth.get_center() + u * absf(e.mouth.size.dot(u)) * 0.5
		for sd: float in [-1.0, 1.0]:
			var p := edge_mid + side * sd * (w * 0.5 + JAMB + 0.6) - u * (FACE_SET + LANTERN_BRACKET.z * 0.5)
			tomb.lantern(Vector3(p.x, LANTERN_AT, p.y), atan2(u.x, u.y), ashlar(), cold_lamp(), ~Arena.CROWD_LAYER, LANTERN_BRACKET)


## The entry slab of the trial (spec 5.1), laid in the floor of the room before it at `at` under `parent`: a dark slab
## in a frame of stone, the cross crack of lilac light on it pulsing, wisps of violet mist over it. Flush with the floor
## (nothing to trip on); returns the node (free it to take the slab away).
static func entry_slab(parent: Node3D, at: Vector2, yaw := 0.0) -> Node3D:
	var root := Node3D.new()
	root.name = "TrialSlab"
	parent.add_child(root)
	var kit := ArenaKit.new(root, hash(at))
	var mm := kit.masonry
	var stone := mm.stone(0.0, STONE * 0.8)
	var foot := Vector3(at.x, -0.2, at.y)
	mm.box(foot + Vector3(0, 0.1, 0), Vector3(SLAB_SIDE, 0.2, SLAB_SIDE), yaw, stone, false)
	var inner := SLAB_SIDE - SLAB_FRAME * 2.0
	mm.box(foot + Vector3(0, 0.105, 0), Vector3(inner, 0.2, inner), yaw, mm.stone(0.0, STONE * 0.55), false)
	mm.merge()
	crack(root, Vector3(at.x, 0.012, at.y), Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -PI * 0.5), Vector2(inner, inner))
	kit.mist_bank(Vector3(at.x, WISP_Y, at.y), WISP, LILAC * 0.6, WISP_ALPHA, 0.5, 0.0)
	return root


# ---------- the stylized look (room redesign lot D, docs/art/room_redesign_lotD_spec.md section 2) ----------

func style() -> Dictionary:
	var st := STYLE.duplicate(true)
	if compat():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * STY_COMPAT_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * STY_COMPAT_MOON
	diffuse_lights()
	style_backdrop(_far, STY_BACKDROP[0], STY_BACKDROP[1], STY_BACKDROP[2])
	return st


## The pieces only the stylized look shows (spec 2.3), on kit.styled(), never the room's random numbers.
func _dress_styled(block: Vector2) -> void:
	var sm := kit.styled()
	var box := layout.floor.bounds()
	var north := box.position.y
	var west := box.position.x
	_lozenges(sm, block, box)
	var nodes: Array[Node] = []
	var face_n := north - FACE_SET + 0.06
	var face_w := west - FACE_SET + 0.06
	nodes.append(kit.styled_build(func() -> void:
		kit.banner(Vector3(BANNER_NORTH, BANNER_TOP, face_n), 0.0, BANNER_SIZE, ArenaKit.FACADE_LAYER, ArenaKit.Emblem.LION)))
	nodes.append(kit.styled_build(func() -> void:
		kit.banner(Vector3(face_w, BANNER_TOP, BANNER_WEST), PI * 0.5, BANNER_SIZE, ArenaKit.FACADE_LAYER, ArenaKit.Emblem.LION)))
	for n in nodes:
		fade_banners(n.get_children(), AltarLook.BANNER_FADE)
	var face := north - FACE_SET
	for x in COLD_BOWLS:
		sm.box(Vector3(x, CORBEL_TOP - CORBEL.y * 0.5, face + CORBEL.z * 0.5), CORBEL, 0.0, ashlar(), false)
		var at := Vector3(x, CORBEL_TOP, face + CORBEL.z * 0.5)
		kit.styled_build(func() -> void: kit.brazier(Vector2(at.x, at.z), at.y, false, 0.0, false), at, COLD_BOWL_SCALE)
	var r := RandomNumberGenerator.new()
	r.seed = STY_SEED
	var urn := sm.carved(0.0, STONE)
	var shelves: Array = [
		wall_ledge(sm, Vector2(SHELF_NORTH.x, north), Vector2(SHELF_NORTH.y, north), Vector2(0, -1), SHELF_HEIGHT, ashlar()),
		wall_ledge(sm, Vector2(west, SHELF_WEST.x), Vector2(west, SHELF_WEST.y), Vector2(-1, 0), SHELF_HEIGHT, ashlar())]
	for line: Array[Vector3] in shelves:
		var n := int(line[0].distance_to(line[1]) / SHELF_STEP)
		for i in n:
			var p := line[0].lerp(line[1], (i + 0.5) / n)
			if r.randf() < 0.3:
				continue
			sm.urn(p, r.randf_range(SHELF_URN.x, SHELF_URN.y), urn, false)
			# the broken lip: a shard fallen beside it
			var side := (line[1] - line[0]).normalized() * r.randf_range(0.12, 0.18) * (1.0 if r.randf() < 0.5 else -1.0)
			var shard := sm.box(p + side + Vector3(0, 0.015, 0), Vector3(0.07, 0.03, 0.05), r.randf() * TAU, urn, false)
			shard.rotate_object_local(Vector3.BACK, r.randf_range(-0.4, 0.4))


## T1: the lozenges round the stele (floor_decal kind 4), one card over the floor's box.
func _lozenges(sm: Masonry, at: Vector2, box: Rect2) -> void:
	var mi := MeshInstance3D.new()
	var q := PlaneMesh.new()
	# centred on the stele, as large as reaches the floor's far sides
	var half := Vector2(maxf(at.x - box.position.x, box.end.x - at.x), maxf(at.y - box.position.y, box.end.y - at.y))
	q.size = half * 2.0
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = CatacombHall.DECAL_SHADER
	mat.set_shader_parameter(&"kind", 4)
	mat.set_shader_parameter(&"rug_size", q.size)
	mat.set_shader_parameter(&"lozenges", LOZENGES)
	mat.set_shader_parameter(&"groove_width", LOZENGE_GROOVE)
	mat.set_shader_parameter(&"groove_color", LOZENGE_COLOR)
	mat.set_shader_parameter(&"groove_worn", LOZENGE_WORN)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(at.x, LOZENGE_Y, at.y)
	sm.root.add_child(mi)
