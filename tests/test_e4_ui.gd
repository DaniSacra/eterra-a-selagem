extends GutTest
## E4 interface (E4-03 to E4-05): a person gets a Psalm card and picks it (BoonChoice.open_cards, card_chosen), the
## card's own frame, the action it changes and the three things that opened it, never a number of a psalm nor a verse
## on the screen; the "Salmo descoberto" greeting that never stops the game and waits for the cards to go; the Pastor's
## lights over the special; the Compendium's Salmos, Inimigos, Morvath and Arenas tabs, fitting 720 lines; and what a
## run writes into the Codex for them.

var game: Game


func before_each() -> void:
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)


func _run() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO


func _hold_rocha() -> void:
	for id in [&"golpe_firme", &"escudo", &"vapor"]:
		game.boons.levels[id] = 1


func _labels(n: Node) -> Array[String]:
	var out: Array[String] = []
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return out


## A choice screen with these cards: a Psalm in the middle between two Blessings.
func _choice(p: PsalmDef, state: BoonState) -> BoonChoice:
	var cards: Array[BoonState.Card] = [BoonState.Card.new(state.find(&"brasas"))]
	var pc := BoonState.Card.new()
	pc.psalm = p
	cards.append(pc)
	cards.append(BoonState.Card.new(state.find(&"onda_maior")))
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open_cards(cards, state, null)
	return choice


# ---------- E4-03: the card ----------

func test_a_person_gets_a_psalm_card_and_picks_it() -> void:
	_run()
	assert_true(Game.screen_shows_psalms(), "the screen shows Psalm cards")
	assert_true(game.psalm_cards, "a person gets them")
	_hold_rocha()
	game.open_boon_choice(Boon.RARITY_CHANCE, 1.0)
	assert_eq(game.mode, Game.Mode.CHOICE, "the screen is open")
	var choice := game._screen as BoonChoice
	assert_not_null(choice)
	var psalm_cards := choice.cards().filter(func(c: BoonCard) -> bool: return c.psalm != null)
	assert_eq(psalm_cards.size(), 1, "one Psalm card")
	var card: BoonCard = psalm_cards[0]
	assert_eq(card.psalm.id, &"rocha")
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	card.pressed.emit()
	assert_eq(game.psalms.ids(), ["rocha"], "taken")
	assert_eq(game.mode, Game.Mode.PLAY, "back to the fight")


func test_a_blessing_card_beside_a_psalm_still_gives_the_blessing() -> void:
	_run()
	_hold_rocha()
	game.open_boon_choice(Boon.RARITY_CHANCE, 1.0)
	var choice := game._screen as BoonChoice
	var plain := choice.cards().filter(func(c: BoonCard) -> bool: return c.psalm == null)
	if plain.is_empty():
		pass_test("every card was the Psalm")
		return
	var b: Boon = (plain[0] as BoonCard).boon
	var before := game.boons.level(b.id)
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	(plain[0] as BoonCard).pressed.emit()
	assert_eq(game.boons.level(b.id), before + 1, "the Blessing taken")
	assert_eq(game.psalms.ids(), [], "no Psalm")
	assert_eq(game.mode, Game.Mode.PLAY)


func test_the_psalm_card_has_its_own_frame_and_says_what_it_changes() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	for id in [&"circulo_brasa", &"escudo", &"bastiao"]:
		state.levels[id] = 1
	var p := Psalms.new(Psalms.load_catalog()).find(&"sentinela")
	var choice := _choice(p, state)
	var card := choice.cards()[1]
	assert_eq(card.psalm, p)
	assert_null(card.boon)
	assert_eq(card.edge_color(), BoonCard.PSALM_EDGE)
	for r in [Boon.Rarity.COMMON, Boon.Rarity.RARE, Boon.Rarity.EPIC, Boon.Rarity.LEGENDARY]:
		assert_ne(card.edge_color(), BoonCard.rarity_color(r), "not a rarity's colour")
	assert_ne(card.edge_color(), BoonCard.ELO_EDGE, "not the Elo's metal")
	assert_null(card.find_child("Rarity", true, false), "no rarity")
	assert_null(card.find_child("Level", true, false), "no level")
	assert_not_null(card.find_child("PsalmTab", true, false))
	assert_eq((card.find_child("Transforms", true, false) as Label).text, T.t(&"psalm_transforms", {"action": T.t(&"slot_cast")}))
	var by := (card.find_child("OpenedBy", true, false) as Label).text
	for id in ["circulo_brasa", "escudo", "bastiao"]:
		assert_string_contains(by, T.t("boon_" + id))
	assert_true(card.crest is PsalmIcon)


func test_opened_by_names_a_gift() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	for id in [&"circulo_brasa", &"escudo"]:
		state.levels[id] = 1
	var p := Psalms.new(Psalms.load_catalog()).find(&"sentinela")
	var held := Psalms.held_of(state, [&"reserva"] as Array[StringName])
	var names := BoonChoice.opened_by(p, held)
	assert_eq(names.size(), 3)
	assert_eq(names[2], T.t(HeroDef.warrior().talents().find(&"reserva").name_key))
	assert_eq(Psalms.matching(p, {}).size(), 0, "nothing opens it with nothing held")


func test_picking_the_psalm_card_emits_it() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var p := Psalms.new(Psalms.load_catalog()).find(&"pastor")
	var choice := _choice(p, state)
	var got: Array = []
	choice.card_chosen.connect(func(c: BoonState.Card) -> void: got.append(c))
	choice.cards()[1].pressed.emit()
	assert_eq(got.size(), 0, "a button still held from the fight picks nothing")
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	choice.cards()[1].pressed.emit()
	assert_eq(got.size(), 1)
	assert_eq((got[0] as BoonState.Card).psalm, p)
	assert_eq(choice.drawn().size(), 3)


func test_no_psalm_number_nor_verse_on_the_screen() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var number := RegEx.create_from_string("(?i)salmo\\s*\\d|\\d+\\s*[:.]\\s*\\d+\\s*-|vers[ií]culo|\\b\\d+:\\d+\\b")
	for p in Psalms.load_catalog():
		var choice := _choice(p, state)
		for text in _labels(choice.cards()[1]):
			assert_null(number.search(text), "a number of a psalm or a verse on the card: %s" % text)
		var banner := EloBanner.new()
		add_child_autofree(banner)
		banner.show_psalm(p, true, true)
		for text in _labels(banner):
			assert_null(number.search(text), "on the greeting: %s" % text)
	var table: TextTable = load("res://data/text_pt.tres")
	for key: String in table.entries:
		if key.begins_with("psalm_") or key.begins_with("codex_psalm"):
			assert_null(number.search(String(table.entries[key])), "text %s" % key)


# ---------- E4-04: the greeting ----------

func test_the_greeting_waits_for_the_cards_and_never_stops_the_game() -> void:
	_run()
	_hold_rocha()
	game.open_boon_choice(Boon.RARITY_CHANCE, 1.0)
	var banner := game.hud.banner()
	assert_eq(banner.showing, &"", "nothing over the cards")
	var choice := game._screen as BoonChoice
	choice._opened_at -= BoonChoice.GUARD_MS * 2
	for c in choice.cards():
		if c.psalm != null:
			c.pressed.emit()
	assert_eq(game.mode, Game.Mode.PLAY, "the game goes on")
	game.hud._process(0.016)
	assert_eq(banner.showing, &"psalm")
	assert_eq((banner.find_child("Title", true, false) as Label).text, T.t(&"psalm_discovered"), "found for the first time")
	assert_eq((banner.find_child("Note", true, false) as Label).text, T.t(game.psalms.taken[0].line_key), "its line, taken")


func test_a_psalm_only_seen_is_noted() -> void:
	var banner := EloBanner.new()
	add_child_autofree(banner)
	var p := Psalms.new(Psalms.load_catalog()).find(&"abrigo")
	banner.show_psalm(p, true, false)
	assert_eq((banner.find_child("Note", true, false) as Label).text, T.t(&"psalm_noted"))
	banner.show_elo(BoonState.new(BoonState.load_catalog()).find(&"vapor"), [])
	assert_eq(banner.waiting(), 1, "the next greeting waits its turn")


func test_the_pastors_lights_over_the_special() -> void:
	_run()
	assert_true(game.take_psalm(game.psalms.find(&"pastor")))
	game.psalms.lights = 2
	game.hud._process(0.016)
	var special: ActionSlot
	for s in game.hud._slots:
		if s.slot == Boon.Slot.SPECIAL:
			special = s
	assert_eq(special.lights, 2)
	assert_eq(special.lights_max, game.psalms.find(&"pastor").count)
	for s in game.hud._slots:
		if s != special:
			assert_eq(s.lights_max, 0, "only the special")


# ---------- E4-05: the Compendium ----------

func _codex_data() -> Dictionary:
	var d := SaveData.defaults()
	d.codex.psalms["sentinela"] = {"seen": 2, "taken": 1}
	d.codex.enemies["skeleton"] = {"defeated": 40, "elite": 3}
	d.codex.enemies["mage"] = {"defeated": 5}
	d.codex.enemies["morvath"] = {"met": 3, "phase": 2, "defeated": 0}
	d.codex.arenas["hall"] = {"entered": 6}
	d.codex.arenas["crypt"] = {"entered": 2}
	return d


func _codex(t: CodexScreen.Tab) -> CodexScreen:
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(t, _codex_data())
	return c


func test_codex_has_eight_tabs() -> void:
	var c := _codex(CodexScreen.Tab.PSALMS)
	assert_eq(c.tabs.size(), 8)
	for t: int in CodexScreen.Tab.values():
		assert_eq(c.tabs[t].text, T.t(CodexScreen.TAB_KEY[t]))


func test_codex_psalms_found_and_hinted() -> void:
	var c := _codex(CodexScreen.Tab.PSALMS)
	var found := c._list.find_child("sentinela", true, false)
	assert_eq((found.find_child("Name", true, false) as Label).text, T.t(&"psalm_sentinela"))
	assert_eq((found.find_child("Times", true, false) as Label).text, T.t(&"codex_times", {"n": 1}))
	var hidden := c._list.find_child("rocha", true, false)
	assert_eq((hidden.find_child("Name", true, false) as Label).text, CodexScreen.UNKNOWN)
	assert_eq((hidden.find_child("Desc", true, false) as Label).text, T.t(&"codex_psalm_hint", {"hint": T.t(&"psalm_rocha_hint")}))
	assert_eq(c._legend.text, T.t(&"codex_psalms_legend", {"n": 1, "total": Psalms.load_catalog().size()}))


func test_codex_enemies_with_their_part() -> void:
	var c := _codex(CodexScreen.Tab.ENEMIES)
	var sk := c._list.find_child("skeleton", true, false)
	assert_eq((sk.find_child("Name", true, false) as Label).text, T.t(&"enemy_skeleton"))
	assert_eq((sk.find_child("Role", true, false) as Label).text, T.t(&"codex_role_pressure"))
	assert_string_contains((sk.find_child("Times", true, false) as Label).text, T.t(&"codex_defeated_elite", {"n": 3}))
	var knight := c._list.find_child("knight", true, false)
	assert_eq((knight.find_child("Name", true, false) as Label).text, CodexScreen.UNKNOWN)
	# every part has its text
	for id in CodexScreen.ENEMIES:
		var def: EnemyDef = load(CodexScreen.ENEMY_DIR + String(id) + ".tres")
		assert_ne(T.t(CodexScreen.role_key(def)), String(CodexScreen.role_key(def)), "text for %s" % id)
	assert_eq(CodexScreen.enemy_name(load(CodexScreen.ENEMY_DIR + "priest_elder.tres")), T.t(&"codex_enemy_priest_elder"))


func test_codex_morvath_phases_reached() -> void:
	var c := _codex(CodexScreen.Tab.MORVATH)
	assert_eq((c._list.find_child("phase_1", true, false).find_child("Name", true, false) as Label).text, "O Despertar")
	assert_eq((c._list.find_child("phase_2", true, false).find_child("Name", true, false) as Label).text, "O Ritual dos Mortos")
	assert_eq((c._list.find_child("phase_3", true, false).find_child("Name", true, false) as Label).text, CodexScreen.UNKNOWN)


func test_codex_arenas_entered() -> void:
	var c := _codex(CodexScreen.Tab.ARENAS)
	assert_eq((c._list.find_child("crypt", true, false).find_child("Name", true, false) as Label).text, T.t(&"arena_crypt"))
	assert_eq((c._list.find_child("rift", true, false).find_child("Name", true, false) as Label).text, CodexScreen.UNKNOWN)
	assert_not_null(c._list.find_child("seal_chamber", true, false))


func test_every_tab_fits_720_lines() -> void:
	var holder := Control.new()
	holder.size = Vector2(1280, 720)
	add_child_autofree(holder)
	var c := CodexScreen.new()
	holder.add_child(c)
	c.open(CodexScreen.Tab.GIFTS, _codex_data())
	for t: int in CodexScreen.Tab.values():
		c._show(t)
		await wait_process_frames(3)
		var box := c._list.get_parent().get_parent() as Control
		assert_lt(box.size.y, 720.0, "tab %d is taller than the screen" % t)
		assert_lt(box.size.x, 1280.0, "tab %d is wider than the screen" % t)


func test_a_run_writes_enemies_morvath_and_arenas_into_the_codex() -> void:
	var g := Game.new()
	g.defeated = {&"skeleton": 4, &"skeleton_elite": 1, &"knight": 1}
	g.arenas_seen = {&"hall": 2, &"crypt": 1}
	g.boss_stats = {"max_phase": 3}
	var d := SaveData.defaults()
	g.codex_run("victory", d)
	assert_eq(d.codex.enemies.skeleton, {"defeated": 5, "elite": 1})
	assert_eq(d.codex.enemies.knight, {"defeated": 1})
	assert_eq(d.codex.enemies.morvath, {"met": 1, "phase": 3, "defeated": 1})
	g.boss_stats = {"max_phase": 2}
	g.codex_run("death", d)
	assert_eq(d.codex.enemies.morvath.phase, 3, "the highest phase stays")
	assert_eq(d.codex.arenas.hall.entered, 4)
	# and the save keeps the new section
	assert_eq(SaveData.merged(JSON.parse_string(JSON.stringify(d))).codex.arenas, d.codex.arenas)
	g.free()
