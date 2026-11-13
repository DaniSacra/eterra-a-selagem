class_name EndScreen
extends Control
## Defeat or victory: the numbers of the run, the best time, and "Tentar de novo".

signal retry
signal menu


func open(victory: bool, stats: Dictionary, new_best: bool) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.column(self, 460.0, 0.75)
	v.add_child(UiKit.title(T.t(&"end_victory" if victory else &"end_defeat"), 48, UiKit.GOLD if victory else Color(1.0, 0.55, 0.45)))
	if not victory:
		var sub := UiKit.label(T.t(&"end_defeat_sub"), UiKit.DIM, 22)
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.custom_minimum_size.x = 460
		v.add_child(sub)
	var panel := PanelContainer.new()
	v.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	_row(rows, T.t(&"end_time"), SaveData.format_time(stats.time))
	_row(rows, T.t(&"end_level"), str(stats.level))
	_row(rows, T.t(&"end_kills"), str(stats.kills))
	_row(rows, T.t(&"end_combo"), str(stats.best_combo))
	_row(rows, T.t(&"end_boons"), str(stats.boons))
	var best: Array = Save.data.best_times
	if not best.is_empty():
		_row(rows, T.t(&"end_best"), SaveData.format_time(best[0]), UiKit.GOLD)
	if new_best:
		var nb := UiKit.label(T.t(&"end_new_best"), UiKit.GOLD, 24, UiKit.BOLD_FONT)
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nb)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(buttons)
	var again := UiKit.button(T.t(&"end_retry"), func() -> void: retry.emit(), 220)
	buttons.add_child(again)
	buttons.add_child(UiKit.button(T.t(&"end_menu"), func() -> void: menu.emit(), 160))
	again.grab_focus.call_deferred()


func _row(parent: Control, key: String, value: String, color: Color = UiKit.PALE) -> void:
	var h := HBoxContainer.new()
	var k := UiKit.label(key, UiKit.DIM, 22)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(k)
	h.add_child(UiKit.label(value, color, 24, UiKit.BOLD_FONT))
	parent.add_child(h)
