extends GutTest
## C1d lote 6: the Corte do rastro. The paladin's wave undoes the boss's curse; the Brado takes it with its curse.

var game: Game


func _fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	for i in 120:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
	game.projectiles.clear_hostile()
	return game.boss


func _count(kind: Projectiles.Kind) -> int:
	var n := 0
	for s in game.projectiles.shots:
		n += int(s.kind == kind)
	return n


func test_data() -> void:
	assert_true((load("res://data/bosses/morvath.tres") as BossDef).curse_cut)


func test_wave_undoes_the_curse_without_damage() -> void:
	_fight()
	game.player.invuln = 0.0
	var hits := [0]
	game.projectiles.hit_player.connect(func(_a: float, _f: Vector2) -> void: hits[0] += 1)
	var cuts := [0]
	game.projectiles.curse_cut_at.connect(func(_at: Vector2) -> void: cuts[0] += 1)
	game.player.pos = Vector2(-9, 0)
	game.projectiles.fire_curse(Vector2(0, 0), Vector2.LEFT, 7.0, 10.0, 0.55, 4.0, 55.0, 0.9)
	game.projectiles.fire_wave(Projectiles.Kind.WAVE, Vector2(-9, 0), Vector2.RIGHT, 20.0, 12.0, 4.0, Color.WHITE, [&"heavy"] as Array[StringName])
	for i in 60:
		game.projectiles.step(1.0 / 60.0)
	assert_eq(cuts[0], 1)
	assert_eq(_count(Projectiles.Kind.CURSE), 0)
	assert_eq(hits[0], 0)


func test_the_thin_wave_cuts_too() -> void:
	_fight()
	game.player.pos = Vector2(-30, 0)
	game.projectiles.fire_curse(Vector2(0, 0), Vector2.LEFT, 7.0, 10.0, 0.55, 4.0, 55.0, 0.9)
	game.projectiles.fire_wave(Projectiles.Kind.SPARK, Vector2(-9, 0), Vector2.RIGHT, 20.0, 12.0, 1.0, Color.WHITE, [&"heavy"] as Array[StringName])
	for i in 60:
		game.projectiles.step(1.0 / 60.0)
	assert_eq(_count(Projectiles.Kind.CURSE), 0)


func test_without_the_rule_the_curse_flies_on() -> void:
	_fight()
	game.projectiles.curse_cut = false
	game.player.pos = Vector2(-30, 0)
	game.projectiles.fire_curse(Vector2(0, 0), Vector2.LEFT, 7.0, 10.0, 0.55, 4.0, 55.0, 0.9)
	game.projectiles.fire_wave(Projectiles.Kind.WAVE, Vector2(-9, 0), Vector2.RIGHT, 20.0, 12.0, 4.0, Color.WHITE, [&"heavy"] as Array[StringName])
	for i in 20:
		game.projectiles.step(1.0 / 60.0)
	assert_eq(_count(Projectiles.Kind.CURSE), 1)


func test_a_plain_attack_blow_does_not_cut_it() -> void:
	_fight()
	game.player.pos = Vector2(-30, 0)
	game.projectiles.fire_curse(Vector2(0, 0), Vector2.LEFT, 7.0, 10.0, 0.55, 4.0, 55.0, 0.9)
	game.projectiles.fire_wave(Projectiles.Kind.BLADE, Vector2(-9, 0), Vector2.RIGHT, 20.0, 12.0, 4.0, Color.WHITE, [&"light"] as Array[StringName])
	for i in 40:
		game.projectiles.step(1.0 / 60.0)
	assert_eq(_count(Projectiles.Kind.CURSE), 1)


func test_the_brado_takes_the_curse_with_the_blow() -> void:
	var boss := _fight()
	game.player.invuln = 0.0
	game.player.shield_ready = true
	game.player.hurt(10.0, Vector2(5, 0))
	assert_true(game.player.absorbed_last)
	game._on_status_player(&"curse")
	assert_false(game.player.curse.active(), "no curse")
	game.player.invuln = 0.0
	game.player.hurt(10.0, Vector2(5, 0))
	assert_false(game.player.absorbed_last)
	game._on_status_player(&"curse")
	assert_true(game.player.curse.active(), "a blow taken is cursed")
	assert_not_null(boss)
