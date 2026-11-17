class_name UltCharge
extends RefCounted
## The ultimate's charge (D-54; ultimate_u2_proposals.md section 1): it fills with the Magia spent on Omegas (attack,
## special, circle: every spend of Magick is an Omega's) and is ready at UltDef.charge; using it empties it. Magia
## spent while an ultimate still runs already counts for the next one. Pure: Ultimates feeds it Magick.spent.

## Magia needed to fill it (UltDef.charge).
var need := 60.0
var value := 0.0
## The last Magick.spent seen (feed counts what was spent since; -1: nothing seen yet).
var _seen := -1.0


func _init(cost: float = 60.0) -> void:
	need = maxf(cost, 0.01)


## Adds Magia spent; rate: the Gifts' bonus to how fast it charges (ult_charge_pct, Coração da Emeth: 0.25).
func add(spent: float, rate: float = 0.0) -> void:
	if spent > 0.0:
		value = minf(need, value + spent * (1.0 + rate))


## Counts the Magia spent since the last call, from Magick's running total (a total that went back, a new Magick,
## starts over from it).
func feed(total_spent: float, rate: float = 0.0) -> void:
	if _seen >= 0.0 and total_spent >= _seen:
		add(total_spent - _seen, rate)
	_seen = total_spent


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
