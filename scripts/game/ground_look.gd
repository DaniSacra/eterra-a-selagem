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
enum Style { WARNING, AREA, CIRCLE, HAZARD, EMBERS }
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
## SR-P4 (one style for every area warning): since the lote 3 the floor's own bands and rings (chain, slit, trap, urn,
## oil, stones, slabs) are drawn as any enemy's warning: the game's warning red (WARNING_COLOR), the clean rim
## (RIM_METERS), the faint floor rising to FILL_MAX; only the render priority keeps them under the enemies' warnings.
## The runes' own tiles (RunesLook) keep their amber.
const HAZARD_COLOR := WARNING_COLOR
const HAZARD_STRENGTH := WARNING_STRENGTH
const HAZARD_RIM := RIM_METERS
const HAZARD_TILE := 3.0
const HAZARD_FILL_EARLY := 0.1
const HAZARD_FILL_MAX := 0.35
const HAZARD_PRIORITY := -1
## Every other area's fill (ground.gdshaderinc's defaults).
const FILL_EARLY := 0.1
const FILL_MAX := 0.35
## C17, QW-107 (ART P1-6): a crossbow's aim and a soldier's pounce drawn as an aim (ground.gdshaderinc aim_px): a
## thread AIM_PX pixels wide at AIM_LIGHT, its far end up to 1, and the band filling to AIM_FILL only over the last
## AIM_FILL_LATE of the wind-up (nothing before; no faint floor). Strength 1: those are the light itself, so nothing
## but the tip passes 0.6.
## Art review 2026-11-21 (two red threads across the whole frame): thinner and dimmer, the bright tip kept.
const AIM_PX := 4.5
const AIM_LIGHT := 0.38
const AIM_FILL := 0.22
const AIM_FILL_LATE := 0.3
## Combate C1 (combate_c1_leitura 6): a line that still follows the paladin is only a thread ("it follows you": a line
## at TRACK_STRENGTH; an aim at TRACK_AIM_LIGHT and TRACK_AIM_PX, with no fill) and the moment it locks pulses once
## (Ground.lock_line): in LOCK_RISE s up to the PEAK values, then down over LOCK_FALL s to the SETTLED ones ("thread" to
## "piece"); the aim's band fills from the lock on.
const TRACK_STRENGTH := 0.7
const TRACK_AIM_LIGHT := 0.30
const TRACK_AIM_PX := 3.5
const LOCK_RISE := 0.07
const LOCK_FALL := 0.2
const LOCK_STRENGTH_PEAK := 2.2
const LOCK_AIM_PX_PEAK := 9.0
const LOCK_AIM_PX_SETTLED := 5.0
const LOCK_AIM_LIGHT_PEAK := 0.9
const LOCK_AIM_LIGHT_SETTLED := 0.5
## Seconds after the lock the dry click is heard (it follows the wind-up's own tell).
const LOCK_CLICK_AT := 0.02
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
	put(m, &"plate", 0.0)
	put(m, &"plate_red", 0.0)
	put(m, &"aim_px", 0.0)
	put(m, &"fill_early", FILL_EARLY)
	put(m, &"fill_max", FILL_MAX)
	put(m, &"fill_late", AIM_FILL_LATE)  # (the shader's default; a pooled quad may come back from a locked aim)
	_priority(m, HAZARD_PRIORITY if style == Style.HAZARD else 0)
	put(m, &"progress", 0.0)
	put(m, &"style", style)
	put(m, &"shape", shape)
	put(m, &"fade", 1.0)
	put(m, &"strength", strength)
	put(m, &"size_m", maxf(0.1, width * 0.5 if line else radius))
	put(m, &"rim_m", rim_m)
	put(m, &"rim_cap", 0.2)
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
	put(m, &"fill_early", HAZARD_FILL_EARLY)
	put(m, &"fill_max", HAZARD_FILL_MAX)


## RP-12: the hazard's amber over a circle (the oil urn's ring): its rim whole from the first frame, the fill rising.
static func hazard_round(node: MeshInstance3D, at: Vector2, radius: float, y: float) -> void:
	dress(node, Style.HAZARD, Shape.CIRCLE, HAZARD_COLOR, HAZARD_STRENGTH, HAZARD_RIM, at, Vector2.DOWN, radius, 0.0, y)
	var m := node.material_override as ShaderMaterial
	put(m, &"fill_early", HAZARD_FILL_EARLY)
	put(m, &"fill_max", HAZARD_FILL_MAX)


## RP-06: a slab that strikes when stepped on (PlateFloor), placeholder until the environment artist's piece (SW-G7):
## at rest its frame and two cracks in a dull bone (PLATE_REST_COLOR at PLATE_REST_STRENGTH: read, never amber, the
## colour only a lit floor danger has); arming, the amber of the runes reaching from the frame to the middle.
const PLATE_REST_COLOR := Color(0.62, 0.57, 0.48)
const PLATE_REST_STRENGTH := 0.9
const PLATE_CRACK := 0.8
const PLATE_RIM := 0.14


## Lays a slab's quad over the rectangle r, drawn at rest (set_plate moves it on).
static func plate(node: MeshInstance3D, r: Rect2, y: float) -> void:
	plate_band(node, Vector2(r.position.x, r.get_center().y), Vector2.RIGHT, r.size.x, r.size.y, y)


## plate over any band of the floor (RP-10: a root's strip, placeholder until the environment artist's root that cracks).
static func plate_band(node: MeshInstance3D, from: Vector2, dir: Vector2, length: float, width: float, y: float) -> void:
	dress(node, Style.HAZARD, Shape.LINE, PLATE_REST_COLOR, PLATE_REST_STRENGTH, PLATE_RIM, from, dir, length, width, y)
	var m := node.material_override as ShaderMaterial
	put(m, &"plate", PLATE_CRACK)
	put(m, &"fill_early", HAZARD_FILL_EARLY)
	put(m, &"fill_max", HAZARD_FILL_MAX)


## The ember of a slab's fissure (RP-13, art review 2026-11-23 item 1): arming is a coal, not a warning.
const PLATE_EMBER := Color(1.0, 0.62, 0.25)
const PLATE_EMBER_STRENGTH := 0.8
const PLATE_FILL_MAX := 0.25
## The red of the warning shows only as a rim this wide (m), the last Feel.bang_lead seconds of the arming and the strike.
const PLATE_RED_RIM := 0.12


## A slab's state (PlateHazard.state: x arming, y strike, z ember): at rest the bone frame; arming the amber of the
## fissure reaching in (the slab's body stays stone); in the last `lead` share of the arming (Feel.bang_lead / warn)
## and while it strikes, the red rim of PLATE_RED_RIM; the ember falling back to rest.
static func set_plate(node: MeshInstance3D, s: Vector3, lead := 0.0) -> void:
	var m := node.material_override as ShaderMaterial
	var hot := maxf(maxf(s.x, s.y), s.z)
	var lit := s.x > 0.0 or s.y > 0.0
	var glow := minf(1.0, hot * 4.0)
	put(m, &"color", PLATE_REST_COLOR.lerp(PLATE_EMBER, glow))
	put(m, &"strength", lerpf(PLATE_REST_STRENGTH, PLATE_EMBER_STRENGTH, glow))
	put(m, &"fill_max", PLATE_FILL_MAX)
	var red := 0.0
	if s.y > 0.0 or (s.x > 0.0 and lead > 0.0 and s.x >= 1.0 - lead):
		red = 1.0
	put(m, &"plate_red", red)
	put(m, &"plate_red_m", PLATE_RED_RIM)
	put(m, &"progress", s.x if s.x > 0.0 else 1.0 if s.y > 0.0 else s.z if not lit else 0.0)


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


## The rift's breath (RP-08, art review 2026-11-23 laje_armada): it pushes and never hurts, so no warning red: a pale
## grey-blue haze (the mist rising) with a thin rim, a faint fill; the red stays for what hurts (PT-1).
const GUST_COLOR := Color(0.58, 0.68, 0.82)
const GUST_STRENGTH := 0.6
const GUST_RIM_M := 0.08
const GUST_FILL := 0.12
static func gust(m: ShaderMaterial) -> void:
	put(m, &"color", GUST_COLOR)
	put(m, &"strength", GUST_STRENGTH)
	put(m, &"rim_m", GUST_RIM_M)
	put(m, &"fill_early", GUST_FILL * 0.5)
	put(m, &"fill_max", GUST_FILL)


## The Canalizador's beam on the floor (art review 2026-11-23, item 18): a floor that shows through (the fill never past
## BEAM_FILL_MAX, 0.3 after the stylized gain of 1.5) inside a thin warning ring of BEAM_RIM_M, not an opaque tape.
const BEAM_RIM_M := 0.08
const BEAM_FILL_MAX := 0.2
static func beam(m: ShaderMaterial, half_width: float) -> void:
	put(m, &"rim_m", BEAM_RIM_M)
	put(m, &"rim_cap", BEAM_RIM_M / maxf(half_width, 0.01))
	put(m, &"fill_early", BEAM_FILL_MAX)
	put(m, &"fill_max", BEAM_FILL_MAX)
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


## A warning that follows the paladin until it locks: its quiet look (see TRACK_STRENGTH). aim: drawn with GroundLook.aim.
static func tracking(m: ShaderMaterial, aim: bool) -> void:
	if aim:
		put(m, &"aim_px", TRACK_AIM_PX)
		put(m, &"aim_light", TRACK_AIM_LIGHT)
		put(m, &"fill_max", 0.0)
	else:
		put(m, &"strength", TRACK_STRENGTH)


## The pulse `t` seconds after the lock (see LOCK_RISE); done at LOCK_RISE + LOCK_FALL. left: the share of the wind-up
## still to run at the lock, where the aim's fill begins.
static func lock_pulse(m: ShaderMaterial, aim: bool, t: float, left: float) -> void:
	var up := clampf(t / LOCK_RISE, 0.0, 1.0)
	var down := clampf((t - LOCK_RISE) / LOCK_FALL, 0.0, 1.0)
	if aim:
		put(m, &"fill_max", AIM_FILL)
		put(m, &"fill_late", clampf(left, 0.05, 1.0))
		put(m, &"aim_px", lerpf(TRACK_AIM_PX, LOCK_AIM_PX_PEAK, up) if down <= 0.0 else lerpf(LOCK_AIM_PX_PEAK, LOCK_AIM_PX_SETTLED, down))
		put(m, &"aim_light", lerpf(TRACK_AIM_LIGHT, LOCK_AIM_LIGHT_PEAK, up) if down <= 0.0 else lerpf(LOCK_AIM_LIGHT_PEAK, LOCK_AIM_LIGHT_SETTLED, down))
	else:
		put(m, &"strength", lerpf(TRACK_STRENGTH, LOCK_STRENGTH_PEAK, up) if down <= 0.0 else lerpf(LOCK_STRENGTH_PEAK, WARNING_STRENGTH, down))
