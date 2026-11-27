extends GutTest
## C1d lote 7: the Ruptura of phase 4: 1.5 s warning over the whole floor, 15 damage, then 3 s exposed; once in 25 s.

var game: Game


func _fight_phase4() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	var boss := game.boss
	_run(2.0, false)
	boss.phase = 4
	boss._change_phase(4)
	_run(boss.def.roar_time + 4.0, false)
	return boss


func _run(seconds: float, _safe := true) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		t += 1.0 / 60.0


func test_data_and_pure_rule() -> void:
	var d := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq(d.rupture_every, 25.0)
	assert_eq(d.rupture_windup, 1.5)
	assert_eq(d.rupture_damage, 15.0)
	assert_eq(d.rupture_window, 3.0)
	assert_eq(d.rupture_phase, 4)
	assert_false(BossRules.rupture_due(3, 4, 25.0, 0.0), "not before its phase")
	assert_false(BossRules.rupture_due(4, 4, 25.0, 0.1))
	assert_true(BossRules.rupture_due(4, 4, 25.0, 0.0))
	assert_false(BossRules.rupture_due(4, 4, 0.0, 0.0), "no data, none")


func test_warning_covers_the_floor_then_exposes_him() -> void:
	var boss := _fight_phase4()
	assert_eq(boss.phase, 4)
	boss._rupture_left = 0.0
	boss._rest(0.0)
	boss._cooldown = 0.0
	var seen := false
	var warn: Ground.Zone = null
	for i in 600:
		_run(1.0 / 60.0)
		if boss.state == Boss.State.RUPTURE:
			for z in game.ground.zones:
				if z.source == &"rupture":
					warn = z
			if warn != null:
				seen = true
				break
	assert_true(seen, "the Ruptura started")
	assert_almost_eq(warn.total, 1.5, 0.1, "1.5 s of warning")
	assert_eq(warn.power, 15.0)
	assert_gte(warn.radius, game.arena.shape().bounds().size.x * 0.5 - 0.1, "the whole floor, no free lane")
	assert_eq(int(boss.stats.get("ruptures", 0)), 1)
	# it lands, he is exposed 3 s, x1.4
	for i in 120:
		_run(1.0 / 60.0)
		if boss.e.broken_t > 0.0:
			break
	assert_almost_eq(boss.e.broken_t, 3.0, 0.2)
	assert_eq(boss.state, Boss.State.RECOVER)
	var before := boss.e.hp
	game.horde.damage(boss.e, 10.0, Vector2.DOWN, 0.0, Color.WHITE, false)
	assert_almost_eq(before - boss.e.hp, 10.0 * (1.0 + boss.def.posture_vuln), 0.01)
	boss._on_blow(boss.e, &"special")
	assert_eq(boss.posture_ratio(), 1.0, "no Postura while he is exposed")
	assert_gt(boss._rupture_left, 20.0, "the next one is 25 s away")


func _pulse_hp(brado: bool) -> float:
	var boss := _fight_phase4()
	boss._cancel()
	game.ground.clear()
	game.player.pos = boss._middle + Vector2(3, 0)
	boss._rupture_left = 0.0
	boss._rest(0.0)
	boss._cooldown = 0.0
	var hp0 := game.player.hp
	var guard := 0
	while guard < 900 and game.boss != null:
		guard += 1
		if boss.state == Boss.State.RUPTURE:
			game.player.invuln = 0.0
			game.player.shield_ready = brado
			if boss.e.broken_t > 0.0:
				break
		else:
			game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		if boss.state == Boss.State.RECOVER and boss.e.broken_t > 0.0:
			break
	assert_eq(game.ground.last_source, &"rupture" if hp0 != game.player.hp or not brado else game.ground.last_source)
	return hp0 - game.player.hp


func test_the_pulse_hits_for_15() -> void:
	assert_eq(_pulse_hp(false), 15.0)


func test_the_shield_takes_the_pulse_whole() -> void:
	assert_eq(_pulse_hp(true), 0.0)
