extends GutTest
## Ranged enemies keep to the far end of their reach and shoot; circles on the floor are Morvath's alone
## (Daniel's test of 2026-11-16).

var game: Game


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
	var r := _run(e, 6.0)
	assert_gt(r.shots, 1)
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
