class_name OptionsScreen
extends Control
## Options: volumes, full screen, window size, screen shake and key remapping. Everything is saved at once.

signal closed

const VOLUMES: Array[String] = ["master", "music", "sfx"]

var _list: VBoxContainer
var _waiting: StringName = &""
var _focus_key := ""


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	var page := UiKit.column(self, 290.0)
	page.add_theme_constant_override(&"separation", 2)
	var title := UiKit.label(T.t(&"options_title"), Palette.c(&"luz", 0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override(&"separation", 10)
	page.add_child(cols)
	_list = VBoxContainer.new()
	_list.custom_minimum_size.x = 160
	cols.add_child(_list)
	for key in VOLUMES:
		_stepper("opt_" + key, "%d%%" % roundi(float(Save.option(key)) * 100.0), func(dir: int) -> void:
			Save.set_option(key, clampf(snappedf(float(Save.option(key)) + dir * 0.1, 0.1), 0.0, 1.0))
			App.apply_options())
	_stepper("opt_scale", "%dx%d" % [320 * int(Save.option("scale")), 180 * int(Save.option("scale"))], func(dir: int) -> void:
		Save.set_option("scale", clampi(int(Save.option("scale")) + dir, 2, 8))
		App.apply_options())
	_toggle("opt_fullscreen", "fullscreen")
	_toggle("opt_shake", "shake")
	var keys := VBoxContainer.new()
	keys.add_theme_constant_override(&"separation", 1)
	cols.add_child(keys)
	var hint := UiKit.label(T.t(&"options_keys"), Palette.c(&"luz", 1))
	keys.add_child(hint)
	for action in Controls.REMAPPABLE:
		var waiting := _waiting == action
		var b := UiKit.button("%s: %s" % [T.t("action_" + action), T.t(&"options_press") if waiting else Controls.label(action)], func() -> void:
			_waiting = action
			_focus_key = "key_" + action
			_build())
		b.name = "key_" + action
		b.custom_minimum_size = Vector2(120, 14)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		keys.add_child(b)
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	page.add_child(bottom)
	bottom.add_child(UiKit.button(T.t(&"options_reset"), func() -> void:
		Controls.reset_bindings()
		_build()))
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit())
	back.name = "back"
	bottom.add_child(back)
	_restore_focus.call_deferred()


func _restore_focus() -> void:
	var target := find_child(_focus_key if _focus_key != "" else "back", true, false) as Control
	if target:
		target.grab_focus()


## A row "< value >": left and right change it, so it works the same with keys, mouse and gamepad.
func _stepper(text_key: String, value: String, change: Callable) -> void:
	var row := HBoxContainer.new()
	var l := UiKit.label(T.t(text_key), Palette.c(&"neve", 1))
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	for dir: int in [-1, 1]:
		var b := UiKit.button("<" if dir < 0 else ">", func() -> void:
			_focus_key = "%s_%d" % [text_key, dir]
			change.call(dir)
			_build())
		b.name = "%s_%d" % [text_key, dir]
		b.custom_minimum_size.x = 14
		row.add_child(b)
		if dir < 0:
			var v := UiKit.label(value, Palette.c(&"luz", 0))
			v.custom_minimum_size.x = 56
			v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			row.add_child(v)
	_list.add_child(row)


func _toggle(text_key: String, option: String) -> void:
	var b := UiKit.button("%s: %s" % [T.t(text_key), T.t(&"on" if Save.option(option) else &"off")], func() -> void:
		Save.set_option(option, not Save.option(option))
		App.apply_options()
		_focus_key = text_key
		_build())
	b.name = text_key
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_list.add_child(b)


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
