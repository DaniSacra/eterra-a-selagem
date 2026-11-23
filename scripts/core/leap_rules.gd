class_name LeapRules
extends RefCounted
## The Saltador's jump (lote C1e B): four corners in L round the spot it will land on, a square, never a filled disc. Pure: Horde steps it
## and C1eMarks draws it.

## The corners start this many times the square's half-side from its middle and close to it over the wind-up.
const OPEN := 1.9
## How far each arm of an L reaches along the square's edge (meters).
const ARM := 0.7
## The highest the body gets over the floor in a jump (meters).
const PEAK := 2.6


## True when `p` (the paladin's body, `margin` wide) is inside the square of half-side `half` round `land`.
static func in_area(land: Vector2, p: Vector2, half: float, margin: float = 0.0) -> bool:
	var d := (p - land).abs()
	return d.x <= half + margin and d.y <= half + margin


## Where the jump is `t` seconds in, of `total`: straight from `from` to `to`.
static func pos_at(from: Vector2, to: Vector2, t: float, total: float) -> Vector2:
	return from.lerp(to, clampf(t / maxf(total, 0.001), 0.0, 1.0))


## Its height over the floor `t` seconds into a jump of `total`: up and down in one arc.
static func height_at(t: float, total: float) -> float:
	return sin(clampf(t / maxf(total, 0.001), 0.0, 1.0) * PI) * PEAK


## How far from the middle a corner is (along each axis) `t` seconds into a wind-up of `windup`: open at first, on the square's edge at the end.
static func corner_at(t: float, windup: float, half: float) -> float:
	return lerpf(half * OPEN, half, clampf(t / maxf(windup, 0.001), 0.0, 1.0))


## The spot to land on: where the paladin is while the aim follows, held the last `lock` seconds of a wind-up of `windup`.
static func follows(t: float, windup: float, lock: float) -> bool:
	return t < windup - lock


## Seconds from the first mark to the landing: the warning the paladin has (never under 0.7 s).
static func warning(windup: float, flight: float) -> float:
	return windup + flight
