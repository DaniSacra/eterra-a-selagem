extends GutTest
## SW-O4: Morvath short, the end of the first descent: when the life of the last phase (1) is gone he does not go to the
## next one: he kneels invulnerable and `tutorial_end` is said; no `defeated`, no phase change. The normal fight is the
## same (last_phase 0).

var game: Game
var _ended := 0
var _defeated := 0
var _phases := 0


func after_each() -> void:
	Dev.drop("boss-short")


func _start(short: bool) -> Boss:
	if short:
		Dev.put("boss-short", "1")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	_ended = 0
	_defeated = 0
	_phases = 0
	game.boss.tutorial_end.connect(func() -> void: _ended += 1)
	game.boss.defeated.connect(func() -> void: _defeated += 1)
	game.boss.phase_changed.connect(func(_p: int) -> void: _phases += 1)
	return game.boss


func _run(seconds: float) -> void:
	var t := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		game._step(1.0 / 60.0)
		t += 1.0 / 60.0


func _blow(boss: Boss) -> void:
	var heavy := ComboNode.new()
	heavy.tags = [&"heavy", &"finisher"]
	heavy.damage = 99999.0
	heavy.reach = 40.0
	heavy.shape = ComboNode.Shape.CIRCLE
	boss.e.armor = 0.0
	game.combat.strike(heavy, boss.e.pos + Vector2(2.0, 0.0), Vector2.LEFT)


func test_a_normal_fight_has_no_last_phase_and_full_life() -> void:
	var boss := _start(false)
	assert_eq(boss.last_phase, 0)
	assert_eq(boss.hp_scale, 1.0)
	assert_eq(boss.e.max_hp, (load("res://data/enemies/morvath.tres") as EnemyDef).hp)


func test_short_morvath_has_the_scaled_life() -> void:
	var boss := _start(true)
	assert_eq(boss.last_phase, 1)
	assert_almost_eq(boss.e.max_hp, (load("res://data/enemies/morvath.tres") as EnemyDef).hp * 0.6, 0.01)
	assert_almost_eq(boss.e.hp_floor, boss.e.max_hp * 0.66, 0.01, "phase 1 ends at its floor")


func test_the_last_phase_ends_the_fight_instead_of_the_next_phase() -> void:
	var boss := _start(true)
	_run(3.0)
	_blow(boss)
	_run(1.0)
	assert_eq(boss.state, Boss.State.TUTORIAL_END)
	assert_eq(_ended, 1)
	assert_eq(_phases, 0, "no second phase")
	assert_eq(_defeated, 0, "not a victory")
	assert_eq(boss.phase, 1)
	assert_true(boss.e.alive and boss.e.invulnerable)
	_run(4.0)
	assert_eq(_ended, 1, "said once")
	assert_eq(boss.state, Boss.State.TUTORIAL_END, "he stays on his knees")


func test_without_the_option_the_same_blow_goes_to_phase_two() -> void:
	var boss := _start(false)
	_run(3.0)
	_blow(boss)
	_run(2.0)
	assert_eq(_ended, 0)
	assert_eq(_phases, 1)
	assert_eq(boss.phase, 2)
