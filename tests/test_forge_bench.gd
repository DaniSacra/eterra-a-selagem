extends GutTest
## The Forja as a bench (docs/art/forge_spec.md): the hammer's three strikes (ForgeHammer), what the plate says of a
## choice (ForgeInfo), and the screen's gesture, focus and benches.


func _data(silver := 0, tools := false) -> Dictionary:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	if tools:
		for t in Forge.TOOLS:
			Forge.add_tool(d, t)
	return d


func _screen(d: Dictionary, tab := ForgeScreen.Tab.EMETH) -> ForgeScreen:
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d, tab)
	return f


func _hammer(f: ForgeScreen) -> void:
	for k in 3:
		f.press()
		f.release()


# ---------- the hammer ----------

func test_three_strikes_spend_and_start_again() -> void:
	var h := ForgeHammer.new()
	assert_eq(h.strike(), 1)
	assert_eq(h.strike(), 2)
	assert_eq(h.strikes, 2)
	assert_eq(h.strike(), ForgeHammer.STRIKES, "the third is the spend")
	assert_eq(h.strikes, 0, "and the count restarts")


func test_a_hot_piece_cools_after_the_pause() -> void:
	var h := ForgeHammer.new()
	h.strike()
	h.step(ForgeHammer.COOL_AFTER - 0.1)
	assert_eq(h.strikes, 1, "still hot")
	h.step(0.2)
	assert_eq(h.strikes, 0, "cold: nothing spent")
	assert_true(h.cooled)
	h.step(0.1)
	assert_false(h.cooled, "said once")


func test_cancel_cools_at_once() -> void:
	var h := ForgeHammer.new()
	h.strike()
	h.strike()
	assert_true(h.cancel())
	assert_eq(h.strikes, 0)
	assert_false(h.cancel(), "cold already")


func test_holding_gives_the_three_by_itself() -> void:
	var h := ForgeHammer.new()
	assert_eq(h.press(), 1, "the press is the first")
	var landed: Array[int] = []
	for k in 30:
		var n := h.step(0.05)
		if n > 0:
			landed.append(n)
	assert_eq(landed, [2, 3] as Array[int], "the second halfway and the third at the end")
	assert_eq(h.strikes, 0)


func test_letting_go_keeps_it_hot_but_stops_the_hold() -> void:
	var h := ForgeHammer.new()
	h.press()
	h.step(0.3)
	h.release()
	for k in 5:
		assert_eq(h.step(0.1), 0, "no more strikes by themselves")
	assert_eq(h.strikes, 1)


# ---------- the plate's words ----------

func test_the_six_looks() -> void:
	var d := _data(40, true)
	MaterialPurse.give(d, MaterialPurse.SILVER, 60)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 1)
	var forge := Forge.new(Forge.load_catalog())
	assert_eq(ForgeInfo.of(forge, d, forge.find(&"temper_1")).look, ForgeInfo.Look.READY)
	assert_eq(ForgeInfo.of(forge, d, forge.find(&"temper_3")).look, ForgeInfo.Look.NEEDS)
	assert_eq(ForgeInfo.of(forge, d, forge.find(&"awaken_eco")).look, ForgeInfo.Look.SHORT)
	forge.buy(d, &"refine_fio")
	forge.buy(d, &"refine_peso")
	assert_eq(ForgeInfo.of(forge, d, forge.find(&"refine_fio")).look, ForgeInfo.Look.ON)
	assert_eq(ForgeInfo.of(forge, d, forge.find(&"refine_peso")).look, ForgeInfo.Look.STORED)
	assert_eq(ForgeInfo.of(forge, _data(40), forge.find(&"refine_fio")).look, ForgeInfo.Look.NO_TOOL)


func test_the_plate_reads_what_it_is_what_changes_and_the_price() -> void:
	var d := _data(40)
	var forge := Forge.new(Forge.load_catalog())
	var i := ForgeInfo.of(forge, d, forge.find(&"temper_1"))
	assert_eq(i.name, T.t(&"forge_temper_1"))
	assert_eq(i.desc, T.t(&"forge_temper_1_desc"))
	assert_eq(i.cost, forge.find(&"temper_1").cost)
	assert_eq(i.have, 40)
	assert_eq(i.state_text, T.t(&"forge_state_ready"))
	var short := ForgeInfo.of(forge, _data(5), forge.find(&"temper_1"))
	assert_eq(short.state_text, T.t(&"forge_lack", {"n": short.cost - 5, "name": T.t(&"material_silver_short")}))


func test_a_kept_refine_says_what_it_takes_the_place_of() -> void:
	var d := _data(200, true)
	var forge := Forge.new(Forge.load_catalog())
	forge.buy(d, &"refine_fio")
	assert_eq(ForgeInfo.of(forge, d, forge.find(&"refine_pressa")).detail, T.t(&"forge_instead", {"name": T.t(&"forge_refine_fio")}), "ready, it would take the Fio's place")
	forge.buy(d, &"refine_peso")
	var kept := ForgeInfo.of(forge, d, forge.find(&"refine_peso"))
	assert_eq(kept.detail, T.t(&"forge_instead", {"name": T.t(&"forge_refine_fio")}))
	assert_true(kept.free)


# ---------- the screen ----------

func test_two_strikes_and_b_spend_nothing() -> void:
	var d := _data(40)
	var f := _screen(d)
	f.press()
	f.release()
	f.press()
	f.release()
	assert_eq(f.hammer.strikes, 2)
	assert_eq(Forge.temper(d), 0)
	f._cool()
	assert_eq(f.hammer.strikes, 0)
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 40)
	_hammer(f)
	assert_eq(Forge.temper(d), 1, "three after cooling spend once")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 40 - f.forge.find(&"temper_1").cost)


func test_holding_the_press_forges() -> void:
	var d := _data(40)
	var f := _screen(d)
	f.press()
	for k in 30:
		f._process(0.05)
	assert_eq(Forge.temper(d), 1, "held 1,2 s: the three strikes")
	f.release()
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 40 - f.forge.find(&"temper_1").cost, "spent once")


func test_the_focus_walks_the_weapon_and_the_strip() -> void:
	var f := _screen(_data(0, true))
	f.focus_mark(&"awaken")
	f.move(Vector2i(1, 0))
	assert_eq(f.mark, &"attack", "pommel, then guard")
	f.move(Vector2i(0, 1))
	assert_eq(f.mark, &"special", "down on the guard: the other arm")
	f.move(Vector2i(0, 1))
	assert_true(f.in_strip, "then into the strip")
	f.move(Vector2i(1, 0))
	assert_eq(f.chip_i, 1)
	f.move(Vector2i(0, -1))
	assert_false(f.in_strip, "up: back on the weapon")
	f.move(Vector2i(1, 0))
	assert_eq(f.mark, &"inscribe")
	f.move(Vector2i(1, 0))
	assert_eq(f.mark, &"temper")
	f.move(Vector2i(1, 0))
	assert_eq(f.mark, &"temper", "the end of the blade")


func test_it_opens_on_the_cheapest_thing_to_forge() -> void:
	var f := _screen(_data(30, true))
	assert_true(f.mark in [&"temper", &"inscribe"], "Temperar I and Inscrever are both 20 now (a tie; was 15 for Temperar)")
	var g := _screen(_data(0))
	assert_eq(g.mark, &"temper", "nothing to forge: the Temperar")


func test_a_free_change_is_one_press_and_costs_nothing() -> void:
	var d := _data(500, true)
	var f := _screen(d)
	f.focus_mark(&"attack")
	f.focus_chip(0)
	_hammer(f)
	f.focus_chip(1)
	_hammer(f)
	var silver := MaterialPurse.amount(d, MaterialPurse.SILVER)
	assert_eq(f.hammer.strikes, 0)
	f.press()
	f.release()
	assert_eq(f.hammer.strikes, 0, "Usar does not heat the piece")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), silver)
	assert_true(f.forge.is_on(d, f.forge.find(&"refine_peso")))


func test_the_focus_moving_cools_the_piece() -> void:
	var d := _data(40, true)
	var f := _screen(d)
	f.press()
	f.release()
	assert_eq(f.hammer.strikes, 1)
	f.focus_mark(&"attack")
	assert_eq(f.hammer.strikes, 0)
	assert_eq(Forge.temper(d), 0)


func test_the_bench_shows_what_was_done_on_the_weapon() -> void:
	var d := _data(500, true)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 10)
	var f := _screen(d)
	f.focus_mark(&"inscribe")
	f.focus_chip(0)
	_hammer(f)
	assert_eq(f.bench.lines, 1, "a line engraved on the blade")
	f.focus_mark(&"awaken")
	f.focus_chip(0)
	_hammer(f)
	assert_ne(f.bench.gem, &"", "the stone awake in the pommel")


func test_the_marks_keep_their_distance() -> void:
	var seen: Array[StringName] = [&"awaken", &"attack", &"inscribe", &"temper"]
	for i in seen.size():
		for j in range(i + 1, seen.size()):
			var a: Vector2 = ForgeBench.AT[seen[i]]
			var b: Vector2 = ForgeBench.AT[seen[j]]
			assert_gte(a.distance_to(b), 120.0, "%s and %s" % [seen[i], seen[j]])


func test_the_bag_shows_the_same_three_coins_with_names() -> void:
	var d := _data(5, true)
	MaterialPurse.give(d, MaterialPurse.EMERALD, 2)
	MaterialPurse.give(d, MaterialPurse.MEMORY, 9)
	var f := _screen(d)
	var ids: Array[StringName] = []
	for c in f.find_child("purse", true, false).get_children():
		if c is MaterialCount:
			ids.append((c as MaterialCount).id)
	assert_eq(ids, CoinCorner.WALLET_ORDER, "the same corner as the other screens")


func test_the_text_of_the_bench_is_portuguese_without_dash() -> void:
	for k in ["forge_title_workshop", "forge_emeth_only", "forge_hammer", "forge_stored", "forge_free", "forge_have",
			"forge_lack", "forge_after", "forge_instead", "forge_hot", "forge_hold_hint"]:
		var t := String(T.table.entries.get(k, ""))
		assert_ne(t, "", k)
		assert_false(t.contains("—") or t.contains("–"), k)
