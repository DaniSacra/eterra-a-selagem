class_name VineSheet
extends RefCounted
## A Videira at the Forjador (V1: a plain stand-in for the V2 station, by the ui-ux-designer): one leaf of
## the hub (HubPanel) with the purse, a grid of the nodes as buttons (name and price; the owned ones marked) and, under
## it, what the one in focus does. Enter on a node buys it (Vine.buy), writes the save and says so. Esc closes.
##   VineSheet.open(host, Save.data, on_bought: Callable)   # on_bought(id) after each purchase

const COLUMNS := 3  # one column a branch, one row a step
const BUTTON_W := 180.0


static func open(host: ScreenHost, data: Dictionary, on_bought: Callable = Callable()) -> HubPanel:
	var tree := Vine.new(Vine.load_catalog())
	var body := VBoxContainer.new()
	body.add_theme_constant_override(&"separation", 8)
	var purse := MaterialCount.purse(data, Book.INK, 18, 20.0)
	body.add_child(purse)
	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override(&"h_separation", 8)
	grid.add_theme_constant_override(&"v_separation", 6)
	body.add_child(grid)
	var desc := Book.text("", Book.INK, 16)
	desc.custom_minimum_size = Vector2(430, 44)
	body.add_child(desc)
	var buttons := {}
	for step in 3:
		for branch in tree.branches():
			var n := tree.nodes_of(branch)[step]
			var b := Book.button("", Callable(), BUTTON_W)
			buttons[n.id] = b
			grid.add_child(b)
	var refresh := func() -> void:
		for n in tree.catalog:
			var b: Button = buttons[n.id]
			var state := tree.problem(data, n.id)
			var label := T.t(n.name_key)
			if state == Vine.Problem.OWNED:
				label += " · " + T.t(&"vine_owned")
			else:
				label += " · %d %s" % [n.cost, MaterialCount.short_of(n.material)]
			b.text = label
			b.modulate.a = 0.55 if state == Vine.Problem.NEEDS or state == Vine.Problem.OWNED else 1.0
	var describe := func(n: VineNode) -> void:
		var text := T.t(n.desc_key)
		var state := tree.problem(data, n.id)
		if state == Vine.Problem.NEEDS:
			text += " " + T.t(&"vine_locked", {"a": T.t(tree.find(n.requires).name_key)})
		elif state == Vine.Problem.SHORT:
			text += " " + T.t(&"vine_short")
		desc.text = text
	for n in tree.catalog:
		var b: Button = buttons[n.id]
		b.pressed.connect(func() -> void:
			if tree.buy(data, n.id):
				Save.write()
				if on_bought.is_valid():
					on_bought.call(n.id)
				purse.queue_free()
				purse = MaterialCount.purse(data, Book.INK, 18, 20.0)
				body.add_child(purse)
				body.move_child(purse, 0)
			refresh.call()
			describe.call(n))
		b.focus_entered.connect(describe.bind(n))
	refresh.call()
	var p := HubPanel.new()
	if not host.open(p, [T.t(&"vine_title"), T.t(&"vine_line"), [[&"back", T.t(&"back")]], null, "", body]):
		return null
	var bottom := tree.catalog.filter(func(n: VineNode) -> bool: return n.step == 3)
	var first: Button = buttons[tree.catalog[0].id]
	first.grab_focus.call_deferred()
	p.buttons[0].focus_neighbor_top = p.buttons[0].get_path_to(buttons[bottom[bottom.size() - 1].id])
	for n in bottom:
		(buttons[n.id] as Button).focus_neighbor_bottom = (buttons[n.id] as Button).get_path_to(p.buttons[0])
	return p
