class_name ApogeeLedger
extends RefCounted
## Apogeu's books (redesign 2026-11-24, 04_PLANO B.2), pure: the effective damage the blows of the attack's sequence dealt to each
## target, so the last blow can add `apogee_pct` of that sum to the same target. Only the attack's own blows are added (the
## caller checks DealtBy.source: no reaction, burn, echo, wave, Brado, Investida, Golpe Carregado), never the Apogeu blow itself.
## A target's sum goes with its death, the end of the sequence (clear), the Apogeu blow (reset) and `IDLE` seconds without a blow.

## Seconds a target's sum waits for the next blow of the sequence.
const IDLE := 4.0
## Most the Apogeu blow adds, as a multiple of its own damage (decision G of the plan: 400% of the last hit).
const CAP := 4.0

## target id -> {sum, idle}
var _books: Dictionary = {}


## A blow of the sequence dealt `dmg` (effective) to this target.
func add(target_id: int, dmg: float) -> void:
	if dmg <= 0.0:
		return
	var b: Dictionary = _books.get(target_id, {"sum": 0.0, "idle": 0.0})
	b.sum = float(b.sum) + dmg
	b.idle = 0.0
	_books[target_id] = b


## The sum a target has taken from the sequence so far.
func total(target_id: int) -> float:
	return float((_books.get(target_id, {}) as Dictionary).get("sum", 0.0))


## What the last blow adds on this target: `pct` of the sum, never past CAP times the blow's own damage.
func finisher(target_id: int, pct: float, own: float) -> float:
	return minf(total(target_id) * pct, own * CAP)


## The target's sum is spent (it died, or the Apogeu blow landed).
func reset(target_id: int) -> void:
	_books.erase(target_id)


## The sequence is over (it ended or was lost, the room changed): every sum goes.
func clear() -> void:
	_books.clear()


func step(dt: float) -> void:
	for id: int in _books.keys():
		var b: Dictionary = _books[id]
		b.idle = float(b.idle) + dt
		if float(b.idle) >= IDLE:
			_books.erase(id)


func size() -> int:
	return _books.size()
