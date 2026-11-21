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
	# since C12d the dart roots him 0.71 s (D-44, as in Hades II): standing still far away draws the dash sooner
	assert_gt(far[0], 0.3, "it got away from him")
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


## B-2: the bot walks to a fountain that still has light when under 60% of its life, never otherwise.
func test_the_bot_drinks_from_the_fountain_when_hurt() -> void:
	var spring := Rooms.FOUNTAIN_SPOT
	assert_eq(Bot.drink_at(spring, 10.0, 30.0), spring, "hurt: to the fountain")
	assert_eq(Bot.drink_at(spring, 18.0, 30.0), spring, "at 60% too (QW-112: the door's share)")
	assert_null(Bot.drink_at(spring, 24.0, 30.0), "at 80% it goes on")
	assert_null(Bot.drink_at(spring, 30.0, 30.0))
	assert_null(Bot.drink_at(null, 5.0, 30.0), "no fountain, or its light is spent")


## B-2 in a real room: hurt in the fountain room (no fight), the bot drinks before it takes a door.
func test_the_bot_drinks_in_the_fountain_room() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	var bot := Bot.new()
	game.bot = bot
	var old: Variant = Controls.virtual
	Controls.virtual = bot.pad
	game.player.hp = game.player.max_hp * 0.4
	var dt := 1.0 / 60.0
	var t := 0.0
	while t < 12.0 and game.fountain_target() != null:
		bot.step(dt, game)
		game._step(dt)
		t += dt
	Controls.virtual = old
	assert_null(game.fountain_target(), "the fountain's light is spent: it drank")
	assert_gt(game.player.hp, game.player.max_hp * 0.6, "and was healed")
