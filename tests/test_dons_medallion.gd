extends GutTest
## The Gifts medallion (PT-12, docs/art/dons_medallion_spec.md): its data (one place for every Gift and ultimate of each
## hero, spaced as the spec asks), the pure parts (MedallionNav, HoldGauge) and DonsScreen's rules (the Livro's: toggle,
## open with Memória, choose an ultimate), the hold of a sealed Gift, and the save.

const HEROES: Array[String] = ["warrior", "maga"]
## Mastery 20 (the top) so every Gift is revealed; the test opens what it needs.
const XP_TOP := 3000


func _def(hero: String) -> MedallionDef:
	return MedallionDef.of(hero)


func _hero(id: String) -> HeroDef:
	return HeroDef.maga() if id == "maga" else HeroDef.warrior()


## A save with `xp` of Mastery for the hero and nothing opened or equipped, `memory` fragments in the purse.
func _data(hero: String, xp: int, memory: int = 0, wins: int = 1) -> Dictionary:
	var d := SaveData.defaults()
	var block := SaveData.hero(d, hero)
	block.mastery_xp = xp
	block.equipped = []
	block.opened = []
	d.wins = wins
	MaterialPurse.give(d, MaterialPurse.MEMORY, memory)
	return d


func _screen(hero: String, data: Dictionary) -> DonsScreen:
	var s := DonsScreen.new()
	add_child_autofree(s)
	s.open(data, hero)
	return s


# ---------- data ----------

func test_every_gift_and_ultimate_has_one_place() -> void:
	for h in HEROES:
		var def := _def(h)
		var hero := _hero(h)
		var ids := {}
		for n in def.nodes:
			assert_false(ids.has(n.id), "%s: %s twice" % [h, n.id])
			ids[n.id] = n
		for t in hero.talents().catalog:
			assert_true(ids.has(t.id), "%s: %s has no place" % [h, t.id])
		# the Warrior's Supremo is fixed (redesign A.3): no ULT nodes; the Maga's still has hers until GE-4
		var ults := hero.ultimates.size() if h == "maga" else 0
		if h == "maga":
			for u in hero.ultimates:
				assert_true(ids.has(u.id) and ids[u.id].kind == MedallionNodeDef.Kind.ULT, "%s: ultimate %s" % [h, u.id])
		assert_true(ids.has(MedallionDef.CROWN_ID))
		assert_eq(def.nodes.size(), hero.talents().catalog.size() + ults + 1, h)


func test_nodes_keep_their_distance() -> void:
	for h in HEROES:
		var def := _def(h)
		for i in def.nodes.size():
			for j in range(i + 1, def.nodes.size()):
				var a := def.nodes[i]
				var b := def.nodes[j]
				var need := 60.0 if (a.diameter > 50.0 or b.diameter > 50.0) else 52.0
				assert_gte(def.position_of(a).distance_to(def.position_of(b)), need - 0.5, "%s: %s and %s" % [h, a.id, b.id])


func test_nodes_clear_the_panel_and_the_screen() -> void:
	for h in HEROES:
		var def := _def(h)
		for n in def.nodes:
			var p := def.position_of(n)
			assert_lt(p.x + n.diameter * 0.5, DonsScreen.PANEL_AT.x, "%s under the panel" % n.id)
			assert_gt(p.x - n.diameter * 0.5, 0.0)
			assert_lt(p.y + n.diameter * 0.5, 720.0, "%s past the foot" % n.id)


func test_place_matches_the_spec_table() -> void:
	var def := _def("warrior")
	assert_lt(def.position_of(def.find(&"disciplina")).distance_to(MedallionDef.place(40.0, 254.0)), 1.5)
	assert_lt(def.position_of(def.find(&"crown")).distance_to(Vector2(620, 124)), 0.5)
	assert_lt(def.position_of(def.find(&"forca_titanica")).distance_to(MedallionDef.place(200.0, 254.0)), 1.5)


# ---------- the pure parts ----------

func test_nav_edges_follow_the_prerequisites() -> void:
	var def := _def("warrior")
	var nav := MedallionNav.new(def, HeroDef.warrior().talents().catalog)
	var edges := nav.edges()
	var pairs := {}
	for e: Array in edges:
		pairs["%s|%s" % [e[0], e[1]]] = true
	assert_true(pairs.has("cadencia|disciplina"), "the Middle runs to the Gift it needs")
	assert_true(pairs.has("apogeu|maestria_marcial"), "the Apex runs to the Gift it needs")
	assert_true(pairs.has("forca_titanica|forca_concentrada"), "an apex that needs the entry")
	assert_true(pairs.has("maestria_marcial|cadencia") or pairs.has("maestria_marcial|disciplina"), "a spur is tied to the ring")
	for e: Array in edges:
		assert_lte((nav.pos[e[0]] as Vector2).distance_to(nav.pos[e[1]]), 130.0, "no line runs far: %s %s" % [e[0], e[1]])


func test_nav_direction_goes_to_the_nearest_on_that_side() -> void:
	var nav := MedallionNav.new(_def("warrior"), HeroDef.warrior().talents().catalog)
	assert_eq(nav.neighbor(&"crown", Vector2.RIGHT), &"disciplina")
	assert_eq(nav.neighbor(&"crown", Vector2.LEFT), &"investida_implacavel")
	var down := nav.neighbor(&"crown", Vector2.DOWN)
	assert_ne(down, &"crown", "something is always found")
	assert_ne(nav.neighbor(&"imposicao", Vector2.RIGHT), &"imposicao", "from the spur the arrow goes on")


func test_nav_sector_step_walks_the_ring_and_wraps() -> void:
	var nav := MedallionNav.new(_def("warrior"), HeroDef.warrior().talents().catalog)
	var seen: Array[StringName] = []
	var at := &"crown"
	for i in 12:
		at = nav.sector_step(at, 1)
		if at == &"crown":
			break
		seen.append(at)
	assert_eq(seen[0], &"disciplina", "the first sector after the crown")
	assert_eq(nav.sector_step(seen[0], -1), &"crown", "and back")
	assert_eq(at, &"crown", "the walk wraps round to the crown")


func test_hold_gauge_fills_in_a_second_and_drains_when_let_go() -> void:
	var g := HoldGauge.new(1.0, 0.2)
	g.start()
	assert_false(g.step(0.5))
	assert_almost_eq(g.progress, 0.5, 0.001)
	g.cancel()
	g.step(0.1)
	assert_almost_eq(g.progress, 0.0, 0.001, "gone in 0.2 s at half: 0.1 s takes it to nothing")
	g.start()
	assert_false(g.step(0.9))
	assert_true(g.step(0.2), "full")
	assert_false(g.held)
	assert_eq(g.progress, 0.0)


# ---------- the screen ----------

func test_screen_opens_on_a_gift_that_can_go_on_and_says_what_each_counter_is() -> void:
	var s := _screen("warrior", _data("warrior", XP_TOP, 7))
	assert_eq(s.focus_id, &"disciplina", "the first Dom that can be equipped now")
	assert_eq(_screen("warrior", _data("warrior", 0)).focus_id, &"disciplina")
	assert_not_null(s.find_child("howto", true, false))
	assert_eq(s.find_child("notes", true, false).get_child_count(), 2, "one sentence for Devoção, one for Memória")
	assert_string_contains(s.find_child("howto", true, false).text, "Segure")
	var texts: Array[String] = s._counters.texts()
	assert_string_contains(texts[0], "Vagas")
	assert_false(texts[0].contains("Devoção"))
	assert_string_contains(texts[2], "7 ", "Memória, the second coin")
	s._focus(MedallionDef.CROWN_ID)
	assert_string_contains(s.panel._name.text, "Guerreiro")


func test_press_puts_a_gift_on_and_takes_it_off_and_writes_the_save() -> void:
	var d := _data("warrior", XP_TOP)
	var s := _screen("warrior", d)
	# Quarto Corte is open from the start (no Memória)
	s.press(&"disciplina")
	assert_true(s.loadout.is_equipped(&"disciplina"))
	assert_true(SaveData.hero(d, "warrior").equipped.has("disciplina"), "the save block holds it")
	s.press(&"disciplina")
	assert_false(s.loadout.is_equipped(&"disciplina"))
	assert_eq(SaveData.hero(d, "warrior").equipped, [], "taken off")


func test_a_sealed_gift_opens_only_after_holding_a_second() -> void:
	var d := _data("warrior", XP_TOP, 5)
	var s := _screen("warrior", d)
	var t := s.loadout.book.find(&"forca_concentrada")
	assert_eq(s.loadout.state(t), HeroLoadout.State.SEALED)
	s.press(&"forca_concentrada")
	s._process(0.6)
	s.release()
	s._process(0.5)
	assert_eq(s.loadout.state(t), HeroLoadout.State.SEALED, "let go before the end: nothing opens")
	assert_eq(s.loadout.memory(), 5)
	s.press(&"forca_concentrada")
	s._process(0.6)
	s._process(0.5)
	assert_ne(s.loadout.state(t), HeroLoadout.State.SEALED, "held to the end: open")
	assert_eq(s.loadout.memory(), 5 - t.memory_cost, "the Memória is spent once")
	assert_true(Talents.opened_of(SaveData.hero(d, "warrior")).has("forca_concentrada"), "and written")


func test_a_sealed_gift_without_memory_does_not_open() -> void:
	var s := _screen("warrior", _data("warrior", XP_TOP, 0))
	s.press(&"forca_concentrada")
	s._process(1.2)
	assert_eq(s.loadout.state(s.loadout.book.find(&"forca_concentrada")), HeroLoadout.State.SEALED)
	s._focus(&"forca_concentrada")
	assert_false(s.panel.verb_enabled())
	assert_string_contains(s.panel._verb.reason, "Faltam")


func test_panel_says_each_state_in_words() -> void:
	var d := _data("warrior", 90, 3)
	var s := _screen("warrior", d)
	s._focus(&"disciplina")
	assert_eq(s.panel.verb_text(), "Equipar")
	s.press(&"disciplina")
	assert_eq(s.panel.verb_text(), "Tirar")
	s._focus(&"forca_concentrada")
	assert_eq(s.panel.verb_text(), "Segure para abrir", "sealed")
	s._focus(&"apogeu")
	assert_false(s.panel.verb_enabled())
	assert_string_contains(s.panel._verb.reason, "Maestria 16", "locked says the level")
	assert_eq(s.view.state_of(&"apogeu"), HeroLoadout.State.LOCKED)


func test_a_blocked_gift_says_what_it_asks() -> void:
	var s := _screen("warrior", _data("warrior", XP_TOP, 20))
	s.loadout.open(&"cadencia")
	s._focus(&"cadencia")
	assert_eq(s.view.state_of(&"cadencia"), HeroLoadout.State.BLOCKED)
	assert_false(s.panel.verb_enabled())
	assert_string_contains(s.panel._verb.reason, "Pede")


func test_ultimates_are_chosen_on_the_crown() -> void:
	var d := _data("warrior", XP_TOP)
	var s := _screen("warrior", d)
	s.press(&"vortex")
	assert_eq(s.loadout.ultimate(), &"cleave", "redesign A.3: the weapon's ultimate is fixed, pressing the Voragem changes nothing")
	assert_eq(SaveData.hero(d, "warrior").ultimate, "")


func test_direction_input_moves_the_focus() -> void:
	var s := _screen("warrior", _data("warrior", XP_TOP))
	var ev := InputEventAction.new()
	ev.action = &"ui_right"
	ev.pressed = true
	var before := s.focus_id
	s._unhandled_input(ev)
	assert_ne(s.focus_id, before, "the arrow moves the focus")
	assert_ne(s.focus_id, &"vortex", "redesign A.3: no Supremo node to land on")


func test_the_other_hero_has_her_own_medallion() -> void:
	var d := _data("warrior", XP_TOP, 0, 1)
	var s := _screen("warrior", d)
	assert_eq(s.view.def.hero, &"warrior")
	s.swap_hero()
	assert_eq(s.hero_id, "maga")
	assert_eq(s.view.def.hero, &"maga")
	assert_eq(s.focus_id, s.first_focus())
	var locked := _screen("warrior", _data("warrior", XP_TOP, 0, 0))
	locked.swap_hero()
	assert_eq(locked.hero_id, "warrior", "the Maga stays behind Morvath's seal")


func test_the_short_line_cuts_on_a_word() -> void:
	assert_eq(DonsScreen.short_line("Cura 2 de vida. Mais texto."), "Cura 2 de vida")
	var cut := DonsScreen.short_line("Cada abate dá uma carga, até três, que some em 3 s sem abate: golpes mais rápidos")
	assert_true(cut.ends_with("...") and cut.length() <= MedallionView.CAPTION_MAX + 3, cut)


func test_text_of_the_screen_has_no_dash() -> void:
	for key: String in T.table.entries:
		if key.begins_with("dons_"):
			assert_false(String(T.table.entries[key]).contains("—"), key)
			assert_false(String(T.table.entries[key]).contains("–"), key)
