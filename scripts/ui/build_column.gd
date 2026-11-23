class_name BuildColumn
extends Control
## H1 of the SWORN reference (2026-11-21): the run's build on the right edge, read at a glance. A dark banner standing
## down the edge (a swallow tail at its foot) with one medallion per button, in the order of the row at the bottom:
## left button, right button, Q, E, Shift, Space. The Blessing of that button's slot with its level in the colour of its
## rarity; a button without one (Shift has none) shows its own mark in grey. Under
## them, if any: the Elos formed and the Psalm taken. Pure display: Hud calls show() each time the build changes and
## veil() while someone stands behind it. px at 720 lines; the window stretches the canvas.
##   var col := BuildColumn.new().setup()
##   col.show_build(boons, ult_glyph, psalm)       # boons: BoonState

const WIDTH := 58.0
const ROW_H := 46.0
const ICON := 30.0
const FOOT_ICON := 26.0
const PAD := 6.0
const TAIL := 10.0
const LEVEL_FONT := 12
const BACK := Color(0.035, 0.027, 0.04, 0.8)
const EMPTY := Color(0.42, 0.42, 0.46)
## The buttons in the row's order: the Blessing slot each holds (Boon.Slot.NONE: none can yet) and the mark of the
## button itself (a BoonIcon glyph id; -1: the bare action's, BoonIcon.ACTION_GLYPH + slot).
const BUTTONS: Array[Array] = [[Boon.Slot.ATTACK, -1, &"light_attack"], [Boon.Slot.SPECIAL, -1, &"heavy_attack"],
	[Boon.Slot.CAST, BoonIcon.SHOUT_GLYPH, &"shout"], [Boon.Slot.RUSH, BoonIcon.RUSH_GLYPH, &"rush"],
	[Boon.Slot.ULT, BoonIcon.ULT_GLYPH, &"ultimate"], [Boon.Slot.DASH, -1, &"dodge"]]
## The index of Shift's entry (its mark is the ultimate's, set by show_build).
const ULT_AT := 4

## One entry: the medallion and, under it, the level (or nothing for an empty button).
class Entry extends Control:
	var icon: BoonIcon
	var level_label: Label

	func build() -> Entry:
		custom_minimum_size = Vector2(WIDTH, ROW_H)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon = BoonIcon.new().setup(null, ICON)
		icon.position = Vector2((WIDTH - ICON) * 0.5, 2.0)
		add_child(icon)
		level_label = UiKit.shadow(UiKit.label("", UiKit.PALE, LEVEL_FONT, UiKit.BOLD_FONT))
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_label.position = Vector2(0.0, ICON + 2.0)
		level_label.size = Vector2(WIDTH, ROW_H - ICON - 2.0)
		add_child(level_label)
		return self

	## b: the Blessing of the button (null: empty, its own mark in grey). glyph: that mark's BoonIcon id.
	func show_entry(b: Boon, lv: int, rarity: Boon.Rarity, glyph: int) -> void:
		if b != null:
			icon.boon = b
			icon.icon = -1
			icon.level = lv
			icon.max_level = b.max_level
			level_label.text = T.t(&"hud_build_level", {"n": lv}) if b.has_rarity() else ""
			level_label.add_theme_color_override(&"font_color", BoonCard.rarity_color(rarity).lightened(0.1))
		else:
			icon.boon = null
			icon.icon = glyph
			icon.tint = EMPTY
			icon.level = 0
			icon.max_level = 0
			level_label.text = ""
		icon.modulate.a = 1.0 if b != null else 0.7
		icon.queue_redraw()

var entries: Array[Entry] = []
var _foot: VBoxContainer
var _alpha := 1.0


func setup() -> BuildColumn:
	name = "BuildColumn"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	box.name = "rows"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override(&"separation", 0)
	box.position = Vector2(0.0, PAD)
	add_child(box)
	for i in BUTTONS.size():
		var e := Entry.new().build()
		e.name = "button_%d" % i
		entries.append(e)
		box.add_child(e)
	_foot = VBoxContainer.new()
	_foot.name = "foot"
	_foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_foot.add_theme_constant_override(&"separation", 2)
	_foot.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_foot)
	_fit(0)
	return self


## The column's height with this many rows under the buttons' six (an Elo's, the Psalm's).
static func height_for(foot_rows: int) -> float:
	return PAD * 2.0 + ROW_H * BUTTONS.size() + (FOOT_ICON + 2.0) * foot_rows + TAIL


func _fit(foot_rows: int) -> void:
	custom_minimum_size = Vector2(WIDTH, height_for(foot_rows))
	size = custom_minimum_size
	queue_redraw()


## Reads the build: the Blessing in each slot, the Elos formed (at most two shown) and the Psalm taken (null: none).
## ult_glyph: the ultimate's mark for Shift's button (-1: the generic one).
func show_build(boons: BoonState, ult_glyph: int = -1, psalm: PsalmDef = null) -> void:
	var by_button := {}
	var elos: Array[Boon] = []
	for b in boons.owned():
		if b.is_duo():
			elos.append(b)
		elif b.slot != Boon.Slot.NONE:
			by_button[b.button()] = b  # BC-2: the Investida's Blessings share the dash slot but belong to E
	for i in BUTTONS.size():
		var slot: Boon.Slot = BUTTONS[i][0]
		var b: Boon = by_button.get(BUTTONS[i][2])
		var glyph: int = BUTTONS[i][1] if BUTTONS[i][1] >= 0 else BoonIcon.ACTION_GLYPH + slot
		if i == ULT_AT and ult_glyph >= 0:
			glyph = ult_glyph
		entries[i].show_entry(b, boons.level(b.id) if b else 0, boons.rarity(b.id) if b else Boon.Rarity.COMMON, glyph)
	for c in _foot.get_children():
		_foot.remove_child(c)
		c.queue_free()
	var rows := 0
	if not elos.is_empty():
		var row := HBoxContainer.new()
		row.name = "elos"
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for b in elos.slice(0, 2):
			row.add_child(BoonIcon.new().setup(b, FOOT_ICON * 0.9))
		_foot.add_child(row)
		rows += 1
	if psalm != null:
		var holder := CenterContainer.new()
		holder.name = "psalm"
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(PsalmIcon.new().setup(psalm, FOOT_ICON))
		_foot.add_child(holder)
		rows += 1
	_fit(rows)


## The glyph ids the entries show now, in order (tests).
func marks() -> Array[int]:
	var out: Array[int] = []
	for e in entries:
		out.append(e.icon.icon if e.icon.boon == null else -1)
	return out


## 0..1: how far the banner goes translucent while someone stands behind it (the HUD's veil).
func veil(share: float) -> void:
	_alpha = lerpf(1.0, 0.5, clampf(share, 0.0, 1.0))
	modulate.a = _alpha


func _draw() -> void:
	var h := size.y
	var body := PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, h), Vector2(size.x * 0.5, h - TAIL), Vector2(0, h)])
	draw_colored_polygon(body, BACK)
	var edge := PackedVector2Array(body)
	edge.append(body[0])
	draw_polyline(edge, Color(UiKit.OLD_GOLD, 0.7), 1.5, true)
