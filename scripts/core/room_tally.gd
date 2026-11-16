class_name RoomTally
extends RefCounted
## The rooms of one run in numbers (QW-011, for the human tests): for each room entered, its depth, the arena it was
## (RoomLayout.id), the paladin's life walking in, the damage he took there by what dealt it (DefeatCause.key: an
## enemy kind or a boss attack), the seconds spent in it and the seconds to the first blow given or taken (contact).
## Pure; Game feeds it, RESULT and the run's log carry rooms() and hp_at_boss.

var _rooms: Array[Dictionary] = []
var _started := 0.0
## Life when the boss room was entered (-1: not yet).
var hp_at_boss := -1.0


## A room is entered at play time `time` with `hp` life. The room before it is closed.
func enter(depth: int, layout: String, hp: float, time: float, boss := false) -> void:
	close(time)
	_started = time
	_rooms.append({"depth": depth, "layout": layout, "hp_in": snappedf(hp, 0.1), "hurt_by": {}, "time": 0.0, "contact": -1.0})
	if boss:
		hp_at_boss = snappedf(hp, 0.1)


## The paladin lost `amount` life to `by` in the current room.
func hurt(by: String, amount: float) -> void:
	if _rooms.is_empty() or amount <= 0.0:
		return
	var h: Dictionary = _rooms[-1].hurt_by
	h[by] = snappedf(float(h.get(by, 0.0)) + amount, 0.1)


## The first blow given or taken in the current room, at play time `time` (contact: seconds after walking in; only
## the first counts).
func touch(time: float) -> void:
	if not _rooms.is_empty() and float(_rooms[-1].contact) < 0.0:
		_rooms[-1].contact = snappedf(time - _started, 0.1)


## Sets the seconds spent in the current room, as of `time`.
func close(time: float) -> void:
	if not _rooms.is_empty():
		_rooms[-1].time = snappedf(time - _started, 0.1)


## Every room so far, the current one timed up to `time` (a copy).
func rooms(time: float) -> Array:
	close(time)
	return _rooms.duplicate(true)
