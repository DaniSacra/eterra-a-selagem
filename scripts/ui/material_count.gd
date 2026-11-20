class_name MaterialCount
extends HBoxContainer
## A material's mark (DoorGlyph SILVER, MEMORY) and its number in lining figures (UiKit.number_font, never Cinzel:
## UI review d2ff05d, P0-1), optionally followed by the material's short name ("12 Prata"). The same everywhere a
## material shows (Rejogabilidade, Fatia 1): the Forja's cost and purse, the Livro's purse, the Gift tree's panel, the
## end screen's "Trazidos", the hub's corner and the greeting of a material found.
##   MaterialCount.new().setup(MaterialPurse.SILVER, 12)
##   MaterialCount.purse(Save.data)        # the "Bolsa": Prata and Memória side by side

## The mark's height and the number's size by default (px at 720 lines).
const MARK := 18.0
const SIZE := 17

var id: StringName
var amount := 0
var number: Label
var mark: DoorGlyph
var _named := false
## "+3" (a greeting of a material found) instead of "3".
var plus := false


## p_id: MaterialPurse.SILVER, MEMORY or EMERALD. named: the short name after the number.
func setup(p_id: StringName, n: int, color: Color = UiKit.PALE, size: int = SIZE, mark_px: float = MARK,
		named: bool = false) -> MaterialCount:
	self.id = p_id
	_named = named
	name = String(p_id)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"separation", 5)
	mark = DoorGlyph.new().setup(DoorGlyph.of_material(p_id), mark_px)
	add_child(mark)
	number = UiKit.label("", color, size, UiKit.number_font())
	number.name = "n"
	number.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(number)
	tooltip_text = T.t(MaterialPurse.NAME_KEY[p_id])
	set_amount(n)
	return self


func set_amount(n: int) -> void:
	amount = n
	var digits := ("+%d" if plus else "%d") % n
	number.text = digits if not _named else "%s %s" % [digits, T.t(MaterialPurse.SHORT_KEY[id])]


func set_color(c: Color) -> void:
	number.add_theme_color_override(&"font_color", c)


## The "Bolsa": what the save holds of each material, side by side (the Forja, the Livro, the hub). The Esmeralda
## (Fatia 2) only once one was ever found (shown): a new save sees no stone it cannot get yet.
static func purse(data: Dictionary, color: Color = UiKit.PALE, size: int = SIZE, mark_px: float = MARK) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "purse"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 14)
	for m: StringName in shown(data):
		row.add_child(MaterialCount.new().setup(m, MaterialPurse.amount(data, m), color, size, mark_px))
	return row


## The materials a purse shows: Prata and Memória always, the Esmeralda once the save has held one.
static func shown(data: Dictionary) -> Array[StringName]:
	var out: Array[StringName] = [MaterialPurse.SILVER, MaterialPurse.MEMORY]
	var total: Dictionary = data.get("materials_total", {}) if data.get("materials_total") is Dictionary else {}
	if MaterialPurse.amount(data, MaterialPurse.EMERALD) > 0 or int(total.get(String(MaterialPurse.EMERALD), 0)) > 0:
		out.append(MaterialPurse.EMERALD)
	return out


## Reads the save again into a purse made by purse().
static func refresh(row: Control, data: Dictionary) -> void:
	for c in row.get_children():
		if c is MaterialCount:
			(c as MaterialCount).set_amount(MaterialPurse.amount(data, (c as MaterialCount).id))
