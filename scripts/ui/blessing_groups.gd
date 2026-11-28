class_name BlessingGroups
extends PanelContainer
## PT28-6 (like SWORN): the Blessings of the run grouped by angel, shown only while `show_blessings` (Tab, Back on the pad) is
## held, beside the SlotColumn (option A: it lists the ones that have no place in the column). Each medallion is a flat button:
## hovering or focusing it emits `inspected`, a click or the pad's accept emits `picked` (BlessingTab shows and pins the cards). One block per angel (its Family: the Elos and the rest get their own), in the angel's colour: its name, a row of
## medallions and, under them, the names of those Blessings. Pure display: Hud calls show_boons() when the build changes and
## shows or hides the panel by the action. The pause keeps the BuildColumn's list.
##   var panel := BlessingGroups.new().setup()
##   panel.show_boons(SlotColumn.others(game.boons), game.boons)

const ICON := 30.0
const PER_ROW := 6
const NAME_FONT := 13
const HEAD_FONT := 15
const WIDTH := 260.0
const BACK := Color(0.035, 0.027, 0.04, 0.9)

signal inspected(boon: Boon)
signal picked(boon: Boon)

var _box: VBoxContainer
var _buttons: Array[Button] = []
var _interactive := false
## Family -> the Blessings of that angel, in the order of the build (tests read it).
var groups: Dictionary = {}


## The Blessings by Family, families in enum order (angels first, Elos by their own family), empty ones left out.
static func group(boons: Array[Boon]) -> Dictionary:
	var out := {}
	for f in Boon.Family.values():
		var list: Array[Boon] = []
		for b in boons:
			if b.family == f:
				list.append(b)
		if not list.is_empty():
			out[f] = list
	return out


func setup() -> BlessingGroups:
	name = "BlessingGroups"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = BACK
	sb.set_content_margin_all(10.0)
	sb.set_corner_radius_all(4)
	sb.border_color = Color(UiKit.OLD_GOLD, 0.5)
	sb.set_border_width_all(1)
	add_theme_stylebox_override(&"panel", sb)
	custom_minimum_size.x = WIDTH
	_box = VBoxContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_constant_override(&"separation", 8)
	add_child(_box)
	return self


## state: for the level badge and the rarity border (null: none).
func show_boons(boons: Array[Boon], state: BoonState = null) -> void:
	groups = group(boons)
	_buttons.clear()
	for c in _box.get_children():
		_box.remove_child(c)
		c.queue_free()
	for f: int in groups:
		var list: Array[Boon] = groups[f]
		var col: Color = Boon.FAMILY_COLOR[f]
		var block := VBoxContainer.new()
		block.name = "angel_%d" % f
		block.mouse_filter = Control.MOUSE_FILTER_IGNORE
		block.add_theme_constant_override(&"separation", 3)
		block.add_child(UiKit.shadow(UiKit.label(T.t(Boon.FAMILY_KEY[f]), col, HEAD_FONT, UiKit.BOLD_FONT)))
		var grid := GridContainer.new()
		grid.columns = PER_ROW
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		grid.add_theme_constant_override(&"h_separation", 6)
		grid.add_theme_constant_override(&"v_separation", 4)
		var names: PackedStringArray = []
		for b in list:
			grid.add_child(_tile(b, state))
			names.append(T.t("boon_" + String(b.id)))
		block.add_child(grid)
		var l := UiKit.shadow(UiKit.label(", ".join(names), UiKit.PALE, NAME_FONT))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = WIDTH - 20.0
		block.add_child(l)
		_box.add_child(block)


## One medallion with its level badge and the flat button over it.
func _tile(b: Boon, state: BoonState) -> Control:
	var tile := Control.new()
	tile.custom_minimum_size = Vector2(ICON, ICON)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(BoonIcon.new().setup(b, ICON))
	if state != null:
		var text := SlotColumn.level_badge(state.level(b.id), b.max_level)
		if text != "":
			var l := SlotColumn.badge(text, state.level(b.id) >= b.max_level)
			l.position = Vector2(ICON * 0.5 - 4.0, ICON - 11.0)
			tile.add_child(l)
	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var none := StyleBoxEmpty.new()
	for st in [&"normal", &"hover", &"pressed", &"disabled"]:
		btn.add_theme_stylebox_override(st, none)
	var ring := UiKit.box(Color(0, 0, 0, 0), UiKit.GOLD, 2, 0, int(ICON * 0.5))
	btn.add_theme_stylebox_override(&"focus", ring)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP if _interactive else Control.MOUSE_FILTER_IGNORE
	btn.focus_mode = Control.FOCUS_ALL if _interactive else Control.FOCUS_NONE
	btn.mouse_entered.connect(func() -> void: inspected.emit(b))
	btn.focus_entered.connect(func() -> void: inspected.emit(b))
	btn.pressed.connect(func() -> void: picked.emit(b))
	tile.add_child(btn)
	_buttons.append(btn)
	return tile


## While Tab is held the medallions take the mouse and the pad's focus.
func set_interactive(on: bool) -> void:
	_interactive = on
	for btn in _buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
		btn.focus_mode = Control.FOCUS_ALL if on else Control.FOCUS_NONE
	if not on and is_inside_tree():
		var f := get_viewport().gui_get_focus_owner()
		if f != null and is_ancestor_of(f):
			f.release_focus()


## The first medallion, for the pad's focus when the panel opens (null: none).
func first_button() -> Button:
	return _buttons[0] if not _buttons.is_empty() else null


func has_content() -> bool:
	return not groups.is_empty()
