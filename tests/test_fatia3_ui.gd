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
	assert_eq(plain.tabs.size(), 0)
	Forge.add_tool(d, Forge.TOOL_REFINE)
	Forge.add_tool(d, Forge.TOOL_AWAKEN)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 5)
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d, ForgeScreen.Tab.ARTS)
	assert_eq(f.tabs.size(), 2, "Emeth and Despertar")
	assert_eq(f.tab, ForgeScreen.Tab.ARTS)
	assert_eq(f.shown.track, Forge.AWAKEN)
	assert_false(f.buy_button.disabled)
	f._buy()
	var forge := Forge.new(Forge.load_catalog())
	assert_eq(forge.awake(d), f.shown, "the first forged wakes")
	assert_eq(f.buy_button.text, T.t(&"forge_awaken_off"))
	f._buy()
	assert_null(forge.awake(d), "Adormecer puts it to sleep")
	assert_eq(f.buy_button.text, T.t(&"forge_awaken_use"))
	# the Inscrever still waits for its tool and says which
	f._show(forge.track(Forge.INSCRIBE)[0])
	assert_true(f.buy_button.disabled)
	assert_eq((f.find_child("step", true, false) as Label).text, T.t(&"forge_no_tool_inscribe"))
	f._turn(-1)
	assert_eq(f.tab, ForgeScreen.Tab.EMETH)


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


func test_the_book_only_reads_the_discernimento() -> void:
	var d := _data()
	MaterialPurse.give(d, MaterialPurse.MEMORY, 10)
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(d, HeroScreen.Chapter.OFICIOS)
	assert_not_null(s.find_child("discern_row_1", true, false), "the grades are still read")
	assert_null(s.find_child("discern_1", true, false), "but nothing is bought in the book")
	assert_eq(Discern.level(d), 0)


func _stall(d: Dictionary) -> VendorScreen:
	var v := VendorScreen.new()
	add_child_autofree(v)
	v.open(d)
	return v


func _open_stall_data() -> Dictionary:
	var d := _data()
	Oficios.block(d).orders[String(OficiosDef.live().order)] = "done"
	return d


func _offer(v: VendorScreen, id: StringName) -> VendorOffer:
	for o in v.offers:
		if o.id() == id:
			return o
	return null


func test_the_vendor_stall_builds_with_two_presses() -> void:
	var d := _open_stall_data()
	MaterialPurse.give(d, MaterialPurse.SILVER, 200)
	MaterialPurse.give(d, MaterialPurse.MEMORY, 20)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 5)
	var v := _stall(d)
	assert_eq(v.offers.size(), OficiosDef.live().trades.size() + Vendor.load_catalog().size() + Discern.COSTS.size())
	var o := _offer(v, v.catalog[0].id)
	watch_signals(v)
	v.press_tag(o)
	assert_eq(v.placed, o, "the first press only puts it on the plate")
	assert_false(Vendor.made(d, v.catalog[0]))
	assert_true(v.close_button.visible)
	v.press_close()
	assert_signal_emitted(v, "built")
	assert_true(Vendor.made(d, v.catalog[0]))
	assert_null(v.placed)
	assert_eq(o.state(d, v.def), VendorOffer.State.MADE)


func test_the_vendor_stall_trades_and_takes_back_without_spending() -> void:
	var d := _open_stall_data()
	MaterialPurse.give(d, MaterialPurse.SILVER, 200)
	var v := _stall(d)
	var t := _offer(v, &"trade_0")
	var silver := MaterialPurse.amount(d, MaterialPurse.SILVER)
	v.press_tag(t)
	v.cancel()
	assert_null(v.placed)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), silver, "B takes it off the plate and spends nothing")
	v.press_tag(t)
	v.press_tag(t)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), silver - int(v.def.trades[0]["give_n"]), "the second press trades once")
	assert_false(v.press_close(), "nothing is left on the plate to close")


func test_the_vendor_stall_sells_the_discernimento_in_order() -> void:
	var d := _open_stall_data()
	MaterialPurse.give(d, MaterialPurse.MEMORY, 10)
	var v := _stall(d)
	var one := _offer(v, &"discern_1")
	var two := _offer(v, &"discern_2")
	assert_eq(one.state(d, v.def), VendorOffer.State.CAN)
	assert_eq(two.state(d, v.def), VendorOffer.State.NEEDS, "the second asks for the first")
	v.put(two)
	assert_true(v.close_button.disabled, "put on the plate, but the button says why not")
	assert_false(v.press_close())
	v.put(one)
	v.press_close()
	assert_eq(Discern.level(d), 1)
	assert_eq(one.state(d, v.def), VendorOffer.State.MADE)
	assert_eq(two.state_text(d, v.def), T.t(&"vendor_short", {"list": VendorOffer.short_list({MaterialPurse.MEMORY: Discern.cost(2) - 2})}))


func test_the_vendor_stall_without_means_spends_nothing() -> void:
	var d := _open_stall_data()
	var v := _stall(d)
	for o in v.offers:
		if o.state(d, v.def) == VendorOffer.State.MADE:
			continue
		v.put(o)
		assert_true(v.close_button.disabled, str(o.id()))
		assert_false(v.press_close())
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 0)


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
