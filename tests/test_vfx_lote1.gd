extends GutTest
## The VFX pass, Lote 1, gameplay's share (docs/art/vfx_pass_spec.md 4, 5.3, 5.4 and 6): the light that falls on what
## is taken (the reward of a room won, the shop's items by the gold, the fountain while it has water; no column), the
## families' colours (the Vigília sage, apart from the Luz; the Elo and the Psalm old gold) and the magic of the dead
## in crimson and magenta. No time changes.

const R := RunMap.Reward


func _hue(c: Color) -> float:
	return c.h * 360.0


func _gap(a: float, b: float) -> float:
	var d := absf(a - b)
	return minf(d, 360.0 - d)


func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	return game


func test_the_families_colours_follow_the_spec() -> void:
	var c := Boon.FAMILY_COLOR
	assert_between(_hue(c[Boon.Family.CHAMA]), 28.0, 38.0, "the Chama amber, out of the danger's red")
	assert_between(_hue(c[Boon.Family.VIGILIA]), 80.0, 95.0, "the Vigília sage (decided)")
	assert_between(_hue(c[Boon.Family.LUZ]), 40.0, 48.0, "the Luz pale gold")
	assert_lt(c[Boon.Family.LUZ].s, 0.35, "pale")
	assert_eq(c[Boon.Family.DUO], PsalmDef.new().color, "the Elo old gold, the Psalm's")
	assert_gte(_gap(_hue(c[Boon.Family.VIGILIA]), _hue(Combat.EMETH)), 25.0, "the Vigília apart from the Emeth")
	assert_gte(_gap(_hue(c[Boon.Family.CHAMA]), 0.0), 26.0, "the Chama apart from the warning's red")
	assert_eq(Combat.FIRE, c[Boon.Family.CHAMA])
	assert_eq(Combat.LIGHT, c[Boon.Family.LUZ])
	assert_eq(Combat.VIGIL, c[Boon.Family.VIGILIA])


func test_the_vigilia_strikes_in_its_own_colour() -> void:
	var game := _game()
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	var combat := game.combat
	assert_eq(combat.color_of([&"skill", &"vigilia"] as Array[StringName]), Combat.VIGIL, "the Vigília's own")
	assert_eq(combat.color_of([&"skill", &"luz"] as Array[StringName]), Combat.LIGHT, "the Luz keeps Elun's gold")
	assert_eq(combat.color_of([&"skill", &"chama"] as Array[StringName]), Combat.FIRE)
	assert_eq(combat.color_of([&"light"] as Array[StringName]), Combat.EMETH)


func test_the_dead_shoot_crimson_and_magenta_and_violet_is_morvath_s() -> void:
	for id: StringName in [&"runner", &"runner_elite", &"archer", &"archer_elite"]:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		assert_between(_hue(d.magic_color), 345.0, 356.0, "%s crimson" % id)
	for id: StringName in [&"mage", &"mage_elite", &"priest", &"priest_elite", &"priest_elder"]:
		var d: EnemyDef = load("res://data/enemies/%s.tres" % id)
		assert_between(_hue(d.magic_color), 328.0, 338.0, "%s magenta (333 in the material: 320 to 330 on the screen)" % id)
	var morvath: EnemyDef = load("res://data/enemies/morvath.tres")
	assert_ne(_hue(morvath.magic_color), _hue((load("res://data/enemies/mage.tres") as EnemyDef).magic_color), "Morvath's own")


func test_the_rewards_leave_the_danger_red() -> void:
	for r: int in [R.POM, R.POM_SLICE, R.HEART]:
		var c := Rooms._reward_color(r)
		assert_lte(c.s, 0.5, "%s a rose, never the danger's red" % R.keys()[r])
	assert_eq(Rooms.PSALM_COLOR, PsalmDef.new().color, "the Psalm in old gold")


func test_a_blessing_by_one_angel_is_lit_in_its_seal_and_the_shop_by_the_gold() -> void:
	var game := _game()
	var room := RunMap.Room.new(RunMap.Kind.COMBAT, R.BOON, 3)
	assert_eq(game.rooms._angel_family(room), -1, "no angel at the door: ivory")
	room.angel = game.encounters.book.catalog[0].id
	assert_eq(game.rooms._angel_family(room), game.encounters.book.catalog[0].family, "the door's angel")
	room.meeting = true
	assert_eq(game.rooms._angel_family(room), -1, "two angels: ivory")
	assert_eq(Rooms.shop_light(true), RewardShaft.SHOP_CAN)
	assert_eq(Rooms.shop_light(false), RewardShaft.SHOP_CANNOT)


func _lifted(s: RewardShaft) -> bool:
	return not is_instance_valid(s) or s.is_queued_for_deletion() or s.stage == RewardShaft.Stage.UP


func test_the_room_won_lights_its_reward_until_he_takes_it() -> void:
	var game := _game()
	game.rooms._room_cleared()
	if game.rooms.room.reward == R.NONE:
		pass_test("no reward in this room")
		return
	var shaft: RewardShaft = game.rooms.get(&"_reward_shaft")
	assert_not_null(shaft, "a shaft over the reward")
	assert_true(game.fx.last_beam.is_empty(), "and no column")
	assert_eq(shaft.stage, RewardShaft.Stage.WAITING, "it waits for the last kill's slow motion")
	assert_almost_eq(shaft.strength, 1.0, 0.001)
	var at: Vector2 = game.rooms.get(&"_reward_at")
	assert_almost_eq(Vector2(shaft.global_position.x, shaft.global_position.z).distance_to(at), 0.0, 0.01, "on the reward")
	game.rooms._collect()
	assert_true(_lifted(shaft), "taking the reward lifts it")


func test_the_shop_lights_follow_the_gold() -> void:
	var game := _game()
	game.rooms.start_at(RunMap.Kind.SHOP)
	game.rooms.gold = 0
	var pedestals: Array = game.rooms.get(&"_pedestals")
	assert_gt(pedestals.size(), 0)
	for p: Dictionary in pedestals:
		var s: RewardShaft = p.shaft
		assert_not_null(s, "every item has its light")
		assert_eq(s.stage, RewardShaft.Stage.HERE, "all at once as he comes in")
		assert_almost_eq(float(s.get(&"_target")), RewardShaft.SHOP_CANNOT, 0.001, "faint without the gold")
	game.rooms.gold = 9999
	for p: Dictionary in pedestals:
		assert_almost_eq(float(p.shaft.get(&"_target")), RewardShaft.SHOP_CAN, 0.001, "strong when the gold reaches it")
	var first: Dictionary = pedestals[0]
	var shaft: RewardShaft = first.shaft
	game.player.pos = first.at
	game.rooms._step_shop(true)
	assert_true(_lifted(shaft), "a bought item's light rises")


func test_the_fountain_is_lit_while_it_has_water() -> void:
	var game := _game()
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	var shaft: RewardShaft = game.get(&"_fountain_shaft")
	assert_not_null(shaft, "the fountain's light")
	assert_almost_eq(shaft.strength, RewardShaft.FOUNTAIN, 0.001)
	game.player.pos = game.get(&"_fountain_at")
	game.player.hp = 1.0
	game.call(&"_step_fountain")
	assert_true(_lifted(shaft), "spent, its light goes")


func _gold_slivers(game: Game) -> int:
	var gold := CrowdRenderer.GILD_COLOR * Fx.MOTE_GLOW
	var n := 0
	for i in game.fx._mote_n:
		var c: Color = game.fx._mote_color[i]
		if c.is_equal_approx(Color(gold.r, gold.g, gold.b)):
			n += 1
	return n


## V-14: a gilded elite falls with two slivers of old gold more; a common one and a guardian with none.
func test_a_gilded_elite_falls_with_two_gold_slivers() -> void:
	var game := _game()
	game.horde.clear_crowd()
	var at := game.player.pos + Vector2(4, 0)
	for id: StringName in [&"skeleton", &"knight", &"skeleton_elite"]:
		var before := _gold_slivers(game)
		var e := game.horde.spawn(game.horde.def(id), at, false)
		e.armor = 0.0
		game.horde.damage(e, 99999.0, Vector2.RIGHT, 0.0)
		assert_false(e.alive, "%s fell" % id)
		assert_eq(_gold_slivers(game) - before, 2 if id == &"skeleton_elite" else 0, "%s: gold slivers" % id)
