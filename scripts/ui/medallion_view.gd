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
const LABEL_GAP := 42.0
const LABEL_APART := 24.0
const CAPTION_MAX := 46

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
	def = MedallionDef.of(String(loadout.hero.id))
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


func tint_of(id: StringName) -> Color:
	var t := nav.talent(id)
	return GiftArt.ULT_INK if t == null else GiftArt.gift_ink(t)


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
	draw_arc(Vector2.ZERO, MedallionDef.RING, 0.0, TAU, 160, Color(LINE, 0.6), 3.0, true)
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


## One prerequisite line between nodes a (the one that asks) and b: along the ring between two ring nodes, straight for a
## spur. Lit when both are on (3 px, branch ink toward gold, and its glow), half when one side is reached (2 px, half
## alpha), nothing else (the ring line is the base).
func _draw_edge(ci: CanvasItem, a: StringName, b: StringName, glow_pass: bool) -> void:
	var sa := state_of(a)
	var sb := state_of(b)
	var lit := sa == HeroLoadout.State.EQUIPPED and sb == HeroLoadout.State.EQUIPPED
	var half := not lit and (_reached(sa) or _reached(sb))
	if not lit and not half:
		return
	if glow_pass and not lit:
		return
	var tint := tint_of(a)
	var col := tint.lightened(0.15).lerp(UiKit.GOLD, 0.5) if lit else Color(tint, 0.75)
	if glow_pass:
		col = Color(tint.lightened(0.3), 0.3 * _appear(a))
	var na := def.find(a)
	var nb := def.find(b)
	var w := (12.0 if glow_pass else 5.0) if lit else 3.5
	if absf(na.radius - nb.radius) < 1.0:
		var a1 := deg_to_rad(na.angle - 90.0)
		var a2 := deg_to_rad(nb.angle - 90.0)
		if absf(a2 - a1) > PI:
			a2 += TAU if a2 < a1 else -TAU
		ci.draw_arc(Vector2.ZERO, na.radius, a1, a2, 24, col, w, true)
	else:
		ci.draw_line(MedallionDef.place(na.angle, na.radius) - MedallionDef.CENTER, MedallionDef.place(nb.angle, nb.radius) - MedallionDef.CENTER, col, w, true)


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
	elif t != null and t.tier == TalentDef.Tier.BRIDGE and t.joins.size() == 2:
		draw_arc(c, r - 1.0, PI * 0.5, PI * 1.5, 16, Color(GiftArt.ink(t.joins[0]).lightened(0.25), a), 3.0, true)
		draw_arc(c, r - 1.0, -PI * 0.5, PI * 0.5, 16, Color(GiftArt.ink(t.joins[1]).lightened(0.25), a), 3.0, true)
		if st == HeroLoadout.State.EQUIPPED:
			draw_arc(c, r + 0.5, 0.0, TAU, 28, Color(UiKit.GOLD, a), 1.2, true)
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
		var fs := maxi(int(r * 0.57), 9)
		GiftArt.corner(self, c + Vector2(0.0, -r * 0.34), r * 0.26, loadout.hero, Color(MUTE, a))
		var at := c + Vector2(-f.get_string_size(lvl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.5, r * 0.38 + (f.get_ascent(fs) - f.get_descent(fs)) * 0.5)
		draw_string(f, at, lvl, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(UiKit.PARCHMENT, 0.7 * a))
	else:
		MedallionView.draw_icon(self, loadout.hero, id, n, c, r * 0.5, icon * mod, fill)
	if st == HeroLoadout.State.SEALED and t != null:
		ActionSlot.padlock(self, c + Vector2(-r * 0.62, r * 0.66), r * 0.34, Color(SHELL, a))
		var at := c + Vector2(r * 0.72, r * 0.72)
		DonsArt.memory_mark(self, at, 20.0)
		var f := UiKit.BOLD_FONT
		var s := str(t.memory_cost)
		draw_string_outline(f, at + Vector2(-3.0 - f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x * 0.5 + 2.0, 20.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, 4, Color(UiKit.INK, a))
		draw_string(f, at + Vector2(-3.0 - f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x * 0.5 + 2.0, 20.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(UiKit.PALE, a))


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
	draw_arc(c, r, 0.0, TAU, 40, Color(1.0, 0.96, 0.8, 0.95), 3.0, true)
	if hold_id == focus_id and hold_progress > 0.0:
		draw_arc(c, r + 5.0, -PI * 0.5, -PI * 0.5 + TAU * hold_progress, 48, UiKit.GOLD, 4.0, true)


## The name of every branch written on the inside of the ring at the middle of its sector (Combo, Fúria, Magia, Emeth,
## Sustento; the bridges have no name of their own): [{text, pos, ink}].
func _sector_labels() -> Array:
	var sums := {}
	for n in def.nodes:
		var t := nav.talent(n.id)
		if t == null or t.branch == TalentDef.Branch.BRIDGE:
			continue
		var s: Dictionary = sums.get(t.branch, {"sum": 0.0, "n": 0, "r": INF, "first": n.id, "at": n.angle})
		s.sum += n.angle
		s.n += 1
		if n.radius < s.r:
			s.r = n.radius
			s.first = n.id
			s.at = n.angle
		sums[t.branch] = s
	var out: Array = []
	for b: int in sums:
		# right inside the branch's innermost node (its own angle), not at the middle of the sector
		out.append({"text": T.t(HeroLoadout.BRANCH_KEY[b]), "angle": sums[b].at, "radius": sums[b].r - LABEL_GAP, "first": sums[b].first, "ink": GiftArt.ink(b).lightened(0.45)})
	# two labels closer than LABEL_APART: the one with the larger angle slides along the arc
	out.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return x.angle < y.angle)
	for i in range(1, out.size()):
		for k in 12:
			if MedallionDef.place(out[i].angle, out[i].radius).distance_to(MedallionDef.place(out[i - 1].angle, out[i - 1].radius)) >= LABEL_APART:
				break
			out[i].angle += 3.0
	return out


func _draw_labels() -> void:
	var f := UiKit.TITLE_FONT
	for l: Dictionary in _labels:
		var p := spot_at(l.angle, l.radius)
		var w := f.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		var to := spot(l.first)
		var dir := (to - p).normalized()
		var edge := minf(w * 0.5 + 8.0, 12.0 / maxf(absf(dir.y), 0.01)) if absf(dir.y) > 0.01 else w * 0.5 + 8.0
		draw_line(p + dir * edge, to - dir * (def.find(l.first).diameter * 0.5 + 1.5), Color(l.ink, 0.5), 1.0, true)
		var box := Rect2(p - Vector2(w * 0.5 + 8.0, 12.0), Vector2(w + 16.0, 24.0))
		draw_style_box(UiKit.box(Color(0.03, 0.025, 0.035, 0.78 * clampf(reveal * 2.0, 0.0, 1.0)), Color(l.ink, 0.7), 1, 0, 11), box)
		draw_string(f, p + Vector2(-w * 0.5, 5.5), l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, l.ink)


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
	var w := minf(f.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x, 260.0)
	var p := c + inward * (n.diameter * 0.5 + 62.0)
	var box := Rect2(p - Vector2(w * 0.5 + 8.0, 13.0), Vector2(w + 16.0, 26.0))
	draw_style_box(UiKit.box(Color(0.03, 0.025, 0.035, 0.92), UiKit.OLD_GOLD, 1, 0, 4), box)
	draw_string(f, p + Vector2(-w * 0.5, 5.5), caption, HORIZONTAL_ALIGNMENT_LEFT, w, 15, UiKit.PALE)
