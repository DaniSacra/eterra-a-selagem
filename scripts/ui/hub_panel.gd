class_name HubPanel
extends Control
## A small page of the hub in the Livro de Ahk's language (HUB-B3, HUB-C): one leaf of parchment (BookSpread single,
## cover, browned edges, gilt brackets, the petrol ribbon) on a shade over the hub; on it, an optional mark, the title
## in Cinzel rubric over a gilt rule, an optional state ("◆ A DEFINIR"), a line of ink and a row of buttons (the
## menus' dark buttons, as on the book's boards), the first one the main action and in focus. Used for the Portal's
## short confirmation ("Descer às catacumbas?", Descer, Ficar) and the honest pages of the Vendedor and the Forjador
## (nothing to buy or forge yet, Voltar). Left and right walk the buttons, Enter, A or a click press one; Esc and B
## close it (its ScreenHost), and nothing pressed here reaches the hub (ScreenHost.close clears the presses).
##   var p := HubPanel.new()
##   host.open(p, [T.t(&"hub_descend_title"), T.t(&"hub_descend_line"),
##       [[&"go", T.t(&"hub_descend_go")], [&"stay", T.t(&"hub_descend_stay")]], HowToScreen.step_glyph(0, 56)])
##   p.chosen.connect(func(id: StringName) -> void: ...)

## A button was pressed (its id); closed follows it.
signal chosen(id: StringName)
signal closed

## The page's text column, px at 720 lines (the leaf grows round it).
const WIDTH := 430.0
const TITLE_SIZE := 28
const LINE_SIZE := 18
const BUTTON_WIDTH := 170.0
## The shade over the hub behind the leaf.
const SHADE := Color(0.01, 0.0, 0.02, 0.6)

## The buttons in order (by name: their ids).
var buttons: Array[Button] = []
var leaf: BookSpread


## title: the page's title; line: a line of ink under it (empty: none); choices: [[id, text], ...] in order;
## mark: a small drawing over the title (null: none); state: a short state under the title (empty: none).
func open(title: String, line: String, choices: Array, mark: Control = null, state: String = "") -> void:
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.name = "shade"
	shade.color = SHADE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	leaf = BookSpread.new().setup(0.62, true)
	centre.add_child(leaf)
	var v := VBoxContainer.new()
	v.name = "page"
	v.custom_minimum_size.x = WIDTH
	v.add_theme_constant_override(&"separation", 10)
	leaf.left.add_child(v)
	if mark != null:
		mark.name = "mark"
		mark.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(mark)
	var head := Book.label(title, Book.RUBRIC, TITLE_SIZE, UiKit.TITLE_FONT)
	head.name = "title"
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.custom_minimum_size.x = WIDTH
	v.add_child(head)
	var rule := GoldRule.new()
	rule.tint = Book.GILT
	rule.custom_minimum_size = Vector2(WIDTH * 0.6, 12)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(rule)
	if state != "":
		var s := Book.section(state)
		s.name = "state"
		s.alignment = BoxContainer.ALIGNMENT_CENTER
		v.add_child(s)
	if line != "":
		var l := Book.text(line, Book.INK, LINE_SIZE)
		l.name = "line"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size.x = WIDTH
		v.add_child(l)
	var gap := Control.new()
	gap.custom_minimum_size.y = 4
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(gap)
	var foot := UiKit.foot()
	foot.name = "foot"
	v.add_child(foot)
	for c: Array in choices:
		var id: StringName = c[0]
		var b := UiKit.button(String(c[1]), func() -> void:
			chosen.emit(id)
			closed.emit(), BUTTON_WIDTH)
		b.name = String(id)
		if buttons.is_empty():
			UiKit.primary(b)
		foot.add_child(b)
		buttons.append(b)
	_chain()
	if not buttons.is_empty():
		buttons[0].grab_focus.call_deferred()
	# the page comes up as the book's do
	leaf.modulate.a = 0.0
	create_tween().tween_property(leaf, ^"modulate:a", 1.0, 0.18)


## Left and right walk the row and stop at its ends; up and down stay on the button.
func _chain() -> void:
	for i in buttons.size():
		var b := buttons[i]
		b.focus_neighbor_left = b.get_path_to(buttons[maxi(i - 1, 0)])
		b.focus_neighbor_right = b.get_path_to(buttons[mini(i + 1, buttons.size() - 1)])
		b.focus_neighbor_top = b.get_path_to(b)
		b.focus_neighbor_bottom = b.get_path_to(b)
