extends GutTest
## Ranged enemies keep to the far end of their reach and shoot; circles on the floor are Morvath's alone
## (Daniel's test of 2026-11-16).

var game: Game


## Every game here plays the same dice (QA E2-12): without --seed each system's generator is randomize()d
## (Dev.seed_rng), so the cooldowns (attack_cooldown x 0.85 to 1.2) and the retreats differed run to run.
func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)


## One enemy of this kind, 14 m east of the paladin, in a room with nobody else (the fountain room).
func _alone(id: StringName, offset := Vector2(14, 0)) -> Enemy:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	return game.horde.spawn(game.horde.def(id), game.arena.resolve(game.player.pos + offset, 0.6), false)


## Steps the game; walk: where the paladin heads each frame (6.75 m/s), ZERO stands still. Counts its shots and
## the circles laid on the floor that hurt.
func _run(e: Enemy, seconds: float, walk := Callable()) -> Dictionary:
	var out := {"shots": 0, "circles": 0, "lines": 0, "min_dist": INF, "orbs": 0, "turning": 0}
	var seen := {}
	for i in int(seconds * 60.0):
		game.player.invuln = 10.0
		if walk.is_valid():
			var to: Vector2 = walk.call()
			game.player.pos = game.arena.resolve(game.player.pos + (to - game.player.pos).limit_length(6.75 / 60.0), 0.5)
		game._step(1.0 / 60.0)
		for s in game.projectiles.shots:
			if not seen.has(s) and s.by == e.def.id:
				seen[s] = true
				out.shots += 1
				if s.kind == Projectiles.Kind.ORB:
					out.orbs += 1
				if s.turn > 0.0:
					out.turning += 1
		for z in game.ground.zones:
			if not seen.has(z):
				seen[z] = true
				if z.shape == Ground.Shape.CIRCLE and z.power > 0.0:
					out.circles += 1
				elif z.shape == Ground.Shape.LINE:
					out.lines += 1
		if i > 120:
			out.min_dist = minf(out.min_dist, e.pos.distance_to(game.player.pos))
	return out


func test_the_mage_shoots_bursts_of_turning_orbs_from_afar() -> void:
	var e := _alone(&"mage", Vector2(16, 0))
	var r := _run(e, 8.0)
	assert_gt(r.shots, 2, "at least one burst of three")
	assert_eq(r.circles, 0, "never a circle on the floor")
	var d := e.pos.distance_to(game.player.pos)
	assert_between(d, e.def.attack_range * e.def.keep_away - 1.0, e.def.attack_range + 2.5, "it keeps away")
	# every shot it fired over the run (not only those still flying at the end: a burst may have died out by then)
	assert_eq(r.orbs, r.shots, "it shoots orbs")
	assert_eq(r.turning, r.shots, "its orbs turn after him")


func test_each_orb_of_the_burst_pushes_the_mage_back() -> void:
	var e := _alone(&"mage", Vector2(12, 0))
	var pushed := [false]
	for i in 6 * 60:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if e.state == Enemy.State.ATTACK and e.push.dot(e.pos - game.player.pos) > 1.0:
			pushed[0] = true
	assert_true(pushed[0], "the recoil pushes it away from him")


func test_the_mage_waits_behind_a_pillar() -> void:
	var e := _alone(&"mage", Vector2(10, 0))
	game.arena.pillars.assign([Vector3(4, 0, 0.6)])
	var spot: Variant = game.horde.cover_spot(e.pos, e.def.cover_hug)
	assert_not_null(spot)
	if spot:
		assert_gt((spot as Vector2).x, 4.0, "past the pillar, away from him")
	game.arena.pillars.clear()
	assert_null(game.horde.cover_spot(e.pos, e.def.cover_hug), "no pillar, no cover")


func test_the_crossbowman_runs_after_each_bolt() -> void:
	var e := _alone(&"archer", Vector2(9, 0))
	var ran := [false]
	for i in 6 * 60:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if e.retreat_t > 0.0:
			ran[0] = true
	assert_true(ran[0])
	assert_eq(e.def.retreat_far, 700.0 / 80.0)


func test_no_more_than_two_crossbowmen_shoot_at_once() -> void:
	var e := _alone(&"archer")
	for k in 3:
		game.horde.spawn(game.horde.def(&"archer"), game.arena.resolve(Vector2(-12, -6 + k * 6), 0.6), false)
	var peak := [0]
	for i in 8 * 60:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		peak[0] = maxi(peak[0], game.horde.attackers(e.def))
	assert_eq(peak[0], 2)


func test_the_mage_runs_from_a_paladin_who_comes_for_it() -> void:
	var e := _alone(&"mage")
	_run(e, 3.0)
	# he walks at it for 1.5 s: it gives ground (he is faster, so the gap closes, but not to nothing)
	var r := _run(e, 1.5, func() -> Vector2: return e.pos)
	assert_gt(r.min_dist, 3.0, "it runs instead of waiting for him")


func test_ranged_enemies_never_walk_up_to_him() -> void:
	for id: StringName in [&"mage", &"archer"]:
		var e := _alone(id, Vector2(5, 0))
		_run(e, 3.0)
		assert_gt(e.pos.distance_to(game.player.pos), e.def.attack_range * e.def.keep_away - 0.5, "%s backs off to its reach" % id)


func test_the_crossbowman_marks_its_aim_and_shoots_a_bolt() -> void:
	var e := _alone(&"archer")
	# 8 s, not 6 (QA E2-12): a bolt, then 0.4 s, recover_time 0.6, the retreat (1.5 to 1.75 s) and the cooldown
	# (1.8 x 0.85 to 1.2) before the next aim: over 40 seeds the 2nd bolt left at 5.1 to 6.5 s (first at 1.7 to 3.0),
	# so a 6 s window lost it about one run in three. Not noise: the window was shorter than the crossbowman's cycle.
	var r := _run(e, 8.0)
	assert_gt(r.shots, 1, "a second bolt after its retreat")
	assert_gt(r.lines, 0, "its aim is marked on the floor")
	assert_eq(r.circles, 0)
	for s in game.projectiles.shots:
		if s.by == &"archer":
			assert_eq(s.kind, Projectiles.Kind.BOLT)


func test_the_priest_sends_a_vine_creeping_after_him() -> void:
	var e := _alone(&"priest", Vector2(10, 0))
	var vine: Projectiles.Shot = null
	var first_life := 0.0
	for i in 8 * 60:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		for s in game.projectiles.shots:
			if s.by == &"priest" and vine == null:
				vine = s
				first_life = s.life
	assert_not_null(vine)
	if vine:
		assert_true(vine.low, "along the floor")
		assert_almost_eq(vine.vel.length(), 150.0 / 80.0, 0.01)
		assert_almost_eq(first_life, 12.0, 0.1, "it follows for 12 s")


func test_the_priests_shoot_not_circles() -> void:
	for id: StringName in [&"priest", &"priest_elder"]:
		var e := _alone(id, Vector2(8, 0))
		var r := _run(e, 10.0)
		assert_gt(r.shots, e.def.shot_count - 1, "%s shoots a fan" % id)
		assert_eq(r.circles, 0, "%s lays no circle on the floor" % id)


func test_flee_dir_turns_along_the_wall_and_never_off_the_floor() -> void:
	var e := _alone(&"mage")
	var h := game.horde
	# at the middle: straight away
	assert_eq(h.flee_dir(Vector2.ZERO, Vector2.RIGHT, 0.5, 1.0), Vector2.RIGHT)
	# against a wall it turns, and where it goes is floor
	var edge := game.arena.shape().clamp(Vector2(40, 0), 1.0)
	var dir := h.flee_dir(edge, Vector2.RIGHT, 0.5, 1.0)
	if dir != Vector2.ZERO:
		assert_true(game.arena.inside(edge + dir * Horde.RANGED_LOOK, 0.8))
		assert_lt(dir.dot(Vector2.RIGHT), 0.99, "it turns along the wall")
	assert_not_null(e)


func test_morvaths_eruptions_are_twice_as_wide() -> void:
	var def := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq(def.eruption_radius, 4.0)


## C17, QW-101 (CF-01): the caster's orbs turn after him only in their first shot_homing seconds, then fly straight:
## they catch him early or not at all. A paladin who stands until the orbs have flown `from` seconds, then runs
## sideways at 6.75 m/s, is never hit (the burst of three, either side). Returns the hits.
func _sidestep_hits(def: EnemyDef, from: float, side: float, until := INF) -> int:
	var e := _alone(&"mage")
	e.def = def
	var hits := [0]
	game.projectiles.hit_player.connect(func(_dmg: float, _at: Vector2) -> void: hits[0] += 1)
	var aim := (game.player.pos - e.pos).normalized()
	var run := aim.orthogonal() * side
	var t := 0.0
	for k in def.shot_ticks:
		game.horde.shoot(e, aim)
		for i in int(def.shot_interval * 60.0):
			game.projectiles.step(1.0 / 60.0)
			t += 1.0 / 60.0
	while t < 4.0:
		game.player.invuln = 0.0
		if t >= from and t < until:
			game.player.pos += run * 6.75 / 60.0
		game.projectiles.step(1.0 / 60.0)
		t += 1.0 / 60.0
	return hits[0]


func test_the_mage_orb_catches_early_or_never() -> void:
	var def: EnemyDef = load("res://data/enemies/mage.tres")
	assert_almost_eq(def.shot_homing, 0.8, 0.001, "it turns in its first 0.8 s")
	assert_almost_eq((load("res://data/enemies/mage_elite.tres") as EnemyDef).shot_homing, 0.8, 0.001)
	for from in [1.2, 1.5]:
		for side in [1.0, -1.0]:
			assert_eq(_sidestep_hits(def, from, side), 0, "running sideways from %.1f s of flight: never hit" % from)
	assert_almost_eq(def.shot_turn, 20.0, 0.001, "and half as fast (was 40)")
	# the orb of before (turning 40 degrees a second its whole flight)
	var old: EnemyDef = def.duplicate()
	old.shot_homing = 0.0
	old.shot_turn = 40.0
	# the PO's blow: he ran sideways as the burst left, then planted to strike; the old orbs curved back onto him
	# 2 s into their flight (all three, measured), the new ones fly on past where he was at 0.8 s
	for until in [1.5, 1.8, 2.1]:
		assert_eq(_sidestep_hits(old, 0.0, 1.0, until), 3, "the old orbs caught him after %.1f s of running" % until)
		assert_eq(_sidestep_hits(def, 0.0, 1.0, until), 0, "the new ones never do")
	assert_eq(_sidestep_hits(def, 9.0, 1.0), 3, "standing still they still hit")
