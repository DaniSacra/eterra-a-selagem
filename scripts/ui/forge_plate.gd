class_name ForgePlate
extends Control
## The bench's plate: the reading of the choice in focus in three seconds (docs/art/forge_spec.md 4). Three columns:
## WHAT (the point's icon, its name, the state in one word and colour), WHAT CHANGES (the sentence with its numbers in
## bold, and the small line of what it replaces or why it waits) and HOW MUCH (the price big, "você tem N" under it, or
## "Sem custo"). At the foot the hammer button with the key's glyph, the verb and the three dots that light a strike at
## a time; with nothing to do the button is gone and the line says why. Drawn in code (iron, a gold thread, rivets).
##   plate.show_info(info, hammer)    # again after each strike (the dots)

const SIZE := Vector2(1000, 214)
const IRON := Color("1a1612")
const BUTTON := Vector2(340, 42)
const BUTTON_AT := Vector2(330, 160)
const FOOT_Y := 160.0
const RED_DIM := Color("c05040")
const EMBER := Color("e07a2a")

signal hovered
signal down
signal up

var info: ForgeInfo
var hammer: ForgeHammer
## The icon: lingot (Temperar), ring (Refinar), stone (Despertar), letter (Inscrever), pick (Oficina).
var icon := &"ingot"
var _name: Label
var _state: Label
var _desc: RichTextLabel
var _detail: Label
var _price: MaterialCount
var _have: Label
var _free: Label
var _why: Label
var _button: ForgeTouch


func setup() -> ForgePlate:
	name = "plate"
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name = UiKit.label("", UiKit.STRONG, 28, UiKit.TITLE_FONT)
	_name.name = "name"
	_name.position = Vector2(94, 20)
	_name.custom_minimum_size.x = 300
	_name.size = Vector2(300, 34)
	_name.clip_text = true
	add_child(_name)
	_state = UiKit.label("", UiKit.PALE, 18, UiKit.BOLD_FONT)
	_state.name = "state"
	_state.position = Vector2(94, 60)
	_state.size = Vector2(290, 48)
	_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_state)
	_desc = UiKit.rich("", UiKit.PALE, 22)
	_desc.name = "effect"
	_desc.position = Vector2(300, 20)
	_desc.size = Vector2(400, 60)
	add_child(_desc)
	_detail = UiKit.label("", UiKit.DIM, 16)
	_detail.name = "step"
	_detail.position = Vector2(300, 100)
	_detail.size = Vector2(400, 48)
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_detail)
	_price = MaterialCount.new().setup(MaterialPurse.SILVER, 0, UiKit.GOLD, 36, 34.0)
	_price.name = "cost"
	_price.position = Vector2(740, 20)
	add_child(_price)
	_have = UiKit.label("", UiKit.DIM, 16)
	_have.name = "have"
	_have.position = Vector2(740, 70)
	add_child(_have)
	_free = UiKit.label(T.t(&"forge_free"), UiKit.PALE, 20)
	_free.name = "free"
	_free.position = Vector2(740, 28)
	add_child(_free)
	_why = UiKit.label("", UiKit.PALE, 16)
	_why.name = "why"
	_why.position = Vector2(20, FOOT_Y)
	_why.size = Vector2(SIZE.x - 40, 42)
	_why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_why.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_why.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_why)
	_button = ForgeTouch.new()
	_button.name = "button"
	_button.position = BUTTON_AT
	_button.size = BUTTON
	_button.hovered.connect(func() -> void: hovered.emit())
	_button.down.connect(func() -> void: down.emit())
	_button.up.connect(func() -> void: up.emit())
	add_child(_button)
	return self


func show_info(p_info: ForgeInfo, p_hammer: ForgeHammer, p_icon: StringName = &"ingot") -> void:
	info = p_info
	hammer = p_hammer
	icon = p_icon
	_name.text = info.name
	_state.text = info.state_text
	var good := info.look == ForgeInfo.Look.READY or info.look == ForgeInfo.Look.ON or info.look == ForgeInfo.Look.STORED
	_state.add_theme_color_override(&"font_color", _state_color())
	_desc.text = BoonCard.strong_numbers(info.desc)
	_detail.text = info.detail
	var price := not info.free and info.cost > 0
	_price.visible = price
	_have.visible = price
	_free.visible = info.free and info.action != ForgeInfo.Action.NONE
	if price:
		_price.set_id(info.material)
		_price.set_amount(info.cost)
		var enough := info.have >= info.cost
		_price.set_color(UiKit.GOLD if enough else RED_DIM)
		_have.text = T.t(&"forge_have", {"n": info.have})
	var acts := info.action != ForgeInfo.Action.NONE
	_button.visible = acts
	_button.mouse_filter = Control.MOUSE_FILTER_STOP if acts else Control.MOUSE_FILTER_IGNORE
	_why.visible = not acts
	_why.text = info.why
	_why.add_theme_color_override(&"font_color", UiKit.PALE if good else UiKit.DIM)
	queue_redraw()


## The state's word in the colour of its state: ember to forge, ash-red for a lack, gold for what is on, dim for a wait.
func _state_color() -> Color:
	match info.look:
		ForgeInfo.Look.READY:
			return Color("f0904a")
		ForgeInfo.Look.SHORT:
			return RED_DIM
		ForgeInfo.Look.ON, ForgeInfo.Look.STORED:
			return UiKit.GOLD
	return UiKit.DIM


## The animated number of the price (the bag counts down after a spend): shows n for the price now.
func show_price(n: int) -> void:
	_price.set_amount(n)


func _process(_delta: float) -> void:
	if hammer != null and info != null and info.spends():
		# a hot piece says how many strikes are left
		var text := T.t(&"forge_hot", {"n": ForgeHammer.STRIKES - hammer.strikes}) if hammer.strikes > 0 else info.state_text
		if _state.text != text:
			_state.text = text
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, SIZE)
	draw_style_box(UiKit.box(Color(IRON, 0.94), Color(UiKit.OLD_GOLD, 0.0), 0, 0, 6), r)
	draw_rect(r.grow(-3.0), UiKit.OLD_GOLD, false, 2.0)
	for c: Vector2 in [Vector2(10, 10), Vector2(SIZE.x - 10, 10), Vector2(10, SIZE.y - 10), Vector2(SIZE.x - 10, SIZE.y - 10)]:
		draw_circle(c, 3.5, UiKit.OLD_GOLD.darkened(0.2))
	if info == null:
		return
	_icon(Vector2(48, 48))
	if info.action != ForgeInfo.Action.NONE:
		_button_draw()


func _icon(c: Vector2) -> void:
	draw_circle(c, 30.0, Color(0, 0, 0, 0.35))
	match icon:
		&"ring":
			draw_arc(c, 15.0, 0.0, TAU, 32, UiKit.OLD_GOLD, 6.0, true)
		&"stone":
			var rr := 18.0
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -rr), c + Vector2(rr, 0), c + Vector2(0, rr), c + Vector2(-rr, 0)]), UiKit.GOLD.darkened(0.15))
		&"letter":
			draw_string(UiKit.TITLE_FONT, c + Vector2(-20, 11), "A", HORIZONTAL_ALIGNMENT_CENTER, 40, 32, UiKit.OLD_GOLD.lightened(0.2))
		&"pick":
			PickMark.paint(self, PickMark.Look.WHOLE, c, 52.0, false)
		_:
			# the ingot of the Temperar: a short trapezoid of iron with a bright top
			var p := PackedVector2Array([c + Vector2(-20, 10), c + Vector2(20, 10), c + Vector2(15, -8), c + Vector2(-15, -8)])
			draw_colored_polygon(p, Color("6a625a"))
			draw_line(c + Vector2(-15, -8), c + Vector2(15, -8), Color("b0a090"), 2.0)


func _button_draw() -> void:
	var r := Rect2(BUTTON_AT, BUTTON)
	var held := hammer != null and hammer.gauge.progress > 0.0
	draw_style_box(UiKit.box(Color(0.25, 0.14, 0.06, 0.97) if not held else Color(0.37, 0.2, 0.08), EMBER, 2, 0, 6), r)
	var key := UiKit.action_label(&"ui_accept")
	var f := UiKit.BOLD_FONT
	var kw := maxf(24.0, f.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 14.0)
	var kr := Rect2(r.position + Vector2(14, 8), Vector2(kw, 26))
	draw_style_box(UiKit.box(Color(0.1, 0.08, 0.07), UiKit.OLD_GOLD, 1, 0, 5), kr)
	draw_string(f, kr.position + Vector2(0, 19), key, HORIZONTAL_ALIGNMENT_CENTER, kw, 16, UiKit.STRONG)
	if held:
		draw_rect(Rect2(r.position + Vector2(6, BUTTON.y - 6), Vector2((BUTTON.x - 12.0) * hammer.gauge.progress, 3.0)), EMBER)
	var x := kr.end.x + 12.0
	draw_string(UiKit.TITLE_FONT, Vector2(x, r.position.y + 28), info.verb(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, UiKit.STRONG)
	if info.spends():
		var vw := UiKit.TITLE_FONT.get_string_size(info.verb(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		var dx := x + vw + 16.0
		var n := hammer.strikes if hammer != null else 0
		for i in 3:
			var c := Vector2(dx + i * 20.0, r.position.y + 21)
			draw_circle(c, 7.0, Color(0.1, 0.07, 0.05))
			if i < n:
				draw_circle(c, 6.0, Color("f5a050"))
			else:
				draw_arc(c, 6.0, 0.0, TAU, 16, Color("8a5a30"), 1.5, true)
		draw_string(UiKit.TEXT_FONT, Vector2(r.end.x + 14.0, r.position.y + 27), T.t(&"forge_hold_hint"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UiKit.DIM)
