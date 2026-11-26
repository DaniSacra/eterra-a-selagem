class_name HubFacades
extends RefCounted
## The Santuario da Vigilia's faces (hub refine round 1, 2026-11-26, environment-artist): what makes each building read as
## its station in the approved art (docs/art/ref/hub01_2026-11-25/eterra_hub/01-arte-aprovada.jpg): the great arch of the
## Aposento dos Herois with its red carpet and wine banners, the Biblioteca's and the Capela dos Dons' stained glass, the
## Alquimista's glasshouse, the Portao's stone lions and the violet view in its opening, warm lanterns at the doors.
## Display only, in HubLook's frame (u to the right of the screen, v up it; the south face of a building is at its v0):
## nothing here collides, and what stands on the floor stays at an edge or against a wall.
##   HubFacades.new(look, scenery).build()      # buildings' faces, after the roofs and windows
##   facades.gate()                             # the Portao's lions and view, after its frame

# ---------- palette ----------
const VINOUS := Color(0.5, 0.1, 0.16)
const BANNER_GOLD := Color(0.74, 0.56, 0.22)
const OLD_GOLD := Color(0.72, 0.55, 0.24)
const GLASS_FRAME := Color(0.78, 0.66, 0.4)
const AMBER := Color(1.0, 0.72, 0.38)
## Round 4: the stained glass is a lattice of small lozenges in four muted jewel tones (amber, wine, deep blue, moss-green)
## in dark lead (hub_stained.gdshader), not wedges of pure colour.
const STAINED: Array[Color] = [Color(0.78, 0.5, 0.16), Color(0.46, 0.1, 0.17), Color(0.1, 0.18, 0.42), Color(0.2, 0.33, 0.18)]
const STAINED_SHADER := preload("res://assets/shaders/hub_stained.gdshader")
const CARPET := Color(0.46, 0.08, 0.12)
const VISTA_SHADER := preload("res://assets/shaders/hub_vista.gdshader")

# ---------- the features (centre u, span, spring, ring; the wall's south face is the building's v0) ----------
const HERO_ARCH := Vector4(-1.0, 3.2, 1.8, 0.45)
const HERO_SILL := 0.15
const HERO_BANNERS: Array[float] = [-4.0, 4.7]
const LIBRARY_GLASS := Vector4(23.2, 1.8, 1.8, 0.35)
const DONS_GLASS := Vector4(19.7, 1.4, 1.7, 0.3)
const GLASS_SILL := 0.7
const GLASS_DEEP := 0.3
const BANNER := Vector2(0.95, 2.6)  # width, length
const BANNER_TOP := 4.1
## The red carpet from the Aposento's arch toward the south (u of its middle, width, v from, v to): it runs under the
## standards and stops short of the basin's lip (v 17).
const CARPET_RUN := Vector4(-1.0, 1.9, 20.4, 17.5)
## The Alquimista's glasshouse against its south wall (u0, u1, v0, v1), the eaves' height and the ridge's.
const GLASSHOUSE := Vector4(-27.6, -22.6, 0.6, 3.0)
const GLASSHOUSE_EAVES := 2.4
const GLASSHOUSE_RIDGE := 3.4
## Round 5: the glasshouse glass is dark green-amber (the plants and the warm light show through), the frame dark iron, the
## roof a gable with rafters; a warm glow stands behind the plants (GLASSHOUSE_GLOW: energy, light energy).
const GLASS_PANE := Color(0.2, 0.3, 0.2)
const GLASS_ALPHA := 0.34
const GLASS_EMIT := Color(1.0, 0.7, 0.3)
const GLASS_EMIT_ENERGY := 0.12
const GLASSHOUSE_IRON := Color(0.11, 0.11, 0.1)
const GLASSHOUSE_GLOW := Vector2(0.8, 1.2)
const FRAME_THICK := 0.1
const POST_EVERY := 1.25
## The lions at the Portao's feet (round 4, on its terrace in front of the facade): how far each stands from the arch's middle
## (u), how far south of its face (v), their size. The banners hang on the wall each side of the ring (their width and length,
## the height of the rod), the medallion over the keystone (its height and side).
const LION_OFFSET := Vector3(1.5, 1.5, 0.85)
const GATE_BANNER := Vector3(0.5, 2.3, 4.4)
const GATE_MEDAL := Vector2(4.95, 0.62)
const GATE_STEP := Vector3(1.0, 0.16, 0.5)
const PLINTH := Vector3(1.35, 0.7, 1.35)
## Door lanterns: how far each stands from the door's edge, its height, its size.
const DOOR_LAMP := Vector3(0.55, 2.0, 0.26)
const LIGHT_MASK_ALL := -1

var look: HubLook
var scenery: HubScenery
var _glass_mat: StandardMaterial3D
var _pane_mat: StandardMaterial3D
var _stained_mat: ShaderMaterial
var _lantern_xf: Array[Transform3D] = []
var _rng := RandomNumberGenerator.new()


func _init(owner_look: HubLook, owner_scenery: HubScenery) -> void:
	look = owner_look
	scenery = owner_scenery
	_rng.seed = 8821


## Rects (local u, v) of what the faces take of the south walls, for the windows and plants to keep clear of.
static func reserved() -> Array[Rect2]:
	var out: Array[Rect2] = []
	var h := HERO_ARCH
	out.append(Rect2(h.x - h.y * 0.5 - h.w - 0.4, 21.3, h.y + h.w * 2.0 + 0.8, 1.4))
	for u in HERO_BANNERS:
		out.append(Rect2(u - BANNER.x * 0.5 - 0.3, 21.3, BANNER.x + 0.6, 1.4))
	var g := LIBRARY_GLASS
	out.append(Rect2(g.x - g.y * 0.5 - g.w - 0.3, 21.3, g.y + g.w * 2.0 + 0.6, 1.5))
	var d := DONS_GLASS
	out.append(Rect2(d.x - d.y * 0.5 - d.w - 0.3, -9.4, d.y + d.w * 2.0 + 0.6, 1.5))
	out.append(Rect2(GLASSHOUSE.x - 0.3, GLASSHOUSE.z - 0.3, GLASSHOUSE.y - GLASSHOUSE.x + 0.6, GLASSHOUSE.w - GLASSHOUSE.z + 0.6))
	return out


func _at(u: float, y: float, v: float) -> Vector3:
	return HubLook.at(u, y, v)


func build() -> void:
	_hero_hall()
	_library()
	_dons()
	_glasshouse()
	_door_lanterns()
	_lantern_instances()


# ---------- shapes and materials ----------

## A pointed (ogive) panel in the x, y plane facing +z (the camera): `span` wide, straight up `spring`, then two arcs of
## radius span * `radius` meeting at the apex (the voussoir arches' own curve). UV.y is 0 at the apex. `colors`: the panel
## in wedges of these colours (vertex colours, stained glass); empty: white.
static func ogive_mesh(span: float, spring: float, radius: float, colors: Array[Color] = [], steps := 8) -> ArrayMesh:
	var r := span * radius
	var cx := r - span * 0.5
	var a_apex := acos(clampf(-cx / r, -1.0, 1.0))
	var apex := spring + r * sin(a_apex)
	var ring: Array[Vector2] = [Vector2(-span * 0.5, 0.0), Vector2(span * 0.5, 0.0)]
	for i in steps + 1:
		var a := lerpf(PI, a_apex, float(i) / steps)
		ring.append(Vector2(-(cx + r * cos(a)), spring + r * sin(a)))
	for i in range(steps - 1, -1, -1):
		var a := lerpf(PI, a_apex, float(i) / steps)
		ring.append(Vector2(cx + r * cos(a), spring + r * sin(a)))
	var c0 := Vector2(0.0, apex * 0.55)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.BACK)
	for i in ring.size():
		var p := ring[i]
		var q := ring[(i + 1) % ring.size()]
		if not colors.is_empty():
			st.set_color(colors[i % colors.size()])
		# Godot's front face is clockwise seen from the front: c0, q, p (the other order is culled from the +z side)
		for pt: Vector2 in [c0, q, p]:
			st.set_uv(Vector2(pt.x / span + 0.5, 1.0 - pt.y / apex))
			st.add_vertex(Vector3(pt.x, pt.y, 0.0))
	return st.commit()


## The wall light's glass: warm amber, lit from within (the windows' own).
func _warm_glass() -> StandardMaterial3D:
	if _glass_mat == null:
		_glass_mat = StandardMaterial3D.new()
		_glass_mat.albedo_color = AMBER * 0.5
		_glass_mat.emission_enabled = true
		_glass_mat.emission = AMBER
		_glass_mat.emission_energy_multiplier = 1.3
		_glass_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _glass_mat


## Stained glass: leaded lozenges of jewel tones, lit from behind (hub_stained.gdshader).
func _stained_glass() -> ShaderMaterial:
	if _stained_mat == null:
		_stained_mat = ShaderMaterial.new()
		_stained_mat.shader = STAINED_SHADER
		for i in STAINED.size():
			_stained_mat.set_shader_parameter(StringName("jewel_" + "abcd"[i]), STAINED[i])
	return _stained_mat


## A panel of glass standing on the wall's face `v` (a little in front of it), its foot at y0.
func _panel(u: float, y0: float, v: float, span: float, spring: float, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = ogive_mesh(span, spring, 0.8)
	mi.material_override = mat
	mi.position = _at(u, y0, v - 0.04)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)


## A window of stone with the glass in it: the frame's jambs and sill, the voussoir ring, the glass (stained or amber),
## the leading (a mullion and a transom).
func _arched_window(spec: Vector4, v: float, stained: bool, sill := GLASS_SILL) -> void:
	var stone: Material = look.stone()
	var u := spec.x
	var span := spec.y
	var spring := spec.z
	var ring := spec.w
	var foot := _at(u, sill, v)
	_panel(u, sill, v, span, spring, _stained_glass() if stained else _warm_glass())
	for s: float in [-1.0, 1.0]:
		look.fm.block(_at(u + s * (span * 0.5 + ring * 0.5), sill, v - 0.04), Vector3(ring, spring, GLASS_DEEP), 0.0, stone, false)
	look.fm.block(_at(u, sill - 0.14, v - 0.08), Vector3(span + ring * 2.0 + 0.3, 0.14, GLASS_DEEP + 0.14), 0.0, stone, false)
	look.fm.voussoir_arch(foot + Vector3(0, 0, 0.0), Vector2(0, 1), span, spring, ring, GLASS_DEEP, stone, 0.8)
	var dark := look._plain(HubScenery.IRON, 0.7)
	var apex := spring + span * 0.8 * 0.6
	look._bar(_at(u, sill + apex * 0.5, v - 0.08), Vector3(0.05, apex, 0.04), dark)
	look._bar(_at(u, sill + spring * 0.55, v - 0.08), Vector3(span, 0.05, 0.04), dark)
	if stained:
		look._bar(_at(u, sill + spring * 0.2, v - 0.08), Vector3(span, 0.05, 0.04), dark)


## A banner of wine cloth with old gold trim and the lion, hanging from a rod over (u, v) on a face looking along `yaw`
## (0: south, toward the camera; -PI/2: west): `top` the rod's height, w x length. The art's standards: vinous, never the
## room's petrol.
func banner(u: float, top: float, v: float, w: float, length: float, yaw := 0.0) -> void:
	var cloth := look._plain(VINOUS, 0.9)
	var gold := look._plain(BANNER_GOLD, 0.5)
	var node := Node3D.new()
	node.position = _at(u, 0.0, v)
	node.basis = Basis(Vector3.UP, yaw)
	look.frame.add_child(node)
	var body := length - w * 0.5
	_box(node, Vector3(0, top - body * 0.5, 0.07), Vector3(w, body, 0.04), cloth)
	_box(node, Vector3(0, top - body, 0.07), Vector3(w * 0.7071, w * 0.7071, 0.04), cloth, Basis(Vector3.BACK, PI * 0.25))
	for s: float in [-1.0, 1.0]:
		_box(node, Vector3(s * (w * 0.5 - 0.03), top - body * 0.5, 0.095), Vector3(0.06, body, 0.03), gold)
		_box(node, Vector3(s * w * 0.25, top - body - w * 0.25, 0.095), Vector3(w * 0.7071, 0.06, 0.03), gold, Basis(Vector3.BACK, s * PI * 0.25))
	_box(node, Vector3(0, top + 0.04, 0.1), Vector3(w + 0.3, 0.08, 0.08), gold)
	look._lion(Vector3(0, top - body * 0.5 + 0.1, 0.13), Basis(), w * 0.78, BANNER_GOLD, node)


func _box(parent: Node3D, p: Vector3, size: Vector3, mat: Material, basis := Basis()) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.transform = Transform3D(basis, p)
	parent.add_child(mi)


## A small warm light (no shadow, never on the crowd) at a point of the frame; the faces' few point lights.
func light(p: Vector3, color: Color, energy: float, reach: float) -> void:
	var l := OmniLight3D.new()
	l.position = look.world(p.x, p.y, p.z)
	l.light_color = color
	l.light_energy = energy
	l.omni_range = reach
	l.shadow_enabled = false
	l.light_cull_mask = ~Arena.CROWD_LAYER
	l.set_meta(ArenaKit.NOT_FIRE, true)
	look.add_child(l)


# ---------- the Aposento dos Herois ----------

## The great arch of the chapel on the south face (a wide ogive of amber glass with leading), the two wine banners, the red
## carpet with its gold borders running south, a lit glow on the carpet's head.
func _hero_hall() -> void:
	var r := _rect(&"heroes")
	var v := r.y
	var spec := HERO_ARCH
	_arched_window(spec, v, false, HERO_SILL)
	for u in HERO_BANNERS:
		banner(u, BANNER_TOP, v, BANNER.x, BANNER.y)
	var c := CARPET_RUN
	var mid := (c.z + c.w) * 0.5
	var run := absf(c.z - c.w)
	var cloth := look._plain(CARPET, 1.0)
	var gold := look._plain(BANNER_GOLD, 0.6)
	look._bar(_at(c.x, 0.03, mid), Vector3(c.y, 0.02, run), cloth)
	for s: float in [-1.0, 1.0]:
		look._bar(_at(c.x + s * (c.y * 0.5 - 0.07), 0.035, mid), Vector3(0.08, 0.02, run), gold)
	look._bar(_at(c.x, 0.035, c.w), Vector3(c.y, 0.02, 0.08), gold)
	light(Vector3(spec.x, 3.0, v - 1.6), AMBER, 2.4, 7.0)


# ---------- the Biblioteca de Ahk and the Capela dos Dons ----------

func _library() -> void:
	var r := _rect(&"book")
	_arched_window(LIBRARY_GLASS, r.y, true)
	light(Vector3(LIBRARY_GLASS.x, 2.8, r.y - 1.4), Color(1.0, 0.7, 0.55), 2.0, 6.0)


func _dons() -> void:
	var r := _rect(&"tree")
	_arched_window(DONS_GLASS, r.y, true)
	light(Vector3(DONS_GLASS.x, 2.6, r.y - 1.4), Color(1.0, 0.78, 0.45), 1.8, 5.5)
	# a gold finial on the roof's ridge
	var gold := look._plain(OLD_GOLD, 0.4)
	var h := 4.5 + 0.12 + 1.2
	var c := Vector2(r.x + r.z, r.y + r.w) * 0.5
	look._bar(_at(c.x, h + 0.4, c.y), Vector3(0.1, 0.8, 0.1), gold)
	look._bar(_at(c.x, h + 0.85, c.y), Vector3(0.22, 0.22, 0.22), gold, Basis(Vector3.UP, PI * 0.25))


# ---------- the Alquimista's glasshouse ----------

## A glass house against the Alquimista's south wall: a low stone plinth, gold-white frame, panes of pale glass, a hip roof
## of glass, plants in flower inside and a warm light (the art's estufa).
func _glasshouse() -> void:
	var g := GLASSHOUSE
	var u0 := g.x
	var u1 := g.y
	var v0 := g.z
	var v1 := g.w
	var cu := (u0 + u1) * 0.5
	var cv := (v0 + v1) * 0.5
	var frame := look._plain(GLASSHOUSE_IRON, 0.5)
	var pane := _glass_pane()
	look.fm.block(_at(cu, 0.0, cv), Vector3(u1 - u0, 0.4, v1 - v0), 0.0, look.stone(), false)
	var h := GLASSHOUSE_EAVES
	# the front and the two sides
	_quad(_at(cu, 0.4, v0), Vector2(u1 - u0, h - 0.4), 0.0, pane)
	for s: float in [-1.0, 1.0]:
		_quad(_at(cu + s * (u1 - u0) * 0.5, 0.4, cv), Vector2(v1 - v0, h - 0.4), -s * PI * 0.5, pane)
	# the posts and the rails
	var n := maxi(2, roundi((u1 - u0) / POST_EVERY))
	for i in n + 1:
		var u := lerpf(u0, u1, float(i) / n)
		look._bar(_at(u, 0.4 + (h - 0.4) * 0.5, v0), Vector3(FRAME_THICK, h - 0.4, FRAME_THICK), frame)
	for s: float in [-1.0, 1.0]:
		for k in 2:
			look._bar(_at(cu + s * (u1 - u0) * 0.5, 0.4 + (h - 0.4) * 0.5, lerpf(v0, v1, float(k))), Vector3(FRAME_THICK, h - 0.4, FRAME_THICK), frame)
	look._bar(_at(cu, h, v0), Vector3(u1 - u0 + 0.1, 0.08, 0.08), frame)
	look._bar(_at(cu, 1.2, v0), Vector3(u1 - u0, 0.05, 0.05), frame)
	# the hip roof: a ridge along u, four panes
	var ridge := GLASSHOUSE_RIDGE
	var inset := 0.0  # a gable: the ridge spans the whole length
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var e: Array[Vector3] = [_at(u0, h, v0), _at(u1, h, v0), _at(u1, h, v1), _at(u0, h, v1)]
	var t: Array[Vector3] = [_at(u0 + inset, ridge, cv), _at(u1 - inset, ridge, cv)]
	for tri: Array in [[e[0], e[1], t[1]], [e[0], t[1], t[0]], [e[2], e[3], t[0]], [e[2], t[0], t[1]], [e[3], e[0], t[0]], [e[1], e[2], t[1]]]:
		for p: Vector3 in tri:
			st.add_vertex(p)
	st.generate_normals()
	var roof := MeshInstance3D.new()
	roof.name = "GlasshouseRoof"
	roof.mesh = st.commit()
	roof.material_override = pane
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(roof)
	for s: float in [-1.0, 1.0]:
		look._bar((e[0] + t[0]) * 0.5 if s < 0.0 else (e[1] + t[1]) * 0.5, Vector3(0.06, 0.06, 0.06), frame)
	look._bar(_at(cu, ridge, cv), Vector3(u1 - u0 - inset * 2.0, 0.12, 0.12), frame)
	# rafters down each slope at every post, and a warm glow behind the plants
	for i in n + 1:
		var u := lerpf(u0, u1, float(i) / n)
		for ev: float in [v0, v1]:
			var a := _at(u, h, ev)
			var b := _at(u, ridge, cv)
			look._bar((a + b) * 0.5, Vector3(FRAME_THICK * 0.7, FRAME_THICK * 0.7, a.distance_to(b)), frame, Basis.looking_at(b - a, Vector3.UP))
	_quad(_at(cu, 0.4, v1 - 0.05), Vector2(u1 - u0, h - 0.4), 0.0, HubLook.lit_opening(AMBER, GLASSHOUSE_GLOW.x, 0.15))
	# the plants inside, in flower
	for k in 6:
		var u := lerpf(u0 + 0.6, u1 - 0.6, (k + _rng.randf_range(0.1, 0.9)) / 6.0)
		var v := _rng.randf_range(v0 + 0.5, v1 - 0.4)
		scenery.plant(k % 2, Vector3(u, 0.4, v), _rng.randf_range(0.9, 1.5))
	light(Vector3(cu, 1.6, v0 + 0.5), Color(1.0, 0.8, 0.5), GLASSHOUSE_GLOW.y, 5.0)


func _glass_pane() -> StandardMaterial3D:
	if _pane_mat == null:
		_pane_mat = StandardMaterial3D.new()
		_pane_mat.albedo_color = Color(GLASS_PANE.r, GLASS_PANE.g, GLASS_PANE.b, GLASS_ALPHA)
		_pane_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_pane_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_pane_mat.roughness = 0.1
		_pane_mat.emission_enabled = true
		_pane_mat.emission = GLASS_EMIT
		_pane_mat.emission_energy_multiplier = GLASS_EMIT_ENERGY
	return _pane_mat


## A flat quad at p facing +z turned by yaw (a pane).
func _quad(p: Vector3, size: Vector2, yaw: float, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	mi.material_override = mat
	mi.position = p + Vector3(0, size.y * 0.5, 0)
	mi.basis = Basis(Vector3.UP, yaw)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)


# ---------- lanterns at the doors ----------

## A warm lantern each side of every door of a station that is not a future room's (emissive; one MultiMesh for all).
func _door_lanterns() -> void:
	var cap := look.stone()
	for id: StringName in HubPlan.DOORS:
		if id == HubPlan.FUTURE_A or id == HubPlan.FUTURE_B:
			continue
		if id == HubPlan.VINE:
			continue
		var d: Vector4 = HubPlan.DOORS[id]
		var across_u := d.z >= d.w
		var long_half := maxf(d.z, d.w)
		var b := _rect(id)
		# the wall the door is in: a south face, or the west or east one (by which side of the building the door is on)
		var wall_u := d.x + d.z - DOOR_LAMP.z * 0.5 if (b.x + b.z) * 0.5 > d.x else d.x - d.z + DOOR_LAMP.z * 0.5
		for s: float in [-1.0, 1.0]:
			var p := Vector2(d.x + s * (long_half + DOOR_LAMP.x), d.y + d.w - DOOR_LAMP.z * 0.5) if across_u else Vector2(wall_u, d.y + s * (long_half + DOOR_LAMP.x))
			_lantern_xf.append(Transform3D(Basis.from_scale(Vector3.ONE * DOOR_LAMP.z), _at(p.x, DOOR_LAMP.y, p.y)))
			look.fm.block(_at(p.x, DOOR_LAMP.y + DOOR_LAMP.z * 0.5, p.y), Vector3(DOOR_LAMP.z * 1.3, 0.07, DOOR_LAMP.z * 1.3), 0.0, cap, false)
			look.fm.block(_at(p.x, DOOR_LAMP.y - 0.07 - DOOR_LAMP.z * 0.5, p.y), Vector3(DOOR_LAMP.z * 0.5, 0.07, DOOR_LAMP.z * 0.5), 0.0, cap, false)


func _lantern_instances() -> void:
	scenery.add_lanterns(_lantern_xf)


# ---------- the Portao da Aventura ----------

## The Portao's face (HubBlockout builds the wall, the arch and the sheet): two wine banners with the lion on the wall each
## side of the ring, the gold lion over the keystone, a pair of low steps to the sill, the two stone lions seated on their
## plinths at the foot of the facade (facing the camera) and the violet view in the opening.
func gate() -> void:
	var t := HubBlockout.GATE_TERRACE
	var wall := HubBlockout.GATE_WALL_U
	var cu := (wall.x + wall.y) * 0.5
	var front := HubBlockout.GATE_FRONT
	var half := HubBlockout.GATE_W * 0.5 + HubBlockout.GATE_RING
	var side := (half + (wall.y - wall.x) * 0.5) * 0.5
	for s: float in [-1.0, 1.0]:
		banner(cu + s * side, GATE_BANNER.z, front, GATE_BANNER.x, GATE_BANNER.y)
		_lion_statue(Vector3(cu + s * LION_OFFSET.x, t, front - LION_OFFSET.y), LION_OFFSET.z)
	look._lion(_at(cu, GATE_MEDAL.x, front - 0.03), Basis(), GATE_MEDAL.y, HubLook.MEDALLION_GOLD)
	for k in 2:
		look.fm.block(_at(cu, t, front - 0.5 - 0.3 * k), Vector3(HubBlockout.GATE_W + 0.9 + 0.5 * k, GATE_STEP.y * (2 - k), GATE_STEP.z - 0.1 * k), 0.0, look.facade_stone(), false)
	_vista(cu, front, t)


## A seated lion from stone boxes (plinth, haunches, chest, forelegs, mane, head, tail), its face to the camera (south), its
## plinth standing at foot (u, height, v).
func _lion_statue(foot: Vector3, scale_: float) -> void:
	var stone: Material = look.facade_stone()
	var fm := look.fm
	var u := foot.x
	var v := foot.z
	var base := foot.y
	fm.block(_at(u, base, v), Vector3(PLINTH.x, PLINTH.y, PLINTH.z) * scale_, 0.0, stone, false)
	fm.block(_at(u, base + PLINTH.y * scale_, v), Vector3(PLINTH.x + 0.18, 0.14, PLINTH.z + 0.18) * scale_, 0.0, stone, false)
	var y0 := base + (PLINTH.y + 0.14) * scale_
	var k := scale_
	# the haunches behind, the chest up in front
	fm.block(_at(u, y0, v + 0.22 * k), Vector3(0.86, 0.78, 0.85) * k, 0.0, stone, false)
	fm.block(_at(u, y0, v - 0.2 * k), Vector3(0.64, 1.3, 0.5) * k, 0.0, stone, false)
	for sd: float in [-1.0, 1.0]:
		fm.block(_at(u + sd * 0.2 * k, y0, v - 0.46 * k), Vector3(0.17, 0.8, 0.2) * k, 0.0, stone, false)
		fm.block(_at(u + sd * 0.2 * k, y0, v - 0.55 * k), Vector3(0.2, 0.08, 0.3) * k, 0.0, stone, false)
	# the mane (a diamond behind the head), the head and the muzzle
	var mane := fm.block(_at(u, y0 + 1.0 * k, v - 0.12 * k), Vector3(0.9, 0.9, 0.34) * k, 0.0, stone, false)
	mane.rotate_object_local(Vector3.BACK, PI * 0.25)
	fm.block(_at(u, y0 + 1.1 * k, v - 0.34 * k), Vector3(0.46, 0.5, 0.42) * k, 0.0, stone, false)
	fm.block(_at(u, y0 + 1.1 * k, v - 0.6 * k), Vector3(0.28, 0.22, 0.2) * k, 0.0, stone, false)
	# the tail along the haunch
	fm.block(_at(u + 0.45 * k, y0, v + 0.3 * k), Vector3(0.1, 0.1, 0.5) * k, 0.0, stone, false)


## The view through the opening: the vista card (hub_vista.gdshader) just in front of the wall and behind the sheet of light,
## cut to the arch.
func _vista(cu: float, front: float, base: float) -> void:
	var mi := MeshInstance3D.new()
	mi.name = "GateVista"
	mi.mesh = ogive_mesh(HubBlockout.GATE_W, HubBlockout.GATE_SPRING, HubBlockout.gate_arc(), [], 10)
	var mat := ShaderMaterial.new()
	mat.shader = VISTA_SHADER
	mi.material_override = mat
	mi.position = _at(cu, base, front - 0.04)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	look.frame.add_child(mi)


func _rect(id: StringName) -> Vector4:
	for b in HubPlan.BUILDINGS:
		if b[&"id"] == id:
			return b[&"rect"]
	return Vector4.ZERO
