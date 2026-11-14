class_name Magick
extends RefCounted
## The paladin's Magia: the strong (held) version of a move costs it. It does not refill by itself: kills and
## the light orbs bring it back.

var max_value := 100.0
var value := 100.0


func _init(maximum: float = 100.0) -> void:
	max_value = maximum
	value = maximum


func can_pay(cost: float) -> bool:
	return value >= cost


## Spends cost when there is enough. Returns false (and spends nothing) otherwise.
func spend(cost: float) -> bool:
	if not can_pay(cost):
		return false
	value -= cost
	return true


func gain(amount: float) -> void:
	value = clampf(value + amount, 0.0, max_value)


func ratio() -> float:
	return value / max_value if max_value > 0.0 else 0.0
