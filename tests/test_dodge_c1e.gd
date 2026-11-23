extends GutTest
## C1e: the dodge as the main defence. Safe on the whole path and no longer, 0.8 s a charge, a close dodge rewarded
## at most once in 2 s (and nobody stunned), the dodge cutting every blow's recovery.

var game: Game


func _run() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func test_rules_close_window_and_cooldown() -> void:
	assert_true(DodgeClose.counts(0.05, 0.15, 0.0))
	assert_true(DodgeClose.counts(0.15, 0.15, 0.0))
	assert_false(DodgeClose.counts(0.16, 0.15, 0.0), "late in the roll is no close one")
	assert_false(DodgeClose.counts(0.05, 0.15, 1.0), "cooling down")


func test_numbers_are_the_dodge_of_c1e() -> void:
	var f := load(Feel.PATH) as Feel
	assert_almost_eq(f.dodge_time, 0.2, 0.001)
	assert_almost_eq(f.dodge_iframes, f.dodge_time, 0.001, "safe on the whole path, not a frame more")
	assert_almost_eq(f.close_cooldown, 2.0, 0.001)
	var h := load("res://data/heroes/warrior.tres") as HeroDef if ResourceLoader.exists("res://data/heroes/warrior.tres") else HeroDef.new()
	assert_almost_eq(h.dodge_recharge, 0.8, 0.001)
	assert_eq(h.dodge_charges, 1, "one charge at the base; Passos and the Gifts give the second")


func test_safe_through_the_roll_then_hurt() -> void:
	_run()
	var p := game.player
	p.dodge_charges = 1
	p._start_dodge(Vector2.RIGHT)
	for i in 6:
		p.step(0.016, Vector2.ZERO, Vector2.ZERO)
	var hp := p.hp
	p.hurt(5.0, p.pos + Vector2.LEFT)
	assert_eq(p.hp, hp, "protected on the path")
	for i in 20:
		p.step(0.016, Vector2.ZERO, Vector2.ZERO)
	assert_ne(p.state, Player.State.DODGE)
	p.hurt(5.0, p.pos + Vector2.LEFT)
	assert_lt(p.hp, hp, "no safety left after the path")


func test_close_dodge_rewarded_once_per_two_seconds_and_stuns_nobody() -> void:
	_run()
	var p := game.player
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3, 0), false)
	var stun_before: float = e.stun_t
	var closes: Array[int] = [0]
	p.dodge_close.connect(func() -> void: closes[0] += 1)
	p.dodge_charges = 2
	p.dodge_max = 2
	p._start_dodge(Vector2.RIGHT)
	p.step(0.016, Vector2.RIGHT, Vector2.ZERO)
	p.hurt(5.0, Vector2.ZERO)
	assert_eq(closes[0], 1, "a blow in the first 0.15 s")
	assert_eq(game.dodge_closes, 1)
	p.hurt(5.0, Vector2.ZERO)
	assert_eq(closes[0], 1, "cooling down")
	for i in 20:
		p.step(0.016, Vector2.ZERO, Vector2.ZERO)
	p._start_dodge(Vector2.RIGHT)
	p.hurt(5.0, Vector2.ZERO)
	assert_eq(closes[0], 1, "less than 2 s since")
	assert_eq(e.stun_t, stun_before, "no one is stunned (F8)")


func test_a_late_blow_is_no_close_one() -> void:
	_run()
	var p := game.player
	var closes: Array[int] = [0]
	p.dodge_close.connect(func() -> void: closes[0] += 1)
	p.dodge_charges = 1
	p._start_dodge(Vector2.RIGHT)
	for i in 11:
		p.step(0.016, Vector2.ZERO, Vector2.ZERO)
	assert_eq(p.state, Player.State.DODGE)
	p.hurt(5.0, Vector2.ZERO)
	assert_eq(closes[0], 0)


func test_the_dodge_cuts_every_recovery() -> void:
	_run()
	assert_true(game.player.runner.can_cancel(), "any move, any moment")
	assert_eq(Player.DODGE_BUFFER, 0.15, "a press kept 0.15 s")
