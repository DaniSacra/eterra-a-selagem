class_name VineScreen
extends Control
## A Videira (V2, Daniel 2026-11-23), the account's roots on the Livro de Ahk's leaf: opened at its own station of the
## Santuário (it was a plain sheet at the Forjador, V1). One wide leaf with the title and its line ("Raízes que fortalecem
## todas as jornadas"), the balance of Prata and Memória, three columns (Vida, Provisão, Perseverança) of three nodes
## each: name, what it does, its price in the right material and its state (Comprada, Falta material, Precisa de: X).
## Choosing a root that can be bought asks first (Comprar, Cancelar at the foot: the price said, nothing spent), then
## buying writes the save and says it (bought). Keys, gamepad and mouse walk the same cards (a click chooses, the
## focus moves to Comprar); Esc and B cancel a question first and close the screen after it. The leaf scales by anchors
## and containers, from 1280 x 720 up.
##   var s := VineScreen.new()
##   host.open(s, [Save.data]); s.bought.connect(func(id: StringName) -> void: ...)

signal closed
signal bought(id: StringName)

const OUTER := Vector2(22, 12)
const CARD_HEIGHT := 112.0
const CARD_PAD := Vector2i(30, 8)
const NAME_SIZE := 20
const TEXT_SIZE := 15
const COST_SIZE := 17
const COST_MARK := 18.0

var _data: Dictionary
var vine: Vine
## The cards by node id, and the foot's buttons.
var cards: Dictionary = {}
var buy_button: Button
var cancel_button: Button
var back_button: Button
## The root being asked about (&"": none).
var pending: StringName = &""
var _states: Dictionary = {}
var _costs: Dictionary = {}
var _purse: HBoxContainer
var _info: Label
var _focus_after: Control


func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	vine = Vine.new(Vine.load_catalog())
	name = "vine_screen"
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, 0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right"]:
		frame.add_theme_constant_override("margin_" + side, int(OUTER.x))
	frame.add_theme_constant_override(&"margin_top", int(OUTER.y))
	frame.add_theme_constant_override(&"margin_bottom", int(ActionBar.RESERVE))
	add_child(frame)
	var leaf := BookSpread.new().setup(0.5, true)
	frame.add_child(leaf)
	var page := VBoxContainer.new()
	page.name = "page"
	page.add_theme_constant_override(&"separation", 10)
	leaf.left.add_child(page)
	_head(page)
	var columns := HBoxContainer.new()
	columns.name = "columns"
	columns.add_theme_constant_override(&"separation", 18)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(columns)
	for branch in vine.branches():
		columns.add_child(_column(branch))
	page.add_child(_foot())
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), _back)])
	_chain()
	_refresh()
	_first_focus().grab_focus.call_deferred()


func _head(page: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 16)
	page.add_child(row)
	var words := VBoxContainer.new()
	words.add_theme_constant_override(&"separation", 2)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_child(Book.heading(T.t(&"vine_title"), 32, 320))
	var line := Book.text(T.t(&"vine_line"), Book.FADED, 17)
	line.name = "line"
	words.add_child(line)
	row.add_child(words)
	var money := VBoxContainer.new()
	money.add_theme_constant_override(&"separation", 2)
	money.add_child(Book.section(T.t(&"vine_balance")))
	_purse = MaterialCount.purse(_data, Book.INK, 22, 24.0)
	money.add_child(_purse)
	row.add_child(money)


func _column(branch: StringName) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.name = String(branch)
	col.add_theme_constant_override(&"separation", 8)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(Book.section(T.t(StringName("vine_branch_%s" % branch)), 17))
	for n in vine.nodes_of(branch):
		col.add_child(_card(n))
	return col


## A node: a paper button holding its name, its effect, its price and its state.
func _card(n: VineNode) -> Button:
	var b := Book.button("", _choose.bind(n.id), 0.0)
	b.name = String(n.id)
	b.custom_minimum_size = Vector2(0, CARD_HEIGHT)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override(&"margin_left", CARD_PAD.x)
	pad.add_theme_constant_override(&"margin_right", 10)
	pad.add_theme_constant_override(&"margin_top", CARD_PAD.y)
	pad.add_theme_constant_override(&"margin_bottom", CARD_PAD.y)
	b.add_child(pad)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override(&"separation", 2)
	pad.add_child(v)
	var title := Book.label(T.t(n.name_key), Book.INK, NAME_SIZE, UiKit.TITLE_FONT)
	title.name = "name"
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(title)
	var desc := Book.text(T.t(n.desc_key), Book.FADED, TEXT_SIZE)
	desc.name = "desc"
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(desc)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(fill)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 12)
	v.add_child(row)
	var cost := MaterialCount.new().setup(n.material, n.cost, Book.INK, COST_SIZE, COST_MARK, true)
	cost.name = "cost"
	row.add_child(cost)
	_costs[n.id] = cost
	var state := Book.label("", Book.FADED, 14, UiKit.BOLD_FONT)
	state.name = "state"
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	state.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(state)
	_states[n.id] = state
	cards[n.id] = b
	return b


func _foot() -> HBoxContainer:
	var foot := HBoxContainer.new()
	foot.name = "foot"
	foot.add_theme_constant_override(&"separation", 14)
	_info = Book.text("", Book.INK, 18)
	_info.name = "info"
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(_info)
	buy_button = Book.primary(Book.button(T.t(&"vine_buy"), confirm, 150.0))
	buy_button.name = "buy"
	foot.add_child(buy_button)
	cancel_button = Book.button(T.t(&"vine_cancel"), cancel, 150.0)
	cancel_button.name = "cancel"
	foot.add_child(cancel_button)
	back_button = Book.button(T.t(&"back"), func() -> void: closed.emit(), 150.0)
	back_button.name = "back"
	foot.add_child(back_button)
	return foot


## Up and down walk a column, left and right walk across the columns on the same step, the foot is under the last row.
func _chain() -> void:
	var branches := vine.branches()
	for bi in branches.size():
		var nodes := vine.nodes_of(branches[bi])
		for si in nodes.size():
			var b: Button = cards[nodes[si].id]
			if bi > 0:
				b.focus_neighbor_left = b.get_path_to(cards[vine.nodes_of(branches[bi - 1])[si].id])
			else:
				b.focus_neighbor_left = b.get_path_to(b)
			if bi < branches.size() - 1:
				b.focus_neighbor_right = b.get_path_to(cards[vine.nodes_of(branches[bi + 1])[si].id])
			else:
				b.focus_neighbor_right = b.get_path_to(b)
			b.focus_neighbor_top = b.get_path_to(cards[nodes[si - 1].id] if si > 0 else b)
			b.focus_neighbor_bottom = b.get_path_to(cards[nodes[si + 1].id] if si < nodes.size() - 1 else back_button)
	back_button.focus_neighbor_top = back_button.get_path_to(cards[vine.nodes_of(branches[0])[-1].id])
	back_button.focus_neighbor_left = back_button.get_path_to(back_button)
	back_button.focus_neighbor_right = back_button.get_path_to(back_button)
	buy_button.focus_neighbor_right = buy_button.get_path_to(cancel_button)
	cancel_button.focus_neighbor_left = cancel_button.get_path_to(buy_button)
	cancel_button.focus_neighbor_right = cancel_button.get_path_to(back_button)
	buy_button.focus_neighbor_top = buy_button.get_path_to(cards[vine.nodes_of(branches[0])[-1].id])
	cancel_button.focus_neighbor_top = cancel_button.get_path_to(cards[vine.nodes_of(branches[0])[-1].id])
	buy_button.focus_neighbor_left = buy_button.get_path_to(buy_button)
	buy_button.focus_neighbor_bottom = buy_button.get_path_to(buy_button)
	cancel_button.focus_neighbor_bottom = cancel_button.get_path_to(cancel_button)


## Everything from the save as it is now: the balance, each card's price colour and state, the foot's line and buttons.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	for n in vine.catalog:
		var b: Button = cards[n.id]
		var st := vine.state(_data, n.id)
		var cost: MaterialCount = _costs[n.id]
		var state: Label = _states[n.id]
		cost.visible = st != Vine.State.OWNED
		cost.set_color(Book.RUBRIC if st == Vine.State.SHORT else Book.INK)
		match st:
			Vine.State.OWNED:
				state.text = T.t(&"vine_owned")
				state.add_theme_color_override(&"font_color", Book.OK)
			Vine.State.SHORT:
				state.text = T.t(&"vine_short")
				state.add_theme_color_override(&"font_color", Book.RUBRIC)
			Vine.State.LOCKED:
				state.text = T.t(&"vine_locked", {"a": T.t(vine.find(n.requires).name_key)})
				state.add_theme_color_override(&"font_color", Book.FADED)
			_:
				state.text = ""
		b.modulate.a = 0.6 if st == Vine.State.LOCKED else 1.0
	var asking := pending != &""
	buy_button.visible = asking
	cancel_button.visible = asking
	back_button.visible = not asking
	if asking:
		var n := vine.find(pending)
		_info.text = T.t(&"vine_confirm", {"a": T.t(n.name_key), "b": n.cost, "c": MaterialCount.short_of(n.material)})
	else:
		_info.text = T.t(&"vine_pick") if vine.bought_count(_data) == 0 else ""
	_chain()


## A card pressed: a root that can be bought asks first; any other just says why it cannot (its card shows it).
func _choose(id: StringName) -> void:
	select(id)


## Asks about a root (true when it can be bought now); the focus goes to Comprar.
func select(id: StringName) -> bool:
	if vine.state(_data, id) != Vine.State.AVAILABLE:
		return false
	pending = id
	_focus_after = cards[id]
	_refresh()
	buy_button.grab_focus.call_deferred()
	return true


## Buys the root asked about: written in the save and said (bought). False with no question open.
func confirm() -> bool:
	if pending == &"":
		return false
	var id := pending
	pending = &""
	if not vine.buy(_data, id):
		_refresh()
		return false
	Audio.play(&"ui_ok")
	if is_same(_data, Save.data):
		Save.write()
	bought.emit(id)
	_refresh()
	(cards[id] as Button).grab_focus.call_deferred()
	return true


## Drops the question: nothing is spent and the focus goes back to the card.
func cancel() -> void:
	if pending == &"":
		return
	pending = &""
	_refresh()
	if _focus_after != null:
		_focus_after.grab_focus.call_deferred()


func _back() -> void:
	if pending != &"":
		cancel()
	else:
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if pending != &"" and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		cancel()


func _first_focus() -> Control:
	for n in vine.catalog:
		if vine.state(_data, n.id) == Vine.State.AVAILABLE:
			return cards[n.id]
	return cards[vine.nodes_of(vine.branches()[0])[0].id]
