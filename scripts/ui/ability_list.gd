class_name AbilityList
extends PanelContainer
## BC-1: the hero's six buttons listed beside the Blessings of the choice screen: the one the Blessing in focus changes
## is lit in that Blessing's colour, the others stay quiet; a Blessing that changes none says "Age sozinha". Each line is
## the action's mark, its name and the plaque with the key the player has now (UiKit.action_label: the pad, a remapped
## key). Pure display: the screen calls show_for() each time the focus moves.
##   var list := AbilityList.new().setup(220.0)
##   list.show_for(&"rush", color)        # &"": acts alone
## SW-B1: show_held(state) writes under each button the Blessing it already has (its medallion and name).

## The buttons in the order of the HUD's row: action, its mark (BoonIcon id; -1: the action's own by slot), its slot.
const BUTTONS: Array[Array] = [[&"light_attack", -1, Boon.Slot.ATTACK], [&"heavy_attack", -1, Boon.Slot.SPECIAL],
	[&"shout", BoonIcon.SHOUT_GLYPH, Boon.Slot.CAST], [&"rush", BoonIcon.RUSH_GLYPH, Boon.Slot.RUSH],
	[&"ultimate", BoonIcon.ULT_GLYPH, Boon.Slot.ULT], [&"dodge", -1, Boon.Slot.DASH]]
const NAME_SIZE := 16
const MARK := 22.0
const HELD_SIZE := 13
const DIM_ALPHA := 0.42

var lit := &""
var _lines: Dictionary = {}
var _alone: Label
var _tint := Color.WHITE


## ult_open: whether the Golpe Supremo's milestone is open in this save; closed, its line (Shift) is not listed (sweep
## 2026-11-25, P1-4: it showed a key that does nothing yet).
func setup(width: float, ult_open: bool = Hud.ult_open()) -> AbilityList:
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
		var words := VBoxContainer.new()
		words.mouse_filter = Control.MOUSE_FILTER_IGNORE
		words.add_theme_constant_override(&"separation", -2)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var n := UiKit.label(T.t("action_" + String(action)), UiKit.PALE, NAME_SIZE, UiKit.BOLD_FONT)
		n.name = &"Name"
		words.add_child(n)
		var held := UiKit.label("", UiKit.DIM, HELD_SIZE)
		held.name = &"Held"
		held.clip_text = true
		held.visible = false
		words.add_child(held)
		line.add_child(words)
		line.add_child(BoonCard.key_plaque(action))
		col.add_child(line)
		_lines[action] = line
		if action == &"ultimate" and not ult_open:
			line.visible = false
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
		(line.find_child("Name", true, false) as Label).add_theme_color_override(&"font_color", tint.lightened(0.3) if on else UiKit.PALE)
	_alone.visible = lit == &""


## Whether the line of an action is the one lit (tests).
func is_lit(action: StringName) -> bool:
	return lit == action


## SW-B1: the Blessing the hero holds on each button (action -> Boon), the Investida's apart from the dodge's (BC-2).
static func held_by_action(state: BoonState) -> Dictionary:
	var out := {}
	if state == null:
		return out
	for b in state.owned():
		if not b.is_duo() and b.slot != Boon.Slot.NONE:
			out[b.button()] = b
	return out


## Writes under each button the name of the Blessing it already has (nothing under a free button).
func show_held(state: BoonState) -> void:
	var held := held_by_action(state)
	for a: StringName in _lines:
		var label := (_lines[a] as HBoxContainer).find_child("Held", true, false) as Label
		var b: Boon = held.get(a)
		label.visible = b != null
		label.text = T.t("boon_" + String(b.id)) if b != null else ""
		if b != null:
			label.add_theme_color_override(&"font_color", b.color().lightened(0.2))


## The name written under a button ("" when free), for the tests.
func held_text(action: StringName) -> String:
	var line: HBoxContainer = _lines.get(action)
	return (line.find_child("Held", true, false) as Label).text if line != null else ""
