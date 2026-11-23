class_name AbilityList
extends PanelContainer
## BC-1: the hero's six buttons listed beside the Blessings of the choice screen: the one the Blessing in focus changes
## is lit in that Blessing's colour, the others stay quiet; a Blessing that changes none says "Age sozinha". Each line is
## the action's mark, its name and the plaque with the key the player has now (UiKit.action_label: the pad, a remapped
## key). Pure display: the screen calls show_for() each time the focus moves.
##   var list := AbilityList.new().setup(220.0)
##   list.show_for(&"rush", color)        # &"": acts alone

## The buttons in the order of the HUD's row: action, its mark (BoonIcon id; -1: the action's own by slot), its slot.
const BUTTONS: Array[Array] = [[&"light_attack", -1, Boon.Slot.ATTACK], [&"heavy_attack", -1, Boon.Slot.SPECIAL],
	[&"shout", BoonIcon.SHOUT_GLYPH, Boon.Slot.CAST], [&"rush", BoonIcon.RUSH_GLYPH, Boon.Slot.RUSH],
	[&"ultimate", BoonIcon.ULT_GLYPH, Boon.Slot.ULT], [&"dodge", -1, Boon.Slot.DASH]]
const NAME_SIZE := 16
const MARK := 22.0
const DIM_ALPHA := 0.42

var lit := &""
var _lines: Dictionary = {}
var _alone: Label
var _tint := Color.WHITE


func setup(width: float) -> AbilityList:
	name = "abilities"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.x = width
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := UiKit.box(Color(UiKit.PAGE, 0.9), Color(UiKit.OLD_GOLD, 0.55), 1, 0, 6)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	add_theme_stylebox_override(&"panel", sb)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override(&"separation", 5)
	add_child(col)
	var head := UiKit.label(T.t(&"list_head"), UiKit.OLD_GOLD.lightened(0.3), 13, UiKit.BOLD_FONT)
	head.text = head.text.to_upper()
	col.add_child(head)
	for b in BUTTONS:
		var action: StringName = b[0]
		var line := HBoxContainer.new()
		line.name = String(action)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_theme_constant_override(&"separation", 8)
		var glyph: int = b[1] if b[1] >= 0 else BoonIcon.ACTION_GLYPH + int(b[2])
		line.add_child(ActionSlot.glyph_mark(glyph, MARK))
		var n := UiKit.label(T.t("action_" + String(action)), UiKit.PALE, NAME_SIZE, UiKit.BOLD_FONT)
		n.name = &"Name"
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(n)
		line.add_child(BoonCard.key_plaque(action))
		col.add_child(line)
		_lines[action] = line
	_alone = UiKit.label(T.t(&"list_alone"), UiKit.DIM, 15, UiKit.BOLD_FONT)
	_alone.name = &"Alone"
	_alone.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_alone)
	show_for(&"", Color.WHITE)
	return self


## Lights the line of action (in tint), the rest dimmed; &"" lights none and says the Blessing acts alone.
func show_for(action: StringName, tint: Color) -> void:
	lit = action if _lines.has(action) else &""
	_tint = tint
	for a: StringName in _lines:
		var line: HBoxContainer = _lines[a]
		var on := a == lit
		line.modulate.a = 1.0 if on or lit == &"" else DIM_ALPHA
		(line.get_node("Name") as Label).add_theme_color_override(&"font_color", tint.lightened(0.3) if on else UiKit.PALE)
	_alone.visible = lit == &""


## Whether the line of an action is the one lit (tests).
func is_lit(action: StringName) -> bool:
	return lit == action
