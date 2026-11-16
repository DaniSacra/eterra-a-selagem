class_name GroundLook
extends RefCounted
## How an area on the floor is drawn (ground.gdshader on a flat quad), apart from what it does (Ground), so the
## labs can draw a warning without a game around it (tools/enemy_lab.gd --warn).

const SHADER := preload("res://assets/shaders/ground.gdshader")
## ground.gdshader's styles, and its shapes (the same order as Ground.Shape; this file does not name Ground, which
## needs the game's autoloads).
enum Style { WARNING, AREA, CIRCLE }
enum Shape { CIRCLE, LINE, ARC }
## An enemy's warning: its red, how strongly it is drawn (bright enough to read on the dark floor) and the meters of
## its bright rim (its size is always the attack's).
const WARNING_COLOR := Color(1.0, 0.18, 0.12)
const WARNING_STRENGTH := 1.4
const RIM_METERS := 0.28
## Morvath's signature on his warnings (ART-001, docs/art/boss_chamber_spec.md section 8): a narrower red rim, and
## the quad reaches this far past the area for the violet thread and the band of spectral runes (thread 2 px, gap,
## runes 0.3 m: ground.gdshader's signature).
const SIGN_RIM := 0.18
const SIGN_PAD := 0.38
## The red fill of his warnings (ground.gdshader's sign_fill; the eruptions' circles take it too, art review P5).
const SIGN_FILL := 0.35
## The storm's lanes (art review P2): nothing drawn this close to their root (Morvath), and their fill comes up from
## STORM_ROOT_FILL of itself there to all of it STORM_SOFT meters further out.
const STORM_CLEAR := 1.2
const STORM_SOFT := 2.5
const STORM_ROOT_FILL := 0.35
## The storm's lanes cover most of the floor at once: their red fill is lighter than his other warnings' (SIGN_FILL),
## so the lighter floor of the chamber (P1) under six of them does not go to a hot pink (the rims, the fronts, the order
## marks and the runes stay as they are).
const STORM_FILL := 0.2
## The storm's rim by its place in the order of leaving (the next to leave first): its share of the light.
const ORDER_LEVELS: Array[float] = [1.0, 0.7, 0.55, 0.45, 0.38, 0.32]


static func new_node() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1, 1)
	mi.mesh = plane
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
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
	m.set_shader_parameter(&"signed", 1.0 if pad > 0.0 else 0.0)
	m.set_shader_parameter(&"pad_m", pad)
	m.set_shader_parameter(&"order_marks", 0.0)
	m.set_shader_parameter(&"order_level", 1.0)
	m.set_shader_parameter(&"wedge", Vector2.ZERO)
	m.set_shader_parameter(&"root_clear_m", 0.0)
	m.set_shader_parameter(&"root_soft_m", 0.0)
	m.set_shader_parameter(&"root_fill", 1.0)
	m.set_shader_parameter(&"sign_fill", SIGN_FILL)
	m.set_shader_parameter(&"color", color)
	m.set_shader_parameter(&"progress", 0.0)
	m.set_shader_parameter(&"style", style)
	m.set_shader_parameter(&"shape", shape)
	m.set_shader_parameter(&"fade", 1.0)
	m.set_shader_parameter(&"strength", strength)
	m.set_shader_parameter(&"size_m", maxf(0.1, width * 0.5 if line else radius))
	m.set_shader_parameter(&"rim_m", rim_m)
	m.set_shader_parameter(&"length_m", radius if line else 1.0)
	match shape:
		Shape.LINE:
			node.scale = Vector3(width + pad * 2.0, 1.0, radius)
			node.rotation = Vector3(0, atan2(dir.x, dir.y), 0)
			var mid := at + dir * radius * 0.5
			node.position = Vector3(mid.x, y, mid.y)
		Shape.ARC:
			m.set_shader_parameter(&"arc_half", deg_to_rad(width) * 0.5)
			node.scale = Vector3((radius + pad) * 2.0, 1.0, (radius + pad) * 2.0)
			# the shader opens the arc towards -V of the quad; turn the quad so that points along dir
			node.rotation = Vector3(0, atan2(-dir.x, -dir.y), 0)
			node.position = Vector3(at.x, y, at.y)
		_:
			node.scale = Vector3((radius + pad) * 2.0, 1.0, (radius + pad) * 2.0)
			node.rotation = Vector3.ZERO
			node.position = Vector3(at.x, y, at.y)


## An enemy's warning, as Ground draws it.
static func warning(node: MeshInstance3D, shape: int, at: Vector2, dir: Vector2, radius: float, width: float, y: float) -> void:
	dress(node, Style.WARNING, shape, WARNING_COLOR, WARNING_STRENGTH, RIM_METERS, at, dir, radius, width, y)


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
	m.set_shader_parameter(&"sign_fill", STORM_FILL)


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
