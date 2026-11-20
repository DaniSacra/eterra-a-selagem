class_name SaveSlotScreen
extends Control
## The first screen of the game (the Daniel, 2026-11-19): the three saves (SaveSlots) side by side on the menus' page
## (UiKit.page over the title art). A save that exists shows the Warrior's crest, its Mastery, descents, victories,
## Prata and Memória and the day of its last descent; an empty one says so and that choosing it starts a new save.
## Choosing a card (Enter, A, a click) emits chosen(n): the caller puts it in use (Save.use) and goes on to the title.
## Under each save that exists a quiet "Apagar" asks first, in a page of its own over the cards ("Apagar o Save N? Não
## há volta."), with Cancelar in focus; only "Apagar" there erases it (Save.erase: the file and its copy).
## Left and right walk the cards, down goes to the card's Apagar; Esc or B closes the question, and closes the screen
## only when it was opened from the title with a save already chosen (back = true).
##   host.open(SaveSlotScreen.new(), [false])
##   screen.chosen.connect(func(n: int) -> void: Save.use(n))

signal chosen(n: int)
signal closed

## px at 720 lines.
const WIDTH := 1010.0
const CARD := Vector2(300, 282)
const CARD_GAP := 22
const CREST := 64.0
const LABEL_SIZE := 14
const VALUE_SIZE := 20
const EMPTY_SIZE := 22
## The card's fill, plain and in focus (the menus' ink; the focus a gold line, like UiKit.focus_row).
const CARD_FILL := Color(0.06, 0.045, 0.075, 0.95)
const CARD_LIT := Color(0.11, 0.08, 0.09, 0.98)
## The erase question: its button in a muted red, never the screen's main colour.
const ERASE_FILL := Color(0.24, 0.06, 0.06, 0.97)
const ERASE_LIT := Color(0.36, 0.09, 0.08, 1.0)
const ERASE_EDGE := Color(0.72, 0.3, 0.24)

## Folder of the saves (SaveSlots; the tests point it at their own).
var base := "user://"
## Esc and B close the screen (opened from the title, a save already chosen).
var back := false
## The cards and their Apagar, by slot (index 0 is Save 1).
var cards: Array[Button] = []
var erasers: Array[Button] = []
## The question on show (null: none) and the slot it asks about.
var question: Control
var asking := 0
var _row: HBoxContainer
var _hint: Label


## folder: where the saves are ("": Save.base, the game's).
func open(can_back: bool = false, folder: String = "") -> void:
	back = can_back
	base = folder if folder != "" else Save.base
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var page := UiKit.page(self, T.t(&"slots_title"), WIDTH, 0.55, 34)
	var lead := UiKit.shadow(UiKit.label(T.t(&"slots_lead"), UiKit.DIM, 17))
	lead.name = "lead"
	lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(lead)
	_row = HBoxContainer.new()
	_row.name = "slots"
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override(&"separation", CARD_GAP)
	page.add_child(_row)
	_hint = UiKit.shadow(UiKit.label("", UiKit.DIM, 15))
	_hint.name = "hint"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(_hint)
	refresh()
	Controls.device_changed.connect(_name_keys)
	_name_keys(Controls.using_pad)
	var start := clampi((Save.slot if Save.slot > 0 else 1) - 1, 0, SaveSlots.COUNT - 1)
	cards[start].grab_focus.call_deferred()
	if Dev.has("slot-ask"):
		# captures: the question over Save N
		_ask.call_deferred(int(Dev.num("slot-ask", 1)))


## Builds the cards again from the disk (after an erase).
func refresh() -> void:
	for c in _row.get_children():
		# freed now: a focus asked for one of them later in this frame finds nothing to call
		c.free()
	cards.clear()
	erasers.clear()
	for i in SaveSlots.COUNT:
		var n := i + 1
		var col := VBoxContainer.new()
		col.name = "slot%d" % n
		col.add_theme_constant_override(&"separation", 6)
		_row.add_child(col)
		var info: Variant = SaveSlots.summary_of(n, base)
		var card := _card(n, info)
		col.add_child(card)
		cards.append(card)
		var erase := UiKit.link(T.t(&"slot_erase"), _ask.bind(n), CARD.x)
		erase.name = "erase"
		# the place stays when there is nothing to erase (the cards keep their line)
		erase.modulate.a = 1.0 if info != null else 0.0
		erase.disabled = info == null
		erase.focus_mode = Control.FOCUS_ALL if info != null else Control.FOCUS_NONE
		erase.mouse_filter = Control.MOUSE_FILTER_STOP if info != null else Control.MOUSE_FILTER_IGNORE
		col.add_child(erase)
		erasers.append(erase)
	for i in cards.size():
		var card := cards[i]
		var erase := erasers[i]
		card.focus_neighbor_top = card.get_path_to(card)
		card.focus_neighbor_bottom = card.get_path_to(erase if not erase.disabled else card)
		card.focus_neighbor_left = card.get_path_to(cards[maxi(i - 1, 0)])
		card.focus_neighbor_right = card.get_path_to(cards[mini(i + 1, cards.size() - 1)])
		erase.focus_neighbor_top = erase.get_path_to(card)
		erase.focus_neighbor_bottom = erase.get_path_to(erase)
		var left := _eraser_or_card(i - 1, -1)
		var right := _eraser_or_card(i + 1, 1)
		erase.focus_neighbor_left = erase.get_path_to(left if not (left as Button).disabled else erase)
		erase.focus_neighbor_right = erase.get_path_to(right if not (right as Button).disabled else erase)


## The nearest Apagar on that side (itself at the end of the row).
func _eraser_or_card(i: int, step: int) -> Control:
	while i >= 0 and i < erasers.size():
		if not erasers[i].disabled:
			return erasers[i]
		i += step
	return erasers[clampi(i - step, 0, erasers.size() - 1)]


func _card(n: int, info: Variant) -> Button:
	var b := Button.new()
	b.name = "card"
	b.custom_minimum_size = CARD
	b.focus_mode = Control.FOCUS_ALL
	var plain := UiKit.box(CARD_FILL, UiKit.EDGE.darkened(0.35), 1, 16, 3)
	var lit := UiKit.box(CARD_LIT, UiKit.GOLD, 2, 16, 3)
	b.add_theme_stylebox_override(&"normal", plain)
	b.add_theme_stylebox_override(&"hover", lit)
	b.add_theme_stylebox_override(&"pressed", lit)
	b.add_theme_stylebox_override(&"focus", lit)
	b.add_theme_stylebox_override(&"disabled", plain)
	b.pressed.connect(func() -> void:
		if question != null:
			return
		Audio.play(&"ui_ok")
		chosen.emit(n))
	b.focus_entered.connect(func() -> void: Audio.play(&"ui_move"))
	b.mouse_entered.connect(func() -> void:
		if question == null:
			b.grab_focus())
	var v := VBoxContainer.new()
	v.name = "body"
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 20
	v.offset_right = -20
	v.offset_top = 16
	v.offset_bottom = -16
	v.add_theme_constant_override(&"separation", 4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 12)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(head)
	var mark: Control = HeroCrest.new().setup(CREST) if info != null else EmptyMark.new().setup(CREST)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(mark)
	# "Save" in Cinzel and the number in lining figures (Cinzel's 1 reads as an I)
	var words := T.t(&"slot_name", {"n": "#"}).split("#")
	var title := HBoxContainer.new()
	title.name = "name"
	title.add_theme_constant_override(&"separation", 0)
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(title)
	for i in words.size():
		if words[i] != "":
			title.add_child(UiKit.shadow(UiKit.label(words[i], UiKit.GOLD, 26, UiKit.TITLE_FONT)))
		if i < words.size() - 1:
			var number := UiKit.shadow(UiKit.label(str(n), UiKit.GOLD, 28, UiKit.number_font()))
			number.name = "number"
			title.add_child(number)
	var rule := GoldRule.new()
	rule.custom_minimum_size = Vector2(CARD.x - 40, 12)
	v.add_child(rule)
	if info == null:
		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(spacer)
		var empty := UiKit.shadow(UiKit.label(T.t(&"slot_empty"), UiKit.DIM.lightened(0.15), EMPTY_SIZE, UiKit.TITLE_FONT))
		empty.name = "empty"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(empty)
		var new_line := UiKit.shadow(UiKit.label(T.t(&"slot_new"), UiKit.PALE, 17))
		new_line.name = "new"
		new_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(new_line)
		var spacer2 := spacer.duplicate()
		v.add_child(spacer2)
		return b
	var grid := GridContainer.new()
	grid.name = "facts"
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 18)
	grid.add_theme_constant_override(&"v_separation", 6)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(grid)
	_fact(grid, &"slot_mastery", UiKit.whole(info.level))
	_fact(grid, &"slot_runs", UiKit.whole(info.runs))
	_fact(grid, &"slot_wins", UiKit.whole(info.wins))
	var purse := HBoxContainer.new()
	purse.name = "purse"
	purse.add_theme_constant_override(&"separation", 14)
	purse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	purse.add_child(MaterialCount.new().setup(MaterialPurse.SILVER, int(info.silver), UiKit.PALE, VALUE_SIZE, 20.0))
	purse.add_child(MaterialCount.new().setup(MaterialPurse.MEMORY, int(info.memory), UiKit.PALE, VALUE_SIZE, 20.0))
	_fact(grid, &"slot_materials", "", purse)
	var when := SaveSlots.date_text(int(info.played_at))
	var last := UiKit.shadow(UiKit.label(T.t(&"slot_last"), UiKit.OLD_GOLD.lightened(0.35), LABEL_SIZE, UiKit.TITLE_FONT))
	v.add_child(last)
	var date := UiKit.shadow(UiKit.label(when if when != "" else T.t(&"slot_never"), UiKit.PALE, 18, UiKit.number_font()))
	date.name = "date"
	v.add_child(date)
	return b


## A line of the card: the name in small old gold, the value in pale lining figures (or a control of its own).
func _fact(grid: GridContainer, key: StringName, value: String, own: Control = null) -> void:
	var l := UiKit.shadow(UiKit.label(T.t(key), UiKit.OLD_GOLD.lightened(0.35), LABEL_SIZE, UiKit.TITLE_FONT))
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	grid.add_child(l)
	if own != null:
		grid.add_child(own)
		return
	var v := UiKit.shadow(UiKit.label(value, UiKit.PALE, VALUE_SIZE, UiKit.number_font()))
	v.name = String(key)
	grid.add_child(v)


## The question before erasing: its own small page over the cards, Cancelar in focus.
func _ask(n: int) -> void:
	if question != null or not SaveSlots.exists(n, base):
		return
	asking = n
	question = Control.new()
	question.name = "question"
	question.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(question)
	var page := UiKit.page(question, T.t(&"slot_erase_ask", {"n": n}), 560.0, 0.7, 28)
	# the save's number in lining figures (Cinzel's 1 reads as an I)
	var head := page.find_child("header", false, false).get_child(0) as Label
	head.add_theme_font_override(&"font", UiKit.number_font())
	var line := UiKit.shadow(UiKit.label(T.t(&"slot_erase_line"), UiKit.PALE, 18))
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size.x = 500
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(line)
	var foot := UiKit.foot(18)
	page.add_child(foot)
	var yes := UiKit.button(T.t(&"slot_erase_yes"), _erase, 200)
	yes.name = "yes"
	yes.add_theme_stylebox_override(&"normal", UiKit.box(ERASE_FILL, ERASE_EDGE, 2, 10))
	yes.add_theme_stylebox_override(&"hover", UiKit.box(ERASE_LIT, ERASE_EDGE.lightened(0.3), 2, 10))
	yes.add_theme_stylebox_override(&"focus", UiKit.box(ERASE_LIT, ERASE_EDGE.lightened(0.3), 3, 10))
	foot.add_child(yes)
	var no := UiKit.button(T.t(&"slot_erase_no"), _unask, 200)
	no.name = "no"
	foot.add_child(no)
	for b: Button in [yes, no]:
		b.focus_neighbor_top = b.get_path_to(b)
		b.focus_neighbor_bottom = b.get_path_to(b)
		b.focus_neighbor_left = b.get_path_to(yes)
		b.focus_neighbor_right = b.get_path_to(no)
	no.grab_focus.call_deferred()


func _erase() -> void:
	var n := asking
	if base == Save.base:
		Save.erase(n)
	else:
		SaveSlots.erase(n, base)
	Audio.play(&"ui_ok")
	question.queue_free()
	question = null
	asking = 0
	refresh()
	cards[n - 1].grab_focus.call_deferred()


## The question closes; the focus goes back to that save's Apagar (or its card, erased).
func _unask() -> void:
	if question == null:
		return
	var n := asking
	question.queue_free()
	question = null
	asking = 0
	var to: Control = erasers[n - 1] if not erasers[n - 1].disabled else cards[n - 1]
	to.grab_focus.call_deferred()


func _name_keys(pad: bool) -> void:
	if is_instance_valid(_hint):
		_hint.text = T.t(&"slot_hint_pad" if pad else &"slot_hint")


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"ui_cancel"):
		return
	if question != null:
		get_viewport().set_input_as_handled()
		_unask()
	elif not back:
		# the first screen: there is nothing behind it (the ScreenHost never sees this Esc)
		get_viewport().set_input_as_handled()
	# with back, the ScreenHost closes the screen (it sees the Esc after this page)


## The mark of an empty save: the crest's ring of old gold round a dark field, with nothing in it.
class EmptyMark:
	extends Control

	func setup(side: float) -> EmptyMark:
		custom_minimum_size = Vector2(side, side)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		return self

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.5 - 2.0
		draw_circle(c, r, Color(UiKit.INK, 0.85))
		draw_arc(c, r, 0.0, TAU, 48, Color(UiKit.OLD_GOLD, 0.6), UiKit.FRAME, true)
		draw_arc(c, r * 0.62, 0.0, TAU, 40, Color(UiKit.OLD_GOLD, 0.25), 1.0, true)
