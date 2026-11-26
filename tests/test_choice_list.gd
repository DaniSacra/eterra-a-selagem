extends GutTest
## The lote C3 (BC-1 to BC-4): the Blessing screen as a list with the button's real key and the six buttons beside it,
## each Blessing on the button it really changes, the meeting with two figures and the angel's words first.

var game: Game


func _state() -> BoonState:
	return BoonState.new(BoonState.load_catalog())


func _meeting(ids := "sarael,nivael") -> void:
	Dev._args["seed"] = "5"
	Dev._args["boons"] = "0"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	await wait_process_frames(2)
	game.rooms.room.reward = RunMap.Reward.BOON
	Dev.put("angels", ids)
	game.rooms._room_cleared()
	game.rooms._collect()
	Dev.drop("angels")


func after_each() -> void:
	Dev.put("seed", "1")
	Dev._args.erase("boons")


# ---------- BC-2 ----------

func test_a_blessing_names_the_button_it_changes() -> void:
	var st := _state()
	assert_eq(st.find(&"golpe_brasa").button(), &"light_attack")
	assert_eq(st.find(&"pesado_brasa").button(), &"heavy_attack")
	assert_eq(st.find(&"circulo_brasa").button(), &"heavy_attack", "GP-1: the Poder is on the right button")
	assert_eq(st.find(&"passo_radiante").button(), &"dodge", "GP-1: the Investida's Blessings sit on the dodge")
	assert_eq(st.find(&"passo_brasa").button(), &"dodge", "the embers' trail is the dodge")
	assert_eq(st.find(&"passos").button(), &"dodge")
	assert_eq(st.find(&"passo_frio").button(), &"dodge", "an Elo reads its own tag")


func test_the_column_puts_both_dodge_blessings_on_space() -> void:
	var st := _state()
	var col := BuildColumn.new().setup()
	add_child_autofree(col)
	st.take(st.find(&"passo_radiante"), Boon.Rarity.COMMON)
	col.show_build(st)
	assert_eq(col.entries[3].icon.boon, st.find(&"passo_radiante"), "Space")
	var st2 := _state()
	st2.take(st2.find(&"passo_brasa"), Boon.Rarity.COMMON)
	col.show_build(st2)
	assert_eq(col.entries[3].icon.boon, st2.find(&"passo_brasa"), "Space")


# ---------- BC-1 ----------

func _choice(ids: Array) -> BoonChoice:
	var st := _state()
	var offers: Array[Boon] = []
	for id in ids:
		offers.append(st.find(id))
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open(offers, st)
	return choice


func test_the_blessings_are_lines_one_under_the_other_with_the_real_key() -> void:
	var choice := _choice([&"golpe_brasa", &"passo_radiante", &"circulo_brasa"])
	await wait_process_frames(4)
	var cards := choice.cards()
	assert_eq(cards.size(), 3)
	var view := choice.get_viewport_rect()
	for i in cards.size():
		assert_true(cards[i].listed)
		var r := cards[i].get_global_rect()
		assert_true(view.encloses(r), "line %d inside the screen" % i)
		assert_gt(r.size.x, r.size.y * 2.0, "a wide line, not a tall card")
		if i > 0:
			assert_gte(r.position.y, cards[i - 1].get_global_rect().end.y, "one under the other")
		var plaque := cards[i].find_child("Key", true, false)
		assert_not_null(plaque, "the key's plaque")
		if plaque is Label:
			assert_eq((plaque as Label).text, UiKit.action_label(cards[i].button()), "the key the player has now")
		else:
			assert_true(plaque is TextureRect, "a mouse button is the mouse icon (PT-26-1)")
	assert_eq((cards[1].find_child("Key", true, false) as Label).text, UiKit.action_label(&"dodge"), "the Investida's Blessing says Space")
	for c in cards:
		for other in [choice.list, choice.glossary]:
			assert_false(c.get_global_rect().intersects((other as Control).get_global_rect()), "nothing over the lines")


func test_the_list_lights_the_button_of_the_blessing_in_focus() -> void:
	var choice := _choice([&"golpe_brasa", &"passo_radiante", &"circulo_brasa"])
	await wait_process_frames(3)
	assert_true(choice.list.is_lit(&"light_attack"), "the first card has the focus")
	choice.cards()[1].grab_focus()
	assert_true(choice.list.is_lit(&"dodge"))
	choice.cards()[2].grab_focus()
	assert_true(choice.list.is_lit(&"heavy_attack"))
	assert_false(choice.list.is_lit(&"dodge"))


func test_a_blessing_that_acts_alone_lights_none() -> void:
	var st := _state()
	var alone: Boon = null
	for b in st.catalog:
		if b.button() == &"" and not b.is_duo():
			alone = b
			break
	assert_not_null(alone, "some Blessing acts alone")
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open([alone] as Array[Boon], st)
	await wait_process_frames(3)
	assert_eq(choice.list.lit, &"")
	assert_true((choice.list.find_child("Alone", true, false) as Label).visible, "Age sozinha")


func test_the_lights_follow_the_family_colour() -> void:
	var c := BoonCard.new()
	c.setup(_state().find(&"golpe_geada"), Boon.Rarity.COMMON, 0, [], null, "x")
	assert_eq(BoonChoice.card_tint(c), _state().find(&"golpe_geada").color())
	c.free()


func test_the_texts_have_no_dash_and_exist() -> void:
	for k in ["list_head", "list_alone", "encounter_hear"]:
		assert_true(T.table.entries.has(k), k)
		assert_false(T.t(k).contains("—") or T.t(k).contains("–"), k)


# ---------- BC-3 and BC-4 ----------

func test_the_angel_speaks_first_then_the_options_come() -> void:
	var a := Encounter.load_catalog()[0]
	var choice := _choice([&"golpe_brasa", &"toque_geada", &"onda_maior"])
	choice.by_angel(a, func() -> void: pass, 3)
	await wait_process_frames(2)
	assert_true(choice.intro_open())
	assert_false(choice.cards()[0].is_visible_in_tree(), "only the angel and its words")
	assert_false((choice.find_child("angel", true, false) as Control).is_visible_in_tree(), "no brought-by line while it speaks")
	var words := choice.find_child("IntroLine", true, false) as Label
	assert_eq(words.text, T.t(a.line_key), "the line that already exists")
	assert_true((choice.find_child("IntroHeld", true, false) as Label).text.contains("3"))
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	choice._press_focus()
	assert_false(choice.intro_open())
	await wait_process_frames(2)
	assert_true(choice.cards()[0].is_visible_in_tree())
	assert_true((choice.find_child("angel", true, false) as Control).is_visible_in_tree(), "back with the options")
	assert_true(choice.cards()[0].has_focus())


func test_without_the_held_count_the_options_open_at_once() -> void:
	var choice := _choice([&"golpe_brasa"])
	choice.by_angel(Encounter.load_catalog()[0], func() -> void: pass)
	assert_false(choice.intro_open())
	assert_true(choice.cards()[0].visible)


func test_the_meeting_has_two_stages_one_lit_and_the_hear_line() -> void:
	await _meeting()
	var meet := game._screen as EncounterScreen
	assert_eq(meet.buttons.size(), 2)
	assert_eq(meet.stages.size(), 2)
	await wait_process_frames(2)
	var left := meet.stages[0]
	var right := meet.stages[1]
	assert_lt(left.get_global_rect().end.x, right.get_global_rect().position.x + 1.0, "one at each side")
	assert_eq(left.size.y, meet.size.y, "the whole height")
	assert_gt(left.lit, right.lit, "the one in focus lit, the other dimmed")
	assert_gt(left.fx.strength, right.fx.strength)
	meet.buttons[1].grab_focus()
	await wait_process_frames(2)
	assert_eq(meet.focus, 1)
	assert_eq((meet.find_child("name", true, false) as Label).text, T.t(meet.angels[1].name_key), "the speech names the one in focus")
	assert_eq((meet.find_child("line", true, false) as Label).text, T.t(meet.angels[1].line_key))
	assert_eq((meet.find_child("Hear", true, false) as Label).text, T.t(&"encounter_hear", {"name": T.t(meet.angels[1].name_key)}))
	await wait_seconds(0.4)
	assert_gt(right.lit, left.lit, "the light followed in 0.2 s")
	assert_true(right.figure.get_child(0).material.get_shader_parameter(&"flip"), "the right one looks inwards")
	assert_false(left.figure.get_child(0).material.get_shader_parameter(&"flip"))


func test_left_and_right_change_the_angel_in_focus() -> void:
	await _meeting()
	var meet := game._screen as EncounterScreen
	await wait_process_frames(2)
	assert_eq(meet.focus, 0)
	var ev := InputEventAction.new()
	ev.action = &"ui_right"
	ev.pressed = true
	Input.parse_input_event(ev)
	await wait_process_frames(3)
	assert_eq(meet.focus, 1)


func test_a_lone_angel_goes_straight_to_its_cards() -> void:
	await _meeting()
	game.encounters.angels_now.clear()
	game.close_screen()
	EncounterScreen.attach(game)
	game.encounters.dev_open("sarael")
	await wait_process_frames(2)
	# PT-26-2: nothing to choose, so no screen waiting for Enter; the angel's art stays on the cards
	assert_false(game._screen is EncounterScreen)
	assert_true(game._screen is BoonChoice, "straight to the options")
	assert_not_null(game._screen.find_child("angel_column", true, false), "with its figure")


func test_autopick_never_waits_at_the_stage() -> void:
	Dev.put("autopick", "1")
	await _meeting()
	Dev.drop("autopick")
	assert_false(game._screen is EncounterScreen)


func test_the_words_come_once_in_a_room_not_again_on_going_back() -> void:
	await _meeting()
	var meet := game._screen as EncounterScreen
	meet._opened_at -= BoonChoice.GUARD_MS * 2
	meet.buttons[0].pressed.emit()
	var choice := game._screen as BoonChoice
	assert_true(choice.intro_open(), "the first time")
	assert_true(choice.back.is_valid(), "Esc still goes back to the pair")
	choice.back.call()
	meet = game._screen as EncounterScreen
	meet._opened_at -= BoonChoice.GUARD_MS * 2
	meet.buttons[0].pressed.emit()
	choice = game._screen as BoonChoice
	assert_false(choice.intro_open(), "not again for the same angel in the same room")
	assert_not_null(choice.find_child("angel_column", true, false), "the figure is there")


# ---------- adjustments after the captures ----------

func test_every_blessing_card_says_the_word_of_its_own_button() -> void:
	var st := _state()
	for b in st.catalog:
		if b.slot == Boon.Slot.NONE or b.is_duo():
			continue
		var card := BoonCard.new()
		card.listed = true
		card.setup(b, Boon.Rarity.COMMON, 0, [], null, "x")
		add_child_autofree(card)
		var words: Array[String] = []
		for l in card.find_children("*", "Label", true, false):
			words.append((l as Label).text)
		assert_true(words.has(T.t("action_" + String(b.button()))), "%s says %s" % [b.id, b.button()])
		var key := card.find_child("Key", true, false)
		if key is Label:
			assert_eq((key as Label).text, UiKit.action_label(b.button()))
		else:
			assert_true(key is TextureRect, "%s: a mouse button is the icon" % b.id)


func test_the_words_hide_the_title_and_the_hint_until_they_end() -> void:
	var choice := _choice([&"golpe_brasa"])
	choice.by_angel(Encounter.load_catalog()[0], func() -> void: pass, 0)
	await wait_process_frames(2)
	assert_false(choice._title.visible)
	assert_false(choice._hint.visible)
	assert_eq(choice.find_children("*", "Label", true, false).filter(func(l: Label) -> bool:
		return l.text == T.t(Encounter.load_catalog()[0].name_key) and l.is_visible_in_tree()).size(), 1, "the name once")
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	choice.end_intro()
	assert_true(choice._title.visible and choice._hint.visible)
