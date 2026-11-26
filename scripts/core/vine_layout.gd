class_name VineLayout
extends RefCounted
## Where the Videira's figures stand in the sky (SW-M1, replaces the plant of vine_spec.md 1.1) and how the focus walks
## between their stars. Each branch is one figure of Eterra drawn with the nodes it already has: Vida the lion (the hero's
## sign), Provisão the chalice, Perseverança the sword; the seal and the vine are kept for branches to come. A node is found
## by its branch and its step (the offsets below are in the order of purchase, growing from the figure's root outward), so a
## branch with one more node asks one more row in NODES, not new code. Positions are WORLD px of the 1280 x 720 stage at
## zoom 1 (the whole sky); SkyCamera magnifies them. Up is growing (step + 1), left and right pass to the neighbouring
## branch on the same step. Pure data and arithmetic.

const STAGE := Vector2(1280, 720)
## The world point and the screen point of the whole sky (the camera at rest), and where a figure's centre stands when the
## camera has closed on it (left of the reading panel).
const SKY_CENTER := Vector2(640, 360)
const READ_AT := Vector2(480, 395)
const TAG_SIZE := Vector2(128, 46)
## Gap between a star and its tag, and how far the tag reaches up from the star's level.
const TAG_GAP := 20.0
## The figures' centres in the whole sky (Vida left, Provisão high in the middle, Perseverança right).
const CENTER := {&"vida": Vector2(400, 410), &"provisao": Vector2(640, 285), &"perseveranca": Vector2(880, 410)}
## Each branch's stars, offsets from its centre, step 1 first.
const NODES := {
	&"vida": [Vector2(-50, 55), Vector2(-85, 0), Vector2(-55, -65), Vector2(0, -92), Vector2(55, -65)],
	&"provisao": [Vector2(0, 45), Vector2(-65, -45), Vector2(65, -45)],
	&"perseveranca": [Vector2(0, 50), Vector2(0, -15), Vector2(0, -95)],
}
## Where each figure starts (a star that is not a node: the first line comes from it).
const ROOT := {&"vida": Vector2(0, 95), &"provisao": Vector2(0, 100), &"perseveranca": Vector2(0, 105)}
## The faint strokes that finish the figure (not nodes, nothing to buy): offsets from the centre.
const OUTLINE := {
	&"vida": [[Vector2(55, -65), Vector2(85, 0), Vector2(50, 55), Vector2(0, 95)]],
	&"provisao": [[Vector2(0, 45), Vector2(65, -45)], [Vector2(-65, -45), Vector2(-30, -52), Vector2(30, -52), Vector2(65, -45)],
		[Vector2(-40, 100), Vector2(0, 92), Vector2(40, 100)]],
	&"perseveranca": [[Vector2(-42, 50), Vector2(42, 50)],
		[Vector2(-12, 40), Vector2(-12, -70), Vector2(0, -105), Vector2(12, -70), Vector2(12, 40)]],
}
## Faint stars that are not nodes (nothing to buy, no tag): the lion's mane vertices that lost their node, and a few
## inside it that fill the mane without drawing a face (UI review 2026-11-26, item 13). Offsets from the centre.
const FAINT := {
	&"vida": [Vector2(85, 0), Vector2(50, 55), Vector2(-30, 20), Vector2(22, -34), Vector2(38, 14), Vector2(-22, -42)],
}
## The light of each figure.
const TINT := {&"vida": Color("f0b85a"), &"provisao": Color("b48cf0"), &"perseveranca": Color("78e6d2")}
## What each figure is called (text keys).
const NAME_KEY := {&"vida": &"vine_fig_vida", &"provisao": &"vine_fig_provisao", &"perseveranca": &"vine_fig_perseveranca"}
## How far under the figure's centre its name stands in the whole sky, and the screen point of the name when closed on it.
const NAME_BELOW := 140.0
const NAME_READ_AT := Vector2(480, 74)


static func center(branch: StringName) -> Vector2:
	return CENTER[branch]


static func tint(branch: StringName) -> Color:
	return TINT[branch]


static func places(branch: StringName) -> int:
	return (NODES[branch] as Array).size()


## A star's world place.
static func bud(branch: StringName, step: int) -> Vector2:
	var row: Array = NODES[branch]
	return CENTER[branch] + row[clampi(step - 1, 0, row.size() - 1)]


static func root(branch: StringName) -> Vector2:
	return CENTER[branch] + ROOT[branch]


## The figure's line of nodes from its root: the points the lit lines run through (root first, then step 1, 2, ...), only
## `count` stars long (-1: every place), so a branch with fewer nodes than places does not draw a line to nowhere.
static func chain(branch: StringName, count := -1) -> PackedVector2Array:
	var out := PackedVector2Array([root(branch)])
	var n := places(branch) if count < 0 else mini(count, places(branch))
	for step in range(1, n + 1):
		out.append(bud(branch, step))
	return out


## The faint strokes of the figure in world px.
static func outline(branch: StringName) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for stroke: Array in OUTLINE[branch]:
		var pts := PackedVector2Array()
		for p: Vector2 in stroke:
			pts.append(CENTER[branch] + p)
		out.append(pts)
	return out


## The faint stars of a figure in world px (empty for a figure without any).
static func faint(branch: StringName) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p: Vector2 in FAINT.get(branch, []):
		out.append(CENTER[branch] + p)
	return out


## Which side of its star the tag hangs on: +1 right, -1 left (the stars left of the figure's middle keep it outside).
static func tag_side(branch: StringName, step: int) -> int:
	var row: Array = NODES[branch]
	return -1 if (row[clampi(step - 1, 0, row.size() - 1)] as Vector2).x < 0.0 else 1


## The tag's top-left corner for a star seen at the screen point `star`.
static func tag_corner(branch: StringName, step: int, star: Vector2) -> Vector2:
	var x := star.x + TAG_GAP if tag_side(branch, step) > 0 else star.x - TAG_GAP - TAG_SIZE.x
	return Vector2(x, star.y - TAG_SIZE.y * 0.5)


## The camera for a whole sky and for each figure.
static func sky_camera() -> SkyCamera:
	return SkyCamera.new(SKY_CENTER, SKY_CENTER)


static func close_on(cam: SkyCamera, branch: StringName) -> void:
	cam.close_on(CENTER[branch], READ_AT)


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


## The first star to show with the focus: the lowest that can grow now (Vida first), else the first of Vida.
static func first_focus(vine: Vine, data: Dictionary) -> StringName:
	for row in 6:
		for branch in vine.branches():
			var nodes := vine.nodes_of(branch)
			if row < nodes.size() and vine.state(data, nodes[row].id) == Vine.State.AVAILABLE:
				return nodes[row].id
	return vine.nodes_of(vine.branches()[0])[0].id
