extends GutTest
## Daniel 2026-11-27: the Warrior's four mouse blows cost no Magia, so nothing of his spends it. What was built on the cost follows:
## no Magia bar, no Magia door nor shelf, the altar's candles give life, no Magia card in the Provação, the Gifts that fed on it feed
## the Supremo. The Maga keeps all of it.


func test_only_the_maga_uses_magia() -> void:
	assert_false(HeroDef.warrior().uses_magick())
	assert_true(HeroDef.maga().uses_magick())


func test_no_blow_of_the_warrior_has_a_cost_and_nothing_gives_magia_back() -> void:
	var hero := HeroDef.warrior()
	var tree: ComboTree = load(hero.combos)
	for n in tree.all_nodes():
		assert_eq(n.magick_cost, 0.0, String(n.id))
		assert_eq(n.magick_per_hit, 0.0, String(n.id))
	assert_eq([hero.magick_on_finisher, hero.magick_on_break], [0.0, 0.0])


func test_the_stage_without_magia_swaps_the_doors_and_empties_the_shelf() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	assert_true(stage.reward_deck.has(RunMap.Reward.MAGICK), "the base stage has them")
	var out := stage.without_magick()
	assert_false(out.reward_deck.has(RunMap.Reward.MAGICK))
	assert_eq(out.reward_deck.size(), stage.reward_deck.size(), "a card for a card")
	assert_eq(stage.reward_deck.count(RunMap.Reward.GOLD) + stage.reward_deck.count(RunMap.Reward.MAGICK), out.reward_deck.count(RunMap.Reward.GOLD))
	for depth: Variant in out.fixed_rewards:
		assert_false((out.fixed_rewards[depth] as PackedInt32Array).has(RunMap.Reward.MAGICK))
	for g in out.shop_groups:
		assert_false(g.items.has(RunMap.Reward.MAGICK))
		assert_eq(g.items.size(), g.prices.size())
		assert_eq(g.items.size(), g.weights.size())
	assert_true(stage.reward_deck.has(RunMap.Reward.MAGICK), "the shared stage is untouched")


func test_the_candles_give_life_to_a_hero_without_magia() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var o := Altar.options(stage, 100, 50.0, true, 30.0, stage.altar_candle_life)
	var candles: Dictionary = o[Altar.Option.CANDLES]
	assert_eq(candles.gain, stage.altar_candle_life)
	assert_true(candles.life)
	assert_eq([candles.get_from, candles.get_to], [50.0, 50.0 + stage.altar_candle_life])
	var maga: Dictionary = Altar.options(stage, 100, 50.0, true, 50.0)[Altar.Option.CANDLES]
	assert_eq(maga.gain, stage.altar_magick, "the Maga still lights them for Magia")
	assert_false(maga.has("life"))
	for key in [&"altar_candles_life_get", &"altar_candles_life_get_detail"]:
		assert_ne(T.t(key), String(key))


func test_the_provacao_never_offers_magia_ampla_to_the_warrior() -> void:
	var all := Trials.new(Trials.load_catalog())
	var has := func(t: Trials) -> bool:
		for d in t.catalog:
			if d.id == &"trial_reserva":
				return true
		return false
	assert_true(has.call(all))
	all.drop_magick()
	assert_false(has.call(all))
	assert_gt(all.catalog.size(), 5, "the others stay")


func test_the_warrior_hud_has_two_bars_and_the_maga_three() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	var hud := game.hud
	assert_false(hud._magick.visible)
	assert_eq(hud._bar_count(), 2)
	assert_false(hud.has_method("_magick_ticks"), "the cost ticks left with the costs")


func test_the_gifts_that_fed_on_magia_charge_the_supremo() -> void:
	var boons := BoonState.new()
	boons.equip_talents(HeroDef.warrior().talents().defs([&"forca_concentrada", &"determinacao", &"forca_titanica"] as Array[StringName]))
	assert_almost_eq(boons.stat(&"ult_charge_pct"), 0.25, 0.0001)
	assert_eq(boons.stat(&"omega_cost_pct"), 0.0)
	assert_eq(boons.stat(&"magick_max"), 0.0)
	assert_eq(boons.stat(&"attack_magick_pct"), 0.0)
