extends GutTest
## A charge's line on the floor belongs to the charging enemy: when it is not winding up or charging, no line of it may
## stay on the Ground (the Cavaleiro's red 2.4 m rectangle left by the north wall).

func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	return game


## Live zones an enemy that is neither winding up nor attacking still holds as its warning (a line left behind).
func _stale(game: Game) -> int:
	var n := 0
	for o in game.horde.list:
		if o.state == Enemy.State.WINDUP or o.state == Enemy.State.ATTACK:
			continue
		for z in [o.warning, o.warning2]:
			if z != null and (z as Ground.Zone).life > 0.0 and not (z as Ground.Zone).cancelled:
				n += 1
	return n


## Live round marks of the wall under a charge's line.
func _marks(game: Game) -> int:
	var n := 0
	for z in game.ground.zones:
		if z.source == WallMark.SOURCE and z.life > 0.0 and not z.cancelled:
			n += 1
	return n


## Runs `id` for `secs` against a paladin who walks about; shakes its life/armor to pass the phases, and cuts it now and then.
func _run(id: StringName, start: Vector2, secs: float, seed_v: int, pinned: bool = false) -> int:
	var game := _game()
	var wall := Vector2.ZERO
	var y := 0.0
	while game.arena.resolve(Vector2(0, y), 0.6).distance_to(Vector2(0, y)) < 0.05 and y < 40.0:
		y += 0.25
	wall = Vector2(0, y - 1.2)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	game.rooms.wall_mark = WallMark.new(game)  # (the knight's hall: the mark where its line meets the wall)
	var e := game.horde.spawn(game.horde.def(id), start, false)
	game.player.pos = Vector2.ZERO
	var leaks := 0
	var still := 0
	var t := 0.0
	var dt := 1.0 / 60.0
	for i in int(secs / dt):
		t += dt
		game.player.pos = wall + Vector2(cos(t * 0.7 + seed_v) * 1.5, 0.0) if pinned else Vector2(cos(t * 0.7 + seed_v) * 6.0, sin(t * 0.5) * 5.0)
		game.player.hp = game.player.max_hp
		if i % 150 == 0:
			var k := rng.randf()
			if k < 0.3:
				e.armor = maxf(0.0, e.armor - e.max_armor * 0.15)
				e.hp = maxf(1.0, e.hp - e.max_hp * 0.08)
			elif k < 0.5:
				game.horde.interrupt(e)
			elif k < 0.6:
				game.horde.stun(e, 1.0) if game.horde.has_method("stun") else null
		game._step(dt)
		game.rooms.wall_mark.step(dt)
		if not e.alive:
			break
		leaks += _stale(game)
		var bracing := e.state == Enemy.State.WINDUP and e.warning != null
		var marks := _marks(game)
		still = still + 1 if marks > 0 and not bracing else 0
		if still > 3:
			leaks += 1
	return leaks


func _wall_side() -> Vector2:
	return Vector2(0, -2)


func test_knight_leaves_no_line() -> void:
	for s in 6:
		assert_eq(_run(&"knight", Vector2(0, -9), 40.0, s), 0, "knight seed %d" % s)
		assert_eq(_run(&"knight", _wall_side(), 40.0, s, true), 0, "knight at the wall, seed %d" % s)


func test_other_chargers_leave_no_line() -> void:
	for id in [&"capitao", &"runner_elite", &"guard", &"guard_elite", &"runner_big"]:
		for s in 2:
			assert_eq(_run(id, Vector2(0, -9), 25.0, s), 0, "%s seed %d" % [id, s])
