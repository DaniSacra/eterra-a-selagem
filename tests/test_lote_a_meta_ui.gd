extends GutTest
## Lote A of the 2026-11-24 round (docs/qa/ui_review_2026-11-24.md): the words of the meta screens, the Dons' caption and
## button, the one wallet, the Enter verbs, the Forja's causes and the end screen's way to bring something home.

const VISIBLE_KEYS: Array[StringName] = [&"slot_ult", &"action_ultimate", &"howto_ultimate", &"hero_ultimate", &"hud_ult_locked_tip",
	&"hud_ult_charge_tip", &"end_unlocked_ult", &"end_unlocked_ults", &"hero_xp", &"end_xp", &"jur_xp", &"hero_step_mastery",
	&"hero_next", &"dons_hero_reveals", &"hero_ult_chosen", &"dons_do_chosen", &"mouse_1", &"mouse_2", &"title_controls", &"title_pad"]


func test_words_the_children_could_not_read_are_gone() -> void:
	for k in VISIBLE_KEYS:
		var t := String(T.table.entries.get(k, ""))
		assert_ne(t, "", k)
		for bad in ["ltimate", "ultimate", " XP", "Mouse esq", "Mouse dir", "Escolhida", "Devoção", "revela:"]:
			assert_false(t.contains(bad), "%s still says %s" % [k, bad])
		assert_false(t.contains("—") or t.contains("–"), k)
	assert_eq(T.t(&"slot_ult"), "Golpe Supremo")
	assert_eq(T.t(&"dons_do_chosen"), "Equipado")
	assert_eq(T.t(&"dons_devotion", {"free": 2, "max": 6}), "Vagas livres 2 de 6")


func test_no_devotion_anywhere_in_the_text() -> void:
	for k in T.table.entries:
		var t := String(T.table.entries[k])
		assert_false(t.contains("Devoção"), String(k))


func test_wallet_is_always_silver_memory_emerald_with_names() -> void:
	var row := CoinCorner.wallet(SaveData.defaults())
	add_child_autofree(row)
	var ids: Array[StringName] = []
	for c in row.get_children():
		ids.append((c as MaterialCount).id)
		assert_string_contains((c as MaterialCount).number.text, MaterialCount.short_of((c as MaterialCount).id))
	assert_eq(ids, [MaterialPurse.SILVER, MaterialPurse.MEMORY, MaterialPurse.EMERALD] as Array[StringName])


func test_caption_keeps_clear_of_the_branch_labels() -> void:
	var s := DonsScreen.new()
	add_child_autofree(s)
	s.open(SaveData.defaults(), "warrior")
	var view := s.view
	var boxes := view.label_boxes()
	assert_gt(boxes.size(), 0)
	var size := Vector2(240, 26)
	for n in view.def.nodes:
		var c := view.spot(n.id)
		var inward := (MedallionDef.CENTER - c).normalized()
		var p := view.caption_spot(c, inward, n.diameter * 0.5 + 62.0, size)
		var r := Rect2(p - size * 0.5, size)
		var hits := 0
		for b in boxes:
			if r.intersects(b):
				hits += 1
		var plain := Rect2(c + inward * (n.diameter * 0.5 + 62.0) - size * 0.5, size)
		var plain_hits := 0
		for b in boxes:
			if plain.intersects(b):
				plain_hits += 1
		assert_lte(hits, plain_hits, "%s: the push never makes it worse" % n.id)


func test_a_gift_that_cannot_be_paid_is_words_not_a_button() -> void:
	var s := DonsScreen.new()
	add_child_autofree(s)
	s.open(SaveData.defaults(), "warrior")
	var verb := s.panel._verb as DonsPanel.Verb
	verb.set_up("Segure para abrir", false, "Enter", true, "Faltam 2 de Memória")
	assert_false(verb.enabled)
	assert_eq(verb.reason, "Faltam 2 de Memória", "the reason is what it draws, in rubrica, with no frame, no key and no bar")
	verb.set_up("Segure para abrir", true, "Enter", true, "")
	assert_true(verb.hold and verb.enabled, "the bar belongs to the Dom that can be paid")


func test_dons_has_the_common_bar_with_one_way_out() -> void:
	var s := DonsScreen.new()
	add_child_autofree(s)
	s.open(SaveData.defaults(), "warrior")
	var bar := s.find_child("action_bar", true, false) as ActionBar
	assert_not_null(bar)
	assert_not_null(bar.item(&"tab_prev"))
	assert_not_null(bar.item(&"tab_next"))
	assert_eq(bar.item(&"ui_cancel").verb.text, T.t(&"bar_back").to_upper())
	assert_null(s.find_child("hint", true, false), "the loose line is gone")


func test_every_bar_leaves_by_the_same_word() -> void:
	var back := T.t(&"bar_back").to_upper()
	var forge := ForgeScreen.new()
	add_child_autofree(forge)
	forge.open(SaveData.defaults(), ForgeScreen.Tab.EMETH)
	assert_eq((forge.find_child("action_bar", true, false) as ActionBar).item(&"ui_cancel").verb.text, back)
	var vine := VineScreen.new()
	add_child_autofree(vine)
	vine.open(SaveData.defaults())
	vine.zoom_in(&"vida")
	var vbar := vine.find_child("action_bar", true, false) as ActionBar
	assert_eq(vbar.item(&"ui_cancel").verb.text, back)
	# an empty purse: Enter says why it cannot water (UI review 2026-11-24b, B1; test_enter_follows_focus)
	assert_eq(vbar.item(&"ui_accept").verb.text, vine.water_button.text.to_upper(), "Enter says the reason")
	var book := HeroScreen.new()
	add_child_autofree(book)
	book.open(SaveData.defaults(), HeroScreen.Chapter.HERO)
	assert_eq(book.bar.item(&"ui_cancel").verb.text, back)
	assert_eq(book.bar.item(&"ui_accept").verb.text, T.t(&"bar_open_page").to_upper(), "Enter opens")


func test_forge_enter_says_hammer_and_the_plate_says_the_same() -> void:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, 40)
	for t in Forge.TOOLS:
		Forge.add_tool(d, t)
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d, ForgeScreen.Tab.EMETH)
	var bar := f.find_child("action_bar", true, false) as ActionBar
	assert_eq(bar.item(&"ui_accept").verb.text, f.info.verb().to_upper() if f.info.verb() != "" else T.t(&"bar_hammer").to_upper())
	assert_string_contains(T.t(&"forge_hold_hint"), "Aperte 3 vezes ou segure")


func test_forge_names_what_each_closed_point_lacks() -> void:
	var d := SaveData.defaults()
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d, ForgeScreen.Tab.EMETH)
	for m: StringName in f.bench.marks:
		assert_true(f.bench.causes.has(m) or f.bench.sealed.get(m, false) == false, "%s: a closed point says why" % m)
	for sub: StringName in ForgeBench.SUB_KEY.values():
		assert_ne(T.t(sub), String(sub))


func test_vendor_trade_verb_is_trocar() -> void:
	assert_eq(T.t(&"vendor_deal_trade"), "Trocar")


func test_end_screen_says_the_way_when_nothing_came_and_is_silent_otherwise() -> void:
	var none := EndScreen.new()
	add_child_autofree(none)
	none.open(false, {"time": 20.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 0, "materials": {"silver": 0, "memory": 0}}, false)
	var line := none.find_child("brought_none", true, false) as Label
	assert_not_null(line)
	assert_string_contains(line.text, "guardião")
	var some := EndScreen.new()
	add_child_autofree(some)
	some.open(false, {"time": 20.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 0, "materials": {"silver": 4, "memory": 0}}, false)
	assert_null(some.find_child("brought_none", true, false))
	assert_not_null(some.find_child("brought", true, false))
