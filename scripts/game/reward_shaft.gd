class_name RewardShaft
extends Node3D
## The light of Elun over what the paladin may take or buy (vfx_pass_spec.md 6, the Daniel's "quando precisa pegar algo,
## cair uma luz em cima"): a faint frustum of light from above the screen down to the reliquary (0.6 m wide at the top,
## 1.25 at the floor, 18 m tall: its top is never seen), a pool on the floor under it (a decal, no real light) and fine
## dust falling in it. It comes down when the room is won and stays until the thing is taken; a shop's items take theirs
## at once, strong where the gold reaches. Ivory warm light pulled toward the reward's own tone (the medallion's enamel,
## the angel of the door for a Blessing; tint_of). Nothing over the paladin: within 2.5 m of its axis it falls to 0.35
## (the pool to 0.6) and it opens round him where it stands in front of him, all in its shaders (reward_shaft,
## reward_pool, reward_dust); it lays its light over what is behind it under a cap a little below the screen's
## (CAP_SHARE), so it never washes the medallion or the paladin. Drawn in real time (the slow motion does not slow it).
##
## Use (rooms.gd, the gameplay side):
##   var shaft := RewardShaft.make(parent, Vector3(x, 0, z), RewardShaft.tint_of(reward, angel_family))
##   shaft.appear()                 # waits WAIT (the end of the last kill's slow motion), comes down, lands
##   shaft.appear(0.0, true)        # a shop: there at once, no wait
##   shaft.set_strength(0.75)       # the shop: SHOP_CAN (0.75) or SHOP_CANNOT (0.3) as the gold changes
##   shaft.take()                   # taken or bought: the light goes up and the node frees itself
## --no-shafts (Dev) makes make() return a shaft that never shows, to compare a capture with and without.

## The light of Elun before the reward's tone, and how much of the tone's saturation it keeps (the hue is the tone's
## own: mixed with ivory in RGB the pomegranate and the Encanto drifted 30 to 48 degrees toward the ivory's 40), never
## past PALE (a light, not a colour).
const IVORY := Color(1.0, 0.94, 0.82)
const TINT := 0.55
const PALE := 0.28
## Each reward's tone (hue in degrees, saturation): its medallion's enamel (RewardGem), so the light and the medallion say
## the same thing. A Blessing takes the tone of the angel of its door (AngelSeal.TINT) or ivory (two angels, the guardian).
const TONE := {
	RunMap.Reward.POM: Vector2(352, 0.5), RunMap.Reward.POM_SLICE: Vector2(352, 0.5),
	RunMap.Reward.HEART: Vector2(6, 0.4), RunMap.Reward.HEAL: Vector2(6, 0.4),
	RunMap.Reward.MAGICK: Vector2(225, 0.5), RunMap.Reward.GOLD: Vector2(40, 0.55),
	RunMap.Reward.SILVER: Vector2(210, 0.1), RunMap.Reward.MEMORY: Vector2(38, 0.3),
	RunMap.Reward.ENCHANT: Vector2(135, 0.4), RunMap.Reward.PSALM: Vector2(40, 0.45),
}
## The fountain's tone.
const FOUNTAIN_TONE := Vector2(196, 0.25)
## C1V (N1, 2.1): in the stylized look the fountain's shaft is the hall's shaft of Elun, ivory gold (hue 40).
const FOUNTAIN_TONE_STYLIZED := Vector2(40, 0.45)
## Strengths: a reward 1.0, a fountain with water 0.8, a shop item the gold reaches 0.75 and one it does not 0.3.
const FOUNTAIN := 0.8
const SHOP_CAN := 0.75
const SHOP_CANNOT := 0.3
## Its cap: this share of ScreenTone.linear_peak of its colour (the body stays near 200 on the screen, under the paladin
## and the medallion).
const CAP_SHARE := 0.85
## The frustum (m) and the pool's radius (m).
const TOP_RADIUS := 0.6
const FOOT_RADIUS := 1.25
const HEIGHT := 18.0
const POOL_RADIUS := 1.7
const POOL_Y := 0.035
## The times (s, real): the wait for the slow motion of the last kill, coming down, landing (the pool opening from
## POOL_FROM with a pulse of PULSE that comes back), the breath (between BREATH and 1 in BREATH_TIME), going up, a
## strength change.
const WAIT := 0.45
const DOWN := 0.35
const LAND := 0.25
const POOL_FROM := 0.6
const PULSE := 1.3
const BREATH := 0.88
const BREATH_TIME := 2.6
const UP := 0.3
const STRENGTH_TIME := 0.25
## The dust: streaks of DUST_SIZE (m) falling at DUST_SPEED (m/s) inside DUST_REACH of the radius, from DUST_TOP (m).
const DUST := 8
const DUST_SIZE := Vector2(0.04, 0.18)
const DUST_SPEED := 0.35
const DUST_REACH := 0.8
const DUST_TOP := 6.0
## The Compatibility renderer shows its light darker (no linear to sRGB on the way out).
const COMPAT_GAIN := 1.6

const SHAFT_SHADER := preload("res://assets/shaders/reward_shaft.gdshader")
const POOL_SHADER := preload("res://assets/shaders/reward_pool.gdshader")
const DUST_SHADER := preload("res://assets/shaders/reward_dust.gdshader")

enum Stage { HIDDEN, WAITING, DOWN, LANDING, HERE, UP }

var stage := Stage.HIDDEN
var color := IVORY
var strength := 1.0
var _target := 1.0
var _t := 0.0
var _breath := 0.0
var _shaft: MeshInstance3D
var _pool: MeshInstance3D
var _dust: MultiMeshInstance3D
var _mats: Array[ShaderMaterial] = []
var _drops: PackedFloat32Array = []
var _rng := RandomNumberGenerator.new()
var _off := false


## A shaft over `at` (its foot on the floor), not shown until appear().
static func make(parent: Node, at: Vector3, tint: Color = IVORY, strength_: float = 1.0) -> RewardShaft:
	var s := RewardShaft.new()
	s.name = "RewardShaft"
	s.color = tint
	s.strength = strength_
	s._target = strength_
	s._off = Dev.has("no-shafts")
	parent.add_child(s)
	s.global_position = at
	return s


## The light for a reward (RunMap.Reward): ivory pulled toward its tone; a Blessing toward its angel's (Boon.Family,
## -1 for none: two angels or the guardian, ivory).
static func tint_of(reward: int, angel_family: int = -1) -> Color:
	if reward == RunMap.Reward.BOON:
		if angel_family < 0 or angel_family >= AngelSeal.TINT.size():
			return IVORY
		var a := AngelSeal.TINT[angel_family]
		return _mix(Vector2(a.h * 360.0, 0.6))
	if TONE.has(reward):
		return _mix(TONE[reward])
	return IVORY


## The fountain's light.
static func fountain_tint() -> Color:
	return _mix(FOUNTAIN_TONE_STYLIZED if VisualProfile.stylized() else FOUNTAIN_TONE)


static func _mix(tone: Vector2) -> Color:
	return Color.from_hsv(tone.x / 360.0, minf(PALE, maxf(tone.y * TINT, IVORY.s * 0.5)), 1.0)


func _ready() -> void:
	_rng.seed = hash(global_position)
	var cap := ScreenTone.linear_peak(color) * CAP_SHARE
	var gain := COMPAT_GAIN if RenderingServer.get_current_rendering_method() == "gl_compatibility" else 1.0
	_shaft = MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = TOP_RADIUS
	c.bottom_radius = FOOT_RADIUS
	c.height = 1.0
	c.radial_segments = 16
	c.rings = 1
	c.cap_top = false
	c.cap_bottom = false
	_shaft.mesh = c
	_shaft.scale = Vector3(1.0, HEIGHT, 1.0)
	_shaft.position.y = HEIGHT * 0.5
	_shaft.material_override = _material(SHAFT_SHADER, cap, gain)
	_shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_shaft)
	_pool = MeshInstance3D.new()
	var p := PlaneMesh.new()
	p.size = Vector2.ONE * POOL_RADIUS * 2.0
	_pool.mesh = p
	_pool.position.y = POOL_Y
	_pool.material_override = _material(POOL_SHADER, cap, gain)
	_pool.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_pool)
	_dust = MultiMeshInstance3D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	var q := QuadMesh.new()
	q.size = DUST_SIZE
	mm.mesh = q
	mm.instance_count = DUST
	_dust.multimesh = mm
	_dust.material_override = _material(DUST_SHADER, cap, gain)
	_dust.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_dust)
	for i in DUST:
		_drops.append(_rng.randf() * DUST_TOP)
		_place_drop(i, true)
	_set_all(&"reveal", 0.0)
	visible = false


func _material(shader: Shader, cap: float, gain: float) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = shader
	m.set_shader_parameter(&"color", color)
	m.set_shader_parameter(&"cap", cap)
	m.set_shader_parameter(&"strength", strength)
	m.set_shader_parameter(&"compat_gain", gain)
	_mats.append(m)
	return m


## Comes down after `wait` seconds (real); `now`: there at once (a shop, the fountain), no descent.
func appear(wait: float = WAIT, now: bool = false) -> void:
	if _off:
		return
	if now:
		stage = Stage.HERE
		visible = true
		_set_all(&"reveal", 1.0)
		_pool_open(1.0, 1.0)
		return
	stage = Stage.WAITING
	_t = -wait


## Taken (or bought): the light goes up, the pool goes out, then the node frees itself.
func take() -> void:
	if stage == Stage.HIDDEN or stage == Stage.WAITING:
		queue_free()
		return
	stage = Stage.UP
	_t = 0.0


## Its strength (eased over STRENGTH_TIME): a shop item the gold reaches or not.
func set_strength(s: float) -> void:
	_target = s


func _process(delta: float) -> void:
	if stage == Stage.HIDDEN:
		return
	var dt := delta / maxf(Engine.time_scale, 0.001)
	_t += dt
	strength = move_toward(strength, _target, dt / STRENGTH_TIME * absf(SHOP_CAN - SHOP_CANNOT))
	var breath := 1.0
	match stage:
		Stage.WAITING:
			if _t >= 0.0:
				stage = Stage.DOWN
				visible = true
		Stage.DOWN:
			var k := clampf(_t / DOWN, 0.0, 1.0)
			_set_all(&"reveal", 1.0 - (1.0 - k) * (1.0 - k))
			_pool_open(0.0, 0.0)
			if k >= 1.0:
				stage = Stage.LANDING
				_t = 0.0
		Stage.LANDING:
			var k := clampf(_t / LAND, 0.0, 1.0)
			_pool_open(lerpf(POOL_FROM, 1.0, k), lerpf(PULSE, 1.0, k) * smoothstep(0.0, 0.3, k))
			breath = lerpf(PULSE, 1.0, k)
			if k >= 1.0:
				stage = Stage.HERE
				_t = 0.0
		Stage.HERE:
			_breath += dt
			breath = lerpf(BREATH, 1.0, 0.5 + 0.5 * cos(TAU * _breath / BREATH_TIME))
		Stage.UP:
			var k := clampf(_t / UP, 0.0, 1.0)
			_set_all(&"lift", k * k)
			_pool_open(1.0, 1.0 - k)
			if k >= 1.0:
				queue_free()
				return
	_set_all(&"strength", strength * breath)
	if stage != Stage.WAITING:
		for i in DUST:
			_drops[i] -= DUST_SPEED * dt
			_place_drop(i, _drops[i] <= 0.0)


func _pool_open(open: float, light: float) -> void:
	var m := _pool.material_override as ShaderMaterial
	m.set_shader_parameter(&"open", maxf(open, 0.001))
	m.set_shader_parameter(&"pool", 0.32 * light)


func _set_all(param: StringName, v: float) -> void:
	for m in _mats:
		m.set_shader_parameter(param, v)


func _place_drop(i: int, fresh: bool) -> void:
	if fresh:
		_drops[i] = DUST_TOP * _rng.randf_range(0.85, 1.0)
	var y := _drops[i]
	var radius := lerpf(FOOT_RADIUS, TOP_RADIUS, y / HEIGHT) * DUST_REACH
	if fresh or _dust.multimesh.get_instance_transform(i).origin == Vector3.ZERO:
		var a := _rng.randf() * TAU
		var r := sqrt(_rng.randf()) * radius
		_dust.multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(cos(a) * r, y, sin(a) * r)))
	else:
		var t := _dust.multimesh.get_instance_transform(i)
		t.origin.y = y
		_dust.multimesh.set_instance_transform(i, t)
	var fade := smoothstep(0.0, 0.6, y) * (1.0 - smoothstep(DUST_TOP * 0.75, DUST_TOP, y))
	_dust.multimesh.set_instance_custom_data(i, Color(0, 0, 0, fade))
