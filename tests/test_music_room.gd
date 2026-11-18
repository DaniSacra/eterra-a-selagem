extends GutTest
## T5, the PO's review ("deixar eu ouvir as músicas que já temos e escolher"): the music catalog (MusicCatalog), the
## choice per place in the save (music_title, music_dungeon, music_morvath; our own pieces by default), Music playing
## the chosen piece, and the Músicas screen (MusicRoomScreen) opened from Configurações.

var _options: Dictionary


func before_each() -> void:
	_options = (Save.data.options as Dictionary).duplicate()
	for place in MusicCatalog.PLACES:
		Save.data.options[MusicCatalog.OPTION[place]] = String(MusicCatalog.DEFAULT[place])
	Music.mix = MusicMix.new(Music.catalog())


func after_each() -> void:
	Save.data.options = _options
	Music.mix = MusicMix.new(Music.catalog())


func test_the_catalog_is_valid_and_every_file_is_there() -> void:
	var names := {}
	for id: StringName in MusicCatalog.PIECES:
		var spec := MusicCatalog.spec(id)
		var name := T.t(spec.name)
		assert_ne(name, String(spec.name), "%s has a name for the player" % id)
		assert_false(names.has(name), "%s: names are not repeated" % id)
		assert_false(name.contains("—") or name.contains("–"), "%s: no dash" % id)
		names[name] = true
		assert_gt(int(spec.layers), 0)
		for i in int(spec.layers):
			assert_true(ResourceLoader.exists(MusicCatalog.file_of(id, i)), MusicCatalog.file_of(id, i))
		for place: StringName in spec.places:
			assert_true(MusicCatalog.PLACES.has(place), "%s: %s is a place" % [id, place])
			# a place needs its layers: the rooms a walk and a fight, Morvath four phases
			assert_gte(int(spec.layers), int(MusicCatalog.NEEDS[place]), "%s serves %s" % [id, place])
			assert_true(spec.get("loop", false), "%s loops where it is chosen" % id)
		if spec.has("then"):
			assert_true(MusicCatalog.PLACES.has(spec.then), "%s hands over to a place" % id)
	for place in MusicCatalog.PLACES:
		assert_true(MusicCatalog.choices(place).size() >= 2, "%s has something to choose" % place)
		assert_true(MusicCatalog.serves(MusicCatalog.DEFAULT[place], place), "%s's default serves there" % place)
		assert_true(SaveData.defaults().options.has(MusicCatalog.OPTION[place]), "%s is a save option" % place)
	# the Psalms' themes and the victory are only to listen
	for id: StringName in [&"victory", &"psalm_sentinel", &"psalm_shelter", &"psalm_shepherd", &"psalm_rock"]:
		assert_true(MusicCatalog.has(id))
		assert_eq((MusicCatalog.spec(id).places as Array).size(), 0, "%s is only to listen" % id)


func test_the_default_is_our_own_music_everywhere() -> void:
	# MUS-1: the fight music composed by the project is the default; the title hears the walk of the rooms' piece
	var opts: Dictionary = SaveData.defaults().options
	assert_eq(opts.music_title, "blade_march", "the title hears the walk of our rooms' music")
	assert_eq(opts.music_dungeon, "blade_march")
	assert_eq(opts.music_morvath, "morvath_battle")
	assert_eq(T.t(MusicCatalog.spec(&"blade_march").name), "Marcha das Lâminas")
	assert_eq(T.t(MusicCatalog.spec(&"morvath_battle").name), "Morvath, a Batalha")
	# the pieces of before stay in the list
	for id: StringName in [&"classic_catacombs", &"gloom_descent"]:
		assert_true(MusicCatalog.choices(MusicCatalog.DUNGEON).has(id), "%s may still be chosen" % id)
	for id: StringName in [&"deep_drums", &"iron_pulse"]:
		assert_true(MusicCatalog.choices(MusicCatalog.DUNGEON).has(id), "%s is a rooms' piece" % id)
	for id: StringName in [&"classic_morvath", &"clash_defiant"]:
		assert_true(MusicCatalog.choices(MusicCatalog.MORVATH).has(id), "%s may still be chosen" % id)
	assert_eq(T.t(MusicCatalog.spec(&"classic_catacombs").name), "Catacumbas (original)")
	# an older save (no option) reads the default
	var old := SaveData.merged({"version": 4, "options": {"music": 0.5}})
	assert_eq(old.options.music_morvath, "morvath_battle")


func test_a_wrong_choice_falls_back_to_the_default() -> void:
	for place in MusicCatalog.PLACES:
		for bad: Variant in [null, "", "nothing", 3, "victory", "psalm_rock"]:
			assert_eq(MusicCatalog.resolve(place, bad), MusicCatalog.DEFAULT[place], "%s with %s" % [place, bad])
	assert_eq(MusicCatalog.resolve(MusicCatalog.MORVATH, "gloom_descent"), &"morvath_battle", "a rooms' piece is not Morvath's")
	assert_eq(MusicCatalog.resolve(MusicCatalog.DUNGEON, "tempting_secrets"), &"blade_march", "the title's piece has no fight")
	assert_eq(MusicCatalog.resolve(MusicCatalog.TITLE, "gloom_descent"), &"gloom_descent", "a rooms' piece may play on the title")
	var merged := SaveData.merged({"options": {"music_dungeon": 7}})
	assert_eq(merged.options.music_dungeon, "blade_march", "a damaged option")
	Save.data.options.music_morvath = "nothing"
	assert_eq(Music.piece_for(&"morvath"), &"morvath_battle")


func test_music_plays_the_chosen_piece() -> void:
	assert_eq(Music.piece_for(&"catacombs"), &"blade_march")
	assert_eq(Music.piece_for(&"victory"), &"victory", "not a place: itself")
	Music.choose(&"catacombs", &"gloom_descent")
	assert_eq(Save.data.options.music_dungeon, "gloom_descent", "the choice is saved")
	assert_eq(Music.mix.catalog[&"victory"].then, &"gloom_descent", "the victory hands over to the chosen rooms")
	Music.play(&"catacombs", Music.FIGHT)
	assert_eq(Music.current(), &"gloom_descent")
	Music.choose(&"morvath", &"gloom_descent")
	assert_eq(Save.data.options.music_morvath, "morvath_battle", "a piece that does not serve there is refused")
	Music.choose(&"morvath", &"clash_defiant")
	Music.boss_phase(2)
	assert_eq(Music.current(), &"clash_defiant")
	assert_eq(Array(Music.mix.current().targets), [0.0, 1.0, 0.0, 0.0])
	assert_eq(MusicCatalog.step(&"title", &"classic_catacombs", 1), &"tempting_secrets")
	assert_eq(MusicCatalog.step(&"title", &"blade_march", 1), &"deep_drums")
	assert_eq(MusicCatalog.step(&"title", &"blade_march", -1), &"gloom_descent", "wraps around")


func test_listening_and_back_to_the_game() -> void:
	Music.play(&"catacombs", Music.FIGHT)
	Music.listen(&"clash_defiant", 3)
	assert_eq(Music.heard(), &"clash_defiant")
	assert_eq(Music.mix.level(), 3)
	Music.listen(&"psalm_rock")
	assert_eq(Music.heard(), &"psalm_rock", "a theme alone")
	assert_eq(Music.mix.current().fade_to, 0.0, "without a bed under it")
	Music.listen(&"victory")
	assert_eq(Music.mix.stings.size(), 0, "the theme stops for the next piece")
	assert_eq(Music.mix.current().then, &"", "the victory heard alone does not go on into the walk")
	Music.quiet()
	assert_eq(Music.heard(), &"")
	Music.resume()
	assert_eq(Music.current(), &"blade_march", "back to the rooms")
	assert_eq(Music.mix.level(), Music.FIGHT, "at the level they were")


func _press(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await get_tree().process_frame
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)
	await get_tree().process_frame
	await get_tree().process_frame


func test_the_screen_opens_chooses_and_closes_by_keys() -> void:
	Music.play(&"title")
	var options := OptionsScreen.new()
	add_child_autofree(options)
	options.open()
	await get_tree().process_frame
	var button := options.find_child("music_room", true, false) as Button
	assert_not_null(button, "Configurações has Músicas")
	button.grab_focus()
	await _press(&"ui_accept")
	var rooms := options.find_children("*", "MusicRoomScreen", true, false)
	assert_eq(rooms.size(), 1, "Músicas opens")
	if rooms.is_empty():
		return
	var room: MusicRoomScreen = rooms[0]
	await get_tree().process_frame
	var focus := get_viewport().gui_get_focus_owner()
	assert_true(focus != null and String(focus.name) == "place_title_1", "the focus starts on the title's choice")
	# every piece is listed with Ouvir
	for id: StringName in MusicCatalog.PIECES:
		assert_not_null(room.find_child("listen_" + id, true, false), "%s is listed" % id)
	await _press(&"ui_accept")
	assert_eq(Save.data.options.music_title, "deep_drums", "right steps the title's piece and saves it")
	var shown := room.find_child("place_title", true, false) as Label
	assert_eq(shown.text, T.t(&"music_deep_drums"), "and shows it")
	focus = get_viewport().gui_get_focus_owner()
	assert_true(focus != null and String(focus.name) == "place_title_1", "the focus stays on it")
	var listen := room.find_child("listen_classic_morvath", true, false) as Button
	listen.grab_focus()
	await _press(&"ui_accept")
	assert_eq(Music.heard(), &"classic_morvath", "Ouvir plays the piece")
	await get_tree().process_frame
	assert_eq(listen.text, T.t(&"music_stop"), "and turns into Parar")
	await _press(&"ui_accept")
	assert_eq(Music.heard(), &"", "Parar stops it")
	await _press(&"ui_cancel")
	await get_tree().process_frame
	assert_eq(options.find_children("*", "MusicRoomScreen", true, false).size(), 0, "Esc closes Músicas")
	assert_true(options.is_inside_tree(), "and only Músicas")
	assert_eq(Music.current(), &"deep_drums", "the title's new choice plays")
	focus = get_viewport().gui_get_focus_owner()
	assert_true(focus != null and String(focus.name) == "music_room", "focus back on Músicas")


func test_the_screen_fits_720_lines() -> void:
	# the game's base size (project.godot 1280 x 720, canvas_items: 1920 x 1080 is the same layout scaled)
	var holder := Control.new()
	holder.size = Vector2(1280, 720)
	add_child_autofree(holder)
	var room := MusicRoomScreen.new()
	holder.add_child(room)
	room.open()
	await get_tree().process_frame
	await get_tree().process_frame
	for c: Control in room.find_children("*", "Button", true, false):
		var r := c.get_global_rect()
		assert_true(r.position.y >= 0.0 and r.end.y <= 720.0 and r.position.x >= 0.0 and r.end.x <= 1280.0, "%s on screen (%s)" % [c.name, r])
