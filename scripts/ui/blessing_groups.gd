class_name BlessingGroups
extends PanelContainer
## PT28-6 (like SWORN): the Blessings of the run grouped by angel, shown only while `show_blessings` (Tab, Back on the pad) is
## held. One block per angel (its Family: the Elos and the rest get their own), in the angel's colour: its name, a row of
## medallions and, under them, the names of those Blessings. Pure display: Hud calls show_boons() when the build changes and
## shows or hides the panel by the action. The pause keeps the BuildColumn's list.
##   var panel := BlessingGroups.new().setup()
##   panel.show_boons(game.boons.owned())

const ICON := 30.0
const PER_ROW := 6
const NAME_FONT := 13
const HEAD_FONT := 15
const WIDTH := 260.0
const BACK := Color(0.035, 0.027, 0.04, 0.9)

var _box: VBoxContainer
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


func show_boons(boons: Array[Boon]) -> void:
	groups = group(boons)
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
			grid.add_child(BoonIcon.new().setup(b, ICON))
			names.append(T.t("boon_" + String(b.id)))
		block.add_child(grid)
		var l := UiKit.shadow(UiKit.label(", ".join(names), UiKit.PALE, NAME_FONT))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = WIDTH - 20.0
		block.add_child(l)
		_box.add_child(block)


func has_content() -> bool:
	return not groups.is_empty()
