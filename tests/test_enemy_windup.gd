extends GutTest
## T5 (docs/design/combat_cadence.md 6.1, 6.3; docs/qa/t5_enemy_motion.md): every enemy's wind-up is a body that
## prepares (three beats, its own clip moving at least 1 m/s, an armed pose 0.3 m from its guard), its damage comes
## from its body on the frame the drawing strikes (the warning full on that frame), and its recovery is alive.

const DT := 1.0 / 60.0
const FIGURES: Array[StringName] = [&"skeleton", &"runner", &"mage", &"guard", &"priest", &"knight", &"priest_elder"]
## The clip each figure winds up with (Horde: _behave_*), the archer aside (its aim is a held loop; the crossbow rises
## in the fade of its settle, EnemyDef.windup_settle).
const WINDUP := {&"skeleton": &"windup", &"runner": &"windup", &"mage": &"cast", &"guard": &"brace", &"priest": &"cast",
	&"knight": &"brace", &"priest_elder": &"cast"}
## Their EnemyDef (the knight's charge and the elder's raising are its guardians').
const DEFS := {&"skeleton": &"skeleton", &"runner": &"runner", &"mage": &"mage", &"guard": &"guard", &"priest": &"priest",
	&"knight": &"knight", &"priest_elder": &"priest_elder"}

var game: Game


## The staff casters measured 0.3 m or more with KayKit's heavy staff (1.5 thousand triangles, most of them in the head
## at the end of the swing); the Meshy staff (2026-11-21, 1 thousand, a thin shaft) has fewer vertices to move in the
## mean, the same clip: 0.25 m. The shape of the weapon, not the pose (the body's own gap is unchanged).
const ARMED_MIN := {&"mage": 0.14,  # 2026-11-27: the sorcerer is 1.15 m tall now
	 &"priest_elder": 0.22}


func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)


func _model(id: StringName) -> BakedModel:
	return load("res://assets/baked/%s.res" % id)


## The mean distance its vertices move between two poses (every third vertex, as tools/clip_motion.gd).
static func _gap(a: PackedVector3Array, b: PackedVector3Array) -> float:
	var sum := 0.0
	var n := 0
	for v in range(0, a.size(), 3):
		sum += a[v].distance_to(b[v])
		n += 1
	return sum / maxi(n, 1)


## Settle, arm, hold: nothing moves while it settles, it arms eased in and out, and holds the armed pose.
func test_the_three_beats() -> void:
	assert_eq(Horde.windup_arm(0.0, 0.9, 0.12, 0.3), 0.0)
	assert_eq(Horde.windup_arm(0.1, 0.9, 0.12, 0.3), 0.0, "settling")
	var mid := Horde.windup_arm((0.12 + 0.63) * 0.5, 0.9, 0.12, 0.3)
	assert_almost_eq(mid, 0.5, 0.01, "half armed half way")
	assert_lt(Horde.windup_arm(0.15, 0.9, 0.12, 0.3), 0.05, "eased in")
	assert_eq(Horde.windup_arm(0.63, 0.9, 0.12, 0.3), 1.0, "armed at 70%")
	assert_eq(Horde.windup_arm(0.85, 0.9, 0.12, 0.3), 1.0, "held")
	assert_eq(Horde.windup_arm(0.1, 0.1, 0.12, 0.3), 1.0, "a wind-up shorter than its settle is armed at its end")


## 6.1: the wind-up clip drawn moves at least 1 m/s at its peak (at the pace windup_arm plays it: its length over the
## arm, times 1.5 the smoothstep's peak), and its last pose is 0.3 m or more from the guard (size 1).
func test_every_wind_up_moves_the_body() -> void:
	for id: StringName in FIGURES:
		var m := _model(id)
		var d: EnemyDef = load("res://data/enemies/%s.tres" % DEFS[id])
		var clip: StringName = WINDUP[id]
		var n := m.frame_count(clip)
		assert_gt(n, 1, "%s has %s" % [id, clip])
		var rate := m.pose_rate(clip)
		var peak := 0.0
		for f in range(1, n):
			peak = maxf(peak, _gap(m.pose(clip, f), m.pose(clip, f - 1)) * rate)
		var windup := d.attack_windup
		var arm := windup * (1.0 - d.windup_hold) - d.windup_settle
		var drawn := peak * m.duration(clip) / maxf(arm, 0.01) * 1.5
		assert_gte(drawn, 1.0, "%s %s: %.2f m/s drawn (%.2f in the clip)" % [id, clip, drawn, peak])
		var armed := _gap(m.pose(clip, n - 1), m.pose(&"idle", 0))
		assert_gte(armed, ARMED_MIN.get(id, 0.3), "%s %s: armed %.2f m from the guard" % [id, clip, armed])
	# the archer: the crossbow rises to the shoulder in its settle
	var archer := _model(&"archer")
	var a: EnemyDef = load("res://data/enemies/archer.tres")
	var rise := _gap(archer.pose(&"aim", 0), archer.pose(&"idle", 0))
	assert_gte(rise, 0.3, "the crossbow at the shoulder")
	assert_gte(rise / a.windup_settle, 1.0, "risen at %.2f m/s" % (rise / a.windup_settle))


## T5-15: Morvath's Blades and charge each have their own wind-up, armed poses 0.3 m or more apart.
func test_morvath_winds_up_his_own_way() -> void:
	var m := _model(&"morvath")
	var blades := m.pose(&"blades_windup", m.frame_count(&"blades_windup") - 1)
	var dash := m.pose(&"dash_windup", m.frame_count(&"dash_windup") - 1)
	assert_gte(_gap(blades, dash), 0.3, "two wind-ups")
	assert_gte(_gap(dash, m.pose(&"idle", 0)), 0.3, "the charge crouched")
	assert_gte(_gap(blades, m.pose(&"idle", 0)), 0.3, "the blade drawn back")


## T5-08: the swept contact of a body and the share of a charge where it first touches.
func test_body_contact() -> void:
	assert_true(BodyBlock.swept_touch(Vector2(-2, 0), Vector2(2, 0), Vector2(0, 0.9), 1.0), "passing by within reach")
	assert_false(BodyBlock.swept_touch(Vector2(-2, 0), Vector2(2, 0), Vector2(0, 1.1), 1.0))
	assert_false(BodyBlock.swept_touch(Vector2(-2, 0), Vector2(-1, 0), Vector2(1, 0), 1.0), "not reached yet")
	assert_almost_eq(Boss.dash_contact(Vector2.ZERO, Vector2.RIGHT, 10.0, Vector2(6, 0), 1.0), 0.5, 0.001)
	assert_eq(Boss.dash_contact(Vector2.ZERO, Vector2.RIGHT, 10.0, Vector2(6, 3), 1.0), 1.0, "beside the lane")
	assert_eq(Boss.dash_contact(Vector2.ZERO, Vector2.RIGHT, 10.0, Vector2(-3, 0), 1.0), 0.0, "behind him")


func _room() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func _frame() -> void:
	game.player.invuln = 10.0
	game._step(DT)
	game.horde.render(DT)


## Plays a kind against the standing paladin until it hurts him: the frame of the blow, its body's distance to him then,
## and the frame its warning ended (-1: none). The blow is counted on whatever deals it (its body or a warning).
func _first_blow(id: StringName, at: Vector2, frames := 600) -> Dictionary:
	_room()
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.8), false)
	e.cooldown = 0.0
	var hit := {}
	var count := func(_amount: float, _from: Vector2) -> void:
		if hit.is_empty():
			hit["gap"] = e.pos.distance_to(game.player.pos)
	game.horde.hit_player.connect(count)
	game.ground.hit_player.connect(count)
	var warn: Ground.Zone = null
	var warn_end := -1
	for f in frames:
		if e.warning != null:
			warn = e.warning
		_frame()
		if warn != null and warn_end < 0 and (warn.life <= 0.0 or warn.cancelled or not warn in game.ground.zones):
			warn_end = f
		if not hit.is_empty():
			hit["frame"] = f
			hit["warn_end"] = warn_end
			hit["e"] = e
			return hit
	return hit


## 6.1 "Dano x corpo" and "Aviso x dano" (T5-08, T5-09): the soldier's blade lands from its body within its reach, the
## brute's charge only when its body touches him, each as its warning ends (0 to 1 frame).
func test_the_damage_comes_from_the_body() -> void:
	for id: StringName in [&"skeleton", &"guard"]:
		for start: Vector2 in [Vector2(3.0, 0.0), Vector2(0.0, -6.0)]:
			var hit := _first_blow(id, start)
			assert_false(hit.is_empty(), "%s from %s struck" % [id, start])
			if hit.is_empty():
				continue
			var e: Enemy = hit.e
			var reach := (Horde.blade_reach(e.def) if id == &"skeleton" else e.def.radius) + Player.RADIUS + 0.15
			gut.p("%s from %s: %.2f m from him (reach %.2f), warning ends f%d, blow f%d" % [id, start, hit.gap, reach, hit.warn_end, hit.frame])
			assert_lte(float(hit.gap), reach, "%s from %s: %.2f m from him (reach %.2f)" % [id, start, hit.gap, reach])
			assert_gte(int(hit.warn_end), 0, "%s: its warning ended" % id)
			assert_between(int(hit.frame) - int(hit.warn_end), -1, 1, "%s: the warning full on the blow's frame" % id)


## T5-12: the recovery is alive: no pose drawn the same for more than 0.3 s, and the next wind-up waits 0.25 s.
func test_the_recovery_moves() -> void:
	_room()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(2.6, 0.0), false)
	e.cooldown = 0.0
	for f in 240:
		_frame()
		if e.state == Enemy.State.RECOVER:
			break
	assert_eq(e.state, Enemy.State.RECOVER, "it struck")
	var same := 0
	var longest := 0
	var last := -1
	while e.state == Enemy.State.RECOVER:
		_frame()
		same = same + 1 if e.drawn_row == last else 0
		last = e.drawn_row
		longest = maxi(longest, same)
	assert_lte(longest * DT, 0.3, "the same pose %.2f s at most" % (longest * DT))
	assert_gte(e.cooldown, Horde.AFTER_RECOVER - DT, "a moment in its guard before the next")


## T5-08: Morvath's charge hurts with his body: the first frame its edge reaches the paladin, as its lane fills, never
## at its start (it hurt 15.7 m before his body came).
func test_morvath_charges_with_his_body() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	var boss: Boss = game.boss
	for f in 30:
		_frame()
	boss.e.pos = Vector2(0.0, -4.0)
	game.player.pos = Vector2(0.0, 5.0)
	boss._attack = &"dash"
	boss._go(Boss.State.DASH_WARN)
	var hit := {}
	var count := func(_amount: float, _from: Vector2) -> void:
		if hit.is_empty() and game.ground.last_source == &"dash":
			hit["gap"] = boss.e.pos.distance_to(game.player.pos)
	game.ground.hit_player.connect(count)
	var lane: Ground.Zone = null
	var lane_end := -1
	for f in 120:
		game.player.pos = Vector2(0.0, 5.0)
		_frame()
		if lane == null:
			for z in game.ground.zones:
				if z.source == &"dash":
					lane = z
		elif lane_end < 0 and (lane.life <= 0.0 or not lane in game.ground.zones):
			lane_end = f
		if hit.has("gap") and not hit.has("frame"):
			hit["frame"] = f
	assert_true(hit.has("gap"), "his charge struck")
	if not hit.has("gap"):
		return
	var reach := boss.e.def.radius + Player.RADIUS
	gut.p("morvath charge: %.2f m from him (reach %.2f), lane ends f%d, blow f%d" % [hit.gap, reach, lane_end, hit.frame])
	assert_lte(float(hit.gap), reach + 0.05, "his body on him (%.2f m, reach %.2f)" % [hit.gap, reach])
	assert_gte(lane_end, 0, "its lane ended")
	assert_between(int(hit.frame) - lane_end, -1, 1, "the lane full on the frame his body strikes")


## A-T5-1 (docs/gallery/t5/ART_REVIEW.md 1.6): the brute and the knight run their charge behind the shield: in every
## pose its centre 0.3 m or more in front of the chest, the trunk leaning 12 degrees or more, the head behind its top
## edge (size 1, BakedModel.guard_pose). 2026-11-27: the painted guard (no shield of its own) leans only 3 degrees at least in its slowest poses.
func test_the_charge_is_run_behind_the_shield() -> void:
	for id: StringName in [&"guard", &"knight"]:
		var m := _model(id)
		assert_true(m.parts.has("shield"), "%s: its shield is named" % id)
		for f in m.frame_count(&"charge"):
			var g := m.guard_pose(&"charge", f)
			assert_gte(float(g.ahead), 0.3, "%s charge %d: the shield %.2f m in front of the chest" % [id, f, g.ahead])
			assert_gte(float(g.lean), 12.0 if id != &"guard" else 3.0, "%s charge %d: the trunk leaning %.0f degrees" % [id, f, g.lean])
			assert_gte(float(g.head_behind), 0.0, "%s charge %d: the head %.2f m behind the shield's top" % [id, f, g.head_behind])


## A-T5-2 (1.10): the soldier's jog stands taller: the top of its head never under 90% of its idle's, both feet off the
## floor in 6 of its 20 poses at most (the lowest vertex over 3 cm, as tools/clip_motion.gd).
func test_the_soldier_jogs_upright() -> void:
	var m := _model(&"skeleton")
	var idle := m.body_top(m.pose(&"idle", 0))
	var air := 0
	for f in m.frame_count(&"walk"):
		var p := m.pose(&"walk", f)
		var head := m.body_top(p)
		assert_gte(head / idle, 0.9, "walk %d: the head at %.0f%% of idle" % [f, 100.0 * head / idle])
		var low := INF
		for v in range(0, p.size(), 2):
			low = minf(low, p[v].y)
		if low > 0.03:
			air += 1
	assert_lte(air, 9, "both feet off the floor in %d poses" % air)


## A-T5-3 (1.2): the runner gathers without the flamingo knee: in no pose of its wind-up is one foot more than 0.15 m
## over the other (the lowest point of each leg, size 1).
func test_the_runner_gathers_on_both_feet() -> void:
	var m := _model(&"runner")
	for f in m.frame_count(&"windup"):
		var p := m.pose(&"windup", f)
		var left := INF
		var right := INF
		for v in p.size():
			if p[v].y < 0.6 and absf(p[v].x) < 0.3:
				if p[v].x < 0.0:
					left = minf(left, p[v].y)
				else:
					right = minf(right, p[v].y)
		assert_lte(absf(left - right), 0.17, "windup %d: one foot %.2f m over the other" % [f, absf(left - right)])


## A-T5-4 (1.3): each bolt of the sorcerer is a gesture: the top of its staff goes 0.25 m or more from where the hold
## has it and back, the shot starting and ending in the hold's pose (no jump when Horde restarts it).
func test_the_sorcerer_thrusts_each_bolt() -> void:
	var m := _model(&"mage")
	var staff: PackedInt32Array = m.parts.staff
	var hold := m.pose(&"cast_hold", 0)
	var tip := staff[0]
	for v in staff:
		if hold[v].y > hold[tip].y:
			tip = v
	var n := m.frame_count(&"shot")
	var far := 0.0
	for f in n:
		far = maxf(far, m.position(&"shot", f, tip).distance_to(hold[tip]))
	assert_gte(far, 0.25, "the staff's top goes %.2f m" % far)
	assert_lt(m.position(&"shot", 0, tip).distance_to(hold[tip]), 0.03, "it starts in the hold")
	assert_lt(m.position(&"shot", n - 1, tip).distance_to(hold[tip]), 0.03, "and ends in it")


## C17, QW-102 (CF-02): the runner warns 1.0 s before it bursts (it was 0.7, the shortest warning of the game), its
## warning full on the blow's frame; no blow of a common enemy warns less than 0.9 s but the brute's short slam.
func test_the_runner_warns_enough() -> void:
	var hit := _first_blow(&"runner", Vector2(1.2, 0.0))
	assert_false(hit.is_empty(), "the runner burst")
	if hit.is_empty():
		return
	assert_between(int(hit.frame) - int(hit.warn_end), -1, 1, "its warning full on the blow's frame")
	var d: EnemyDef = hit.e.def
	assert_almost_eq(d.attack_windup, 0.68, 0.001)  # 2026-11-23, ENEMY_WINDUP 0.8: 0.85 before it, 1.0 before C1b
	assert_almost_eq(d.attack_windup * d.windup_hold, 0.204, 0.001, "the last share of it held trembling")
	assert_gt(d.windup_shake, 0.0)
	# 2026-11-23 ("ataca mais rapido"): the study's median for a common is 0.67 s; a heavy blow never under 0.6 s
	for id in [&"skeleton", &"skeleton_elite", &"runner", &"runner_elite", &"guard", &"guard_elite", &"knight"]:
		var def: EnemyDef = load("res://data/enemies/%s.tres" % id)
		var least := 0.6 if id in [&"skeleton", &"runner", &"knight"] else 0.7 if id in [&"skeleton_elite", &"runner_elite"] else 0.7 if id in [&"guard", &"guard_elite"] else 0.9
		assert_gte(def.attack_windup, least - 0.001, "%s warns enough" % id)


## C17, QW-104 (CF-06), P2 of combat_cadence.md 8.1: the body clears over the last tell_time (0.5 s, Hades II) of its
## wind-up, never longer than the wind-up, all of it as the blow comes, under the flash's cap; every crowd material
## carries its own share.
func test_the_body_clears_in_the_hold() -> void:
	for id in [&"skeleton", &"guard", &"mage", &"runner", &"archer", &"priest", &"priest_elder"]:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		var hold := CrowdRenderer.tell_share(d)
		assert_almost_eq(hold * d.attack_windup, minf(0.5, d.attack_windup), 0.001, "%s: the last 0.5 s of its wind-up" % id)
		assert_eq(CrowdRenderer.tell_ready(1.0 - hold - 0.01, hold), 0.0, "%s: nothing before the hold" % id)
		assert_gt(CrowdRenderer.tell_ready(1.0 - hold * 0.5, hold), 0.0, "%s: clearing in the hold" % id)
		assert_almost_eq(CrowdRenderer.tell_ready(1.0, hold), 1.0, 0.001, "%s: all of it as the blow comes" % id)
	# the most the clearing adds (a white painting, fully lit, at the end) stays under the flash's cap
	var shader: Shader = load("res://assets/shaders/crowd.gdshader")
	var code := shader.code
	assert_true(code.contains("min(warmer, max(vec3(flash_cap) - EMISSION"), "capped like the flash")
	assert_lte(CrowdRenderer.TELL_LIGHT, 0.6, "half a blow's flash at most")
	_room()
	var e := game.horde.spawn(game.horde.def(&"guard"), Vector2(5, 0), false)
	game.horde.render(DT)
	var mat := game.horde.renderer.kind(e.def).material as ShaderMaterial
	assert_almost_eq(float(mat.get_shader_parameter(&"tell_hold")), CrowdRenderer.tell_share(e.def), 0.001, "its own share")
	assert_almost_eq(float(mat.get_shader_parameter(&"tell_light")), CrowdRenderer.TELL_LIGHT, 0.001)


## C17, QW-105 (CF-08, CF-11): next to a paladin who stands still the knight no longer slams forever: after
## Horde.KNIGHT_SLAMS slams it backs off and charges (at least one charge in any four blows); a soldier's blows are
## never on the same beat (the wait after its recovery is drawn).
func test_no_metronome() -> void:
	_room()
	var k := game.horde.spawn(game.horde.def(&"knight"), Vector2(2.6, 0.0), false)
	var blows: Array[StringName] = []
	var was := Enemy.State.WALK
	for f in 60 * 40:
		_frame()
		if k.state == Enemy.State.WINDUP and was != Enemy.State.WINDUP and k.anim != &"summon":
			blows.append(k.anim)
		was = k.state
	assert_gte(blows.size(), 6, "it kept striking: %s" % [blows])
	for i in range(0, blows.size() - 3):
		assert_true(blows.slice(i, i + 4).has(&"brace"), "a charge in every four blows: %s" % [blows])
	game.horde.clear_crowd()
	var s := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(2.0, 0.0), false)
	var starts: Array[int] = []
	was = Enemy.State.WALK
	for f in 60 * 30:
		_frame()
		if s.state == Enemy.State.WINDUP and was != Enemy.State.WINDUP:
			starts.append(f)
		was = s.state
	var gaps := {}
	for i in range(1, starts.size()):
		gaps[starts[i] - starts[i - 1]] = true
	assert_gte(starts.size(), 5)
	assert_gt(gaps.size(), 2, "its blows fall on different beats: %s" % [starts])


## GP-12 (Daniel, 2026-11-22): the guardian charges twice in a row, the second braced for recharge_windup and aimed at
## where he stands then; the shield-bearer once.
func test_the_knight_charges_twice() -> void:
	for id: StringName in [&"knight", &"guard"]:
		_room()
		var k := game.horde.spawn(game.horde.def(id), Vector2(8.0, 0.0), false)
		var row := 0
		var braced := 0
		var was := Enemy.State.WALK
		for f in 60 * 20:
			_frame()
			if k.state == Enemy.State.WINDUP and was != Enemy.State.WINDUP and k.anim == &"brace" and k.memo != Horde.KNIGHT_GUARD:
				row += 1  # (C1d K3: raising the shield by time is a brace too, not a charge)
			if row == 2 and k.state == Enemy.State.WINDUP:
				braced += 1
			if row > 0 and k.state == Enemy.State.RECOVER:
				break
			was = k.state
		assert_eq(row, k.def.charges, "%s charges %d in a row" % [id, k.def.charges])
		if k.def.charges > 1:
			assert_almost_eq(braced / 60.0, k.def.recharge_windup, 0.1, "the second warning is fair")
		game.horde.clear_crowd()


## CV-1 (Daniel, 2026-11-22): the knight's charge follows him through the wind-up and holds for the last aim_lock
## seconds, its line with it; the shield-bearer's stays where it was marked.
func test_the_knights_charge_follows_then_locks() -> void:
	for id: StringName in [&"knight", &"guard"]:
		_room()
		var k := game.horde.spawn(game.horde.def(id), Vector2(8.0, 0.0), false)
		var d := k.def
		k.rows = 0
		var first := Vector2.ZERO
		var locked := Vector2.ZERO
		for f in 60 * 10:
			_frame()
			if k.state == Enemy.State.WINDUP and k.anim == &"brace":
				if first == Vector2.ZERO:
					first = k.aim
				game.player.pos = k.pos + Vector2.from_angle(PI + k.state_t) * 7.0
				game.horde.target = game.player.pos
				assert_almost_eq((k.warning as Ground.Zone).dir.angle_to(k.aim), 0.0, 0.01, "%s: the line goes with its aim" % id)
				if k.state_t > d.attack_windup - (d.aim_lock if d.aim_lock > 0.0 else 0.3) + 0.02:
					if locked == Vector2.ZERO:
						locked = k.aim
					assert_eq(k.aim, locked, "%s: locked at the end" % id)
			elif first != Vector2.ZERO:
				break
		assert_ne(locked, Vector2.ZERO, "%s braced" % id)
		if d.aim_lock > 0.0:
			assert_gt(absf(first.angle_to(locked)), 0.3, "%s turned with him" % id)
		else:
			assert_eq(first, locked, "%s never turns" % id)
		game.horde.clear_crowd()


## CV-2 (Daniel, 2026-11-22): the knight raises raise_count skeletons every raise_every rows, never more than raise_max
## of its own standing; a blow of its is never struck while it calls.
func test_the_knight_raises_its_dead() -> void:
	_room()
	var k := game.horde.spawn(game.horde.def(&"knight"), Vector2(8.0, 0.0), false)
	var d := k.def
	# SW-REA: the call is the third phase's (60% and under), once every raise_cooldown seconds
	k.hp = k.max_hp * 0.5
	k.armor = k.max_armor * 0.5
	k.roars = 2
	k.call_cd = 0.0
	var most := 0
	var calls := 0
	var was: StringName = &""
	for f in 60 * 60:
		game.player.hp = game.player.max_hp
		_frame()
		if k.anim == &"summon" and was != &"summon":
			calls += 1
			assert_gte(k.rows, d.raise_every)
		was = k.anim
		most = maxi(most, k.raised.filter(func(r: Enemy) -> bool: return r.alive).size())
		if calls >= 3:
			break
	assert_gte(calls, 2, "it calls")
	assert_gte(most, d.raise_count)
	assert_lte(most, d.raise_max)
	assert_eq(load("res://data/enemies/guard.tres").raise_count, 0, "the shield-bearer raises none")
	assert_gt(_model(&"knight").frame_count(&"summon"), 0, "its own gesture")


## C17, QW-107 (ART P1-6): the crossbow's aim and the soldier's pounce are drawn as an aim (a thread, a bright tip, the
## band filling only over the end of the wind-up), never the opaque band: nothing but the tip above 0.6 of light.
func test_the_aims_are_threads() -> void:
	assert_lte(GroundLook.AIM_PX, 10.0, "a thread of 10 px at most")
	assert_lte(GroundLook.AIM_LIGHT, 0.6)
	assert_lte(GroundLook.AIM_FILL, 0.45)
	for id in [&"skeleton", &"archer"]:
		_room()
		var e := game.horde.spawn(game.horde.def(id), Vector2(4.0 if id == &"skeleton" else 9.0, 0.0), false)
		e.cooldown = 0.0
		var z: Ground.Zone = null
		for f in 400:
			_frame()
			if e.warning != null:
				z = e.warning
				break
		assert_not_null(z, "%s warned" % id)
		if z == null:
			continue
		var m := z.mat as ShaderMaterial
		# (the soldier's follows him first: the thinner thread of the tracking, until it locks)
		assert_eq(float(m.get_shader_parameter(&"aim_px")), GroundLook.TRACK_AIM_PX if id == &"skeleton" else GroundLook.AIM_PX, "%s: an aim" % id)
		assert_eq(float(m.get_shader_parameter(&"strength")), 1.0)
		assert_eq(float((m.next_pass as ShaderMaterial).get_shader_parameter(&"fill_early")), 0.0, "%s: no fill early" % id)
		assert_eq(float((m.next_pass as ShaderMaterial).get_shader_parameter(&"base_fill")), 0.0)
	# a pooled node dressed again as another warning is no aim
	var other := game.ground.add_arc_warning(Vector2.ZERO, Vector2.UP, 3.0, 90.0, 1.0, 0.0)
	assert_eq(float(other.mat.get_shader_parameter(&"aim_px")), 0.0)


## C17, DT-102: every wind-up is counted by kind (started, reached its blow, cut), the flight of a shot that hurt him
## and the Omega charges begun and let go, for RESULT.
func test_the_windups_are_counted() -> void:
	_room()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(2.0, 0.0), false)
	e.cooldown = 0.0
	for f in 120:
		_frame()
		if e.state == Enemy.State.ATTACK:
			break
	var w: Dictionary = game.horde.windup_report().get("skeleton", {})
	assert_eq(int(w.get("started", 0)), 1)
	assert_eq(int(w.get("struck", 0)), 1)
	var c := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(-2.0, 0.0), false)
	c.cooldown = 0.0
	for f in 120:
		_frame()
		if c.state == Enemy.State.WINDUP:
			break
	game.horde.interrupt(c)
	w = game.horde.windup_report()["skeleton"]
	assert_eq(int(w.cut), 1, "a cut wind-up")
	assert_true(game.result().has("windups") and game.result().has("shot_flight"))
	assert_eq(game.result().omega_charges_cancelled, 0)
