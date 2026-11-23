class_name TrapRules
extends RefCounted
## The Armadilheiro's plates (lote C1e C): where one is laid and how many may lie. Pure: Horde lays them and the floor warns.


## Where the next plate goes: where the paladin's last dodge ended when it was under `window` s ago, else where he stands.
static func spot(hero: Vector2, dodge_end: Vector2, dodge_age: float, window: float) -> Vector2:
	return dodge_end if dodge_age <= window else hero


## Whether another plate may be laid: fewer than `most` lie and none within `gap` m of the spot.
static func may_lay(at: Vector2, laid: Array[Vector2], most: int, gap: float) -> bool:
	if laid.size() >= most:
		return false
	for p in laid:
		if p.distance_to(at) < gap:
			return false
	return true
