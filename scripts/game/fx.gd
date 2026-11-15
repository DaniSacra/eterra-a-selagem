class_name Fx
extends Node3D
## Everything that only shows: particle bursts, sword arcs, shockwaves, pillars of light, damage numbers,
## camera shake, hit stop and the full screen colour split. Pooled; nothing here changes the game.

const SLASH := preload("res://assets/shaders/slash.gdshader")
const INK := preload("res://assets/shaders/slash_ink.gdshader")
const RING := preload("res://assets/shaders/ring.gdshader")
const BEAM := preload("res://assets/shaders/beam.gdshader")
const IMPACT := preload("res://assets/shaders/impact.gdshader")
const IMPACT_POOL := 40
const GLINT := preload("res://assets/shaders/glint.gdshader")
const CRESCENT := preload("res://assets/shaders/crescent.gdshader")
const GLINT_POOL := 4
## Meters across the quad of a finisher's glint (its long streak reaches the edges).
const GLINT_SIZE := 13.0
## Seconds the glint takes to burst and fade after its hold.
const GLINT_BURST := 0.16
const CRESCENT_POOL := 6
## A finisher's crescent flies out to this many times the reach of the blow while it fades.
const CRESCENT_GROW := 1.8
## Seconds it lasts (the white edge goes in the first half, the ink lingers).
const CRESCENT_TIME := 0.42
## Where its band starts, as a share of the reach (lower is a broader sweep).
const CRESCENT_INNER := 0.72
## Share of the ink opacity (Feel.ink_opacity) its dark body keeps: lighter than a blow, so the white edge leads.
const CRESCENT_INK := 0.28
const KICK_METERS := 0.35
const GOLD := Color(1.0, 0.82, 0.38)
const SLASH_POOL := 18
## Where the ink of a sword arc starts, as a share of its reach (lower is a fatter crescent of ink).
const INK_INNER := 0.42
## Where the bright streaks start, as a share of the reach: a wide band from near the paladin out to the tip
## (Ember & Blade's cuts are sheets of light, not thin lines; a narrower band since the first test found them too big).
const SLASH_INNER := 0.5
const RING_POOL := 16
const BEAM_POOL := 24
const NUMBER_POOL := 90
## Damage numbers and floating words: font sizes in pixels at 720 lines (small and white, as in the references)
## and the dark outline around them.
const NUMBER_SIZE := 17
const NUMBER_BIG := 24
const WORD_SIZE := 21
const NUMBER_OUTLINE := 5
## Size of the star of a blow landing, in meters (times the size asked for).
const IMPACT_SIZE := 1.6
## Particle bursts are drawn this much smaller than their BURSTS size, with this share of their specks.
const BURST_SCALE := 0.7
const BURST_AMOUNT := 0.7
const SHAKE_METERS := 0.12

## kind -> [colour, amount, speed, gravity, size, lifetime, spread]
const BURSTS := {
	&"spark": [Color(2.6, 2.2, 1.4), 10, 9.0, -6.0, 0.16, 0.28, 50.0],
	&"bone": [Color(1.4, 1.35, 1.2), 9, 5.5, -16.0, 0.22, 0.7, 70.0],
	&"fire": [Color(3.0, 1.2, 0.3), 16, 4.0, 3.0, 0.42, 0.55, 80.0],
	&"frost": [Color(1.2, 2.2, 3.2), 14, 6.0, -5.0, 0.26, 0.5, 80.0],
	&"light": [Color(3.0, 2.5, 1.2), 18, 4.0, 2.0, 0.3, 0.7, 90.0],
	&"shadow": [Color(0.75, 0.52, 1.3), 16, 3.0, 1.5, 0.55, 0.8, 90.0],
	&"dust": [Color(0.5, 0.45, 0.42), 10, 2.5, 0.5, 0.6, 0.6, 70.0],
	&"heal": [Color(0.8, 2.6, 1.2), 16, 2.5, 2.5, 0.3, 0.8, 90.0],
}

var camera: Camera3D
## Where damage numbers are drawn (a Control over the 3D view).
var overlay: Control
var stop_left := 0.0
## Strength of the colour split on screen (0..1), read by the screen pass.
var split := 0.0
## Seconds left of the impact frame (the screen in flat black and white), read by the screen pass.
var frame_left := 0.0
var shake_scale := 1.0
## When >= 0, sword arcs hold at this point of their life (the --lab still).
var freeze_t := -1.0
## The moment of slow motion now playing (Hades II slows the whole world on the last kill of a fight and on the
## biggest blows): how much the camera closes in (1 = not at all) and the radial blur and bloom of the screen pass (0..1).
var zoom := 1.0
var radial := 0.0
var _slow_on := false
var _slow_fraction := 1.0
var _slow_in := 0.05
var _slow_hold := 0.0
var _slow_out := 0.3
var _slow_zoom := 1.0
var _slow_blur := 0.0
var _slow_t := 0.0
var _shake := 0.0
var _pools: Dictionary = {}
var _next: Dictionary = {}
var _slashes: Array[Dictionary] = []
var _inks: Array[Dictionary] = []
var _impacts: Array[Dictionary] = []
var _glints: Array[Dictionary] = []
var _crescents: Array[Dictionary] = []
var _kick := Vector3.ZERO
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
	Dev.seed_rng(_rng, 6)
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
			p.amount = maxi(3, roundi(spec[1] * BURST_AMOUNT))
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
			p.mesh = quad(spec[4] * BURST_SCALE, spec[0])
			p.color_ramp = fade_ramp(Color.WHITE)
			p.local_coords = false
			add_child(p)
			list.append(p)
		_pools[kind] = list
		_next[kind] = 0
	for i in SLASH_POOL:
		_inks.append(_effect_node(INK, null))
		_slashes.append(_effect_node(SLASH, null))
	for e in _inks:
		(e.mat as ShaderMaterial).render_priority = -1
	for e in _slashes:
		(e.mat as ShaderMaterial).render_priority = 1
	var q := QuadMesh.new()
	q.size = Vector2.ONE
	for i in IMPACT_POOL:
		var e := _effect_node(IMPACT, q)
		(e.node as MeshInstance3D).sorting_offset = 10.0
		_impacts.append(e)
	var gq := QuadMesh.new()
	gq.size = Vector2.ONE
	for i in GLINT_POOL:
		var e := _effect_node(GLINT, gq)
		(e.node as MeshInstance3D).sorting_offset = 12.0
		_glints.append(e)
	for i in CRESCENT_POOL:
		var e := _effect_node(CRESCENT, null)
		(e.mat as ShaderMaterial).render_priority = 2
		_crescents.append(e)
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
		l.add_theme_constant_override(&"outline_size", NUMBER_OUTLINE)
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
	return {"node": mi, "mat": mat, "life": 1.0, "time": 1.0, "grow": 0.0, "size": 1.0, "follow": null}


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
## ink: lay the dark half-moon under the cut.
func slash(origin: Vector2, dir: Vector2, reach: float, width_deg: float, color: Color, time: float = 0.2, flip: bool = false, height: float = 0.9, ink_under: bool = true) -> void:
	var tilt := _rng.randf_range(-0.08, 0.08)
	var s: Dictionary = _take(_slashes)
	var ink: Dictionary = _take(_inks)
	_place_arc(s, _arc(reach, width_deg, SLASH_INNER), origin, dir, height, tilt)
	_place_arc(ink, _arc(reach, width_deg, INK_INNER), origin, dir, height - 0.05, tilt)
	s.time = time
	var feel := Feel.live()
	ink.time = time * feel.ink_life
	var sweep := clampf(feel.slash_sweep_time / time, 0.25, 0.7)
	for e: Dictionary in [s, ink]:
		var mat: ShaderMaterial = e.mat
		mat.set_shader_parameter(&"flip", flip)
		mat.set_shader_parameter(&"t", 0.0)
	(s.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	(s.mat as ShaderMaterial).set_shader_parameter(&"sweep", sweep)
	(s.mat as ShaderMaterial).set_shader_parameter(&"intensity", feel.slash_intensity)
	(ink.mat as ShaderMaterial).set_shader_parameter(&"sweep", sweep / feel.ink_life)
	(ink.mat as ShaderMaterial).set_shader_parameter(&"opacity", feel.ink_opacity if ink_under else 0.0)


func _place_arc(e: Dictionary, mesh: Mesh, origin: Vector2, dir: Vector2, height: float, tilt: float) -> void:
	var mi: MeshInstance3D = e.node
	mi.mesh = mesh
	mi.position = Vector3(origin.x, height, origin.y)
	mi.rotation = Vector3(tilt, atan2(dir.x, dir.y), 0.0)


## The star of a blow landing on someone. time: seconds it lasts (by default, quicker for smaller stars).
func impact(pos: Vector3, color: Color, size: float = 1.0, time: float = -1.0) -> void:
	var e: Dictionary = _take(_impacts)
	(e.node as Node3D).position = pos
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"seed", _rng.randf() * 100.0)
	mat.set_shader_parameter(&"size", IMPACT_SIZE * size)
	mat.set_shader_parameter(&"life", 0.0)
	e.time = time if time > 0.0 else 0.16 + 0.04 * size


## A finisher gathering light on the blade: a thin cross, a long streak and a ring that grow for hold seconds,
## then burst (the blow lands at that instant). follow: a node it stays on (the tip of the sword), else it stays at pos.
func glint(pos: Vector3, color: Color, hold: float, follow: Node3D = null) -> void:
	var e: Dictionary = _take(_glints)
	e.follow = follow
	(e.node as Node3D).position = follow.global_position if follow else pos
	e.time = hold + GLINT_BURST
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"size", GLINT_SIZE)
	mat.set_shader_parameter(&"hold", hold / e.time)
	mat.set_shader_parameter(&"life", 0.0)
	mat.set_shader_parameter(&"streak_angle", _rng.randf_range(0.25, 0.45) * (1.0 if _rng.randf() < 0.5 else -1.0))


## The wave of a finisher: a thin crescent of ink with a white edge that flies far past the blow and fades.
func crescent(origin: Vector2, dir: Vector2, reach: float, width_deg: float, color: Color, height: float = 0.7) -> void:
	var e: Dictionary = _take(_crescents)
	_place_arc(e, _arc(reach, width_deg, CRESCENT_INNER), origin, dir, height, 0.0)
	(e.node as Node3D).scale = Vector3.ONE
	e.time = CRESCENT_TIME
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"ink_opacity", Feel.live().ink_opacity * CRESCENT_INK)


## One or two frames of the whole screen in flat black and white: only for the biggest blows.
## Off with the screen shake option (fx.shake_scale 0), so it can be turned off for comfort.
func impact_frame() -> void:
	if shake_scale > 0.0:
		frame_left = maxf(frame_left, Feel.live().impact_frame)


## The camera jolts along a blow (dir on the floor plane).
func kick(dir: Vector2, amount: float) -> void:
	_kick += Vector3(dir.x, 0, dir.y) * KICK_METERS * amount * shake_scale * Feel.live().kick_scale


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
	_text(pos, str(roundi(amount)), color, NUMBER_BIG if big else NUMBER_SIZE)


func word(pos: Vector3, text: String, color: Color) -> void:
	_text(pos, text, color, WORD_SIZE)


func hit_stop(ms: float) -> void:
	stop_left = maxf(stop_left, ms / 1000.0)


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount * SHAKE_METERS * shake_scale * Feel.live().shake_scale)


func kick_split(amount: float) -> void:
	split = maxf(split, amount)


## Runs every frame, even during hit stop. Returns the camera's shake offset.
func tick(delta: float) -> Vector3:
	_tick_slow(delta / maxf(Engine.time_scale, 0.001))
	stop_left = maxf(0.0, stop_left - delta)
	_shake = maxf(0.0, _shake - delta * (0.6 + _shake * 6.0))
	split = maxf(0.0, split - delta * 3.0)
	frame_left = maxf(0.0, frame_left - delta)
	_kick *= maxf(0.0, 1.0 - delta * 14.0)
	if _shake <= 0.0:
		return _kick
	return _kick + Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-0.5, 0.5), _rng.randf_range(-1, 1)) * _shake


## Slow motion: the world runs at fraction of its speed (eased in over ease_in seconds, held, eased back over
## ease_out), the camera closes in by zoom and the screen blurs toward its middle. A weaker one never cuts a
## stronger one short. Seconds here are real seconds.
func slow_mo(fraction: float, hold: float, ease_out: float, zoom_to: float = 1.0, blur: float = 0.0, ease_in: float = 0.06) -> void:
	if _slow_on and fraction > _slow_fraction:
		return
	_slow_on = true
	_slow_fraction = fraction
	_slow_in = ease_in
	_slow_hold = hold
	_slow_out = ease_out
	_slow_zoom = zoom_to
	_slow_blur = blur
	_slow_t = 0.0


## Back to full speed at once (a menu opens, the run ends).
func end_slow() -> void:
	_slow_on = false
	zoom = 1.0
	radial = 0.0
	Engine.time_scale = 1.0


## How deep in the slow motion we are now (0..1), by real time since it began.
static func slow_strength(t: float, ease_in: float, hold: float, ease_out: float) -> float:
	if t < ease_in:
		return t / maxf(ease_in, 0.001)
	if t < ease_in + hold:
		return 1.0
	return clampf(1.0 - (t - ease_in - hold) / maxf(ease_out, 0.001), 0.0, 1.0)


func _tick_slow(real_dt: float) -> void:
	if not _slow_on:
		return
	_slow_t += real_dt
	if _slow_t >= _slow_in + _slow_hold + _slow_out:
		end_slow()
		return
	var k := slow_strength(_slow_t, _slow_in, _slow_hold, _slow_out)
	Engine.time_scale = lerpf(1.0, _slow_fraction, k)
	zoom = lerpf(1.0, _slow_zoom, k)
	radial = _slow_blur * k


## Ages the pooled effects (also during hit stop, so the impact frame keeps glowing).
func animate(delta: float) -> void:
	for list: Array[Dictionary] in [_slashes, _inks]:
		for s in list:
			if s.life < 1.0 or (s.node as Node3D).visible:
				if freeze_t >= 0.0:
					s.life = freeze_t / (Feel.live().ink_life if list == _inks else 1.0)
				else:
					_age(s, delta)
				(s.mat as ShaderMaterial).set_shader_parameter(&"t", s.life)
	for s in _impacts:
		if (s.node as Node3D).visible:
			_age(s, delta)
			(s.mat as ShaderMaterial).set_shader_parameter(&"life", s.life)
	for g in _glints:
		if (g.node as Node3D).visible:
			if freeze_t >= 0.0:
				g.life = freeze_t
			else:
				_age(g, delta)
			if is_instance_valid(g.follow):
				(g.node as Node3D).position = (g.follow as Node3D).global_position
			(g.mat as ShaderMaterial).set_shader_parameter(&"life", g.life)
	for c in _crescents:
		if (c.node as Node3D).visible:
			if freeze_t >= 0.0:
				c.life = freeze_t
			else:
				_age(c, delta)
			var out: float = 1.0 - pow(1.0 - c.life, 3.0)
			(c.node as Node3D).scale = Vector3.ONE * lerpf(1.0, CRESCENT_GROW, out)
			(c.mat as ShaderMaterial).set_shader_parameter(&"t", c.life)
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
		n.life = 0.2 if freeze_t >= 0.0 else n.life + delta
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


## Ring sector mesh: UV.x along the swing, UV.y from the inner (inner_frac of reach) to the outer edge. Cached by size.
func _arc(reach: float, width_deg: float, inner_frac: float) -> ArrayMesh:
	var key := Vector3i(roundi(reach * 10.0), roundi(width_deg), roundi(inner_frac * 100.0))
	if _arc_meshes.has(key):
		return _arc_meshes[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := maxi(12, ceili(width_deg / 5.0))
	var half := deg_to_rad(minf(width_deg, 359.0)) * 0.5
	var inner := reach * inner_frac
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
