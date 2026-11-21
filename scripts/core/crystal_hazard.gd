class_name CrystalHazard
extends RefCounted
## The crystals that discharge (RP-14, H-5; docs/design/rooms_progression.md, combat_cadence.md 9.3): the Hades II's
## steam cube, a hazard the paladin uses. Each crystal (HazardDef.crystals, off the floor by the north wall of the
## Câmara das Runas Instáveis B) takes a charge from every blow of his that touches it; at HazardDef.crystal_hits it
## discharges at once along its column of tiles (HazardDef.crystal_cols): the runes' floor warms that column up and
## strikes everyone on it (ArenaHazard.discharge, RuneFloor). While a discharge is on the floor no crystal takes a
## charge (so a full one never waits, hidden). Asleep before HazardDef.crystal_from (awake false: no charge). Pure.

var def: HazardDef
var awake := true
## Each crystal's charges (0 to crystal_hits - 1; it discharges and empties at crystal_hits).
var charge := PackedInt32Array()
## How many blows charged a crystal, and how many discharges.
var charged := 0
var discharged := 0


func _init(hazard: HazardDef, is_awake := true) -> void:
	def = hazard
	awake = is_awake
	charge.resize(def.crystals.size())


func count() -> int:
	return def.crystals.size()


## A blow of the paladin (the shape of Combat.reached). busy: a discharge is on the floor now (no charge is taken).
## Returns {"charged": crystals that took a charge and are not full, "full": the crystal that discharges now (-1:
## none)}. At most one crystal fills from one blow (the first in order).
func hit(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float, busy: bool) -> Dictionary:
	var took := PackedInt32Array()
	var full := -1
	if not awake or busy:
		return {"charged": took, "full": full}
	for i in count():
		if not ColumnFall.touches(shape, origin, dir, reach, width, def.crystals[i], def.crystal_radius):
			continue
		if full >= 0:
			continue
		charge[i] += 1
		charged += 1
		if charge[i] >= def.crystal_hits:
			charge[i] = 0
			full = i
			discharged += 1
		else:
			took.append(i)
	return {"charged": took, "full": full}


## The column crystal i discharges along.
func col(i: int) -> int:
	return def.crystal_cols[i] if i < def.crystal_cols.size() else -1


## How full crystal i is (0 to 1 short of discharging).
func fill(i: int) -> float:
	return float(charge[i]) / maxf(1.0, def.crystal_hits)
