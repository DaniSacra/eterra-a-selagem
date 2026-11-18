extends GutTest
## T5b (docs/qa/t5b_boss_fight.md; PO: "a luta com o boss ainda está estranha, tem uns esqueletos pulando novamente"):
## the sorcerer and the crossbowman jog with their feet on the floor (P1-1), the sorcerer's rise ends standing in its
## guard and fades into its walk (P1-2), a change of clip fades into the new clip's own blend, never its nearest pose
## (P1-3), and a risen body waits ARRIVE before its first wind-up (P1-5). Morvath's turn: test_boss_body.gd (P1-4).

const DT := 1.0 / 60.0
## P1-1, at size 1: the whole body over AIR_OVER m in at most AIR_POSES of the walk's 20 poses, its lowest vertex never
## over LOWEST, the middle of the body (what it carries left out) rising and falling at most BOB. The review asked 7 cm;
## the jog keeps 7.3 to 7.4 (the soldier's, approved in T5, 8.6): the legs' own lift in the body's mean.
## The runner (PO, 2026-11-18: "ainda tem esqueleto que anda tremendo", the rust one) hopped on Running_B: the whole body
## over 0.10 m in 14 of 20 poses, up to 0.34 m, rising and falling 0.23 m. It jogs too, on a long stride.
const JOGGERS: Array[StringName] = [&"mage", &"archer", &"skeleton", &"runner"]
const AIR_OVER := 0.10
const AIR_POSES := 6
const LOWEST := 0.15
const BOB := {&"mage": 0.075, &"archer": 0.075, &"skeleton": 0.09, &"runner": 0.09}
## P1-3: the loops are this short at most, so the share of a fade into a loop's last pose keeps 1/32 or better on the
## Compatibility renderer's half floats (CrowdRenderer.fade_target).
const LONGEST_LOOP := 30

var game: Game


func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test (tests/hooks/pre_run.gd, BUG-109)


func _model(id: StringName) -> BakedModel:
	return load("res://assets/baked/%s.res" % id)


func _middle_y(m: BakedModel, p: PackedVector3Array) -> float:
	var carried := m.carried_mask()
	var sum := 0.0
	var n := 0
	for v in p.size():
		if carried[v] == 0:
			sum += p[v].y
			n += 1
	return sum / maxf(n, 1)


func test_the_sorcerer_and_the_crossbowman_jog_on_the_floor() -> void:
	for id in JOGGERS:
		var m := _model(id)
		var air := 0
		var worst := -INF
		var lo := INF
		var hi := -INF
		for f in m.frame_count(&"walk"):
			var p := m.pose(&"walk", f)
			var low := INF
			for v in p.size():
				low = minf(low, p[v].y)
			if low > AIR_OVER:
				air += 1
			worst = maxf(worst, low)
			var mid := _middle_y(m, p)
			lo = minf(lo, mid)
			hi = maxf(hi, mid)
		gut.p("%s: %d of 20 poses in the air, lowest up to %.2f m, the body rises and falls %.3f m" % [id, air, worst, hi - lo])
		assert_lte(air, AIR_POSES, "%s: the whole body over %.2f m in %d poses" % [id, AIR_OVER, air])
		assert_lte(worst, LOWEST, "%s: its feet at most %.2f m off the floor (%.2f)" % [id, LOWEST, worst])
		assert_lte(hi - lo, float(BOB[id]), "%s: the body rises and falls %.3f m" % [id, hi - lo])


## P1-2: every figure's rise ends standing in its guard: its last pose near the first of its idle (the mean distance of
## its vertices, size 1) and its top (the body's, what it carries left out) at its idle's. The sorcerer's ended stooped,
## 0.40 m from its guard, its staff lying (the top at 1.88 m, its idle 2.65).
func test_every_rise_ends_standing() -> void:
	for id: StringName in [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"knight", &"priest", &"priest_elder"]:
		var m := _model(id)
		var n := m.frame_count(&"rise")
		var last := m.pose(&"rise", n - 1)
		var guard := m.pose(&"idle", 0)
		var far := 0.0
		for v in range(0, last.size(), 3):
			far += last[v].distance_to(guard[v])
		far /= ceilf(last.size() / 3.0)
		gut.p("%s: the rise ends %.2f m from its guard, its top %.2f of its idle's" % [id, far, m.body_top(last) / m.body_top(guard)])
		assert_lte(far, 0.25, "%s: the rise ends %.2f m from its guard" % [id, far])
		assert_gte(m.body_top(last) / m.body_top(guard), 0.92, "%s: and standing" % id)
	var mage := _model(&"mage")
	var end := mage.pose(&"rise", mage.frame_count(&"rise") - 1)
	var top := -INF
	for v in end:
		top = maxf(top, v.y)
	var idle_top := -INF
	for v in mage.pose(&"idle", 0):
		idle_top = maxf(idle_top, v.y)
	assert_almost_eq(top, idle_top, 0.1, "the sorcerer's staff upright at the end of its rise")


## P2-2: the rise keeps its hips over the figure's place ("in_place"): the soldier's body slid 0.46 m forward while it
## rose (the middle of its poses from z -0.45 to 0.01, size 1), now at most 0.25 m from its place.
func test_the_soldier_rises_where_it_stands() -> void:
	var m := _model(&"skeleton")
	gut.p("the soldier's rise: %.2f m from its place at most" % m.drift(&"rise"))
	assert_lte(m.drift(&"rise"), 0.25)


## P1-3: the colour of a fading instance names the new clip's blend, also as the half float of the Compatibility
## renderer, and never rounds up to the next code.
func test_a_fade_names_the_new_clips_blend() -> void:
	for c: Array in [[3, 4, 0.0, 20], [3, 4, 0.37, 20], [3, 4, 0.9999, 20], [19, 0, 0.5, 20], [19, 0, 0.9999, 20],
			[11, 11, 0.0, 12], [29, 0, 0.99, LONGEST_LOOP]]:
		var code := CrowdRenderer.fade_target(c[0], c[1], c[2], c[3])
		assert_lt(code, 0.0, "fading: negative")
		for half: bool in [false, true]:
			var read := _half(code) if half else code
			var pick := CrowdRenderer.fade_pick(read)
			assert_eq(int(c[0]) + int(pick[0]), int(c[1]), "%s: the next pose (half %s)" % [c, half])
			if c[0] != c[1]:
				assert_almost_eq(float(pick[1]), float(c[2]), 0.04, "%s: its share (half %s)" % [c, half])


	for id: StringName in [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"knight", &"priest", &"priest_elder", &"morvath"]:
		var m := _model(id)
		for anim: StringName in m.first:
			if m.loops.get(anim, false):
				assert_lte(m.frame_count(anim), LONGEST_LOOP, "%s %s: a loop of %d poses" % [id, anim, m.frame_count(anim)])


## A float as the Compatibility renderer keeps an instance colour (a half: 11 significant bits).
func _half(x: float) -> float:
	var e := floorf(log(absf(x)) / log(2.0))
	var q := pow(2.0, e - 10.0)
	return roundf(x / q) * q


## P1-3: with the fade held half way, the drawn body moves smoothly as the new clip plays: from one frame to the next
## its middle moves no more than the clip's own blend moves it (it stepped a whole pose at once, up to 0.55 m on
## Morvath's summon).
func test_the_fade_moves_with_the_new_clip() -> void:
	var m := _model(&"morvath")
	var rate := m.pose_rate(&"slash3")
	var from := int(m.first[&"walk"]) + 5
	var worst_fade := 0.0
	var worst_own := 0.0
	var last_fade := Vector3.INF
	var last_own := Vector3.INF
	for i in 40:
		var t := i * DT
		var p := clampf(t * rate, 0.0, m.frame_count(&"slash3") - 1.0)
		var a := mini(int(p), m.frame_count(&"slash3") - 1)
		var next := mini(a + 1, m.frame_count(&"slash3") - 1)
		var pick := CrowdRenderer.fade_pick(CrowdRenderer.fade_target(a, next, p - a, m.frame_count(&"slash3")))
		var own := _mean(m, int(m.first[&"slash3"]) + a).lerp(_mean(m, int(m.first[&"slash3"]) + a + int(pick[0])), pick[1])
		var drawn := _mean(m, from).lerp(own, 0.5)
		if last_fade != Vector3.INF:
			worst_fade = maxf(worst_fade, drawn.distance_to(last_fade))
			worst_own = maxf(worst_own, own.distance_to(last_own))
		last_fade = drawn
		last_own = own
	assert_lte(worst_fade, worst_own * 0.5 + 0.001, "half way, the body moves half as fast as the new clip (%.3f, %.3f)" % [worst_fade, worst_own])


var _means := {}


func _mean(m: BakedModel, row: int) -> Vector3:
	if not _means.has(row):
		var sum := Vector3.ZERO
		var n := 0
		for v in range(0, m.vertices, 5):
			var i := row * m.vertices + v
			var c := m.positions.get_pixel(i % BakedModel.WIDTH, i / BakedModel.WIDTH)
			sum += Vector3(c.r, c.g, c.b)
			n += 1
		_means[row] = sum / n
	return _means[row]


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


## P1-5 and P1-2: a body that rises next to the paladin with its cooldown run down waits Horde.ARRIVE once standing
## before its first wind-up, fades from its rise over Horde.RISE_FADE and turns slowly at first.
func test_a_risen_body_arrives_before_it_strikes() -> void:
	_room()
	for id: StringName in [&"skeleton", &"mage"]:
		game.horde.clear_crowd()
		var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(Vector2(2.0, 0.0) if id == &"skeleton" else Vector2(8.0, 0.0), 0.8))
		e.cooldown = 0.0
		var stood := -1
		var wound := -1
		var last_yaw := INF
		var worst_turn := 0.0
		for f in 240:
			_frame()
			if stood < 0 and e.state != Enemy.State.RISE:
				stood = f
				assert_almost_eq(e.fade_len, Horde.RISE_FADE, 0.001, "%s: the rise fades into its walk" % id)
			if stood >= 0 and f - stood <= int(Horde.RISEN_TIME * 60.0) and last_yaw != INF:
				worst_turn = maxf(worst_turn, absf(rad_to_deg(angle_difference(last_yaw, e.yaw()))))
			last_yaw = e.yaw()
			if stood >= 0 and wound < 0 and e.state == Enemy.State.WINDUP:
				wound = f
				break
		assert_gte(stood, 0, "%s stood up" % id)
		assert_gte(wound, 0, "%s wound up" % id)
		gut.p("%s: first wind-up %.2f s after standing" % [id, (wound - stood) * DT])
		assert_gte((wound - stood) * DT, Horde.ARRIVE - DT, "%s: it arrives before it strikes" % id)
		assert_lte(worst_turn, Horde.RISEN_TURN * DT + 0.5, "%s: it turns slowly as it stands (%.1f degrees a frame)" % [id, worst_turn])


## Corredor (PO, 2026-11-18: "ainda tem esqueleto que anda tremendo", the rust one): its sway rocked the trunk 7 degrees
## 9 times a second and an uneven stride played its walk from backwards to 2.4 times its pace. The sway now follows the
## stride, once to each side a loop of two steps, and its walk plays on at the pace of its speed.
func test_the_runners_sway_follows_its_stride() -> void:
	var loop := _model(&"runner").duration(&"walk")
	assert_almost_eq(Horde.stride_lean(7.0, loop * 0.25, loop), deg_to_rad(7.0), 0.0001, "the most to one side")
	assert_almost_eq(Horde.stride_lean(7.0, loop * 0.75, loop), -deg_to_rad(7.0), 0.0001, "and to the other")
	assert_almost_eq(Horde.stride_lean(7.0, loop * 1.25, loop), Horde.stride_lean(7.0, loop * 0.25, loop), 0.0001, "a loop")
	assert_eq(Horde.stride_lean(7.0, 1.0, 0.0), 0.0)


func test_the_runner_runs_on_at_its_pace() -> void:
	_room()
	var e := game.horde.spawn(game.horde.def(&"runner"), game.arena.resolve(Vector2(12.0, 0.0), 0.8), false)
	var m := _model(&"runner")
	var first := int(m.first[&"walk"])
	var n := m.frame_count(&"walk")
	var last := -1
	var walked := 0
	var back := 0
	var leap := 0
	for f in 90:
		_frame()
		var row := e.drawn_row
		if e.drawn_anim == &"walk" and e.walking and row >= first and row < first + n:
			if last >= 0:
				var step := posmod(row - last, n)
				walked += 1
				if step > n / 2:
					back += 1
				elif step > 1:
					leap += 1
			last = row
		else:
			last = -1
	gut.p("runner: %d frames running, %d backwards, %d over a pose a frame" % [walked, back, leap])
	assert_gt(walked, 30, "it ran")
	assert_eq(back, 0, "its walk never plays backwards")
	assert_eq(leap, 0, "nor skips a pose (it plays %.2f a frame)" % (n / m.duration(&"walk") * Horde.walk_rate(e.def.speed, float(m.ground_speed[&"walk"]), e.def.size) * DT))
