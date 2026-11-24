class_name VineLayout
extends RefCounted
## Where the Videira's roots stand on its 1280 x 720 stage (docs/art/vine_spec.md 1.1) and how the focus walks between them.
## Pure data and arithmetic: a root is found by its branch and its step, so a branch with four nodes asks one more row in
## BUD, not new code (Vida has five). Up is growing (step + 1), left and right pass to the neighbouring branch on the same step.

const STAGE := Vector2(1280, 720)
## The foot of the trunk where the three branches part, and the vase's centre.
const FORK := Vector2(490, 500)
const TRUNK_BASE := Vector2(490, 615)
const VASE := Vector2(490, 660)
## The bud centres by branch, in step order (spec 1.1).
const BUD := {
	&"vida": [Vector2(395, 452), Vector2(325, 370), Vector2(262, 288), Vector2(215, 206), Vector2(178, 124)],
	&"provisao": [Vector2(490, 390), Vector2(490, 275), Vector2(490, 160)],
	&"perseveranca": [Vector2(590, 450), Vector2(690, 330), Vector2(760, 200)],
}
## The clay tag's corner by branch and step (it stands outside the trunk: left for Vida, right for the others).
const TAG := {
	&"vida": [Vector2(245, 429), Vector2(175, 347), Vector2(112, 265), Vector2(65, 183), Vector2(28, 101)],
	&"provisao": [Vector2(512, 367), Vector2(512, 252), Vector2(512, 137)],
	&"perseveranca": [Vector2(612, 427), Vector2(712, 307), Vector2(782, 177)],
}
## Where each branch's name is written (above its last bud).
const NAME_AT := {&"vida": Vector2(178, 78), &"provisao": Vector2(490, 112), &"perseveranca": Vector2(760, 150)}
const TAG_SIZE := Vector2(128, 46)
const SAMPLES := 12


static func bud(branch: StringName, step: int) -> Vector2:
	var row: Array = BUD[branch]
	return row[clampi(step - 1, 0, row.size() - 1)]


static func tag(branch: StringName, step: int) -> Vector2:
	var row: Array = TAG[branch]
	return row[clampi(step - 1, 0, row.size() - 1)]


## The branch's stem from the fork through its buds, as a smooth curve (Catmull-Rom): SAMPLES points per leg, so the
## bud of step k stands at index k * SAMPLES. Only `count` buds long (-1: every place of the branch in BUD), so a branch
## with fewer nodes than places does not grow a stem to nowhere.
static func path(branch: StringName, count := -1) -> PackedVector2Array:
	var pts: Array[Vector2] = [FORK]
	var row: Array = BUD[branch]
	for p: Vector2 in row.slice(0, row.size() if count < 0 else mini(count, row.size())):
		pts.append(p)
	var out := PackedVector2Array()
	for i in pts.size() - 1:
		# the ends borrow a mirrored neighbour (no overshoot) and the stem leaves the fork upward
		var p0 := pts[i - 1] if i > 0 else FORK + Vector2(0, 70)
		var p3 := pts[i + 2] if i + 2 < pts.size() else pts[i + 1] * 2.0 - pts[i]
		for s in SAMPLES:
			out.append(_cr(p0, pts[i], pts[i + 1], p3, float(s) / SAMPLES))
	out.append(pts[-1])
	return out


static func _cr(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (2.0 * p1 + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)


## The id the focus goes to from `id` in a direction (Vector2.UP grows, LEFT and RIGHT change branch on the same step);
## `id` itself when there is nothing that way.
static func neighbor(vine: Vine, id: StringName, dir: Vector2) -> StringName:
	var n := vine.find(id)
	if n == null:
		return id
	var branches := vine.branches()
	var nodes := vine.nodes_of(n.branch)
	var row := nodes.find(n)
	if dir == Vector2.UP or dir == Vector2.DOWN:
		var at := row + (1 if dir == Vector2.UP else -1)
		return nodes[at].id if at >= 0 and at < nodes.size() else id
	var next := branches.find(n.branch) + (1 if dir == Vector2.RIGHT else -1)
	if next < 0 or next >= branches.size():
		return id
	var there := vine.nodes_of(branches[next])
	return there[mini(row, there.size() - 1)].id if not there.is_empty() else id


## The first root to show with the focus: the lowest that can grow now (Vida first), else the first of Vida.
static func first_focus(vine: Vine, data: Dictionary) -> StringName:
	for row in 6:
		for branch in vine.branches():
			var nodes := vine.nodes_of(branch)
			if row < nodes.size() and vine.state(data, nodes[row].id) == Vine.State.AVAILABLE:
				return nodes[row].id
	return vine.nodes_of(vine.branches()[0])[0].id
