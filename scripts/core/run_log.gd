class_name RunLog
extends RefCounted
## The log of every run played by a person (QW-001 of cycle 10, for the human tests): one JSON object per line in
## user://runs.jsonl, appended when the run ends (won, lost or left). Nothing leaves the computer. Game.log_run builds
## the entry: the RESULT line (Game.result) plus FIELDS.

const PATH := "user://runs.jsonl"
## 2 (cycle C12c, GP-02): source, boons_at_boss, shop, fountain_used, hurt_ctx, and more numbers in each room
## (RoomTally: variant, dodges, hits, hits_by, shots, blocked_by, gold_in, boons_in).
const VERSION := 2
## What an entry adds to the RESULT: outcome (victory, death, quit), when (local date and time), the gifts taken (in
## order: id, level and rarity), the device used (keyboard, gamepad, both, none; bot for the test robot), how many
## Omegas and dodges, the last thing that hurt the paladin (DefeatCause) and, on a death, its text key. Since
## VERSION 2: who played (source: human or bot), the gifts held at Morvath, the shop (gold walking in, what was
## bought and for how much), whether the fountain healed him and every blow taken in context (RoomTally.hurt_ctx).
const FIELDS: Array[String] = ["version", "outcome", "when", "gifts", "device", "omegas", "dodges", "last_hurt", "defeated_by",
	"source", "boons_at_boss", "shop", "fountain_used", "hurt_ctx"]
## Who played a run (source).
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


## Every entry in the file at path (a damaged line is skipped).
static func read(path: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		return out
	var json := JSON.new()
	for text in FileAccess.get_file_as_string(path).split("\n", false):
		if json.parse(text) == OK and json.data is Dictionary:
			out.append(json.data)
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
