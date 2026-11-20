class_name EnchantChoice
extends Control
## PROVISIONAL (gameplay-engineer, Rejogabilidade Fatia 2): the choice of an Encanto, only so the flow works for a
## person until the ui-ux-designer makes its screen (sistemas.md 5.3, Fatia 2). Up to three side by side, each with its
## name, the action's mark and what it does; the first in focus (one press). Game.open_enchant_choice opens it only
## when no screen listens to Game.enchant_offered.
##   var s := EnchantChoice.new(); game.open_screen(s); s.open(options); s.chosen.connect(...)

signal chosen(enchant: EnchantDef)

const CARD_WIDTH := 280.0

var buttons: Array[Button] = []
var _opened_at := 0


func open(options: Array[EnchantDef]) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.page(self, T.t(&"enchant_title"), options.size() * (CARD_WIDTH + 30.0) + 60.0)
	var hint := UiKit.label(T.t(&"enchant_hint"), UiKit.PALE, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 30)
	page.add_child(row)
	for e in options:
		var col := VBoxContainer.new()
		col.name = String(e.id)
		col.custom_minimum_size.x = CARD_WIDTH
		col.add_theme_constant_override(&"separation", 8)
		row.add_child(col)
		var b := UiKit.button(T.t(e.name_key), _pick.bind(e), CARD_WIDTH)
		b.name = "pick"
		col.add_child(b)
		buttons.append(b)
		var line := UiKit.label(T.t(e.desc_key), UiKit.PALE, 17)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(line)
	if not buttons.is_empty():
		buttons[0].grab_focus.call_deferred()


func _pick(e: EnchantDef) -> void:
	if Time.get_ticks_msec() - _opened_at < BoonChoice.GUARD_MS:
		return
	chosen.emit(e)
