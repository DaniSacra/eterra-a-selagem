class_name HeroPickScreen
extends Control
## The hero's pick at its own station of the Santuário (PT-9, Daniel 2026-11-23: it left the Portal), beside the Vendedor:
## one small leaf of the Livro de Ahk with a card per hero (SaveData.HEROES), the Warrior and the Maga. The picked one
## says "Escolhido"; the Maga, until Morvath was sealed once (SaveData.hero_open), stands behind a padlock (SealedMark)
## with the sentence of what frees her, and cannot be picked. A pick is written in the save at once (picked) and holds for
## the next descent. Keys, gamepad and mouse walk the cards; Esc and B close it. Scales by anchors and containers.
##   host.open(HeroPickScreen.new(), [Save.data]); screen.picked.connect(func(id: String) -> void: ...)

signal closed
signal picked(id: String)

const WIDTH := 640.0
const CARD := Vector2(280.0, 250.0)
const LOCK_MARK := 44.0

var _data: Dictionary
var cards: Dictionary = {}
var back_button: Button
var _states: Dictionary = {}


func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	name = "hero_pick_screen"
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = HubPanel.SHADE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.offset_bottom = -ActionBar.RESERVE
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	var leaf := BookSpread.new().setup(0.5, true)
	centre.add_child(leaf)
	var page := VBoxContainer.new()
	page.name = "page"
	page.custom_minimum_size.x = WIDTH
	page.add_theme_constant_override(&"separation", 10)
	leaf.left.add_child(page)
	page.add_child(Book.heading(T.t(&"heroes_title"), 30, 300))
	var line := Book.text(T.t(&"heroes_line"), Book.FADED, 17)
	line.name = "line"
	page.add_child(line)
	var row := HBoxContainer.new()
	row.name = "row"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 20)
	page.add_child(row)
	for id in SaveData.HEROES:
		row.add_child(_card(id))
	var foot := UiKit.foot()
	page.add_child(foot)
	back_button = Book.button(T.t(&"back"), func() -> void: closed.emit(), 170.0)
	back_button.name = "back"
	foot.add_child(back_button)
	_chain()
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
	_refresh()
	(cards[SaveData.picked_hero(_data)] as Button).grab_focus.call_deferred()


func _card(id: String) -> Button:
	var b := Book.button("", pick.bind(id), CARD.x)
	b.name = id
	b.custom_minimum_size = CARD
	var pad := MarginContainer.new()
	pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 28 if side == "left" else 14)
	pad.add_theme_constant_override(&"margin_top", 14)
	pad.add_theme_constant_override(&"margin_bottom", 14)
	b.add_child(pad)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override(&"separation", 6)
	pad.add_child(v)
	var title := Book.label(T.t(StringName("heroes_name_" + id)), Book.RUBRIC, 24, UiKit.TITLE_FONT)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(title)
	var desc := Book.text(T.t(StringName("heroes_desc_" + id)), Book.INK, 16)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(desc)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(fill)
	if not SaveData.hero_open(_data, id):
		var lock := HBoxContainer.new()
		lock.name = "lock"
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock.add_theme_constant_override(&"separation", 10)
		lock.add_child(SealedMark.new().setup(LOCK_MARK))
		var why := Book.text(T.t(&"heroes_maga_lock"), Book.RUBRIC, 15)
		why.name = "why"
		why.mouse_filter = Control.MOUSE_FILTER_IGNORE
		why.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lock.add_child(why)
		v.add_child(lock)
	var state := Book.label("", Book.FADED, 15, UiKit.BOLD_FONT)
	state.name = "state"
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(state)
	cards[id] = b
	_states[id] = state
	return b


func _refresh() -> void:
	var now := SaveData.picked_hero(_data)
	for id: String in cards:
		var state: Label = _states[id]
		var open := SaveData.hero_open(_data, id)
		state.text = T.t(&"heroes_picked") if id == now else (T.t(&"heroes_pick") if open else T.t(&"heroes_locked"))
		state.add_theme_color_override(&"font_color", Book.OK if id == now else (Book.FADED if open else Book.RUBRIC))
		(cards[id] as Button).modulate.a = 1.0 if open else 0.8


## Picks a hero for the next descent (written in the save; false for a locked one, nothing changes).
func pick(id: String) -> bool:
	if not SaveData.HEROES.has(id) or not SaveData.hero_open(_data, id):
		return false
	_data.hero = id
	Audio.play(&"ui_ok")
	if is_same(_data, Save.data):
		Save.write()
	picked.emit(id)
	_refresh()
	return true


## Left and right walk the cards, down goes to Voltar, up back to the picked card.
func _chain() -> void:
	var ids := SaveData.HEROES
	for i in ids.size():
		var b: Button = cards[ids[i]]
		b.focus_neighbor_left = b.get_path_to(cards[ids[maxi(i - 1, 0)]])
		b.focus_neighbor_right = b.get_path_to(cards[ids[mini(i + 1, ids.size() - 1)]])
		b.focus_neighbor_top = b.get_path_to(b)
		b.focus_neighbor_bottom = b.get_path_to(back_button)
	back_button.focus_neighbor_top = back_button.get_path_to(cards[SaveData.picked_hero(_data)])
	back_button.focus_neighbor_left = back_button.get_path_to(back_button)
	back_button.focus_neighbor_right = back_button.get_path_to(back_button)
	back_button.focus_neighbor_bottom = back_button.get_path_to(back_button)
