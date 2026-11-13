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

var stop_left := 0.0
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
