class_name GapRule
extends RefCounted
## PT-25-9, the crossing only a dash makes (Daniel, 2026-11-25; the SWORN's narrow streams and rifts): a rectangle of the
## floor (RoomLayout.gaps, a stream or a rift of 2 to 4 m) that walking does not cross and the dodge does (5.6 m). A body
## on foot that would step into it stays on the edge it came from; one that comes out of a dash inside it (or stands in it
## some other way) is put on the nearest edge, and hurt `fall` if the room says so ("a fall hurts and gives back the
## floor": nothing kills here). Pure: rectangles in, a point out. Player.step and Bot read it through Arena.
##   GapRule.keep_out(gaps, from, to)  where the walker ends this step
##   GapRule.inside(gaps, p)           the index of the gap p stands in (-1: none)
##   GapRule.hop(gaps, p, goal, reach) the unit direction to dash toward to cross (the robot's), or ZERO

## How near the edge a hop starts, and how far past the goal's side it is aimed (m).
const HOP_EDGE := 0.9
## The share of a dash's reach that counts when planning a hop (a dash slows as it goes).
const REACH_SHARE := 0.85


## The index of the first gap holding p (-1: none).
static func inside(gaps: Array[Rect2], p: Vector2) -> int:
	for i in gaps.size():
		if gaps[i].has_point(p):
			return i
	return -1


## Where a walker that moves from `from` to `to` ends. Into a gap from outside: on the edge of the side it came from
## (just outside, a hair off). Already inside (landed there): the nearest edge.
static func keep_out(gaps: Array[Rect2], from: Vector2, to: Vector2) -> Vector2:
	var i := inside(gaps, to)
	if i < 0:
		return to
	var r := gaps[i]
	if not r.has_point(from):
		return _edge_of_side(r, from, to)
	return nearest_edge(r, to)


## The side of the rectangle `from` stands on (the one it is farthest out of), and the point on that edge in line with `to`.
static func _edge_of_side(r: Rect2, from: Vector2, to: Vector2) -> Vector2:
	var left := r.position.x - from.x
	var right := from.x - r.end.x
	var up := r.position.y - from.y
	var down := from.y - r.end.y
	var most := maxf(maxf(left, right), maxf(up, down))
	if most == left:
		return Vector2(r.position.x - EDGE, clampf(to.y, r.position.y, r.end.y))
	if most == right:
		return Vector2(r.end.x + EDGE, clampf(to.y, r.position.y, r.end.y))
	if most == up:
		return Vector2(clampf(to.x, r.position.x, r.end.x), r.position.y - EDGE)
	return Vector2(clampf(to.x, r.position.x, r.end.x), r.end.y + EDGE)


## A hair outside the edge, so the body stands on floor and not on the line.
const EDGE := 0.02


## The nearest point just outside the rectangle.
static func nearest_edge(r: Rect2, p: Vector2) -> Vector2:
	var to_left := p.x - r.position.x
	var to_right := r.end.x - p.x
	var to_up := p.y - r.position.y
	var to_down := r.end.y - p.y
	var least := minf(minf(to_left, to_right), minf(to_up, to_down))
	if least == to_left:
		return Vector2(r.position.x - EDGE, p.y)
	if least == to_right:
		return Vector2(r.end.x + EDGE, p.y)
	if least == to_up:
		return Vector2(p.x, r.position.y - EDGE)
	return Vector2(p.x, r.end.y + EDGE)


## The robot's hop: standing on foot within HOP_EDGE of a gap that lies between it and `goal`, the direction of the dash
## that carries it across (toward the goal, straight over the narrowest way); ZERO when none is needed or it cannot (the gap
## wider along that way than `reach` times REACH_SHARE).
static func hop(gaps: Array[Rect2], p: Vector2, goal: Vector2, reach: float) -> Vector2:
	var way := goal - p
	if way.length() < 0.01:
		return Vector2.ZERO
	for r in gaps:
		var near := r.grow(HOP_EDGE)
		if not near.has_point(p) or r.has_point(p):
			continue
		if _across(r, p, goal) <= 0.0:
			continue
		# across the narrow side: the dash goes square to the nearer long edge unless the goal is along it
		var dir := way.normalized()
		var depth := _depth_along(r, p, dir)
		if depth <= reach * REACH_SHARE:
			return dir
	return Vector2.ZERO


## How much of the segment a to b lies inside r (0: it never touches it).
static func _across(r: Rect2, a: Vector2, b: Vector2) -> float:
	var d := b - a
	var t0 := 0.0
	var t1 := 1.0
	for axis in 2:
		var lo: float = r.position[axis]
		var hi: float = r.end[axis]
		var s: float = a[axis]
		var v: float = d[axis]
		if absf(v) < 0.00001:
			if s < lo or s > hi:
				return 0.0
			continue
		var ta := (lo - s) / v
		var tb := (hi - s) / v
		t0 = maxf(t0, minf(ta, tb))
		t1 = minf(t1, maxf(ta, tb))
		if t0 > t1:
			return 0.0
	return (t1 - t0) * d.length()


## The metres from p along dir to the far side of r (the ray leaves the rectangle there), from where it first meets it.
static func _depth_along(r: Rect2, p: Vector2, dir: Vector2) -> float:
	var far := 0.0
	var t0 := 0.0
	var t1 := INF
	for axis in 2:
		var lo: float = r.position[axis]
		var hi: float = r.end[axis]
		var s: float = p[axis]
		var v: float = dir[axis]
		if absf(v) < 0.00001:
			if s < lo or s > hi:
				return INF
			continue
		var ta := (lo - s) / v
		var tb := (hi - s) / v
		t0 = maxf(t0, minf(ta, tb))
		t1 = minf(t1, maxf(ta, tb))
	far = t1
	return far if t1 > t0 else INF
