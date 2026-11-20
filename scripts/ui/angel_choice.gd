class_name AngelChoice
extends Control
## PROVISIONAL (gameplay-engineer, Rejogabilidade Fatia 1): the meeting with two angels, only so the flow works for a
## person until the ui-ux-designer makes the Encontro screen (sistemas.md 3.4). The pair side by side, each with its
## seal (AngelSeal), name and line of temperament; the first in focus, so choosing is one press (A10: Enter, A or a
## click). Its cards open right after on the usual choice screen (Encounters.choose).
##   var s := AngelChoice.new(); game.open_screen(s); s.open(angels); s.chosen.connect(...)

signal chosen(angel: AngelDef)

const SEAL := 112.0
const CARD_WIDTH := 300.0

var buttons: Array[Button] = []
var _opened_at := 0


func open(angels: Array[AngelDef]) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.page(self, T.t(&"encounter_title" if angels.size() > 1 else &"encounter_alone"), 2.0 * CARD_WIDTH + 80.0)
	var hint := UiKit.label(T.t(&"encounter_hint"), UiKit.PALE, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 40)
	page.add_child(row)
	for a in angels:
		var col := VBoxContainer.new()
		col.name = String(a.id)
		col.custom_minimum_size.x = CARD_WIDTH
		col.add_theme_constant_override(&"separation", 8)
		row.add_child(col)
		var seal := AngelSeal.new().setup(a.family, SEAL)
		seal.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(seal)
		var b := UiKit.button(T.t(a.name_key), _pick.bind(a), CARD_WIDTH)
		b.name = "pick"
		col.add_child(b)
		buttons.append(b)
		var line := UiKit.label(T.t(a.line_key), a.color.lightened(0.2), 17)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(line)
	if not buttons.is_empty():
		buttons[0].grab_focus.call_deferred()


func _pick(a: AngelDef) -> void:
	if Time.get_ticks_msec() - _opened_at < BoonChoice.GUARD_MS:
		return
	chosen.emit(a)
