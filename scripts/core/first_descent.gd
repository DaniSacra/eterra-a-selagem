class_name FirstDescent
extends RefCounted
## The guided first descent (SW-O4, docs/design/onboarding_sw_o.md): when it is the one played, what ends it, and the
## stage and the graph it is played on. Pure; the rooms read them (Rooms.setup), the game ends it (Game).
##   FirstDescent.active(data, flags) -> bool   whether this descent is the guided one
##   FirstDescent.finish(data, how)             writes `first` (how: &"done", &"death", &"skip")
##   FirstDescent.stage_for(stage, def)         the stage it is played on (7 rooms and Morvath, no events)
##   FirstDescent.map(stage, def, seed)         its graph (RunMap.scripted)
## What the save keeps, `first`: PENDING (0), DONE (1: played, ended by a death or by Morvath's short fight) or SKIPPED (2).

const PENDING := 0
const DONE := 1
const SKIPPED := 2

## The switches that keep the guided descent out of a run: the robot, the smoke runs, a dev's room, the old horde, the
## stress, a fixed arena, the shorter descents and a run with no save. --first alone turns it on whatever the others say.
const BLOCKED_BY: Array[String] = ["bot", "smoke", "start", "horde", "stress", "arena", "short", "medium", "nosave"]


## flags: the switches in force as {name: true} (see flags_now) and "save": false when no save is kept.
static func active(data: Dictionary, flags: Dictionary) -> bool:
	if bool(flags.get("first", false)):
		return true
	for k in BLOCKED_BY:
		if bool(flags.get(k, false)):
			return false
	if not bool(flags.get("save", true)):
		return false
	return int(data.get("first", PENDING)) == PENDING


## The switches now (Dev), for active().
static func flags_now(save_enabled: bool) -> Dictionary:
	var out := {"save": save_enabled}
	for k in BLOCKED_BY:
		out[k] = Dev.has(k)
	out["first"] = Dev.has("first")
	return out


## --first=arrival: only the arrival and the Antessala (for captures of them); the door does not take him on.
static func arrival_only() -> bool:
	return Dev.arg("first") == "arrival"


## The descent ended: a death or Morvath's short fight is "done", a skip from the pause is "skipped". Never goes back
## (a save already past it keeps what it has). No `wins`, no `firsts` here: the first descent opens no Forja nor Juramento.
static func finish(data: Dictionary, how: StringName) -> void:
	if int(data.get("first", PENDING)) != PENDING:
		return
	data["first"] = SKIPPED if how == &"skip" else DONE


## The stage the guided descent is played on: the catacombs cut to its seven rooms and Morvath, with no event, no
## modifier, no elite, no long room and no fixed door of the long descent (they are the normal descent's).
static func stage_for(stage: StageDef, def: FirstDescentDef) -> StageDef:
	var st: StageDef = stage.duplicate()
	st.rooms = def.rooms_total - 1
	st.miniboss_depth_min = _depth_of(def, RunMap.Kind.MINIBOSS)
	st.miniboss_depth_max = st.miniboss_depth_min
	st.miniboss2_depth_min = 0
	st.rest_after_guardian = false
	st.fixed_rewards = {}
	st.long_depths = PackedInt32Array()
	st.elite_from_depth = 99
	st.mods = []
	st.mod_from_depth = 99
	st.trial_chance = 0.0
	st.altar_chance = 0.0
	st.route_shop_chance = 0.0
	st.big_from_depth = 99
	return st


## The layer (its depth in the line) of the first room of this kind.
static func _depth_of(def: FirstDescentDef, kind: RunMap.Kind) -> int:
	for r in def.rooms:
		if r.kind == kind:
			return r.layer
	return 0


## The graph of the guided descent: one room (or two, where the doors give a choice) a step, from the Antessala. In
## arrival-only mode (--first=arrival) the door leads nowhere (Rooms keeps it shut).
static func map(stage: StageDef, def: FirstDescentDef, seed_value: int, arrival := false) -> RunMap:
	return RunMap.scripted(stage, def, seed_value, arrival)


## The fight of one room, in the shape EncounterGen draws (Rooms plays it as any other).
static func fight_of(room: FirstRoomDef, stage: StageDef) -> EncounterGen.Fight:
	var f := EncounterGen.Fight.new()
	for w in room.waves:
		var wave: Array = []
		for id_ in w:
			wave.append(StringName(id_))
		f.waves.append(wave)
	f.kinds = room.kinds()
	f.tier = StageDef.Tier.HARD if room.kind == RunMap.Kind.MINIBOSS else StageDef.Tier.COMMON
	f.cap = room.cap
	f.ceiling = stage.alive_cap
	f.mode = EncounterGen.Mode.WAVES
	return f
