class_name BoonCard
extends Button
## One tall card of the gift screen (BoonChoice): the art at the top (a painted medallion by the gift's id, BoonArt, or
## the drawn BoonIcon; an Elo hangs between its two sources on a chain), then name, family or "Elo de A e B", the
## action, level and rarity on one line, a thin rule, the description on clean dark ground and, at the bottom, the gift
## it replaces. The frame is a thin line of old metal; its outer edge and glow take the rarity's colour (common keeps
## a quiet metal), and the card in focus gains a pale inner line and lighter ink, so focus never hides the rarity (no
## scaling: a scaled card blurs its text).
## E3-06: each rarity has its own frame, read before the colour: common one quiet line, rare one line with coloured
## rivets, epic a double line, heroic a double line of old gold with corner flourishes (never bright yellow). An Elo
## has no rarity and no level (BUG-017): its frame is the chain's metal with links on the corners and its card shows
## neither. An exchange (upgrade: the card replaces the Blessing on the same action one rarity up) wears a tab on top,
## "Sobe uma raridade", and says at the bottom what it trades and from which rarity to which.
## boon null: the rest card ("Fôlego").

## Card size at 720 lines (the screen scales with the window: canvas_items stretch).
const SIZE := Vector2(320, 450)
const PAD := 18.0
## Height of the art band at the top.
const ART_H := 172.0
## Medallions: painted Elo, painted single gift, drawn single gift; the drawn Elo (EloLink) and the sources.
const PAINTED_ELO := 138.0
const PAINTED := 156.0
const DRAWN := 116.0
const DRAWN_ELO := 88.0
const SOURCE := 46.0
const SOURCE_GAP := 20.0
const DRAWN_SOURCE := 50.0
const DRAWN_GAP := 30.0
## Frame: the outer edge's width, the old metal line inside it, the focus line's inset and colour.
const EDGE_W := 2.0
const METAL_INSET := 5.0
const FOCUS_INSET := 9.0
const FOCUS_W := 2.0
const FOCUS_COLOR := Color(1.0, 0.95, 0.84, 0.95)
## The card's colour of each rarity (the interface's own; Boon.RARITY_COLOR stays the game's): common a quiet metal
## (the game's common colour is a plain white), rare a cold blue, epic violet, heroic old gold (HSV saturation 0.52,
## never bright yellow). The rarity's word on the card takes the same colour.
const RARITY_EDGE: Array[Color] = [Color("8f7f63"), Color("6f9be6"), Color("b07ae6"), Color("d4ad66")]
const COMMON_EDGE := Color("8f7f63")
## Lines of the outer edge per rarity (epic and heroic are doubled) and the gap between the two.
const RARITY_LINES: Array[int] = [1, 1, 2, 2]
const DOUBLE_GAP := 3.0
## Heroic corner flourish: a diamond on the corner and a short spur along each side.
const FLOURISH := 6.0
const SPUR := 22.0
## An Elo's edge: one line of the chain's darker metal (heroic is the lit old gold, doubled), links on the corners.
const ELO_EDGE := EloLink.METAL
## The exchange's tab on the top edge: its height and how far it rises above the card.
const TAB_H := 24.0
const TAB_RISE := 12.0
const INK := Color(0.045, 0.035, 0.06, 0.97)
const INK_LIT := Color(0.085, 0.065, 0.09, 0.98)
const IVORY := Color(0.97, 0.93, 0.84)
const WARN := Color(1.0, 0.62, 0.5)

var boon: Boon
var rarity: Boon.Rarity = Boon.Rarity.COMMON
## An Elo: no rarity, no level, the chain's frame.
var elo := false
## An exchange one rarity up (E3-01): the tab on top and the trade at the bottom.
var upgrade := false
## The control that shows the gift at the top: a TextureRect (painted), a BoonIcon or an EloLink.
var crest: Control

static var _glow: GradientTexture2D


## level: the gift's level now (0 = new; an exchange: the level it keeps); replaces: the gift it would replace, or null.
## upgrade: the card is an exchange one rarity up; replaced_rarity: the rarity of the gift it replaces.
func setup(b: Boon, rarity_: Boon.Rarity, level: int, from: Array[Boon], replaces: Boon, text: String,
		upgrade_: bool = false, replaced_rarity: Boon.Rarity = Boon.Rarity.COMMON) -> BoonCard:
	boon = b
	elo = b != null and (b.is_duo() or not from.is_empty())
	upgrade = upgrade_ and b != null and not elo
	rarity = Boon.Rarity.COMMON if elo else rarity_
	custom_minimum_size = SIZE
	focus_mode = Control.FOCUS_ALL
	var empty := StyleBoxEmpty.new()
	for st in [&"normal", &"hover", &"pressed", &"focus", &"disabled", &"hover_pressed"]:
		add_theme_stylebox_override(st, empty)
	_add_glow(b.color() if b else Color(0.55, 0.85, 0.6))
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = PAD
	box.offset_right = -PAD
	box.offset_top = PAD * 0.5
	box.offset_bottom = -PAD
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override(&"separation", 5)
	add_child(box)
	var art := CenterContainer.new()
	art.custom_minimum_size.y = ART_H
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(art)
	crest = _crest(b, from)
	art.add_child(crest)
	if b == null:
		box.add_child(_name(T.t(&"boon_rest")))
		box.add_child(_rule())
		box.add_child(_text(text, UiKit.PALE, 18))
	else:
		box.add_child(_name(T.t("boon_" + String(b.id))))
		var cap := EloLink.caption(from) if not from.is_empty() else T.t(Boon.FAMILY_KEY[b.family])
		box.add_child(_text(cap, EloLink.METAL_LIT if not from.is_empty() else b.color().lightened(0.25), 17, UiKit.BOLD_FONT))
		var meta := _meta(b, level)
		if meta.get_child_count() > 0:
			box.add_child(meta)
		else:
			meta.free()
		box.add_child(_rule())
		var desc := _text(text, UiKit.PALE, 18)
		desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(desc)
		if replaces != null:
			var replaced_name := T.t("boon_" + String(replaces.id))
			var warn: Label
			if upgrade:
				warn = _text(T.t(&"choice_upgrade_swap", {"name": replaced_name, "from": T.t(Boon.RARITY_KEY[replaced_rarity]),
						"to": T.t(Boon.RARITY_KEY[rarity])}), rarity_color(rarity).lightened(0.12), 16, UiKit.BOLD_FONT)
			else:
				warn = _text(T.t(&"choice_replaces", {"name": replaced_name}), WARN, 16, UiKit.BOLD_FONT)
			warn.name = &"Replaces"
			box.add_child(warn)
	var frame := Control.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.draw.connect(_draw_frame.bind(frame))
	add_child(frame)
	if upgrade:
		add_child(_upgrade_tab())
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(_on_focus.bind(true, frame))
	focus_exited.connect(_on_focus.bind(false, frame))
	return self


## The colour of the outer edge: the rarity's (RARITY_EDGE), the chain's metal for an Elo. Never changed by focus.
func edge_color() -> Color:
	return ELO_EDGE if elo else rarity_color(rarity)


## How many lines the outer edge has (an Elo: one, its corners carry the links).
func edge_lines() -> int:
	return 1 if elo else RARITY_LINES[rarity]


## The card's colour of a rarity.
static func rarity_color(r: Boon.Rarity) -> Color:
	return RARITY_EDGE[clampi(r, 0, RARITY_EDGE.size() - 1)]


## Whether the pale inner line of focus is drawn.
func focus_lit() -> bool:
	return has_focus()


func _on_focus(on: bool, frame: Control) -> void:
	if on:
		Audio.play(&"ui_move")
	frame.queue_redraw()
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var edge := edge_color()
	var bg := UiKit.box(INK_LIT if has_focus() else INK, Color(0, 0, 0, 0), 0, 0, 8)
	if elo:
		bg.shadow_color = Color(edge.r, edge.g, edge.b, 0.25)
		bg.shadow_size = 10
	elif rarity != Boon.Rarity.COMMON:
		bg.shadow_color = Color(edge.r, edge.g, edge.b, 0.4)
		bg.shadow_size = 14
	else:
		bg.shadow_color = Color(0, 0, 0, 0.5)
		bg.shadow_size = 8
	draw_style_box(bg, r)


func _draw_frame(frame: Control) -> void:
	var r := Rect2(Vector2.ZERO, frame.size)
	var edge := edge_color()
	frame.draw_style_box(UiKit.box(Color(0, 0, 0, 0), edge, int(EDGE_W), 0, 8), r)
	var doubled := edge_lines() > 1
	if doubled:
		frame.draw_style_box(UiKit.box(Color(0, 0, 0, 0), Color(edge, 0.7), 1, 0, 7), r.grow(-EDGE_W - DOUBLE_GAP))
	var metal := r.grow(-METAL_INSET - (DOUBLE_GAP if doubled else 0.0))
	frame.draw_rect(metal, Color(UiKit.OLD_GOLD, 0.75), false, 1.0)
	var corners: Array[Vector2] = [metal.position, Vector2(metal.end.x, metal.position.y), metal.end, Vector2(metal.position.x, metal.end.y)]
	if elo:
		for c in corners:
			_draw_link(frame, c)
	else:
		# small diamonds on the metal line's corners, as rivets: the metal, or the rarity's colour from rare up
		var rivet := EloLink.METAL_LIT if rarity == Boon.Rarity.COMMON else edge.lightened(0.15)
		for c in corners:
			_diamond(frame, c, 3.5, rivet)
		if rarity == Boon.Rarity.HEROIC:
			_draw_flourishes(frame, r.grow(-EDGE_W * 0.5), edge)
	if has_focus():
		var f := r.grow(-FOCUS_INSET)
		var s := UiKit.box(Color(0, 0, 0, 0), FOCUS_COLOR, int(FOCUS_W), 0, 5)
		frame.draw_style_box(s, f)


static func _diamond(ci: CanvasItem, c: Vector2, d: float, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), col)


## Two small interlocked links on a corner of an Elo's card.
static func _draw_link(ci: CanvasItem, c: Vector2) -> void:
	for i in 2:
		var o := Vector2(-2.6, -2.6) if i == 0 else Vector2(2.6, 2.6)
		ci.draw_arc(c + o, 3.6, 0.0, TAU, 14, EloLink.METAL_DARK, 3.4, true)
		ci.draw_arc(c + o, 3.6, 0.0, TAU, 14, EloLink.METAL_LIT, 1.6, true)


## The heroic corners: a diamond on each corner of the outer edge and a short spur of old gold along both sides.
static func _draw_flourishes(ci: CanvasItem, r: Rect2, col: Color) -> void:
	var lit := col.lightened(0.2)
	var pts: Array[Vector2] = [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for k in 4:
		var c := pts[k]
		var sx := 1.0 if k == 0 or k == 3 else -1.0
		var sy := 1.0 if k < 2 else -1.0
		ci.draw_line(c + Vector2(sx * FLOURISH, sy * 3.0), c + Vector2(sx * (FLOURISH + SPUR), sy * 3.0), col, 2.0, true)
		ci.draw_line(c + Vector2(sx * 3.0, sy * FLOURISH), c + Vector2(sx * 3.0, sy * (FLOURISH + SPUR)), col, 2.0, true)
		_diamond(ci, c + Vector2(sx, sy) * 2.0, FLOURISH, Color(0.05, 0.04, 0.05))
		_diamond(ci, c + Vector2(sx, sy) * 2.0, FLOURISH - 1.5, lit)


## The exchange's tab: a plate on the top edge, rising above the card, with two chevrons and "Sobe uma raridade" in the
## new rarity's colour.
func _upgrade_tab() -> Control:
	var col := rarity_color(rarity).lightened(0.12)
	var tab := PanelContainer.new()
	tab.name = &"UpgradeTab"
	tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := UiKit.box(INK, rarity_color(rarity), int(EDGE_W), 0, 6)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 1
	sb.content_margin_bottom = 2
	tab.add_theme_stylebox_override(&"panel", sb)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 6)
	tab.add_child(row)
	var chev := Control.new()
	chev.custom_minimum_size = Vector2(12, 18)
	chev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chev.draw.connect(func() -> void:
		for i in 2:
			var y := 6.0 + i * 6.0
			chev.draw_polyline(PackedVector2Array([Vector2(1, y + 4), Vector2(6, y - 1), Vector2(11, y + 4)]), col, 2.0, true))
	row.add_child(chev)
	var l := UiKit.label(T.t(&"choice_upgrade"), col, 15, UiKit.BOLD_FONT)
	l.name = &"UpgradeLabel"
	row.add_child(l)
	tab.custom_minimum_size.y = TAB_H
	tab.anchor_left = 0.5
	tab.anchor_right = 0.5
	tab.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tab.offset_top = -TAB_RISE
	tab.offset_bottom = TAB_H - TAB_RISE
	return tab


func _add_glow(color: Color) -> void:
	if _glow == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.45, Color(1, 1, 1, 0.35))
		_glow = GradientTexture2D.new()
		_glow.gradient = g
		_glow.fill = GradientTexture2D.FILL_RADIAL
		_glow.fill_from = Vector2(0.5, 0.5)
		_glow.fill_to = Vector2(0.5, 0.0)
		_glow.width = 128
		_glow.height = 128
	var t := TextureRect.new()
	t.texture = _glow
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.modulate = Color(color.r, color.g, color.b, 0.42)
	t.anchor_right = 1.0
	t.offset_left = METAL_INSET + 2.0
	t.offset_right = -METAL_INSET - 2.0
	t.offset_top = -10.0
	t.offset_bottom = ART_H + 10.0
	add_child(t)


func _crest(b: Boon, from: Array[Boon]) -> Control:
	if b == null:
		var rest := Control.new()
		rest.custom_minimum_size = Vector2(DRAWN, DRAWN)
		rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rest.draw.connect(func() -> void: _draw_rest(rest))
		return rest
	var art := BoonArt.medallion(b.id)
	if not from.is_empty():
		if art:
			return EloLink.new().setup(b, from, PAINTED_ELO, SOURCE, SOURCE_GAP, art)
		return EloLink.new().setup(b, from, DRAWN_ELO, DRAWN_SOURCE, DRAWN_GAP)
	if art:
		return BoonArt.rect(art, PAINTED)
	return BoonIcon.new().setup(b, DRAWN)


## The rest card's medallion: the drawn medallion's rim around a heart.
func _draw_rest(ci: Control) -> void:
	var c := ci.size * 0.5
	var r := minf(ci.size.x, ci.size.y) * 0.46
	var col := Color(0.55, 0.85, 0.6)
	ci.draw_circle(c, r + 4.0, Color(0.85, 0.68, 0.36))
	ci.draw_circle(c, r, col.darkened(0.72))
	ci.draw_circle(c + Vector2(-r * 0.15, -r * 0.18), r * 0.8, col.darkened(0.5))
	BoonIcon.glyph(ci, 6, c, r * 0.6, Color(1.0, 0.98, 0.9), col.darkened(0.5))
	ci.draw_arc(c, r, 0.0, TAU, 48, Color(1.0, 0.9, 0.6, 0.8), 2.0, true)


func _name(text: String) -> Label:
	var l := UiKit.title(text, 25, IVORY)
	l.add_theme_constant_override(&"outline_size", 6)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _text(text: String, color: Color, size_: int, font: Font = null) -> Label:
	var l := UiKit.label(text, color, size_, font)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size.x = SIZE.x - PAD * 2.0
	return l


## Action (if any), level and rarity on one line, each in its own colour. An Elo shows only its action (it has
## neither level nor rarity); an exchange shows the level it keeps.
func _meta(b: Boon, level: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	var parts: Array[Label] = []
	if b.slot != Boon.Slot.NONE:
		parts.append(UiKit.label(T.t(Boon.SLOT_KEY[b.slot]), UiKit.DIM, 16, UiKit.BOLD_FONT))
	if not elo:
		var lv_text: String
		if upgrade:
			lv_text = T.t(&"choice_level", {"n": maxi(level, 1), "max": b.max_level})
		else:
			lv_text = T.t(&"choice_new") if level == 0 else T.t(&"choice_level", {"n": level + 1, "max": b.max_level})
		var lv := UiKit.label(lv_text, UiKit.GOLD, 16)
		lv.name = &"Level"
		parts.append(lv)
		var rar := UiKit.label(T.t(Boon.RARITY_KEY[rarity]), rarity_color(rarity).lightened(0.12), 16, UiKit.BOLD_FONT)
		rar.name = &"Rarity"
		parts.append(rar)
	for i in parts.size():
		if i > 0:
			row.add_child(UiKit.label("·", UiKit.DIM, 16))
		row.add_child(parts[i])
	return row


## A thin rule of old gold with a small diamond in the middle, between the heading and the description.
func _rule() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 14)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func() -> void:
		var y := c.size.y * 0.5
		var w := c.size.x
		var col := Color(UiKit.OLD_GOLD, 0.8)
		c.draw_line(Vector2(w * 0.14, y), Vector2(w * 0.44, y), col, 1.0)
		c.draw_line(Vector2(w * 0.56, y), Vector2(w * 0.86, y), col, 1.0)
		var m := Vector2(w * 0.5, y)
		c.draw_colored_polygon(PackedVector2Array([m + Vector2(0, -4), m + Vector2(5, 0), m + Vector2(0, 4), m + Vector2(-5, 0)]), EloLink.METAL_LIT))
	return c
