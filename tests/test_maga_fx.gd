extends GutTest
## F7: the Maga's own spell effects (MagaFx, maga_spell.gdshader): a card pool with a ceiling, faint cards on the floor drawn before every
## warning, one card per spell piece, no violet and no red in the palette, the shader in the warm-up set.

var fx: MagaFx


func before_each() -> void:
	fx = MagaFx.new()
	add_child_autofree(fx)


func test_the_floor_is_faint_and_draws_before_the_warnings() -> void:
	for form in [MagaFx.FORM_CONE, MagaFx.FORM_FROST, MagaFx.FORM_RING, MagaFx.FORM_STEAM, MagaFx.FORM_CRYSTALS]:
		assert_true(MagaFx.is_ground(form))
		assert_lte(MagaFx.alpha_for(form), 0.6, "a ground card keeps a warning under it readable")
	for form in [MagaFx.FORM_ARC, MagaFx.FORM_ORB, MagaFx.FORM_STREAK]:
		assert_false(MagaFx.is_ground(form))
	assert_lt(MagaFx.GROUND_PRIORITY, 0, "before the default order of a warning")
	assert_lt(MagaFx.GROUND_Y, 0.1, "under every body")


func test_the_pool_has_a_ceiling() -> void:
	for i in 40:
		fx.bolt(Vector2.ZERO, Vector2(3.0, 0.0))
		fx.thermal(Vector2(i, 0.0))
	assert_lte(fx.live(), MagaFx.MAX_LIVE)
	assert_false(MagaFx.room_for(MagaFx.MAX_LIVE))
	assert_true(MagaFx.room_for(0))


func test_cards_are_short_and_go_away() -> void:
	fx.trails(Vector2.ZERO, [Vector2.RIGHT, Vector2.RIGHT.rotated(0.2), Vector2.RIGHT.rotated(-0.2)] as Array[Vector2])
	fx.cone(Vector2.ZERO, Vector2.RIGHT, 5.0, 90.0)
	fx.impact(Vector2(4, 0), 2.0)
	fx.crystallize(Vector2.ZERO)
	fx.overload(Vector2.ZERO, 1.8)
	assert_gt(fx.live(), 5)
	for i in 120:
		fx.step(1.0 / 60.0)
	assert_eq(fx.live(), 0, "everything is gone in two seconds")


func test_the_trails_run_ahead() -> void:
	fx.trails(Vector2.ZERO, [Vector2.RIGHT] as Array[Vector2])
	var node := fx.get_child(1) as Node3D
	var x0 := node.position.x
	fx.step(0.1)
	assert_gt(node.position.x, x0)


func test_the_frost_lasts_its_life_then_melts_away() -> void:
	fx.frost(Vector2(2, 2), 3.0, 1.0)
	assert_true(fx.has_frost())
	fx.step(0.5)
	assert_true(fx.has_frost())
	fx.step(0.6)
	assert_false(fx.has_frost())
	fx.frost(Vector2.ZERO, 2.0, 5.0)
	fx.clear()
	assert_false(fx.has_frost())


func test_the_palette_has_no_violet_and_no_red() -> void:
	for c: Color in [MagaFx.AMBER, MagaFx.ICE, MagaFx.IVORY, MagaFx.GOLD, MagaFx.ORANGE, MagaFx.STEAM, MagaFx.HOT]:
		var violet: bool = c.b > c.g + 0.05 and c.r > c.g + 0.05
		assert_false(violet)
		var red: bool = c.r > 0.7 and c.g < 0.3 and c.b < 0.3
		assert_false(red)


func test_the_staff_tip_is_in_front_and_high() -> void:
	var tip := MagaFx.tip_of(Vector2(1, 1), Vector2(0, 1))
	assert_almost_eq(tip.x, 1.0, 0.001)
	assert_gt(tip.z, 1.0)
	assert_gt(tip.y, 1.0)
	assert_almost_eq(MagaFx.yaw_of(Vector2.RIGHT), 0.0, 0.001)


func test_the_spells_play_in_a_run_and_the_room_clears_them() -> void:
	Dev.put("hero", "maga")
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	assert_not_null(game.arcane.vfx)
	game.arcane.vfx.bolt(Vector2.ZERO, Vector2(4, 0))
	game.arcane.vfx.frost(Vector2(3, 3), 3.0, 5.0)
	game.arcane.clear()
	assert_eq(game.arcane.vfx.live(), 0)
	assert_false(game.arcane.vfx.has_frost())
	Dev.drop("hero")
