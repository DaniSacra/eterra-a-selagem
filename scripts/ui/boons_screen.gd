class_name BoonsScreen
extends Control
## "Suas bênçãos" (from the pause; art pack board 06): every gift the paladin holds, grouped as the rules group them:
## the Blessings on an action (Ataque, Especial, Círculo, Esquiva: Boon.slot), the ones that act alone (Boon.Slot.NONE)
## and the Elos (an Elo shows its two gifts on the chain, so it reads as forged from them). On the left one entry per
## group with its count: choosing it takes the focus to the group's first row. On the right one row per gift (medallion,
## name, rarity and level, action and family, what it does now) in a list that scrolls with the focus, so keys, gamepad
## and mouse wheel reach the last of a full hand; left from a row goes back to its group.

signal closed

enum Group { ACTIONS, AUTO, ELOS }

const GROUP_KEY: Array[StringName] = [&"boons_group_actions", &"boons_group_auto", &"boons_group_elos"]
const WIDTH := 1060.0
const NAV_WIDTH := 220.0
const LIST_HEIGHT := 452.0
const ICON := 42.0
const DESC_SIZE := 17

var state: BoonState
## The group entries on the left, and each group's rows (Group -> Array[Control]).
var nav: Array[Button] = []
var rows: Dictionary = {}
var _scroll: ScrollContainer


## The group a gift belongs to.
static func group_of(b: Boon) -> Group:
	if b.is_duo():
		return Group.ELOS
	return Group.AUTO if b.slot == Boon.Slot.NONE else Group.ACTIONS


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.page(self, T.t(&"boons_title"), WIDTH, 0.82, 34)
	var owned: Array[Boon] = state.owned() if state else ([] as Array[Boon])
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	if owned.is_empty():
		var none := UiKit.label(T.t(&"boons_none"), UiKit.DIM, 22)
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(none)
		var f := UiKit.foot()
		f.add_child(back)
		v.add_child(f)
		back.grab_focus.call_deferred()
		return
	var groups: Array = [[], [], []]
	for b in owned:
		(groups[group_of(b)] as Array).append(b)
	# on an action: in the order of the actions (Ataque, Especial, Círculo, Esquiva)
	(groups[Group.ACTIONS] as Array).sort_custom(func(a: Boon, b: Boon) -> bool: return a.slot < b.slot)
	var body := HBoxContainer.new()
	body.add_theme_constant_override(&"separation", 22)
	v.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = NAV_WIDTH
	left.add_theme_constant_override(&"separation", 8)
	body.add_child(left)
	_scroll = ScrollContainer.new()
	_scroll.name = "list"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_scroll.custom_minimum_size.y = LIST_HEIGHT
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override(&"separation", 6)
	_scroll.add_child(list)
	for g: int in Group.values():
		var members: Array = groups[g]
		if members.is_empty():
			continue
		var head := UiKit.section(T.t(GROUP_KEY[g]))
		head.name = "head_%d" % g
		list.add_child(head)
		var group_rows: Array[Control] = []
		for b: Boon in members:
			var e := _entry(b)
			list.add_child(e)
			group_rows.append(e)
		rows[g] = group_rows
		var entry := UiKit.button("%s  %d" % [T.t(GROUP_KEY[g]), members.size()], Callable(), NAV_WIDTH)
		entry.name = "group_%d" % g
		entry.toggle_mode = true
		entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.add_theme_stylebox_override(&"pressed", UiKit.box(UiKit.TAB_ON, UiKit.OLD_GOLD.lightened(0.2), 2, 10))
		entry.pressed.connect(func() -> void:
			Audio.play(&"ui_ok")
			group_rows[0].grab_focus())
		left.add_child(entry)
		nav.append(entry)
		for r in group_rows:
			r.focus_neighbor_left = r.get_path_to(entry)
			r.focus_entered.connect(_light.bind(entry))
		entry.focus_neighbor_right = entry.get_path_to(group_rows[0])
	var f := UiKit.foot()
	f.add_child(back)
	v.add_child(f)
	# the last row goes down to Voltar, Voltar up to the list
	var all: Array[Control] = []
	for g: int in rows:
		all.append_array(rows[g])
	all[-1].focus_neighbor_bottom = all[-1].get_path_to(back)
	back.focus_neighbor_top = back.get_path_to(all[0])
	nav[-1].focus_neighbor_bottom = nav[-1].get_path_to(back)
	_light(nav[0])
	all[0].grab_focus.call_deferred()


## The group of the row in focus is the one lit on the left.
func _light(entry: Button) -> void:
	for b in nav:
		b.set_pressed_no_signal(b == entry)


func _entry(b: Boon) -> PanelContainer:
	var lv := state.level(b.id)
	var rarity := state.rarity(b.id)
	var panel := UiKit.focus_row(9)
	panel.name = String(b.id)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)
	var from := state.sources(b)
	var icon: BoonIcon
	if from.is_empty():
		icon = BoonIcon.new().setup(b, ICON)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon)
	else:
		var link := EloLink.new().setup(b, from, ICON, 28.0, 14.0)
		link.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(link)
		icon = link.main_icon()
	icon.level = lv
	icon.max_level = b.max_level
	var text := VBoxContainer.new()
	text.add_theme_constant_override(&"separation", 0)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text)
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 0)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(head)
	var name_l := UiKit.label(T.t("boon_" + String(b.id)), Color(1.0, 0.95, 0.85), 20, UiKit.TITLE_FONT)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_l)
	if b.has_rarity():
		# the same word and colour as on the card; an Elo has neither rarity nor level (BUG-017)
		var rar := UiKit.label(T.t(Boon.RARITY_KEY[rarity]) + " · ", BoonCard.rarity_color(rarity).lightened(0.12), 16,
				UiKit.BOLD_FONT)
		rar.name = "Rarity"
		head.add_child(rar)
		head.add_child(UiKit.label(T.t(&"choice_level", {"n": lv, "max": b.max_level}), UiKit.GOLD, 16))
	var tag := EloLink.caption(from) if not from.is_empty() else T.t(Boon.FAMILY_KEY[b.family])
	if b.slot != Boon.Slot.NONE:
		tag = T.t(Boon.SLOT_KEY[b.slot]) + "  ·  " + tag
	text.add_child(UiKit.label(tag, b.color().lightened(0.25) if from.is_empty() else EloLink.METAL_LIT, 16, UiKit.BOLD_FONT))
	var desc := UiKit.label(BoonChoice.describe(b, lv, Boon.RARITY_MULT[rarity]), UiKit.PALE, DESC_SIZE)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 200
	text.add_child(desc)
	return panel
