class_name BuildColumn
extends Control
## H1 of the SWORN reference (2026-11-21): the run's build on the right edge, read at a glance. A dark banner standing
## down the edge (a swallow tail at its foot), one row per Blessing: its medallion on the left, its name on the right
## and under the name its state (the recharge seconds, or the level when above 1). First the Blessing of each button in
## the order of the row at the bottom (left button, right button, Q, E, Shift, Space), then the ones that own no
## button (passives, a second on the same button). A button without a Blessing has no row (the bottom row says it).
## Under them, if any: the Elos formed and the Psalm taken. Pure display: Hud calls show_build() each time the build
## changes and veil() while someone stands behind it. px at 720 lines; the window stretches the canvas.
##   var col := BuildColumn.new().setup()
##   col.show_build(boons, ult_glyph, psalm)       # boons: BoonState

const WIDTH := 168.0
const ROW_H := 38.0
const ICON := 32.0
const FOOT_ICON := 28.0
const PAD := 6.0
const TAIL := 10.0
const NAME_FONT := 13
const LEVEL_FONT := 12
## PT-26-4 (second round): the rows after the buttons' own use the same height; the column keeps room for MAX_ROWS
## rows so it never leaves the screen (the rest becomes a "+N"). MARGIN: the gap to the screen's edge.
const EXTRA_H := ROW_H
const MAX_ROWS := 12
const MARGIN := 14.0
const READY := Color(0.55, 0.9, 0.6)
const BACK := Color(0.035, 0.027, 0.04, 0.82)
const EMPTY := Color(0.42, 0.42, 0.46)
## The buttons in the row's order: the Blessing slot each holds (Boon.Slot.NONE: none can yet) and the mark of the
## button itself (a BoonIcon glyph id; -1: the bare action's, BoonIcon.ACTION_GLYPH + slot).
const BUTTONS: Array[Array] = [[Boon.Slot.ATTACK, -1, &"light_attack"], [Boon.Slot.SPECIAL, -1, &"heavy_attack"],
	[Boon.Slot.CAST, BoonIcon.SHOUT_GLYPH, &"shout"], [Boon.Slot.RUSH, BoonIcon.RUSH_GLYPH, &"rush"],
	[Boon.Slot.ULT, BoonIcon.ULT_GLYPH, &"ultimate"], [Boon.Slot.DASH, -1, &"dodge"]]
## The index of Shift's entry (its mark is the ultimate's, set by show_build).
const ULT_AT := 4

## One row: the medallion, the Blessing's name and, under it, the state.
class Entry extends Control:
	var icon: BoonIcon
	var name_label: Label
	var level_label: Label
	## The Blessing shown, and what its state says: recharging (a sweep over the medallion and the seconds left),
	## ready (a small lit dot) or passive (no dot, no sweep: it works on its own).
	var boon: Boon
	var lv := 0
	var rarity := Boon.Rarity.COMMON
	var ready_dot := false
	var dot: Control

	func _draw_dot() -> void:
		if ready_dot and icon != null and icon.boon != null:
			var at := icon.position + Vector2(icon.size.x - 2.0, 5.0)
			dot.draw_circle(at, 5.0, UiKit.INK)
			dot.draw_circle(at, 3.5, BuildColumn.READY)

	func build() -> Entry:
		custom_minimum_size = Vector2(WIDTH, ROW_H)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon = BoonIcon.new().setup(null, ICON)
		icon.position = Vector2(PAD, (ROW_H - ICON) * 0.5)
		add_child(icon)
		var x := PAD + ICON + 7.0
		name_label = UiKit.shadow(UiKit.label("", UiKit.PALE, NAME_FONT, UiKit.BOLD_FONT))
		name_label.position = Vector2(x, 2.0)
		name_label.size = Vector2(WIDTH - x - 4.0, 18.0)
		name_label.clip_text = true
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		add_child(name_label)
		level_label = UiKit.shadow(UiKit.label("", UiKit.PALE, LEVEL_FONT, UiKit.BOLD_FONT))
		level_label.position = Vector2(x, 20.0)
		level_label.size = Vector2(WIDTH - x - 4.0, 16.0)
		add_child(level_label)
		dot = Control.new()
		dot.name = "ReadyDot"
		dot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.draw.connect(_draw_dot)
		add_child(dot)
		return self

	## The state every frame (Hud): the recharge of a Blessing that has a skill, read from the skills.
	func tick(skills: Skills) -> void:
		if boon == null or boon.skill == null or skills == null or boon.skill.kind == SkillDef.Kind.ORBIT:
			return
		var t := skills.timer(boon)
		var wait := clampf(t.x / maxf(t.y, 0.01), 0.0, 1.0)
		var charging := t.x > 0.05
		var cd := snappedf(wait, 0.02) if charging else 0.0
		var lit := not charging
		var text := T.t(&"hud_build_wait", {"n": ceili(t.x)}) if charging else _level_text()
		if cd == icon.cooldown and lit == ready_dot and text == level_label.text:
			return
		icon.cooldown = cd
		ready_dot = lit
		level_label.text = text
		level_label.add_theme_color_override(&"font_color", UiKit.PALE if charging else BoonCard.rarity_color(rarity).lightened(0.1))
		icon.queue_redraw()
		dot.queue_redraw()

	## Only a Blessing above level 1 says its level (a "Nv. 1" on every row was noise).
	func _level_text() -> String:
		if boon != null and boon.is_complement() and not boon.reserve:
			return T.t(&"hud_build_complement")  # V1: a complement is told from the principal of a button
		return T.t(&"hud_build_level", {"n": lv}) if boon != null and boon.has_rarity() and lv > 1 else ""

	## b: the Blessing of the button (null: empty, its own mark in grey). glyph: that mark's BoonIcon id.
	func show_entry(b: Boon, lv_: int, rarity_: Boon.Rarity, glyph: int) -> void:
		boon = b
		lv = lv_
		rarity = rarity_
		ready_dot = false
		icon.cooldown = 0.0
		if b != null:
			icon.boon = b
			icon.icon = -1
			icon.level = lv_
			icon.max_level = b.max_level
			name_label.text = T.t("boon_" + String(b.id))
			level_label.text = _level_text()
			level_label.add_theme_color_override(&"font_color", BoonCard.rarity_color(rarity_).lightened(0.1))
		else:
			icon.boon = null
			icon.icon = glyph
			icon.tint = EMPTY
			icon.level = 0
			icon.max_level = 0
			name_label.text = ""
			level_label.text = ""
		icon.modulate.a = 1.0 if b != null else 0.7
		icon.queue_redraw()

var entries: Array[Entry] = []
var _extras: VBoxContainer
var _extra_count := 0
var _foot: VBoxContainer
var _alpha := 1.0
var _held := 0


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
	_extras = VBoxContainer.new()
	_extras.name = "extras"
	_extras.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_extras.add_theme_constant_override(&"separation", 0)
	box.add_child(_extras)
	_foot = VBoxContainer.new()
	_foot.name = "foot"
	_foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_foot.add_theme_constant_override(&"separation", 2)
	_foot.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_foot)
	_fit(0, 0)
	return self


## The column's height with this many rows under the buttons' six (an Elo's, the Psalm's).
static func height_for(foot_rows: int, button_rows: int = BUTTONS.size(), extra_rows: int = 0) -> float:
	return PAD * 2.0 + ROW_H * button_rows + EXTRA_H * extra_rows + (FOOT_ICON + 2.0) * foot_rows + TAIL


func _fit(foot_rows: int, button_rows: int = BUTTONS.size(), extra_rows: int = 0) -> void:
	custom_minimum_size = Vector2(WIDTH, height_for(foot_rows, button_rows, extra_rows))
	size = custom_minimum_size
	queue_redraw()


## Reads the build: the Blessing in each slot, the Elos formed (at most two shown) and the Psalm taken (null: none).
## ult_glyph: the ultimate's mark for Shift's button (-1: the generic one).
func show_build(boons: BoonState, ult_glyph: int = -1, psalm: PsalmDef = null) -> void:
	var by_button := {}
	var held := 0
	var elos: Array[Boon] = []
	var extra: Array[Boon] = []
	for b in boons.owned():
		if b.is_duo():
			elos.append(b)
		elif b.slot != Boon.Slot.NONE and not by_button.has(b.button()):
			by_button[b.button()] = b  # BC-2: the Investida's Blessings share the dash slot but belong to E
		else:
			extra.append(b)  # PT-26-4: a passive or a second one on the button: shown too, never dropped
	for i in BUTTONS.size():
		var slot: Boon.Slot = BUTTONS[i][0]
		var b: Boon = by_button.get(BUTTONS[i][2])
		var glyph: int = BUTTONS[i][1] if BUTTONS[i][1] >= 0 else BoonIcon.ACTION_GLYPH + slot
		if i == ULT_AT and ult_glyph >= 0:
			glyph = ult_glyph
		entries[i].show_entry(b, boons.level(b.id) if b else 0, boons.rarity(b.id) if b else Boon.Rarity.COMMON, glyph)
		# UI 15: the actions live in the bottom row only; here just the Blessings gained
		entries[i].visible = b != null
		held += 1 if b != null else 0
	for c in _extras.get_children():
		_extras.remove_child(c)
		c.queue_free()
	var room := maxi(MAX_ROWS - held - (1 if extra.size() > MAX_ROWS - held else 0), 0)
	var shown_extra := extra.slice(0, room)
	for b in shown_extra:
		var e := Entry.new().build()
		e.show_entry(b, boons.level(b.id), boons.rarity(b.id), -1)
		_extras.add_child(e)
	if extra.size() > shown_extra.size():
		var more := UiKit.shadow(UiKit.label(T.t(&"hud_more", {"n": extra.size() - shown_extra.size()}), UiKit.PALE, LEVEL_FONT, UiKit.BOLD_FONT))
		more.name = &"More"
		more.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		more.custom_minimum_size = Vector2(WIDTH, ROW_H * 0.6)
		_extras.add_child(more)
	_extra_count = shown_extra.size() + (1 if extra.size() > shown_extra.size() else 0)
	held += shown_extra.size()
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
	_held = held
	_fit(rows, held - shown_extra.size(), _extra_count)


## The recharge of every Blessing, every frame (Hud): the sweep, the seconds left, the ready dot.
func tick(skills: Skills) -> void:
	if not visible:
		return
	for e in entries:
		if e.visible:
			e.tick(skills)
	for c in _extras.get_children():
		if c is Entry:
			(c as Entry).tick(skills)


## Whether the column has anything to show (a Blessing, an Elo or the Psalm).
func has_content() -> bool:
	return _held > 0 or _foot.get_child_count() > 0


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
