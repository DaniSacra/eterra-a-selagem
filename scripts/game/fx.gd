class_name Fx
extends Node3D
## Everything that only shows: particle bursts, sword arcs, thrusts, cuts, motes, shockwaves, pillars of light, damage numbers,
## camera shake, hit stop and the full screen colour split. Pooled; nothing here changes the game.

const SLASH := preload("res://assets/shaders/slash.gdshader")
## Morvath's scythe and the wake of his dash and of his crescents (cycle 9): each drawn only over what it hurts.
const BOSS_SCYTHE := preload("res://assets/shaders/boss_scythe.gdshader")
const WAKE := preload("res://assets/shaders/boss_wake.gdshader")
const BOSS_POOL := 3
## The scythe's sector starts this share of its reach out from his middle (his own body covers the rest).
const BOSS_SCYTHE_INNER := 0.1
const INK := preload("res://assets/shaders/slash_ink.gdshader")
const RING := preload("res://assets/shaders/ring.gdshader")
const BEAM := preload("res://assets/shaders/beam.gdshader")
const IMPACT := preload("res://assets/shaders/impact.gdshader")
const IMPACT_POOL := 40
const THRUST := preload("res://assets/shaders/emeth_thrust.gdshader")
const THRUST_POOL := 4
## Motes: the specks of magic a swing sheds and the chips of a blow landing, all in one MultiMesh.
const MOTE_POOL := 192
const MOTE_GRAVITY := 5.0
const MOTE_DRAG := 3.5
## Old gold, lit: one mote in MOTE_GOLD_EVERY (the veins of the blade).
const OLD_GOLD := Color(0.95, 0.72, 0.3)
const MOTE_GOLD_EVERY := 4
## How bright a mote is (times its colour): small, so it may pass the glow threshold.
const MOTE_GLOW := 2.2
## The blade's pulse on a swing: seconds it takes to fall back (EmethSword.PULSE_GLOW at its top).
const BLADE_PULSE := 0.15
const GLINT := preload("res://assets/shaders/glint.gdshader")
const CRESCENT := preload("res://assets/shaders/crescent.gdshader")
const GLINT_POOL := 4
## Meters across the quad of a finisher's glint (its long streak reaches the edges).
const GLINT_SIZE := 13.0
## Seconds the glint takes to burst and fade after its hold.
const GLINT_BURST := 0.16
const CRESCENT_POOL := 6
## A finisher's crescent flies out to this many times the reach of the blow while it fades.
const CRESCENT_GROW := 1.3
## Seconds it lasts (the light edge goes in the first half, the ink lingers).
const CRESCENT_TIME := 0.3
## Where its band starts, as a share of the reach (lower is a broader sweep): a thin blade of a wave, under a
## meter across when it has flown out.
const CRESCENT_INNER := 0.87
## The longest reach it is drawn with: the wave of a long thrust stays a crescent at the paladin, not across the room.
const CRESCENT_MAX_REACH := 5.5
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
## The ribbon's tail behind the head of the swing: at most this share of the arc, and at most this many degrees
## (a spin all around keeps a blade of light, not a full disc).
const SLASH_TAIL := 0.6
const SLASH_TAIL_DEGREES := 120.0
const RING_POOL := 16
const BEAM_POOL := 24
const NUMBER_POOL := 32
## Damage numbers and floating words: font sizes in pixels at 720 lines (small and white, as in the references)
## and the dark outline around them.
const NUMBER_SIZE := 17
const NUMBER_BIG := 24
const WORD_SIZE := 21
const NUMBER_OUTLINE := 5
## Meters across the crossed cuts of Fx.impact (times the size asked for).
const IMPACT_SIZE := 1.0
## A damage number starts this far above the point asked for (the top of the enemy's head): clear of the life bar
## that sits there (CrowdRenderer.BAR_ABOVE), a quarter of a meter above it.
const NUMBER_LIFT := 1.0
## Which numbers show is NumberTally's: one per target that counts up while the hits keep coming, at most
## NUMBER_CROWD within NUMBER_CROWD_RADIUS meters and NumberTally.MAX_SHOWN on screen; finishers never hidden.
const NUMBER_CROWD := NumberTally.CROWD
const NUMBER_CROWD_RADIUS := NumberTally.CROWD_RADIUS
## What may start in one frame (FxBudget): chips and motes, cuts on the struck, particle bursts. Past it, nothing
## more is drawn that frame (a swing through a pack piled cuts, chips and numbers on the paladin).
const BUDGET_MOTES := 40
const BUDGET_GASHES := 8
const BUDGET_BURSTS := 6
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
	# a boss's souls and necromancy: a cold, pale green smoke that rises slowly (never Emeth's crystal green)
	&"soul": [Color(0.38, 1.55, 1.1), 14, 2.2, 2.2, 0.5, 0.9, 80.0],
	# a curse: dark purple wisps
	&"curse": [Color(0.55, 0.15, 0.8), 10, 1.6, 1.2, 0.35, 0.7, 90.0],
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
var _thrusts: Array[Dictionary] = []
var _motes: MultiMesh
var _mote_n := 0
var _mote_pos := PackedVector3Array()
var _mote_vel := PackedVector3Array()
var _mote_life := PackedFloat32Array()
var _mote_time := PackedFloat32Array()
var _mote_size := PackedFloat32Array()
var _mote_color := PackedColorArray()
## The motes' MultiMesh buffer (12 floats of transform, 4 of colour each), sent in one call a frame.
var _mote_buf := PackedFloat32Array()
var _blade: ShaderMaterial
var _blade_looked := false
var _pulse := 0.0
var _glints: Array[Dictionary] = []
var _crescents: Array[Dictionary] = []
var _kick := Vector3.ZERO
var _rings: Array[Dictionary] = []
var _beams: Array[Dictionary] = []
## One label per entry of the tally.
var _labels: Array[Label] = []
var _tally := NumberTally.new(NUMBER_POOL)
## The paladin's head in the world (Player sets it each frame): no number stands within NumberTally.HERO_CLEAR of it.
var hero_head := Vector3.INF
var budget := FxBudget.new({&"motes": BUDGET_MOTES, &"gashes": BUDGET_GASHES, &"bursts": BUDGET_BURSTS})
var _font: Font
var _arc_meshes: Dictionary = {}
var _boss_scythes: Array[Dictionary] = []
var _boss_wakes: Array[Dictionary] = []
## Seconds the blade's light is held up (the ending: Emeth answers).
var _blade_hold := 0.0
static var _strip_mesh: ArrayMesh
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
		(e.node as MeshInstance3D).extra_cull_margin = 3.0
		_impacts.append(e)
	var strip := PlaneMesh.new()
	strip.size = Vector2.ONE
	for i in THRUST_POOL:
		var e := _effect_node(THRUST, strip)
		(e.mat as ShaderMaterial).render_priority = 1
		_thrusts.append(e)
	_build_motes()
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
	for i in BOSS_POOL:
		var e := _effect_node(BOSS_SCYTHE, null)
		(e.mat as ShaderMaterial).render_priority = 1
		_boss_scythes.append(e)
		var w := _effect_node(WAKE, strip())
		(w.mat as ShaderMaterial).render_priority = 1
		_boss_wakes.append(w)
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
		_labels.append(l)


func _build_motes() -> void:
	_motes = MultiMesh.new()
	_motes.transform_format = MultiMesh.TRANSFORM_3D
	_motes.use_colors = true
	var dot := quad(1.0, Color.WHITE)
	var mat: StandardMaterial3D = dot.material
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true
	_motes.mesh = dot
	_motes.instance_count = MOTE_POOL
	_motes.visible_instance_count = 0
	_mote_pos.resize(MOTE_POOL)
	_mote_vel.resize(MOTE_POOL)
	_mote_life.resize(MOTE_POOL)
	_mote_time.resize(MOTE_POOL)
	_mote_size.resize(MOTE_POOL)
	_mote_color.resize(MOTE_POOL)
	_mote_buf.resize(MOTE_POOL * 16)
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = _motes
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# the motes fly anywhere in the room: never culled by the box of the first ones
	mmi.custom_aabb = AABB(Vector3(-60, -5, -60), Vector3(120, 30, 120))
	add_child(mmi)


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
	if list.is_empty() or not budget.allows(&"bursts"):
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
	(s.mat as ShaderMaterial).set_shader_parameter(&"tail", minf(SLASH_TAIL, SLASH_TAIL_DEGREES / maxf(width_deg, 1.0)))
	(ink.mat as ShaderMaterial).set_shader_parameter(&"sweep", sweep / feel.ink_life)
	(ink.mat as ShaderMaterial).set_shader_parameter(&"opacity", feel.ink_opacity if ink_under else 0.0)


func _place_arc(e: Dictionary, mesh: Mesh, origin: Vector2, dir: Vector2, height: float, tilt: float) -> void:
	var mi: MeshInstance3D = e.node
	mi.mesh = mesh
	mi.position = Vector3(origin.x, height, origin.y)
	mi.rotation = Vector3(tilt, atan2(dir.x, dir.y), 0.0)


## The cut a blow leaves on whoever it lands on: a short streak of length meters along axis (the way the blade was
## moving there), a pale core in the blow's colour. cross: a second, thinner streak across it (a heavy blow).
func gash(pos: Vector3, axis: Vector3, color: Color, length: float = 1.2, cross: bool = false, time: float = 0.15) -> void:
	if not budget.allows(&"gashes"):
		return
	var e: Dictionary = _take(_impacts)
	(e.node as Node3D).position = pos
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"axis", axis.normalized() if axis.length_squared() > 0.0001 else Vector3.RIGHT)
	mat.set_shader_parameter(&"size", length)
	mat.set_shader_parameter(&"cross_cut", 1.0 if cross else 0.0)
	mat.set_shader_parameter(&"life", 0.0)
	e.time = time


## A burst where something breaks (armor): two crossed cuts, upright. size 1 is IMPACT_SIZE meters across.
func impact(pos: Vector3, color: Color, size: float = 1.0, time: float = -1.0) -> void:
	gash(pos, Vector3(_rng.randf_range(-0.4, 0.4), 1.0, 0.0), color, IMPACT_SIZE * size, true, time if time > 0.0 else 0.18)


## A thrust: a thin beam from origin along dir, reach meters long and width meters across at its widest (what the
## blow reaches), tapering to a point. omega: the held thrust (a broader, paler thread with the gold veins of Emeth).
func thrust(origin: Vector2, dir: Vector2, reach: float, width: float, color: Color, time: float = 0.2, height: float = 0.9, omega: bool = false) -> void:
	var e: Dictionary = _take(_thrusts)
	var mi: MeshInstance3D = e.node
	var mid := origin + dir * reach * 0.5
	mi.position = Vector3(mid.x, height, mid.y)
	mi.rotation = Vector3(0.0, atan2(dir.x, dir.y), 0.0)
	mi.scale = Vector3(width, 1.0, reach)
	e.time = time
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"intensity", Feel.live().slash_intensity)
	mat.set_shader_parameter(&"omega", 1.0 if omega else 0.0)


## Small specks flying from pos along dir (meters per second at most; a third of that at least) within spread
## radians of it: the magic a swing sheds, the chips of a blow landing. size in meters, life in
## seconds, both at most. gold_every: one in so many is old gold instead of color (0: none).
func chips(pos: Vector3, dir: Vector3, color: Color, count: int, speed: float = 6.0, size: float = 0.1, life: float = 0.35, spread: float = 0.6, gold_every: int = 0) -> void:
	var lit := Color(color.r * MOTE_GLOW, color.g * MOTE_GLOW, color.b * MOTE_GLOW)
	var forward := dir.normalized() if dir.length_squared() > 0.0001 else Vector3.UP
	var side := forward.cross(Vector3.UP)
	side = side.normalized() if side.length_squared() > 0.0001 else Vector3.RIGHT
	var up := side.cross(forward)
	for i in budget.take(&"motes", count):
		if _mote_n >= MOTE_POOL:
			return
		var k := _mote_n
		_mote_n += 1
		var a := _rng.randf_range(-spread, spread)
		var b := _rng.randf_range(-spread, spread) * 0.6
		_mote_pos[k] = pos
		_mote_vel[k] = (forward + side * tan(a) + up * tan(b)).normalized() * speed * _rng.randf_range(0.35, 1.0)
		_mote_life[k] = 0.0
		_mote_time[k] = life * _rng.randf_range(0.6, 1.0)
		_mote_size[k] = size * _rng.randf_range(0.75, 1.0)
		_mote_color[k] = OLD_GOLD if gold_every > 0 and i % gold_every == gold_every - 1 else lit


## The blade answers a swing: its light rises for an instant (never a light on the room).
func blade_pulse() -> void:
	_pulse = 1.0


## How many effects of a kind are on screen now (tests: nothing shows without a real hit).
func showing(kind: StringName) -> int:
	match kind:
		&"motes":
			return _mote_n
		&"numbers":
			var shown := 0
			for l in _labels:
				if l.visible:
					shown += 1
			return shown
	var pools := {&"gashes": _impacts, &"slashes": _slashes, &"thrusts": _thrusts, &"crescents": _crescents, &"rings": _rings, &"glints": _glints,
		&"boss_scythes": _boss_scythes, &"boss_wakes": _boss_wakes}
	var count := 0
	for e: Dictionary in pools.get(kind, []):
		if (e.node as Node3D).visible:
			count += 1
	return count


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
	_place_arc(e, _arc(minf(reach, CRESCENT_MAX_REACH), width_deg, CRESCENT_INNER), origin, dir, height, 0.0)
	(e.node as Node3D).scale = Vector3.ONE
	e.time = CRESCENT_TIME
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"ink_opacity", Feel.live().ink_opacity * CRESCENT_INK)


## Morvath's Sepulchral Scythe: the blade crosses the half circle from origin along dir (reach m, degrees wide) in
## sweep seconds, its trail and ashes last until `life`. body: the violet of the trail, edge: the blade and the reach.
## Drawn flat on the floor, exactly over the sector the blow hurts.
func boss_scythe(origin: Vector2, dir: Vector2, reach: float, degrees: float, sweep: float, life: float, body: Color, edge: Color) -> void:
	var e: Dictionary = _take(_boss_scythes)
	_place_arc(e, _arc(reach, degrees, BOSS_SCYTHE_INNER), origin, dir, 0.08, 0.0)
	e.time = life
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"sweep", clampf(sweep / maxf(life, 0.01), 0.05, 0.95))
	mat.set_shader_parameter(&"flip", _rng.randf() < 0.5)
	mat.set_shader_parameter(&"body", body)
	mat.set_shader_parameter(&"edge", edge)


## Morvath's dash: its lane (from, dir, length, width in m) revealed as he runs it in `run` seconds, breaking into
## ashes until `life`.
func boss_dash(from: Vector2, dir: Vector2, length: float, width: float, run: float, life: float, body: Color, edge: Color) -> void:
	var e: Dictionary = _take(_boss_wakes)
	var mi: MeshInstance3D = e.node
	mi.position = Vector3(from.x, 0.07, from.y)
	mi.rotation = Vector3(0.0, atan2(dir.x, dir.y), 0.0)
	mi.scale = Vector3(width, 1.0, length)
	e.time = life
	var mat: ShaderMaterial = e.mat
	mat.set_shader_parameter(&"t", 0.0)
	mat.set_shader_parameter(&"sweep", clampf(run / maxf(life, 0.01), 0.05, 0.95))
	mat.set_shader_parameter(&"body", body)
	mat.set_shader_parameter(&"edge", edge)


## Emeth's blade holds its light up for `seconds` (the ending), then falls back as after a swing.
func blade_glow(seconds: float) -> void:
	_blade_hold = maxf(_blade_hold, seconds)
	_pulse = 1.0


## A flat strip one meter wide and one long on the floor plane: x across (-0.5 to 0.5), z along (0 to 1); UV.x across,
## UV.y along.
static func strip() -> ArrayMesh:
	if _strip_mesh:
		return _strip_mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var p := [Vector3(-0.5, 0, 0), Vector3(0.5, 0, 0), Vector3(-0.5, 0, 1), Vector3(0.5, 0, 1)]
	var uv := [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
	for k: int in [0, 2, 1, 1, 2, 3]:
		st.set_uv(uv[k])
		st.add_vertex(p[k])
	_strip_mesh = st.commit()
	return _strip_mesh


## One or two frames of the whole screen in flat black and white: only for the biggest blows.
## Off with the screen shake option (fx.shake_scale 0), so it can be turned off for comfort.
func impact_frame() -> void:
	if shake_scale > 0.0:
		frame_left = maxf(frame_left, Feel.live().impact_frame)


## The camera jolts along a blow (dir on the floor plane).
func kick(dir: Vector2, amount: float) -> void:
	_kick += Vector3(dir.x, 0, dir.y) * KICK_METERS * amount * shake_scale * Feel.live().kick_scale


## A flat shockwave growing to radius. thin: only a fine line, nothing inside it.
func ring(center: Vector2, radius: float, color: Color, time: float = 0.35, height: float = 0.15, thin: bool = false) -> void:
	var r: Dictionary = _take(_rings)
	var mi: MeshInstance3D = r.node
	mi.position = Vector3(center.x, height, center.y)
	r.size = radius
	r.grow = 1.0
	mi.scale = Vector3.ONE * radius * 0.3
	(r.mat as ShaderMaterial).set_shader_parameter(&"color", color)
	(r.mat as ShaderMaterial).set_shader_parameter(&"band", 0.035 if thin else 0.08)
	(r.mat as ShaderMaterial).set_shader_parameter(&"fill", 0.0 if thin else 0.18)
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


## A damage number over pos (the top of whoever took it). key: who took it (an instance id; 0 for none): hits that
## follow each other on the same target join its number, which counts up and pops again (NumberTally).
func number(pos: Vector3, amount: float, color: Color, big: bool = false, key: int = 0) -> void:
	var i := _tally.add(key, pos + Vector3(0, NUMBER_LIFT, 0), amount, color, big, Engine.get_process_frames())
	if i < 0:
		return
	var e := _tally.entries[i]
	if not _tally.merged:
		e.pos += _jitter()
	_show_label(i, str(roundi(e.amount)), e.color, NUMBER_BIG if e.big else (NumberTally.GROUP_SIZE if e.group else NUMBER_SIZE))


func word(pos: Vector3, text: String, color: Color) -> void:
	var i := _tally.add_word(pos + _jitter(), color)
	_show_label(i, text, color, WORD_SIZE)


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


## Ages the pooled effects (also during hit stop, so the impact frame keeps glowing). A new frame: the budget of
## what may start is whole again.
func animate(delta: float) -> void:
	budget.reset()
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
	for list: Array[Dictionary] in [_thrusts, _boss_scythes, _boss_wakes]:
		for s in list:
			if (s.node as Node3D).visible:
				_age(s, delta)
				(s.mat as ShaderMaterial).set_shader_parameter(&"t", s.life)
	_animate_motes(delta)
	_animate_blade(delta)
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
	if freeze_t >= 0.0:
		for e in _tally.entries:
			e.life = 0.2
	else:
		_tally.age(delta)
	for i in _labels.size():
		var l := _labels[i]
		var e := _tally.entries[i]
		if not e.shown or camera == null:
			l.visible = false
			continue
		if not l.visible:
			continue
		var p: Vector3 = e.pos + Vector3(0, e.life * 1.6, 0)
		if camera.is_position_behind(p):
			l.visible = false
			_tally.hide(i)
			continue
		var sp := camera.unproject_position(p)
		if hero_head.is_finite() and not camera.is_position_behind(hero_head):
			sp = NumberTally.clear_of(sp, camera.unproject_position(hero_head), NumberTally.HERO_CLEAR + l.size.y * 0.5)
		var pop := 1.0 + maxf(0.0, 0.12 - e.life) * 4.0
		l.scale = Vector2.ONE * pop
		l.position = sp - l.size * 0.5 * pop
		l.modulate.a = 1.0 - smoothstep(0.45, NumberTally.LIFE, e.life)


func _animate_motes(delta: float) -> void:
	if _mote_n == 0:
		if _motes.visible_instance_count != 0:
			_motes.visible_instance_count = 0
		return
	var i := 0
	var drag := maxf(0.0, 1.0 - MOTE_DRAG * delta)
	while i < _mote_n:
		var life := _mote_life[i] + delta / _mote_time[i]
		if life >= 1.0:
			# the last one takes its place
			_mote_n -= 1
			_mote_pos[i] = _mote_pos[_mote_n]
			_mote_vel[i] = _mote_vel[_mote_n]
			_mote_life[i] = _mote_life[_mote_n]
			_mote_time[i] = _mote_time[_mote_n]
			_mote_size[i] = _mote_size[_mote_n]
			_mote_color[i] = _mote_color[_mote_n]
			continue
		_mote_life[i] = life
		var vel := _mote_vel[i] * drag - Vector3(0, MOTE_GRAVITY * delta, 0)
		_mote_vel[i] = vel
		_mote_pos[i] += vel * delta
		var fade := 1.0 - life * life
		# a billboard scaled evenly where it is, and its colour fading (what set_instance_transform and
		# set_instance_color would store, written into the buffer)
		var s := Vector3.ONE * _mote_size[i] * (0.7 + 0.3 * fade)
		var at := _mote_pos[i]
		var c := _mote_color[i] * fade
		var o := i * 16
		var d := _mote_buf
		d[o] = s.x; d[o + 1] = 0.0; d[o + 2] = 0.0; d[o + 3] = at.x
		d[o + 4] = 0.0; d[o + 5] = s.y; d[o + 6] = 0.0; d[o + 7] = at.y
		d[o + 8] = 0.0; d[o + 9] = 0.0; d[o + 10] = s.z; d[o + 11] = at.z
		d[o + 12] = c.r; d[o + 13] = c.g; d[o + 14] = c.b; d[o + 15] = c.a
		i += 1
	if _mote_n > 0:
		_motes.buffer = _mote_buf
	_motes.visible_instance_count = _mote_n


## The pulse of the blade falls back to its still light. The blade is looked for once: the sword EmethSword made
## that lives in this game (the title screen has one of its own).
func _animate_blade(delta: float) -> void:
	if _pulse <= 0.0:
		return
	if _blade_hold > 0.0:
		_blade_hold -= delta
	else:
		_pulse = maxf(0.0, _pulse - delta / BLADE_PULSE)
	if not _blade_looked:
		_blade_looked = true
		_blade = EmethSword.blade_of(get_parent())
	if _blade:
		EmethSword.set_pulse(_blade, _pulse)


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


## The label of tally entry i shows text; the labels of entries the tally let go are hidden.
func _show_label(i: int, text: String, color: Color, size: int) -> void:
	for k in _labels.size():
		if not _tally.entries[k].shown:
			_labels[k].visible = false
	var l := _labels[i]
	l.text = text
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", color)
	l.visible = true
	l.size = Vector2.ZERO
	l.pivot_offset = l.get_combined_minimum_size() * 0.5
	var at := _tally.entries[i].pos
	if camera and not camera.is_position_behind(at):
		l.position = camera.unproject_position(at) - l.get_combined_minimum_size() * 0.5
	else:
		l.visible = false
		_tally.hide(i)


func _jitter() -> Vector3:
	return Vector3(_rng.randf_range(-0.4, 0.4), 0, _rng.randf_range(-0.2, 0.2))


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
