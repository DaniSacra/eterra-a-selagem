class_name TalentNode
extends BaseButton
## One node of the Gift tree on the hero screen (E2-06; art pack stage 2, board 09): a diamond of felt in its branch's
## colour inside a frame of old gold with small flares at its four tips, and the Gift's own glyph in ivory
## (TalentGlyph: what the Gift does; the centre the Emeth's crystal). One frame, four states told apart by fill, line,
## glyph and text, never by colour alone:
## - equipped: the felt lit in the branch's colour, an emerald line and a glow round it;
## - open (can go on now): dark felt with a hint of the branch, the old gold frame, the glyph in the branch's colour;
## - blocked (reached, but a rule refuses it now): the same felt greyed, a dull frame cut at the tips, the glyph dim;
## - locked (Mastery too low): slate, no glyph, a small lock and the Mastery level that opens it.
## The cost is a row of small diamonds under it. Focus (mouse, keys or gamepad: the mouse takes the focus with it) is
## an ivory line round the frame; on_path rings the Gifts the focused one needs (TalentTree lights their links).

## The branch's colour, muted (TalentDef.Branch; the centre is CENTRE).
## Combo is the crimson of the Emeth's hilt and the Warrior's hair (it was a grey that read as switched off).
const BRANCH_COLOR: Array[Color] = [Color("c4404e"), Color("c8643c"), Color("3fae7c"), Color("4f9cc6"), Color("a88e5c"), Color("b8665a")]
const CENTRE := Color("3fae7c")
## A Gift worn: its felt takes this much of its branch's colour (darkened this much), the line is the Emeth's emerald
## and a glow of GLOW_RINGS rings reaches GLOW_REACH px out.
const EQUIPPED_FILL := 0.85
const EQUIPPED_DARKEN := 0.2
const EQUIPPED_LINE := Color("6fe0a8")
const GLOW_RINGS := 4
const GLOW_REACH := 7.0
const GLOW_ALPHA := 0.5
## A Gift only open: dark felt with this much of its branch's colour (darkened), so the frame and glyph carry it.
const OPEN_FILL := 0.28
const OPEN_DARKEN := 0.55
const LOCK_LINE := Color("4a4239")
const LOCK_INK := Color(0.035, 0.03, 0.04, 0.96)
const BLOCKED_LINE := Color("6b5a3f")
const FOCUS := Color(1.0, 0.95, 0.84, 0.95)
const PATH := Color(1.0, 0.95, 0.84, 0.55)
const SIDE := 46.0
## The flares at the tips of the frame: how far out and how wide.
const FLARE := 5.0
const FLARE_WIDE := 2.6
## The cost's diamonds under the node: their half size and step.
const PIP := 3.2
const PIP_STEP := 9.0
const LEVEL_SIZE := 15
## A sealed Gift (revealed by the Mastery, not opened with Memória): its glyph at half strength, and under it the leaf
## of Memória and the price, in place of the Devotion's pips.
const SEALED_GLYPH := 0.5
const MEMORY_MARK := 13.0
const MEMORY_SIZE := 14
## Ciclo visual 2026-11-20 (item 3, Dons): worn, open and sealed told apart by shape too, not by colour alone. Worn: a
## round badge with a tick at the upper right tip; sealed: the frame in dashes (no flares) and a small round wax seal
## at the upper right, the lock of Memória. BADGE is the badge's radius against the node's half side.
const BADGE := 0.3
const DASH := 5.0
const SEAL_WAX := Color("7a3a34")

## Glyph outlines in units of the glyph's radius (convex enough to triangulate).
const FLAME := TalentGlyph.FLAME
const TONGUE := TalentGlyph.TONGUE
const DROP := TalentGlyph.DROP

enum Glyph { COMBO, FURIA, EMETH, MAGIA, BRIDGE, SUSTAIN, CENTRE }

var def: TalentDef
var glyph := Glyph.CENTRE
var state := HeroLoadout.State.OPEN:
	set(v):
		state = v
		queue_redraw()
## A Gift the focused one needs (TalentTree.path_of): a faint ivory ring.
var on_path := false:
	set(v):
		on_path = v
		queue_redraw()
var _flash := 0.0


func setup(p_def: TalentDef, side: float = SIDE) -> TalentNode:
	def = p_def
	glyph = Glyph.CENTRE if def == null else (def.branch as int) as Glyph
	custom_minimum_size = Vector2(side, side)
	size = custom_minimum_size
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(func() -> void:
		if not has_focus():
			grab_focus())
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	name = String(def.id) if def else "centre"
	return self


func color() -> Color:
	return CENTRE if def == null else BRANCH_COLOR[def.branch]


## A short shake of the line when a rule refuses it.
func refuse() -> void:
	_flash = 1.0
	set_process(true)


func _process(delta: float) -> void:
	_flash = maxf(_flash - delta / 0.35, 0.0)
	queue_redraw()
	if _flash <= 0.0:
		set_process(false)


func _has_point(point: Vector2) -> bool:
	var d := (point - size * 0.5).abs()
	return d.x + d.y <= size.x * 0.5 + 2.0


func _draw() -> void:
	var c := size * 0.5 + Vector2(sin(_flash * 40.0) * 3.0 * _flash, 0.0)
	var h := size.x * 0.5
	var locked := state == HeroLoadout.State.LOCKED
	var blocked := state == HeroLoadout.State.BLOCKED and def != null
	var sealed := state == HeroLoadout.State.SEALED and def != null
	var on := equipped()
	var line := line_color()
	if _flash > 0.0:
		line = line.lerp(Color(1.0, 0.62, 0.5), _flash)
	if on:
		# the glow of a Gift worn: soft emerald rings outside the frame
		for i in GLOW_RINGS:
			var k := float(i + 1) / GLOW_RINGS
			draw_polyline(_closed(_diamond(c, h + 1.5 + k * GLOW_REACH)), Color(EQUIPPED_LINE, GLOW_ALPHA * (1.0 - k)), 2.0, true)
	if on_path and not has_focus():
		draw_polyline(_closed(_diamond(c, h + 4.0 + (GLOW_REACH * 0.5 if on else 0.0))), PATH, 1.2, true)
	# the frame: a band of the line's colour, the felt inside, a thin inner line
	if sealed:
		# revealed, not opened: no solid frame yet, a line of dashes round the dark felt
		draw_colored_polygon(_diamond(c, h - UiKit.FRAME), ink_color())
		_dashed(_closed(_diamond(c, h)), line, 1.6)
	else:
		draw_colored_polygon(_diamond(c, h), line.darkened(0.35))
		draw_colored_polygon(_diamond(c, h - UiKit.FRAME - (1.0 if on else 0.0)), ink_color())
		draw_polyline(_closed(_diamond(c, h)), line, 1.4, true)
	draw_polyline(_closed(_diamond(c, h - 5.0)), Color(line, 0.25 if locked or blocked else 0.45), 1.0, true)
	if not locked and not sealed:
		_flares(c, h, line.lightened(0.1) if not blocked else line)
	if blocked:
		# the frame cut at its four tips: reached, but not now
		for d: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
			draw_line(c + d * (h - 6.0) + d.orthogonal() * 3.0, c + d * (h - 6.0) - d.orthogonal() * 3.0, ink_color(), 2.4)
	if has_focus():
		draw_polyline(_closed(_diamond(c, h + 4.0 + (GLOW_REACH * 0.5 if on else 0.0))), FOCUS, 1.6, true)
	if locked:
		_draw_lock(c, def.unlock_level if def else 1)
	else:
		var r := h * 0.5
		var col := glyph_color()
		# AP-4: the Gift's painted motif (technical-artist's TalentMotif), else its glyph, else its branch's
		if def == null or not TalentMotif.draw(self, def.id, c, r, state):
			if def == null or not TalentGlyph.draw(self, def.id, c, r, col, ink_color()):
				branch_glyph(self, glyph, c, r, col)
	if on and def != null:
		_badge_tick(c + Vector2(h * 0.62, -h * 0.62), h * BADGE)
	elif sealed:
		_badge_seal(c + Vector2(h * 0.62, -h * 0.62), h * BADGE)
	if sealed and def.memory_cost > 0:
		# revealed, not opened (Rejogabilidade, Fatia 1): its price in Memória under it, not its Devotion
		_draw_memory(c, def.memory_cost)
	elif def != null and def.cost > 0:
		var pip := (EQUIPPED_LINE if on else UiKit.OLD_GOLD.lightened(0.3)) if not locked else LOCK_LINE.lightened(0.2)
		if blocked:
			pip = BLOCKED_LINE
		var x0 := c.x - (def.cost - 1) * PIP_STEP * 0.5
		for i in def.cost:
			draw_colored_polygon(_diamond(Vector2(x0 + i * PIP_STEP, size.y + 7.0), PIP), pip)


## A polyline in dashes of DASH px.
func _dashed(pts: PackedVector2Array, col: Color, width: float) -> void:
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var n := int(a.distance_to(b) / DASH)
		for k in range(0, n, 2):
			draw_line(a.lerp(b, float(k) / n), a.lerp(b, minf(float(k + 1) / n, 1.0)), col, width, true)


## Worn: a round emerald badge with a tick of ivory.
func _badge_tick(at: Vector2, r: float) -> void:
	draw_circle(at, r + 1.5, UiKit.INK)
	draw_circle(at, r, EQUIPPED_LINE.darkened(0.25))
	draw_polyline(PackedVector2Array([at + Vector2(-r * 0.5, 0.0), at + Vector2(-r * 0.1, r * 0.4), at + Vector2(r * 0.55, -r * 0.4)]),
		Color(1.0, 0.97, 0.9), maxf(1.6, r * 0.28), true)


## Sealed: a small round wax seal with a notched rim and a diamond pressed in it.
func _badge_seal(at: Vector2, r: float) -> void:
	draw_circle(at, r + 1.5, UiKit.INK)
	var rim := PackedVector2Array()
	for i in 16:
		rim.append(at + Vector2.from_angle(i * TAU / 16.0) * (r if i % 2 == 0 else r * 0.84))
	draw_colored_polygon(rim, SEAL_WAX)
	draw_colored_polygon(_diamond(at, r * 0.42), SEAL_WAX.lightened(0.35))


## The small flares of the frame (board 09): a thin spike out of each tip.
func _flares(c: Vector2, h: float, col: Color) -> void:
	for d: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		var tip := c + d * (h + FLARE)
		var base := c + d * (h - 1.0)
		var n := d.orthogonal() * FLARE_WIDE
		draw_colored_polygon(PackedVector2Array([base + n, tip, base - n]), col)


## Worn (the centre always is): filled in its branch's colour, an emerald line and a glow.
func equipped() -> bool:
	return state == HeroLoadout.State.EQUIPPED or def == null


## The diamond's felt: the branch's colour when worn, dark felt with a hint of it when open, greyed when blocked,
## slate when locked.
func ink_color() -> Color:
	if equipped():
		return UiKit.INK.lerp(color().darkened(EQUIPPED_DARKEN), EQUIPPED_FILL)
	match state:
		HeroLoadout.State.LOCKED:
			return LOCK_INK
		HeroLoadout.State.BLOCKED:
			return UiKit.INK.lerp(Color(0.3, 0.29, 0.3), 0.25)
	return UiKit.INK.lerp(color().darkened(OPEN_DARKEN), OPEN_FILL)


## The outer line: emerald when worn, old gold when open, a duller gold when blocked, a dull line when locked.
func line_color() -> Color:
	if equipped():
		return EQUIPPED_LINE
	match state:
		HeroLoadout.State.LOCKED:
			return LOCK_LINE
		HeroLoadout.State.BLOCKED:
			return BLOCKED_LINE
	return UiKit.OLD_GOLD


## The glyph: lit ivory over the branch's fill when worn, the branch's colour on dark felt when open, dim otherwise.
func glyph_color() -> Color:
	if equipped():
		return color().lerp(Color.WHITE, 0.7)
	if state == HeroLoadout.State.SEALED:
		return Color(color().lightened(0.15), SEALED_GLYPH)
	return color().lightened(0.15) if state == HeroLoadout.State.OPEN else UiKit.DIM.darkened(0.15)


## The price of opening a sealed Gift under its diamond: the Memória's leaf and the number (MaterialCount's language).
func _draw_memory(c: Vector2, n: int) -> void:
	var font := UiKit.number_font()
	var text := str(n)
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, MEMORY_SIZE).x
	var y := size.y + 8.0
	var x0 := c.x - (MEMORY_MARK + 3.0 + w) * 0.5
	DoorGlyph.material(self, DoorGlyph.Kind.MEMORY, Vector2(x0 + MEMORY_MARK * 0.5, y), MEMORY_MARK)
	draw_string_outline(font, Vector2(x0 + MEMORY_MARK + 3.0, y + MEMORY_SIZE * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, MEMORY_SIZE, 3, DoorGlyph.OUTLINE_COLOR)
	draw_string(font, Vector2(x0 + MEMORY_MARK + 3.0, y + MEMORY_SIZE * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, MEMORY_SIZE, DoorGlyph.PARCHMENT_FILL)


func _draw_lock(c: Vector2, level: int) -> void:
	var col := UiKit.DIM.darkened(0.1)
	# a padlock over the number
	var body := Rect2(c + Vector2(-5.0, -10.0), Vector2(10.0, 7.0))
	draw_arc(c + Vector2(0.0, -10.0), 3.4, PI, TAU, 10, col, 1.6, true)
	draw_rect(body, col)
	var n := str(level)
	var font := UiKit.number_font()
	var w := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_SIZE).x
	draw_string(font, c + Vector2(-w * 0.5, 11.0), n, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_SIZE, col)


## A branch's glyph inside a radius r around c (the centre, and any Gift without a glyph of its own): Combo two crossed
## blades, Fúria a flame, Emeth and the centre a crystal, Magia a four-pointed star of light (never the sun), a bridge
## two linked diamonds, sustain a drop.
static func branch_glyph(ci: CanvasItem, g: Glyph, c: Vector2, r: float, col: Color) -> void:
	match g:
		Glyph.COMBO:
			for s: float in [-1.0, 1.0]:
				var a := c + Vector2(-r * s, r)
				var b := c + Vector2(r * s, -r)
				ci.draw_line(a, b, col, 2.2, true)
				var gd := a.lerp(b, 0.22)
				var across := (b - a).normalized().orthogonal() * r * 0.32
				ci.draw_line(gd - across, gd + across, col, 2.0, true)
		Glyph.FURIA:
			ci.draw_colored_polygon(_shape(c, r, FLAME), col)
			ci.draw_colored_polygon(_shape(c, r, TONGUE), UiKit.INK)
		Glyph.EMETH, Glyph.CENTRE:
			var crystal := PackedVector2Array([c + Vector2(0, -r * 1.1), c + Vector2(r * 0.5, 0), c + Vector2(0, r * 1.1), c + Vector2(-r * 0.5, 0)])
			ci.draw_colored_polygon(crystal, col)
			ci.draw_line(c + Vector2(0, -r * 1.1), c + Vector2(0, r * 1.1), Color(UiKit.INK, 0.6), 1.2, true)
			if g == Glyph.CENTRE:
				ci.draw_line(c + Vector2(-r * 0.7, r * 0.45), c + Vector2(r * 0.7, r * 0.45), col, 2.0, true)
		Glyph.MAGIA:
			var star := PackedVector2Array()
			for i in 8:
				var d := Vector2.from_angle(i * PI * 0.25 - PI * 0.5)
				star.append(c + d * (r if i % 2 == 0 else r * 0.3))
			ci.draw_colored_polygon(star, col)
		Glyph.BRIDGE:
			ci.draw_polyline(_closed(_diamond(c + Vector2(-r * 0.45, 0), r * 0.5)), col, 1.8, true)
			ci.draw_polyline(_closed(_diamond(c + Vector2(r * 0.45, 0), r * 0.5)), col, 1.8, true)
		Glyph.SUSTAIN:
			ci.draw_colored_polygon(_shape(c, r, DROP), col)


## A shape given in units of r around c.
static func _shape(c: Vector2, r: float, pts: Array[Vector2]) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + p * r)
	return out


static func _diamond(c: Vector2, h: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -h), c + Vector2(h, 0), c + Vector2(0, h), c + Vector2(-h, 0)])


static func _closed(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	out.append(poly[0])
	return out
