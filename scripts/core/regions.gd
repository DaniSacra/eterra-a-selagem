class_name Regions
extends RefCounted
## Chapter II, A-1: the regions of a descent. A region is one StageDef (data/stages/*.tres); the REGION INDEX (0 the catacombs, 1 the Bosque
## Submerso) is separate from the DEPTH (the room's number inside its region, RunMap). The `chapter2` switch (Regions.enabled) decides whether
## a descent may go past region 0; OFF the game is exactly Chapter I. Pure rules; Rooms does the passage.

## The stage of each region, in order.
const PATHS: Array[String] = ["res://data/stages/catacombs.tres", "res://data/stages/bosque.tres"]
## The option's key in the save's options (default off) and the command line switch that overrides it (--chapter2, --chapter2=0).
const OPTION := "chapter2"
const SWITCH := "chapter2"

## Where this run stands: the region index and how many passages were made. A passage is IDEMPOTENT: asking to pass to a region the run is
## already in (or past) does nothing, so a repeated call (a double trigger, a reload) never builds a second map nor loses a thing.
var index := 0
var passages := 0


## The switch: --chapter2 on the command line wins (=0 turns it off), else the save's option (false by default).
static func enabled(option_value: Variant = false) -> bool:
	if Dev.has(SWITCH):
		return Dev.arg(SWITCH) != "0"
	return bool(option_value)


static func count() -> int:
	return PATHS.size()


## The stage file of a region (a bad index is the first region's).
static func path(region: int) -> String:
	return PATHS[region] if region >= 0 and region < PATHS.size() else PATHS[0]


static func has_next(region: int) -> bool:
	return region + 1 < PATHS.size()


## The region a run starts in: --region=N (dev, only with the switch on), else the first.
static func start_region(on: bool) -> int:
	if not on or not Dev.has("region"):
		return 0
	return clampi(int(Dev.num("region", 0)), 0, PATHS.size() - 1)


## Passes to `target` when it is the next region and the switch is on. Returns whether the passage happened (false: off, a repeat, or no such region).
func pass_to(target: int, on: bool) -> bool:
	if not on or target != index + 1 or target >= PATHS.size():
		return false
	index = target
	passages += 1
	return true


## Chapter II, A-2: whether sealing Morvath leads to the Átrio and the next region instead of the end screen (the switch is on and there is a next region).
static func leads_on(region: int, on: bool) -> bool:
	return on and has_next(region)


## Chapter II, A-6: the preview ends when the hero would walk into the chamber of a region past the first (the Bosque has no chief yet, its
## chamber is a stand-in): the end is "Fim da prévia", never a victory.
static func preview_over(region: int, entering: RunMap.Kind) -> bool:
	return region > 0 and entering == RunMap.Kind.BOSS
