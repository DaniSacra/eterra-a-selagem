class_name OficioSheets
extends RefCounted
## The Ofícios' sheets of the hub (Roteiro A; docs/design/oficios/10_ux.md 10.4), on the HubPanel's leaf: the
## Vendedor's order with what it asks for (each line its mark, its name and "1 de 2" in lining figures, what is missing
## in the rubric, what is there in ink with a tick), where to find the stone and what the delivery makes; Entregar
## greyed out and out of the focus while something is missing. One order a leaf. The hub opens it and keeps the rules:
##   var p := HubPanel.new()
##   host.open(p, OficioSheets.order(Save.data, OficiosDef.live()))
##   p.chosen.connect(func(id: StringName) -> void: if id == &"deliver": ...)

const ROW_SIZE := 18
const ROW_MARK := 22.0
const NAME_WIDTH := 210.0
const TEXT_SIZE := 16
## The leaf's mark over the title by default: the Pedra Funda's.
const MARK := 46.0


## The HubPanel's arguments for the Vendedor's order as the save stands (open or done; a locked order has no sheet).
static func order(data: Dictionary, def: OficiosDef, mark: Control = null) -> Array:
	var done := Oficios.order_state(data, def) == Oficios.Order.DONE
	var missing := Oficios.order_missing(data, def)
	var body := VBoxContainer.new()
	body.add_theme_constant_override(&"separation", 4)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not done:
		body.add_child(Book.section(T.t(&"order_wants")))
		for id: Variant in def.order_wants:
			var want := int(def.order_wants[id])
			body.add_child(want_row(StringName(id), MaterialCount.amount_of(data, StringName(id)), want))
		body.add_child(Book.section(T.t(&"order_where")))
		body.add_child(_text(T.t(&"order_where_stone"), Book.FADED))
		body.add_child(Book.section(T.t(&"order_gives")))
		body.add_child(_text(T.t(&"order_gives_preview"), Book.INK))
	var choices: Array = [[&"back", T.t(&"back")]]
	if not done:
		choices.push_front([&"deliver", T.t(&"oficio_deliver"), missing.is_empty()])
	var line := T.t(&"oficio_vendor_done") if done else T.t(&"order_speech")
	if mark == null:
		mark = DoorGlyph.new().setup(DoorGlyph.Kind.STONE, MARK)
	if body.get_child_count() == 0:
		body.free()
		body = null
	return [T.t(&"oficio_vendor_title"), line, choices, mark, T.t(&"order_done_state") if done else "", body]


## A line of an order: the mark, the name, "have de want" (the count stops at want), the missing count in the rubric
## or a tick in ink.
static func want_row(id: StringName, have: int, want: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "want_" + String(id)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	var g := DoorGlyph.new().setup(DoorGlyph.of_material(id), ROW_MARK)
	g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(g)
	var n := Book.label(MaterialCount.name_of(id), Book.INK, ROW_SIZE, UiKit.BOLD_FONT)
	n.custom_minimum_size.x = NAME_WIDTH
	row.add_child(n)
	var ok := have >= want
	var count := Book.label(T.t(&"order_of", {"have": mini(have, want), "want": want}), Book.INK if ok else Book.RUBRIC,
		ROW_SIZE, UiKit.number_font())
	count.name = "count"
	row.add_child(count)
	if ok:
		var tick := Tick.new()
		tick.custom_minimum_size = Vector2(16, 16)
		tick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(tick)
	return row


static func _text(s: String, col: Color) -> Label:
	var l := Book.text(s, col, TEXT_SIZE)
	l.custom_minimum_size.x = HubPanel.WIDTH
	return l


## A tick in ink (what an order asks for is there).
class Tick extends Control:
	func _draw() -> void:
		var s := size
		draw_polyline(PackedVector2Array([Vector2(s.x * 0.12, s.y * 0.55), Vector2(s.x * 0.4, s.y * 0.82),
			Vector2(s.x * 0.9, s.y * 0.18)]), Book.OK, 2.4, true)
