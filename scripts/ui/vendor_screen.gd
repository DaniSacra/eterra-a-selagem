class_name VendorScreen
extends Control
## The Vendedor's stall (Rejogabilidade, Fatia 3; sistemas.md 1.7), a spread of the Livro as the Forja is, opened once
## the Ofícios' first order was delivered (Vendor.state OPEN). The left page the Obras: each its name, what it does,
## its cost in the three materials (MaterialCount, the short ones in the rubric) and Erguer (only when it can be paid;
## made, "Erguida" in green ink). The right page the trades at a loss (Vendor.trades: "Dá 10 Prata", an arrow,
## "Recebe 1 Memória") each with Trocar, and the purse under them. Every action writes the save (only the game's own
## data) and says so (built, traded); the pages read the save again. Esc and B close it (ScreenHost).
##   host.open(VendorScreen.new(), [Save.data])

signal closed
signal built(obra: StringName)
signal traded(index: int)

const SPINE := 0.56
const OUTER := Vector2(22, 12)
const NAME_SIZE := 19
const TEXT_SIZE := 15
const COST_SIZE := 17
const COST_MARK := 18.0
const BUTTON_WIDTH := 150.0

var _data: Dictionary
var def: OficiosDef
var catalog: Array[ObraDef] = []
## The buttons: Erguer per Obra (by id) and Trocar per trade (by index), and Voltar.
var build_buttons: Dictionary = {}
var trade_buttons: Array[Button] = []
var back_button: Button
var _purse: HBoxContainer
var _states: Dictionary = {}
var _costs: Dictionary = {}


func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	def = OficiosDef.live()
	catalog = Vendor.load_catalog()
	name = "vendor_screen"
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
	var book := BookSpread.new().setup(SPINE)
	frame.add_child(book)
	_left_page(book.left)
	_right_page(book.right)
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
	_refresh()
	_first_focus().grab_focus.call_deferred()


func _left_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "obras"
	v.add_theme_constant_override(&"separation", 8)
	page.add_child(v)
	v.add_child(Book.heading(T.t(&"vendor_title"), 30, 300))
	v.add_child(Book.text(T.t(&"vendor_lead"), Book.FADED, TEXT_SIZE))
	v.add_child(Book.section(T.t(&"vendor_obras")))
	for o in catalog:
		var row := HBoxContainer.new()
		row.name = String(o.id)
		row.add_theme_constant_override(&"separation", 12)
		var words := VBoxContainer.new()
		words.add_theme_constant_override(&"separation", 1)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		words.add_child(Book.label(T.t(o.name_key), Book.INK, NAME_SIZE, UiKit.BOLD_FONT))
		words.add_child(Book.text(T.t(o.desc_key), Book.FADED, TEXT_SIZE))
		var cost := HBoxContainer.new()
		cost.name = "cost"
		cost.add_theme_constant_override(&"separation", 14)
		for m: Variant in o.cost:
			cost.add_child(MaterialCount.new().setup(StringName(m), int(o.cost[m]), Book.INK, COST_SIZE, COST_MARK))
		words.add_child(cost)
		_costs[o.id] = cost
		var state := Book.label("", Book.FADED, 14, UiKit.BOLD_FONT)
		state.name = "state"
		words.add_child(state)
		_states[o.id] = state
		row.add_child(words)
		var b := Book.button(T.t(&"vendor_build"), _build.bind(o), BUTTON_WIDTH)
		b.name = "build"
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
		build_buttons[o.id] = b
		v.add_child(row)


func _right_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "trades"
	v.add_theme_constant_override(&"separation", 10)
	page.add_child(v)
	v.add_child(Book.section(T.t(&"vendor_trade")))
	var trades := Vendor.trades(def)
	for i in trades.size():
		var t: Dictionary = trades[i]
		var row := HBoxContainer.new()
		row.name = "trade_%d" % i
		row.add_theme_constant_override(&"separation", 10)
		row.add_child(MaterialCount.new().setup(StringName(t["give"]), int(t["give_n"]), Book.INK, COST_SIZE, COST_MARK, true))
		var arrow := Arrow.new()
		arrow.custom_minimum_size = Vector2(28, 16)
		arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(arrow)
		var get_ := MaterialCount.new().setup(StringName(t["get"]), int(t["get_n"]), Book.INK, COST_SIZE, COST_MARK, true)
		get_.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(get_)
		var b := Book.button(T.t(&"vendor_trade_do"), _trade.bind(i), BUTTON_WIDTH)
		b.name = "trade"
		row.add_child(b)
		trade_buttons.append(b)
		v.add_child(row)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(fill)
	v.add_child(Book.section(T.t(&"forge_balance")))
	_purse = MaterialCount.purse(_data, Book.INK, 22, 24.0)
	v.add_child(_purse)
	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(foot)
	back_button = Book.button(T.t(&"back"), func() -> void: closed.emit(), BUTTON_WIDTH)
	back_button.name = "back"
	foot.add_child(back_button)


## Everything from the save as it is now.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	for o in catalog:
		var b: Button = build_buttons[o.id]
		var st := Vendor.state(_data, def, o)
		var missing := Vendor.missing(_data, o)
		var state: Label = _states[o.id]
		var can := st == Vendor.State.OPEN and missing.is_empty()
		b.visible = st != Vendor.State.DONE
		_enable(b, can)
		(_costs[o.id] as Control).visible = st != Vendor.State.DONE
		for c in (_costs[o.id] as Control).get_children():
			(c as MaterialCount).set_color(Book.RUBRIC if missing.has((c as MaterialCount).id) else Book.INK)
		match st:
			Vendor.State.DONE:
				state.text = T.t(&"vendor_made")
				state.add_theme_color_override(&"font_color", Book.OK)
			Vendor.State.LOCKED:
				state.text = T.t(&"vendor_closed")
				state.add_theme_color_override(&"font_color", Book.FADED)
			_:
				state.text = "" if missing.is_empty() else T.t(&"vendor_short", {"list": short_list(missing)})
				state.add_theme_color_override(&"font_color", Book.RUBRIC)
	for i in trade_buttons.size():
		_enable(trade_buttons[i], Vendor.can_trade(_data, def, i))


## "5 Prata e 1 Esmeralda".
static func short_list(missing: Dictionary) -> String:
	var parts := PackedStringArray()
	for m: Variant in missing:
		parts.append("%d %s" % [int(missing[m]), MaterialCount.short_of(StringName(m))])
	return T.t(&"and_join", {"a": ", ".join(parts.slice(0, parts.size() - 1)), "b": parts[-1]}) if parts.size() > 1 \
		else (parts[0] if not parts.is_empty() else "")


static func _enable(b: Button, on: bool) -> void:
	b.disabled = not on
	b.focus_mode = Control.FOCUS_ALL if on else Control.FOCUS_NONE


func _first_focus() -> Control:
	for o in catalog:
		var b: Button = build_buttons[o.id]
		if b.visible and not b.disabled:
			return b
	for b in trade_buttons:
		if not b.disabled:
			return b
	return back_button


func build(o: ObraDef) -> bool:
	if not Vendor.build(_data, def, o):
		return false
	_save()
	built.emit(o.id)
	_refresh()
	_first_focus().grab_focus()
	return true


func trade(i: int) -> bool:
	if not Vendor.trade(_data, def, i):
		return false
	_save()
	traded.emit(i)
	_refresh()
	if trade_buttons[i].disabled:
		_first_focus().grab_focus()
	return true


func _build(o: ObraDef) -> void:
	build(o)


func _trade(i: int) -> void:
	trade(i)


func _save() -> void:
	Audio.play(&"ui_ok")
	if is_same(_data, Save.data):
		Save.write()


## An arrow in ink from what is given to what comes.
class Arrow extends Control:
	func _draw() -> void:
		var y := size.y * 0.5
		draw_line(Vector2(2, y), Vector2(size.x - 4, y), Book.FADED, 2.0, true)
		draw_colored_polygon(PackedVector2Array([Vector2(size.x - 2, y), Vector2(size.x - 9, y - 5), Vector2(size.x - 9, y + 5)]),
			Book.FADED)
