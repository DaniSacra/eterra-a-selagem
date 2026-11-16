class_name BodyBlock
extends RefCounted
## Solid bodies on the floor, as in Hades II (StopsUnits on the heroine and on every enemy): the paladin and the
## enemies are circles that do not walk into each other. Nobody pushes anybody by walking: whoever moves stops at
## the other's edge and slides along it, as along a wall. Only the dash goes through (Hades: the BLINK).
## A body already inside another (a dash or a lunge that ended there, a summon rising on him) may stay as deep as it
## is but never go deeper, and the enemy works its way out at EASE meters a second: no snap.

## Meters a second an overlap melts (the enemy steps out of the paladin it ended up inside).
const EASE := 3.0
const PASSES := 4
## Meters of overlap that are rounding, not a body: a step never stops on less, and a push ends exactly at the edge,
## so an overlap cannot creep deeper frame after frame.
const SLACK := 0.0001


## How deep a body at `pos` stands in another at `center` (`reach`: the sum of both radii). 0 or less: apart.
static func depth(pos: Vector2, center: Vector2, reach: float) -> float:
	return reach - pos.distance_to(center)


## How deep the body may still stand next frame in one it was `was` deep in (the overlap only melts).
static func allowance(was: float, dt: float) -> float:
	return maxf(0.0, was - EASE * dt)


## `pos` moved out of every body i until it stands no deeper than allowed[i] in it: the shortest way out of each
## (radially, so a step against a body slides along it). centers, reaches (sum of radii) and allowed run in step.
static func hold(pos: Vector2, centers: PackedVector2Array, reaches: PackedFloat32Array, allowed: PackedFloat32Array) -> Vector2:
	for pass_ in PASSES:
		var moved := false
		for i in centers.size():
			var keep := reaches[i] - allowed[i]
			if keep <= 0.0:
				continue
			var off := pos - centers[i]
			var len_sq := off.length_squared()
			if len_sq >= (keep - SLACK) * (keep - SLACK):
				continue
			var dir := off / sqrt(len_sq) if len_sq > 0.00000001 else Vector2.DOWN
			pos = centers[i] + dir * keep
			moved = true
		if not moved:
			break
	return pos


## True when `pos` stands no deeper than allowed in every body (a little rounding aside).
static func fits(pos: Vector2, centers: PackedVector2Array, reaches: PackedFloat32Array, allowed: PackedFloat32Array) -> bool:
	for i in centers.size():
		if depth(pos, centers[i], reaches[i]) > allowed[i] + SLACK:
			return false
	return true
