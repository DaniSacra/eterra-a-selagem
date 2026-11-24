class_name RunLog
extends RefCounted
## The log of every run played by a person (QW-001 of cycle 10, for the human tests): one JSON object per line in
## user://runs.jsonl, appended when the run ends (won, lost or left). Nothing leaves the computer. Game.log_run builds
## the entry: the RESULT line (Game.result) plus FIELDS.

const PATH := "user://runs.jsonl"
## 2 (cycle C12c, GP-02): source, boons_at_boss, shop, fountain_used, hurt_ctx, and more numbers in each room
## (RoomTally: variant, dodges, hits, hits_by, shots, blocked_by, gold_in, boons_in).
## 3 (DT-015, E2a): the hero (hero: warrior), the Mastery XP the run gave (xp, by source in xp_by) and the level after
## it (mastery_level), the Gifts equipped (talents) and the ultimate chosen. gifts stays the list of Blessings.
## 4 (DV-1, MAP-02): the descent's graph (map: seed, nodes, edges, the way walked), the node of each room
## (rooms[].node) and, in each door's event, the node chosen and those offered.
## 5 (Rejogabilidade, Fatia 1; sistemas.md 5.2): materials (by source and in total, MaterialPurse.report), forge (the
## Forja's ranks carried: temper), talents_opened (Gifts open at the start) and angels (one entry a meeting: room, node,
## offered, chose, cards, fallback; Encounters.log).
## 6 (Ofícios, Roteiro A; OficiosRun.report): oficios (finds, find_by, marked, gather: veins, stones, gather_s,
## noted; pity: due, passed_guardian).
const VERSION := 6
## What an entry adds to the RESULT: outcome (victory, death, quit), when (local date and time), the gifts taken (in
## order: id, level and rarity), the device used (keyboard, gamepad, both, none; bot for the test robot), how many
## Omegas and dodges, the last thing that hurt the paladin (DefeatCause) and, on a death, its text key. Since
## VERSION 2: who played (source: human or bot), the gifts held at Morvath, the shop (gold walking in, what was
## bought and for how much), whether the fountain healed him and every blow taken in context (RoomTally.hurt_ctx).
## Since VERSION 3: HERO_FIELDS.
const FIELDS: Array[String] = ["version", "outcome", "when", "gifts", "device", "omegas", "dodges", "last_hurt", "defeated_by",
	"source", "boons_at_boss", "shop", "fountain_used", "hurt_ctx", "hero", "xp", "xp_by", "mastery_level", "talents", "ultimate"]
## The fields of version 3 and what an older line (version 1 or 2, all played by the first hero) reads as.
const HERO_FIELDS := {"hero": "warrior", "xp": 0, "xp_by": {}, "mastery_level": 0, "talents": [], "ultimate": ""}
## The field of version 4 and what an older line (one straight line of rooms, no graph) reads as.
const MAP_FIELDS := {"map": {}}
## The fields of version 5 and what an older line (no materials, no angels) reads as.
const KEEP_FIELDS := {"materials": {}, "forge": {}, "talents_opened": 0, "angels": []}
## The field of version 6 and what an older line (no Ofícios) reads as.
const OFICIOS_FIELDS := {"oficios": {}}
## Who played a run (source).
## A "quit" before any room was won and within this many seconds is someone passing through the Portal: not logged.
const EMPTY_QUIT_S := 10.0

const HUMAN := "human"
const BOT := "bot"
const OUTCOMES: Array[String] = ["victory", "death", "quit"]


## One entry: a copy of the result with the extra fields over it.
static func entry(result: Dictionary, extra: Dictionary) -> Dictionary:
	var out := result.duplicate(true)
	out["version"] = VERSION
	for k: String in extra:
		out[k] = extra[k]
	return out


## The entry as one line of JSON (no line breaks inside).
static func line(e: Dictionary) -> String:
	return JSON.stringify(e)


## Adds one entry at the end of the file at path. Returns the error, OK when written.
static func append(path: String, e: Dictionary) -> Error:
	var f := FileAccess.open(path, FileAccess.READ_WRITE) if FileAccess.file_exists(path) else FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.seek_end()
	f.store_line(line(e))
	return OK


## Every entry in the file at path (a damaged line is skipped), older versions read in the current shape (normalized).
static func read(path: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		return out
	var json := JSON.new()
	for text in FileAccess.get_file_as_string(path).split("\n", false):
		if json.parse(text) == OK and json.data is Dictionary:
			out.append(normalized(json.data))
	return out


## An entry of any version with the fields of this one: an older line (version 1 or 2, or none) gets HERO_FIELDS
## (the first hero, no XP, no Gifts), one before version 4 an empty map (MAP_FIELDS) and each room the node -1, one
## before version 5 no materials and no angels (KEEP_FIELDS), and it
## keeps its own version number, so a reader still knows what it was.
static func normalized(e: Dictionary) -> Dictionary:
	if int(e.get("version", 1)) >= VERSION:
		return e
	var out := e.duplicate(true)
	for fields: Dictionary in [HERO_FIELDS, MAP_FIELDS, KEEP_FIELDS, OFICIOS_FIELDS]:
		for k: String in fields:
			if not out.has(k):
				out[k] = fields[k].duplicate() if fields[k] is Array or fields[k] is Dictionary else fields[k]
	for r: Variant in out.get("rooms", []):
		if r is Dictionary and not (r as Dictionary).has("node"):
			r["node"] = -1
	return out


## Which device a run was played with, from what was seen: keyboard and mouse, gamepad, both, none.
static func device(keys: bool, pad: bool) -> String:
	if keys and pad:
		return "both"
	if pad:
		return "gamepad"
	return "keyboard" if keys else "none"


## Who played: the test robot or a person.
static func source(bot: bool) -> String:
	return BOT if bot else HUMAN


## Whether a run is worth a line in the log: not a "quit" with no room won and under EMPTY_QUIT_S seconds.
static func worth_keeping(outcome: String, rooms_won: int, time: float) -> bool:
	return outcome != "quit" or rooms_won > 0 or time >= EMPTY_QUIT_S
