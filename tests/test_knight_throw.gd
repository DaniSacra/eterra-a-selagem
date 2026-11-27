extends GutTest
## 2026-11-23, the quick Cavaleiro: the priority list (AttackList), the shield throw and its wave (ShockRing: only the dodge
## crosses it), the armor that feels only strong blows, the tightened wind-ups.

func _knight_def() -> EnemyDef:
	return load("res://data/enemies/knight.tres") as EnemyDef


func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO
	return game


# ---------- pure rules ----------

func _list() -> Array[KnightMove]:
	var a := KnightMove.new()
	a.id = &"throw"
	a.cooldown = 10.0
	a.first = 4.0
	a.min_dist = 4.0
	a.max_dist = 16.0
	var b := KnightMove.new()
	b.id = &"charge"
	b.count = 3
	b.from_life = 0.4
	b.min_dist = 3.0
	b.max_dist = 14.0
	var c := KnightMove.new()
	c.id = &"charge"
	c.count = 1
	c.min_dist = 3.0
	c.max_dist = 14.0
	return [a, b, c] as Array[KnightMove]


func test_list_runs_top_down_and_first_use_waits() -> void:
	var moves := _list()
	var clocks := AttackList.start_clocks(moves)
	assert_eq(clocks, [4.0, 0.0, 0.0] as Array[float])
	assert_eq(AttackList.pick(moves, clocks, 1.0, 8.0), 2, "the throw waits its first 4 s: the plain charge")
	clocks[0] = 0.0
	assert_eq(AttackList.pick(moves, clocks, 1.0, 8.0), 0, "then the top of the list wins")
	clocks[0] = 10.0
	assert_eq(AttackList.pick(moves, clocks, 1.0, 8.0), 2, "its cooldown hands the turn down")


func test_list_life_gate_distance_and_rest() -> void:
	var moves := _list()
	var clocks: Array[float] = [5.0, 0.0, 0.0]
	assert_eq(AttackList.pick(moves, clocks, 0.9, 8.0), 2, "the triple charge is shut above 40%")
	assert_eq(AttackList.pick(moves, clocks, 0.3, 8.0), 1, "and open under it")
	assert_eq(AttackList.pick(moves, clocks, 0.3, 2.0), -1, "nothing at 2 m: it slams instead")
	assert_eq(AttackList.pick(moves, clocks, 0.3, 20.0), -1, "nor from 20 m")
	assert_eq(AttackList.pick(moves, clocks, 0.3, 8.0, false), -1, "nothing starts while it may not")


func test_wave_grows_after_its_delay_and_outruns_the_hero() -> void:
	assert_eq(ShockRing.radius_at(0.1, 1.2, 12.0, 0.25), 1.2, "held at the start through its delay")
	assert_almost_eq(ShockRing.radius_at(0.75, 1.2, 12.0, 0.25), 1.2 + 6.0, 0.001)
	var f := load(Feel.PATH) as Feel
	var sprint := f.speed * f.sprint_scale
	assert_gt(_knight_def().ring_speed, f.speed, "faster than the walk (SW-REA: the Butcher's 7.5 m/s; only the dodge crosses it, the sprint outruns it in the open)")
	assert_gt(sprint, f.speed)
	assert_eq(ShockRing.caught_in(5.0, 12.0, sprint) < INF, true)
	assert_eq(ShockRing.caught_in(5.0, 12.0, 20.0), INF)


func test_band_touch_and_end() -> void:
	var c := Vector2(2, 2)
	assert_true(ShockRing.touches(c, 5.0, 0.8, c + Vector2(5.3, 0), 0.25))
	assert_false(ShockRing.touches(c, 5.0, 0.8, c + Vector2(6.0, 0), 0.25), "past the band")
	assert_false(ShockRing.touches(c, 5.0, 0.8, c + Vector2(3.0, 0), 0.25), "still inside it")
	assert_true(ShockRing.spent(32.0, 32.0))
	assert_false(ShockRing.spent(10.0, 32.0))


func test_armor_feels_only_strong_blows() -> void:
	var light: Array[StringName] = [&"light"]
	var cut3: Array[StringName] = [&"light", &"spin", &"finisher"]
	var bolt: Array[StringName] = [&"heavy", &"wave"]
	var rush: Array[StringName] = [&"light", &"dash"]
	var omega: Array[StringName] = [&"light", &"thrust", &"finisher", &"omega"]
	assert_eq(DamageCalc.armor_scale(0.3, light), 0.3)
	assert_eq(DamageCalc.armor_scale(0.3, cut3), 1.0)
	assert_eq(DamageCalc.armor_scale(0.3, bolt), 1.0)
	assert_eq(DamageCalc.armor_scale(0.3, rush), 1.0)
	assert_eq(DamageCalc.armor_scale(0.3, omega), 1.0)
	assert_eq(DamageCalc.armor_scale(1.0, light), 1.0, "a common armor is as it was")


# ---------- data ----------

func test_knight_is_quick_but_readable() -> void:
	var d := _knight_def()
	assert_lte(d.attack_windup, 0.65, "the charge's wind-up 0.65 s (SW-REA; it was 1.0)")
	assert_lte(d.close_windup, 0.5, "the close blow 0.5 s (it was 0.8)")
	assert_gte(d.attack_windup, 0.4, "a heavy blow is never under 0.4 s")
	assert_gte(d.close_windup, 0.4)
	assert_lte(d.aim_lock, 0.2, "the line follows him until late")
	assert_gt(d.lunge_speed, 18.0, "a faster lunge")
	assert_gt(d.throw_flight, 0.0)
	assert_lt(d.ring_thick, 1.2, "a thin band")
	assert_false(d.moves.is_empty())
	assert_eq(d.moves[0].id, &"throw", "the rare one on top of the list")
	var most := 1
	for m in d.moves:
		if m.id == &"charge":
			most = maxi(most, m.count)
	assert_gte(most, 2, "the double charge comes in the last phase (40%)")


func test_commons_wind_ups_tightened_with_a_floor() -> void:
	for id in [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"saltador"]:
		var d := load("res://data/enemies/%s.tres" % id) as EnemyDef
		assert_lte(d.attack_windup, 1.0, "%s" % id)
		assert_gte(d.attack_windup, 0.5, "%s: never under the floor" % id)
	assert_lte((load("res://data/enemies/skeleton.tres") as EnemyDef).attack_windup, 0.61)
	assert_lte((load("res://data/enemies/guard.tres") as EnemyDef).attack_windup, 0.95)
	assert_lte((load("res://data/enemies/mage.tres") as EnemyDef).attack_windup, 0.8)


# ---------- in the game ----------

func _knight(game: Game, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(&"knight"), at, false)
	e.cooldown = 99.0
	return e


func test_throw_lands_where_he_stands_hurts_and_opens_the_knight() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(8, 0))
	e.move_cd[0] = 0.0
	e.cooldown = 0.0
	e.rows = 0
	e.guard_cd = 99.0
	var hp := game.player.hp
	var seen_shield := false
	var away_in_flight := false
	for i in 400:
		game._step(1.0 / 60.0)
		if not h.shields.is_empty():
			seen_shield = true
			away_in_flight = away_in_flight or h.shield_away(e)
		if game.player.hp < hp:
			break
	assert_true(seen_shield, "it hurled the shield")
	assert_true(away_in_flight, "empty-handed while it flies")
	assert_lt(game.player.hp, hp, "standing still, the landing (or the wave) hurt")


func test_wave_crossed_by_a_dodge_hurts_nobody_and_counts_as_close() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(-9, 0))
	var w := Horde.Wave.new()
	w.owner = e
	w.center = Vector2(6, 0)
	w.hit = false
	w.ring = game.fx.wave_ring(w.center, Horde.WAVE_COLOR)
	h.waves.append(w)
	var p := game.player
	p.pos = Vector2(0, 0)
	h.target = p.pos
	var closes: Array[int] = [0]
	p.dodge_close.connect(func() -> void: closes[0] += 1)
	var hp := p.hp
	var d := e.def
	var dodged := false
	for i in 200:
		var r := ShockRing.radius_at(w.t, Horde.WAVE_START, d.ring_speed, d.ring_delay)
		var gap := p.pos.distance_to(w.center) - r - d.ring_thick * 0.5
		if not dodged and gap < 1.0 and p.state != Player.State.DODGE:
			p.dodge_charges = 1
			p._start_dodge((w.center - p.pos).normalized())
			dodged = true
		game._step(1.0 / 60.0)
		h.target = p.pos
	assert_true(dodged)
	assert_eq(p.hp, hp, "through the band in the roll: no damage")
	assert_eq(closes[0], 1, "and it counts as a close dodge")


func test_wave_hurts_whoever_stands_in_its_way() -> void:
	var game := _game()
	var h := game.horde
	var e := _knight(game, Vector2(-9, 0))
	var w := Horde.Wave.new()
	w.owner = e
	w.center = Vector2(6, 0)
	w.ring = game.fx.wave_ring(w.center, Horde.WAVE_COLOR)
	h.waves.append(w)
	var p := game.player
	p.pos = Vector2(0, 0)
	h.target = p.pos
	var hp := p.hp
	for i in 90:
		game._step(1.0 / 60.0)
	assert_lt(p.hp, hp, "no dodge, no way through")
	assert_eq(h.waves.size(), 1, "the wave goes on over the room until its reach")
