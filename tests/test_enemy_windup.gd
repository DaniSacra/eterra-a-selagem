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


func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev._args.erase("seed")


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
		assert_gte(armed, 0.3, "%s %s: armed %.2f m from the guard" % [id, clip, armed])
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
