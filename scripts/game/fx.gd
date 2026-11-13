class_name Fx
extends Node3D
## Everything that only shows: particle bursts, sword arcs, shockwaves, pillars of light, damage numbers,
## camera shake, hit stop and the full screen colour split. Pooled; nothing here changes the game.

const SLASH := preload("res://assets/shaders/slash.gdshader")
const RING := preload("res://assets/shaders/ring.gdshader")
const BEAM := preload("res://assets/shaders/beam.gdshader")
const GOLD := Color(1.0, 0.82, 0.38)
const SLASH_POOL := 18
const RING_POOL := 16
const BEAM_POOL := 24
const NUMBER_POOL := 90
const SHAKE_METERS := 0.12

## kind -> [colour, amount, speed, gravity, size, lifetime, spread]
const BURSTS := {
	&"spark": [Color(2.6, 2.2, 1.4), 10, 9.0, -6.0, 0.16, 0.28, 50.0],
	&"bone": [Color(1.4, 1.35, 1.2), 9, 5.5, -16.0, 0.22, 0.7, 70.0],
	&"fire": [Color(3.0, 1.2, 0.3), 16, 4.0, 3.0, 0.42, 0.55, 80.0],
	&"frost": [Color(1.2, 2.2, 3.2), 14, 6.0, -5.0, 0.26, 0.5, 80.0],
	&"light": [Color(3.0, 2.5, 1.2), 18, 4.0, 2.0, 0.3, 0.7, 90.0],
	&"shadow": [Color(1.2, 0.4, 2.0), 16, 3.0, 1.5, 0.55, 0.8, 90.0],
	&"dust": [Color(0.5, 0.45, 0.42), 10, 2.5, 0.5, 0.6, 0.6, 70.0],
	&"heal": [Color(0.8, 2.6, 1.2), 16, 2.5, 2.5, 0.3, 0.8, 90.0],
}

var camera: Camera3D
## Where damage numbers are drawn (a Control over the 3D view).
var overlay: Control
var stop_left := 0.0
## Strength of the colour split on screen (0..1), read by the screen pass.
var split := 0.0
var shake_scale := 1.0
var _shake := 0.0
var _pools: Dictionary = {}
var _next: Dictionary = {}
var _slashes: Array[Dictionary] = []
var _rings: Array[Dictionary] = []
var _beams: Array[Dictionary] = []
var _numbers: Array[Dictionary] = []
var _font: Font
var _arc_meshes: Dictionary = {}
var _rng := RandomNumberGenerator.new()


static func quad(size: float, color: Color) -> QuadMesh:
	var q := QuadMesh.new()
	q.size = Vector2(size, size)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.vertex_color_use_as_albedo = true
	m.albedo_color = color
	m.albedo_texture = soft_dot()
	m.disable_receive_shadows = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = m
	return q


static var _dot: GradientTexture2D

## A round soft dot, white in the middle.
static func soft_dot() -> GradientTexture2D:
	if _dot == null:
		_dot = GradientTexture2D.new()
		_dot.fill = GradientTexture2D.FILL_RADIAL
		_dot.fill_from = Vector2(0.5, 0.5)
		_dot.fill_to = Vector2(0.5, 0.0)
		_dot.width = 64
		_dot.height = 64
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.35, Color(1, 1, 1, 0.75))
		_dot.gradient = g
	return _dot


static func fade_ramp(c: Color) -> Gradient:
	var g := Gradient.new()
	g.set_color(0, c)
	g.set_color(1, Color(c.r, c.g, c.b, 0.0))
	return g


func setup(cam: Camera3D, over: Control) -> void:
	camera = cam
	overlay = over
	_font = load("res://assets/fonts/AlegreyaSans-Bold.ttf")
	for kind: StringName in BURSTS:
		var spec: Array = BURSTS[kind]
		var list: Array[CPUParticles3D] = []
		for i in 14:
			var p := CPUParticles3D.new()
			p.emitting = false
			p.one_shot = true
			p.explosiveness = 0.92
			p.amount = spec[1]
			p.lifetime = spec[5]
			p.initial_velocity_min = spec[2] * 0.4
			p.initial_velocity_max = spec[2]
			p.gravity = Vector3(0, spec[3], 0)
			p.spread = spec[6]
			p.direction = Vector3.UP
			p.scale_amount_min = 0.5
			p.scale_amount_max = 1.0
			p.damping_min = 2.0
			p.damping_max = 4.0
			p.mesh = quad(spec[4], spec[0])
			p.color_ramp = fade_ramp(Color.WHITE)
			p.local_coords = false
			add_child(p)
			list.append(p)
		_pools[kind] = list
		_next[kind] = 0
	for i in SLASH_POOL:
		_slashes.append(_effect_node(SLASH, null))
	for i in RING_POOL:
		var plane := PlaneMesh.new()
		plane.size = Vector2(2, 2)
		_rings.append(_effect_node(RING, plane))
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.7
	cyl.bottom_radius = 1.0
	cyl.height = 1.0
	cyl.radial_segments = 16
	cyl.cap_top = false
	cyl.cap_bottom = false
	for i in BEAM_POOL:
		_beams.append(_effect_node(BEAM, cyl))
	for i in NUMBER_POOL:
		var l := Label.new()
		l.add_theme_font_override(&"font", _font)
		l.add_theme_constant_override(&"outline_size", 8)
		l.add_theme_color_override(&"font_outline_color", Color(0.05, 0.02, 0.06, 0.9))
		l.visible = false
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		overlay.add_child(l)
		_numbers.append({"label": l, "life": 0.0, "pos": Vector3.ZERO, "rise": 0.0})


func _effect_node(shader: Shader, mesh: Mesh) -> Dictionary:
	var mi := MeshInstance3D.new()
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mi.material_override = mat
	mi.mesh = mesh
	mi.visible = false
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return {"node": mi, "mat": mat, "life": 1.0, "time": 1.0, "grow": 0.0, "size": 1.0}


# ---------- what the game calls ----------

func burst(kind: StringName, pos: Vector3, dir: Vector3 = Vector3.ZERO) -> void:
	var list: Array = _pools.get(kind, [])
	if list.is_empty():
		return
	var i: int = _next[kind]
	_next[kind] = (i + 1) % list.size()
	var p: CPUParticles3D = list[i]
	p.global_position = pos
	p.direction = (dir + Vector3.UP * 0.6).normalized() if dir != Vector3.ZERO else Vector3.UP
	p.restart()


## A sword arc on the floor plane at waist height: from origin towards dir, reach meters, width degrees.
func slash(origin: Vector2, dir: Vector2, reach: float, width_deg: float, color: Color, time: float = 0.2, flip: bool = false, height: float = 0.9) -> void:
	var s: Dictionary = _take(_slashes)
	var mi: MeshInstance3D = s.node
	mi.mesh = _arc(reach, width_deg)
	mi.position = Vector3(origin.x, height, origin.y)
	mi.rotation = Vector3(_rng.randf_range(-0.18, 0.18), atan2(dir.x, dir.y), 0.0)
	var mat: ShaderMaterial = s.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"flip", flip)
	mat.set_shader_parameter(&"t", 0.0)
	s.time = time


## A flat shockwave growing to radius.
func ring(center: Vector2, radius: float, color: Color, time: float = 0.35, height: float = 0.15) -> void:
	var r: Dictionary = _take(_rings)
	var mi: MeshInstance3D = r.node
	mi.position = Vector3(center.x, height, center.y)
	r.size = radius
	r.grow = 1.0
	mi.scale = Vector3.ONE * radius * 0.3
	(r.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	r.time = time


## A pillar of light (or shadow) at a point on the floor.
func beam(at: Vector2, color: Color, radius: float = 0.8, height: float = 9.0, time: float = 0.45) -> void:
	var b: Dictionary = _take(_beams)
	var mi: MeshInstance3D = b.node
	mi.position = Vector3(at.x, height * 0.5, at.y)
	mi.scale = Vector3(radius, height, radius)
	b.size = radius
	(b.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	b.time = time


func number(pos: Vector3, amount: float, color: Color, big: bool = false) -> void:
	_text(pos, str(roundi(amount)), color, 34 if big else 24)


func word(pos: Vector3, text: String, color: Color) -> void:
	_text(pos, text, color, 30)


func hit_stop(ms: float) -> void:
	stop_left = maxf(stop_left, ms / 1000.0)


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount * SHAKE_METERS * shake_scale)


func kick_split(amount: float) -> void:
	split = maxf(split, amount)


## Runs every frame, even during hit stop. Returns the camera's shake offset.
func tick(delta: float) -> Vector3:
	stop_left = maxf(0.0, stop_left - delta)
	_shake = maxf(0.0, _shake - delta * (0.6 + _shake * 6.0))
	split = maxf(0.0, split - delta * 3.0)
	if _shake <= 0.0:
		return Vector3.ZERO
	return Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-0.5, 0.5), _rng.randf_range(-1, 1)) * _shake


## Ages the pooled effects (also during hit stop, so the impact frame keeps glowing).
func animate(delta: float) -> void:
	for s in _slashes:
		if s.life < 1.0 or (s.node as Node3D).visible:
			_age(s, delta)
			(s.mat as ShaderMaterial).set_shader_parameter(&"t", s.life)
	for r in _rings:
		if (r.node as Node3D).visible:
			_age(r, delta)
			var k: float = 1.0 - pow(1.0 - r.life, 3.0)
			(r.node as Node3D).scale = Vector3.ONE * r.size * lerpf(0.3, 1.0, k)
			(r.mat as ShaderMaterial).set_shader_parameter(&"life", r.life)
	for b in _beams:
		if (b.node as Node3D).visible:
			_age(b, delta)
			var mi: Node3D = b.node
			mi.scale.x = b.size * (1.0 - b.life * 0.6)
			mi.scale.z = mi.scale.x
			(b.mat as ShaderMaterial).set_shader_parameter(&"life", b.life)
	for n in _numbers:
		var l: Label = n.label
		if not l.visible:
			continue
		n.life += delta
		if n.life > 0.75 or camera == null:
			l.visible = false
			continue
		var p: Vector3 = n.pos + Vector3(0, n.life * 1.6, 0)
		if camera.is_position_behind(p):
			l.visible = false
			continue
		var sp := camera.unproject_position(p)
		var pop := 1.0 + maxf(0.0, 0.12 - n.life) * 4.0
		l.scale = Vector2.ONE * pop
		l.position = sp - l.size * 0.5 * pop
		l.modulate.a = 1.0 - smoothstep(0.45, 0.75, n.life)


func _age(e: Dictionary, delta: float) -> void:
	e.life = minf(1.0, e.life + delta / maxf(e.time, 0.01))
	if e.life >= 1.0:
		(e.node as Node3D).visible = false


func _take(pool: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = pool[0]
	for e in pool:
		if not (e.node as Node3D).visible:
			best = e
			break
		if e.life > best.life:
			best = e
	best.life = 0.0
	(best.node as Node3D).visible = true
	return best


func _text(pos: Vector3, text: String, color: Color, size: int) -> void:
	var best: Dictionary = _numbers[0]
	for n in _numbers:
		if not (n.label as Label).visible:
			best = n
			break
		if n.life > best.life:
			best = n
	var l: Label = best.label
	l.text = text
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", color)
	l.visible = true
	l.size = Vector2.ZERO
	l.pivot_offset = l.get_combined_minimum_size() * 0.5
	best.life = 0.0
	best.pos = pos + Vector3(_rng.randf_range(-0.4, 0.4), 0, _rng.randf_range(-0.2, 0.2))
	if camera and not camera.is_position_behind(best.pos):
		l.position = camera.unproject_position(best.pos) - l.get_combined_minimum_size() * 0.5
	else:
		l.visible = false


## Ring sector mesh: UV.x along the swing, UV.y from the inner to the outer edge. Cached by size.
func _arc(reach: float, width_deg: float) -> ArrayMesh:
	var key := Vector2i(roundi(reach * 10.0), roundi(width_deg))
	if _arc_meshes.has(key):
		return _arc_meshes[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 24
	var half := deg_to_rad(minf(width_deg, 359.0)) * 0.5
	var inner := reach * 0.35
	for i in seg:
		var a0 := -half + 2.0 * half * i / seg
		var a1 := -half + 2.0 * half * (i + 1) / seg
		var u0 := float(i) / seg
		var u1 := float(i + 1) / seg
		var p := [Vector3(sin(a0) * inner, 0, cos(a0) * inner), Vector3(sin(a0) * reach, 0, cos(a0) * reach),
			Vector3(sin(a1) * inner, 0, cos(a1) * inner), Vector3(sin(a1) * reach, 0, cos(a1) * reach)]
		var uv := [Vector2(u0, 0), Vector2(u0, 1), Vector2(u1, 0), Vector2(u1, 1)]
		for k: int in [0, 1, 2, 2, 1, 3]:
			st.set_uv(uv[k])
			st.add_vertex(p[k])
	var mesh := st.commit()
	_arc_meshes[key] = mesh
	return mesh
