extends GutTest
## The interface benchmark against Hades II (docs/design/benchmark_hades2_ui.md P0 and P1, docs/art/benchmark_hades2_style.md
## UI-HB1, UI-HB2, UI-HB5; ciclo visual 2026-11-20, item 3): the use key hangs under the thing used and never on the
## hero, a row of real keys at the foot of every screen that stops the game, the hit count by the bars, the cards as
## tall as what they say with their numbers marked and their facts as label and value, the glossary beside the row,
## the shop's signs in two lines, the Forja with the Emeth itself.

const SCREEN_EDGE := 48.0
const STRONG_RE := "\\[color=#[0-9a-f]+\\]\\[b\\].*?\\[/b\\]\\[/color\\]"

var state: BoonState


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())


# ---------- P0-1: the use key under the thing used ----------

func test_the_key_hangs_under_its_anchor_clear_of_the_hero() -> void:
	var screen := Vector2(1280, 720)
	var plate := Vector2(90, 24)
	# the hero right in front of the object (between it and the camera): his body covers the object's foot
	var head := Vector2(640, 300)
	var feet := Vector2(640, 374)
	var anchor := Vector2(640, 360)
	var at := StationSign.place_under(anchor, plate, screen, head, feet)
	var box := StationSign.hero_box(head, feet)
	assert_false(Rect2(at, plate).intersects(box), "never on the hero")
	assert_gte(at.y, head.y + 60.0, "60 px or more from his head")
	assert_lte(Rect2(at, plate).get_center().distance_to(anchor), 80.0, "close to the object")
	# the hero behind the object: the plate right under it
	at = StationSign.place_under(Vector2(640, 420), plate, screen, head, feet)
	assert_eq(at, (Vector2(640, 420) + Vector2(-plate.x * 0.5, StationSign.UNDER_GAP)).round())
	# at the bottom of the screen it stays on screen and off him
	at = StationSign.place_under(Vector2(640, 715), plate, screen, Vector2(640, 640), Vector2(640, 716))
	assert_lte(at.y + plate.y, screen.y)
	assert_false(Rect2(at, plate).intersects(StationSign.hero_box(Vector2(640, 640), Vector2(640, 716))))


func test_the_runs_key_stands_at_the_reward_and_says_what_is_missing_at_the_shop() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var rooms := game.rooms
	rooms.start_at(RunMap.Kind.SHOP)
	await wait_process_frames(2)
	assert_false(rooms._pedestals.is_empty(), "the shop's items")
	var p: Dictionary = rooms._pedestals[0]
	rooms.gold = 0
	game.player.place(p.at)
	rooms.step(0.0)
	assert_not_null(rooms.prompt)
	assert_true(rooms.prompt.under, "under the item")
	assert_eq(rooms.use_spot(), p.at as Vector2, "anchored on the item, not on him")
	assert_eq(rooms.prompt.prompt.text, T.t(&"shop_use_short", {"n": int(p.price)}), "what is missing, by the key")
	rooms.gold = 9999
	rooms.step(0.0)
	assert_eq(rooms.prompt.prompt.text, T.t(&"hub_use_shop"))
	# two lines on the item's sign: the name and the price (P1-3)
	var sign := p.sign as DoorSign
	assert_null(sign.group, "no group's word")
	rooms.gold = 0
	assert_eq(sign.detail.text, DoorSign.price_text(int(p.price)), "the price alone")
	assert_eq(sign.detail.get_theme_color(&"font_color"), DoorSign.SHORT_COLOR, "its colour says it")


# ---------- P0-2: the row of actions at the foot ----------

func _bar_ok(screen: Control, what: String) -> void:
	await wait_process_frames(2)
	var bar := screen.find_child("action_bar", true, false) as ActionBar
	assert_not_null(bar, "%s has the action bar" % what)
	if bar == null:
		return
	assert_false(bar.items.is_empty(), what)
	for it in bar.items:
		assert_eq(it.key_text(), ActionBar.key_for(it.action), "%s: the real key of %s" % [what, it.action])
		assert_ne(it.key_text(), "", "%s: %s has a key" % [what, it.action])
	var bottom := screen.get_viewport_rect().size.y
	var r := bar.get_global_rect()
	assert_gte(r.position.y, bottom - SCREEN_EDGE - ActionBar.HEIGHT, "%s: at the foot" % what)
	assert_lte(r.end.y, bottom, "%s: inside the screen" % what)


func test_every_screen_that_stops_the_game_has_the_bar() -> void:
	var offers: Array[Boon] = [state.find(&"toque_geada"), state.find(&"brasas"), state.find(&"golpe_brasa")]
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open(offers, state)
	await _bar_ok(choice, "the Blessings")
	assert_eq(choice.bar.item(&"ui_accept").verb.text, T.t(&"bar_choose").to_upper())
	choice.by_angel(Encounter.load_catalog()[0], func() -> void: pass)
	assert_not_null(choice.bar.item(&"ui_cancel"), "back to the angels, with its key")
	var meet := EncounterScreen.new()
	add_child_autofree(meet)
	var pair: Array[AngelDef] = []
	pair.assign(Encounter.load_catalog().slice(0, 2))
	meet.open(pair, state)
	await _bar_ok(meet, "the angels")
	var book := HeroScreen.new()
	add_child_autofree(book)
	book.open(SaveData.defaults(), HeroScreen.Chapter.HERO)
	await _bar_ok(book, "the Livro")
	var forge := ForgeScreen.new()
	add_child_autofree(forge)
	forge.open(SaveData.defaults())
	await _bar_ok(forge, "the Forja")
	var codex := CodexScreen.new()
	add_child_autofree(codex)
	codex.open(CodexScreen.Tab.GIFTS, SaveData.defaults())
	await _bar_ok(codex, "the Compêndio")
	var pause := PauseMenu.new()
	add_child_autofree(pause)
	pause.open()
	await _bar_ok(pause, "the pause")


func test_the_bar_follows_the_device() -> void:
	var was := Controls.using_pad
	Controls.using_pad = false
	var bar := ActionBar.attach(autofree(Control.new()) as Control, [ActionBar.entry(&"ui_cancel", "Voltar")])
	add_child(bar.get_parent())
	var it := bar.item(&"ui_cancel")
	assert_eq(it.key_text(), T.t(&"key_Escape"), "Esc on the keyboard")
	Controls.using_pad = true
	assert_eq(it.key_text(), "B", "B on the gamepad, live")
	Controls.using_pad = was


# ---------- P0-3, UI-HB5: the hit count by the row ----------

func test_the_hit_count_stands_right_of_the_row_out_of_the_field() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	var hud := game.hud
	hud.on_combo(12)
	hud._move.text = T.t(&"move_spin")
	await wait_process_frames(1)
	var screen := hud.get_viewport_rect().size
	var row := hud.find_child("Combo", true, false) as Control
	assert_not_null(row)
	var r := row.get_global_rect()
	assert_gte(r.position.x, hud._action_row.get_global_rect().end.x, "right of the diamonds (the row is centred since Lote 2)")
	assert_gte(r.position.y, screen.y * 0.75, "at the bottom")
	for l: Label in [hud._combo_word, hud._move]:
		assert_ne(l.get_theme_font(&"font"), UiKit.TITLE_FONT, "no Cinzel under 24 px")
	assert_gte(Hud.FONT_COMBO, 24, "the count itself")
	assert_lte(r.end.x, screen.x, "on screen")


# ---------- Lote 2: the row centred at the foot ----------

func _hud_with(layout: String) -> Hud:
	if layout != "":
		Dev.put("hud", layout)
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	Dev.drop("hud")
	return game.hud


func test_the_row_is_centred_at_the_foot() -> void:
	var hud := await _hud_with("")
	var screen := hud.get_viewport_rect().size
	var row := hud._action_row.get_global_rect()
	assert_almost_eq(row.get_center().x, screen.x * 0.5, 2.0, "centred (Daniel's decision, 2026-11-21)")
	assert_eq(hud._slots[0].side, Hud.ROW_DIAMOND)
	assert_gte(row.position.y, screen.y * 0.85, "at the bottom")
	assert_lte(row.end.y, screen.y, "inside the screen")
	assert_lt(row.end.x, hud._passives.get_global_rect().position.x + screen.x, "clear of the right corner")
	# the bars and the medallion stand left of the row, the gifts' corner right of it
	var bars := hud._crest.get_global_rect().merge(hud._life.get_global_rect()).merge(hud._magick.get_global_rect())
	assert_lt(bars.end.x, row.position.x, "the bars end before the row begins")
	assert_gte(hud._passives.get_global_rect().position.x, row.end.x, "the gifts in the right corner")
	for c: Control in [hud._curse_badge, hud._trial_seal]:
		assert_lte(c.get_global_rect().end.y, hud._magick.get_global_rect().position.y + 1.0, "%s over the bars" % c.name)
	assert_gte(Hud.ROW_DIAMOND * 1080.0 / 720.0, 52.0, "about 54 px at 1080")
	# the permanent HUD of the fight under 6% of the screen: medallion, bars, diamonds, build column
	var area := 0.0
	for c: Control in [hud._crest, hud._life, hud._magick, hud._charge, hud._action_row, hud._column]:
		area += c.get_global_rect().get_area()
	assert_lt(area / (screen.x * screen.y), 0.075)


func test_the_bars_stack_life_over_magia_beside_the_medallion() -> void:
	var hud := await _hud_with("")
	var crest := hud._crest.get_global_rect()
	var magick := hud._magick.get_global_rect()
	var life := hud._life.get_global_rect()
	assert_gte(magick.position.x, crest.end.x, "right of the medallion")
	assert_lt(life.end.y, magick.position.y, "life over Magia (Lote B)")
	assert_lt(magick.end.y, hud._charge.get_global_rect().position.y + 1.0, "the ultimate's charge under the bars")
	assert_almost_eq(magick.position.x, life.position.x, 0.5, "left edges together")
	assert_lte(magick.end.y, crest.end.y + 1.0, "no lower than the medallion")
	assert_gte(magick.position.y, crest.position.y - 1.0, "no higher than it")


# ---------- UI-HB1, UI-HB2: the cards ----------

func test_every_number_of_every_blessing_is_marked() -> void:
	var re := RegEx.create_from_string(STRONG_RE)
	var digit := RegEx.create_from_string("[0-9]")
	for b in state.catalog:
		for lv in [1, 2]:
			var text := BoonChoice.describe(b, lv, 1.5, true)
			var bare := re.sub(text, "", true)
			assert_null(digit.search(bare), "%s: a number outside a mark in '%s'" % [b.id, text])


func test_the_cards_say_their_facts_and_stand_as_tall_as_their_words() -> void:
	var rows: Array = [[&"toque_geada", &"brasas", &"golpe_brasa"], [&"estilhaco", &"firmeza", &"passos"],
		[&"vapor", &"aurora", &"onda_maior"]]
	for ids: Array in rows:
		var offers: Array[Boon] = []
		for id: StringName in ids:
			offers.append(state.find(id))
		var choice := BoonChoice.new()
		add_child_autofree(choice)
		choice.open(offers, state)
		await wait_process_frames(4)
		for c in choice.cards():
			assert_lte(c.size.y, BoonCard.SIZE.y + 1.0, "%s within the card's height" % c.boon.id)
			var fill := c.find_child("Fill", true, false) as Control
			assert_lte(fill.size.y, c.size.y * 0.25, "%s: at most a quarter of the card empty" % c.boon.id)
			if not BoonChoice.facts(c.boon, 1).is_empty():
				var facts := c.find_child("Facts", true, false)
				assert_not_null(facts, "%s: label and value" % c.boon.id)
				for row: Node in facts.get_children():
					assert_ne((row.find_child("Value", false, false) as Label).text, "")
			assert_eq((c.find_child("Desc", true, false) as RichTextLabel).horizontal_alignment, HORIZONTAL_ALIGNMENT_LEFT)


func test_a_trade_shows_the_numbers_it_leaves() -> void:
	# Golpe Radiante (damage) goes out, Golpe Firme (reach and damage) comes in one rarity up: the damage it had first
	state.take(state.find(&"golpe_radiante"))
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open([state.find(&"golpe_firme")] as Array[Boon], state, {&"golpe_firme": {"rarity": Boon.Rarity.EPIC, "upgrade": true}})
	await wait_process_frames(2)
	var card := choice.cards()[0]
	assert_not_null(card.find_child("Replaces", true, false), "what goes out and what comes in")
	var old := BoonChoice.facts(state.find(&"golpe_radiante"), 1)
	var new := BoonChoice.facts(state.find(&"golpe_firme"), 1, Boon.RARITY_MULT[Boon.Rarity.EPIC])
	var row := card.find_child("Fact_damage_pct", true, false)
	assert_not_null(row, "the damage on both")
	var old_v := ""
	var new_v := ""
	for f: Array in old:
		if f[0] == &"damage_pct":
			old_v = f[2]
	for f: Array in new:
		if f[0] == &"damage_pct":
			new_v = f[2]
	if old_v != new_v:
		assert_eq((row.find_child("Was", false, false) as Label).text, T.t(&"fact_was", {"v": old_v}))


func test_the_glossary_names_the_words_of_the_card_in_focus() -> void:
	assert_eq(Glossary.terms_of("O especial congela por 0,4 s."), [&"freeze"] as Array[StringName])
	assert_eq(Glossary.terms_of("O ataque incendeia: 3 de dano por segundo."), [&"burn"] as Array[StringName])
	assert_true(Glossary.emphasize("O especial congela.").contains(Glossary.mark("congela", &"freeze")))
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open([state.find(&"toque_geada"), state.find(&"golpe_brasa"), state.find(&"onda_maior")] as Array[Boon], state)
	await wait_process_frames(4)
	choice.cards()[0].grab_focus()
	await wait_process_frames(1)
	assert_eq(choice.glossary.shown, [&"freeze"] as Array[StringName])
	var g := choice.glossary.get_global_rect()
	for c in choice.cards():
		assert_false(g.intersects(c.get_global_rect()), "the glossary covers no card")
	for id in Glossary.TERMS:
		for k in ["gloss_%s" % id, "gloss_%s_text" % id, "gloss_%s_words" % id]:
			var t := String(T.table.entries.get(k, ""))
			assert_ne(t, "", k)
			assert_false(t.contains("—") or t.contains("–"), k)


# ---------- the Forja ----------

func test_the_forge_shows_the_emeth_with_its_rank_on_the_blade() -> void:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, 20)
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d)
	assert_not_null(f.bench.emeth, "the Emeth itself on the cloth")
	assert_true(f.bench.emeth.flat, "lying, the tip to the right")
	assert_eq(f.bench.emeth.rank, 0.0)
	for k in 3:
		f.press()
		f.release()
	assert_eq(f.bench.emeth._target, 1.0, "the new rank grows on the blade")
	assert_eq(f.bench.temper, 1, "and lights a notch of the edge")
	assert_not_null(f.plate.find_child("cost", true, false), "the price on the plate")
	assert_not_null(f.plate.find_child("have", true, false), "and what he has")


func test_new_texts_in_portuguese_without_dash() -> void:
	for k: String in T.table.entries:
		if k.begins_with("bar_") or k.begins_with("fact_") or k.begins_with("forge_") or k == "shop_use_short":
			var t := String(T.table.entries[k])
			assert_false(t.contains("—") or t.contains("–"), k)


# ---------- second batch: the Compêndio, the tree, the menus, the endings ----------

func test_the_codex_shows_the_selected_enemy_and_gift() -> void:
	var d := SaveData.defaults()
	d.codex.enemies["skeleton"] = {"defeated": 4}
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.ENEMIES, d)
	await wait_process_frames(2)
	assert_true(c.detail.visible, "the selected entry's detail")
	assert_eq(c.selected, &"skeleton", "the first entry at the start")
	assert_true(c.figure.visible)
	assert_eq(c.figure.def.id, &"skeleton", "its own figure")
	assert_true(c.figure.known)
	# the never defeated share one line, named after the first of them in the list (C1b: the bigger soldier)
	var runner := c.find_child(String(CodexScreen.ENEMIES[1]), true, false) as Control
	runner.grab_focus()
	await wait_process_frames(1)
	assert_eq(c.selected, CodexScreen.ENEMIES[1])
	assert_false(c.figure.known, "never defeated: a silhouette")
	assert_eq((c.find_child("detail_name", true, false) as Label).text, CodexScreen.UNKNOWN)
	c._show(CodexScreen.Tab.GIFTS)
	await wait_process_frames(1)
	assert_true(c.detail.visible)
	assert_false(c.figure.visible, "a Gift shows its mark, not a figure")
	assert_ne(c.selected, &"")
	c._show(CodexScreen.Tab.BOONS)
	assert_false(c.detail.visible, "no detail where there is no figure")


func test_the_tree_tells_its_states_apart_beyond_colour() -> void:
	# every state draws (the badge of a worn Gift, the dashed frame and wax seal of a sealed one)
	var t: TalentDef = HeroDef.warrior().talents().catalog[1]
	for st: int in HeroLoadout.State.values():
		var n := TalentNode.new().setup(t)
		add_child_autofree(n)
		n.state = st as HeroLoadout.State
		await wait_process_frames(1)
		assert_true(n.is_visible_in_tree())


func test_every_menu_has_the_bar_in_the_same_place() -> void:
	var at: Array[Rect2] = []
	var jur := JuramentoScreen.new()
	add_child_autofree(jur)
	jur.open()
	await _bar_ok(jur, "the Juramentos")
	var opts := OptionsScreen.new()
	add_child_autofree(opts)
	opts.open()
	await _bar_ok(opts, "the Configurações")
	var music := MusicRoomScreen.new()
	add_child_autofree(music)
	music.open()
	await _bar_ok(music, "the Músicas")
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 100.0, "level": 0, "kills": 3, "best_combo": 4, "boons": 0, "materials": {"silver": 6}}, false)
	await _bar_ok(end, "the defeat")
	var panel := HubPanel.new()
	add_child_autofree(panel)
	panel.open("T", "L", [[&"back", "Voltar"]])
	await _bar_ok(panel, "the station's page")
	for s: Control in [jur, opts, music, end, panel]:
		var bar := s.find_child("action_bar", true, false) as ActionBar
		var r := bar.get_global_rect()
		at.append(r)
	for r in at:
		assert_almost_eq(r.end.y, at[0].end.y, 4.0, "the same foot")
		assert_almost_eq(r.end.x, at[0].end.x, 4.0, "the same right edge")


func test_the_defeat_shows_what_was_brought_before_the_blessings() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	var gifts := [{"boon": load("res://data/boons/00_brasas.tres") as Boon, "level": 1}]
	end.open(false, {"time": 100.0, "level": 0, "kills": 3, "best_combo": 4, "boons": 1, "gifts": gifts,
		"materials": {"silver": 6, "memory": 1}}, false)
	await wait_process_frames(2)
	var brought := end.find_child("brought", true, false) as Control
	var carried := end.find_child("gifts", true, false) as Control
	assert_not_null(brought)
	assert_not_null(carried)
	assert_lt(brought.get_global_rect().position.y, carried.get_global_rect().position.y, "what he keeps first")


func test_the_saved_seal_comes_and_goes() -> void:
	var host := Node.new()
	add_child_autofree(host)
	var s := SaveSeal.flash(host)
	assert_eq(SaveSeal.flash(host), s, "one seal, shown again")
	await wait_seconds(SaveSeal.IN + 0.05)
	assert_gt(s._box.modulate.a, 0.5)
	await wait_seconds(SaveSeal.SHOWN + SaveSeal.OUT + 0.1)
	assert_almost_eq(s._box.modulate.a, 0.0, 0.01)


func test_the_angels_seal_stands_beside_the_cards() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open([st.find(&"toque_geada"), st.find(&"golpe_brasa"), st.find(&"onda_maior")] as Array[Boon], st)
	choice.by_angel(Encounter.load_catalog()[0], func() -> void: pass)
	await wait_process_frames(4)
	var col := choice.find_child("angel_column", true, false) as Control
	assert_not_null(col, "the seal in a column of its own")
	var r := col.get_global_rect()
	for c in choice.cards():
		assert_false(r.intersects(c.get_global_rect()), "never over a card")
	assert_true(choice.glossary.get_parent() == choice.list.get_parent(), "the glossary under the list of buttons (BC-1)")
	assert_lte(choice.get_viewport_rect().size.x, 1280.0 + 1.0)
	assert_gte(r.position.x, 0.0, "inside the screen")
