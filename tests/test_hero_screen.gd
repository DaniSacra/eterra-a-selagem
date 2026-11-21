extends GutTest
## E2 interface: "Bênção" in the player's text (QW-018, E2-03), the hero screen on the title (E2-06: HeroLoadout,
## TalentTree, HeroScreen), the Mastery on the end screen (E2-04: MasteryReport) and the small Compendium (E2-11:
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
	return d


func _loadout(xp: int, equipped: Array = []) -> HeroLoadout:
	return HeroLoadout.new(HeroDef.warrior(), _data(xp, equipped))


func _screen(data: Dictionary) -> HeroScreen:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(data, HeroScreen.Chapter.GIFTS)
	return s


# ---------- QW-018 / E2-03: Bênção ----------

func test_only_the_heros_gifts_say_dom_on_screen() -> void:
	var word := RegEx.create_from_string("(?i)\\bdons?\\b")
	# the hub's Árvore de Dons (HUB-01) and what a save keeps (save slots) are the hero's Gifts too
	var own: Array[String] = ["talent_", "hero_", "codex_", "end_unlocked", "hub_tree", "hub_use_tree", "howto_interact", "hub_descend_line",
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
	assert_eq(l.state(l.book.find(&"quarto_corte")), HeroLoadout.State.OPEN)
	assert_true(l.toggle(&"quarto_corte"))
	assert_eq(l.equipped(), ["quarto_corte"])
	assert_eq(l.used(), 3)
	assert_eq(l.state(l.book.find(&"impeto")), HeroLoadout.State.LOCKED)
	assert_false(l.toggle(&"impeto"), "Ímpeto opens at level 2")
	assert_eq(l.why(l.book.find(&"impeto")).key, &"hero_why_locked")
	assert_true(l.toggle(&"quarto_corte"))
	assert_eq(l.equipped(), [])


func test_why_tells_the_rule_that_refuses() -> void:
	var top := 2470
	var l := _loadout(top)
	# a middle without its entry
	var why := l.why(l.book.find(&"passo_encadeado"))
	assert_eq(why.key, &"hero_why_needs")
	assert_eq(why.args.what, T.t(&"talent_quarto_corte"))
	# a bridge without both entries
	assert_eq(l.why(l.book.find(&"investida")).key, &"hero_why_bridge")
	# an apex: its middle and a Gift of the partner branch
	assert_eq(l.why(l.book.find(&"golpe_sem_fim")).key, &"hero_why_apex")
	# one Gift per action: the dash
	assert_true(l.toggle(&"quarto_corte"))
	assert_true(l.toggle(&"passo_encadeado"))
	assert_true(l.toggle(&"corte_crescente"))
	var slot := l.why(l.book.find(&"fio_do_passo"))
	assert_eq(slot.key, &"hero_why_slot")
	assert_eq(slot.args.name, T.t(&"talent_passo_encadeado"))


func test_devotion_refuses_what_does_not_fit() -> void:
	var l := _loadout(0)
	assert_true(l.toggle(&"quarto_corte")) # 3 of 6
	l = _loadout(XP_3, ["quarto_corte", "impeto"]) # 5 of 8
	assert_eq(l.used(), 5)
	var d := _loadout(XP_8, ["quarto_corte", "impeto", "corte_crescente", "lamina_faminta", "passo_encadeado"])
	assert_eq(d.used(), 12)
	assert_eq(d.devotion(), 13)
	var why := d.why(d.book.find(&"avanco_feroz"))
	assert_eq(why.key, &"hero_why_devotion")
	assert_eq(why.args.free, 1)


func test_taking_an_entry_off_takes_what_needed_it() -> void:
	var l := _loadout(XP_8, ["quarto_corte", "passo_encadeado"])
	assert_eq(l.equipped(), ["quarto_corte", "passo_encadeado"])
	assert_true(l.toggle(&"quarto_corte"))
	assert_eq(l.equipped(), [], "Passo Encadeado needs Quarto Corte on")


func test_what_the_save_holds_is_cleaned_on_open() -> void:
	var l := _loadout(0, ["impeto", "nope", "quarto_corte"])
	assert_eq(l.equipped(), ["quarto_corte"])


func test_ultimates_open_by_level_and_one_is_chosen() -> void:
	var l := _loadout(0)
	var cleave := l.hero.ultimate(&"cleave")
	assert_false(l.ult_open(cleave))
	assert_false(l.choose_ult(&"cleave"))
	l = _loadout(XP_6)
	assert_true(l.choose_ult(&"cleave"))
	assert_eq(l.block.ultimate, "cleave")
	assert_false(l.choose_ult(&"vortex"), "the Voragem opens at level 10")


func test_next_level_tells_what_it_brings() -> void:
	assert_eq(_loadout(0).next_unlocks(), [T.t(&"talent_impeto")] as Array[String])
	assert_eq(_loadout(XP_5).next_unlocks(), [T.t(&"ult_cleave")] as Array[String])
	assert_eq(_loadout(2470).next_unlocks(), [] as Array[String])


# ---------- the screen ----------

func test_the_screen_shows_every_gift_and_the_two_ultimates() -> void:
	var s := _screen(_data(0))
	assert_eq(s.tree.nodes.size(), HeroDef.warrior().talents().catalog.size())
	assert_eq(s.ults.size(), 2)
	assert_eq(s.tree.node(&"impeto").state, HeroLoadout.State.LOCKED)
	assert_eq(s.tree.node(&"quarto_corte").state, HeroLoadout.State.OPEN)
	assert_false(s.ults[0].open)
	await wait_process_frames(2)
	var focus := get_viewport().gui_get_focus_owner()
	assert_eq(focus, s.tree.node(&"quarto_corte"), "the focus starts on the Gift that can go on")


func test_pressing_a_node_equips_it_in_the_save_data() -> void:
	var d := _data(XP_3)
	var s := _screen(d)
	s.tree.node(&"quarto_corte").pressed.emit()
	assert_eq(SaveData.hero(d, "warrior").equipped, ["quarto_corte"])
	assert_eq(s.tree.node(&"quarto_corte").state, HeroLoadout.State.EQUIPPED)
	var count := s.find_child("devotion", true, false) as Label
	assert_eq(count.text, T.t(&"hero_devotion_count", {"used": 3, "max": 8}))
	s.tree.node(&"quarto_corte").pressed.emit()
	assert_eq(SaveData.hero(d, "warrior").equipped, [])


## QA of E2: a Gift worn and a Gift only open read apart at a glance (filled, emerald line, glow against an outline),
## and Combo has a colour of its own (it was a grey that read as switched off).
func test_worn_and_open_gifts_look_apart() -> void:
	var s := _screen(_data(XP_8, ["quarto_corte"]))
	var worn := s.tree.node(&"quarto_corte")
	var open := s.tree.node(&"impeto")
	assert_eq(worn.state, HeroLoadout.State.EQUIPPED)
	assert_eq(open.state, HeroLoadout.State.OPEN)
	assert_eq(worn.line_color(), TalentNode.EQUIPPED_LINE)
	assert_eq(open.line_color(), UiKit.OLD_GOLD)
	assert_lt(open.ink_color().get_luminance(), 0.12, "open is dark felt: the frame and the glyph carry the branch")
	assert_gt(absf(worn.ink_color().get_luminance() - open.ink_color().get_luminance()) + absf(worn.ink_color().s - open.ink_color().s), 0.1)
	var combo := TalentNode.BRANCH_COLOR[TalentDef.Branch.COMBO]
	assert_gt(combo.s, 0.4, "Combo is a colour, not a grey")
	for b in [TalentDef.Branch.FURIA, TalentDef.Branch.EMETH, TalentDef.Branch.MAGIA]:
		assert_gt(absf(combo.h - TalentNode.BRANCH_COLOR[b].h), 0.03, "Combo apart from branch %d" % b)


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


func test_the_panel_says_why_a_gift_cannot_go_on() -> void:
	var d := _data(XP_8)
	var s := _screen(d)
	s.tree.node(&"passo_encadeado").focus_entered.emit()
	var status := s.find_child("status", true, false) as Label
	assert_eq(status.text, T.t(&"hero_why_needs", {"what": T.t(&"talent_quarto_corte")}))
	s.tree.node(&"passo_encadeado").pressed.emit()
	assert_eq(SaveData.hero(d, "warrior").equipped, [], "refused")
	var name := s.find_child("gift_name", true, false) as Label
	assert_eq(name.text, T.t(&"talent_passo_encadeado"))


func test_choosing_an_ultimate_on_the_screen() -> void:
	var d := _data(XP_6)
	var s := _screen(d)
	assert_true(s.ults[0].open)
	assert_false(s.ults[1].open)
	s.ults[0].pressed.emit()
	assert_eq(SaveData.hero(d, "warrior").ultimate, "cleave")
	assert_true(s.ults[0].chosen)
	s.ults[1].pressed.emit()
	assert_eq(SaveData.hero(d, "warrior").ultimate, "cleave", "the locked one is never chosen")


func test_keys_walk_the_diamond() -> void:
	var s := _screen(_data(2470))
	await wait_process_frames(2)
	s.tree.centre.grab_focus()
	var right := s.tree.centre.find_valid_focus_neighbor(SIDE_RIGHT)
	assert_true(right is TalentNode, "right of the centre is a Gift")
	assert_eq((right as TalentNode).def.id, &"impeto", "Fúria's entry is to the right")
	var up := s.tree.centre.find_valid_focus_neighbor(SIDE_TOP)
	assert_eq((up as TalentNode).def.id, &"quarto_corte", "Combo's entry is above")


func test_every_text_of_the_screen_is_in_the_table() -> void:
	for key: StringName in [&"title_hero", &"hero_mastery", &"hero_devotion", &"hero_passive", &"hero_passive_desc",
			&"hero_ultimate", &"bar_equip", &"bar_open", &"hero_why_locked", &"hero_why_devotion", &"hero_why_slot",
			&"hero_why_needs", &"hero_why_apex", &"hero_why_bridge", &"codex_title", &"end_level_up"]:
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
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 1, 2), [T.t(&"end_unlocked", {"name": T.t(&"talent_impeto")})] as Array[String])
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 5, 6), [T.t(&"end_unlocked_ult", {"name": T.t(&"ult_cleave")})] as Array[String])
	# several levels at once: one line each, the names joined
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 1, 4), [
		T.t(&"end_unlocked_many", {"name": ", ".join([T.t(&"talent_impeto"), T.t(&"talent_corte_crescente"), T.t(&"talent_lamina_faminta")])})] as Array[String])
	assert_eq(MasteryReport.unlocks(HeroDef.warrior(), 9, 10), [T.t(&"end_unlocked", {"name": T.t(&"talent_reserva")}),
		T.t(&"end_unlocked_ult", {"name": T.t(&"ult_vortex")})] as Array[String])
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
	var open_row := c.find_child("impeto", true, false)
	assert_eq((open_row.find_child("Name", false, false) as Label).text, T.t(&"talent_impeto"))
	var closed_row := c.find_child("lamina_faminta", true, false)
	assert_eq((closed_row.find_child("Name", false, false) as Label).text, "???")
	assert_eq((closed_row.find_child("Desc", false, false) as Label).text, T.t(&"codex_locked", {"n": 4}))


func test_codex_tabs_switch_by_focus() -> void:
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(CodexScreen.Tab.MOVES, _data(0))
	assert_eq(c.tab, CodexScreen.Tab.MOVES)
	assert_null(c.find_child("quarto_corte", true, false))
	c.tabs[0].grab_focus()
	assert_eq(c.tab, CodexScreen.Tab.GIFTS)
	assert_true(c.tabs[0].button_pressed)
	assert_false(c.tabs[1].button_pressed)
