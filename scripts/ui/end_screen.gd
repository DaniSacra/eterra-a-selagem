class_name EndScreen
extends Control
## Defeat or victory: the numbers of the run, the best times, and "Tentar de novo".

signal retry
signal menu


func open(victory: bool, stats: Dictionary, new_best: bool) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.veil(0.7))
	var v := UiKit.column(self, 170.0)
	var title := UiKit.label(T.t(&"end_victory" if victory else &"end_defeat"), Palette.c(&"luz" if victory else &"perigo", 0), UiKit.BIG)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	if not victory:
		var sub := UiKit.label(T.t(&"end_defeat_sub"), Palette.c(&"neve", 2))
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.custom_minimum_size.x = 170
		v.add_child(sub)
	_row(v, T.t(&"end_time"), SaveData.format_time(stats.time))
	_row(v, T.t(&"end_level"), str(stats.level))
	_row(v, T.t(&"end_kills"), str(stats.kills))
	_row(v, T.t(&"end_combo"), str(stats.best_combo))
	_row(v, T.t(&"end_boons"), str(stats.boons))
	var best: Array = Save.data.best_times
	if not best.is_empty():
		_row(v, T.t(&"end_best"), SaveData.format_time(best[0]), Palette.c(&"luz", 1))
	if new_best:
		var nb := UiKit.label(T.t(&"end_new_best"), Palette.c(&"luz", 0))
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nb)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(buttons)
	var again := UiKit.button(T.t(&"end_retry"), func() -> void: retry.emit())
	again.custom_minimum_size.x = 84
	buttons.add_child(again)
	var back := UiKit.button(T.t(&"end_menu"), func() -> void: menu.emit())
	back.custom_minimum_size.x = 50
	buttons.add_child(back)
	again.grab_focus.call_deferred()


func _row(parent: Control, key: String, value: String, color: Color = Palette.c(&"neve", 0)) -> void:
	var h := HBoxContainer.new()
	var k := UiKit.label(key, Palette.c(&"neve", 2))
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(k)
	h.add_child(UiKit.label(value, color))
	parent.add_child(h)
