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


## Beyond this distance (m) the king does not choose his sword slashes.
const SLASH_CHOICE_RANGE := 12.0


## The attacks Morvath may choose next: what the phase allows, never his slashes from afar, and not the last one
## again unless nothing else is left. Never empty: an empty list made `randi() % 0` crash the exported game
## (phase 1, the paladin far away, right after a dash).
static func attacks(phase: int, dist: float, last: StringName, can_summon: bool) -> Array[StringName]:
	var out: Array[StringName] = [&"slashes", &"dash"]
	if phase >= 2:
		out.append(&"rain")
		if can_summon:
			out.append(&"summon")
	if phase >= 3:
		out.append(&"volley")
		out.append(&"volley")
	if dist > SLASH_CHOICE_RANGE:
		out.erase(&"slashes")
	var fresh := out.duplicate()
	fresh.erase(last)
	return fresh if not fresh.is_empty() else out


## Skeletons Morvath would raise in one summon at this phase (few, as the first boss of Hades II brings few helpers).
static func summon_want(phase: int) -> int:
	return 2 + phase


## Most of his reinforcements standing at once at this phase (caps: one per phase, the last holds after; empty: no
## ceiling of his own).
static func adds_cap(caps: PackedInt32Array, phase: int) -> int:
	if caps.is_empty():
		return 1 << 30
	return caps[clampi(phase - 1, 0, caps.size() - 1)]


## Skeletons one summon raises with `adds` of his reinforcements already standing: fewer near the ceiling, none at it.
static func summon_count(phase: int, adds: int, caps: PackedInt32Array) -> int:
	return EncounterGen.room_for(adds, adds_cap(caps, phase), summon_want(phase))


## Radius of the safe ground as the dark mist closes in.
static func mist_radius(elapsed: float, from: float, to: float, time: float) -> float:
	return lerpf(from, to, clampf(elapsed / time, 0.0, 1.0))
