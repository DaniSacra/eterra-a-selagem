class_name FxBudget
extends RefCounted
## How many of each kind of effect may start in one frame (pure; Fx asks before it starts one, and resets it every
## frame). A swing through a pack used to start a cut, six chips and a number for each one it reached, all in the same
## frame, and the pile hid the paladin (cycle 7 review, B4 and the number groups of `19`). What is past the budget is
## simply not drawn: nothing here changes the game.

var limits: Dictionary[StringName, int] = {}
var _used: Dictionary[StringName, int] = {}


func _init(per_frame: Dictionary[StringName, int] = {}) -> void:
	limits = per_frame


## Up to `want` of a kind, as many as the frame still has room for (all of them for a kind without a limit).
func take(kind: StringName, want: int) -> int:
	if want <= 0:
		return 0
	if not limits.has(kind):
		return want
	var used: int = _used.get(kind, 0)
	var grant := clampi(limits[kind] - used, 0, want)
	_used[kind] = used + grant
	return grant


## One, if the frame has room for it.
func allows(kind: StringName) -> bool:
	return take(kind, 1) == 1


## How many of a kind this frame has started.
func used(kind: StringName) -> int:
	return _used.get(kind, 0)


## A new frame: every kind has its whole budget again.
func reset() -> void:
	_used.clear()
