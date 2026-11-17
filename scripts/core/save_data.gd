class_name SaveData
extends RefCounted
## Pure rules of the save file (options, best times, discovered moves, each hero's Mastery and Gifts, the Codex). The
## Save autoload does the disk part.

## 2: full screen by default (Daniel, 2026-11-16); an older file switches to it once.
## 3 (DT-012, E2a): heroes (heroes.<id>: mastery_xp, unlocked, equipped, ultimate, firsts) and codex (boons, elos,
## psalms, talents, enemies: id to a small dictionary of counts). An older file gets the Warrior's Mastery for what it
## already played, once (MasteryCurve.retro_xp).
const VERSION := 3
const MAX_BEST_TIMES := 5
## The hero every older save belongs to (HeroDef.id).
const FIRST_HERO := "warrior"
## Codex sections: each maps an id to a dictionary of counts (seen, formed, defeated...). E4-05: enemies (defeated,
## elite; Morvath: met, phase the highest reached, defeated) and arenas (entered).
const CODEX: Array[String] = ["boons", "elos", "psalms", "talents", "enemies", "arenas"]
## The lists of ids in a hero's block (only strings are kept).
const HERO_LISTS: Array[String] = ["unlocked", "equipped"]


static func defaults() -> Dictionary:
	var codex := {}
	for section in CODEX:
		codex[section] = {}
	return {
		"version": VERSION,
		"options": {"master": 0.8, "music": 0.7, "sfx": 0.9, "fullscreen": true, "scale": 1, "shake": true, "impact_frames": true, "slow_motion": true, "color_split": true, "rumble": true, "quality": 0, "bindings": {}},
		"best_times": [],
		"moves": [],
		"wins": 0,
		"runs": 0,
		"heroes": {FIRST_HERO: hero_defaults()},
		"codex": codex,
	}


## One hero's block: the Mastery XP (the level comes out of it), the Gifts unlocked (ids, what the screens have shown),
## the Gifts equipped for the next descent (ids), the ultimate chosen (id or "") and first times (guardian, victory:
## counts) for the Mastery's first-time XP.
static func hero_defaults() -> Dictionary:
	return {"mastery_xp": 0, "unlocked": [], "equipped": [], "ultimate": "", "firsts": {}}


## Fills anything missing from an older or damaged file, never dropping what is valid. Dictionaries with free keys
## (the heroes, the Codex sections, bindings, firsts) keep every entry whose value has the right type (DT-012: before
## version 3 only the keys of defaults() survived, so a Mastery or a Codex would have been wiped at every read).
static func merged(loaded: Variant) -> Dictionary:
	var out := defaults()
	if not loaded is Dictionary:
		return out
	for key: String in out:
		if not loaded.has(key):
			continue
		match key:
			"heroes":
				if loaded.heroes is Dictionary:
					for id: Variant in loaded.heroes:
						if id is String and loaded.heroes[id] is Dictionary:
							out.heroes[id] = _fixed_keys(loaded.heroes[id], hero_defaults())
			"codex":
				if loaded.codex is Dictionary:
					for section in CODEX:
						if loaded.codex.get(section) is Dictionary:
							out.codex[section] = _entries(loaded.codex[section])
			_:
				if out[key] is Dictionary and loaded[key] is Dictionary:
					out[key] = _fixed_keys(loaded[key], out[key])
				else:
					out[key] = _coerced(loaded[key], out[key])
	var version := int(_coerced(loaded.get("version", 1), 1))
	# files before version 2 kept the old windowed default: they open in full screen once, then the choice is theirs
	if version < 2:
		out.options.fullscreen = true
	# files before version 3 had no Mastery: what was played counts once (40 a run, 60 a win, up to level 5, D-57)
	if version < 3:
		var hero_block: Dictionary = out.heroes[FIRST_HERO]
		hero_block.mastery_xp = maxi(int(hero_block.mastery_xp), HeroDef.warrior().mastery.retro_xp(int(out.runs), int(out.wins)))
		if int(out.wins) > 0:
			# a player who already won has met the guardian and the sealing: no first-time XP for them again
			hero_block.firsts = {"guardian": int(out.wins), "victory": int(out.wins)}
	out.version = VERSION
	return out


## A dictionary with known keys: each known key read in its default's type (an empty default dictionary, as bindings
## and firsts, keeps the loaded one whole; the lists of ids keep their strings); unknown keys are dropped.
static func _fixed_keys(loaded: Dictionary, model: Dictionary) -> Dictionary:
	var out := model.duplicate(true)
	for sub: String in model:
		if not loaded.has(sub):
			continue
		if sub in HERO_LISTS and loaded[sub] is Array:
			out[sub] = (loaded[sub] as Array).filter(func(v: Variant) -> bool: return v is String)
		else:
			out[sub] = _coerced(loaded[sub], model[sub])
	return out


## A Codex section: every id whose value is a dictionary of numbers, flags or words; whole numbers back to ints (JSON
## reads every number as a float).
static func _entries(loaded: Dictionary) -> Dictionary:
	var out := {}
	for id: Variant in loaded:
		if not (id is String and loaded[id] is Dictionary):
			continue
		var entry := {}
		for k: Variant in loaded[id]:
			var v: Variant = loaded[id][k]
			if v is float and is_equal_approx(v, roundf(v)):
				v = int(v)
			if k is String and (v is int or v is float or v is bool or v is String):
				entry[k] = v
		out[id] = entry
	return out


## A hero's block (made when missing).
static func hero(data: Dictionary, id: String) -> Dictionary:
	if not data.get("heroes") is Dictionary:
		data["heroes"] = {}
	if not data.heroes.has(id):
		data.heroes[id] = hero_defaults()
	return data.heroes[id]


## Counts one more of what (seen, formed, defeated...) for an id in a Codex section. Returns true the first time.
static func codex_add(data: Dictionary, section: String, id: String, what: String, amount: int = 1) -> bool:
	var entries: Dictionary = _section(data, section)
	var first := not entries.has(id)
	var entry: Dictionary = entries.get(id, {})
	entry[what] = int(entry.get(what, 0)) + amount
	entries[id] = entry
	return first


## Keeps the highest value of what for an id in a Codex section (Morvath's phase reached). Returns true the first time.
static func codex_max(data: Dictionary, section: String, id: String, what: String, value: int) -> bool:
	var entries: Dictionary = _section(data, section)
	var first := not entries.has(id)
	var entry: Dictionary = entries.get(id, {})
	entry[what] = maxi(int(entry.get(what, 0)), value)
	entries[id] = entry
	return first


static func _section(data: Dictionary, section: String) -> Dictionary:
	if not data.get("codex") is Dictionary:
		data["codex"] = {}
	if not data.codex.get(section) is Dictionary:
		data.codex[section] = {}
	return data.codex[section]


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
