class_name BoonsScreen
extends Control
## "Dons" (from the pause): every gift the paladin holds, with its level and what it does now. An Elo shows its two
## gifts on the chain, so it reads as forged from them. Two columns that scroll when the list is long; each entry takes
## focus, so keys and gamepad scroll it too.

signal closed

const WIDTH := 1040.0
const ICON := 46.0
const ENTRY_W := 500.0
const DESC_SIZE := 17

var state: BoonState


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.column(self, WIDTH, 0.8)
	v.add_child(UiKit.title(T.t(&"boons_title"), 40))
	var owned: Array[Boon] = state.owned() if state else ([] as Array[Boon])
	var first: Control
	if owned.is_empty():
		var none := UiKit.label(T.t(&"boons_none"), UiKit.DIM, 22)
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(none)
	else:
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.follow_focus = true
		scroll.custom_minimum_size.y = 470
		v.add_child(scroll)
		var grid := GridContainer.new()
		grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override(&"h_separation", 16)
		grid.add_theme_constant_override(&"v_separation", 10)
		scroll.add_child(grid)
		# the Elos last, after the gifts they are forged from
		owned.sort_custom(func(a: Boon, b: Boon) -> bool: return not a.is_duo() and b.is_duo())
		for b in owned:
			var e := _entry(b)
			grid.add_child(e)
			if first == null:
				first = e
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	var c := CenterContainer.new()
	c.add_child(back)
	v.add_child(c)
	(first if first else back).grab_focus.call_deferred()


func _entry(b: Boon) -> PanelContainer:
	var lv := state.level(b.id)
	var rarity := state.rarity(b.id)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = ENTRY_W
	panel.focus_mode = Control.FOCUS_ALL
	var plain := UiKit.box(Color(0.07, 0.05, 0.09, 0.9), UiKit.EDGE.darkened(0.35), 1, 10)
	var lit := UiKit.box(Color(0.12, 0.08, 0.1, 0.95), UiKit.GOLD, 2, 10)
	panel.add_theme_stylebox_override(&"panel", plain)
	panel.focus_entered.connect(func() -> void: panel.add_theme_stylebox_override(&"panel", lit))
	panel.focus_exited.connect(func() -> void: panel.add_theme_stylebox_override(&"panel", plain))
	panel.mouse_entered.connect(func() -> void: panel.grab_focus())
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
		var link := EloLink.new().setup(b, from, ICON, 30.0, 14.0)
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
