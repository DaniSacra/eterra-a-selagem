class_name MovesScreen
extends Control
## "Golpes": the combos found so far. The ones not yet landed show only question marks.

signal closed


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.column(self, 560.0, 0.8)
	v.add_child(UiKit.title(T.t(&"moves_title"), 40))
	var panel := PanelContainer.new()
	v.add_child(panel)
	var list := VBoxContainer.new()
	list.add_theme_constant_override(&"separation", 6)
	panel.add_child(list)
	var tree: ComboTree = load(Player.COMBOS)
	var words := {"dodge": T.t(&"moves_dodge"), "charge": T.t(&"moves_charge")}
	var known: Array = Save.data.moves
	for m in tree.named_moves():
		var node: ComboNode = m.node
		var found := known.has(String(node.id))
		var row := HBoxContainer.new()
		var keys := UiKit.label(ComboTree.notation(m.path, m.from_dodge, words), UiKit.GOLD if found else UiKit.DIM, 22, UiKit.BOLD_FONT)
		keys.custom_minimum_size.x = 220
		row.add_child(keys)
		row.add_child(UiKit.label(T.t(node.title) if found else "???", UiKit.PALE if found else UiKit.DIM, 22))
		list.add_child(row)
	var legend := UiKit.label(T.t(&"moves_legend"), UiKit.DIM, 19)
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(legend)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	var c := CenterContainer.new()
	c.add_child(back)
	v.add_child(c)
	back.grab_focus.call_deferred()
