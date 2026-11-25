extends GutTest
## Save slots (the Daniel, 2026-11-19): three saves (SaveSlots, user://save_<n>.json) and a profile with the slot in
## use and the shared options. The save of before the slots (save.json) becomes Save 1 without losing anything
## (every fixture tests/fixtures/save_v*.json), choosing an empty slot creates a save, choosing one that exists
## continues it, and Apagar erases the file and its copy (and never brings the old save.json back as Save 1).
## Everything in a folder of the test's own; the Save autoload is pointed at it and given back afterwards.

const DIR := "user://test_save_slots/"
const FIXTURES: Array[String] = ["save_v1.json", "save_v2.json", "save_v3.json", "save_v4.json", "save_v5.json"]

var _kept := {}


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	_clear()
	_kept = {"data": Save.data, "enabled": Save.enabled, "slot": Save.slot, "chosen": Save.chosen, "base": Save.base,
		"path": Save.path}
	Save.base = DIR
	Save.path = Save.PATH
	Save.enabled = true
	Save.slot = 0
	Save.chosen = false


func after_each() -> void:
	Save.data = _kept.data
	Save.enabled = _kept.enabled
	Save.slot = _kept.slot
	Save.chosen = _kept.chosen
	Save.base = _kept.base
	Save.path = _kept.path
	_clear()


func after_all() -> void:
	_clear()
	DirAccess.remove_absolute(DIR)


func _clear() -> void:
	for f in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR + f)


func _put(p: String, text: String) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _fixture(name: String) -> String:
	return FileAccess.get_file_as_string("res://tests/fixtures/" + name)


## The parts of a save that are progress (what a migration must never lose).
func _progress(d: Dictionary) -> Dictionary:
	# through JSON on both sides: a number kept as an int in memory reads back as a float (the same value)
	return JSON.parse_string(JSON.stringify({"runs": d.runs, "wins": d.wins, "heroes": d.heroes, "codex": d.codex, "materials": d.materials,
		"best_times": d.best_times, "moves": d.moves, "juramentos": d.juramentos}))


func test_every_older_save_becomes_save_1_without_losing_anything() -> void:
	for name in FIXTURES:
		_clear()
		var text := _fixture(name)
		_put(DIR + SaveSlots.LEGACY, text)
		var want := SaveData.merged(JSON.parse_string(text))
		assert_true(SaveSlots.has_legacy(DIR), "%s waits to become Save 1" % name)
		assert_true(SaveSlots.exists(1, DIR) and not SaveSlots.exists(2, DIR), "%s shows as Save 1" % name)
		var profile := SaveSlots.read_profile(DIR)
		assert_eq(int(profile.active), 1, "%s: Save 1 is the one in use" % name)
		assert_eq(SaveSlots.options_of(profile.options), want.options, "%s: its options are the computer's" % name)
		# the first launch: read only, nothing written yet
		Save.load_profile()
		Save.call(&"_load_slot")
		assert_eq(_progress(Save.data), _progress(want), "%s read as Save 1" % name)
		assert_false(FileAccess.file_exists(DIR + "save_1.json"), "reading never writes")
		# the player picks Save 1: it is moved, once
		Save.use(1)
		assert_true(FileAccess.file_exists(DIR + "save_1.json"), "%s moved into save_1.json" % name)
		assert_false(FileAccess.file_exists(DIR + SaveSlots.LEGACY), "the old file is out of the way")
		assert_true(FileAccess.file_exists(DIR + SaveSlots.RETIRED), "and kept as save_legacy.json")
		assert_false(SaveSlots.has_legacy(DIR))
		var back: Dictionary = SaveSlots.read(1, DIR)
		assert_eq(_progress(back), _progress(want), "%s: Save 1 holds every bit of progress" % name)
		assert_eq(int(SaveSlots.read_profile(DIR).active), 1)


func test_the_old_copy_moves_too_and_a_damaged_old_file_reads_its_copy() -> void:
	var text := _fixture("save_v5.json")
	_put(DIR + SaveSlots.LEGACY, "{\"version\": 5, \"heroes\"")
	_put(DIR + SaveSlots.LEGACY + SaveFile.BAK, text)
	var read: Variant = SaveSlots.read(1, DIR)
	assert_true(read is Dictionary, "the copy of a damaged old save is read")
	assert_eq(int(read.runs), 4)
	Save.load_profile()
	Save.use(1)
	assert_eq(int(SaveSlots.read(1, DIR).runs), 4, "Save 1 has the copy's progress")


func test_an_empty_slot_creates_a_new_save() -> void:
	assert_eq(SaveSlots.summary_of(2, DIR), null, "empty")
	Save.load_profile()
	Save.use(2)
	assert_true(FileAccess.file_exists(DIR + "save_2.json"), "choosing it writes a new save")
	assert_eq(Save.slot, 2)
	assert_true(Save.chosen)
	var info: Dictionary = SaveSlots.summary_of(2, DIR)
	assert_eq([info.level, info.runs, info.wins, info.silver, info.memory, info.played_at], [1, 0, 0, 0, 0, 0],
		"a new save: Maestria 1, nothing played")
	assert_eq(int(SaveSlots.read_profile(DIR).active), 2, "the profile remembers the slot")


func test_a_slot_that_exists_continues() -> void:
	var d := SaveData.defaults()
	d.runs = 9
	d.wins = 2
	d.played_at = 1795000000
	d.heroes.warrior.mastery_xp = 500
	d.materials.silver = 33
	d.materials.memory = 4
	d.options.music = 0.1  # a slot's own options never win over the computer's
	_put(SaveSlots.path(3, DIR), JSON.stringify(d))
	SaveSlots.write_profile(1, SaveData.defaults().options, DIR)
	Save.load_profile()
	var options: Dictionary = Save.data.options.duplicate(true)
	Save.use(3)
	assert_eq(int(Save.data.runs), 9, "the save goes on")
	assert_eq(int(SaveData.hero(Save.data, SaveData.FIRST_HERO).mastery_xp), 500)
	assert_eq(Save.data.options, options, "the options stay the computer's")
	var info: Dictionary = SaveSlots.summary_of(3, DIR)
	assert_eq(info.level, HeroDef.warrior().mastery.level_of(500))
	assert_eq([info.runs, info.wins, info.silver, info.memory, info.played_at], [9, 2, 33, 4, 1795000000])
	assert_eq(SaveSlots.date_text(0), "")
	assert_string_contains(SaveSlots.date_text(1795000000), "/20")


func test_options_are_shared_and_never_stamp_a_game() -> void:
	Save.load_profile()
	Save.use(2)
	var stamped := int(SaveSlots.read(2, DIR).played_at)
	Save.set_option("music", 0.3)
	assert_eq(float(SaveSlots.read_profile(DIR).options.music), 0.3, "an option goes to the profile")
	assert_eq(int(SaveSlots.read(2, DIR).played_at), stamped, "changing an option is not a game played")
	Save.use(1)
	assert_eq(float(Save.option("music")), 0.3, "another save keeps the computer's options")


func test_erase_removes_the_file_its_copy_and_the_rest() -> void:
	var text := JSON.stringify(SaveData.defaults())
	for ext: String in ["", SaveFile.BAK, SaveFile.TMP, SaveFile.BROKEN, SaveFile.BROKEN + "1"]:
		_put(SaveSlots.path(2, DIR) + ext, text)
	_put(SaveSlots.path(3, DIR), text)
	Save.load_profile()
	Save.use(2)
	Save.erase(2)
	for ext: String in ["", SaveFile.BAK, SaveFile.TMP, SaveFile.BROKEN, SaveFile.BROKEN + "1"]:
		assert_false(FileAccess.file_exists(SaveSlots.path(2, DIR) + ext), "save_2.json%s erased" % ext)
	assert_false(SaveSlots.exists(2, DIR))
	assert_true(SaveSlots.exists(3, DIR), "the other saves stay")
	assert_eq(Save.slot, 0, "the save in use was that one: none now")
	assert_eq(int(SaveSlots.read_profile(DIR).active), 0)


func test_erasing_save_1_never_brings_the_old_save_back() -> void:
	_put(DIR + SaveSlots.LEGACY, _fixture("save_v5.json"))
	Save.load_profile()
	Save.erase(1)
	assert_false(SaveSlots.exists(1, DIR), "Save 1 is empty")
	assert_false(SaveSlots.has_legacy(DIR), "the old save is retired, not read again")
	Save.load_profile()
	assert_eq(int(Save.data.runs), 0)
	Save.use(1)
	assert_eq(int(SaveSlots.read(1, DIR).runs), 0, "a new Save 1 starts from zero")


func test_without_a_save_nothing_is_written() -> void:
	Save.enabled = false
	Save.use(2)
	Save.write()
	Save.set_option("music", 0.2)
	Save.erase(2)
	assert_eq(DirAccess.get_files_at(DIR).size(), 0, "--nosave and the tests write nothing")


## The Daniel, 2026-11-21: the title first; Iniciar asks for the save; a used save goes to the hub, an empty one
## straight into the first descent.
func test_iniciar_asks_for_the_save_and_a_new_one_goes_straight_down() -> void:
	var boot: GDScript = load("res://scripts/boot.gd")
	assert_true(boot.call(&"wants_slots"), "with a save, Iniciar asks which")
	Save.enabled = false
	assert_false(boot.call(&"wants_slots"), "--nosave and the tests go straight on")
	Save.enabled = true
	var d := SaveData.defaults()
	assert_eq(boot.call(&"first_scene", d), SceneGo.GAME, "an empty save: the first descent, no hub")
	d.runs = 1
	assert_eq(boot.call(&"first_scene", d), SceneGo.HUB, "a save with a descent: the Santuário")


func test_the_first_descent_ends_only_towards_the_santuario() -> void:
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, {"time": 60.0, "level": 0, "kills": 3, "best_combo": 2, "boons": 1, "defeated_by": &"", "mastery": {}}, false)
	assert_not_null(end.find_child("retry", true, false), "a later descent offers going down again")
	end.home_only()
	await wait_process_frames(2)
	assert_null(end.find_child("retry", true, false), "the first one only the way to the Santuário")
	assert_not_null(end.find_child("menu", true, false))


func test_the_screen_shows_each_save() -> void:
	var d := SaveData.defaults()
	d.runs = 3
	d.played_at = 1795000000
	_put(SaveSlots.path(2, DIR), JSON.stringify(d))
	var screen := SaveSlotScreen.new()
	add_child_autofree(screen)
	screen.open(false, DIR)
	assert_eq(screen.cards.size(), 3)
	assert_not_null(screen.cards[0].find_child("empty", true, false), "Save 1 empty")
	assert_not_null(screen.cards[1].find_child("date", true, false), "Save 2 with its day")
	assert_true(screen.erasers[0].disabled and not screen.erasers[1].disabled, "Apagar only where there is a save")
	var said: Array[int] = []
	screen.chosen.connect(func(n: int) -> void: said.append(n))
	# SW-O4: a new save beside a played one first asks about the guided descent (Save 3 is empty, Save 2 has descents)
	screen.cards[2].pressed.emit()
	assert_eq(said.size(), 0, "the question comes first")
	assert_not_null(screen.question, "the guided descent is asked")
	await wait_process_frames(2)
	(screen.question as AskPage).cancelled.emit()
	assert_null(screen.question, "Esc leaves it as it was")
	screen.cards[2].pressed.emit()
	await wait_process_frames(2)
	((screen.question as AskPage).yes as Button).pressed.emit()
	assert_eq(said, [3] as Array[int], "a card says its slot")
	assert_false(screen.skip_first, "yes: the guided descent is done")
	screen.erasers[1].pressed.emit()
	assert_not_null(screen.question, "Apagar asks first")
	var title := screen.question.find_child("header", true, false)
	assert_not_null(title)
	assert_string_contains((title.get_child(0) as Label).text, "Não há volta")
	(screen.question.find_child("yes", true, false) as Button).pressed.emit()
	assert_false(SaveSlots.exists(2, DIR), "Apagar in the question erases it")
	assert_null(screen.cards[1].find_child("date", true, false), "the card is empty again")
