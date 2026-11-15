class_name CurseState
extends RefCounted
## A curse on the paladin (Morvath's last phases): for a few seconds he walks slower and one action is locked,
## never his walking or his dodge. Right after it ends he is immune to a new one for a moment.

var left := 0.0
var total := 0.0
var slow := 0.0
var immune_left := 0.0
var _immunity := 0.0


## Puts the curse on him. False (and nothing changes) while cursed or still immune.
func apply(seconds: float, slow_share: float, immunity: float) -> bool:
	if active() or immune_left > 0.0 or seconds <= 0.0:
		return false
	left = seconds
	total = seconds
	slow = clampf(slow_share, 0.0, 0.9)
	_immunity = immunity
	return true


func step(dt: float) -> void:
	if left > 0.0:
		left -= dt
		if left <= 0.0:
			left = 0.0
			immune_left = _immunity
	elif immune_left > 0.0:
		immune_left = maxf(0.0, immune_left - dt)


func active() -> bool:
	return left > 0.0


## How much of his walking speed he keeps.
func speed_scale() -> float:
	return 1.0 - slow if active() else 1.0


## Share of the curse still to run (1 when just cast, 0 when gone).
func ratio() -> float:
	return left / total if active() and total > 0.0 else 0.0


## Lifts it at once (the boss fell): no immunity after.
func clear() -> void:
	left = 0.0
	immune_left = 0.0
