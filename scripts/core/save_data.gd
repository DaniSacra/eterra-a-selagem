class_name SaveData
extends RefCounted
## Pure rules of the save file (options, best times, discovered moves). The Save autoload does the disk part.

const VERSION := 1
const MAX_BEST_TIMES := 5


static func defaults() -> Dictionary:
	return {
		"version": VERSION,
		"options": {"master": 0.8, "music": 0.7, "sfx": 0.9, "fullscreen": false, "scale": 1, "shake": true, "impact_frames": true, "bindings": {}},
		"best_times": [],
		"moves": [],
		"wins": 0,
		"runs": 0,
	}


## Fills anything missing from an older or damaged file, never dropping what is valid.
static func merged(loaded: Variant) -> Dictionary:
	var out := defaults()
	if not loaded is Dictionary:
		return out
	for key: String in out:
		if not loaded.has(key):
			continue
		if out[key] is Dictionary and loaded[key] is Dictionary:
			for sub: String in out[key]:
				if loaded[key].has(sub):
					out[key][sub] = _coerced(loaded[key][sub], out[key][sub])
		else:
			out[key] = _coerced(loaded[key], out[key])
	out.version = VERSION
	return out


## The loaded value in the type of the default (JSON turns every number into a float), or the default itself.
static func _coerced(value: Variant, fallback: Variant) -> Variant:
	if fallback is int and (value is float or value is int):
		return int(value)
	if fallback is float and (value is float or value is int):
		return float(value)
	return value if typeof(value) == typeof(fallback) else fallback


## Adds a winning time (seconds), keeping the fastest few. Returns true when it is the new best.
static func add_best_time(data: Dictionary, seconds: float) -> bool:
	var times: Array = data.best_times
	var best: bool = times.is_empty() or seconds < float(times[0])
	times.append(seconds)
	times.sort()
	if times.size() > MAX_BEST_TIMES:
		times.resize(MAX_BEST_TIMES)
	return best


## A won run's time, kept only when the run has a save (saving false, as with --nosave: no record, never a new best,
## BUG-008). Returns true when it is the new best.
static func record_win_time(data: Dictionary, seconds: float, saving: bool) -> bool:
	return saving and add_best_time(data, seconds)


static func discover_move(data: Dictionary, id: String) -> bool:
	if (data.moves as Array).has(id):
		return false
	data.moves.append(id)
	return true


static func format_time(seconds: float) -> String:
	var s := int(seconds)
	return "%d:%02d" % [s / 60, s % 60]
