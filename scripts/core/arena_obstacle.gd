class_name ArenaObstacle
extends Resource
## One thing standing on an arena's floor that the fight has to deal with (cycle C12, the classes of Daniel's brief:
## B stops bodies, C stops shots; the abyss is a hole of the FloorShape, not an obstacle). Its collision and its
## look come from this same data (RoomLayout.obstacles): Arena turns it into what blocks, the arena's look draws
## `piece` on the same footprint. Pure (no nodes). Positions are (x, z) in meters.

enum Shape { CIRCLE, BOX }

@export var shape := Shape.CIRCLE
@export var center := Vector2.ZERO
## CIRCLE: its radius.
@export var radius := 0.6
## BOX: half its size along its own axes, and its turn (radians, around the up axis; x toward z positive).
@export var half := Vector2(1.0, 0.5)
@export var yaw := 0.0
## Nobody walks through it (B).
@export var blocks_move := true
## Shots die on it, the shooters' line of fire stops at it (C).
@export var blocks_shots := true
## Tall enough to hide the paladin: its look opens in a stipple around him (the see_through of masonry.gdshader).
@export var see_through := false
## What the look draws there: column, sarcophagus, block, trunk, root, statue.
@export var piece: StringName = &"block"
## Height of the piece (meters; the look's, and whether it is low enough to see over).
@export var height := 1.0


static func circle(at: Vector2, r: float, what: StringName, h: float, shots := true, see := false) -> ArenaObstacle:
	var o := ArenaObstacle.new()
	o.shape = Shape.CIRCLE
	o.center = at
	o.radius = r
	o.piece = what
	o.height = h
	o.blocks_shots = shots
	o.see_through = see
	return o


static func box(at: Vector2, half_size: Vector2, turn: float, what: StringName, h: float, shots := true, see := false) -> ArenaObstacle:
	var o := ArenaObstacle.new()
	o.shape = Shape.BOX
	o.center = at
	o.half = half_size
	o.yaw = turn
	o.piece = what
	o.height = h
	o.blocks_shots = shots
	o.see_through = see
	return o


## The corners of a box (in order round it), or a 16-sided outline of a circle.
func outline() -> PackedVector2Array:
	var out := PackedVector2Array()
	if shape == Shape.CIRCLE:
		for k in 16:
			out.append(center + Vector2.from_angle(TAU * k / 16.0) * radius)
		return out
	var ax := Vector2(cos(yaw), sin(yaw))
	var az := Vector2(-ax.y, ax.x)
	for c: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		out.append(center + ax * half.x * c.x + az * half.y * c.y)
	return out


## True when it lies square to the axes (a box Arena keeps as a Rect2).
func square() -> bool:
	return shape == Shape.BOX and is_zero_approx(fmod(absf(yaw), PI * 0.5))


## The box as a Rect2 on the floor (square() boxes; a turn of 90 degrees swaps its sides).
func rect() -> Rect2:
	var h := half if is_zero_approx(fmod(absf(yaw), PI)) else Vector2(half.y, half.x)
	return Rect2(center - h, h * 2.0)


## How far a body of radius r at p stands inside it (0 or less: clear of it).
func depth(p: Vector2, r: float) -> float:
	if shape == Shape.CIRCLE:
		return radius + r - p.distance_to(center)
	var local := (p - center).rotated(-yaw)
	var q := local.clamp(-half, half)
	if q != local:
		return r - local.distance_to(q)
	return r + minf(half.x - absf(local.x), half.y - absf(local.y))


## Where a body of radius r at p goes to stand just clear of it (p when it already does).
func push_out(p: Vector2, r: float) -> Vector2:
	if depth(p, r) <= 0.0:
		return p
	if shape == Shape.CIRCLE:
		var d := p - center
		return center + (d.normalized() if d.length_squared() > 0.0001 else Vector2.DOWN) * (radius + r)
	var local := (p - center).rotated(-yaw)
	var q := local.clamp(-half, half)
	var out: Vector2
	if q != local:
		out = q + (local - q).normalized() * r
	elif half.x - absf(local.x) < half.y - absf(local.y):
		out = Vector2(signf(local.x if local.x != 0.0 else 1.0) * (half.x + r), local.y)
	else:
		out = Vector2(local.x, signf(local.y if local.y != 0.0 else 1.0) * (half.y + r))
	return center + out.rotated(yaw)


## Where along the segment a to b (0 to 1) it is first touched by a shot of radius r, or -1 when never.
func hit_by(a: Vector2, b: Vector2, r: float = 0.0) -> float:
	if a.distance_squared_to(b) < 0.0000001:
		return 0.0 if depth(a, r) > 0.0 else -1.0
	if shape == Shape.CIRCLE:
		if a.distance_to(center) < radius + r:
			return 0.0
		return Geometry2D.segment_intersects_circle(a, b, center, radius + r)
	var la := (a - center).rotated(-yaw)
	var lb := (b - center).rotated(-yaw)
	var h := half + Vector2(r, r)
	# the slab test on the box grown by r (a shot is a point grown by its radius)
	var t0 := 0.0
	var t1 := 1.0
	var d := lb - la
	for axis in 2:
		var s := d[axis]
		var o := la[axis]
		if absf(s) < 0.0000001:
			if absf(o) > h[axis]:
				return -1.0
			continue
		var ta := (-h[axis] - o) / s
		var tb := (h[axis] - o) / s
		t0 = maxf(t0, minf(ta, tb))
		t1 = minf(t1, maxf(ta, tb))
		if t0 > t1:
			return -1.0
	return t0


## The same obstacle seen in a mirror across x = 0 (an arena's mirrored variant).
func mirrored() -> ArenaObstacle:
	var o := duplicate() as ArenaObstacle
	o.center.x = -center.x
	o.yaw = -yaw
	return o
