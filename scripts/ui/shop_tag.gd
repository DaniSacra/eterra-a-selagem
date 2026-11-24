class_name ShopTag
extends Button
## The leather tag of a counter's offer (docs/art/shop_spec.md B.2 and C.1), lying on the counter: brown leather with an
## ivory stitch, the corners cut on the eyelet side, a brass eyelet. A trade shows what is given, an arrow and what comes;
## an Obra and a Discernimento grade its name over its price. In focus it steps 10 px toward the middle with a ring of old
## gold; a made one is stamped (gold, turned -8 degrees) and dims to 60%. The tag is one Button, so keyboard, pad and
## mouse all land on it; the screen decides what a press does.
##   var tag := ShopTag.new().setup(offer, def, Vector2(320, 76), 1)   # 1: it steps to the right when focused

const SIZE := Vector2(320, 76)
const CUT := 10.0
const STEP := 10.0
const NAME_SIZE := 17
const NUMBER_SIZE := 22
const COST_SIZE := 18
const STAMP := Color("d9b866")

var offer: VendorOffer
var home := Vector2.ZERO
## What the stamp takes from the right of a made tag.
const STAMP_ROOM := 96.0
var _toward := 1.0
var _content: Control
var _stamp: Label
var _costs: Array[MaterialCount] = []
var _tween: Tween


## toward: +1 when the tag steps right on focus (left column), -1 when it steps left (right column).
func setup(p_offer: VendorOffer, def: OficiosDef, p_size: Vector2 = SIZE, p_toward: float = 1.0) -> ShopTag:
	offer = p_offer
	_toward = p_toward
	name = "tag_%s" % offer.id()
	custom_minimum_size = p_size
	size = p_size
	var empty := StyleBoxEmpty.new()
	for style: StringName in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		add_theme_stylebox_override(style, empty)
	_content = Control.new()
	_content.name = "content"
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.position = Vector2(CUT + 24.0, 0)
	_content.size = Vector2(p_size.x - CUT - 36.0, p_size.y)
	add_child(_content)
	if offer.is_trade():
		_trade_face(def)
	else:
		_work_face(def)
	_stamp = UiKit.label("", STAMP, 22, UiKit.TITLE_FONT)
	_stamp.name = "stamp"
	_stamp.visible = false
	_stamp.rotation = deg_to_rad(-8.0)
	_stamp.position = Vector2(p_size.x - 124.0, p_size.y * 0.5 - 14.0)
	UiKit.shadow(_stamp)
	add_child(_stamp)
	focus_entered.connect(_lit.bind(true))
	focus_exited.connect(_lit.bind(false))
	return self


func _row(parent: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 12)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(row)
	return row


## What is given, an arrow of ink, what comes.
func _trade_face(def: OficiosDef) -> void:
	var row := _row(_content)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	for m: Variant in offer.cost(def):
		var c := MaterialCount.new().setup(StringName(m), int(offer.cost(def)[m]), Book.MARK_IVORY, NUMBER_SIZE, 28.0)
		c.name = "give"
		_costs.append(c)
		row.add_child(c)
	var arrow := Arrow.new()
	arrow.custom_minimum_size = Vector2(46, 20)
	arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(arrow)
	for m: Variant in offer.gain(def):
		var g := MaterialCount.new().setup(StringName(m), int(offer.gain(def)[m]), Book.MARK_IVORY, NUMBER_SIZE, 28.0)
		g.name = "get"
		row.add_child(g)


## The name over the price in each material.
func _work_face(def: OficiosDef) -> void:
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override(&"separation", 2)
	_content.add_child(col)
	var title := UiKit.shadow(UiKit.label(offer.title(), Book.MARK_IVORY, NAME_SIZE, UiKit.TITLE_FONT))
	title.name = "name"
	title.clip_text = true
	col.add_child(title)
	var cost := HBoxContainer.new()
	cost.name = "cost"
	cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost.add_theme_constant_override(&"separation", 16)
	col.add_child(cost)
	for m: Variant in offer.cost(def):
		var c := MaterialCount.new().setup(StringName(m), int(offer.cost(def)[m]), Book.MARK_IVORY, COST_SIZE, 20.0)
		_costs.append(c)
		cost.add_child(c)


## The tag as the save stands: the short prices in the faded red, the made one stamped and dimmed.
func refresh(data: Dictionary, def: OficiosDef) -> void:
	var st := offer.state(data, def)
	var missing := offer.missing(data, def)
	for c in _costs:
		c.set_color(ShopArt.SHORT if missing.has(c.id) and st != VendorOffer.State.MADE else Book.MARK_IVORY)
	var made := st == VendorOffer.State.MADE
	_content.modulate.a = 0.4 if made else 1.0
	# the stamp takes the side and the words stay clear of it (UI 20)
	_content.size.x = size.x - CUT - 36.0 - (STAMP_ROOM if made else 0.0)
	_stamp.visible = made
	_stamp.text = offer.state_text(data, def) if made else ""
	queue_redraw()


func _lit(on: bool) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position:x", home.x + (STEP * _toward if on else 0.0), 0.1)
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var body := PackedVector2Array([Vector2(CUT, 0), Vector2(r.end.x, 0), r.end, Vector2(CUT, r.end.y), Vector2(0, r.end.y - CUT),
		Vector2(0, CUT)])
	draw_colored_polygon(body, ShopArt.LEATHER)
	var line := body.duplicate()
	line.append(body[0])
	draw_polyline(line, ShopArt.LEATHER_EDGE, 3.0, true)
	ShopArt.stitch(self, r, 6.0, CUT)
	var eye := Vector2(CUT + 6.0, size.y * 0.5)
	draw_circle(eye, 6.0, ShopArt.BRASS)
	draw_circle(eye, 3.0, ShopArt.LEATHER_EDGE)
	if has_focus():
		draw_polyline(line, UiKit.GOLD, 2.5, true)


## An arrow of ivory ink from what is given to what comes.
class Arrow extends Control:
	func _draw() -> void:
		var y := size.y * 0.5
		draw_line(Vector2(2, y), Vector2(size.x - 6, y), Book.MARK_IVORY, 2.5, true)
		draw_colored_polygon(PackedVector2Array([Vector2(size.x - 1, y), Vector2(size.x - 11, y - 7), Vector2(size.x - 11, y + 7)]),
			Book.MARK_IVORY)
