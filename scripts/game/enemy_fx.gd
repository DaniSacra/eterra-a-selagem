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

enum Shape { DOT, RING, STREAK, SHARD, BAR, INK }

const SHADER := preload("res://assets/shaders/enemy_tell.gdshader")
## LC-1: the quads put with `over` are drawn by a second MultiMesh over what is in front of them (no depth test).
const OVER_SHADER := preload("res://assets/shaders/enemy_tell_over.gdshader")
## LC-1b/LC-3b: BAR is a stroke with hard edges (a drawn object, not a glow); INK the same stroke in dark ink, which
## only the quads drawn over darken (enemy_tell_over.gdshader, premultiplied): put under a BAR it outlines it, so the
## shape reads on the pale floor and on the bone of the figures alike.
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
## LC-1 (docs/backlog.md 9): the crossbow itself drawn in light where the pose holds it (BakedModel.point "crossbow"),
## from BOW_FROM of the wind-up, as it comes up to the shoulder. LC-1b: drawn in the screen's plane (never shortened by
## the camera's tilt, whichever way it aims) and pointing where the aim points on the screen, in hard pale strokes
## outlined in ink (BAR over INK), all in meters at size 1: the stock CROSSBOW_STOCK long, the bow's two arms
## CROSSBOW_ARM long at its front, swept back CROSSBOW_SWEEP, the string straight across their ends, about 70 px across
## at 1080 in the game's camera (it was a 30 to 40 px cross of thin streaks). The sight goes from the bolt's tip down to
## the aim's wire on the floor, SIGHT meters ahead of its feet: the figure that aims tied to the way the bolt will fly
## (the wire on the floor, Ground.add_aim_warning, from the same frame). The bolt's steel, never the bolt's orange: red
## is the floor's danger.
const BOW_FROM := 0.15
const CROSSBOW_STOCK := 1.0
const CROSSBOW_ARM := 0.62
const CROSSBOW_SWEEP := 0.3
const CROSSBOW_STROKE := 0.075
const STRING_STROKE := 0.035
## The ink round each stroke: this much wider than it (meters at size 1, each side).
const INK_EDGE := 0.065
const INK_ALPHA := 0.6
## The strokes (BAR) are lit to this share of the brightest their hue may be and stay under ScreenTone.SAFE on the
## screen (ScreenTone.fit, linear): the rest is the room for what shows through the ink under them.
const STROKE_ROOM := 0.9
## The bow sits this far ahead of the crossbow's middle, the bolt's tip that far (meters at size 1).
const BOW_AHEAD := 0.3
const BOW_TIP := 0.5
const SIGHT := 3.4
const SIGHT_LIGHT := 0.7
const SIGHT_STROKE := 0.05
## The steel of the tip gleams as the shot comes (the soldier's blade does the same): its size at size 1, fullest at
## GLINT_PEAK of the wind-up.
const TIP_GLINT := 0.5
## The shield's edge catches the light from this share of the wind-up (the long charge reads early), dust kicked up
## at its feet in the last part.
const SHIELD_FROM := 0.3
const SHIELD_DUST := 0.6
## Sparks spiralling up from a staff's orb: how many, how wide and how high (meters at size 1).
const ORB_SPARKS := 4
const ORB_RADIUS := 0.2
const ORB_RISE := 0.75
const ORB_HALO := 0.55
## LC-2: the orb is the sorcerer's wind-up, where its staff holds it (BakedModel.point "orb"): a core that swells
## from ORB_CORE to ORB_CORE_FULL (meters at size 1), and rings that close on it from ORB_GATHER, ORB_RINGS of them
## over the wind-up (thin, turned to the camera): its magic gathered into the staff's top, a point and not a cloud.
## The sparks come in to it instead of rising from it.
const ORB_CORE := 0.16
const ORB_CORE_FULL := 0.42
const ORB_GATHER := 1.1
const ORB_RINGS := 2.0
const ORB_RING_WIDTH := 0.22
## The light of the magic's sparks round a staff's orb and a priest's rite: the magic's hue (largest channel 1) times
## this, under the glow threshold (cycle 10, BUG-006: at 1.6 a few sorcerers winding up together bloomed white).
const MAGIC_SPARK := 1.2
## The priest's ritual: the ring on the floor (meters, opacity at its most: not a warning) and the motes between its hands.
const RITUAL_RING := 1.2
const RITUAL_RING_ALPHA := 0.3
const RITUAL_MOTES := 3
const RITUAL_ORBIT := 0.24
## LC-3: the rite's light rides its raised hands (BakedModel.point "hand_l", "hand_r"): a glow in each palm
## (meters at size 1), and over the middle of the two, RITUAL_LIFT higher, a soft flame that grows as the arms come
## up, the motes turning round it. Lit palms at the ends of a V over the head: the gesture reads by its shape. A thread
## goes from the flame down to the ring on the floor in the hold: from the rite to the ground it will reach.
const RITUAL_PALM := 0.32
const RITUAL_FLAME := 0.38
const RITUAL_LIFT := 0.3
const RITUAL_THREAD := 0.5
## LC-3b: the rite reads from every side, its back to the camera too (the body hid the V of its arms): the two arms
## drawn as strokes of the magic's light outlined in ink, from the chest (RITUAL_NECK of its height) to each lit palm,
## over the body (as the crossbow), with the palms and the flame; in the magic's hue, under ScreenTone.SAFE (lit()).
const RITUAL_NECK := 0.6
const RITUAL_ARM := 0.07
## The V never narrower than this across, nor its palms lower than this over the chest, on the screen (meters at size 1).
const RITUAL_SPREAD := 0.8
const RITUAL_RAISE := 0.45
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
## Which quads of _data are drawn over (1), and the second MultiMesh that draws them.
var _over := PackedByteArray()
## The over pass draws after the life bars (CrowdRenderer, render_priority 10): in a crowd the bars of the ones in
## front covered the priest's V and the crossbow (LC, 2026-11-19). The tells are short; the bars read again after.
const OVER_PRIORITY := 11
var _over_mmi: MultiMeshInstance3D
var _sparks: Array[Spark] = []
## Each hue's stroke light (lit()), computed once.
var _lit := {}
## The camera's right and up in the world (read in begin(); without a camera, the game's: 30 degrees over the floor,
## looking north), for the strokes drawn in the screen's plane (LC-1b).
var _right := Vector3.RIGHT
var _up := Vector3(0, 0.866, -0.5)
## Only for the scatter of the armor's sparks: never the simulation's generator.
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 7
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	_data.resize(POOL * FLOATS)
	_over.resize(POOL)
	_mmi = _batch(quad, SHADER, 5)
	_over_mmi = _batch(quad, OVER_SHADER, OVER_PRIORITY)


func _batch(quad: QuadMesh, shader: Shader, priority: int) -> MultiMeshInstance3D:
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.render_priority = priority
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = POOL
	mm.visible_instance_count = 0
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.layers = layers
	mmi.custom_aabb = AABB(Vector3(-200, -10, -200), Vector3(400, 60, 400))
	mmi.visible = false
	add_child(mmi)
	return mmi


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
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam != null:
		_right = cam.global_basis.x
		_up = cam.global_basis.y


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


## LC-1 to LC-3: the named part of the drawn figure each wind-up sits on (BakedModel.point), when the model has it.
const PART := {EnemyDef.Tell.BOLT: "crossbow", EnemyDef.Tell.ORB: "orb", EnemyDef.Tell.RITUAL: "hands"}


## Where its wind-up's light sits: the part of the pose drawn (model, anim, t as the crowd draws it) or, without
## them, its EnemyDef.tell_at.
static func spot(e: Enemy, model: BakedModel, anim: StringName, t: float) -> Vector3:
	var d := e.def
	var part: String = PART.get(d.tell, "")
	if model != null and part != "" and model.has_point(part) and model.frame_count(anim) > 0:
		return anchor(e.pos, e.y, e.yaw(), d.size, model.point(part, anim, t))
	return anchor(e.pos, e.y, e.yaw(), d.size, d.tell_at)


## The wind-up of one enemy, k from 0 (it just started) to 1 (the attack is loosed). model, anim, t: the pose drawn
## (Horde.render), so the light sits on the crossbow, the orb or the hands where they are.
func tell(e: Enemy, k: float, model: BakedModel = null, anim := &"", t := 0.0) -> void:
	var d := e.def
	if d.tell == EnemyDef.Tell.NONE:
		return
	var at := spot(e, model, anim, t)
	if d.tell == EnemyDef.Tell.RITUAL:
		_rite(e, k, at, model, anim, t)
		return
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
			var gone := 1.0 - smoothstep(0.94, 1.0, k)
			_put(Shape.DOT, at, Vector2.ONE * ORB_HALO * d.size * (0.6 + 0.4 * k), c, 0.5 * k * gone)
			# the core swells as the staff comes up and is held
			var core := lerpf(ORB_CORE, ORB_CORE_FULL, smoothstep(0.1, 0.85, k)) * d.size
			_put(Shape.DOT, at, Vector2.ONE * core, c, minf(1.0, k * 2.5) * 0.6 * gone)
			# rings closing on it: the magic gathered from round it into the staff's top
			var wave := k * ORB_RINGS
			var r_k := 1.0 - fposmod(wave, 1.0)
			if wave < ORB_RINGS:
				var ring := lerpf(core * 1.1, ORB_GATHER * d.size, r_k)
				_put(Shape.RING, at, Vector2.ONE * ring, c * MAGIC_SPARK, sin((1.0 - r_k) * PI) * minf(1.0, k * 3.0) * 0.6 * gone, 0.0, ORB_RING_WIDTH)
			for i in ORB_SPARKS:
				var phase := fposmod(k * 1.6 + float(i) / ORB_SPARKS, 1.0)
				var a := phase * TAU * 1.5 + TAU * i / ORB_SPARKS
				var r := ORB_RADIUS * 2.2 * d.size * (1.0 - phase)
				_put(Shape.DOT, at + Vector3(cos(a) * r, (1.0 - phase) * ORB_RISE * 0.4 * d.size, sin(a) * r), Vector2.ONE * 0.16 * d.size, c * MAGIC_SPARK,
					sin(phase * PI) * minf(1.0, k * 3.0) * gone)
		EnemyDef.Tell.BOLT:
			_crossbow(e, k, at)
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


## LC-3: the priest's rite (see RITUAL_*). at: the middle of its hands (or its tell_at without them).
func _rite(e: Enemy, k: float, at: Vector3, model: BakedModel, anim: StringName, t: float) -> void:
	var d := e.def
	var c := magic_of(d)
	var rise := smoothstep(0.0, 0.3, k)
	var gone := 1.0 - smoothstep(0.94, 1.0, k)
	_floor(Shape.RING, Vector3(e.pos.x, 0.06, e.pos.y), Vector2.RIGHT, Vector2.ONE * 2.0 * RITUAL_RING, c, RITUAL_RING_ALPHA * rise, 0.05)
	# the flame over the raised hands, grown with them; it and the palms over the body (LC-3b: the back too)
	var flame := smoothstep(0.15, 0.7, k)
	var top := at + Vector3(0, RITUAL_LIFT * d.size * flame, 0)
	if model != null and model.has_point("hand_l") and model.frame_count(anim) > 0:
		# the two raised arms: a V of light from its chest to each palm, outlined in ink, in the screen's plane; seen
		# from the side (the palms one behind the other) the V opens to RITUAL_SPREAD across and RITUAL_RAISE up, so
		# it reads the same from every side
		var chest := anchor(e.pos, e.y, e.yaw(), d.size, Vector3(0, RITUAL_NECK * model.height, 0))
		var ends: Array[Vector2] = []
		for hand: String in ["hand_l", "hand_r"]:
			var off := anchor(e.pos, e.y, e.yaw(), d.size, model.point(hand, anim, t)) - chest
			ends.append(Vector2(off.dot(_right), off.dot(_up)))
		if ends[0].x > ends[1].x:
			ends.reverse()
		var spread := RITUAL_SPREAD * d.size
		var mid_x := (ends[0].x + ends[1].x) * 0.5
		if ends[1].x - ends[0].x < spread:
			ends[0].x = mid_x - spread * 0.5
			ends[1].x = mid_x + spread * 0.5
		for i in 2:
			ends[i].y = maxf(ends[i].y, RITUAL_RAISE * d.size)
		var arm_alpha := 0.9 * flame * gone
		for end in ends:
			_flat_bar(Shape.INK, chest, Vector2.ZERO, end, (RITUAL_ARM + INK_EDGE * 2.0) * d.size, INK_EDGE * d.size, Color.BLACK, INK_ALPHA * minf(arm_alpha / 0.9, 1.0))
		for end in ends:
			_flat_bar(Shape.BAR, chest, Vector2.ZERO, end, RITUAL_ARM * d.size, 0.0, lit(c), arm_alpha)
		# a glow in each palm, at the V's ends
		for end in ends:
			_put(Shape.DOT, chest + _right * end.x + _up * end.y, Vector2.ONE * RITUAL_PALM * d.size, c * MAGIC_SPARK, 0.8 * flame * gone, 0.0, 0.0, true)
	_put(Shape.DOT, top, Vector2(0.8, 1.15) * RITUAL_FLAME * d.size * (0.5 + 0.5 * flame), c, 0.7 * flame * gone, 0.0, 0.0, true)
	for i in RITUAL_MOTES:
		var a := k * TAU * 2.0 + TAU * i / RITUAL_MOTES
		_put(Shape.DOT, top + Vector3(cos(a), 0.35 * sin(a * 0.5), sin(a)) * RITUAL_ORBIT * d.size, Vector2.ONE * 0.2 * d.size, c * MAGIC_SPARK, rise * gone)
	# in the hold, a thread from the flame down to the ring: from the rite to the ground
	var thread := ramp(k, 0.6, 0.85)
	if thread > 0.0:
		var low := Vector3(e.pos.x, 0.1, e.pos.y)
		# turned to the camera and upright on the screen (the game's camera sees a standing meter as 0.87)
		_put(Shape.STREAK, (top + low) * 0.5, Vector2((top.y - low.y) * 0.87, 0.05 * d.size), c, RITUAL_THREAD * thread, PI * 0.5)


## A stroke's light in the hue of c: as bright as it may be and stay under ScreenTone.SAFE on the screen, times
## STROKE_ROOM (the strokes are opaque light over ink: the old streaks of 1.0 and more went to 255).
func lit(c: Color) -> Color:
	if not _lit.has(c):
		# the quads' colour is linear (unshaded, no sRGB decoding)
		var f := ScreenTone.fit(Color(c.r * 8.0, c.g * 8.0, c.b * 8.0), ScreenTone.SAFE, false)
		_lit[c] = Color(f.r * STROKE_ROOM, f.g * STROKE_ROOM, f.b * STROKE_ROOM)
	return _lit[c]


## LC-1b: the crossbow in light where the pose holds it (at), in the screen's plane, pointing where it aims, and the
## sight from its tip down to the aim's wire on the floor (see CROSSBOW_*).
func _crossbow(e: Enemy, k: float, at: Vector3) -> void:
	var d := e.def
	var bow := ramp(k, BOW_FROM, BOLT_FROM)
	if bow <= 0.0:
		return
	var aim := e.aim if e.aim.length_squared() > 0.01 else Vector2.from_angle(PI * 0.5 - e.yaw())
	var aim3 := Vector3(aim.x, 0.0, aim.y)
	# the aim on the screen (right, up), and across it
	var on := Vector2(aim3.dot(_right), aim3.dot(_up))
	on = on.normalized() if on.length_squared() > 1e-4 else Vector2.RIGHT
	var across := Vector2(-on.y, on.x)
	var z := d.size
	var pale := lit(PALE)
	var front := on * BOW_AHEAD * z
	var strokes: Array = [[-on * CROSSBOW_STOCK * 0.6 * z, on * CROSSBOW_STOCK * 0.4 * z, CROSSBOW_STROKE]]
	var ends: Array[Vector2] = []
	for side: float in [-1.0, 1.0]:
		var arm_end: Vector2 = front + (across * side * cos(CROSSBOW_SWEEP) - on * sin(CROSSBOW_SWEEP)) * CROSSBOW_ARM * z
		strokes.append([front, arm_end, CROSSBOW_STROKE])
		ends.append(arm_end)
	# the string straight across the bow's ends
	strokes.append([ends[0], ends[1], STRING_STROKE])
	for s: Array in strokes:
		_flat_bar(Shape.INK, at, s[0], s[1], (s[2] + INK_EDGE * 2.0) * z, INK_EDGE * z, Color.BLACK, INK_ALPHA * bow)
	for s: Array in strokes:
		_flat_bar(Shape.BAR, at, s[0], s[1], s[2] * z, 0.0, pale, bow)
	var b := ramp(k, BOLT_FROM, 1.0)
	if b <= 0.0:
		return
	# the bolt drawn back: its tip lights, and the sight comes from it down to the wire on the floor
	var tip := at + aim3 * BOW_TIP * z
	var glint := ramp(k, GLINT_FROM, GLINT_PEAK)
	_put(Shape.DOT, tip, Vector2.ONE * lerpf(0.32, TIP_GLINT, glint) * z, PALE, 0.65 * b + 0.25 * glint, 0.0, 0.0, true)
	var ground := Vector3(e.pos.x, 0.08, e.pos.y) + aim3 * SIGHT * z
	_stroke(tip, tip.lerp(ground, b), SIGHT_STROKE * z, pale, SIGHT_LIGHT * b)


## A stroke in the screen's plane round `at`: from a to b (right, up on the screen, meters), width wide, past its
## ends by `past` (the ink's edge), drawn over.
func _flat_bar(shape: Shape, at: Vector3, a: Vector2, b: Vector2, width: float, past: float, color: Color, alpha: float) -> void:
	var along := b - a
	var mid := (a + b) * 0.5
	_put(shape, at + _right * mid.x + _up * mid.y, Vector2(along.length() + past * 2.0, width), color, alpha, along.angle(), 0.0, true)


## A stroke from a to b in the world, facing the camera, width wide, outlined in ink, drawn over. part: 0 both, 1 only
## the ink, 2 only the light (strokes that meet put all their ink first).
func _stroke(a: Vector3, b: Vector3, width: float, color: Color, alpha: float, part := 0) -> void:
	var along := b - a
	if along.length_squared() < 1e-6 or alpha <= 0.003:
		return
	var facing := _right.cross(_up)
	var side := along.cross(facing)
	side = side.normalized() if side.length_squared() > 1e-8 else _right
	var dir := along.normalized()
	for ink: bool in [true, false]:
		if (ink and part == 2) or (not ink and part == 1):
			continue
		var w := width + (INK_EDGE * 2.0 if ink else 0.0)
		var x := along + (dir * INK_EDGE * 2.0 if ink else Vector3.ZERO)
		_write(Basis(x, side * w, facing), (a + b) * 0.5, Shape.INK if ink else Shape.BAR, Color.BLACK if ink else color,
			(INK_ALPHA * minf(alpha / 0.9, 1.0)) if ink else alpha, 0.0, 0.0, 0.0, true)


## One enemy whose attack was just loosed, t seconds ago (model, anim, clip_t: the pose drawn, as for tell()).
func loosed(e: Enemy, t: float, model: BakedModel = null, anim := &"", clip_t := 0.0) -> void:
	var d := e.def
	if d.behavior == EnemyDef.Behavior.RUNNER:
		_lunge(e, t)
	if t >= LOOSE_TIME:
		return
	var k := 1.0 - t / LOOSE_TIME
	var at := spot(e, model, anim, clip_t)
	match d.tell:
		EnemyDef.Tell.BOLT:
			# the release at the crossbow's tip
			var face := Vector2.from_angle(PI * 0.5 - e.yaw())
			at += Vector3(face.x, 0.0, face.y) * BOW_TIP * d.size
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
	var over := _over.slice(0, count).count(1)
	if over == 0:
		_show(_mmi, _data, count)
		_show(_over_mmi, _data, 0)
		return
	# the quads drawn over go to their own MultiMesh, the rest stay in order
	var under := PackedFloat32Array()
	var above := PackedFloat32Array()
	for i in count:
		if _over[i] == 1:
			above.append_array(_data.slice(i * FLOATS, (i + 1) * FLOATS))
		else:
			under.append_array(_data.slice(i * FLOATS, (i + 1) * FLOATS))
	_show(_mmi, under, count - over)
	_show(_over_mmi, above, over)


func _show(mmi: MultiMeshInstance3D, data: PackedFloat32Array, n: int) -> void:
	mmi.visible = n > 0
	if n > 0:
		data.resize(POOL * FLOATS)
		mmi.multimesh.buffer = data
		mmi.multimesh.visible_instance_count = n


## A quad turned to the camera. turn: radians in the screen's plane.
## param: a ring's thickness (share of its radius).
## over: drawn over what is in front of it (LC-1).
func _put(shape: Shape, at: Vector3, size: Vector2, color: Color, alpha: float, turn := 0.0, param := 0.0, over := false) -> void:
	_write(Basis(Vector3(size.x, 0, 0), Vector3(0, size.y, 0), Vector3(0, 0, 1)), at, shape, color, alpha, 1.0, param, turn, over)


## A quad lying flat, its x along a direction of the floor. param: the ring's thickness.
func _floor(shape: Shape, at: Vector3, dir: Vector2, size: Vector2, color: Color, alpha: float, param := 0.0, over := false) -> void:
	var x := Vector3(dir.x, 0, dir.y)
	var y := Vector3(-dir.y, 0, dir.x)
	_write(Basis(x * size.x, y * size.y, Vector3.UP), at, shape, color, alpha, 0.0, param, 0.0, over)


func _write(basis: Basis, at: Vector3, shape: Shape, color: Color, alpha: float, billboard: float, param: float, turn: float, over := false) -> void:
	if count >= POOL or alpha <= 0.003:
		return
	_over[count] = 1 if over else 0
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
