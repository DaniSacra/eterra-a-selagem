extends GutTest
## C17, the text and HUD front (docs/backlog.md): one name for the special, "Onda de Luz" (QW-109, D-69); one word for
## each action (QW-110: Ataque, Especial, Círculo, Esquiva, Ultimate; never Leve/Pesado nor the letters E and D);
## Como Jogar with the rules of today (BUG-106); one rule for capitals (QW-118); whole numbers where the HUD shows
## whole ones (BUG-113); the HUD's row of gifts that stops with "+N" (BUG-105); greetings held under a screen
## (BUG-107); the chevrons clear of the ultimate's caption (BUG-111); the move's name going with the count (BUG-112);
## the Compendium and the Livro whole and at 14 px or more at 720 (QW-114); LB and RB through the tabs (DT-103).

## Small words that stay lower case inside a name in Title Case.
const SMALL := ["a", "o", "e", "de", "da", "do", "das", "dos", "em", "na", "no", "sem", "por", "com"]

var game: Game


func after_each() -> void:
	Dev._args.erase("boons")
	Dev.put("seed", "1")  # back to the seed of every test, never none (tests/hooks/pre_run.gd, BUG-109)


## Save data with the Warrior at this much XP (the screens read and never write it).
func _data(xp: int) -> Dictionary:
	var d := SaveData.defaults()
	SaveData.hero(d, "warrior").mastery_xp = xp
	return d


func _entries() -> Dictionary:
	return T.table.entries


# ---------- QW-109: Onda de Luz ----------

func test_no_arrow_of_light_in_the_players_text() -> void:
	var seta := RegEx.create_from_string("(?i)\\bseta\\b")
	for key: String in _entries():
		assert_null(seta.search(String(_entries()[key])), "%s says \"seta\": the special is a wave (D-69)" % key)


func test_every_move_of_the_special_is_the_wave() -> void:
	for path: String in ["res://data/combos/paladin.tres", "res://data/combos/paladin_fifth.tres"]:
		var tree: ComboTree = load(path)
		for m in tree.named_moves():
			var title := T.t((m.node as ComboNode).title)
			assert_false(title.to_lower().contains("seta"), "%s in %s" % [title, path])
	assert_eq(T.t(&"move_wave"), "Onda de Luz")
	assert_false(T.t(&"howto_heavy_attack_desc").to_lower().contains("seta"), "GP-1: the right button is the Corte Circular and the Lança")


# ---------- QW-110: one word for each action ----------

func test_one_word_for_each_action() -> void:
	# GP-1: the right button holds two (the touch is the Poder, the hold the Especial)
	var words := {&"light_attack": T.t(&"slot_attack"), &"heavy_attack": "%s e %s" % [T.t(&"slot_cast"), T.t(&"slot_special")], &"dodge": T.t(&"slot_dash")}
	for action: StringName in words:
		assert_eq(T.t("action_" + String(action)), words[action], "Controles names %s as the HUD" % action)
		assert_eq(T.t("howto_" + String(action)), words[action], "Como Jogar names %s as the HUD" % action)
	assert_eq(T.t(&"action_ultimate"), T.t(&"howto_ultimate"))


func test_no_light_heavy_nor_letters_for_the_actions() -> void:
	var bad := RegEx.create_from_string("(?i)\\b(golpes? leves?|golpes? pesados?)\\b|\\bLeve \\(|\\bPesado \\(|\\((E|D)\\)|\\b(E|D) segurado\\b|\\bE: ataque")
	for key: String in _entries():
		var text := String(_entries()[key])
		assert_null(bad.search(text), "%s: \"%s\"" % [key, text])
	# Avanço is the name of a Gift (Avanço Feroz), never of the dodge
	for key: String in _entries():
		if key != "talent_avanco_feroz":
			assert_false(String(_entries()[key]).begins_with("Avanço"), key)


func test_both_endings_say_descer_de_novo() -> void:
	assert_false(_entries().has("end_retry"), "one key for both endings")
	assert_eq(T.t(&"end_again"), "Descer de novo")


func test_the_compendium_moves_are_the_hud_marks() -> void:
	var codex := CodexScreen.new()
	add_child_autofree(codex)
	codex.open(CodexScreen.Tab.MOVES, _data(0))
	var keys := codex.find_children("Keys", "HBoxContainer", true, false)
	assert_gt(keys.size(), 0)
	for row: Node in keys:
		assert_gt(row.find_children("ActionMark", "", false, false).size(), 0, "each move with the HUD's marks")
		for l in row.find_children("*", "Label", true, false):
			assert_false((l as Label).text in ["E", "D"], "no letters for the actions")


# ---------- BUG-106: Como Jogar ----------

func test_how_to_play_tells_the_rules_of_today() -> void:
	var ult := T.t(&"howto_ultimate_desc")
	assert_false(ult.contains("escolhido antes"), "the first ultimate comes without a choice (T5)")
	assert_true(ult.contains("dano"), "it charges with the damage dealt and taken (T5)")
	assert_true(HowToScreen.STEPS.has("events"), "a step for the Provação and the Altar")
	assert_true(T.t(&"howto_step_events").contains("Provação") and T.t(&"howto_step_events").contains("Altar"))
	var screen := HowToScreen.new()
	add_child_autofree(screen)
	screen.open()
	assert_not_null(screen.find_child("step_events", true, false))


# ---------- QW-118: capitals ----------

func test_names_in_title_case_and_bencao_always_capital() -> void:
	var names: Array[String] = []
	for b in BoonState.load_catalog():
		names.append(T.t("boon_" + String(b.id)))
	for t in Trials.load_catalog():
		names.append(T.t(t.name_key))
	for name in names:
		var words := name.split(" ")
		for i in words.size():
			var w := words[i]
			if i > 0 and SMALL.has(w):
				continue
			assert_eq(w.left(1), w.left(1).to_upper(), "\"%s\" in Title Case" % name)
	var lower := RegEx.create_from_string("\\bbênçã(o|os)\\b")
	for key: String in _entries():
		assert_null(lower.search(String(_entries()[key])), "%s: Bênção is a word of the game, always capital" % key)


# ---------- BUG-113: whole numbers ----------

func test_whole_numbers_where_the_hud_shows_whole_ones() -> void:
	assert_eq(BoonMod.format(&"max_hp", 22.5), "23")
	assert_eq(BoonMod.format(&"freeze_time", 1.5), "1,5", "seconds keep their decimal")
	for b in BoonState.load_catalog():
		for mult in Boon.RARITY_MULT:
			for level in range(1, maxi(b.max_level, 1) + 1):
				for m in b.mods:
					if m.stat in BoonMod.WHOLE:
						assert_false(BoonMod.format(m.stat, m.at(level, mult)).contains(","), "%s %s" % [b.id, m.stat])
				if b.skill:
					assert_false(UiKit.whole(b.skill.damage_at(level, mult)).contains(","), "%s damage" % b.id)
	var trials := Trials.load_catalog()
	for t in trials:
		if t.mods.is_empty() or not t.mods[0].stat in BoonMod.WHOLE:
			continue
		for r in Boon.RARITY_MULT.size():
			assert_false(TrialSeal.value_text(t, r).contains(","), "%s at rarity %d" % [t.id, r])


# ---------- BUG-105, BUG-107, BUG-111, BUG-112: the HUD ----------

func test_the_gifts_row_stops_with_plus_n() -> void:
	var owned: Array[Boon] = []
	for b in BoonState.load_catalog():
		if b.slot == Boon.Slot.NONE:
			owned.append(b)
	var fit := 5
	var shown := Hud.passives_shown(owned, fit)
	assert_eq(shown.size(), fit - 1, "the last place says +N")
	assert_eq(Hud.passives_shown(owned, owned.size()).size(), owned.size(), "all of them when they fit")
	assert_eq(Hud.passive_fit(Hud.PASSIVE_ICON * 3 + Hud.PASSIVE_GAP * 2), 3)


func _run_with_boons(n: int) -> void:
	Dev._args["seed"] = "5"
	Dev._args["boons"] = str(n)
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.horde.clear_crowd()
	await wait_process_frames(4)


func test_with_25_blessings_the_row_stays_on_screen() -> void:
	await _run_with_boons(25)
	var row := game.hud.find_child("Passives", true, false) as HBoxContainer
	assert_not_null(row)
	var width := game.hud.get_viewport_rect().size.x
	var right := 0.0
	for c in row.get_children():
		right = maxf(right, (c as Control).get_global_rect().end.x)
	assert_lte(right, width * Hud.PASSIVE_EDGE + 0.5, "nothing past 96% of the width")
	var passives := game.boons.owned().filter(func(b: Boon) -> bool: return b.slot == Boon.Slot.NONE).size()
	if row.get_child_count() < passives:
		var more := row.find_child("More", false, false) as Label
		assert_not_null(more, "+N at the end")
		assert_eq(more.text, T.t(&"hud_more", {"n": passives - (row.get_child_count() - 1)}))


func test_the_row_and_greetings_wait_under_a_screen() -> void:
	await _run_with_boons(0)
	var banner := game.hud.banner()
	game.mode = Game.Mode.PAUSE
	await wait_process_frames(2)
	assert_false((game.hud.find_child("Passives", true, false) as Control).visible, "the row hides in the pause")
	var b: Boon = BoonState.load_catalog()[0]
	banner.show_boon(b)
	assert_false(banner.visible, "nothing over the pause")
	assert_eq(banner.waiting(), 1, "it waits its turn")
	game.mode = Game.Mode.PLAY
	await wait_process_frames(2)
	assert_eq(banner.showing, &"boon", "shown once the run is back")
	assert_true(banner.visible)


func test_a_greeting_showing_stands_still_under_a_screen() -> void:
	var banner := EloBanner.new()
	add_child_autofree(banner)
	banner.show_boon(BoonState.load_catalog()[0])
	banner._process(0.5)
	banner.held = true
	assert_false(banner.visible)
	banner._process(EloBanner.TIME * 2.0)
	assert_eq(banner.showing, &"boon", "its clock stands still")
	banner.held = false
	assert_true(banner.visible)


func test_the_chevrons_clear_the_ultimates_caption() -> void:
	await _run_with_boons(0)
	var view := game.hud.get_viewport_rect()
	# a chevron on the bottom edge, about its middle
	var chevron_bottom := view.size.y - game.hud.edge_bottom() + Hud.POINTER_SIZE * 0.5
	var row := game.hud._action_row
	var caption_top := row.get_global_rect().position.y - ActionSlot.CAPTION_RISE - ActionSlot.CAPTION_FONT
	assert_lt(chevron_bottom, caption_top, "the chevron stays above \"Maestria 2\"")


func test_the_moves_name_goes_with_the_count() -> void:
	await _run_with_boons(0)
	var hud := game.hud
	hud.on_combo(4)
	hud._move_t = Hud.MOVE_TIME
	hud.on_combo(0)
	assert_lte(hud._move_t, Hud.MOVE_FADE, "the name fades with the count")


func test_the_hud_small_text_is_14_px_or_more() -> void:
	assert_gte(ActionSlot.CAPTION_FONT, 14)
	assert_gte(ActionSlot.KEY_FONT, 14)


# ---------- QW-114: the Compendium and the Livro ----------

func _small_or_cut(root: Node) -> Array[String]:
	var out: Array[String] = []
	for n in root.find_children("*", "Label", true, false):
		var l := n as Label
		if l.text == "" or not l.is_visible_in_tree():
			continue
		if l.get_theme_font_size(&"font_size") < 14:
			out.append("%s (%d px)" % [l.text, l.get_theme_font_size(&"font_size")])
		if l.text_overrun_behavior != TextServer.OVERRUN_NO_TRIMMING or l.clip_text:
			out.append("%s (cut)" % l.text)
	return out


func test_the_compendium_is_whole_and_readable() -> void:
	var data := _data(99999)
	var codex := CodexScreen.new()
	add_child_autofree(codex)
	codex.open(CodexScreen.Tab.GIFTS, data)
	for t: int in CodexScreen.Tab.values():
		codex._show(t)
		assert_eq(_small_or_cut(codex), [] as Array[String], "tab %d" % t)


func test_the_book_is_readable() -> void:
	var screen := HeroScreen.new()
	add_child_autofree(screen)
	screen.open(_data(500))
	for c: int in HeroScreen.Chapter.values():
		screen._show(c)
		assert_eq(_small_or_cut(screen), [] as Array[String], "chapter %d" % c)


# ---------- DT-103: LB and RB through the tabs ----------

func _tab_key(screen: Control, next: bool) -> void:
	var e := InputEventAction.new()
	e.action = &"tab_next" if next else &"tab_prev"
	e.pressed = true
	screen._unhandled_input(e)


func test_lb_and_rb_step_through_the_tabs() -> void:
	assert_true(InputMap.has_action(&"tab_next") and InputMap.has_action(&"tab_prev"))
	var pad := InputMap.action_get_events(&"tab_next").filter(func(e: InputEvent) -> bool: return e is InputEventJoypadButton)
	assert_eq((pad[0] as InputEventJoypadButton).button_index, JOY_BUTTON_RIGHT_SHOULDER, "RB")
	var codex := CodexScreen.new()
	add_child_autofree(codex)
	codex.open(CodexScreen.Tab.GIFTS, _data(0))
	_tab_key(codex, true)
	assert_eq(codex.tab, CodexScreen.Tab.BOONS)
	_tab_key(codex, false)
	_tab_key(codex, false)
	assert_eq(codex.tab, CodexScreen.Tab.MOVES, "wraps round")
	var howto := HowToScreen.new()
	add_child_autofree(howto)
	howto.open()
	_tab_key(howto, true)
	assert_eq(howto.tab, HowToScreen.Tab.CONTROLS)
	var book := HeroScreen.new()
	add_child_autofree(book)
	book.open(_data(0))
	var before := book.chapter
	_tab_key(book, true)
	assert_eq(book.chapter, posmod(before + 1, HeroScreen.Chapter.size()))
	var options := OptionsScreen.new()
	add_child_autofree(options)
	options.open()
	var at := options.tab
	_tab_key(options, true)
	assert_eq(options.tab, posmod(at + 1, options.tabs.size()))


# ---------- QW-113: Juramentos and Músicas in the menus' page ----------

func test_juramentos_and_music_in_the_framed_page() -> void:
	var music := MusicRoomScreen.new()
	add_child_autofree(music)
	music.open()
	assert_not_null(music.find_child("page", true, false) as PanelContainer, "Músicas in the page")
	var vows := JuramentoScreen.new()
	add_child_autofree(vows)
	vows.open()
	assert_not_null(vows.find_child("page", true, false) as PanelContainer, "Juramentos in the page")
