class_name FloorShape
extends Resource
## The floor a room's bodies stand on, as data (RoomLayout.floor): a rectangle (the catacomb hall), a circle (the
## Seal Chamber where Morvath fights, cycle C11) or polygons (the arenas of cycle C12: a union of simple polygons, less
## the holes cut into it, the abyss inside a room). It is the edge for a point: a body of radius r keeps its middle r
## inside it. Pure (no nodes); tested in tests/test_floor_shape.gd and tests/test_floor_poly.gd. Positions are (x, z)
## in meters.

enum Kind { RECT, CIRCLE, POLY }

@export var kind := Kind.RECT
## The middle of the floor.
@export var center := Vector2.ZERO
## RECT: half its width (x) and depth (z).
@export var half := Vector2(10, 10)
## CIRCLE: its radius (the inner face of the balustrade in the chamber: 12.5).
@export var radius := 10.0
## POLY: the floor is every point inside one of `polys` (simple polygons, either winding; they may overlap) and in
## none of `holes` (the abyss cut into it).
@export var polys: Array[PackedVector2Array] = []
@export var holes: Array[PackedVector2Array] = []

## POLY: the parts of the polygons' and holes' sides that are a real edge of the floor (floor on one side, none on
## the other), as pairs of points, and the floor side of each (unit); made on first use (_edges).
var _seg_a := PackedVector2Array()
var _seg_b := PackedVector2Array()
var _seg_in := PackedVector2Array()
var _made := false
## How far off a side (meters) _edges looks for which side of it is floor.
const SIDE_PROBE := 0.01


static func rect(half_size: Vector2, at := Vector2.ZERO) -> FloorShape:
	var s := FloorShape.new()
	s.kind = Kind.RECT
	s.half = half_size
	s.center = at
	return s


static func circle(r: float, at := Vector2.ZERO) -> FloorShape:
	var s := FloorShape.new()
	s.kind = Kind.CIRCLE
	s.radius = r
	s.center = at
	return s


## A floor of polygons (union) less holes; centered on nothing in particular.
static func poly(walk: Array[PackedVector2Array], cut: Array[PackedVector2Array] = []) -> FloorShape:
	var s := FloorShape.new()
	s.kind = Kind.POLY
	s.polys = walk
	s.holes = cut
	return s


## This floor with more walkable polygons (the mouths of the doors used): a new POLY floor (a rectangle becomes its
## polygon).
func joined(extra: Array[PackedVector2Array]) -> FloorShape:
	var walk: Array[PackedVector2Array] = []
	if kind == Kind.POLY:
		walk.append_array(polys)
	elif kind == Kind.RECT:
		walk.append(PackedVector2Array([center - half, center + Vector2(half.x, -half.y), center + half, center + Vector2(-half.x, half.y)]))
	else:
		return self
	walk.append_array(extra)
	return FloorShape.poly(walk, holes.duplicate())


## The four corners of a rectangle, as a polygon.
static func box(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])


func is_round() -> bool:
	return kind == Kind.CIRCLE


## True when the point is on the floor at all (POLY: in a polygon, in no hole; the others: edge_distance >= 0).
func covers(p: Vector2) -> bool:
	if kind != Kind.POLY:
		return edge_distance(p) >= 0.0
	for h in holes:
		if Geometry2D.is_point_in_polygon(p, h):
			return false
	for q in polys:
		if Geometry2D.is_point_in_polygon(p, q):
			return true
	return false


## Meters from p to the edge (negative outside).
func edge_distance(p: Vector2) -> float:
	if kind == Kind.POLY:
		var near := sqrt(_nearest_edge_sq(p))
		return near if covers(p) else -near
	var d := p - center
	if kind == Kind.CIRCLE:
		return radius - d.length()
	var out := Vector2(absf(d.x), absf(d.y)) - half
	if out.x > 0.0 or out.y > 0.0:
		return -Vector2(maxf(out.x, 0.0), maxf(out.y, 0.0)).length()
	return -maxf(out.x, out.y)


## True when a body of radius `margin` at p stands wholly on the floor (strictly inside for the rectangle, as
## Arena.inside always was).
func contains(p: Vector2, margin := 0.0) -> bool:
	if kind == Kind.POLY:
		if not covers(p):
			return false
		return margin <= 0.0 or _nearest_edge_sq(p) >= margin * margin
	if kind == Kind.CIRCLE:
		return edge_distance(p) >= margin
	var d := p - center
	return absf(d.x) < half.x - margin and absf(d.y) < half.y - margin


## The nearest point to p where a body of radius `margin` stands wholly on the floor. The circle has no corner: a
## body pushed against its edge slides along it.
func clamp(p: Vector2, margin := 0.0) -> Vector2:
	if kind == Kind.POLY:
		return _clamp_poly(p, margin)
	if kind == Kind.CIRCLE:
		var r := maxf(radius - margin, 0.0)
		var d := p - center
		return p if d.length_squared() <= r * r else center + d.normalized() * r
	var h := Vector2(maxf(half.x - margin, 0.0), maxf(half.y - margin, 0.0))
	return p.clamp(center - h, center + h)


## How far along `dir` (unit) from `from` a body of radius `margin` stays on the floor, at most `length` (0 when
## `from` is already off it for that body). Cuts a charge, a lane or a flight at the edge.
func cut(from: Vector2, dir: Vector2, length: float, margin := 0.0) -> float:
	if dir.length_squared() < 0.000001:
		return 0.0
	var u := dir.normalized()
	if kind == Kind.POLY:
		return _cut_poly(from, u, length, margin)
	if kind == Kind.CIRCLE:
		var r := radius - margin
		var f := from - center
		var b := f.dot(u)
		var c := f.length_squared() - r * r
		if c > 0.0:
			return 0.0
		# the far root of |f + t u| = r (from is inside: c <= 0, so it is >= 0)
		return clampf(-b + sqrt(maxf(b * b - c, 0.0)), 0.0, length)
	var h := half - Vector2(margin, margin)
	var p := from - center
	if absf(p.x) > h.x or absf(p.y) > h.y:
		return 0.0
	var t := length
	if absf(u.x) > 0.000001:
		t = minf(t, ((h.x if u.x > 0.0 else -h.x) - p.x) / u.x)
	if absf(u.y) > 0.000001:
		t = minf(t, ((h.y if u.y > 0.0 else -h.y) - p.y) / u.y)
	return clampf(t, 0.0, length)


## The bounding half size around `center` (the rectangle's own; the circle's square; the polygons' box, measured from
## the origin as their center is).
func extent() -> Vector2:
	if kind == Kind.POLY:
		var b := bounds()
		return Vector2(maxf(absf(b.position.x), absf(b.end.x)), maxf(absf(b.position.y), absf(b.end.y)))
	return half if kind == Kind.RECT else Vector2(radius, radius)


## The box around the whole floor (x, z).
func bounds() -> Rect2:
	if kind == Kind.CIRCLE:
		return Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0)
	if kind == Kind.RECT:
		return Rect2(center - half, half * 2.0)
	var b := Rect2()
	var first := true
	for q in polys:
		for v in q:
			if first:
				b = Rect2(v, Vector2.ZERO)
				first = false
			else:
				b = b.expand(v)
	return b


## POLY: the real edges of the floor as pairs of points (a0, b0, a1, b1...), for drawing its cliffs and for tests.
func edges() -> PackedVector2Array:
	_edges()
	var out := PackedVector2Array()
	for i in _seg_a.size():
		out.append(_seg_a[i])
		out.append(_seg_b[i])
	return out


## POLY: the side of edge i (edges() pair i) the floor is on (unit, on the floor plane).
func edge_inward(i: int) -> Vector2:
	_edges()
	return _seg_in[i]


## POLY: forget the edges worked out (after the polygons were changed).
func changed() -> void:
	_made = false


# ---------- polygons ----------

## Splits every side of the polygons and holes where it crosses another's, and keeps the pieces that are a real edge
## of the floor: floor just on one side of them, none just on the other.
func _edges() -> void:
	if _made:
		return
	_made = true
	_seg_a.clear()
	_seg_b.clear()
	_seg_in.clear()
	var all: Array[PackedVector2Array] = []
	all.append_array(polys)
	all.append_array(holes)
	for q in all:
		for i in q.size():
			var a := q[i]
			var b := q[(i + 1) % q.size()]
			if a.distance_squared_to(b) < 0.000001:
				continue
			var cuts: Array[float] = [0.0, 1.0]
			for r in all:
				for j in r.size():
					var hit: Variant = Geometry2D.segment_intersects_segment(a, b, r[j], r[(j + 1) % r.size()])
					if hit != null:
						cuts.append(clampf(((hit as Vector2) - a).length() / a.distance_to(b), 0.0, 1.0))
			cuts.sort()
			var along := (b - a).normalized()
			var side := Vector2(-along.y, along.x)
			for k in cuts.size() - 1:
				if cuts[k + 1] - cuts[k] < 0.0001:
					continue
				var m := a.lerp(b, (cuts[k] + cuts[k + 1]) * 0.5)
				var left := covers(m + side * SIDE_PROBE)
				var right := covers(m - side * SIDE_PROBE)
				if left == right:
					continue
				_seg_a.append(a.lerp(b, cuts[k]))
				_seg_b.append(a.lerp(b, cuts[k + 1]))
				_seg_in.append(side if left else -side)


## The square of the distance from p to the nearest real edge.
func _nearest_edge_sq(p: Vector2) -> float:
	_edges()
	var best := INF
	for i in _seg_a.size():
		var q := Geometry2D.get_closest_point_to_segment(p, _seg_a[i], _seg_b[i])
		best = minf(best, q.distance_squared_to(p))
	return best


## The nearest point to p where a body of radius margin stands wholly on the floor: p itself when it does; else it is
## put `margin` inside its nearest edge, again from there (a corner needs two), until it fits.
func _clamp_poly(p: Vector2, margin: float) -> Vector2:
	if contains(p, margin):
		return p
	_edges()
	if _seg_a.is_empty():
		return p
	var m := maxf(margin, 0.0) + 0.0005
	var c := p
	for k in CLAMP_TRIES:
		var i := _nearest_edge(c)
		var q := Geometry2D.get_closest_point_to_segment(c, _seg_a[i], _seg_b[i])
		var away := c - q
		if covers(c) and away.length_squared() > 0.00000001:
			c = q + away.normalized() * m
		else:
			c = q + _seg_in[i] * m
		if contains(c, margin):
			return c
	return c


## Times _clamp_poly moves a point in before giving up (a corner takes two; a gap narrower than the body never fits).
const CLAMP_TRIES := 8


## The index of the edge nearest to p.
func _nearest_edge(p: Vector2) -> int:
	var best := -1
	var best_d := INF
	for i in _seg_a.size():
		var d := Geometry2D.get_closest_point_to_segment(p, _seg_a[i], _seg_b[i]).distance_squared_to(p)
		if d < best_d:
			best_d = d
			best = i
	return best


## How far along u from `from` a body of radius margin stays on the floor (marched in short steps, then narrowed).
func _cut_poly(from: Vector2, u: Vector2, length: float, margin: float) -> float:
	if not contains(from, margin):
		return 0.0
	var step := CUT_STEP
	var t := 0.0
	while t < length:
		var next := minf(t + step, length)
		if not contains(from + u * next, margin):
			var lo := t
			var hi := next
			for k in 12:
				var mid := (lo + hi) * 0.5
				if contains(from + u * mid, margin):
					lo = mid
				else:
					hi = mid
			return lo
		t = next
	return length


## Meters between two looks along a line (_cut_poly): under the narrowest thing a floor may have (a bridge).
const CUT_STEP := 0.2
