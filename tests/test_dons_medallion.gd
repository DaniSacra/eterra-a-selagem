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
		# the Supremo is fixed to the weapon (redesign A.3): no ULT node for either hero
		var ults := 0
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


func test_places_go_from_the_centre_along_three_axes() -> void:
	var def := _def("warrior")
	assert_lt(def.position_of(def.find(&"crown")).distance_to(MedallionDef.CENTER), 0.5, "the crown is the medallion at the centre")
	# Combo up, Ímpeto bottom left, Domínio bottom right: entry by the centre, apex at the tip, two middles side by side
	for row: Array in [[&"disciplina", &"cadencia", &"maestria_marcial", &"apogeu", 0.0],
			[&"forca_concentrada", &"determinacao", &"concentracao", &"forca_titanica", 240.0],
			[&"ruptura", &"voz_do_leao", &"imposicao", &"investida_implacavel", 120.0]]:
		var ax: float = row[4]
		var entry := def.find(row[0])
		var apex := def.find(row[3])
		assert_almost_eq(entry.angle, ax, 0.01)
		assert_almost_eq(apex.angle, ax, 0.01)
		assert_lt(entry.radius, def.find(row[1]).radius, "the entry is nearest the centre")
		assert_lt(def.find(row[1]).radius, apex.radius, "the apex at the tip")
		assert_almost_eq(def.find(row[1]).radius, def.find(row[2]).radius, 0.01, "the middles side by side")
		assert_gt(apex.diameter, def.find(row[1]).diameter)
		assert_gt(def.find(row[1]).diameter, entry.diameter)


# ---------- the order of opening, from the centre ----------

func test_open_order_entry_then_a_middle_then_the_apex() -> void:
	var book := HeroDef.warrior().talents()
	var memory := 99
	assert_eq(book.open_problem(&"forca_concentrada", 20, [], memory), Talents.Problem.OK, "an entry opens first")
	assert_eq(book.open_problem(&"determinacao", 20, [], memory), Talents.Problem.PATH, "a middle waits for the entry")
	assert_eq(book.open_problem(&"forca_titanica", 20, [], memory), Talents.Problem.PATH, "the apex waits for a middle")
	assert_eq(book.open_problem(&"forca_titanica", 20, ["forca_concentrada"], memory), Talents.Problem.PATH, "the entry alone is not enough")
	assert_eq(book.open_problem(&"determinacao", 20, ["forca_concentrada"], memory), Talents.Problem.OK)
	assert_eq(book.open_problem(&"concentracao", 20, ["forca_concentrada"], memory), Talents.Problem.OK, "either middle")
	assert_eq(book.open_problem(&"forca_titanica", 20, ["forca_concentrada", "concentracao"], memory), Talents.Problem.OK, "one middle is enough")
	assert_eq(book.open_problem(&"forca_titanica", 20, ["determinacao"], memory), Talents.Problem.OK, "an older save opened out of order keeps the path")
	assert_eq(book.open_problem(&"ruptura", 20, [], memory), Talents.Problem.OK, "other branches do not wait for this one")
	assert_eq(book.open_problem(&"voz_do_leao", 20, ["forca_concentrada"], memory), Talents.Problem.PATH, "nor count for it")


func test_open_in_refuses_out_of_order_and_spends_nothing() -> void:
	var book := HeroDef.warrior().talents()
	var d := _data("warrior", XP_TOP, 20)
	assert_false(book.open_in(d, "warrior", &"investida_implacavel", 20))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.MEMORY), 20)
	assert_true(book.open_in(d, "warrior", &"ruptura", 20))
	assert_true(book.open_in(d, "warrior", &"imposicao", 20))
	assert_true(book.open_in(d, "warrior", &"investida_implacavel", 20))


func test_a_gift_open_out_of_order_stays_open_and_the_panel_names_what_is_missing() -> void:
	var d := _data("warrior", XP_TOP, 20)
	SaveData.hero(d, "warrior").opened = ["investida_implacavel"]
	var lo := HeroLoadout.new(HeroDef.warrior(), d)
	assert_true(lo.is_open(lo.book.find(&"investida_implacavel")), "kept")
	var imp := lo.book.find(&"imposicao")
	assert_eq(lo.can_open(imp), Talents.Problem.PATH)
	var why := lo.next_step(imp)
	assert_eq(why.key, &"dons_path_need")
	assert_string_contains(T.t(why.key, why.args), T.t(&"talent_ruptura"))
	var s := _screen("warrior", d)
	var info := s._gift_info(&"imposicao", s.view.def.find(&"imposicao"))
	assert_false(info.enabled, "no hold on a node out of order")
	assert_eq(info.reason, T.t(why.key, why.args))
	assert_false(T.t(why.key, why.args).contains("\u2014"))


func test_holding_a_gift_out_of_order_opens_nothing() -> void:
	var d := _data("warrior", XP_TOP, 20)
	var s := _screen("warrior", d)
	s.press(&"determinacao")
	assert_eq(s._hold_node, &"", "no hold starts")
	assert_eq(Talents.opened_of(SaveData.hero(d, "warrior")).size(), 0)


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
