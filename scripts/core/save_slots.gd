class_name SaveSlots
extends RefCounted
## The three saves on disk (Save 1, 2, 3; the Daniel, 2026-11-19): each one is a whole save of its own
## (`save_<n>.json`, written safely by SaveFile with its `.bak`), and one small profile file (`profile.json`) holds
## what belongs to the computer, not to a save: the save in use (active, 0 = none yet) and the options (volumes,
## screen, keys, music), shared by the three, so the first screen already has the player's window and sound.
## The save of before the slots (`save.json`, one per computer) reads as Save 1 while Save 1 does not exist yet, and
## is moved into it at the first write (migrate): it is renamed to `save_legacy.json` (kept, never read again), so
## nothing is lost and it can never come back over a Save 1 erased later. Reading never writes anything (tests and
## captures load the save without touching the disk). Pure: no nodes; `base` is the folder (user:// in the game, a
## folder of their own in the tests).

const COUNT := 3
const LEGACY := "save.json"
const RETIRED := "save_legacy.json"
const PROFILE := "profile.json"


static func path(n: int, base: String = "user://") -> String:
	return base + "save_%d.json" % n


static func profile_path(base: String = "user://") -> String:
	return base + PROFILE


## Whether a save is there (its own file, or its copy; Save 1 also as the save of before the slots).
static func exists(n: int, base: String = "user://") -> bool:
	var p := path(n, base)
	if FileAccess.file_exists(p) or FileAccess.file_exists(p + SaveFile.BAK):
		return true
	return n == 1 and has_legacy(base)


## The save of before the slots still waiting to become Save 1.
static func has_legacy(base: String = "user://") -> bool:
	var p := base + LEGACY
	if FileAccess.file_exists(path(1, base)) or FileAccess.file_exists(path(1, base) + SaveFile.BAK):
		return false
	return FileAccess.file_exists(p) or FileAccess.file_exists(p + SaveFile.BAK)


## The save's dictionary, merged to the current version (SaveData.merged), or null when the slot is empty or
## unreadable (a damaged file falls back to its copy, SaveFile.read). Save 1 reads the save of before the slots while
## it has no file of its own.
static func read(n: int, base: String = "user://") -> Variant:
	var p := base + LEGACY if n == 1 and has_legacy(base) else path(n, base)
	var got := SaveFile.read(p)
	if got.data == null:
		return null
	return SaveData.merged(got.data)


## The profile: {active: int (0 none), options: Dictionary or null}. Without a profile yet the save of before the
## slots gives its options (and Save 1 is the one in use), so the first launch after the change looks the same.
static func read_profile(base: String = "user://") -> Dictionary:
	var got: Variant = SaveFile.read(profile_path(base)).data
	if got is Dictionary:
		var options: Variant = got.get("options")
		return {"active": clampi(int(got.get("active", 0)), 0, COUNT), "options": options if options is Dictionary else null}
	if has_legacy(base):
		var old: Variant = read(1, base)
		if old is Dictionary:
			return {"active": 1, "options": old.options}
	return {"active": 0, "options": null}


static func write_profile(active: int, options: Dictionary, base: String = "user://") -> bool:
	return SaveFile.write(profile_path(base), JSON.stringify({"active": active, "options": options}, "  "))


## The options of the profile read in the current shape (every key known, the free ones kept: bindings), over the
## defaults.
static func options_of(loaded: Variant) -> Dictionary:
	if not loaded is Dictionary:
		return SaveData.defaults().options
	return SaveData.merged({"version": SaveData.VERSION, "options": loaded}).options


## Moves the save of before the slots into Save 1, once: its text (and its copy) becomes save_1.json, and the old
## file is renamed to save_legacy.json. Called before the first write of Save 1. True when there was one to move.
static func migrate(base: String = "user://") -> bool:
	if not has_legacy(base):
		return false
	var old := base + LEGACY
	for ext: String in ["", SaveFile.BAK]:
		if FileAccess.file_exists(old + ext):
			DirAccess.copy_absolute(old + ext, path(1, base) + ext)
	retire_legacy(base)
	return true


## The save of before the slots out of the way (renamed, never read again; the copy too).
static func retire_legacy(base: String = "user://") -> void:
	for ext: String in ["", SaveFile.BAK]:
		var from := base + LEGACY + ext
		if FileAccess.file_exists(from):
			var to := base + RETIRED + ext
			if FileAccess.file_exists(to):
				DirAccess.remove_absolute(to)
			DirAccess.rename_absolute(from, to)


## Erases a save for good: its file, its copy, a temporary file and the damaged ones set aside. Save 1 also retires
## the save of before the slots, so it never comes back as Save 1.
static func erase(n: int, base: String = "user://") -> void:
	if n == 1:
		retire_legacy(base)
	var p := path(n, base)
	for ext: String in ["", SaveFile.BAK, SaveFile.TMP]:
		if FileAccess.file_exists(p + ext):
			DirAccess.remove_absolute(p + ext)
	var k := 0
	var broken := p + SaveFile.BROKEN
	while FileAccess.file_exists(broken):
		DirAccess.remove_absolute(broken)
		k += 1
		broken = p + SaveFile.BROKEN + str(k)


## What the slot screen shows of a save: {level, runs, wins, silver, memory, played_at (unix seconds of the last
## descent's end, 0 none)}.
static func summary(data: Dictionary) -> Dictionary:
	var warrior := HeroDef.warrior()
	var block := SaveData.hero(data, SaveData.FIRST_HERO)
	return {
		"level": warrior.mastery.level_of(int(block.mastery_xp)),
		"runs": int(data.get("runs", 0)),
		"wins": int(data.get("wins", 0)),
		"silver": MaterialPurse.amount(data, MaterialPurse.SILVER),
		"memory": MaterialPurse.amount(data, MaterialPurse.MEMORY),
		"played_at": int(data.get("played_at", 0)),
	}


## The summary of slot n read from disk (null when empty); a save with descents but no time (one of before the slots)
## takes its file's time.
static func summary_of(n: int, base: String = "user://") -> Variant:
	var data: Variant = read(n, base)
	if data == null:
		return null
	var out := summary(data)
	if out.played_at <= 0 and out.runs > 0:
		var p := base + LEGACY if n == 1 and has_legacy(base) else path(n, base)
		if FileAccess.file_exists(p):
			out.played_at = int(FileAccess.get_modified_time(p))
	return out


## When the save of before the slots was last written (unix seconds, 0 without one).
static func legacy_time(base: String = "user://") -> int:
	var p := base + LEGACY
	return int(FileAccess.get_modified_time(p)) if FileAccess.file_exists(p) else 0


## "19/11/2026 21:30" in the computer's own time ("" when unknown).
static func date_text(unix: int) -> String:
	if unix <= 0:
		return ""
	var bias := int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var d := Time.get_datetime_dict_from_unix_time(unix + bias)
	return "%02d/%02d/%04d %02d:%02d" % [d.day, d.month, d.year, d.hour, d.minute]
