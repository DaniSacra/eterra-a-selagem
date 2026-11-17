extends GutTest
## E5 interface (docs/art/e5_spec.md 5.3, 6.3 and 7.1): the Provação's cards on a screen (the blessing with its rarity,
## the curse on its band with its length), opened by stepping before the block and taken by take_trial; the robot and
## --autopick take the first with no screen; the altar's trades on a small screen with a card that takes nothing, a
## trade out of reach dimmed; the seal in the HUD while a curse is carried, its turn and the "Provação vencida" greeting;
## the pictograms and second line of the doors' signs and the slab's "Vida insuficiente".

var game: Game


func before_each() -> void:
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev._args.erase("seed")
	Dev._args.erase("autopick")


func _run(kind: RunMap.Kind) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.horde.clear_crowd()
	game.rooms.start_at(kind)
	game.horde.clear_crowd()


func _labels(n: Node) -> Array[String]:
	var out: Array[String] = []
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return out


func _cards(n: int = 3) -> Array[Trials.Card]:
	var trials := Trials.new(Trials.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return trials.offers(rng, n, [0.5, 0.35, 0.15] as Array[float])


## Walks onto a spot and steps the rooms there.
func _step_on(at: Vector2) -> void:
	game.player.place(at)
	game.rooms.step(0.02)


# ---------- the Provação's cards ----------

func test_the_trial_card_shows_the_blessing_and_the_curse() -> void:
	var cards := _cards()
	var screen := EventChoice.new()
	add_child_autofree(screen)
	screen.open_trial(cards)
	assert_eq(screen.cards().size(), cards.size())
	for i in cards.size():
		var card := screen.cards()[i]
		var c := cards[i]
		assert_eq(card.trial, c)
		assert_eq(card.rarity, c.rarity as Boon.Rarity, "the blessing's rarity on the card")
		assert_eq(card.edge_color(), BoonCard.rarity_color(card.rarity), "and on its edge, as any card")
		assert_true(card.crest is TrialSeal, "the cracked diamond, no painted medallion")
		assert_eq((card.find_child("Name", true, false) as Label).text, T.t(c.blessing.name_key))
		assert_eq((card.find_child("Rarity", true, false) as Label).text, T.t(Boon.RARITY_KEY[c.rarity]))
		assert_eq((card.find_child("Blessing", true, false) as Label).text, TrialSeal.blessing_text(c))
		assert_not_null(card.find_child("CurseBand", true, false), "the curse on its own band")
		assert_eq((card.find_child("CurseName", true, false) as Label).text, T.t(c.curse.name_key))
		assert_eq((card.find_child("Curse", true, false) as Label).text, TrialSeal.curse_text(c))
		assert_eq((card.find_child("Encounters", true, false) as Label).text, T.t(&"trial_card_for", {"n": c.encounters}).to_upper())
		# T5: when each half comes, said on the card (the blessing only after the fights, then to the end)
		assert_eq((card.find_child("GainWhen", true, false) as Label).text, T.t(&"trial_gain_when", {"n": c.encounters}).to_upper())
		assert_true((card.find_child("GainWhen", true, false) as Label).text.contains(str(c.encounters)), "after how many fights")
		assert_eq((card.find_child("Keep", true, false) as Label).text, T.t(&"trial_gain_keep"))
		assert_eq(card.custom_minimum_size, BoonCard.TRIAL_SIZE)
	for text in _labels(screen):
		assert_false(text.contains("{"), "no key left unfilled: %s" % text)
		assert_false(text.contains("—"), "no dash in %s" % text)
	var lead := screen.find_child("Lead", true, false) as Label
	assert_not_null(lead, "a line under the title says the deal")
	assert_eq(lead.text, T.t(&"trial_hint"))
	assert_true(T.t(&"trial_pick_hint") in _labels(screen), "and under the cards that a card opens the doors")


func test_the_trial_card_tells_the_truth_about_when() -> void:
	# the blessing is not given when the card is taken: only when its fights are won (Rooms._fight_won)
	_run(RunMap.Kind.TRIAL)
	var rooms := game.rooms
	var before := game.boons.stat(&"max_hp")
	var i := -1
	for k in rooms.trial_cards.size():
		if rooms.trial_cards[k].blessing.id == &"trial_vigor":
			i = k
	if i < 0:
		pass_test("no Vigor in this draw")
		return
	rooms.take_trial(i)
	assert_eq(game.boons.stat(&"max_hp"), before, "nothing yet, as the card says")
	for f in rooms.trials.left:
		rooms._fight_won()
	assert_gt(game.boons.stat(&"max_hp"), before, "after the fights it is his")


func test_a_number_reads_as_the_player_reads_it() -> void:
	for c in _cards():
		assert_false(TrialSeal.blessing_text(c).contains("-"), "a blessing's number has no sign")
		assert_ne(TrialSeal.value_text(c.blessing, c.rarity), "")


func test_the_trial_screen_guards_and_picks() -> void:
	var screen := EventChoice.new()
	add_child_autofree(screen)
	screen.open_trial(_cards())
	watch_signals(screen)
	screen.cards()[2].pressed.emit()
	assert_signal_not_emitted(screen, "picked", "a button still held from the fight picks nothing")
	screen._opened_at -= BoonChoice.GUARD_MS * 2
	screen.cards()[2].pressed.emit()
	assert_signal_emitted_with_parameters(screen, "picked", [2])


func test_stepping_before_the_block_opens_the_cards() -> void:
	_run(RunMap.Kind.TRIAL)
	var rooms := game.rooms
	assert_eq(rooms.phase, Rooms.Phase.EVENT)
	assert_eq(game.mode, Game.Mode.PLAY, "nothing opens before he gets there")
	_step_on(Rooms.TRIAL_SPOT)
	assert_eq(game.mode, Game.Mode.CHOICE, "the screen stops the run")
	var screen := game._screen as EventChoice
	assert_not_null(screen)
	assert_eq(screen.cards().size(), rooms.trial_cards.size())
	var card := rooms.trial_cards[1]
	screen._opened_at -= BoonChoice.GUARD_MS * 2
	screen.cards()[1].pressed.emit()
	assert_eq(game.mode, Game.Mode.PLAY, "the run goes on")
	assert_eq(rooms.trials.active, card, "the card picked is taken")
	assert_eq(rooms.phase, Rooms.Phase.OPEN, "its doors open")
	_step_on(Rooms.TRIAL_SPOT + Vector2(3, 0))
	_step_on(Rooms.TRIAL_SPOT)
	assert_eq(game.mode, Game.Mode.PLAY, "nothing opens again")


func test_autopick_takes_the_first_card_with_no_screen() -> void:
	Dev._args["autopick"] = "1"
	_run(RunMap.Kind.TRIAL)
	var first := game.rooms.trial_cards[0]
	_step_on(Rooms.TRIAL_SPOT)
	assert_eq(game.mode, Game.Mode.PLAY)
	assert_null(game._screen)
	assert_eq(game.rooms.trials.active, first)


# ---------- the seal and the turn ----------

func test_the_seal_counts_the_fights_and_turns() -> void:
	_run(RunMap.Kind.TRIAL)
	var rooms := game.rooms
	var seal := game.hud.trial_seal()
	assert_eq(seal.left, 0)
	rooms.take_trial(0)
	var card := rooms.trials.active
	await wait_process_frames(3)
	assert_eq(seal.left, card.encounters, "the fights left inside the seal")
	assert_eq(seal.curse_name, T.t(card.curse.name_key), "the curse's name beside it")
	rooms._fight_won()
	await wait_process_frames(3)
	assert_eq(seal.left, card.encounters - 1)
	for i in card.encounters - 1:
		rooms._fight_won()
	assert_true(seal.turning(), "the crack fills with gold")
	assert_eq(game.hud.banner().showing, &"trial", "Provação vencida from the top")
	assert_true(T.t(&"notice_trial_won") in _labels(game.hud.banner()))
	assert_eq(game.mode, Game.Mode.PLAY, "the greeting never stops the run")
	await wait_seconds(TrialSeal.TURN_FILL + 0.1)
	assert_almost_eq(seal.gold, 1.0, 0.01)


func test_the_seal_is_not_morvaths_curse() -> void:
	assert_ne(TrialSeal.LILAC, Hud.CURSE_COLOR, "its own grey lilac")
	var lilac := TrialSeal.LILAC
	assert_lt(lilac.s, 0.35, "grey lilac, not the saturated violet of Morvath")


# ---------- the altar ----------

func test_the_altar_screen_has_a_way_out_and_dims_what_is_out_of_reach() -> void:
	var stage: StageDef = load(Rooms.STAGE)
	var opts := Altar.options(stage, 0, 30.0, true)
	var screen := EventChoice.new()
	add_child_autofree(screen)
	screen.open_altar(opts)
	var cards := screen.cards()
	assert_eq(cards.size(), opts.size() + 1, "a last card takes nothing")
	assert_eq(cards.back().altar, &"none")
	var candles := cards[Altar.Option.CANDLES]
	assert_true(candles.disabled, "no gold: the candles cannot be lit")
	assert_eq(candles.focus_mode, Control.FOCUS_NONE)
	var why := candles.find_child("Cannot", true, false) as Label
	assert_not_null(why, "and it says why")
	assert_eq(why.text, T.t(&"altar_why_gold", {"n": stage.altar_gold_cost}), "how much gold is missing")
	for c in cards:
		assert_eq(c.custom_minimum_size, BoonCard.ALTAR_SIZE, "smaller than a Blessing's card")
		assert_lt(c.custom_minimum_size.y, BoonCard.SIZE.y)
	assert_eq((screen.find_child("Lead", true, false) as Label).text, T.t(&"altar_lead"))
	watch_signals(screen)
	screen._opened_at -= BoonChoice.GUARD_MS * 2
	cards.back().pressed.emit()
	assert_signal_emitted_with_parameters(screen, "picked", [EventChoice.NONE])


func test_the_altar_cards_say_what_is_given_and_got() -> void:
	var stage: StageDef = load(Rooms.STAGE)
	var screen := EventChoice.new()
	add_child_autofree(screen)
	screen.open_altar(Altar.options(stage, 120, 30.0, true, 50.0))
	var cards := screen.cards()
	var life := cards[Altar.Option.LIFE]
	assert_eq((life.find_child("GiveHead", true, false) as Label).text, T.t(&"altar_give").to_upper())
	assert_eq((life.find_child("GetHead", true, false) as Label).text, T.t(&"altar_get").to_upper())
	assert_eq((life.find_child("Give", true, false) as Label).text, T.t(&"altar_life_give", {"n": "10"}))
	assert_eq((life.find_child("GiveDetail", true, false) as Label).text,
		T.t(&"altar_life_give_detail", {"from": "30", "to": "20"}), "the most life now and after")
	assert_eq((life.find_child("Get", true, false) as Label).text, T.t(&"altar_life_get"))
	var candles := cards[Altar.Option.CANDLES]
	assert_eq((candles.find_child("GiveDetail", true, false) as Label).text,
		T.t(&"altar_candles_give_detail", {"from": "120", "to": "45"}))
	assert_eq((candles.find_child("GetDetail", true, false) as Label).text,
		T.t(&"altar_candles_get_detail", {"from": "50", "to": "75"}))
	var none: BoonCard = cards.back()
	assert_eq((none.find_child("Give", true, false) as Label).text, T.t(&"altar_nothing"), "walking on gives nothing")
	assert_eq((none.find_child("Get", true, false) as Label).text, T.t(&"altar_nothing"))
	for text in _labels(screen):
		assert_false(text.contains("{"), "no key left unfilled: %s" % text)
		assert_false(text.contains("—"), "no dash in %s" % text)


func test_the_altar_says_why_a_trade_is_out_of_reach() -> void:
	var stage: StageDef = load(Rooms.STAGE)
	assert_eq(Altar.options(stage, 0, 30.0, false)[Altar.Option.LIFE].why, &"altar_why_grow")
	assert_eq(Altar.options(stage, 0, Altar.MIN_LIFE + stage.altar_life_cost - 1, true)[Altar.Option.LIFE].why, &"altar_why_life")
	assert_eq(Altar.options(stage, 500, 30.0, true)[Altar.Option.LIFE].why, &"")
	assert_eq(Altar.options(stage, 500, 30.0, true)[Altar.Option.CANDLES].why, &"")
	assert_eq(Altar.options(stage, 30, 30.0, true)[Altar.Option.CANDLES].short, stage.altar_gold_cost - 30)
	assert_eq(BoonCard.num(22.5), "22,5")
	assert_eq(BoonCard.num(30.0), "30")


func test_the_altar_in_a_real_room() -> void:
	_run(RunMap.Kind.ALTAR)
	var rooms := game.rooms
	rooms.gold = 200
	_step_on(Rooms.ALTAR_SPOT)
	var screen := game._screen as EventChoice
	assert_not_null(screen, "the slab before the step opens the trades")
	screen._opened_at -= BoonChoice.GUARD_MS * 2
	screen.cards().back().pressed.emit()
	assert_eq(game.mode, Game.Mode.PLAY, "nothing taken, the run goes on")
	assert_eq(rooms.gold, 200)
	rooms.step(0.02)
	assert_eq(game.mode, Game.Mode.PLAY, "standing there does not open it again")
	_step_on(Rooms.ALTAR_SPOT + Vector2(4, 0))
	_step_on(Rooms.ALTAR_SPOT)
	screen = game._screen as EventChoice
	assert_not_null(screen, "stepping back on opens it again")
	watch_signals(rooms)
	screen._opened_at -= BoonChoice.GUARD_MS * 2
	screen.cards()[Altar.Option.CANDLES].pressed.emit()
	assert_eq(rooms.gold, 200 - rooms.stage.altar_gold_cost)
	assert_signal_emitted_with_parameters(rooms, "altar_used", [&"candles"])


# ---------- the doors' signs ----------

func test_each_room_has_its_pictogram() -> void:
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.COMBAT, "hard": false}), DoorGlyph.Kind.NONE, "a common fight: none")
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.COMBAT, "hard": true}), DoorGlyph.Kind.HARD)
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.MINIBOSS, "guardian": true}), DoorGlyph.Kind.GUARDIAN)
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.BOSS}), DoorGlyph.Kind.BOSS)
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.FOUNTAIN}), DoorGlyph.Kind.FOUNTAIN)
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.SHOP}), DoorGlyph.Kind.SHOP)
	assert_eq(DoorGlyph.of({"kind": RunMap.Kind.ALTAR}), DoorGlyph.Kind.ALTAR)
	assert_eq(DoorGlyph.of({}), DoorGlyph.Kind.NONE)
	assert_eq(DoorGlyph.chevrons(DoorGlyph.Kind.HARD), 1)
	assert_eq(DoorGlyph.chevrons(DoorGlyph.Kind.GUARDIAN), 2)
	assert_eq(DoorGlyph.chevrons(DoorGlyph.Kind.BOSS), 3)


func test_the_sign_carries_the_pictogram_and_a_warning() -> void:
	var plain := DoorSign.make("Bênção")
	autofree(plain)
	assert_null(plain.mark, "no pictogram unless asked")
	var sign := DoorSign.make(T.t(&"room_trial"), T.t(&"trial_cost", {"n": 12}), DoorGlyph.Kind.TRIAL)
	autofree(sign)
	assert_not_null(sign.mark)
	assert_eq(sign.mark.kind, DoorGlyph.Kind.TRIAL)
	assert_eq(sign.mark.get_parent(), sign.title.get_parent(), "left of the name, on its line")
	sign.set_short(true, T.t(&"trial_short"), T.t(&"trial_cost", {"n": 12}))
	assert_eq(sign.detail.text, T.t(&"trial_short"))
	assert_eq(sign.detail.get_theme_color(&"font_color"), DoorSign.SHORT_COLOR)
	sign.set_short(false, T.t(&"trial_short"), T.t(&"trial_cost", {"n": 12}))
	assert_eq(sign.detail.text, T.t(&"trial_cost", {"n": 12}))
	for c: Color in [DoorGlyph.IVORY, DoorGlyph.CHEVRON_GOLD, TrialSeal.LILAC, DoorSign.GROUP_COLOR]:
		assert_gt(DoorSign.contrast(c, DoorSign.OUTLINE_COLOR), DoorSign.MIN_CONTRAST, "the pictogram reads on its outline")
	sign.add_note("a")
	sign.add_note("b")
	assert_eq(sign.note.text, "b", "one note, rewritten")
	assert_eq(sign.note.get_parent(), sign.detail.get_parent())


func test_the_slab_says_what_it_is_and_how_to_refuse() -> void:
	_run(RunMap.Kind.FOUNTAIN)
	var rooms := game.rooms
	rooms.stage = rooms.stage.duplicate()  # never the loaded stage the other tests read
	rooms.stage.trial_chance = 1.0
	rooms.trials.last_shown = -1000
	rooms.map.depth = 3
	rooms._roll_slab()
	assert_not_null(rooms.slab)
	var sign := rooms._slab_sign
	assert_eq(sign.detail.text, T.t(&"trial_cost", {"n": int(rooms.slab.cost)}))
	assert_not_null(sign.note)
	assert_true(sign.note.text.contains(T.t(&"trial_slab_offer")))
	assert_true(sign.note.text.contains(T.t(&"trial_slab_refuse")), "not stepping on it is refusing")


func test_the_altar_door_says_it_is_a_trade() -> void:
	var r := RunMap.Room.new(RunMap.Kind.ALTAR, RunMap.Reward.NONE, 3, -1)
	assert_eq(Rooms.door_text(r), T.t(&"room_altar") + "\n" + T.t(&"door_altar"))


func test_the_doors_wear_their_pictograms_in_a_run() -> void:
	_run(RunMap.Kind.FOUNTAIN)
	var rooms := game.rooms
	var found := 0
	for i in rooms.next_rooms.size():
		var want := DoorGlyph.of(rooms.door_info(i))
		var signs := rooms._door_labels[i].find_children("DoorSign", "", true, false)
		assert_eq(signs.size(), 1)
		var sign := signs[0] as DoorSign
		if want == DoorGlyph.Kind.NONE:
			assert_null(sign.mark)
		else:
			found += 1
			assert_eq(sign.mark.kind, want)
	assert_gt(rooms.next_rooms.size(), 0)


func test_the_new_words_are_in_the_text() -> void:
	for k in [&"trial_card_for", &"trial_title", &"trial_hint", &"trial_step", &"altar_none", &"altar_none_desc",
			&"altar_hint", &"altar_step", &"trial_slab_offer", &"trial_slab_refuse", &"trial_gain_when", &"trial_gain_keep",
			&"trial_pick_hint", &"trial_blessing_word", &"altar_lead", &"altar_give", &"altar_get", &"altar_nothing",
			&"altar_life_give", &"altar_life_give_detail", &"altar_life_get", &"altar_life_get_detail",
			&"altar_candles_give", &"altar_candles_give_detail", &"altar_candles_get", &"altar_candles_get_detail",
			&"altar_why_grow", &"altar_why_life", &"altar_why_gold", &"door_altar"]:
		assert_ne(T.t(k), String(k), "%s has its text" % k)
		assert_false(T.t(k).contains("—"), "no dash in %s" % k)
