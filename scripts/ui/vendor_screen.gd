class_name VendorScreen
extends Control
## The Vendedor's counter (docs/art/shop_spec.md B, redone 2026-11-23 as the merchant's balance; docs/art/meta_identities.md 4),
## open once the Ofícios' first order was delivered (Vendor.state OPEN). A striped awning, the counter, and a brass balance in
## the middle; on the left the Trocas of materials at a loss (Vendor.trades), on the right the Obras and, since the night of
## 2026-11-23, the two grades of the Discernimento (moved out of the Livro de Ahk, which only reads now). Each is a leather
## tag (ShopTag); a reading plate (VendorPlate) says what the one in focus is, what it changes and what it costs with "Você
## tem N". Nothing scrolls. The gesture is "pôr no prato": the first press puts the offer on the plates (the beam leans toward
## what is given), the second, on "Fechar a troca", closes the deal by the rules that already were (VendorOffer asks Vendor
## and Discern) and writes the save; B takes it off the plate without spending, and closes the screen when the plate is empty.
## The 1280 x 720 stage scales evenly to the window and is centred (VineScreen's way).
##   host.open(VendorScreen.new(), [Save.data])
## Captures: --title --screen=vendor [--silver=N --memory=N --emerald=N --made=obra_altar --discern=1 --place=<offer index>].

signal closed
signal built(obra: StringName)
signal traded(index: int)
signal discerned(grade: int)

const STAGE := Vector2(1280, 720)
const AWNING := Rect2(0, 0, 1280, 70)
const FRINGE := 16.0
const COUNTER_TOP := 560.0
const TRADE_X := 40.0
const WORK_X := 920.0
const TRADE_Y := 140.0
const TRADE_PITCH := 88.0
const WORK_Y := 182.0
const WORK_PITCH := 76.0
const WORK_SIZE := Vector2(320, 70)
const PLATE_POS := Vector2(400, 404)
const CLOSE_SIZE := Vector2(300, 44)

var _data: Dictionary
var def: OficiosDef
var catalog: Array[ObraDef] = []
var offers: Array[VendorOffer] = []
## The tags by offer id, the offer on the plates ("" none) and the one the plate reads.
var tags: Dictionary = {}
var placed: VendorOffer
var shown: VendorOffer
var close_button: Button
var balance: VendorScale
var plate: VendorPlate
var bar: ActionBar
var _stage: Control
var _purse: HBoxContainer
var _trade_tags: Array[ShopTag] = []
var _work_tags: Array[ShopTag] = []


func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	def = OficiosDef.live()
	catalog = Vendor.load_catalog()
	offers = VendorOffer.all(def, catalog)
	name = "vendor_screen"
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ground := ColorRect.new()
	ground.color = ShopArt.WOOD.darkened(0.5)
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ground)
	_stage = Control.new()
	_stage.name = "stage"
	_stage.size = STAGE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.clip_contents = true
	add_child(_stage)
	resized.connect(_place_stage)
	_place_stage()
	_stage.add_child(Backdrop.new())
	_head()
	_columns()
	balance = VendorScale.new()
	balance.size = STAGE
	balance.settled.connect(_settled)
	_stage.add_child(balance)
	plate = VendorPlate.new()
	plate.position = PLATE_POS
	_stage.add_child(plate)
	close_button = UiKit.button("", press_close, CLOSE_SIZE.x)
	close_button.name = "close"
	close_button.custom_minimum_size = CLOSE_SIZE
	close_button.size = CLOSE_SIZE
	close_button.position = Vector2((STAGE.x - CLOSE_SIZE.x) * 0.5, 584.0 - CLOSE_SIZE.y * 0.5)
	close_button.visible = false
	_stage.add_child(close_button)
	bar = ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_put"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), cancel)])
	_refresh()
	var first := first_offer()
	(tags[first.id()] as ShopTag).grab_focus.call_deferred()
	_see(first)
	if Dev.has("place"):
		var i := clampi(int(Dev.num("place", 0)), 0, offers.size() - 1)
		(tags[offers[i].id()] as ShopTag).grab_focus.call_deferred()
		put(offers[i])


## The stage at the largest even scale that fits the window, centred (1280 x 720 up to 1920 x 1080 and over).
func _place_stage() -> void:
	if _stage == null:
		return
	var k := minf(size.x / STAGE.x, size.y / STAGE.y)
	_stage.scale = Vector2(k, k)
	_stage.position = ((size - STAGE * k) * 0.5).floor()


func _head() -> void:
	var title := UiKit.shadow(UiKit.label(T.t(&"vendor_title"), UiKit.STRONG, 28, UiKit.TITLE_FONT))
	title.name = "title"
	title.position = Vector2(0, 14)
	title.size = Vector2(STAGE.x, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stage.add_child(title)
	_purse = CoinCorner.wallet(_data)
	CoinCorner.place(_purse, 1256.0, 104.0)
	_stage.add_child(_purse)


## The two columns of tags: the Trocas on the left, the Obras and the Discernimento on the right.
func _columns() -> void:
	_stage.add_child(_heading(T.t(&"vendor_trades"), Vector2(TRADE_X, 104)))
	_stage.add_child(_heading(T.t(&"vendor_obras"), Vector2(WORK_X, 150)))
	for o in offers:
		var left := o.is_trade()
		var list := _trade_tags if left else _work_tags
		var tag := ShopTag.new().setup(o, def, ShopTag.SIZE if left else WORK_SIZE, 1.0 if left else -1.0)
		tag.home = Vector2(TRADE_X, TRADE_Y + TRADE_PITCH * list.size()) if left \
			else Vector2(WORK_X, WORK_Y + WORK_PITCH * list.size())
		tag.position = tag.home
		tag.pressed.connect(press_tag.bind(o))
		tag.focus_entered.connect(_see.bind(o))
		tag.mouse_entered.connect(_hover.bind(tag))
		list.append(tag)
		tags[o.id()] = tag
		_stage.add_child(tag)
	_wire()


func _heading(text: String, at: Vector2) -> Label:
	var l := UiKit.shadow(UiKit.label(text, UiKit.GOLD, 18, UiKit.TITLE_FONT))
	l.position = at
	return l


## Focus walks a column with up and down, and crosses to the other with left and right (to the same row), through the
## button of the middle while it is lit.
func _wire() -> void:
	for col: Array in [_trade_tags, _work_tags]:
		for i in col.size():
			var t: ShopTag = col[i]
			t.focus_neighbor_top = t.get_path_to(col[maxi(i - 1, 0)])
			t.focus_neighbor_bottom = t.get_path_to(col[mini(i + 1, col.size() - 1)])
	for i in _trade_tags.size():
		var t := _trade_tags[i]
		var across: Control = close_button if close_button != null and close_button.visible else _work_tags[mini(i, _work_tags.size() - 1)]
		t.focus_neighbor_right = t.get_path_to(across)
		t.focus_neighbor_left = t.get_path_to(t)
	for i in _work_tags.size():
		var t := _work_tags[i]
		t.focus_neighbor_left = t.get_path_to(_trade_tags[mini(i, _trade_tags.size() - 1)])
		t.focus_neighbor_right = t.get_path_to(t)
	if close_button != null and placed != null:
		var own := tag_of(placed)
		close_button.focus_neighbor_top = close_button.get_path_to(close_button)
		close_button.focus_neighbor_bottom = close_button.get_path_to(close_button)
		close_button.focus_neighbor_left = close_button.get_path_to(own if placed.is_trade() else _trade_tags[0])
		close_button.focus_neighbor_right = close_button.get_path_to(own if not placed.is_trade() else _work_tags[0])


func tag_of(o: VendorOffer) -> ShopTag:
	return tags[o.id()]


## The first the person can pay among the trades; none: the first Obra.
func first_offer() -> VendorOffer:
	for o in offers:
		if o.is_trade() and o.state(_data, def) == VendorOffer.State.CAN:
			return o
	return _work_tags[0].offer if not _work_tags.is_empty() else offers[0]


# ---- reading and the plates ----

## The plate reads the offer in focus; the balance previews it (unless another is already put).
func _see(o: VendorOffer) -> void:
	if placed != null and placed != o:
		take(false)
	shown = o
	plate.show_offer(o, _data, def)
	if placed == null and not balance.busy:
		balance.show_offer(_give_of(o), _get_of(o))


func _hover(t: ShopTag) -> void:
	if placed == null:
		t.grab_focus()


## What the left plate carries: the prices.
func _give_of(o: VendorOffer) -> Control:
	var row := HBoxContainer.new()
	row.name = "give"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 10)
	var price := o.cost(def)
	for m: Variant in price:
		row.add_child(MaterialCount.new().setup(StringName(m), int(price[m]), UiKit.STRONG, 22, 26.0))
	row.custom_minimum_size = Vector2(VendorScale.PLATE.x, 36)
	return row


## What the right plate carries: the material that comes (a trade) or the Obra's picture (final art, else a reward icon).
func _get_of(o: VendorOffer) -> Control:
	var box := HBoxContainer.new()
	box.name = "get"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.custom_minimum_size = Vector2(VendorScale.PLATE.x, 48)
	if o.is_trade():
		var g := o.gain(def)
		for m: Variant in g:
			box.add_child(MaterialCount.new().setup(StringName(m), int(g[m]), UiKit.STRONG, 22, 26.0))
		return box
	var icon := TextureRect.new()
	icon.texture = icon_of(o)
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(icon)
	return box


## The picture of an Obra or a grade: assets/ui/shop/<id>.png when it exists, else the reward icon that nearly says it.
static func icon_of(o: VendorOffer) -> Texture2D:
	var own := ShopArt.texture(String(o.id()))
	if own != null:
		return own
	var stand_in := "boon"
	match String(o.id()):
		"obra_altar":
			stand_in = "altar"
		"obra_fonte":
			stand_in = "fountain"
		"obra_banca":
			stand_in = "shop"
	return load("res://assets/ui/rewards/%s.png" % stand_in) as Texture2D


# ---- the gesture ----

## The press on a tag: puts the offer on the plates; a second press on the one already there closes the deal.
func press_tag(o: VendorOffer) -> void:
	if placed == o:
		press_close()
		return
	put(o)


## Puts the offer on the plates (the first press). A made one stays where it is.
func put(o: VendorOffer) -> bool:
	if o.state(_data, def) == VendorOffer.State.MADE:
		return false
	if placed != null and placed != o:
		take(false)
	if placed != o:
		shown = o
		plate.show_offer(o, _data, def)
		balance.show_offer(_give_of(o), _get_of(o))
	placed = o
	balance.put(o.tilt(def))
	_set_close()
	Audio.play(&"ui_move")
	if close_button.visible and not close_button.disabled:
		close_button.grab_focus()
	return true


## B: off the plate with nothing spent.
func take(refocus := true) -> void:
	if placed == null:
		return
	var o := placed
	placed = null
	balance.take()
	_set_close()
	if refocus and is_inside_tree() and not tag_of(o).has_focus():
		tag_of(o).grab_focus()


## The button of the middle for the offer on the plates: its verb when it can be paid, the reason when it cannot.
func _set_close() -> void:
	close_button.visible = placed != null
	if placed != null:
		var st := placed.state(_data, def)
		var can := st == VendorOffer.State.CAN
		close_button.disabled = not can
		close_button.text = _deal_text(placed) if can else placed.state_text(_data, def)
		bar.item(&"ui_accept").set_verb(_deal_text(placed))
	else:
		bar.item(&"ui_accept").set_verb(T.t(&"bar_put"))
	_wire()


static func _deal_text(o: VendorOffer) -> String:
	match o.kind:
		VendorOffer.Kind.TRADE:
			return T.t(&"vendor_deal_trade")
		VendorOffer.Kind.OBRA:
			return T.t(&"vendor_deal_obra")
	return T.t(&"vendor_deal_discern")


## The second press: the deal is made by the rules (VendorOffer.commit), the save written, the plates emptied.
func press_close() -> bool:
	if placed == null or placed.state(_data, def) != VendorOffer.State.CAN:
		return false
	var o := placed
	if not o.commit(_data, def):
		return false
	Audio.play(&"ui_ok")
	if is_same(_data, Save.data):
		Save.write()
	placed = null
	balance.settle()
	match o.kind:
		VendorOffer.Kind.TRADE:
			traded.emit(o.index)
		VendorOffer.Kind.OBRA:
			built.emit(o.obra.id)
		_:
			discerned.emit(o.index)
	_refresh()
	_set_close()
	var back := tag_of(o) if o.state(_data, def) != VendorOffer.State.MADE else tag_of(first_offer())
	back.grab_focus()
	_see(back.offer)
	return true


## The plates are empty again: preview what the focus rests on.
func _settled() -> void:
	if placed == null and shown != null:
		balance.show_offer(_give_of(shown), _get_of(shown))


## B and Esc: take it off the plate; with the plate empty, close the screen.
func cancel() -> void:
	if placed != null:
		take()
	else:
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and placed != null:
		get_viewport().set_input_as_handled()
		take()
		return
	if event.is_action_pressed(&"tab_next") or event.is_action_pressed(&"tab_prev"):
		_cross(event.is_action_pressed(&"tab_next"))


## LB and RB, Page Up and Down: to the other column, on the same row.
func _cross(to_works: bool) -> void:
	if placed != null or shown == null:
		return
	var from: Array[ShopTag] = _trade_tags if shown.is_trade() else _work_tags
	var into: Array[ShopTag] = _work_tags if to_works else _trade_tags
	if from == into:
		return
	var row := 0
	for i in from.size():
		if from[i].offer == shown:
			row = i
	into[mini(row, into.size() - 1)].grab_focus()


## Everything as the save stands now.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	for o in offers:
		tag_of(o).refresh(_data, def)
	if shown != null:
		plate.show_offer(shown, _data, def)


## The wall, the counter and the awning behind it all (placeholder drawing until assets/ui/shop/ has them).
class Backdrop extends Control:
	func _init() -> void:
		name = "backdrop"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = VendorScreen.STAGE

	func _draw() -> void:
		ShopArt.counter(self, Rect2(0, VendorScreen.AWNING.end.y, 1280, 650), VendorScreen.COUNTER_TOP, 40.0)
		ShopArt.awning(self, VendorScreen.AWNING, VendorScreen.FRINGE)
