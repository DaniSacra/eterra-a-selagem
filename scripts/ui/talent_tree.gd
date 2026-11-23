class_name TalentTree
extends Control
## The Warrior's Gift tree as a diamond (docs/design/warrior_spec.md 4.1; art pack stage 2, board 05): the passive in
## the centre and the four branches on the axes in the art bible's order (Combo up, Fúria right, Magia down, Emeth
## left), each with its entry, middle and apex going out; the bridges on the diagonals between neighbours; the sustain
## Gifts in a row of their own in the lower left corner (they hang on the centre alone). It sits on a slate inset of the
## book's page, with brackets of old gold in its corners. Lines join what a Gift needs; a line lights in old gold when
## both its ends are on, and the Gifts the focused one needs (path_of) light their links in ivory and ring their nodes.
## The nodes are TalentNode buttons placed by hand inside this control, the diamond scaled to the room it is given
## (fit, between FIT_MIN and FIT_MAX); focus moves between them by direction (Godot's own search), so keys and the
## gamepad's pad walk the diamond.

signal picked(def: TalentDef)
signal focused(def: TalentDef)

## Half the diamond across and down, in pixels at 720 lines at fit 1, and how far out each tier sits (share of the half).
const HALF := Vector2(290, 222)
const TIER_AT := {TalentDef.Tier.ENTRY: 0.34, TalentDef.Tier.MIDDLE: 0.64, TalentDef.Tier.APEX: 0.92}
const BRIDGE_AT := 0.5
## Where a second or third Gift of the same branch and tier (or the same bridge) sits: a middle slides across its axis, a
## bridge steps out of the diamond, by this many pixels at fit 1, the second to one side, the third to the other.
const VARIANT_STEP := 56.0
## How many steps further out along its ray a bridge's variant sits (the lines of two bridges of one pair never cross).
const BRIDGE_VARIANT_PUSH := 1.5
const AXIS := {
	TalentDef.Branch.COMBO: Vector2(0, -1), TalentDef.Branch.FURIA: Vector2(1, 0),
	TalentDef.Branch.MAGIA: Vector2(0, 1), TalentDef.Branch.EMETH: Vector2(-1, 0),
	# the Maga's triangle (M2): Piromancia up, Arcanismo lower right, Selos lower left (a unit vector each, 120 degrees apart)
	TalentDef.Branch.PIRO: Vector2(0, -1), TalentDef.Branch.ARCA: Vector2(0.87, 0.5), TalentDef.Branch.CTRL: Vector2(-0.87, 0.5),
}
## The sustain row (centre of its first node and the step) and its label, from the diamond's centre.
const SUSTAIN_AT := Vector2(-258, 204)
const SUSTAIN_STEP := 58.0
const LABEL_SIZE := 17
const CENTRE_SIDE := 58.0
## The room around the diamond for the branch names.
const MARGIN := Vector2(40, 18)
## How much the diamond may shrink or grow to fit what it is given.
const FIT_MIN := 0.72
const FIT_MAX := 1.15
## The slate inset under the tree.
const SLATE := Color(0.06, 0.065, 0.07, 0.97)
const SLATE_EDGE := Color(0.3, 0.25, 0.17)
const BRACKET := 14.0

var loadout: HeroLoadout
var nodes: Array[TalentNode] = []
var centre: TalentNode
## The diamond's scale now (fit()).
var k := 1.0
## The Gift the focus is on (null: the centre or nothing): its prerequisites light.
var _focus: TalentDef


func setup(p_loadout: HeroLoadout) -> TalentTree:
	loadout = p_loadout
	custom_minimum_size = base_size() * FIT_MIN
	centre = TalentNode.new().setup(null, CENTRE_SIDE)
	add_child(centre)
	centre.focus_entered.connect(func() -> void:
		_light(null)
		focused.emit(null))
	var sustain := 0
	for t in loadout.book.catalog:
		var n := TalentNode.new().setup(t)
		nodes.append(n)
		add_child(n)
		n.set_meta(&"at", spot(t, sustain, variant_of(t)))
		if t.tier == TalentDef.Tier.SUSTAIN:
			sustain += 1
		n.pressed.connect(func() -> void: picked.emit(t))
		n.focus_entered.connect(func() -> void:
			_light(t)
			focused.emit(t))
	refresh()
	resized.connect(_place)
	_place()
	return self


## The room the diamond takes at fit 1 (with its names round it).
static func base_size() -> Vector2:
	return (HALF + MARGIN) * 2.0


## The scale that fits the diamond into a size.
static func fit(room: Vector2) -> float:
	var b := base_size()
	return clampf(minf(room.x / b.x, room.y / b.y), FIT_MIN, FIT_MAX)


## Where a Gift sits, from the diamond's centre at fit 1 (k: its place in the sustain row).
static func spot(t: TalentDef, k_: int = 0, variant: int = 0) -> Vector2:
	match t.tier:
		TalentDef.Tier.BRIDGE:
			var d: Vector2 = AXIS[t.joins[0]] + AXIS[t.joins[1]]
			var out := d * HALF * BRIDGE_AT
			if variant > 0:
				# further out along the same ray: a second bridge between the same two entries has its lines clear of
				# the first one's (beside it, or on the other side of the edge, they would cross)
				out += out.normalized() * VARIANT_STEP * BRIDGE_VARIANT_PUSH * float(variant)
			return out
		TalentDef.Tier.SUSTAIN:
			return SUSTAIN_AT + Vector2(SUSTAIN_STEP * k_, 0)
	var axis: Vector2 = AXIS[t.branch]
	var at := axis * HALF * float(TIER_AT[t.tier])
	if variant > 0:
		var side := 1.0 if variant % 2 == 1 else -1.0
		var across := Vector2(axis.y, axis.x).abs() if absf(axis.x) < 0.01 or absf(axis.y) < 0.01 else Vector2(-axis.y, axis.x)
		at += across * side * VARIANT_STEP * float(ceili(variant * 0.5))
	return at


## Which of the Gifts that share its place (same branch and tier, or same two branches for a bridge) this one is, from 0.
func variant_of(t: TalentDef) -> int:
	var n := 0
	for o in loadout.book.catalog:
		if o == t:
			return n
		if HeroLoadout.same_place(o, t):
			n += 1
	return n


## What a Gift needs, as drawn links back to the centre: [] for an entry or a sustain Gift, the entry for a middle,
## the middle and the entry for an apex, both entries for a bridge (the apex's partner branch is a rule, not a line:
## the panel tells it).
func path_of(t: TalentDef) -> Array[TalentDef]:
	var out: Array[TalentDef] = []
	if t == null:
		return out
	match t.tier:
		TalentDef.Tier.MIDDLE:
			out.append(loadout.of(t.branch, TalentDef.Tier.ENTRY))
		TalentDef.Tier.APEX:
			out.append_array(loadout.all_of(t.branch, TalentDef.Tier.MIDDLE))
			out.append(loadout.of(t.branch, TalentDef.Tier.ENTRY))
		TalentDef.Tier.BRIDGE:
			for b: TalentDef.Branch in t.joins:
				out.append(loadout.of(b, TalentDef.Tier.ENTRY))
	return out.filter(func(x: TalentDef) -> bool: return x != null)


func node(id: StringName) -> TalentNode:
	for n in nodes:
		if n.def.id == id:
			return n
	return null


## Every node takes its state again (after a Gift goes on or off).
func refresh() -> void:
	for n in nodes:
		n.state = loadout.state(n.def)
	queue_redraw()


func _light(t: TalentDef) -> void:
	_focus = t
	var path := path_of(t)
	for n in nodes:
		n.on_path = path.has(n.def)
	queue_redraw()


func _mid() -> Vector2:
	return size * 0.5


func _at(t: TalentDef) -> Vector2:
	return _mid() if t == null else _mid() + (node(t.id).get_meta(&"at") as Vector2) * k


func _place() -> void:
	k = fit(size)
	var m := _mid()
	centre.position = m - centre.size * 0.5
	for n in nodes:
		n.position = m + (n.get_meta(&"at") as Vector2) * k - n.size * 0.5
	queue_redraw()


## Every line of the tree as [from, to] (from null: the centre).
func links() -> Array[Array]:
	var out: Array[Array] = []
	for t in loadout.book.catalog:
		match t.tier:
			TalentDef.Tier.ENTRY:
				out.append([null, t])
			TalentDef.Tier.MIDDLE:
				out.append([loadout.of(t.branch, TalentDef.Tier.ENTRY), t])
			TalentDef.Tier.APEX:
				for mid in loadout.all_of(t.branch, TalentDef.Tier.MIDDLE):
					out.append([mid, t])
			TalentDef.Tier.BRIDGE:
				for b: TalentDef.Branch in t.joins:
					out.append([loadout.of(b, TalentDef.Tier.ENTRY), t])
	return out


func _on(t: TalentDef) -> bool:
	return t == null or loadout.is_equipped(t.id)


func _draw() -> void:
	_draw_slate()
	var m := _mid()
	var path := path_of(_focus)
	for pair in links():
		_link(pair[0], pair[1], path)
	# the branch names past each apex, in the branch's colour
	for b: TalentDef.Branch in AXIS:
		var axis: Vector2 = AXIS[b]
		var text := T.t(HeroLoadout.BRANCH_KEY[b])
		var font := UiKit.TITLE_FONT
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE).x
		var apex := m + axis * HALF * float(TIER_AT[TalentDef.Tier.APEX]) * k
		var at := apex + Vector2(34.0, 6.0) if axis.x == 0.0 else apex + Vector2(-w * 0.5, 50.0)
		var col := Book.RUBRIC
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, col)
	var label := T.t(HeroLoadout.BRANCH_KEY[TalentDef.Branch.SUSTAIN])
	var lat := m + SUSTAIN_AT * k + Vector2(-22.0, -34.0)
	draw_string(UiKit.TITLE_FONT, lat, label, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE - 2, Book.RUBRIC)


## The plate the tree sits on (AP-4 1.5): the page's own paper inside a double rule of ink (1 px, a gap of 3, 1 px
## at 1080) with the corners cut at an angle; no slate.
func _draw_slate() -> void:
	var r := Rect2(Vector2.ZERO, size).grow(-2.0)
	var col := Color(Book.INK, 0.6)
	for inset: float in [0.0, 3.0]:
		var g := r.grow(-inset)
		var cut := BRACKET - inset
		var pts := PackedVector2Array([g.position + Vector2(cut, 0), g.position + Vector2(g.size.x - cut, 0),
			g.position + Vector2(g.size.x, cut), g.position + Vector2(g.size.x, g.size.y - cut),
			g.position + Vector2(g.size.x - cut, g.size.y), g.position + Vector2(cut, g.size.y),
			g.position + Vector2(0, g.size.y - cut), g.position + Vector2(0, cut), g.position + Vector2(cut, 0)])
		draw_polyline(pts, col, 1.0, true)


## The line from what a Gift needs (null: the centre) to it; in ivory when it is on the focused Gift's path.
func _link(from: TalentDef, to: TalentDef, path: Array[TalentDef]) -> void:
	var a := _at(from)
	var b := _at(to)
	var lit := _on(from) and _on(to)
	var locked := to.unlock_level > loadout.level()
	var col := Color(Book.FADED, 0.45 if locked else 0.85)
	var width := 1.5
	if lit:
		draw_line(a, b, Book.GILT.lightened(0.25), 3.0, true)
		col = Book.GILT
		width = 2.0
	if _focus != null and (to == _focus or path.has(to)) and (from == null or path.has(from)):
		col = Book.RUBRIC
		width = maxf(width, 2.4)
	draw_line(a, b, col, width, true)
