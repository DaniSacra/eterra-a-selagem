class_name BossRules
extends RefCounted
## The pure part of the fight with Morvath: phases by life, the stagger from heavy hits, the bullet patterns.

const PHASE_2_AT := 0.6
const PHASE_3_AT := 0.25
const STAGGER_HITS := 3
const STAGGER_FORGET := 4.0


## 1, 2 or 3 from the share of life left.
static func phase_for(hp_ratio: float) -> int:
	if hp_ratio <= PHASE_3_AT:
		return 3
	if hp_ratio <= PHASE_2_AT:
		return 2
	return 1


## Directions of a ring of bullets, turned by an offset (radians).
static func ring(count: int, offset: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in count:
		out.append(Vector2.from_angle(offset + TAU * i / count))
	return out


## Directions of a fan aimed at a target.
static func fan(aim: Vector2, count: int, spread: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in count:
		var k := 0.0 if count == 1 else float(i) / (count - 1) - 0.5
		out.append(aim.rotated(k * spread))
	return out


## Radius of the safe ground as the dark mist closes in.
static func mist_radius(elapsed: float, from: float, to: float, time: float) -> float:
	return lerpf(from, to, clampf(elapsed / time, 0.0, 1.0))
