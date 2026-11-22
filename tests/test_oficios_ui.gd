extends GutTest
## Ofícios, Roteiro A, on the interface: the find's name on its door, the vein's plate, the Pedra Funda in the purse
## and in Trazidos, the "Achado" greeting, the Vendedor's order sheet, the Oficina in the Forja and the Livro's chapter.


func _data(noted: bool, head: bool, silver: int, stones: int = 0) -> Dictionary:
	var d := SaveData.defaults()
	var b := Oficios.block(d)
	if noted:
		(b.seen as Array).append(Oficios.VEIN)
	if head:
		(b.finds as Array).append(String(OficiosDef.live().head))
	if stones > 0:
		Oficios.add_item(d, OficiosDef.live(), OficiosDef.live().stone, stones)
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	return d


func test_the_door_names_the_find_behind_it() -> void:
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 3)
	var line := T.t(&"door_find", {"name": T.t(&"oficio_pick_head")})
	assert_false(Rooms.door_text(r).contains(line))
	r.find = &"pick_head"
	assert_true(Rooms.door_text(r).contains(line))
	assert_false(Rooms.door_text(r, false).contains(line), "not in the HUD's line")


func test_the_vein_plate_says_the_pick() -> void:
	var note := StationSign.make(&"vein_note", "", "")
	autofree(note)
	assert_not_null(note.need)
	assert_eq(note.need.text, T.t(&"oficio_needs", {"name": T.t(&"oficio_pick")}))
	assert_eq(note.prompt.text, T.t(&"hub_use_vein_note"))
	var open := StationSign.make(&"vein", "", "")
	autofree(open)
	assert_eq(open.need.text, T.t(&"oficio_uses", {"name": T.t(&"oficio_pick")}))
	var reward := StationSign.make(&"reward", "", "")
	autofree(reward)
	assert_null(reward.need)


func test_the_stone_joins_the_purse_once_held() -> void:
	var none := _data(true, false, 5)
	assert_false(DoorGlyph.STONE_ID in MaterialCount.shown(none))
	var some := _data(true, false, 5, 3)
	assert_true(DoorGlyph.STONE_ID in MaterialCount.shown(some))
	var row := MaterialCount.purse(some)
	autofree(row)
	var stone := row.find_child(String(DoorGlyph.STONE_ID), false, false) as MaterialCount
	assert_not_null(stone)
	assert_eq(stone.amount, 3)
	assert_eq(MaterialCount.name_of(DoorGlyph.STONE_ID), T.t(&"oficio_stone"))


func test_trazidos_brings_the_stone_and_the_find() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 20.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 0,
		"oficios": {"finds": ["pick_head"], "gather": {"stones": 2}}}, false)
	var row := end.find_child("brought", true, false)
	assert_not_null(row)
	var stone := row.find_child(String(DoorGlyph.STONE_ID), false, false) as MaterialCount
	assert_not_null(stone)
	assert_eq(stone.amount, 2)
	assert_not_null(row.find_child("find", false, false))


func test_the_find_is_greeted_at_the_top() -> void:
	var b := EloBanner.new()
	add_child_autofree(b)
	b.show_find(&"pick_head")
	assert_eq(b.showing, &"find")
	assert_eq((b.find_child("Title", true, false) as Label).text, T.t(&"oficio_find_title"))
	assert_true(Hud.oficio_notice(T.t(&"oficio_found", {"name": T.t(&"oficio_pick_head")})))
	assert_true(Hud.oficio_notice(T.t(&"oficio_noted")))
	assert_false(Hud.oficio_notice(T.t(&"notice_room_clear")))


func test_the_order_sheet_counts_and_waits() -> void:
	var def := OficiosDef.live()
	var short := _data(true, false, 10, 1)
	var p := HubPanel.new()
	add_child_autofree(p)
	p.callv(&"open", OficioSheets.order(short, def))
	var deliver := p.find_child("deliver", true, false) as Button
	assert_true(deliver.disabled, "Entregar waits while something is missing")
	assert_eq(deliver.focus_mode, Control.FOCUS_NONE)
	var stone := p.find_child("want_" + String(def.stone), true, false)
	assert_eq((stone.find_child("count", false, false) as Label).text, T.t(&"order_of", {"have": 1, "want": 2}))
	var full := _data(true, false, 40, 2)
	var q := HubPanel.new()
	add_child_autofree(q)
	q.callv(&"open", OficioSheets.order(full, def))
	assert_false((q.find_child("deliver", true, false) as Button).disabled)


func test_the_forja_has_the_oficina_once_noted() -> void:
	var plain := ForgeScreen.new()
	add_child_autofree(plain)
	plain.open(_data(false, false, 30))
	assert_eq(plain.tabs.size(), 0, "no bookmarks before a vein was noted")
	var data := _data(true, true, 30)
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(data, ForgeScreen.Tab.WORKSHOP)
	assert_eq(f.tabs.size(), 2)
	assert_true(f.showing_pick)
	assert_eq(f.buy_button.text, T.t(&"oficio_restore"))
	assert_false(f.buy_button.disabled)
	assert_eq(f.pick_view.look, PickMark.Look.HEAD)
	watch_signals(f)
	assert_true(f.restore())
	assert_signal_emitted(f, "restored")
	assert_true(Oficios.has_tool(data, OficiosDef.live()))
	assert_eq(MaterialPurse.amount(data, MaterialPurse.SILVER), 10)
	assert_eq(f.pick_view.look, PickMark.Look.WHOLE)
	assert_true(f.buy_button.disabled)
	f._turn(-1)
	assert_eq(f.tab, ForgeScreen.Tab.EMETH)
	assert_false(f.showing_pick)


func test_the_oficina_without_the_head_says_where() -> void:
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(_data(true, false, 30), ForgeScreen.Tab.WORKSHOP)
	assert_true(f.buy_button.disabled)
	assert_eq(f.pick_view.look, PickMark.Look.LOST)
	assert_eq((f.find_child("step", true, false) as Label).text, T.t(&"oficio_smith_where"))


func test_the_book_has_the_oficios_chapter() -> void:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(_data(false, false, 0))
	s._show(HeroScreen.Chapter.OFICIOS)
	var left := s.find_child("oficios_left", true, false)
	assert_true((left as Control).visible)
	assert_not_null(left.find_child("stone", true, false))
	var t := HeroScreen.new()
	add_child_autofree(t)
	t.open(_data(true, true, 0, 4))
	var stone := t.find_child("oficios_left", true, false).find_child("stone", true, false)
	assert_eq((stone.find_child("count", true, false) as Label).text, T.t(&"oficios_stone_count", {"n": 4, "cap": 10}))
	# the voice stays plain: nobody is spoken to
	for l: Node in t.find_child("oficios_right", true, false).find_children("*", "Label", true, false):
		assert_false((l as Label).text.contains("você"), (l as Label).text)
