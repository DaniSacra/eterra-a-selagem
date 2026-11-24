class_name WordBudget
extends RefCounted
## UX-08: how many floating words (a reaction's name, the Apogeu) the screen may take, pure so a horde never spams
## them. Two rules: a word's NAME shows only its first NAMED_MAX times in a run (after that Fx shows the small number
## alone), and at most PER_SECOND words are admitted in any second, the ones past it dropped.
##   if budget.admit(now, &"react_thermal"): fx.word(pos, T.t(key) if budget.named(&"react_thermal") else "", color)
## `named` counts a use, so call it once per word shown. Fx calls reset() on a new run.

const NAMED_MAX := 3
const PER_SECOND := 6

var _named := {}
var _stamps: Array[float] = []


func reset() -> void:
	_named.clear()
	_stamps.clear()


## True when a word may be shown at time `now` (seconds, the run clock); records it.
func admit(now: float) -> bool:
	while not _stamps.is_empty() and now - _stamps[0] >= 1.0:
		_stamps.pop_front()
	if _stamps.size() >= PER_SECOND:
		return false
	_stamps.append(now)
	return true


## True while the name of `key` is still told (its first NAMED_MAX times); counts this use.
func named(key: StringName) -> bool:
	var n: int = _named.get(key, 0)
	_named[key] = n + 1
	return n < NAMED_MAX
