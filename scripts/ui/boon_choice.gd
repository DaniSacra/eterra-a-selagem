class_name BoonChoice
extends Control
## Level up: the run stops and three gifts are offered. One is chosen with the mouse, the keys 1 to 3, or a gamepad.

signal chosen(boon: Boon)

const CARD := Vector2(96, 112)
const ARM_TIME := 0.35
const REST_HEAL := 20

var _cards: Array[Button] = []
var _offers: Array[Boon] = []
var _armed := 0.0


func open(offers: Array[Boon], boons: BoonState) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiKit.veil(0.55))
	_offers = offers
	var title := UiKit.label(T.t(&"choice_title"), Palette.c(&"luz", 0), UiKit.BIG)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 8
	add_child(title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_top = 38
	row.offset_bottom = -30
	add_child(row)
	if offers.is_empty():
		_cards.append(_card(row, null, 0, 0))
	for i in offers.size():
		_cards.append(_card(row, offers[i], boons.level(offers[i].id) + 1, i))
	var hint := UiKit.label(T.t(&"choice_hint"), Palette.c(&"neve", 2))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -18
	add_child(hint)
	_armed = ARM_TIME
	for c in _cards:
		c.disabled = true
	Audio.play(&"level_up")


func _process(delta: float) -> void:
	if _armed > 0.0:
		_armed -= delta
		if _armed <= 0.0:
			for c in _cards:
				c.disabled = false
			_cards[0].grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if _armed > 0.0 or not event.is_pressed():
		return
	var idx := (event as InputEventKey).physical_keycode - KEY_1
	if idx >= 0 and idx < _cards.size():
		_pick(idx)


func _pick(index: int) -> void:
	Audio.play(&"boon")
	chosen.emit(_offers[index] if index < _offers.size() else null)


func _card(row: Container, b: Boon, level: int, index: int) -> Button:
	var card := UiKit.button("")
	card.custom_minimum_size = CARD
	card.pressed.connect(_pick.bind(index))
	row.add_child(card)
	var family: StringName = b.color_family() if b else &"luz"
	var band := ColorRect.new()
	band.color = Palette.c(family, 4)
	band.position = Vector2(1, 1)
	band.size = Vector2(CARD.x - 2, 16)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(band)
	var ic := UiKit.icon(b.icon if b else 6)
	ic.position = Vector2(4, 4)
	card.add_child(ic)
	var fam := UiKit.label(T.t(Boon.FAMILY_KEY[b.family]).get_slice(",", 0) if b else "", Palette.c(family, 0))
	fam.position = Vector2(18, 3)
	card.add_child(fam)
	var num := UiKit.label(str(index + 1), Palette.c(family, 1))
	num.position = Vector2(CARD.x - 10, 3)
	card.add_child(num)
	var name_label := UiKit.label(T.t("boon_%s" % b.id) if b else T.t(&"boon_rest"), Palette.c(family, 0))
	_wrap(name_label, Vector2(5, 20), 26)
	card.add_child(name_label)
	var state := ""
	if b:
		state = T.t(&"choice_new") if level == 1 else T.t(&"choice_level", {"n": level, "max": b.max_level})
	var lv := UiKit.label(state, Palette.c(&"neve", 3))
	lv.position = Vector2(5, 45)
	card.add_child(lv)
	var desc := UiKit.label(UiKit.boon_desc(b, level) if b else T.t(&"boon_rest_desc", {"a": REST_HEAL}), Palette.c(&"neve", 1))
	_wrap(desc, Vector2(5, 58), 52)
	card.add_child(desc)
	return card


func _wrap(l: Label, at: Vector2, height: float) -> void:
	l.position = at
	l.custom_minimum_size = Vector2(CARD.x - 9, height)
	l.size = l.custom_minimum_size
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.clip_text = false
