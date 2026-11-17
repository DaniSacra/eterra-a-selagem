class_name UltCharge
extends RefCounted
## The ultimate's charge (D-54; ultimate_u2_proposals.md section 1): it fills with the Magia spent on Omegas (attack,
## special, circle: every spend of Magick is an Omega's) and, since T5 (docs/design/t5_ultimate.md), with the damage
## the hero deals and the life he loses (UltDef.damage_charge, hurt_charge); it is ready at UltDef.charge; using it
## empties it. What is spent or dealt while an ultimate still runs already counts for the next one. Pure: Ultimates
## feeds it running totals (Magick.spent, DealtBy.total without the ultimate's own hits).

## Magia needed to fill it (UltDef.charge).
var need := 60.0
var value := 0.0
## The last running total seen of each source (feed counts what was added since; none yet: nothing seen).
var _seen: Dictionary = {}


func _init(cost: float = 60.0) -> void:
	need = maxf(cost, 0.01)


## Adds Magia spent; rate: the Gifts' bonus to how fast it charges (ult_charge_pct, Coração da Emeth: 0.25).
func add(spent: float, rate: float = 0.0) -> void:
	if spent > 0.0:
		value = minf(need, value + spent * (1.0 + rate))


## Counts the Magia spent since the last call, from Magick's running total (a total that went back, a new Magick,
## starts over from it).
func feed(total_spent: float, rate: float = 0.0) -> void:
	feed_from(&"magick", total_spent, 1.0, rate)


## The same for any running total (source names it): what it grew since the last call, times weight (charge per unit).
func feed_from(source: StringName, total: float, weight: float, rate: float = 0.0) -> void:
	if _seen.has(source) and total >= float(_seen[source]):
		add((total - float(_seen[source])) * weight, rate)
	_seen[source] = total


func ready() -> bool:
	return value >= need - 0.001


## 0..1: how full it is.
func ratio() -> float:
	return clampf(value / need, 0.0, 1.0)


## Spends it when ready; false (and nothing changes) otherwise.
func use() -> bool:
	if not ready():
		return false
	value = 0.0
	return true


func fill() -> void:
	value = need
