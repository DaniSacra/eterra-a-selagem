extends GutTest
## C1d lote 2: the Cavaleiro's answers (K1 wall stun, K2 the Brado opens it, K3 the guard by time).

func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	return game


func _knight(game: Game, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(&"knight"), at, false)
	e.cooldown = 99.0
	e.rows = 0
	return e


func test_data_and_warnings() -> void:
	var d := load("res://data/enemies/knight.tres") as EnemyDef
	assert_eq(d.wall_stun, 1.5)
	assert_eq(d.ward_open, 1.0)
	assert_eq(d.guard_up_time, 4.0)
	assert_eq(d.front_block, 0.7)
	assert_eq(d.close_windup, 0.5, "2026-11-23: the close blow warns 0.5 s (0.8 before)")
	assert_gte(d.guard_up_hit_windup, 0.5, "the swing behind the shield warns 0.5 s or more")
	assert_gte(d.attack_windup, 0.5)
	assert_lt(d.guard_up_every, 15.0)


func test_shield_up_only_by_time() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(4, 0))
	e.face = Vector2.LEFT
	e.dir = Vector2.LEFT
	assert_false(h.guard_up(e), "down by default")
	assert_false(h.blocks_front(e, Vector2(0, 0)))
	e.guard_t = 3.0
	assert_true(h.guard_up(e))
	assert_true(h.blocks_front(e, Vector2(0, 0)), "in front")
	assert_false(h.blocks_front(e, Vector2(8, 0)), "behind it")
	assert_true(h.behind(e, Vector2(8, 0)))
	assert_false(h.behind(e, Vector2(0, 0)))


func test_guard_rises_in_its_windup_then_falls_by_itself() -> void:
	var game := _game()
	var h := game.horde
	h.target = Vector2(0, 0)
	var e := _knight(game, Vector2(7, 0))
	e.guard_cd = 0.0
	var seen_windup := false
	var up := false
	for i in 200:
		game._step(1.0 / 60.0)
		if e.memo == Horde.KNIGHT_GUARD and e.state == Enemy.State.WINDUP:
			seen_windup = true
			assert_eq(e.guard_t, 0.0, "not up before its windup is out")
		if e.guard_t > 0.0:
			up = true
			break
	assert_true(seen_windup)
	assert_true(up)
	e.cooldown = 99.0
	for i in 300:
		game._step(1.0 / 60.0)
	assert_eq(e.guard_t, 0.0, "it falls by itself")
	assert_almost_eq(e.guard_cd, 14.0 - 1.0, 1.5, "and the next one counts from there")


func test_no_guard_under_half_armor() -> void:
	var game := _game()
	var e := _knight(game, Vector2(7, 0))
	e.guard_cd = 0.0
	e.armor = e.max_armor * 0.4
	for i in 90:
		game._step(1.0 / 60.0)
	assert_eq(e.guard_t, 0.0)
	assert_ne(e.memo, Horde.KNIGHT_GUARD)


func test_special_opens_the_raised_guard_and_not_a_lowered_one() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(4, 0))
	h.open_guard(e)
	assert_eq(e.open_t, 0.0, "nothing to open")
	e.guard_t = 3.0
	h.open_guard(e)
	assert_eq(e.open_t, 4.0)
	assert_false(h.guard_up(e))


func test_brado_opens_the_slam() -> void:
	var game := _game()
	var e := _knight(game, Vector2(2, 0))
	e.memo = 1
	game.player.ward_taken.emit(e.pos)
	assert_eq(e.stun_t, 1.0)
	var o := _knight(game, Vector2(9, 0))
	game.player.ward_taken.emit(o.pos + Vector2(0.1, 0))
	assert_eq(o.stun_t, 0.0, "only after its slam")


func test_wall_stun_is_its_own_collision_not_a_blow() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(4, 0))
	e.state = Enemy.State.ATTACK
	e.aim = Vector2.RIGHT
	h._wall_stun(e)
	assert_eq(e.stun_t, 1.5)
	assert_eq(e.charges, 0)
	assert_eq(e.broken_t, 0.0, "no Quebra, no vulnerability")
	assert_ne(e.state, Enemy.State.ATTACK)


func test_charge_into_the_wall_stuns() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(0, 0))
	e.state = Enemy.State.ATTACK
	e.state_t = 0.0
	e.aim = Vector2.RIGHT
	e.dir = Vector2.RIGHT
	e.pos = Vector2(100.0, 0.0)  # far past any wall
	h.target = Vector2(-50.0, 0.0)
	for i in 5:
		h._behave_knight(e, 1.0 / 60.0, Vector2.LEFT, 150.0)
		if e.stun_t > 0.0:
			break
	assert_eq(e.stun_t, 1.5, "the floor pushed it back: wall stun")
