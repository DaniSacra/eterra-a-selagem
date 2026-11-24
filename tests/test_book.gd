extends GutTest
## Art pack stage 2: the Livro de Ahk (HeroScreen in three chapters on a BookSpread), the Gift tree's new language
## (GiftEntry states, TalentGlyph, the codex's thread), the panel's prerequisite and next step
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


func test_only_the_playable_hero_is_in_the_book() -> void:
	var s := _book(_data(0))
	# one hero: his name is the chapter's (capital and rest in the head), no other hero offered anywhere
	var head := (s.find_child("name_cap", true, false) as Label).text + (s.find_child("name_rest", true, false) as Label).text
	assert_eq(head, T.t(HeroDef.warrior().name_key))
	assert_false(T.t(&"hero_maga") in s.chapters.map(func(b: Button) -> String: return String(b.get_meta(&"title"))))
	assert_eq(s.chapters.size(), 3, "Abertura, o herói, Ofícios: the Gifts left the book")


func test_dons_button_opens_the_medallion_over_the_book() -> void:
	var s := _book(_data(XP_3))
	(s.find_child("to_gifts", true, false) as Button).pressed.emit()
	assert_true(s._dons is DonsScreen)
	assert_true(s._dons.is_inside_tree())
	s._close_dons()
	assert_false(is_instance_valid(s._dons))


func test_focus_on_a_ribbon_shows_its_chapter() -> void:
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
	assert_eq(cap.custom_minimum_size.y, ceilf(UiKit.TEXT_FONT.get_height(HeroScreen.EPIGRAPH_SIZE)) * 3.0, "three lines tall")
	for id: String in HowToScreen.STEPS:
		assert_not_null(s.find_child("step_" + id, true, false), id)
	assert_eq((s.find_child("book_title", true, false) as Label).text, T.t(&"book_title").to_upper())
	assert_false(T.t(&"book_title").contains("Akh"), "Ahk, never Akh")


func test_the_way_down_emits_descend() -> void:
	var s := _book(_data(0), HeroScreen.Chapter.OPENING)
	watch_signals(s)
	(s.find_child("descend", true, false) as Button).pressed.emit()
	assert_signal_emitted(s, "descend")
	assert_null(s.find_child("descend_hero", true, false), "the one way down is the Abertura's")


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

func test_needs_text_by_place_in_the_tree() -> void:
	var lo := _loadout(2470)
	var book := lo.book
	assert_eq(lo.needs_text(book.find(&"disciplina")).key, &"hero_needs_none", "an entry needs nothing")
	var mid := lo.needs_text(book.find(&"cadencia"))
	assert_eq(mid.key, &"hero_why_needs")
	assert_eq(mid.args.what, T.t(&"talent_disciplina"))
	var apex := lo.needs_text(book.find(&"apogeu"))
	assert_eq(apex.key, &"hero_why_needs", "redesign: an apex names the Gift it needs")
	assert_eq(apex.args.what, T.t(&"talent_maestria_marcial"))


func test_next_step_and_xp_missing() -> void:
	var lo := _loadout(XP_3)
	var later := lo.book.find(&"cadencia")
	var step := lo.next_step(later)
	assert_eq(step.key, &"hero_step_mastery")
	assert_eq(step.args.xp, HeroDef.warrior().mastery.total_to(later.unlock_level) - XP_3)
	assert_eq(lo.next_step(lo.book.find(&"disciplina")), {}, "open: nothing to do but put it on")
	var blocked := _loadout(XP_8)
	assert_eq(blocked.next_step(blocked.book.find(&"cadencia")).key, &"hero_why_needs", "blocked: the rule")
	assert_eq(lo.xp_missing(1), 0)


# ---------- the tree ----------

func test_every_gift_has_its_own_glyph() -> void:
	for t in HeroDef.warrior().talents().catalog:
		assert_true(TalentGlyph.has(t.id), String(t.id))


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


# ---------- the redo of 2026-11-23 (docs/art/book_spec.md) ----------

func test_the_chapters_loop_and_a_far_ribbon_is_a_turn_a_chapter() -> void:
	assert_eq(BookTurn.next(2, 1, 3), 0, "Ofícios turns to the Abertura")
	assert_eq(BookTurn.next(0, -1, 3), 2)
	assert_eq(BookTurn.next(1, 1, 3), 2)
	assert_eq(BookTurn.route(0, 2), [1, 2] as Array[int], "one turn for each chapter of distance")
	assert_eq(BookTurn.route(2, 0), [1, 0] as Array[int])
	assert_eq(BookTurn.route(1, 1), [] as Array[int])
	assert_almost_eq(HeroScreen.TURN, 0.35, 0.001)


func test_inputs_turn_the_page() -> void:
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	assert_eq(HeroScreen.page_step(wheel), 1)
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	assert_eq(HeroScreen.page_step(wheel), -1)
	var key := InputEventAction.new()
	key.pressed = true
	key.action = &"tab_next"
	assert_eq(HeroScreen.page_step(key), 1)
	key.action = &"tab_prev"
	assert_eq(HeroScreen.page_step(key), -1)
	key.action = &"ui_accept"
	assert_eq(HeroScreen.page_step(key), 0)


func test_turning_goes_to_the_next_chapter_and_loops() -> void:
	var s := _book(_data(0), HeroScreen.Chapter.OFICIOS)
	s._turn_page(1)
	assert_eq(s.chapter, HeroScreen.Chapter.OPENING)
	s._turn_page(-1)
	assert_eq(s.chapter, HeroScreen.Chapter.OFICIOS)
	for i in 2:
		assert_eq((s.get("_folios")[i] as Label).text, HeroScreen.FOLIO[HeroScreen.Chapter.OFICIOS][i], "the folios follow")


func test_the_pages_are_equal_and_the_head_names_the_chapter() -> void:
	var s := _book(_data(0))
	await wait_process_frames(3)
	assert_almost_eq(s._book.left.size.x, s._book.right.size.x, 1.0, "two equal pages")
	assert_eq((s.find_child("name_cap", true, false) as Label).text + (s.find_child("name_rest", true, false) as Label).text,
		T.t(&"title_hero"))
	s._show(HeroScreen.Chapter.OPENING)
	assert_eq((s.find_child("name_cap", true, false) as Label).text, "A")
	assert_not_null(s.find_child("mastery", true, false))
	assert_null(s.find_child("devotion", true, false))


func test_the_hero_page_lists_the_equipped_gifts_to_read_only() -> void:
	var s := _book(_data(XP_3, [&"disciplina"]))
	var list := s.find_child("gifts_equipped", true, false)
	assert_not_null(list)
	assert_eq(list.get_child_count(), 1)
	for b in list.find_children("*", "BaseButton", true, false):
		assert_true(false, "no button in the list")
	var none := _book(_data(0))
	assert_not_null(none.find_child("gifts_none", true, false))
	assert_eq((none.find_child("gifts_none", true, false) as Label).text, T.t(&"hero_gifts_none"))


func test_the_book_follows_the_picked_hero() -> void:
	var d := _data(0)
	d.wins = 1
	d.hero = "maga"
	var s := _book(d)
	assert_true(GiftArt.is_maga(s.loadout.hero), "the Maga's page")
	assert_eq((s.chapters[HeroScreen.Chapter.HERO].get_meta(&"title") as String), T.t(&"hero_maga"))
	var skills := s.find_child("skills", true, false)
	var said := " ".join(skills.find_children("*", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text))
	assert_string_contains(said, T.t(&"hero_skill_name_special_maga"))
	assert_string_contains(said, T.t(&"hero_passive_maga"))
	assert_false(said.contains(T.t(&"hero_passive")), "not the Warrior's passive")


func test_nothing_is_bought_in_the_book() -> void:
	var s := _book(_data(0), HeroScreen.Chapter.OFICIOS)
	for b in s.find_children("*", "Button", true, false):
		var n := String((b as Button).name)
		assert_false(n.begins_with("buy") or n.begins_with("discern_"), n)
