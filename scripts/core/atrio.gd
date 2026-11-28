class_name Atrio
extends RefCounted
## Chapter II, A-2: the rules of the Átrio, the room between Morvath's chamber and the Bosque (docs/design/cap2/docs/01_MASTER_PLAN.md).
## No fight, no XP: the fountain (Game's, once, 40% of the life), the merchant (the shop), Galael's GRAÇA (one choice) and the portal, which
## opens only after the choice. The Graça is one of three: a further 35% of the life, one Blessing a rarity up, or +1 level on two Blessings.
## An option that cannot be taken (no Blessing eligible) is shown dimmed with its reason; the heal is always there, and a Graça that turns
## ineligible when it is applied falls back to it. Values PROVISIONAL (for the balance-designer). Pure rules; Rooms does the room.

enum Grace { HEAL, RARITY, LEVELS }
const IDS: Array[StringName] = [&"heal", &"rarity", &"levels"]
## The share of the most life the heal Graça gives (on top of the fountain's 40%).
const HEAL_SHARE := 0.35
## A Blessing goes up to this rarity at most (the legendary comes only by a trade or a Psalm).
const RARITY_CEILING := Boon.Rarity.EPIC
## How many Blessings the levels Graça raises.
const LEVELS_COUNT := 2

## The Graça taken (-1: none yet). The portal opens when it is set; it is set once.
var chosen := -1


func portal_open() -> bool:
	return chosen >= 0


## Takes the Graça (once). Returns false for a second choice or a bad option.
func choose(option: int) -> bool:
	if chosen >= 0 or option < 0 or option >= IDS.size():
		return false
	chosen = option
	return true


## Blessings a rarity can go up on (it has a rarity, below RARITY_CEILING).
static func rarity_pool(boons: BoonState) -> Array[Boon]:
	var out: Array[Boon] = []
	for b in boons.owned():
		if b.has_rarity() and boons.rarity(b.id) < RARITY_CEILING:
			out.append(b)
	return out


## Blessings a level can still be added to.
static func level_pool(boons: BoonState) -> Array[Boon]:
	var out: Array[Boon] = []
	for b in boons.owned():
		if boons.can_offer(b):
			out.append(b)
	return out


## The three Graças for a screen: {option, id, ok, why (text key), share}.
static func options(boons: BoonState) -> Array[Dictionary]:
	return [
		{"option": Grace.HEAL, "id": IDS[Grace.HEAL], "ok": true, "why": &"", "share": HEAL_SHARE},
		{"option": Grace.RARITY, "id": IDS[Grace.RARITY], "ok": not rarity_pool(boons).is_empty(), "why": &"grace_why_rarity", "share": HEAL_SHARE},
		{"option": Grace.LEVELS, "id": IDS[Grace.LEVELS], "ok": level_pool(boons).size() >= LEVELS_COUNT, "why": &"grace_why_levels", "share": HEAL_SHARE},
	]


## What the robot takes: levels first (it grows the build), then a rarity, else the heal.
static func bot_choice(opts: Array[Dictionary]) -> int:
	for o: Dictionary in [opts[Grace.LEVELS], opts[Grace.RARITY]]:
		if o.ok:
			return int(o.option)
	return Grace.HEAL


## Applies a Graça to the Blessings and tells what happened: {option (what was applied: the heal when the asked one was ineligible), heal
## (the share of the most life to give, 0 when none), boons (ids raised)}. rng picks among the eligible. The caller heals and shows.
static func apply(option: int, boons: BoonState, rng: RandomNumberGenerator) -> Dictionary:
	var out := {"option": Grace.HEAL, "heal": HEAL_SHARE, "boons": []}
	match option:
		Grace.RARITY:
			var pool := rarity_pool(boons)
			if not pool.is_empty():
				var b: Boon = pool[rng.randi() % pool.size()]
				if boons.raise_rarity(b):
					out = {"option": Grace.RARITY, "heal": 0.0, "boons": [b.id]}
		Grace.LEVELS:
			var pool := level_pool(boons)
			if pool.size() >= LEVELS_COUNT:
				var ids: Array = []
				for i in LEVELS_COUNT:
					var b: Boon = pool.pop_at(rng.randi() % pool.size())
					if boons.take(b, boons.rarity(b.id)) > 0:
						ids.append(b.id)
				out = {"option": Grace.LEVELS, "heal": 0.0, "boons": ids}
	return out
