extends GutTest
## C1d lote 5: the Condutores. Each fallen caster of the ritual cuts 5 s off it; both fallen, the shield opens at 10 s.

var game: Game


func test_limit_is_pure_and_never_negative() -> void:
	assert_eq(BossRules.ritual_limit(20.0, 5.0, 0), 20.0)
	assert_eq(BossRules.ritual_limit(20.0, 5.0, 1), 15.0)
	assert_eq(BossRules.ritual_limit(20.0, 5.0, 2), 10.0)
	assert_eq(BossRules.ritual_limit(20.0, 5.0, 9), 0.0)
	assert_eq(BossRules.ritual_limit(20.0, 0.0, 2), 20.0, "no data, no cut")


func _ritual() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	var boss := game.boss
	_run(2.0)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	for i in 600:
		if boss.state == Boss.State.RITUAL:
			break
		_run(1.0 / 60.0)
	return boss


func _run(seconds: float) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		t += 1.0 / 60.0


func test_data() -> void:
	var d := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq(d.ritual_shorten, 5.0)
	assert_true(d.ritual_conductors.has(&"mage"))
	assert_false(d.ritual_conductors.has(&"skeleton"), "only the casters conduct")


func test_two_casters_down_open_the_shield_at_ten_seconds() -> void:
	var boss := _ritual()
	assert_eq(boss.state, Boss.State.RITUAL)
	_run(4.0)  # the dead have all risen
	var casters: Array[Enemy] = []
	for r in boss._raised:
		if r.def.id == &"mage":
			casters.append(r)
	assert_eq(casters.size(), 2)
	assert_eq(boss.conductors_dead(), 0)
	assert_almost_eq(boss.ritual_time_left(), 20.0 - boss._ritual_t, 0.05)
	game.horde.damage(casters[0], 99999.0, Vector2.DOWN, 0.0)
	assert_eq(boss.conductors_dead(), 1)
	assert_almost_eq(boss.ritual_time_left(), 15.0 - boss._ritual_t, 0.05)
	game.horde.damage(casters[1], 99999.0, Vector2.DOWN, 0.0)
	assert_eq(boss.conductors_dead(), 2)
	assert_almost_eq(boss.ritual_time_left(), 10.0 - boss._ritual_t, 0.05)
	# the skeletons left standing: the shield still holds until the 10 s
	assert_eq(boss.state, Boss.State.RITUAL)
	var guard := 0
	while boss.state == Boss.State.RITUAL and guard < 20 * 60:
		_run(1.0 / 60.0)
		guard += 1
	assert_lte(boss._ritual_t, 10.2, "it opened at 10 s")
	assert_eq(boss.state, Boss.State.STUNNED)
	assert_gte(boss._stun_time, 2.0)
