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
	var out := {"shots": 0, "circles": 0, "lines": 0, "min_dist": INF}
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


func test_the_mage_waits_at_the_far_end_and_shoots_orbs() -> void:
	var e := _alone(&"mage")
	var r := _run(e, 8.0)
	assert_gt(r.shots, 1, "it shoots")
	assert_eq(r.circles, 0, "never a circle on the floor")
	assert_almost_eq(e.pos.distance_to(game.player.pos), e.def.attack_range, 1.0, "at the far end of its reach")


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


func test_the_priests_shoot_fans_of_orbs_not_circles() -> void:
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
