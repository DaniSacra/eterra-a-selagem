class_name ActionBar
extends HBoxContainer
## The row of actions at the foot of every screen that stops the game (benchmark_hades2_ui.md P0-2, UI-HB6): always
## in the same place, a few pixels over the bottom edge, the extras on the left ("Ver Bênçãos", "Mapa"), the main
## action and the way back on the right, each one the real key or button on the HUD's key plate
## (ActionSlot.key_plate, round for a gamepad's face button) and its verb in small capitals of old gold. The keys follow
## the device live (Controls.device_changed) and a remapping (refresh). A click on an entry does what its key does
## (its callable), so the mouse reads and uses the same row. Replaces the hints written as sentences ("Esc: voltar").
##   var bar := ActionBar.attach(self, [
##       ActionBar.entry(&"ui_accept", T.t(&"bar_choose")),
##       ActionBar.entry(&"ui_cancel", T.t(&"back"), close)])
##   bar.add(ActionBar.entry(&"menu_reroll", T.t(&"bar_reroll"), reroll, true))   # an extra, on the left

## Height of the row and its gap over the bottom edge and from the sides (px at 720 lines).
const HEIGHT := 30.0
const BOTTOM := 12.0
const SIDE := 28.0
## What a full screen keeps free at its foot for the bar (a book's margin, ActionBar.RESERVE).
const RESERVE := HEIGHT + BOTTOM + 4.0
## The verb's size and colour, the key plate's size, and the room between two entries.
const VERB_SIZE := 15
const VERB_COLOR := Color(0.86, 0.74, 0.5)
const VERB_HOVER := Color(1.0, 0.9, 0.66)
const KEY_SIZE := 15
const KEY_H := 24.0
const GAP := 26

## The arrows that step a value (a Juramento's rank, a volume): not one action but left and right, shown as one plate.
const STEP := &"step"
const STEP_KEYS := "← →"

var left: HBoxContainer
var right: HBoxContainer
## The middle of the row (between the extras and the main action): empty, or what set_center put there.
var center: HBoxContainer
var items: Array[Item] = []


## One entry: the input action whose key is shown, the verb, what a click does (empty: only the key works) and
## whether it is an extra (on the left).
static func entry(action: StringName, verb: String, on_click: Callable = Callable(), extra := false) -> Dictionary:
	return {"action": action, "verb": verb, "click": on_click, "extra": extra}


## A bar at the bottom of a full screen control, with these entries in order.
static func attach(parent: Control, entries: Array = []) -> ActionBar:
	var bar := ActionBar.new()
	bar.name = "action_bar"
	parent.add_child(bar)
	bar.anchor_left = 0.0
	bar.anchor_right = 1.0
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_left = SIDE
	bar.offset_right = -SIDE
	bar.offset_top = -BOTTOM - HEIGHT
	bar.offset_bottom = -BOTTOM
	for e: Dictionary in entries:
		bar.add(e)
	return bar


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	left = HBoxContainer.new()
	left.name = "left"
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_theme_constant_override(&"separation", GAP)
	add_child(left)
	center = HBoxContainer.new()
	center.name = "center"
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(center)
	right = HBoxContainer.new()
	right.name = "right"
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.add_theme_constant_override(&"separation", GAP)
	add_child(right)


func _ready() -> void:
	Controls.device_changed.connect(func(_pad: bool) -> void: refresh())


## A passive piece in the middle of the row (the Livro's coins).
func set_center(node: Control) -> void:
	for c in center.get_children():
		c.queue_free()
	center.add_child(node)


func add(e: Dictionary) -> Item:
	var it := Item.new().setup(e.action, e.verb, e.click)
	(left if bool(e.extra) else right).add_child(it)
	items.append(it)
	return it


## The entry of an action (null: none).
func item(action: StringName) -> Item:
	for it in items:
		if it.action == action:
			return it
	return null


## Presses the button in focus inside a screen (the main entry's click: "Escolher", "Confirmar").
static func press_focus(screen: Control) -> void:
	var f := screen.get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and screen.is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


## The text on the plate of an action (its real key, the arrows for STEP).
static func key_for(action: StringName) -> String:
	return STEP_KEYS if action == STEP else UiKit.action_label(action)


## Reads every key again (the device in use, a remapping).
func refresh() -> void:
	for it in items:
		it.refresh()


## One entry: the key plate and the verb; a click calls its callable.
class Item:
	extends HBoxContainer

	var action: StringName
	var key: StationSign.KeyCap
	var verb: Label
	var click := Callable()

	func setup(p_action: StringName, p_verb: String, p_click: Callable) -> Item:
		action = p_action
		click = p_click
		name = String(p_action)
		add_theme_constant_override(&"separation", 7)
		mouse_filter = Control.MOUSE_FILTER_STOP if click.is_valid() else Control.MOUSE_FILTER_IGNORE
		if click.is_valid():
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		key = StationSign.KeyCap.new()
		key.name = "key"
		key.font_size = ActionBar.KEY_SIZE
		key.height = ActionBar.KEY_H
		add_child(key)
		verb = UiKit.shadow(UiKit.label(p_verb.to_upper(), ActionBar.VERB_COLOR, ActionBar.VERB_SIZE, UiKit.BOLD_FONT))
		verb.name = "verb"
		verb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(verb)
		refresh()
		mouse_entered.connect(_hover.bind(true))
		mouse_exited.connect(_hover.bind(false))
		return self

	func refresh() -> void:
		key.set_key(ActionBar.key_for(action), Controls.using_pad and action != ActionBar.STEP)

	func set_verb(text: String) -> void:
		verb.text = text.to_upper()

	## The text on the key plate now.
	func key_text() -> String:
		return key.text

	func _hover(on: bool) -> void:
		verb.add_theme_color_override(&"font_color", ActionBar.VERB_HOVER if on else ActionBar.VERB_COLOR)
		key.line = UiKit.GOLD if on else UiKit.OLD_GOLD
		key.queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if click.is_valid() and mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			click.call()
