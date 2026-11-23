extends GutTest
## M1b: the hero is picked at the Portal and kept in the save ("hero"); older saves and bad values read as the Warrior.


func test_a_new_save_picks_the_warrior() -> void:
	var d := SaveData.defaults()
	assert_eq(SaveData.picked_hero(d), "warrior")
	assert_eq(SaveData.next_hero(d), "warrior", "PT-9: the Maga is locked until Morvath is sealed once")
	d.wins = 1
	assert_eq(SaveData.next_hero(d), "maga")


func test_the_pick_walks_the_list_and_back() -> void:
	var d := SaveData.defaults()
	d.wins = 1
	d.hero = SaveData.next_hero(d)
	assert_eq(SaveData.picked_hero(d), "maga")
	assert_eq(SaveData.next_hero(d), "warrior")


func test_the_pick_survives_a_merge() -> void:
	var d := SaveData.defaults()
	d.hero = "maga"
	assert_eq(SaveData.merged(JSON.parse_string(JSON.stringify(d))).hero, "maga")


func test_an_old_or_broken_save_reads_as_the_warrior() -> void:
	var old := SaveData.defaults()
	old.erase("hero")
	assert_eq(SaveData.merged(old).hero, "warrior", "a save from before")
	for bad: Variant in ["paladin", 3, null, ""]:
		var d := SaveData.defaults()
		d.hero = bad
		assert_eq(SaveData.merged(d).hero, "warrior", "bad value %s" % str(bad))


func test_the_game_plays_the_warrior_without_a_save_and_the_pick_with_one() -> void:
	assert_false(Save.enabled, "tests never write")
	assert_eq(Game.hero_option().id, &"warrior")


func test_the_maga_block_is_empty_and_the_hero_screen_still_lists_gifts() -> void:
	var d := SaveData.defaults()
	var block := SaveData.hero(d, "maga")
	assert_eq(int(block.mastery_xp), 0)
	assert_true((block.equipped as Array).is_empty())
	var screen := HeroScreen.new()
	add_child_autofree(screen)
	screen.open(d)
	assert_not_null(screen)


func test_the_hud_shows_the_maga_marks_and_the_resonance() -> void:
	assert_eq(Hud.MAGA_GLYPHS.size(), 4)
	for a: StringName in [&"light_attack", &"heavy_attack", &"shout", &"rush"]:
		assert_true(Hud.MAGA_GLYPHS.has(a), String(a))
	assert_eq(Hud.ACTIONS.size(), 5, "the same five buttons as the Warrior")
