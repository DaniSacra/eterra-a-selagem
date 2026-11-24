extends GutTest


func test_merged_fills_missing_keys_and_keeps_valid_ones() -> void:
	var out := SaveData.merged({"options": {"master": 0.3, "bogus": 1}, "wins": 2.0})
	assert_eq(out.options.master, 0.3)
	assert_eq(out.options.sfx, SaveData.defaults().options.sfx)
	assert_false(out.options.has("bogus"))
	assert_eq(out.wins, 2, "JSON numbers come back as floats and are read as ints")
	assert_eq(typeof(out.wins), TYPE_INT)
	assert_eq(SaveData.merged({"wins": "many"}).wins, 0)


func test_merged_survives_garbage() -> void:
	assert_eq(SaveData.merged(null).version, SaveData.VERSION)
	assert_eq(SaveData.merged("x").best_times, [])


func test_best_times_keep_the_fastest_in_order() -> void:
	var d := SaveData.defaults()
	assert_true(SaveData.add_best_time(d, 1000.0))
	assert_false(SaveData.add_best_time(d, 1100.0))
	assert_true(SaveData.add_best_time(d, 950.0))
	for i in 6:
		SaveData.add_best_time(d, 2000.0 + i)
	assert_eq(d.best_times.size(), SaveData.MAX_BEST_TIMES)
	assert_eq(d.best_times[0], 950.0)


func test_moves_are_discovered_once() -> void:
	var d := SaveData.defaults()
	assert_true(SaveData.discover_move(d, "spin"))
	assert_false(SaveData.discover_move(d, "spin"))


func test_format_time() -> void:
	assert_eq(SaveData.format_time(905.4), "15:05")


func test_player_text_has_no_dash_and_keeps_placeholders() -> void:
	var table: TextTable = load("res://data/text_pt.tres")
	for key: String in table.entries:
		assert_false((table.entries[key] as String).contains("—"), key)
		assert_false((table.entries[key] as String).contains("–"), key)
	assert_eq(table.text(&"PALADIN_1"), "PALADIN_1")


func test_the_game_opens_in_full_screen() -> void:
	assert_true(SaveData.defaults().options.fullscreen, "full screen by default")
	# an older file kept the old windowed default: it switches once
	var old := SaveData.merged({"version": 1, "options": {"fullscreen": false}})
	assert_true(old.options.fullscreen)
	# from version 2 on, a player who picked a window keeps it
	var chosen := SaveData.merged({"version": 2, "options": {"fullscreen": false}})
	assert_false(chosen.options.fullscreen)


# ---------- version 3 (DT-012, E2a): heroes and the Codex ----------

func _fixture(version: int) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save_v%d.json" % version))


## Reads data as the game does after a write: to JSON and back.
func _round_trip(data: Dictionary) -> Dictionary:
	return SaveData.merged(JSON.parse_string(JSON.stringify(data)))


func test_every_older_version_opens_as_the_current_one() -> void:
	for v in [1, 2, 3, 4]:
		assert_true(_fixture(v) is Dictionary, "fixture %d reads" % v)
		var out := SaveData.merged(_fixture(v))
		assert_eq(out.version, SaveData.VERSION, "version %d opens as %d" % [v, SaveData.VERSION])
		assert_true(out.heroes.has(SaveData.FIRST_HERO), "version %d has the Warrior" % v)
		for section in SaveData.CODEX:
			assert_true(out.codex[section] is Dictionary, "version %d has the codex %s" % [v, section])


func test_version_1_keeps_everything_valid() -> void:
	var out := SaveData.merged(_fixture(1))
	assert_eq(out.options.master, 0.5)
	assert_eq(out.options.scale, 2)
	assert_false(out.options.shake)
	assert_true(out.options.fullscreen, "version 1 switches to full screen once")
	assert_eq(out.best_times, [612.4, 700.0])
	assert_eq(out.moves, ["cut1", "cut2", "spin"])
	assert_eq(out.wins, 1)
	assert_eq(out.runs, 2)
	assert_eq(out.options.bindings.dodge[0].type, "key", "bindings (free keys) kept whole")


func test_version_2_keeps_its_window_and_options() -> void:
	var out := SaveData.merged(_fixture(2))
	assert_false(out.options.fullscreen, "a version 2 window is the player's choice")
	assert_false(out.options.impact_frames)
	assert_false(out.options.rumble)
	assert_eq(out.options.sfx, 0.6)
	assert_eq(out.runs, 30)


func test_older_saves_get_mastery_once_up_to_level_5() -> void:
	var curve := HeroDef.warrior().mastery
	# version 1: 2 runs and 1 win: 2 x 40 + 60 = 140
	var v1 := SaveData.merged(_fixture(1))
	assert_eq(v1.heroes.warrior.mastery_xp, 140)
	assert_eq(curve.level_of(140), 3)
	assert_eq(int(v1.heroes.warrior.firsts.victory), 1, "a past win is not a first win again")
	# version 2: 30 runs would be 1200, but never past level 5
	var v2 := SaveData.merged(_fixture(2))
	assert_eq(v2.heroes.warrior.mastery_xp, curve.total_to(5))
	assert_eq(curve.level_of(v2.heroes.warrior.mastery_xp), 5)
	assert_true((v2.heroes.warrior.firsts as Dictionary).is_empty(), "never won: the first times are still ahead")
	# once: what is read again (version 3 now) is not given again
	var again := _round_trip(v2)
	assert_eq(again.heroes.warrior.mastery_xp, curve.total_to(5))
	again.heroes.warrior.mastery_xp = 10
	assert_eq(_round_trip(again).heroes.warrior.mastery_xp, 10, "a version 3 file never gets the retroactive XP")
	# nothing played, nothing given
	assert_eq(SaveData.merged({"version": 2}).heroes.warrior.mastery_xp, 0)


func test_version_3_keeps_heroes_and_codex_through_read_and_write() -> void:
	var out := SaveData.merged(_fixture(3))
	var w: Dictionary = out.heroes.warrior
	assert_eq(w.mastery_xp, 512, "no retroactive XP on a version 3 file")
	assert_eq(typeof(w.mastery_xp), TYPE_INT)
	# (the fixture holds the Warrior's old Gifts: the v13 migration takes them out and gives the Memória back; the ids that
	# are not strings were dropped by the read before that)
	assert_eq(w.unlocked, [], "only ids (strings) are kept, the legacy ones migrated")
	assert_eq(w.equipped, [])
	assert_eq(w.ultimate, "", "the Supremo is the weapon's: nothing chosen is kept")
	assert_eq(int(w.firsts.guardian), 2)
	assert_true(out.heroes.has("someone_later"), "a hero this version does not know is kept")
	assert_eq(out.heroes.someone_later.mastery_xp, 40)
	assert_eq(out.codex.boons.brasas.seen, 3)
	assert_eq(typeof(out.codex.boons.brasas.seen), TYPE_INT)
	assert_false(out.codex.boons.has("broken"), "an entry that is not a dictionary goes")
	assert_eq(out.codex.elos.vapor.formed, 1)
	assert_eq(out.codex.talents.quarto_corte.used, 2)
	assert_eq(out.codex.enemies.knight.first_room, 5)
	# written and read back, nothing is lost
	var back := _round_trip(out)
	assert_eq(JSON.stringify(back.heroes), JSON.stringify(out.heroes))
	assert_eq(JSON.stringify(back.codex), JSON.stringify(out.codex))
	assert_eq(back.best_times, out.best_times)


func test_a_damaged_hero_block_falls_back_to_defaults() -> void:
	var out := SaveData.merged({"version": 3, "heroes": {"warrior": {"mastery_xp": "lots", "equipped": "x"}, "bad": 3}, "codex": "x"})
	assert_eq(out.heroes.warrior.mastery_xp, 0)
	assert_eq(out.heroes.warrior.equipped, [])
	assert_false(out.heroes.has("bad"))
	assert_eq(out.codex.boons, {})


func test_codex_counts_and_says_the_first_time() -> void:
	var d := SaveData.defaults()
	assert_true(SaveData.codex_add(d, "boons", "brasas", "seen"))
	assert_false(SaveData.codex_add(d, "boons", "brasas", "seen"))
	assert_eq(d.codex.boons.brasas.seen, 2)
	assert_eq(SaveData.hero(d, "warrior"), d.heroes.warrior)
	assert_eq(SaveData.hero(d, "new").mastery_xp, 0, "a missing hero block is made")


func test_old_music_defaults_move_to_the_new_ones_once() -> void:
	var loaded := {"version": 4, "options": {"music_title": "classic_catacombs", "music_dungeon": "classic_catacombs",
			"music_morvath": "deep_drums"}}
	var data := SaveData.merged(loaded)
	assert_eq(String(data.options.music_dungeon), String(MusicCatalog.DEFAULT[MusicCatalog.DUNGEON]))
	assert_eq(String(data.options.music_title), String(MusicCatalog.DEFAULT[MusicCatalog.TITLE]))
	assert_eq(String(data.options.music_morvath), "deep_drums", "a piece the player chose stays")
