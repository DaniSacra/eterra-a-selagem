extends GutTest
## Lote C1 (Daniel, 2026-11-22: "o combate bem melhor"): the weak hero, and the enemies that each ask for another answer.

const DT := 1.0 / 60.0

var game: Game


func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO


func after_each() -> void:
	Dev.put("seed", "1")


func _spawn(id: StringName, at: Vector2) -> Enemy:
	return game.horde.spawn(game.horde.def(id), at, false)


func _hit(e: Enemy, base: float, tags: Array[StringName]) -> float:
	var before := e.hp + e.armor
	game.combat.hit_enemy(e, base, tags, Vector2.RIGHT, 0.0)
	return before - e.hp - e.armor


func test_a_shield_stops_the_attack_from_the_front_only() -> void:
	var g := _spawn(&"guard", Vector2(3.0, 0.0))
	g.dir = Vector2.LEFT
	var light: Array[StringName] = [&"light"]
	var heavy: Array[StringName] = [&"heavy"]
	var dash: Array[StringName] = [&"light", &"dash"]
	assert_almost_eq(_hit(g, 20.0, light), 6.0, 0.01, "70% stopped")
	assert_almost_eq(_hit(g, 20.0, dash), 20.0, 0.01, "the Investida goes past it")
	g.dir = Vector2.RIGHT
	assert_almost_eq(_hit(g, 20.0, light), 20.0, 0.01, "from behind, all of it")
	g.dir = Vector2.LEFT
	assert_almost_eq(_hit(g, 20.0, heavy), 20.0, 0.01, "the wave is not stopped")
	assert_gt(g.open_t, 0.0)
	assert_almost_eq(_hit(g, 20.0, light), 20.0, 0.01, "and leaves its guard open")


func test_the_special_wears_armor_down_faster() -> void:
	var e := _spawn(&"archer_elite", Vector2(5.0, 0.0))
	e.max_armor = 190.0  # (given by hand: no enemy has armor since 2026-11-27)
	e.armor = 190.0
	assert_almost_eq(_hit(e, 20.0, [&"heavy"] as Array[StringName]), 30.0, 0.01)
	assert_almost_eq(_hit(e, 20.0, [&"light"] as Array[StringName]), 20.0, 0.01)


func test_the_brado_takes_one_blow() -> void:
	var p := game.player
	p.gifts.rally(5.0, 0.15, 0.15)
	p.gifts.ward = 1
	p.invuln = 0.0
	var hp := p.hp
	p.hurt(10.0, Vector2(3.0, 0.0))
	assert_eq(p.hp, hp, "taken whole")
	p.invuln = 0.0
	p.hurt(10.0, Vector2(3.0, 0.0))
	assert_lt(p.hp, hp, "only one")
	p.gifts.ward = 1
	p.gifts.rally_left = 0.0
	assert_false(p.gifts.take_ward(), "nor once the buff is over")


func test_frost_holds_only_by_the_strong_blows() -> void:
	var was := StunRule.live
	StunRule.live = StunRule.Mode.NONE
	var e := _spawn(&"skeleton", Vector2(5.0, 0.0))
	game.combat._freeze(e, 2.0, [&"light"] as Array[StringName])
	assert_eq(e.frozen_t, 0.0, "a plain cut slows")
	assert_gt(e.slow_t, 0.0)
	game.combat._freeze(e, 2.0, [&"light", &"finisher"] as Array[StringName])
	assert_almost_eq(e.frozen_t, Combat.FREEZE_MAX, 0.001, "a finisher freezes, a second at most")
	e.frozen_t = 0.0
	game.combat._freeze(e, 2.0, [&"finisher"] as Array[StringName])
	assert_eq(e.frozen_t, 0.0, "not again at once")
	StunRule.live = was


func test_what_morvath_ignores_strikes_him() -> void:
	var m := _spawn(&"morvath", Vector2(6.0, 0.0))
	assert_almost_eq(game.combat._resisted(m, 0.0, 1.0), Combat.RESIST_FREEZE, 0.001)
	assert_almost_eq(game.combat._resisted(m, 1.0, 0.0), Combat.RESIST_PUSH, 0.001)
	var s := _spawn(&"skeleton", Vector2(6.0, 3.0))
	assert_eq(game.combat._resisted(s, 1.0, 1.0), 0.0, "the common crowd is pushed and frozen")


func test_the_runner_bursts_as_it_falls() -> void:
	var r := _spawn(&"runner", Vector2(3.0, 0.0))
	var before := game.ground.zones.size()
	game.horde.damage(r, 999.0, Vector2.RIGHT, 0.0)
	assert_false(r.alive)
	assert_eq(game.ground.zones.size(), before + 1)
	var z := game.ground.zones[-1]
	assert_almost_eq(z.life, r.def.death_burst, 0.001)
	assert_almost_eq(z.power, r.def.attack_damage, 0.01)


func test_the_soldier_follows_then_locks() -> void:
	var s := _spawn(&"skeleton", Vector2(3.0, 0.0))
	var first := Vector2.ZERO
	var locked := Vector2.ZERO
	for f in 60 * 8:
		game.player.invuln = 10.0
		game._step(DT)
		if s.state == Enemy.State.WINDUP:
			if first == Vector2.ZERO:
				first = s.aim
			game.player.pos = s.pos + Vector2.from_angle(PI + s.state_t * 2.0) * 2.4
			if s.state_t > s.def.attack_windup - s.def.aim_lock + 0.03:
				if locked == Vector2.ZERO:
					locked = s.aim
				assert_eq(s.aim, locked)
		elif first != Vector2.ZERO:
			break
	assert_gt(absf(first.angle_to(locked)), 0.3)


func test_the_crossbowmans_second_bolt_is_aimed_again() -> void:
	var a := _spawn(&"archer", Vector2(9.0, 0.0))
	var aims: Array[Vector2] = []
	var was := 0
	for f in 60 * 10:
		game.player.invuln = 10.0
		game._step(DT)
		if a.state == Enemy.State.ATTACK and a.memo > was:
			aims.append(a.aim)
			game.player.pos = Vector2(0.0, 4.0)
		was = a.memo if a.state == Enemy.State.ATTACK else 0
		if aims.size() >= 2:
			break
	assert_eq(aims.size(), 2)
	if aims.size() == 2:
		assert_gt(absf(aims[0].angle_to(aims[1])), 0.1, "where he stands then")


func test_impact_pitch_goes_down_from_blow_1_to_the_finisher() -> void:
	var c1 := ComboNode.new()
	c1.id = &"cut1"
	var c2 := ComboNode.new()
	c2.id = &"cut2"
	var c3 := ComboNode.new()
	c3.id = &"cut3"
	c3.tags = [&"finisher"]
	assert_eq(Combat.hit_pitch(c1), 1.0)
	assert_lt(Combat.hit_pitch(c2), Combat.hit_pitch(c1))
	assert_lt(Combat.hit_pitch(c3), Combat.hit_pitch(c2))
