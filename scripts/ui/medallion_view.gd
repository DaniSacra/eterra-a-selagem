class_name MedallionView
extends Control
## The ring of the Gifts screen (docs/art/dons_medallion_spec.md 1, 2, 4, 5): the outer frame, the ring line, the lit
## prerequisite lines and one node per place of the hero's MedallionDef, drawn by state (LOCKED, SEALED, OPEN, EQUIPPED,
## BLOCKED), the crown with the hero's mark, the ultimates with a double rim, the focus ring and the hold ring. Pure
## presentation over a HeroLoadout: the screen decides what a press does. The mouse hovers (focused) and presses
## (press_began, press_ended). It lives in the 1280 x 720 space of the stage.

signal focused(id: StringName)
signal press_began(id: StringName)
signal press_ended

const HALO_R := 1.5
const FOCUS_GAP := 4.0
const PULSE := 0.6
const POP_TIME := 0.2
const SHAKE_TIME := 0.25
const FLASH_TIME := 0.12
const SPARK_TIME := 0.4
const SPARKS := 12
const STAR_COUNT := 8
const FRAME_R := 340.0
const MUTE := Color("7a756c")
const IRON := Color("5a5650")
const DEEP := Color("2a2620")
const SHELL := Color("b8b4aa")
const IVORY := Color(0.97, 0.93, 0.84)
const LINE := Color("8e7444")
const LOCKED_D := 48.0
const LABEL_FS := 24
const LABEL_NEAR := 14.0
## The three branches of the medallion in the colours of the PO's drawing (Combo terracotta, Impeto blue, Dominio gold).
const BRANCH_TINT := {
	TalentDef.Branch.COMBO: Color("b8553a"), TalentDef.Branch.IMPETO: Color("3f7fc0"), TalentDef.Branch.DOMINIO: Color("c9a03c"),
}
const NODE_NUM_MIN := 16
const CAPTION_MAX := 70
const CAPTION_W := 230.0
const CAPTION_FS := 16
const CAPTION_LINE := 20.0

var def: MedallionDef
var nav: MedallionNav
var loadout: HeroLoadout
var focus_id: StringName = &""
## The node held down for "Segure para abrir" and how full its ring is (0..1).
var hold_id: StringName = &""
var hold_progress := 0.0
## 0..1: the screen's entrance (the ring turns in from -8 degrees, the nodes come down the two sides).
var reveal := 1.0:
	set(v):
		reveal = v
		queue_redraw()
var glow: Control
## The short line under the focused node (what it does, or what it asks), set by the screen.
var caption := ""
var _labels: Array = []
var _t := 0.0
var _pop: Dictionary = {}
var _shake: Dictionary = {}
var _edges: Array = []
## The openings in flight: {id, t} (the white flash 0.12 s, the twelve sparks 0.4 s).
var _bursts: Array = []


func setup(p_loadout: HeroLoadout) -> MedallionView:
	loadout = p_loadout
	def = only_known(without_ults(MedallionDef.of(String(loadout.hero.id)), loadout.hero), loadout.book.catalog)
	nav = MedallionNav.new(def, loadout.book.catalog)
	_edges = nav.edges()
	_labels = _sector_labels()
	name = "medallion_view"
	custom_minimum_size = Vector2(1280, 720)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	glow = Control.new()
	glow.name = "glow"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = add
	glow.draw.connect(_draw_glow)
	add_child(glow)
	return self


## True when the hero's Supremo is fixed by the weapon (HeroDef.ult_for_weapon, redesign A.3): there is no ultimate to
## choose, so the medallion has no ULT nodes and the Livro shows the one the hero has. Tolerant of a HeroDef without it.
static func has_fixed_ult(hero: HeroDef) -> bool:
	return hero.weapon != &""


## The Supremo of the hero's weapon, unlocked or not (null: the hero has none).
static func weapon_ult(hero: HeroDef) -> UltDef:
	return hero.ult_for_weapon(1 << 30)


## The medallion without its ULT nodes when the hero's Supremo is fixed (the same def otherwise).
static func without_ults(source: MedallionDef, hero: HeroDef) -> MedallionDef:
	if not has_fixed_ult(hero):
		return source
	var out := MedallionDef.new()
	out.hero = source.hero
	for n in source.nodes:
		if n.kind != MedallionNodeDef.Kind.ULT:
			out.nodes.append(n)
	return out


## The medallion without the Gift nodes the hero's catalog does not have (a stale or drawn-ahead place never crashes the
## view; the crown and the ultimates stay). The same def when none is missing.
static func only_known(source: MedallionDef, catalog: Array[TalentDef]) -> MedallionDef:
	var have := {}
	for t in catalog:
		have[t.id] = true
	var out := MedallionDef.new()
	out.hero = source.hero
	for n in source.nodes:
		if n.kind != MedallionNodeDef.Kind.GIFT or have.has(n.id):
			out.nodes.append(n)
	return out if out.nodes.size() != source.nodes.size() else source


func _process(delta: float) -> void:
	_t += delta
	for id: StringName in _pop.keys():
		_pop[id] = maxf(_pop[id] - delta / POP_TIME, 0.0)
		if _pop[id] <= 0.0:
			_pop.erase(id)
	for id: StringName in _shake.keys():
		_shake[id] = maxf(_shake[id] - delta / SHAKE_TIME, 0.0)
		if _shake[id] <= 0.0:
			_shake.erase(id)
	for b: Dictionary in _bursts:
		b.t += delta
	_bursts = _bursts.filter(func(b: Dictionary) -> bool: return b.t < SPARK_TIME)
	queue_redraw()
	glow.queue_redraw()


## A Gift opened: a white flash on the node and sparks in its branch's ink flying out in a circle.
func burst(id: StringName) -> void:
	_bursts.append({"id": id, "t": 0.0})
	pop(id)


## The node swells (a Gift put on) for POP_TIME.
func pop(id: StringName) -> void:
	_pop[id] = 1.0


## The node shakes (a press that is refused).
func refuse(id: StringName) -> void:
	_shake[id] = 1.0


## The place a node is drawn at, with the turn of the entrance on it.
func spot(id: StringName) -> Vector2:
	var p: Vector2 = nav.pos[id]
	return MedallionDef.CENTER + (p - MedallionDef.CENTER).rotated(_turn())


func _turn() -> float:
	return deg_to_rad(-8.0) * (1.0 - clampf(reveal, 0.0, 1.0))


## 0..1: how far the entrance has come for this node (the top first, going down both sides).
func _appear(id: StringName) -> float:
	var lead := clampf(((nav.pos[id] as Vector2).y - 100.0) / 560.0, 0.0, 1.0)
	return clampf(reveal * 1.8 - lead * 0.8, 0.0, 1.0)


## The state of a node: a HeroLoadout.State, EQUIPPED for the crown, the chosen ultimate and LOCKED for an ultimate not
## reached yet.
func state_of(id: StringName) -> HeroLoadout.State:
	var n := def.find(id)
	match n.kind:
		MedallionNodeDef.Kind.CROWN:
			return HeroLoadout.State.EQUIPPED
		MedallionNodeDef.Kind.ULT:
			var u := loadout.hero.ultimate(id)
			if not loadout.ult_open(u):
				return HeroLoadout.State.LOCKED
			return HeroLoadout.State.EQUIPPED if loadout.ultimate() == id else HeroLoadout.State.OPEN
	return loadout.state(nav.talent(id))


## A node's place from the medallion's centre (the transform the lines are drawn in).
func spot_rel(id: StringName) -> Vector2:
	var n := def.find(id)
	return MedallionDef.place(n.angle, n.radius) - MedallionDef.CENTER


func tint_of(id: StringName) -> Color:
	var t := nav.talent(id)
	if t == null:
		return GiftArt.ULT_INK
	return BRANCH_TINT.get(t.branch, GiftArt.gift_ink(t))


# ---- input ----

## The node under a point of this control (the nearest whose disc, a little grown, holds it), or &"".
func node_at(p: Vector2) -> StringName:
	var best := &""
	var best_d := INF
	for n in def.nodes:
		var d := p.distance_to(spot(n.id))
		if d <= n.diameter * 0.5 + 6.0 and d < best_d:
			best = n.id
			best_d = d
	return best


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var id := node_at((event as InputEventMouseMotion).position)
		if id != &"" and id != focus_id:
			focused.emit(id)
	elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var id := node_at((event as InputEventMouseButton).position)
		if (event as InputEventMouseButton).pressed:
			if id != &"":
				focused.emit(id)
				press_began.emit(id)
		else:
			press_ended.emit()


# ---- drawing ----

func _draw() -> void:
	if def == null:
		return
	draw_set_transform(MedallionDef.CENTER, _turn(), Vector2.ONE)
	_draw_frame()
	draw_arc(Vector2.ZERO, MedallionDef.RING, 0.0, TAU, 160, Color(LINE, 0.45), 1.5, true)
	for e: Array in _edges:
		_draw_edge(self, e[0], e[1], false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for n in def.nodes:
		_draw_node(n)
	_draw_labels()
	_draw_focus()
	_draw_caption()


func _draw_glow() -> void:
	if def == null:
		return
	glow.draw_set_transform(MedallionDef.CENTER, _turn(), Vector2.ONE)
	for e: Array in _edges:
		_draw_edge(glow, e[0], e[1], true)
	glow.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var breathe := 0.9 + 0.1 * sin(_t * TAU / 2.0)
	for n in def.nodes:
		var id := n.id
		if n.kind == MedallionNodeDef.Kind.GIFT and state_of(id) == HeroLoadout.State.EQUIPPED:
			var c := spot(id)
			var r := n.diameter * 0.5 * HALO_R
			var tint := tint_of(id)
			for k in 4:
				glow.draw_circle(c, r * (1.0 - k * 0.18), Color(tint.lightened(0.2), 0.10 * breathe * _appear(id)))
	for b: Dictionary in _bursts:
		var c := spot(b.id)
		var r := def.find(b.id).diameter * 0.5
		if b.t < FLASH_TIME:
			glow.draw_circle(c, r + 2.0, Color(1, 1, 1, 1.0 - b.t / FLASH_TIME))
		var k: float = b.t / SPARK_TIME
		for i in SPARKS:
			var dir := Vector2.from_angle(TAU * i / SPARKS)
			glow.draw_circle(c + dir * (r + 6.0 + 34.0 * (1.0 - pow(1.0 - k, 2.0))), 2.5 * (1.0 - k) + 0.5, Color(tint_of(b.id).lightened(0.4), 1.0 - k))
	if hold_id != &"" and hold_progress > 0.0:
		var c := spot(hold_id)
		glow.draw_circle(c, def.find(hold_id).diameter * 0.5 * (1.0 + hold_progress * 0.8), Color(UiKit.GOLD, 0.12 * hold_progress))


func _draw_frame() -> void:
	var tex := DonsArt.texture("frame.png")
	if tex != null:
		draw_texture_rect(tex, Rect2(Vector2(-FRAME_R, -FRAME_R), Vector2(FRAME_R, FRAME_R) * 2.0), false)
		return
	draw_arc(Vector2.ZERO, FRAME_R, 0.0, TAU, 200, Color(UiKit.GOLD, 0.6), 2.5, true)
	draw_arc(Vector2.ZERO, FRAME_R - 7.0, 0.0, TAU, 200, Color(LINE, 0.55), 1.2, true)
	for k in STAR_COUNT:
		if k == 0:
			continue  # the banner's ornament stands at twelve o'clock
		var dir := Vector2.from_angle(TAU * k / STAR_COUNT - PI * 0.5)
		var at := dir * FRAME_R
		var s := 11.0 if k % 2 == 0 else 7.0
		var perp := dir.orthogonal()
		draw_colored_polygon(PackedVector2Array([at + dir * s * 1.6, at + perp * s * 0.5, at - dir * s * 1.6, at - perp * s * 0.5]), Color(UiKit.GOLD, 0.8))


## One line "from the centre" between nodes a (the farther) and b: the branch colour always, thick and dim as the
## skeleton; lit when both are on (branch colour toward gold, and its glow), half when one side is reached.
func _draw_edge(ci: CanvasItem, a: StringName, b: StringName, glow_pass: bool) -> void:
	var sa := state_of(a)
	var sb := state_of(b)
	var lit := sa == HeroLoadout.State.EQUIPPED and sb == HeroLoadout.State.EQUIPPED
	var half := not lit and (_reached(sa) or _reached(sb))
	if glow_pass and not lit:
		return
	var tint := tint_of(a)
	var col := Color(tint.darkened(0.1), 0.8)
	var w := 6.0
	if lit:
		col = tint.lightened(0.15).lerp(UiKit.GOLD, 0.35)
		w = 7.0
	elif half:
		col = Color(tint, 0.85)
	if glow_pass:
		col = Color(tint.lightened(0.3), 0.3 * _appear(a))
		w = 14.0
	if not glow_pass:
		ci.draw_line(spot_rel(a), spot_rel(b), Color(UiKit.INK, 0.55), w + 4.0, true)
	ci.draw_line(spot_rel(a), spot_rel(b), col, w, true)


static func _reached(s: HeroLoadout.State) -> bool:
	return s == HeroLoadout.State.EQUIPPED or s == HeroLoadout.State.OPEN or s == HeroLoadout.State.BLOCKED


func _draw_node(n: MedallionNodeDef) -> void:
	var id := n.id
	var a := _appear(id)
	if a <= 0.0:
		return
	var c := spot(id)
	if _shake.has(id):
		c.x += sin(_shake[id] * 30.0) * 3.0 * _shake[id]
	var grow := 1.0 + 0.12 * sin(float(_pop.get(id, 0.0)) * PI)
	var st := state_of(id)
	# a dark node (the big capstones too) is no bigger than the open nodes (the eye goes to what can be used)
	var d := minf(n.diameter, LOCKED_D) if st == HeroLoadout.State.LOCKED else n.diameter
	var r := d * 0.5 * grow * (0.7 + 0.3 * a)
	var tint := tint_of(id)
	var mod := Color(1, 1, 1, a)
	var t := nav.talent(id)
	var rim := LINE
	var fill := tint.darkened(0.3)
	var icon := IVORY
	match st:
		HeroLoadout.State.LOCKED:
			rim = IRON
			fill = DEEP
		HeroLoadout.State.SEALED:
			fill = tint.lerp(IRON, 0.7).darkened(0.35)
			icon = SHELL
			if t != null and loadout.can_open(t) == Talents.Problem.PATH:
				fill = fill.lerp(DEEP, 0.5)
				icon = Color(SHELL, 0.6)
				rim = IRON
		HeroLoadout.State.EQUIPPED:
			rim = UiKit.GOLD
			fill = tint.lightened(0.1)
		HeroLoadout.State.BLOCKED:
			fill = tint.darkened(0.3).lerp(DEEP, 0.45)
			icon = Color(IVORY, 0.7)
	if n.kind == MedallionNodeDef.Kind.CROWN:
		rim = UiKit.GOLD
		fill = DEEP.lerp(UiKit.GOLD, 0.18)
		icon = UiKit.GOLD
	elif n.kind == MedallionNodeDef.Kind.ULT and st == HeroLoadout.State.EQUIPPED:
		fill = UiKit.GOLD.darkened(0.25)
	# the disc: ink under the rim, the enamel inside
	draw_circle(c, r + 1.5, Color(UiKit.INK, 0.9 * a))
	if st == HeroLoadout.State.BLOCKED:
		_dashed(c, r - 1.0, Color(rim, a), 2.5)
	else:
		draw_circle(c, r, rim * mod)
	draw_circle(c, r - 2.6, fill * mod)
	if n.kind == MedallionNodeDef.Kind.ULT:
		draw_arc(c, r + 3.5, 0.0, TAU, 28, Color(UiKit.GOLD, 0.9 * a), 1.5, true)
	# what it shows
	if st == HeroLoadout.State.LOCKED:
		# not reached yet: dark, with the Mastery level that reaches it (the padlock is the sealed Gift's, the one that asks Memória)
		var lvl := str(t.unlock_level) if t != null else str(loadout.hero.ultimate(id).mastery_level)
		var f := UiKit.BOLD_FONT
		var fs := maxi(int(r * 0.7), NODE_NUM_MIN)
		GiftArt.corner(self, c + Vector2(0.0, -r * 0.34), r * 0.26, loadout.hero, Color(MUTE, a))
		var at := c + Vector2(-f.get_string_size(lvl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.5, r * 0.38 + (f.get_ascent(fs) - f.get_descent(fs)) * 0.5)
		draw_string_outline(f, at, lvl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(UiKit.INK, a))
		draw_string(f, at, lvl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(IVORY, a))
	else:
		MedallionView.draw_icon(self, loadout.hero, id, n, c, r * 0.5, icon * mod, fill)
	if st == HeroLoadout.State.SEALED and t != null:
		ActionSlot.padlock(self, c + Vector2(-r * 0.62, r * 0.66), r * 0.34, Color(SHELL, a))
		var at := c + Vector2(r * 0.72, r * 0.72)
		DonsArt.memory_mark(self, at, 20.0)
		var f := UiKit.BOLD_FONT
		var s := str(t.memory_cost)
		draw_string_outline(f, at + Vector2(-3.0 - f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x * 0.5 + 2.0, 20.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 4, Color(UiKit.INK, a))
		draw_string(f, at + Vector2(-3.0 - f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x * 0.5 + 2.0, 20.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(UiKit.PALE, a))


## The glyph of a node inside radius r: the lion or the star on the crown, the ultimate's mark, the Gift's own glyph or
## its branch's. Also the panel's big disc.
static func draw_icon(ci: CanvasItem, hero: HeroDef, id: StringName, n: MedallionNodeDef, c: Vector2, r: float, col: Color, ink: Color) -> void:
	match n.kind:
		MedallionNodeDef.Kind.CROWN:
			GiftArt.corner(ci, c, r * 1.35, hero, col)
		MedallionNodeDef.Kind.ULT:
			BoonIcon.glyph(ci, BoonIcon.ULT_GLYPH + hero.ultimate(id).kind, c, r * 1.1, col, ink)
		_:
			var t := hero.talents().find(id)
			if not TalentGlyph.draw(ci, id, c, r * 1.15, col, ink):
				TalentNode.branch_glyph(ci, TalentNode.glyph_of(t.branch), c, r * 1.1, col)


func _dashed(c: Vector2, r: float, col: Color, w: float) -> void:
	for k in 12:
		var a0 := TAU * k / 12.0
		draw_arc(c, r, a0, a0 + TAU / 24.0, 4, col, w, true)


func _draw_focus() -> void:
	if focus_id == &"" or not nav.pos.has(focus_id):
		return
	var n := def.find(focus_id)
	var c := spot(focus_id)
	var pulse := 0.5 + 0.5 * sin(_t * TAU / PULSE)
	var r := n.diameter * 0.5 + FOCUS_GAP + pulse * 1.5
	_draw_needs(c, r)
	draw_arc(c, r, 0.0, TAU, 40, Color(1.0, 0.96, 0.8, 0.95), 3.0, true)
	if hold_id == focus_id and hold_progress > 0.0:
		draw_arc(c, r + 5.0, -PI * 0.5, -PI * 0.5 + TAU * hold_progress, 48, UiKit.GOLD, 4.0, true)


## The Gift the focused one needs (TalentDef.needs) when it is on this medallion, else &"".
func needs_of(id: StringName) -> StringName:
	var t := nav.talent(id)
	return t.needs if t != null and t.needs != &"" and nav.pos.has(t.needs) else &""


## UX-01: the prerequisite of the focused Gift marked in gold (a dashed ring on it and a line to the focus), so a child
## sees where a Dom comes from without reading.
func _draw_needs(focus_c: Vector2, focus_r: float) -> void:
	var need := needs_of(focus_id)
	if need == &"":
		return
	var c := spot(need)
	var r := def.find(need).diameter * 0.5 + FOCUS_GAP
	var dir := (c - focus_c).normalized()
	draw_line(focus_c + dir * focus_r, c - dir * r, Color(UiKit.GOLD, 0.8), 3.0, true)
	_dashed(c, r, UiKit.GOLD, 4.0)


## The name of every branch in big letters in its colour, by the tip of the branch (its apex): below the apex of a
## bottom branch, beside the one at the top (the banner is above it): [{text, at (the centre of the text), w, ink}].
func _sector_labels() -> Array:
	var out: Array = []
	for b in nav.branches:
		var apex: MedallionNodeDef = null
		for n in def.nodes:
			var t := nav.talent(n.id)
			if t != null and t.branch == b.branch and (apex == null or n.radius > apex.radius):
				apex = n
		if apex == null or not HeroLoadout.BRANCH_KEY.has(b.branch):
			continue
		var text := T.t(HeroLoadout.BRANCH_KEY[b.branch])
		var w := UiKit.TITLE_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FS).x
		var c := MedallionDef.place(apex.angle, apex.radius)
		var out_dir := (c - MedallionDef.CENTER).normalized()
		var at := c + Vector2(apex.diameter * 0.5 + LABEL_NEAR + w * 0.5, 0.0) if out_dir.y < -0.3 \
				else c + Vector2(0.0, apex.diameter * 0.5 + LABEL_NEAR + LABEL_FS * 0.6)
		out.append({"text": text, "at": at, "w": w, "ink": tint_of(apex.id).lightened(0.25)})
	return out


func _draw_labels() -> void:
	var f := UiKit.TITLE_FONT
	var a := clampf(reveal * 2.0, 0.0, 1.0)
	for l: Dictionary in _labels:
		var at: Vector2 = l.at + Vector2(-l.w * 0.5, LABEL_FS * 0.35)
		draw_string_outline(f, at, l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FS, 6, Color(UiKit.INK, 0.9 * a))
		draw_string(f, at, l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FS, Color(l.ink, a))


## The boxes the branch names fill now (same place as _draw_labels) and the other nodes' discs: what the caption avoids.
func label_boxes() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for l: Dictionary in _labels:
		out.append(Rect2(l.at - Vector2(l.w * 0.5, LABEL_FS * 0.7), Vector2(l.w, LABEL_FS * 1.4)))
	for n in def.nodes:
		if n.id != focus_id:
			out.append(Rect2(spot(n.id) - Vector2.ONE * n.diameter * 0.5, Vector2.ONE * n.diameter))
	return out


## Where the caption's centre goes: inward from the node at `start`, pushed along that line (further in, then back
## toward the node) until its box clears every branch label (UI 6: the hint sat over "FÚRIA" and "COMBO").
func caption_spot(c: Vector2, inward: Vector2, start: float, box_size: Vector2) -> Vector2:
	var boxes := label_boxes()
	for step: float in [0.0, 28.0, 56.0, -28.0, 84.0, -56.0]:
		var p := c + inward * (start + step)
		var r := Rect2(p - box_size * 0.5, box_size).grow(4.0)
		var clear := true
		for b in boxes:
			if r.intersects(b):
				clear = false
				break
		if clear:
			return p
	return c + inward * start


## A place on the ring's plane by angle and radius, with the entrance's turn.
func spot_at(angle: float, radius: float) -> Vector2:
	return MedallionDef.CENTER + (MedallionDef.place(angle, radius) - MedallionDef.CENTER).rotated(_turn())


## The short effect (or reason) of the focused node, on the inside of the ring beside it, over the figure and clear of
## the other nodes.
func _draw_caption() -> void:
	if caption == "" or focus_id == &"" or not nav.pos.has(focus_id) or reveal < 1.0:
		return
	var n := def.find(focus_id)
	var c := spot(focus_id)
	var inward := (MedallionDef.CENTER - c).normalized()
	var f := UiKit.TEXT_FONT
	var lines := caption_lines(caption)
	var box_size := caption_box_size(lines)
	# start far enough that the box clears the node's disc whatever the direction (UI B2: it covered the node)
	var reach := absf(inward.x) * box_size.x * 0.5 + absf(inward.y) * box_size.y * 0.5
	var p := caption_spot(c, inward, n.diameter * 0.5 + FOCUS_GAP + 12.0 + reach, box_size)
	var box := Rect2(p - box_size * 0.5, box_size)
	draw_style_box(UiKit.box(Color(0.03, 0.025, 0.035, 0.92), UiKit.OLD_GOLD, 1, 0, 4), box)
	for i in lines.size():
		var w := f.get_string_size(lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FS).x
		draw_string(f, Vector2(p.x - w * 0.5, box.position.y + 18.0 + i * CAPTION_LINE), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FS, UiKit.PALE)


## The caption broken on words into lines no wider than CAPTION_W (never cut mid-word).
static func caption_lines(text: String) -> Array[String]:
	var f := UiKit.TEXT_FONT
	var out: Array[String] = []
	var cur := ""
	for word in text.split(" ", false):
		var tryw := word if cur == "" else cur + " " + word
		if cur != "" and f.get_string_size(tryw, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FS).x > CAPTION_W:
			out.append(cur)
			cur = word
		else:
			cur = tryw
	if cur != "":
		out.append(cur)
	return out


static func caption_box_size(lines: Array[String]) -> Vector2:
	var f := UiKit.TEXT_FONT
	var w := 0.0
	for l in lines:
		w = maxf(w, f.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, CAPTION_FS).x)
	return Vector2(w + 16.0, 12.0 + CAPTION_LINE * maxi(lines.size(), 1))
