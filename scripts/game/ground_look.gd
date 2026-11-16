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
