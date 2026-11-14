class_name FeelPanel
extends CanvasLayer
## F1 in debug builds: sliders for every number of Feel (scripts/core/feel.gd), applied while the run goes on.
## "Save" writes user://feel_override.tres (used on this machine from then on); "Reset" goes back to data/feel.tres.
## A tool for tuning, not for players: labels are the property names, nothing goes to data/text_pt.tres.

const WIDTH := 400.0

var _list: VBoxContainer
var _status: Label


func _ready() -> void:
	layer = 60
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", UiKit.box(UiKit.PANEL, UiKit.EDGE, 1, 10))
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -WIDTH - 12.0
	panel.offset_right = -12.0
	panel.offset_top = 12.0
	panel.offset_bottom = -12.0
	panel.theme = UiKit.theme()
	add_child(panel)
	var col := VBoxContainer.new()
	panel.add_child(col)
	col.add_child(UiKit.label("Feel (F1)", UiKit.GOLD, 22, UiKit.BOLD_FONT))
	var buttons := HBoxContainer.new()
	col.add_child(buttons)
	buttons.add_child(UiKit.button("Save", _save, 120.0))
	buttons.add_child(UiKit.button("Reset", _reset, 120.0))
	_status = UiKit.label("", UiKit.DIM, 16)
	col.add_child(_status)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	_build()


func _build() -> void:
	for c in _list.get_children():
		c.queue_free()
	var feel := Feel.live()
	for p in feel.get_property_list():
		if p.usage & PROPERTY_USAGE_GROUP:
			if p.name == "Resource":
				continue
			_list.add_child(UiKit.label(p.name, UiKit.GOLD, 18, UiKit.BOLD_FONT))
			continue
		if not (p.usage & PROPERTY_USAGE_EDITOR) or p.hint != PROPERTY_HINT_RANGE:
			continue
		if p.type != TYPE_FLOAT and p.type != TYPE_INT:
			continue
		_list.add_child(_row(feel, p.name, p.hint_string))


func _row(feel: Feel, prop: String, hint: String) -> Control:
	var range_ := hint.split(",")
	var box := VBoxContainer.new()
	var top := HBoxContainer.new()
	box.add_child(top)
	var name_ := UiKit.label(prop, UiKit.PALE, 16)
	name_.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_)
	var value := UiKit.label(_fmt(feel.get(prop)), UiKit.GOLD, 16)
	top.add_child(value)
	var slider := HSlider.new()
	slider.min_value = float(range_[0])
	slider.max_value = float(range_[1])
	slider.step = float(range_[2]) if range_.size() > 2 else 0.01
	slider.value = float(feel.get(prop))
	slider.focus_mode = Control.FOCUS_NONE
	slider.value_changed.connect(func(v: float) -> void:
		var f := Feel.live()
		f.set(prop, int(v) if typeof(f.get(prop)) == TYPE_INT else v)
		value.text = _fmt(f.get(prop))
		_status.text = "")
	box.add_child(slider)
	return box


func _fmt(v: Variant) -> String:
	return str(v) if typeof(v) == TYPE_INT else "%.2f" % float(v)


func _save() -> void:
	var err := Feel.save_override()
	_status.text = "saved to %s" % Feel.OVERRIDE if err == OK else "could not save (%d)" % err


func _reset() -> void:
	Feel.reset()
	_build()
	_status.text = "back to %s" % Feel.PATH
