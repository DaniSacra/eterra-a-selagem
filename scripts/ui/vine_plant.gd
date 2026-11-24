class_name VinePlant
extends Control
## The Videira's picture on its 1280 x 720 stage (docs/art/vine_spec.md 1, 2, 5): the arch and trellis behind, the vase, the
## trunk, three curved branches and a bud on each root. Drawing only: it knows each root's state (set_states) and the one in
## focus, never the rules. `grow` (0 to 1) reveals the plant from the vase up (the opening); `water_t` runs the watering can
## over `water_id`. The painted pieces of VineArt replace the stand-ins as they appear.

const STONE := Color("50473f")
const CLAY := Color("8a5a3a")
const CLAY_DARK := Color("5a3a24")
const WOOD := Color("42301c")
const LIVE := Color("5f6b2e")
const LEAF := Color("5f6b2e")
const LEAF_LIGHT := Color("7d8a3c")
const BUD_READY := Color("8a9a4a")
const BUD_DRY := Color("5a4a3a")
const DRY_BRANCH := Color("4a463e")
const AMBER := Color("f0a040")
const WATER := Color("8fc4d8")
const TRUNK_W := Vector2(26, 18)
const BRANCH_W := Vector2(14, 6)
const BUD_R := 22.0
const CLUSTER_R := 32.0
## The can's whole run (tilt and drops), in seconds.
const WATER_TIME := 0.5

var vine: Vine
var states: Dictionary = {}
var focus_id: StringName = &""
## 0 to 1: how much of the plant is shown (the opening grows it from the vase).
var grow := 1.0
var water_id: StringName = &""
var water_t := 0.0
## The root that blooms just now (0 to 1) and which: the bud opens, the flowers show.
var bloom_id: StringName = &""
var bloom := 1.0
var _time := 0.0
var _paths: Dictionary = {}


func setup(v: Vine) -> VinePlant:
	vine = v
	name = "plant"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = VineLayout.STAGE
	for b in v.branches():
		_paths[b] = VineLayout.path(b, vine.nodes_of(b).size())
	return self


func set_states(s: Dictionary) -> void:
	states = s
	queue_redraw()


## 0 to 1: how far into the opening this root's bud shows (the buds come from the bottom up).
func reveal(id: StringName) -> float:
	var n := vine.find(id)
	var at: int = VineLayout.BUD[n.branch].size()
	return clampf(grow * (at + 1.0) - float(n.step), 0.0, 1.0)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if vine == null:
		return
	_backdrop()
	_vase_and_trunk()
	for b in vine.branches():
		_branch(b)
	for n in vine.catalog:
		_bud(n)
	for b in vine.branches():
		_branch_name(b)
	if water_id != &"":
		_can()


# ---- the arch and the trellis ----

func _backdrop() -> void:
	var tex := VineArt.texture("bg.png")
	if tex != null:
		draw_texture_rect(tex, Rect2(Vector2.ZERO, VineLayout.STAGE), false)
		return
	draw_rect(Rect2(Vector2.ZERO, VineLayout.STAGE), UiKit.INK)
	# the trellis of thin iron lozenges inside the arch (x 120..900, y 80..600), clipped to it
	var line := Color(0.30, 0.31, 0.34, 0.55)  # thin iron, dark, so the roots and the tags read over it
	var box := Rect2(120, 80, 780, 520)
	var step := 96.0
	for i in range(-8, 16):
		var x := box.position.x + i * step
		_clipped(Vector2(x, box.position.y), Vector2(x + box.size.y, box.end.y), box, line)
		_clipped(Vector2(x + box.size.y, box.position.y), Vector2(x, box.end.y), box, line)
	# two pillars and the arch in stone
	draw_rect(Rect2(94, 200, 26, 520), STONE)
	draw_rect(Rect2(900, 200, 26, 520), STONE)
	draw_set_transform(Vector2(510, 210), 0.0, Vector2(1.0, 0.44))
	draw_arc(Vector2.ZERO, 403.0, PI, TAU, 64, STONE, 28.0)
	draw_arc(Vector2.ZERO, 391.0, PI, TAU, 64, STONE.darkened(0.35), 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## A line cut to a rectangle (Liang-Barsky), so the trellis stays inside the arch.
func _clipped(a: Vector2, b: Vector2, r: Rect2, c: Color) -> void:
	var t0 := 0.0
	var t1 := 1.0
	var d := b - a
	var p := [-d.x, d.x, -d.y, d.y]
	var q := [a.x - r.position.x, r.end.x - a.x, a.y - r.position.y, r.end.y - a.y]
	for i in 4:
		if is_zero_approx(p[i]):
			if q[i] < 0.0:
				return
		else:
			var t: float = q[i] / p[i]
			if p[i] < 0.0:
				t0 = maxf(t0, t)
			else:
				t1 = minf(t1, t)
	if t0 < t1:
		draw_line(a + d * t0, a + d * t1, c, 1.0, true)


# ---- vase, trunk, branches ----

## The stand-in vase: a round clay pot (belly, rolled rim, soil, shadow on the floor), not a box.
func _clay_vase(vase: Rect2) -> void:
	var c := vase.get_center()
	draw_set_transform(Vector2(c.x, vase.end.y - 2.0), 0.0, Vector2(1.0, 0.18))
	draw_circle(Vector2.ZERO, 82.0, Color(0, 0, 0, 0.4))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var belly := PackedVector2Array()
	for i in 17:
		var t := float(i) / 16.0
		var half := lerpf(60.0, 38.0, t) * (1.0 + 0.1 * sin(t * PI))
		belly.append(Vector2(c.x - half, vase.position.y + 18.0 + t * 88.0))
	for i in range(16, -1, -1):
		var t := float(i) / 16.0
		var half := lerpf(60.0, 38.0, t) * (1.0 + 0.1 * sin(t * PI))
		belly.append(Vector2(c.x + half, vase.position.y + 18.0 + t * 88.0))
	draw_colored_polygon(belly, CLAY)
	draw_polyline(belly, CLAY_DARK, 2.5, true)
	draw_rect(Rect2(c.x - 70, vase.position.y + 8, 140, 16), CLAY.lightened(0.08))
	draw_rect(Rect2(c.x - 70, vase.position.y + 8, 140, 16), CLAY_DARK, false, 2.5)
	draw_rect(Rect2(c.x - 60, vase.position.y + 8, 120, 5), UiKit.INK.lightened(0.05))
	draw_arc(c + Vector2(-8, 18), 44.0, 1.9, 2.8, 12, CLAY.lightened(0.25), 4.0, true)

func _vase_and_trunk() -> void:
	var tex := VineArt.texture("vase.png")
	var vase := Rect2(VineLayout.VASE - Vector2(75, 55), Vector2(150, 110))
	if tex != null:
		draw_texture_rect(tex, vase, false)
	else:
		_clay_vase(vase)
	# the trunk, a little crooked, thinner towards the fork
	var base := VineLayout.TRUNK_BASE
	var pts := PackedVector2Array()
	var count := 10
	var shown := clampf(grow * 3.0, 0.0, 1.0)
	for i in count + 1:
		var t := float(i) / count
		pts.append(base.lerp(VineLayout.FORK, t) + Vector2(sin(t * 5.0) * 7.0, 0.0))
	_tapered(pts, TRUNK_W.x, TRUNK_W.y, WOOD, shown)


func _branch(branch: StringName) -> void:
	var pts: PackedVector2Array = _paths[branch]
	var nodes := vine.nodes_of(branch)
	var last := int((pts.size() - 1) * clampf(grow * 1.3 - 0.2, 0.0, 1.0))
	for i in range(0, last):
		var leg := mini(i / VineLayout.SAMPLES, nodes.size() - 1)
		var t := float(i) / (pts.size() - 1)
		var w := lerpf(BRANCH_W.x, BRANCH_W.y, t)
		var col := WOOD
		if states.get(nodes[leg].id) == Vine.State.OWNED:
			col = WOOD.lerp(LIVE, 0.85)
			w += 2.0
		elif leg > 0 and states.get(nodes[leg - 1].id) != Vine.State.OWNED:
			col = DRY_BRANCH
			w *= 0.6
		draw_line(pts[i], pts[i + 1], col, w, true)
		draw_circle(pts[i + 1], w * 0.5, col)
		if states.get(nodes[leg].id) == Vine.State.OWNED and i % 6 == 3:
			_small_leaf(pts[i], pts[i + 1] - pts[i], 1.0 if (i / 6) % 2 == 0 else -1.0)


func _tapered(pts: PackedVector2Array, w0: float, w1: float, col: Color, shown: float) -> void:
	var last := int((pts.size() - 1) * shown)
	for i in last:
		var w := lerpf(w0, w1, float(i) / (pts.size() - 1))
		draw_line(pts[i], pts[i + 1], col, w, true)
		draw_circle(pts[i + 1], w * 0.5, col)


func _branch_name(branch: StringName) -> void:
	var at: Vector2 = VineLayout.NAME_AT[branch]
	var text := T.t(StringName("vine_branch_%s" % branch))
	var size_px := 18
	var w := UiKit.TITLE_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	UiKit.draw_shadow(self, UiKit.TITLE_FONT, Vector2(at.x - w * 0.5, at.y), text, size_px)
	draw_string(UiKit.TITLE_FONT, Vector2(at.x - w * 0.5, at.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, UiKit.PALE)


# ---- the buds ----

func _bud(n: VineNode) -> void:
	var seen := reveal(n.id)
	if seen <= 0.0:
		return
	var at := VineLayout.bud(n.branch, n.step)
	var st: int = states.get(n.id, Vine.State.LOCKED)
	var k := seen
	if n.id == bloom_id:
		k *= bloom
	match st:
		Vine.State.OWNED:
			_cluster(at, k, n.id == bloom_id)
		Vine.State.AVAILABLE:
			var pulse := 0.9 + 0.1 * sin(_time * PI)
			draw_circle(at, BUD_R * 1.35 * k, Color(BUD_READY, 0.22 * pulse))
			_round_bud(at, BUD_R * k, BUD_READY, "bud_ready.png")
		Vine.State.SHORT:
			_round_bud(at, BUD_R * k, BUD_READY.darkened(0.2), "bud_closed.png")
		_:
			_round_bud(at, BUD_R * 0.62 * k, BUD_DRY, "bud_dry.png")
			draw_line(at + Vector2(-6, -3) * k, at + Vector2(5, 4) * k, BUD_DRY.darkened(0.3), 2.0)
	if n.id == focus_id:
		var r := (CLUSTER_R if st == Vine.State.OWNED else BUD_R) + 6.0
		var pulse := 0.75 + 0.25 * sin(_time * TAU / 0.6)
		draw_arc(at, r, 0.0, TAU, 40, Color(AMBER, pulse), 3.0, true)


func _round_bud(at: Vector2, r: float, col: Color, file: String) -> void:
	var tex := VineArt.texture(file)
	if tex != null:
		draw_texture_rect(tex, Rect2(at - Vector2(r, r), Vector2(r, r) * 2.0), false)
		return
	draw_circle(at, r, col.darkened(0.35))
	draw_circle(at + Vector2(-1, -2), r * 0.86, col)
	draw_circle(at + Vector2(-r * 0.3, -r * 0.35), r * 0.28, col.lightened(0.3))


## The grown root: three olive leaves and two amber flowers (the picture of cluster.png replaces them).
func _cluster(at: Vector2, k: float, fresh: bool) -> void:
	var tex := VineArt.texture("cluster.png")
	if tex != null:
		draw_texture_rect(tex, Rect2(at - Vector2(32, 32) * k, Vector2(64, 64) * k), false)
		return
	var shake := sin(_time * 18.0) * 0.06 * (1.0 - bloom) if fresh else 0.0
	for i in 3:
		var a := -PI * 0.5 + (i - 1) * 1.05 + shake
		_leaf(at + Vector2.from_angle(a) * 16.0 * k, a, 17.0 * k, LEAF if i != 1 else LEAF_LIGHT)
	draw_circle(at, 9.0 * k, LEAF.darkened(0.2))
	for i in 2:
		var p := at + Vector2(-12.0 if i == 0 else 13.0, -3.0 if i == 0 else 9.0) * k
		draw_circle(p, 9.0 * k, Color(AMBER, 0.25))
		draw_circle(p, 5.0 * k, AMBER)
		draw_circle(p, 2.0 * k, AMBER.lightened(0.5))


func _leaf(at: Vector2, angle: float, length: float, col: Color) -> void:
	draw_set_transform(at, angle, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, length * 0.5, col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _small_leaf(at: Vector2, along: Vector2, side: float) -> void:
	var a := along.angle() + side * 1.0
	_leaf(at + Vector2.from_angle(a) * 7.0, a, 13.0, LEAF)


# ---- the watering can ----

func _can() -> void:
	var n := vine.find(water_id)
	if n == null:
		return
	var at := VineLayout.bud(n.branch, n.step)
	var t := clampf(water_t / WATER_TIME, 0.0, 1.0)
	var tilt := -0.5 * clampf(t * 5.0, 0.0, 1.0)
	var home := at + Vector2(-46.0, -58.0)
	draw_set_transform(home, tilt, Vector2.ONE)
	draw_rect(Rect2(-24, -14, 40, 30), CLAY)
	draw_rect(Rect2(-24, -14, 40, 6), CLAY_DARK)
	draw_line(Vector2(16, -2), Vector2(38, 14), CLAY, 7.0, true)
	draw_arc(Vector2(-26, 0), 12.0, -PI * 0.5, PI * 0.5, 12, CLAY_DARK, 4.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if t > 0.2:
		var spout := home + Vector2(38, 14).rotated(tilt)
		for i in 8:
			var fall := fposmod(t * 3.0 + i * 0.125, 1.0)
			var p := spout.lerp(at, fall) + Vector2(sin(i * 2.1) * 4.0, 0.0)
			draw_circle(p, 2.4, Color(WATER, 1.0 - fall * 0.5))
