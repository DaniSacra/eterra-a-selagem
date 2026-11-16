class_name MasteryCurve
extends Resource
## A hero's Mastery (docs/design/warrior_spec.md 4.4, guardian_spec.md 7): permanent, one per hero, never lost (a death
## keeps everything the run gave). Each level unlocks one Gift (TalentDef) and adds one point of Devotion. Only the XP
## is saved (heroes.<id>.mastery_xp); the level comes out of it. The numbers are data (_mastery in tools/make_data.gd).

@export var max_level := 20
## XP from level n to n + 1: xp_base + xp_step * (n - 1) (40, 50, 60 ... 220; 2470 from 1 to 20).
@export var xp_base := 40
@export var xp_step := 10
## Devotion (the room for Gifts): devotion_base + level.
@export var devotion_base := 5

@export_group("Sources")
## A fight room won, a guardian (miniboss) won, each of Morvath's phases reached (at most phase_max), the sealing.
@export var room_xp := 10
@export var guardian_xp := 25
@export var phase_xp := 10
@export var phase_max := 4
@export var victory_xp := 50

@export_group("First times")
@export var first_boon_xp := 2
@export var first_elo_xp := 10
@export var first_psalm_xp := 25
@export var first_guardian_xp := 25
@export var first_victory_xp := 100

@export_group("Older saves")
## A save from before Mastery gets it once: retro_run_xp a run and retro_win_xp more a win, up to retro_max_level.
@export var retro_run_xp := 40
@export var retro_win_xp := 60
@export var retro_max_level := 5


## XP from level n to n + 1 (0 at the top).
func needed(n: int) -> int:
	if n >= max_level:
		return 0
	return xp_base + xp_step * (maxi(n, 1) - 1)


## XP from level 1 to the start of level n.
func total_to(n: int) -> int:
	var total := 0
	for i in range(1, clampi(n, 1, max_level)):
		total += needed(i)
	return total


## The level this much XP reaches (1 to max_level).
func level_of(xp: int) -> int:
	var n := 1
	while n < max_level and xp >= total_to(n + 1):
		n += 1
	return n


## XP gathered inside the current level (for a bar), and what the level needs.
func progress(xp: int) -> Vector2i:
	var n := level_of(xp)
	return Vector2i(xp - total_to(n), needed(n))


func devotion(level: int) -> int:
	return devotion_base + level


## The XP one run gives, by source, and its total. run: rooms (fight rooms won), guardians (guardian rooms won),
## phase (Morvath's highest phase reached, 0 when not met), victory (bool) and the first times of this run:
## new_boons (Blessings seen for the first time), new_elos, new_psalms, first_guardian, first_victory (bools).
func run_xp(run: Dictionary) -> Dictionary:
	var out := {
		"rooms": room_xp * int(run.get("rooms", 0)),
		"guardians": guardian_xp * int(run.get("guardians", 0)),
		"phases": phase_xp * clampi(int(run.get("phase", 0)), 0, phase_max),
		"victory": victory_xp if run.get("victory", false) else 0,
		"first_boons": first_boon_xp * int(run.get("new_boons", 0)),
		"first_elos": first_elo_xp * int(run.get("new_elos", 0)),
		"first_psalms": first_psalm_xp * int(run.get("new_psalms", 0)),
		"first_guardian": first_guardian_xp if run.get("first_guardian", false) else 0,
		"first_victory": first_victory_xp if run.get("first_victory", false) else 0,
	}
	var total := 0
	for k: String in out:
		total += int(out[k])
	out["total"] = total
	return out


## The XP an older save gets once for what was already played (never past retro_max_level).
func retro_xp(runs: int, wins: int) -> int:
	return mini(retro_run_xp * maxi(runs, 0) + retro_win_xp * maxi(wins, 0), total_to(retro_max_level))
