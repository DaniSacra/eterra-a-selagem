extends GutTest
## M-1 of the C11 QA (Morvath nearly white while burning): a tick of fire is no blow and leaves no flash on the body
## (the embers in crowd.gdshader show the burn), while a real blow still flashes; and the ink stroke of elites and the
## boss (crowd_outline.gdshader) never flashes white.

var game: Game


func _start() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)


## Steps the horde alone (no blows from the paladin or the bot) and returns the largest flash seen on `e`.
func _burn_for(e: Enemy, seconds: float) -> float:
	var peak := 0.0
	var t := 0.0
	while t < seconds:
		game.horde.step(1.0 / 60.0)
		peak = maxf(peak, e.flash_t)
		t += 1.0 / 60.0
	return peak


func test_a_burning_boss_does_not_flash_on_each_tick() -> void:
	_start()
	var e := game.boss.e
	e.armor = 0.0
	e.flash_t = 0.0
	e.burn_t = 3.0
	e.burn_dps = 20.0
	var hp := e.hp
	var peak := _burn_for(e, 2.0)
	assert_lt(e.hp, hp, "the fire still hurts him")
	assert_eq(peak, 0.0, "no flash from the ticks")


func test_a_burning_skeleton_does_not_flash_on_each_tick_but_a_blow_does() -> void:
	_start()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(6.0, 6.0), false)
	e.burn_t = 3.0
	e.burn_dps = 1.0
	var hp := e.hp
	var peak := _burn_for(e, 1.2)
	assert_lt(e.hp, hp, "the fire still hurts it")
	assert_eq(peak, 0.0, "no flash from the ticks")
	game.horde.damage(e, 1.0, Vector2.LEFT, 0.0)
	assert_gt(e.flash_t, 0.0, "a blow still flashes")


func test_the_outline_never_flashes_white() -> void:
	var code := (load("res://assets/shaders/crowd_outline.gdshader") as Shader).code
	assert_false(code.contains("vec3(3.0)"), "no white over the glow threshold")
	var re := RegEx.create_from_string("uniform\\s+vec3\\s+flash_color[^=]*=\\s*vec3\\(([^)]*)\\)")
	var m := re.search(code)
	assert_not_null(m, "flash_color")
	if m:
		for v in m.get_string(1).split(","):
			assert_lte(float(v), 0.4, "a warm dark, never white")
