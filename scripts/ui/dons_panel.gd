class_name DonsPanel
extends PanelContainer
## The detail panel of the Gifts screen (docs/art/dons_medallion_spec.md 6): the focused node's disc, name, place, effect,
## cost line and the action button (the key or button of the controller, the verb, and the bar that fills while a
## sealed Gift is held). On the crown it shows the hero (level, Mastery bar, what the next level reveals, the hero's
## phrase). Presentation only: DonsScreen computes what to say (tell_node and tell_hero) and listens to the button
## (pressed, released: the mouse holds it as it holds a node).

signal pressed
signal released

const SIZE_PX := Vector2(302, 317)
const MARGIN := 16
const DISC := 56.0
const BODY := 15
const BUTTON := Vector2(270, 46)
const MARK := 18.0
const PHRASE_SKEW := 0.2
## Red of the reasons that close a Gift (the Forja's missing-material red).
const RUBRIC := Color("d9644f")

var _disc: Disc
var _name: Label
var _sub: Label
var _mark_holder: Control
var _desc: Label
var _needs: Label
var _rule: ColorRect
var _cost: HBoxContainer
var _cost_icon: CostIcon
var _cost_name: Label
var _cost_right: Label
var _verb: Verb
var _bar: MasteryBar
var _phrase: Label
var _spacer: Control


func _init() -> void:
	name = "dons_panel"
	custom_minimum_size = SIZE_PX
	size = SIZE_PX
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := UiKit.box(Color(0.045, 0.032, 0.04, 0.95), UiKit.OLD_GOLD, 2, MARGIN, 6)
	add_theme_stylebox_override(&"panel", box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 7)
	add_child(col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 10)
	col.add_child(head)
	_disc = Disc.new()
	head.add_child(_disc)
	var names := VBoxContainer.new()
	names.add_theme_constant_override(&"separation", 1)
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(names)
	_name = UiKit.label("", UiKit.STRONG, 20, UiKit.TITLE_FONT)
	_name.name = "name"
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name.add_theme_constant_override(&"outline_size", 0)
	names.add_child(_name)
	_sub = UiKit.label("", UiKit.DIM, 14, _italic())
	_sub.name = "place"
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.add_theme_constant_override(&"outline_size", 0)
	names.add_child(_sub)
	_mark_holder = Control.new()
	_mark_holder.custom_minimum_size = Vector2(MARK, MARK)
	_mark_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(_mark_holder)
	_desc = UiKit.label("", UiKit.PALE, BODY)
	_desc.name = "desc"
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.max_lines_visible = 5
	_desc.add_theme_constant_override(&"outline_size", 0)
	col.add_child(_desc)
	# UX-01: "Pede X equipado." in gold bold under the effect line, only for a Gift that needs another
	_needs = UiKit.label("", UiKit.GOLD, BODY, UiKit.BOLD_FONT)
	_needs.name = "needs"
	_needs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_needs.add_theme_constant_override(&"outline_size", 0)
	_needs.visible = false
	col.add_child(_needs)
	_bar = MasteryBar.new()
	_bar.name = "mastery"
	col.add_child(_bar)
	_phrase = UiKit.label("", UiKit.DIM, BODY, _italic())
	_phrase.name = "phrase"
	_phrase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phrase.add_theme_constant_override(&"outline_size", 0)
	col.add_child(_phrase)
	_spacer = Control.new()
	_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_spacer)
	_rule = ColorRect.new()
	_rule.custom_minimum_size.y = 1.0
	_rule.color = Color(UiKit.OLD_GOLD, 0.6)
	col.add_child(_rule)
	_cost = HBoxContainer.new()
	_cost.name = "cost"
	col.add_child(_cost)
	_cost_icon = CostIcon.new()
	_cost.add_child(_cost_icon)
	_cost_name = UiKit.label("", UiKit.GOLD, 16, UiKit.BOLD_FONT)
	_cost_name.add_theme_constant_override(&"outline_size", 0)
	_cost.add_child(_cost_name)
	_cost_right = UiKit.label("", UiKit.DIM, 15)
	_cost_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cost_right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_cost_right.add_theme_constant_override(&"outline_size", 0)
	_cost.add_child(_cost_right)
	_verb = Verb.new()
	_verb.pressed.connect(func() -> void: pressed.emit())
	_verb.released.connect(func() -> void: released.emit())
	col.add_child(_verb)


static func _italic() -> Font:
	var f := FontVariation.new()
	f.base_font = UiKit.TEXT_FONT
	f.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(PHRASE_SKEW, 1.0), Vector2.ZERO)
	return f


## A node of the ring or an ultimate. info: name, sub, desc, paint (Callable(ci, centre, radius)), tint,
## cost_kind ("" | "devotion" | "memory"), cost_n, cost_right, verb, enabled, reason, key, hold, slot (Boon.Slot or -1).
func tell_node(info: Dictionary) -> void:
	_set_hero_mode(false)
	_disc.paint = info.paint
	_disc.tint = info.get("tint", UiKit.GOLD)
	_disc.queue_redraw()
	_name.text = info.name
	_sub.text = info.sub
	_desc.text = info.desc
	_needs.text = info.get("needs", "")
	_needs.visible = _needs.text != ""
	_set_mark(int(info.get("slot", -1)))
	var kind: String = info.get("cost_kind", "")
	_cost.visible = kind != ""
	_cost_icon.memory = kind == "memory"
	_cost_icon.queue_redraw()
	_cost_name.text = T.t(&"dons_cost_memory" if kind == "memory" else &"dons_cost_devotion") + "  " + str(info.get("cost_n", ""))
	_cost_right.text = info.get("cost_right", "")
	_verb.visible = true
	_verb.set_up(info.verb, info.enabled, info.key, info.get("hold", false), info.get("reason", ""))


## The crown: the hero's page. info: name, sub (the level), paint, curve, xp, reveals, phrase.
func tell_hero(info: Dictionary) -> void:
	_set_hero_mode(true)
	_disc.paint = info.paint
	_disc.tint = UiKit.GOLD
	_disc.queue_redraw()
	_name.text = info.name
	_sub.text = info.sub
	_desc.text = info.reveals
	_desc.visible = info.reveals != ""
	_bar.setup(info.curve, info.xp, BUTTON.x)
	_bar.queue_redraw()
	_phrase.text = info.phrase
	_set_mark(-1)


func set_progress(p: float) -> void:
	_verb.progress = p
	_verb.queue_redraw()


func _set_hero_mode(on: bool) -> void:
	_bar.visible = on
	_phrase.visible = on
	_desc.visible = not on
	_needs.visible = false
	_cost.visible = not on
	_rule.visible = not on
	_verb.visible = not on


func _set_mark(slot: int) -> void:
	for c in _mark_holder.get_children():
		c.queue_free()
	_mark_holder.visible = slot >= 0
	if slot >= 0:
		var m := ActionSlot.mark(slot as Boon.Slot, MARK)
		m.position = Vector2.ZERO
		_mark_holder.add_child(m)


func verb_text() -> String:
	return _verb.text


func verb_enabled() -> bool:
	return _verb.enabled


## The big round icon beside the name: the node's own drawing on enamel under a gold rim.
class Disc:
	extends Control

	var paint := Callable()
	var tint := UiKit.GOLD

	func _init() -> void:
		custom_minimum_size = Vector2(DonsPanel.DISC, DonsPanel.DISC)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_CENTER

	func _draw() -> void:
		var c := size * 0.5
		var r := DonsPanel.DISC * 0.5
		draw_circle(c, r, UiKit.GOLD)
		draw_circle(c, r - 2.5, UiKit.INK.lerp(tint, 0.45))
		if paint.is_valid():
			paint.call(self, c, r * 0.55)


## The cost line's little icon: the Devoção's disc or the Memória's crystal (24 px).
class CostIcon:
	extends Control

	var memory := false

	func _init() -> void:
		custom_minimum_size = Vector2(24, 24)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_vertical = Control.SIZE_SHRINK_CENTER

	func _draw() -> void:
		if memory:
			DonsArt.memory_mark(self, size * 0.5, size.y)
		else:
			DonsArt.socket(self, size * 0.5, 10.0)


## The button: key plate, verb, and the bar that fills while held.
class Verb:
	extends Control

	signal pressed
	signal released

	var text := ""
	var enabled := true
	var key := ""
	var hold := false
	var progress := 0.0
	var reason := ""

	func _init() -> void:
		name = "verb"
		custom_minimum_size = DonsPanel.BUTTON
		mouse_filter = Control.MOUSE_FILTER_STOP
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	func set_up(p_text: String, p_enabled: bool, p_key: String, p_hold: bool, p_reason: String) -> void:
		text = p_text
		enabled = p_enabled
		key = p_key
		hold = p_hold
		reason = p_reason
		progress = 0.0
		queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				pressed.emit()
			else:
				released.emit()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		if not enabled and reason != "":
			# cannot be paid: plain words in rubrica, no frame, no key, no hold bar (UI 7)
			var rf := UiKit.BOLD_FONT
			draw_string(rf, Vector2(0.0, size.y * 0.5 + (rf.get_ascent(17) - rf.get_descent(17)) * 0.5 - 2.0), reason, HORIZONTAL_ALIGNMENT_CENTER, size.x, 17, DonsPanel.RUBRIC)
			return
		var edge := UiKit.GOLD if enabled else UiKit.OLD_GOLD.darkened(0.3)
		draw_style_box(UiKit.box(Color(0.1, 0.07, 0.05, 0.96) if enabled else Color(0.07, 0.06, 0.06, 0.9), edge, 2, 0, 8), rect)
		var f := UiKit.BOLD_FONT
		var label := text if enabled or reason == "" else reason
		var col := UiKit.STRONG if enabled else UiKit.DIM
		var fs := 17
		var key_w := ActionSlot.key_plate(self, Vector2(26.0, size.y * 0.5 - 2.0), key, 14, 24.0, Controls.using_pad) if enabled and key != "" else 0.0
		var x := 26.0 + key_w * 0.5 + 12.0 if key_w > 0.0 else 14.0
		var w := size.x - x - 10.0
		var base := Vector2(x, size.y * 0.5 + (f.get_ascent(fs) - f.get_descent(fs)) * 0.5 - 2.0)
		draw_string(f, base, label.to_upper() if enabled else label, HORIZONTAL_ALIGNMENT_LEFT, w, fs, col)
		if hold and enabled:
			var bar := Rect2(Vector2(10.0, size.y - 11.0), Vector2(size.x - 20.0, 6.0))
			draw_rect(bar, Color(0.02, 0.015, 0.02, 0.9))
			draw_rect(Rect2(bar.position, Vector2(bar.size.x * progress, bar.size.y)), UiKit.GOLD)
			draw_rect(bar, Color(UiKit.OLD_GOLD, 0.7), false, 1.0)
