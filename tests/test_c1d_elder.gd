extends GutTest
## C1d lote 3: the Ancião's answers (A2 the retreat and the volley, A3 the shield on the servants).

func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	return game


func test_data() -> void:
	var d := load("res://data/enemies/priest_elder.tres") as EnemyDef
	assert_eq(d.volley_count, 3)
	assert_eq(d.volley_speed, 4.0)
	assert_eq(d.volley_turn, 60.0)
	assert_eq(d.volley_life, 4.0)
	assert_eq(d.volley_back, 8.0)
	assert_eq(d.volley_every, 12.0)
	assert_gte(d.volley_windup, 0.8, "the new pattern warns 0.8 s or more (2026-11-23: 1.0 before the quicker wind-ups)")
	assert_gte(d.volley_recover, 1.5)
	assert_eq(d.ward_count, 0, "no armor to give since 2026-11-27 (the yellow bar is gone)")
	assert_eq(d.armor, 0.0)


func test_retreat_then_three_slow_orbs_that_turn() -> void:
	var game := _game()
	var h := game.horde
	h.target = Vector2(0, 0)
	game.player.pos = Vector2(0, 0)
	var e := h.spawn(h.def(&"priest_elder"), Vector2(3, 0), false)
	e.cooldown = 99.0
	e.volley = 1
	var start := e.pos
	var worn := false
	var shots := 0
	for i in 420:
		game._step(1.0 / 60.0)
		if e.volley == 2:
			worn = true
			assert_eq(e.fan.size(), 3, "a thread for each orb")
			assert_gt(e.pos.distance_to(start), 1.0, "it moved back first")
		if h.projectiles.shots.size() >= 3 and shots == 0:
			shots = h.projectiles.shots.size()
			for s in h.projectiles.shots:
				assert_almost_eq(s.vel.length(), 4.0, 0.01)
				assert_almost_eq(s.turn, deg_to_rad(60.0), 0.001)
			break
	assert_true(worn)
	assert_eq(shots, 3)
	assert_eq(e.volley, 0)
	assert_gt(e.volley_cd, 11.0, "once in 12 s")
	assert_gte(e.cooldown, 1.0, "then it rests")


func test_interrupted_volley_does_not_wedge() -> void:
	var game := _game()
	var h := game.horde
	var e := h.spawn(h.def(&"priest_elder"), Vector2(6, 0), false)
	e.volley = 2
	e.state = Enemy.State.WINDUP
	h.interrupt(e)
	assert_eq(e.volley, 0)
