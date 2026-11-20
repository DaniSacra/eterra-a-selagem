class_name OptionsScreen
extends Control
## Configurações (art pack board 10): one framed page with tabs: Áudio (volumes as gauges, and Músicas: MusicRoomScreen,
## T5, hear every piece and choose the title's, the rooms' and Morvath's), Vídeo (window size, full screen, graphics
## quality), Conforto (screen shake, impact frames, slow motion, colour split, gamepad vibration; all on by default, the
## run reads them in Game.apply_options) and Controles (key remapping and the default keys). Everything is saved at
## once. One control for every setting (UI review d2ff05d, P1-11): a row with its name on the left and its value
## between two chevrons of old gold on the right ("‹ Sim ›", a gauge for a volume); left and right step it, Enter, A or
## a click on the row steps it forward (a switch flips), a click on a chevron steps that way. "Janela" is greyed and
## skipped while the full screen is on. Under the page, a line says what the setting in focus does (opt_<id>_tip).
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
## The value between a row's chevrons, the chevrons' size, the value's letters.
const VALUE_WIDTH := 280.0
const CHEVRON := 30.0
const VALUE_SIZE := 20
## The line under the page that tells what the setting in focus does.
const TIP_SIZE := 17
const TIP_HEIGHT := 46.0

var tab := Tab.AUDIO
var tabs: Array[Button] = []
var pages: Array[VBoxContainer] = []
var _list: VBoxContainer
var _waiting: StringName = &""
var _focus_key := ""
## What the setting in focus does (opt_<id>_tip), under the page.
var tip: Label


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
		_setting("opt_" + key, "%d%%" % roundi(float(Save.option(key)) * 100.0), func(dir: int) -> void:
			_set_volume(key, float(Save.option(key)) + dir * 0.1), true, float(Save.option(key)),
			func(f: float) -> void:
				_focus_key = "opt_" + key
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
	# the window's size means nothing under the full screen: greyed and skipped by the focus then
	_setting("opt_scale", "%dx%d" % [win.x, win.y], func(dir: int) -> void:
		Save.set_option("scale", posmod(int(Save.option("scale")) - 1 + dir, App.WINDOW_SIZES.size()) + 1)
		App.apply_options(), not bool(Save.option("fullscreen")))
	_toggle("opt_fullscreen", "fullscreen")
	# E6 (DT-003): Alta, Média, Baixa (GraphicsQuality); the run in progress gets it when the pause closes
	_setting("opt_quality", T.t(GraphicsQuality.TEXT[GraphicsQuality.clamp_level(int(Save.option("quality")))]), func(dir: int) -> void:
		Save.set_option("quality", posmod(GraphicsQuality.clamp_level(int(Save.option("quality"))) + dir, GraphicsQuality.TEXT.size()))
		App.apply_options())
	# the near camera (Daniel, 2026-11-19; CamRig.near, read every frame: the run behind the pause moves at once)
	_setting("opt_camera", T.t("opt_camera_near" if String(Save.option("camera")) == "near" else "opt_camera_far"), func(_dir: int) -> void:
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
		_state(b, T.t(&"options_press") if waiting else HowToScreen.keys_label([action]), UiKit.PALE if waiting else UiKit.GOLD)
		# the gamepad's button beside the key, to read (UI review d2ff05d, P2-4; the pad is not remapped yet)
		var pad := UiKit.label(HowToScreen.pad_label([action]), UiKit.DIM.lightened(0.15), 17, UiKit.BOLD_FONT)
		pad.name = "pad"
		pad.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		pad.offset_left = -180.0
		pad.offset_right = -126.0
		pad.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		pad.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(pad)
		keys.add_child(b)
	var reset := UiKit.button(T.t(&"options_reset"), func() -> void:
		_focus_key = "options_reset"
		Controls.reset_bindings()
		_build(), 260)
	reset.name = "options_reset"
	reset.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_list.add_child(_gap(4))
	_list.add_child(reset)
	tip = UiKit.label("", UiKit.DIM.lightened(0.2), TIP_SIZE)
	tip.name = "tip"
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(WIDTH - 60.0, TIP_HEIGHT)
	tip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(tip)
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
	if is_instance_valid(tip):
		tip.text = tip_text(c.name)
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


## What a setting does, for the line under the page ("" for a row without a tip).
static func tip_text(row: String) -> String:
	var key := row + "_tip"
	return T.t(key) if row.begins_with("opt_") and T.table.entries.has(key) else ""


## A setting (P1-11, one control for every kind): a row button with its name on the left and on the right its value
## between two drawn chevrons of old gold; change(dir) steps it. Left and right step it, Enter, A or a click on the
## row step it forward, a click on a chevron steps that way (the chevrons are opt_<id>_-1 and opt_<id>_1, never
## focused). With a fraction (0..1) the value is a gauge (the volumes); a click on the gauge sets it there (set_to).
## Not enabled: greyed, no focus, no chevrons.
func _setting(text_key: String, value: String, change: Callable, enabled: bool = true, fraction: float = -1.0,
		set_to: Callable = Callable()) -> Button:
	var step := func(dir: int) -> void:
		_focus_key = text_key
		change.call(dir)
		_build()
	var b := UiKit.button(T.t(text_key), step.bind(1))
	b.name = text_key
	b.custom_minimum_size = Vector2(0, ROW)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override(&"font_size", 21)
	var right := HBoxContainer.new()
	right.name = "value"
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.add_theme_constant_override(&"separation", 2)
	right.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	right.offset_left = -(VALUE_WIDTH + CHEVRON * 2.0 + 14.0)
	right.offset_right = -8.0
	b.add_child(right)
	for dir: int in [-1, 1]:
		var c := Chevron.new()
		c.name = "%s_%d" % [text_key, dir]
		c.dir = dir
		c.visible = enabled
		c.custom_minimum_size = Vector2(CHEVRON, ROW)
		c.pressed.connect(step.bind(dir))
		right.add_child(c)
		if dir < 0:
			if fraction >= 0.0:
				var g := Gauge.new()
				g.fraction = fraction
				g.text = value
				g.on_set = set_to
				g.custom_minimum_size = Vector2(VALUE_WIDTH, ROW)
				right.add_child(g)
			else:
				var v := UiKit.label(value, UiKit.GOLD if enabled else UiKit.DIM, VALUE_SIZE,
						UiKit.number_font() if UiKit.has_digit(value) else UiKit.TITLE_FONT)
				v.name = "state"
				v.custom_minimum_size.x = VALUE_WIDTH
				v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				v.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				v.size_flags_vertical = Control.SIZE_FILL
				right.add_child(v)
	if enabled:
		b.gui_input.connect(func(event: InputEvent) -> void:
			for pair: Array in [[&"ui_left", -1], [&"ui_right", 1]]:
				if event.is_action_pressed(pair[0], true):
					b.accept_event()
					Audio.play(&"ui_move")
					step.call(pair[1])
					return)
	else:
		b.disabled = true
		b.focus_mode = Control.FOCUS_NONE
	_list.add_child(b)
	return b


## A switch: a setting whose value is Sim or Não (gold when on); any step flips it.
func _toggle(text_key: String, option: String) -> void:
	var on: bool = Save.option(option)
	var b := _setting(text_key, T.t(&"on" if on else &"off"), func(_dir: int) -> void:
		Save.set_option(option, not Save.option(option))
		App.apply_options()
		if option == "rumble" and Save.option(option):
			for pad in Input.get_connected_joypads():
				Input.start_joy_vibration(pad, RUMBLE_TRY.x, RUMBLE_TRY.y, RUMBLE_TRY.z))
	if not on:
		(b.find_child("state", true, false) as Label).add_theme_color_override(&"font_color", UiKit.DIM.lightened(0.2))


## A row button's value on its right end (a switch's sim or não, a key's binding).
func _state(b: Button, text: String, color: Color) -> void:
	var state := UiKit.label(text, color, 21, UiKit.BOLD_FONT)
	state.name = "state"
	state.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	state.offset_left = -120.0
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


## A step of a setting's value: a chevron of old gold pointing left or right, lit while hovered; clicked, it steps.
class Chevron:
	extends BaseButton

	var dir := 1

	func _init() -> void:
		focus_mode = Control.FOCUS_NONE
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		mouse_entered.connect(queue_redraw)
		mouse_exited.connect(queue_redraw)

	func _draw() -> void:
		var c := size * 0.5
		var k := 6.0
		var col := UiKit.GOLD if is_hovered() else UiKit.OLD_GOLD.lightened(0.25)
		var tip := c + Vector2(k * dir, 0)
		var back := c - Vector2(k * dir, 0)
		draw_polyline(PackedVector2Array([back + Vector2(0, -k * 1.3), tip, back + Vector2(0, k * 1.3)]), col, 2.4, true)
