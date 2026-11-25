class_name KnightPhase
extends RefCounted
## The Cavaleiro's phases by life (docs/design/sworn_rea_butcher_2026-11-25.md 2.4): each one adds a move to his list (the
## `from_life` of KnightMove and the gates of EnemyDef) and the first and last announce themselves with a roar, standing and
## hittable. Pure rules; Horde keeps the clocks. `share` is how much toughness he has left (Horde.toughness).


## How many of the marks (shares of toughness, falling) he has passed.
static func crossed(marks: PackedFloat32Array, share: float) -> int:
	var n := 0
	for m in marks:
		if share <= m:
			n += 1
	return n


## A roar is due when he has passed more marks than he has roared for.
static func roar_due(marks: PackedFloat32Array, done: int, share: float) -> bool:
	return crossed(marks, share) > done


## The guard by time is open for him: his life under `life` (1: any) and the paladin within `reach` m (0: any distance).
static func guard_open(life: float, reach: float, share: float, dist: float) -> bool:
	return share <= life and (reach <= 0.0 or dist <= reach)
