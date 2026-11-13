class_name Fx
extends Node2D
## Impact feel in one place: particle bursts, camera shake, hit stop and (from milestone 2) slashes and numbers.
## Lives on its own canvas layer so effects keep their palette colours instead of the darkness of the crypt.

const POOL := 8
## kind -> tones (family, indexes), amount, life, speed, spread degrees, gravity, size
const KINDS := {
	&"dust": {"family": &"materia", "tones": [5, 6, 7], "amount": 7, "life": 0.35, "speed": 26.0, "spread": 60.0, "gravity": -10.0, "size": 2.0},
	&"spark": {"family": &"luz", "tones": [0, 1, 2], "amount": 8, "life": 0.25, "speed": 70.0, "spread": 40.0, "gravity": 60.0, "size": 1.0},
	&"bone": {"family": &"neve", "tones": [0, 1, 3], "amount": 6, "life": 0.4, "speed": 50.0, "spread": 180.0, "gravity": 140.0, "size": 2.0},
	&"ember": {"family": &"perigo", "tones": [0, 0, 1], "amount": 6, "life": 0.6, "speed": 18.0, "spread": 180.0, "gravity": -40.0, "size": 1.0},
	&"frost": {"family": &"noite", "tones": [0, 0, 1], "amount": 8, "life": 0.5, "speed": 34.0, "spread": 180.0, "gravity": 30.0, "size": 1.0},
	&"light": {"family": &"luz", "tones": [0, 0, 1], "amount": 12, "life": 0.6, "speed": 30.0, "spread": 180.0, "gravity": -50.0, "size": 1.0},
	&"shadow": {"family": &"misterio", "tones": [1, 2, 3], "amount": 10, "life": 0.5, "speed": 36.0, "spread": 180.0, "gravity": -20.0, "size": 2.0},
	&"guard": {"family": &"vida", "tones": [0, 1, 2], "amount": 10, "life": 0.4, "speed": 50.0, "spread": 180.0, "gravity": 0.0, "size": 1.0},
}

const FONT: Font = preload("res://art/fonts/eterra.fnt")
const NUMBER_TIME := 0.55
## Particle kind that matches each colour family.
const FAMILY_BURST := {&"perigo": &"ember", &"noite": &"frost", &"luz": &"light", &"vida": &"guard", &"misterio": &"shadow"}

var stop_left := 0.0
var enemies: EnemySystem
var _numbers: Array[Dictionary] = []
var _shapes: Array[Dictionary] = []
var _clock := 0.0
var _pools: Dictionary = {}
var _next: Dictionary = {}
var _trauma := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	for kind: StringName in KINDS:
		var list: Array[GPUParticles2D] = []
		for i in POOL:
			var p := _make_emitter(KINDS[kind])
			add_child(p)
			list.append(p)
		_pools[kind] = list
		_next[kind] = 0


func _make_emitter(cfg: Dictionary) -> GPUParticles2D:
	var p := GPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = cfg.amount
	p.lifetime = cfg.life
	p.explosiveness = 0.95
	p.local_coords = false
	var m := ParticleProcessMaterial.new()
	m.particle_flag_disable_z = true
	m.spread = cfg.spread
	m.initial_velocity_min = cfg.speed * 0.4
	m.initial_velocity_max = cfg.speed
	m.gravity = Vector3(0, cfg.gravity, 0)
	m.scale_min = cfg.size
	m.scale_max = cfg.size
	m.damping_min = cfg.speed * 0.8
	m.damping_max = cfg.speed * 1.2
	# palette tones in hard steps over the life of the particle, then gone
	var g := Gradient.new()
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var tones: Array = cfg.tones
	var offsets := PackedFloat32Array()
	var colors := PackedColorArray()
	for i in tones.size():
		offsets.append(float(i) / (tones.size() + 0.4))
		colors.append(Palette.c(cfg.family, tones[i]))
	offsets.append(0.94)
	colors.append(Color(colors[colors.size() - 1], 0.0))
	g.offsets = offsets
	g.colors = colors
	var ramp := GradientTexture1D.new()
	ramp.gradient = g
	m.color_ramp = ramp
	p.process_material = m
	return p


## One burst of particles of a kind, optionally thrown in a direction.
func burst(kind: StringName, at: Vector2, dir: Vector2 = Vector2.ZERO) -> void:
	var list: Array = _pools[kind]
	var p: GPUParticles2D = list[_next[kind]]
	_next[kind] = (_next[kind] + 1) % list.size()
	p.position = at
	var m: ParticleProcessMaterial = p.process_material
	m.direction = Vector3(dir.x, dir.y, 0) if dir != Vector2.ZERO else Vector3(0, -1, 0)
	p.restart()


func shake(amount: float) -> void:
	_trauma = maxf(_trauma, amount)


## Freezes the simulation for a few milliseconds: the weight of a hit.
func hit_stop(ms: float) -> void:
	stop_left = maxf(stop_left, ms / 1000.0)


## Real-time update. Returns the camera offset for this frame.
func tick(delta: float) -> Vector2:
	stop_left = maxf(0.0, stop_left - delta)
	_trauma = maxf(0.0, _trauma - delta * 9.0)
	if _trauma <= 0.0 or not Save.option("shake"):
		return Vector2.ZERO
	return Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1)) * _trauma


# ---------- drawn effects: slashes, rings, streaks, damage numbers, stun stars ----------

## A damage number that hops up from a hit.
func number(at: Vector2, amount: float, family: StringName = &"luz") -> void:
	if _numbers.size() > 60:
		_numbers.pop_front()
	_numbers.append({"pos": at + Vector2(_rng.randf_range(-4, 4), 0), "text": str(int(amount)), "t": 0.0, "family": family, "big": amount >= 30.0})


## A floating word (heals, "Escudo!").
func word(at: Vector2, text: String, family: StringName) -> void:
	_numbers.append({"pos": at, "text": text, "t": -0.3, "family": family, "big": false})


## Crescent that sweeps through an arc: the trail of a sword cut.
func slash(at: Vector2, dir: Vector2, reach: float, degrees: float, family: StringName, time: float = 0.16, reverse: bool = false) -> void:
	_shapes.append({"kind": 0, "pos": at, "angle": dir.angle(), "reach": reach, "half": deg_to_rad(degrees) * 0.5, "family": family, "t": 0.0, "time": time, "rev": reverse})


## Ring that opens from the centre: spins, bursts, ground impacts.
func ring(at: Vector2, radius: float, family: StringName, time: float = 0.22) -> void:
	_shapes.append({"kind": 1, "pos": at, "reach": radius, "family": family, "t": 0.0, "time": time})


## Straight flash: thrusts and dashes.
func streak(at: Vector2, dir: Vector2, length: float, width: float, family: StringName, time: float = 0.16) -> void:
	_shapes.append({"kind": 2, "pos": at, "dir": dir, "reach": length, "width": width, "family": family, "t": 0.0, "time": time})


## Called every frame with real time, so effects keep moving during hit stop.
func animate(delta: float) -> void:
	_clock += delta
	for n in _numbers:
		n.t += delta
	for s in _shapes:
		s.t += delta
	_numbers = _numbers.filter(func(n: Dictionary) -> bool: return n.t < NUMBER_TIME)
	_shapes = _shapes.filter(func(s: Dictionary) -> bool: return s.t < s.time)
	queue_redraw()


func _draw() -> void:
	for s in _shapes:
		var k: float = s.t / s.time
		var c0 := Palette.c(s.family, 0)
		var c1 := Palette.c(s.family, 1 if k < 0.6 else 2)
		match s.kind:
			0:
				var a0: float = s.angle - s.half
				var a1: float = s.angle + s.half
				if s.rev:
					var tmp := a0
					a0 = a1
					a1 = tmp
				var head := lerpf(a0, a1, clampf(k * 2.2, 0.0, 1.0))
				var tail := lerpf(a0, a1, clampf(k * 2.2 - 0.9, 0.0, 1.0))
				_crescent(s.pos, s.reach, s.reach * 0.42, tail, head, c1)
				_crescent(s.pos, s.reach, s.reach * 0.16, lerpf(tail, head, 0.3), head, c0)
			1:
				var r: float = s.reach * (0.45 + 0.55 * minf(k * 1.8, 1.0))
				draw_arc(s.pos, r, 0.0, TAU, 28, c1, 4.0 if k < 0.5 else 2.0)
				if k < 0.7:
					draw_arc(s.pos, r + 1.0, 0.0, TAU, 28, c0, 1.0)
			2:
				var from: Vector2 = s.pos + s.dir * s.reach * clampf(k * 1.5 - 0.5, 0.0, 1.0)
				var to: Vector2 = s.pos + s.dir * s.reach * clampf(k * 3.0, 0.0, 1.0)
				draw_line(from, to, c1, maxf(1.0, s.width * 0.5 * (1.0 - k)))
				draw_line(from.lerp(to, 0.3), to, c0, 1.0)
	if enemies:
		var star := Palette.c(&"luz", 1)
		for e in enemies.list:
			if e.stun_t > 0.0:
				for i in 3:
					var a := _clock * 6.0 + i * TAU / 3.0
					var p := e.pos + Vector2(cos(a) * 5.0, -Art.origin(e.def.sprite).y * 0.72 + sin(a) * 2.0)
					draw_rect(Rect2(p.x, p.y, 2, 2), star)
	for n in _numbers:
		if n.t < 0.0:
			continue
		var k: float = n.t / NUMBER_TIME
		var p: Vector2 = n.pos + Vector2(0, -14.0 * sin(minf(k * 1.4, 1.0) * PI * 0.5))
		var size := 22 if n.big else 11
		var w := FONT.get_string_size(n.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		p = (p - Vector2(w * 0.5, 0)).round()
		draw_string(FONT, p + Vector2(1, 1), n.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Palette.c(&"perigo", 4))
		draw_string(FONT, p, n.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Palette.c(n.family, 0 if k < 0.6 else 1))


func _crescent(center: Vector2, radius: float, thick: float, a0: float, a1: float, color: Color) -> void:
	if absf(a1 - a0) < 0.12:
		return
	var steps := 10
	var pts := PackedVector2Array()
	for i in steps + 1:
		pts.append(center + Vector2.from_angle(lerpf(a0, a1, float(i) / steps)) * radius)
	for i in range(steps, -1, -1):
		var f := float(i) / steps
		pts.append(center + Vector2.from_angle(lerpf(a0, a1, f)) * (radius - thick * sin(f * PI) - 0.6))
	draw_colored_polygon(pts, color)
