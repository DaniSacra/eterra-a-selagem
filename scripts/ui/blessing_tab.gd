class_name BlessingTab
extends HBoxContainer
## PT28-6 option A: what opens beside the SlotColumn while `show_blessings` (Tab, Back on the pad) is held: the Blessings that
## have no place in the column grouped by angel (BlessingGroups) and, to their right, the description cards: the one under the
## mouse or the pad's focus, and up to MAX_PINS the player pinned with a click (or the pad's accept; Hades II's pins). Pins are
## forgotten when Tab is let go. Hud wires the SlotColumn's and the groups' `inspected` / `picked` to inspect() / pin().
##   var tab := BlessingTab.new().setup()
##   tab.show_build(game.boons)

const MAX_PINS := 3
const CARD_W := 270.0
const DESC_FONT := 15
const BACK := Color(0.035, 0.027, 0.04, 0.94)

var groups: BlessingGroups
var state: BoonState
var pins: Array[StringName] = []
var hovered: StringName = &""
var _cards: VBoxContainer


## The pins after a click on `id`: unpinned if it was pinned, pinned if there is room, else unchanged.
static func toggle_pin(current: Array[StringName], id: StringName, cap: int = MAX_PINS) -> Array[StringName]:
	var out := current.duplicate()
	if out.has(id):
		out.erase(id)
	elif out.size() < cap:
		out.append(id)
	return out


func setup() -> BlessingTab:
	name = "BlessingTab"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	add_theme_constant_override(&"separation", 10)
	groups = BlessingGroups.new().setup()
	groups.visible = true
	groups.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	groups.inspected.connect(inspect)
	groups.picked.connect(pin)
	add_child(groups)
	_cards = VBoxContainer.new()
	_cards.name = "cards"
	_cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_cards.add_theme_constant_override(&"separation", 6)
	add_child(_cards)
	return self


func show_build(boons: BoonState) -> void:
	state = boons
	groups.show_boons(SlotColumn.others(boons), boons)
	_refresh()


func inspect(b: Boon) -> void:
	hovered = b.id
	_refresh()


func pin(b: Boon) -> void:
	pins = toggle_pin(pins, b.id)
	_refresh()


## Opened (true) or closed (false) by the held action; closing forgets the pins and the hover.
func set_open(on: bool) -> void:
	if on == visible:
		return
	visible = on
	groups.set_interactive(on)
	if not on:
		pins.clear()
		hovered = &""
		_refresh()
	elif groups.first_button() != null and Controls.using_pad:
		groups.first_button().grab_focus()


## The ids whose cards show now: the pinned, then the hovered one if it is not among them.
func card_ids() -> Array[StringName]:
	var out := pins.duplicate()
	if hovered != &"" and not out.has(hovered):
		out.append(hovered)
	return out


func _refresh() -> void:
	for c in _cards.get_children():
		_cards.remove_child(c)
		c.queue_free()
	if state == null or not visible:
		return
	for id in card_ids():
		var b := state.find(id)
		if b != null:
			_cards.add_child(card(b, state, pins.has(id)))


## The description card of an owned Blessing: its name, rarity and level, where it belongs, and what it does.
static func card(b: Boon, state_: BoonState, pinned: bool) -> PanelContainer:
	var lv := state_.level(b.id)
	var rarity := state_.rarity(b.id)
	var edge := b.color()
	var panel := PanelContainer.new()
	panel.name = "card_%s" % b.id
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := UiKit.box(BACK, Color(edge, 0.9 if pinned else 0.55), 2 if pinned else 1, 10, 4)
	panel.add_theme_stylebox_override(&"panel", sb)
	panel.custom_minimum_size.x = CARD_W
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override(&"separation", 2)
	panel.add_child(col)
	col.add_child(UiKit.shadow(UiKit.label(T.t("boon_" + String(b.id)), Color(1.0, 0.95, 0.85), 18, UiKit.TITLE_FONT)))
	var tag := T.t(Boon.FAMILY_KEY[b.family])
	if b.slot != Boon.Slot.NONE:
		tag = T.t(Boon.SLOT_KEY[b.slot]) + "  ·  " + tag
	if b.has_rarity():
		tag += "  ·  " + T.t(Boon.RARITY_KEY[rarity]) + "  ·  " + T.t(&"choice_level", {"n": lv, "max": b.max_level})
	col.add_child(UiKit.label(tag, edge.lightened(0.25), 13, UiKit.BOLD_FONT))
	var desc := UiKit.label(BoonChoice.describe(b, lv, Boon.RARITY_MULT[rarity]), UiKit.PALE, DESC_FONT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = CARD_W - 20.0
	col.add_child(desc)
	return panel
