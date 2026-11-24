extends GutTest
## C2: the four new Dons (Voz Larga, Escudo de Guerra, Fôlego de Guerra, Ferro na Investida) have a place of their own in the
## Santuário's tree, can be bought and worn, and what they say reaches the stats the game reads.

const NEW: Array[StringName] = [&"voz_larga", &"escudo_de_guerra", &"folego_de_guerra", &"ferro_na_investida"]
const TOP_XP := 2470


func _data(equipped: Array = []) -> Dictionary:
	var d := SaveData.defaults()
	var block := SaveData.hero(d, "warrior")
	block.mastery_xp = TOP_XP
	SaveData.open_revealed(block)
	block.equipped = equipped
	return d


func _loadout(equipped: Array = []) -> HeroLoadout:
	return HeroLoadout.new(HeroDef.warrior(), _data(equipped))


func _stats(ids: Array[StringName]) -> BoonState:
	var l := _loadout()
	var defs: Array[TalentDef] = []
	for id in ids:
		defs.append(l.book.find(id))
	var b := BoonState.new()
	b.equip_talents(defs)
	return b


func test_the_four_are_in_the_catalog() -> void:
	var l := _loadout()
	for id in NEW:
		assert_not_null(l.book.find(id), str(id))


func test_the_loadout_gives_every_gift_of_a_place() -> void:
	var l := _loadout()
	var mids := l.all_of(TalentDef.Branch.FURIA, TalentDef.Tier.MIDDLE)
	assert_eq(mids.size(), 3)
	assert_eq(l.of(TalentDef.Branch.FURIA, TalentDef.Tier.MIDDLE), mids[0], "of() is still the first")
	assert_eq(l.all_of(TalentDef.Branch.COMBO, TalentDef.Tier.MIDDLE).size(), 2)


func test_every_gift_has_one_entry_in_its_own_chapter() -> void:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(_data(), HeroScreen.Chapter.GIFTS)
	var l := s.loadout
	assert_eq(s.codex.entries.size(), l.book.catalog.size())
	for i in s.codex.branches.size():
		for e: GiftEntry in s.codex.by_chapter[i]:
			assert_eq(e.def.branch, s.codex.branches[i], str(e.def.id))


func test_they_can_be_worn_and_the_apex_needs_any_middle() -> void:
	var l := _loadout(["impeto", "quarto_corte"])
	for id in [&"voz_larga", &"escudo_de_guerra", &"ferro_na_investida", &"folego_de_guerra"]:
		assert_eq(l.state(l.book.find(id)), HeroLoadout.State.OPEN, str(id))
		assert_true(l.toggle(id), str(id))
		assert_true(l.is_equipped(id), str(id))


func test_the_screen_shows_them_and_keys_reach_them() -> void:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(_data(), HeroScreen.Chapter.GIFTS)
	await wait_process_frames(2)
	for id in NEW:
		assert_not_null(s.codex.entry(id), str(id))
	s.codex.show_chapter(1)
	s.codex.entry(&"avanco_feroz").grab_focus()
	var down := s.codex.entry(&"avanco_feroz").find_valid_focus_neighbor(SIDE_BOTTOM)
	assert_true(down is GiftEntry, "a Gift below the first Fúria middle")


func test_effects_reach_the_stats_the_game_reads() -> void:
	var b := _stats([&"voz_larga", &"escudo_de_guerra", &"folego_de_guerra", &"ferro_na_investida"])
	var shout: Array[StringName] = [&"shout"]
	var dash: Array[StringName] = [&"dash", &"light"]
	assert_almost_eq(b.stat(&"reach_pct", shout), 0.35, 0.001)
	assert_almost_eq(b.stat(&"damage_pct", shout), 0.5, 0.001)
	assert_almost_eq(b.stat(&"push_pct", shout), 0.3, 0.001)
	assert_eq(b.stat(&"shout_ward", shout), 1.0)
	assert_almost_eq(b.stat(&"cooldown_pct", shout), -0.25, 0.001)
	assert_almost_eq(b.stat(&"cooldown_pct", dash), -0.25, 0.001)
	assert_almost_eq(b.stat(&"damage_pct", dash), 0.5, 0.001)
	assert_almost_eq(b.stat(&"armor_pct", dash), 0.25, 0.001)
	assert_eq(b.stat(&"reach_pct", dash), 0.0, "Voz Larga is the Brado's only")


func test_the_four_new_gifts_draw_different_symbols() -> void:
	var seen := {}
	for id in NEW:
		assert_true(TalentMotif.has(id), "%s has a motif" % id)
		var key := str(TalentMotif.shapes(id))
		assert_false(seen.has(key), "%s repeats a symbol" % id)
		seen[key] = true
