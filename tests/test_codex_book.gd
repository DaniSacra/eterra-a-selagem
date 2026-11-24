extends GutTest
## The Livro de Ahk's Gifts chapter as a codex of parchment (docs/art/meta_screens_identity.md 1): ribbons per branch,
## entries in reading order with capitals by rung, the thread of the prerequisite, the five states of HeroLoadout told by
## drawing and by words (the lacre of wax for the sealed), the Devotion in candles, the last chapter of the ultimates,
## and the Maga's own hand. Replaces the tree's geometry tests (the diamond and the triangle are gone).

const XP_MAX := 5000


func _data(hero: String, xp: int, equipped: Array = [], memory := 0, revealed := true) -> Dictionary:
	var d := SaveData.defaults()
	d["wins"] = 1
	d["hero"] = hero
	var block := SaveData.hero(d, hero)
	block.mastery_xp = xp
	if revealed:
		SaveData.open_revealed(block)
	block.equipped = equipped
	MaterialPurse.give(d, MaterialPurse.MEMORY, memory)
	return d


func _screen(data: Dictionary) -> HeroScreen:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(data, HeroScreen.Chapter.GIFTS)
	return s


# ---------- ribbons and chapters ----------

func test_the_warrior_has_six_ribbons_and_the_last_is_the_ultimates() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	assert_eq(s.codex.branches, [TalentDef.Branch.COMBO, TalentDef.Branch.FURIA, TalentDef.Branch.EMETH,
		TalentDef.Branch.MAGIA, TalentDef.Branch.BRIDGE, TalentDef.Branch.SUSTAIN] as Array[int])
	assert_eq(s.codex.ribbons.size(), 7, "six branches and Poder maior")
	assert_eq(s.codex.ribbons[6].title, T.t(&"codex_ribbon_ult"))
	assert_eq(s.codex.ults.size(), 2)


func test_the_maga_has_five_ribbons_in_her_order() -> void:
	var s := _screen(_data("maga", XP_MAX))
	assert_eq(s.loadout.hero.id, &"maga")
	assert_eq(s.codex.branches, [TalentDef.Branch.PIRO, TalentDef.Branch.ARCA, TalentDef.Branch.CTRL,
		TalentDef.Branch.BRIDGE, TalentDef.Branch.SUSTAIN] as Array[int])
	assert_eq(s.codex.ribbons.size(), 6)
	assert_eq(s.codex.entries.size(), 23)
	assert_ne(T.t(s.loadout.hero.name_key), String(s.loadout.hero.name_key))


func test_every_gift_is_one_entry_in_reading_order() -> void:
	for hero in ["warrior", "maga"]:
		var s := _screen(_data(hero, XP_MAX))
		assert_eq(s.codex.entries.size(), s.loadout.book.catalog.size(), hero)
		for i in s.codex.branches.size():
			var last := -1
			for e: GiftEntry in s.codex.by_chapter[i]:
				assert_eq(e.def.branch, s.codex.branches[i], str(e.def.id))
				assert_gte(e.def.tier, last, "Entrada, Meio, Ápice from the top: %s" % e.def.id)
				last = e.def.tier


func test_focus_on_a_ribbon_turns_to_its_page() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	s.codex.ribbons[2].grab_focus()
	assert_eq(s.codex.chapter, 2)
	assert_true(s.codex.ribbons[2].open)
	assert_false(s.codex.ribbons[0].open)
	assert_true(s.codex.entry(&"corte_crescente").is_visible_in_tree())
	assert_false(s.codex.entry(&"quarto_corte").is_visible_in_tree())


func test_a_ribbon_shows_a_dot_for_each_gift_worn_in_its_chapter() -> void:
	var s := _screen(_data("warrior", XP_MAX, ["quarto_corte", "impeto"]))
	assert_eq(s.codex.ribbons[0].worn, 1)
	assert_eq(s.codex.ribbons[1].worn, 1)
	assert_eq(s.codex.ribbons[2].worn, 0)
	s.codex.entry(&"passo_encadeado").pressed.emit()
	assert_eq(s.codex.ribbons[0].worn, 2)


# ---------- the capitals and the thread ----------

func test_the_capital_says_the_rung() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	assert_eq(s.codex.entry(&"quarto_corte").rung, DropCap.Rung.PLAIN)
	assert_eq(s.codex.entry(&"passo_encadeado").rung, DropCap.Rung.FILIGREE)
	assert_eq(s.codex.entry(&"golpe_sem_fim").rung, DropCap.Rung.ILLUMINATED)
	assert_lt(DropCap.RUNG_SIDE[0], DropCap.RUNG_SIDE[1])
	assert_lt(DropCap.RUNG_SIDE[1], DropCap.RUNG_SIDE[2])
	assert_eq(DropCap.RUNG_LETTER, [28, 34, 44], "the letters of the specification")


func test_a_bridge_is_split_in_the_ink_of_both_branches() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	var bridge := s.codex.entry(&"investida")
	assert_eq(bridge.def.joins, [TalentDef.Branch.COMBO, TalentDef.Branch.FURIA] as Array[TalentDef.Branch])
	assert_eq(GiftArt.gift_ink(bridge.def), GiftArt.ink(TalentDef.Branch.COMBO))
	assert_eq(GiftArt.ink2(bridge.def), GiftArt.ink(TalentDef.Branch.FURIA))
	assert_eq(GiftArt.ink2(s.codex.entry(&"quarto_corte").def).a, 0.0, "only a bridge is split")
	assert_eq(bridge.note, T.t(&"codex_note_bridge", {"a": T.t(&"hero_branch_combo"), "b": T.t(&"hero_branch_furia")}))


func test_the_apex_has_a_margin_note_with_the_partner_branch() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	assert_eq(s.codex.entry(&"golpe_sem_fim").note, T.t(&"codex_note_apex", {"branch": T.t(&"hero_branch_furia")}))
	assert_eq(s.codex.entry(&"quarto_corte").note, "")


func test_two_gifts_on_the_same_action_are_joined_by_an_or() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	assert_true(s.codex.entry(&"ferro_na_investida").or_above, "Passo Encadeado and Ferro na Investida take the Investida")
	assert_false(s.codex.entry(&"passo_encadeado").or_above)
	assert_false(s.codex.entry(&"quarto_corte").or_above)


func test_the_thread_lights_with_what_is_worn() -> void:
	var s := _screen(_data("warrior", XP_MAX, ["quarto_corte"]))
	assert_eq(s.codex.entry(&"quarto_corte").thread_in, GiftEntry.Cord.NONE)
	assert_eq(s.codex.entry(&"quarto_corte").thread_out, GiftEntry.Cord.MET, "the segment to Passo Encadeado is gold")
	assert_eq(s.codex.entry(&"passo_encadeado").thread_in, GiftEntry.Cord.MET)
	assert_eq(s.codex.entry(&"golpe_sem_fim").thread_in, GiftEntry.Cord.MISSING)
	assert_eq(s.codex.entry(&"investida").thread_in, GiftEntry.Cord.NONE, "no thread in Pontes")


# ---------- the five states ----------

func test_locked_open_equipped_blocked_and_sealed_are_told_in_words() -> void:
	var s := _screen(_data("warrior", HeroDef.warrior().mastery.total_to(8), ["quarto_corte"], 0, false))
	assert_eq(s.codex.entry(&"furia_plena").state, HeroLoadout.State.LOCKED)
	assert_eq(s.codex.entry(&"furia_plena").line, T.t(&"codex_gift_locked", {"n": 18}))
	assert_eq(s.codex.entry(&"quarto_corte").state, HeroLoadout.State.EQUIPPED)
	var sealed := s.codex.entry(&"impeto")
	assert_eq(sealed.state, HeroLoadout.State.SEALED)
	assert_eq(sealed.seal_cost, 2, "the Memória's price is pressed in the lacre")
	assert_eq(sealed.line, T.t(sealed.def.desc_key), "the paragraph stays written under the cord")
	# an open one that a rule refuses is BLOCKED and says why in a few words
	var d := _data("warrior", XP_MAX)
	var t := _screen(d)
	var blocked := t.codex.entry(&"passo_encadeado")
	assert_eq(blocked.state, HeroLoadout.State.BLOCKED)
	assert_eq(blocked.line, T.t(&"codex_block_needs", {"what": T.t(&"talent_quarto_corte")}))
	assert_true(blocked.line_is_reason)


func test_a_short_reason_for_each_rule() -> void:
	var l := HeroLoadout.new(HeroDef.warrior(), _data("warrior", XP_MAX, ["quarto_corte", "passo_encadeado", "corte_crescente"]))
	var slot := l.short_why(l.book.find(&"fio_do_passo"))
	assert_eq(slot.key, &"codex_block_slot")
	assert_eq(slot.args.name, T.t(&"talent_passo_encadeado"))
	var apex := l.short_why(l.book.find(&"golpe_sem_fim"))
	assert_eq(apex.key, &"codex_block_apex")
	var bridge := l.short_why(l.book.find(&"sangue_quente"))
	assert_eq(bridge.key, &"codex_block_bridge")
	var full := HeroLoadout.new(HeroDef.warrior(), _data("warrior", HeroDef.warrior().mastery.total_to(8), ["quarto_corte", "impeto", "corte_crescente", "lamina_faminta", "passo_encadeado"]))
	var short := full.short_why(full.book.find(&"avanco_feroz"))
	assert_eq(short.key, &"codex_block_candles", "two candles missing")
	assert_eq(short.args.n, 2)


func test_breaking_the_lacre_asks_twice_then_the_wax_cracks() -> void:
	var s := _screen(_data("warrior", HeroDef.warrior().mastery.total_to(3), [], 2, false))
	var impeto := s.loadout.book.find(&"impeto")
	var e := s.codex.entry(&"impeto")
	assert_eq(e.state, HeroLoadout.State.SEALED)
	s._pick(impeto)
	assert_eq(s.arming, &"impeto")
	assert_eq(e.state, HeroLoadout.State.SEALED, "nothing is spent before the second press")
	s._pick(impeto)
	assert_eq(e.state, HeroLoadout.State.OPEN)
	assert_true(e.is_cracking(), "the wax splits and falls")
	assert_eq(s.loadout.memory(), 0)
	await wait_seconds(0.6)
	assert_false(e.is_cracking())


func test_the_status_line_names_the_lacre() -> void:
	var s := _screen(_data("warrior", HeroDef.warrior().mastery.total_to(3), [], 0, false))
	s._tell(s.loadout.book.find(&"impeto"))
	assert_eq((s.find_child("status", true, false) as Label).text, T.t(&"codex_state_sealed", {"n": 2}))
	for key: StringName in [&"codex_state_sealed", &"hero_state_sealed", &"hero_open_confirm", &"bar_open", &"hero_step_open", &"hero_why_sealed", &"hero_cost_memory"]:
		assert_false(T.t(key).to_lower().contains("selo"), "the wax piece is the lacre, never the selo: %s" % key)


func test_equipping_fills_the_capital_from_the_bottom() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	var e := s.codex.entry(&"quarto_corte")
	assert_eq(e.fill(), 0.0)
	e.pressed.emit()
	assert_eq(e.state, HeroLoadout.State.EQUIPPED)
	assert_lt(e.fill(), 1.0, "it fills over a moment")
	await wait_seconds(0.5)
	assert_eq(e.fill(), 1.0)
	e.pressed.emit()
	await wait_seconds(0.5)
	assert_eq(e.fill(), 0.0)


func test_a_locked_gift_refuses_and_a_maga_gift_equips() -> void:
	var s := _screen(_data("maga", 0))
	s.codex.entry(&"inferno_runico").pressed.emit()
	assert_false(s.loadout.is_equipped(&"inferno_runico"))
	s.codex.entry(&"brasa_viva").pressed.emit()
	assert_true(s.loadout.is_equipped(&"brasa_viva"))
	assert_eq(s.codex.entry(&"brasa_viva").state, HeroLoadout.State.EQUIPPED)


# ---------- candles ----------

func test_the_devotion_is_candles_with_the_number_written() -> void:
	var s := _screen(_data("warrior", XP_MAX, ["quarto_corte"]))
	var candles := s.find_child("candles", true, false) as Candles
	assert_eq(candles.total, s.loadout.devotion())
	assert_eq(candles.used, 3)
	assert_eq((s.find_child("devotion", true, false) as Label).text, T.t(&"hero_devotion_count", {"used": 3, "max": s.loadout.devotion()}))
	assert_eq(candles.step_for(10000.0), 16.0)
	assert_lt(candles.step_for(100.0), 16.0, "many candles squeeze together")
	s._tell(s.loadout.book.find(&"impeto"))
	assert_eq(candles.preview, 2, "the candles it would cost tremble")
	s._tell(s.loadout.book.find(&"quarto_corte"))
	assert_true(candles.preview_held)


# ---------- the last chapter ----------

func test_the_ultimates_are_a_chapter_with_pencil_when_locked() -> void:
	var s := _screen(_data("warrior", HeroDef.warrior().mastery.total_to(6)))
	assert_true(s.codex.ults[0].open)
	assert_false(s.codex.ults[1].open)
	s.codex.ribbons[6].grab_focus()
	assert_eq(s.codex.chapter, 6)
	assert_true(s.codex.ults[0].is_visible_in_tree())
	s.codex.ults[0].pressed.emit()
	assert_true(s.codex.ults[0].chosen)
	s.codex.ults[1].pressed.emit()
	assert_false(s.codex.ults[1].chosen, "the locked one is never chosen")


# ---------- keys ----------

func _press(action: StringName) -> InputEventAction:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	return ev


func test_left_and_right_turn_the_ribbon_and_keep_the_row() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	await wait_process_frames(2)
	var e := s.codex.entry(&"passo_encadeado")
	e.grab_focus()
	e.gui_input.emit(_press(&"ui_right"))
	assert_eq(s.codex.chapter, 1)
	assert_eq(get_viewport().gui_get_focus_owner(), s.codex.entry(&"avanco_feroz"), "the second row of the next ribbon")
	s.codex.entry(&"avanco_feroz").gui_input.emit(_press(&"ui_left"))
	assert_eq(s.codex.chapter, 0)


func test_down_from_a_ribbon_enters_its_page_and_up_returns() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	await wait_process_frames(2)
	s.codex.ribbons[3].grab_focus()
	assert_eq(s.codex.ribbons[3].find_valid_focus_neighbor(SIDE_BOTTOM), s.codex.entry(&"lamina_faminta"))
	assert_eq(s.codex.entry(&"lamina_faminta").find_valid_focus_neighbor(SIDE_TOP), s.codex.ribbons[3])


func test_the_book_opens_on_the_first_gift_that_can_go_on() -> void:
	var s := _screen(_data("warrior", HeroDef.warrior().mastery.total_to(3)))
	await wait_process_frames(2)
	assert_eq(get_viewport().gui_get_focus_owner(), s.codex.entry(&"quarto_corte"))


# ---------- the hero's hand and the miniatures ----------

func test_the_maga_inks_are_amber_and_slate_never_violet() -> void:
	for b in [TalentDef.Branch.PIRO, TalentDef.Branch.ARCA, TalentDef.Branch.CTRL]:
		var c := GiftArt.ink(b)
		assert_false(c.h > 0.72 and c.h < 0.9, "branch %d is not violet" % b)
	assert_ne(GiftArt.title_ink(HeroDef.maga()), GiftArt.title_ink(HeroDef.warrior()))


func test_each_branch_has_an_ink_of_its_own() -> void:
	var seen := {}
	for b in GiftArt.INK:
		seen[GiftArt.INK[b]] = true
	assert_eq(seen.size(), GiftArt.INK.size())
	assert_eq(GiftArt.INK.size(), 9)


func test_the_corners_and_the_placeholders_draw_without_a_painted_art() -> void:
	var c := Control.new()
	var drawn := [0]
	c.draw.connect(func() -> void:
		for hero in [HeroDef.warrior(), HeroDef.maga()]:
			GiftArt.corner(c, Vector2(20, 20), 10.0, hero, Color(Book.GILT, 0.5))
		GiftArt.paint(c, Rect2(0, 0, 200, 110), &"branch_combo", GiftArt.ink(TalentDef.Branch.COMBO), "C")
		GiftArt.paint(c, Rect2(0, 0, 200, 110), &"ult_cleave", GiftArt.ULT_INK, "C", true)
		drawn[0] += 1)
	add_child_autofree(c)
	await wait_process_frames(2)
	assert_gt(drawn[0], 0, "drawn without a painted art and without errors")
	assert_null(GiftArt.texture(&"branch_nope"))


func test_the_leiame_lists_every_art_id_the_loader_asks_for() -> void:
	var text := FileAccess.get_file_as_string("res://assets/ui/book/LEIAME.txt")
	var ids: Array[String] = []
	for b in GiftArt.BRANCH_ART:
		ids.append(String(GiftArt.BRANCH_ART[b]))
	for hero in [HeroDef.warrior(), HeroDef.maga()]:
		for u in hero.ultimates:
			ids.append("ult_%s" % u.id)
	for id in ids:
		assert_true(text.contains(id), "LEIAME.txt lists %s" % id)


func test_every_new_text_is_in_the_table_without_a_dash() -> void:
	for key: StringName in [&"codex_ribbon_ult", &"codex_gift_locked", &"codex_or", &"codex_note_apex", &"codex_note_bridge",
			&"codex_block_needs", &"codex_block_apex", &"codex_block_bridge", &"codex_block_slot", &"codex_block_candle",
			&"codex_block_candles", &"codex_state_sealed"]:
		assert_true(T.table.entries.has(String(key)), String(key))
		assert_false(T.t(key).contains("—") or T.t(key).contains("–"), String(key))
