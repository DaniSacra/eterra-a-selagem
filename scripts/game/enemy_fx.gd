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

enum Shape { DOT, RING, STREAK, SHARD, BAR, INK, ARC }

const SHADER := preload("res://assets/shaders/enemy_tell.gdshader")
## LC-1: the quads put with `over` are drawn by a second MultiMesh over what is in front of them (no depth test).
const OVER_SHADER := preload("res://assets/shaders/enemy_tell_over.gdshader")
## LC-1b/LC-3b: BAR is a stroke with hard edges (a drawn object, not a glow); INK the same stroke in dark ink, which
## only the quads drawn over darken (enemy_tell_over.gdshader, premultiplied): put under a BAR it outlines it, so the
## shape reads on the pale floor and on the bone of the figures alike.
## Quads on the screen at once; past it the rest is not drawn.
const POOL := 320
const FLOATS := 20
## Steel catching light: blades, the tip of a bolt, the edge of a shield. vfx_pass_spec.md V-13: a reddish ivory (hue
## near 8, pale), never the paladin's white (it was (1.25, 1.2, 1.05)).
const PALE := Color(1.05, 0.78, 0.74)
const DUST := Color(0.34, 0.31, 0.28)
## Armor: old gold, as the elites' trims (CrowdRenderer.GILD_COLOR), bright enough to read as a spark.
const OLD_GOLD := Color(1.5, 1.1, 0.5)
## The blade's gleam starts at this share of the wind-up, is fullest at GLINT_PEAK (the moment to dodge) and is gone
## by the blow. Cycle 8 (few enemies, each read alone): it swells late instead of in the middle, a little larger,
## with a short cross stroke so it reads as a point of light on steel and not a mote.
const GLINT_FROM := 0.45
const GLINT_PEAK := 0.85
const GLINT_SIZE := 0.7
## V-13: the gleam is one stroke running once along the edge, from the guard to the tip (GLINT_LINE m at size 1, about
## 2 px wide at 1080: GLINT_WIDTH m, its lit part GLINT_RUN of the line), and a hot point at the tip; never a star.
const GLINT_LINE := 0.6
const GLINT_WIDTH := 0.03
const GLINT_RUN := 0.35
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
const INK_EDGE := 0.09
const INK_ALPHA := 0.78
## L-1 (art review of the Sworn P1, P2): the strokes read as paint on the figure, not an interface laid over it. The
## crossbow's body in the aged bone and wood of the weapon (BOW_BODY), the priest's arms a darker violet
## (RITUAL_ARM_DARK of their light), each at STROKE_TONE of the light lit() allows; with the thicker ink above, the
## strokes' luma p50 170 to 200 at 1080 (217 to 219 before) and nothing pure white. Size, shape and timing unchanged.
const BOW_BODY := Color(0.86, 0.7, 0.48)
const STROKE_TONE := 0.78
const RITUAL_ARM_DARK := 0.72
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
	var color := OLD_GOLD
	var pos := Vector3.ZERO
	var vel := Vector3.ZERO
	var life := 0.0
	var total := 1.0
	var size := 0.1
	var shape := Shape.SHARD
	var turn := 0.0

## Combate C1 (docs/art/combate_c1_leitura.md 2): the Escudo's guard drawn on the floor. Neutral steel, only the front:
## five streaks tangent to an arc round it (GUARD_ARC degrees each side, GUARD_REACH m past its body), faint far off and
## clearer with the paladin close in front; a guard opened throws them out (guard_fling) and shows them back one by one
## over the last GUARD_BACK s of it; a blow it shuts lights the middle one.
const STEEL := Color(0.66, 0.69, 0.74)
## C1b: the shards of a broken poise (pale ivory: gold is the elites', red the danger, green Emeth's).
const POISE_BREAK := Color(0.92, 0.93, 0.88)
const STEEL_TONE := 0.75
## N2: the Quebra's ring parts in POISE_ARCS arcs that fly out in POISE_ARC_TIME s, from this share of the body's size to
## POISE_ARC_GROW times it (the word is smaller than the ring).
const POISE_ARCS := 6
const POISE_ARC_TIME := 0.25
const POISE_ARC_GROW := Vector2(0.5, 1.6)
const POISE_ARC_THICK := 0.16
const POISE_ARC_TONE := 0.8
const GUARD_STREAKS := 5
const GUARD_ARC := 60.0
const GUARD_REACH := 0.7
const GUARD_STREAK := Vector2(0.95, 0.3)
const GUARD_FAR := 0.55
const GUARD_NEAR := 0.95
const GUARD_NEAR_M := 6.0
const GUARD_BACK := 1.0
const GUARD_BACK_STEP := 0.2
const GUARD_FLING_TIME := 0.15
const GUARD_FLING_REACH := 0.5
const GUARD_BLOCK_ALPHA := 1.0
const GUARD_Y := 0.07
## The order the streaks come back in: the sides, then toward the middle.
const GUARD_ORDER: Array[int] = [0, 4, 1, 3, 2]

## A priest's thread cut by its fall: from where it ran, parting from the middle to both ends.
class Cut:
	var from := Vector3.ZERO
	var to := Vector3.ZERO
	var life := 0.18


class Flung:
	var at := Vector3.ZERO
	var out := Vector3.ZERO
	var dir := Vector2.RIGHT
	var life := GUARD_FLING_TIME

## The arcs of a poise broken: where, how big, seconds left.
class Arcs:
	var at := Vector3.ZERO
	var size := 1.0
	var life := POISE_ARC_TIME
	var turn := 0.0

var _arcs: Array[Arcs] = []
var _flung: Array[Flung] = []
var _cuts: Array[Cut] = []
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
	var c := _cuts.size() - 1
	while c >= 0:
		_cuts[c].life -= delta
		if _cuts[c].life <= 0.0:
			_cuts.remove_at(c)
		c -= 1
	var q := _arcs.size() - 1
	while q >= 0:
		_arcs[q].life -= delta
		if _arcs[q].life <= 0.0:
			_arcs.remove_at(q)
		q -= 1
	var f := _flung.size() - 1
	while f >= 0:
		_flung[f].life -= delta
		if _flung[f].life <= 0.0:
			_flung.remove_at(f)
		f -= 1
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


## Where in its wind-up (0 to 1) the enemy's aim locks (1 - aim_lock / attack_windup), or `otherwise` without a lock.
static func lock_at(d: EnemyDef, otherwise: float) -> float:
	if d.aim_lock <= 0.0 or d.attack_windup <= 0.0:
		return otherwise
	return clampf(1.0 - d.aim_lock / d.attack_windup, GLINT_FROM + 0.1, 1.0)


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
			# combate_c1_leitura 6: whoever follows him until its aim locks has its gleam end there (the tip lights = it left)
			var peak := lock_at(d, GLINT_PEAK)
			var g := ramp(k, GLINT_FROM, peak)
			if g > 0.0:
				# a gleam running once along the edge toward the blow, a hot point at the tip, gone when the blade comes down
				var run := smoothstep(GLINT_FROM, peak, k)
				var way := (_right * 0.7 + _up * 0.7).normalized() * GLINT_LINE * d.size
				var guard := at - way * 0.5
				var head := guard + way * run
				_stroke(guard + way * maxf(0.0, run - GLINT_RUN), head, GLINT_WIDTH * d.size, PALE, 0.9 * g, 2, false)
				_put(Shape.DOT, guard + way, Vector2.ONE * 0.16 * d.size, PALE, 0.8 * g * smoothstep(0.6, 1.0, run))
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
			_put(Shape.DOT, at, Vector2.ONE * ORB_HALO * d.size * (0.6 + 0.4 * k), c, 0.25 * k * gone)
			# the core swells as the staff comes up and is held: dim inside, its hue on a rim (V-11 and V-13: the dark
			# cored shot it will loose), under what stands in front of it
			var core := lerpf(ORB_CORE, ORB_CORE_FULL, smoothstep(0.1, 0.85, k)) * d.size
			_put(Shape.DOT, at, Vector2.ONE * core, c, minf(1.0, k * 2.5) * 0.25 * gone)
			_put(Shape.RING, at, Vector2.ONE * core * 1.08, c, minf(1.0, k * 2.5) * 0.8 * gone, 0.0, 0.22)
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
			var s := ramp(k, SHIELD_FROM, lock_at(d, 1.0))
			if s > 0.0:
				# the edge of the raised shield catches the light, stronger as the charge comes (full at the lock, if it has one)
				_put(Shape.STREAK, at, Vector2(0.95 * d.size, 0.06 * d.size), PALE, (1.0 if d.aim_lock > 0.0 else 0.75) * s, PI * 0.5)
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
			_flat_bar(Shape.BAR, chest, Vector2.ZERO, end, RITUAL_ARM * d.size, 0.0, toned(lit(c), RITUAL_ARM_DARK), arm_alpha)
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


## A stroke's colour a share of its light (alpha untouched).
static func toned(c: Color, k: float) -> Color:
	return Color(c.r * k, c.g * k, c.b * k, c.a)


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
	var pale := toned(lit(BOW_BODY), STROKE_TONE)
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
func _stroke(a: Vector3, b: Vector3, width: float, color: Color, alpha: float, part := 0, over := true) -> void:
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
			(INK_ALPHA * minf(alpha / 0.9, 1.0)) if ink else alpha, 0.0, 0.0, 0.0, over)


## PT-1 (Daniel, 2026-11-23; the principle of the "!" over the enemies of SWORN): the signal to dodge. A yellow
## exclamation mark over the head, in the screen's plane, outlined in ink (_stroke), lit only in the last `lead` seconds
## before the blow; `age` is how long it has been lit (0 to lead). It pulses once as it lights; the elites and the heavy
## ones carry a larger one. Costs 2 strokes of the pool (4 quads), never a node.
## Daniel, 2026-11-23 after seeing it: larger and yellow (it was ivory gold, 0.34 m tall).
const BANG_COLOR := Color(1.0, 0.9, 0.1)
## Above the life and Quebra bars, so the dot reads (at 0.5 the bars covered it: a yellow bar, not a "!").
const BANG_RISE := 1.05
## The light pushed past the strokes' usual tone (it read olive on the GPU at 1.0).
const BANG_GLOW := 1.45
const BANG_BAR := 0.62
const BANG_DOT := 0.18
const BANG_GAP := 0.14
const BANG_WIDTH := 0.18
const BANG_BIG := 1.45
const BANG_PULSE := 0.4
const BANG_PULSE_TIME := 0.12


## The size of the "!" `age` seconds after it lit: a short swell that settles (1 at rest).
static func bang_pulse(age: float) -> float:
	return 1.0 + BANG_PULSE * (1.0 - smoothstep(0.0, BANG_PULSE_TIME, age))


func alert(e: Enemy, age: float) -> void:
	var d := e.def
	var big := BANG_BIG if (d.elite or d.heavy) else 1.0
	var s := bang_pulse(age) * big
	var base := Vector3(e.pos.x, e.y + d.size * 1.9 + BANG_RISE, e.pos.y)
	var up := _up.normalized()
	var color := toned(lit(BANG_COLOR), BANG_GLOW)
	var width := BANG_WIDTH * s
	# the dot at the base, then the gap, then the bar (the gap counted from the dot's top, ink included, or the two
	# strokes join into one yellow block)
	var bottom := base + up * (BANG_DOT + BANG_GAP + INK_EDGE * 2.0) * s
	var top := bottom + up * BANG_BAR * s
	var dot_base := base
	# ink first for both strokes, then the light (strokes that meet put all their ink first)
	_stroke(bottom, top, width, color, 1.0, 1)
	_stroke(dot_base, dot_base + up * BANG_DOT * s, width, color, 1.0, 1)
	_stroke(bottom, top, width, color, 1.0, 2)
	_stroke(dot_base, dot_base + up * BANG_DOT * s, width, color, 1.0, 2)


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
func armor_hit(at: Vector3, dir: Vector2, n := ABSORB_SPARKS) -> void:
	_scatter(at, dir, n, ABSORB_TIME, 0.09, Shape.DOT)


## Combate C1 (combate_c1_leitura 7): a heavy blow or an Omega on armor throws more sparks, its edge stays HEAVY_EDGE s.
const HEAVY_SPARKS := 10
const HEAVY_EDGE := 0.18
## The armor's wear in steps (share of the armor left under 75, 50 and 25%, then gone) and what the crowd shader draws
## for each (its armored rim light and its gold fade out in steps).
const WEAR_STEPS: Array[float] = [0.75, 0.5, 0.25]
const WEAR_DRAWN: Array[float] = [0.0, 0.25, 0.55, 0.8, 1.0]
const CRACK_SHARDS := 6
const CRACK_SHARDS_GUARDIAN := 10
const CRACK_SPEED := 0.7


## 0 to 3: how many of 75, 50 and 25% the armor is under; 4: gone. 0 for a body with no armor to begin with.
static func wear_level(armor: float, max_armor: float) -> int:
	if max_armor <= 0.0:
		return 0
	if armor <= 0.0:
		return 4
	var left := armor / max_armor
	var n := 0
	for s in WEAR_STEPS:
		if left < s:
			n += 1
	return n


## How worn the armor is drawn (0..1, CrowdRenderer.state): WEAR_DRAWN of its level.
static func wear(armor: float, max_armor: float) -> float:
	return WEAR_DRAWN[wear_level(armor, max_armor)]


## The armor cracked at 75, 50 or 25%: half the shards of its break, flung slower from the chest toward the paladin.
func armor_crack(at: Vector3, dir: Vector2, size: float, guardian := false) -> void:
	_scatter(at, dir, CRACK_SHARDS_GUARDIAN if guardian else CRACK_SHARDS, BREAK_TIME, 0.11 * maxf(size, 1.0), Shape.SHARD,
		OLD_GOLD, CRACK_SPEED)


## The armor broke: its shards, once.
func armor_break(at: Vector3, size: float, color := OLD_GOLD) -> void:
	_scatter(at, Vector2.ZERO, BREAK_SHARDS, BREAK_TIME, 0.11 * maxf(size, 1.0), Shape.SHARD, color)
	if color == POISE_BREAK and _arcs.size() < 4:
		var a := Arcs.new()
		a.at = at
		a.size = maxf(size, 0.8)
		a.turn = _rng.randf() * TAU
		_arcs.append(a)


func _scatter(at: Vector3, dir: Vector2, n: int, time: float, size: float, shape: Shape, color := OLD_GOLD, speed := 1.0) -> void:
	for i in n:
		if _sparks.size() >= MAX_SPARKS:
			return
		var s := Spark.new()
		var a := _rng.randf() * TAU
		var out := Vector3(cos(a), _rng.randf_range(0.2, 1.0), sin(a)) * _rng.randf_range(0.5, 1.0)
		s.pos = at
		s.vel = (out + Vector3(dir.x, 0, dir.y) * 0.8) * SPARK_SPEED * speed
		s.total = time * _rng.randf_range(0.7, 1.0)
		s.life = s.total
		s.size = size * _rng.randf_range(0.7, 1.3)
		s.shape = shape
		s.color = color
		s.turn = _rng.randf() * TAU
		_sparks.append(s)


func commit() -> void:
	for s in _sparks:
		var k := s.life / s.total
		_put(s.shape, s.pos, Vector2(s.size, s.size * (1.8 if s.shape == Shape.SHARD else 1.0)), s.color, k, s.turn)
	for a in _arcs:
		# the ring cut in arcs, parting outward and fading: it reads as the guard breaking, with no text
		var k := 1.0 - a.life / POISE_ARC_TIME
		var r := a.size * lerpf(POISE_ARC_GROW.x, POISE_ARC_GROW.y, sqrt(k)) * 2.0
		var tone := toned(lit(POISE_BREAK), POISE_ARC_TONE)
		for i in POISE_ARCS:
			_put(Shape.ARC, a.at, Vector2(r, r), tone, 1.0 - k, a.turn + k * 0.5 + TAU * i / POISE_ARCS, POISE_ARC_THICK)
	for c in _cuts:
		# the thread parts from the middle to both ends in WARD_CUT_TIME, thinning as it goes
		var open := 1.0 - c.life / WARD_CUT_TIME
		var color := toned(lit(OLD_GOLD), WARD_TONE)
		_stroke(c.from, c.from.lerp(c.to, 0.5 - 0.5 * open), WARD_WIDTH, color, WARD_ALPHA * (1.0 - open), 2, false)
		_stroke(c.from.lerp(c.to, 0.5 + 0.5 * open), c.to, WARD_WIDTH, color, WARD_ALPHA * (1.0 - open), 2, false)
	for f in _flung:
		var k := f.life / GUARD_FLING_TIME
		_floor(Shape.STREAK, f.at + f.out * (GUARD_FLING_REACH * (1.0 - k)), f.dir, GUARD_STREAK, toned(lit(STEEL), STEEL_TONE), GUARD_FAR * k)
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


## Where the guard's streak `i` lies round `e`: its place on the floor and the way it runs (along the arc).
static func guard_streak(e: Enemy, i: int) -> Array:
	var ahead := e.face if e.face != Vector2.ZERO else e.dir
	ahead = ahead.normalized() if ahead != Vector2.ZERO else Vector2.DOWN
	var a := deg_to_rad(lerpf(-GUARD_ARC, GUARD_ARC, float(i) / (GUARD_STREAKS - 1)))
	var radial := ahead.rotated(a)
	var at := e.pos + radial * (e.def.radius + GUARD_REACH)
	return [Vector3(at.x, GUARD_Y, at.y), radial, Vector2(-radial.y, radial.x)]


## The Escudo's guard on the floor for this frame. up: Horde.guard_up (the rule's own condition); near: the paladin is
## in front of it, inside what it covers (Horde.blocks_front); open_t: the seconds its guard stays open (it comes back
## one streak at a time over the last GUARD_BACK); block_t: share of a blow just shut (0 to 1).
func guard_marks(e: Enemy, up: bool, near: bool, block_k: float) -> void:
	var back := e.open_t if e.open_t > 0.0 else -1.0
	if not up and not (back > 0.0 and back <= GUARD_BACK and not e.helpless() and e.state != Enemy.State.RECOVER):
		return
	var base := GUARD_NEAR if near else GUARD_FAR
	var color := toned(lit(STEEL), STEEL_TONE)
	for i in GUARD_STREAKS:
		if not up:
			# the guard closing: the streak of rank r is back when GUARD_BACK - r * GUARD_BACK_STEP is left to it
			var rank := GUARD_ORDER.find(i)
			var shown := clampf((GUARD_BACK - back) / GUARD_BACK_STEP - float(rank) + 1.0, 0.0, 1.0)
			if shown <= 0.0:
				continue
			_place(e, i, color, base * shown)
			continue
		var alpha := base
		if i == GUARD_STREAKS / 2:
			alpha = lerpf(base, GUARD_BLOCK_ALPHA, block_k)
		_place(e, i, color, alpha)


func _place(e: Enemy, i: int, color: Color, alpha: float) -> void:
	var s := guard_streak(e, i)
	_floor(Shape.STREAK, s[0], s[2], GUARD_STREAK, color, alpha)


## The guard opens: its streaks fly out and fade (only drawn).
func guard_fling(e: Enemy) -> void:
	for i in GUARD_STREAKS:
		var s := guard_streak(e, i)
		var f := Flung.new()
		f.at = s[0]
		f.out = Vector3(s[1].x, 0.0, s[1].y)
		f.dir = s[2]
		_flung.append(f)


## Combate C1 (combate_c1_leitura 3): the priest's thread to what it armored, from its palm to the chest, as long as the
## ward holds. Old gold, light only (no ink), drawn under whatever stands in front; a bead runs along it from the priest
## in WARD_BEAD s, so the way says who gives. close: the paladin is near the priest (the thread reads more).
const WARD_WIDTH := 0.045
const WARD_ALPHA := 0.30
const WARD_ALPHA_CLOSE := 0.55
const WARD_CLOSE_M := 4.0
const WARD_TONE := 0.55
const WARD_BEAD := 0.9
const WARD_BEAD_SIZE := 0.18
const WARD_BEAD_ALPHA := 0.8
const WARD_THREADS := 6
const WARD_CUT_TIME := 0.18


func ward_thread(from: Vector3, to: Vector3, close: bool, now: float, seed_phase: float) -> void:
	var color := toned(lit(OLD_GOLD), WARD_TONE)
	_stroke(from, to, WARD_WIDTH, color, WARD_ALPHA_CLOSE if close else WARD_ALPHA, 2, false)
	var bead := fposmod(now / WARD_BEAD + seed_phase, 1.0)
	_put(Shape.DOT, from.lerp(to, bead), Vector2.ONE * WARD_BEAD_SIZE, color, WARD_BEAD_ALPHA)


## The priest fell: this thread (from its palm to the chest it armored) parts from the middle to both ends in WARD_CUT_TIME.
func ward_cut(from: Vector3, to: Vector3) -> void:
	if _cuts.size() >= WARD_THREADS:
		return
	var c := Cut.new()
	c.from = from
	c.to = to
	c.life = WARD_CUT_TIME
	_cuts.append(c)


## GR-7 (combate_c1_leitura 8): Morvath's two eyes, two points of pale violet on his face (EnemyDef/bake mark "head"), 0.10 m
## each, a little to each side and ahead of the head's middle (meters at size 1). Not drawn over: from behind they are
## gone with the head. They go out while he is stunned and rise 20% in his wind-up. Never red, never past the glow's threshold.
const EYE_COLOR := Color(0.74, 0.55, 1.0)
const EYE_SIZE := 0.10
const EYE_ALPHA := 0.9
const EYE_SIDE := 0.05
const EYE_AHEAD := 0.14
const EYE_WINDUP := 1.2


func eyes(head: Vector3, yaw: float, size: float, winding: bool, stunned: bool) -> void:
	if stunned:
		return
	var turn := Basis(Vector3.UP, yaw)
	var k := EYE_WINDUP if winding else 1.0
	for side: float in [-1.0, 1.0]:
		_put(Shape.DOT, head + turn * (Vector3(side * EYE_SIDE, 0.0, EYE_AHEAD) * size), Vector2.ONE * EYE_SIZE,
			Color(EYE_COLOR.r * k, EYE_COLOR.g * k, EYE_COLOR.b * k), minf(EYE_ALPHA * k, 1.0))
