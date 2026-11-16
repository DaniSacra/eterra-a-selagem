extends GutTest
## Morvath falls without turning white (BUG-004 of cycle 10, ART_REVIEW B1): no flash from the killing blow nor from
## the fall, no fire or frost glowing on him, and his body darkens over the ending. A gift's column falling on him is
## drawn faint (ART-004).

var game: Game


func _start_fight() -> Boss:
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


func _into_last_phase(boss: Boss) -> void:
	_run(3.0)
	boss.e.hp = boss.e.max_hp * 0.1
	boss.phase = 4
	boss._ritual_done = true
	boss.e.hp_floor = 0.0
	boss.e.armor = 0.0


func test_the_killing_blow_leaves_no_flash_nor_burn_on_him() -> void:
	var boss := _start_fight()
	_into_last_phase(boss)
	boss.e.burn_t = 2.0
	boss.e.burn_dps = 5.0
	var heavy := ComboNode.new()
	heavy.tags = [&"heavy", &"finisher"]
	heavy.damage = 99999.0
	heavy.reach = 40.0
	heavy.shape = ComboNode.Shape.CIRCLE
	game.combat.strike(heavy, boss.e.pos + Vector2(2.0, 0.0), Vector2.LEFT)
	assert_false(boss.e.alive)
	assert_eq(boss.state, Boss.State.DYING)
	assert_lte(boss.e.flash_t, 0.0, "no flash from the blow that fells him")
	assert_eq(boss.e.burn_t, 0.0, "no fire glowing on him")
	assert_eq(boss.e.frozen_t, 0.0)


func test_his_body_darkens_over_the_ending() -> void:
	var boss := _start_fight()
	_into_last_phase(boss)
	var mat := boss._material()
	assert_not_null(mat)
	var tint: Color = mat.get_shader_parameter(&"tint")
	var grey := float(mat.get_shader_parameter(&"desaturate"))
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0, Fx.GOLD, true, true)
	assert_lte(boss.e.flash_t, 0.0, "a big blow too")
	_run(Boss.VICTORY_DIM_TIME + 0.1)
	var dark: Color = mat.get_shader_parameter(&"tint")
	assert_almost_eq(dark.r, tint.r * Boss.VICTORY_DIM, 0.01, "his colour dims to stone")
	assert_almost_eq(dark.b, tint.b * Boss.VICTORY_DIM, 0.01)
	assert_gt(float(mat.get_shader_parameter(&"desaturate")), grey, "and greys")
	assert_eq(float(mat.get_shader_parameter(&"paint_glow")), 0.0, "his glow is out")
	assert_eq(float(mat.get_shader_parameter(&"crest")), 0.0, "and the pale light on his crown")


func test_a_fallen_boss_is_drawn_without_the_flash_of_the_fallen() -> void:
	var boss := _start_fight()
	_into_last_phase(boss)
	var skeleton := game.horde.spawn(game.horde.def(&"skeleton"), boss.e.pos + Vector2(6, 0), false)
	game.horde.damage(skeleton, 99999.0, Vector2.DOWN, 0.0)
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	game.horde.step(1.0 / 60.0)
	assert_true(game.horde.dying.has(boss.e))
	assert_true(game.horde.dying.has(skeleton))
	assert_gt(Horde.death_flash(skeleton), 0.5, "the fallen flash for an instant")
	assert_eq(Horde.death_flash(boss.e), 0.0, "never him")


func test_a_column_falling_on_him_is_faint() -> void:
	var boss := _start_fight()
	_run(3.0)
	assert_true(Skills.over_boss(boss.e, boss.e.pos + Vector2(0.5, 0.0), 0.35))
	assert_false(Skills.over_boss(boss.e, boss.e.pos + Vector2(8.0, 0.0), 0.35))
	assert_false(Skills.over_boss(null, Vector2.ZERO, 1.0))
	assert_lt(Skills.BEAM_OVER_BOSS * Fx.BEAM_INTENSITY, 1.0, "its core stays under the glow over him")
	# art review P4: a tall column between him and the camera covers him on the screen too; one behind him does not
	var toward_cam := Vector2(sin(deg_to_rad(35.0)), cos(deg_to_rad(35.0)))
	assert_true(Skills.over_boss(boss.e, boss.e.pos + toward_cam * 6.0, 1.6, 16.0, 35.0, 30.0), "in front of him")
	assert_false(Skills.over_boss(boss.e, boss.e.pos - toward_cam * 6.0, 1.6, 16.0, 35.0, 30.0), "behind him")
	assert_false(Skills.over_boss(boss.e, boss.e.pos + toward_cam * 6.0, 1.6), "without its height, only on him")
	assert_lt(Skills.BEAM_CORE_CAP, 1.01, "the core over him never past the glow threshold")


func test_a_strong_blow_never_turns_him_ivory() -> void:
	var boss := _start_fight()
	_run(1.0)
	boss.e.armor = 0.0
	boss.e.invulnerable = false
	game.horde.damage(boss.e, 1.0, Vector2.DOWN, 0.0, Fx.GOLD, true, true)
	assert_lt(boss.e.flash_power, 0.85, "under crowd.gdshader's white_from: lighter and warmer, never the ivory frame")
	assert_almost_eq(boss.e.flash_power, Horde.BOSS_FLASH, 0.001)
