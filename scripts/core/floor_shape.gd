class_name FloorShape
extends Resource
## The floor a room's bodies stand on, as data (RoomLayout.floor): a rectangle (the catacomb hall) or a circle (the
## Seal Chamber where Morvath fights, cycle C11). It is the edge for a point: a body of radius r keeps its middle r
## inside it. Pure (no nodes); tested in tests/test_floor_shape.gd. Positions are (x, z) in meters.

enum Kind { RECT, CIRCLE }

@export var kind := Kind.RECT
## The middle of the floor.
@export var center := Vector2.ZERO
## RECT: half its width (x) and depth (z).
@export var half := Vector2(10, 10)
## CIRCLE: its radius (the inner face of the balustrade in the chamber: 12.5).
@export var radius := 10.0


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


func is_round() -> bool:
	return kind == Kind.CIRCLE


## Meters from p to the edge (negative outside).
func edge_distance(p: Vector2) -> float:
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
	if kind == Kind.CIRCLE:
		return edge_distance(p) >= margin
	var d := p - center
	return absf(d.x) < half.x - margin and absf(d.y) < half.y - margin


## The nearest point to p where a body of radius `margin` stands wholly on the floor. The circle has no corner: a
## body pushed against its edge slides along it.
func clamp(p: Vector2, margin := 0.0) -> Vector2:
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


## The bounding half size (the rectangle's own; the circle's square).
func extent() -> Vector2:
	return half if kind == Kind.RECT else Vector2(radius, radius)
