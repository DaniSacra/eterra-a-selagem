extends GutTest
## HUB-B1, the hub's foundation (docs/design/hub_spec.md; hub_spec_art.md 2.1 to 2.4): the plan in the world, the
## focus by distance, the slide round the fountain, the action interact (its key, its remapping), the hero at peace
## (no press there is ever a blow, a special, a circle, an ultimate or a roll), the hub's screens and Esc (nothing
## pressed to close one reaches the hub), the flow title, hub, Portal (with the Juramentos), run, end screen and
## pause back to the hub, --hub, and a fake save through death, hub and a new descent (nothing doubled).

const DT := 1.0 / 60.0

var hub: Hub
var went: Array[String] = []
var _wins := 0


func before_each() -> void:
	went.clear()
	SceneGo.catch = func(path: String) -> void: went.append(path)
	Controls.virtual = null
	Controls.clear_presses()
	_wins = int(Save.data.wins)


func after_each() -> void:
	SceneGo.catch = Callable()
	for a: StringName in [&"interact", &"pause", &"light_attack", &"heavy_attack", &"cast", &"ultimate", &"dodge", &"ui_cancel"]:
		Input.action_release(a)
	Controls.virtual = null
	Controls.clear_presses()
	Controls.reset_bindings()
	Save.data.wins = _wins
	Engine.time_scale = 1.0


func _hub() -> Hub:
	hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	return hub


func _key(code: Key, pressed: bool) -> InputEvent:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.keycode = code
	e.pressed = pressed
	return e


func _mouse(button: MouseButton, pressed: bool) -> InputEvent:
	var e := InputEventMouseButton.new()
	e.button_index = button
	e.pressed = pressed
	e.position = Vector2(-50, -50)
	return e


## A real event through Input, then frames go by.
func _send(e: InputEvent, frames := 2) -> void:
	await get_tree().process_frame
	Input.parse_input_event(e)
	Input.flush_buffered_events()
	for i in frames:
		await get_tree().process_frame


func _tap(code: Key, frames := 3) -> void:
	await _send(_key(code, true), 2)
	await _send(_key(code, false), frames)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


# ---------- the plan ----------

func test_the_plan_turns_into_the_world_and_back() -> void:
	# the spec's own table (2.3, 2.4): local (u, v) and world (x, z)
	assert_almost_eq(HubPlan.to_world(Vector2(0.0, 1.0), 35.0), Vector2(-0.574, -0.819), Vector2(0.01, 0.01), "the camera's point")
	# HV-A: the portal's at the foot of its stairs, the Livro's about 10 m off the axis, the arrival on the Retorno's
	# seal at the south-east (the plan's (18; -11.4))
	assert_almost_eq(HubPlan.use_point(HubPlan.PORTAL, 35.0), Vector2(-6.31, -9.01), Vector2(0.06, 0.06))
	assert_almost_eq(HubPlan.use_point(HubPlan.BOOK, 35.0), Vector2(11.20, -1.62), Vector2(0.06, 0.06))
	assert_almost_eq(HubPlan.to_world(HubPlan.ARRIVAL, 35.0), Vector2(21.28, -0.99), Vector2(0.06, 0.06))
	for p: Vector2 in [Vector2(3, -7), Vector2(-12, 4), Vector2(0.5, 0.25)]:
		assert_almost_eq(HubPlan.to_local(HubPlan.to_world(p, 35.0), 35.0), p, Vector2(0.0001, 0.0001))


func test_the_layout_is_its_own_and_stands_on_the_plan() -> void:
	var l := HubPlan.layout()
	assert_eq(l.look, &"hub")
	assert_true(ArenaRoom.LOOKS.has(&"hub"), "the arena knows the hub's look")
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	for room in stage.layouts:
		assert_ne(room.id, &"hub", "the hub never enters the descent's draw of arenas")
	assert_true(l.floor.contains(l.hero_spawn, Player.RADIUS), "he arrives on the floor")
	for id in HubPlan.STATIONS:
		assert_true(l.floor.contains(HubPlan.use_point(id), Player.RADIUS), "%s's use point is on the floor" % id)
		for other in HubPlan.STATIONS:
			if other != id:
				assert_gt(HubPlan.use_point(id).distance_to(HubPlan.use_point(other)), HubPlan.FOCUS_OUT * 2.0,
					"two stations never both in reach (%s, %s)" % [id, other])
	assert_eq(l.cam_reach, HubPlan.CAM_REACH)
	assert_gt(l.cam_reach, 10.0, "the camera goes wherever he walks in the hub, not 3 m off its point")
	# the floor about twice the first plan's each way (the PO, HUB-B2): 50 x 33 m
	var area := 0.0
	for i in HubPlan.FLOOR.size():
		area += HubPlan.FLOOR[i].cross(HubPlan.FLOOR[(i + 1) % HubPlan.FLOOR.size()]) * 0.5
	# (HUB-D: plus the lobes beside the portal's terrace; HV-A: the south-east corner whole, no well)
	assert_between(absf(area), 1400.0, 1800.0, "about 48 to 52 by 30 to 34 m")


# ---------- focus ----------

func test_focus_comes_in_at_2_2_and_leaves_past_2_8() -> void:
	var f := HubFocus.new({&"a": Vector2.ZERO, &"b": Vector2(10, 0)})
	assert_false(f.step(Vector2(2.3, 0)))
	assert_eq(f.current, &"")
	assert_true(f.step(Vector2(2.1, 0)))
	assert_eq(f.current, &"a")
	assert_false(f.step(Vector2(2.7, 0)), "inside 2.8 it holds")
	assert_eq(f.current, &"a")
	assert_true(f.step(Vector2(2.9, 0)))
	assert_eq(f.current, &"")
	assert_true(f.step(Vector2(8.0, 0)), "the other one")
	assert_eq(f.current, &"b")


func test_focus_gives_way_only_to_one_clearly_nearer() -> void:
	var f := HubFocus.new({&"a": Vector2.ZERO, &"b": Vector2(3, 0)})
	f.step(Vector2(1.4, 0))
	assert_eq(f.current, &"a")
	f.step(Vector2(1.55, 0))
	assert_eq(f.current, &"a", "b is nearer, but not 0.4 m nearer")
	f.step(Vector2(1.75, 0))
	assert_eq(f.current, &"b")


# ---------- the slide ----------

func test_a_body_pushed_at_a_round_middle_slides_round_it() -> void:
	var circles: Array[Vector3] = [Vector3(0, 0, 1.6)]
	var at := Vector2(0, 2.15)
	var way := RoundSlide.steer(at, Vector2(0, -1), 0.1, 0.5, circles)
	assert_almost_eq(way.length(), 1.0, 0.0001, "the speed is kept")
	assert_almost_eq(way.dot(Vector2(0, -1)), 0.0, 0.0001, "head-on: along the edge")
	assert_eq(RoundSlide.steer(at, Vector2(0, -1), 0.1, 0.5, circles), way, "always the same side")
	assert_eq(RoundSlide.steer(at, Vector2(0, 1), 0.1, 0.5, circles), Vector2(0, 1), "walking away: as it is")
	assert_eq(RoundSlide.steer(Vector2(0, 6), Vector2(0, -1), 0.1, 0.5, circles), Vector2(0, -1), "far: as it is")
	var glance := RoundSlide.steer(Vector2(0.5, 2.15), Vector2(0, -1), 0.1, 0.5, circles)
	assert_gt(glance.x, 0.0, "off the middle he slides to his own side")


func test_pushed_straight_at_the_fountain_he_goes_round_it() -> void:
	_hub()
	var up := HubPlan.to_world(Vector2(0, 1))
	hub.player.pos = HubPlan.to_world(Vector2(0, -4))
	var stood := 0
	for i in 240:
		if HubPlan.to_local(hub.player.pos).y > 2.0:
			break
		var was := hub.player.pos
		hub.player.step(DT, up, Vector2.ZERO)
		if hub.player.pos.distance_to(was) < 0.01:
			stood += 1
	assert_gt(HubPlan.to_local(hub.player.pos).y, 2.0, "past the fountain, on the way to the portal")
	assert_lt(stood, 3, "never stopped on the axis")


func test_every_station_is_reached_from_the_arrival() -> void:
	_hub()
	for id in HubPlan.STATIONS:
		hub.player.pos = hub.arena.start
		var target := HubPlan.use_point(id)
		for i in 900:
			var to := target - hub.player.pos
			if to.length() < 0.3:
				break
			hub.player.step(DT, to.normalized(), Vector2.ZERO)
		assert_lt(hub.player.pos.distance_to(target), 0.5, "%s reached walking from the arrival" % id)


# ---------- interact ----------

func test_interact_is_f_and_a_and_listed() -> void:
	assert_true(Controls.ACTIONS.has(&"interact"))
	assert_true(Controls.REMAPPABLE.has(&"interact"), "remappable (Configurações > Controles)")
	assert_eq(Controls.DEFAULT_KEYS[&"interact"], [KEY_F])
	assert_eq(Controls.DEFAULT_PAD[&"interact"], JOY_BUTTON_A)
	assert_eq(Controls.label(&"interact"), "F")
	var listed := false
	for row in HowToScreen.ROWS:
		listed = listed or (row.actions as Array).has(&"interact")
	assert_true(listed, "Como Jogar lists it")
	assert_eq(T.t(&"action_interact"), "Interagir")
	assert_false(T.t(&"howto_interact_desc").contains("—"), "no dash")
	assert_false(T.t(&"howto_interact_desc").contains("{"), "the place's name is filled in")


func test_a_save_that_gave_f_away_keeps_interact_on_a_free_key() -> void:
	assert_eq(Controls.keys_for(&"interact", {}), [KEY_F])
	var f_on_attack := {"light_attack": {"type": "key", "code": KEY_F}}
	assert_eq(Controls.keys_for(&"interact", f_on_attack), [KEY_G])
	f_on_attack["cast"] = {"type": "key", "code": float(KEY_G)}  # as JSON gives it back
	assert_eq(Controls.keys_for(&"interact", f_on_attack), [KEY_T])
	assert_eq(Controls.keys_for(&"dodge", f_on_attack), [KEY_SPACE], "the others keep their defaults as before")
	Save.set_option("bindings", {"light_attack": {"type": "key", "code": KEY_F}})
	Controls.apply_bindings()
	assert_eq(Controls.label(&"interact"), "G")
	assert_eq(Controls.label(&"light_attack"), "F")


func test_rebinding_onto_a_used_key_swaps_them() -> void:
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	assert_true(Controls.rebind(&"interact", space))
	assert_eq(Controls.label(&"interact"), "Space")
	assert_eq(Controls.label(&"dodge"), "F", "the dodge takes interact's old key")
	var keys := {}
	for action in Controls.REMAPPABLE:
		for ev in InputMap.action_get_events(action):
			var entry := Controls.entry_of(ev)
			if entry.is_empty():
				continue
			var k := str(entry)
			assert_false(keys.has(k), "%s shared by %s and %s" % [k, keys.get(k), action])
			keys[k] = action


# ---------- the hero at peace ----------

func test_no_press_in_the_hub_is_a_blow_a_roll_or_a_spell() -> void:
	_hub()
	var acts: Array[String] = []
	hub.player.runner.move_started.connect(func(n: ComboNode) -> void: acts.append("move " + String(n.id)))
	hub.player.dodged.connect(func(_d: Vector2) -> void: acts.append("dodge"))
	hub.player.cast_released.connect(func(_a: Vector2, _o: bool) -> void: acts.append("cast"))
	hub.player.ult_started.connect(func(_d: Vector2) -> void: acts.append("ult"))
	hub.player.ult_refused.connect(func() -> void: acts.append("ult refused"))
	await _frames(3)
	await _send(_mouse(MOUSE_BUTTON_LEFT, true), 2)
	await _send(_mouse(MOUSE_BUTTON_LEFT, false), 2)
	await _send(_mouse(MOUSE_BUTTON_RIGHT, true), 40)
	await _send(_mouse(MOUSE_BUTTON_RIGHT, false), 2)
	for code: Key in [KEY_Q, KEY_E, KEY_SHIFT, KEY_SPACE]:
		await _send(_key(code, true), 40)
		await _send(_key(code, false), 2)
	assert_eq(acts, [] as Array[String], "nothing but walking")
	assert_eq(hub.player.state, Player.State.MOVE)
	assert_false(hub.player.charging)
	assert_eq(hub.find_children("*", "Hud", true, false).size(), 0, "no fight's HUD")
	assert_eq(hub.find_children("*", "Horde", true, false).size(), 0, "nobody to fight")


func test_holding_the_dodge_runs() -> void:
	_hub()
	var way := HubPlan.to_world(Vector2(1, 0))
	hub.player.pos = HubPlan.to_world(Vector2(-6, -4))
	var from := hub.player.pos
	for i in 30:
		hub.player.step(DT, way, Vector2.ZERO)
	var walked := hub.player.pos.distance_to(from)
	assert_almost_eq(walked, Feel.live().speed * 0.5, 0.2, "walks at his speed")
	Input.action_press(&"dodge")
	from = hub.player.pos
	for i in 30:
		hub.player.step(DT, -way, Vector2.ZERO)
	Input.action_release(&"dodge")
	assert_true(hub.player.sprinting)
	assert_almost_eq(hub.player.pos.distance_to(from), Feel.live().speed * Feel.live().sprint_scale * 0.5, 0.3, "runs while held")
	assert_eq(hub.player.state, Player.State.MOVE, "no roll")


# ---------- stations and screens ----------

func test_the_station_in_focus_shows_one_sign_with_the_key() -> void:
	_hub()
	var seen: Array[StringName] = []
	hub.focus_changed.connect(func(id: StringName) -> void: seen.append(id))
	await _frames(2)
	assert_eq(hub.focus.current, &"", "nothing in focus at the arrival")
	assert_null(hub.station_sign)
	hub.player.pos = HubPlan.use_point(HubPlan.BOOK)
	await _frames(2)
	assert_eq(hub.focus.current, HubPlan.BOOK)
	assert_not_null(hub.station_sign)
	assert_eq(hub.station_sign.title.text, T.t(&"hub_book"))
	assert_eq(hub.station_sign.key_text(), "F", "the real key")
	assert_eq(hub.find_children("*", "StationSign", true, false).size(), 1, "one sign")
	hub.player.pos = hub.arena.start
	await _frames(3)
	assert_eq(seen, [HubPlan.BOOK, &""] as Array[StringName])
	assert_eq(hub.find_children("*", "StationSign", true, false).filter(func(n: Node) -> bool: return not n.is_queued_for_deletion()).size(), 0)


func test_interact_opens_a_station_and_esc_closes_it_without_leaking() -> void:
	_hub()
	hub.player.pos = HubPlan.use_point(HubPlan.SMITH)
	await _frames(2)
	await _tap(KEY_F)
	assert_true(hub.host.is_open(), "F on the Forjador opens its page")
	if hub.host.screen is HubPanel:
		# Lote 5: once the Forja is behind him the Forjador asks first (A Forja or O Preparo)
		(hub.host.screen as HubPanel).buttons[0].pressed.emit()
		await _frames(3)
	assert_true(hub.host.screen is ForgeScreen, "the Forja (Rejogabilidade, Fatia 1)")
	await _tap(KEY_F)
	assert_true(hub.host.is_open(), "F again does not open a second one")
	await _send(_key(KEY_ESCAPE, true), 3)
	assert_false(hub.host.is_open(), "Esc closes it")
	await _send(_key(KEY_ESCAPE, false), 4)
	assert_false(hub.host.is_open(), "the Esc that closed it opens no menu")
	await _tap(KEY_ESCAPE, 3)
	assert_true(hub.host.screen is PauseMenu, "a new Esc opens the hub's menu")
	assert_true((hub.host.screen as PauseMenu).hub)
	assert_null(hub.host.screen.find_child("boons", true, false), "no Bênçãos of a descent")
	await _tap(KEY_ESCAPE, 3)
	assert_false(hub.host.is_open(), "and Esc closes it")


func test_the_tree_opens_the_medallion_and_the_book_the_livro() -> void:
	_hub()
	hub.use(HubPlan.TREE)
	assert_true(hub.host.screen is DonsScreen, "the Árvore de Dons opens the Gifts medallion")
	hub.host.close()
	await _frames(1)
	hub.use(HubPlan.BOOK)
	assert_true(hub.host.screen is HeroScreen)
	assert_eq(int(hub.host.screen.get(&"chapter")), int(HeroScreen.Chapter.HERO))
	hub.host.close()
	await _frames(1)


func test_the_hub_menu_goes_back_to_the_title() -> void:
	_hub()
	hub.open_menu()
	(hub.host.screen.find_child("quit", true, false) as Button).pressed.emit()
	assert_eq(went, [SceneGo.TITLE] as Array[String])
	assert_eq((hub.host.screen.find_child("quit", true, false) as Button).text, T.t(&"hub_to_title"))


func test_the_portal_asks_and_goes_down() -> void:
	_hub()
	Save.data.wins = 0
	hub.player.pos = HubPlan.use_point(HubPlan.PORTAL)
	await _frames(2)
	await _tap(KEY_F)
	var panel := hub.host.screen as HubPanel
	assert_not_null(panel, "a short confirmation")
	(panel.find_child("stay", true, false) as Button).pressed.emit()
	await _frames(2)
	assert_false(hub.host.is_open())
	assert_eq(went, [] as Array[String], "Ficar stays")
	hub.use(HubPlan.PORTAL)
	(hub.host.screen.find_child("go", true, false) as Button).pressed.emit()
	await wait_seconds(Hub.FADE + 0.3)
	assert_eq(went, [SceneGo.GAME] as Array[String], "Descer goes to the run")


func test_after_a_victory_the_portal_shows_the_juramentos_first() -> void:
	_hub()
	Save.data.wins = 1
	hub.use(HubPlan.PORTAL)
	(hub.host.screen.find_child("go", true, false) as Button).pressed.emit()
	await _frames(2)
	assert_true(hub.host.screen is JuramentoScreen, "the Juramentos, as the title's Iniciar had them")
	assert_eq(went, [] as Array[String])
	(hub.host.screen as JuramentoScreen).descend.emit()
	await wait_seconds(Hub.FADE + 0.3)
	assert_eq(went, [SceneGo.GAME] as Array[String])


# ---------- the flow ----------

func test_the_end_screen_and_the_pause_go_back_to_the_hub() -> void:
	var game: Game = (load(SceneGo.GAME) as PackedScene).instantiate()
	add_child_autofree(game)
	game._open_end(false, false)
	var end := game.find_children("*", "EndScreen", true, false)[0] as EndScreen
	var to_menu := end.find_child("menu", true, false) as Button
	assert_eq(to_menu.text, "Continuar", "PT-25-6: the Espólios' Continuar goes on to the hub")
	to_menu.pressed.emit()
	(end.find_child("retry", true, false) as Button).pressed.emit()
	assert_eq(went, [SceneGo.HUB, SceneGo.GAME] as Array[String], "Voltar goes to the hub, Descer de novo still goes down")
	went.clear()
	var pause := PauseMenu.new()
	add_child_autofree(pause)
	pause.open()
	(pause.find_child("quit", true, false) as Button).pressed.emit()
	assert_eq(went, [SceneGo.HUB] as Array[String], "the pause's way out goes to the hub")


func test_iniciar_goes_to_the_hub_and_hub_skips_the_title() -> void:
	var boot: Node = (load(SceneGo.TITLE) as PackedScene).instantiate()
	add_child_autofree(boot)
	await _frames(2)
	boot.call(&"_start")
	await wait_seconds(0.8)
	assert_eq(went, [SceneGo.HUB] as Array[String], "Iniciar always goes to the hub (D-H5)")
	Dev.put("hub")
	assert_eq(boot.call(&"route"), SceneGo.HUB, "--hub")
	Dev.put("bot")
	assert_eq(boot.call(&"route"), SceneGo.GAME, "--bot still skips title and hub")
	Dev.drop("bot")
	Dev.put("title")
	assert_eq(boot.call(&"route"), "", "--title shows the title")
	Dev.drop("title")
	Dev.drop("hub")
	Dev.put("shot")
	assert_eq(boot.call(&"route"), SceneGo.GAME, "--shot alone is a run")
	Dev.drop("shot")


## A fake save (its own file, never the player's): a death, the hub, the Portal and a new descent, and a second death.
## The Mastery, the Gifts unlocked and the Compêndio are counted once per run, never again by the hub or the new run.
func test_death_hub_portal_and_a_new_descent_double_nothing() -> void:
	var path := "user://test_hub_save.json"
	var runs := "user://test_hub_runs.jsonl"
	var kept := Save.data
	Save.data = SaveData.defaults()
	Save.data.first = FirstDescent.DONE  # not the guided descent (its own rules: test_first_descent.gd)
	Save.enabled = true
	Save.path = path
	Dev.put("runlog", runs)
	var logged: Array[String] = []  # a lambda captures a local int by value
	var game := _run()
	game.run_logged.connect(func(o: String, _e: Dictionary) -> void: logged.append(o))
	game.rooms.won.append_array([RunMap.Kind.COMBAT, RunMap.Kind.COMBAT])
	game.seen_boons[&"brasas"] = true
	game.defeated[&"skeleton"] = 3
	game.player.hurt(999.0, game.player.pos + Vector2.RIGHT)
	var block := SaveData.hero(Save.data, SaveData.FIRST_HERO)
	var xp := int(block.mastery_xp)
	assert_gt(xp, 0, "the death kept its Mastery")
	assert_eq(int(Save.data.runs), 1)
	var after_death: Dictionary = Save.data.duplicate(true)
	game.free()  # the end screen's Voltar ao Santuário: the run leaves the tree
	assert_eq(logged, ["death"] as Array[String], "logged once")
	assert_eq(Save.data, after_death, "leaving after the end logs nothing more")
	_hub()
	await _frames(3)
	hub.use(HubPlan.PORTAL)
	(hub.host.screen.find_child("go", true, false) as Button).pressed.emit()
	await wait_seconds(Hub.FADE + 0.3)
	assert_eq(went, [SceneGo.GAME] as Array[String])
	assert_eq(Save.data, after_death, "the hub writes nothing")
	hub.free()
	var second := _run()
	assert_eq(second.boons.owned().size(), 0, "a clean descent: no Bênção")
	assert_eq(second.rooms.won.size(), 0)
	assert_eq(second.defeated.size(), 0)
	assert_eq(Save.data, after_death, "starting a descent doubles nothing")
	second.rooms.won.append(RunMap.Kind.COMBAT)
	second.player.hurt(999.0, second.player.pos + Vector2.RIGHT)
	assert_eq(int(Save.data.runs), 2)
	var gain := int(second.mastery_report.get("gain", {}).get("total", 0))
	assert_gt(gain, 0)
	assert_eq(int(SaveData.hero(Save.data, SaveData.FIRST_HERO).mastery_xp), xp + gain, "only the second run's own XP")
	assert_eq(int(Save.data.codex.enemies.skeleton.defeated), 3, "the first run's enemies counted once")
	second.free()
	Save.enabled = false
	Save.path = Save.PATH
	Save.data = kept
	Dev.drop("runlog")
	for f in [path, runs, path + SaveFile.BAK, path + ".tmp"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


func _run() -> Game:
	var g: Game = (load(SceneGo.GAME) as PackedScene).instantiate()
	add_child(g)
	g.rooms.start_at(RunMap.Kind.FOUNTAIN)
	return g
