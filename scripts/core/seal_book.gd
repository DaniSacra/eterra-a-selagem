class_name SealBook
extends RefCounted
## Who holds a Selo (the Maga's mark, maga.md 2.1), and for how long. Keys are any objects (the game's enemies); pure.
## A Selo lives `life` seconds; the clock stops for a key `paused` says so for (inside the Círculo or the Suspensão).

var life := 8.0
var cap := 1
## key -> [count, seconds left]
var _seals: Dictionary = {}


func _init(seconds: float = 8.0, most: int = 1) -> void:
	life = seconds
	cap = most


func has(key: Object) -> bool:
	return _seals.has(key)


func count(key: Object) -> int:
	return int(_seals[key][0]) if _seals.has(key) else 0


## Total Selos on the floor.
func total() -> int:
	var n := 0
	for k in _seals:
		n += int(_seals[k][0])
	return n


func keys() -> Array:
	return _seals.keys()


func left(key: Object) -> float:
	return float(_seals[key][1]) if _seals.has(key) else 0.0


## Lays one Selo (its clock starts over). True when it was a new Selo, false at the cap (only the clock restarts).
func lay(key: Object) -> bool:
	if not _seals.has(key):
		_seals[key] = [1, life]
		return true
	var s: Array = _seals[key]
	s[1] = life
	if int(s[0]) < cap:
		s[0] = int(s[0]) + 1
		return true
	return false


## Takes the Selos of a key (a blast detonates them): how many it held.
func take(key: Object) -> int:
	if not _seals.has(key):
		return 0
	var n := int(_seals[key][0])
	_seals.erase(key)
	return n


func forget(key: Object) -> void:
	_seals.erase(key)


func clear() -> void:
	_seals.clear()


## Runs the clocks; `paused` (Callable(key) -> bool, may be invalid) holds a key's clock. Returns the keys whose Selo ran out.
func step(dt: float, paused: Callable = Callable()) -> Array:
	var gone: Array = []
	for k in _seals.keys():
		if paused.is_valid() and bool(paused.call(k)):
			continue
		var s: Array = _seals[k]
		s[1] = float(s[1]) - dt
		if float(s[1]) <= 0.0:
			gone.append(k)
	for k in gone:
		_seals.erase(k)
	return gone
