class_name HeroScreen
extends Control
## "O Guerreiro" on the title (E2-06; docs/design/warrior_spec.md 4 and 7, pieces 1 to 3): the hero's medallion and
## name, his Mastery (MasteryBar, and what the next level brings), the Devotion in use, the Gift tree (TalentTree) and
## the choice of ultimate. The panel on the right tells the focused Gift or ultimate: where it sits, its cost, the action
## it takes, what it does and whether it can go on now (or why not, in the words of Talents' rules: HeroLoadout.why).
## Enter, A or a click puts a Gift on or takes it off (taking one off takes what needed it too) and chooses an
## ultimate; it is written to the save at once (heroes.<id>.equipped, ultimate). Esc or B goes back (the title closes
## the screen on ui_cancel, like its other panels).

signal closed

const MARGIN := Vector2(44, 26)
const PANEL_WIDTH := 430.0
const CREST := 64.0
const NAME_SIZE := 26
const DESC_SIZE := 19
const META_SIZE := 17
const WARN := Color(1.0, 0.62, 0.5)
const OK := Color(0.62, 0.86, 0.7)

var loadout: HeroLoadout
var tree: TalentTree
var ults: Array[UltCard] = []
var _data: Dictionary
var _bar: MasteryBar
var _next: Label
var _devotion: DevotionPips
var _devotion_count: Label
var _name: Label
var _place: Label
var _meta: Label
var _desc: Label
var _status: Label
var _hint: Label
## What the panel tells now (a TalentDef, an UltDef or null for the centre).
var _shown: Variant = null


## data: the save data to read and edit (Save.data in the game; tests give their own).
func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	loadout = HeroLoadout.new(HeroDef.warrior(), _data)
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, 0.9)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right"]:
		frame.add_theme_constant_override("margin_" + side, int(MARGIN.x))
	for side: String in ["top", "bottom"]:
		frame.add_theme_constant_override("margin_" + side, int(MARGIN.y))
	add_child(frame)
	var page := VBoxContainer.new()
	page.add_theme_constant_override(&"separation", 10)
	frame.add_child(page)
	page.add_child(_header())
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override(&"separation", 28)
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	page.add_child(body)
	tree = TalentTree.new().setup(loadout)
	tree.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tree.picked.connect(_pick)
	tree.focused.connect(_tell)
	body.add_child(tree)
	body.add_child(_panel())
	page.add_child(_footer())
	_refresh()
	_first_focus().grab_focus.call_deferred()


func _header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 16)
	var crest := HeroCrest.new().setup(CREST)
	crest.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(crest)
	var names := VBoxContainer.new()
	names.add_theme_constant_override(&"separation", 0)
	names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var title := UiKit.shadow(UiKit.label(T.t(HeroDef.warrior().name_key), UiKit.GOLD, 34, UiKit.TITLE_FONT))
	title.add_theme_constant_override(&"outline_size", 6)
	names.add_child(title)
	_next = UiKit.shadow(UiKit.label("", UiKit.DIM.lightened(0.1), 16))
	_next.name = "next"
	names.add_child(_next)
	row.add_child(names)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(gap)
	_bar = MasteryBar.new().setup(loadout.hero.mastery, loadout.xp(), 340.0)
	_bar.name = "mastery"
	_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar)
	var spacer := Control.new()
	spacer.custom_minimum_size.x = 24
	row.add_child(spacer)
	var dev := VBoxContainer.new()
	dev.add_theme_constant_override(&"separation", 2)
	dev.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var top := HBoxContainer.new()
	top.add_child(UiKit.shadow(UiKit.label(T.t(&"hero_devotion"), UiKit.PARCHMENT, 16, UiKit.BOLD_FONT)))
	_devotion_count = UiKit.shadow(UiKit.label("", UiKit.DIM.lightened(0.2), 16, UiKit.number_font()))
	_devotion_count.name = "devotion"
	_devotion_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_devotion_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(_devotion_count)
	dev.add_child(top)
	_devotion = DevotionPips.new()
	dev.add_child(_devotion)
	row.add_child(dev)
	return row


func _panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = PANEL_WIDTH
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 6)
	panel.add_child(v)
	_name = UiKit.label("", UiKit.GOLD, NAME_SIZE, UiKit.TITLE_FONT)
	_name.name = "gift_name"
	v.add_child(_name)
	_place = UiKit.label("", UiKit.DIM.lightened(0.1), META_SIZE)
	v.add_child(_place)
	_meta = UiKit.label("", UiKit.PARCHMENT, META_SIZE, UiKit.BOLD_FONT)
	v.add_child(_meta)
	_desc = UiKit.label("", UiKit.PALE, DESC_SIZE)
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.custom_minimum_size = Vector2(PANEL_WIDTH - 40.0, 78)
	v.add_child(_desc)
	_status = UiKit.label("", UiKit.PALE, META_SIZE + 1, UiKit.BOLD_FONT)
	_status.name = "status"
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(PANEL_WIDTH - 40.0, 48)
	v.add_child(_status)
	var o := EndScreen.Ornament.new()
	o.custom_minimum_size = Vector2(PANEL_WIDTH * 0.7, 14)
	o.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(o)
	var head := UiKit.title(T.t(&"hero_ultimate"), 16, UiKit.OLD_GOLD.lightened(0.3))
	head.add_theme_constant_override(&"outline_size", 4)
	v.add_child(head)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 12)
	v.add_child(row)
	for u in loadout.hero.ultimates:
		var card := UltCard.new().setup(u)
		card.pressed.connect(_choose.bind(u))
		card.focus_entered.connect(_tell.bind(u))
		ults.append(card)
		row.add_child(card)
	return panel


func _footer() -> Control:
	var row := HBoxContainer.new()
	_hint = UiKit.shadow(UiKit.label("", UiKit.DIM, 16))
	_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_hint)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 200)
	back.name = "back"
	row.add_child(back)
	return row


## Focus at the start: the first Gift that can go on, else the first one on, else the centre.
func _first_focus() -> Control:
	for want: HeroLoadout.State in [HeroLoadout.State.OPEN, HeroLoadout.State.EQUIPPED]:
		for n in tree.nodes:
			if n.state == want:
				return n
	return tree.centre


func _pick(t: TalentDef) -> void:
	if loadout.toggle(t.id):
		Audio.play(&"ui_ok")
		_save()
	else:
		tree.node(t.id).refuse()
	_refresh()


func _choose(u: UltDef) -> void:
	if loadout.choose_ult(u.id):
		Audio.play(&"ui_ok")
		_save()
	else:
		for c in ults:
			if c.def == u:
				c.grab_focus()
	_refresh()


func _save() -> void:
	if is_same(_data, Save.data):
		Save.write()


func _refresh() -> void:
	tree.refresh()
	for c in ults:
		c.open = loadout.ult_open(c.def)
		c.chosen = loadout.ultimate() == c.def.id
	_devotion.set_counts(loadout.used(), loadout.devotion())
	_devotion_count.text = T.t(&"hero_devotion_count", {"used": loadout.used(), "max": loadout.devotion()})
	var next := loadout.next_unlocks()
	_next.text = T.t(&"hero_next", {"n": loadout.level() + 1, "what": ", ".join(next)}) if not next.is_empty() else ""
	_hint.text = T.t(&"hero_hint_pad" if Controls.using_pad else &"hero_hint")
	_tell(_shown)


## The panel tells a Gift (TalentDef), an ultimate (UltDef) or the passive (null).
func _tell(what: Variant) -> void:
	_shown = what
	if what is TalentDef:
		_tell_gift(what)
	elif what is UltDef:
		_tell_ult(what)
	else:
		_name.text = T.t(&"hero_passive")
		_place.text = T.t(&"hero_passive_note")
		_meta.text = ""
		_desc.text = T.t(&"hero_passive_desc")
		_set_status("", UiKit.PALE)


func _tell_gift(t: TalentDef) -> void:
	_name.text = T.t(t.name_key)
	_place.text = loadout.place_text(t)
	var meta := T.t(&"hero_cost", {"n": t.cost})
	if t.slot != Boon.Slot.NONE:
		meta += ". " + T.t(&"hero_action", {"action": T.t(HeroLoadout.ACTION_KEY[t.slot])})
	_meta.text = meta
	_desc.text = T.t(t.desc_key)
	match loadout.state(t):
		HeroLoadout.State.EQUIPPED:
			_set_status(T.t(&"hero_equipped"), OK)
		HeroLoadout.State.OPEN:
			_set_status(T.t(&"hero_can_equip"), UiKit.PALE)
		HeroLoadout.State.LOCKED:
			_set_status(T.t(&"hero_why_locked", {"n": t.unlock_level}), UiKit.DIM)
		_:
			var why := loadout.why(t)
			_set_status(T.t(why.key, why.args) if not why.is_empty() else "", WARN)


func _tell_ult(u: UltDef) -> void:
	_name.text = T.t(u.name_key)
	_place.text = T.t(&"hero_ultimate")
	_meta.text = T.t(&"hero_ult_charge", {"n": UiKit.format_number(u.charge)})
	_desc.text = T.t(u.desc_key)
	if not loadout.ult_open(u):
		_set_status(T.t(&"hero_ult_locked", {"n": u.mastery_level}), UiKit.DIM)
	elif loadout.ultimate() == u.id:
		_set_status(T.t(&"hero_ult_chosen"), OK)
	else:
		_set_status(T.t(&"hero_ult_none") if loadout.ultimate() == &"" else "", UiKit.DIM)


func _set_status(text: String, color: Color) -> void:
	_status.text = text
	_status.add_theme_color_override(&"font_color", color)


## The Devotion as a row of small diamonds: the used ones filled in old gold, the free ones hollow.
class DevotionPips:
	extends Control

	const STEP := 13.0
	const HALF := 4.6

	var used := 0
	var total := 0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(STEP * 8, 14)

	func set_counts(p_used: int, p_total: int) -> void:
		used = p_used
		total = p_total
		custom_minimum_size.x = maxf(STEP * total, 60.0)
		queue_redraw()

	func _draw() -> void:
		for i in total:
			var c := Vector2(HALF + 1.0 + i * STEP, size.y * 0.5)
			var d := PackedVector2Array([c + Vector2(0, -HALF), c + Vector2(HALF, 0), c + Vector2(0, HALF), c + Vector2(-HALF, 0)])
			if i < used:
				draw_colored_polygon(d, UiKit.OLD_GOLD.lightened(0.35))
			else:
				d.append(d[0])
				draw_polyline(d, UiKit.OLD_GOLD, 1.4, true)
