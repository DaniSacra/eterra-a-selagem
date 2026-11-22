class_name AccountSheet
extends RefCounted
## The account's tree "O Preparo" at the Forjador (Lote 5; a plain first version for the ui-ux-designer to dress): one leaf of
## the hub (HubPanel) with the purse, a grid of the nodes as buttons (name and price; the owned ones marked) and, under
## it, what the one in focus does. Enter on a node buys it (Account.buy), writes the save and says so. Esc closes.
##   AccountSheet.open(host, Save.data, on_bought: Callable)   # on_bought(id) after each purchase

const COLUMNS := 2
const BUTTON_W := 255.0


static func open(host: ScreenHost, data: Dictionary, on_bought: Callable = Callable()) -> HubPanel:
	var tree := Account.new(Account.load_catalog())
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
	for n in tree.catalog:
		var b := Book.button("", Callable(), BUTTON_W)
		buttons[n.id] = b
		grid.add_child(b)
	var refresh := func() -> void:
		for n in tree.catalog:
			var b: Button = buttons[n.id]
			var state := tree.problem(data, n.id)
			var label := T.t(n.name_key)
			if state == Account.Problem.OWNED:
				label += " · " + T.t(&"account_owned")
			else:
				label += " · %d %s" % [n.cost, MaterialCount.short_of(n.material)]
			b.text = label
			b.modulate.a = 0.55 if state == Account.Problem.NEEDS or state == Account.Problem.OWNED else 1.0
	var describe := func(n: AccountNode) -> void:
		var text := T.t(n.desc_key)
		var state := tree.problem(data, n.id)
		if state == Account.Problem.NEEDS:
			text += " " + T.t(&"account_locked", {"a": T.t(tree.find(n.requires).name_key)})
		elif state == Account.Problem.SHORT:
			text += " " + T.t(&"account_short")
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
	if not host.open(p, [T.t(&"account_title"), T.t(&"account_line"), [[&"back", T.t(&"back")]], null, "", body]):
		return null
	var first: Button = buttons[tree.catalog[0].id]
	first.grab_focus.call_deferred()
	p.buttons[0].focus_neighbor_top = p.buttons[0].get_path_to(buttons[tree.catalog[tree.catalog.size() - 1].id])
	for n in tree.catalog.slice(tree.catalog.size() - COLUMNS):
		(buttons[n.id] as Button).focus_neighbor_bottom = (buttons[n.id] as Button).get_path_to(p.buttons[0])
	return p
