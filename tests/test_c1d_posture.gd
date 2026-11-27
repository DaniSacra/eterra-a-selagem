extends GutTest
## C1d lote 4: Morvath's Postura, worn by the button as a common's Quebra is (the same weights), broken only by it.

var game: Game


func _fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	return game.boss


func _run(seconds: float) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		t += 1.0 / 60.0


func _blow(boss: Boss, source: StringName, amount := 1.0) -> void:
	game.horde.dealing = source
	game.horde.damage(boss.e, amount, Vector2.DOWN, 0.0, Color.WHITE, false)
	game.horde.dealing = &""


func test_data() -> void:
	var d := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq(d.posture, 1300.0)
	assert_eq(d.posture_stun, 3.5)
	assert_eq(d.posture_vuln, 0.3)


func test_posture_wears_by_button_with_the_commons_weights() -> void:
	var boss := _fight()
	_run(3.0)
	assert_eq(boss.posture_ratio(), 1.0)
	_blow(boss, &"attack")
	var w := Feel.live().poise_weights
	var want := 1.0 - Poise.share(&"attack", w) * boss.def.posture_mult
	assert_almost_eq(boss.posture_ratio(), want, 0.001)
	_blow(boss, &"burn")
	assert_almost_eq(boss.posture_ratio(), want, 0.001, "a burn takes none")


func test_attack_alone_takes_many_blows_the_buttons_few() -> void:
	var boss := _fight()
	_run(3.0)
	var n := 0
	while boss.state != Boss.State.STUNNED and n < 100:
		_blow(boss, &"attack")
		n += 1
	assert_gte(n, 30, "the plain attack is slow (SWORN: 800 of stagger over blows of 20)")
	var w := Feel.live().poise_weights
	var per_special := Poise.share(&"special", w) * boss.def.posture_mult
	assert_lte(ceilf(1.0 / per_special), 10.0, "the special breaks it in 10 or fewer (Gawain 800 of stagger)")
	assert_lt(Poise.share(&"attack", w) * 3.0, Poise.share(&"special", w), "an attack is under 40% of a button")


func test_break_kneels_cuts_the_attack_and_takes_more() -> void:
	var boss := _fight()
	_run(3.0)
	for i in int(ceilf(1.0 / (Poise.share(&"special", Feel.live().poise_weights) * boss.def.posture_mult))):
		_blow(boss, &"special")
	assert_eq(boss.state, Boss.State.STUNNED)
	assert_gt(boss.e.broken_t, 2.0)
	var before := boss.e.hp
	_blow(boss, &"attack", 10.0)
	assert_almost_eq(before - boss.e.hp, 10.0 * (1.0 + boss.def.posture_vuln), 0.01, "more damage while he kneels")
	assert_eq(boss.posture_ratio(), 0.0, "no wear while he kneels")
	_run(3.5)
	assert_eq(boss.e.broken_t, 0.0)
	assert_eq(boss.posture_ratio(), 1.0, "full again after")
	var again := boss.e.hp
	_blow(boss, &"attack", 10.0)
	assert_almost_eq(again - boss.e.hp, 10.0, 0.01, "no longer")


func test_idle_refills() -> void:
	var boss := _fight()
	_run(3.0)
	_blow(boss, &"special")
	assert_lt(boss.posture_ratio(), 1.0)
	_run(boss.def.posture_idle + 0.5)
	assert_eq(boss.posture_ratio(), 1.0)


func test_heavy_hits_no_longer_stagger_by_count() -> void:
	var boss := _fight()
	_run(2.0)
	boss.phase = 3
	for i in 5:
		boss._on_struck(boss.e, [&"heavy"] as Array[StringName], 5.0)
	assert_ne(boss.state, Boss.State.STUNNED, "the Postura replaced the count of heavy blows")
