extends GutTest
## The Rejogabilidade's Fatia 1 on screen (sistemas.md 5.3; UI review d2ff05d, "Fatia 1"): the materials' marks and
## counts, the Forja da Emeth as a spread of the Livro, Abrir a Dom with Memória confirmed on its own page, the
## Encontro with the angels (and back to the pair from their cards), "Trazidos" on the end screen, the purse in the hub
## and the greeting of a material found.

var game: Game


func after_each() -> void:
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)
	Dev._args.erase("boons")
	DoorSign.keep_out = Rect2()


func _run(kind := RunMap.Kind.COMBAT) -> void:
	Dev._args["seed"] = "5"
	Dev._args["boons"] = "0"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(kind)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	await wait_process_frames(2)


func _data(xp_level: int, silver := 0, memory := 0) -> Dictionary:
	var d := SaveData.defaults()
	SaveData.hero(d, "warrior").mastery_xp = HeroDef.warrior().mastery.total_to(xp_level)
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	MaterialPurse.give(d, MaterialPurse.MEMORY, memory)
	return d


# ---------- the marks ----------

func test_silver_and_memory_have_their_marks_everywhere() -> void:
	assert_eq(DoorGlyph.of_reward(RunMap.Reward.SILVER), DoorGlyph.Kind.SILVER)
	assert_eq(DoorGlyph.of_reward(RunMap.Reward.MEMORY), DoorGlyph.Kind.MEMORY)
	assert_eq(DoorGlyph.of_material(MaterialPurse.SILVER), DoorGlyph.Kind.SILVER)
	assert_eq(DoorGlyph.of_material(MaterialPurse.MEMORY), DoorGlyph.Kind.MEMORY)
	var d := _data(1, 12, 3)
	var purse := MaterialCount.purse(d)
	add_child_autofree(purse)
	var counts := purse.get_children()
	assert_eq(counts.size(), 2)
	assert_eq((counts[0] as MaterialCount).number.text, "12")
	assert_eq((counts[1] as MaterialCount).number.text, "3")
	for c: MaterialCount in counts:
		assert_eq(c.number.get_theme_font(&"font"), UiKit.number_font(), "numbers never in Cinzel")
		assert_ne(c.mark.kind, DoorGlyph.Kind.NONE)


# ---------- the Forja ----------

func _forge(d: Dictionary) -> ForgeScreen:
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d)
	return f


func test_the_forge_is_a_spread_that_buys_in_order() -> void:
	var d := _data(1, 60)
	var f := _forge(d)
	assert_not_null(f.find_child("book", true, false) as BookSpread, "a spread of the Livro")
	for head in [&"hero_effect", &"hero_cost_head", &"hero_state_head", &"forge_step_head"]:
		assert_true(_texts(f).has(T.t(head).to_upper()), "the head %s" % head)
	assert_eq(f.shown.id, &"temper_1")
	var bought: Array[StringName] = []
	f.forged.connect(func(id: StringName) -> void: bought.append(id))
	assert_false(f.buy_button.disabled)
	f.buy_button.pressed.emit()
	assert_eq(Forge.temper(d), 1)
	assert_eq(bought, [&"temper_1"] as Array[StringName])
	assert_eq(f.shown.id, &"temper_2", "on to the next")
	assert_eq((f.entries[0].find_child("count", false, false) as Label).text, "", "forged: no price")
	assert_eq((f.entries[0].find_child("mark", false, false) as ForgeScreen.Mark).look, ForgeScreen.Mark.Look.OWNED)
	assert_false(f.buy_button.disabled, "45 of 35")
	f.buy_button.pressed.emit()
	assert_eq(Forge.temper(d), 2)
	# (Fatia 2: Temperar III next, 60 Prata; 10 left)
	assert_eq(f.shown.id, &"temper_3")
	assert_true(f.buy_button.disabled, "10 of 60")
	MaterialPurse.give(d, MaterialPurse.SILVER, 60)
	f._refresh()
	assert_false(f.buy_button.disabled, "70 of 60")
	f.buy_button.pressed.emit()
	assert_eq(Forge.temper(d), 3)
	assert_true((f.find_child("done", true, false) as Label).visible, "all forged")
	assert_false(T.t(&"forge_done").contains("versão"), "no prototype words")


func test_the_forge_says_what_is_missing() -> void:
	var f := _forge(_data(1, 5))
	assert_true(f.buy_button.disabled)
	assert_eq(f.buy_button.focus_mode, Control.FOCUS_NONE)
	var state := f.find_child("state", true, false) as Label
	assert_eq(state.text, T.t(&"forge_short", {"n": 10, "name": T.t(&"forge_temper_1")}))
	f._show(f.ranks[1])
	assert_eq(state.text, T.t(&"forge_state_needs", {"name": T.t(&"forge_temper_1")}))
	var purse := f.find_child("purse", true, false)
	assert_eq((purse.get_child(0) as MaterialCount).amount, 5)


func test_the_forjador_opens_the_forge() -> void:
	var saved := Save.data
	Save.data = _data(1, 20)
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	hub.use(HubPlan.SMITH)
	assert_true(hub.host.screen is ForgeScreen)
	hub.host.close()
	Save.data = saved


# ---------- Abrir a Dom with Memória ----------

func _book(d: Dictionary) -> HeroScreen:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(d, HeroScreen.Chapter.GIFTS)
	return s


func test_a_sealed_gift_opens_on_a_second_press_only() -> void:
	var d := _data(3, 0, 2)
	var s := _book(d)
	var impeto := s.loadout.book.find(&"impeto")
	assert_eq(s.loadout.state(impeto), HeroLoadout.State.SEALED)
	assert_eq(s.codex.entry(&"impeto").state, HeroLoadout.State.SEALED)
	s._tell(impeto)
	assert_eq(s.bar.item(&"ui_accept").verb.text, T.t(&"bar_open").to_upper(), "the bar says it opens with Memória")
	s._pick(impeto)
	assert_eq(s.arming, &"impeto", "the first press asks")
	assert_false(s.loadout.is_open(impeto))
	assert_eq((s.find_child("step", true, false) as Label).text, T.t(&"hero_open_confirm", {"cost": 2}))
	s._pick(impeto)
	assert_true(s.loadout.is_open(impeto), "the second opens it")
	assert_eq(s.loadout.memory(), 0)
	assert_false(s.loadout.is_equipped(&"impeto"), "opening never puts it on")
	s._pick(impeto)
	assert_true(s.loadout.is_equipped(&"impeto"), "then a press puts it on")


func test_the_question_goes_away_with_the_focus_or_the_time() -> void:
	var s := _book(_data(3, 0, 2))
	var impeto := s.loadout.book.find(&"impeto")
	s._pick(impeto)
	s._tell(s.loadout.book.find(&"quarto_corte"))
	assert_eq(s.arming, &"", "another Gift in focus")
	s._tell(impeto)
	s._pick(impeto)
	s._process(HeroScreen.CONFIRM_TIME + 0.1)
	assert_eq(s.arming, &"", "three seconds")
	s._pick(impeto)
	assert_false(s.loadout.is_open(impeto), "a new question, nothing opened")


func test_without_memory_the_gift_refuses_and_says_why() -> void:
	var s := _book(_data(3, 0, 1))
	var impeto := s.loadout.book.find(&"impeto")
	s._tell(impeto)
	s._pick(impeto)
	assert_eq(s.arming, &"")
	assert_false(s.loadout.is_open(impeto))
	assert_eq((s.find_child("step", true, false) as Label).text, T.t(&"hero_open_short", {"n": 1}))


func test_the_book_shows_the_purse() -> void:
	var s := _book(_data(1, 7, 4))
	var purse := s.find_child("purse", true, false)
	assert_not_null(purse)
	assert_eq((purse.get_child(1) as MaterialCount).amount, 4)


# ---------- the Encontro ----------

func _meeting() -> void:
	await _run()
	game.rooms.room.reward = RunMap.Reward.BOON
	Dev.put("angels", "sarael,nivael")
	game.rooms._room_cleared()
	game.rooms._collect()
	Dev.drop("angels")


func test_the_meeting_is_the_encounter_screen_with_two_seals() -> void:
	await _meeting()
	var meet := game._screen as EncounterScreen
	assert_not_null(meet, "the Encontro, not the provisional one")
	assert_false(game._screen is AngelChoice)
	assert_eq(meet.buttons.size(), 2)
	for b in meet.buttons:
		assert_not_null(b.find_child("seal", true, false) as AngelSeal)
		assert_not_null(b.find_child("held", true, false) as Label)
	await wait_process_frames(1)
	assert_true(meet.buttons[0].has_focus(), "the first in focus: one press")


func test_back_from_the_cards_to_the_same_pair() -> void:
	await _meeting()
	var meet := game._screen as EncounterScreen
	var pair := meet.angels.duplicate()
	meet._opened_at -= BoonChoice.GUARD_MS * 2
	meet.buttons[1].pressed.emit()
	var choice := game._screen as BoonChoice
	assert_not_null(choice, "the angel's cards")
	assert_eq(choice.angel, pair[1])
	assert_true(choice.back.is_valid())
	var first := game.offer_cards.map(func(c: BoonState.Card) -> StringName: return c.boon.id if c.boon else &"")
	choice.back.call()
	meet = game._screen as EncounterScreen
	assert_not_null(meet, "back to the pair")
	assert_eq(meet.angels, pair)
	await wait_process_frames(1)
	assert_true(meet.buttons[1].has_focus(), "the focus on the angel just seen")
	meet._opened_at -= BoonChoice.GUARD_MS * 2
	meet.buttons[1].pressed.emit()
	var again := game.offer_cards.map(func(c: BoonState.Card) -> StringName: return c.boon.id if c.boon else &"")
	assert_eq(again, first, "the same cards")
	assert_eq(game.encounters.meetings.size(), 1, "one meeting")


func test_the_angels_colours_keep_off_the_fights_own() -> void:
	var reserved: Array[float] = [350.0 / 360.0, 150.0 / 360.0, 180.0 / 360.0]  # danger red, the Emeth, the hero's petrol
	for f in [Boon.Family.CHAMA, Boon.Family.GEADA, Boon.Family.LUZ, Boon.Family.VIGILIA]:
		var c := AngelSeal.tint(f)
		for h in reserved:
			var d := absf(c.h - h)
			d = minf(d, 1.0 - d)
			assert_gt(d * 360.0, 20.0, "%s at hue %d" % [Boon.Family.keys()[f], roundi(c.h * 360.0)])


# ---------- the end, the hub, the greeting ----------

func test_the_end_says_what_was_brought() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 20.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 0,
		"materials": {"silver": 10, "memory": 3}}, false)
	var row := end.find_child("brought", true, false)
	assert_not_null(row)
	assert_eq(row.get_child_count(), 2)
	assert_eq((row.get_child(0) as MaterialCount).number.text, "10 " + T.t(&"material_silver_short"))
	var none := EndScreen.new()
	add_child_autofree(none)
	none.open(false, {"time": 20.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 0}, false)
	assert_null(none.find_child("brought", true, false), "nothing brought, nothing said")


func test_the_hub_shows_the_purse_and_hides_it_under_a_screen() -> void:
	var saved := Save.data
	Save.data = _data(1, 9, 2)
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	await wait_process_frames(2)
	var labels := hub.find_child("HubLabels", true, false) as HubLabels
	assert_true(labels.purse.visible)
	assert_eq((labels.purse.get_child(0).get_child(0) as MaterialCount).amount, 9)
	hub.use(HubPlan.SMITH)
	await wait_process_frames(1)
	assert_false(labels.purse.visible)
	hub.host.close()
	Save.data = saved


func test_a_material_greets_and_more_of_it_adds_up() -> void:
	var b := EloBanner.new()
	add_child_autofree(b)
	b.show_material(MaterialPurse.SILVER, 10)
	assert_eq(b.showing, &"material")
	b.show_material(MaterialPurse.SILVER, 2)
	var row := b.get_child(0) as MaterialCount
	assert_eq(row.number.text, "+12 " + T.t(&"material_silver_short"))
	b.show_material(MaterialPurse.MEMORY, 1)
	b.show_material(MaterialPurse.MEMORY, 2)
	assert_eq(b.waiting(), 1, "the Memória waits, summed")


## (Lote 2, H3: the greeting stands in the bottom right corner, CoinCorner, no longer in the banner at the top.)
func test_the_hud_greets_a_door_but_not_an_elites_drop() -> void:
	await _run(RunMap.Kind.FOUNTAIN)
	var banner: EloBanner = game.hud._elo_banner
	game.rooms.found(MaterialPurse.SILVER, &"elite", 1)
	await wait_process_frames(2)
	assert_eq(game.hud._coins.note_text(), "")
	game.rooms.found(MaterialPurse.SILVER, &"door", 10)
	await wait_process_frames(2)
	assert_eq(game.hud._coins.note_text(), "+10 %s" % T.t(&"material_silver_short"))
	assert_eq(banner.showing, &"", "nothing at the top")


static func _texts(n: Node) -> Array[String]:
	var out: Array[String] = []
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return out
