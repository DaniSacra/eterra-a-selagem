class_name BoonCard
extends Button
## One tall card of the gift screen (BoonChoice): the art at the top (a painted medallion by the gift's id, BoonArt, or
## the drawn BoonIcon; an Elo hangs between its two sources on a chain), then name, family or "Elo de A e B", the
## action, level and rarity on one line, a thin rule, the description on clean dark ground and, at the bottom, the gift
## it replaces. The frame is a thin line of old metal; its outer edge and glow take the rarity's colour (common keeps
## the metal), and the card in focus gains a pale inner line and lighter ink, so focus never hides the rarity (no
## scaling: a scaled card blurs its text).
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
## Common cards keep the metal on the edge (the game's common colour is a plain white).
const COMMON_EDGE := Color("b39565")
const INK := Color(0.045, 0.035, 0.06, 0.97)
const INK_LIT := Color(0.085, 0.065, 0.09, 0.98)
const IVORY := Color(0.97, 0.93, 0.84)
const WARN := Color(1.0, 0.62, 0.5)

var boon: Boon
var rarity: Boon.Rarity = Boon.Rarity.COMMON
## The control that shows the gift at the top: a TextureRect (painted), a BoonIcon or an EloLink.
var crest: Control

static var _glow: GradientTexture2D


## level: the gift's level now (0 = new); replaces: the gift it would replace, or null.
func setup(b: Boon, rarity_: Boon.Rarity, level: int, from: Array[Boon], replaces: Boon, text: String) -> BoonCard:
	boon = b
	rarity = rarity_
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
		box.add_child(_meta(b, level))
		box.add_child(_rule())
		var desc := _text(text, UiKit.PALE, 18)
		desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(desc)
		if replaces != null:
			var warn := _text(T.t(&"choice_replaces", {"name": T.t("boon_" + String(replaces.id))}), WARN, 16, UiKit.BOLD_FONT)
			warn.name = &"Replaces"
			box.add_child(warn)
	var frame := Control.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.draw.connect(_draw_frame.bind(frame))
	add_child(frame)
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(_on_focus.bind(true, frame))
	focus_exited.connect(_on_focus.bind(false, frame))
	return self


## The colour of the outer edge: the rarity's, the old metal for common. Never changed by focus.
func edge_color() -> Color:
	return COMMON_EDGE if rarity == Boon.Rarity.COMMON else Boon.RARITY_COLOR[rarity]


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
	if rarity != Boon.Rarity.COMMON:
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
	var metal := r.grow(-METAL_INSET)
	frame.draw_rect(metal, Color(UiKit.OLD_GOLD, 0.75), false, 1.0)
	# small diamonds on the metal line's corners, as rivets
	for c in [metal.position, Vector2(metal.end.x, metal.position.y), metal.end, Vector2(metal.position.x, metal.end.y)]:
		var d := 3.5
		frame.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), EloLink.METAL_LIT)
	if has_focus():
		var f := r.grow(-FOCUS_INSET)
		var s := UiKit.box(Color(0, 0, 0, 0), FOCUS_COLOR, int(FOCUS_W), 0, 5)
		frame.draw_style_box(s, f)


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


## Action (if any), level and rarity on one line, each in its own colour.
func _meta(b: Boon, level: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	var parts: Array[Label] = []
	if b.slot != Boon.Slot.NONE:
		parts.append(UiKit.label(T.t(Boon.SLOT_KEY[b.slot]), UiKit.DIM, 16, UiKit.BOLD_FONT))
	parts.append(UiKit.label(T.t(&"choice_new") if level == 0 else T.t(&"choice_level", {"n": level + 1, "max": b.max_level}), UiKit.GOLD, 16))
	var rar := UiKit.label(T.t(Boon.RARITY_KEY[rarity]), Boon.RARITY_COLOR[rarity], 16, UiKit.BOLD_FONT)
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
