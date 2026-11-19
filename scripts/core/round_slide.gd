class_name RoundSlide
extends RefCounted
## A body walking into a round piece (a pillar, the hub's fountain: Arena.pillars) slides round it at its own speed
## instead of standing against it; pushed exactly at its middle it always goes round by the same side (HUB-B1, hub_spec_art.md 2.2:
## never stopped on the axis). Only the hub's walk uses it (Player._step_peace): the run keeps Arena.resolve's push.

## How far past touching a piece the slide already turns the step (meters).
const REACH := 0.05
## Under this share of the step left once the part going into the piece is taken off, the move counts as head-on.
const HEAD_ON := 0.02


## The way to walk this frame: move (a direction, any length) turned along the first round piece it walks into
## (circles: x, z and radius), its length kept; move as it is when nothing is in the way.
## step: meters walked this frame; radius: the body's.
static func steer(pos: Vector2, move: Vector2, step: float, radius: float, circles: Array[Vector3]) -> Vector2:
	if move.length_squared() < 0.000001:
		return move
	for c in circles:
		var to := Vector2(c.x, c.y) - pos
		var reach := c.z + radius
		var dist := to.length()
		if dist < 0.0001 or dist > reach + step + REACH or move.dot(to) <= 0.0:
			continue
		var n := to / dist
		var slid := move - n * move.dot(n)
		var side := slid.normalized() if slid.length() > move.length() * HEAD_ON else n.orthogonal()
		return side * move.length()
	return move
