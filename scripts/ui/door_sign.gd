class_name DoorSign
extends Node3D
## The sign over a door, a reward or a shop item: what it gives in warm gold (Alegreya Sans Bold, a dark outline and
## the HUD's shadow) and, under it, a detail in pale (the price). Drawn as interface text over the point it marks (a
## CanvasLayer above the world, like the damage numbers), so fog, glow, tonemap and the vignette never wash it: the
## capitals stand CAP_PX tall at 1080 lines (in proportion on any other screen, through the canvas stretch) and both
## colours keep at least MIN_CONTRAST against the outline (UI-01).
##   var sign := DoorSign.make(T.t(&"reward_gold"), "120 ouro")
##   sign.position.y = 2.7   # the point the sign stands on (its text grows upwards from there)
## The shop (C13-04, three groups and the healing): DoorSign.shop(name, price, group) adds the group's word over the
## name in a cool grey (the run's shop passes none since P1-3) and the price in ivory under it; set_gold(gold) keeps the
## price ivory while there is gold for it and, when not, turns it a muted rose (the colour says it, as the Hades shop).
##   var sign := DoorSign.shop(T.t(&"reward_heal"), 50, T.t(&"shop_group_care"))
##   sign.set_gold(rooms.gold)
## E5 (docs/art/e5_spec.md 7.1): a door's sign may carry a pictogram left of its name (DoorGlyph: chevrons for a hard
## fight, the guardian and Morvath, a drop, a coin, a flame, the cracked diamond) and, for a room that is not a common
## fight, the kind in pale under it ("Difícil", "Guardião"). The Provação's slab says its price in life, or "Vida
## insuficiente" in SHORT_COLOR when he has not enough (set_short).
##   var sign := DoorSign.make(T.t(&"reward_boon"), T.t(&"door_hard"), DoorGlyph.Kind.HARD)
## Stage 1A of the art pack (2026-11-17): a reward's sign carries the reward's own mark left of its name (reward,
## DoorGlyph.of_reward: the same mark the altar's cards and the shop use); the room's pictogram then stands left of the
## line under it ("Difícil", "Guardião"), so each mark sits by the words it explains.
##   var sign := DoorSign.make(T.t(&"reward_gold"), T.t(&"door_hard"), DoorGlyph.Kind.HARD, DoorGlyph.Kind.GOLD)
## Fatia 2: a Blessing's door names who waits behind it on a line of its own under the reward (show_angel): the
## angel's seal (AngelSeal, its house's mark) and its name in its colour, or two small seals and "Dois anjos" for a
## meeting of two (who they are is drawn when the room opens).
## Signs and HUD greetings never touch (keep_out): while a greeting shows, a sign that would cross its band stands
## under it.

## Height of the capitals at a screen 1080 lines tall (the backlog asks for 16 at least).
const CAP_PX := 19.0
## Lines of the project's base canvas (window/size/viewport_height; canvas_items stretch scales from it).
const BASE_LINES := 720.0
## Cap height of Alegreya Sans Bold over its em (OS/2 sCapHeight 644 of 1000).
const CAP_RATIO := 0.644
## Height of a tall lowercase letter ("l", "d") over the em, as the review measures lowercase (about 0,72 drawn).
const ASCENDER := 0.72
## The name's font size on the base canvas (capitals CAP_PX at 1080).
const FONT_SIZE := 20
## The detail line against the name.
const DETAIL_SIZE := 16
## Outline in canvas pixels (about 6 screen pixels at 1080).
const OUTLINE := 4
const TITLE_COLOR := Color(0.98, 0.84, 0.5)
const DETAIL_COLOR := UiKit.PALE
## The shop group's word over the name, smaller, and the price without gold enough for it.
const GROUP_SIZE := 16
const GROUP_COLOR := Color(0.74, 0.72, 0.8)
## The note (add_note, T5, A-T5-7): its first line as big as the detail (lowercase at least 11 px at 720 lines), the
## lines after it (the instruction) in the regular face and the shop group's cool grey; every line of the body
## (detail and note) on a fixed pitch of LINE_PITCH times the font size, on a veil of dark ink with cut corners so
## no light of the room (the slab's glow, the thread of light) runs through the letters.
const NOTE_SIZE := 16
const NOTE_COLOR := DETAIL_COLOR
const HINT_COLOR := GROUP_COLOR
const LINE_PITCH := 1.15
const VEIL := Color(0.035, 0.027, 0.04, 0.6)
const VEIL_CUT := 6
const VEIL_PAD := Vector2(10, 2)
const SHORT_COLOR := Color(0.92, 0.62, 0.58)
const OUTLINE_COLOR := Color(0.035, 0.027, 0.04)
## WCAG contrast ratio each colour keeps against the outline.
const MIN_CONTRAST := 4.5
## Above the world, with the damage numbers, under the HUD and the menus (Game: numbers 2, HUD 5).
const LAYER := 2
## The band of the screen a HUD greeting stands in while it shows (EloBanner sets it, Rect2() when none; canvas px):
## a sign that would cross it goes under it, KEEP_GAP px lower (UI review d2ff05d, P1-1: "Provação vencida" touched
## the door's "Bênção / Guardião", the shop's "Bênção nova" stood 50 px over its five signs).
static var keep_out := Rect2()
const KEEP_GAP := 8.0

var title: Label
var detail: Label
## The room's pictogram (null: none): left of the name, or of the detail when the reward's mark stands by the name.
var mark: DoorGlyph
## The reward's mark left of the name (null: none).
var reward: DoorGlyph
## The shop group's word (null: not a shop sign).
var group: Label
## The explanation under the detail (null: none; add_note): its first line, and all its lines.
var note: Label
var notes: Array[Label] = []
## The veil behind the body (detail and note; null until a note is added) and the column the body's lines stand in.
var veil: PanelContainer
var _body: VBoxContainer
## The shop price (-1: not a shop sign) and the gold still missing for it (0: enough).
var price := -1
var missing := 0
var _layer: CanvasLayer
var _box: VBoxContainer
## The angel's line (null: none; show_angel).
var angel_row: HBoxContainer
## The seal's height on the sign and the gap of the two seals of a meeting.
const ANGEL_SEAL := 20.0


## A sign with a name and, optionally, a detail line under it (empty: none), a pictogram left of the name and the
## reward's mark (with both, the pictogram goes left of the detail).
static func make(name_text: String, detail_text: String = "", glyph: DoorGlyph.Kind = DoorGlyph.Kind.NONE,
		reward_mark: DoorGlyph.Kind = DoorGlyph.Kind.NONE) -> DoorSign:
	var s := DoorSign.new()
	s.name = "DoorSign"
	s._layer = CanvasLayer.new()
	s._layer.layer = LAYER
	s.add_child(s._layer)
	s._box = VBoxContainer.new()
	s._box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s._box.add_theme_constant_override(&"separation", -4)
	s._box.visible = false
	s._layer.add_child(s._box)
	s.title = _label(name_text, TITLE_COLOR, FONT_SIZE)
	s.title.name = "title"
	if glyph != DoorGlyph.Kind.NONE:
		s.mark = DoorGlyph.new().setup(glyph)
		s.mark.name = "mark"
	if reward_mark != DoorGlyph.Kind.NONE:
		s.reward = DoorGlyph.new().setup(reward_mark)
		s.reward.name = "reward"
	var by_detail := s.reward != null and detail_text != ""
	s._box.add_child(_row(s.title, s.reward if s.reward != null else s.mark, "row"))
	if detail_text != "":
		s.detail = _label(detail_text, DETAIL_COLOR, DETAIL_SIZE)
		s.detail.name = "detail"
		s._box.add_child(_row(s.detail, s.mark if by_detail else null, "detail_row"))
	if s.mark != null and s.mark.get_parent() == null:
		# a reward and a pictogram without a detail line: both by the name, the room's first
		s.title.get_parent().add_child(s.mark)
		s.title.get_parent().move_child(s.mark, 0)
	return s


## The angel waiting behind the door (angel null: a meeting of two) on its own line under the name; text is the line
## the room's words already carry (Rooms.door_text), taken out of the detail so it shows once.
func show_angel(text: String, angel: AngelDef) -> void:
	if detail != null:
		var lines := Array(detail.text.split("\n"))
		lines.erase(text)
		detail.text = "\n".join(lines)
		var row := detail.get_parent() if detail.get_parent() != _box else detail
		row.visible = detail.text != ""
	angel_row = HBoxContainer.new()
	angel_row.name = "angel"
	angel_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	angel_row.alignment = BoxContainer.ALIGNMENT_CENTER
	angel_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	angel_row.add_theme_constant_override(&"separation", 5)
	var col := DETAIL_COLOR
	if angel != null:
		col = AngelSeal.tint(angel.family).lightened(0.35)
		angel_row.add_child(AngelSeal.new().setup(angel.family, ANGEL_SEAL))
	else:
		var two := Control.new()
		two.name = "two"
		two.custom_minimum_size = Vector2(ANGEL_SEAL * 1.5, ANGEL_SEAL)
		two.mouse_filter = Control.MOUSE_FILTER_IGNORE
		two.draw.connect(func() -> void:
			for i in 2:
				SealMedal.draw_seal(two, Vector2(ANGEL_SEAL * (0.5 + i * 0.5), ANGEL_SEAL * 0.5), ANGEL_SEAL * 0.42, 1.0))
		angel_row.add_child(two)
	var l := _label(text, col, DETAIL_SIZE)
	l.name = "angel_name"
	angel_row.add_child(l)
	_box.add_child(angel_row)
	_box.move_child(angel_row, title.get_parent().get_index() + 1 if title.get_parent() != _box else title.get_index() + 1)


## A line of the sign: the label alone, or a row with the mark left of it.
static func _row(l: Label, mark_: DoorGlyph, row_name: String) -> Control:
	if mark_ == null:
		return l
	var row := HBoxContainer.new()
	row.name = row_name
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override(&"separation", 5)
	row.add_child(mark_)
	row.add_child(l)
	return row


## A shop item's sign: the group's word over the name (empty: none), the name and its price in ivory.
static func shop(name_text: String, price_: int, group_text: String = "",
		reward_mark: DoorGlyph.Kind = DoorGlyph.Kind.NONE) -> DoorSign:
	var s := make(name_text, price_text(price_), DoorGlyph.Kind.NONE, reward_mark)
	s.price = price_
	if group_text != "":
		s.group = _label(group_text, GROUP_COLOR, GROUP_SIZE)
		s.group.name = "group"
		s._box.add_child(s.group)
		s._box.move_child(s.group, 0)
	return s


## "150 ouro".
static func price_text(n: int) -> String:
	return T.t(&"shop_price", {"n": n})


## The price in ivory while gold is enough; without, muted rose and what is missing.
func set_gold(gold: int) -> void:
	if detail == null or price < 0:
		return
	missing = maxi(price - gold, 0)
	# the price alone, its colour saying whether there is gold for it (benchmark_hades2_ui.md P1-3; what is missing
	# shows by the key when he stands at the item, Rooms._step_prompt)
	detail.text = price_text(price)
	detail.add_theme_color_override(&"font_color", SHORT_COLOR if missing > 0 else DETAIL_COLOR)


## A short explanation under everything (T5, the Provação's slab: what it is and how to refuse it). Lines split by
## "\n": the first as the detail, the rest (the instruction) in the regular face and a cool grey, so the name and the
## price stay first. The detail and the note move onto the veil, on a fixed pitch. Called again, it rewrites the note.
func add_note(text: String) -> Label:
	if veil == null:
		_make_veil()
	for l in notes:
		l.free()
	notes.clear()
	var lines := text.split("\n")
	for i in lines.size():
		var l := _label(lines[i], NOTE_COLOR if i == 0 else HINT_COLOR, NOTE_SIZE, UiKit.BOLD_FONT if i == 0 else UiKit.TEXT_FONT)
		l.name = "note" if i == 0 else "note_%d" % i
		_body.add_child(l)
		notes.append(l)
	note = notes[0]
	return note


## The veil of dark ink with cut corners and, in it, the column on a fixed pitch; the name and the detail move into it.
func _make_veil() -> void:
	veil = PanelContainer.new()
	veil.name = "veil"
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = VEIL
	sb.set_corner_radius_all(VEIL_CUT)
	sb.corner_detail = 1
	sb.content_margin_left = VEIL_PAD.x
	sb.content_margin_right = VEIL_PAD.x
	sb.content_margin_top = VEIL_PAD.y
	sb.content_margin_bottom = VEIL_PAD.y
	veil.add_theme_stylebox_override(&"panel", sb)
	_body = VBoxContainer.new()
	_body.name = "body"
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_theme_constant_override(&"separation", line_gap(NOTE_SIZE))
	veil.add_child(_body)
	# the name too: a thread of light behind the sign never runs through any of its letters
	for n in _box.get_children():
		n.reparent(_body, false)
	_box.add_child(veil)


## The separation between two lines of this size for a pitch of LINE_PITCH times the size (negative: the font's own
## line is taller than the pitch).
static func line_gap(font_size: int) -> int:
	return roundi(font_size * LINE_PITCH - UiKit.BOLD_FONT.get_height(font_size))


## The detail line as a warning (the slab without life enough: "Vida insuficiente" in SHORT_COLOR) or back to its own
## text in the detail colour.
func set_short(short: bool, short_text: String, normal_text: String) -> void:
	if detail == null:
		return
	detail.text = short_text if short else normal_text
	detail.add_theme_color_override(&"font_color", SHORT_COLOR if short else DETAIL_COLOR)


## Whether the gold given last (set_gold) is enough for this sign's price (true for a sign without price).
func affordable() -> bool:
	return missing == 0


## Follows the point it marks: the text's bottom centre on it; hidden behind the camera or with the sign hidden.
func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	var at := global_position
	if cam == null or cam.is_position_behind(at) or not is_visible_in_tree():
		_box.visible = false
		return
	var s := _box.get_combined_minimum_size()
	_box.size = s
	_box.position = (cam.unproject_position(at) - Vector2(s.x * 0.5, s.y)).round()
	# a greeting of the HUD up there (EloBanner): the sign steps down under it, never touching it (P1-1)
	if keep_out.has_area() and Rect2(_box.position, s).intersects(keep_out):
		_box.position.y = keep_out.end.y + KEEP_GAP
	_box.visible = true


## Height of the capitals in screen pixels for this canvas font size on a screen this many lines tall.
static func cap_px(font_size: int, lines: float) -> float:
	return font_size * CAP_RATIO * lines / BASE_LINES


## WCAG 2 contrast ratio between two colours (1 to 21).
static func contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func _luminance(c: Color) -> float:
	return 0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b)


static func _linear(v: float) -> float:
	return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)


static func _label(text: String, color: Color, size: int, font: Font = UiKit.BOLD_FONT) -> Label:
	var l := UiKit.shadow(UiKit.label(text, color, size, font))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	l.add_theme_constant_override(&"outline_size", OUTLINE)
	l.add_theme_color_override(&"font_outline_color", OUTLINE_COLOR)
	return l
