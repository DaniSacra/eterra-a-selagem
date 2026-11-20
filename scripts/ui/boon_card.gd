class_name BoonCard
extends Button
## One tall card of the gift screen (BoonChoice): the art at the top (a painted medallion by the gift's id, BoonArt, or
## the drawn BoonIcon; an Elo hangs between its two sources on a chain), then name, family or "Elo de A e B", the
## action, level and rarity on one line, a thin rule, the description on clean dark ground and, at the bottom, the gift
## it replaces. The frame is a thin line of old metal; its outer edge and glow take the rarity's colour (common keeps
## a quiet metal), and the card in focus gains a pale inner line and lighter ink, so focus never hides the rarity (no
## scaling: a scaled card blurs its text).
## E3-06: each rarity has its own frame, read before the colour: common one quiet line, rare one line with coloured
## rivets, epic a double line, legendary a double line of old gold with corner flourishes (never bright yellow). An Elo
## has no rarity and no level (BUG-017): its frame is the chain's metal with links on the corners and its card shows
## neither. An exchange (upgrade: the card replaces the Blessing on the same action one rarity up) wears a tab on top,
## "Sobe uma raridade", and says at the bottom what it trades and from which rarity to which.
## boon null: the rest card ("Fôlego").
## E4-03, a Psalm (setup_psalm): no rarity, no level, no number. Its frame is its own: an ivory edge with the corners
## cut (an octagon, no other card has one), old gold inside, a pointed arch of old gold over the medallion and the
## Psalm's colour in the glow; a tab on top says "Salmo" (or "Salmo descoberto" the first time ever). The card says
## the action it transforms and, at the bottom, the three held things that opened it.
## E5, the Provação's card (setup_trial, docs/art/e5_spec.md 5.3): the body split in two. On top the blessing to be won
## (its name in ivory, "Provação" and its rarity on one line, the rarity on the edge as any card), under it the curse on
## a band of dark lilac ink with its words in pale lilac and how many fights it lasts. T5 (A-T5-5): the crest is the
## blessing's own medallion (BoonIcon, TrialSeal.blessing_look), so the three cards differ at a glance, with the cracked
## diamond (TrialSeal) small on its lower right as a stamp; the curse's band sits right under the blessing's words.
## The altar's card (setup_altar, smaller): what the trade gives and what it asks, a medallion in the house's seal
## (SealMedal, A-T5-6: a pomegranate, a candle's flame, an open arch) and, when it cannot be taken now, dimmed with
## why; "Seguir em frente" takes nothing.
## Stage 1A of the art pack (2026-11-17, docs/gallery/artpack/stage1a/): an exchange names what goes out and what comes
## in, in that order, each with its glyph, name and rarity ("Sai", "Entra"); the altar's crests are the painted
## pomegranate, candles and open passage (BoonArt.event; the drawn SealMedal stays as their small glyph), what is given
## and got carries the reward's mark (DoorGlyph: heart, coin, pomegranate, gem) and walking on says "Sem custo"; the
## Provação's crest is the blessing's medallion alone and the curse's band carries the painted cracked seal.

## Card size at 720 lines (the screen scales with the window: canvas_items stretch). A Blessing's and a Psalm's card
## take the height of what they say (fit_height, UI-HB1: the bottom third of the tall cards was empty), never past
## SIZE.y nor under MIN_H; the cards of a row stand as tall as the tallest (the row's container).
const SIZE := Vector2(300, 450)
const MIN_H := 300.0
const PAD := 18.0
## Height of the art band at the top.
const ART_H := 140.0
## Medallions: painted Elo, painted single gift, drawn single gift; the drawn Elo (EloLink) and the sources.
const PAINTED_ELO := 120.0
const PAINTED := 128.0
const DRAWN := 100.0
const DRAWN_ELO := 80.0
## The description (UI-HB2): its body in a quieter ivory, the numbers and the words of rule in full ivory and bold
## (UiKit.strong, Glossary.emphasize; never a reserved colour), left aligned, and its size.
const BODY := Color(0.8, 0.76, 0.69)
const BODY_SIZE := 17
## The card's facts (UI-HB1, benchmark P1-1): one row per number, its label small and quiet on the left, its value in
## bold ivory on the right ("Congela por" / "0,4 s"); on a trade, the value of what goes out before it, dimmed.
const FACT_LABEL := 14
const FACT_VALUE := 18
const FACT_MAX := 3
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
## The focus brackets' arms (px at 720 lines) and the ivory glow behind a card in focus.
const FOCUS_ARM := 30.0
const FOCUS_GLOW := Color(1.0, 0.95, 0.84, 0.22)
## The card's colour of each rarity is Boon.RARITY_COLOR (rare blue, epic violet, legendary old gold), but common is a
## quiet metal here (the game's common colour is a plain white). The rarity's word on the card takes the same colour.
const COMMON_EDGE := Color("8f7f63")
## Lines of the outer edge per rarity (epic and legendary are doubled) and the gap between the two.
const RARITY_LINES: Array[int] = [1, 1, 2, 2]
const DOUBLE_GAP := 3.0
## Legendary corner flourish: a diamond on the corner and a short spur along each side.
const FLOURISH := 6.0
const SPUR := 22.0
## An Elo's edge: one line of the chain's darker metal (legendary is the lit old gold, doubled), links on the corners.
const ELO_EDGE := EloLink.METAL
## The exchange's tab on the top edge: its height and how far it rises above the card.
const TAB_H := 24.0
const TAB_RISE := 12.0
const INK := Color(0.045, 0.035, 0.06, 0.97)
const INK_LIT := Color(0.085, 0.065, 0.09, 0.98)
const IVORY := Color(0.97, 0.93, 0.84)
const WARN := Color(1.0, 0.62, 0.5)
## A Psalm's frame: its ivory edge, the cut of its corners and the arch over the medallion (inset from the sides).
const PSALM_EDGE := Color(0.9, 0.85, 0.74)
const PSALM_CUT := 14.0
const PSALM_ARCH_INSET := 34.0
const PSALM_ICON := 112.0
## The Provação's card: the crest, the curse's band (spec 5.3: ink (0.16; 0.12; 0.22), words (0.82; 0.76; 0.92)).
## T5: a shorter art band and card than a Blessing's, so the screen's lead line and the card's own heads fit at 720.
const TRIAL_ICON := 100.0
## The room between the blessing's words and the curse's band (A-T5-5: at most 40 px at 1080).
const TRIAL_BAND_GAP := 8.0
const TRIAL_SIZE := Vector2(320, 384)
const TRIAL_ART_H := 118.0
const TRIAL_BAND := TrialSeal.INK
const TRIAL_WORDS := TrialSeal.PALE
## The heads of the events' sections ("Você entrega", "Você recebe"), their size and the room over each.
const DEAL_HEAD := Color(0.78, 0.66, 0.44)
const HEAD_SIZE := 13
const DEAL_GAP := 22.0
## The altar's cards: smaller than a Blessing's, a shorter art band, the altar's warm ivory (Rooms.ALTAR_COLOR) in the
## glow (T5: taller than at E5, for what is given and what is got).
const ALTAR_SIZE := Vector2(290, 392)
const ALTAR_ART_H := 112.0
const ALTAR_ICON := 104.0
## The reward's mark beside what an altar's trade gives and gets (DoorGlyph), and its gap.
const DEAL_MARK := 19.0
## The curse band's painted cracked seal (BoonArt.event "trial_seal") and the room beside it.
const CURSE_SEAL := 36.0
const CURSE_SEAL_GAP := 8.0
## An exchange's rows ("Sai", "Entra"): the glyphs' size and the words'.
const SWAP_ICON := 26.0
const SWAP_SIZE := 15
## The action's mark beside its name (ActionSlot.mark, the HUD's symbol).
const ACTION_MARK := 20.0
const ALTAR_GLOW := Color(0.95, 0.85, 0.65)
## The altar's medallion of each trade: its colour, its drawn glyph (SealMedal, when the painting is missing) and its
## painting (BoonArt.event). Life buys a pomegranate (never a heart: the trade takes life), gold lights the candles,
## walking on is the open passage.
const ALTAR_LOOK := {&"life": [Color(0.78, 0.26, 0.32), SealMedal.Glyph.POMEGRANATE, &"pomegranate"],
	&"candles": [Color(0.98, 0.78, 0.45), SealMedal.Glyph.CANDLE, &"candles"],
	&"none": [Color(0.62, 0.6, 0.66), SealMedal.Glyph.OPEN_ARCH, &"passage"]}
## What an altar's trade gives and gets, as reward marks (DoorGlyph.Kind): give, get.
const ALTAR_MARKS := {&"life": [DoorGlyph.Kind.HEART, DoorGlyph.Kind.POMEGRANATE], &"candles": [DoorGlyph.Kind.GOLD, DoorGlyph.Kind.MAGICK]}

var boon: Boon
var rarity: Boon.Rarity = Boon.Rarity.COMMON
## An Elo: no rarity, no level, the chain's frame.
var elo := false
## An exchange one rarity up (E3-01): the tab on top and the trade at the bottom.
var upgrade := false
## A Psalm's card (E4-03): boon is null.
var psalm: PsalmDef
## The Provação's card shown (E5; boon is null), and the altar's trade (E5: &"life", &"candles", &"none"; &"" otherwise).
var trial: Trials.Card
var altar := &""
## The control that shows the gift at the top: a TextureRect (painted), a BoonIcon or an EloLink.
var crest: Control
## The description as plain words (no markup): the glossary reads its terms from it (Glossary.show_for).
var plain := ""
var _box: VBoxContainer
var _fits := 0

static var _glow: GradientTexture2D


## level: the gift's level now (0 = new; an exchange: the level it keeps); replaces: the gift it would replace, or null.
## upgrade: the card is an exchange one rarity up; replaced_rarity: the rarity of the gift it replaces.
## replaced_level: the level of the gift it replaces (its numbers stand before the card's, dimmed, on a trade).
func setup(b: Boon, rarity_: Boon.Rarity, level: int, from: Array[Boon], replaces: Boon, text: String,
		upgrade_: bool = false, replaced_rarity: Boon.Rarity = Boon.Rarity.COMMON, replaced_level := 0) -> BoonCard:
	boon = b
	elo = b != null and (b.is_duo() or not from.is_empty())
	upgrade = upgrade_ and b != null and not elo
	rarity = Boon.Rarity.COMMON if elo else rarity_
	var box := _shell(b.color() if b else Color(0.55, 0.85, 0.6))
	var art := _art(box)
	crest = _crest(b, from)
	art.add_child(crest)
	if b == null:
		box.add_child(_name(T.t(&"boon_rest")))
		box.add_child(_rule())
		box.add_child(_rich(text))
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
		box.add_child(_rich(text))
		# the facts at the level shown: the next one (new or grown), or the one a trade keeps
		var lv := maxi(level, 1) if upgrade else level + 1
		var before: Array = []
		if replaces != null and replaced_level > 0:
			before = BoonChoice.facts(replaces, replaced_level, Boon.RARITY_MULT[replaced_rarity])
		var facts := _facts(BoonChoice.facts(b, lv, Boon.RARITY_MULT[rarity] if not elo else 1.0), before)
		if facts != null:
			box.add_child(facts)
		# what is left of the height goes over the trade, so it always stands at the bottom
		box.add_child(_fill())
		if replaces != null:
			# what goes out and what comes in, in that order (UI-HB1: a trade said plainly, also on a plain replace)
			box.add_child(_swap(replaces, replaced_rarity, b, rarity))
	_finish(true)
	if upgrade:
		add_child(_upgrade_tab())
	return self


## The start every card shares: its size, no theme boxes (the card draws itself), the glow of its colour behind the
## art and the column its parts go in.
func _shell(glow: Color, size_px: Vector2 = SIZE, art_h: float = ART_H) -> VBoxContainer:
	custom_minimum_size = size_px
	focus_mode = Control.FOCUS_ALL
	var empty := StyleBoxEmpty.new()
	for st in [&"normal", &"hover", &"pressed", &"focus", &"disabled", &"hover_pressed"]:
		add_theme_stylebox_override(st, empty)
	_add_glow(glow, art_h)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = PAD
	box.offset_right = -PAD
	box.offset_top = PAD * 0.5
	box.offset_bottom = -PAD
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override(&"separation", 5)
	add_child(box)
	_box = box
	return box


## The band at the top of the column the crest stands in.
func _art(box: VBoxContainer, art_h: float = ART_H) -> CenterContainer:
	var art := CenterContainer.new()
	art.custom_minimum_size.y = art_h
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(art)
	return art


## The end every card shares: the frame drawn over its parts, and focus that follows the mouse. fit: the card takes
## the height of what it says (fit_height, once laid out).
func _finish(fit := false) -> void:
	if fit:
		custom_minimum_size.y = MIN_H
		_fits = 2
		_fit_later.call_deferred()
	var frame := Control.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.draw.connect(_draw_frame.bind(frame))
	add_child(frame)
	mouse_entered.connect(func() -> void:
		if not has_focus() and focus_mode != Control.FOCUS_NONE:
			grab_focus())
	focus_entered.connect(_on_focus.bind(true, frame))
	focus_exited.connect(_on_focus.bind(false, frame))


func _fit_later() -> void:
	if not is_inside_tree():
		return
	fit_height()
	_fits -= 1
	if _fits > 0:
		# the text wraps to the width it got: once more after the row has laid the card out
		_fit_later.call_deferred()


## The height of what the card says, from its top to its last line, between MIN_H and SIZE.y.
func fit_height() -> void:
	if _box == null:
		return
	var need := _box.get_combined_minimum_size().y + _box.offset_top - _box.offset_bottom
	custom_minimum_size.y = clampf(ceilf(need), MIN_H, SIZE.y)


## The colour of the outer edge: the rarity's (rarity_color), the chain's metal for an Elo. Never changed by focus.
func edge_color() -> Color:
	if psalm != null:
		return PSALM_EDGE
	return ELO_EDGE if elo else rarity_color(rarity)


## How many lines the outer edge has (an Elo: one, its corners carry the links).
func edge_lines() -> int:
	if psalm != null:
		return 2
	return 1 if elo else RARITY_LINES[rarity]


## The card's colour of a rarity.
static func rarity_color(r: Boon.Rarity) -> Color:
	return COMMON_EDGE if r <= Boon.Rarity.COMMON else Boon.RARITY_COLOR[mini(r, Boon.RARITY_COLOR.size() - 1)]


## The focus of a card (UI review d2ff05d, P2-10): ivory corner brackets inside the metal line, never a whole line
## round the card (a whole ivory line inside the edge read as a second frame line, a Common in focus like a Legendary),
## with the ink lit and a soft ivory glow behind (_draw). Also the angels' cards (EncounterScreen).
static func draw_focus(ci: CanvasItem, r: Rect2) -> void:
	var f := r.grow(-FOCUS_INSET)
	var arm := minf(FOCUS_ARM, minf(f.size.x, f.size.y) * 0.25)
	var corners: Array[Vector2] = [f.position, Vector2(f.end.x, f.position.y), f.end, Vector2(f.position.x, f.end.y)]
	var dirs: Array[Vector2] = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	for i in 4:
		var c := corners[i]
		ci.draw_polyline(PackedVector2Array([c + Vector2(dirs[i].x * arm, 0), c, c + Vector2(0, dirs[i].y * arm)]), FOCUS_COLOR, FOCUS_W + 1.0, true)


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
	if psalm != null:
		# the cut corners: the ink fills the octagon, the Psalm's colour glows out of its edge
		var glow := PsalmIcon.tint(psalm)
		for k in 3:
			draw_polyline(_octagon(r.grow(2.0 + k * 3.0), PSALM_CUT + k * 2.0), Color(glow, 0.16 - k * 0.045), 4.0, true)
		draw_colored_polygon(_octagon(r, PSALM_CUT), INK_LIT if has_focus() else INK)
		return
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
	if has_focus():
		# the rarity's own glow stays (it says the rarity); a Common, which has none, glows ivory
		if rarity == Boon.Rarity.COMMON and not elo:
			bg.shadow_color = FOCUS_GLOW
		bg.shadow_size += 4
	draw_style_box(bg, r)


func _draw_frame(frame: Control) -> void:
	var r := Rect2(Vector2.ZERO, frame.size)
	if psalm != null:
		_draw_psalm_frame(frame, r)
		return
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
		if rarity == Boon.Rarity.LEGENDARY:
			_draw_flourishes(frame, r.grow(-EDGE_W * 0.5), edge)
	if has_focus():
		draw_focus(frame, r)


## A Psalm's frame: an ivory octagon doubled by a thinner one, the old gold line inside with diamonds on its cut
## corners, a pointed arch of old gold over the medallion, and the focus line (an octagon too).
func _draw_psalm_frame(frame: Control, r: Rect2) -> void:
	frame.draw_polyline(_octagon(r.grow(-EDGE_W * 0.5), PSALM_CUT), PSALM_EDGE, EDGE_W, true)
	frame.draw_polyline(_octagon(r.grow(-EDGE_W - DOUBLE_GAP), PSALM_CUT - 2.0), Color(PSALM_EDGE, 0.55), 1.0, true)
	var metal := r.grow(-METAL_INSET - DOUBLE_GAP - 1.0)
	var line := _octagon(metal, PSALM_CUT - 3.0)
	frame.draw_polyline(line, Color(UiKit.OLD_GOLD, 0.8), 1.0, true)
	for i in range(1, 8, 2):
		_diamond(frame, line[i].lerp(line[i + 1], 0.5), 3.0, PsalmIcon.tint(psalm))
	var a := PsalmIcon.arch(Vector2(r.size.x * 0.5, PAD * 0.5 + ART_H * 0.5 + 6.0), r.size.x * 0.5 - PSALM_ARCH_INSET, ART_H - 4.0)
	frame.draw_polyline(a, Color(UiKit.OLD_GOLD, 0.7), 1.5, true)
	if has_focus():
		frame.draw_polyline(_octagon(r.grow(-FOCUS_INSET - 2.0), PSALM_CUT - 5.0), FOCUS_COLOR, FOCUS_W, true)


## A rectangle with its four corners cut by cut pixels, closed (9 points, the last the first).
static func _octagon(r: Rect2, cut: float) -> PackedVector2Array:
	var p := r.position
	var e := r.end
	return PackedVector2Array([Vector2(p.x + cut, p.y), Vector2(e.x - cut, p.y), Vector2(e.x, p.y + cut), Vector2(e.x, e.y - cut),
		Vector2(e.x - cut, e.y), Vector2(p.x + cut, e.y), Vector2(p.x, e.y - cut), Vector2(p.x, p.y + cut), Vector2(p.x + cut, p.y)])


static func _diamond(ci: CanvasItem, c: Vector2, d: float, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), col)


## Two small interlocked links on a corner of an Elo's card.
static func _draw_link(ci: CanvasItem, c: Vector2) -> void:
	for i in 2:
		var o := Vector2(-2.6, -2.6) if i == 0 else Vector2(2.6, 2.6)
		ci.draw_arc(c + o, 3.6, 0.0, TAU, 14, EloLink.METAL_DARK, 3.4, true)
		ci.draw_arc(c + o, 3.6, 0.0, TAU, 14, EloLink.METAL_LIT, 1.6, true)


## The legendary corners: a diamond on each corner of the outer edge and a short spur of old gold along both sides.
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
	var chev := Control.new()
	chev.custom_minimum_size = Vector2(12, 18)
	chev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chev.draw.connect(func() -> void:
		for i in 2:
			var y := 6.0 + i * 6.0
			chev.draw_polyline(PackedVector2Array([Vector2(1, y + 4), Vector2(6, y - 1), Vector2(11, y + 4)]), col, 2.0, true))
	var tab := _tab(T.t(&"choice_upgrade"), col, rarity_color(rarity), chev)
	tab.name = &"UpgradeTab"
	(tab.get_child(0) as HBoxContainer).get_child(1).name = &"UpgradeLabel"
	return tab


## A plate on the top edge, rising above the card: an optional mark, then the text in col, framed in edge.
func _tab(text: String, col: Color, edge: Color, mark: Control = null) -> PanelContainer:
	var tab := PanelContainer.new()
	tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := UiKit.box(INK, edge, int(EDGE_W), 0, 6)
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
	if mark != null:
		row.add_child(mark)
	row.add_child(UiKit.label(text, col, 15, UiKit.BOLD_FONT))
	tab.custom_minimum_size.y = TAB_H
	tab.anchor_left = 0.5
	tab.anchor_right = 0.5
	tab.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tab.offset_top = -TAB_RISE
	tab.offset_bottom = TAB_H - TAB_RISE
	return tab


## An exchange's trade, in the order it happens: "Sai" with the glyph, name and rarity of the Blessing that goes, then
## "Entra" with those of the one that comes (named Replaces; rows TradeOut and TradeIn, their names OutName, InName).
func _swap(out_b: Boon, out_r: Boon.Rarity, in_b: Boon, in_r: Boon.Rarity) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.name = &"Replaces"
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override(&"separation", 2)
	col.add_child(_swap_row(&"Out", T.t(&"choice_trade_out"), out_b, out_r))
	col.add_child(_swap_row(&"In", T.t(&"choice_trade_in"), in_b, in_r))
	return col


func _swap_row(id: StringName, head: String, b: Boon, r: Boon.Rarity) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = StringName("Trade" + String(id))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 6)
	var h := UiKit.label(head.to_upper(), DEAL_HEAD, HEAD_SIZE, UiKit.BOLD_FONT)
	h.custom_minimum_size.x = 42.0
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(h)
	var icon := BoonIcon.new().setup(b, SWAP_ICON)
	icon.name = StringName(String(id) + "Icon")
	row.add_child(icon)
	var n := UiKit.label(T.t("boon_" + String(b.id)), UiKit.PALE if id == &"In" else UiKit.DIM, SWAP_SIZE, UiKit.BOLD_FONT)
	n.name = StringName(String(id) + "Name")
	row.add_child(n)
	row.add_child(UiKit.label("·", UiKit.DIM, SWAP_SIZE))
	var rar := UiKit.label(T.t(Boon.RARITY_KEY[r]), rarity_color(r).lightened(0.12), SWAP_SIZE, UiKit.BOLD_FONT)
	rar.name = StringName(String(id) + "Rarity")
	row.add_child(rar)
	return row


## A Psalm's card (E4-03): the tab ("Salmo", or "Salmo descoberto" the first time ever), the medallion under the arch,
## the name, the action it transforms, the description with its numbers and the three held things that opened it
## (names: one per group, in order; Psalms.matching). No rarity, no level, never a number of its own.
func setup_psalm(p: PsalmDef, opened_by: PackedStringArray, first: bool = false) -> BoonCard:
	psalm = p
	var col := PsalmIcon.tint(p)
	var box := _shell(p.color)
	var art := _art(box)
	crest = PsalmIcon.new().setup(p, PSALM_ICON)
	art.add_child(crest)
	var title := _name(T.t(p.name_key))
	title.name = &"Name"
	box.add_child(title)
	var does := UiKit.label(T.t(&"psalm_transforms", {"action": T.t(Boon.SLOT_KEY[p.slot])}), col, 17, UiKit.BOLD_FONT)
	does.name = &"Transforms"
	var line := HBoxContainer.new()
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override(&"separation", 7)
	line.add_child(ActionSlot.mark(p.slot, ACTION_MARK + 2.0))
	line.add_child(does)
	box.add_child(line)
	box.add_child(_rule())
	var args := p.text_args()
	for k: String in args:
		args[k] = UiKit.strong(str(args[k]))
	var desc := _rich(T.t(p.desc_key, args))
	desc.name = &"Desc"
	box.add_child(desc)
	box.add_child(_fill())
	if not opened_by.is_empty():
		var by := _text(T.t(&"psalm_opened_by", {"list": " · ".join(opened_by)}), EloLink.METAL_LIT, 15, UiKit.BOLD_FONT)
		by.name = &"OpenedBy"
		box.add_child(by)
	_finish(true)
	var mark := Control.new()
	mark.custom_minimum_size = Vector2(10, 18)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.draw.connect(func() -> void: mark.draw_colored_polygon(PsalmIcon.arch(Vector2(5, 10), 4.5, 13.0), col))
	var tab := _tab(T.t(&"psalm_discovered" if first else &"psalm_card"), IVORY, PSALM_EDGE, mark)
	tab.name = &"PsalmTab"
	add_child(tab)
	return self


## The Provação's card (E5, spec 5.3): the blessing on top, the curse on a band of dark lilac below it with its length.
## T5 (the PO did not understand it): each half says when it comes. On top "Você recebe depois de N lutas", the
## blessing's number and that it stays to the end of the descent; on the band "Você carrega nas próximas N lutas", the
## curse's name and its number. The blessing is not given now: Rooms._fight_won grants it when the curse turns.
func setup_trial(c: Trials.Card) -> BoonCard:
	trial = c
	rarity = clampi(c.rarity, Boon.Rarity.COMMON, Boon.Rarity.LEGENDARY) as Boon.Rarity
	var look := TrialSeal.blessing_look(c.blessing)
	var box := _shell(look[1], TRIAL_SIZE, TRIAL_ART_H)
	crest = _trial_crest(look)
	_art(box, TRIAL_ART_H).add_child(crest)
	var title := _name(T.t(c.blessing.name_key))
	title.name = &"Name"
	box.add_child(title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	row.add_child(UiKit.label(T.t(&"trial_blessing_word"), TrialSeal.PALE, 16, UiKit.BOLD_FONT))
	row.add_child(UiKit.label("·", UiKit.DIM, 16))
	var rar := UiKit.label(T.t(Boon.RARITY_KEY[rarity]), rarity_color(rarity).lightened(0.12), 16, UiKit.BOLD_FONT)
	rar.name = &"Rarity"
	row.add_child(rar)
	box.add_child(row)
	box.add_child(_rule())
	var when := _head(T.t(&"trial_gain_when", {"n": c.encounters}), DEAL_HEAD)
	when.name = &"GainWhen"
	box.add_child(when)
	var gain := _text(TrialSeal.blessing_text(c), UiKit.PALE, 18, UiKit.BOLD_FONT)
	gain.name = &"Blessing"
	box.add_child(gain)
	var keep := _text(T.t(&"trial_gain_keep"), UiKit.DIM, 15)
	keep.name = &"Keep"
	box.add_child(keep)
	var gap := Control.new()
	gap.custom_minimum_size.y = TRIAL_BAND_GAP
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(gap)
	var band := PanelContainer.new()
	band.name = &"CurseBand"
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_theme_stylebox_override(&"panel", UiKit.box(Color(TRIAL_BAND, 0.96), Color(TrialSeal.LILAC, 0.55), 1, 8, 4))
	var side := HBoxContainer.new()
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side.add_theme_constant_override(&"separation", int(CURSE_SEAL_GAP))
	band.add_child(side)
	side.add_child(_curse_seal())
	var inner := VBoxContainer.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_theme_constant_override(&"separation", 1)
	side.add_child(inner)
	var width := TRIAL_SIZE.x - PAD * 2.0 - 18.0 - CURSE_SEAL - CURSE_SEAL_GAP
	var lasts := _head(T.t(&"trial_card_for", {"n": c.encounters}), TrialSeal.LILAC.lightened(0.25))
	lasts.name = &"Encounters"
	var curse := _text(T.t(c.curse.name_key), TRIAL_WORDS.lightened(0.2), 16, UiKit.BOLD_FONT)
	curse.name = &"CurseName"
	var does := _text(TrialSeal.curse_text(c), TRIAL_WORDS, 16)
	does.name = &"Curse"
	for l: Label in [lasts, curse, does]:
		l.custom_minimum_size.x = width
		inner.add_child(l)
	box.add_child(band)
	# what is left of the card's height goes under the band, never between the two halves
	var rest := Control.new()
	rest.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(rest)
	_finish()
	return self


## The Provação card's crest: the blessing's own medallion (look: [glyph, colour]); the cracked seal is the curse's,
## on its band (stage 1A: the prancha's "selo rachado para a maldição").
func _trial_crest(look: Array) -> Control:
	var holder := CenterContainer.new()
	holder.name = &"TrialCrest"
	holder.custom_minimum_size = Vector2(TRIAL_ICON, TRIAL_ICON)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var medal := BoonIcon.new().setup_glyph(int(look[0]), look[1], TRIAL_ICON)
	medal.name = &"Medal"
	holder.add_child(medal)
	return holder


## The curse's mark on its band: the painted cracked seal (BoonArt.event), or the drawn diamond without it.
func _curse_seal() -> Control:
	var tex := BoonArt.event(&"trial_seal")
	var seal: Control = BoonArt.rect(tex, CURSE_SEAL) if tex != null else TrialSeal.new().setup(CURSE_SEAL * 0.8)
	seal.name = &"CurseSeal"
	seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return seal


## One of the altar's trades (E5, Altar.options: {option, id, cost, gain, ok, why, give_from...}), or {id: &"none"} to
## take nothing. T5: each card reads "Você entrega" and "Você recebe" with the numbers and what they become (life,
## gold, Magia from now to after), so the cost shows before anything is pressed; "Seguir em frente" gives and gets
## nothing. A trade that cannot be taken now is dimmed, cannot be focused or pressed and says why (Altar.options' why).
func setup_altar(o: Dictionary) -> BoonCard:
	altar = StringName(o.get("id", &"none"))
	var look: Array = ALTAR_LOOK.get(altar, ALTAR_LOOK[&"none"])
	var box := _shell(ALTAR_GLOW, ALTAR_SIZE, ALTAR_ART_H)
	var painted := BoonArt.event(look[2])
	var medal: Control = BoonArt.rect(painted, ALTAR_ICON) if painted != null else SealMedal.new().setup(look[1], look[0], ALTAR_ICON)
	medal.name = &"Medal"
	crest = medal
	_art(box, ALTAR_ART_H).add_child(medal)
	var title := _name(T.t(StringName("altar_" + String(altar))))
	title.name = &"Name"
	box.add_child(title)
	box.add_child(_rule())
	var ok := bool(o.get("ok", true))
	if altar == &"none":
		# walking on: no cost, no gain (the prancha's "Sem custo"), and where to go
		box.add_child(_free_tag())
		var where := _text(T.t(&"altar_none_desc"), UiKit.DIM, 15)
		where.name = &"Where"
		where.custom_minimum_size.x = ALTAR_SIZE.x - PAD * 2.0
		where.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(where)
		_finish()
		return self
	var marks: Array = ALTAR_MARKS[altar]
	var n := {"n": num(float(o.get("cost", 0)))}
	var give := ""
	var give_detail := ""
	var got := ""
	var got_detail := ""
	match altar:
		&"life":
			give = T.t(&"altar_life_give", n)
			give_detail = T.t(&"altar_life_give_detail", _from_to(o, "give"))
			got = T.t(&"altar_life_get")
			got_detail = T.t(&"altar_life_get_detail")
		&"candles":
			give = T.t(&"altar_candles_give", n)
			give_detail = T.t(&"altar_candles_give_detail", _from_to(o, "give")) if ok else ""
			got = T.t(&"altar_candles_get", {"n": num(float(o.get("gain", 0)))})
			got_detail = T.t(&"altar_candles_get_detail", _from_to(o, "get")) if float(o.get("get_from", 0.0)) > 0.0 else ""
	_deal(box, &"Give", T.t(&"altar_give"), give, give_detail, marks[0])
	var last := _deal(box, &"Get", T.t(&"altar_get"), got, got_detail, marks[1])
	last.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if not ok:
		var why_key := StringName(o.get("why", &""))
		var why := _text(T.t(why_key if why_key != &"" else &"altar_cannot", {"n": int(o.get("short", 0))}), WARN, 15, UiKit.BOLD_FONT)
		why.name = &"Cannot"
		why.custom_minimum_size.x = ALTAR_SIZE.x - PAD * 2.0
		box.add_child(why)
		disabled = true
		focus_mode = Control.FOCUS_NONE
		# dimmed, never see-through (the signs of the room would show through it)
		modulate = Color(0.58, 0.56, 0.6)
	_finish()
	return self


func _add_glow(color: Color, art_h: float = ART_H) -> void:
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
	t.offset_bottom = art_h + 10.0
	add_child(t)


func _crest(b: Boon, from: Array[Boon]) -> Control:
	if b == null:
		var rest := Control.new()
		rest.custom_minimum_size = Vector2(DRAWN, DRAWN)
		rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rest.draw.connect(func() -> void: _draw_medallion(rest, Color(0.55, 0.85, 0.6), 6))
		return rest
	var art := BoonArt.medallion(b.id)
	if not from.is_empty():
		if art:
			return EloLink.new().setup(b, from, PAINTED_ELO, SOURCE, SOURCE_GAP, art)
		return EloLink.new().setup(b, from, DRAWN_ELO, DRAWN_SOURCE, DRAWN_GAP)
	if art:
		return BoonArt.rect(art, PAINTED)
	return BoonIcon.new().setup(b, DRAWN)


## A drawn medallion (the rest card's heart): the rim around a glyph of BoonIcon (-1: a small
## empty diamond).
static func _draw_medallion(ci: Control, col: Color, glyph: int) -> void:
	var c := ci.size * 0.5
	var r := minf(ci.size.x, ci.size.y) * 0.46
	ci.draw_circle(c, r + 4.0, Color(0.85, 0.68, 0.36))
	ci.draw_circle(c, r, col.darkened(0.72))
	ci.draw_circle(c + Vector2(-r * 0.15, -r * 0.18), r * 0.8, col.darkened(0.5))
	if glyph >= 0:
		BoonIcon.glyph(ci, glyph, c, r * 0.6, Color(1.0, 0.98, 0.9), col.darkened(0.5))
	else:
		_diamond(ci, c, r * 0.28, Color(col.lightened(0.3), 0.8))
	ci.draw_arc(c, r, 0.0, TAU, 48, Color(1.0, 0.9, 0.6, 0.8), 2.0, true)


func _name(text: String) -> Label:
	var l := UiKit.title(text, 25, IVORY)
	l.add_theme_constant_override(&"outline_size", 6)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## A section's head on the events' cards ("Você entrega", "Você recebe depois de 5 lutas"): small bold capitals.
func _head(text: String, color: Color) -> Label:
	return _text(text.to_upper(), color, HEAD_SIZE, UiKit.BOLD_FONT)


## One half of an altar's trade: the head, what (bold, after the reward's mark) and, under it, the detail (dim; empty:
## none). Returns the last control added (the caller may let it fill the card).
func _deal(box: VBoxContainer, id: StringName, head: String, what: String, detail: String,
		mark: DoorGlyph.Kind = DoorGlyph.Kind.NONE) -> Control:
	var width := custom_minimum_size.x - PAD * 2.0
	var h := _head(head, DEAL_HEAD)
	h.name = StringName(String(id) + "Head")
	h.custom_minimum_size = Vector2(width, DEAL_GAP)
	h.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	box.add_child(h)
	var what_l := UiKit.label(what, UiKit.PALE, 17, UiKit.BOLD_FONT)
	what_l.name = id
	var row := HBoxContainer.new()
	row.name = StringName(String(id) + "Row")
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 6)
	if mark != DoorGlyph.Kind.NONE:
		var m := DoorGlyph.new().setup(mark, DEAL_MARK)
		m.name = StringName(String(id) + "Mark")
		row.add_child(m)
	row.add_child(what_l)
	box.add_child(row)
	var last: Control = row
	if detail != "":
		var d := _text(detail, UiKit.DIM, 15)
		d.name = StringName(String(id) + "Detail")
		d.custom_minimum_size.x = width
		box.add_child(d)
		last = d
	return last


## The plate "Sem custo" of walking on (a plate of ink with an old gold line and two short rules, as the prancha).
func _free_tag() -> Control:
	var holder := CenterContainer.new()
	holder.name = &"FreeTag"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.custom_minimum_size.y = 58.0
	var tag := PanelContainer.new()
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := UiKit.box(INK, UiKit.OLD_GOLD, 1, 0, 6)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 3
	sb.content_margin_bottom = 4
	tag.add_theme_stylebox_override(&"panel", sb)
	var l := UiKit.label(T.t(&"altar_free").to_upper(), IVORY, 15, UiKit.BOLD_FONT)
	l.name = &"Free"
	tag.add_child(l)
	holder.add_child(tag)
	return holder


## A number of the altar as the player reads it: life, gold and Magia are whole, as on the HUD (BUG-113).
static func num(v: float) -> String:
	return UiKit.whole(v)


## {from, to} of an altar's option for "give" or "get" (Altar.options: give_from, give_to, get_from, get_to).
static func _from_to(o: Dictionary, which: String) -> Dictionary:
	return {"from": num(float(o.get(which + "_from", 0.0))), "to": num(float(o.get(which + "_to", 0.0)))}


func _text(text: String, color: Color, size_: int, font: Font = null) -> Label:
	var l := UiKit.label(text, color, size_, font)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size.x = SIZE.x - PAD * 2.0
	return l


## The description (UI-HB2): bbcode with the numbers and the words of rule already marked (UiKit.strong,
## Glossary.emphasize), the body in BODY, left aligned, as tall as its lines. Its plain words go to plain.
func _rich(bbcode: String) -> RichTextLabel:
	var marked := Glossary.emphasize(bbcode)
	var r := UiKit.rich(marked, BODY, BODY_SIZE)
	r.name = &"Desc"
	r.custom_minimum_size.x = SIZE.x - PAD * 2.0
	plain = r.get_parsed_text()
	return r


## The rows of facts (BoonChoice.facts: [stat, label, value]); before: the same of what a trade lets go, matched by
## stat (its value shows dimmed before the new one). null without facts.
func _facts(rows: Array, before: Array = []) -> VBoxContainer:
	if rows.is_empty():
		return null
	var old := {}
	for f: Array in before:
		old[f[0]] = f[2]
	var col := VBoxContainer.new()
	col.name = &"Facts"
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override(&"separation", 0)
	for f: Array in rows.slice(0, FACT_MAX):
		var row := HBoxContainer.new()
		row.name = StringName("Fact_" + String(f[0]))
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override(&"separation", 6)
		var label := UiKit.label(String(f[1]), UiKit.DIM, FACT_LABEL, UiKit.BOLD_FONT)
		label.name = &"Label"
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(label)
		if old.has(f[0]) and old[f[0]] != f[2]:
			var was := UiKit.label(T.t(&"fact_was", {"v": old[f[0]]}), UiKit.DIM, FACT_LABEL + 1, UiKit.number_font())
			was.name = &"Was"
			was.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(was)
		var value := UiKit.label(String(f[2]), UiKit.STRONG, FACT_VALUE, UiKit.number_font())
		value.name = &"Value"
		row.add_child(value)
		col.add_child(row)
	return col


## A spacer that takes the card's height left over.
func _fill() -> Control:
	var c := Control.new()
	c.name = &"Fill"
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


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
	if b.slot != Boon.Slot.NONE:
		# the action said with the HUD's own symbol (stage 1A)
		row.add_child(ActionSlot.mark(b.slot, ACTION_MARK))
		row.move_child(row.get_child(-1), 0)
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
