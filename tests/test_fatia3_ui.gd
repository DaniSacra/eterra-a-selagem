extends GutTest
## Fatia 3 on the interface: Despertar and Inscrever in the Forja, the Blessings' reroll button, the Discernimento in
## the Livro, the Vendedor's stall (Obras and trades) and the Compêndio's Anjos tab.


func after_each() -> void:
	Dev.drop("discern")


func _data() -> Dictionary:
	return SaveData.defaults()


func test_the_forja_shows_despertar_once_a_tool_is_found() -> void:
	var d := _data()
	var plain := ForgeScreen.new()
	add_child_autofree(plain)
	plain.open(d)
	assert_false(plain.marks().has(&"awaken"), "no tool found: the pommel and the blade have no points")
	assert_false(plain.marks().has(&"inscribe"))
	Forge.add_tool(d, Forge.TOOL_REFINE)
	Forge.add_tool(d, Forge.TOOL_AWAKEN)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 5)
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d)
	assert_eq(f.marks(), [&"awaken", &"attack", &"inscribe", &"temper"] as Array[StringName])
	f.focus_mark(&"awaken")
	assert_eq(f.shown.track, Forge.AWAKEN)
	assert_eq(f.info.action, ForgeInfo.Action.HAMMER)
	f.focus_chip(0)
	var forge := Forge.new(Forge.load_catalog())
	for k in 3:
		f.press()
		f.release()
	assert_eq(forge.awake(d), f.shown, "the first forged wakes")
	assert_eq(f.bench.gem, f.shown.id, "the stone lights in the pommel")
	assert_eq(f.info.action, ForgeInfo.Action.SLEEP)
	f.press()
	f.release()
	assert_null(forge.awake(d), "Adormecer puts it to sleep, in one press")
	assert_eq(f.info.action, ForgeInfo.Action.AWAKEN)
	# the Inscrever still waits for its tool and says which
	f.focus_mark(&"inscribe")
	assert_eq(f.info.look, ForgeInfo.Look.NO_TOOL)
	assert_eq(f.info.action, ForgeInfo.Action.NONE)
	assert_eq((f.find_child("step", true, false) as Label).text, T.t(&"forge_no_tool_inscribe"))


func test_the_choice_offers_a_reroll_with_discernimento() -> void:
	Dev.put("discern", "1")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	game.open_boon_choice()
	await wait_process_frames(2)
	var screen := game.ui.find_child("*", true, false)
	var choice: BoonChoice = null
	for n in game.ui.get_children():
		if n is BoonChoice:
			choice = n
	assert_not_null(choice)
	assert_not_null(choice.reroll_item, "Sortear de novo on the bar")
	assert_eq(choice.reroll_item.verb.text.to_lower(), T.t(&"bar_reroll", {"n": 1}).to_lower())
	assert_true(choice.reroll())
	await wait_process_frames(2)
	for n in game.ui.get_children():
		if n is BoonChoice and not n.is_queued_for_deletion():
			assert_null((n as BoonChoice).reroll_item, "once a descent: the new draw has no button")
	assert_not_null(screen)


func test_no_reroll_button_without_it() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	game.open_boon_choice()
	await wait_process_frames(2)
	for n in game.ui.get_children():
		if n is BoonChoice:
			assert_null((n as BoonChoice).reroll_item)


func test_the_book_sells_the_discernimento_in_two_presses() -> void:
	var d := _data()
	MaterialPurse.give(d, MaterialPurse.MEMORY, 10)
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(d, HeroScreen.Chapter.OFICIOS)
	assert_eq(s.discern_buttons.size(), 2)
	var one := s.discern_buttons[0]
	var two := s.discern_buttons[1]
	assert_false(one.disabled)
	assert_true(two.disabled, "the second asks for the first")
	one.pressed.emit()
	assert_eq(Discern.level(d), 0, "the first press only asks")
	assert_eq(one.text, T.t(&"discern_confirm", {"n": Discern.cost(1)}))
	one.pressed.emit()
	assert_eq(Discern.level(d), 1)
	assert_eq(one.text, T.t(&"discern_owned"))
	assert_eq(two.text, T.t(&"discern_short", {"n": Discern.cost(2) - 2}))


func test_the_vendor_stall_builds_and_trades() -> void:
	var d := _data()
	var def := OficiosDef.live()
	Oficios.block(d).orders[String(def.order)] = "done"
	MaterialPurse.give(d, MaterialPurse.SILVER, 200)
	MaterialPurse.give(d, MaterialPurse.MEMORY, 20)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 5)
	var v := VendorScreen.new()
	add_child_autofree(v)
	v.open(d)
	assert_eq(v.build_buttons.size(), Vendor.load_catalog().size())
	var o := v.catalog[0]
	watch_signals(v)
	assert_true(v.build(o))
	assert_signal_emitted(v, "built")
	assert_true(Vendor.made(d, o))
	assert_false((v.build_buttons[o.id] as Button).visible, "made: Erguida, no button")
	var silver := MaterialPurse.amount(d, MaterialPurse.SILVER)
	assert_true(v.trade(0))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), silver - int(def.trades[0]["give_n"]))
	var poor := _data()
	Oficios.block(poor).orders[String(def.order)] = "done"
	var w := VendorScreen.new()
	add_child_autofree(w)
	w.open(poor)
	for id: Variant in w.build_buttons:
		assert_true((w.build_buttons[id] as Button).disabled)
	for b in w.trade_buttons:
		assert_true(b.disabled)


func test_the_codex_has_the_angels() -> void:
	var d := _data()
	SaveData.codex_add(d, "angels", "sarael", "met")
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.ANGELS, d)
	assert_eq(c.tab, CodexScreen.Tab.ANGELS)
	var list := c.find_child("list", true, false)
	var sarael := list.find_child("sarael", true, false)
	assert_eq((sarael.find_child("Name", true, false) as Label).text, T.t(&"angel_sarael"))
	assert_not_null(sarael.find_child("Counts", true, false))
	assert_null(list.find_child("nivael", true, false), "the unmet angels are one line")
	assert_eq((list.find_child("undiscovered", true, false).find_child("Name", true, false) as Label).text, T.t(&"codex_undiscovered", {"n": 6}))
	assert_eq(c.progress(CodexScreen.Tab.ANGELS), Vector2i(1, 7))


func test_a_defeated_enemy_is_drawn_in_ink() -> void:
	var d: EnemyDef = load(CodexScreen.ENEMY_DIR + "skeleton.tres")
	var v := FigureView.new().setup(Vector2(160, 200))
	add_child_autofree(v)
	v.show_enemy(d, true)
	var k: CrowdRenderer.Kind = v._renderer.kind(d)
	assert_eq((k.material as ShaderMaterial).shader, FigureSketch.material(k.model).shader, "the sketch's passes")
	v.show_enemy(d, false)
	var plain: CrowdRenderer.Kind = v._renderer.kind(d)
	assert_ne((plain.material as ShaderMaterial).shader, FigureSketch.material(plain.model).shader, "the unknown: the silhouette")
