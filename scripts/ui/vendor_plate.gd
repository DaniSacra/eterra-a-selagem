class_name VendorPlate
extends Control
## The reading plate of the Vendedor's counter (docs/art/shop_spec.md B.4), 480 x 144 in dark leather with an ivory
## stitch: what the offer in focus is, in three lines that read in three seconds. Line 1 its name and, at the right, its
## state in words and colour; line 2 what it changes, the numbers in bold; line 3 what it costs with "Você tem N" under
## each price. Nothing scrolls and nothing is asked: the press is on the tag and the button beside it.
##   plate.show_offer(offer, data, def)      plate.clear()

const SIZE := Vector2(480, 144)
const MARGIN := 14.0
const OK_LIT := Color("7fc79a")

var name_label: Label
var state_label: Label
var effect: RichTextLabel
var costs: HBoxContainer


func _init() -> void:
	name = "plate"
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label = UiKit.shadow(UiKit.label("", UiKit.STRONG, 22, UiKit.TITLE_FONT))
	name_label.name = "name"
	name_label.position = Vector2(MARGIN, 8)
	name_label.size = Vector2(SIZE.x * 0.5, 30)
	name_label.clip_text = true
	add_child(name_label)
	state_label = UiKit.label("", UiKit.PALE, 16, UiKit.BOLD_FONT)
	state_label.name = "state"
	state_label.position = Vector2(SIZE.x * 0.5, 12)
	state_label.size = Vector2(SIZE.x * 0.5 - MARGIN, 24)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state_label.clip_text = true
	add_child(state_label)
	effect = UiKit.rich("", UiKit.PALE, 18)
	effect.name = "effect"
	effect.position = Vector2(MARGIN, 40)
	effect.size = Vector2(SIZE.x - MARGIN * 2.0, 44)
	add_child(effect)
	costs = HBoxContainer.new()
	costs.name = "costs"
	costs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	costs.position = Vector2(MARGIN, 90)
	costs.size = Vector2(SIZE.x - MARGIN * 2.0, 48)
	costs.add_theme_constant_override(&"separation", 30)
	add_child(costs)


func clear() -> void:
	name_label.text = ""
	state_label.text = ""
	effect.text = ""
	for c in costs.get_children():
		c.queue_free()


func show_offer(offer: VendorOffer, data: Dictionary, def: OficiosDef) -> void:
	clear()
	var st := offer.state(data, def)
	name_label.text = offer.title()
	state_label.text = offer.state_text(data, def)
	var lit := UiKit.GOLD
	if st == VendorOffer.State.MADE:
		lit = OK_LIT
	elif st != VendorOffer.State.CAN:
		lit = ShopArt.SHORT
	state_label.add_theme_color_override(&"font_color", lit)
	effect.text = bold_numbers(offer.effect(def))
	var missing := offer.missing(data, def)
	var price := offer.cost(def)
	for m: Variant in price:
		var id := StringName(m)
		var cell := VBoxContainer.new()
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_theme_constant_override(&"separation", 0)
		cell.add_child(MaterialCount.new().setup(id, int(price[m]),
			ShopArt.SHORT if missing.has(id) else UiKit.STRONG, 22, 24.0))
		var have := UiKit.label(T.t(&"vendor_have", {"n": MaterialCount.amount_of(data, id)}), UiKit.DIM, 15)
		have.name = "have"
		cell.add_child(have)
		costs.add_child(cell)


## The numbers of a text in bold ivory for a RichTextLabel ("55%", "10").
static func bold_numbers(s: String) -> String:
	var re := RegEx.new()
	re.compile("\\d+%?")
	var out := ""
	var at := 0
	for m in re.search_all(s):
		out += s.substr(at, m.get_start() - at) + UiKit.strong(m.get_string())
		at = m.get_end()
	return out + s.substr(at)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, SIZE)
	draw_rect(r, ShopArt.PLATE_LEATHER)
	draw_rect(r, ShopArt.LEATHER_EDGE, false, 3.0)
	ShopArt.stitch(self, r, 4.0)
