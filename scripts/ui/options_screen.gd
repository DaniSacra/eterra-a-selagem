class_name OptionsScreen
extends Control
## Configurações (art pack board 10): one framed page with tabs: Áudio (volumes as gauges, and Músicas: MusicRoomScreen,
## T5, hear every piece and choose the title's, the rooms' and Morvath's), Vídeo (window size, full screen, graphics
## quality), Conforto (screen shake, impact frames, slow motion, colour split, gamepad vibration; all on by default, the
## run reads them in Game.apply_options) and Controles (key remapping and the default keys). Everything is saved at
## once. Each row is a button or a "< value >" pair: arrows, Enter, the gamepad's pad and A, and the mouse all work.
## Moving onto a tab shows its page; down goes into it. The focus kept across a rebuild opens the page it is on.

signal closed

enum Tab { AUDIO, VIDEO, COMFORT, CONTROLS }

const TAB_KEY: Array[StringName] = [&"options_tab_audio", &"options_tab_video", &"options_comfort", &"options_tab_controls"]
const TAB_NAME: Array[String] = ["tab_audio", "tab_video", "tab_comfort", "tab_controls"]
const VOLUMES: Array[String] = ["master", "music", "sfx"]
## The comfort switches (save option -> text "opt_<option>"), in their order on screen.
const COMFORT: Array[String] = ["shake", "impact_frames", "slow_motion", "color_split", "rumble"]
## Turning the gamepad's vibration on gives a short buzz on every pad, so the player feels what it does: weak motor,
## strong motor, seconds. The run reads the option as Save.option("rumble") (cycle C12d, GF-11).
const RUMBLE_TRY := Vector3(0.3, 0.5, 0.18)
## Height of a row and the gap between rows.
const ROW := 42.0
const ROW_GAP := 6
const WIDTH := 780.0
const TAB_WIDTH := 172.0
## The page under the tabs is this tall (the tallest, Controles, fits it), so the tabs and Voltar never move.
const PAGE_HEIGHT := 400.0
## The value between a row's arrows.
const VALUE_WIDTH := 280.0

var tab := Tab.AUDIO
var tabs: Array[Button] = []
var pages: Array[VBoxContainer] = []
var _list: VBoxContainer
var _waiting: StringName = &""
var _focus_key := ""


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


func _enter_tree() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus)


func _exit_tree() -> void:
	if get_viewport().gui_focus_changed.is_connected(_on_focus):
		get_viewport().gui_focus_changed.disconnect(_on_focus)


func _build() -> void:
	for c in get_children():
		# out of the tree at once: the focus is restored by name, and the old row must not answer for the new one
		remove_child(c)
		c.queue_free()
	tabs.clear()
	pages.clear()
	var v := UiKit.page(self, T.t(&"options_title"), WIDTH, 0.8, 36)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 6)
	v.add_child(row)
	var holder := PanelContainer.new()
	holder.add_theme_stylebox_override(&"panel", UiKit.box(Color(0.02, 0.018, 0.03, 0.65), UiKit.OLD_GOLD.darkened(0.25), 1, 16, 3))
	holder.custom_minimum_size.y = PAGE_HEIGHT
	v.add_child(holder)
	for t: int in Tab.values():
		var b := UiKit.tab(T.t(TAB_KEY[t]), TAB_WIDTH)
		b.name = TAB_NAME[t]
		b.focus_entered.connect(_show_tab.bind(t))
		b.pressed.connect(_show_tab.bind(t))
		row.add_child(b)
		tabs.append(b)
		var page := VBoxContainer.new()
		page.name = "page_" + TAB_NAME[t].trim_prefix("tab_")
		page.add_theme_constant_override(&"separation", ROW_GAP)
		holder.add_child(page)
		pages.append(page)
	_list = pages[Tab.AUDIO]
	for key in VOLUMES:
		_stepper("opt_" + key, "%d%%" % roundi(float(Save.option(key)) * 100.0), func(dir: int) -> void:
			_set_volume(key, float(Save.option(key)) + dir * 0.1), float(Save.option(key)),
			func(f: float) -> void:
				_focus_key = "opt_%s_1" % key
				_set_volume(key, f)
				_build())
	# T5: the music to hear and to choose for the title, the rooms and Morvath (MusicRoomScreen)
	var music := UiKit.button(T.t(&"options_music"), _open_music, 260)
	music.name = "music_room"
	music.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_list.add_child(_gap(8))
	_list.add_child(music)
	_list = pages[Tab.VIDEO]
	var win := App.window_size()
	_stepper("opt_scale", "%dx%d" % [win.x, win.y], func(dir: int) -> void:
		Save.set_option("scale", clampi(int(Save.option("scale")) + dir, 1, App.WINDOW_SIZES.size()))
		App.apply_options())
	_toggle("opt_fullscreen", "fullscreen")
	# E6 (DT-003): Alta, Média, Baixa (GraphicsQuality); the run in progress gets it when the pause closes
	_stepper("opt_quality", T.t(GraphicsQuality.TEXT[GraphicsQuality.clamp_level(int(Save.option("quality")))]), func(dir: int) -> void:
		Save.set_option("quality", GraphicsQuality.clamp_level(int(Save.option("quality")) + dir))
		App.apply_options())
	# the near camera (Daniel, 2026-11-19; CamRig.near, read every frame: the run behind the pause moves at once)
	_stepper("opt_camera", T.t("opt_camera_near" if String(Save.option("camera")) == "near" else "opt_camera_far"), func(_dir: int) -> void:
		Save.set_option("camera", "far" if String(Save.option("camera")) == "near" else "near"))
	_list = pages[Tab.COMFORT]
	for option in COMFORT:
		_toggle("opt_" + option, option)
	_list = pages[Tab.CONTROLS]
	var keys := GridContainer.new()
	keys.columns = 2
	keys.add_theme_constant_override(&"h_separation", 12)
	keys.add_theme_constant_override(&"v_separation", ROW_GAP)
	_list.add_child(keys)
	for action in Controls.REMAPPABLE:
		var waiting := _waiting == action
		var b := UiKit.button(T.t("action_" + action), func() -> void:
			_waiting = action
			_focus_key = "key_" + action
			_build())
		b.name = "key_" + action
		b.custom_minimum_size = Vector2(340, ROW)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_state(b, T.t(&"options_press") if waiting else UiKit.action_label(action), UiKit.PALE if waiting else UiKit.GOLD)
		keys.add_child(b)
	var reset := UiKit.button(T.t(&"options_reset"), func() -> void:
		_focus_key = "options_reset"
		Controls.reset_bindings()
		_build(), 260)
	reset.name = "options_reset"
	reset.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_list.add_child(_gap(4))
	_list.add_child(reset)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	var f := UiKit.foot()
	f.add_child(back)
	v.add_child(f)
	_link_tabs()
	var target := _focus_target()
	_show_tab(_page_of(target) if target else tab)
	_restore_focus.call_deferred()


## Down from a tab goes to the first row of its page; up from a page's first row back to its tab.
func _link_tabs() -> void:
	for t in tabs.size():
		var first := _first_focusable(pages[t])
		if first == null:
			continue
		tabs[t].focus_neighbor_bottom = tabs[t].get_path_to(first)
		var row := first.get_parent()
		for c in row.get_children():
			if c is Control and (c as Control).focus_mode == Control.FOCUS_ALL:
				(c as Control).focus_neighbor_top = (c as Control).get_path_to(tabs[t])


func _first_focusable(n: Node) -> Control:
	for c in n.get_children():
		if c is Control and (c as Control).focus_mode == Control.FOCUS_ALL:
			return c
		var deeper := _first_focusable(c)
		if deeper:
			return deeper
	return null


## Shows a tab's page (the tab lit).
func _show_tab(t: int) -> void:
	tab = t as Tab
	for i in tabs.size():
		tabs[i].set_pressed_no_signal(i == t)
		pages[i].visible = i == t


## LB and RB (PageUp, PageDown) go to the tab before or after (DT-103); not while a key waits to be bound, nor under
## Músicas.
func _unhandled_input(event: InputEvent) -> void:
	if _waiting != &"" or not find_children("*", "MusicRoomScreen", false, false).is_empty():
		return
	if UiKit.step_tabs(event, tabs, tab):
		get_viewport().set_input_as_handled()


## The page a control is on (the open tab when it is on none).
func _page_of(c: Control) -> int:
	for i in pages.size():
		if pages[i].is_ancestor_of(c):
			return i
	return tab


## A row of another page took the focus (by name after a rebuild, or a test): its page shows.
func _on_focus(c: Control) -> void:
	if c == null or pages.is_empty() or not is_ancestor_of(c):
		return
	var p := _page_of(c)
	if p != tab or not pages[p].visible:
		_show_tab(p)


func _set_volume(key: String, value: float) -> void:
	Save.set_option(key, clampf(snappedf(value, 0.1), 0.0, 1.0))
	App.apply_options()


## Músicas over this page; back here with the focus on its button (the room puts the game's music back itself).
func _open_music() -> void:
	_focus_key = "music_room"
	for c in get_children():
		(c as CanvasItem).visible = false
	var room := MusicRoomScreen.new()
	add_child(room)
	room.open()
	room.closed.connect(_build)


func _focus_target() -> Control:
	if _focus_key == "":
		return null
	return find_child(_focus_key, true, false) as Control


func _restore_focus() -> void:
	var target := _focus_target()
	if target == null:
		target = tabs[tab]
	target.grab_focus()


func _gap(h: float) -> Control:
	var g := Control.new()
	g.custom_minimum_size.y = h
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g


## A row "< value >": left and right change it, so it works the same with keys, mouse and gamepad. With a fraction
## (0..1) the value is a gauge (the volumes); a click on the gauge sets it there (set_to).
func _stepper(text_key: String, value: String, change: Callable, fraction: float = -1.0, set_to: Callable = Callable()) -> void:
	var row := HBoxContainer.new()
	row.name = text_key
	var l := UiKit.label(T.t(text_key), UiKit.PALE, 22)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	for dir: int in [-1, 1]:
		var b := UiKit.button("<" if dir < 0 else ">", func() -> void:
			_focus_key = "%s_%d" % [text_key, dir]
			change.call(dir)
			_build())
		b.name = "%s_%d" % [text_key, dir]
		b.custom_minimum_size = Vector2(ROW, ROW)
		row.add_child(b)
		if dir < 0:
			if fraction >= 0.0:
				var g := Gauge.new()
				g.fraction = fraction
				g.text = value
				g.on_set = set_to
				g.custom_minimum_size = Vector2(VALUE_WIDTH, ROW)
				row.add_child(g)
			else:
				var v := UiKit.label(value, UiKit.GOLD, 22, UiKit.BOLD_FONT)
				v.custom_minimum_size.x = VALUE_WIDTH
				v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				row.add_child(v)
	_list.add_child(row)


## A switch: the row is a button with its name on the left and its state (sim, não) on the right, gold when on.
func _toggle(text_key: String, option: String) -> void:
	var on: bool = Save.option(option)
	var b := UiKit.button(T.t(text_key), func() -> void:
		Save.set_option(option, not Save.option(option))
		App.apply_options()
		if option == "rumble" and Save.option(option):
			for pad in Input.get_connected_joypads():
				Input.start_joy_vibration(pad, RUMBLE_TRY.x, RUMBLE_TRY.y, RUMBLE_TRY.z)
		_focus_key = text_key
		_build())
	b.name = text_key
	b.custom_minimum_size.y = ROW
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_state(b, T.t(&"on" if on else &"off"), UiKit.GOLD if on else UiKit.DIM)
	_list.add_child(b)


## A row button's value on its right end (a switch's sim or não, a key's binding).
func _state(b: Button, text: String, color: Color) -> void:
	var state := UiKit.label(text, color, 21, UiKit.BOLD_FONT)
	state.name = "state"
	state.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	state.offset_left = -170.0
	state.offset_right = -14.0
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_child(state)


func _input(event: InputEvent) -> void:
	if _waiting == &"":
		return
	if event is InputEventKey and event.is_pressed() and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
		_waiting = &""
	elif (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		Controls.rebind(_waiting, event)
		_waiting = &""
	else:
		return
	get_viewport().set_input_as_handled()
	_build()


## A volume between its arrows: a track of old gold filled to the value with a diamond on its end, the percent beside
## it; a click on the track sets the value there.
class Gauge:
	extends Control

	const TRACK := 4.0
	const KNOB := 7.0
	const TEXT_WIDTH := 58.0

	var fraction := 0.0
	var text := ""
	var on_set: Callable

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _track() -> Rect2:
		return Rect2(Vector2(12.0, size.y * 0.5 - TRACK * 0.5), Vector2(size.x - TEXT_WIDTH - 24.0, TRACK))

	func _draw() -> void:
		var r := _track()
		draw_rect(r, Color(UiKit.OLD_GOLD, 0.3))
		var end := r.position.x + r.size.x * clampf(fraction, 0.0, 1.0)
		draw_rect(Rect2(r.position, Vector2(end - r.position.x, TRACK)), UiKit.OLD_GOLD.lerp(UiKit.GOLD, 0.45))
		var c := Vector2(end, r.position.y + TRACK * 0.5)
		var k := KNOB
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -k - 1.5), c + Vector2(k + 1.5, 0), c + Vector2(0, k + 1.5),
				c + Vector2(-k - 1.5, 0)]), UiKit.INK)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -k), c + Vector2(k, 0), c + Vector2(0, k), c + Vector2(-k, 0)]), UiKit.GOLD)
		var font := UiKit.number_font()
		var at := Vector2(size.x - TEXT_WIDTH, size.y * 0.5 + 8.0)
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_RIGHT, TEXT_WIDTH, 21, UiKit.GOLD)

	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and on_set.is_valid():
			var r := _track()
			accept_event()
			on_set.call(clampf((mb.position.x - r.position.x) / r.size.x, 0.0, 1.0))
