class_name MagaFx
extends Node3D
## The Maga's spell effects (F7, maga_redesign_v1_pack/03_ARTE_VFX.md): her own pieces, all drawn by assets/shaders/maga_spell.gdshader
## (procedural paint: noise edges, cracked-ice cells, a hot core) from a small pool of cards. Preparation (the glow at the staff
## tip), execution (the fan of trails, the cone, the ball, the frost, the bolt) and dissipation (sparks, mist, embers, melt) per spell.
## Rules it keeps: the cards on the floor are faint (GROUND_ALPHA) and draw before every warning (GROUND_PRIORITY), so no telegraph
## and no enemy is hidden; at most MAX_LIVE cards at once (what does not fit is not drawn); every piece is short.
## Palette: fire amber, ice pale blue and ivory, electricity light gold; never violet, never red.

const SHADER := preload("res://assets/shaders/maga_spell.gdshader")
const MAX_LIVE := 24
const FORM_CONE := 0
const FORM_FROST := 1
const FORM_ARC := 2
const FORM_ORB := 3
const FORM_RING := 4
const FORM_STEAM := 5
const FORM_STREAK := 6
const FORM_CRYSTALS := 7
## The most opacity of a card lying on the floor (a warning under it keeps reading), and its draw order (before the warnings).
const GROUND_ALPHA := 0.6
const GROUND_PRIORITY := -2
const GROUND_Y := 0.07
const AIR_ALPHA := 0.9
const AMBER := Color(1.0, 0.62, 0.2)
const HOT := Color(1.0, 0.96, 0.82)
const ICE := Color(0.55, 0.85, 1.0)
const IVORY := Color(0.96, 0.95, 0.88)
const GOLD := Color(1.0, 0.86, 0.38)
const ORANGE := Color(1.0, 0.5, 0.15)
const STEAM := Color(0.95, 0.97, 1.0)
## The staff tip above the floor, and how far in front of her.
const TIP_HEIGHT := 1.35
const TIP_AHEAD := 0.7

var _cards: Array[Dictionary] = []
var _flat: PlaneMesh
var _quad: QuadMesh
var _frost: Dictionary = {}
var _hold: Dictionary = {}
var _rng := RandomNumberGenerator.new()


static func is_ground(form: int) -> bool:
	return form != FORM_ORB and form != FORM_ARC and form != FORM_STREAK


## The card's most opacity: low for the floor, a bit more for the air.
static func alpha_for(form: int) -> float:
	return GROUND_ALPHA if is_ground(form) else AIR_ALPHA


## Whether one more transient card fits (`live` are drawn now).
static func room_for(live: int) -> bool:
	return live < MAX_LIVE


static func yaw_of(dir: Vector2) -> float:
	return -atan2(dir.y, dir.x)


static func tip_of(pos: Vector2, facing: Vector2) -> Vector3:
	var f := facing.normalized() if facing.length_squared() > 0.0001 else Vector2.RIGHT
	return Vector3(pos.x + f.x * TIP_AHEAD, TIP_HEIGHT, pos.y + f.y * TIP_AHEAD)


func _init() -> void:
	_rng.seed = 2811
	_flat = PlaneMesh.new()
	_flat.size = Vector2.ONE
	_quad = QuadMesh.new()
	_quad.size = Vector2.ONE


## The held-spell glow is built at once and hidden: its shader is in the scene for the warm-up harvest (tools/make_warmup.gd) before the
## first cast compiles it in the middle of a fight.
func _ready() -> void:
	hold_orb(true, Vector2.ZERO, Vector2.RIGHT, 0.0, true)
	hold_orb(false, Vector2.ZERO, Vector2.RIGHT, 0.0, true)


func live() -> int:
	return _cards.size()


func _make(form: int, color: Color, core: Color) -> Dictionary:
	var mi := MeshInstance3D.new()
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter(&"form", form)
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"core", core)
	mat.set_shader_parameter(&"seed", _rng.randf() * 50.0)
	mat.set_shader_parameter(&"alpha_cap", alpha_for(form))
	mat.set_shader_parameter(&"billboard", form == FORM_ORB)
	if is_ground(form):
		mat.render_priority = GROUND_PRIORITY
	mi.material_override = mat
	mi.mesh = _quad if form == FORM_ORB else _flat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return {"node": mi, "mat": mat, "age": 0.0, "life": 0.4, "vel": Vector3.ZERO, "grow": 0.0, "size": Vector3.ONE}


## A transient card, or {} when the pool is full.
func _spawn(form: int, color: Color, core: Color, life: float) -> Dictionary:
	if not room_for(_cards.size()):
		return {}
	var c := _make(form, color, core)
	c.life = life
	_cards.append(c)
	return c


func _place(c: Dictionary, pos: Vector3, yaw: float, size: Vector3) -> void:
	var n: Node3D = c.node
	n.position = pos
	n.rotation = Vector3(0.0, yaw, 0.0)
	n.scale = size
	c.size = size


# ---------- preparation ----------

## The glow at the staff tip: a short flare when a spell is prepared (the Centelha, the Sopro, the Tempestade's trembling).
func tip_flare(pos: Vector2, facing: Vector2, color: Color, size: float = 0.6, life: float = 0.22) -> void:
	var c := _spawn(FORM_ORB, color, HOT, life)
	if c.is_empty():
		return
	_place(c, tip_of(pos, facing), 0.0, Vector3.ONE * size)
	c.grow = 0.5


## The ball growing at the staff tip while a held spell charges (share 0..1); `on` false hides it. One card, reused.
func hold_orb(on: bool, pos: Vector2, facing: Vector2, share: float, fire: bool) -> void:
	if not on:
		if not _hold.is_empty():
			(_hold.node as Node3D).visible = false
		return
	if _hold.is_empty():
		_hold = _make(FORM_ORB, AMBER, HOT)
	var n: Node3D = _hold.node
	n.visible = true
	n.position = tip_of(pos, facing)
	n.scale = Vector3.ONE * (0.3 + 0.9 * share)
	var m: ShaderMaterial = _hold.mat
	m.set_shader_parameter(&"color", AMBER if fire else ICE)
	m.set_shader_parameter(&"core", HOT if fire else IVORY)
	m.set_shader_parameter(&"t", fmod(Time.get_ticks_msec() * 0.001, 1.0))


# ---------- execution ----------

## The Centelha: a tapered trail leaves the tip along each of the fan's rays, a bright head running ahead of a thin tail.
func trails(origin: Vector2, ways: Array[Vector2], speed: float = 14.0, length: float = 2.4) -> void:
	if ways.is_empty():
		return
	for way in ways:
		var c := _spawn(FORM_STREAK, AMBER, HOT, 0.3)
		if c.is_empty():
			return
		var mid := origin + way * (length * 0.5 + 0.4)
		_place(c, Vector3(mid.x, 1.0, mid.y), yaw_of(way), Vector3(length, 1.0, 0.28))
		c.vel = Vector3(way.x, 0.0, way.y) * speed
	spark_burst(origin + ways[ways.size() / 2] * 0.7, AMBER, 0.45)


## The Sopro Glacial: the cone of cold wind (a pale mist and a readable crystal edge) that clears fast.
func cone(origin: Vector2, dir: Vector2, reach: float, deg: float) -> void:
	var c := _spawn(FORM_CONE, ICE, IVORY, 0.42)
	if c.is_empty():
		return
	_place(c, Vector3(origin.x, GROUND_Y + 0.01, origin.y), yaw_of(dir), Vector3(reach * 2.0, 1.0, reach * 2.0))
	(c.mat as ShaderMaterial).set_shader_parameter(&"width_deg", deg)


## The Combustão's impact: an irregular ring of fire, tongues on its edge, a hot flash over it.
func impact(at: Vector2, radius: float) -> void:
	var c := _spawn(FORM_RING, ORANGE, HOT, 0.5)
	if not c.is_empty():
		_place(c, Vector3(at.x, GROUND_Y + 0.02, at.y), _rng.randf() * TAU, Vector3(radius * 2.4, 1.0, radius * 2.4))
	var core := _spawn(FORM_ORB, AMBER, HOT, 0.3)
	if not core.is_empty():
		_place(core, Vector3(at.x, 0.7, at.y), 0.0, Vector3.ONE * radius * 1.3)


## The Inverno Eterno's ground (a card that lasts `life`, then melts); a new one replaces the old.
func frost(at: Vector2, radius: float, life: float) -> void:
	end_frost()
	_frost = _make(FORM_FROST, ICE, IVORY)
	_frost.life = life
	_place(_frost, Vector3(at.x, GROUND_Y, at.y), _rng.randf() * TAU, Vector3(radius * 2.1, 1.0, radius * 2.1))


func end_frost() -> void:
	if not _frost.is_empty():
		(_frost.node as Node).queue_free()
		_frost = {}


func has_frost() -> bool:
	return not _frost.is_empty()


## One leap of the Tempestade: a thick main arc between two points and two thin branches that fade sooner.
func bolt(from: Vector2, to: Vector2) -> void:
	var way := to - from
	var dist := way.length()
	if dist < 0.1:
		return
	var dir := way / dist
	var c := _spawn(FORM_ARC, GOLD, HOT, 0.3)
	if c.is_empty():
		return
	var mid := (from + to) * 0.5
	_place(c, Vector3(mid.x, 1.0, mid.y), yaw_of(dir), Vector3(dist, 1.0, 0.9))
	(c.mat as ShaderMaterial).set_shader_parameter(&"thick", 1.6)
	for side in [-1.0, 1.0]:
		var b := _spawn(FORM_ARC, GOLD, HOT, 0.2)
		if b.is_empty():
			return
		var bdir := dir.rotated(side * (0.5 + _rng.randf() * 0.4))
		var blen := clampf(dist * 0.45, 0.6, 2.2)
		var root := from + dir * dist * (0.3 + _rng.randf() * 0.4)
		var bm := root + bdir * blen * 0.5
		_place(b, Vector3(bm.x, 1.0, bm.y), yaw_of(bdir), Vector3(blen, 1.0, 0.5))
		(b.mat as ShaderMaterial).set_shader_parameter(&"thick", 0.55)
	tip_flare(to, Vector2.ZERO, GOLD, 0.7, 0.2)


# ---------- dissipation and reactions ----------

## A small flash where sparks start (the particles themselves are the shared Fx pool's).
func spark_burst(at: Vector2, color: Color, size: float = 0.5) -> void:
	var c := _spawn(FORM_ORB, color, HOT, 0.14)
	if not c.is_empty():
		_place(c, Vector3(at.x, 1.0, at.y), 0.0, Vector3.ONE * size)


## Choque Térmico: white steam and a burst, amber on one side and blue on the other.
func thermal(at: Vector2) -> void:
	var s := _spawn(FORM_STEAM, STEAM, STEAM, 0.7)
	if not s.is_empty():
		_place(s, Vector3(at.x, GROUND_Y + 0.03, at.y), _rng.randf() * TAU, Vector3(2.2, 1.0, 2.2))
	var a := _spawn(FORM_RING, AMBER, HOT, 0.4)
	if not a.is_empty():
		_place(a, Vector3(at.x, GROUND_Y + 0.02, at.y), _rng.randf() * TAU, Vector3(2.6, 1.0, 2.6))
	var b := _spawn(FORM_RING, ICE, IVORY, 0.4)
	if not b.is_empty():
		_place(b, Vector3(at.x, GROUND_Y + 0.025, at.y), _rng.randf() * TAU, Vector3(1.8, 1.0, 1.8))


## Sobrecarga: a gold pulse with orange sparks.
func overload(at: Vector2, radius: float) -> void:
	var a := _spawn(FORM_RING, GOLD, HOT, 0.35)
	if not a.is_empty():
		_place(a, Vector3(at.x, GROUND_Y + 0.02, at.y), _rng.randf() * TAU, Vector3(radius * 2.4, 1.0, radius * 2.4))
	spark_burst(at, ORANGE, 0.6)


## Cristalização: a few crystals standing for a moment and a short arc across them.
func crystallize(at: Vector2) -> void:
	var c := _spawn(FORM_CRYSTALS, ICE, IVORY, 0.55)
	if not c.is_empty():
		_place(c, Vector3(at.x, GROUND_Y + 0.02, at.y), _rng.randf() * TAU, Vector3(1.9, 1.0, 1.9))
	var way := Vector2.RIGHT.rotated(_rng.randf() * TAU)
	var arc := _spawn(FORM_ARC, GOLD, HOT, 0.2)
	if not arc.is_empty():
		_place(arc, Vector3(at.x, 0.9, at.y), yaw_of(way), Vector3(1.4, 1.0, 0.5))
		(arc.mat as ShaderMaterial).set_shader_parameter(&"thick", 0.7)


# ---------- the loop ----------

func step(dt: float) -> void:
	var i := _cards.size() - 1
	while i >= 0:
		var c := _cards[i]
		c.age = float(c.age) + dt
		var t := clampf(float(c.age) / float(c.life), 0.0, 1.0)
		(c.mat as ShaderMaterial).set_shader_parameter(&"t", t)
		if c.vel != Vector3.ZERO:
			(c.node as Node3D).position += (c.vel as Vector3) * dt
		if float(c.grow) > 0.0:
			(c.node as Node3D).scale = (c.size as Vector3) * (1.0 + float(c.grow) * t)
		if t >= 1.0:
			(c.node as Node).queue_free()
			_cards.remove_at(i)
		i -= 1
	if not _frost.is_empty():
		_frost.age = float(_frost.age) + dt
		var ft := clampf(float(_frost.age) / float(_frost.life), 0.0, 1.0)
		(_frost.mat as ShaderMaterial).set_shader_parameter(&"t", ft)
		if ft >= 1.0:
			end_frost()


func clear() -> void:
	for c in _cards:
		(c.node as Node).queue_free()
	_cards.clear()
	end_frost()
	hold_orb(false, Vector2.ZERO, Vector2.RIGHT, 0.0, true)
