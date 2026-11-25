class_name FirstTips
extends RefCounted
## GP-9 and 10B-2: the four short tips of the first descents, pure. Hitting and dodging, holding for the Omega, the
## yellow bar (armor) and the pale one (Poise), the pair of Blessings that forms an Elo. Each one shows once per save
## (`data.hub.tips` keeps the ids shown) and only while the save is new (fewer than FIRST_RUNS descents). The HUD's
## TipToast shows them; nothing here touches the run, so the robot, a smoke run or --nosave see none
## (--tips forces them for captures, not written).
##   FirstTips.pick(Save.data, ctx) -> the tip due now (&"" none); ctx: {fighting, fight_t, armored, boons, elos, tutorial}
##   FirstTips.mark(Save.data, id)

const IDS: Array[StringName] = [&"armor", &"fight", &"hold", &"elo"]
## A save with this many descents or more has no tips (it knows the game).
const FIRST_RUNS := 2
## Seconds of fighting in the room before the first tip, and before the Omega's one.
const FIGHT_AFTER := 1.5
const HOLD_AFTER := 8.0


static func enabled() -> bool:
	if Dev.has("tips"):
		return true
	for k in ["bot", "smoke", "nosave"]:
		if Dev.has(k):
			return false
	return true


static func shown(data: Dictionary) -> Array:
	if not data.get("hub") is Dictionary:
		data["hub"] = SaveData.hub_defaults()
	var h: Dictionary = data["hub"]
	if not h.get("tips") is Array:
		h["tips"] = []
	return h["tips"]


static func mark(data: Dictionary, id: StringName) -> void:
	var done := shown(data)
	if not done.has(String(id)):
		done.append(String(id))


## Whether a tip may still come in this save: not shown yet and the save is new.
static func open(data: Dictionary, id: StringName) -> bool:
	return int(data.get("runs", 0)) < FIRST_RUNS and not shown(data).has(String(id))


## The tip due now, or &"". One at a time; the Omega's waits for the first to have been seen.
static func pick(data: Dictionary, ctx: Dictionary) -> StringName:
	var fighting: bool = ctx.get("fighting", false)
	var t: float = ctx.get("fight_t", 0.0)
	if fighting and bool(ctx.get("armored", false)) and open(data, &"armor"):
		return &"armor"
	# SW-O2: in the guided descent the objective line and the room's own tips teach hitting: no "fight" tip there
	var tutorial: bool = ctx.get("tutorial", false)
	if fighting and not tutorial and t >= FIGHT_AFTER and open(data, &"fight"):
		return &"fight"
	if fighting and t >= HOLD_AFTER and (tutorial or not open(data, &"fight")) and open(data, &"hold"):
		return &"hold"
	if not fighting and int(ctx.get("boons", 0)) >= 2 and int(ctx.get("elos", 0)) == 0 and open(data, &"elo"):
		return &"elo"
	return &""


## UI 11 (Lote B): the "Q: Brado" word over the Q diamond. At most SHOUT_PER_ROOM times in a room and only in the save's
## first SHOUT_RUNS descents; the robot, a smoke run and --nosave never see it (enabled()).
const SHOUT_PER_ROOM := 2
const SHOUT_RUNS := 3
## Seconds the word stays.
const SHOUT_TIME := 1.0


## Whether the Brado's word may show now: worth it, told fewer than SHOUT_PER_ROOM times in this room, save still new.
static func shout_due(data: Dictionary, told_in_room: int, worth: bool) -> bool:
	return worth and told_in_room < SHOUT_PER_ROOM and int(data.get("runs", 0)) < SHOUT_RUNS


## SW-O4 (D-O2 b): a player who already knows the game skips the guided descent: `first` 0 (pending) becomes 2 (skipped,
## it counts as done for the milestones). A done descent (1) stays 1. The pause and the save choice call this; the caller writes.
static func mark_skipped(data: Dictionary) -> void:
	if int(data.get("first", 0)) == 0:
		data["first"] = 2
