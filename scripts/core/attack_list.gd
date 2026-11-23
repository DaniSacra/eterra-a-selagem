class_name AttackList
extends RefCounted
## A guardian's priority list with a cooldown for each move (docs/design/sworn_gawain.md): pure rules, Horde keeps the
## clocks (Enemy.move_cd, one per move index) and acts on the index returned.


## The cooldown clocks a fight starts with: each move's `first`.
static func start_clocks(moves: Array[KnightMove]) -> Array[float]:
	var out: Array[float] = []
	for m in moves:
		out.append(m.first)
	return out


## Whether move `m` is open: its life gate, its distance and its clock (seconds left, <= 0 ready).
static func open(m: KnightMove, life_share: float, dist: float, clock: float) -> bool:
	if life_share > m.from_life or clock > 0.0 or dist < m.min_dist:
		return false
	return m.max_dist <= 0.0 or dist <= m.max_dist


## Index of the first open move, -1 when none is. `ready` is false while nothing may start (resting, shield away...).
static func pick(moves: Array[KnightMove], clocks: Array[float], life_share: float, dist: float, ready := true) -> int:
	if not ready:
		return -1
	for i in moves.size():
		if open(moves[i], life_share, dist, clocks[i]):
			return i
	return -1
