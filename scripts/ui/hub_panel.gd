class_name HubPanel
extends Control
## A small page of the hub (HUB-B1, provisional until the ui-ux-designer's HUB-B3/C): a title, a line and a row of
## buttons, the first one in focus. The Portal's short confirmation (Descer, Ficar) and the honest "A definir" of the
## Vendedor and the Forjador (Voltar). Esc and B close it (its ScreenHost).
##   var p := HubPanel.new()
##   host.open(p, [T.t(&"hub_descend_title"), "", [[&"go", T.t(&"hub_descend_go")], [&"stay", T.t(&"hub_descend_stay")]]])
##   p.chosen.connect(func(id: StringName) -> void: ...)

## A button was pressed (its id); closed follows it.
signal chosen(id: StringName)
signal closed

const WIDTH := 460.0

## The buttons in order (by name: their ids).
var buttons: Array[Button] = []


func open(title: String, line: String, choices: Array) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.page(self, title, WIDTH, 0.55, 30)
	if line != "":
		var l := UiKit.label(line, UiKit.PALE, 19)
		l.name = "line"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = WIDTH * 0.85
		v.add_child(l)
	var foot := UiKit.foot()
	v.add_child(foot)
	for c: Array in choices:
		var id: StringName = c[0]
		var b := UiKit.button(String(c[1]), func() -> void:
			chosen.emit(id)
			closed.emit(), 180)
		b.name = String(id)
		if buttons.is_empty():
			UiKit.primary(b)
		foot.add_child(b)
		buttons.append(b)
	if not buttons.is_empty():
		buttons[0].grab_focus.call_deferred()
