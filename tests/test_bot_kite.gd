extends GutTest
## The bot that sometimes keeps away (--bot-kite, QW-004 of cycle 10): it spends its share of each KITE_PERIOD far
## from the boss, and so Morvath's dash (which needs 9 m) comes in a real fight. Also the paladin's own light bursts
## stay under the glow and behind him (ART-009).

var game: Game


func test_it_keeps_away_its_share_of_the_time() -> void:
	var bot := Bot.new()
	assert_false(bot.kite_step(1.0, true), "off by default")
	bot.kite = 0.2
	var dt := 1.0 / 60.0
	var kiting := 0.0
	var steps := int(Bot.KITE_PERIOD * 5.0 / dt)
	for i in steps:
		if bot.kite_step(dt, true):
			kiting += dt
	assert_almost_eq(kiting / (Bot.KITE_PERIOD * 5.0), 0.2 * 4.0 / 5.0, 0.01, "a fifth of each period after the first")
	# running out there does not count: it keeps away until it has been far its share
	bot = Bot.new()
	bot.kite = 0.2
	for i in int(Bot.KITE_PERIOD / dt) + 1:
		bot.kite_step(dt, false)
	var near := 0.0
	while bot.kite_step(dt, near >= 1.0) and near < Bot.KITE_PERIOD:
		near += dt
	assert_almost_eq(near, 1.0 + 0.2 * Bot.KITE_PERIOD, 0.05, "one second to get there, then its share far")


func test_keeping_away_draws_his_dash_in_a_real_fight() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	var bot := Bot.new()
	bot.kite = 0.5
	game.bot = bot
	var old: Variant = Controls.virtual
	Controls.virtual = bot.pad
	var far := [0.0]
	var t := 0.0
	var dt := 1.0 / 60.0
	while t < 60.0 and game.boss != null and int((game.boss.stats.attacks as Dictionary).get(&"dash", 0)) == 0:
		game.player.invuln = 10.0
		bot.step(dt, game)
		game._step(dt)
		if game.boss and game.player.pos.distance_to(game.boss.e.pos) > 9.0:
			far[0] += dt
		t += dt
	Controls.virtual = old
	assert_not_null(game.boss)
	assert_gt(far[0], 1.0, "it got away from him")
	assert_gt(int((game.boss.stats.attacks as Dictionary).get(&"dash", 0)), 0, "and he dashed at it")


func test_the_paladins_light_stays_under_the_glow_and_behind_him() -> void:
	var light: Color = Fx.BURSTS[&"light"][0]
	assert_lte(maxf(light.r, maxf(light.g, light.b)), 1.101, "no glow, no saturated yellow")
	assert_gt(light.b / light.r, 0.6, "ivory, not yellow")
	var fx := Fx.new()
	add_child_autofree(fx)
	var camera := Camera3D.new()
	add_child_autofree(camera)
	camera.global_position = Vector3(10, 30, 20)
	fx.camera = camera
	var at := Vector3(0, 1.2, 0)
	var off := fx.behind(at, Fx.HERO_BURST_BACK)
	assert_almost_eq(off.length(), Fx.HERO_BURST_BACK, 0.001)
	assert_eq(off.y, 0.0)
	var to_camera := Vector3(camera.global_position.x - at.x, 0, camera.global_position.z - at.z)
	assert_lt(off.dot(to_camera), 0.0, "away from the camera")
