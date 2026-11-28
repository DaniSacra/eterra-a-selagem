class_name SlotColumn
extends Control
## PT28-6 option A (Daniel, 2026-11-27; the Hades II / SWORN way, docs/design/hud_boons_reference.md): a column on the LEFT edge with
## five fixed places, one for each button's Blessing: Ataque, Poder, Especial, Esquiva, Supremo (the Maga's slots are the same
## enum). An empty place keeps a dim outline with the button's own mark, so what is missing can be read. The medallion wears the
## angel's colour, the rarity is the border, the level only a small badge from level 2 up ("Nv 2", "Máx" at the cap).
## Passive Blessings and Elos are not here: under the column only the ones with a live state (a recharge running) show, small,
## and under them the key that opens the Tab panel. Pure display: Hud calls show_build() when the build changes and tick()
## every frame; set_interactive() while the Tab panel is up (the places then take the mouse and the pad's focus).
##   var col := SlotColumn.new().setup()
##   col.show_build(game.boons, ult_glyph)

signal inspected(boon: Boon)
signal picked(boon: Boon)

const WIDTH := 58.0
const ROW_H := 50.0
const ICON := 36.0
const MARGIN := 14.0
const BADGE_FONT := 12
const SECS_FONT := 14
const CHIP := 28.0
const HINT_FONT := 13
const EMPTY := Color(0.42, 0.42, 0.46)
## The places, top to bottom (the Warrior's ATTACK, CAST, SPECIAL, DASH, ULT).
const SLOTS: Array[Boon.Slot] = [Boon.Slot.ATTACK, Boon.Slot.CAST, Boon.Slot.SPECIAL, Boon.Slot.DASH, Boon.Slot.ULT]
## A recharge shorter than this is not "live" (the frame it ends on).
const LIVE_MIN := 0.05

var cells: Array[Cell] = []
var _live_box: HFlowContainer
var _hint: Label
var _live_key := ""
var _chips := {}
var _interactive := false
var _owned := 0


## The Blessing in each place of SLOTS (null: the place is empty).
static func slot_boons(state: BoonState) -> Array[Boon]:
	var out: Array[Boon] = []
	for s in SLOTS:
		out.append(state.in_slot(s))
	return out


## Everything owned that has no place in the column: passives, the second on a slot, Elos (the Tab panel lists them).
static func others(state: BoonState) -> Array[Boon]:
	var placed := slot_boons(state)
	var out: Array[Boon] = []
	for b in state.owned():
		if not placed.has(b):
			out.append(b)
	return out


## The badge under a medallion: nothing at level 1 (or a Blessing that does not grow), "Máx" at the ceiling, else "Nv n".
static func level_badge(lv: int, max_level: int) -> String:
	if lv < 2:
		return ""
	if max_level > 0 and lv >= max_level:
		return T.t(&"hud_slot_max")
	return T.t(&"hud_slot_level", {"n": lv})


## Whether a recharge (remaining seconds, total) is a live state worth a place under the column.
static func is_live(timer: Vector2) -> bool:
	return timer.x > LIVE_MIN and timer.y > 0.0


## A badge label (the Tab panel's icons use it too).
static func badge(text: String, gold: bool) -> Label:
	var l := UiKit.label(text, UiKit.GOLD if gold else UiKit.PALE, BADGE_FONT, UiKit.BOLD_FONT)
	l.add_theme_constant_override(&"outline_size", 4)
	l.add_theme_color_override(&"font_outline_color", UiKit.INK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## One place: the medallion, its rarity border, the badge, the recharge, and a flat button over it for the Tab panel.
class Cell extends Control:
	var icon: BoonIcon
	var boon: Boon
	var rarity := Boon.Rarity.COMMON
	var badge_label: Label
	var secs_label: Label
	var button: Button

	func build() -> Cell:
		custom_minimum_size = Vector2(SlotColumn.WIDTH, SlotColumn.ROW_H)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon = BoonIcon.new().setup(null, SlotColumn.ICON)
		icon.position = Vector2((SlotColumn.WIDTH - SlotColumn.ICON) * 0.5, (SlotColumn.ROW_H - SlotColumn.ICON) * 0.5)
		add_child(icon)
		secs_label = UiKit.label("", UiKit.PALE, SlotColumn.SECS_FONT, UiKit.number_font())
		secs_label.add_theme_constant_override(&"outline_size", 5)
		secs_label.add_theme_color_override(&"font_outline_color", UiKit.INK)
		secs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		secs_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		secs_label.size = Vector2(SlotColumn.WIDTH, SlotColumn.ROW_H)
		secs_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(secs_label)
		badge_label = SlotColumn.badge("", false)
		badge_label.position = Vector2(SlotColumn.WIDTH * 0.5 - 6.0, SlotColumn.ROW_H - 17.0)
		add_child(badge_label)
		button = Button.new()
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var none := StyleBoxEmpty.new()
		for st in [&"normal", &"hover", &"pressed", &"disabled", &"focus"]:
			button.add_theme_stylebox_override(st, none)
		add_child(button)
		return self

	func _draw() -> void:
		var c := Vector2(SlotColumn.WIDTH * 0.5, SlotColumn.ROW_H * 0.5)
		var r := SlotColumn.ICON * 0.5 + 3.0
		if boon == null:
			draw_arc(c, r, 0.0, TAU, 40, Color(UiKit.OLD_GOLD, 0.32), 1.5, true)
			return
		draw_circle(c, r, Color(UiKit.INK, 0.8))
		draw_arc(c, r, 0.0, TAU, 40, BoonCard.rarity_color(rarity), 2.5, true)
		if button.has_focus():
			draw_arc(c, r + 3.0, 0.0, TAU, 40, UiKit.GOLD, 2.0, true)

	func show_slot(b: Boon, rarity_: Boon.Rarity, lv: int, glyph: int) -> void:
		boon = b
		rarity = rarity_
		secs_label.text = ""
		icon.cooldown = 0.0
		icon.level = 0
		icon.max_level = 0
		if b != null:
			icon.boon = b
			icon.icon = -1
			badge_label.text = SlotColumn.level_badge(lv, b.max_level)
			badge_label.add_theme_color_override(&"font_color", UiKit.GOLD if lv >= b.max_level else UiKit.PALE)
		else:
			icon.boon = null
			icon.icon = glyph
			icon.tint = SlotColumn.EMPTY
			badge_label.text = ""
		icon.modulate.a = 1.0 if b != null else 0.4
		icon.queue_redraw()
		queue_redraw()

	## The recharge sweep and seconds of a Blessing with a skill.
	func tick(skills: Skills) -> void:
		if boon == null or boon.skill == null or skills == null or boon.skill.kind == SkillDef.Kind.ORBIT:
			return
		var t := skills.timer(boon)
		var live := SlotColumn.is_live(t)
		var cd := snappedf(clampf(t.x / maxf(t.y, 0.01), 0.0, 1.0), 0.02) if live else 0.0
		var secs := str(ceili(t.x)) if live else ""
		if cd == icon.cooldown and secs == secs_label.text:
			return
		icon.cooldown = cd
		secs_label.text = secs
		icon.queue_redraw()


func setup() -> SlotColumn:
	name = "SlotColumn"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.name = "rows"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override(&"separation", 0)
	add_child(box)
	for i in SLOTS.size():
		var cell := Cell.new().build()
		cell.name = "slot_%d" % i
		var at := i
		cell.button.mouse_entered.connect(func() -> void: _inspect(at))
		cell.button.focus_entered.connect(func() -> void:
			cell.queue_redraw()
			_inspect(at))
		cell.button.focus_exited.connect(cell.queue_redraw)
		cell.button.pressed.connect(func() -> void:
			if cells[at].boon != null:
				picked.emit(cells[at].boon))
		cells.append(cell)
		box.add_child(cell)
	_live_box = HFlowContainer.new()
	_live_box.name = "live"
	_live_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_live_box.custom_minimum_size.x = WIDTH
	_live_box.alignment = FlowContainer.ALIGNMENT_CENTER
	_live_box.add_theme_constant_override(&"h_separation", 2)
	box.add_child(_live_box)
	_hint = UiKit.shadow(UiKit.label("", Color(UiKit.PALE, 0.7), HINT_FONT, UiKit.BOLD_FONT))
	_hint.name = "hint"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.custom_minimum_size.x = WIDTH
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_hint)
	custom_minimum_size = Vector2(WIDTH, ROW_H * SLOTS.size())
	return self


func _inspect(i: int) -> void:
	if cells[i].boon != null:
		inspected.emit(cells[i].boon)


## ult_glyph: the ultimate's mark for the empty last place (-1: the generic one).
func show_build(boons: BoonState, ult_glyph: int = -1) -> void:
	var placed := slot_boons(boons)
	for i in SLOTS.size():
		var b := placed[i]
		var glyph := BoonIcon.ACTION_GLYPH + SLOTS[i]
		if SLOTS[i] == Boon.Slot.ULT and ult_glyph >= 0:
			glyph = ult_glyph
		cells[i].show_slot(b, boons.rarity(b.id) if b else Boon.Rarity.COMMON, boons.level(b.id) if b else 0, glyph)
	_owned = boons.owned().size()
	_hint.text = T.t(&"hud_tab_hint", {"key": UiKit.action_label(&"show_blessings")}) if _owned > 0 else ""
	_live_key = "?"  # the chips are read again on the next tick


## Every frame: the recharge of each place, and the live-state chips under the column.
func tick(skills: Skills) -> void:
	if not visible or skills == null:
		return
	for c in cells:
		c.tick(skills)
	var live: Array[Boon] = []
	for b in others(skills.game.boons):
		if b.skill != null and b.skill.kind != SkillDef.Kind.ORBIT and is_live(skills.timer(b)):
			live.append(b)
	var key := ",".join(live.map(func(b: Boon) -> String: return String(b.id)))
	if key != _live_key:
		_live_key = key
		for c in _live_box.get_children():
			_live_box.remove_child(c)
			c.queue_free()
		_chips.clear()
		for b in live:
			var chip := Control.new()
			chip.custom_minimum_size = Vector2(CHIP, CHIP)
			chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chip.add_child(BoonIcon.new().setup(b, CHIP))
			var l := UiKit.label("", UiKit.PALE, SECS_FONT - 3, UiKit.number_font())
			l.add_theme_constant_override(&"outline_size", 4)
			l.add_theme_color_override(&"font_outline_color", UiKit.INK)
			l.size = Vector2(CHIP, CHIP)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chip.add_child(l)
			_chips[b.id] = l
			_live_box.add_child(chip)
	for b in live:
		(_chips[b.id] as Label).text = str(ceili(skills.timer(b).x))


## Number of live chips shown (tests).
func live_count() -> int:
	return _live_box.get_child_count()


## While the Tab panel is up the places take the mouse and the pad's focus; otherwise the mouse goes through to the game.
func set_interactive(on: bool) -> void:
	if on == _interactive:
		return
	_interactive = on
	for c in cells:
		c.button.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
		c.button.focus_mode = Control.FOCUS_ALL if on else Control.FOCUS_NONE
	if not on and is_inside_tree():
		var f := get_viewport().gui_get_focus_owner()
		if f != null and is_ancestor_of(f):
			f.release_focus()


func has_content() -> bool:
	return _owned > 0


## 0..1: how far the column goes translucent while someone stands behind it (the HUD's veil).
func veil(share: float) -> void:
	modulate.a = lerpf(1.0, 0.5, clampf(share, 0.0, 1.0))
