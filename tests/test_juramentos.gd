extends GutTest
## E6 (D-63, docs/design/e6_juramentos.md): the Juramentos. The data (the vows of Hades II's Oath with their numbers
## and Fear per rank as Peso), the rules (Juramentos, pure: ranks, Peso, numbers, the stage, Morvath, the waves, the
## Blessings denied), the save (version 4), the Mastery a victory with Peso gives, and a real run with them sworn.

var game: Game


func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev._args.erase("seed")
	Dev._args.erase("juramentos")


func _vows(chosen: Dictionary = {}) -> Juramentos:
	return Juramentos.new(Juramentos.load_catalog(), chosen)


# ---------- the data ----------

func test_the_nine_juramentos_are_data_with_hades_numbers() -> void:
	var v := _vows()
	var ids: Array[StringName] = []
	for d in v.catalog:
		ids.append(d.id)
		assert_true(d.stat in Juramentos.STATS, "%s changes a known word" % d.id)
		assert_eq(d.values.size(), d.weights.size(), "%s: a Peso per rank" % d.id)
		assert_ne(T.t(d.name_key), String(d.name_key), "%s has a name" % d.id)
		var desc := T.t(d.desc_key, {"v": d.shown_value(1)})
		assert_false(desc.contains("{v}"), "%s tells its number" % d.id)
		assert_false(desc.contains("—") or T.t(d.name_key).contains("—"), "no em dash")
	assert_eq(ids, [&"pain", &"grit", &"frenzy", &"hordes", &"menace", &"scars", &"debt", &"denial", &"rivals"] as Array[StringName], "in screen order")
	# Hades II's Oath: Pain +20/60/100% for 1/2/2, Grit +10/20/30% for 1/1/1, Frenzy +20/40% for 3/3, Scars 75/50/0%
	var pain := v.find(&"pain")
	assert_almost_eq(pain.value(3), 1.0, 0.001)
	assert_eq(pain.weight(3), 5)
	assert_eq(v.find(&"grit").weight(3), 3)
	assert_eq(v.find(&"frenzy").weight(2), 6)
	assert_eq(v.find(&"scars").shown_value(3), "0%")
	assert_eq(v.find(&"scars").shown_value(1), "75%")
	assert_eq(v.find(&"pain").shown_value(2), "60%")
	assert_eq(v.find(&"denial").shown_value(1), "2")
	assert_eq(v.max_weight(), 30, "every Juramento at its top")


# ---------- the rules ----------

func test_ranks_are_kept_within_each_juramento() -> void:
	var v := _vows()
	v.set_rank(&"pain", 9)
	assert_eq(v.rank(&"pain"), 3, "never past its top")
	v.set_rank(&"pain", -1)
	assert_eq(v.rank(&"pain"), 0)
	assert_false(v.ranks.has(&"pain"), "off is not kept")
	v.set_rank(&"nobody", 2)
	assert_true(v.ranks.is_empty(), "an unknown id is ignored")
	assert_eq(v.cycle(&"frenzy"), 1)
	assert_eq(v.cycle(&"frenzy"), 2)
	assert_eq(v.cycle(&"frenzy"), 0, "past the top back to off")
	assert_eq(v.cycle(&"frenzy", -1), 2, "down from off goes to the top")


func test_peso_and_numbers_add_up() -> void:
	var v := _vows({"pain": 2, "grit": 3, "scars": 2, "frenzy": 1})
	assert_eq(v.weight(), 3 + 3 + 2 + 3)
	assert_almost_eq(v.scale(&"enemy_damage_pct"), 1.6, 0.001)
	assert_almost_eq(v.scale(&"enemy_hp_pct"), 1.3, 0.001)
	assert_almost_eq(v.scale(&"heal_pct"), 0.5, 0.001)
	assert_almost_eq(v.scale(&"enemy_speed_pct"), 1.2, 0.001)
	assert_almost_eq(v.scale(&"price_pct"), 1.0, 0.001, "a word nobody swore stays as is")
	assert_eq(_vows({"scars": 3}).scale(&"heal_pct"), 0.0, "Scars at its top: no healing")
	assert_eq(v.to_dict(), {"pain": 2, "grit": 3, "scars": 2, "frenzy": 1})


func test_the_switch_and_the_save_read_as_ranks() -> void:
	assert_eq(Juramentos.parse("pain:2, hordes ,debt:1"), {&"pain": 2, &"hordes": 1, &"debt": 1})
	var v := _vows({"pain": 2.0, "hordes": 1.0, "unknown": 3.0, "grit": "x", 7: 1})
	assert_eq(v.to_dict(), {"pain": 2, "hordes": 1}, "JSON floats read, the rest dropped")


func test_the_stage_gets_more_elites_and_dearer_prices_without_touching_the_original() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	assert_eq(_vows().stage_for(stage), stage, "none sworn: the same stage")
	var chances := stage.pools.map(func(p: EncounterPool) -> float: return p.elite_chance)
	var prices := stage.shop_groups.map(func(g: ShopGroup) -> PackedInt32Array: return g.prices.duplicate())
	var out := _vows({"menace": 2, "debt": 1}).stage_for(stage)
	assert_ne(out, stage)
	for i in stage.pools.size():
		assert_almost_eq(out.pools[i].elite_chance, minf(1.0, chances[i] + 0.25), 0.001, "pool %d: 25 points more" % i)
		assert_almost_eq(stage.pools[i].elite_chance, chances[i], 0.001, "the stage's own pool is untouched")
	for g in stage.shop_groups.size():
		for i in prices[g].size():
			assert_eq(out.shop_groups[g].prices[i], roundi(prices[g][i] * 1.4), "group %d item %d 40%% dearer" % [g, i])
			assert_eq(stage.shop_groups[g].prices[i], prices[g][i], "the stage's prices are untouched")


func test_morvath_rests_less_and_raises_more() -> void:
	var def: BossDef = load("res://data/bosses/morvath.tres")
	assert_eq(_vows().boss_for(def), def, "none sworn: the same Morvath")
	var rests := def.rest.duplicate()
	var out := _vows({"rivals": 1}).boss_for(def)
	for i in rests.size():
		assert_almost_eq(out.rest[i], rests[i] * 0.75, 0.001)
		assert_almost_eq(def.rest[i], rests[i], 0.001, "his own data is untouched")
	for i in def.adds_cap.size():
		assert_eq(out.adds_cap[i], def.adds_cap[i] + 2 if def.adds_cap[i] > 0 else 0)
	assert_eq(out.ritual_cap, def.ritual_cap + 2)


func test_hordes_add_a_share_of_each_wave_from_its_first_kind() -> void:
	var waves: Array[Array] = [[&"a", &"a", &"b", &"c", &"d"], [&"b"], []]
	assert_eq(_vows().more_waves(waves), waves, "none sworn: as they were")
	var out := _vows({"hordes": 2}).more_waves(waves)
	assert_eq(out[0], [&"a", &"a", &"b", &"c", &"d", &"a", &"a"], "40% of 5: two more, in the wave's order")
	assert_eq(out[1], [&"b"], "40% of one rounds to none")
	assert_eq(out[2], [])
	assert_eq(_vows({"hordes": 3}).more_waves(waves)[1], [&"b", &"b"], "60% of one rounds to one")


func test_denial_takes_two_of_the_ones_not_chosen() -> void:
	var offered: Array[StringName] = [&"a", &"b", &"c"]
	assert_eq(_vows().denial(offered, &"b"), [] as Array[StringName])
	assert_eq(_vows({"denial": 1}).denial(offered, &"b"), [&"a", &"c"] as Array[StringName])
	var boons := BoonState.new(BoonState.load_catalog())
	var some := boons.catalog[0]
	assert_true(boons.can_offer(some))
	boons.banned[some.id] = true
	assert_false(boons.can_offer(some), "a Blessing denied is never offered again")


# ---------- the save and the Mastery ----------

func test_save_version_4_keeps_the_juramentos() -> void:
	assert_eq(SaveData.VERSION, 4)
	assert_eq(SaveData.defaults().juramentos, {"ranks": {}, "best": 0})
	var old := SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v3.json")))
	assert_eq(old.juramentos, {"ranks": {}, "best": 0}, "a version 3 file opens with none chosen")
	assert_true(Juramentos.unlocked(old), "it had won once: they are open")
	var now := SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v4.json")))
	assert_eq(now.juramentos.best, 7)
	assert_eq(_vows(now.juramentos.ranks).to_dict(), {"pain": 2, "hordes": 1})
	var back := SaveData.merged(JSON.parse_string(JSON.stringify(now)))
	assert_eq(_vows(back.juramentos.ranks).weight(), 4, "written and read again")
	assert_false(Juramentos.unlocked(SaveData.defaults()), "closed before the first victory")


func test_the_best_peso_won_is_kept() -> void:
	var data := SaveData.defaults()
	assert_true(Juramentos.record_win(data, 6))
	assert_false(Juramentos.record_win(data, 4), "a lower Peso is not a record")
	assert_eq(data.juramentos.best, 6)


func test_a_victory_with_peso_gives_more_mastery() -> void:
	var curve := HeroDef.warrior().mastery
	assert_eq(curve.run_xp({"victory": true, "weight": 10}).juramentos, curve.weight_xp * 10)
	assert_eq(curve.run_xp({"victory": false, "weight": 10}).juramentos, 0, "only a victory")
	assert_eq(curve.run_xp({"victory": true}).juramentos, 0)
	var won := curve.run_xp({"victory": true, "weight": 5})
	assert_eq(won.total, curve.victory_xp + curve.weight_xp * 5)


# ---------- a real run ----------

func test_a_run_with_juramentos_sworn() -> void:
	Dev._args["juramentos"] = "pain:2,grit:3,frenzy:1,scars:2,denial:1"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	assert_eq(game.juramentos.weight(), 3 + 3 + 3 + 2 + 2)
	assert_almost_eq(game.player.hurt_scale, 1.6, 0.001, "blows hurt 60% more")
	assert_almost_eq(game.player.heal_scale, 0.5, 0.001, "healing at half")
	assert_almost_eq(game.horde.speed_scale, 1.2, 0.001, "the dead walk 20% faster")
	var d := game.horde.def(&"skeleton")
	var e := game.horde.spawn(d, Vector2(4, 4), false)
	assert_almost_eq(e.max_hp, d.hp * 1.3, 0.01, "30% more life")
	var r := game.result()
	assert_eq(r.weight, 13)
	assert_eq(r.juramentos, {"pain": 2, "grit": 3, "frenzy": 1, "scars": 2, "denial": 1})
	# a Blessing chosen from three: the other two leave the descent
	var rng := RandomNumberGenerator.new()
	game.offer_cards = game.boons.draw(rng, 3, Boon.RARITY_CHANCE, 0.0, 0.0)
	assert_eq(game.offer_cards.size(), 3)
	var others := game.offer_cards.slice(1).map(func(c: BoonState.Card) -> StringName: return c.boon.id)
	game._take(game.offer_cards[0].boon)
	for id: StringName in others:
		assert_true(game.boons.banned.has(id), "%s left the descent" % id)
	assert_eq(game.boons.banned.size(), 2)


func test_a_run_without_juramentos_is_as_before() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	assert_eq(game.juramentos.weight(), 0)
	assert_eq(game.horde.vow_hp, 1.0)
	assert_eq(game.player.hurt_scale, 1.0)
	assert_eq(game.result().juramentos, {})


## QA T5 (Q-T5-3): the cursor left over a row by the title's Iniciar must not steal the focus from "Descer".
func test_a_resting_cursor_does_not_take_the_focus() -> void:
	var s := JuramentoScreen.new()
	add_child_autofree(s)
	s._open_mouse = Vector2(400, 300)
	assert_false(s.hover_takes_focus(Vector2(402, 301)), "a twitch where Iniciar was clicked")
	assert_true(s.hover_takes_focus(Vector2(440, 300)), "a real move")
	s._open_mouse = Vector2.INF
	assert_true(s.hover_takes_focus(Vector2(402, 301)), "after the first real move hover works as before")
