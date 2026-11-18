extends GutTest
## DV-1, MAP-03: the descent's map in the Livro de Ahk. The map's reading of a descent (DescentMap: which rooms are
## walked, stood in, behind an open door, ahead or left behind; the marks of the doors' signs and the "?"), the focus
## walking the rooms, the page telling the room in focus, and the map over a real run (the HUD's key and button, the
## pause's entry; the run stops under it).

const Kind := DoorGlyph.Kind


func _map(moment: String = "doors") -> DescentMap:
	return DescentMap.from_dict(MapSample.at(moment))


func test_reads_how_each_room_stands() -> void:
	var m := _map("doors")
	assert_eq(m.depths(), 11)
	assert_eq(m.current, 11)
	assert_eq(m.state(11), DescentMap.State.CURRENT)
	for id in [0, 2, 5, 7, 9]:
		assert_eq(m.state(id), DescentMap.State.DONE, "walked: %d" % id)
	assert_eq(m.doors, [13, 14] as Array[int], "the doors are the room's links")
	for id in [13, 14]:
		assert_eq(m.state(id), DescentMap.State.DOOR)
	for id in [15, 16, 17, 18, 19, 20]:
		assert_eq(m.state(id), DescentMap.State.AHEAD, "still reachable: %d" % id)
	for id in [1, 3, 4, 6, 8, 10, 12]:
		assert_eq(m.state(id), DescentMap.State.BEHIND, "left behind: %d" % id)
	assert_true(m.walked(9, 11))
	assert_false(m.walked(11, 9))


func test_at_the_start_everything_is_ahead() -> void:
	var m := _map("start")
	assert_eq(m.state(0), DescentMap.State.CURRENT)
	assert_eq(m.doors, [1, 2] as Array[int])
	for id: int in m.rooms:
		if id > 2:
			assert_eq(m.state(id), DescentMap.State.AHEAD, "every room reachable from the hall: %d" % id)
	assert_eq(m.first_focus(), 1, "the focus starts on the first door")


func test_marks_are_the_signs_own() -> void:
	var m := _map("doors")
	assert_eq(m.mark(0), Kind.BLESSING)
	assert_eq(m.mark(2), Kind.GOLD)
	assert_eq(m.mark(3), Kind.POMEGRANATE)
	assert_eq(m.mark(5), Kind.HEART)
	assert_eq(m.mark(6), Kind.MAGICK)
	assert_eq(m.mark(4), Kind.ALTAR)
	assert_eq(m.mark(11), Kind.FOUNTAIN)
	assert_eq(m.mark(19), Kind.SHOP)
	assert_eq(m.mark(20), Kind.BOSS)
	assert_eq(m.mark(13), Kind.UNKNOWN, "a hidden room shows only the question mark")
	assert_eq(m.badge(13), Kind.NONE, "and nothing beside it")
	assert_eq(m.badge(5), Kind.HARD)
	assert_eq(m.badge(8), Kind.GUARDIAN)
	assert_eq(m.badge(0), Kind.NONE)
	assert_eq(m.guardian_short(8), "Cavaleiro")
	assert_eq(m.guardian_short(9), "Ancião")
	assert_eq(m.guardian_short(10), "")


func test_texts_are_in_the_table() -> void:
	var m := _map("doors")
	for id: int in m.rooms:
		assert_ne(m.title(id), "")
		for line in m.lines(id):
			assert_false(line.contains("—"), "no dash: " + line)
			assert_false(line.contains("{"), "every field filled: " + line)
	assert_string_contains(m.title(8), "Cavaleiro")
	assert_eq(m.title(13), T.t(&"map_hidden"))
	assert_true(Array(m.lines(13)).has(T.t(&"map_state_door")))
	assert_true(Array(m.lines(8)).has(T.t(&"map_state_behind")))
	for key: String in T.table.entries:
		if key.begins_with("map_") or key == "hud_map" or key == "pause_map" or key.begins_with("howto_map"):
			assert_false(T.t(key).contains("—"), "no dash in " + key)


func test_the_focus_walks_the_rooms() -> void:
	var m := _map("doors")
	assert_eq(m.step(13, Vector2i.RIGHT), 14)
	assert_eq(m.step(14, Vector2i.RIGHT), 14, "no room further right")
	assert_eq(m.step(14, Vector2i.LEFT), 13)
	assert_eq(m.step(13, Vector2i.DOWN), 15, "down to the room it links with")
	assert_eq(m.step(20, Vector2i.DOWN), 20, "nothing under Morvath")
	assert_eq(m.step(0, Vector2i.UP), 0, "nothing over the entrance")
	var up := m.step(13, Vector2i.UP)
	assert_eq(m.room(up).depth, 6)


func test_the_page_tells_the_room_in_focus_and_the_focus_moves() -> void:
	var s := MapScreen.new()
	add_child_autofree(s)
	s.open(_map("doors"))
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(s.graph.focus_id, 13, "first open door")
	assert_string_contains(s.focus_text(), T.t(&"map_hidden"))
	assert_true(s.graph.has_focus())
	var right := InputEventAction.new()
	right.action = &"ui_right"
	right.pressed = true
	s.graph._gui_input(right)
	await get_tree().process_frame
	assert_eq(s.graph.focus_id, 14)
	assert_string_contains(s.focus_text(), T.t(&"arena_sanctuary"))
	# every room has its mark on the page, and the guardians their names
	assert_eq(s.graph.find_children("mark_*", "DoorGlyph", false, false).size(), 21)
	assert_not_null(s.graph.find_child("name_8", false, false))
	assert_not_null(s.graph.find_child("name_20", false, false), "Morvath named at the foot")
	# the pointer focuses the room under it
	var motion := InputEventMouseMotion.new()
	motion.position = s.graph.centre(20)
	s.graph._gui_input(motion)
	assert_eq(s.graph.focus_id, 20)


func test_closes_on_the_map_key_or_back() -> void:
	var s := MapScreen.new()
	add_child_autofree(s)
	s.open(_map("start"))
	watch_signals(s)
	var ev := InputEventAction.new()
	ev.action = &"map"
	ev.pressed = true
	s._unhandled_input(ev)
	assert_signal_emit_count(s, "closed", 1)
	s._unhandled_input(ev)
	assert_signal_emit_count(s, "closed", 1, "closes once")


func test_the_pages_fit_720_and_1080() -> void:
	for h: float in [720.0, 1080.0]:
		var holder := Control.new()
		holder.size = Vector2(h * 16.0 / 9.0, h)
		add_child_autofree(holder)
		var s := MapScreen.new()
		holder.add_child(s)
		s.open(_map("doors"))
		await get_tree().process_frame
		await get_tree().process_frame
		var page := s.graph.get_global_rect()
		for id: int in s.map.rooms:
			var c := s.graph.global_position + s.graph.centre(id)
			assert_true(page.grow(1.0).has_point(c), "room %d on its page at %d lines" % [id, h])
		var back := s.find_child("back", true, false) as Control
		assert_true(Rect2(Vector2.ZERO, holder.size).encloses(back.get_global_rect()), "Voltar inside the screen at %d" % h)
		var rows := s.graph.size.y / s.map.depths()
		assert_gt(rows, 2.0 * MapGraph.RADIUS + 4.0, "the rows clear each other at %d" % h)


# --- over a real run ---------------------------------------------------------------------------------------------

func _run() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	return game


func test_the_map_of_a_run_reads_the_descent() -> void:
	var game := _run()
	await get_tree().process_frame
	var m := DescentMap.from_game(game)
	assert_eq(m.depths(), game.rooms.stage.rooms + 1)
	assert_eq(m.room(m.current).depth, game.rooms.depth())
	assert_eq(m.room(m.layers[-1][0].id).kind, RunMap.Kind.BOSS)


func test_opening_from_the_hud_stops_the_run_and_closing_goes_on() -> void:
	var game := _run()
	for i in 10:
		await get_tree().process_frame
	assert_eq(game.mode, Game.Mode.PLAY)
	assert_true(game.hud.map_button.visible, "the button beside the room's number")
	assert_string_contains(game.hud.map_button.text, Controls.label(&"map"))
	var before := DescentMap.line_of(game.rooms)
	for k in 20:
		var s := game.hud.open_map()
		assert_not_null(s)
		assert_eq(game.mode, Game.Mode.CHOICE)
		var t := game.time
		var where: Array = game.horde.list.map(func(e: Enemy) -> Vector2: return e.pos)
		await get_tree().process_frame
		await get_tree().process_frame
		assert_eq(game.time, t, "the run's clock stands still")
		assert_eq(game.horde.list.map(func(e: Enemy) -> Vector2: return e.pos), where, "no enemy moves")
		assert_null(game.hud.open_map(), "one map at a time")
		s.close()
		await get_tree().process_frame
		assert_eq(game.mode, Game.Mode.PLAY)
	assert_eq(DescentMap.line_of(game.rooms), before, "opening and closing changes nothing")


func test_the_pause_has_the_map() -> void:
	var game := _run()
	await get_tree().process_frame
	game.call(&"_open_pause")
	await get_tree().process_frame
	var pause := game.get(&"_screen") as PauseMenu
	assert_not_null(pause.map_button)
	assert_eq(pause.buttons[1], pause.map_button, "right under Continuar")
	pause.map_button.pressed.emit()
	await get_tree().process_frame
	var map := pause.find_child("map_screen", false, false) as MapScreen
	assert_not_null(map)
	map.close()
	await get_tree().process_frame
	assert_null(pause.find_child("map_screen", false, false))
	assert_true(pause.map_button.has_focus(), "the focus goes back to Mapa")
	assert_eq(game.mode, Game.Mode.PAUSE)
