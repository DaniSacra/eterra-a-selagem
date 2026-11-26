extends GutTest
## E2 interface: "Bênção" in the player's text (QW-018, E2-03), the hero screen on the title (E2-06: HeroLoadout,
## CodexBook, HeroScreen), the Mastery on the end screen (E2-04: MasteryReport) and the small Compendium (E2-11:
## CodexScreen).

## XP at the start of a level (40 + 10 per level: 2 at 40, 3 at 90, 6 at 300, 8 at 490).
const XP_2 := 40
const XP_3 := 90
const XP_8 := 490
## B-2 and B-3 (balance.md B.5): the first ultimate at Mastery 6, Ímpeto at 2.
const XP_5 := 220
const XP_6 := 300


func _data(xp: int, equipped: Array = [], ult: String = "") -> Dictionary:
	var d := SaveData.defaults()
	var block := SaveData.hero(d, "warrior")
	block.mastery_xp = xp
	SaveData.open_revealed(block)  # a player who got there before the Memória (Rejogabilidade): every Gift opened
	block.equipped = equipped
	block.ultimate = ult
	d.runs = 6  # (SW-O5: the Ultimate's milestone, 6 descents)
	return d


func _loadout(xp: int, equipped: Array = []) -> HeroLoadout:
	return HeroLoadout.new(HeroDef.warrior(), _data(xp, equipped))


func _screen(data: Dictionary) -> HeroScreen:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(data, HeroScreen.Chapter.HERO)
	return s


# ---------- QW-018 / E2-03: Bênção ----------

func test_only_the_heros_gifts_say_dom_on_screen() -> void:
	var word := RegEx.create_from_string("(?i)\\bdons?\\b")
	# the hub's Árvore de Dons (HUB-01) and what a save keeps (save slots) are the hero's Gifts too
	var own: Array[String] = ["talent_", "hero_", "codex_", "dons_", "end_unlocked", "end_open_tree", "hub_tree", "hub_use_tree", "guide_tree", "guide_ult", "howto_interact", "hub_descend_line",
		"slots_lead", "slot_erase_line"]
	var found: Array[String] = []
	for key: String in T.table.entries:
		if word.search(String(T.table.entries[key])) == null:
			continue
		if own.any(func(p: String) -> bool: return key.begins_with(p)):
			continue
		found.append(key)
	assert_eq(found, [] as Array[String], "keys outside the hero's Gifts that still say dom: %s" % [found])


func test_the_blessing_screens_say_bencao() -> void:
	for key: StringName in [&"choice_title", &"choice_hint", &"reward_boon", &"end_gifts", &"pause_boons", &"boons_title",
			&"boons_none"]:
		assert_true(T.t(key).to_lower().contains("bênç"), "%s: %s" % [key, T.t(key)])
		assert_false(T.t(key).contains("—"))
	assert_eq(T.t(&"rarity_rare"), "Rara")
	assert_eq(T.t(&"rarity_epic"), "Épica")
	assert_eq(T.t(&"rarity_legendary"), "Lendária")


# ---------- HeroLoadout ----------

func test_level_and_devotion_come_from_the_xp() -> void:
	assert_eq(_loadout(0).level(), 1)
	assert_eq(_loadout(0).devotion(), 6)
	assert_eq(_loadout(XP_3).level(), 3)
	assert_eq(_loadout(XP_3).devotion(), 8)


func test_a_gift_goes_on_and_off_and_a_locked_one_never() -> void:
	var l := _loadout(0)
	assert_eq(l.state(l.book.find(&"disciplina")), HeroLoadout.State.OPEN)
	assert_true(l.toggle(&"disciplina"))
	assert_eq(l.equipped(), ["disciplina"])
	assert_eq(l.used(), 2)
	assert_eq(l.state(l.book.find(&"forca_concentrada")), HeroLoadout.State.LOCKED)
	assert_false(l.toggle(&"forca_concentrada"), "Força Concentrada opens at level 2")
	assert_eq(l.why(l.book.find(&"forca_concentrada")).key, &"hero_why_locked")
	assert_true(l.toggle(&"disciplina"))
	assert_eq(l.equipped(), [])


func test_why_tells_the_rule_that_refuses() -> void:
	var top := 2470
	var l := _loadout(top)
	# a Gift without the one it needs
	var why := l.why(l.book.find(&"cadencia"))
	assert_eq(why.key, &"hero_why_needs")
	assert_eq(why.args.what, T.t(&"talent_disciplina"))
	# an apex asks for the Gift the package names, not for a partner branch
	why = l.why(l.book.find(&"apogeu"))
	assert_eq(why.key, &"hero_why_needs")
	assert_eq(why.args.what, T.t(&"talent_maestria_marcial"))
	assert_true(l.toggle(&"disciplina"))
	assert_true(l.toggle(&"maestria_marcial"))
	assert_true(l.toggle(&"apogeu"))


func test_devotion_refuses_what_does_not_fit() -> void:
	var l := _loadout(0)
	assert_true(l.toggle(&"disciplina")) # 2 of 6
	l = _loadout(XP_3, ["disciplina", "forca_concentrada"]) # 4 of 8
	assert_eq(l.used(), 4)
	var ids := ["disciplina", "cadencia", "maestria_marcial", "forca_concentrada", "determinacao", "concentracao", "ruptura", "voz_do_leao", "imposicao"]
	var d := _loadout(2470, ids)
	assert_eq(d.used(), 22)
	assert_eq(d.devotion(), 25)
	var why := d.why(d.book.find(&"apogeu"))
	assert_eq(why.key, &"hero_why_devotion")
	assert_eq(why.args.free, 3)


func test_taking_an_entry_off_takes_what_needed_it() -> void:
	var l := _loadout(XP_8, ["disciplina", "cadencia"])
	assert_eq(l.equipped(), ["disciplina", "cadencia"])
	assert_true(l.toggle(&"disciplina"))
	assert_eq(l.equipped(), [], "Cadência needs Disciplina on")


func test_what_the_save_holds_is_cleaned_on_open() -> void:
	var l := _loadout(0, ["forca_concentrada", "nope", "disciplina"])
	assert_eq(l.equipped(), ["disciplina"])


func test_ultimates_open_by_level_and_one_is_chosen() -> void:
	var l := _loadout(0)
	var cleave := l.hero.ultimate(&"cleave")
	assert_false(l.ult_open(cleave))
	assert_false(l.choose_ult(&"cleave"))
	l = _loadout(XP_6)
	assert_true(l.choose_ult(&"cleave"), "the fixed one of the Emeth (the shim answers true for it)")
	assert_eq(l.ultimate(), &"cleave")
	assert_false(l.choose_ult(&"vortex"), "the Voragem is in reserve: no choice")
	l = _loadout(HeroDef.warrior().mastery.total_to(12))
	assert_false(l.choose_ult(&"vortex"))
	assert_eq(l.ultimate(), &"cleave")


func test_next_level_tells_what_it_brings() -> void:
	assert_eq(_loadout(0).next_unlocks(), [T.t(&"talent_forca_concentrada")] as Array[String])
	assert_eq(_loadout(HeroDef.warrior().mastery.total_to(2)).next_unlocks(), [T.t(&"talent_ruptura"), T.t(&"ult_cleave")] as Array[String])
	assert_eq(_loadout(2470).next_unlocks(), [] as Array[String])


# ---------- the screen ----------

func test_the_hint_names_the_keys_of_the_device_in_hand() -> void:
	var was := Controls.using_pad
	Controls.using_pad = false
	var s := _screen(_data(0))
	# the action bar at the foot (benchmark P0-2): the real key, live
	var accept := s.bar.item(&"ui_accept")
	assert_eq(accept.key_text(), UiKit.action_label(&"ui_accept"))
	Controls.using_pad = true
	assert_eq(accept.key_text(), UiKit.action_label(&"ui_accept"), "changes live")
	assert_eq(accept.key_text(), "A")
	Controls.using_pad = false
	assert_eq(accept.key_text(), UiKit.action_label(&"ui_accept"))
	Controls.using_pad = was


func test_every_text_of_the_screen_is_in_the_table() -> void:
	for key: StringName in [&"title_hero", &"hero_mastery", &"hero_devotion", &"hero_passive", &"hero_passive_desc",
			&"hero_ultimate", &"bar_equip", &"bar_open", &"hero_why_locked", &"hero_why_devotion", &"hero_why_slot",
			&"hero_why_needs", &"codex_title", &"end_level_up"]:
		assert_true(T.table.entries.has(String(key)), String(key))
		assert_false(T.t(key).contains("—"), String(key))
	for t in HeroDef.warrior().talents().catalog:
		assert_true(T.table.entries.has(String(t.name_key)) and T.table.entries.has(String(t.desc_key)), String(t.id))


# ---------- E2-04: the end screen ----------

func test_report_tells_the_sources_and_what_the_new_levels_unlocked() -> void:
	var gain := HeroDef.warrior().mastery.run_xp({"rooms": 4, "guardians": 1, "first_guardian": true})
	assert_eq(gain.total, 90)
	assert_eq(MasteryReport.sources_text(gain), "%s 40, %s 25, %s 25" % [T.t(&"mastery_src_rooms"),
		T.t(&"mastery_src_guardians"), T.t(&"mastery_src_first_guardian")])
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 1, 2), [T.t(&"end_unlocked", {"name": T.t(&"talent_forca_concentrada")})] as Array[String])
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 2, 3), [T.t(&"end_unlocked", {"name": T.t(&"talent_ruptura")}), T.t(&"end_unlocked_ult", {"name": T.t(&"ult_cleave")})] as Array[String])
	# several levels at once: one line each, the names joined
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 1, 4), [
		T.t(&"end_unlocked_many", {"name": ", ".join([T.t(&"talent_forca_concentrada"), T.t(&"talent_ruptura"), T.t(&"talent_cadencia")])}), T.t(&"end_unlocked_ult", {"name": T.t(&"ult_cleave")})] as Array[String])
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 9, 10), [T.t(&"end_unlocked_ult", {"name": T.t(&"ult_vortex")})] as Array[String])
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 3, 3), [] as Array[String])


func test_report_fills_the_bar_to_the_new_level() -> void:
	var gain := HeroDef.warrior().mastery.run_xp({"rooms": 4, "guardians": 1, "first_guardian": true})
	var r := MasteryReport.new().setup({"gain": gain, "xp_before": 10})
	add_child_autofree(r)
	assert_eq(r.bar.level(), 1)
	r.finish()
	assert_eq(r.bar.level(), 3)
	assert_eq(int(r.bar.xp), 100)
	var up := r.find_child("level_up", true, false) as Label
	assert_eq(up.text, T.t(&"end_level_up", {"n": 3}))
	assert_not_null(r.find_child("unlocked", true, false))


func test_end_screen_carries_the_mastery() -> void:
	var gain := HeroDef.warrior().mastery.run_xp({"rooms": 2})
	var stats := {"time": 100.0, "level": 0, "kills": 9, "best_combo": 4, "boons": 0,
		"mastery": {"gain": gain, "xp_before": 0}}
	for victory: bool in [false, true]:
		var end := EndScreen.new()
		add_child_autofree(end)
		end.open(victory, stats, false)
		var r := end.find_child("mastery", true, false) as MasteryReport
		assert_not_null(r, "victory %s" % victory)
		assert_null(r.find_child("level_up", true, false), "20 XP does not reach level 2")
	var plain := EndScreen.new()
	add_child_autofree(plain)
	stats.erase("mastery")
	plain.open(false, stats, false)
	assert_null(plain.find_child("mastery", true, false), "nothing without the run's Mastery")


# ---------- E2-11: the Compendium ----------

func test_codex_shows_reached_gifts_and_hides_the_rest() -> void:
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.GIFTS, _data(XP_3))
	var open_row := c.find_child("forca_concentrada", true, false)
	assert_eq((open_row.find_child("Name", false, false) as Label).text, T.t(&"talent_forca_concentrada"))
	var closed_row := c.find_child("cadencia", true, false)
	assert_eq((closed_row.find_child("Name", false, false) as Label).text, "???")
	assert_eq((closed_row.find_child("Desc", false, false) as Label).text, T.t(&"codex_locked", {"n": 4}))


func test_codex_tabs_switch_by_focus() -> void:
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.MOVES, _data(0))
	assert_eq(c.tab, CodexScreen.Tab.MOVES)
	assert_null(c.find_child("disciplina", true, false))
	c.tabs[0].grab_focus()
	assert_eq(c.tab, CodexScreen.Tab.GIFTS)
	assert_true(c.tabs[0].button_pressed)
	assert_false(c.tabs[1].button_pressed)


# ---------- the Warrior's page fits the sheet ----------

func _hero_page(size: Vector2) -> HeroScreen:
	var host := Control.new()
	host.custom_minimum_size = size
	host.size = size
	add_child_autofree(host)
	var s := HeroScreen.new()
	host.add_child(s)
	s.open(_data(0), HeroScreen.Chapter.HERO)
	return s


func _check_hero_page_fits(size: Vector2) -> void:
	var s := _hero_page(size)
	await wait_process_frames(4)
	var paper: Rect2 = s._book.paper_rect()
	paper.position += s._book.global_position
	var foot_top: float = size.y - ActionBar.RESERVE
	for id: String in ["to_gifts", "codex"]:
		var b: Control = s.find_child(id, true, false)
		assert_not_null(b, id)
		if b == null:
			continue
		var r := b.get_global_rect()
		assert_true(paper.encloses(r), "%s inside the sheet at %s: %s in %s" % [id, size, r, paper])
		assert_lt(r.end.y, foot_top, "%s above the key bar at %s" % [id, size])
	var gifts: Control = s.find_child("hero_right", true, false)
	var to_gifts: Control = s.find_child("to_gifts", true, false)
	assert_lte(gifts.get_global_rect().end.y, to_gifts.get_global_rect().position.y + 1.0, "the page's text above the foot row")


func test_the_warriors_page_fits_at_1280() -> void:
	await _check_hero_page_fits(Vector2(1280, 720))


func test_the_warriors_page_fits_at_1672() -> void:
	await _check_hero_page_fits(Vector2(1672, 941))
