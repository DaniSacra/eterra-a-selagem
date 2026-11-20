extends SceneTree
## Drives the title like a player (keyboard): Iniciar goes to the hub (its menu and a station open and close with Esc;
## the Portal, with the Juramentos after a victory, starts the run), the pause's way back reaches the hub and the hub's
## menu the title again,
## O Guerreiro opens the hero screen (a Gift goes on and off with Enter, the arrows walk the tree), Como Jogar opens
## the Compêndio, Como Jogar and Configurações open and close with Esc, focus moves with the arrows, the comfort switches flip with
## Enter and keep the focus, Configurações opens Músicas and Esc comes back from it. The gamepad's RB and LB (real
## joypad button events) turn the Livro's chapters, Como Jogar's tabs, the Compendium's index and the options' tabs
## (DT-103). First of all the choice of save (save slots, 2026-11-19) on saves of its own (a folder of the check's,
## never the player's): the screen opens first, right walks the cards, down reaches Apagar, the question opens on
## Cancelar and Esc closes it, Apagar erases the save and its copy, Enter on a card puts it in use and gives the title,
## Esc on the title opens the choice again and Esc closes it. Prints FLOW ok or FLOW FAIL.
## ~/tools/godot/godot --headless --path . -s tools/title_flow_check.gd

var _fail := 0


func _initialize() -> void:
	# a check, not a person's run: nothing written to the save or the run log (as --nosave)
	(func() -> void: root.get_node("Save").set("enabled", false)).call_deferred()
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok   " if ok else "FAIL ") + what)
	if not ok:
		_fail += 1


func _key(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	await process_frame
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)
	await process_frame
	await process_frame


## A press and release of a gamepad button (LB, RB), as the pad sends it.
func _pad(button: JoyButton) -> void:
	for down: bool in [true, false]:
		var e := InputEventJoypadButton.new()
		e.button_index = button
		e.pressed = down
		Input.parse_input_event(e)
		await process_frame
	await process_frame


func _sub_is(boot: Node, file: String) -> bool:
	var sub = boot.get(&"_sub")
	return sub != null and String(sub.get_script().resource_path).ends_with(file)


func _wait(s: float) -> void:
	await create_timer(s).timeout


## The comfort switches by keys: Enter flips one and the focus stays on it, down reaches the next. Each is flipped
## back afterwards.
func _comfort(options: Node) -> void:
	var save := root.get_node("Save")
	var first := options.find_child("opt_impact_frames", true, false) as Control
	_check(first != null, "the options have Clarões de impacto")
	if first == null:
		return
	first.grab_focus()
	await process_frame
	for key: String in ["impact_frames", "slow_motion", "color_split", "rumble"]:
		var before: bool = save.call(&"option", key)
		await _key(&"ui_accept")
		_check(save.call(&"option", key) == not before, "Enter flips %s" % key)
		var row := options.find_child("opt_" + key, true, false) as Control
		_check(row != null and row.has_focus(), "the focus stays on %s" % key)
		await _key(&"ui_accept")
		_check(save.call(&"option", key) == before, "Enter flips %s back" % key)
		if key != "rumble":
			await _key(&"ui_down")


## Configurações → Músicas → back (T5): Enter on Músicas opens the list with the focus on the title's choice, Esc goes
## back to the options (not to the title) with the focus on Músicas.
func _music_room(options: Node) -> void:
	var button := options.find_child("music_room", true, false) as Control
	_check(button != null, "the options have Músicas")
	if button == null:
		return
	button.grab_focus()
	await process_frame
	await _key(&"ui_accept")
	var rooms := options.find_children("*", "MusicRoomScreen", true, false)
	_check(rooms.size() == 1, "Músicas opens")
	await process_frame
	var owner_ := root.gui_get_focus_owner()
	_check(owner_ != null and owner_.name == "place_title_1", "the focus starts on the title's music")
	await _key(&"ui_down")
	owner_ = root.gui_get_focus_owner()
	_check(owner_ != null and owner_ != button and rooms[0].is_ancestor_of(owner_), "down moves inside Músicas")
	await _key(&"ui_cancel")
	await _wait(0.1)
	_check(options.find_children("*", "MusicRoomScreen", true, false).is_empty() and options.is_inside_tree(), "Esc goes back to the options")
	var back := options.find_child("music_room", true, false) as Control
	_check(back != null and back.has_focus(), "focus back on Músicas")


## The hero screen (the Livro de Ahk) by keys: it opens on the Warrior with the focus on Dons; Enter opens the Gifts
## with the focus on a Gift, Enter puts it on and takes it off, down walks to another node.
func _hero(screen: Node) -> void:
	var first := root.gui_get_focus_owner()
	_check(first != null and first.name == "to_gifts", "the book opens on the Warrior, the focus on Dons")
	await _key(&"ui_accept")
	var owner_ := root.gui_get_focus_owner()
	_check(owner_ != null and owner_.get_script() != null and String(owner_.get_script().resource_path).ends_with("talent_node.gd"),
		"the focus starts on a Gift")
	if owner_ == null:
		return
	var block: Dictionary = screen.get(&"loadout").get(&"block")
	var id := String(owner_.get(&"def").get(&"id"))
	var had: bool = (block.equipped as Array).has(id)
	await _key(&"ui_accept")
	_check((block.equipped as Array).has(id) != had, "Enter puts %s on (or off)" % id)
	await _key(&"ui_accept")
	_check((block.equipped as Array).has(id) == had, "Enter again takes it back")
	await _key(&"ui_down")
	var moved := root.gui_get_focus_owner()
	_check(moved != null and moved != owner_, "down walks the tree")
	var at := int(screen.get(&"chapter"))
	await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	_check(int(screen.get(&"chapter")) == (at + 1) % 3, "RB turns to the next chapter")
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check(int(screen.get(&"chapter")) == at, "LB turns back")


## Como Jogar's Compêndio by keys: it opens on the Gifts tab, down the index shows Bênçãos, Esc goes back to Como Jogar.
func _codex(howto: Node) -> void:
	await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	_check(int(howto.get(&"tab")) == 1, "RB shows Como Jogar's Controles")
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check(int(howto.get(&"tab")) == 0, "LB back to A descida")
	var button := howto.find_child("moves", true, false) as Control
	_check(button != null, "Como Jogar has the Compêndio")
	if button == null:
		return
	button.grab_focus()
	await process_frame
	await _key(&"ui_accept")
	var codex := howto.find_children("*", "CodexScreen", true, false)
	_check(codex.size() == 1, "Compêndio opens")
	if codex.is_empty():
		return
	await _key(&"ui_down")
	_check(int(codex[0].get(&"tab")) == 1, "down shows Bênçãos")
	await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	_check(int(codex[0].get(&"tab")) == 2, "RB shows Elos")
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check(int(codex[0].get(&"tab")) == 1, "LB back to Bênçãos")
	await _key(&"ui_cancel")
	await _wait(0.1)
	_check(howto.find_children("*", "CodexScreen", true, false).is_empty() and howto.is_inside_tree(), "Esc goes back to Como Jogar")


## The Juramentos (E6) by keys at the hub's Portal, once Morvath was sealed (wins 1, in memory only): interact on the
## Portal and Enter on Descer open them with Descer in focus, up reaches a Juramento, right raises its rank and left
## lowers it (saved in Save.data), Esc goes back to the hub; then the Portal shows them again.
func _juramentos(hub: Node) -> void:
	var save := root.get_node("Save")
	var data: Dictionary = save.get(&"data")
	data.wins = 1
	await _portal(hub)
	_check(_shown_is(hub, "juramento_screen.gd"), "after a victory the Portal opens the Juramentos")
	var owner_ := root.gui_get_focus_owner()
	_check(owner_ != null and owner_.name == "descend", "the focus starts on Descer")
	await _key(&"ui_up")
	var row := root.gui_get_focus_owner()
	var id := String(row.name) if row else ""
	_check(id == "rivals", "up reaches the last Juramento (%s)" % id)
	await _key(&"ui_right")
	_check(int((data.juramentos.ranks as Dictionary).get(id, 0)) == 1, "right raises %s to 1" % id)
	_check(root.gui_get_focus_owner() == row, "the focus stays on the row")
	await _key(&"ui_left")
	_check(int((data.juramentos.ranks as Dictionary).get(id, 0)) == 0, "left takes it off")
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(not hub.get(&"host").call(&"is_open"), "Esc closes the Juramentos, back in the hub")


func _shown_is(hub: Node, file: String) -> bool:
	var s = hub.get(&"host").get(&"screen")
	return s != null and is_instance_valid(s) and String(s.get_script().resource_path).ends_with(file)


## Stands at the Portal, interact (the real key's action) and Enter on Descer (in focus).
func _portal(hub: Node) -> void:
	var player = hub.get(&"player")
	player.set(&"pos", _use_point(&"portal"))
	await _wait(0.2)
	await _key(&"interact")
	await _wait(0.2)
	_check(_shown_is(hub, "hub_panel.gd"), "interact on the Portal asks to go down")
	var focus := root.gui_get_focus_owner()
	_check(focus != null and focus.name == "go", "the focus on Descer")
	await _key(&"ui_accept")
	await _wait(0.3)


func _use_point(id: StringName) -> Vector2:
	return load("res://scripts/core/hub_plan.gd").call(&"use_point", id)


## The hub by keys: it opens with nothing on screen; Esc opens its menu (Configurações, Voltar ao título), Esc closes
## it; the Forjador's page opens with interact and closes with Esc.
func _hub(hub: Node) -> void:
	var host = hub.get(&"host")
	_check(not host.call(&"is_open"), "the hub opens with nothing on screen")
	hub.get(&"player").set(&"pos", _use_point(&"smith"))
	await _wait(0.2)
	var sign = hub.get(&"station_sign")
	_check(sign != null and sign.call(&"key_text") == load("res://scripts/ui/ui_kit.gd").call(&"action_label", &"interact"), "the Forjador's sign names the real key (%s)" % sign.call(&"key_text"))
	await _key(&"interact")
	_check(_shown_is(hub, "forge_screen.gd"), "interact on the Forjador opens the Forja")
	var page = host.get(&"screen")
	_check(page.get(&"back_button") != null and page.get(&"back_button").name == &"back", "the Forja (Rejogabilidade Fatia 1) has Voltar")
	var focused: Control = hub.get_viewport().gui_get_focus_owner()
	_check(focused != null and page.is_ancestor_of(focused), "the focus is on the Forja (%s)" % (focused.name if focused else "none"))
	_check(not sign.get(&"plate").visible, "no sign over the page")
	await _key(&"ui_cancel")
	await _wait(0.1)
	_check(not host.call(&"is_open"), "Esc closes it")
	_check(sign.get(&"plate").visible, "the sign comes back")
	hub.get(&"player").set(&"pos", hub.get(&"arena").get(&"start"))
	await _wait(0.2)
	await _key(&"pause")
	_check(_shown_is(hub, "pause_menu.gd"), "Esc opens the hub's menu")
	_check(host.get(&"screen").find_child("howto", true, false) != null, "the hub's menu has Como Jogar")
	await _key(&"ui_cancel")
	await _wait(0.1)
	_check(not host.call(&"is_open"), "Esc closes the hub's menu")


const SLOTS_DIR := "user://flow_check_slots/"


## The choice of save by keys, on saves in a folder of the check's (Save 2 exists with its copy, 1 and 3 are empty).
func _slots() -> void:
	var save := root.get_node("Save")
	DirAccess.make_dir_recursive_absolute(SLOTS_DIR)
	var text := JSON.stringify({"version": 7, "runs": 4, "wins": 1, "played_at": 1795000000})
	for ext: String in ["", ".bak"]:
		var f := FileAccess.open(SLOTS_DIR + "save_2.json" + ext, FileAccess.WRITE)
		f.store_string(text)
		f.close()
	save.set(&"base", SLOTS_DIR)
	save.set(&"slot", 0)
	save.set(&"chosen", false)
	save.set(&"enabled", true)
	change_scene_to_file("res://scenes/boot.tscn")
	await _wait(1.0)
	var boot := current_scene
	_check(_sub_is(boot, "save_slot_screen.gd"), "the first screen is the choice of save")
	var screen = boot.get(&"_sub")
	if screen == null:
		return
	var cards: Array = screen.get(&"cards")
	_check(cards[0].has_focus(), "the focus starts on Save 1")
	_check(cards[0].find_child("empty", true, false) != null and cards[1].find_child("date", true, false) != null, "Save 1 empty, Save 2 with its day")
	await _key(&"ui_right")
	_check(cards[1].has_focus(), "right moves to Save 2")
	await _key(&"ui_cancel")
	_check(_sub_is(boot, "save_slot_screen.gd"), "Esc does not close the first screen")
	await _key(&"ui_down")
	var erasers: Array = screen.get(&"erasers")
	_check(erasers[1].has_focus(), "down reaches Save 2's Apagar")
	await _key(&"ui_accept")
	await process_frame
	var focus := root.gui_get_focus_owner()
	_check(screen.get(&"question") != null and focus != null and focus.name == "no", "Apagar asks first, Cancelar in focus")
	await _key(&"ui_cancel")
	await process_frame
	_check(screen.get(&"question") == null and erasers[1].has_focus(), "Esc closes the question, back on Apagar")
	_check(FileAccess.file_exists(SLOTS_DIR + "save_2.json"), "nothing erased yet")
	await _key(&"ui_accept")
	await process_frame
	await _key(&"ui_left")
	focus = root.gui_get_focus_owner()
	_check(focus != null and focus.name == "yes", "left reaches Apagar in the question")
	await _key(&"ui_accept")
	await process_frame
	_check(not FileAccess.file_exists(SLOTS_DIR + "save_2.json") and not FileAccess.file_exists(SLOTS_DIR + "save_2.json.bak"), "Apagar erases Save 2 and its copy")
	cards = screen.get(&"cards")
	_check(cards[1].has_focus() and cards[1].find_child("empty", true, false) != null, "Save 2 is empty now, in focus")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(int(save.get(&"slot")) == 2 and FileAccess.file_exists(SLOTS_DIR + "save_2.json"), "Enter on Save 2 starts a new save there")
	var menu = boot.get(&"_menu")
	_check(boot.get(&"_sub") == null and menu.visible and menu.button(0).has_focus(), "the title comes after, Iniciar in focus")
	await _key(&"ui_cancel")
	await _wait(0.2)
	_check(_sub_is(boot, "save_slot_screen.gd"), "Esc on the title opens the choice of save again")
	await _key(&"ui_cancel")
	await _wait(0.2)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes it (a save is in use)")
	save.set(&"enabled", false)
	save.set(&"base", "user://")
	for f: String in DirAccess.get_files_at(SLOTS_DIR):
		DirAccess.remove_absolute(SLOTS_DIR + f)
	DirAccess.remove_absolute(SLOTS_DIR)


func _run() -> void:
	await _slots()
	change_scene_to_file("res://scenes/boot.tscn")
	await _wait(1.5)
	var boot := current_scene
	_check(boot != null and boot.name == "Boot", "title opens")
	var menu = boot.get(&"_menu")  # untyped: a -s script compiles before the autoloads exist
	_check(menu.button(0).has_focus(), "focus starts on Iniciar")
	await _key(&"ui_down")
	_check(menu.button(1).has_focus(), "down moves to O Guerreiro")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "hero_screen.gd"), "O Guerreiro opens the hero screen")
	await _hero(boot.get(&"_sub"))
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes the hero screen")
	_check(menu.button(1).has_focus(), "focus back on O Guerreiro")
	await _key(&"ui_down")
	_check(menu.button(2).has_focus(), "down moves to Como Jogar")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "how_to_screen.gd"), "Como Jogar opens its screen")
	await _codex(boot.get(&"_sub"))
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null and menu.visible, "Esc closes it")
	_check(menu.button(2).has_focus(), "focus back on Como Jogar")
	await _key(&"ui_down")
	await _key(&"ui_accept")
	await _wait(0.3)
	_check(_sub_is(boot, "options_screen.gd"), "Configurações opens the options")
	var options = boot.get(&"_sub")
	var tab_at := int(options.get(&"tab"))
	await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	_check(int(options.get(&"tab")) == tab_at + 1, "RB shows the next tab of Configurações")
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check(int(options.get(&"tab")) == tab_at, "LB back")
	await _comfort(boot.get(&"_sub"))
	await _music_room(boot.get(&"_sub"))
	await _key(&"ui_cancel")
	await _wait(0.3)
	_check(boot.get(&"_sub") == null, "Esc closes the options")
	await _key(&"ui_down")
	_check(menu.button(4).has_focus(), "down reaches Sair")
	await _key(&"ui_up")
	await _key(&"ui_up")
	await _key(&"ui_up")
	await _key(&"ui_up")
	_check(menu.button(0).has_focus(), "up returns to Iniciar")
	await _key(&"ui_accept")
	await _wait(1.5)
	var hub := current_scene
	_check(hub != null and hub.scene_file_path == "res://scenes/hub.tscn", "Iniciar goes to the hub")
	await _hub(hub)
	await _juramentos(hub)
	await _portal(hub)
	_check(_shown_is(hub, "juramento_screen.gd"), "the Portal shows the Juramentos again")
	await _key(&"ui_accept")
	await _wait(2.0)
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/game.tscn", "Descer starts the run")
	await _wait(0.5)
	await _key(&"pause")
	await _wait(0.3)
	var way := current_scene.find_child("quit", true, false) as Button
	_check(way != null and way.is_visible_in_tree(), "the pause has the way back to the hub")
	if way:
		way.grab_focus()
		await _key(&"ui_accept")
	await _wait(1.5)
	hub = current_scene
	_check(hub != null and hub.scene_file_path == "res://scenes/hub.tscn", "the pause goes back to the hub")
	await _key(&"pause")
	await _wait(0.2)
	way = hub.find_child("quit", true, false) as Button
	_check(way != null, "the hub's menu has Voltar ao título")
	if way:
		way.grab_focus()
		await _key(&"ui_accept")
	await _wait(1.5)
	_check(current_scene != null and current_scene.name == "Boot" and current_scene.get(&"_menu") != null, "back to the title from the hub")
	print("FLOW ok" if _fail == 0 else "FLOW FAIL %d" % _fail)
	quit(_fail)
