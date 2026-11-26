class_name Objective
extends RefCounted
## SW-O2: the one-line objective at the top left ("Explore a área", "Vença a sala"), pure. `pick` reads a context the
## HUD builds and answers the key of the line to show (&"" none); `enabled` says whether the line is on in this save;
## `text` fills the keys with the real bindings. No node, no save writes: the HUD and the hub only display it.
##   Objective.pick({kind: &"ante", near_plates: true}) -> &"obj_dodge"
## The Santuário has no line (QW-5, Daniel 2026-11-26): only the rooms of a descent speak.
## ctx (every key optional):
##   kind: the room's kind as a lowercase name (&"ante", &"combat", &"miniboss", &"shop",
##   &"boss"...); fighting; reward_waiting; doors_open (how many); first_choice (two doors for the first time);
##   screen: &"" none, &"boon" the Blessing's screen, &"other" any other; near_plates; near_breakable; crossed_plates;
##   broke_one; lesson (PT-25-8: the Antessala's tip now, AnteLesson.key; it comes before the rest there).

## A save with this many descents or fewer still has the line when the option is on (the tutorial and two more: D-O3 b).
const OBJ_RUNS := 3
const KEYS: Array[StringName] = [&"obj_explore", &"obj_dodge", &"obj_break", &"obj_find_way", &"obj_win", &"obj_take",
		&"obj_bless", &"lesson_attack", &"lesson_special", &"lesson_dodge", &"lesson_shout", &"lesson_rush", &"obj_door", &"obj_guardian", &"obj_shop", &"obj_morvath"]
## Metres from the plates and from a breakable at which the Antessala speaks of them (FirstDescentDef obj_*_near).
const DODGE_NEAR := 6.0
const BREAK_NEAR := 5.0


## The line due now, or &"".
static func pick(ctx: Dictionary) -> StringName:
	var screen: StringName = ctx.get("screen", &"")
	if screen == &"boon":
		return &"obj_bless"
	if screen != &"":
		return &""
	var kind: StringName = ctx.get("kind", &"")
	var fighting: bool = ctx.get("fighting", false)
	if kind == &"boss" and (fighting or (not bool(ctx.get("reward_waiting", false)) and int(ctx.get("doors_open", 0)) == 0)):
		return &"obj_morvath"  # (not after the victory: the reward and the doors speak then; sweep P1-2)
	if kind == &"miniboss" and (fighting or (not bool(ctx.get("reward_waiting", false)) and int(ctx.get("doors_open", 0)) == 0)):
		return &"obj_guardian"
	if fighting:
		return &"obj_win"
	if kind == &"shop":
		return &"obj_shop"
	if bool(ctx.get("reward_waiting", false)):
		return &"obj_take"
	if kind == &"ante":
		return _ante(ctx)
	var doors := int(ctx.get("doors_open", 0))
	if doors >= 2 and bool(ctx.get("first_choice", false)):
		return &"obj_door"
	if doors > 0:
		return &"obj_find_way"
	return &""


## The Antessala: the plates when near and not crossed, a breakable when near and none broken, then the way.
static func _ante(ctx: Dictionary) -> StringName:
	var lesson: StringName = ctx.get("lesson", &"")
	if lesson != &"":
		return lesson
	var crossed := bool(ctx.get("crossed_plates", false))
	if bool(ctx.get("near_plates", false)) and not crossed:
		return &"obj_dodge"
	if bool(ctx.get("near_breakable", false)) and not bool(ctx.get("broke_one", false)):
		return &"obj_break"
	return &"obj_find_way" if crossed else &"obj_explore"


## Whether the line is on: always in the tutorial; otherwise in the first OBJ_RUNS descents of a save with the option on.
static func enabled(data: Dictionary, tutorial: bool) -> bool:
	if tutorial:
		return true
	var options: Dictionary = data.get("options", {})
	return int(data.get("runs", 0)) <= OBJ_RUNS and bool(options.get("objective", true))


## The words of a key, with the keys of the actions as bound now (keyboard or pad).
static func text(key: StringName) -> String:
	if key == &"":
		return ""
	return T.t(key, {"attack": UiKit.action_label(&"light_attack"), "dodge": UiKit.action_label(&"dodge"),
			"interact": UiKit.action_label(&"interact"), "special": UiKit.action_label(&"heavy_attack"),
			"shout": UiKit.action_label(&"shout"), "rush": UiKit.action_label(&"rush")})


## The Dev flags that FirstDescent.active reads (the document's list), passed as it asks for them.
const FLAGS: Array[String] = ["first", "bot", "smoke", "start", "horde", "stress", "arena", "short", "medium", "nosave"]
const FIRST_DESCENT := "res://scripts/core/first_descent.gd"


## Whether this run is the guided first descent (3A1's FirstDescent.active). Until that file exists only --first says so.
static func tutorial() -> bool:
	if not ResourceLoader.exists(FIRST_DESCENT):
		return Dev.has("first")
	var flags := {}
	for f in FLAGS:
		flags[f] = Dev.has(f)
	return bool((load(FIRST_DESCENT) as GDScript).call(&"active", Save.data, flags))
