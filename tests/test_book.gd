extends GutTest
## Art pack stage 2: the Livro de Ahk (HeroScreen in three chapters on a BookSpread), the Gift tree's new language
## (TalentNode states, TalentGlyph, TalentTree.path_of and fit), the panel's prerequisite and next step
## (HeroLoadout.needs_text, next_step, xp_missing) and the Compendium as a page of the book (CodexScreen.progress, its
## index).

const XP_3 := 90
const XP_8 := 490


func _data(xp: int, equipped: Array = []) -> Dictionary:
	var d := SaveData.defaults()
	var block := SaveData.hero(d, "warrior")
	block.mastery_xp = xp
	SaveData.open_revealed(block)  # a player who got there before the Memória (Rejogabilidade): every Gift opened
	block.equipped = equipped
	return d


func _book(data: Dictionary, start: HeroScreen.Chapter = HeroScreen.Chapter.HERO) -> HeroScreen:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(data, start)
	return s


func _loadout(xp: int, equipped: Array = []) -> HeroLoadout:
	return HeroLoadout.new(HeroDef.warrior(), _data(xp, equipped))


# ---------- the book ----------

func test_the_book_opens_on_the_warrior_with_the_focus_on_his_gifts() -> void:
	var s := _book(_data(0))
	await wait_process_frames(2)
	assert_eq(s.chapter, HeroScreen.Chapter.HERO)
	assert_eq(get_viewport().gui_get_focus_owner(), s.find_child("to_gifts", true, false))
	assert_true(s.chapters[HeroScreen.Chapter.HERO].button_pressed)
	assert_true(s.find_child("portrait", true, false).is_visible_in_tree(), "the painted Warrior on the left page")
	assert_false(s.tree.is_visible_in_tree(), "the tree waits in its chapter")


func test_only_the_playable_hero_is_in_the_book() -> void:
	var s := _book(_data(0))
	# one hero: one name in the head of the page, no other hero offered anywhere
	var names := 0
	for l: Node in s.find_children("*", "Label", true, false):
		if (l as Label).text == T.t(HeroDef.warrior().name_key):
			names += 1
	assert_eq(names, 1)
	assert_eq(s.chapters.size(), 4)


func test_dons_opens_the_tree_with_the_focus_on_a_gift() -> void:
	var s := _book(_data(XP_3))
	(s.find_child("to_gifts", true, false) as Button).pressed.emit()
	assert_eq(s.chapter, HeroScreen.Chapter.GIFTS)
	assert_true(get_viewport().gui_get_focus_owner() is TalentNode)


func test_focus_on_a_bookmark_shows_its_chapter() -> void:
	var s := _book(_data(0))
	s.chapters[HeroScreen.Chapter.OPENING].grab_focus()
	assert_eq(s.chapter, HeroScreen.Chapter.OPENING)
	assert_true(s.find_child("epigraph", true, false).is_visible_in_tree())
	assert_false(s.find_child("portrait", true, false).is_visible_in_tree())


func test_the_opening_quotes_ahk_and_the_descent() -> void:
	var s := _book(_data(0), HeroScreen.Chapter.OPENING)
	assert_eq((s.find_child("epigraph_by", true, false) as Label).text, "Ahk, o Escriba")
	var ep := s.find_child("epigraph", true, false)
	var said := (ep.find_child("head", true, false) as Label).text + " " + (ep.find_child("tail", true, false) as Label).text
	assert_string_contains(said, "Elun, o Filho da Luz")
	var cap := ep.get_child(0).get_child(0) as DropCap
	assert_eq(cap.letter, "M", "the capital is the paragraph's first letter")
	assert_eq(cap.custom_minimum_size.y, ceilf(UiKit.TEXT_FONT.get_height(22)) * 3.0, "three lines tall")
	for id: String in HowToScreen.STEPS:
		assert_not_null(s.find_child("step_" + id, true, false), id)
	assert_eq((s.find_child("book_title", true, false) as Label).text, T.t(&"book_title").to_upper())
	assert_false(T.t(&"book_title").contains("Akh"), "Ahk, never Akh")


func test_the_way_down_emits_descend() -> void:
	var s := _book(_data(0), HeroScreen.Chapter.OPENING)
	watch_signals(s)
	(s.find_child("descend", true, false) as Button).pressed.emit()
	assert_signal_emitted(s, "descend")
	(s.find_child("descend_hero", true, false) as Button).pressed.emit()
	assert_signal_emit_count(s, "descend", 2)


func test_the_hero_page_names_his_weapon_and_abilities_with_the_hud_marks() -> void:
	var s := _book(_data(0))
	var skills := s.find_child("skills", true, false)
	var marks := skills.find_children("ActionMark", "Control", true, false)
	assert_eq(marks.size(), 6, "five actions and the ultimate")
	var glyphs := marks.map(func(m: Node) -> int: return int(m.get_meta(&"glyph")))
	for slot: Boon.Slot in [Boon.Slot.ATTACK, Boon.Slot.SPECIAL, Boon.Slot.DASH]:
		assert_true(glyphs.has(BoonIcon.ACTION_GLYPH + slot), "action %d" % slot)
	assert_true(glyphs.has(BoonIcon.SHOUT_GLYPH), "the Brado (Q)")
	assert_true(glyphs.has(BoonIcon.RUSH_GLYPH), "the Investida (E)")
	assert_eq(skills.find_children("TalentMark", "Control", true, false).size(), 1, "the passive")


func test_every_new_text_is_in_the_table_without_a_dash() -> void:
	for key: StringName in [&"book_title", &"book_chapter_opening", &"book_epigraph", &"book_epigraph_by", &"hero_weapon",
			&"hero_weapon_name", &"hero_weapon_desc", &"hero_style", &"hero_style_desc", &"hero_skills", &"hero_skill_attack",
			&"hero_skill_special", &"hero_skill_cast", &"hero_skill_dash", &"hero_skill_ultimate", &"hero_effect",
			&"hero_cost_head", &"hero_cost_devotion", &"hero_needs_head", &"hero_needs_none", &"hero_state_head",
			&"hero_step_mastery", &"hero_ult_needs", &"hero_ult_can_choose", &"codex_count"]:
		assert_true(T.table.entries.has(String(key)), String(key))
		assert_false(T.t(key).contains("—") or T.t(key).contains("–"), String(key))
		for word: String in ["Aliança", "Convênio", "Punho de Elun"]:
			assert_false(T.t(key).contains(word), "%s: %s" % [key, word])


# ---------- the panel ----------

func test_the_panel_tells_cost_prerequisite_state_and_next_step() -> void:
	var s := _book(_data(XP_3), HeroScreen.Chapter.GIFTS)
	s.tree.node(&"lamina_faminta").focus_entered.emit()
	var step := s.find_child("step", true, false) as Label
	var status := s.find_child("status", true, false) as Label
	var lo := s.loadout
	assert_eq(status.text, T.t(&"hero_why_locked", {"n": 4}))
	assert_eq(step.text, T.t(&"hero_step_mastery", {"n": 4, "xp": lo.xp_missing(4)}))
	s.tree.node(&"quarto_corte").focus_entered.emit()
	assert_eq(step.text, "", "no next step when it can go on")
	assert_eq(status.text, T.t(&"hero_can_equip"))


func test_needs_text_by_place_in_the_tree() -> void:
	var lo := _loadout(2470)
	var book := lo.book
	assert_eq(lo.needs_text(book.find(&"quarto_corte")).key, &"hero_needs_none", "an entry needs nothing")
	assert_eq(lo.needs_text(book.find(&"firmeza")).key, &"hero_needs_none", "a sustain Gift neither")
	var mid := lo.needs_text(book.find(&"passo_encadeado"))
	assert_eq(mid.key, &"hero_why_needs")
	assert_eq(mid.args.what, T.t(&"talent_quarto_corte"))
	assert_eq(lo.needs_text(book.find(&"golpe_sem_fim")).key, &"hero_why_apex")


func test_next_step_and_xp_missing() -> void:
	var lo := _loadout(XP_3)
	var later := lo.book.find(&"lamina_faminta")
	var step := lo.next_step(later)
	assert_eq(step.key, &"hero_step_mastery")
	assert_eq(step.args.xp, HeroDef.warrior().mastery.total_to(later.unlock_level) - XP_3)
	assert_eq(lo.next_step(lo.book.find(&"quarto_corte")), {}, "open: nothing to do but put it on")
	var blocked := _loadout(XP_8)
	assert_eq(blocked.next_step(blocked.book.find(&"passo_encadeado")).key, &"hero_why_needs", "blocked: the rule")
	assert_eq(lo.xp_missing(1), 0)


# ---------- the tree ----------

func test_every_gift_has_its_own_glyph() -> void:
	for t in HeroDef.warrior().talents().catalog:
		assert_true(TalentGlyph.has(t.id), String(t.id))


func test_path_of_lights_what_a_gift_needs() -> void:
	var s := _book(_data(2470), HeroScreen.Chapter.GIFTS)
	var book := s.loadout.book
	assert_eq(s.tree.path_of(book.find(&"quarto_corte")), [] as Array[TalentDef])
	var apex := s.tree.path_of(book.find(&"golpe_sem_fim"))
	assert_eq(apex.size(), 3, "the entry and both middles (Ferro na Investida, C2): either opens it")
	assert_true(apex.has(book.find(&"passo_encadeado")) and apex.has(book.find(&"quarto_corte")))
	var bridge := book.catalog.filter(func(t: TalentDef) -> bool: return t.tier == TalentDef.Tier.BRIDGE)[0] as TalentDef
	assert_eq(s.tree.path_of(bridge).size(), 2, "both entries")
	s.tree.node(&"golpe_sem_fim").focus_entered.emit()
	assert_true(s.tree.node(&"passo_encadeado").on_path)
	assert_false(s.tree.node(&"impeto").on_path)


func test_the_four_states_read_apart() -> void:
	var s := _book(_data(XP_8, ["quarto_corte"]), HeroScreen.Chapter.GIFTS)
	var worn := s.tree.node(&"quarto_corte")
	var open := s.tree.node(&"impeto")
	var locked := s.tree.node(&"furia_plena")
	var d := _data(XP_8)
	var t := _book(d, HeroScreen.Chapter.GIFTS)
	var blocked := t.tree.node(&"passo_encadeado")
	assert_eq(blocked.state, HeroLoadout.State.BLOCKED)
	assert_eq(locked.state, HeroLoadout.State.LOCKED)
	var lines := [worn.line_color(), open.line_color(), blocked.line_color(), locked.line_color()]
	for i in lines.size():
		for j in range(i + 1, lines.size()):
			assert_ne(lines[i], lines[j], "lines %d and %d" % [i, j])
	assert_ne(blocked.glyph_color(), open.glyph_color())


func test_the_tree_fits_the_room_it_gets() -> void:
	assert_almost_eq(TalentTree.fit(TalentTree.base_size()), 1.0, 0.001)
	assert_eq(TalentTree.fit(Vector2(10, 10)), TalentTree.FIT_MIN)
	assert_almost_eq(TalentTree.fit(TalentTree.base_size() * Vector2(0.9, 2.0)), 0.9, 0.001)


# ---------- the Compendium ----------

func test_the_codex_index_counts_what_was_found() -> void:
	var d := _data(XP_3)
	d.codex.boons["brasas"] = {"seen": 2}
	d.codex.enemies["skeleton"] = {"defeated": 4}
	d.codex.enemies["morvath"] = {"met": 1, "phase": 2}
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.ENEMIES, d)
	assert_eq(c.progress(CodexScreen.Tab.BOONS).x, 1)
	assert_eq(c.progress(CodexScreen.Tab.ENEMIES), Vector2i(1, CodexScreen.ENEMIES.size()))
	assert_eq(c.progress(CodexScreen.Tab.MORVATH), Vector2i(2, CodexScreen.PHASES))
	var gifts := HeroDef.warrior().talents().unlocked(20)
	assert_eq(c.progress(CodexScreen.Tab.GIFTS).y, gifts.size())
	var count := c.tabs[CodexScreen.Tab.ENEMIES].find_child("count", false, false) as Label
	assert_eq(count.text, T.t(&"codex_count", {"n": 1, "total": CodexScreen.ENEMIES.size()}))
	assert_eq((c._chapter.get_node("text") as Label).text, T.t(&"codex_tab_enemies"))


func test_the_codex_is_a_page_of_the_book() -> void:
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.GIFTS, _data(0))
	var book := c.find_child("book", true, false) as BookSpread
	assert_not_null(book)
	assert_true(book.left.is_ancestor_of(c.tabs[0]), "the index on the left page")
	assert_true(book.right.is_ancestor_of(c._list), "the list on the right page")
	await wait_process_frames(2)
	assert_eq(c.tabs[0].find_valid_focus_neighbor(SIDE_BOTTOM), c.tabs[1], "down walks the index")


func test_drop_cap_split_keeps_every_word() -> void:
	var text := T.t(&"book_epigraph").substr(1)
	var parts := DropCap.split(text, UiKit.TEXT_FONT, 22, 220.0)
	assert_eq(parts[0] + " " + parts[1], text, "head and tail are the paragraph")
	var p := TextParagraph.new()
	p.width = 220.0
	p.add_string(parts[0], UiKit.TEXT_FONT, 22)
	assert_lte(p.get_line_count(), DropCap.LINES, "the head is three lines at most")
	assert_eq(DropCap.split("curto", UiKit.TEXT_FONT, 22, 220.0)[1], "", "a short text has no tail")
