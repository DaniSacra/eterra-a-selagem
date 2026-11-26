extends GutTest
## SW-B1 and SW-B3: the Blessing screen in the angel's colour (name and line, "Novo!", the numbers in one line, the box of
## a word of rule, the six buttons with what each holds, the cards coming apart) and what a Blessing asks before it
## comes (BoonNeeds).

var _kept_data: Dictionary


func _state() -> BoonState:
	return BoonState.new(BoonState.load_catalog())


func before_each() -> void:
	_kept_data = Save.data.duplicate(true)


func after_each() -> void:
	Save.data = _kept_data


func _choice(ids: Array, fresh: Array[StringName] = []) -> BoonChoice:
	var st := _state()
	var offers: Array[Boon] = []
	for id in ids:
		offers.append(st.find(id))
	var choice := BoonChoice.new()
	choice.fresh = fresh
	add_child_autofree(choice)
	choice.open(offers, st)
	return choice


# ---------- SW-B3 ----------

func test_an_elo_asks_one_blessing_of_each_list() -> void:
	var st := _state()
	var lines := BoonNeeds.lines(st.find(&"vapor"), st.catalog)
	assert_eq(lines.size(), 2, "one line a list")
	for l in lines:
		assert_true(l.begins_with("Pede "), l)
		assert_false(l.contains("—") or l.contains("–"), "no dash")
	assert_true(lines[0].contains(T.t(&"need_others")), "a long list ends in outras")


func test_a_move_tag_asks_the_combo_for_it() -> void:
	var st := _state()
	# (V1: no Blessing of the draw asks a move shape any more; the line stays for the data that does)
	for tag in [&"finisher", &"spin"]:
		var b := Boon.new()
		b.id = StringName("needs_%s" % tag)
		b.needs_tag = tag
		assert_eq(BoonNeeds.lines(b, st.catalog), PackedStringArray([T.t(StringName("need_tag_%s" % tag))]))


func test_a_plain_blessing_asks_nothing_and_null_is_safe() -> void:
	var st := _state()
	assert_true(BoonNeeds.lines(st.find(&"golpe_brasa"), st.catalog).is_empty())
	assert_true(BoonNeeds.lines(null).is_empty())


func test_a_blessing_of_shift_asks_the_ultimate() -> void:
	var st := _state()
	var ult: Boon
	for b in st.catalog:
		if b.slot == Boon.Slot.ULT and not b.is_duo():
			ult = b
			break
	assert_not_null(ult)
	assert_true(BoonNeeds.lines(ult, st.catalog).has(T.t(&"need_ult")))


# ---------- SW-B1 ----------

func test_the_six_buttons_say_what_each_holds() -> void:
	var st := _state()
	st.take(st.find(&"passo_radiante"), Boon.Rarity.COMMON)
	st.take(st.find(&"golpe_brasa"), Boon.Rarity.COMMON)
	var held := AbilityList.held_by_action(st)
	assert_eq(held[&"dodge"], st.find(&"passo_radiante"), "GP-1: the Investida's Blessing sits on the dodge")
	assert_eq(held[&"light_attack"], st.find(&"golpe_brasa"))
	assert_false(held.has(&"ultimate"))
	var list := AbilityList.new().setup(240.0)
	add_child_autofree(list)
	list.show_held(st)
	assert_eq(list.held_text(&"dodge"), T.t(&"boon_passo_radiante"))
	assert_eq(list.held_text(&"ultimate"), "", "a free button says nothing")
	list.show_held(_state())
	assert_eq(list.held_text(&"dodge"), "")


func test_never_seen_means_the_codex_has_no_count() -> void:
	Save.data["codex"] = {"boons": {"golpe_brasa": {"seen": 2}}}
	assert_true(BoonChoice.known_to_codex(&"golpe_brasa"))
	assert_false(BoonChoice.known_to_codex(&"passo_brasa"))
	Save.data["codex"] = {}
	assert_false(BoonChoice.known_to_codex(&"golpe_brasa"))


func test_the_new_mark_is_only_on_the_unseen_ones() -> void:
	var choice := _choice([&"golpe_brasa", &"passo_brasa"], [&"golpe_brasa"] as Array[StringName])
	await wait_process_frames(2)
	assert_not_null(choice.cards()[0].find_child("NewMark", true, false))
	assert_eq((choice.cards()[0].find_child("New", true, false) as Label).text, T.t(&"choice_new_mark"))
	assert_null(choice.cards()[1].find_child("NewMark", true, false))


func test_the_numbers_run_in_one_line_with_the_real_values() -> void:
	var choice := _choice([&"pesado_brasa"])
	await wait_process_frames(3)
	var card := choice.cards()[0]
	var facts := card.find_child("Facts", true, false) as HBoxContainer
	assert_not_null(facts, "a row, not a column")
	var rows := BoonChoice.facts(card.boon, 1)
	assert_gt(rows.size(), 0)
	assert_eq((facts.get_child(0).find_child("Value", false, false) as Label).text, rows[0][2], "the Blessing's own number")
	assert_true((facts.get_child(0).find_child("Label", false, false) as Label).text.ends_with(":"))
	assert_lte(facts.get_child_count(), 2)


func test_a_button_blessing_never_says_every_n_seconds() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var b := state.find(&"circulo_brasa")
	for r: Array in BoonChoice.facts(b, 1):
		assert_ne(r[0], &"cd", "a button's skill is not periodic")
	var gap: Array = BoonChoice.facts(b, 1).filter(func(r: Array) -> bool: return r[0] == &"gap")
	assert_eq(gap.size(), 1, "the pause between two firings instead")
	var auto := BoonChoice.facts(state.find(&"brasas"), 1).filter(func(r: Array) -> bool: return r[0] == &"cd")
	assert_eq(auto.size(), 1, "an automatic one keeps its period")


func test_the_rarity_stands_beside_the_name() -> void:
	var choice := _choice([&"golpe_brasa"])
	await wait_process_frames(2)
	var rar := choice.cards()[0].find_child("Rarity", true, false)
	assert_eq(rar.get_parent().name, &"Title")


func test_a_word_of_rule_under_the_pointer_shows_its_own_box() -> void:
	var choice := _choice([&"pesado_brasa"])
	await wait_process_frames(3)
	var card := choice.cards()[0]
	assert_true(card.plain.to_lower().contains("queimadura") or choice.glossary.shown.size() > 0)
	card.term_hovered.emit(&"freeze")
	assert_eq(choice.glossary.shown, [&"freeze"] as Array[StringName])
	card.term_hovered.emit(&"")
	assert_eq(choice.glossary.shown, Glossary.terms_of(card.plain), "off the word: the card's words again")


func test_the_words_of_rule_are_marked_for_the_pointer() -> void:
	assert_true(Glossary.mark("congela", &"freeze").begins_with("[url=freeze]"))
	assert_eq(Glossary.mark("congela", &"freeze").length() - Glossary.mark("congela", &"freeze").replace("[url=freeze]", "").length(), 12)


func test_the_screen_takes_the_angels_colour_name_and_line() -> void:
	var a := Encounter.load_catalog()[0]
	var choice := _choice([&"golpe_brasa"])
	choice.by_angel(a, func() -> void: pass)
	var veil := choice.find_child("AngelTint", true, false) as ColorRect
	assert_not_null(veil)
	assert_eq(Color(veil.color, 1.0).h, Color(AngelSeal.tint(a.family).darkened(0.4), 1.0).h, "the family's hue")
	assert_eq((choice.find_child("angel", true, false) as Label).text, T.t(a.name_key))
	assert_eq((choice.find_child("angel_line", true, false) as Label).text, T.t(a.line_key), "the line that already exists")
	choice.by_angel(a, func() -> void: pass)
	assert_eq(choice.find_children("AngelTint", "ColorRect", true, false).size(), 1, "never twice")


func test_the_cards_come_apart_before_the_pick_is_told() -> void:
	var choice := _choice([&"golpe_brasa", &"passo_brasa"])
	choice.dissolve_headless = true
	var picked: Array[Boon] = []
	choice.chosen.connect(func(b: Boon) -> void: picked.append(b))
	await wait_process_frames(2)
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	choice.cards()[0].pressed.emit()
	assert_true(picked.is_empty(), "not yet: they are coming apart")
	assert_true(choice.cards()[0].material is ShaderMaterial)
	choice.cards()[1].pressed.emit()
	await wait_seconds(BoonChoice.DISSOLVE_TIME + 0.3)
	assert_eq(picked.size(), 1, "told once, and only the first card")
	assert_eq(picked[0].id, &"golpe_brasa")


func test_the_new_texts_exist_without_dash() -> void:
	for k in ["need_set", "need_or", "need_others", "need_tag_finisher", "need_tag_spin", "need_ult", "choice_new_mark"]:
		assert_true(T.table.entries.has(k), k)
		assert_false(T.t(k).contains("—") or T.t(k).contains("–"), k)
