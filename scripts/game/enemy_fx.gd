class_name EnemyFx
extends Node3D
## The small lights that say what an enemy is about to do, and what its armor did with a blow: one MultiMesh of
## quads (enemy_tell.gdshader) with a fixed reserve, no node per enemy. Horde.render() calls begin(), then tell() for
## each enemy winding up and loosed() for each one that just attacked, then commit().
##
## The wind-ups are drawn from the enemy's own clock (Enemy.state_t): nothing is remembered and nothing is drawn
## by chance, so they cost nothing to the simulation and never touch its dice. Only the armor's sparks live for a
## moment of their own, scattered by this file's generator.
## Rules (docs/art/cycle7_spec.md, 1 and 4.2): born of a real event, gone when the attack is loosed, never red (red
## is danger on the floor), violet is the enemy's magic, old gold is armor, pale is steel.

enum Shape { DOT, RING, STREAK, SHARD }

const SHADER := preload("res://assets/shaders/enemy_tell.gdshader")
## Quads on the screen at once; past it the rest is not drawn.
const POOL := 320
const FLOATS := 20
## Steel catching light: blades, the tip of a bolt, the edge of a shield.
const PALE := Color(1.25, 1.2, 1.05)
const DUST := Color(0.34, 0.31, 0.28)
## Armor: old gold, as the elites' trims (CrowdRenderer.GILD_COLOR), bright enough to read as a spark.
const OLD_GOLD := Color(1.5, 1.1, 0.5)
## The blade's gleam starts at this share of the wind-up, is fullest at GLINT_PEAK (the moment to dodge) and is gone
## by the blow. Cycle 8 (few enemies, each read alone): it swells late instead of in the middle, a little larger,
## with a short cross stroke so it reads as a point of light on steel and not a mote.
const GLINT_FROM := 0.45
const GLINT_PEAK := 0.85
const GLINT_SIZE := 0.7
## The crossbow's bolt drawn back: a pale streak along the aim, growing to this length (meters at size 1), from
## this share of the wind-up.
const BOLT_FROM := 0.35
const BOLT_DRAW := 0.9
## The shield's edge catches the light from this share of the wind-up (the long charge reads early), dust kicked up
## at its feet in the last part.
const SHIELD_FROM := 0.3
const SHIELD_DUST := 0.6
## Sparks spiralling up from a staff's orb: how many, how wide and how high (meters at size 1).
const ORB_SPARKS := 4
const ORB_RADIUS := 0.2
const ORB_RISE := 0.75
const ORB_HALO := 0.55
## The priest's ritual: the ring on the floor (meters, opacity at its most: not a warning) and the motes between its hands.
const RITUAL_RING := 1.2
const RITUAL_RING_ALPHA := 0.3
const RITUAL_MOTES := 3
const RITUAL_ORBIT := 0.24
## Seconds the loosed attack still shows (the spark of the bolt, the stroke on the shield).
const LOOSE_TIME := 0.14
## A lunge leaves two pale streaks behind the body (meters) and dust where it started.
const STREAK_LENGTH := 1.0
const STREAK_HEIGHTS: Array[float] = [0.75, 1.35]
## Armor that takes a blow sheds a few sparks; armor that breaks, its shards (count, seconds, speed in m/s).
const ABSORB_SPARKS := 4
const ABSORB_TIME := 0.22
const BREAK_SHARDS := 12
const BREAK_TIME := 0.35
const SPARK_SPEED := 5.0
const SPARK_GRAVITY := 14.0
const MAX_SPARKS := 96

class Spark:
	var pos := Vector3.ZERO
	var vel := Vector3.ZERO
	var life := 0.0
	var total := 1.0
	var size := 0.1
	var shape := Shape.SHARD
	var turn := 0.0

var layers := 1
## Quads put this frame (tests read it).
var count := 0
var _mmi: MultiMeshInstance3D
var _data := PackedFloat32Array()
var _sparks: Array[Spark] = []
## Only for the scatter of the armor's sparks: never the simulation's generator.
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.render_priority = 5
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = POOL
	mm.visible_instance_count = 0
	_data.resize(POOL * FLOATS)
	_mmi = MultiMeshInstance3D.new()
	_mmi.multimesh = mm
	_mmi.material_override = mat
	_mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mmi.layers = layers
	_mmi.custom_aabb = AABB(Vector3(-200, -10, -200), Vector3(400, 60, 400))
	_mmi.visible = false
	add_child(_mmi)


func _process(delta: float) -> void:
	var i := _sparks.size() - 1
	while i >= 0:
		var s := _sparks[i]
		s.life -= delta
		if s.life <= 0.0:
			_sparks.remove_at(i)
		else:
			s.vel.y -= SPARK_GRAVITY * delta
			s.pos += s.vel * delta
		i -= 1


func begin() -> void:
	count = 0


## Where a point of the figure (EnemyDef.tell_at) is in the world: x to its right, y up, z ahead, scaled by its size.
static func anchor(pos: Vector2, y: float, yaw: float, size: float, at: Vector3) -> Vector3:
	return Vector3(pos.x, y, pos.y) + Basis(Vector3.UP, yaw) * (at * size)


## The unit colour of an enemy's magic (its largest channel at 1), or pale steel when it has none.
static func magic_of(d: EnemyDef) -> Color:
	var m := d.magic_color
	var top := maxf(m.r, maxf(m.g, m.b))
	return Color(m.r / top, m.g / top, m.b / top) if m.a > 0.0 and top > 0.0 else PALE


## 0 before from, rising to 1 at peak, held, and gone by the end of the wind-up (the last 8%): a cue that is fullest
## just before the blow and never still on screen when it lands.
static func ramp(k: float, from: float, peak: float) -> float:
	return smoothstep(from, peak, k) * (1.0 - smoothstep(0.92, 1.0, k))


## The wind-up of one enemy, k from 0 (it just started) to 1 (the attack is loosed).
func tell(e: Enemy, k: float) -> void:
	var d := e.def
	if d.tell == EnemyDef.Tell.NONE:
		return
	var at := anchor(e.pos, e.y, e.yaw(), d.size, d.tell_at)
	match d.tell:
		EnemyDef.Tell.GLINT:
			var g := ramp(k, GLINT_FROM, GLINT_PEAK)
			if g > 0.0:
				# a pale gleam on the edge: it swells toward the blow and is gone when the blade comes down
				_put(Shape.DOT, at, Vector2.ONE * GLINT_SIZE * 0.5 * d.size * g, PALE, 0.8 * g)
				_put(Shape.STREAK, at, Vector2(GLINT_SIZE * d.size * g, 0.07 * d.size), PALE, 0.9 * g, 0.5)
				_put(Shape.STREAK, at, Vector2(GLINT_SIZE * 0.55 * d.size * g, 0.06 * d.size), PALE, 0.7 * g, 0.5 + PI * 0.5)
		EnemyDef.Tell.TREMBLE:
			# dust shaken off the floor under it
			for i in 3:
				var a := TAU * (i / 3.0) + e.look * TAU
				var out := (0.3 + 0.5 * k) * d.size
				_put(Shape.DOT, Vector3(e.pos.x + cos(a) * out, 0.15 + 0.25 * k, e.pos.y + sin(a) * out),
					Vector2.ONE * (0.5 + 0.5 * k) * d.size, DUST, 0.45 * sin(k * PI))
		EnemyDef.Tell.ORB:
			var c := magic_of(d)
			_put(Shape.DOT, at, Vector2.ONE * ORB_HALO * d.size * (0.6 + 0.4 * k), c, 0.5 * k)
			for i in ORB_SPARKS:
				var phase := fposmod(k * 1.6 + float(i) / ORB_SPARKS, 1.0)
				var a := phase * TAU * 1.5 + TAU * i / ORB_SPARKS
				var r := ORB_RADIUS * d.size * (1.0 - 0.5 * phase)
				_put(Shape.DOT, at + Vector3(cos(a) * r, phase * ORB_RISE * d.size, sin(a) * r), Vector2.ONE * 0.16 * d.size, c * 1.6,
					sin(phase * PI) * minf(1.0, k * 3.0))
		EnemyDef.Tell.BOLT:
			var b := ramp(k, BOLT_FROM, 1.0)
			if b > 0.0:
				# the bolt drawn back: its tip lights and a pale streak grows along the aim, the way it will fly
				_put(Shape.DOT, at, Vector2.ONE * 0.32 * d.size, PALE, 0.65 * b)
				var length := BOLT_DRAW * d.size * b
				var mid := Vector2(at.x, at.z) + e.aim * length * 0.5
				_floor(Shape.STREAK, Vector3(mid.x, at.y, mid.y), e.aim, Vector2(length, 0.07 * d.size), PALE, 0.55 * b)
		EnemyDef.Tell.SHIELD:
			var s := ramp(k, SHIELD_FROM, 1.0)
			if s > 0.0:
				# the edge of the raised shield catches the light, stronger as the charge comes
				_put(Shape.STREAK, at, Vector2(0.95 * d.size, 0.06 * d.size), PALE, 0.75 * s, PI * 0.5)
			if k > SHIELD_DUST:
				var dust := (k - SHIELD_DUST) / (1.0 - SHIELD_DUST)
				for i in 2:
					var a := TAU * (i / 2.0) + e.look * TAU
					var foot := e.pos - e.aim * 0.3 * d.size + Vector2(cos(a), sin(a)) * 0.35 * d.size
					_put(Shape.DOT, Vector3(foot.x, 0.15 + 0.2 * dust, foot.y), Vector2.ONE * 0.6 * d.size, DUST, 0.5 * sin(dust * PI))
		EnemyDef.Tell.RITUAL:
			var c := magic_of(d)
			var rise := smoothstep(0.0, 0.3, k)
			_floor(Shape.RING, Vector3(e.pos.x, 0.06, e.pos.y), Vector2.RIGHT, Vector2.ONE * 2.0 * RITUAL_RING, c, RITUAL_RING_ALPHA * rise, 0.05)
			for i in RITUAL_MOTES:
				var a := k * TAU * 2.0 + TAU * i / RITUAL_MOTES
				_put(Shape.DOT, at + Vector3(cos(a), 0.35 * sin(a * 0.5), sin(a)) * RITUAL_ORBIT * d.size, Vector2.ONE * 0.2 * d.size, c * 1.6, rise)


## One enemy whose attack was just loosed, t seconds ago.
func loosed(e: Enemy, t: float) -> void:
	var d := e.def
	if d.behavior == EnemyDef.Behavior.RUNNER:
		_lunge(e, t)
	if t >= LOOSE_TIME:
		return
	var k := 1.0 - t / LOOSE_TIME
	var at := anchor(e.pos, e.y, e.yaw(), d.size, d.tell_at)
	match d.tell:
		EnemyDef.Tell.BOLT:
			_put(Shape.DOT, at, Vector2.ONE * 0.55 * d.size * k, PALE, k)
			_put(Shape.STREAK, at, Vector2(0.9 * d.size, 0.08 * d.size), PALE, k)
		EnemyDef.Tell.SHIELD:
			_put(Shape.STREAK, at, Vector2(1.2 * d.size, 0.08 * d.size), PALE, k, PI * 0.5)


## The lunge: two pale streaks trailing the body, and dust where it left from.
func _lunge(e: Enemy, t: float) -> void:
	var d := e.def
	var k := clampf(1.0 - t / maxf(d.lunge_time, 0.01), 0.0, 1.0)
	if k <= 0.0:
		return
	for h in STREAK_HEIGHTS:
		var mid := e.pos - e.aim * (d.radius + STREAK_LENGTH * 0.5)
		_floor(Shape.STREAK, Vector3(mid.x, h * d.size, mid.y), e.aim, Vector2(STREAK_LENGTH, 0.16), PALE, 0.4 * k)
	var from := e.pos - e.aim * d.lunge_speed * t
	for i in 3:
		var a := TAU * (i / 3.0) + e.look * TAU
		var out := 0.3 + 0.7 * (1.0 - k)
		_put(Shape.DOT, Vector3(from.x + cos(a) * out, 0.2 + 0.5 * (1.0 - k), from.y + sin(a) * out), Vector2.ONE * (0.6 + 0.6 * (1.0 - k)), DUST, 0.8 * k)


## Armor took the blow: a few sparks of old gold fly from where it landed (dir: the way the blow went).
func armor_hit(at: Vector3, dir: Vector2) -> void:
	_scatter(at, dir, ABSORB_SPARKS, ABSORB_TIME, 0.09, Shape.DOT)


## The armor broke: its shards, once.
func armor_break(at: Vector3, size: float) -> void:
	_scatter(at, Vector2.ZERO, BREAK_SHARDS, BREAK_TIME, 0.11 * maxf(size, 1.0), Shape.SHARD)


func _scatter(at: Vector3, dir: Vector2, n: int, time: float, size: float, shape: Shape) -> void:
	for i in n:
		if _sparks.size() >= MAX_SPARKS:
			return
		var s := Spark.new()
		var a := _rng.randf() * TAU
		var out := Vector3(cos(a), _rng.randf_range(0.2, 1.0), sin(a)) * _rng.randf_range(0.5, 1.0)
		s.pos = at
		s.vel = (out + Vector3(dir.x, 0, dir.y) * 0.8) * SPARK_SPEED
		s.total = time * _rng.randf_range(0.7, 1.0)
		s.life = s.total
		s.size = size * _rng.randf_range(0.7, 1.3)
		s.shape = shape
		s.turn = _rng.randf() * TAU
		_sparks.append(s)


func commit() -> void:
	for s in _sparks:
		var k := s.life / s.total
		_put(s.shape, s.pos, Vector2(s.size, s.size * (1.8 if s.shape == Shape.SHARD else 1.0)), OLD_GOLD, k, s.turn)
	var mm := _mmi.multimesh
	_mmi.visible = count > 0
	if count > 0:
		mm.buffer = _data
		mm.visible_instance_count = count


## A quad turned to the camera. turn: radians in the screen's plane.
func _put(shape: Shape, at: Vector3, size: Vector2, color: Color, alpha: float, turn := 0.0) -> void:
	_write(Basis(Vector3(size.x, 0, 0), Vector3(0, size.y, 0), Vector3(0, 0, 1)), at, shape, color, alpha, 1.0, 0.0, turn)


## A quad lying flat, its x along a direction of the floor. param: the ring's thickness.
func _floor(shape: Shape, at: Vector3, dir: Vector2, size: Vector2, color: Color, alpha: float, param := 0.0) -> void:
	var x := Vector3(dir.x, 0, dir.y)
	var y := Vector3(-dir.y, 0, dir.x)
	_write(Basis(x * size.x, y * size.y, Vector3.UP), at, shape, color, alpha, 0.0, param, 0.0)


func _write(basis: Basis, at: Vector3, shape: Shape, color: Color, alpha: float, billboard: float, param: float, turn: float) -> void:
	if count >= POOL or alpha <= 0.003:
		return
	var o := count * FLOATS
	var d := _data
	d[o] = basis.x.x; d[o + 1] = basis.y.x; d[o + 2] = basis.z.x; d[o + 3] = at.x
	d[o + 4] = basis.x.y; d[o + 5] = basis.y.y; d[o + 6] = basis.z.y; d[o + 7] = at.y
	d[o + 8] = basis.x.z; d[o + 9] = basis.y.z; d[o + 10] = basis.z.z; d[o + 11] = at.z
	d[o + 12] = color.r; d[o + 13] = color.g; d[o + 14] = color.b; d[o + 15] = minf(alpha, 1.0)
	d[o + 16] = float(shape); d[o + 17] = billboard; d[o + 18] = param; d[o + 19] = turn
	count += 1


## The quads put this frame as [shape, position, colour with its opacity] (tests).
func put() -> Array:
	var out := []
	for i in count:
		var o := i * FLOATS
		out.append([int(_data[o + 16]), Vector3(_data[o + 3], _data[o + 7], _data[o + 11]), Color(_data[o + 12], _data[o + 13], _data[o + 14], _data[o + 15])])
	return out
