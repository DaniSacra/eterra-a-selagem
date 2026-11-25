class_name WallAim
extends RefCounted
## RD2-10: where a charge ends against the wall. Pure: the distance along a line from `from` toward `dir` at which a body is
## pushed back by the floor (`pushed`: Callable(Vector2) -> bool, true when the point is not free), within `reach`; -1 when
## the charge ends in the open. WallMark lays it on the floor so the paladin reads which wall the knight will hit.

const STEP := 0.25


static func hit_at(from: Vector2, dir: Vector2, reach: float, pushed: Callable) -> float:
	if dir.length_squared() < 0.0001:
		return -1.0
	var d := dir.normalized()
	var s := STEP
	while s <= reach:
		if pushed.call(from + d * s):
			return s
		s += STEP
	return -1.0
