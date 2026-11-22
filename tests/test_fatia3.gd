extends GutTest
## Rejogabilidade, Fatia 3 "o fim de jogo" (sistemas.md 1.5, 1.7, 3.6): the Forjador's second and third tools open
## Despertar (Esmeralda, one awake) and Inscrever (an Encanto learned); Encantos 4 to 6; Discernimento I (a reroll
## of a Blessing's choice once a descent) and II (one more layer of angels on the map); the Vendedor's Obras and
## trades; Esmeralda by a new best Peso; the Compêndio's Anjos tab. Working names.

var game: Game


func _run(kind := RunMap.Kind.COMBAT) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func after_each() -> void:
	for k in ["discern", "inscribed"]:
		Dev.drop(k)


func test_awaken_behind_the_second_tool_one_awake() -> void:
	var forge := Forge.new(Forge.load_catalog())
	var d := SaveData.defaults()
	var wake := forge.track(Forge.AWAKEN)
	assert_eq(wake.size(), 3)
	for r in wake:
		assert_eq(r.material, MaterialPurse.EMERALD, "%s in Esmeralda" % r.id)
		assert_ne(T.t(r.name_key), String(r.name_key))
		assert_false(T.t(r.desc_key).contains("—"))
	var sede := forge.find(&"awaken_sede")
	assert_eq(forge.problem(d, sede), Forge.Problem.NO_TOOL)
	Forge.add_tool(d, Forge.TOOL_AWAKEN)
	assert_eq(forge.problem(d, sede), Forge.Problem.SHORT)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 5)
	assert_true(forge.buy(d, &"awaken_sede"))
	assert_eq(forge.awake(d), sede, "the first bought wakes")
	assert_true(forge.buy(d, &"awaken_impeto"))
	assert_eq(forge.awake(d), sede, "the second waits")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.EMERALD), 0)
	assert_true(forge.put_on(d, &"awaken_impeto"))
	assert_eq(forge.awake(d).id, &"awaken_impeto", "one awake")
	var state := BoonState.new(BoonState.load_catalog())
	state.equip_forge(forge.ranks_for(d))
	assert_eq(state.stat(&"finisher_magick"), 3.0, "the descent carries the one awake")
	assert_eq(state.stat(&"heal_on_kill"), 0.0)
	var back := SaveData.merged(JSON.parse_string(JSON.stringify(d)))
	assert_eq(forge.awake(back).id, &"awaken_impeto", "kept in the save")
	assert_eq(Forge.rank_of(back, Forge.AWAKEN), 2)
	forge.take_off(d, Forge.AWAKEN)
	assert_null(forge.awake(d))


func test_inscribe_behind_the_third_tool_learns_an_encanto() -> void:
	var forge := Forge.new(Forge.load_catalog())
	var catalog := Enchants.load_catalog()
	var d := SaveData.defaults()
	assert_eq(Enchants.learned(catalog, d).size(), 3, "the three of the Fatia 2")
	var cut := forge.find(&"corte_sismico")
	assert_eq(cut.track, Forge.INSCRIBE)
	assert_eq(T.t(cut.name_key), "Corte Sísmico", "it reads as the Encanto")
	MaterialPurse.give(d, MaterialPurse.SILVER, 50)
	assert_eq(forge.problem(d, cut), Forge.Problem.NO_TOOL)
	Forge.add_tool(d, Forge.TOOL_INSCRIBE)
	assert_true(forge.buy(d, &"corte_sismico"))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 30)
	var pool := Enchants.learned(catalog, d)
	assert_eq(pool.size(), 4)
	assert_true(pool.any(func(e: EnchantDef) -> bool: return e.id == &"corte_sismico"))
	assert_false(forge.ranks_for(d).has(cut), "no numbers of its own in the descent")


func test_encantos_four_to_six_and_their_rules() -> void:
	var all := Enchants.load_catalog()
	assert_eq(all.size(), 6)
	var none: Array[EnchantDef] = []
	for e in all.slice(3):
		assert_false(e.learned, "%s waits to be inscribed" % e.id)
		assert_false(T.t(e.desc_key).contains("—"))
	var twin := all[4]
	assert_false(Enchants.allowed(twin, none, [&"onda_carregada"] as Array[StringName]), "never with the Onda Carregada")
	var eco := all[5]
	var back: Array[EnchantDef] = [all[2]]
	assert_false(Enchants.allowed(eco, back, [] as Array[StringName]), "never with the Retorno do Corte")


func test_corte_sismico_strikes_the_floor_round_him() -> void:
	_run()
	game.boons.take_enchant(load("res://data/enchants/03_corte_sismico.tres"))
	var far := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(0, 4.0), false)
	far.hp = 9999.0
	var spin: ComboNode = _first(&"spin")
	var reach := Combat.swing_shape(spin, 0.0).hit_reach as float
	assert_lt(reach, 4.0, "out of the spin's own reach")
	game.combat.strike(spin, Vector2.ZERO, Vector2.RIGHT)
	assert_almost_eq(far.hp, 9999.0 - 25.0, 2.0, "the pulse reached it")


func test_onda_gemea_throws_two_at_the_sides() -> void:
	_run()
	var heavy: ComboNode = _first(&"heavy")
	var before := game.projectiles.shots.size()
	game.combat.strike(heavy, Vector2.ZERO, Vector2.RIGHT)
	var plain := game.projectiles.shots.size() - before
	assert_eq(plain, 1, "the special's own wave")
	before = game.projectiles.shots.size()
	game.boons.take_enchant(load("res://data/enchants/04_onda_gemea.tres"))
	game.combat.strike(heavy, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(game.projectiles.shots.size() - before, 3, "the special's own and two more at the sides")


func _first(tag: StringName) -> ComboNode:
	for n in game.player.runner.tree.neutral:
		var f := _find(n, tag)
		if f != null:
			return f
	return null


func _find(n: ComboNode, tag: StringName) -> ComboNode:
	if n == null:
		return null
	if n.tags.has(tag):
		return n
	for x in n.following():
		var f := _find(x, tag)
		if f != null:
			return f
	return null


func test_discernimento_in_order_with_memoria() -> void:
	var d := SaveData.defaults()
	assert_eq(Discern.level(d), 0)
	assert_eq(Discern.problem(d, 2), Discern.Problem.NEEDS)
	assert_eq(Discern.problem(d, 1), Discern.Problem.SHORT)
	MaterialPurse.give(d, MaterialPurse.MEMORY, Discern.cost(1) + Discern.cost(2))
	assert_true(Discern.buy(d))
	assert_true(Discern.buy(d))
	assert_false(Discern.buy(d), "two in all")
	assert_eq(Discern.level(SaveData.merged(JSON.parse_string(JSON.stringify(d)))), 2)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 0)
	for n in [1, 2]:
		assert_ne(T.t(StringName("discern_%d" % n)), "discern_%d" % n)


func test_discernimento_one_rerolls_a_choice_once() -> void:
	Dev.put("discern", "1")
	_run()
	assert_eq(game.rerolls_left, 1)
	game.open_boon_choice()
	assert_eq(game.mode, Game.Mode.CHOICE)
	assert_true(game.can_reroll())
	watch_signals(game)
	assert_true(game.reroll_choice())
	assert_signal_emitted(game, "rerolled")
	assert_eq(game.mode, Game.Mode.CHOICE, "a new choice on screen")
	assert_eq(game.offer_cards.size(), 3)
	assert_false(game.can_reroll(), "once a descent")
	assert_false(game.reroll_choice())


func test_no_reroll_without_it_nor_on_a_psalms_door() -> void:
	_run()
	game.open_boon_choice()
	assert_false(game.can_reroll(), "not bought")
	game.close_screen()
	game.rerolls_left = 1
	game.open_psalm_choice()
	if game.mode == Game.Mode.CHOICE:
		assert_false(game.can_reroll(), "never the Psalm's door")


func test_discernimento_two_shows_one_more_layer_of_angels() -> void:
	Dev.put("discern", "2")
	_run()
	game.rooms._open_doors()
	var shown := 0
	for r in game.rooms.next_rooms:
		for id in r.next:
			var n: RunMap.Room = game.rooms.map.nodes[id]
			if n.reward == RunMap.Reward.BOON and not n.meeting and n.kind == RunMap.Kind.COMBAT:
				assert_ne(n.angel, &"", "the angel behind the doors is shown")
				shown += 1
	gut.p("rooms behind the doors with an angel shown: %d" % shown)


func test_esmeralda_by_a_new_best_peso() -> void:
	assert_eq(Juramentos.record_emeralds(0, 4), 0)
	assert_eq(Juramentos.record_emeralds(0, 5), 1)
	assert_eq(Juramentos.record_emeralds(0, 12), 2)
	assert_eq(Juramentos.record_emeralds(12, 14), 0, "the step of 10 already paid")
	assert_eq(Juramentos.record_emeralds(12, 15), 1)
	assert_eq(Juramentos.record_emeralds(20, 20), 0, "no new best")
	assert_eq(Juramentos.record_emeralds(0, 30), 6, "six in all")


func test_the_vendors_obras_and_trades() -> void:
	var def := OficiosDef.live()
	var obras := Vendor.load_catalog()
	assert_eq(obras.size(), 3)
	var d := SaveData.defaults()
	var altar := obras[0]
	assert_eq(Vendor.state(d, def, altar), Vendor.State.LOCKED, "the stall opens with the first order")
	assert_false(Vendor.can_trade(d, def, 0))
	Oficios.block(d).orders[String(def.order)] = "done"
	assert_eq(Vendor.state(d, def, altar), Vendor.State.OPEN)
	assert_false(Vendor.missing(d, altar).is_empty())
	MaterialPurse.give(d, MaterialPurse.SILVER, 60)
	MaterialPurse.give(d, MaterialPurse.MEMORY, 4)
	assert_true(Vendor.build(d, def, altar))
	assert_eq(Vendor.state(d, def, altar), Vendor.State.DONE)
	assert_false(Vendor.build(d, def, altar), "once")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 20)
	assert_true(Vendor.trade(d, def, 0))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 10)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 1, "ten Prata for one Memória")
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var made := Vendor.works(d, obras)
	assert_eq(made, [&"obra_altar"] as Array[StringName])
	var laid := Vendor.stage_for(stage, obras, made)
	assert_almost_eq(laid.altar_chance, 0.35, 0.0001)
	assert_almost_eq(stage.altar_chance, 0.2, 0.0001, "the stage itself untouched")
	assert_eq(Vendor.stage_for(stage, obras, [] as Array[StringName]), stage)
	for o in obras:
		assert_ne(T.t(o.name_key), String(o.name_key))


func test_an_obra_reaches_the_descent() -> void:
	Dev.put("oficios", "obra_fonte")
	_run()
	Dev.drop("oficios")
	assert_almost_eq(game.rooms.stage.fountain_heal, 0.55, 0.0001)


func test_the_angels_codex() -> void:
	var d := SaveData.defaults()
	assert_eq(AngelCodex.count(d), [0, 7] as Array[int])
	var meetings: Array[Dictionary] = [{"offered": ["sarael", "nivael"], "chose": "nivael"}, {"offered": ["nivael"], "chose": "nivael"}]
	var frost: Boon = BoonState.new(BoonState.load_catalog()).find(&"toque_geada")
	AngelCodex.keep(d, meetings, [frost] as Array[Boon])
	var all := AngelCodex.entries(SaveData.merged(JSON.parse_string(JSON.stringify(d))))
	var by := {}
	for e in all:
		by[e.id] = e
	assert_eq(by[&"nivael"].met, 2)
	assert_eq(by[&"nivael"].chosen, 2)
	assert_eq(by[&"nivael"].blessed, 1)
	assert_eq(by[&"sarael"].met, 1)
	assert_true(by[&"sarael"].known)
	assert_false(by[&"lumael"].known)
	assert_eq(AngelCodex.count(d), [2, 7] as Array[int])


func test_the_second_and_third_tools_are_found() -> void:
	_run(RunMap.Kind.BOSS)
	game.rooms.boss_phase(3)
	assert_true(game.tools_found.has(Forge.TOOL_AWAKEN), "at the first phase 3")
	assert_eq(Forge.TOOLS, [Forge.TOOL_REFINE, Forge.TOOL_AWAKEN, Forge.TOOL_INSCRIBE] as Array[StringName])
