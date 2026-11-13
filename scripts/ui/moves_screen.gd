class_name MovesScreen
extends Control
## "Golpes": the combos found so far. The ones not yet landed show only question marks.

signal closed


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.column(self, 210.0)
	var title := UiKit.label(T.t(&"moves_title"), Palette.c(&"luz", 0), UiKit.BIG)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var tree: ComboTree = load(Player.COMBO_TREE)
	var words := {"dodge": T.t(&"moves_dodge"), "charge": T.t(&"moves_charge")}
	var known: Array = Save.data.moves
	for m in tree.named_moves():
		var node: ComboNode = m.node
		var found := known.has(String(node.id))
		var row := HBoxContainer.new()
		var keys := UiKit.label(ComboTree.notation(m.path, m.from_dodge, words), Palette.c(&"luz", 1) if found else Palette.c(&"neve", 3))
		keys.custom_minimum_size.x = 84
		row.add_child(keys)
		row.add_child(UiKit.label(T.t(node.title) if found else "???", Palette.c(&"neve", 0) if found else Palette.c(&"neve", 4)))
		v.add_child(row)
	v.add_child(UiKit.label(T.t(&"moves_legend"), Palette.c(&"neve", 3)))
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit())
	v.add_child(back)
	back.grab_focus.call_deferred()
