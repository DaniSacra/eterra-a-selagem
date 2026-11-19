class_name GroundLook
extends RefCounted
## How an area on the floor is drawn (ground.gdshader on a flat quad), apart from what it does (Ground), so the
## labs can draw a warning without a game around it (tools/enemy_lab.gd --warn).

const SHADER := preload("res://assets/shaders/ground.gdshader")
## The second pass of every floor area: an enemy's own warning's red fill, never added to another fill under it
## (C12d, VX-03, the stencil in ground_fill.gdshader). Its uniforms are the first pass's: set both with put.
const FILL_SHADER := preload("res://assets/shaders/ground_fill.gdshader")
## ground.gdshader's styles, and its shapes (the same order as Ground.Shape; this file does not name Ground, which
## needs the game's autoloads).
enum Style { WARNING, AREA, CIRCLE, HAZARD }
enum Shape { CIRCLE, LINE, ARC }
## An enemy's warning: its red, how strongly it is drawn (bright enough to read on the dark floor) and the meters of
## its bright rim (its size is always the attack's).
const WARNING_COLOR := Color(1.0, 0.18, 0.12)
const WARNING_STRENGTH := 1.4
const RIM_METERS := 0.28
## Morvath's signature on his warnings (ART-001, docs/art/boss_chamber_spec.md section 8): a narrower red rim, and
## the quad reaches this far past the area for the violet thread and the band of spectral runes (thread 2 px, gap,
## runes 0.3 m: ground.gdshader's signature; C12a: a 2 px dark gap between the rim and the thread, so 0.44 m).
const SIGN_RIM := 0.18
const SIGN_PAD := 0.44
## The red fill of his warnings (ground.gdshader's sign_fill; the eruptions' circles take it too, art review P5).
const SIGN_FILL := 0.35
## Every other warning's faint floor and light (ground.gdshader's defaults: base_fill, no light_cap).
const BASE_FILL := 0.08
const NO_CAP := 64.0
## The storm's lanes (art review P2): nothing drawn this close to their root (Morvath), and their fill comes up from
## STORM_ROOT_FILL of itself there to all of it STORM_SOFT meters further out (C12a BOSS-001: from nothing, across the seal, and
## the faint floor, the violet thread and the runes come up with it, and the rims from STORM_ROOT_RIM: the six roots
## met in a pink disc over the seal).
const STORM_CLEAR := 1.2
const STORM_SOFT := 5.0
const STORM_ROOT_FILL := 0.0
const STORM_ROOT_RIM := 0.3
## The storm's lanes cover most of the floor at once: their red fill is lighter than his other warnings' (SIGN_FILL),
## so the lighter floor of the chamber (P1) under six of them does not go to a hot pink (the rims, the fronts, the order
## marks and the runes stay as they are).
const STORM_FILL := 0.09
## C12a (BOSS-001: the middle still read the lightest shape of the frame, luminance 121, where the six roots and the
## paladin's circle meet): a lighter fill (STORM_FILL, was 0.2: the floor's joints show in the lanes' middles), the
## lanes' faint floor (ground.gdshader's base_fill, 0.08 on every other warning), their rims at STORM_RIM of the light
## (the brightest, the next to leave, adds 0.95 of red: under 1, never past the glow threshold) and the most light any
## channel of a lane adds where its parts stack (light_cap).
const STORM_BASE := 0.02
const STORM_RIM := 0.75
const STORM_CAP := 0.95
## The storm's rim by its place in the order of leaving (the next to leave first): its share of the light.
const ORDER_LEVELS: Array[float] = [1.0, 0.7, 0.55, 0.45, 0.38, 0.32]
## The floor that strikes on its own (E5, the runes; docs/art/e5_spec.md 3.4): amber, never the enemies' red nor
## Morvath's violet; a frame round every tile (HAZARD_TILE m) that warms with the wind-up, a faint fill (alpha 0.08)
## coming up to 0.3 over the last 30% (the warnings' own fill_late, the hand learns it once); its strongest channel
## stays under 1.0 (HAZARD_STRENGTH). Drawn before the enemies' warnings (render priority HAZARD_PRIORITY).
const HAZARD_COLOR := Color(1.0, 0.62, 0.25)
const HAZARD_STRENGTH := 0.75
const HAZARD_RIM := 0.12
const HAZARD_TILE := 3.0
const HAZARD_FILL_EARLY := 0.08
const HAZARD_FILL_MAX := 0.3
const HAZARD_PRIORITY := -1
## Every other area's fill (ground.gdshaderinc's defaults).
const FILL_EARLY := 0.1
const FILL_MAX := 0.35
## C17, QW-107 (ART P1-6): a crossbow's aim and a soldier's pounce drawn as an aim (ground.gdshaderinc aim_px): a
## thread AIM_PX pixels wide at AIM_LIGHT, its far end up to 1, and the band filling to AIM_FILL only over the last
## AIM_FILL_LATE of the wind-up (nothing before; no faint floor). Strength 1: those are the light itself, so nothing
## but the tip passes 0.6.
const AIM_PX := 6.0
const AIM_LIGHT := 0.5
const AIM_FILL := 0.22
const AIM_FILL_LATE := 0.3
## LC-5: in the Compatibility renderer's stylized look (browser, phone) the painted floor is lighter and colder and a red
## added to it read pale pink (Morvath's storm lanes, 13% red against 77% on the desktop): a warning adds COMPAT_GAIN
## times its light there and lays the floor under its area at 1 - COMPAT_UNDER (ground.gdshaderinc style_compat_*).
## Set only in that renderer; nothing changes on the desktop nor in the classic look.
const COMPAT_GAIN := 1.1
const COMPAT_UNDER := 0.3


static func new_node() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1, 1)
	mi.mesh = plane
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	var fill := ShaderMaterial.new()
	fill.shader = FILL_SHADER
	mat.next_pass = fill
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		put(mat, &"style_compat_gain", COMPAT_GAIN)
		put(mat, &"style_compat_under", COMPAT_UNDER)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


## Lays the quad over the area and sets its look. shape: Shape (Ground.Shape). radius: circle and arc radius, line length;
## width: line width, arc opening in degrees. dir: unit, where a line or an arc goes. y: height over the floor.
## pad: meters the quad reaches past the area (a signed warning's thread and runes; 0 for everything else).
static func dress(node: MeshInstance3D, style: Style, shape: int, color: Color, strength: float, rim_m: float,
		at: Vector2, dir: Vector2, radius: float, width: float, y: float, pad := 0.0) -> void:
	var m := node.material_override as ShaderMaterial
	var line := shape == Shape.LINE
	put(m, &"signed", 1.0 if pad > 0.0 else 0.0)
	put(m, &"pad_m", pad)
	put(m, &"order_marks", 0.0)
	put(m, &"order_level", 1.0)
	put(m, &"wedge", Vector2.ZERO)
	put(m, &"root_clear_m", 0.0)
	put(m, &"root_soft_m", 0.0)
	put(m, &"root_fill", 1.0)
	put(m, &"root_rim", 1.0)
	put(m, &"sign_fill", SIGN_FILL)
	put(m, &"base_fill", BASE_FILL)
	put(m, &"rim_scale", 1.0)
	put(m, &"light_cap", NO_CAP)
	put(m, &"color", color)
	put(m, &"tile_m", 0.0)
	put(m, &"aim_px", 0.0)
	put(m, &"fill_early", FILL_EARLY)
	put(m, &"fill_max", FILL_MAX)
	_priority(m, HAZARD_PRIORITY if style == Style.HAZARD else 0)
	put(m, &"progress", 0.0)
	put(m, &"style", style)
	put(m, &"shape", shape)
	put(m, &"fade", 1.0)
	put(m, &"strength", strength)
	put(m, &"size_m", maxf(0.1, width * 0.5 if line else radius))
	put(m, &"rim_m", rim_m)
	put(m, &"length_m", radius if line else 1.0)
	match shape:
		Shape.LINE:
			node.scale = Vector3(width + pad * 2.0, 1.0, radius)
			node.rotation = Vector3(0, atan2(dir.x, dir.y), 0)
			var mid := at + dir * radius * 0.5
			node.position = Vector3(mid.x, y, mid.y)
		Shape.ARC:
			put(m, &"arc_half", deg_to_rad(width) * 0.5)
			node.scale = Vector3((radius + pad) * 2.0, 1.0, (radius + pad) * 2.0)
			# the shader opens the arc towards -V of the quad; turn the quad so that points along dir
			node.rotation = Vector3(0, atan2(-dir.x, -dir.y), 0)
			node.position = Vector3(at.x, y, at.y)
		_:
			node.scale = Vector3((radius + pad) * 2.0, 1.0, (radius + pad) * 2.0)
			node.rotation = Vector3.ZERO
			node.position = Vector3(at.x, y, at.y)


## Sets a uniform of a floor area on its material and on its fill pass (new_node), so both draw the same area.
## Any other material (a ritual circle's) takes it alone.
static func put(m: ShaderMaterial, uniform: StringName, value: Variant) -> void:
	m.set_shader_parameter(uniform, value)
	var fill := m.next_pass as ShaderMaterial
	if fill != null:
		fill.set_shader_parameter(uniform, value)


## A band of the floor that strikes on its own (E5, the runes), as Ground draws it: a line `length` long, `width`
## across, framed tile by tile.
static func hazard(node: MeshInstance3D, at: Vector2, dir: Vector2, length: float, width: float, y: float) -> void:
	dress(node, Style.HAZARD, Shape.LINE, HAZARD_COLOR, HAZARD_STRENGTH, HAZARD_RIM, at, dir, length, width, y)
	var m := node.material_override as ShaderMaterial
	put(m, &"tile_m", HAZARD_TILE)
	put(m, &"fill_early", HAZARD_FILL_EARLY)
	put(m, &"fill_max", HAZARD_FILL_MAX)


static func _priority(m: ShaderMaterial, p: int) -> void:
	m.render_priority = p
	if m.next_pass != null:
		m.next_pass.render_priority = p


## An enemy's warning, as Ground draws it.
static func warning(node: MeshInstance3D, shape: int, at: Vector2, dir: Vector2, radius: float, width: float, y: float) -> void:
	dress(node, Style.WARNING, shape, WARNING_COLOR, WARNING_STRENGTH, RIM_METERS, at, dir, radius, width, y)


## An enemy's line warning drawn as an aim (QW-107): the thread, the bright tip, the late fill.
static func aim_warning(node: MeshInstance3D, at: Vector2, dir: Vector2, length: float, width: float, y: float) -> void:
	dress(node, Style.WARNING, Shape.LINE, WARNING_COLOR, 1.0, RIM_METERS, at, dir, length, width, y)
	aim(node.material_override as ShaderMaterial)


## Turns a line warning's material into an aim (QW-107).
static func aim(m: ShaderMaterial) -> void:
	put(m, &"strength", 1.0)
	put(m, &"aim_px", AIM_PX)
	put(m, &"aim_light", AIM_LIGHT)
	put(m, &"fill_early", 0.0)
	put(m, &"fill_max", AIM_FILL)
	put(m, &"fill_late", AIM_FILL_LATE)
	put(m, &"base_fill", 0.0)


## One of Morvath's warnings, with his signature (ART-001).
static func signed_warning(node: MeshInstance3D, shape: int, at: Vector2, dir: Vector2, radius: float, width: float, y: float) -> void:
	dress(node, Style.WARNING, shape, WARNING_COLOR, WARNING_STRENGTH, SIGN_RIM, at, dir, radius, width, y, SIGN_PAD)


## A storm lane's place in the order of leaving: marks (1 to 6) at its root, rank 0 the next to leave (the brightest
## rim). marks < 0 keeps the marks it has.
static func order(node: MeshInstance3D, marks: int, rank: int) -> void:
	var m := node.material_override as ShaderMaterial
	if marks >= 0:
		m.set_shader_parameter(&"order_marks", float(marks))
	m.set_shader_parameter(&"order_level", ORDER_LEVELS[clampi(rank, 0, ORDER_LEVELS.size() - 1)])


## A storm lane's share of the floor round its root (ground.gdshader's wedge): half the angle to the lane next to it on
## the quad's +x side (the next smaller angle, Vector2.angle) and on the other side, and nothing within STORM_CLEAR.
static func storm_wedge(node: MeshInstance3D, wedge: Vector2) -> void:
	var m := node.material_override as ShaderMaterial
	m.set_shader_parameter(&"wedge", wedge)
	m.set_shader_parameter(&"root_clear_m", STORM_CLEAR)
	m.set_shader_parameter(&"root_soft_m", STORM_SOFT)
	m.set_shader_parameter(&"root_fill", STORM_ROOT_FILL)
	m.set_shader_parameter(&"root_rim", STORM_ROOT_RIM)
	m.set_shader_parameter(&"sign_fill", STORM_FILL)
	m.set_shader_parameter(&"base_fill", STORM_BASE)
	m.set_shader_parameter(&"rim_scale", STORM_RIM)
	m.set_shader_parameter(&"light_cap", STORM_CAP)


## The wedges of lanes leaving one point the ways in dirs (unit): for each, half the angle to its neighbour with the
## next smaller angle (x) and to the one with the next larger (y), in radians. One lane alone keeps its whole width.
static func storm_wedges(dirs: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	var n := dirs.size()
	for i in n:
		if n < 2:
			out.append(Vector2.ZERO)
			continue
		var lo := TAU
		var hi := TAU
		for j in n:
			if j == i:
				continue
			var gap := fposmod(dirs[j].angle() - dirs[i].angle(), TAU)
			hi = minf(hi, gap)
			lo = minf(lo, TAU - gap)
		out.append(Vector2(lo, hi) * 0.5)
	return out
